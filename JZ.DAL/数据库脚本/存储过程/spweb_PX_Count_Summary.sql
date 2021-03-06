USE [SYGLDB_XiCheng]
GO
/****** Object:  StoredProcedure [dbo].[spweb_PX_Count_Summary]    Script Date: 2013/8/15 8:44:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		张宏伟
-- Create date: 2013-7-22
-- Description:	平行
-- =============================================
ALTER PROCEDURE [dbo].[spweb_PX_Count_Summary]	
AS

BEGIN

 TRUNCATE TABLE dbo.biz_px_relation_web

 INSERT dbo.biz_px_relation_web
         ( 
           SGDataID ,
           PXDataID ,
           SGTestRoomCode ,
           PXTestRoomCode ,
           PXTime 
        
         )
SELECT SGDataID ,
           PXDataID ,
           SGTestRoomCode ,
           PXTestRoomCode ,
           PXTime  FROM dbo.biz_px_relation

 DECLARE 
	@modelID varchar(50),--游标中使用
	@sqls nvarchar(4000)	
 
	DECLARE cur CURSOR FOR
  
  	SELECT DISTINCT ModelIndex FROM  sys_biz_reminder_Itemfrequency WHERE IsActive=1
  

	OPEN cur
	FETCH NEXT FROM cur INTO @modelID
	WHILE @@FETCH_STATUS = 0
	BEGIN
	 

		  
	 
	 SET @sqls='UPDATE dbo.biz_px_relation_web SET PXBGRQ=b.BGRQ,ModelIndex='''+@modelID+''' FROM dbo.biz_px_relation_web a JOIN [biz_norm_extent_'+@modelID+'] b 
	 ON a.PXDataID =b.ID   '
	 EXEC sp_executesql @sqls
   
   SET @sqls='UPDATE dbo.biz_px_relation_web SET SGBGRQ=b.BGRQ,ModelIndex='''+@modelID+''' FROM dbo.biz_px_relation_web a JOIN [biz_norm_extent_'+@modelID+'] b 
	 ON a.SGDataID =b.ID   '
	 EXEC sp_executesql @sqls
   
	   
	   FETCH NEXT FROM cur INTO  @modelID
	END

	CLOSE cur
	DEALLOCATE cur	


			
END

 



 




