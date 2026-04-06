USE ig_clone;

--- Q1
WITH UserActivity AS (
    SELECT
        U.id AS user_id,
        U.username,
        COUNT(DISTINCT P.id) AS total_posts,
        COUNT(DISTINCT L.photo_id) AS total_likes,
        COUNT(DISTINCT C.id) AS total_comments
    FROM
        users AS U
    LEFT JOIN
        photos AS P ON U.id = P.user_id
    LEFT JOIN
        likes AS L ON U.id = L.user_id
    LEFT JOIN
        comments AS C ON U.id = C.user_id
    GROUP BY
        U.id,
        U.username
)
SELECT
    user_id,
    username,
    total_posts,
    total_likes,
    total_comments,
    (total_posts * 3) + (total_comments * 2) + (total_likes * 1) AS activity_score,
    DENSE_RANK() OVER (ORDER BY (total_posts * 3) + (total_comments * 2) + (total_likes * 1) DESC) AS activity_rank
FROM
    UserActivity
ORDER BY
    activity_rank ASC,
    username ASC;

--- Q2
SELECT
    u.username
FROM
    users AS u
LEFT JOIN
    likes AS l ON u.id = l.user_id AND l.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
WHERE
    l.user_id IS NULL;

--- Q3
WITH PhotoLikes AS (
    SELECT
        P.id AS photo_id,
        COUNT(L.photo_id) AS total_likes
    FROM
        photos AS P
    LEFT JOIN
        likes AS L ON P.id = L.photo_id
    GROUP BY
        P.id
)
SELECT
    T.tag_name,
    AVG(PL.total_likes) AS average_likes
FROM
    tags AS T
JOIN
    photo_tags AS PT ON T.id = PT.tag_id
JOIN
    PhotoLikes AS PL ON PT.photo_id = PL.photo_id
GROUP BY
    T.tag_name
ORDER BY
    average_likes DESC;

--- Q4
SELECT
    HOUR(created_at) AS hour_of_day,
    COUNT(*) AS total_likes
FROM
    likes
GROUP BY
    hour_of_day
ORDER BY
    total_likes DESC;
    
--- Q5
WITH photo_metrics AS (
    SELECT
        P.id AS photo_id,
        P.user_id,
        COUNT(DISTINCT L.user_id) AS total_likes,
        COUNT(DISTINCT C.id) AS total_comments
    FROM
        photos AS P
    LEFT JOIN
        likes AS L ON P.id = L.photo_id
    LEFT JOIN
        comments AS C ON P.id = C.photo_id
    GROUP BY
        P.id, P.user_id
),

-- Step 2: Aggregate the total likes and comments for each user.
user_metrics AS (
    SELECT
        user_id,
        SUM(total_likes) AS total_likes,
        SUM(total_comments) AS total_comments
    FROM
        photo_metrics
    GROUP BY
        user_id
),

-- Step 3: Count the total followers for each user.
follower_counts AS (
    SELECT
        followee_id AS user_id,
        COUNT(follower_id) AS follower_count
    FROM
        follows
    GROUP BY
        followee_id
)

-- Step 4: Combine the metrics, calculate engagement rate, and rank the users.
SELECT
    U.username,
    COALESCE(UM.total_likes, 0) AS total_likes,
    COALESCE(UM.total_comments, 0) AS total_comments,
    COALESCE(FC.follower_count, 0) AS follower_count,
    -- Calculate engagement rate, handling division by zero for users with no followers.
    CAST((COALESCE(UM.total_likes, 0) + COALESCE(UM.total_comments, 0)) AS FLOAT) /
    CASE
        WHEN COALESCE(FC.follower_count, 0) = 0 THEN 1
        ELSE FC.follower_count
    END AS engagement_rate,
    -- Rank users based on engagement rate.
    DENSE_RANK() OVER (ORDER BY (COALESCE(UM.total_likes, 0) + COALESCE(UM.total_comments, 0)) /
    CASE
        WHEN COALESCE(FC.follower_count, 0) = 0 THEN 1
        ELSE FC.follower_count
    END DESC) AS engagement_rank
FROM
    users AS U
LEFT JOIN
    user_metrics AS UM ON U.id = UM.user_id
LEFT JOIN
    follower_counts AS FC ON U.id = FC.user_id
ORDER BY
    engagement_rate DESC, U.username;
    
--- Q6
-- CTE to count the number of posts for each user.
WITH user_posts AS (
    SELECT
        user_id,
        COUNT(id) AS post_count
    FROM
        photos
    GROUP BY
        user_id
),

-- CTE to count the total likes received by each user on their posts.
user_likes AS (
    SELECT
        P.user_id,
        COUNT(L.user_id) AS like_count
    FROM
        photos AS P
    LEFT JOIN
        likes AS L ON P.id = L.photo_id
    GROUP BY
        P.user_id
),

-- CTE to count the total comments received by each user on their posts.
user_comments AS (
    SELECT
        P.user_id,
        COUNT(C.id) AS comment_count
    FROM
        photos AS P
    LEFT JOIN
        comments AS C ON P.id = C.photo_id
    GROUP BY
        P.user_id
),

-- CTE to count the number of followers for each user.
user_followers AS (
    SELECT
        followee_id AS user_id,
        COUNT(follower_id) AS follower_count
    FROM
        follows
    GROUP BY
        followee_id
),

-- CTE to count the number of people each user is following.
user_followings AS (
    SELECT
        follower_id AS user_id,
        COUNT(followee_id) AS following_count
    FROM
        follows
    GROUP BY
        follower_id
)

-- Final SELECT statement to combine all metrics and assign a segment.
SELECT
    U.id,
    U.username,
    COALESCE(UP.post_count, 0) AS post_count,
    COALESCE(UL.like_count, 0) AS like_count,
    COALESCE(UC.comment_count, 0) AS comment_count,
    COALESCE(UF.follower_count, 0) AS follower_count,
    COALESCE(UFG.following_count, 0) AS following_count,
    CASE
        WHEN COALESCE(UP.post_count, 0) > 50 THEN 'Content Creator'
        WHEN COALESCE(UL.like_count, 0) > 1000 THEN 'Super Fan'
        WHEN COALESCE(UF.follower_count, 0) > 1000 AND COALESCE(UFG.following_count, 0) > 1000 THEN 'Community Builder'
        ELSE 'Inactive User'
    END AS user_segment
FROM
    users AS U
LEFT JOIN
    user_posts AS UP ON U.id = UP.user_id
LEFT JOIN
    user_likes AS UL ON U.id = UL.user_id
LEFT JOIN
    user_comments AS UC ON U.id = UC.user_id
LEFT JOIN
    user_followers AS UF ON U.id = UF.user_id
LEFT JOIN
    user_followings AS UFG ON U.id = UFG.user_id
ORDER BY
    U.id;
    

--- Q7
WITH user_posts AS (
    SELECT
        user_id,
        COUNT(id) AS post_count
    FROM
        photos
    GROUP BY
        user_id
),

-- CTE to count the total likes received by each user on their posts.
user_likes AS (
    SELECT
        P.user_id,
        COUNT(L.user_id) AS like_count
    FROM
        photos AS P
    LEFT JOIN
        likes AS L ON P.id = L.photo_id
    GROUP BY
        P.user_id
),

-- CTE to count the total comments received by each user on their posts.
user_comments AS (
    SELECT
        P.user_id,
        COUNT(C.id) AS comment_count
    FROM
        photos AS P
    LEFT JOIN
        comments AS C ON P.id = C.photo_id
    GROUP BY
        P.user_id
),

-- CTE to count the number of followers for each user.
user_followers AS (
    SELECT
        followee_id AS user_id,
        COUNT(follower_id) AS follower_count
    FROM
        follows
    GROUP BY
        followee_id
),

-- CTE to count the number of people each user is following.
user_followings AS (
    SELECT
        follower_id AS user_id,
        COUNT(followee_id) AS following_count
    FROM
        follows
    GROUP BY
        follower_id
),

-- CTE to segment all users based on their behavior.
user_segments AS (
    SELECT
        U.id AS user_id,
        U.username,
        CASE
            WHEN COALESCE(UP.post_count, 0) > 50 THEN 'Content Creator'
            WHEN COALESCE(UL.like_count, 0) > 1000 THEN 'Super Fan'
            WHEN COALESCE(UF.follower_count, 0) > 1000 AND COALESCE(UFG.following_count, 0) > 1000 THEN 'Community Builder'
            ELSE 'Inactive User'
        END AS user_segment
    FROM
        users AS U
    LEFT JOIN
        user_posts AS UP ON U.id = UP.user_id
    LEFT JOIN
        user_likes AS UL ON U.id = UL.user_id
    LEFT JOIN
        user_comments AS UC ON U.id = UC.user_id
    LEFT JOIN
        user_followers AS UF ON U.id = UF.user_id
    LEFT JOIN
        user_followings AS UFG ON U.id = UFG.user_id
),

-- Hypothetical CTE representing ad campaign data for each user.
ad_campaign_data AS (
    -- In a real-world scenario, we would replace this with our actual ad data table.
    -- The table would contain a user ID, a click event, and a conversion event.
    SELECT
        user_id,
        SUM(CASE WHEN is_clicked = 1 THEN 1 ELSE 0 END) AS total_clicks,
        SUM(CASE WHEN is_converted = 1 THEN 1 ELSE 0 END) AS total_conversions
    FROM
        ad_campaigns -- Replace with our actual ad data table.
    GROUP BY
        user_id
)

-- Final SELECT to join segments and ad data, calculating conversion rate per segment.
SELECT
    US.user_segment,
    SUM(ACD.total_clicks) AS total_clicks,
    SUM(ACD.total_conversions) AS total_conversions,
    -- Calculate conversion rate, handling division by zero.
    CAST(SUM(ACD.total_conversions) AS FLOAT) /
    CASE
        WHEN SUM(ACD.total_clicks) = 0 THEN 1
        ELSE SUM(ACD.total_clicks)
    END AS conversion_rate
FROM
    user_segments AS US
JOIN
    ad_campaign_data AS ACD ON US.user_id = ACD.user_id
GROUP BY
    US.user_segment
ORDER BY
    conversion_rate DESC;

--- Q8
-- Step 1: Aggregate the total number of posts, likes, and comments for each user.
WITH user_activity AS (
    SELECT
        U.id AS user_id,
        U.username,
        COUNT(DISTINCT P.id) AS total_posts,
        COUNT(DISTINCT L.user_id) AS total_likes,
        COUNT(DISTINCT C.id) AS total_comments
    FROM
        users AS U
    LEFT JOIN
        photos AS P ON U.id = P.user_id
    LEFT JOIN
        likes AS L ON P.id = L.photo_id
    LEFT JOIN
        comments AS C ON P.id = C.photo_id
    GROUP BY
        U.id
),

-- Step 2: Aggregate the total number of followers and followings for each user.
user_connections AS (
    SELECT
        U.id AS user_id,
        COUNT(DISTINCT F_follower.follower_id) AS follower_count,
        COUNT(DISTINCT F_followee.followee_id) AS following_count
    FROM
        users AS U
    LEFT JOIN
        follows AS F_follower ON U.id = F_follower.followee_id
    LEFT JOIN
        follows AS F_followee ON U.id = F_followee.follower_id
    GROUP BY
        U.id
)

-- Step 3: Combine activity and connection metrics to identify Community Builders and rank them.
SELECT
    UA.username,
    UA.total_posts,
    UA.total_likes,
    UA.total_comments,
    UC.follower_count,
    UC.following_count,
    -- Calculate the ratio of comments to likes. Use a CASE statement to handle division by zero.
    CAST(UA.total_comments AS FLOAT) /
    CASE
        WHEN UA.total_likes = 0 THEN 1
        ELSE UA.total_likes
    END AS conversation_ratio,
    -- Rank the users by their conversation ratio.
    DENSE_RANK() OVER (
        ORDER BY
            CAST(UA.total_comments AS FLOAT) /
            CASE
                WHEN UA.total_likes = 0 THEN 1
                ELSE UA.total_likes
            END DESC
    ) AS conversation_rank
FROM
    user_activity AS UA
JOIN
    user_connections AS UC ON UA.user_id = UC.user_id
WHERE
    -- Filter for users who fit the 'Community Builder' profile.
    UC.follower_count > 10 AND UC.following_count > 10 AND UA.total_posts > 5
ORDER BY
    conversation_ratio DESC, UA.username;


--- Q10
UPDATE User_Interactions
SET Engagement_Type = 'Heart'
WHERE Engagement_Type = 'Like';