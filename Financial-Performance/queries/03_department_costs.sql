-- ================================
-- Department Costs vs Budget (Annual)
-- ================================
with dept_costs as (
    select fc."Department_ID", sum(fc."Amount") as amount_total
    from fact_costs fc 
    group by 1
),
dept_budgets as (
    select fb."Department_ID", sum(fb."Budget_Amount") as budget_total
    from fact_budgets fb 
    group by 1
)
select 
    dd."Department_Name", dc.amount_total , db.budget_total ,
    round(((dc.amount_total - db.budget_total) / db.budget_total * 100)::numeric, 1) as pct_over_budget
from dept_costs dc
join dept_budgets db
    on db."Department_ID" = dc."Department_ID" 
join dim_department dd 
    on dd."Department_ID" = dc."Department_ID"
order by 1;

-- ================================
-- Department Costs Month-over-Month
-- ================================

with monthly_costs as (
	select fc."Department_ID", date_trunc('month', fc."Date"::date )::date as month , sum(fc."Amount" ) as amount_total
	from fact_costs fc 
	group by 2, 1
	order by 1, 2 
)
select dd."Department_Name" , mc."month" , mc.amount_total , fb."Budget_Amount" ,
	round(((mc.amount_total  - fb."Budget_Amount" )/fb."Budget_Amount" * 100)::numeric, 1) as pct_over_budget
from monthly_costs mc
join fact_budgets fb
	on fb."Department_ID" = mc."Department_ID" 
	and mc."month" = fb."Date"::date
join dim_department dd 
	on mc."Department_ID" = dd."Department_ID"
order by 1, 2
;

-- ================================
-- Department Costs Month-over-Month
-- ================================

with monthly_costs as (
	select dd."Department_Name", date_trunc('month',fc."Date"::date)::date as month,
		sum(fc."Amount") as amount_total
	from fact_costs fc
	join dim_department dd
		on fc."Department_ID" = dd."Department_ID" 
	group by 1,2
),
mom_calc as (
	select "Department_Name" , "month" , amount_total ,
		lag(amount_total ) over (partition by "Department_Name" order by "month" ) as prev_amount
	from monthly_costs 
)
select mc."Department_Name" , mc."month" , mc.amount_total ,
	round(((mc.amount_total - mc.prev_amount )/mc.prev_amount  * 100)::numeric, 1) as growth_pct
from mom_calc mc
where mc.prev_amount is not null
order by 1, 2
;