create table bankloan
(
State_Abbr varchar(50) ,
Account_ID varchar(50)  ,
Age varchar(50)  ,
BH_Name varchar(50)  ,
Bank_Name varchar(50)  ,
Branch_Name varchar(50) , 
Caste varchar(50) , 
Center_Id int ,
City varchar(50) , 
Client_id int ,
Client_Name varchar(50)  ,
Close_Client varchar(50)  ,
Closed_date date ,
Credif_Officer varchar(50),
Dateof_Birth date,
Disb_By varchar(50) ,
Disbursement_Date date, 
DisbursementDateYEAR date,
Gender_ID varchar(50), 
Home_Ownership varchar(50), 
Loan_Status varchar(50) ,
Loan_Transferdate varchar(50) ,
NextMeetingDate date, 
Product_Code varchar(50), 
Grade varchar(50) ,
Sub_Grade varchar(50),
Productid varchar(50), 
Region_Name varchar(50), 
Religion varchar(50), 
Verification_Status varchar(50) ,
State_Abbr0 varchar(50), 
State_Name varchar(50) ,
Tranfer_Logic varchar(50), 
Is_Delinquent_Loan varchar(50) ,
Is_Default_Loan varchar(50) ,
Age_T int ,
Delinq_2_Yrs int ,
Application_Type varchar(50), 
Loan_Amount int ,
Funded_Amount int ,
Funded_Amount_inv  int ,
Int_Rate float, 
Total_Pymnt float, 
Total_Pymnt_inv float, 
TotalRecPrncp varchar(50) ,
Total_Fees float, 
Total_Rrec_int float, 
Total_Rec_Late_fee float ,
Total_Revenue float ,
Revenue varchar(50), 
Recoveries float, 
Collection_Recovery_fee float, 
LoanMaturity varchar(50)
);

LOAD DATA  INFILE 'C:\ProgramData\MySQL\MySQL Server 9.3\Uploads\loan.csv' INTO TABLE bankloan
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- KPI 1: Total Loan Amount Funded
SELECT SUM(`Funded Amount`) AS Total_Loan_Amount_Funded
FROM Loan;

-- KPI 2: Total Loans
SELECT COUNT(*) AS Total_Loans
FROM Loan;

-- KPI 3. Total Collection (Principal + Interest)
SELECT 
  round(SUM(`Total Rec Prncp`) + SUM(`Total Rrec int`),2) AS Total_Collection
FROM Loan;

-- KPI 4. Total Interest
SELECT SUM(`Total Rrec int`) AS Total_Interest
FROM Loan;

-- KPI 5. Branch-Wise Performance
SELECT 
  `Branch Name`,
  SUM(`Total Rrec int`) AS Interest,
  SUM(`Total Fees`) AS Fees,
  SUM(CAST(`Total Revenue` AS DECIMAL(10,2))) AS Total_Revenue
FROM Loan
GROUP BY `Branch Name`;

-- KPI 6. State-Wise Loan
SELECT 
  `State Name`,
  COUNT(*) AS Loan_Count,
  SUM(`Funded Amount`) AS Total_Funded
FROM Loan
GROUP BY `State Name`;

-- KPI 7: Religion-Wise Loan
SELECT 
  Religion,
  COUNT(*) AS Loan_Count,
  SUM(`Funded Amount`) AS Total_Funded
FROM Loan
GROUP BY Religion;

-- 8. Product Group-Wise Loan
SELECT 
  `Product Code`,
  COUNT(*) AS Loan_Count,
  SUM(`Funded Amount`) AS Total_Funded
FROM Loan
GROUP BY `Product Code`;

-- KPI 9. Disbursement Trend (Monthly)
SELECT 
  DATE_FORMAT(STR_TO_DATE(`Disbursement Date`, '%e/%c/%Y'), '%Y-%m') AS `Month`,
  COUNT(*) AS Loan_Count,
  SUM(`Funded Amount`) AS Total_Disbursed
FROM Loan
WHERE `Disbursement Date` REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}'
GROUP BY `Month`
ORDER BY `Month`;

-- KPI 10: Grade-Wise Loan
SELECT 
  Grrade,
  COUNT(*) AS Loan_Count,
  SUM(`Funded Amount`) AS Total_Funded
FROM Loan
GROUP BY Grrade;

-- KPI 11:  Default Loan Count
SELECT COUNT(*) AS Default_Loan_Count
FROM Loan
WHERE `Is Default Loan` = 'Y';

-- KPI 13: Delinquent Loan Rate
SELECT 
  ROUND(SUM(CASE WHEN 
  `Is Delinquent Loan` = 'Y' THEN 1 
  ELSE 0 
  END) * 100.0 / COUNT(*), 2) AS Delinquent_Loan_Rate_Percentage
FROM Loan
WHERE `Is Delinquent Loan` IS NOT NULL AND `Is Delinquent Loan` != '';

-- KPI 14: Default Loan Rate
SELECT 
  ROUND(SUM(CASE WHEN `Is Default Loan` = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Default_Loan_Rate_Percentage
FROM Loan
WHERE `Is Default Loan` IS NOT NULL AND `Is Default Loan` != '';

-- KPI 15: Loan Status-Wise Loan Count
SELECT 
  `Loan Status`, 
  COUNT(*) AS Loan_Count
FROM Loan
WHERE `Loan Status` IS NOT NULL AND `Loan Status` != ''
GROUP BY `Loan Status`
ORDER BY Loan_Count DESC;

-- KPI 16: Age Group-Wise Loan
SELECT 
  CASE 
    WHEN `Age _T` BETWEEN 18 AND 25 THEN '18-25'
    WHEN `Age _T` BETWEEN 26 AND 35 THEN '26-35'
    WHEN `Age _T` BETWEEN 36 AND 45 THEN '36-45'
    WHEN `Age _T` BETWEEN 46 AND 60 THEN '46-60'
    WHEN `Age _T` > 60 THEN '60+'
    ELSE 'Unknown'
  END AS Age_Group,
  COUNT(*) AS Loan_Count
FROM Loan
GROUP BY Age_Group
ORDER BY Age_Group;

-- KPI 17: Loan Maturity Distribution
SELECT 
  `Loan Maturity`, 
  COUNT(*) AS Loan_Count
FROM Loan
WHERE `Loan Maturity` IS NOT NULL AND `Loan Maturity` != ''
GROUP BY `Loan Maturity`
ORDER BY Loan_Count DESC;

-- KPI 18: No Verified Loans
SELECT 
  COUNT(*) AS No_Verified_Loans
FROM Loan
WHERE `Verification Status` IS NULL 
   OR `Verification Status` = '' 
   OR LOWER(`Verification Status`) IN ('not verified', 'unverified');