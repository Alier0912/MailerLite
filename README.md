# Subscriber Database Analysis
## Overview

**Dataset**: Our analysis focuses on the `subscribers_growth` table, which contains detailed subscriber information including acquisition dates, sources, geographic locations, engagement activity, and engagement scores. This dataset provides a comprehensive view of your subscriber lifecycle from signup through ongoing engagement.

**Objective**: 
The primary goal of this analysis is to assess the overall health of your subscriber base, understand acquisition effectiveness, measure retention patterns, and identify at-risk segments that require targeted intervention. By examining these dimensions, we aim to provide actionable insights that drive subscriber retention and long-term engagement.

**Key Focus Areas**:
- **Growth Metrics**: Understanding acquisition trends across different sources and geographies
- **Retention & Cohort Analysis**: Measuring how well we retain subscribers over 30-day and 90-day periods
- **Engagement Quality**: Evaluating which acquisition channels produce the most engaged subscribers
- **Risk Assessment**: Identifying subscribers at risk of churn so proactive measures can be taken

```sql
CREATE TABLE subscribers_growth(
    subscriber_id INT,
    date_joined TIMESTAMP,
    source VARCHAR(100),
    country VARCHAR(100),
    last_open_date TIMESTAMP,
    engagement_score FLOAT
```

)
-  The table is loaded using the pg Admin. Now we can view the dataset
```sql
SELECT * FROM subscribers_growth
```

1. Growth analysis(Acquisition health)

*What is our monthly growth trend?*
```sql
SELECT 
EXTRACT('month' FROM date_joined) AS month, 
EXTRACT('year' FROM date_joined) AS year,
COUNT(subscriber_id) AS new_subscribers
FROM subscribers_growth
GROUP BY 1, 2
ORDER BY 2, 1
```
*Which acquisition sources drive the most new subscribers?*
```sql
SELECT 
    source,
    COUNT(subscriber_id) AS new_subscribers
FROM  subscribers_growth
GROUP BY 1
ORDER BY 2 DESC
```

**Which countries are our subscribers coming from?*
```sql
SELECT 
        country, 
        COUNT(subscriber_id) AS new_subscribers 
FROM subscribers_growth 
GROUP BY 1 
ORDER BY 2 DESC
```
2. Engagement Quality (List Health)
   
*What percentage of subscribers are active vs inactive?*
```sql
SELECT
    CASE
        WHEN last_open_date >= NOW() - INTERVAL '90 Days' THEN 'Active'
        ELSE 'Inactive' 
        END AS engagement_status,
        COUNT(subscriber_id) AS subscriber_count,
        ROUND((COUNT(subscriber_id) * 100.0 / (SELECT COUNT(*) FROM subscribers_growth)), 2) AS percentage 
FROM subscribers_growth
GROUP BY 1 
```

**Which acquisition sources produce the most engaged subscribers?*
```sql
SELECT 
        source,
        COUNT(subscriber_id) AS engaged_subscribers
FROM subscribers_growth WHERE last_open_date >= NOW() - INTERVAL '90 Days' 
GROUP BY 1 
ORDER BY 2 DESC
```
*How is engagement score distributed?*
```sql
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
```

3.  Retention & Cohort Analysis
*How does engagement decline over time?*
```sql
SELECT
        EXTRACT('month' FROM date_joined) AS month,
        EXTRACT('year' FROM date_joined) AS year,
        COUNT(subscriber_id) AS total_subsribers,
        COUNT(CASE WHEN last_open_date >= NOW() - INTERVAL '90 Days' THEN 1 END) AS active_subscribers,
        ROUND((COUNT(CASE WHEN last_open_date >= NOW() - INTERVAL '90 Days' THEN 1 END) * 100.0 / COUNT(subscriber_id)), 2) AS retention_rate
FROM subscribers_growth
GROUP BY 1, 2
ORDER BY 2, 1
```

*What is 30-day and 90-day retention by cohort?*
```sql
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
```

4.  Strategic Insight (Action-Oriented)
*Which source brings high volume but low engagement?*
```sql
SELECT
        source,
        COUNT(subscriber_id) AS total_subsribers,
        COUNT( CASE WHEN last_open_date >= NOW() - INTERVAL '90 Days' THEN 1 END) AS engaged_subscribers,
        ROUND((COUNT(CASE WHEN last_open_date >= NOW() - INTERVAL '90 Days' THEN 1 END) * 100.0 / COUNT(subscriber_id)), 2) AS engagement_percentage
FROM subscribers_growth
GROUP BY 1
ORDER BY 2 DESC
```
*  What percentage of the total database is “at risk”?
*  Define at-risk as:
*   ngagement score below threshold
*   open in last 60–90 days

```sql
SELECT
        COUNT(subscriber_id) AS total_subsribers,
        COUNT(CASE WHEN engagement_score < 50 OR last_open_date < NOW() - INTERVAL '60 Days' THEN 1 END) AS at_risk_subscribers,
        ROUND((COUNT(CASE WHEN engagement_score < 50 OR last_open_date < NOW() - INTERVAL '60 Days' THEN 1 END) * 100.0 / COUNT(subscriber_id)), 2) AS at_risk_percentage 
FROM subscribers_growth
GROUP BY 1
``` 

## Findings
1. **Subscriber Growth Trends**: The analysis of the `subscribers_growth` table indicates a monthly growth pattern in subscriber numbers. The data shows fluctuations in growth rates, which may correlate with marketing campaigns or seasonal trends.

2. **Retention Rates**: The retention rate over 90 days is calculated, revealing that a significant percentage of subscribers do not engage after their initial sign-up. This suggests a need for improved onboarding processes or follow-up strategies.

3. **Engagement Insights**: The engagement analysis highlights that certain sources bring in a high volume of subscribers but result in low engagement rates. This indicates that while these sources are effective for acquisition, they may not be ideal for long-term retention.

4. **At-Risk Subscribers**: A considerable portion of the subscriber base is classified as “at risk,” defined by low engagement scores and inactivity over the last 60-90 days. This group requires immediate attention to prevent churn.

## Conclusions
- The current subscriber acquisition strategies are effective in generating leads but lack in maintaining engagement. 
- There is a clear need for targeted re-engagement campaigns aimed at at-risk subscribers to improve retention rates.
- The data suggests that not all acquisition sources are equal; some may need to be reevaluated or optimized to enhance overall engagement.

## Recommendations

We've identified key opportunities to strengthen your subscriber relationships and build a more engaged, loyal community. Here are strategic initiatives we recommend implementing:

1. **Enhance Onboarding**: First impressions matter. Implement a more robust onboarding process that includes personalized communication and compelling value propositions to improve initial engagement. A thoughtful welcome sequence helps subscribers quickly understand the value you provide, setting the foundation for long-term relationships.

2. **Targeted Re-Engagement Campaigns**: Your at-risk subscribers represent an opportunity, not a loss. Develop campaigns specifically aimed at these subscribers, offering incentives or tailored content that reignites their interest. These personalized touch-points show that you value their presence in your community.

3. **Source Evaluation**: Not all acquisition channels perform equally, and that's valuable information. Regularly assess the performance of different sources to identify which bring the most engaged subscribers. This data-driven approach allows you to invest more in high-performing channels while refining or reimagining underperforming ones.

4. **Monitor Engagement Metrics**: Make engagement metrics your compass. Continuously track these indicators to spot trends early and make informed decisions about your marketing strategies. Regular monitoring empowers you to stay ahead of changes and adapt quickly to keep your audience engaged.
