with shots as (
  
  select

      shot_id_nk as shot_id_nk_s, -- CTE join identifier

      is_bucket, -- measure
      case
          when shot_type = '3PT Field Goal' then 1
          when shot_type = '2PT Field Goal' then 0
          else null
      end as is_three_pointer, -- Measure
      shot_distance, -- Measure
      loc_x, -- Measure
      loc_y -- Measure


  from {{ ref('stg_nbaapi__player_shots') }}

),

plays as (
-- Play-by-play defines the fact-table grain: one row per shot attempt,
-- including free throws.

    select


        {{ dbt_utils.generate_surrogate_key(['shot_id_nk']) }} as shot_key,
        {{ dbt_utils.generate_surrogate_key(['game_id_nk']) }} as game_key,
        {{ dbt_utils.generate_surrogate_key(['team_id_nk']) }} as team_key,
        {{ dbt_utils.generate_surrogate_key(['team_id_nk', 'game_id_nk']) }} as team_game_key,
        {{ dbt_utils.generate_surrogate_key(['player_id_nk', 'team_id_nk']) }} as player_key,
        {{ dbt_utils.generate_surrogate_key(['season', 'season_segment']) }} as season_type_key,

        shot_id_nk         as shot_id_nk_p,
        game_id_nk         as game_id_nk,
        game_event_id_nk   as game_event_id_nk,

        is_fg, -- distinguishes between field goal (1) and free throw (0)

        period_no, -- Measure
        min_left, -- Measure
        sec_left, -- Measure
        home_pts, -- Measure
        away_pts, -- Measure

        points_scored, -- Measure
        shot_value_new, -- Measure
        team_location, -- For calculation, not a measure. Discloses the location of the player's team [v, h]

        case
            when is_fg = 0 then 1
            else 0
        end as is_ft,

    -- Score values are populated only on scoring plays so we carry the latest score forward so missed attempts retain the current game score.
    -- MAX window function finds the highest point count so far in the game
    -- Ordered by period number then time because ordering by game_event_id is unreliable
    MAX(home_pts) OVER (
        PARTITION BY game_id_nk
        ORDER BY period_no, min_left DESC, sec_left DESC, game_event_id_nk
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS home_pts_new, -- Keeps a continuous track of home team points
    MAX(away_pts) OVER (
        PARTITION BY game_id_nk
        ORDER BY period_no, min_left DESC, sec_left DESC, game_event_id_nk
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS away_pts_new -- Keeps a continuous track of away team points

    from {{ ref('stg_nbaapi__play_by_play') }}

),
-- Join the above CTE's and add a calculation: Keeping track of the home points and away points after each shot taken
-- Preserves every play-by-play attempt. Field goals match the shot endpoint, while free throws have no corresponding shot-detail record.
joined_shots as (

    select

        s.*,
        p.*,

        -- The current points display only displays the points if the shot was made. So we are creating home_pts_new/away_pts_new to give points to every shot whether made or not
        case
            when p.team_location = 'h' then p.home_pts_new
            when p.team_location = 'v' then p.away_pts_new
        end as player_team_points, -- Determine which points should be allocated for the player. i.e. are they from the home team or visiting team

        case
            when p.team_location = 'h' then p.away_pts_new
            when p.team_location = 'v' then p.home_pts_new
        end as opposite_team_points -- Determine which points should be allocated for the opposition team

    from shots as s

    right join plays as p
        on s.shot_id_nk_s = p.shot_id_nk_p

),
-- Find point margins after every shot attempt, used for creating shot_flags
-- Margin is calculated from the shooting player's perspective. Subtracting points_scored reconstructs the margin before the attempt; missed attempts require no adjustment because points_scored is zero.
points_difference_cte as (

    select 
    
        *,
        (CAST(js.player_team_points as smallint) - CAST(js.opposite_team_points as smallint)) as pt_margin_after,
        (CAST(js.player_team_points as smallint) - CAST(js.opposite_team_points as smallint)) - points_scored as  pt_margin_before
    
    from joined_shots as js



),
-- Describe what the attempt could achieve, regardless of whether it was made. FGA flags can be field-goal attempts AND free throw attempts.
opportunity_flags as (

    select 
    
    -- Calculate attempts/opportunities
        *,

        -- If trailing and margin + shot value would have tied
        case
            when pt_margin_before < 0 and pt_margin_before + shot_value_new = 0 then 1
            else 0
        end as fga_tie,


        -- If tying or (trailing and margin + shot value would have gone above 0)
        case
            when pt_margin_before = 0 or(pt_margin_before < 0 and pt_margin_before + shot_value_new > 0) then 1
            else 0
        end as fga_lead,

        
        -- If clutch time and margin is within 5
        -- Clutch definition: field-goal attempt in the fourth quarter or overtime, with less than five minutes remaining
        case
            when period_no >= 4 and min_left <=4 and pt_margin_before <= 5 and pt_margin_before >= -5 then 1
            else 0
        end as fga_clutch

    from points_difference_cte

),
-- Made flags combine the corresponding opportunity with a successful result.
made_flags as (

    select

        *,

        case
            when fga_tie = 1 and points_scored > 0 then 1
            else 0
        end as fgm_tie,

        case
            when fga_lead = 1 and points_scored > 0 then 1
            else 0
        end as fgm_lead,

        case
            when fga_clutch = 1 and points_scored > 0 then 1
            else 0
        end as fgm_clutch


    from opportunity_flags

),


final as (

    select

        shot_key,
        game_key,
        team_key,
        team_game_key,
        player_key,
        season_type_key,

        shot_id_nk_p as shot_id_nk,
        game_id_nk,
        game_event_id_nk,

        is_fg,
        is_ft,

        is_bucket,
        is_three_pointer,
        
        shot_value_new as shot_value,
        points_scored,

        shot_distance,
        loc_x,
        loc_y,

        period_no,
        min_left,
        sec_left,

        home_pts_new as home_pts,
        away_pts_new as away_pts,

        fga_tie,
        fgm_tie,
        fga_lead,
        fgm_lead,
        fga_clutch,
        fgm_clutch



    from made_flags

)
    
    select

        *

    from final
        

;
