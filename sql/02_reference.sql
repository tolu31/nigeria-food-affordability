-- 02_reference.sql
-- Pack sizes and quality figures copied from the World Bank ticker information file
-- (NGA_RTP_ticker_info_mkt_2007_2026-11-02.csv). Prices are quoted per PACK.
CREATE SCHEMA IF NOT EXISTS staging;

DROP TABLE IF EXISTS staging.commodity_ref;
CREATE TABLE staging.commodity_ref AS
SELECT * FROM (VALUES
  ('beans',       'Beans (red)',     '2.5 KG', 2.5,  NULL, 14.25, 0.95),
  ('eggs',        'Eggs',            '30 pcs', NULL, 30,   18.03, 0.98),
  ('fish',        'Fish',            '1 KG',   1,    NULL, 12.87, 0.91),
  ('gari_fao',    'Gari (white)',    '1 KG',   1,    NULL, 10.34, 0.92),
  ('groundnuts',  'Groundnuts',      '2.2 KG', 2.2,  NULL, 15.00, 0.95),
  ('maize_fao',   'Maize (white)',   '1 KG',   1,    NULL, 11.55, 0.99),
  ('maize_flour', 'Maize flour',     '2.1 KG', 2.1,  NULL, 13.68, 0.94),
  ('meat_beef',   'Meat (beef)',     '1 KG',   1,    NULL, 14.79, 0.97),
  ('meat_goat',   'Meat (goat)',     '1 KG',   1,    NULL, 13.91, 0.97),
  ('milk',        'Milk (powder)',   '400 G',  0.4,  NULL, 14.66, 0.95),
  ('millet',      'Millet',          '2.6 KG', 2.6,  NULL, 28.76, 0.96),
  ('onions',      'Onions',          '0.5 KG', 0.5,  NULL, 13.37, 0.96),
  ('rice',        'Rice (imported)', '2.8 KG', 2.8,  NULL, 20.56, 0.98),
  ('rice_fao',    'Rice (imported)', '1 KG',   1,    NULL, 9.72,  0.99),
  ('sorghum_fao', 'Sorghum (white)', '1 KG',   1,    NULL, 6.77,  0.99),
  ('yam',         'Yam',             '2.5 KG', 2.5,  NULL, 20.93, 0.92)
) AS t(ticker, item_name, pack_size, kg_per_pack, pcs_per_pack, data_coverage_pct, r2_imputation);

SELECT COUNT(*) AS items FROM staging.commodity_ref;