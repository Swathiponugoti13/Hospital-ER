--Total Patients
SELECT COUNT(DISTINCT [Patient Id]) AS Total_Patients
FROM Hospital_ER_Clean;

--Admission Status
SELECT
    CASE
        WHEN [Admission Status] = 'Admitted' THEN 'Admitted'
        ELSE 'Not Admitted'
    END AS Status,
    COUNT(*) AS Patients
FROM Hospital_ER_Clean
GROUP BY
    CASE
        WHEN [Admission Status] = 'Admitted' THEN 'Admitted'
        ELSE 'Not Admitted'
    END;


--Patients Within 30 Minutes
SELECT
    SUM(CASE WHEN [Patient Waittime] <= 30 THEN 1 ELSE 0 END)
        AS Patients_Within_30_Min
FROM Hospital_ER_Clean;

--Department Ranking
WITH Dept AS (
    SELECT [Department Referral], COUNT(*) AS Patients
    FROM Hospital_ER_Clean
    GROUP BY [Department Referral]
)
SELECT *,
    DENSE_RANK() OVER (ORDER BY Patients DESC) AS Dept_Rank
FROM Dept;


--Patient Ranking Within Department
SELECT
    [Patient Id],
    [Department Referral],
    [Patient Waittime],
    ROW_NUMBER() OVER (
        PARTITION BY [Department Referral]
        ORDER BY [Patient Waittime] DESC
    ) AS Wait_Rank
FROM Hospital_ER_Clean;


--Department vs Overall Average
SELECT
    [Department Referral],
    AVG([Patient Waittime]) AS Avg_Wait,
    AVG(AVG([Patient Waittime])) OVER() AS Overall_Avg
FROM Hospital_ER_Clean
GROUP BY [Department Referral];

--Monthly Patients + Previous Month
WITH Monthly AS (
    SELECT
        YEAR([Admission Date]) AS Year,
        MONTH([Admission Date]) AS Month,
        COUNT(*) AS Patients
    FROM Hospital_ER_Clean
    GROUP BY YEAR([Admission Date]), MONTH([Admission Date])
)
SELECT *,
    LAG(Patients) OVER (
        ORDER BY Year, Month
    ) AS Previous_Month
FROM Monthly;


--Patient Volume Trend
WITH Monthly AS (
    SELECT
        YEAR([Admission Date]) AS Year,
        MONTH([Admission Date]) AS Month,
        COUNT(*) AS Patients
    FROM Hospital_ER_Clean
    GROUP BY YEAR([Admission Date]), MONTH([Admission Date])
)
SELECT *,
    CASE
        WHEN Patients > LAG(Patients) OVER (ORDER BY Year, Month)
            THEN 'Increased'
        WHEN Patients < LAG(Patients) OVER (ORDER BY Year, Month)
            THEN 'Decreased'
        ELSE 'No Change'
    END AS Trend
FROM Monthly;


--Running Total
WITH Monthly AS (
    SELECT
        YEAR([Admission Date]) AS Year,
        MONTH([Admission Date]) AS Month,
        COUNT(*) AS Patients
    FROM Hospital_ER_Clean
    GROUP BY YEAR([Admission Date]), MONTH([Admission Date])
)
SELECT *,
    SUM(Patients) OVER (
        ORDER BY Year, Month
    ) AS Running_Total
FROM Monthly;


--Top 3 Departments
WITH Dept AS (
    SELECT
        [Department Referral],
        COUNT(*) AS Patients
    FROM Hospital_ER_Clean
    GROUP BY [Department Referral]
),
Ranked AS (
    SELECT *,
        DENSE_RANK() OVER (ORDER BY Patients DESC) AS Rank_No
    FROM Dept
)
SELECT *,
    CASE
        WHEN Rank_No <= 3 THEN 'Top Department'
        ELSE 'Other'
    END AS Category
FROM Ranked
WHERE Rank_No <= 3;