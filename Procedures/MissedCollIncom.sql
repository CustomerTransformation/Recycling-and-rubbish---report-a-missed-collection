USE [FStepRubbishRecycling_prod]
GO
/****** Object:  StoredProcedure [dbo].[MissedCollIncom]    Script Date: 13/02/2023 15:25:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Daniel Gregory
-- Create date: 23/05/2017
-- Description:	Updated with infromation from Biffa Collection
-- updated 18/09/2019 DCG: added for missed Food Waste
-- updated 08/11/2022 DCG: added for missed batteries or electrical items
-- =============================================
ALTER PROCEDURE [dbo].[MissedCollIncom] 
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
	@taskID as varchar(20)
	
AS
BEGIN
	SET NOCOUNT ON;
    
	IF @Rubbish = 'yes' or @Rubbish = 'no'
	BEGIN
		UPDATE MissedCollJobs
		   SET [IncompleteOut] = @Rubbish
			  ,[Incom_by] = @UserName
			  ,[Incom_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'Rubbish';
    END
    
	IF @Batteries in ('yes', 'no')
	BEGIN
		UPDATE MissedCollJobs
		   SET [IncompleteOut] = @Batteries
			  ,[Incom_by] = @UserName
			  ,[Incom_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'Batteries';
    END
    
	IF @Recycling = 'yes' or @Recycling = 'no'
	BEGIN
		UPDATE MissedCollJobs
		   SET [IncompleteOut] = @Recycling
			  ,[Incom_by] = @UserName
			  ,[Incom_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'Recycling';
    END
    
	IF @Electrical in ('yes', 'no')
	BEGIN
		UPDATE MissedCollJobs
		   SET [IncompleteOut] = @Electrical
			  ,[Incom_by] = @UserName
			  ,[Incom_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'Recycling';
    END
    
	IF @FoodWaste = 'yes' or @FoodWaste = 'no'
	BEGIN
		UPDATE MissedCollJobs
		   SET [IncompleteOut] = @FoodWaste
			  ,[Incom_by] = @UserName
			  ,[Incom_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'FoodWaste';
    END
    
	IF @Healthcare = 'yes' or @Healthcare = 'no'
	BEGIN
		UPDATE MissedCollJobs
		   SET [IncompleteOut] = @Healthcare
			  ,[Incom_by] = @UserName
			  ,[Incom_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'Healthcare';
    END
    
	IF @Bulky = 'yes' or @Bulky = 'no'
	BEGIN
		UPDATE MissedCollJobs
		   SET [IncompleteOut] = @Bulky
			  ,[Incom_by] = @UserName
			  ,[Incom_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'Bulky';
    END
    
	IF @ComRubbish = 'yes' or @ComRubbish = 'no'
	BEGIN
		UPDATE MissedCollJobs
		   SET [IncompleteOut] = @ComRubbish
			  ,[Incom_by] = @UserName
			  ,[Incom_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'ComRubbish';
    END
    
	IF @ComRecycling = 'yes' or @ComRecycling = 'no'
	BEGIN
		UPDATE MissedCollJobs
		   SET [IncompleteOut] = @ComRecycling
			  ,[Incom_by] = @UserName
			  ,[Incom_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'ComRecycling';
    END

	UPDATE [dbo].[MissedColl]
	   SET [TaskID] = @taskID
	 WHERE [CaseNo] = @CaseNo
 
END

