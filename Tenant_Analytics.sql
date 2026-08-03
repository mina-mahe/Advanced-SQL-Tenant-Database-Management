-- =================================================================================================
-- PROJECT: TENANT HOUSING & REFERRAL ANALYTICS
-- DESCRIPTION: Operational audit of tenancy retention, referral acquisition costs, and asset utilization.
-- =================================================================================================

use localdb_pk;

-- =================================================================================================
-- 1. TENANT LOYALTY PROFILING
-- Business Logic: Standardizing contact names and identifying the tenant with the maximum 
-- continuous stay to model retention characteristics of long-term customers.
-- =================================================================================================

-- Standardizing schema for reporting
alter table Profiles
add FullName nvarchar(50) 
update Profiles
set FullName = concat(first_name, ' ', last_name)

-- Calculating historical tenancy durations
select profile_id ,move_in_date , convert(date,move_out_date) as move_out_date, datediff(day,move_in_date, move_out_date) as duration
into New
from [Tenancy History]
where move_out_date like '%-%-%'
 
-- Extracting contact details for the most loyal tenant
select a.profile_id , a.FullName , a.phone
from Profiles as a
join New as b
on a.profile_id = b.profile_id
where b.duration =(select max(duration) from New);

-- =================================================================================================
-- 2. PREMIUM DEMOGRAPHIC ISOLATION
-- Business Logic: Isolating high-value tenants (monthly rent > ?9,000) to build targeted 
-- contact lists for premium service offerings or lease renewal incentives.
-- =================================================================================================

select a.FullName , a.phone , a.email_id
from Profiles as a
join (
select * 
from [Tenancy History]
where rent>9000
)
as b
on a.profile_id = b.profile_id

-- =================================================================================================
-- 3. REGIONAL MARKET PROFILING (2015-2016)
-- Business Logic: Conducting a deep-dive demographic and employment analysis for the highly 
-- strategic Bangalore and Pune markets to assess tenant financial stability.
-- =================================================================================================

-- Staging total referral counts per profile
select profile_id ,sum(cast(referral_valid as int)) as 'Total_Referrals'
into D
from Referral
group by profile_id
select * from D

-- Compiling holistic tenant profiles for key regions sorted by revenue contribution
select a.profile_id , a.FullName , a.phone , a.email_id, a.city ,b.house_id, b.move_in_date , b.move_out_date, b.rent, c.Total_Referrals, d.latest_employer , d.occupational_category
from Profiles as a
join [Tenancy History] as b
on a.profile_id = b.profile_id
join D as c
on a.profile_id = c.profile_id
join [Employee Status] as d
on a.profile_id = d.profile_id
where a.city in ('Bangalore', 'Pune') and b.move_in_date >= '2015-01-01' and b.move_out_date <= '2016-01-01'
order by b.rent desc

-- =================================================================================================
-- 4. CUSTOMER ACQUISITION COST (CAC) AUDIT
-- Business Logic: Reconciling the referral bonus ledger to ensure financial payouts are 
-- calculated strictly against legally valid conversions, preventing revenue leakage.
-- =================================================================================================

-- Staging financial liability for valid referrals
select profile_id, sum(referrer_bonus_amount) as 'Total_Bonus'
into E
from Referral
where referral_valid <> 0
group by profile_id

-- Mapping financial liabilities back to user profiles
select a.FullName , a.email_id, a.phone, a.referral_code, c.Total_Bonus
from Profiles as a
join D as b
on a.profile_id = b.profile_id
join E as c
on a.profile_id = c.profile_id
where b.Total_Referrals >=1

-- =================================================================================================
-- 5. GEOGRAPHICAL REVENUE DISTRIBUTION
-- Business Logic: Aggregating rental income by city and comparing it against the global 
-- portfolio total to determine market share and identify expansion priorities.
-- =================================================================================================

-- Staging rent amounts to their respective geographical centers
select a.rent , b.city
into K
from [Tenancy History] as a 
join Profiles as b
on a.profile_id = b.profile_id

-- Utilizing window functions for portfolio-wide revenue comparison
select city,sum(rent) as 'City_Rent', sum(sum(rent)) over() as 'Total_Rent'
from K
group by city
select * from K

-- =================================================================================================
-- 6. ASSET UNDER-UTILIZATION MONITORING PIPELINE
-- Business Logic: Establishing a persistent view to track partially vacant properties containing 
-- active tenants, enabling the sales team to incentivize current residents to fill empty beds.
-- =================================================================================================

create view vw_tenant as
select 
a.profile_id, a.rent , a.move_in_date , b.house_type, b.beds_vacant, c.description , c.city
from [Tenancy History] as a
join Houses as b on a.house_id = b.house_id
join Addresses as c on b.house_id = c.house_id
where a.move_in_date >= '2015-04-30' and b.beds_vacant >0
select * from vw_tenant

-- =================================================================================================
-- 7. AUTOMATED LOYALTY INCENTIVIZATION
-- Business Logic: Executing a database update to automatically reward high-performing "power referrers" 
-- by extending their code validity window by 30 days, driving further organic growth.
-- =================================================================================================

update Referral
set valid_till = dateadd(month,1,valid_till)
where referral_valid <>0 and profile_id in (
select profile_id
from Referral
group by profile_id
having sum(cast(referral_valid as int))> 1
);
select * from Referral

-- =================================================================================================
-- 8. REVENUE STRATIFICATION & SEGMENTATION
-- Business Logic: Engineering a tiered Customer Segment classification system to allow 
-- the marketing department to tailor campaigns based on customer lifetime value.
-- =================================================================================================

select a.profile_id, a.FullName ,a.phone ,
case 
when b.rent >10000 then 'Grade A '
when b.rent between 7500 and 10000 then 'Grade B'
else 'Grade C '
end as Customer_Segment
from Profiles as a
join [Tenancy History] as b on a.profile_id = b.profile_id 

-- =================================================================================================
-- 9. UNTAPPED ACQUISITION POTENTIAL
-- Business Logic: Extracting the housing and contact details of tenants who have generated zero 
-- referrals to design targeted educational campaigns regarding the referral program.
-- =================================================================================================

select a.FullName ,a.phone , a.city , c.house_type,	c.bhk_type, c.bed_count	, c.furnishing_type, c.beds_vacant , c.house_id
from Profiles as a
join [Tenancy History] as b on a.profile_id = b.profile_id
join Houses as c on b.house_id = c.house_id
join Referral as d on a.profile_id = d.profile_id
where d.referral_valid = 0

-- =================================================================================================
-- 10. MAXIMUM YIELD ASSET IDENTIFICATION
-- Business Logic: Creating a permanent occupancy metric within the inventory schema to dynamically 
-- pinpoint properties operating at maximum structural capacity, guiding future real estate investments.
-- =================================================================================================

-- Structuring the schema for dynamic asset tracking
alter table Houses
add Occupancy int ;

-- Calculating utilization efficiency
update Houses
set Occupancy = ((bed_count - beds_vacant) *100 /bed_count);

-- Isolating peak performing properties
select * from Houses
where Occupancy =(
select max(Occupancy)
from Houses
);
