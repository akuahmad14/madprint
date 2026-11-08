-- PrintTrack Mobile - skema Supabase
-- Jalankan di Supabase Dashboard > SQL Editor

create extension if not exists "pgcrypto";

-- ===== ENUM =====
create type user_role as enum ('admin', 'operator', 'staff');
create type order_status as enum (
  'diterima', 'antrean_produksi', 'sedang_diproses',
  'finishing', 'siap_diambil', 'selesai', 'tertunda', 'dibatalkan'
);

-- ===== TABEL =====
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role user_role not null default 'operator',
  created_at timestamptz not null default now()
);

create table customers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text,
  created_at timestamptz not null default now()
);

create sequence order_number_seq start 1;

create table orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique
    default ('SPK-' || to_char(now(), 'YYMM') || '-' || lpad(nextval('order_number_seq')::text, 4, '0')),
  customer_id uuid not null references customers(id),
  product_type text not null,
  specifications text,
  quantity int not null check (quantity > 0),
  price numeric(14,2) not null default 0 check (price >= 0),
  deadline timestamptz,
  notes text,
  status order_status not null default 'diterima',
  created_by uuid not null references profiles(id) default auth.uid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index orders_status_idx on orders(status);
create index orders_deadline_idx on orders(deadline);

create table order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  item_name text not null,
  specifications text,
  quantity int not null check (quantity > 0),
  unit_price numeric(14,2) not null default 0
);

create table order_status_history (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  old_status order_status,
  new_status order_status not null,
  updated_by uuid not null references profiles(id) default auth.uid(),
  notes text,
  created_at timestamptz not null default now()
);
create index osh_order_idx on order_status_history(order_id, created_at desc);

create table order_files (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  file_path text not null,
  uploaded_by uuid not null references profiles(id) default auth.uid(),
  created_at timestamptz not null default now()
);

-- ===== FUNGSI BANTU =====
create or replace function current_role_name() returns user_role
language sql stable security definer set search_path = public as $$
  select role from profiles where id = auth.uid()
$$;

-- Profil otomatis saat user baru dibuat (peran default operator; admin mengubahnya)
create or replace function handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into profiles (id, full_name, role)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', new.email), 'operator');
  return new;
end $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- Riwayat awal saat pesanan dibuat
create or replace function log_initial_status() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into order_status_history (order_id, old_status, new_status, updated_by, notes)
  values (new.id, null, new.status, new.created_by, 'Pesanan dibuat');
  return new;
end $$;

create trigger orders_initial_history
  after insert on orders
  for each row execute function log_initial_status();

create or replace function touch_updated_at() returns trigger
language plpgsql as $$
begin new.updated_at = now(); return new; end $$;

create trigger orders_touch before update on orders
  for each row execute function touch_updated_at();

-- ===== ATURAN PERUBAHAN STATUS (divalidasi di server) =====
-- Aplikasi memanggil rpc('change_order_status'); status tidak diubah langsung via update.
create or replace function change_order_status(
  p_order_id uuid, p_new_status order_status, p_notes text default null
) returns void
language plpgsql security definer set search_path = public as $$
declare
  v_role user_role := current_role_name();
  v_old order_status;
  v_allowed boolean := false;
begin
  if auth.uid() is null or v_role is null then
    raise exception 'Tidak terautentikasi';
  end if;

  select status into v_old from orders where id = p_order_id for update;
  if not found then raise exception 'Pesanan tidak ditemukan'; end if;
  if v_old = p_new_status then raise exception 'Status sudah sama'; end if;
  if v_old in ('selesai', 'dibatalkan') then
    raise exception 'Pesanan sudah final dan tidak dapat diubah';
  end if;

  -- Alur maju yang valid
  v_allowed := (v_old, p_new_status) in (
    ('diterima','antrean_produksi'),
    ('antrean_produksi','sedang_diproses'),
    ('sedang_diproses','finishing'),
    ('finishing','siap_diambil'),
    ('siap_diambil','selesai')
  ) or p_new_status in ('tertunda','dibatalkan')
    or (v_old = 'tertunda' and p_new_status in ('antrean_produksi','sedang_diproses','finishing'));

  if not v_allowed then
    raise exception 'Transisi % -> % tidak diizinkan', v_old, p_new_status;
  end if;

  -- Hak akses per peran
  if v_role = 'admin' then
    null; -- boleh semua
  elsif v_role = 'operator' then
    if p_new_status not in ('sedang_diproses','finishing','tertunda') then
      raise exception 'Operator tidak berhak mengubah ke status %', p_new_status;
    end if;
  elsif v_role = 'staff' then
    if p_new_status not in ('siap_diambil','selesai') then
      raise exception 'Staf tidak berhak mengubah ke status %', p_new_status;
    end if;
  end if;

  if p_new_status in ('tertunda','dibatalkan') and coalesce(trim(p_notes), '') = '' then
    raise exception 'Catatan wajib diisi untuk status %', p_new_status;
  end if;

  perform set_config('printtrack.via_rpc', 'on', true);
  update orders set status = p_new_status where id = p_order_id;
  perform set_config('printtrack.via_rpc', 'off', true);
  insert into order_status_history (order_id, old_status, new_status, updated_by, notes)
  values (p_order_id, v_old, p_new_status, auth.uid(), p_notes);
end $$;

-- ===== ROW LEVEL SECURITY =====
alter table profiles enable row level security;
alter table customers enable row level security;
alter table orders enable row level security;
alter table order_items enable row level security;
alter table order_status_history enable row level security;
alter table order_files enable row level security;

-- profiles: semua user login bisa baca; hanya admin mengubah
create policy profiles_select on profiles for select to authenticated using (true);
create policy profiles_admin_update on profiles for update to authenticated
  using (current_role_name() = 'admin') with check (current_role_name() = 'admin');

-- customers: semua baca; admin tulis
create policy customers_select on customers for select to authenticated using (true);
create policy customers_admin_write on customers for all to authenticated
  using (current_role_name() = 'admin') with check (current_role_name() = 'admin');

-- orders: semua baca; admin insert/update data (status hanya lewat RPC)
create policy orders_select on orders for select to authenticated using (true);
create policy orders_admin_insert on orders for insert to authenticated
  with check (current_role_name() = 'admin');
create policy orders_admin_update on orders for update to authenticated
  using (current_role_name() = 'admin') with check (current_role_name() = 'admin');

-- Cegah admin mengubah status langsung lewat update biasa (harus lewat RPC)
create or replace function block_direct_status_change() returns trigger
language plpgsql as $$
begin
  if new.status is distinct from old.status
     and current_setting('printtrack.via_rpc', true) is distinct from 'on' then
    raise exception 'Ubah status melalui change_order_status';
  end if;
  return new;
end $$;

create trigger orders_block_status before update on orders
  for each row execute function block_direct_status_change();

-- order_items & order_files
create policy items_select on order_items for select to authenticated using (true);
create policy items_admin_write on order_items for all to authenticated
  using (current_role_name() = 'admin') with check (current_role_name() = 'admin');
create policy files_select on order_files for select to authenticated using (true);
create policy files_admin_write on order_files for all to authenticated
  using (current_role_name() = 'admin') with check (current_role_name() = 'admin');

-- riwayat: baca saja dari klien; penulisan hanya lewat fungsi security definer
create policy history_select on order_status_history for select to authenticated using (true);

-- ===== REALTIME =====
alter publication supabase_realtime add table orders;
alter publication supabase_realtime add table order_status_history;

-- Setelah membuat akun pertama, jadikan admin:
-- update profiles set role = 'admin' where id = '<UUID-USER>';
