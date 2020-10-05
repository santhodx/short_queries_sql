-- Name: DEVDUTT SANTHOSH

--------------------------------------------------------------------------------
-- IMDb Queries
\c imdb2016
--------------------------------------------------------------------------------

--
\echo QUERY #1
\echo
SELECT kind,
       YEAR
FROM movie
JOIN kind_type ON movie.kind_id = kind_type.id
WHERE movie.title = 'Star Wars'
ORDER BY YEAR,
         kind
LIMIT 100;


--
\echo QUERY #2
\echo
SELECT person.name AS real_name,
       character.name AS char_name
FROM person
JOIN cast_info ON person.id = cast_info.person_id
JOIN CHARACTER ON cast_info.char_id = character.id
JOIN movie ON cast_info.movie_id = movie.id
WHERE movie.id = 3409859
  AND YEAR = 2014
ORDER BY nr_order;


--
\echo QUERY #3
\echo
-- For each tv movie in 2015 that has runtime information,
-- what is the plot of the movie? If there is no plot record
-- in the database, simply use NULL for that movie's plot.
-- Only display the first 15 results (there are 2040 total).
--
-- Schema: title text, runtime text, plot text
--  Order: descending runtime, ascending title

SELECT title,
       m.info AS runtime,
       n.info AS plot
FROM movie
JOIN movie_info AS m ON movie.id = m.movie_id
LEFT JOIN movie_info AS n ON movie.id = n.movie_id
AND n.info_id = 98
WHERE kind_id = 3
  AND movie.year = 2015
  AND m.info_id = 1
ORDER BY runtime DESC,
         title ASC
LIMIT 15;


--
\echo QUERY #4
\echo
-- List the top 10 actors and actresses with "Smith" in their name.
-- By "top" we mean those who have been in the most movies of any
-- type. If a person plays more than one role in a particular movie,
-- then that movie should only be counted once for that person.
--
-- Schema: name text, count bigint
--  Order: descending count, ascending name

SELECT person.name,
       COUNT(DISTINCT cast_info.movie_id)
FROM person
JOIN cast_info ON person.id = cast_info.person_id
WHERE cast_info.role_id <= 2
  AND person.name LIKE '%Smith%'
GROUP BY person.id
ORDER BY COUNT DESC, name ASC
LIMIT 10;




--
\echo QUERY #5
\echo
SELECT character.name AS char_name
FROM CHARACTER
JOIN cast_info ON character.id = cast_info.char_id
JOIN person ON cast_info.person_id = person.id
WHERE person.name = 'Depp, Johnny'
GROUP BY char_name
ORDER BY char_name;


--
\echo QUERY #6
\echo
-- For all movies in 2016 (of any kind), which ones have over 100 movie_info
-- records (of any type)?
--
-- Schema: title text, kind varchar(15), count bigint
--  Order: descending count, ascending title

SELECT title,
       kind_type.kind,
       COUNT(info_id)
FROM movie
JOIN kind_type ON movie.kind_id = kind_type.id
JOIN movie_info ON movie.id = movie_info.movie_id
WHERE YEAR = 2016
GROUP BY title,
         kind
HAVING COUNT(info_id) > 100
ORDER BY COUNT DESC ;


--------------------------------------------------------------------------------
-- TPC-H Queries
\c tpch
--------------------------------------------------------------------------------

--
\echo QUERY #7
\echo
-- Which parts are supplied in the Europe region?
--
-- Schema: p_partkey integer, p_name varchar(55), p_retailprice numeric
--  Order: p_retailprice, p_partkey
SELECT p_partkey,
       p_name,
       p_retailprice
FROM part
JOIN partsupp ON part.p_partkey = partsupp.ps_partkey
JOIN supplier ON partsupp.ps_suppkey = supplier.s_suppkey
JOIN nation ON supplier.s_nationkey = nation.n_nationkey
JOIN region ON nation.n_regionkey = region.r_regionkey
WHERE region.r_name = 'EUROPE'
ORDER BY p_retailprice,
         p_partkey
LIMIT 500;

--
\echo QUERY #8
\echo
-- Find the minimum cost supplier for each part.
--
-- You must use a subquery to receive full credit.
-- Hint: Find the minimum cost of each part first.
--
-- Schema: ps_partkey integer, ps_suppkey integer, min_supplycost numeric
--  Order: ps_partkey
SELECT ps_partkey,
       ps_suppkey,
       ps_supplycost AS min_supplycost
FROM partsupp a
WHERE ps_supplycost =
    (SELECT MIN(ps_supplycost)
     FROM partsupp b
     WHERE b.ps_partkey = a.ps_partkey)
GROUP BY ps_partkey,
         ps_suppkey
ORDER BY ps_partkey
LIMIT 500;


--
\echo QUERY #9
\echo
-- Which urgent priority orders have only one line item?
--
-- Schema: o_orderkey integer, o_custkey integer, o_orderstatus char(1)
--  Order: o_orderkey
SELECT o_orderkey,
       o_custkey,
       o_orderstatus
FROM orders
JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
WHERE o_orderpriority = '1-URGENT'
GROUP BY o_orderkey
HAVING COUNT(l_orderkey) = 1
ORDER BY o_orderkey
LIMIT 500;


--
\echo QUERY #10
\echo
-- Which parts supplied by Canadian suppliers have never been ordered?
--
-- Hint: there won't be any line items for these (partkey, suppkey) pairs.
--
-- Schema: p_partkey integer, p_name varchar(55), p_retailprice numeric
--  Order: p_retailprice
SELECT p_partkey,
       p_name,
       p_retailprice
FROM part
JOIN partsupp ON part.p_partkey = partsupp.ps_partkey
JOIN supplier ON partsupp.ps_suppkey = supplier.s_suppkey
JOIN nation ON supplier.s_nationkey = nation.n_nationkey
LEFT JOIN lineitem ON partsupp.ps_suppkey = lineitem.l_suppkey
AND partsupp.ps_partkey = lineitem.l_partkey
WHERE lineitem.l_orderkey IS NULL
  AND nation.n_name = 'CANADA'
ORDER BY part.p_retailprice;
