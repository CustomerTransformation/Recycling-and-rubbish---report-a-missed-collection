USE [FStepRubbishRecycling_prod]
GO
/****** Object:  StoredProcedure [dbo].[MissedCollEnq]    Script Date: 04/05/2020 09:23:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Daniel Gregory
-- Create date: 23/05/2017
-- Description:	Store information from Enquirey
-- updated: 10/10/2018 include red hanger info
-- updated 18/09/2019 DCG: added for missed Food Waste
-- =============================================
ALTER PROCEDURE [dbo].[MissedCollEnq] 
	@CaseNo as varchar(50),
	@Contact as varchar(50),
	@Tel as varchar(50),
	@Mobile as varchar(50),
	@Email as varchar(255),
	@SelfDash as varchar(10),
	@Address as text,
	@Postcode as varchar(10),
	@UPRN as varchar(10),
	@RefuseCrew as varchar(10),
	@RecyclingCrew as varchar(10),
	@ColTypes as varchar(255),
	@Recorded_by as varchar(50),
    @Req_Auth as varchar(5),
    @Enq_by as varchar(50),
    @Rubbish as varchar(50),
    @Recycling as varchar(50),
    
    @FoodWaste as varchar(50),
    
    @Healthcare as varchar(50),
    @Bulky as varchar(50),
    @ComRubbish as varchar(50),
    @ComRecycling as varchar(50),
	@Rub_Rep_Prev_missed as varchar(10),
    @Rub_TimeOut as varchar(50),
    @Rub_Usual as varchar(5),
	@Rec_Rep_Prev_missed as varchar(10),
    @Rec_TimeOut as varchar(50),
    @Rec_Usual as varchar(5),
    
	@Foo_Rep_Prev_missed as varchar(10),
    @Foo_TimeOut as varchar(50),
    @Foo_Usual as varchar(5),
    
	@Hea_Rep_Prev_missed as varchar(10),
    @Hea_TimeOut as varchar(50),
    @Hea_Usual as varchar(5),
    @Bul_TimeOut as varchar(50),
    @Bul_Usual as varchar(5),
    @ComRub_Overflowing as varchar(5),
    @ComRec_Overflowing as varchar(5),
    @RedHanger as varchar(10),
    @Road as varchar(255),

	@taskID as varchar(20)
	
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO MissedColl
           ([CaseNo]
           ,[Contact]
           ,[Tel]
           ,[Mobile]
           ,[Email]
           ,[SelfDash]
           ,[Address]
           ,[Postcode]
           ,[UPRN]
           ,[RefuseCrew]
           ,[RecyclingCrew]
           ,[ColTypes]
           ,[recorded_by]
           ,[recorded_date]
           ,[Road]
           ,[Outcome]
		   ,[TaskID])
     VALUES
           (@CaseNo
           ,@Contact
           ,@Tel
           ,@Mobile
           ,@Email
           ,@SelfDash
           ,@Address
           ,@Postcode
           ,@UPRN
           ,@RefuseCrew
           ,@RecyclingCrew
           ,@ColTypes
           ,@Recorded_by
           ,GETDATE()
           ,@Road
           ,'Enquirey'
		   ,@taskID)
    
	IF @Rubbish = 'rubbishBiffaE'
	BEGIN
		INSERT INTO MissedCollJobs
			   ([CaseNo]
			   ,[ColType]
			   ,[Rep_Prev_missed]
			   ,[TimeOut]
			   ,[Usual]
			   ,[Req_Auth]
			   ,[Enq_by]
			   ,[Enq_date])
		 VALUES
			   (@CaseNo
			   ,'Rubbish'
			   ,@Rub_Rep_Prev_missed
			   ,@Rub_TimeOut
			   ,@Rub_Usual
			   ,@Req_Auth
			   ,@Enq_by
			   ,GETDATE())
    END
    
	IF @Recycling = 'recyclingBiffaE'
	BEGIN
		INSERT INTO MissedCollJobs
			   ([CaseNo]
			   ,[ColType]
			   ,[Rep_Prev_missed]
			   ,[TimeOut]
			   ,[Usual]
			   ,[Req_Auth]
			   ,[Enq_by]
			   ,[Enq_date])
		 VALUES
			   (@CaseNo
			   ,'Recycling'
			   ,@Rec_Rep_Prev_missed
			   ,@Rec_TimeOut
			   ,@Rec_Usual
			   ,@Req_Auth
			   ,@Enq_by
			   ,GETDATE())
    END
    
	IF @FoodWaste = 'foodWasteBiffaE'
	BEGIN
		INSERT INTO MissedCollJobs
			   ([CaseNo]
			   ,[ColType]
			   ,[Rep_Prev_missed]
			   ,[TimeOut]
			   ,[Usual]
			   ,[Req_Auth]
			   ,[Enq_by]
			   ,[Enq_date])
		 VALUES
			   (@CaseNo
			   ,'FoodWaste'
			   ,@Foo_Rep_Prev_missed
			   ,@Foo_TimeOut
			   ,@Foo_Usual
			   ,@Req_Auth
			   ,@Enq_by
			   ,GETDATE())
    END
    
	IF @Healthcare = 'healthcareBiffaE'
	BEGIN
		INSERT INTO MissedCollJobs
			   ([CaseNo]
			   ,[ColType]
			   ,[Rep_Prev_missed]
			   ,[TimeOut]
			   ,[Usual]
			   ,[Req_Auth]
			   ,[Enq_by]
			   ,[Enq_date])
		 VALUES
			   (@CaseNo
			   ,'Healthcare'
			   ,@Hea_Rep_Prev_missed
			   ,@Hea_TimeOut
			   ,@Hea_Usual
			   ,@Req_Auth
			   ,@Enq_by
			   ,GETDATE())
    END
    
	IF @Bulky = 'bulkyBiffaE'
	BEGIN
		INSERT INTO MissedCollJobs
			   ([CaseNo]
			   ,[ColType]
			   ,[TimeOut]
			   ,[Usual]
			   ,[Req_Auth]
			   ,[Enq_by]
			   ,[Enq_date])
		 VALUES
			   (@CaseNo
			   ,'Bulky'
			   ,@Bul_TimeOut
			   ,@Bul_Usual
			   ,@Req_Auth
			   ,@Enq_by
			   ,GETDATE())
    END
    
	IF @ComRubbish = 'comRubbishBiffaE'
	BEGIN
		INSERT INTO MissedCollJobs
			   ([CaseNo]
			   ,[ColType]
			   ,[Overflowing]
			   ,[Req_Auth]
			   ,[Enq_by]
			   ,[Enq_date])
		 VALUES
			   (@CaseNo
			   ,'ComRubbish'
			   ,@ComRub_Overflowing
			   ,@Req_Auth
			   ,@Enq_by
			   ,GETDATE())
    END
    
	IF @ComRecycling = 'comRecyclingBiffaE'
	BEGIN
		INSERT INTO MissedCollJobs
			   ([CaseNo]
			   ,[ColType]
			   ,[Overflowing]
			   ,[Req_Auth]
			   ,[Enq_by]
			   ,[Enq_date])
		 VALUES
			   (@CaseNo
			   ,'ComRecycling'
			   ,@ComRec_Overflowing
			   ,@Req_Auth
			   ,@Enq_by
			   ,GETDATE())
    END
    
	IF @RedHanger != ''
	BEGIN
		INSERT INTO MissedCollJobs
			   ([CaseNo]
			   ,[ColType]
			   ,[Enq_by]
			   ,[Enq_date]
			   ,[redHanger]
			   ,[RH_lastDate]
			   ,[RH_by])
		 VALUES
			   (@CaseNo
			   ,'RedHanger'
			   ,@Enq_by
			   ,GETDATE()
			   ,@RedHanger
			   ,GETDATE()
			   ,@Enq_by)
    END
 
END  
