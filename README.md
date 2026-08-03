# 🏢 Tenant Housing & Referral Analytics: Optimizing Revenue and Occupancy

## 📌 Executive Summary
This project analyzes the operational and financial data of a housing rental and tenancy management company. The primary objective was to audit historical tenancy records, evaluate the financial impact of the customer referral program, and segment the customer base to identify high-value demographics. 

Through advanced SQL querying, this analysis transforms raw, normalized relational data (tenant profiles, housing inventory, and employment statuses) into actionable business intelligence regarding geographic revenue, asset utilization, and Customer Acquisition Cost (CAC) via referrals.

## 🛠️ Tech Stack & Database Architecture
* **Database Management System:** SQL Server (T-SQL)
* **Techniques Utilized:** Multi-table `JOIN` operations, Window Functions (`OVER()`), Subqueries, Temporary Staging Tables (`INTO`), Data Manipulation Language (`UPDATE`, `ALTER`), and logical segmentation (`CASE WHEN`).
* **Schema Structure:** A fully normalized relational database consisting of 6 core tables:
  * `Profiles` (Demographics & Contact Info)
  * `Tenancy_histories` (Move-in/out dates, Rent amounts)
  * `Houses` (Inventory, Bed counts, Vacancies)
  * `Addresses` (Geographical locations)
  * `Referrals` (Referral codes, Bonus amounts, Validity windows)
  * `Employment_details` (Income indicators)

## 📈 Key Insights & Findings

* **Revenue Concentration:** The geographical analysis indicates that the portfolio's revenue is heavily centralized. Bangalore (₹64,200) and Delhi (₹62,000) are the primary market drivers, jointly accounting for 70.3% of the total ₹179,400 rental revenue generated.
* **Premium Demographic Dominance:** The Customer Segmentation analysis reveals a highly premium tenant base. Out of the profiled subset, 80% of tenants fall into the high-value 'Grade A' (Rent > ₹10,000) and mid-value 'Grade B' (₹7,500 - ₹10,000) categories, indicating strong market pricing power.
* **Asset Performance & Utilization:** Six distinct properties across the portfolio successfully achieved and maintained a perfect 100% occupancy rate. The data shows a strong market preference for fully-furnished and semi-furnished apartments, providing a clear blueprint for future real estate acquisitions.
* **Internal Lead Generation:** The under-utilization tracking view successfully isolated 8 active tenants currently residing in apartments with a combined total of 12 vacant beds, providing a hyper-targeted lead list for roommate referral campaigns.
* **Customer Acquisition Cost (CAC) Baseline:** The referral financial audit identified a total valid payout of ₹14,000 distributed among 7 active power-users. This establishes a baseline CAC of ₹2,000 per referring tenant, giving the marketing team a concrete metric to compare against digital advertising costs.
* **Untapped Acquisition Potential:** While the referral program successfully incentivized power-users, the audit identified specific high-value tenants (residing in premium 2-BHK and 3-BHK apartments in Bangalore and Pune) who have never converted a valid referral, highlighting a direct opportunity for targeted organic growth.

## 💡 Strategic Recommendations

1. **Prioritize Premium Retention:** With 80% of the evaluated customer base falling into premium revenue tiers, marketing and property management efforts should prioritize premium service retention over budget-tier acquisition. The company should offer targeted renewal discounts to these "Grade A" tenants before their leases expire.
2. **Execute Roommate Referral Campaigns:** The sales team should immediately offer a temporary, enhanced referral bonus to the 8 specific tenants identified living near the 12 vacant beds. Incentivizing internal tenants is a highly actionable strategy to fill these beds faster than utilizing external cold-marketing channels.
3. **Revamp Referral Education:** A significant portion of the user base has generated zero referrals. Implementing a push-notification campaign explaining the financial benefits of the referral program could drastically lower organic acquisition costs by activating these dormant users.
4. **Focus Expansion on High-Occupancy Metrics:** Future real estate acquisitions should strictly mirror the structural details (BHK type, furnishing) of the 6 properties that consistently hit the maximum occupancy thresholds identified in the asset utilization audit.
9.  **Referral Gap Analysis:** Identify tenants who have never participated in the referral program.
10. **Occupancy Analytics:** Identify properties with the highest occupancy percentage.
