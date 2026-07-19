-- ================================
-- Balance Sheet
-- ================================
select 
	da."Class" , 
	da."Sub_Class" , 
	round(sum(fg."Amount")::numeric, 2) as final_balance
from fact_gl fg 
join dim_accounts da 
	on da."Account_ID" = fg."Account_ID" 
where da."Report_Type" = 'Balance Sheet'
group by 1, 2
;

-- ================================
-- Income Statement
-- ================================
select da."Sub_Class",
	round(sum(fg."Amount"*-1)::numeric, 2) as total_amount
from fact_gl fg 
join dim_accounts da 
	on da."Account_ID" = fg."Account_ID" 
where da."Report_Type" = 'P&L'
group by 1
order by case da."Sub_Class" 
	when 'Revenue' then 1
	when 'Cost of Sales' then 2
	when 'Operating Expense' then 3
	when 'Non-Operating' then 4
	when 'Tax' then 5
	else 6
end
;

-- ================================
-- Gross Profit
-- ================================
select 'Gross Profit' as dre_line,
	round(sum(fg."Amount"*-1 )::numeric,2) as gross_profit
from fact_gl fg 
join dim_accounts da 
	on da."Account_ID" = fg."Account_ID" 
where da."Report_Type" = 'P&L' 
	and da."Sub_Class" in ('Revenue','Cost of Sales')
;

-- ================================
-- EBITDA
-- ================================
select 'EBITDA' as dre_line,
	round(sum(fg."Amount"*-1 )::numeric,2) as ebitda
from fact_gl fg 
join dim_accounts da 
	on da."Account_ID" = fg."Account_ID" 
where da."Report_Type" = 'P&L' 
	and da."Sub_Class" not in ('Tax','Non-Operating')
	and da."Account_ID" <> 6900 -- Depreciation
;

-- ================================
-- Net Profit
-- ================================
select 'Net Income' as dre_line,
	round(sum(fg."Amount"*-1)::numeric,2) as net_profit
from fact_gl fg 
join dim_accounts da 
	on da."Account_ID" = fg."Account_ID" 
where da."Report_Type" = 'P&L' 
;