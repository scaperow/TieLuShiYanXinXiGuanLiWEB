USE [SYGLDB_XiCheng]
GO
/****** Object:  StoredProcedure [dbo].[spweb_qxzlhzb_charts_pop_grid]    Script Date: 2013/8/15 8:46:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		�ź�ΰ
-- Create date: 2013-7-22
-- Description:	ȫ�����ϻ��ܱ�
-- =============================================
ALTER PROCEDURE [dbo].[spweb_qxzlhzb_charts_pop_grid]
	@testcode  VARCHAR(5000),
	@startdate VARCHAR(50),
	@enddate VARCHAR(50),
	@ftype TINYINT,
	@modelID VARCHAR(50),
	@pageSize int=10,
	@page        int, 
	@fldSort    varchar(200) = null,    ----�����ֶ��б������
	@Sort        bit = 0,    
	@pageCount    int = 0 output,           
	@Counts    int = 0 output
AS

BEGIN

 

	CREATE TABLE #tmp
	(	
	DataName VARCHAR(500),
	SCTS DATETIME,
	testroomid VARCHAR(100),
	modelid NVARCHAR(100)	
	)
 
 DECLARE 
	@sqls nvarchar(4000)	
 
	 
		SELECT  DISTINCT b.ID AS modelID,LEFT(a.NodeCode,16) NodeCode  INTO #t1 FROM sys_engs_Tree  a JOIN 

sys_biz_module b ON a.RalationID=b.ID ORDER BY LEFT(a.NodeCode,16)


		
	 IF	@testcode!=''

	 BEGIN
  
    SET @sqls='select DataName,SCTS, LEFT(SCPT,16) as testroomid,'''+@modelID+''' modelid  from 

[biz_norm_extent_'+@modelID+'] a 
	   where  LEFT(SCPT,16) in (SELECT NodeCode FROM #t1) and    a.SCTS>='''+@startdate+''' AND a.SCTS<'''+@enddate+''''  

	INSERT #tmp
	        ( DataName,SCTS, testroomid, modelid )
			  EXEC	sp_executesql @sqls
     
  END   
			    



 SELECT b.��������,b.�������,b.��λ����,b.����������,a.modelid,a.DataName,a.SCTS,b.�����ұ��� INTO #t2 FROM #tmp a JOIN dbo.v_bs_codeName b ON 

a.testroomid=b.�����ұ���



 create table #tmp1
 (
id bigint identity(1,1)  primary key,
project varchar(50),
segment varchar(50),
company varchar(50),
testroom varchar(50),
testcode varchar(50),
testname VARCHAR(500),
DataName VARCHAR(500),
SCTS DATETIME,
modelid VARCHAR(50)
 )
 

 

 insert into #tmp1
 ( project ,
           segment ,
           company ,
           testroom ,
           testcode ,
		   testname,
           DataName ,
           SCTS ,
           modelid)
SELECT a.��������,a.�������,a.��λ����,a.����������,a.�����ұ���,b.Description,a.DataName,a.SCTS,a.modelid  FROM #t2 a JOIN dbo.sys_biz_Module b ON 

a.modelid=b.ID   order by a.�������, a.��λ����,a.���������� 
  



 create table #tmp2
 (
id bigint identity(1,1)  primary key,
project varchar(50),
segment varchar(50),
company varchar(50),
testroom varchar(50),
testcode varchar(50),
testname VARCHAR(500),
DataName VARCHAR(500),
SCTS DATETIME,
modelid VARCHAR(50)
 )

 INSERT #tmp2
         (  
           project ,
           segment ,
           company ,
           testroom ,
           testcode ,
           testname ,
           DataName ,
           SCTS ,
           modelid
         )
  select project ,
           segment ,
           company ,
           testroom ,
           testcode ,
		   testname,
           DataName ,
           SCTS ,
           modelid from #tmp1  where testcode LIKE ''+@testcode+'%' order by project,segment,company,testroom

		   
  declare @totalcounts int
  select @totalcounts=count(ID) from #tmp2

    --ȡ�÷�ҳ����

	  declare @pageIndex INT --����/ҳ��С
    declare @lastcount INT --����%ҳ��С  


	SET @pageIndex=0
	SET @lastcount=0

	 set @pageIndex = @totalcounts/@pageSize
    set @lastcount = @totalcounts%@pageSize
    if @lastcount > 0
        set @pageCount = @pageIndex + 1
    else
        set @pageCount = @pageIndex 

 
	--select @Counts=count(ID) from #tmp2 where  id>(@pageSize*(@page-1)) and id<=(@pageSize*(@page))  
		SET @Counts=@totalcounts

	select * from #tmp2 where id>(@pageSize*(@page-1)) and id<=(@pageSize*(@page))  



			
END

 



 




