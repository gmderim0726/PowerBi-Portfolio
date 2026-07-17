-- ================================
-- Product Profit
-- ================================

select t."Transaction_ID" , 
	t."Qty" , t."Revenue" , 
	dp."Cost" * t."Qty" as cogs ,
	t."Revenue" - (dp."Cost" * t."Qty" ) as profit,
	round((case when t."Revenue" = 0 then 0 else ((t."Revenue" - (dp."Cost" * t."Qty")) / t."Revenue") * 100.0
	end)::numeric,1) as gross_margin
from fact_sales t 
join dim_products dp 
	on t."Product_ID" = dp."Product_ID" 
;

-- ================================
-- Subcategory Profit
-- ================================
select dp."Sub Category" , 
	round((sum(t."Revenue") - sum(t."Qty" * dp."Cost"))::numeric, 2) as Profit,
	round(((sum(t."Revenue") - sum(t."Qty" * dp."Cost"))/sum(t."Revenue" )* 100)::numeric,1) as gross_margin
from fact_sales t 
join dim_products dp 
	on t."Product_ID" = dp."Product_ID" 
group by 1
order by 2 desc
;

-- ================================
-- Customer Performance
-- ================================
select t."Customer_ID" , 
	sum(t."Qty" ) as qty_total, 
	round(sum(t."Revenue" )::numeric, 2) as total_revenue,
	case when count(distinct t."Transaction_ID" ) = 0 then 0
		else round((sum(t."Revenue")/count(distinct t."Transaction_ID"))::numeric, 2) end
	as avg_ticket
from fact_sales t 
group by 1
order by 3 desc
;

-- ================================
-- Monthly Performance
-- ================================
select date_trunc('month', t."Date" ::date)::date as month, 
	round(sum(t."Revenue")::numeric,2) as monthly_revenue,
	sum(t."Qty") as month_qty
from fact_sales t 
group by 1
order by 1
;

-- ================================
-- Monthly Sub-Categories Performance (Top 3)
-- ================================
with revenue_calc as (
	select date_trunc('month',(t."Date")::date)::date as month, dp."Sub Category", sum(t."Revenue") as monthly_revenue,
		dense_rank() over (partition by date_trunc('month',(t."Date")::date)::date order by sum(t."Revenue") desc) as ranking
	from fact_sales t 
	join dim_products dp
		on t."Product_ID" = dp."Product_ID" 
	group by month, dp."Sub Category"
)
select month, "Sub Category", round(monthly_revenue::numeric,2) as monthly_revenue
from revenue_calc
where ranking <= 3
;

-- ================================
-- Monthly Products Performance (Top 3)
-- ================================
with qty_calc as (
	select date_trunc('month',(t."Date")::date)::date as month, dp."Name", sum(t."Qty") as monthly_qty,
		dense_rank() over (partition by date_trunc('month',(t."Date")::date)::date order by sum(t."Qty") desc) as ranking
	from fact_sales t 
	join dim_products dp
		on t."Product_ID" = dp."Product_ID" 
	group by month, dp."Name"
)
select month, "Name", monthly_qty as monthly_qty
from qty_calc
where ranking <= 3
;

-- ================================
-- Month-over-Month (MoM) Revenue & Costs Growth
-- ================================
with mom as (
	select date_trunc('month', t."Date"::date )::date as month,
		sum(t."Revenue") as revenue,
		sum(dp."Cost" * t."Qty" ) as cogs
	from fact_sales t
	join dim_products dp 
		on t."Product_ID" = dp."Product_ID"
	group by 1
)
select month, 
	round(revenue::numeric,2) as revenue,
	round((lag(revenue, 1, 0) over (order by month))::numeric,2) as prev_rev,
	round(((revenue - lag(revenue, 1, 0) over (order by month))/nullif(lag(revenue, 1, 0) over (order by month),0)*100)::numeric,1) as diff_rev,
	round(cogs::numeric,2) as cogs,
	round((lag(cogs,1,0) over (order by month))::numeric,2) as prev_cogs,
	round(((cogs - lag(cogs,1,0) over (order by month))/nullif(lag(cogs,1,0) over (order by month),0)*100)::numeric,1) as diff_cogs
from mom
order by 1
;

-- ================================
-- ABC Classification (80/20)
-- ================================
with product_rev as (
	select dp."Name" , SUM(t."Revenue" ) as total_revenue
	from fact_sales t
	join dim_products dp 
		on t."Product_ID" = dp."Product_ID"
	group by 1
), 
cumm_rev as (
	select "Name" , total_revenue,
		sum(total_revenue ) over (order by total_revenue desc) as running,
		sum(total_revenue ) over () as total
	from product_rev 
)
select "Name" , total_revenue , 
	round((running / total * 100)::numeric,1) as cumm_pct,
	case when 
		(running / total) <= 0.8 then 'A'
	when 
		(running / total) <= 0.95 then 'B'
	else 'C' end as abc_class
from cumm_rev 
;