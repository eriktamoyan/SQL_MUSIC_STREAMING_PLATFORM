-- Music Streaming Platform Analytical Queries
-- Author: Erik Tamoyan
-- Description: Complex SQL Analytics for Business Intelligence Metrics
-- Features: Window Functions, CTEs, Aggregations, Multi-table JOINs
-- DBMS: MySQL 
-- =================================================================

USE music_streaming_platform;

-- =================================================================
-- 1. TOP PERFORMING ARTISTS BY TOTAL STREAMS
-- Calculates total play counts per artist and ranks them 
-- Business Use Case: Identifying top-tier artists for marketing promotions.
-- =================================================================
WITH ArtistStreamCounts AS (
    SELECT 
        ar.artist_id,
        ar.artist_name,
        ar.country,
        COUNT(lh.history_id) AS total_streams,
        DENSE_RANK() OVER (ORDER BY COUNT(lh.history_id) DESC) AS stream_rank
    FROM LISTENING_HISTORY lh
    JOIN MUSICS m ON lh.music_id = m.music_id
    JOIN ALBUMS al ON m.album_id = al.album_id
    JOIN ARTISTS ar ON al.artist_id = ar.artist_id
    GROUP BY ar.artist_id, ar.artist_name, ar.country
)
SELECT 
    stream_rank,
    artist_name,
    country,
    total_streams
FROM ArtistStreamCounts
WHERE stream_rank <= 10;

-- =================================================================
-- 2. USER ENGAGEMENT & LISTENING TIME METRICS
-- Aggregates total listening duration (in minutes) and track counts per user.
-- Business Use Case: Segmenting active vs. churn-risk users.
-- =================================================================
SELECT 
    u.user_id,
    u.username,
    u.email,
    COUNT(lh.history_id) AS total_tracks_listened,
    ROUND(SUM(m.duration_music_seconds) / 60.0, 2) AS total_listening_minutes,
    ROUND(AVG(m.duration_music_seconds), 1) AS avg_track_duration_seconds
FROM USERS u
LEFT JOIN LISTENING_HISTORY lh ON u.user_id = lh.user_id
LEFT JOIN MUSICS m ON lh.music_id = m.music_id
GROUP BY u.user_id, u.username, u.email
ORDER BY total_listening_minutes DESC;

-- =================================================================
-- 3. SUBSCRIPTION REVENUE & CHURN RATE ANALYSIS
-- Calculates Monthly Recurring Revenue and status distribution percentages.
-- Business Use Case: Financial reporting and subscription conversion analysis.
-- =================================================================
SELECT 
    subscription_status,
    COUNT(user_id) AS total_subscribers,
    SUM(price) AS total_revenue_usd,
    ROUND(COUNT(user_id) * 100.0 / (SELECT COUNT(*) FROM SUBSCRIPTIONS), 2) AS percentage_share
FROM SUBSCRIPTIONS
GROUP BY subscription_status
ORDER BY total_revenue_usd DESC;

-- =================================================================
-- 4. MOST POPULAR TRACK IN EACH ALBUM 
-- Ranks tracks within their respective albums based on stream frequency.
-- Business Use Case: Catalog performance optimization and recommendation engines.
-- =================================================================
WITH TrackRankings AS (
    SELECT 
        al.album_name,
        ar.artist_name,
        m.music_name,
        COUNT(lh.history_id) AS stream_count,
        ROW_NUMBER() OVER (PARTITION BY al.album_id ORDER BY COUNT(lh.history_id) DESC) AS track_rank
    FROM MUSICS m
    JOIN ALBUMS al ON m.album_id = al.album_id
    JOIN ARTISTS ar ON al.artist_id = ar.artist_id
    LEFT JOIN LISTENING_HISTORY lh ON m.music_id = lh.music_id
    GROUP BY al.album_id, al.album_name, ar.artist_name, m.music_id, m.music_name
)
SELECT 
    album_name,
    artist_name,
    music_name AS lead_track,
    stream_count
FROM TrackRankings
WHERE track_rank = 1 AND stream_count > 0;

-- =================================================================
-- 5. UNCURATED TRACKS AUDIT 
-- Identifies catalog tracks that have never been added to any user playlist.
-- Business Use Case: Finding underperforming content for playlist curation algorithms.
-- =================================================================
SELECT 
    m.music_id,
    m.music_name,
    al.album_name,
    ar.artist_name
FROM MUSICS m
JOIN ALBUMS al ON m.album_id = al.album_id
JOIN ARTISTS ar ON al.artist_id = ar.artist_id
LEFT JOIN PLAYLIST_MUSICS pm ON m.music_id = pm.music_id
WHERE pm.playlist_id IS NULL
ORDER BY ar.artist_name, m.music_name;