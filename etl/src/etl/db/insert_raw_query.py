

# Create batch id
create_batch_id = """
                DECLARE @id UNIQUEIDENTIFIER = NEWID();
                SELECT @id AS 'new id';
                """

# Straight queries or stored procedures
insert_shot_chart_detail = """
                        EXEC InsertShots 
                            @player_id = ?,
                            @game_id = ?,
                            @game_date  = ?,
                            @season = ?,
                            @json_payload = ?,
                            @batch_id = ?
                        """



insert_player_game_log = """
                        EXEC InsertPlayerGame
                            @player_id = ?,
                            @game_id = ?,
                            @game_date  = ?,
                            @season = ?,
                            @json_payload = ?,
                            @batch_id = ?
                        """

insert_play_by_play = """
                        EXEC InsertPlayByPlay
                            @game_id = ?,
                            @game_date  = ?,
                            @season = ?,
                            @json_payload = ?,
                            @batch_id = ?
                        """

insert_box_score_player_track = """
                            @game_id = ?,
                            @game_date  = ?,
                            @season = ?,
                            @json_payload = ?,
                            @batch_id = ?
                        """