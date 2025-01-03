USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_ModifiedIDsReason]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [RA100].[v_op_ModifiedIDsReason] AS

SELECT  [CommentId]
      ,[QueryId]
      ,[TrlObjectTrialId]
      ,[TrlObjectSiteId]
      ,[TrlObjectPatientId]
      ,[TrlObjectVisitId]
      ,[TrlObjectFormId]
      ,[TrlObjectGroupId]
      ,[TrlObjectItemId]
      ,[ProItemId]
      ,[MsgThreadId]
      ,[MsgType]
      ,[Comment]
      ,[Response]
      ,[MsgStatus]
      ,[ThreadStatus]
      ,[Version]
      ,[GMTDateTime]
      ,[FromUserName]
      ,[FromRole]
      ,[StateChangeDateTime]
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[Comments]
  WHERE [MsgType] = 'Change'
  AND [ProItemID] = '35091'
  AND [TrlObjectPatientId] IN (SELECT [TrlObjectPatientID] FROM [Reporting].[RA100].[v_op_ModifiedIDs])
GO
