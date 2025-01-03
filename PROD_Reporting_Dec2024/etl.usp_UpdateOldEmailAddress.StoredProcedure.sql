USE [Reporting]
GO
/****** Object:  StoredProcedure [etl].[usp_UpdateOldEmailAddress]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

CREATE PROCEDURE [etl].[usp_UpdateOldEmailAddress]

(

      @OldEmailAddress      VARCHAR(100)

      , @NewEmailAddress    VARCHAR(100)

/*************************************************************

Original Author:        Brian K. McDonald, MCDBA, MCSD

Original Creation Date: 7/18/2010

 

Purpose:

      To update the SSRS.dbo.Subscriptions table with a

      new subscribers email address. This could be used when an

      employee who receives emailed documents no longer is

      employed by the company and you need it to be sent to their

      replacement. Or, perhaps maybe the company has changed their

      domain name and will no longer forward the old domain.

     

Sample Execution:

EXECUTE etl.usp_UpdateOldEmailAddress

      @OldEmailAddress = 'BrianKMcDonald@MyEmailAddress.com'

      , @NewEmailAddress = 'BMcDonald@MyNewEmailAddress.com'

**************************************************************/

)

AS

 

--Now Update them to a new user that you want to receive the subscriptions

BEGIN TRANSACTION

      UPDATE Subscriptions

            SET ExtensionSettings = CONVERT(NTEXT,REPLACE(CONVERT(VARCHAR(MAX),ExtensionSettings),@OldEmailAddress,@NewEmailAddress))
			--		select * 
        FROM SSRS.dbo.Subscriptions

        WHERE CONVERT(VARCHAR(MAX),ExtensionSettings) LIKE '%' + CONVERT(VARCHAR(100),@OldEmailAddress) + '%'

COMMIT TRANSACTION

 

--OPTIONAL: Now just return a listing of those records that were updated

SELECT * FROM SSRS.dbo.[Subscriptions]

WHERE CONVERT(VARCHAR(MAX),ExtensionSettings) LIKE '%' + CONVERT(VARCHAR(100),@NewEmailAddress) + '%'
GO
