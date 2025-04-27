# 📊 SQL Portfolio: Marketing Data Analysis Projects

Welcome to my SQL portfolio!  
This repository contains examples of projects focused on analyzing marketing campaign data from Facebook Ads and Google Ads.  
Each project demonstrates practical applications of SQL for business analysis, including data aggregation, KPI calculation, campaign performance evaluation, and trend analysis over time.

---

## 🗄 Dataset Description

The database includes the following key tables:

- **facebook_ads_basic_daily**: Daily performance metrics for Facebook advertising campaigns, including spend, impressions, clicks, reach, leads, and conversion value.
- **facebook_adset**: Details about Facebook ad sets, such as ad set names and their link to campaigns.
- **facebook_campaign**: Information about Facebook campaigns (campaign names and identifiers).
- **google_ads_basic_daily**: Daily performance metrics for Google Ads campaigns, with the same key fields as in `facebook_ads_basic_daily` (spend, impressions, clicks, reach, leads, and conversion value).

The dataset captures daily advertising activities across multiple digital platforms.  
It includes financial data (spend), user interaction metrics (impressions, clicks), audience reach, lead generation, and conversion outcomes.  
Such a structure enables detailed campaign efficiency analysis, KPI calculation, and dynamic performance evaluation to support data-driven marketing decisions.

---

## 🛠 Projects

### 1. [facebook_google_ads_data_aggregation.sql](facebook_google_ads_data_aggregation.sql)

**Objective:**  
To consolidate daily Facebook Ads and Google Ads data into a unified report.  
Aggregates spend, impressions, clicks, and conversion value by ad date, media source, campaign name, and ad set name.

**Techniques:**

- Data merging using `LEFT JOIN` and `UNION ALL`.
- Creation of a unified media source field.
- Aggregation of advertising metrics grouped by multiple dimensions.

---

### 2. [top_campaign_romi_analysis.sql](top_campaign_romi_analysis.sql)

**Objective:**  
To identify the marketing campaign with the highest ROMI (Return on Marketing Investment) among campaigns with significant spending.  
Additionally, to determine the best-performing ad set within the top campaign based on ROMI.

**Techniques:**

- Conditional aggregation and filtering using `GROUP BY` and `HAVING`.
- ROMI calculation with basic SQL aggregation.
- Sorting aggregated results to select top performers.

---

### 3. [utm_campaign_decoding_and_ads_metrics.sql](utm_campaign_decoding_and_ads_metrics.sql)

**Objective:**  
To extract and decode the `utm_campaign` parameter from advertising URL parameters.  
To calculate core advertising KPIs such as CTR (Click-Through Rate), CPC (Cost Per Click), CPM (Cost Per Mille), and ROMI.

**Techniques:**

- Regular expression parsing to extract UTM fields.
- URL decoding via a custom SQL function.
- Handling missing or invalid data.
- Safe division in metric calculations using `CASE` to avoid division-by-zero errors.

---

### 4. [ads_metrics_monthly_trends_analysis.sql](ads_metrics_monthly_trends_analysis.sql)

**Objective:**  
To analyze monthly advertising performance trends by campaign.  
To calculate month-over-month percent changes for key KPIs like CPM, CTR, and ROMI.

**Techniques:**

- Month-based aggregation using `DATE_TRUNC`.
- Use of window functions (`LAG`) to calculate period-over-period dynamics.
- Percent change computation to monitor campaign trends over time.

---

## ✍🏻 Final Note

These projects aim to reflect practical approaches to marketing campaign analysis using SQL.  
They showcase techniques for consolidating multi-source data, calculating business-critical KPIs, and evaluating advertising efficiency across time.

I am open to professional discussions, feedback, and collaboration on topics related to data analysis and marketing insights.

Thank you for your attention and interest!
