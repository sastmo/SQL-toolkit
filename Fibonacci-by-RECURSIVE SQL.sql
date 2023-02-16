DROP FUNCTION fib;
CREATE FUNCTION fib(n numeric) 
RETURNS TABLE(i numeric, "fib(i)" numeric) AS
 $$
  WITH RECURSIVE 
  fibs(iter, i, fib) AS(
    SELECT 0                     AS iter,
           fi.i::numeric         AS i,
          (fi.pos-1)::numeric    AS fib
    FROM   generate_series (0, (CASE n::integer 
                                     WHEN 0
                                     THEN 0
                                     ELSE 1
                                END )) WITH ORDINALITY AS fi(i, pos)
        UNION ALL
    (--  prepare for multiple references
     --  to the recursive table fibs
      WITH fibs(iter, i, fib) AS(
        TABLE fibs  -- reinject already discovered fibs
      )   
    SELECT f.iter+1 AS iter, f.i, f.fib    
    FROM (TABLE fibs 
                  UNION
          SELECT f.iter                 AS iter,
                 (f.iter + 2)::numeric  AS i, 
                 (NTH_VALUE(f.fib, f.iter+2)OVER() + NTH_VALUE(f.fib, f.iter+1)OVER()) AS fib
          FROM ( SELECT f.* 
                  FROM  fibs AS f
                  ORDER BY f.i
                ) AS f          
            ) AS f (iter, i, fib)         
    WHERE  f.iter < n-1
    )
  ),
  --Post-processing
  fib (i, fib) AS(
  SELECT f.i AS i, f.fib AS "fib(i)"
  FROM   fibs AS f
  WHERE  f.iter = n-1
  ORDER BY f.iter, f.i
  )
 TABLE fib;

 $$ LANGUAGE SQL IMMUTABLE;

SELECT f.*
FROM  fib(10) AS f
