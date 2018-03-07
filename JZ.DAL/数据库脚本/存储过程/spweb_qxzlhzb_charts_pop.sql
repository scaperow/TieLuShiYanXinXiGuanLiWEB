USE [SYGLDB_XiCheng]
GO
/****** Object:  StoredProcedure [dbo].[spweb_qxzlhzb_charts_pop]    Script Date: 2013/8/15 8:46:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		�ź�ΰ
-- Create date: 2013-7-22
-- Description:	ȫ�����ϻ��ܱ�
-- =============================================
ALTER PROCEDURE [dbo].[spweb_qxzlhzb_charts_pop]
	@testcode  VARCHAR(5000),
	@startdate VARCHAR(50),
	@enddate VARCHAR(50),
	@ftype TINYINT
AS

BEGIN

 

	CREATE TABLE #tmp
	(	
	ncount INT,
	testroomid VARCHAR(100),
	modelid NVARCHAR(100)	
	)
 
 DECLARE 
	@modelID varchar(50),--�α���ʹ��
	@testroomid VARCHAR(50),
	@sqls nvarchar(4000)	
 
	 
		SELECT  DISTINCT b.ID AS modelID,LEFT(a.NodeCode,16) NodeCode  INTO #t1 FROM sys_engs_Tree  a JOIN 

sys_biz_module b ON a.RalationID=b.ID ORDER BY LEFT(a.NodeCode,16)
	
	DECLARE cur CURSOR FOR
	

 	SELECT * FROM #t1

	OPEN cur
	FETCH NEXT FROM cur INTO @modelID,@testroomid
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
	   SET @sqls='select count(1) as count,'''+@testroomid+''' as testroomid,'''+@modelID+''' modelid  from 

[biz_norm_extent_'+@modelID+'] a 
	   where  LEFT(SCPT,16)='''+@testroomid+''' and    a.SCTS>='''+@startdate+''' AND a.SCTS<'''+@enddate+''''  

	INSERT #tmp
	        ( ncount, testroomid, modelid )
			  EXEC	sp_executesql @sqls
			    
	   
	   FETCH NEXT FROM cur INTO  @modelID,@testroomid
	END

	CLOSE cur
	DEALLOCATE cur	


 SELECT b.��������,b.�������,b.��λ����,b.����������,a.modelid,a.ncount,b.�����ұ��� INTO #t2 FROM #tmp a JOIN dbo.v_bs_codeName b ON 

a.testroomid=b.�����ұ���



 create table #tmp1
 (
id bigint identity(1,1)  primary key,
project varchar(50),
segment varchar(50),
company varchar(50),
testroom varchar(50),
testname varchar(50),
testcode varchar(50),
ncount INT,
modelid VARCHAR(50)
 )
 

 insert into #tmp1
 ( project,segment,company,testroom,testname,testcode,ncount,modelid)
SELECT a.��������,a.�������,a.��λ����,a.����������,b.Description,a.�����ұ���,a.ncount,a.modelid  FROM #t2 a JOIN dbo.sys_biz_Module b ON 

a.modelid=b.ID AND a.ncount>0   order by a.�������, a.��λ����,a.���������� 
  
  SELECT MAX(project) project,MAX(segment) segment,MAX(company) company, testname,SUM(ncount) ncount,modelid from #tmp1  where testcode LIKE ''+@testcode+'%'  GROUP BY testname,modelid


			
END

 



 




