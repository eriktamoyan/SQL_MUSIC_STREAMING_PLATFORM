-- Music Streaming Platform Database Schema
-- Author: Erik Tamoyan
-- Description: 3NF Relational Database Schema for Music Streaming Analytics
-- DBMS: MySQL 
-- =================================================================

CREATE DATABASE IF NOT EXISTS music_streaming_platform;
USE music_streaming_platform;

-- =================================================================
-- 1. USERS TABLE
-- Stores user account profiles and registration dates.
-- =================================================================
CREATE TABLE USERS (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =================================================================
-- 2. ARTISTS TABLE
-- Catalog of music artists and performers.
-- =================================================================
CREATE TABLE ARTISTS (
    artist_id INT AUTO_INCREMENT PRIMARY KEY,
    artist_name VARCHAR(255) NOT NULL,
    country VARCHAR(50) DEFAULT 'Unknown'
);

-- =================================================================
-- 3. ALBUMS TABLE
-- Album records linked to artists via foreign keys.
-- =================================================================
CREATE TABLE ALBUMS (
    album_id INT AUTO_INCREMENT PRIMARY KEY,
    album_name VARCHAR(255) NOT NULL,
    release_year INT,
    artist_id INT NOT NULL,
    
    FOREIGN KEY (artist_id) REFERENCES ARTISTS(artist_id) ON DELETE CASCADE
);

-- =================================================================
-- 4. MUSICS TABLE (TRACKS)
-- Individual audio tracks belonging to specific albums.
-- =================================================================
CREATE TABLE MUSICS (
    music_id INT AUTO_INCREMENT PRIMARY KEY,
    music_name VARCHAR(255) NOT NULL,
    duration_music_seconds INT,
    album_id INT NOT NULL,
    
    FOREIGN KEY (album_id) REFERENCES ALBUMS(album_id) ON DELETE CASCADE
);

-- =================================================================
-- 5. LISTENING_HISTORY TABLE
-- Time-series event log capturing stream occurrences per user.
-- =================================================================
CREATE TABLE LISTENING_HISTORY (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    music_id INT NOT NULL,
    listened_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES USERS(user_id) ON DELETE CASCADE,
    FOREIGN KEY (music_id) REFERENCES MUSICS(music_id) ON DELETE CASCADE
);

-- =================================================================
-- 6. PLAYLISTS TABLE
-- User-created playlist containers.
-- =================================================================
CREATE TABLE PLAYLISTS (
    playlist_id INT AUTO_INCREMENT PRIMARY KEY,
    playlist_name VARCHAR(150) NOT NULL,
    user_id INT NOT NULL,
    
    FOREIGN KEY (user_id) REFERENCES USERS(user_id) ON DELETE CASCADE
);

-- =================================================================
-- 7. PLAYLIST_MUSICS TABLE
-- Junction table handling Many-to-Many relationship between Playlists and Tracks.
-- =================================================================
CREATE TABLE PLAYLIST_MUSICS (
    playlist_id INT NOT NULL,
    music_id INT NOT NULL,
    added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (music_id, playlist_id),
    FOREIGN KEY (playlist_id) REFERENCES PLAYLISTS(playlist_id) ON DELETE CASCADE,
    FOREIGN KEY (music_id) REFERENCES MUSICS(music_id) ON DELETE CASCADE
);

-- =================================================================
-- 8. SUBSCRIPTIONS TABLE
-- Financial billing and active account status for users.
-- =================================================================
CREATE TABLE SUBSCRIPTIONS (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    subscription_status ENUM('Active', 'Canceled', 'Expired', 'Not Activated') DEFAULT 'Not Activated',
    start_date DATETIME NOT NULL, 
    end_date DATETIME NOT NULL,
    
    FOREIGN KEY (user_id) REFERENCES USERS(user_id) ON DELETE CASCADE
);