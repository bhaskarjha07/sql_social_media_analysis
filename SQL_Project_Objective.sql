USE ig_clone;

--- Q2
SELECT u.username,
       COUNT(DISTINCT p.id) AS posts,
       COUNT(DISTINCT l.user_id) AS likes,
       COUNT(DISTINCT c.id) AS comments
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
LEFT JOIN likes l ON u.id = l.user_id
LEFT JOIN comments c ON u.id = c.user_id
GROUP BY u.id;

--- Q3
SELECT
    COUNT(PT.tag_id) / COUNT(DISTINCT P.id) AS avg_tags_per_post
FROM
    photos AS P
LEFT JOIN
    photo_tags AS PT ON P.id = PT.photo_id;

--- Q4
SELECT
    U.username,
    COUNT(DISTINCT L.photo_id) AS total_likes_on_posts,
    COUNT(DISTINCT C.id) AS total_comments_on_posts,
    (COUNT(DISTINCT L.photo_id) + COUNT(DISTINCT C.id)) AS total_engagement,
    (
        SELECT
            COUNT(follower_id)
        FROM
            follows
        WHERE
            followee_id = U.id
    ) AS follower_count,
    (
        (COUNT(DISTINCT L.photo_id) + COUNT(DISTINCT C.id)) * 1.0 / (
            SELECT
                COUNT(follower_id)
            FROM
                follows
            WHERE
                followee_id = U.id
        )
    ) AS engagement_rate
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
ORDER BY
    engagement_rate DESC;

--- Q5
SELECT
    U.username,
    COUNT(F.followee_id) AS follower_count
FROM
    users AS U
JOIN
    follows AS F ON U.id = F.followee_id
GROUP BY
    U.id
ORDER BY
    follower_count DESC;
---
SELECT
    U.username,
    COUNT(F.follower_id) AS following_count
FROM
    users AS U
JOIN
    follows AS F ON U.id = F.follower_id
GROUP BY
    U.id
ORDER BY
    following_count DESC;

--- Q6
SELECT
    U.username,
    COUNT(DISTINCT P.id) AS total_posts,
    COUNT(DISTINCT L.photo_id) AS total_likes_on_posts,
    COUNT(DISTINCT C.id) AS total_comments_on_posts,
    (COUNT(DISTINCT L.photo_id) + COUNT(DISTINCT C.id)) AS total_engagement,
    (
        (COUNT(DISTINCT L.photo_id) + COUNT(DISTINCT C.id)) * 1.0 / COUNT(DISTINCT P.id)
    ) AS avg_engagement_per_post
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
ORDER BY
    avg_engagement_per_post DESC;

--- Q7
SELECT
    U.username
FROM
    users AS U
LEFT JOIN
    likes AS L ON U.id = L.user_id
WHERE
    L.user_id IS NULL;
    
--- Q10
SELECT
    U.username,
    COUNT(DISTINCT L.photo_id) AS total_likes_given,
    COUNT(DISTINCT C.id) AS total_comments_made,
    COUNT(DISTINCT PT.tag_id) AS total_photo_tags_used
FROM users AS U
LEFT JOIN likes AS L
    ON U.id = L.user_id
LEFT JOIN comments AS C
    ON U.id = C.user_id
LEFT JOIN photos AS P
    ON U.id = P.user_id
LEFT JOIN photo_tags AS PT
    ON P.id = PT.photo_id
GROUP BY U.id
ORDER BY
    total_likes_given DESC,
    total_comments_made DESC,
    total_photo_tags_used DESC;

--- Q11
WITH UserEngagement AS (
    SELECT
        U.id AS user_id,
        U.username,
        COUNT(DISTINCT L.photo_id) AS total_likes,
        COUNT(DISTINCT C.id) AS total_comments,
        (COUNT(DISTINCT L.photo_id) + COUNT(DISTINCT C.id)) AS total_engagement
    FROM
        users AS U
    LEFT JOIN
        photos AS P ON U.id = P.user_id
    LEFT JOIN
        likes AS L ON P.id = L.photo_id
    LEFT JOIN
        comments AS C ON P.id = C.photo_id
    WHERE
        P.created_dat >= DATE_SUB(NOW(), INTERVAL 30 DAY) OR L.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) OR C.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
    GROUP BY
        U.id, U.username
)
SELECT
    username,
    total_engagement,
    RANK() OVER (ORDER BY total_engagement DESC) as ranking
FROM
    UserEngagement
ORDER BY
    ranking ASC;

--- Q12
WITH PhotoLikes AS (
    SELECT
        photo_id,
        COUNT(user_id) AS like_count
    FROM
        likes
    GROUP BY
        photo_id
)
SELECT
    T.tag_name,
    AVG(PL.like_count) AS average_likes
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

--- Q13
SELECT DISTINCT
    U.username AS follower_username
FROM
    follows AS F1
JOIN
    follows AS F2
    ON F1.follower_id = F2.followee_id AND F1.followee_id = F2.follower_id
JOIN
    users AS U
    ON F1.follower_id = U.id
WHERE
    F1.created_at > F2.created_at;
