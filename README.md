**📊 SQL Social Media Analytics Project (Meta - Instagram)**

<img width="2315" height="1278" alt="image" src="https://github.com/user-attachments/assets/a1542a31-42a0-4e4f-b24e-1e53bf584952" />


**🚀 Project Overview**

In this project, I worked as a Data Analyst at Meta, collaborating with the Marketing team to analyze Instagram user data and generate actionable insights.
The goal is to leverage SQL-based analysis to support targeted marketing strategies that improve:
-- User Engagement
--User Retention
-- User Acquisition


**🎯 Business Objectives**

-- Identify highly engaged users and content patterns
-- Detect inactive or churn-risk users
-- Analyze user behavior trends
-- Support personalized marketing campaigns
-- Optimize content and posting strategies


**🧠 Key Business Questions**

-- Who are the most active users on the platform?
-- What type of content drives the highest engagement?
-- What is the optimal time for posting content?
-- How do hashtags influence engagement?
-- Which users have the highest influence (followers vs engagement)?


**🗂️ Database Schema**

The dataset consists of the following key tables:

-- users: User profile information
-- photos: Posts uploaded by users
-- likes:	Likes on posts
-- comments:	Comments on posts
-- follows:	Follower-following relationships
-- tags:	Hashtags used in posts
-- photo_tags:	Mapping between photos and tags

<img width="1094" height="844" alt="image" src="https://github.com/user-attachments/assets/21c23e81-2aeb-40e5-b745-05c39637eda7" />


**🛠️ Tools & Technologies**

-- SQL (MySQL)
-- DBMS for querying and analysis
-- Excel (optional for visualization)


**📊 Key Analyses Performed**

**1. User Engagement Analysis**
-- Most active users based on posts, likes, and comments
-- Engagement rate per user

**2. Content Performance**
-- Most liked and commented posts
-- Top-performing hashtags

**3. Hashtag Analysis**
-- Most frequently used hashtags
-- Hashtags driving maximum engagement

**4. User Retention & Churn**
-- Users with no activity (potential churn)
-- Long inactive accounts

**5. Influence Analysis**
-- Users with highest followers
-- Engagement vs follower count comparison

**6. Posting Behavior**
-- Most popular days and times for posting
-- Posting frequency trends


**📈 Sample Insights**
-- A small percentage of users generate the majority of engagement
-- Certain hashtags significantly boost visibility and interaction
-- Many users sign up but never post (onboarding gap)
-- Peak engagement occurs during specific hours/days


**💡 Recommendations**

**📌 Engagement**
-- Promote high-performing content formats
-- Encourage user interaction through comments and likes

**📌 Retention**
--Target inactive users with personalized notifications
--Improve onboarding experience for new users

**📌 Acquisition**
-- Use trending hashtags to increase reach
-- Collaborate with high-influence users

**📌 Content Strategy**
-- Post during peak engagement hours
-- Focus on content types with higher interaction rates

**🧾 Example SQL Queries**
🔹 Top 5 Most Active Users
SELECT user_id, COUNT(*) AS total_posts
FROM photos
GROUP BY user_id
LIMIT 5;

🔹 Most Popular Hashtags
SELECT t.tag_name, COUNT(*) AS usage_count
FROM tags t
JOIN photo_tags pt ON t.id = pt.tag_id
GROUP BY t.tag_name
LIMIT 10;
