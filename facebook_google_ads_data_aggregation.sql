-- Project: Facebook and Google Ads Data Aggregation
-- Description: Aggregating daily performance metrics from Facebook Ads and Google Ads datasets.
-- The query combines the data sources, assigns a media source label, and summarizes key metrics (spend, impressions, clicks, conversion value) by ad date, media source, campaign name, and ad set name.


with facebook_data as (
select 
	fabd.ad_date,
	fc.campaign_name,
	fa.adset_name,
	'facebook_ads' as media_source,
	fabd.spend,
	fabd.impressions,
	fabd.reach,
	fabd.clicks,
	fabd.leads,
	fabd.value 
from  
	public.facebook_ads_basic_daily fabd
left join 
	public.facebook_adset fa on fa.adset_id = fabd.adset_id 
left join 
	public.facebook_campaign fc on fc.campaign_id = fabd.campaign_id
where
	fabd.ad_date is not null
),
all_ads_data as (
select 
	fd.ad_date,
	fd.media_source,
	fd.campaign_name,
	fd.adset_name,
	fd.spend,
	fd.impressions,
	fd.reach,
	fd.clicks,
	fd.leads,
	fd.value 
from  facebook_data fd
	
union all

select 
	gabd.ad_date,
	'google_ads' as media_source,
	gabd.campaign_name,
	gabd.adset_name, 
	gabd.spend, 
	gabd.impressions, 
	gabd.reach,
	gabd.clicks,
	gabd.leads, 
	gabd.value 
from 
	public.google_ads_basic_daily gabd
where
	gabd.ad_date is not null 
)
select 
	aad.ad_date,
	aad.media_source,
	aad.campaign_name,
	aad.adset_name,
	sum(aad.spend) as total_spend,
	sum(aad.impressions) as total_impressions,
	sum(aad.clicks) as total_clicks,
	sum(aad.value) as total_conversion_value
	from all_ads_data aad 
group by
	aad.ad_date,
	aad.media_source,
	aad.campaign_name,
	aad.adset_name
order by aad.ad_date;