DROP TABLE IF EXISTS subscribers_growth;
CREATE TABLE subscribers_growth(
    subscriber_id INT,
    date_joined TIMESTAMP,
    source VARCHAR(100),
    country VARCHAR(100),
    last_open_date TIMESTAMP,
    engagement_score FLOAT

)
--  The table is loaded using the pg Admin. Now we can view the dataset
SELECT * FROM subscribers_growth

-- 1. Growth analysis(Acquisition health)
-- a.) What is our monthly growth trend?
SELECT 
EXTRACT('month' FROM date_joined) AS month, 
EXTRACT('year' FROM date_joined) AS year,
COUNT(subscriber_id) AS new_subscribers
FROM subscribers_growth
GROUP BY 1, 2
ORDER BY 2, 1

-- b.) Which acquisition sources drive the most new subscribers?
SELECT 
    source,
    COUNT(subscriber_id) AS new_subscribers
FROM  subscribers_growth
GROUP BY 1
ORDER BY 2 DESC 
-- c.) Which countries are our subscribers coming from? 
SELECT 
        country, 
        COUNT(subscriber_id) AS new_subscribers 
FROM subscribers_growth 
GROUP BY 1 
ORDER BY 2 DESC

-- 2. Engagement Quality (List Health)
-- a.) What percentage of subscribers are active vs inactive?
SELECT
    CASE
        WHEN last_open_date >= NOW() - INTERVAL '90 Days' THEN 'Active'
        ELSE 'Inactive' 
        END AS engagement_status,
        COUNT(subscriber_id) AS subscriber_count,
        ROUND((COUNT(subscriber_id) * 100.0 / (SELECT COUNT(*) FROM subscribers_growth)), 2) AS percentage 
FROM subscribers_growth
GROUP BY 1 

-- b.) Which acquisition sources produce the most engaged subscribers?
SELECT 
        source,
        COUNT(subscriber_id) AS engaged_subscribers
FROM subscribers_growth WHERE last_open_date >= NOW() - INTERVAL '90 Days' 
GROUP BY 1 
ORDER BY 2 DESC

-- c.) How is engagement score distributed?
SELECT
     CASE
        WHEN engagement_score >= 80 THEN 'High'
        WHEN engagement_score >= 50 THEN 'Medium'
        ELSE 'Low' 
        END AS engagement_level,
        COUNT(subscriber_id) AS subscriber_count,
        ROUND((COUNT(subscriber_id) * 100.0 / (SELECT COUNT(*) FROM subscribers_growth)), 2) AS percentage
FROM subscribers_growth
GROUP BY 1
ORDER BY 2 DESC

-- 3.) Retention & Cohort Analysis
-- a.) How does engagement decline over time?
SELECT
        EXTRACT('month' FROM date_joined) AS month,
        EXTRACT('year' FROM date_joined) AS year,
        COUNT(subscriber_id) AS total_subsribers,
        COUNT(CASE WHEN last_open_date >= NOW() - INTERVAL '90 Days' THEN 1 END) AS active_subscribers,
        ROUND((COUNT(CASE WHEN last_open_date >= NOW() - INTERVAL '90 Days' THEN 1 END) * 100.0 / COUNT(subscriber_id)), 2) AS retention_rate
FROM subscribers_growth
GROUP BY 1, 2
ORDER BY 2, 1

-- b.) What is 30-day and 90-day retention by cohort?
SELECT
        EXTRACT('month' FROM date_joined) AS month,
        EXTRACT('year' FROM date_joined) AS year,
        COUNT(subscriber_id) AS total_subsribers,
        COUNT(CASE WHEN last_open_date >= date_joined + INTERVAL '30 Days' THEN 1 END) AS retained_30_days,
        COUNT(CASE WHEN last_open_date >= date_joined + INTERVAL '90 Days' THEN 1 END) AS retained_90_days,
        ROUND((COUNT(CASE WHEN last_open_date >= date_joined + INTERVAL '30 Days' THEN 1 END) * 100.0 / COUNT(subscriber_id)), 2) AS retention_30_days,
        ROUND((COUNT(CASE WHEN last_open_date >= date_joined + INTERVAL '90 Days' THEN 1 END) * 100.0 / COUNT(subscriber_id)), 2) AS retention_90_days
FROM subscribers_growth
GROUP BY 1, 2
ORDER BY 2, 1

-- 4.) Strategic Insight (Action-Oriented)
-- a.) Which source brings high volume but low engagement?
SELECT
        source,
        COUNT(subscriber_id) AS total_subsribers,
        COUNT( CASE WHEN last_open_date >= NOW() - INTERVAL '90 Days' THEN 1 END) AS engaged_subscribers,
        ROUND((COUNT(CASE WHEN last_open_date >= NOW() - INTERVAL '90 Days' THEN 1 END) * 100.0 / COUNT(subscriber_id)), 2) AS engagement_percentage
FROM subscribers_growth
GROUP BY 1
ORDER BY 2 DESC

-- b.) What percentage of the total database is “at risk”?
-- Define at-risk as:
-- Engagement score below threshold
-- No open in last 60–90 days

SELECT
        COUNT(subscriber_id) AS total_subsribers,
        COUNT(CASE WHEN engagement_score < 50 OR last_open_date < NOW() - INTERVAL '60 Days' THEN 1 END) AS at_risk_subscribers,
        ROUND((COUNT(CASE WHEN engagement_score < 50 OR last_open_date < NOW() - INTERVAL '60 Days' THEN 1 END) * 100.0 / COUNT(subscriber_id)), 2) AS at_risk_percentage 
FROM subscribers_growth
GROUP BY 1
