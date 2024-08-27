-- use to check which records would not be able to be converted to a date
WITH test1(Customer_DOB) AS (
    SELECT '22-JAN-87' FROM dual UNION ALL
    SELECT '11-Nov-81' FROM dual UNION ALL
    SELECT '15-06-75'  FROM dual UNION ALL
    SELECT '15-25-1975'  FROM dual UNION ALL
    SELECT '22-JUN-56' FROM dual
)
SELECT *
FROM   test1
WHERE  validate_conversion(Customer_DOB AS DATE, 'DD-Mon-RR') = 0
;
