USE [SYGLDB_XiCheng]
GO
/****** Object:  StoredProcedure [dbo].[spweb_qxzlhzb]    Script Date: 2013/8/15 8:45:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		�ź�ΰ
-- Create date: 2013-7-22
-- Description:	ȫ�����ϻ��ܱ�
-- =============================================
ALTER PROCEDURE [dbo].[spweb_qxzlhzb]
	-- Add the parameters for the stored procedure here	
	@testcode  VARCHAR(5000),
	@ftype TINYINT,--û���κ�����Ϊ���ܺ�ƽ�м�֤ʹ��ͬһ�������ؼ���һ������
	@startdate VARCHAR(50),
	@enddate VARCHAR(50),
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
	SET @sqls=' INSERT #t1 ( modelID, NodeCode ) SELECT  DISTINCT b.ID AS modelID,LEFT(a.NodeCode,16) NodeCode   FROM sys_engs_Tree  a JOIN sys_biz_module b ON a.RalationID=b.ID WHERE LEFT(a.NodeCode,16) IN ('+@testcode+') ORDER BY LEFT(a.NodeCode,16) '
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


 SELECT b.��������,b.�������,b.��λ����,b.����������,a.modelid,a.ncount,b.�����ұ��� AS testcode INTO #t2 FROM #tmp a JOIN dbo.v_bs_codeName b ON 

a.testroomid=b.�����ұ���



 

 create table #tmp1
 (
id bigint identity(1,1)  primary key,
project varchar(50),
segment varchar(50),
company varchar(50),
testroom varchar(50),
testname varchar(50),
ncount INT,
testcode VARCHAR(50),
modelid VARCHAR(50)
 )


  

   insert into #tmp1
 ( project,segment,company,testroom,testname,ncount,testcode,modelid)
SELECT a.��������,a.�������,a.��λ����,a.����������,b.Description,a.ncount,a.testcode,a.modelid FROM #t2 a JOIN dbo.sys_biz_Module b ON 

a.modelid=b.ID AND a.ncount>0   order by a.��λ����


  /*��û�е����������0ֵ*/


 CREATE TABLE #t5
 (
 NodeCode VARCHAR(50)
 )
	 
IF	@testcode!=''

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
          ncount,
		  testcode,
		  modelid
        )
 SELECT ��������,�������,��λ����,����������,'',0,�����ұ���,''  FROM #t5 a JOIN dbo.v_bs_codeName b ON a.NodeCode=b.�����ұ��� WHERE a.NodeCode NOT IN (SELECT testcode FROM #tmp1)


   /*��û�е����������0ֵ*/


  create table #tmp2
 (
id bigint identity(1,1)  primary key,
project varchar(50),
segment varchar(50),
company varchar(50),
testroom varchar(50),
testname varchar(50),
ncount INT,
testcode VARCHAR(50),
modelid VARCHAR(50)
 )


 INSERT #tmp2
         ( 
           project ,
           segment ,
           company ,
           testroom ,
           testname ,
           ncount,
		   testcode,
		   modelid
         )
SELECT project,segment,company,testroom,testname,ncount,testcode,modelid FROM  #tmp1  ORDER BY project,segment,company,testroom


 


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

 
	--select @Counts=count(ID) from #tmp2 where id>(@pageSize*(@page-1)) and id<=(@pageSize*(@page))  

	SET @Counts=@totalcounts

	select * from #tmp2 where id>(@pageSize*(@page-1)) and id<=(@pageSize*(@page))  
			
END



 



