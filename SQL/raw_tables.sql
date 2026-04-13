
-- RAW TABLES FOR nba_api ENDPOINTS

-- .ShotChartDetail
-- raw schema
-- Player grain. One JSON response (row) per player shots in a given day (game)
CREATE TABLE raw.shot_chart_detail (
  player_id INT NOT NULL,
  game_id INT NOT NULL,
  game_date DATE NOT NULL,
  season VARCHAR(10) NOT NULL,
  json_payload NVARCHAR(MAX) NOT NULL,
  payload_hash VARBINARY(32) NOT NULL,           -- SHA-256 bytes
  ingested_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
  batch_id UNIQUEIDENTIFIER NOT NULL,
  CONSTRAINT uq_shots_daily UNIQUE NONCLUSTERED (player_id, game_id)
);

CREATE CLUSTERED INDEX idx_shots_date
    ON raw.shot_chart_detail (game_date);

-- .PlayByPlayV3
-- raw schema
-- Game grain. One JSON response (row) per game
CREATE TABLE raw.play_by_play (
    game_id INT NOT NULL,
    game_date DATE NOT NULL,
    season VARCHAR(10) NOT NULL,
    json_payload NVARCHAR(MAX) NOT NULL,
    payload_hash VARBINARY(32) NOT NULL,           -- SHA-256 bytes
    ingested_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    batch_id UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT uq_play_by_play UNIQUE NONCLUSTERED (game_id)
);

CREATE CLUSTERED INDEX idx_play_by_play
    ON raw.play_by_play (game_date);

-- .PlayerGameLog
-- raw schema
-- Player-season grain. One JSON response (row) per player-season combination which contains all games for that given season
-- NO! Player-game grain. One JSON response (row) per player-game i.e. each player will have many rows of games for each season
CREATE TABLE raw.player_game_log (
    player_id INT NOT NULL,
    game_id INT NOT NULL,
    game_date DATE NOT NULL,
    season VARCHAR(10) NOT NULL,
    json_payload NVARCHAR(MAX) NOT NULL,
    payload_hash VARBINARY(32) NOT NULL,           -- SHA-256 bytes
    ingested_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    batch_id UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT uq_player_game UNIQUE NONCLUSTERED (player_id, game_id)
);

CREATE CLUSTERED INDEX idx_player_game
    ON raw.player_game_log (game_date);

-- .BoxScorePlayerTrackV2.PlayerStats (Includes starting position of player and team starters for both teams)
-- raw schema
-- Game grain. One JSON response per game combination (boxscoreplayertrackv2.player_stats)
CREATE TABLE raw.box_score_player_track (
    game_id INT NOT NULL,
    game_date DATE NOT NULL,
    season VARCHAR(10) NOT NULL,
    json_payload NVARCHAR(MAX) NOT NULL,
    payload_hash VARBINARY(32) NOT NULL,           -- SHA-256 bytes
    ingested_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    batch_id UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT uq_player_stats UNIQUE NONCLUSTERED (game_id)
);

CREATE CLUSTERED INDEX idx_box_score_player_track
    ON raw.box_score_player_track (game_date);

    

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'raw';
