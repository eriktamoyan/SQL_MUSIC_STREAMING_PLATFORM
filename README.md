# SQL_MUSIC_STREAMING_PLATFORM
## 🎵 Music Streaming Platform Data Architecture & Analytics

A 3NF relational database designed in **MySQL** to simulate a music streaming service platform. This project handles catalog management, multi-tier user subscriptions, and streaming event tracking using real-world data imported from Kaggle.

---

## 📌 Project Overview

The objective of this project is to model, implement, and analyze a scalable data architecture for a streaming platform.

* **Schema Design:** 3NF relational schema with 8 tables enforcing Referential Integrity (`FOREIGN KEY` with `CASCADE` actions).
* **Data Pipeline:** Ingested and transformed 2,000+ real-world tracks from the Kaggle Spotify dataset via MySQL staging tables.
* **SQL Analytics:** Advanced SQL queries utilizing CTEs (`WITH` clauses), Window Functions (`DENSE_RANK`), aggregations, and multi-table `JOIN` operations for business intelligence.

---

## 🛠️ Database Schema

The database follows Third Normal Form (3NF) to eliminate data redundancy and ensure data integrity.

```
+----------------+      +----------------+      +----------------+
|    ARTISTS     |      |     ALBUMS     |      |     MUSICS     |
+----------------+      +----------------+      +----------------+
| artist_id (PK) |<-----| album_id (PK)  |<-----| music_id (PK)  |
| artist_name    |      | album_name     |      | music_name     |
| country        |      | release_year   |      | duration_sec   |
+----------------+      | artist_id (FK) |      | album_id (FK)  |
                        +----------------+      +----------------+
                                                        |
                                                        v
+----------------+      +----------------+      +-------------------+
|     USERS      |      |   PLAYLISTS    |      | LISTENING_HISTORY |
+----------------+      +----------------+      +-------------------+
| user_id (PK)   |<-----| playlist_id(PK)|      | history_id (PK)   |
| username       |      | playlist_name  |      | user_id (FK)      |
| email          |      | user_id (FK)   |      | music_id (FK)     |
+----------------+      +----------------+      | listened_at       |
        |                       |               +-------------------+
        v                       v
+----------------+      +-------------------+
| SUBSCRIPTIONS  |      |  PLAYLIST_MUSICS  |
+----------------+      +-------------------+
| sub_id (PK)    |      | music_id (PK, FK) |
| user_id (FK)   |      | playlist_id(PK,FK)|
| price          |      +-------------------+
| status         |
+----------------+
```

---

## 📊 Key Analytics & Business Queries

The repository includes queries covering core platform metrics:

1. **Artist Streaming Rankings:** Ranks top-streamed artists globally using.
2. **User Engagement Tracking:** Aggregates overall listening time per user to monitor engagement levels.
3. **Financial & Churn Reporting:** Calculates Monthly Recurring Revenue and subscription status breakdown percentages.
4. **Catalog Curation Audit:** Identifies tracks that have never been added to user playlists using .

---

## 🚀 Getting Started

### Prerequisites
* **MySQL Server**
* [Dataset source on Kaggle](https://www.kaggle.com/datasets/paradisejoy/top-hits-spotify-from-20002019/data) (`songs_normalize.csv`)

### Setup Instructions
1. Clone this repository:
   ```bash
   git clone https://github.com/eriktamoyan/SQL_MUSIC_STREAMING_PLATFORM.git
   ```
2. Run `schema.sql` to initialize the database architecture and tables:
   ```sql
   SOURCE schema.sql;
   ```
3. Import the dataset into `STAGE_SPOTIFY` and populate normalized tables using `data_import.sql`.
4. Run analytical queries from `queries.sql` to extract insights.

---

## 📁 Repository Structure

```
├── schema.sql           # Database schema and table definitions (DDL)
├── data_import.sql      # Data loading and transformation pipeline from staging
├── queries.sql          # Analytical SQL queries for BI insights
└── README.md            # Project documentation
```
