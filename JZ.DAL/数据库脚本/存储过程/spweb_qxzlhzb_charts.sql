USE [SYGLDB_XiCheng]
GO
/****** Object:  StoredProcedure [dbo].[spweb_qxzlhzb_charts]    Script Date: 2013/8/15 8:45:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		�ź�ΰ
-- Create date: 2013-7-22
-- Description:	ȫ�����ϻ��ܱ�
-- =============================================
ALTER PROCEDURE [dbo].[spweb_qxzlhzb_charts]
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
 
 CREATE TABLE #t1
 (
 modelID VARCHAR(50),
 NodeCode VARCHAR(50)
 )

  IF @testcode!='' 
  BEGIN
			SET @sqls='INSERT #t1 ( modelID, NodeCode ) SELECT  DISTINCT b.ID AS modelID,LEFT(a.NodeCode,16) NodeCode   FROM sys_engs_Tree  a JOIN sys_biz_module b ON a.RalationID=b.ID  AND LEFT(a.NodeCode,16) IN ('+@testcode+')  ORDER BY LEFT(a.NodeCode,16)'
		 EXEC	sp_executesql @sqls
	END
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


 SELECT b.��������,b.�������,b.��λ����,b.����������,a.modelid,a.ncount,b.�����ұ���,b.��λ���� INTO #t2 FROM #tmp a JOIN dbo.v_bs_codeName b ON 

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
companycode VARCHAR(50),
ncount int
 )
 

 insert into #tmp1
 ( project,segment,company,testroom,testname,testcode,companycode,ncount)
SELECT a.��������,a.�������,a.��λ����,a.����������,b.Description,a.�����ұ���,a.��λ����,a.ncount  FROM #t2 a JOIN dbo.sys_biz_Module b ON 

a.modelid=b.ID AND a.ncount>0   order by a.�������, a.��λ����,a.���������� 



  /*��û�е����������0ֵ*/


 CREATE TABLE #t5
 (
 NodeCode VARCHAR(50)
 )
	 
	 IF @testcode!='' 
  BEGIN
	SET @sqls=' INSERT #t5 (  NodeCode ) SELECT  DISTINCT LEFT(a.NodeCode,16) NodeCode   FROM sys_engs_Tree  a  WHERE LEFT(a.NodeCode,16) IN ('+@testcode+') ORDER BY LEFT(a.NodeCode,16) '
  EXEC	sp_executesql @sqls
  END   

 


 INSERT #tmp1
         ( 
           project ,
           segment ,
           company ,
           testroom ,
           testname ,
           testcode ,
           companycode ,
           ncount
         )
 SELECT ��������,�������,��λ����,����������,'', �����ұ���, ��λ����,0  FROM #t5 a JOIN dbo.v_bs_codeName b ON a.NodeCode=b.�����ұ��� WHERE a.NodeCode NOT IN (SELECT testcode FROM #tmp1)


   /*��û�е����������0ֵ*/



   
 create table #tmp2
 (
id bigint identity(1,1)  primary key,
project varchar(50),
segment varchar(50),
company varchar(50),
testroom varchar(50),
testname varchar(50),
testcode varchar(50),
companycode VARCHAR(50),
ncount int
 )


 INSERT #tmp2
         (
           project ,
           segment ,
           company ,
           testroom ,
           testname ,
           testcode ,
           companycode ,
           ncount
         )


SELECT  project ,
           segment ,
           company ,
           testroom ,
           testname ,
           testcode ,
           companycode ,
           ncount FROM #tmp1 ORDER BY project,segment,company
  
IF @ftype=1
begin
  select MAX(segment) segment,MAX(company) company,MAX(testroom) testroom,sum(ncount) ncount,max(testcode) testcode, companycode  from #tmp2  group by companycode
END
IF @ftype=2
begin
   select MAX(segment) segment,MAX(company) company,MAX(testroom) testroom,sum(ncount) ncount,max(companycode) companycode, testcode  from #tmp2  group by testcode
END
ELSE
BEGIN
SELECT '' AS   segment,'' AS company,'' AS testroom,'' AS ncount,'' AS testcode,'' AS companycode   WHERE 1=0
END
  --select  segment, company, testroom, ncount,testcode, companycode  from #tmp1  
			
END

 



 




