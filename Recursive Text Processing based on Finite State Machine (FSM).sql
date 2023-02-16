-- Relational representation of finite state machine

-- Transition table
DROP TABLE IF EXISTS fsm;
CREATE TABLE fsm (
  source   state NOT NULL, -- source state of transition
  labels   text  NOT NULL, -- transition labels (input)
  target   state,          -- target state of transition
  "final?" boolean,        -- is source a final state?
  PRIMARY KEY (source, labels)
);
-- Represent Regular Expressionin terms of a deterministic Finite State Machine (FSM)
-- Create DFA transition table for regular expression
-- ([A-Za-z]+[0-9]*@([A-Za-z]+\.(edu|com))
INSERT INTO fsm VALUES 
  (0, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz',           1, false ),
  (1, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789', 1, false ),
  (1, '@',                                                              2, false),
  (2, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz',           3, false),                                                
  (3, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz',           3, false),
  (3, '.',                                                              4, false ),
  (4, 'e',                                                              5, false ),
  (4, 'c',                                                              8, false ),
  (5, 'd',                                                              6, false ),
  (8, 'o',                                                              9, false ),
  (6, 'u',                                                              7, true ),
  (9, 'm',                                                             10, true );
---------------------------------------------------------------------

DROP TABLE IF EXISTS emails;
CREATE TABLE emails(
  employee text NOT NULL PRIMARY KEY,
  email     text 
);

INSERT INTO emails(employee, email) VALUES
('Pratibha','pratibha67@sqlguide.edu'),
('Bhavya','bhav_yaa@pythonguide.com'),
('Disha','disha@sqlguide.edu'),
('Divanshi','divanshi23@spguide.com'),
('Srishti','sris%hti@sqlguide.efdu'),
('Kartik','kartik@pythonguide.com'),
('Rytham','rytham6@sqlguide.edu'),
('Madhav','madhav@tsinfoedu'),
('Tanisha','tanisha@pythonguide.cmom'),
('Radhika','radhika41@spguide.com');  
-------------------------------------------------------------

WITH RECURSIVE 

matches (employee, step, state, input) AS(
  SELECT e.employee, 0 AS step, 0 AS state, e.email AS input
  FROM   emails AS e
     UNION

  SELECT m.employee, step + 1 AS step,
         f.target AS state,
         right(m.input, -1) AS input          
  FROM   matches AS m, fsm AS f  
  WHERE  m.state = f.source
  AND    strpos(f.labels, left(m.input, 1)) > 0
  AND    length (m.input) >0  
)
SELECT DISTINCT 
       m.employee,
       LAST_VALUE (m.input) OVER win =''   -- no residual input in final state?
       AND 
       LAST_VALUE(m.state) OVER win        -- final state reached during matching
       IN (SELECT f.target
           FROM   fsm AS f                 -- all FSM final states
           WHERE  f."final?") 
       AS "success?" 

FROM   matches AS m
WINDOW win AS (PARTITION BY m.employee 
               ORDER BY m.step 
               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING);
