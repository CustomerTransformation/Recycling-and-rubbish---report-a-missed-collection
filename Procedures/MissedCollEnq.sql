USE [FStepRubbishRecycling_prod]
GO

/****** Object:  StoredProcedure [dbo].[MissedCollEnq]    Script Date: 13/02/2023 15:24:25 ******/
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
-- updated 08/11/2022 DCG: added for missed batteries or electrical items
-- =============================================
ALTER PROCEDURE [dbo].[MissedCollEnq] 
	@CaseNo as varchar(50),
	@Contact as varchar(50),
	@Tel as varchar(50),
	@Mobile as varchar(50),
	@Email as varchar(255),
	@SelfDash as varchar(10),
	@Address as varchar(1000),
	@Postcode as varchar(10),
	@UPRN as varchar(10),
	@RefuseCrew as varchar(10),
	@RecyclingCrew as varchar(10),
	@ColTypes as varchar(255),
	@Recorded_by as varchar(50),
    @Req_Auth as varchar(5),
    @Enq_by as varchar(50),

    @Rubbish as varchar(50),
    @Batteries as varchar(50),
    @Recycling as varchar(50),
    @Electrical as varchar(50),
    
    @FoodWaste as varchar(50),
    @Healthcare as varchar(50),
    @Bulky as varchar(50),
    @ComRubbish as varchar(50),
    @ComRecycling as varchar(50),
	@Rub_Rep_Prev_missed as varchar(10),
    @Rub_TimeOut as varchar(50),
    @Rub_Usual as varchar(5),

	@Bat_Rep_Prev_missed as varchar(10),
    @Bat_TimeOut as varchar(50),
    @Bat_Usual as varchar(5),

	@Rec_Rep_Prev_missed as varchar(10),
    @Rec_TimeOut as varchar(50),
    @Rec_Usual as varchar(5),

	@Elec_Rep_Prev_missed as varchar(10),
    @Elec_TimeOut as varchar(50),
    @Elec_Usual as varchar(5),
    
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
	@taskID as varchar(20),

	@rubColDate as date = NULL,
	@batColDate as date = NULL,
	@recColDate as date = NULL,
	@elecColDate as date = NULL,

	@fooColDate as date = NULL,
	@heaColDate as date = NULL,
	@bulColDate as date = NULL,
	@comRubColDate as date = NULL,
	@comRecColDate as date = NULL,

	@rub_canKeep as varchar(5) = NULL,
	@bat_canKeep as varchar(5) = NULL,
	@rec_canKeep as varchar(5) = NULL,
	@elec_canKeep as varchar(5) = NULL,
	@foo_canKeep as varchar(5) = NULL,
	@hea_canKeep as varchar(5) = NULL,
	@comRub_canKeep as varchar(5) = NULL,
	@comRec_canKeep as varchar(5) = NULL,
	@FWcrew as varchar(10) = NULL
	
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Outcome as varchar(15) = 'Report Only'
			,@keeping as varchar(50) = 'resident keeping waste'
			,@rubJobsAuthOut as varchar(50)
			,@batJobsAuthOut as varchar(50)
			,@recJobsAuthOut as varchar(50)
			,@elecJobsAuthOut as varchar(50)
			,@fooJobsAuthOut as varchar(50)
			,@heaJobsAuthOut as varchar(50)
			,@comRubJobsAuthOut as varchar(50)
			,@comRecJobsAuthOut as varchar(50)

	SET @Address = TRIM(@Address)

	IF @rub_canKeep = 'yes'
		SET @rubJobsAuthOut = @keeping
	ELSE IF @rub_canKeep = 'no'
	BEGIN
		SET @Outcome = 'Enquirey'
	END

	IF @bat_canKeep = 'yes'
		SET @batJobsAuthOut = @keeping
	ELSE IF @bat_canKeep = 'no'
	BEGIN
		SET @Outcome = 'Enquirey'
	END

	IF @rec_canKeep = 'yes'
		SET @recJobsAuthOut = @keeping
	ELSE IF @rec_canKeep = 'no'
	BEGIN
		SET @Outcome = 'Enquirey'
	END

	IF @elec_canKeep = 'yes'
		SET @elecJobsAuthOut = @keeping
	ELSE IF @elec_canKeep = 'no'
	BEGIN
		SET @Outcome = 'Enquirey'
	END

	IF @foo_canKeep = 'yes'
		SET @fooJobsAuthOut = @keeping
	ELSE IF @foo_canKeep = 'no'
	BEGIN
		SET @Outcome = 'Enquirey'
	END

	IF @hea_canKeep = 'yes'
		SET @heaJobsAuthOut = @keeping
	ELSE IF @hea_canKeep = 'no'
	BEGIN
		SET @Outcome = 'Enquirey'
	END

	IF @comRub_canKeep = 'yes'
		SET @comRubJobsAuthOut = @keeping
	ELSE IF @comRub_canKeep = 'no'
	BEGIN
		SET @Outcome = 'Enquirey'
	END

	IF @comRec_canKeep = 'yes'
		SET @comRecJobsAuthOut = @keeping
	ELSE IF @comRec_canKeep = 'no'
	BEGIN
		SET @Outcome = 'Enquirey'
	END

	
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
		   ,[TaskID]
		   ,FWcrew)
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
           ,@Outcome
		   ,@taskID
		   ,@FWcrew)
    
	IF @Rubbish = 'rubbishBiffaE'
	BEGIN
		INSERT INTO MissedCollJobs
			   ([CaseNo]
			   ,[ColType]
			   ,MissedDate
			   ,[Rep_Prev_missed]
			   ,[TimeOut]
			   ,[Usual]
			   ,[Req_Auth]
			   ,[Auth_out]
			   ,[Enq_by]
			   ,[Enq_date])
		 VALUES
			   (@CaseNo
			   ,'Rubbish'
			   ,@rubColDate
			   ,@Rub_Rep_Prev_missed
			   ,@Rub_TimeOut
			   ,@Rub_Usual
			   ,@Req_Auth
			   ,@rubJobsAuthOut
			   ,@Enq_by
			   ,GETDATE())
    END
    
	IF @Batteries = 'batteriesBiffaE'
	BEGIN
		INSERT INTO MissedCollJobs
			   ([CaseNo]
			   ,[ColType]
			   ,MissedDate
			   ,[Rep_Prev_missed]
			   ,[TimeOut]
			   ,[Usual]
			   ,[Req_Auth]
			   ,[Auth_out]
			   ,[Enq_by]
			   ,[Enq_date])
		 VALUES
			   (@CaseNo
			   ,'Batteries'
			   ,@batColDate
			   ,@Bat_Rep_Prev_missed
			   ,@Bat_TimeOut
			   ,@Bat_Usual
			   ,@Req_Auth
			   ,@batJobsAuthOut
			   ,@Enq_by
			   ,GETDATE())
    END
    
	IF @Recycling = 'recyclingBiffaE'
	BEGIN
		INSERT INTO MissedCollJobs
			   ([CaseNo]
			   ,[ColType]
			   ,MissedDate
			   ,[Rep_Prev_missed]
			   ,[TimeOut]
			   ,[Usual]
			   ,[Req_Auth]
			   ,[Auth_out]
			   ,[Enq_by]
			   ,[Enq_date])
		 VALUES
			   (@CaseNo
			   ,'Recycling'
			   ,@recColDate
			   ,@Rec_Rep_Prev_missed
			   ,@Rec_TimeOut
			   ,@Rec_Usual
			   ,@Req_Auth
			   ,@recJobsAuthOut
			   ,@Enq_by
			   ,GETDATE())
    END
    
	IF @Electrical = 'electricalBiffaE'
	BEGIN
		INSERT INTO MissedCollJobs
			   ([CaseNo]
			   ,[ColType]
			   ,MissedDate
			   ,[Rep_Prev_missed]
			   ,[TimeOut]
			   ,[Usual]
			   ,[Req_Auth]
			   ,[Auth_out]
			   ,[Enq_by]
			   ,[Enq_date])
		 VALUES
			   (@CaseNo
			   ,'Electrical'
			   ,@elecColDate
			   ,@Elec_Rep_Prev_missed
			   ,@Elec_TimeOut
			   ,@Elec_Usual
			   ,@Req_Auth
			   ,@elecJobsAuthOut
			   ,@Enq_by
			   ,GETDATE())
    END
    
	IF @FoodWaste = 'foodWasteBiffaE'
	BEGIN
		INSERT INTO MissedCollJobs
			   ([CaseNo]
			   ,[ColType]
			   ,MissedDate
			   ,[Rep_Prev_missed]
			   ,[TimeOut]
			   ,[Usual]
			   ,[Req_Auth]
			   ,[Auth_out]
			   ,[Enq_by]
			   ,[Enq_date])
		 VALUES
			   (@CaseNo
			   ,'FoodWaste'
			   ,@fooColDate
			   ,@Foo_Rep_Prev_missed
			   ,@Foo_TimeOut
			   ,@Foo_Usual
			   ,@Req_Auth
			   ,@fooJobsAuthOut
			   ,@Enq_by
			   ,GETDATE())
    END
    
	IF @Healthcare = 'healthcareBiffaE'
	BEGIN
		INSERT INTO MissedCollJobs
			   ([CaseNo]
			   ,[ColType]
			   ,MissedDate
			   ,[Rep_Prev_missed]
			   ,[TimeOut]
			   ,[Usual]
			   ,[Req_Auth]
			   ,[Auth_out]
			   ,[Enq_by]
			   ,[Enq_date])
		 VALUES
			   (@CaseNo
			   ,'Healthcare'
			   ,@heaColDate
			   ,@Hea_Rep_Prev_missed
			   ,@Hea_TimeOut
			   ,@Hea_Usual
			   ,@Req_Auth
			   ,@heaJobsAuthOut
			   ,@Enq_by
			   ,GETDATE())
    END
    
	IF @Bulky = 'bulkyBiffaE'
	BEGIN
		INSERT INTO MissedCollJobs
			   ([CaseNo]
			   ,[ColType]
			   ,MissedDate
			   ,[TimeOut]
			   ,[Usual]
			   ,[Req_Auth]
			   ,[Enq_by]
			   ,[Enq_date])
		 VALUES
			   (@CaseNo
			   ,'Bulky'
			   ,@bulColDate
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
			   ,MissedDate
			   ,[Overflowing]
			   ,[Req_Auth]
			   ,[Auth_out]
			   ,[Enq_by]
			   ,[Enq_date])
		 VALUES
			   (@CaseNo
			   ,'ComRubbish'
			   ,@comRubColDate
			   ,@ComRub_Overflowing
			   ,@Req_Auth
			   ,@comRubJobsAuthOut
			   ,@Enq_by
			   ,GETDATE())
    END
    
	IF @ComRecycling = 'comRecyclingBiffaE'
	BEGIN
		INSERT INTO MissedCollJobs
			   ([CaseNo]
			   ,[ColType]
			   ,MissedDate
			   ,[Overflowing]
			   ,[Req_Auth]
			   ,[Auth_out]
			   ,[Enq_by]
			   ,[Enq_date])
		 VALUES
			   (@CaseNo
			   ,'ComRecycling'
			   ,@comRecColDate
			   ,@ComRec_Overflowing
			   ,@Req_Auth
			   ,@comRecJobsAuthOut
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

	UPDATE MissedCollJobs
	   SET [Collection] = 'resKeep'
	 WHERE [Collection] is NULL
	   AND ColType != 'RedHanger'
	   AND [Auth_out] = @keeping
 
END  
GO


