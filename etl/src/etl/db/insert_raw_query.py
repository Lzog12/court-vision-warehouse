

# Create batch id
create_batch_id = """
                DECLARE @id UNIQUEIDENTIFIER = NEWID();
                SELECT @id AS 'new id';
                """

# Straight queries or stored procedures
insert_shot_chart_detail = """
                        EXEC raw.InsertShots 
                            @player_id = ?,
                            @game_id = ?,
                            @game_date  = ?,
                            @season = ?,
                            @season_segment = ?,
                            @json_payload = ?,
                            @batch_id = ?
                        """



insert_player_game_log = """
                        EXEC raw.InsertPlayerGame
                            @player_id = ?,
                            @game_id = ?,
                            @game_date  = ?,
                            @season = ?,
                            @season_segment = ?,
                            @json_payload = ?,
                            @batch_id = ?
                        """

insert_play_by_play = """
                        EXEC raw.InsertPlayByPlay
                            @game_id = ?,
                            @game_date  = ?,
                            @season = ?,
                            @json_payload = ?,
                            @batch_id = ?
                        """

insert_league_game_log = """
                        EXEC raw.InsertLeagueGame
                            @game_date  = ?,
                            @season = ?,
                            @season_segment = ?,
                            @json_payload = ?,
                            @batch_id = ?
                        """