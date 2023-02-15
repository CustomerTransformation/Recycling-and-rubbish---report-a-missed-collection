USE [FStepRubbishRecycling_prod]
GO

/****** Object:  StoredProcedure [dbo].[MissedCollEnqCheck]    Script Date: 13/02/2023 15:06:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Daniel Gregory
-- Create date: 05/09/2022
-- Description:	check for previous missed collections for property on date
-- =============================================
CREATE PROCEDURE [dbo].[MissedCollEnqCheck]
	@Email as varchar(255),
	@SelfDash as varchar(10),
	@Address as varchar(1000),
	@Postcode as varchar(10),
	@UPRN as varchar(10),
	@ColTypes as varchar(255),
	@Recorded_by as varchar(50),

    @Rubbish as varchar(50),
    @Batteries as varchar(50),
    @Recycling as varchar(50),
    @Electrical as varchar(50),
    
    @FoodWaste as varchar(50),
    @Healthcare as varchar(50),
    @Bulky as varchar(50),
    @ComRubbish as varchar(50),
    @ComRecycling as varchar(50),
    @RedHanger as varchar(10),
    @Road as varchar(255),

	@rubColDate as date = NULL,
	@batColDate as date = NULL,
	@recColDate as date = NULL,
	@elecColDate as date = NULL,

	@fooColDate as date = NULL,
	@heaColDate as date = NULL,
	@bulColDate as date = NULL,
	@comRubColDate as date = NULL,
	@comRecColDate as date = NULL,
	
    @lst_canKeep as varchar(50) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CaseNumbers as varchar(2000)
			,@msgPrevious as varchar(2000)
			,@msgSubmitted as varchar(2000)
			,@count as int
			,@statEmail as varchar(10)
			,@msgResponse as varchar(2000)
			,@msgResponseOK as varchar(2000)
			,@typeStatus as varchar(20)
			,@htmlRedHanger as varchar(2000)
			,@htmlStillOpen as varchar(2000)
			,@htmlStillOpenNoEm as varchar(2000)
			,@htmlStillOpenNewEm as varchar(2000)
			,@htmlStillOpenOldEm as varchar(2000)
			,@htmlContact as varchar(2000)
			,@htmlclosed as varchar(2000)
			,@htmlResKeep as varchar(2000)
			,@htmlStopped as varchar(2000)
			,@htmlWrongPlace as varchar(2000)
			,@htmlPart as varchar(2000)
			,@valuesReturnCheck as varchar(500)
			,@withinTwoDays as date
			,@prevCaseNo as varchar(550) = ''
			,@currCaseNo as varchar(50)
			,@StatusRtn as varchar(20) = ''
			,@missEmail as int = 0
			,@canUpdate as varchar(20) = ''
			,@notProceed as varchar(20) = ''
			,@canUpdateInd as varchar(220)
			,@updateOption as varchar(5)
			,@prevTypesNoEmail as varchar(100) = ''

	SELECT @rubColDate = NULLIF(@rubColDate, '1900-01-01')
			,@batColDate = NULLIF(@batColDate, '1900-01-01')
			,@recColDate = NULLIF(@recColDate, '1900-01-01')
			,@elecColDate = NULLIF(@elecColDate, '1900-01-01')
			,@fooColDate = NULLIF(@fooColDate, '1900-01-01')
			,@heaColDate = NULLIF(@heaColDate, '1900-01-01')
			,@bulColDate = NULLIF(@bulColDate, '1900-01-01')
			,@comRubColDate = NULLIF(@comRubColDate, '1900-01-01')
			,@comRecColDate = NULLIF(@comRecColDate, '1900-01-01')

	SET @valuesReturnCheck = REPLACE(@ColTypes, ', ', '') + ISNULL(CAST(@rubColDate as varchar(10)), '') + ISNULL(CAST(@batColDate as varchar(10)), '') + ISNULL(CAST(@recColDate as varchar(10)), '') 
							+ ISNULL(CAST(@elecColDate as varchar(10)), '') + ISNULL(CAST(@fooColDate as varchar(10)), '') 
							+ ISNULL(CAST(@heaColDate as varchar(10)), '') + ISNULL(CAST(@bulColDate as varchar(10)), '') +  ISNULL(CAST(@comRubColDate as varchar(10)), '') + ISNULL(CAST(@comRecColDate as varchar(10)), '')
	

	SELECT  @CaseNumbers = STRING_AGG([CaseNo], ',')
	  FROM MissedColl
	 WHERE recorded_date > DATEADD(DD, -20, GETDATE())
	   AND (([UPRN] = @UPRN AND ISNULL(@UPRN, '') != '')
			OR ([Postcode] = @Postcode
				AND @Postcode != ''
				AND (ISNULL([UPRN], '') = '' OR ISNULL(@UPRN, '') = ''
				AND TRIM(LEFT(CAST([Address] as varchar(10)), 3)) = TRIM(LEFT(@Address, 3)))))

	SET @count = @@ROWCOUNT
    
	IF @count > 0
	BEGIN
		
		SET @msgResponse = ''
		SET @msgResponseOK = ''
		SET @withinTwoDays = dbo.AddWorkingDaysToDate(GETDATE(), -2)
		SET @htmlContact = '<p>If you need to discuss your missed collection with a member of the Recycling and Rubbish Team please call '
									+ '<a target="_blank" href="tel:02392841105">023 9284 1105</a>'
									+ ' or email <a target="_blank" href="mailto:recyclingandrubbish@portsmouthcc.gov.uk">recyclingandrubbish@portsmouthcc.gov.uk</a>.</p>'
		SET @htmlclosed = '<p>The contractor has fed back to us that they have returned and collected the missed bin</p>'
		SET @htmlResKeep = '<p>The report was made as information only with waste kept until next collecton' 
		SET @htmlStopped = '<p>The report checked into and found that no further action is going to take place</p>'
		SET @htmlRedHanger = '<p>The contractor has fed back to us that your recycling bin was contaminated,'
									+ ' this means that there is something in the bin that we do not take. To clarify, we only take the following items as recycling:</p>'
									+ ' </ul> <li>Paper (not shredded)</li> <li>Card</li> <li>Plastic bottles</li> <li>Cans</li> <li>Tins</li> <li>Aerosols</li> </ul>'
									+ ' <br /> <p>Please check your bin and remove any items not listed above; because it was reported as contaminated,'
									+ ' the contractor will not be returning to collect it so you will need to keep it until the next collection.'
									+ ' If you have surplus recycling next time, you can put it in a cardboard box beside your recycling bin.</p>'		
		SET @htmlStillOpen = '<p>You cannot report a missed collection that is still open. '
									+ 'Your report has been sent to our contractor but the original report didn''t include an email address to update you on our progress.</p>'
									+ @htmlContact
		SET @htmlStillOpenNewEm = '<p>You cannot report a missed collection that is still open. '
									+ 'Your report has been sent to our contractor but the original report didn''t include an email address to update you on our progress.</p>'
									+ @htmlContact
		SET @htmlStillOpenNoEm = '<p>You cannot report a missed collection that is still open. '
									+ 'Your report has been sent to our contractor but the original report didn''t include an email address to update you on our progress.</p>'
									+ @htmlContact
		SET @htmlStillOpenOldEm = '<p>You cannot report a missed collection that is still open. '
									+ 'Your report has been sent to our contractor and we will contact you on the email address provided on the original report when action is taken. </p>'
									+ @htmlContact
		
		SET @htmlWrongPlace = '<p>We asked the contractor to return and collect it but they have advised that the bin was left in the wrong place.</p>'
									+ '<p>Please leave your wheeled recycling bin, food caddy and refuse at the front boundary of your property, preferably on the pavement for easy collection by 07:00 hours on the day of collection.</p>'
									+ '<br />'
									+ '<p><img src="https://fs-filestore-eu.s3.amazonaws.com/portsmouth/forms/waste/images/PlacementOfBins.jpg" alt="Placement of Bin for collection" /></p>'
									+ '<br />'
									+ @htmlContact
		
		IF @ColTypes like '%rubbish%'
		BEGIN
			SET @msgSubmitted = '<p>Missed Rubbish Collection on ' + ISNULL(FORMAT(@rubColDate, 'dd/MM/yyyy'), '') + CASE WHEN CHARINDEX('sRub', @lst_canKeep) > 0 THEN ' (report only - bin kept until next collection)' ELSE '' END
			
			SELECT @msgPrevious = '<h2>There is already a report for missed rubbish collection on this date</h2>'
				   ,@typeStatus = mj.[Collection]
				   ,@prevCaseNo = mc.CaseNo
				   ,@statEmail = CASE WHEN ISNULL(mc.email, '') = '' AND ISNULL(@Email, '') = '' THEN 'no email'
									  WHEN ISNULL(mc.email, '') != '' AND ISNULL(@Email, '') = '' THEN 'already'
									  WHEN ISNULL(mc.email, '') = '' AND ISNULL(@Email, '') != '' THEN 'new'
									  WHEN ISNULL(mc.email, '') =  ISNULL(@Email, '') THEN 'match'
									  WHEN ISNULL(mc.email, '') !=  ISNULL(@Email, '') THEN 'different'
										ELSE '' END
				   ,@missEmail = @missEmail + CASE WHEN ISNULL(mc.email, '') = '' THEN 1 ELSE 0 END
				   ,@canUpdate = @canUpdate + CASE WHEN CHARINDEX('sRub', @lst_canKeep) = 0 AND mj.[collection] = 'resKeep' THEN ', sRub' ELSE '' END
				   ,@canUpdateInd = CASE WHEN CHARINDEX('sRub', @lst_canKeep) = 0 AND mj.[collection] = 'resKeep' THEN ', this can be updated for requesting a recollection.' ELSE '.' END
				   ,@notProceed = @notProceed  + CASE WHEN CHARINDEX('sRub', @lst_canKeep) > 0 OR mj.[collection] != 'resKeep' THEN ', sRub' ELSE '' END
				FROM MissedCollJobs mj
			INNER JOIN MissedColl mc
			ON mj.CaseNo = mc.CaseNo
				WHERE mj.[CaseNo] in (SELECT [value] FROM string_split(@CaseNumbers, ','))
				AND [ColType] = 'Rubbish' 
				AND MissedDate = @rubColDate
			
			IF @@ROWCOUNT > 0
			BEGIN
				SET @typeStatus = ISNULL(@typeStatus, '')
				SET @msgResponse = @msgResponse + @msgSubmitted + '</p>' + @msgPrevious 
								 + CASE @typeStatus WHEN 'col' THEN  @htmlclosed
													WHEN 'stop' THEN  @htmlStopped
													WHEN 'wrong' THEN  @htmlWrongPlace
													WHEN 'resKeep' THEN  @htmlResKeep
													ELSE CASE @statEmail WHEN 'match' THEN @htmlStillOpen 
																			WHEN 'no email' THEN @htmlStillOpenNoEm
																			WHEN 'already' THEN @htmlStillOpenOldEm
																			WHEN 'new' THEN @htmlStillOpenNewEm
																			WHEN 'different' THEN @htmlStillOpenOldEm
																			ELSE @htmlStillOpen END END
								 + @canUpdateInd
				IF @statEmail not in ('no email','new') or @typeStatus IN ('redHanger','col','stop','wrong','resKeep')
				BEGIN
					SET @prevCaseNo = ''
				END
				ELSE
				BEGIN
					SET @prevTypesNoEmail = @prevTypesNoEmail + ', sRub'
				END
			END
			ELSE
			BEGIN
				SET @msgResponseOK = @msgResponseOK + @msgSubmitted
				IF @rubColDate < @withinTwoDays And CHARINDEX('sRub', @lst_canKeep) = 0
					SET @msgResponseOK = @msgResponseOK + ' - Please note that this is more than 2 working days ago and therefore the contractor will not go back and collect this</p>'
				ELSE
					SET @msgResponseOK = @msgResponseOK + '</p>'
			END
		END
		
		IF @ColTypes like '%batteries%'
		BEGIN
			SET @msgSubmitted = '<p>Missed Batteries Collection on ' + ISNULL(FORMAT(@batColDate, 'dd/MM/yyyy'), '') + CASE WHEN CHARINDEX('Bat', @lst_canKeep) > 0 THEN ' (report only - bin kept until next collection)' ELSE '' END
						
			SELECT @msgPrevious = '<h2>There is already a report for missed batteries collection on this date</h2>'
				   ,@typeStatus = mj.[Collection]
				   ,@currCaseNo = mc.CaseNo
				   ,@statEmail = CASE WHEN ISNULL(mc.email, '') = '' AND ISNULL(@Email, '') = '' THEN 'no email'
									  WHEN ISNULL(mc.email, '') != '' AND ISNULL(@Email, '') = '' THEN 'already'
									  WHEN ISNULL(mc.email, '') = '' AND ISNULL(@Email, '') != '' THEN 'new'
									  WHEN ISNULL(mc.email, '') =  ISNULL(@Email, '') THEN 'match'
									  WHEN ISNULL(mc.email, '') !=  ISNULL(@Email, '') THEN 'different'
										ELSE '' END
				   ,@missEmail = @missEmail + CASE WHEN ISNULL(mc.email, '') = '' THEN 1 ELSE 0 END
				   ,@canUpdate = @canUpdate + CASE WHEN CHARINDEX('Bat', @lst_canKeep) = 0 AND mj.[collection] = 'resKeep' THEN ', Batt' ELSE '' END
				   ,@canUpdateInd = CASE WHEN CHARINDEX('Bat', @lst_canKeep) = 0 AND mj.[collection] = 'resKeep' THEN ', this can be updated for requesting a recollection.' ELSE '.' END
				   ,@notProceed = @notProceed  + CASE WHEN CHARINDEX('Bat', @lst_canKeep) > 0 OR mj.[collection] != 'resKeep' THEN ', Batt' ELSE '' END
				FROM MissedCollJobs mj
			INNER JOIN MissedColl mc
			ON mj.CaseNo = mc.CaseNo
				WHERE mj.[CaseNo] in (SELECT [value] FROM string_split(@CaseNumbers, ','))
				AND [ColType] = 'Batteries' 
				AND MissedDate = @batColDate
			
			IF @@ROWCOUNT > 0
			BEGIN
				SET @typeStatus = ISNULL(@typeStatus, '')
				SET @msgResponse = @msgResponse + @msgSubmitted + '</p>' + @msgPrevious 
								 + CASE @typeStatus WHEN 'col' THEN  @htmlclosed
													WHEN 'stop' THEN  @htmlStopped
													WHEN 'wrong' THEN  @htmlWrongPlace
													WHEN 'resKeep' THEN  @htmlResKeep
																ELSE CASE @statEmail WHEN 'match' THEN @htmlStillOpen 
																					 WHEN 'no email' THEN @htmlStillOpenNoEm
																					 WHEN 'already' THEN @htmlStillOpenOldEm
																					 WHEN 'new' THEN @htmlStillOpenNewEm
																					 WHEN 'different' THEN @htmlStillOpenOldEm
																					 ELSE @htmlStillOpen END END
								 + @canUpdateInd
				IF @currCaseNo <> @prevCaseNo AND @statEmail IN ('no email','new') AND @typeStatus NOT IN ('redHanger','col','stop','wrong','resKeep')
				BEGIN
					SET @prevTypesNoEmail = @prevTypesNoEmail + ', Batt'
					SET @prevCaseNo = @prevCaseNo + ',' + @currCaseNo
				END
			END
			ELSE
			BEGIN
				SET @msgResponseOK = @msgResponseOK + @msgSubmitted
				IF @batColDate < @withinTwoDays And CHARINDEX('Bat', @lst_canKeep) = 0
					SET @msgResponseOK = @msgResponseOK + ' - Please note that this is more than 2 working days ago and therefore the contractor will not go back and collect this</p>'
				ELSE
					SET @msgResponseOK = @msgResponseOK + '</p>'
			END
		END
		
		IF @ColTypes like '%recycling%'
		BEGIN
			SET @msgSubmitted = '<p>Missed Recycling Collection on ' + ISNULL(FORMAT(@recColDate, 'dd/MM/yyyy'), '') + CASE WHEN CHARINDEX('sRec', @lst_canKeep) > 0 THEN ' (report only - bin kept until next collection)' ELSE '' END
						
			SELECT @msgPrevious = '<h2>There is already a report for missed recycling collection on this date</h2>'
				   ,@typeStatus = mj.[Collection]
				   ,@currCaseNo = mc.CaseNo
				   ,@statEmail = CASE WHEN ISNULL(mc.email, '') = '' AND ISNULL(@Email, '') = '' THEN 'no email'
									  WHEN ISNULL(mc.email, '') != '' AND ISNULL(@Email, '') = '' THEN 'already'
									  WHEN ISNULL(mc.email, '') = '' AND ISNULL(@Email, '') != '' THEN 'new'
									  WHEN ISNULL(mc.email, '') =  ISNULL(@Email, '') THEN 'match'
									  WHEN ISNULL(mc.email, '') !=  ISNULL(@Email, '') THEN 'different'
										ELSE '' END
				   ,@missEmail = @missEmail + CASE WHEN ISNULL(mc.email, '') = '' THEN 1 ELSE 0 END
				   ,@canUpdate = @canUpdate + CASE WHEN CHARINDEX('sRec', @lst_canKeep) = 0 AND mj.[collection] = 'resKeep' THEN ', sRec' ELSE '' END
				   ,@canUpdateInd = CASE WHEN CHARINDEX('sRec', @lst_canKeep) = 0 AND mj.[collection] = 'resKeep' THEN ', this can be updated for requesting a recollection.' ELSE '.' END
				   ,@notProceed = @notProceed  + CASE WHEN CHARINDEX('sRec', @lst_canKeep) > 0 OR mj.[collection] != 'resKeep' THEN ', sRec' ELSE '' END
				FROM MissedCollJobs mj
			INNER JOIN MissedColl mc
			ON mj.CaseNo = mc.CaseNo
				WHERE mj.[CaseNo] in (SELECT [value] FROM string_split(@CaseNumbers, ','))
				AND [ColType] = 'Recycling' 
				AND MissedDate = @recColDate
			
			IF @@ROWCOUNT > 0
			BEGIN
				SET @typeStatus = ISNULL(@typeStatus, '')
				SET @msgResponse = @msgResponse + @msgSubmitted + '</p>' + @msgPrevious 
								 + CASE @typeStatus WHEN 'redHanger' THEN @htmlRedHanger 
													WHEN 'col' THEN  @htmlclosed
													WHEN 'stop' THEN  @htmlStopped
													WHEN 'wrong' THEN  @htmlWrongPlace
													WHEN 'resKeep' THEN  @htmlResKeep
																ELSE CASE @statEmail WHEN 'match' THEN @htmlStillOpen 
																					 WHEN 'no email' THEN @htmlStillOpenNoEm
																					 WHEN 'already' THEN @htmlStillOpenOldEm
																					 WHEN 'new' THEN @htmlStillOpenNewEm
																					 WHEN 'different' THEN @htmlStillOpenOldEm
																					 ELSE @htmlStillOpen END END
								 + @canUpdateInd
				IF @currCaseNo NOT IN (SELECT [value] FROM string_split(@prevCaseNo, ',')) AND @statEmail IN ('no email','new') AND @typeStatus NOT IN ('redHanger','col','stop','wrong','resKeep')
				BEGIN
					SET @prevTypesNoEmail = @prevTypesNoEmail + ', sRec'
					SET @prevCaseNo = @prevCaseNo + ',' + @currCaseNo
				END
			END
			ELSE
			BEGIN
				SET @msgResponseOK = @msgResponseOK + @msgSubmitted
				IF @recColDate < @withinTwoDays And CHARINDEX('sRec', @lst_canKeep) = 0
					SET @msgResponseOK = @msgResponseOK + ' - Please note that this is more than 2 working days ago and therefore the contractor will not go back and collect this</p>'
				ELSE
					SET @msgResponseOK = @msgResponseOK + '</p>'
			END
		END
		
		IF @ColTypes like '%electrical%'
		BEGIN
			SET @msgSubmitted = '<p>Missed Electrical Items Collection on ' + ISNULL(FORMAT(@elecColDate, 'dd/MM/yyyy'), '') + CASE WHEN CHARINDEX('Elec', @lst_canKeep) > 0 THEN ' (report only - bin kept until next collection)' ELSE '' END
						
			SELECT @msgPrevious = '<h2>There is already a report for missed electrical items collection on this date</h2>'
				   ,@typeStatus = mj.[Collection]
				   ,@currCaseNo = mc.CaseNo
				   ,@statEmail = CASE WHEN ISNULL(mc.email, '') = '' AND ISNULL(@Email, '') = '' THEN 'no email'
									  WHEN ISNULL(mc.email, '') != '' AND ISNULL(@Email, '') = '' THEN 'already'
									  WHEN ISNULL(mc.email, '') = '' AND ISNULL(@Email, '') != '' THEN 'new'
									  WHEN ISNULL(mc.email, '') =  ISNULL(@Email, '') THEN 'match'
									  WHEN ISNULL(mc.email, '') !=  ISNULL(@Email, '') THEN 'different'
										ELSE '' END
				   ,@missEmail = @missEmail + CASE WHEN ISNULL(mc.email, '') = '' THEN 1 ELSE 0 END
				   ,@canUpdate = @canUpdate + CASE WHEN CHARINDEX('Elec', @lst_canKeep) = 0 AND mj.[collection] = 'resKeep' THEN ', Elec' ELSE '' END
				   ,@canUpdateInd = CASE WHEN CHARINDEX('Elec', @lst_canKeep) = 0 AND mj.[collection] = 'resKeep' THEN ', this can be updated for requesting a recollection.' ELSE '.' END
				   ,@notProceed = @notProceed  + CASE WHEN CHARINDEX('Elec', @lst_canKeep) > 0 OR mj.[collection] != 'resKeep' THEN ', Elec' ELSE '' END
				FROM MissedCollJobs mj
			INNER JOIN MissedColl mc
			ON mj.CaseNo = mc.CaseNo
				WHERE mj.[CaseNo] in (SELECT [value] FROM string_split(@CaseNumbers, ','))
				AND [ColType] = 'Electrical' 
				AND MissedDate = @elecColDate
			
			IF @@ROWCOUNT > 0
			BEGIN
				SET @typeStatus = ISNULL(@typeStatus, '')
				SET @msgResponse = @msgResponse + @msgSubmitted + '</p>' + @msgPrevious 
								 + CASE @typeStatus WHEN 'col' THEN  @htmlclosed
													WHEN 'stop' THEN  @htmlStopped
													WHEN 'wrong' THEN  @htmlWrongPlace
													WHEN 'resKeep' THEN  @htmlResKeep
																ELSE CASE @statEmail WHEN 'match' THEN @htmlStillOpen 
																					 WHEN 'no email' THEN @htmlStillOpenNoEm
																					 WHEN 'already' THEN @htmlStillOpenOldEm
																					 WHEN 'new' THEN @htmlStillOpenNewEm
																					 WHEN 'different' THEN @htmlStillOpenOldEm
																					 ELSE @htmlStillOpen END END
								 + @canUpdateInd
				IF @currCaseNo NOT IN (SELECT [value] FROM string_split(@prevCaseNo, ',')) AND @statEmail IN ('no email','new') AND @typeStatus NOT IN ('redHanger','col','stop','wrong','resKeep')
				BEGIN
					SET @prevTypesNoEmail = @prevTypesNoEmail + ', Elec'
					SET @prevCaseNo = @prevCaseNo + ',' + @currCaseNo
				END
			END
			ELSE
			BEGIN
				SET @msgResponseOK = @msgResponseOK + @msgSubmitted
				IF @elecColDate < @withinTwoDays And CHARINDEX('Elec', @lst_canKeep) = 0
					SET @msgResponseOK = @msgResponseOK + ' - Please note that this is more than 2 working days ago and therefore the contractor will not go back and collect this</p>'
				ELSE
					SET @msgResponseOK = @msgResponseOK + '</p>'
			END
		END

		IF @ColTypes like '%foodWaste%'
		BEGIN
			SET @msgSubmitted = '<p>Missed Food Waste Collection on ' + ISNULL(FORMAT(@fooColDate, 'dd/MM/yyyy'), '') + CASE WHEN CHARINDEX('Foo', @lst_canKeep) > 0 THEN ' (report only - bin kept until next collection)' ELSE '' END
			
			SELECT @msgPrevious = '<h2>There is already a report for missed food waste collection on this date</h2>'
				   ,@typeStatus = mj.[Collection]
				   ,@currCaseNo = mc.CaseNo
				   ,@statEmail = CASE WHEN ISNULL(mc.email, '') = '' AND ISNULL(@Email, '') = '' THEN 'no email'
									  WHEN ISNULL(mc.email, '') != '' AND ISNULL(@Email, '') = '' THEN 'already'
									  WHEN ISNULL(mc.email, '') = '' AND ISNULL(@Email, '') != '' THEN 'new'
									  WHEN ISNULL(mc.email, '') =  ISNULL(@Email, '') THEN 'match'
									  WHEN ISNULL(mc.email, '') !=  ISNULL(@Email, '') THEN 'different'
										ELSE '' END
				   ,@missEmail = @missEmail + CASE WHEN ISNULL(mc.email, '') = '' THEN 1 ELSE 0 END
				   ,@canUpdate = @canUpdate + CASE WHEN CHARINDEX('Foo', @lst_canKeep) = 0 AND mj.[collection] = 'resKeep' THEN ', Food' ELSE '' END
				   ,@canUpdateInd = CASE WHEN CHARINDEX('Foo', @lst_canKeep) = 0 AND mj.[collection] = 'resKeep' THEN ', this can be updated for requesting a recollection.' ELSE '.' END
				   ,@notProceed = @notProceed  + CASE WHEN CHARINDEX('Foo', @lst_canKeep) > 0 OR mj.[collection] != 'resKeep' THEN ', Food' ELSE '' END
				FROM MissedCollJobs mj
			INNER JOIN MissedColl mc
			ON mj.CaseNo = mc.CaseNo
				WHERE mj.[CaseNo] in (SELECT [value] FROM string_split(@CaseNumbers, ','))
				  AND [ColType] = 'FoodWaste' AND MissedDate = @fooColDate
			
			IF @@ROWCOUNT > 0
			BEGIN
				SET @typeStatus = ISNULL(@typeStatus, '')
				SET @msgResponse = @msgResponse + @msgSubmitted + '</p>' + @msgPrevious 
								 + CASE @typeStatus WHEN 'col' THEN  @htmlclosed
													WHEN 'stop' THEN  @htmlStopped
													WHEN 'wrong' THEN  @htmlWrongPlace
													WHEN 'resKeep' THEN  @htmlResKeep
													ELSE CASE @statEmail WHEN 'match' THEN @htmlStillOpen 
																			WHEN 'no email' THEN @htmlStillOpenNoEm
																			WHEN 'already' THEN @htmlStillOpenOldEm
																			WHEN 'new' THEN @htmlStillOpenNewEm
																			WHEN 'different' THEN @htmlStillOpenOldEm
																			ELSE @htmlStillOpen END END
								 + @canUpdateInd
				IF @currCaseNo NOT IN (SELECT [value] FROM string_split(@prevCaseNo, ',')) AND @statEmail IN ('no email','new') AND @typeStatus NOT IN ('redHanger','col','stop','wrong','resKeep') 
				BEGIN
					SET @prevTypesNoEmail = @prevTypesNoEmail + ', Food'
					SET @prevCaseNo = @prevCaseNo + ',' + @currCaseNo 
				END
			END
			ELSE
			BEGIN
				SET @msgResponseOK = @msgResponseOK + @msgSubmitted
				IF @fooColDate < @withinTwoDays And CHARINDEX('Foo', @lst_canKeep) = 0
					SET @msgResponseOK = @msgResponseOK + ' - Please note that this is more than 2 working days ago and therefore the contractor will not go back and collect this</p>'
				ELSE
					SET @msgResponseOK = @msgResponseOK + '</p>'
			END
		END
		IF @ColTypes like '%healthcare%'
		BEGIN
			SET @msgSubmitted = '<p>Missed Healthcare Collection on ' + ISNULL(FORMAT(@heaColDate, 'dd/MM/yyyy'), '') + CASE WHEN CHARINDEX('Hea', @lst_canKeep) > 0 THEN ' (report only - bin kept until next collection)' ELSE '' END
			
			SELECT @msgPrevious = '<h2>There is already a report for missed healthcare waste collection on this date</h2>'
				   ,@typeStatus = mj.[Collection]
				   ,@currCaseNo = mc.CaseNo
				   ,@statEmail = CASE WHEN ISNULL(mc.email, '') = '' AND ISNULL(@Email, '') = '' THEN 'no email'
									  WHEN ISNULL(mc.email, '') != '' AND ISNULL(@Email, '') = '' THEN 'already'
									  WHEN ISNULL(mc.email, '') = '' AND ISNULL(@Email, '') != '' THEN 'new'
									  WHEN ISNULL(mc.email, '') =  ISNULL(@Email, '') THEN 'match'
									  WHEN ISNULL(mc.email, '') !=  ISNULL(@Email, '') THEN 'different'
										ELSE '' END
				   ,@missEmail = @missEmail + CASE WHEN ISNULL(mc.email, '') = '' THEN 1 ELSE 0 END
				   ,@canUpdate = @canUpdate + CASE WHEN CHARINDEX('Hea', @lst_canKeep) = 0 AND mj.[collection] = 'resKeep' THEN ', Heal' ELSE '' END
				   ,@canUpdateInd = CASE WHEN CHARINDEX('Hea', @lst_canKeep) = 0 AND mj.[collection] = 'resKeep' THEN ', this can be updated for requesting a recollection.' ELSE '.' END
				   ,@notProceed = @notProceed  + CASE WHEN CHARINDEX('Hea', @lst_canKeep) > 0 OR mj.[collection] != 'resKeep' THEN ', Heal' ELSE '' END
				FROM MissedCollJobs mj
			INNER JOIN MissedColl mc
			ON mj.CaseNo = mc.CaseNo
				WHERE mj.[CaseNo] in (SELECT [value] FROM string_split(@CaseNumbers, ','))
				AND [ColType] = 'Healthcare' AND MissedDate = @heaColDate
			
			IF @@ROWCOUNT > 0
			BEGIN
				SET @typeStatus = ISNULL(@typeStatus, '')
				SET @msgResponse = @msgResponse + @msgSubmitted + '</p>' + @msgPrevious 
								 + CASE @typeStatus WHEN 'col' THEN  @htmlclosed
													WHEN 'stop' THEN  @htmlStopped
													WHEN 'wrong' THEN  @htmlWrongPlace
													WHEN 'resKeep' THEN  @htmlResKeep
													ELSE CASE @statEmail WHEN 'match' THEN @htmlStillOpen 
																			WHEN 'no email' THEN @htmlStillOpenNoEm
																			WHEN 'already' THEN @htmlStillOpenOldEm
																			WHEN 'new' THEN @htmlStillOpenNewEm
																			WHEN 'different' THEN @htmlStillOpenOldEm
																			ELSE @htmlStillOpen END END
								 + @canUpdateInd
				IF @currCaseNo NOT IN (SELECT [value] FROM string_split(@prevCaseNo, ',')) AND @statEmail IN ('no email','new')  AND @typeStatus NOT IN ('redHanger','col','stop','wrong','resKeep')
				BEGIN
					SET @prevTypesNoEmail = @prevTypesNoEmail + ', Heal'
					SET @prevCaseNo = @prevCaseNo + ',' + @currCaseNo
				END
			END
			ELSE
			BEGIN
				SET @msgResponseOK = @msgResponseOK + @msgSubmitted
				IF @heaColDate < @withinTwoDays And CHARINDEX('Hea', @lst_canKeep) = 0
					SET @msgResponseOK = @msgResponseOK + ' - Please note that this is more than 2 working days ago and therefore the contractor will not go back and collect this</p>'
				ELSE
					SET @msgResponseOK = @msgResponseOK + '</p>'
			END
		END
		IF @ColTypes like '%bulky%'
		BEGIN
			SET @msgSubmitted = '<p>Missed Bulky Collection on ' + ISNULL(FORMAT(@bulColDate, 'dd/MM/yyyy'), '')
			
			SELECT @msgPrevious = '<h2>There is already a report for missed bulky collection on this date</h2>'
				   ,@typeStatus = mj.[Collection]
				   ,@currCaseNo = mc.CaseNo
				   ,@statEmail = CASE WHEN ISNULL(mc.email, '') = '' AND ISNULL(@Email, '') = '' THEN 'no email'
									  WHEN ISNULL(mc.email, '') != '' AND ISNULL(@Email, '') = '' THEN 'already'
									  WHEN ISNULL(mc.email, '') = '' AND ISNULL(@Email, '') != '' THEN 'new'
									  WHEN ISNULL(mc.email, '') =  ISNULL(@Email, '') THEN 'match'
									  WHEN ISNULL(mc.email, '') !=  ISNULL(@Email, '') THEN 'different'
										ELSE '' END
				   ,@missEmail = @missEmail + CASE WHEN ISNULL(mc.email, '') = '' THEN 1 ELSE 0 END
				FROM MissedCollJobs mj
			INNER JOIN MissedColl mc
			ON mj.CaseNo = mc.CaseNo
				WHERE mj.[CaseNo] in (SELECT [value] FROM string_split(@CaseNumbers, ','))
				AND [ColType] = 'Bulky' AND MissedDate = @bulColDate
			
			IF @@ROWCOUNT > 0
			BEGIN
				SET @typeStatus = ISNULL(@typeStatus, '')
				SET @msgResponse = @msgResponse + @msgSubmitted + '</p>' + @msgPrevious 
								 + CASE @typeStatus WHEN 'col' THEN  @htmlclosed
													WHEN 'stop' THEN  @htmlStopped
													WHEN 'wrong' THEN  @htmlWrongPlace
													WHEN 'resKeep' THEN  @htmlResKeep
													ELSE CASE @statEmail WHEN 'match' THEN @htmlStillOpen 
																			WHEN 'no email' THEN @htmlStillOpenNoEm
																			WHEN 'already' THEN @htmlStillOpenOldEm
																			WHEN 'new' THEN @htmlStillOpenNewEm
																			WHEN 'different' THEN @htmlStillOpenOldEm
																			ELSE @htmlStillOpen END END
				IF @currCaseNo NOT IN (SELECT [value] FROM string_split(@prevCaseNo, ',')) AND @statEmail IN ('no email','new')  AND @typeStatus NOT IN ('redHanger','col','stop','wrong','resKeep')
				BEGIN
					SET @prevTypesNoEmail = @prevTypesNoEmail + ', Bulk'
					SET @prevCaseNo = @prevCaseNo + ',' + @currCaseNo
				END
			END
			ELSE
			BEGIN
				SET @msgResponseOK = @msgResponseOK + @msgSubmitted
				IF @bulColDate < @withinTwoDays
					SET @msgResponseOK = @msgResponseOK + ' - Please note that this is more than 2 working days ago and therefore the contractor will not go back and collect this</p>'
				ELSE
					SET @msgResponseOK = @msgResponseOK + '</p>'
			END
		END
		IF @ColTypes like '%comRubbish%'
		BEGIN
			SET @msgSubmitted = '<p>Missed Communal Rubbish Collection on ' + ISNULL(FORMAT(@comRubColDate, 'dd/MM/yyyy'), '') + CASE WHEN CHARINDEX('CRub', @lst_canKeep) > 0 THEN ' (report only - bin kept until next collection)' ELSE '' END
			
			SELECT @msgPrevious = '<h2>There is already a report for missed communal rubbish collection on this date</h2>'
				   ,@typeStatus = mj.[Collection]
				   ,@currCaseNo = mc.CaseNo
				   ,@statEmail = CASE WHEN ISNULL(mc.email, '') = '' AND ISNULL(@Email, '') = '' THEN 'no email'
									  WHEN ISNULL(mc.email, '') != '' AND ISNULL(@Email, '') = '' THEN 'already'
									  WHEN ISNULL(mc.email, '') = '' AND ISNULL(@Email, '') != '' THEN 'new'
									  WHEN ISNULL(mc.email, '') =  ISNULL(@Email, '') THEN 'match'
									  WHEN ISNULL(mc.email, '') !=  ISNULL(@Email, '') THEN 'different'
										ELSE '' END
				   ,@missEmail = @missEmail + CASE WHEN ISNULL(mc.email, '') = '' THEN 1 ELSE 0 END
				   ,@canUpdate = @canUpdate + CASE WHEN CHARINDEX('CRub', @lst_canKeep) = 0 AND mj.[collection] = 'resKeep' THEN ', CRub' ELSE '' END
				   ,@canUpdateInd = CASE WHEN CHARINDEX('CRub', @lst_canKeep) = 0 AND mj.[collection] = 'resKeep' THEN ', this can be updated for requesting a recollection.' ELSE '.' END
				   ,@notProceed = @notProceed  + CASE WHEN CHARINDEX('CRub', @lst_canKeep) > 0 OR mj.[collection] != 'resKeep' THEN ', CRub' ELSE '' END
				FROM MissedCollJobs mj
			INNER JOIN MissedColl mc
			ON mj.CaseNo = mc.CaseNo
				WHERE mj.[CaseNo] in (SELECT [value] FROM string_split(@CaseNumbers, ','))
				AND [ColType] = 'ComRubbish' AND MissedDate = @comRubColDate
			
			IF @@ROWCOUNT > 0
			BEGIN
				SET @typeStatus = ISNULL(@typeStatus, '')
				SET @msgResponse = @msgResponse + @msgSubmitted + '</p>' + @msgPrevious 
								 + CASE @typeStatus WHEN 'col' THEN  @htmlclosed
													WHEN 'stop' THEN  @htmlStopped
													WHEN 'wrong' THEN  @htmlWrongPlace
													WHEN 'resKeep' THEN  @htmlResKeep
													ELSE CASE @statEmail WHEN 'match' THEN @htmlStillOpen 
																			WHEN 'no email' THEN @htmlStillOpenNoEm
																			WHEN 'already' THEN @htmlStillOpenOldEm
																			WHEN 'new' THEN @htmlStillOpenNewEm
																			WHEN 'different' THEN @htmlStillOpenOldEm
																			ELSE @htmlStillOpen END END
								 + @canUpdateInd
				IF @currCaseNo NOT IN (SELECT [value] FROM string_split(@prevCaseNo, ',')) AND @statEmail IN ('no email','new')  AND @typeStatus NOT IN ('redHanger','col','stop','wrong','resKeep')
				BEGIN
					SET @prevTypesNoEmail = @prevTypesNoEmail + ', CRub'
					SET @prevCaseNo = @prevCaseNo + ',' + @currCaseNo
				END
			END
			ELSE
			BEGIN
				SET @msgResponseOK = @msgResponseOK + @msgSubmitted
				IF @comRubColDate < @withinTwoDays And CHARINDEX('CRub', @lst_canKeep) = 0
					SET @msgResponseOK = @msgResponseOK + ' - Please note that this is more than 2 working days ago and therefore the contractor will not go back and collect this</p>'
				ELSE
					SET @msgResponseOK = @msgResponseOK + '</p>'
			END
		END
		IF @ColTypes like '%comRecycling%'
		BEGIN
			SET @msgSubmitted = '<p>Missed Communal Recycling Collection on ' + ISNULL(FORMAT(@comRecColDate, 'dd/MM/yyyy'), '') + CASE WHEN CHARINDEX('CRec', @lst_canKeep) > 0 THEN ' (report only - bin kept until next collection)' ELSE '' END
			
			SELECT @msgPrevious = '<h2>There is already a report for missed communal recycling collection on this date</h2>'
				   ,@typeStatus = mj.[Collection]
				   ,@currCaseNo = mc.CaseNo
				   ,@statEmail = CASE WHEN ISNULL(mc.email, '') = '' AND ISNULL(@Email, '') = '' THEN 'no email'
									  WHEN ISNULL(mc.email, '') != '' AND ISNULL(@Email, '') = '' THEN 'already'
									  WHEN ISNULL(mc.email, '') = '' AND ISNULL(@Email, '') != '' THEN 'new'
									  WHEN ISNULL(mc.email, '') =  ISNULL(@Email, '') THEN 'match'
									  WHEN ISNULL(mc.email, '') !=  ISNULL(@Email, '') THEN 'different'
										ELSE '' END
				   ,@missEmail = @missEmail + CASE WHEN ISNULL(mc.email, '') = '' THEN 1 ELSE 0 END
				   ,@canUpdate = @canUpdate + CASE WHEN CHARINDEX('CRec', @lst_canKeep) = 0 AND mj.[collection] = 'resKeep' THEN ', CRec' ELSE '' END
				   ,@canUpdateInd = CASE WHEN CHARINDEX('CRec', @lst_canKeep) = 0 AND mj.[collection] = 'resKeep' THEN ', this can be updated for requesting a recollection.' ELSE '.' END
				   ,@notProceed = @notProceed  + CASE WHEN CHARINDEX('CRec', @lst_canKeep) > 0 OR mj.[collection] != 'resKeep' THEN ', CRec' ELSE '' END
				FROM MissedCollJobs mj
			INNER JOIN MissedColl mc
			ON mj.CaseNo = mc.CaseNo
				WHERE mj.[CaseNo] in (SELECT [value] FROM string_split(@CaseNumbers, ','))
				AND [ColType] = 'ComRecycling' AND MissedDate = @comRecColDate
			
			IF @@ROWCOUNT > 0
			BEGIN
				SET @typeStatus = ISNULL(@typeStatus, '')
				SET @msgResponse = @msgResponse + @msgSubmitted + @msgPrevious 
								 + CASE @typeStatus WHEN 'redHanger' THEN @htmlRedHanger 
													WHEN 'col' THEN  @htmlclosed
													WHEN 'stop' THEN  @htmlStopped
													WHEN 'wrong' THEN  @htmlWrongPlace
													WHEN 'resKeep' THEN  @htmlResKeep
																ELSE CASE @statEmail WHEN 'match' THEN @htmlStillOpen 
																					 WHEN 'no email' THEN @htmlStillOpenNoEm
																					 WHEN 'already' THEN @htmlStillOpenOldEm
																					 WHEN 'new' THEN @htmlStillOpenNewEm
																					 WHEN 'different' THEN @htmlStillOpenOldEm
																					 ELSE @htmlStillOpen END END
								 + @canUpdateInd
				IF @currCaseNo NOT IN (SELECT [value] FROM string_split(@prevCaseNo, ',')) AND @statEmail IN ('no email','new') AND @typeStatus NOT IN ('redHanger','col','stop','wrong','resKeep')
				BEGIN
					SET @prevTypesNoEmail = @prevTypesNoEmail + ', CRec'
					SET @prevCaseNo = @prevCaseNo + ',' + @currCaseNo
				END
			END
			ELSE
			BEGIN
				SET @msgResponseOK = @msgResponseOK + @msgSubmitted
				IF @comRecColDate < @withinTwoDays And CHARINDEX('CRec', @lst_canKeep) = 0
					SET @msgResponseOK = @msgResponseOK + ' - Please note that this is more than 2 working days ago and therefore the contractor will not go back and collect this</p>'
				ELSE
					SET @msgResponseOK = @msgResponseOK + '</p>'
			END
		END
	END

	IF NULLIF(@msgResponse, '') is NULL
	BEGIN
		SET @withinTwoDays = dbo.AddWorkingDaysToDate(GETDATE(), -2)
		SET @StatusRtn = 'noPrevious'
		
		SET @msgResponse = '<h2>Summary</h2>'
							+ '<p>For address:</p>'
							+ '<p style="white-space: pre-wrap; padding-left: 5%;">' + @Address + '</p>'
							+ '<p>Ready to submit the following missed collection</p>'
							+ @msgResponseOK

		IF @RedHanger != ''
		BEGIN
			SET @msgResponse = @msgResponse + '<p>Red hanger reported</p>'
		END
		
	END
	ELSE IF NULLIF(@msgResponseOK, '') is not NULL
	BEGIN
		IF @canUpdate != ''
		BEGIN
			SET @canUpdate = dbo.MissedTypesToPrnFriendly(@canUpdate)
			IF @notProceed = ''
			BEGIN
				SET @updateOption = 'yes'
				SET @msgResponse = @msgResponse
								   + @msgResponseOK
			END
			ELSE
			BEGIN
				SET @updateOption = 'no'
				SET @msgResponse = @msgResponse
								   + @msgResponseOK
								   + '<p>To be able to update the ' + @canUpdate + ' you must first go back and remove the ' + dbo.MissedTypesToPrnFriendly(@notProceed) + ' from the missed collections being reported.</p>'
			END
		END
		ELSE
			SET @msgResponse = @msgResponse 
								+ '<p><strong>You cannot submit this form as one or more of the collections you''re trying to report is a duplicate. If you wish to report any other collections, go back to the ''Collection details'' tab and remove the duplicate report(s).</strong></p>'
								+ @msgResponseOK
		
		SET @StatusRtn = 'Previous'
	END
	ELSE IF NULLIF(@msgResponseOK, '') is NULL
	BEGIN
		IF @canUpdate != ''
		BEGIN
			SET @canUpdate = dbo.MissedTypesToPrnFriendly(@canUpdate)
			IF @notProceed = ''
			BEGIN
				SET @updateOption = 'yes'
			END
			ELSE
			BEGIN
				SET @updateOption = 'no'
				SET @msgResponse = @msgResponse
								   + '<p>To be able to update the ' + @canUpdate + ' you must first go back and remove the ' + dbo.MissedTypesToPrnFriendly(@notProceed) + ' from the missed collections being reported.</p>'
			END
		END
		ELSE
		IF @missEmail > 0 AND @prevCaseNo != ''
		BEGIN
			IF @Email = ''
			BEGIN
				SET @msgResponse = @msgResponse + '<p>If you would like an update on our progress regarding your report, you can give us your email address now and click ''submit''.</p>'
				SET @StatusRtn = 'previous None-None'
			END
			ELSE
			BEGIN
				SET @msgResponse = @msgResponse + '<p>If you would like an update on our progress regarding your report, you can give us your email address now click ''submit''.</p>'
				SET @StatusRtn = 'previous None-New'
			END
		END
	END
	ELSE IF @canUpdate != ''
	BEGIN
		SET @canUpdate = dbo.MissedTypesToPrnFriendly(@canUpdate)
		IF @notProceed = ''
		BEGIN
			SET @updateOption = 'yes'
		END
		ELSE
		BEGIN
			SET @updateOption = 'no'
			SET @msgResponse = @msgResponse
								+ '<p>To be able to update the ' + @canUpdate + ' you must first go back and remove the ' + dbo.MissedTypesToPrnFriendly(@notProceed) + ' from the missed collections being reported.</p>'
		END
	END
    
	IF @prevTypesNoEmail != ''
		SET @prevTypesNoEmail = dbo.MissedTypesToPrnFriendly(@prevTypesNoEmail)

	SELECT @msgResponse as msgPrevious
		  ,@valuesReturnCheck as valuesReturnCheck
		  ,@prevCaseNo as prevCaseNo
		  ,@StatusRtn as previousStatus
		  ,@updateOption as updateOption
		  ,@canUpdate as canUpdate
		  ,@prevTypesNoEmail as prevTypesNoEmail

END  
GO


