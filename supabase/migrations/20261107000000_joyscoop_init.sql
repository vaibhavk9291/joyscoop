-- ====================================================================
-- Joyscoop: Phase 1 - Database Schema & Backend Migration
-- Timezone: Asia/Kolkata (IST)
-- ====================================================================

-- 1. EXTENSIONS
create extension if not exists "pgcrypto";
create extension if not exists "uuid-ossp";

-- 2. PROFILES TABLE
-- Stores staff display names for greetings
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  created_at timestamptz not null default now()
);

-- 3. PRODUCTS TABLE
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  price integer not null check (price >= 0),
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- Seed Fixed Products (idempotent seed)
insert into public.products (name, price, sort_order)
values
  ('Softy', 30, 1),
  ('Cold Coffee', 40, 2),
  ('Cold Coffee with Crush', 50, 3),
  ('Cold Coffee with Vanilla', 60, 4)
on conflict do nothing;

-- 4. SALES EVENTS TABLE (APPEND-ONLY)
create table if not exists public.sales_events (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete restrict,
  delta smallint not null check (delta in (1, -1)),
  unit_price integer not null,
  business_date date not null default (now() at time zone 'Asia/Kolkata')::date,
  created_by uuid default auth.uid() references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

-- Performance indices for rapid realtime summaries and filtering
create index if not exists idx_sales_events_date_prod on public.sales_events (business_date, product_id);
create index if not exists idx_sales_events_created_at on public.sales_events (created_at desc);

-- 5. TRIGGERS

-- Trigger Function A: Unit price snapshot & defaults
-- Automatically fetches product price at insert time if not provided,
-- and ensures business_date and created_by default correctly.
create or replace function public.trg_fn_sales_events_before_insert()
returns trigger
language plpgsql
security definer
as $$
declare
  prod_price integer;
  current_sum integer;
begin
  -- Resolve snapshot price from products table
  select price into prod_price
  from public.products
  where id = new.product_id;

  if prod_price is null then
    raise exception 'Product % does not exist', new.product_id;
  end if;

  new.unit_price := prod_price;

  -- Ensure business_date defaults to Asia/Kolkata date
  if new.business_date is null then
    new.business_date := (now() at time zone 'Asia/Kolkata')::date;
  end if;

  -- Ensure created_by defaults to authenticated user if available
  if new.created_by is null then
    new.created_by := auth.uid();
  end if;

  -- Block any -1 event if it would cause that product's daily total to drop below 0
  if new.delta = -1 then
    select coalesce(sum(delta), 0)
    into current_sum
    from public.sales_events
    where product_id = new.product_id
      and business_date = new.business_date;

    if current_sum <= 0 then
      raise exception 'Cannot decrement: sales total for product % on % is already %',
        new.product_id, new.business_date, current_sum;
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_sales_events_before_insert on public.sales_events;
create trigger trg_sales_events_before_insert
before insert on public.sales_events
for each row
execute function public.trg_fn_sales_events_before_insert();

-- 6. VIEWS FOR REPORTING

-- View: daily_summary
create or replace view public.daily_summary as
select
  se.business_date,
  se.product_id,
  p.name as product_name,
  coalesce(sum(se.delta), 0)::integer as units_sold,
  coalesce(sum(se.delta * se.unit_price), 0)::integer as revenue
from public.sales_events se
join public.products p on p.id = se.product_id
group by se.business_date, se.product_id, p.name;

-- View: daily_totals
create or replace view public.daily_totals as
select
  business_date,
  coalesce(sum(delta), 0)::integer as total_units,
  coalesce(sum(delta * unit_price), 0)::integer as total_revenue
from public.sales_events
group by business_date;

-- 7. ROW LEVEL SECURITY (RLS)
alter table public.products enable row level security;
alter table public.profiles enable row level security;
alter table public.sales_events enable row level security;

-- Products RLS (authenticated users can read)
create policy "Allow authenticated read products"
  on public.products for select
  to authenticated
  using (true);

-- Profiles RLS (authenticated users can read all profiles; users can update own)
create policy "Allow authenticated read profiles"
  on public.profiles for select
  to authenticated
  using (true);

create policy "Allow users update own profile"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id);

create policy "Allow users insert own profile"
  on public.profiles for insert
  to authenticated
  with check (auth.uid() = id);

-- Sales Events RLS (append-only: select and insert permitted, NO update, NO delete)
create policy "Allow authenticated read sales_events"
  on public.sales_events for select
  to authenticated
  using (true);

create policy "Allow authenticated insert sales_events"
  on public.sales_events for insert
  to authenticated
  with check (true);

-- Explicitly ensure NO update or delete policies exist on sales_events to guarantee immutability.

-- 8. ENABLE REALTIME ON SALES_EVENTS
alter publication supabase_realtime add table public.sales_events;
alter table public.sales_events replica identity full;

