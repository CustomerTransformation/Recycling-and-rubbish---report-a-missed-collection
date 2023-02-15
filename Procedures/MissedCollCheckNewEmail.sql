USE [FStepRubbishRecycling_prod]
GO

/****** Object:  StoredProcedure [dbo].[MissedCollCheckNewEmail]    Script Date: 13/02/2023 15:07:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Daniel Gregory
-- Create date: 12/09/2022
-- Description:	Check if email address has been provided
-- =============================================
CREATE PROCEDURE [dbo].[MissedCollCheckNewEmail]
			@CaseNo as varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @emailFromTable as varchar(256)

    SELECT @emailFromTable = [Email]
	  FROM MissedColl
	 WHERE [CaseNo] = @CaseNo
	   AND ISNULL([Email], '') <> ''

	IF @@ROWCOUNT > 0
		SELECT 'Found email' as msgCheckNewEmail
			   ,@emailFromTable  as email_cust
	ELSE
		SELECT 'Not Found' as msgCheckNewEmail

END
GO


