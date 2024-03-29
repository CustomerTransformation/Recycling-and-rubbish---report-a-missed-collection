USE [FStepRubbishRecycling_prod]
GO

/****** Object:  StoredProcedure [dbo].[MissedCollAuth]    Script Date: 13/02/2023 15:24:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Daniel Gregory
-- Create date: 23/05/2017
-- Description:	Updated with infromation from Authorisation
-- updated: 10/10/2018 include red hanger info
-- updated 18/09/2019 DCG: added for missed Food Waste
-- updated 08/11/2022 DCG: added for missed batteries or electrical items
-- =============================================
ALTER PROCEDURE [dbo].[MissedCollAuth] 
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
    @DatePrevMiss as date,
    @NoPrevMissed as int,
    @UserName as varchar(50),
    @RedHanger as varchar(10),

	@taskID as varchar(20)
	
AS
BEGIN
	SET NOCOUNT ON;
    
	IF @Rubbish = 'passBiffa' or @Rubbish = 'stop'
	BEGIN
		UPDATE [dbo].[MissedCollJobs]
		   SET [Date_Prev_Miss] = @DatePrevMiss
			  ,[Miss_Prev_6mon] = @NoPrevMissed
			  ,[Auth_out] = @Rubbish
			  ,[Collection] = CASE @Rubbish WHEN 'passBiffa' THEN [Collection] ELSE @Rubbish END
			  ,[Auth_by] = @UserName
			  ,[Auth_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'Rubbish'
    END
    
	IF @Batteries in ('passBiffa', 'stop')
	BEGIN
		UPDATE [dbo].[MissedCollJobs]
		   SET [Date_Prev_Miss] = @DatePrevMiss
			  ,[Miss_Prev_6mon] = @NoPrevMissed
			  ,[Auth_out] = @Batteries
			  ,[Collection] = CASE @Batteries WHEN 'passBiffa' THEN [Collection] ELSE @Batteries END
			  ,[Auth_by] = @UserName
			  ,[Auth_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'Batteries'
    END
    
	IF @Recycling = 'passBiffa' or @Recycling = 'stop' or @Recycling = 'redHanger'
	BEGIN
		UPDATE [dbo].[MissedCollJobs]
		   SET [Date_Prev_Miss] = @DatePrevMiss
			  ,[Miss_Prev_6mon] = @NoPrevMissed
			  ,[Auth_out] = @Recycling
			  ,[Collection] = CASE @Recycling WHEN 'passBiffa' THEN [Collection] ELSE @Recycling END
			  ,[Auth_by] = @UserName
			  ,[Auth_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'Recycling'
    END
    
	IF @Electrical in ('passBiffa', 'stop')
	BEGIN
		UPDATE [dbo].[MissedCollJobs]
		   SET [Date_Prev_Miss] = @DatePrevMiss
			  ,[Miss_Prev_6mon] = @NoPrevMissed
			  ,[Auth_out] = @Electrical
			  ,[Collection] = CASE @Electrical WHEN 'passBiffa' THEN [Collection] ELSE @Electrical END
			  ,[Auth_by] = @UserName
			  ,[Auth_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'Recycling'
    END
    
	IF @FoodWaste = 'passBiffa' or @Rubbish = 'stop'
	BEGIN
		UPDATE [dbo].[MissedCollJobs]
		   SET [Date_Prev_Miss] = @DatePrevMiss
			  ,[Miss_Prev_6mon] = @NoPrevMissed
			  ,[Auth_out] = @FoodWaste
			  ,[Auth_by] = @UserName
			  ,[Auth_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'FoodWaste'
    END
    
    
	IF @Healthcare = 'passBiffa' or @Healthcare = 'stop'
	BEGIN
		UPDATE [dbo].[MissedCollJobs]
		   SET [Date_Prev_Miss] = @DatePrevMiss
			  ,[Miss_Prev_6mon] = @NoPrevMissed
			  ,[Auth_out] = @Healthcare
			  ,[Collection] = CASE @Healthcare WHEN 'passBiffa' THEN [Collection] ELSE @Healthcare END
			  ,[Auth_by] = @UserName
			  ,[Auth_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'Healthcare'
    END
    
	IF @Bulky = 'passBiffa' or @Bulky = 'stop'
	BEGIN
		UPDATE [dbo].[MissedCollJobs]
		   SET [Date_Prev_Miss] = @DatePrevMiss
			  ,[Miss_Prev_6mon] = @NoPrevMissed
			  ,[Auth_out] = @Bulky
			  ,[Collection] = CASE @Bulky WHEN 'passBiffa' THEN [Collection] ELSE @Bulky END
			  ,[Auth_by] = @UserName
			  ,[Auth_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'Bulky'
    END
	IF @ComRubbish = 'passBiffa' or @ComRubbish = 'stop'
	BEGIN
		UPDATE [dbo].[MissedCollJobs]
		   SET [Date_Prev_Miss] = @DatePrevMiss
			  ,[Miss_Prev_6mon] = @NoPrevMissed
			  ,[Auth_out] = @ComRubbish
			  ,[Collection] = CASE @ComRubbish WHEN 'passBiffa' THEN [Collection] ELSE @ComRubbish END
			  ,[Auth_by] = @UserName
			  ,[Auth_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'ComRubbish'
    END
    
	IF @ComRecycling = 'passBiffa' or @ComRecycling = 'stop' or @ComRecycling = 'redHanger'
	BEGIN
		UPDATE [dbo].[MissedCollJobs]
		   SET [Date_Prev_Miss] = @DatePrevMiss
			  ,[Miss_Prev_6mon] = @NoPrevMissed
			  ,[Auth_out] = @ComRecycling
			  ,[Collection] = CASE @ComRecycling WHEN 'passBiffa' THEN [Collection] ELSE @ComRecycling END
			  ,[Auth_by] = @UserName
			  ,[Auth_date] = GETDATE()
		 WHERE [CaseNo] = @CaseNo
			AND [ColType] = 'ComRecycling'
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
		SELECT 'RH' as otherRecorded
    END

	UPDATE [dbo].[MissedColl]
	   SET [TaskID] = @taskID
	 WHERE [CaseNo] = @CaseNo
 
END  

GO


