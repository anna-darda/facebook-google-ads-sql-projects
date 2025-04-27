-- Project: Ads Metrics Monthly Trends Analysis
-- Description: Aggregating advertising performance metrics by month and utm_campaign, then calculating monthly percent changes for key KPIs such as CPM, CTR, and ROMI.
-- The query uses window functions to assess performance trends over time for each campaign.


CREATE OR REPLACE FUNCTION pg_temp.decode_url_part(p varchar) RETURNS varchar AS $$
SELECT
    convert_from(
        CAST(E'\\x' || string_agg(
            CASE 
                WHEN length(r.m[1]) = 1 THEN encode(convert_to(r.m[1], 'SQL_ASCII'), 'hex')
                ELSE substring(r.m[1] FROM 2 FOR 2) 
            END, '') AS bytea
        ), 'UTF8'
    )
FROM regexp_matches($1, '%[0-9a-f][0-9a-f]|.', 'gi') AS r(m);
$$ LANGUAGE SQL IMMUTABLE STRICT;

with all_ads_data as (
select 
	fabd.ad_date,
	coalesce(fabd.spend,0) as spend,
	coalesce(fabd.impressions,0) as impressions,
	coalesce(fabd.reach,0) as reach,
	coalesce(fabd.clicks,0) as clicks,
	coalesce(fabd.leads,0) as leads,
	coalesce(fabd.value,0) as value,
	fabd.url_parameters 
from  
	public.facebook_ads_basic_daily fabd
	
union all

select 
	gabd.ad_date,
	coalesce(gabd.spend,0) as spend, 
	coalesce(gabd.impressions,0) as impressions,
	coalesce(gabd.reach,0) as reach,
	coalesce(gabd.clicks,0) as clicks,
	coalesce(gabd.leads,0) as leads,
	coalesce(gabd.value,0) as value,
	gabd.url_parameters  
from 
	public.google_ads_basic_daily gabd
), 
monthly_ads_data as (
 select 
	date(date_trunc('month', aad.ad_date)) as ad_month,
	sum(aad.spend) as total_spend,
	sum(aad.impressions) as total_impressions,
	sum(aad.clicks) as total_clicks,
	sum(aad.value) as total_value,
case 
	when lower(pg_temp.decode_url_part(
	substring(url_parameters, 'utm_campaign=([^&]+)')
	)) != 'nan' 
	then lower(pg_temp.decode_url_part(
	substring(url_parameters, 'utm_campaign=([^&]+)')
	))		
end as utm_campaign,	
	round(
case when sum(aad.clicks) = 0 then null
	else sum(aad.spend)::numeric/sum(aad.clicks)
end,2) as CPC,
	round(
case when sum(aad.impressions) = 0 then null
	else sum(aad.spend)::numeric/sum(aad.impressions)*1000
end,2) as CPM,
	round(
case when sum(aad.impressions) = 0 then null 
	else sum(aad.clicks)::numeric/sum(aad.impressions)
end,2) as CTR,
	round(
case when sum(aad.spend) = 0 then null
	else (sum(aad.value)::numeric-sum(aad.spend)::numeric)/sum(aad.spend)
end,2) as ROMI
	from all_ads_data aad 
group by ad_month,
         utm_campaign
)
select
	mad.ad_month,
	mad.utm_campaign,
	mad.total_spend,
	mad.total_impressions,
	mad.total_clicks,
	mad.total_value,
	mad.cpc,
	mad.cpm,
	mad.ctr,
	mad.romi,
	round(
	(mad.cpc - lag(mad.cpc,1) over (partition by mad.utm_campaign order by mad.ad_month))
    / 
    nullif(lag(mad.cpc,1) over (partition by mad.utm_campaign order by mad.ad_month), 0) * 100, 2) as cpc_monthly_diff,
	round(
	(mad.cpm - lag(mad.cpm,1) over (partition by mad.utm_campaign order by mad.ad_month))
	/
	nullif(lag(mad.cpm,1) over (partition by mad.utm_campaign order by mad.ad_month),0)*100,2) as cpm_monthly_diff,
	ROUND(
        CASE 
            WHEN round(LAG(mad.ctr,1) OVER (PARTITION BY mad.utm_campaign ORDER BY mad.ad_month),4) > 0 
                 AND mad.ctr = 0 THEN NULL  
            ELSE (mad.ctr - LAG(mad.ctr,1) OVER (PARTITION BY mad.utm_campaign ORDER BY mad.ad_month)) /
                 nullif(round(LAG(mad.ctr,1) OVER (PARTITION BY mad.utm_campaign ORDER BY mad.ad_month),4), 0) * 100
        END, 2
    ) AS ctr_monthly_diff,
	round(
	(mad.romi - lag(mad.romi,1) over (partition by mad.utm_campaign order by mad.ad_month))
	/
	nullif(lag(mad.romi,1) over (partition by mad.utm_campaign order by mad.ad_month),0)*100,2) as romi_monthly_diff
from monthly_ads_data as mad
order by 
	mad.utm_campaign,
	mad.ad_month	