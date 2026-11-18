-- 1. Shape of the data
SELECT COUNT(*)                         AS rows,
       COUNT(DISTINCT geo_id)           AS markets,
       COUNT(DISTINCT adm1_name)        AS states,
       MIN(price_date)                  AS first_month,
       MAX(price_date)                  AS last_month
FROM raw.rtfp;

-- 2. Does every market have every month?
SELECT months_per_market, COUNT(*) AS markets
FROM (SELECT geo_id, COUNT(*) AS months_per_market FROM raw.rtfp GROUP BY geo_id) t
GROUP BY months_per_market
ORDER BY months_per_market;

-- 3. How much price data exists for each food item? (c_ columns, first look only)
SELECT 'beans' AS item, COUNT(NULLIF(c_beans,'')) AS months_with_value FROM raw.rtfp
UNION ALL SELECT 'eggs',         COUNT(NULLIF(c_eggs,''))         FROM raw.rtfp
UNION ALL SELECT 'fish',         COUNT(NULLIF(c_fish,''))         FROM raw.rtfp
UNION ALL SELECT 'gari_fao',     COUNT(NULLIF(c_gari_fao,''))     FROM raw.rtfp
UNION ALL SELECT 'groundnuts',   COUNT(NULLIF(c_groundnuts,''))   FROM raw.rtfp
UNION ALL SELECT 'maize_fao',    COUNT(NULLIF(c_maize_fao,''))    FROM raw.rtfp
UNION ALL SELECT 'maize_flour',  COUNT(NULLIF(c_maize_flour,''))  FROM raw.rtfp
UNION ALL SELECT 'meat_beef',    COUNT(NULLIF(c_meat_beef,''))    FROM raw.rtfp
UNION ALL SELECT 'meat_goat',    COUNT(NULLIF(c_meat_goat,''))    FROM raw.rtfp
UNION ALL SELECT 'milk',         COUNT(NULLIF(c_milk,''))         FROM raw.rtfp
UNION ALL SELECT 'millet',       COUNT(NULLIF(c_millet,''))       FROM raw.rtfp
UNION ALL SELECT 'onions',       COUNT(NULLIF(c_onions,''))       FROM raw.rtfp
UNION ALL SELECT 'rice',         COUNT(NULLIF(c_rice,''))         FROM raw.rtfp
UNION ALL SELECT 'rice_fao',     COUNT(NULLIF(c_rice_fao,''))     FROM raw.rtfp
UNION ALL SELECT 'sorghum_fao',  COUNT(NULLIF(c_sorghum_fao,''))  FROM raw.rtfp
UNION ALL SELECT 'yam',          COUNT(NULLIF(c_yam,''))          FROM raw.rtfp
UNION ALL SELECT 'food_index',   COUNT(NULLIF(c_food_price_index,'')) FROM raw.rtfp;

-- 4. A first look at real values: Lagos-area and Kano markets, most recent months
SELECT adm1_name, mkt_name, price_date, c_rice, c_beans, c_gari_fao, c_yam, c_food_price_index
FROM raw.rtfp
WHERE adm1_name IN ('Lagos', 'Kano')
ORDER BY price_date DESC, adm1_name, mkt_name
LIMIT 12;