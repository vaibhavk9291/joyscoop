-- ====================================================================
-- Joyscoop: Update Softy price from 30 to 25
-- ====================================================================

-- 1. Update the price of "Softy" to 25
UPDATE public.products
SET price = 25
WHERE name = 'Softy' OR (name ILIKE '%softy%' AND name NOT ILIKE '%choco%');

-- 2. Verify all product prices
SELECT id, name, price, sort_order, is_active
FROM public.products
ORDER BY sort_order ASC;

