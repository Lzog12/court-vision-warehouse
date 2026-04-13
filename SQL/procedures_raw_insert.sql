
-- PROCEDURES TO INSERT PAYLOADS INTO RAW TABLES

-- raw.shot_chart_detail
CREATE PROCEDURE InsertShots
    @player_id INT,
    @game_id INT,
    @game_date DATE,
    @season VARCHAR(10),
    @json_payload NVARCHAR(MAX),
    @batch_id UNIQUEIDENTIFIER
AS
BEGIN
    INSERT INTO raw.shot_chart_detail(player_id, game_id, game_date, season, json_payload, payload_hash, batch_id)
        VALUES(@player_id, @game_id, @game_date, @season, @json_payload, HASHBYTES('SHA2_256', CONVERT(NVARCHAR(MAX), @json_payload)), @batch_id);
END;
GO

-- raw.player_game_log
CREATE PROCEDURE InsertPlayerGame
    @player_id INT,
    @game_id INT,
    @game_date DATE,
    @season VARCHAR(10),
    @json_payload NVARCHAR(MAX),
    @batch_id UNIQUEIDENTIFIER
AS
BEGIN
    INSERT INTO raw.player_game_log(player_id, game_id, game_date, season, json_payload, payload_hash, batch_id)
        VALUES(@player_id, @game_id, @game_date, @season, @json_payload, HASHBYTES('SHA2_256', CONVERT(NVARCHAR(MAX), @json_payload)), @batch_id)
END;
GO

-- raw.play_by_play
CREATE PROCEDURE InsertPlayByPlay
    @game_id INT,
    @game_date DATE,
    @season VARCHAR(10),
    @json_payload NVARCHAR(MAX),
    @batch_id UNIQUEIDENTIFIER
AS
BEGIN
    INSERT INTO raw.player_game_log(player_id, game_id, game_date, season, json_payload, payload_hash, batch_id)
        VALUES(@game_id, @game_date, @season, @json_payload, HASHBYTES('SHA2_256', CONVERT(NVARCHAR(MAX), @json_payload)), @batch_id)
END;
GO


-- raw.player_stats
CREATE PROCEDURE InsertBoxScorePlayerTrack
    @game_id INT,
    @game_date DATE,
    @season VARCHAR(10),
    @json_payload NVARCHAR(MAX),
    @batch_id UNIQUEIDENTIFIER
AS
BEGIN
    INSERT INTO raw.player_game_log(player_id, game_id, game_date, season, json_payload, payload_hash, batch_id)
        VALUES(@game_id, @game_date, @season, @json_payload, HASHBYTES('SHA2_256', CONVERT(NVARCHAR(MAX), @json_payload)), @batch_id)
END;
GO




