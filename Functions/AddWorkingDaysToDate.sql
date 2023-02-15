USE [FStepRubbishRecycling_prod]
GO

/****** Object:  UserDefinedFunction [dbo].[AddWorkingDaysToDate]    Script Date: 13/02/2023 15:07:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Daniel Gregory
-- Create date: 12/09/2022
-- Description:	copied and altered from the Bookings system to work whole days, adding or subtracting workign days.
-- =============================================
CREATE FUNCTION [dbo].[AddWorkingDaysToDate] 
(
	@startDay as date
	,@daysToAdd as int
)
RETURNS date
AS
BEGIN
	-- Declare the return variable here
	DECLARE @calcWhen as date = @startDay
			,@Check as int = 0
			,@noWeeks as int
			,@goToDay as date
			,@noBH as int
			,@changePlusMinus int


	IF @daysToAdd < 0
	BEGIN
		SET @changePlusMinus = -1
		SET @daysToAdd = -1 * @daysToAdd
	END
	ELSE
		SET @changePlusMinus = 1

	SET @calcWhen = @startDay



	--make sure we start from a working day
	WHILE @Check = 0
	BEGIN
		SET @Check = 1
		IF DATENAME(DW,@calcWhen) = 'Saturday'
		BEGIN
			IF @changePlusMinus > 0
				SET @calcWhen =  DATEADD(day, 2, @calcWhen)
			ELSE 
				SET @calcWhen =  DATEADD(day, -1, @calcWhen)
			SET @Check = 0
		END
		ELSE IF DATENAME(DW,@calcWhen) = 'Sunday'
		BEGIN
			IF @changePlusMinus > 0
				SET @calcWhen =  DATEADD(day, 1, @calcWhen)
			ELSE 
				SET @calcWhen =  DATEADD(day, -2, @calcWhen)
			SET @Check = 0
		END
		
		IF (SELECT COUNT([BH_ID]) FROM [FStepCodeTables_prod].[dbo].[BankHolidays] WHERE [Date] = CAST(@calcWhen as date) AND BankHol = 1) > 0
		BEGIN
			SET @calcWhen = DATEADD(day, @changePlusMinus, @calcWhen)
			SET @Check = 0
		END
	END
	
	--if a week or more then can work out on weeks first so don't have to go through every day
	IF @daysToAdd >= 5
	BEGIN
		SET @noWeeks = FLOOR(@daysToAdd/5)
		SET @goToDay = DATEADD(day, @noWeeks * 7 * @changePlusMinus, @calcWhen)
		if @changePlusMinus < 0
			SELECT @noBH = COUNT([BH_ID]) 
			  FROM [FStepCodeTables_prod].[dbo].[BankHolidays] 
			 WHERE [Date] <= CAST(@calcWhen as date) 
			   AND [Date] >= CAST(@goToDay as date) 
			   AND BankHol = 1
		ELSE
			SELECT @noBH = COUNT([BH_ID]) 
			  FROM [FStepCodeTables_prod].[dbo].[BankHolidays] 
			 WHERE [Date] >= CAST(@calcWhen as date) 
			   AND [Date] <= CAST(@goToDay as date) 
			   AND BankHol = 1
		SET @daysToAdd = @daysToAdd - (@noWeeks * 5) + @noBH
		SET @calcWhen = @goToDay
	END
	ELSE
		SET @noWeeks = 0

	--for any number of days under a weeks worth go through each and make sure it is a working day or add a day
	WHILE @daysToAdd >= 0
	BEGIN
		WHILE @Check = 0
		BEGIN
			SET @Check = 1
			IF DATENAME(DW,@calcWhen) = 'Saturday'
			BEGIN
				IF @changePlusMinus > 0
					SET @calcWhen =  DATEADD(day, 2, @calcWhen)
				ELSE 
					SET @calcWhen =  DATEADD(day, -1, @calcWhen)
				SET @Check = 0
			END
			ELSE IF DATENAME(DW,@calcWhen) = 'Sunday'
			BEGIN
				IF @changePlusMinus > 0
					SET @calcWhen =  DATEADD(day, 1, @calcWhen)
				ELSE 
					SET @calcWhen =  DATEADD(day, -2, @calcWhen)
				SET @Check = 0
			END
		
			IF (SELECT COUNT([BH_ID]) FROM [FStepCodeTables_prod].[dbo].[BankHolidays] WHERE [Date] = CAST(@calcWhen as date) AND BankHol = 1) > 0
			BEGIN
				SET @calcWhen = DATEADD(day, @changePlusMinus, @calcWhen)
				SET @Check = 0
			END
		END
		IF @daysToAdd > 0
			SET @calcWhen = DATEADD(day, @changePlusMinus, @calcWhen)
		SET @daysToAdd = @daysToAdd - 1
		SET @Check = 0
	END
	
	-- Return the next working day with the required number of working days added
	RETURN @calcWhen

END
GO


