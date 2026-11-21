-- 03_prices_long.sql
-- One row = one market + one month + one food item. Price converted to per kg (or per egg).
CREATE SCHEMA IF NOT EXISTS staging;
DROP TABLE IF EXISTS staging.food_prices_long;

CREATE TABLE staging.food_prices_long AS
SELECT
    r.geo_id,
    r.adm1_name                  AS state,
    r.adm2_name                  AS lga,
    r.mkt_name                   AS market,
    r.lat::numeric               AS lat,
    r.lon::numeric               AS lon,
    r.price_date::date           AS price_date,
    r.year::int                  AS year,
    r.month::int                 AS month,
    u.ticker,
    c.item_name,
    c.pack_size,
    u.price_per_pack::numeric    AS price_per_pack,
    CASE WHEN c.kg_per_pack IS NOT NULL
         THEN ROUND(u.price_per_pack::numeric / c.kg_per_pack, 2) END   AS price_per_kg,
    CASE WHEN c.pcs_per_pack IS NOT NULL
         THEN ROUND(u.price_per_pack::numeric / c.pcs_per_pack, 2) END  AS price_per_piece,
    u.trust::numeric             AS trust,
    r.spatially_interpolated,
    r.data_coverage,
    r.index_confidence_score
FROM raw.rtfp r
CROSS JOIN LATERAL (VALUES
    ('beans',       r.c_beans,       r.trust_beans),
    ('eggs',        r.c_eggs,        r.trust_eggs),
    ('fish',        r.c_fish,        r.trust_fish),
    ('gari_fao',    r.c_gari_fao,    r.trust_gari_fao),
    ('groundnuts',  r.c_groundnuts,  r.trust_groundnuts),
    ('maize_fao',   r.c_maize_fao,   r.trust_maize_fao),
    ('maize_flour', r.c_maize_flour, r.trust_maize_flour),
    ('meat_beef',   r.c_meat_beef,   r.trust_meat_beef),
    ('meat_goat',   r.c_meat_goat,   r.trust_meat_goat),
    ('milk',        r.c_milk,        r.trust_milk),
    ('millet',      r.c_millet,      r.trust_millet),
    ('onions',      r.c_onions,      r.trust_onions),
    ('rice',        r.c_rice,        r.trust_rice),
    ('rice_fao',    r.c_rice_fao,    r.trust_rice_fao),
    ('sorghum_fao', r.c_sorghum_fao, r.trust_sorghum_fao),
    ('yam',         r.c_yam,         r.trust_yam)
) AS u(ticker, price_per_pack, trust)
JOIN staging.commodity_ref c ON c.ticker = u.ticker
WHERE NULLIF(u.price_per_pack, '') IS NOT NULL;

ALTER TABLE staging.food_prices_long ADD PRIMARY KEY (geo_id, price_date, ticker);


-- a. Row count: 17,686 rows x 16 items = 282,976
SELECT COUNT(*) AS rows FROM staging.food_prices_long;

-- b. Pack prices per item (should be 16 rows of 17,686 each, with no zero or negative minimums)
SELECT ticker, item_name, pack_size, COUNT(*) AS rows,
       ROUND(MIN(price_per_pack),0) AS min_pack_price,
       ROUND(AVG(price_per_pack),0) AS avg_pack_price,
       ROUND(MAX(price_per_pack),0) AS max_pack_price
FROM staging.food_prices_long
GROUP BY ticker, item_name, pack_size
ORDER BY ticker;

-- c. Per-kg prices in the last complete month (Oct 2026), national average
SELECT ticker, item_name, ROUND(AVG(price_per_kg),0) AS avg_naira_per_kg
FROM staging.food_prices_long
WHERE price_date = DATE '2026-10-01' AND price_per_kg IS NOT NULL
GROUP BY ticker, item_name
ORDER BY avg_naira_per_kg DESC;


-- d. Is c_ (close) a sensible monthly price? Compare open, high, low, close for rice
SELECT ROUND(AVG(o_rice::numeric),1) AS avg_open,
       ROUND(AVG(h_rice::numeric),1) AS avg_high,
       ROUND(AVG(l_rice::numeric),1) AS avg_low,
       ROUND(AVG(c_rice::numeric),1) AS avg_close,
       COUNT(*) FILTER (WHERE h_rice::numeric < l_rice::numeric) AS high_below_low
FROM raw.rtfp
WHERE price_date >= '2025-01-01';

-- e. What do the quality columns look like?
SELECT mkt_name, price_date, components, start_dense_data, last_survey_point,
       data_coverage, data_coverage_recent, index_confidence_score, spatially_interpolated
FROM raw.rtfp
WHERE mkt_name = 'Dawanau'
ORDER BY price_date DESC
LIMIT 6;

-- f. Markets per state (this is your geographic scope)
SELECT adm1_name AS state, COUNT(DISTINCT geo_id) AS markets
FROM raw.rtfp
GROUP BY adm1_name
ORDER BY markets DESC, state;


-- g. Which geo_ids are not ordinary markets?
SELECT DISTINCT geo_id, adm1_name, adm2_name, mkt_name, lat, lon
FROM raw.rtfp
WHERE adm1_name IN ('Market Average', 'National Average', 'Kano State (1)')
   OR adm1_name LIKE 'Geopolitical%'
ORDER BY adm1_name, mkt_name;


-- h. Market-level quality fields
SELECT spatially_interpolated, COUNT(DISTINCT geo_id) AS series,
       MIN(data_coverage) AS min_coverage, MAX(data_coverage) AS max_coverage
FROM raw.rtfp
GROUP BY spatially_interpolated
ORDER BY spatially_interpolated;


-- i. October 2026, price per kg
SELECT ticker,
       ROUND(AVG(price_per_kg) FILTER (WHERE state = 'National Average'), 0) AS national_row,
       ROUND(AVG(price_per_kg) FILTER (WHERE state NOT IN ('National Average','Market Average','Kano State (1)')
                                          AND state NOT LIKE 'Geopolitical%'), 0) AS simple_market_avg
FROM staging.food_prices_long
WHERE price_date = DATE '2026-10-01' AND price_per_kg IS NOT NULL
GROUP BY ticker
ORDER BY ticker;