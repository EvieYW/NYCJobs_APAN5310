-- GROUP PROJECT ANALYTICS PROCEDURES
--1. Top10 job vacancy group by category

With tep2 AS(With tep AS (SELECT job_category, SUM(number_of_positions) AS vacancy
						  FROM job_info AS I, job_category AS C
						  WHERE I.category_id = C.category_id
						  GROUP BY job_category
						  ORDER BY vacancy DESC)
			 SELECT job_category, vacancy, RANK()OVER(ORDER BY vacancy DESC) AS c_rank
			 FROM tep)
SELECT job_category, vacancy
FROM tep2
WHERE c_rank <= 10;

--2. Vacancy by month

SELECT EXTRACT(MONTH FROM posting_date) AS posting_month, SUM(number_of_positions) AS vacancy
FROM job_info AS I, posting AS P
WHERE I.post_id = P.post_id
GROUP BY posting_month
ORDER BY posting_month;

--3. Geographic distribution
/*In order to produce a map visualize, we add a new attribute to agency collection.
 *if you run this coed you will get error since we didn't change original database but
 *build a new one and connected to Metabase for visualization.
 */

SELECT A.zipcode, SUM(j.number_of_positions) AS vacancy
FROM job_info AS J, agency AS A
WHERE J.agency_id = A.agency_id
GROUP BY zipcode
ORDER BY vacancy DESC;

--4. Top5 job vacancy group by Career level 

SELECT career_level, SUM(number_of_positions) AS vacancy
FROM job_info AS I, career AS C
WHERE I.career_level_id = C.career_level_id
GROUP BY career_level
ORDER BY vacancy DESC
LIMIT 5;

--5. Top 10 job vacancy group by business title

With tep2 AS(
With tep AS (SELECT business_title, SUM(number_of_positions) AS vacancy
			 FROM job_info AS I, business_title AS B
			 WHERE I.business_title_id = B.business_title_id
			 GROUP BY business_title)
SELECT business_title, vacancy, RANK()OVER(ORDER BY vacancy DESC) AS b_rank
FROM tep)
SELECT business_title, vacancy
FROM tep2
WHERE b_rank <=10;

--6. Top 5 highest-paid agency

With tep2 AS(
With tep AS (SELECT agency, AVG(salary_range_to) AS avg_salary
			 FROM job_info AS I, agency AS A, salary AS S
			 WHERE I.salary_id = S.salary_id AND I.agency_id = A.agency_id AND salary_frequency = 'Annual'
			 GROUP BY agency)
SELECT agency, avg_salary, RANK()OVER(ORDER BY avg_salary DESC) AS s_rank
FROM tep)
SELECT agency, avg_salary
FROM tep2
WHERE s_rank <= 5;

--7. Full-/part-time vs. external/internal

SELECT posting_type, full_time_part_time_indicator, SUM(number_of_positions) AS vacancy
FROM job_info AS I, posting AS P
WHERE I.post_id = P.post_id
GROUP BY (posting_type, full_time_part_time_indicator)

--8. Top10 job vacancy group by agency

With tep2 AS(
With tep AS (SELECT agency, SUM(number_of_positions) AS vacancy
			 FROM job_info AS I, agency AS A
			 WHERE I.agency_id = A.agency_id
			 GROUP BY agency)
SELECT agency, vacancy, RANK()OVER(ORDER BY vacancy DESC) AS a_rank
FROM tep)
SELECT agency, vacancy
FROM tep2
WHERE a_rank <= 10;

--9. Fulfill rate of agencies

With fufilled(agency_id, num_pos_fulfilled) AS
	 (SELECT I.agency_id, COUNT(*)
	  FROM job_info AS I, posting AS P
	  WHERE I.post_id = P.post_id AND P.post_until IS NOT null
	  GROUP BY I.agency_id),
	 agency_post_count(agency_id, post_count) AS
	 (SELECT I.agency_id, COUNT(*)
	  FROM job_info AS I
	  GROUP BY I.agency_id)
SELECT temp.agency, round(SUM(temp.job_fulfill_rate) / COUNT(*), 2) AS job_fulfill_rate
FROM (SELECT AG.agency AS agency, 
			F.num_pos_fulfilled/A.post_count AS job_fulfill_rate 
	  FROM job_info AS I, agency_post_count AS A, fufilled AS F, agency AS AG
	  WHERE I.agency_id = A.agency_id AND F.agency_id = I.agency_id AND AG.agency_id = I.agency_id
	  ORDER BY job_fulfill_rate DESC) AS temp
GROUP BY agency
ORDER BY job_fulfill_rate DESC;

--10. Posting type (internal/external) with more vacancy over the time

With vacancy_table(mon, yyyy, posting_type, num_vacancy) AS 
	(SELECT EXTRACT(MONTH FROM P.posting_date),
     	EXTRACT(YEAR FROM P.posting_date),
     	P.posting_type,
     	SUM(I.number_of_positions) AS num_vacancy
	 FROM job_info AS I, posting AS P
	 WHERE I.post_id = P.post_id
	 GROUP BY 1,2,3)
SELECT CAST(YEAR AS text)||'/'|| CAST(mon AS text) AS time, 
	posting_type, num_vacancy
FROM (SELECT mon AS mon,
		yyyy AS year,
		posting_type AS posting_type, 
		num_vacancy AS num_vacancy,
	  	RANK() OVER (PARTITION BY posting_type) AS grouped_rank
	  FROM vacancy_table) AS rank_filter
WHERE grouped_rank = 1
ORDER BY time;













