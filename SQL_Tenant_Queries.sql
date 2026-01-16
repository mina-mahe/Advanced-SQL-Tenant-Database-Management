-- PROJECT: Tenant Database Analysis
-- AUTHOR: Minakshi Mahesh


-- 1.Get Profile ID, Full Name and Contact Number of the tenant who has stayed the longest

use localdb_pk;
select * from INFORMATION_SCHEMA.columns
where TABLE_NAME = 'Tenancy History'
-- move_out_date column is a non-nullable nvarchar column in the excel sheet provided but still has 'NULL' values in some rows , we filter the move_out_date as '%-%-%'

select top 1 with ties p.profile_id, concat(p.first_name, ' ', p.last_name) as full_name, p.phone
from Profiles as p
join [Tenancy History] as th on p.profile_id = th.profile_id
where th.move_out_date like '%-%-%'
order by datediff(day, th.move_in_date, convert(date, th.move_out_date)) desc


-- 2.Get the Full name, email id, phone of tenants who are married and paying rent > 9000 using subqueries

select concat(first_name, ' ', last_name) as full_name, email_id, phone
from Profiles
where marital_status =1 AND profile_id IN (
        select profile_id
        from [Tenancy History]
        where rent > 9000 )


-- 3. Display profile id, full name, phone, email id, city, house id, move_in_date , move_out date, rent, 
--    total number of referrals made, latest employer and the occupational category of all the tenants 
--    living in Bangalore or Pune in the time period of jan 2015 to jan 2016 sorted by their rent in descending order

select * from INFORMATION_SCHEMA.columns
where TABLE_NAME = 'Referral'
select profile_id,count(ID) as 'Total_Referrals_Made' 
-- Counts all referrals made, not just valid ones
into #c
from Referral
group by profile_id;
select * from #c

select a.profile_id , a.full_name , a.phone , a.email_id,adr.city as house_city,b.house_id, b.move_in_date , b.move_out_date, b.rent, 
    isnull(c.Total_Referrals_Made, 0) as Total_Referrals_Made, --replaces NULL values with a 0 for tenants who have never made a referral
    d.latest_employer , d.occupational_category
from (select profile_id , concat(first_name , ' ' , last_name) as full_name, phone , email_id , city from Profiles) as a
join [Tenancy History] as b on a.profile_id = b.profile_id
join [Employee Status] as d on a.profile_id = d.profile_id
join Houses as h on b.house_id = h.house_id
join Addresses as adr on h.house_id = adr.house_id
left join #c as c on a.profile_id = c.profile_id 
-- We use a LEFT JOIN to keep all the tenants from the Profiles table (a), even if they have zero referrals
where adr.city in ('Bangalore', 'Pune') and b.move_in_date < '2016-02-01'-- They moved in before the period ended
    and (b.move_out_date > '2015-01-01' or b.move_out_date IS NULL) -- They moved out after it started (or haven't left)
order by b.rent desc;


-- 4.Find the full_name, email_id, phone number and referral code of all tenants who have referred more than once
--   Also find the total bonus amount they should receive given the bonus gets calculated only for valid referral

select profile_id, count(ID) as 'Total_Attempts'
into #b_attempts
from Referral
group by profile_id
select * from #b_attempts

--Tenants who have referred more than once

select profile_id, sum(referrer_bonus_amount) as 'Total_Bonus'
into #b_bonus
from Referral
where referral_valid <> 0
group by profile_id
select * from #b_bonus
--Tenants with valid referrals

select a.profile_id, a.full_name , a.email_id, a.phone, a.referral_code, ISNULL(b.Total_Bonus, 0) as Total_Bonus
from (select profile_id , concat(first_name , ' ' , last_name) as full_name, email_id , phone , referral_code from Profiles) as a
join #b_attempts as att on a.profile_id = att.profile_id  /* Join to get attempts */
left join #b_bonus as b on a.profile_id = b.profile_id     /* LEFT JOIN for bonus, in case 0 */
where 
    att.Total_Attempts > 1;


-- 5.Find the rent generated from each city and also the total of all cities

select a.rent , c.city
into #d
from [Tenancy History] as a
join Houses as b 
on a.house_id = b.house_id
join Addresses as c
on b.house_id = c.house_id; 

select city,sum(rent) as 'City_Rent', sum(sum(rent)) over() as 'Total_Rent'
from #d
group by city;


-- 6.Using view 'vw_tenant' find profile_id, rent, move_in_date, house_type, beds_vacant, description, city of tenants who
--   shifted on/after 30th april 2015 and are living in houses having vacant beds and its address

create view vw_tenant as 
select a.profile_id, a.rent , a.move_in_date , b.house_type, b.beds_vacant, c.description , c.city
from [Tenancy History] as a
join Houses as b on a.house_id = b.house_id
join Addresses as c on b.house_id = c.house_id
where a.move_in_date >= '2015-04-30' and b.beds_vacant >0 ;

select * from vw_tenant


-- 7.Extend the valid_till date for a month of tenants who have referred more than one time

update Referral
set valid_till = dateadd(month,1,valid_till)
where profile_id in (
    select profile_id
    from Referral
    group by profile_id
    having count(ID) > 1 /* Counts all referral attempts, not just valid ones */
);
select * from Referral


-- 8.Get Profile ID, Full Name, Contact Number of the tenants along with a new column 'Customer Segment' wherein 
--   if the tenant pays rent greater than 10000, tenant falls in Grade A segment, 
--   if rent is between 7500 to 10000, tenant falls in Grade B else in Grade C

select a.profile_id, a.full_name ,a.phone ,
case 
when b.rent >10000 then 'Grade A '
when b.rent between 7500 and 10000 then 'Grade B'
else 'Grade C '
end as Customer_Segment
from ( select profile_id , concat(first_name , ' ' , last_name)as full_name,phone from Profiles)  as a
join [Tenancy History] as b on a.profile_id = b.profile_id


-- 9.Get Fullname, Contact, City and House Details of the tenants who have not referred even once

select a.profile_id, a.full_name , a.phone , a.city , c.house_type, c.bhk_type, c.bed_count , c.furnishing_type, c.beds_vacant , c.house_id
from (select profile_id , concat(first_name , ' ' , last_name) as full_name, phone , city from Profiles) as a
join [Tenancy History] as b on a.profile_id = b.profile_id
join Houses as c on b.house_id = c.house_id
left join Referral as d on a.profile_id = d.profile_id 
where d.profile_id IS NULL


-- 10.Get the house details of the house having highest occupancy

select *, (cast(bed_count - beds_vacant as float) / bed_count) as Occupancy_Rate
into #e 
from Houses 

select *, format(Occupancy_Rate, 'P') as Occupancy_Percent
from #e
where Occupancy_Rate = (
    select max(Occupancy_Rate)
    from #e
)