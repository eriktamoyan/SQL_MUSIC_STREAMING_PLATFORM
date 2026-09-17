-- Data Import & ETL Pipeline
-- Description: Cleans raw Kaggle data from STAGE_SPOTIFY and populates the 3NF target tables.
-- =================================================================

USE music_streaming_platform;

-- Safety check: ensure staging table exists and is not empty before starting
SELECT COUNT(*) INTO @staging_count FROM STAGE_SPOTIFY;

-- -----------------------------------------------------------------
-- 1. Populate ARTISTS
-- Extract unique artist names, clean whitespace, and handle missing values.
-- -----------------------------------------------------------------
INSERT IGNORE INTO ARTISTS (artist_name, country)
SELECT DISTINCT 
    TRIM(artist) AS artist_name,
    'Unknown' AS country
FROM STAGE_SPOTIFY
WHERE artist IS NOT NULL 
  AND TRIM(artist) != '';

-- -----------------------------------------------------------------
-- 2. Populate ALBUMS
-- Map tracks to pseudo-albums based on Artist and Release Year.
-- -----------------------------------------------------------------
INSERT IGNORE INTO ALBUMS (album_name, release_year, artist_id)
SELECT DISTINCT 
    CONCAT(TRIM(s.artist), ' - ', s.year, ' Collection') AS album_name,
    s.year AS release_year,
    a.artist_id
FROM STAGE_SPOTIFY s
JOIN ARTISTS a ON a.artist_name = TRIM(s.artist)
WHERE s.song IS NOT NULL 
  AND TRIM(s.song) != '';

-- -----------------------------------------------------------------
-- 3. Populate MUSICS
-- Convert duration from milliseconds to seconds and link to album_id.
-- -----------------------------------------------------------------
INSERT INTO MUSICS (music_name, duration_music_seconds, album_id)
SELECT DISTINCT
    TRIM(s.song) AS music_name,
    ROUND(s.duration_ms / 1000) AS duration_music_seconds,
    al.album_id
FROM STAGE_SPOTIFY s
JOIN ARTISTS a ON a.artist_name = TRIM(s.artist)
JOIN ALBUMS al 
  ON al.album_name = CONCAT(TRIM(s.artist), ' - ', s.year, ' Collection') 
 AND al.artist_id = a.artist_id
WHERE s.song IS NOT NULL 
  AND TRIM(s.song) != '';

-- -----------------------------------------------------------------
-- 4. Cleanup
-- Drop staging table to keep the database clean after import.
-- -----------------------------------------------------------------
DROP TABLE IF EXISTS STAGE_SPOTIFY;