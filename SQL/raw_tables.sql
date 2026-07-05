
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
-- Player-game grain. One JSON response (row) per player-game i.e. each player will have one row for one game of the given date
CREATE TABLE raw.player_game_log (
    player_id INT NOT NULL,
    game_id INT NOT NULL,
    game_date DATE NOT NULL,
    season VARCHAR(10) NOT NULL,
    season_segment VARCHAR(20) NOT NULL,
    json_payload NVARCHAR(MAX) NOT NULL,
    payload_hash VARBINARY(32) NOT NULL,           -- SHA-256 bytes
    ingested_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    batch_id UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT uq_player_game UNIQUE NONCLUSTERED (player_id, game_id)
);

CREATE CLUSTERED INDEX idx_player_game
    ON raw.player_game_log (game_date);

-- .LeagueGameLog
-- raw schema
-- League-game grain. One JSON response (row) for all games in a given day
CREATE TABLE raw.league_game_log (
    game_date DATE NOT NULL,
    season VARCHAR(10) NOT NULL,
    season_segment VARCHAR(20) NOT NULL,
    json_payload NVARCHAR(MAX) NOT NULL,
    payload_hash VARBINARY(32) NOT NULL,           -- SHA-256 bytes
    ingested_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    batch_id UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT uq_league_game UNIQUE NONCLUSTERED (game_date)
);

CREATE CLUSTERED INDEX idx_league_game
    ON raw.league_game_log (game_date);

