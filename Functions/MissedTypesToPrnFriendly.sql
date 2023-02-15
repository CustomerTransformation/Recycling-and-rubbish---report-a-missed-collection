USE [FStepRubbishRecycling_prod]
GO

/****** Object:  UserDefinedFunction [dbo].[MissedTypesToPrnFriendly]    Script Date: 13/02/2023 15:08:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Daniel Gregory
-- Create date: 30/01/2023
-- Description:	Update four letter missed collection types to a print frendly list
-- =============================================
CREATE FUNCTION [dbo].[MissedTypesToPrnFriendly] 
(
	@lst as varchar(220)
)
RETURNS varchar(550)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @friendlyList as varchar(550)

	IF  LEFT(@lst, 2) = ', ' 
		SET @lst = RIGHT(@lst, LEN(@lst) - 2)

	IF  RIGHT(@lst, 2) = ', ' 
		SET @lst = LEFT(@lst, LEN(@lst) - 2)

	IF LEN(@lst) > 6
		SET @lst = LEFT(@lst, LEN(@lst) - 6) + REPLACE(RIGHT(@lst, 6), ', ', ' and ')

	SET @lst = REPLACE(@lst, 'sRub', 'Rubbish')

	SET @lst = REPLACE(@lst, 'Batt', 'Rubbish')

	SET @lst = REPLACE(@lst, 'sRec', 'Rubbish')

	SET @lst = REPLACE(@lst, 'Elec', 'Electrical items')

	SET @lst = REPLACE(@lst, 'Heal', 'Healthcare')

	SET @lst = REPLACE(@lst, 'Food', 'Food Waste')

	SET @lst = REPLACE(@lst, 'Bulk', 'Bulky waste')

	SET @lst = REPLACE(@lst, 'CRub', 'Communal rubbish')

	SET @friendlyList = REPLACE(@lst, 'CRec', 'Communal recycling')

	RETURN @friendlyList

END
GO


