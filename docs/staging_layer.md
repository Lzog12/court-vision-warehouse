# Staging Layer — court-vision-whse

The **staging layer** transforms raw JSON payloads into **typed, relational tables**.  
It normalizes semi-structured data into clean structures that match the grain, while preserving natural keys for uniqueness and joins.

---

## Design Principles

- **One staging table per raw endpoint** (or per logical entity).
- **Typed columns**: JSON fields cast into proper SQL Server data types (`INT`, `DATE`, `DECIMAL`, etc.).
- **Normalized grain**: Explode arrays / nested JSON into one row per natural entity (e.g., one shot, one player-game).
- **Natural key uniqueness enforced** with `UNIQUE` constraints.
- **Convenience attributes** (e.g., `shot_id_nk`) can be added but do not replace natural keys.
- **Calculated Measures (CM)**: Pre-computed rollups (e.g., quarterly FGM) flagged as derived.
- **No SCD logic** here.

---

## Standard Practices

- **Source**: Each staging table pulls from one or more raw tables via `OPENJSON` in dbt models.
- **Constraints**:
  - `UNIQUE` constraints on natural keys to enforce grain.
  - `CHECK` constraints for categorical domains (`W`/`L`, season segment).
- **Indexes**: NOT added yet for common filters (e.g., `game_id_nk`, `player_id_nk`), could look into doing this in the future.

---

## Tables

### **stg_nbaapi__player_shots**
- **Grain:** One row per shot (`game_id_nk`, `game_event_id_nk`).
- **Columns:** Player, team, game, shot metadata (zones, action types), and factual measures (`is_bucket`, `distance`, coordinates, period/time remaining).
- **Notes:** `shot_id_nk` is a convenience identifier derived from game/event; not part of uniqueness.

---

### **stg_nbaapi__play_by_play**  
- **Grain:** One row per game-event sequence (captures shots only).
- **Columns:** `game_id_nk`, `game_event_id_nk`, points, indicators (`is_fg_to_lead_or_tie`, `is_tie`, `is_clutch`).  
- **Notes:** Unique constraint ensures no duplicate events.  

---

### **stg_nbaapi__player_game**
- **Grain:** One row per player per game per season.
- **Columns:** `game_id_nk`, `player_id_nk`, `season_id_nk`, shooting stats, points, plus/minus, quarterly/half stats, season identifiers.  
- **Notes:** `plus_minus` stored as `TINYINT` but may need widening; CM flags indicate pre-calculated splits. Delivers actual stats for a player in a given game.

---

### **stg_nbaapi__game_team_stats**  
- **Grain:** One row per team per game per season.
- **Columns:** `team_id_nk`, `game_id_nk`, starter list, results (`htm_result`, `vtm_result`).  
- **Notes:** `starters` stored as a single string; may be split later if needed.  

---

### **stg_nbaapi__game_player_stats**  
- **Grain:** One row per player per game (starting lineup metadata).  
- **Columns:** `game_id_nk`, `player_id_nk`, `team_id_nk`, `start_position`.  
- **Notes:** `team_id_nk` may be redundant (derivable from player + game), but retained for constraint usage. Delivers only the start position of the player.

---

## Data Quality & Governance

- **Tests enforced in dbt schema.yml**:
  - `unique` on natural keys.
  - `not_null` on mandatory IDs (game_id_nk, player_id_nk, season_id_nk).
  - `accepted_values` for categorical columns (season_segment, W/L results).
  - `relationships` to validate foreign keys (e.g., player_id_nk exists in dim_players).

- **Derived / Calculated Measures (CM)** are flagged in comments to distinguish them from raw API fields.

---

## Notes
- Staging is **ephemeral**: data can always be truncated and rebuilt from raw.
- All SCD2 logic, surrogate key creation, and conformed dimension design happen in the **warehouse schema**, not here.
- The staging layer is where JSON parsing stops; everything downstream assumes fully typed rows.
