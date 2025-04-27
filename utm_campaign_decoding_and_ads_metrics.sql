-- Project: UTM Campaign Decoding and Ads Metrics Calculation
-- Description: Extracting and decoding the utm_campaign parameter from URL strings for both Facebook and Google Ads campaigns.
-- The query calculates key advertising KPIs including CTR, CPC, CPM, and ROMI, while handling potential URL encoding and missing data.


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
)
 select 
	aad.ad_date,
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
group by
	aad.ad_date,
	utm_campaign
order by aad.ad_date;