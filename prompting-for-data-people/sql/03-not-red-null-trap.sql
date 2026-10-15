/*  03-not-red-null-trap.sql
    The NULL trap, used as a quiz in the session: "How many products are not red?"
*/

/* The plausible answer. Rows with a NULL Color are silently left out. */
SELECT COUNT(*) AS NotRed_Plausible
FROM SalesLT.Product
WHERE Color <> N'Red';

/* The answer to the question that was asked */
SELECT COUNT(*) AS NotRed_Correct
FROM SalesLT.Product
WHERE Color <> N'Red' OR Color IS NULL;

/* Evidence: the parts must add up to the whole */
SELECT  COALESCE(Color, N'(NULL)') AS Color,
        COUNT(*)                   AS Products
FROM SalesLT.Product
GROUP BY Color
ORDER BY Products DESC;

SELECT COUNT(*) AS AllProducts
FROM SalesLT.Product;
