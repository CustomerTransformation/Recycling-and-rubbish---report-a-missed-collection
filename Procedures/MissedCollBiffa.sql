USE [FStepRubbishRecycling_prod]
GO

/****** Object:  StoredProcedure [dbo].[MissedCollBiffa]    Script Date: 13/02/2023 15:25:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Daniel Gregory
-- Create date: 23/05/2017
-- Description:	Updated with infromation from Biffa Collection
-- updated: 10/10/2018 include red hanger info
-- updated 18/09/2019 DCG: added for missed Food Waste
-- updated 08/11/2022 DCG: added for missed batteries or electrical items
-- =============================================
ALTER PROCEDURE [dbo].[MissedCollBiffa] 
	@CaseNo as varchar(50),

    @Rubbish as varchar(50),
    @Batteries as varchar(50),
    @Recycling as varchar(50),
    @Electrical as varchar(50),
    
    @FoodWaste as varchar(50),
    @Healthcare as varchar(50),
    @Bulky as varchar(50),
    @ComRubbish as varchar(50),
    @ComRecycling as varchar(50),
    @UserName as varchar(50),
    @RedHanger as varchar(10),

	@taskID as varchar(20)
	
AS
BEGIN
	SET NOCOUNT ON;
    
    DECLARE @NoRecoll	int;
    
	IF @Rubbish = 'col' or @Rubbish = 'part' or @Rubbish = 'wrong'
	BEGIN
		SET @NoRecoll = (SELECT SUM(NoRecollections)
							FROM MissedCollJobs
							WHERE [CaseNo] = @CaseNo
								AND [ColType] = 'Rubbish');
		IF @NoRecoll is null
		BEGIN
			SET @NoRecoll = 0;
		END
	
		UPDATE MissedCollJobs
		   SET [Collection] = @Rubbish
			  ,[NoRecollections] = @NoRecoll + 1
			  ,[Col_by] = @UserName
			  ,[Col_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'Rubbish';
    END
    
	IF @Batteries in ('col', 'part', 'wrong')
	BEGIN
		SET @NoRecoll = (SELECT SUM(NoRecollections)
							FROM MissedCollJobs
							WHERE [CaseNo] = @CaseNo
								AND [ColType] = 'Batteries');
		IF @NoRecoll is null
		BEGIN
			SET @NoRecoll = 0;
		END
	
		UPDATE MissedCollJobs
		   SET [Collection] = @Batteries
			  ,[NoRecollections] = @NoRecoll + 1
			  ,[Col_by] = @UserName
			  ,[Col_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'Batteries';
    END
    
	IF @Recycling = 'col' or @Recycling = 'part' or @Recycling = 'redHanger' or @Recycling = 'wrong'
	BEGIN
		SET @NoRecoll = (SELECT SUM(NoRecollections)
							FROM MissedCollJobs
							WHERE [CaseNo] = @CaseNo
								AND [ColType] = 'Recycling');
		IF @NoRecoll is null
		BEGIN
			SET @NoRecoll = 0;
		END
	
		UPDATE MissedCollJobs
		   SET [Collection] = @Recycling
			  ,[NoRecollections] = @NoRecoll + 1
			  ,[Col_by] = @UserName
			  ,[Col_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'Recycling';
    END
    
	IF @Electrical in ('col', 'part', 'wrong')
	BEGIN
		SET @NoRecoll = (SELECT SUM(NoRecollections)
							FROM MissedCollJobs
							WHERE [CaseNo] = @CaseNo
								AND [ColType] = 'Electrical');
		IF @NoRecoll is null
		BEGIN
			SET @NoRecoll = 0;
		END
	
		UPDATE MissedCollJobs
		   SET [Collection] = @Electrical
			  ,[NoRecollections] = @NoRecoll + 1
			  ,[Col_by] = @UserName
			  ,[Col_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'Electrical';
    END
    
	IF @FoodWaste = 'col' or @FoodWaste = 'part' or @FoodWaste = 'wrong'
	BEGIN
		SET @NoRecoll = (SELECT SUM(NoRecollections)
							FROM MissedCollJobs
							WHERE [CaseNo] = @CaseNo
								AND [ColType] = 'FoodWaste');
		IF @NoRecoll is null
		BEGIN
			SET @NoRecoll = 0;
		END
	
		UPDATE MissedCollJobs
		   SET [Collection] = @FoodWaste
			  ,[NoRecollections] = @NoRecoll + 1
			  ,[Col_by] = @UserName
			  ,[Col_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'FoodWaste';
    END
    
    
	IF @Healthcare = 'col' or @Healthcare = 'part'
	BEGIN
		SET @NoRecoll = (SELECT SUM(NoRecollections)
							FROM MissedCollJobs
							WHERE [CaseNo] = @CaseNo
								AND [ColType] = 'Healthcare');
		IF @NoRecoll is null
		BEGIN
			SET @NoRecoll = 0;
		END
	
		UPDATE MissedCollJobs
		   SET [Collection] = @Healthcare
			  ,[NoRecollections] = @NoRecoll + 1
			  ,[Col_by] = @UserName
			  ,[Col_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'Healthcare';
    END
    
	IF @Bulky = 'col' or @Bulky = 'part'
	BEGIN
		SET @NoRecoll = (SELECT SUM(NoRecollections)
							FROM MissedCollJobs
							WHERE [CaseNo] = @CaseNo
								AND [ColType] = 'Bulky');
		IF @NoRecoll is null
		BEGIN
			SET @NoRecoll = 0;
		END
	
		UPDATE MissedCollJobs
		   SET [Collection] = @Bulky
			  ,[NoRecollections] = @NoRecoll + 1
			  ,[Col_by] = @UserName
			  ,[Col_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'Bulky';
    END
    
	IF @ComRubbish = 'col' or @ComRubbish = 'part'
	BEGIN
		SET @NoRecoll = (SELECT SUM(NoRecollections)
							FROM MissedCollJobs
							WHERE [CaseNo] = @CaseNo
								AND [ColType] = 'ComRubbish');
		IF @NoRecoll is null
		BEGIN
			SET @NoRecoll = 0;
		END
	
		UPDATE MissedCollJobs
		   SET [Collection] = @ComRubbish
			  ,[NoRecollections] = @NoRecoll + 1
			  ,[Col_by] = @UserName
			  ,[Col_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'ComRubbish';
    END
    
	IF @ComRecycling = 'col' or @ComRecycling = 'part' or @ComRecycling = 'redHanger'
	BEGIN
		SET @NoRecoll = (SELECT SUM(NoRecollections)
							FROM MissedCollJobs
							WHERE [CaseNo] = @CaseNo
								AND [ColType] = 'ComRecycling');
		IF @NoRecoll is null
		BEGIN
			SET @NoRecoll = 0;
		END
	
		UPDATE MissedCollJobs
		   SET [Collection] = @ComRecycling
			  ,[NoRecollections] = @NoRecoll + 1
			  ,[Col_by] = @UserName
			  ,[Col_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'ComRecycling';
    END
    
	IF @RedHanger != ''
	BEGIN
		INSERT INTO MissedCollJobs
			   ([CaseNo]
			   ,[ColType]
			   ,[redHanger]
			   ,[RH_lastDate]
			   ,[RH_by])
		 VALUES
			   (@CaseNo
			   ,'RedHanger'
			   ,@RedHanger
			   ,GETDATE()
			   ,@UserName)
    END

	UPDATE [dbo].[MissedColl]
	   SET [TaskID] = @taskID
	 WHERE [CaseNo] = @CaseNo
 
END  

GO


