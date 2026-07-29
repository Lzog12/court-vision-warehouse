/* ===========================================================
   STAGING TABLES — NBA API (typed, normalized from raw JSON)
   Notes:
   - Do not change grain without updating UNIQUE constraints.
   - Consider adding CREATE INDEX statements separately (not here).
   - dbt will populate these; lineage stays in raw + audit tables.
   =========================================================== */

-- Fact tables (shot-level facts + dim attributes flattened for convenience)
CREATE TABLE staging.stg_nbaapi__player_shots (
    -- dim_players (natural keys/attrs; SCD handled in warehouse dims)
    player_id_nk INT NOT NULL,              -- NK: player from source
    player_name VARCHAR(45) NOT NULL,
    position VARCHAR(10) NOT NULL,

    -- dim_teams
    team_id_nk INT NOT NULL,                -- NK: team from source
    team_name VARCHAR(30) NOT NULL,
    team_abbrev CHAR(3) NOT NULL,

    -- dim_games
    game_id_nk INT NOT NULL,                -- NK: game from source
    matchup VARCHAR(15) NOT NULL,
    htm CHAR(3) NOT NULL,
    vtm CHAR(3) NOT NULL,
    game_date DATE NOT NULL,
    season_segment VARCHAR(20) NOT NULL CHECK(season_segment IN('Regular Season', 'Playoffs')),
    season CHAR(7),

    -- dim_shots (use (game_id_nk, game_event_id_nk) as authoritative NK)
    shot_id_nk VARCHAR(25),                 -- custom shot id, convenience only
    game_event_id_nk INT,                   -- NK component with game_id_nk

    action_type VARCHAR(45),
    shot_type VARCHAR(45),
    shot_zone_basic VARCHAR(45),
    shot_zone_area VARCHAR(45),
    shot_zone_range VARCHAR(45),
    event_type VARCHAR(45),

    -- fct_shots (measures)
    is_bucket BIT,
    shot_distance TINYINT,                  
    loc_x SMALLINT,
    loc_y SMALLINT,
    period_no TINYINT,                      -- consider CHECK (1–7)
    min_left TINYINT,                       -- consider CHECK (0–12)
    sec_left TINYINT,                       -- consider CHECK (0–59)

    CONSTRAINT uq_stg_player_shots UNIQUE (game_id_nk, game_event_id_nk)  -- grain: 1 row per shot
);
-- Optional indexes (add later): IX(game_id_nk), IX(player_id_nk), IX(team_id_nk)



CREATE TABLE staging.stg_nbaapi__play_by_play(
    -- fct_win_pct (1 row per game event’s win prob snapshot)
    shot_id_nk VARCHAR(25),                 -- optional convenience key; not required for uniqueness
    game_id_nk INT,
    game_event_id_nk INT,                   -- pairs with game_id_nk for NK

    home_pts INT,
    away_pts INT,
    is_fg_to_lead_or_tie BIT,               -- Calculated Measure (CM)
    is_lead BIT,
    is_tie BIT,                             -- (CM)
    is_clutch BIT,                          -- (CM)

    CONSTRAINT uq_stg_pbp UNIQUE (game_id_nk, game_event_id_nk)  -- grain: per event
);
-- Optional indexes: IX(game_id_nk)



CREATE TABLE staging.stg_nbaapi__player_game(
    -- fct_player_game (1 row per player per game)
    player_id_nk INT NOT NULL,
    game_id_nk INT NOT NULL,

    -- dim_seasons (identify season context used by source)
    season_id_nk INT,
    season CHAR(7),
    season_segment VARCHAR(20) CHECK(season_segment IN ('Regular Season', 'Playoffs')),

    -- box score measures
    min TINYINT,
    fgm TINYINT,
    fga TINYINT,
    fg3m TINYINT,
    fg3a TINYINT,
    pts TINYINT,
    q1_fgm INT,                             -- Calculated Measures (CM)
    q2_fgm INT,                             -- (CM)
    q3_fgm INT,                             -- (CM)
    q4_fgm INT,                             -- (CM)
    h1_fgm INT,                             -- (CM)
    h2_fgm INT,                             -- (CM)
    ot_fgm INT,                             -- (CM)
    plus_minus TINYINT,                     -- may exceed TINYINT range; consider SMALLINT


    CONSTRAINT uq_stg_player_game UNIQUE (player_id_nk, game_id_nk, season_id_nk)  -- grain: player-game-season
);
-- Optional indexes: IX(game_id_nk), IX(player_id_nk)



CREATE TABLE staging.stg_nbaapi__league_game(
    -- team-games grain (results by team for each game in a given day). Unique entries of games.
    team_id_nk INT NOT NULL,
    game_id_nk INT NOT NULL,

    game_date DATE NOT NULL,

    season_id_nk INT,
    season CHAR(7),
    season_segment VARCHAR(20) CHECK(season_segment IN ('Regular Season', 'Playoffs')),

    matchup VARCHAR(15),
    
    result CHAR(1) CHECK (result IN ('W', 'L')),
    pts TINYINT,

    CONSTRAINT uq_stg_league_game UNIQUE (team_id_nk, game_id_nk)  -- grain: team-games
);

/* ===========================================================
   NEXT STEPS (not in this script):
   - Add CREATE INDEX statements per table on common join/filter keys.
   - In dbt: implement models that populate these via OPENJSON from raw.
   - Add schema.yml tests: not_null, unique (on NKs), accepted_values, relationships.
   =========================================================== */
