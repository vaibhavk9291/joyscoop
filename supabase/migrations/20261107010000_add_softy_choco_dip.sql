-- ====================================================================
-- Joyscoop: Add "Softy Choco Dip" and standardize coffee names
-- ====================================================================

-- 1. Insert "Softy Choco Dip" if it doesn't already exist
insert into public.products (name, price, sort_order, is_active)
select 'Softy Choco Dip', 40, 2, true
where not exists (
  select 1 from public.products where name = 'Softy Choco Dip'
);

-- 2. Update names and sort orders to match requested menu:
-- 1: Softy (30)
-- 2: Softy Choco Dip (40)
-- 3: Cold Coffee (40)
-- 4: Coffee with Crush (50)
-- 5: Coffee with Vanilla (60)

update public.products set sort_order = 1 where name = 'Softy';
update public.products set sort_order = 2 where name = 'Softy Choco Dip';

-- Update Cold Coffee with Crush -> Coffee with Crush
update public.products
set name = 'Coffee with Crush', sort_order = 4
where name = 'Cold Coffee with Crush' or name = 'Coffee with Crush';

-- Update Cold Coffee with Vanilla -> Coffee with Vanilla (Price: 55)
update public.products
set name = 'Coffee with Vanilla', price = 55, sort_order = 5
where name = 'Cold Coffee with Vanilla' or name = 'Coffee with Vanilla';

-- Ensure Cold Coffee sort_order = 3
update public.products
set sort_order = 3
where name = 'Cold Coffee';

-- 3. Verify the 5 products in order
select id, name, price, sort_order, is_active
from public.products
order by sort_order asc;

