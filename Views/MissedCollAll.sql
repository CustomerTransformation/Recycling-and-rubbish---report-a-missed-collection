USE [FStepRubbishRecycling_prod]
GO

/****** Object:  View [dbo].[MissedCollAll]    Script Date: 28/03/2022 08:26:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[MissedCollAll]
AS
SELECT        rp.CaseNo, ISNULL(rp.Contact, 'no data') AS MissedColl, ISNULL(rp.Email, 'no data') AS Email, rp.SelfDash AS [Source System], ISNULL(rp.Address, 'no data') AS Address, ISNULL(rp.Postcode, 'no data') AS Postcode, 
                         ISNULL(rp.UPRN, 'no data') AS UPRN, ISNULL(rp.RefuseCrew, 'no data') AS RefuseCrew, ISNULL(rp.RecyclingCrew, 'no data') AS RecyclingCrew, ISNULL(jb.ColType, 'no data') AS [Waste Type], jb.MissedDate AS [Missed date], 
                         ISNULL(jb.Rep_Prev_missed, 'no data') AS [Report of previous miss], ISNULL(jb.TimeOut, 'no data') AS [Time put out], ISNULL(jb.Usual, 'no data') AS [Was it in the usual place?], ISNULL(jb.Overflowing, 'no data') 
                         AS [Is the communal bin overflowing?], ISNULL(jb.Req_Auth, 'no data') AS Req_Auth, ISNULL(jb.Auth_out, 'no data') AS [PCC Authorisation outcome], ISNULL(jb.Collection, 'no data') AS [Collection Complete?], 
                         ISNULL(jb.IncompleteOut, 'no data') AS [PCC Decision of Incomplete Collection], ISNULL(jb.Enq_by, 'no data') AS [Enquiry raiser], dbo.DTtoDate(jb.Enq_date) AS [Enquiry date], dbo.DTtoTime(jb.Enq_date) AS [Enquiry time], 
                         ISNULL(jb.Auth_by, 'no data') AS [PCC Authoriser], dbo.DTtoDate(jb.Auth_date) AS [Date of Authorisation], dbo.DTtoTime(jb.Auth_date) AS [Time of Authorisation], ISNULL(jb.Col_by, 'no data') AS [Collected by], 
                         dbo.DTtoDate(jb.Col_date) AS [Collection date], dbo.DTtoTime(jb.Col_date) AS [Collection time], ISNULL(jb.Incom_by, 'no data') AS [PCC Decision on incomplete by], dbo.DTtoDate(jb.Incom_date) 
                         AS [Date of decision on incomplete], dbo.DTtoTime(jb.Incom_date) AS [Time of decision on incomplete], dbo.MissedTimeToComplete(jb.RR_ID_J) AS [End to End time]
FROM            dbo.MissedColl AS rp INNER JOIN
                         dbo.MissedCollJobs AS jb ON rp.CaseNo = jb.CaseNo
GO


