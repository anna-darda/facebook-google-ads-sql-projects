-- Project: Top Campaign ROMI Analysis
-- Description: Identifying the marketing campaign with the highest ROMI (Return on Marketing Investment) among campaigns with total spend exceeding 500,000.
-- The query also finds the top-performing ad set (ad group) within the selected campaign based on ROMI.


with all_ads_data as (
select 
	fabd.ad_date,
	fc.campaign_name,
	fa.adset_name,	
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
	
union all

select 
	gabd.ad_date,
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
),
 top_campaign as (
select 
	aad.campaign_name,
	sum(aad.spend) as total_spend,
	sum(aad.impressions) as total_impressions,
	sum(aad.clicks) as total_clicks,
	sum(aad.value) as total_conversion_value,
	round((sum(aad.value)::numeric/sum(aad.spend)),2) as ROMI
from all_ads_data aad 
where 
	aad.spend > 0 
	and aad.campaign_name is not null
group by
	aad.campaign_name
having 
	sum(aad.spend) >= 500000
order by 
	romi desc
limit 1
)
select
	aad.adset_name,
	aad.campaign_name,
	sum(aad.spend) as spend,
	sum(aad.value) as value,
	round((sum(aad.value)::numeric/sum(aad.spend)),2) as ROMI
from 
	all_ads_data aad
inner join 
	top_campaign tc on tc.campaign_name = aad.campaign_name
where aad.spend > 0	
group by 
	aad.campaign_name,
	aad.adset_name	
	order by 
	romi desc
    limit 1;