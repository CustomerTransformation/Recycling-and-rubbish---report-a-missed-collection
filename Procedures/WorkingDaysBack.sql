USE [FStepRubbishRecycling_prod]
GO

/****** Object:  StoredProcedure [dbo].[WorkingDaysBack]    Script Date: 13/02/2023 15:06:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Daniel Gregory
-- Create date: 09/12/2022
-- Description:	Provide earliest date (no time) working days back from date with end of working day
-- =============================================
CREATE PROCEDURE [dbo].[WorkingDaysBack]
		@timeDayEnd as time
		,@numDaysBack as int
		,@fromTime as datetime = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DateBack as date
			,@currTime as time
			,@useDate as date
			,@maxDate as date


	SET @numDaysBack = @numDaysBack - 1

	IF @fromTime is NULL
		SET @fromTime = GETDATE()

	IF CONVERT(TIME, @fromTime) < @timeDayEnd
		SET @useDate = DATEADD(DD,-1,CAST(@fromTime as date))
	ELSE
		SET @useDate = @fromTime

	IF CONVERT(TIME, @fromTime) < '15:00:00.000'
		SET @maxDate = DATEADD(dd, -1, @fromTime)
	ELSE
		SET @maxDate = @fromTime


	SELECT dbo.AddWorkingDaysToDate(@useDate, -@numDaysBack) as minDate
			,@maxDate as maxDate


    
END
GO


