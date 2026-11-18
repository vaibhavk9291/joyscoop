-- ====================================================================
-- Joyscoop: Update Softy price back to 30
-- ====================================================================

-- 1. Ensure authenticated users can update products table if needed
do $$
begin
  if not exists (
    select 1 from pg_policies 
    where schemaname = 'public' 
      and tablename = 'products' 
      and policyname = 'Allow authenticated update products'
  ) then
    create policy "Allow authenticated update products"
      on public.products for update
      to authenticated
      using (true)
      with check (true);
  end if;
end $$;

-- 2. Update the price of "Softy" to 30
UPDATE public.products
SET price = 30
WHERE name = 'Softy' OR (name ILIKE '%softy%' AND name NOT ILIKE '%choco%');

-- 3. Verify all product prices
SELECT id, name, price, sort_order, is_active
FROM public.products
ORDER BY sort_order ASC;

