-- public.vw_aba1 fonte
-- Management Overview
-- Answer questions such as 'How many clients are active?', 'What is Total Credit Limit?', 'What is the Total Revolving Balance?', 
-- 'What is the Total Credit/Balance by card category', and 'What is the Variation between Q1 and Q4'
CREATE OR REPLACE VIEW public.vw_aba1
AS SELECT "CLIENTNUM" AS client_id,
        CASE
            WHEN "Attrition_Flag" = 'Existing Customer'::text THEN 'Active'::text
            ELSE 'Inactive'::text
        END AS status,
    "Credit_Limit",
    "Total_Revolving_Bal",
    "Income_Category",
    "Card_Category",
    "Total_Amt_Chng_Q4_Q1"
   FROM bankchurners b;

-- public.vw_aba2 fonte
-- Credit Risk Monitoring
-- Track metrics such as 'Average customers age and credit card usage', 'Relative credit limit utilization', 
-- 'Credit status by demographic profile (marital status and dependents)', and 'Default risk based on customer profile'
CREATE OR REPLACE VIEW public.vw_aba2
AS SELECT "CLIENTNUM" AS client_id,
        CASE
            WHEN "Attrition_Flag" = 'Existing Customer'::text THEN 'Active'::text
            ELSE 'Inactive'::text
        END AS status,
    "Customer_Age",
    "Months_on_book",
    "Avg_Utilization_Ratio",
    "Months_Inactive_12_mon",
    "Marital_Status",
    "Dependent_count",
    "Avg_Open_To_Buy"
   FROM bankchurners b;

-- public.vw_aba3 fonte
-- Operational reports
-- Track metric such as 'Customer transaction data', 'Yearly variation in transactions and usage',
-- 'Costumer contact frequency', and 'Automated alerts for high contact and low usage'
CREATE OR REPLACE VIEW public.vw_aba3
AS SELECT "CLIENTNUM" AS client_id,
        CASE
            WHEN "Attrition_Flag" = 'Existing Customer'::text THEN 'Active'::text
            ELSE 'Inactive'::text
        END AS status,
    "Total_Trans_Amt",
    "Total_Trans_Ct",
    "Total_Ct_Chng_Q4_Q1",
    "Contacts_Count_12_mon",
    "Months_Inactive_12_mon",
        CASE
            WHEN "Contacts_Count_12_mon" >= 5 AND "Total_Ct_Chng_Q4_Q1" < 0.5::double precision THEN 'Investigar'::text
            WHEN "Months_Inactive_12_mon" >= 3 THEN 'Alerta'::text
            ELSE 'Normal'::text
        END AS op_alert
   FROM bankchurners b;