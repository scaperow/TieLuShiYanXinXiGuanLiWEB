USE [SYGLDB_XiCheng]
GO
/****** Object:  UserDefinedFunction [dbo].[Fweb_ReturnPXCount]    Script Date: 2013/8/15 8:41:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER FUNCTION [dbo].[Fweb_ReturnPXCount]
 (
     @ModelIndex VARCHAR(50),
	 @SGRoomCode VARCHAR(50),
	 @StartDate DATETIME,
	 @EndDate DATETIME
    )

	RETURNS INT
	BEGIN
  
		DECLARE @count INT  


 SELECT @count=COUNT(1) FROM dbo.biz_px_relation_web WHERE
  ModelIndex=@ModelIndex
   AND  LEFT(SGTestRoomCode,16)=@SGRoomCode
   AND   SGBGRQ>@StartDate 
   AND   SGBGRQ<@EndDate 
   AND  PXBGRQ>@StartDate 
   AND  PXBGRQ<@EndDate 
  

		RETURN @count
	END
    