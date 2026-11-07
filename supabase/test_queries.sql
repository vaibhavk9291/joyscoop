-- ====================================================================
-- Joyscoop: Verification & Test Queries
-- ====================================================================

-- --------------------------------------------------------------------
-- Test Query 1: Verify Seed Products
-- Checks that all 4 fixed products exist with correct prices and sort orders.
-- --------------------------------------------------------------------
select
  id,
  name,
  price as "price_inr",
  sort_order,
  is_active
from public.products
order by sort_order asc;

-- --------------------------------------------------------------------
-- Test Query 2: Simulation of Sales & Verification of daily_summary & daily_totals
-- --------------------------------------------------------------------
do $$
declare
  softy_id uuid;
  coffee_id uuid;
  today_date date := (now() at time zone 'Asia/Kolkata')::date;
begin
  select id into softy_id from public.products where name = 'Softy' limit 1;
  select id into coffee_id from public.products where name = 'Cold Coffee' limit 1;

  -- 2x Softy (+1, +1)
  insert into public.sales_events (product_id, delta, business_date)
  values (softy_id, 1, today_date), (softy_id, 1, today_date);

  -- 1x Cold Coffee (+1)
  insert into public.sales_events (product_id, delta, business_date)
  values (coffee_id, 1, today_date);

  -- 1x Softy reversal (-1) -> net softy should be 1
  insert into public.sales_events (product_id, delta, business_date)
  values (softy_id, -1, today_date);
end $$;

-- Query daily summary:
select
  business_date,
  product_name,
  units_sold,
  revenue
from public.daily_summary
where business_date = (now() at time zone 'Asia/Kolkata')::date
order by product_name;

-- Query daily totals:
select
  business_date,
  total_units,
  total_revenue
from public.daily_totals
where business_date = (now() at time zone 'Asia/Kolkata')::date;

-- --------------------------------------------------------------------
-- Test Query 3: Negative Delta Guard Test (Must fail with exception)
-- Attempts to decrement a product whose sales count is 0 on a date.
-- --------------------------------------------------------------------
do $$
declare
  crush_id uuid;
  test_date date := '2026-01-01';
begin
  select id into crush_id from public.products where name = 'Cold Coffee with Crush' limit 1;

  -- This insert MUST throw: "Cannot decrement: sales total for product ... is already 0"
  insert into public.sales_events (product_id, delta, business_date)
  values (crush_id, -1, test_date);
end $$;

