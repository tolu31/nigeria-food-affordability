# Data notes

| # | Note | Decision |
|---|------|----------|
| 1 | Prices are model-based estimates. The documentation lists a data coverage of 6.77% to 28.76% per item and an imputation model (two-stage cubist). | State this clearly in the README and treat results as estimates. |
| 2 | Prices are quoted per pack (for example beans 2.5 kg, rice 2.8 kg, eggs 30 pieces, milk 400 g). | Convert to price per kg (per piece for eggs) before any comparison or basket. |
| 3 | The file has 74 location series, 239 months each (Jan 2007 to Nov 2026). Some are aggregates (National Average, Market Average, a Kano State row, geopolitical zones). 53 ordinary markets are in Borno, Yobe and Adamawa. | Do not average all series into a national figure. Use the aggregate series or weight by state, after checking how they are built. |
| 4 | Nov 2026 is the current month and provisional. | Last complete month is Oct 2026. |
| 5 | rice and rice_fao are both imported rice. | Use one rice series in the basket. |
| 6 | The c_ column (close) is used as the monthly price. For rice since 2025 the open, high, low and close averages are within a few percent of each other, and no row has a high below its low. Using the mean of all four would raise rice by about 1.6%. | Keep c_ and record it as an assumption. |
| 7 | The quality columns (data_coverage, data_coverage_recent, index_confidence_score, spatially_interpolated) were constant across months for the market checked. | They describe a series, not individual months. Check variation across markets before using them. |
| 8 | Oct 2026 national averages for gari, maize, sorghum and millet may be low for what buyers pay. | Validate a few price levels against NBS published prices and note it as a limitation. |
