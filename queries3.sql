-- Name: DEVDUTT SANTHOSH

--
\echo QUERY #1
\echo
-- Make a copy of the UCI ML "Bank Marketing" data set.
-- Note this table will be created in your own schema.

DROP TABLE IF EXISTS client; 

CREATE TABLE client AS
SELECT *
FROM public.bank;

--
\echo CHANGE #1
\echo
-- Add the following record to your client table:
--   20, technician, single, primary, no, 5432, no, yes,
--   cellular, 19, apr, 80, 3, 101, 2, unknown, no

INSERT INTO client (age, job, marital, education, badcredit, balance, housing, loan, contact, DAY, MONTH, duration, campaign, pdays, previous, poutcome, subscribe)
VALUES ('20', 'technician', 'single', 'primary', 'no', '5432', 'no', 'yes', 'cellular', '19', 'apr', '80', '3', '101', '2', 'unknown', 'no');
--
\echo CHANGE #2
\echo
-- For the clients with bad credit, decrease their balance by 10
-- and increase their duration by 5.

UPDATE client
SET balance = balance - 10,
    duration = duration + 5
WHERE badcredit = 'yes';


--
\echo CHANGE #3
\echo
--
-- Delete clients from campaign #1 with an unknown previous outcome.


DELETE
FROM client
WHERE campaign = 1
  AND poutcome = 'unknown';

--
\echo RESULTS
\echo
-- Select the table for comparison with expected output.
-- For convenience, sort by age, balance, and duration.

FROM client
ORDER BY age,
         balance,
         duration
LIMIT 200; 
--------------------------------------------------------------------------------
-- IMDb Queries
\c imdb2016
--------------------------------------------------------------------------------

--
\echo QUERY #2
\echo
-- Which video games in 2015 have fewer than three cast_info records?
--
-- Schema: title, year, count
--  Order: title
SELECT movie.title,
       YEAR,
       Count(cast_info.movie_id)
FROM movie
JOIN kind_type ON movie.kind_id = kind_type.id
LEFT JOIN cast_info ON movie.id = cast_info.movie_id
WHERE movie.kind_id = 6
  AND YEAR = 2015
GROUP BY movie.title,
         movie.id
HAVING Count(cast_info.movie_id) <= 2
ORDER BY movie.title;

--------------------------------------------------------------------------------
-- TPCH Queries
\c tpch
--------------------------------------------------------------------------------

--
\echo QUERY #3
\echo
-- What parts containing the word "chocolate" were ordered on or after
-- August 1, 1998 and shipped by mail?
--
-- Schema: p_name, ps_supplycost, l_quantity
--  Order: p_partkey
SELECT p_name,
       ps_supplycost,
       l_quantity
FROM part
JOIN partsupp ON part.p_partkey = partsupp.ps_partkey
JOIN lineitem ON partsupp.ps_partkey = lineitem.l_partkey
AND partsupp.ps_suppkey = lineitem.l_suppkey
JOIN orders ON lineitem.l_orderkey = orders.o_orderkey
WHERE o_orderdate >= '1998-08-01'
  AND p_name LIKE '%chocolate%'
  AND l_shipmode = 'MAIL'
ORDER BY p_partkey
LIMIT 500;


