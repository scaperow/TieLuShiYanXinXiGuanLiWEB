USE [SYGLDB_XiCheng]
GO
/****** Object:  StoredProcedure [dbo].[spweb_qxzlhzb_jqgrid_pop]    Script Date: 2013/8/15 8:46:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		张宏伟
-- Create date: 2013-7-4
-- Description:	全线资料列表弹出层
-- =============================================
ALTER PROCEDURE [dbo].[spweb_qxzlhzb_jqgrid_pop] 
	-- Add the parameters for the stored procedure here
	@testcode VARCHAR(50), --标准试验室id
	@ftype TINYINT, -- 频率类型1=平行，2=见证
	@startdate varchar(30),
	@enddate varchar(30),
	@modelID varchar(50)
AS
BEGIN


	 DECLARE 
 
	@sqls nvarchar(4000)

	 IF	@testcode!=''
	 BEGIN
   SET @sqls='select count(1) as zjCount,CONVERT(varchar(100), SCTS, 23) as chartDate from 

[biz_norm_extent_'+@modelID+'] a 
	   where  LEFT(SCPT,16)='''+@testcode+''' and    a.SCTS>='''+@startdate+''' AND a.SCTS<'''+@enddate+'''  GROUP BY CONVERT(varchar(100), SCTS, 23)'  

	   	  EXEC	sp_executesql @sqls   
  END   
  ELSE
  BEGIN
select '' as zjCount,'' as chartDate WHERE 1=0
  END
			
END

