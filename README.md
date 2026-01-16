# Tenant Management System - Advanced SQL Case Study

## Project Overview
This project involves a comprehensive analysis of a **Tenancy Management Database**. The goal was to transform raw relational data into actionable business intelligence using **SQL Server**. The analysis covers tenant demographics, referral program performance, financial segmentation, and real-time inventory tracking.

## Executive Summary & Key Insights
* **Longest Tenancy:** Identified the tenant with the longest stay duration using `DATEDIFF` and `TOP 1 WITH TIES`, providing insights into long-term retention.
* **Market Share Analysis:** Utilized **Window Functions (`OVER()`)** to calculate total revenue distribution across different cities simultaneously with individual city aggregates.
* **Referral Program ROI:** Segregated "Total Referral Attempts" from "Valid Referrals" using **Temporary Tables** to evaluate the effectiveness of the current referral bonus structure.
* **Customer Segmentation:** Implemented a **Grading System (A, B, C)** based on rent brackets to identify high-value customer segments.
* **Inventory Optimization:** Calculated the **Occupancy Rate** percentage for all properties, identifying which house types are performing at maximum capacity.


## Technical SQL Highlights
This project moves beyond basic queries and implements advanced database logic:

* **Window Functions:** Used `SUM(SUM(rent)) OVER()` to calculate global totals alongside grouped data without collapsing rows.
* **Data Staging:** Extensive use of **Temporary Tables (`#`)** to handle multi-step calculations for referral bonuses and occupancy metrics.
* **Advanced Joins:** Implementation of `LEFT JOINs` to identify "Inertia Tenants" (those who have never made a referral).
* **Conditional Logic:** Used `CASE` statements for customer segmentation and `ISNULL()` for clean reporting.
* **Database Objects:** Created **Views** to simplify complex multi-table joins for frequently accessed tenant vacancy data.
* **Data Maintenance:** Used `DATEADD` within `UPDATE` scripts to dynamically extend referral validity periods for active referrers.


## Business Problems Solved (10 Queries)
1.  **Retention Analysis:** Find the tenant who stayed the longest.
2.  **Targeted Marketing:** Identify married tenants paying high rent (>9000).
3.  **Regional Reporting:** Comprehensive tenant profiles for Bangalore and Pune.
4.  **Referral Audit:** Filter tenants with multiple referral attempts.
5.  **Financial Overview:** City-wise rent contribution vs. Total revenue (Window Function).
6.  **Vacancy Tracker:** Created a view for available beds and property descriptions.
7.  **Retention Incentive:** Update referral validity for high-performing referrers.
8.  **Customer Grading:** Segmenting tenants into Grade A, B, and C based on rent.
9.  **Referral Gap Analysis:** Identify tenants who have never participated in the referral program.
10. **Occupancy Analytics:** Identify properties with the highest occupancy percentage.
