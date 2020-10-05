-- Name: DEVDUTT SANTHOSH

--------------------------------------------------------------------------------
-- DBLP Queries
\c dblp
--------------------------------------------------------------------------------

--
\echo QUERY #1
\echo
-- Find all publications since Jan 1, 2000 that have the words 'K-12 education'
-- anywhere in the title (i.e., the user typed that into a simple search box).
--
-- Schema: year, title, dblp_type, booktitle, journal, volume, issnum, pages
--  Order: dblp_mdate, dblp_key
SELECT YEAR,
       title,
       dblp_type,
       booktitle,
       journal,
       volume,
       issnum,
       pages
FROM publ
NATURAL JOIN publ_fts
WHERE title_tsv @@ plainto_tsquery('K-12 education')
  AND dblp_mdate >= '2000-01-01'
  AND YEAR >='2000'
ORDER BY dblp_mdate,
         dblp_key;



--
\echo QUERY #2
\echo
-- Search for publications that have a title similar to "Principles of Database
-- Management". Set the similarity threshold to 0.5 before running your query.
-- For full credit, you must use the string "Principles of Database Management"
-- only once in your query.
--
-- Schema: dblp_key, year, title, similarity
--  Order: similarity DESC, dblp_key

SELECT set_limit(0.5);


SELECT dblp_key,
       YEAR,
       publ.title,
       similarity(publ.title, book.title)
FROM publ,

  (SELECT 'Principles of Database Management') AS book(title)
WHERE publ.title % book.title
ORDER BY similarity DESC,
         dblp_key;



--
\echo QUERY #3
\echo
-- List the coauthors of Jennifer Widom who have written more publications
-- than she has.
--
-- You must write the query in a generic way that would work for any author.
-- Hint: The only table you need is auth. Use subqueries to do the counting.
--
-- Schema: coauthor
--  Order: coauthor
SELECT author AS coauthor
FROM
  (SELECT DISTINCT b.author
   FROM auth AS a
   JOIN auth AS b ON a.dblp_key = b.dblp_key
   AND a.author<> b.author
   WHERE a.author = 'Jennifer Widom')SUB
AND SUM(b.dblp_key)>
  (SELECT sum(a.dblp_key)
   FROM auth
   WHERE author='jennifer widom');

GROUP BY author
ORDER BY author;


--
\echo QUERY #4
\echo
-- Write a recursive query that lists authors related to Chris Mayfield (in the
-- sense of coauthorship) along with their collaborative distance: 1 = coauthor,
-- 2 = coauthor's coauthor, etc.
--
-- Hint #1: In the initial query (the non-recursive part), select all coauthors
-- of Chris Mayfield with a depth of 1 and a path of ARRAY[coauthor, Mayfield].
-- Hint #2: Since the results are limited to 500 rows, the max depth you will
-- need to compute is 3.
--
-- Schema: author, min_depth
--  Order: min_depth, author

WITH RECURSIVE search(author, depth, PATH) AS
  (-- find the coauthors of Erdös
 SELECT DISTINCT b.author,
                 1 AS depth, ARRAY[b.author,
                                   'Mayfield,Christopher Scott']
   FROM auth AS a -- same paper, but different author

   JOIN auth AS b ON a.dblp_key = b.dblp_key
   AND a.author != b.author
   WHERE a.author = 'Mayfield,Christopher Scott'
     SELECT *
     FROM e
   UNION ALL -- find the coauthors of coauthors
 SELECT DISTINCT d.author,
                 e.depth + 1 AS depth,
                 PATH || d.author
   FROM e -- first get all papers of e's authors
 
   JOIN auth AS c ON e.author = c.author -- same paper, but different author
 
   JOIN auth AS d ON c.dblp_key = d.dblp_key 
   AND c.author != d.author 
   WHERE d.author != 'Mayfield,Christopher Scott'
     AND depth < 3
     AND NOT d.author = ANY(PATH) )
SELECT *
FROM SEARCH
ORDER BY depth,
         author;

--------------------------------------------------------------------------------
-- JMU Queries
\c jmudb
--------------------------------------------------------------------------------

--
\echo QUERY #5
\echo
-- List all courses that have had more students enrolled than 1.5 times the
-- room capacity. Ignore classrooms that have a capacity of zero (unlimited).
--
-- Schema: term int4, subject text, number int4, suffix text, section text,
--         room text, room_cap integer, enrolled integer, enrl_cap integer
--  Order: term, subject, number, suffix, section, room

SELECT DISTINCT term, subject, number, suffix, section, room , room_cap, enrolled, enrl_cap
FROM enrollment
WHERE enrolled > 1.5*room_cap
  AND room_cap != 0
ORDER BY term, subject, number, suffix, section, room;



--
\echo QUERY #6
\echo
-- For each instructor, count the total number of students they have taught in
-- CS courses over the past three academic years. Be careful not to count the
-- same section of students more than once.
--
-- Schema: instructor text, students bigint
--  Order: sum descending, instructor
SELECT instructor , SUM(enrolled) 
FROM
 (SELECT DISTINCT term, section, number, enrolled, instructor 
  FROM enrollment
  WHERE term > 1171
   AND subject = 'CS')SUB
GROUP BY instructor
ORDER BY SUM DESC;


--
\echo QUERY #7
\echo
-- List all sections in Spring 2020 with more that 100 students enrolled, and
-- rank them by course (i.e., the section with the most students is rank #1).
--
-- Schema: subject, number, nbr, enrolled, rank
--  Order: subject, number, nbr
SELECT subject, number, nbr, enrolled,
  rank() OVER (PARTITION BY subject,number ORDER BY enrolled DESC )
FROM
  (SELECT subject, number, nbr, enrolled    
   FROM enrollment
   WHERE term = '1201'
     AND enrolled > '100') AS DEV
ORDER BY subject, number, nbr;



--
\echo QUERY #8
\echo
-- Rank departments in Spring 2020 by their total enrollment, i.e., who has the
-- most students enrolled across all sections. (Hint: two nested subqueries)
--
-- Schema: subject, total, rank
--  Order: subject

SELECT DISTINCT subject, total,
  rank() OVER (ORDER BY total DESC)
FROM(SELECT subject, SUM(enrolled) as total
	 FROM
    (SELECT DISTINCT nbr, subject , number , enrolled
     FROM enrollment
     WHERE term = '1201') AS DEV
GROUP BY subject)DEV1
ORDER BY subject;


