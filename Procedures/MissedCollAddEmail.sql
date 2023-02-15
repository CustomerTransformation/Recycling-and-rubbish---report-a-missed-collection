USE [FStepRubbishRecycling_prod]
GO

/****** Object:  StoredProcedure [dbo].[MissedCollAddEmail]    Script Date: 13/02/2023 15:04:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Daniel Gregory
-- Create date: 13/09/2022
-- Description:	To update the record with email address
-- =============================================
CREATE PROCEDURE [dbo].[MissedCollAddEmail] 
						@PrevCaseNo as varchar(550)
					   ,@emailAddress as varchar(256)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @listCases TABLE (ID int identity(1,1)
							  ,caseNo varchar(50))

	DECLARE @currCaseNo as varchar(50)
			,@noEntries as int
			,@loopCount as int = 1

	INSERT INTO @listCases (caseNo)
	SELECT [value]
	  FROM string_split(@PrevCaseNo, ',')
	
	SET @noEntries = @@ROWCOUNT
	
	WHILE @loopCount <= @noEntries
	BEGIN
		SELECT @currCaseNo = caseNo
		  FROM @listCases
		 WHERE ID = @loopCount
	
		UPDATE [dbo].[MissedColl]
		   SET [Email] = @emailAddress
		 WHERE [CaseNo] = @PrevCaseNo

		SET @loopCount = @loopCount + 1
	END
END  

GO


