# Data Warehouse Blueprint — court-vision-whse

This blueprint defines the **logical design** for the NBA shot analytics constellation schema.  
It includes fact tables, conformed and non-conformed dimensions, their **grain**, key structures,  
and relationships. Data types are aligned with **SQL Server** conventions.

---

## 1. Fact Tables & Grain

### **fct_shots**
**Grain:** One row per shot taken in the NBA season.
**Columns / Measures:**
- shot_key INT NOT NULL PRIMARY KEY
- game_key INT NOT NULL
- team_key INT NOT NULL
- player_key INT NOT NULL
- is_bucket BIT
- shot_distance TINYINT
- loc_x SMALLINT
- loc_y SMALLINT
- period TINYINT
- min_left TINYINT
- sec_left TINYINT
- shot_id_nk VARCHAR(25)

---

### **fct_pbp**
**Grain:** One row per win for each shot (1:1 with `fct_shots`), tracks current score after each shot and state of the game.
**Columns / Measures:**
- game_key INT NOT NULL
- shot_key INT NOT NULL UNIQUE
- home_pts INT
- away_pts INT
- is_fg_to_lead_or_tie BIT
- is_lead BIT
- is_tie BIT
- is_clutch BIT
- shot_id_nk VARCHAR(25)
- game_id_nk INT
- game_event_id_nk INT

---

### **fct_player_seasons**
**Grain:** One row per player per season.  
**Columns / Measures:**
- season_type_key INT NOT NULL
- player_key INT NOT NULL
- player_id_nk INT
- season_high_pts INT
- season_high_pts_game_id INT
- season_low_pts INT
- season_low_pts_game_id INT
- avg_pts DECIMAL(4,1)
- avg_min DECIMAL(4,1)
- avg_fga DECIMAL(4,1)
- avg_fgm DECIMAL(4,1)
- avg_fg_pct DECIMAL(4,1)
- avg_fg3a DECIMAL(4,1)
- avg_fg3m DECIMAL(4,1)
- plus_minus_ovr INT

---

### **fct_player_games**
**Grain:** One row per player per game.  
**Columns / Measures:**
- player_key INT NOT NULL
- game_key INT NOT NULL
- season_type_key INT
- game_id_nk INT
- player_id_nk INT
- minutes INT
- fgm INT
- fga INT
- fg3m INT
- fg3a INT
- pts INT
- plus_minus INT
- q1_fgm INT
- q2_fgm INT
- q3_fgm INT
- q4_fgm INT
- h1_fgm INT
- h2_fgm INT
- ot_fgm INT
- start_position CHAR(1) NULL -> degenerate attribute
###### CREATE TABLE... `CONSTRAINT uq_fct_player_game UNIQUE (game_key, player_key)`
---

## 2. Conformed Dimensions

### **dim_shots**
- shot_key INT IDENTITY PRIMARY KEY
- shot_id_nk VARCHAR(25)
- game_id_nk INT  -- Natural Key
- game_event_id_nk INT  -- Natural Key
- action_type VARCHAR(45)
- shot_type VARCHAR(45)
- shot_zone_basic VARCHAR(45)
- shot_zone_area VARCHAR(45)
- shot_zone_range VARCHAR(45)
- event_type VARCHAR(45)

---

### **dim_games**
- game_key INT IDENTITY PRIMARY KEY
- game_id_nk INT UNIQUE  -- Natural Key
- matchup VARCHAR(15)
- htm CHAR(3)
- vtm CHAR(3)
- htm_starters VARCHAR(45)
- vtm_starters VARCHAR(45)
- htm_result CHAR(3) CHAR(1) CHECK (result IN ('W', 'L'))
- vtm_result CHAR(3) CHAR(1) CHECK (result IN ('W', 'L'))
- season VARCHAR(10)
- season_segment VARCHAR(20)
- game_date DATE

---

### **dim_players**
- player_key INT IDENTITY PRIMARY KEY
- player_id_nk INT  -- Natural Key
- team_id_nk INT
- player_name VARCHAR(45)
- position VARCHAR(10)
SCD-2 FIELD
- - start_date TIMESTAMP()
- - end_date TIMESTAMP() NULL
- - is_current BIT


---

## 3. Non-Conformed Dimensions

### **dim_teams**
- team_key INT IDENTITY PRIMARY KEY
- team_id_nk INT UNIQUE  -- Natural Key
- team_name VARCHAR(30)
- team_abbrev CHAR(3)

---

### **dim_seasons**
- season_key INT IDENTITY PRIMARY KEY
- season_segment_key INT IDENTITY PRIMARY KEY
- season_id_nk INT
- season CHAR(7)
- season_segment VARCHAR(20) CHECK (season_segment IN ('Regular Season', 'Playoffs'))
###### CREATE TABLE `CONSTRAINT uq_dim_season UNIQUE (season)`

---

## 4. Slowly Changing Dimensions (SCD Type 2)

**Applied to:** `dim_players` when:
- New player enters the league
- Player changes teams
- Player leaves the league

**SCD-2 Columns:**
- start_date DATETIME
- end_date DATETIME NULL
- is_current BIT

---

## 5. Table Relationships

### **fct_shots**
- `shot_key` FK → `dim_shots.shot_key`
- `game_key` FK → `dim_games.game_key`
- `team_key` FK → `dim_teams.team_key`
- `player_key` FK → `dim_players.player_key`

### **fct_pbp**
- `game_key` FK → `dim_games.game_key`
- `shot_key` FK → `dim_shots.shot_key`

### **fct_player_seasons**
- `player_key` FK → `dim_players.player_key`
- `season_type_key` FK → `dim_seasons.season_type_key`

### **fct_player_games**
- `player_key` FK → `dim_players.player_key`
- `game_key` FK → `dim_games.game_key`
- `season_type_key` FK → `dim_seasons.season_type_key`

---

## 6. Dimension-to-Dimension Relationship
- `dim_players.team_id_nk` FK → `dim_teams.team_id_nk`

---

## 7. Data Quality Rules (for dbt schema.yml)
`Data Quality Rules” section to the end so this blueprint ties directly into the schema.yml`
These rules will be implemented later in `schema.yml` for automated testing in dbt.

### **General**
- All surrogate keys (`*_key`) must be `NOT NULL` and `UNIQUE`.
- All natural keys must be `NOT NULL` and `UNIQUE` within their table.
- Foreign key fields must have matching values in their referenced dimension.

### **Fact Tables**
- **fct_shots**
  - `shot_key`, `game_key`, `team_key`, `player_key` → must have valid relationships.
  - `is_bucket` → accepted values: {0, 1}.
  - `shot_distance` → must be between 0 and 40.
  - `loc_x` and `loc_y` → must be within valid court bounds (-250 to 250 approx).

- **fct_pbp**
  - Four calculated measure columns:
  - `is_fg_to_lead_or_tie`, `is_lead`, `is_tie`, `is_clutch`

- **fct_player_seasons**
  - `avg_*` percentage columns → between 0.0 and 100.0.
  - `plus_minus_ovr` → no NULLs allowed.

- **fct_player_games**
  - 


### **Dimensions**
- **dim_shots**
  - `game_id` + `game_event_id` → unique combination.
  - `shot_zone_basic`, `shot_zone_area`, `shot_zone_range` → must be from predefined NBA zone lists.

- **dim_games**
  - `game_id` → unique.
  - `htm`, `vtm` → valid NBA team abbreviations.

- **dim_players**
  - `player_id` → unique.
  - `team_id` → must match a `team_id` in `dim_teams`.

- **dim_time**
  - `season_segment` → accepted values: {'Regular Season', 'Playoffs'}.
  - `period` → between 1 and 7.
  - `min_left` → between 0 and 12.
  - `sec_left` → between 0 and 59.

- **dim_teams**
  - `team_id` → unique.
  - `team_abbrev` → valid NBA team abbreviations.

- **dim_seasons**
  - `season_id_nk` → unique.