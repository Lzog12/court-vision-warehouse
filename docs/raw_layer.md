# Raw Layer — court-vision-whse

The **raw layer** stores ingested payloads exactly as received from the NBA API, with minimal transformation.
It provides immutability, auditability, and a reliable foundation for downstream staging models.

---

## Design Principles

- **One table per API endpoint** (aligned with nba_api).
- **Grain = one JSON payload per entity per day/game/player/season** (depends on endpoint).
- **Append + idempotent policy**: data is updated in-place via `MERGE` on natural keys.
- **Metadata included** for traceability and deduplication.
- **Clustered on `game_date`** where applicable, to support daily backfill/queries.
- **No parsing in Python** — payload remains in `json_payload` until staging.

---

## Standard Columns

All raw tables share these metadata columns:

| Column         | Type             | Description                                   |
|----------------|------------------|-----------------------------------------------|
| `json_payload` | NVARCHAR(MAX)    | Raw JSON response                             |
| `payload_hash` | VARBINARY(32)    | SHA-256 digest of payload for deduplication   |
| `ingested_at`  | DATETIME2(0)     | UTC timestamp of ingestion                    |
| `batch_id`     | UNIQUEIDENTIFIER | Identifier for the ETL batch                  |

---

## Unique Constraints

Each table enforces **natural key uniqueness** based on its grain:  

- `(player_id, game_id)` → e.g. shots, player logs, player stats  
- `(game_id)` → game-level payloads (win probability)  
- `(player_id, season)` → player season stats, league dash  
- `(season, ingested_at)` → player index, bulk player load

These constraints are implemented as **nonclustered unique indexes**.  

---

## Clustered Indexes  

Clustered indexes are applied only on **`game_date`** (or `(game_date, …)` if required by query patterns):  

- `raw.shot_chart_detail (game_date)`
- `raw.play_by_play (game_date)`
- `raw.player_game_log (game_date)`
- `raw.player_stats (game_date)`

This design optimizes for daily ingestion, reprocessing, and backfills.  

---

## Tables  

- **shot_chart_detail** → one row per `(player_id, game_id)` payload of shots  
- **play_by_play** → one row per `(game_id)` play by play for each game payload
- **player_game_log** → one row per `(player_id, game_id)` log payload  
- **player_stats** → one row per `(game_id)` game stats payload  

---

## Upsert Policy  

- **Idempotent upsert** with `MERGE`:  
  - Match on natural keys (grain)  
  - If new `payload_hash` differs → `UPDATE`  
  - If not matched → `INSERT`  

---

## Notes  

- Reference schema was removed as redundant; player/team lookup will be sourced from **game/boxscore endpoints** and handled downstream in staging/dimensions.  
- Raw layer is intentionally **wide + opaque** (JSON only) to decouple ingestion from parsing.  
- Removed raw.league_dash_player_stats which was used to fill fct_player_seasons. Will use incrementals from fct_player_games instead