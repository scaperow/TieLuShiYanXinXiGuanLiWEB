USE [SYGLDB_XiCheng]
GO
/****** Object:  StoredProcedure [dbo].[spweb_pxjzReport]    Script Date: 2013/8/15 8:45:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		�ź�ΰ
-- Create date: 2013-7-24
-- Description:	��ȡƽ�С���֤�ı���
-- =============================================
ALTER PROCEDURE [dbo].[spweb_pxjzReport]
	@testcode varchar(5000), --��Ȩ�޵�������id����
	@ftype TINYINT, -- Ƶ������1=ƽ�У�2=��֤
	@startdate varchar(30),
	@enddate varchar(30),
	@pageSize int=10,
	@page        int, 
	@fldSort    varchar(200) = null,    ----�����ֶ��б������
	@Sort        bit = 0,    
	@pageCount    int = 1 output,           
	@Counts    int = 1 output
AS
BEGIN

 	CREATE TABLE #tmp1
	(
	id bigint identity(1,1)  primary key,
	modelName NVARCHAR(50),
	condition FLOAT,
	zjCount FLOAT,
	pxCount FLOAT,
	frequency FLOAT,
	result VARCHAR(10),
	segment VARCHAR(100),
	jl VARCHAR(100),
	sg VARCHAR(100),
	testroom VARCHAR(100),
	modelID NVARCHAR(50),
	testroomID NVARCHAR(50),
	pxqulifty FLOAT
	)
 


	SELECT ModelIndex,MAX(ModelName) ModelName ,TestRoomCode,SUM(ZjCount) ZjCount,SUM(JzCount) JzCount,MAX(JLCompanyName) JLCompanyName INTO #t1 FROM biz_ZJ_JZ_Summary  WHERE BGRQ>@startdate AND BGRQ<@enddate GROUP BY TestRoomCode,ModelIndex



INSERT #tmp1
        ( 
          modelName ,
          zjCount ,
          pxCount ,
          jl ,
          modelID ,
          testroomID 
        )	
 SELECT ModelName,ZjCount, dbo.Fweb_ReturnPXCount(ModelIndex,TestRoomCode,@startdate,@enddate),JLCompanyName,ModelIndex,TestRoomCode FROM #t1

 
 
	 SELECT  
           a.modelName ,
             condition ,
           zjCount ,
           pxCount ,
          ROUND((pxCount/zjCount),2) AS frequency ,
           result ,
           b.������� segment ,
           jl ,
           b.��λ���� sg ,
           b.���������� testroom ,
           modelID ,
           a.testroomID ,
           pxqulifty INTO #t3 FROM #tmp1 a JOIN dbo.v_bs_codeName b
		   ON a.testroomID=b.�����ұ���
		     ORDER BY segment,sg,testroom



		   TRUNCATE TABLE #tmp1
		   INSERT #tmp1
		           ( 
		             modelName ,
		             condition ,
		             zjCount ,
		             pxCount ,
		             frequency ,
		             result ,
		             segment ,
		             jl ,
		             sg ,
		             testroom ,
		             modelID ,
		             testroomID ,
		             pxqulifty
		           )SELECT * FROM #t3


	 UPDATE #tmp1 SET condition=(b.Frequency*100) FROM #tmp1 a JOIN sys_biz_reminder_Itemfrequency b
			 ON a.modelID=b.ModelIndex AND a.testroomID=b.TestRoomCode AND b.IsActive=1  


    --ȡ�÷�ҳ����
  declare @totalcounts int
  select @totalcounts=count(ID) from #tmp1
	  declare @pageIndex int --����/ҳ��С
    declare @lastcount int --����%ҳ��С  

	 set @pageIndex = @totalcounts/@pageSize
    set @lastcount = @totalcounts%@pageSize
    if @lastcount > 0
        set @pageCount = @pageIndex + 1
    else
        set @pageCount = @pageIndex 


		SET @Counts=@totalcounts
	SELECT id, modelName ,
		             condition ,
		             zjCount ,
		             pxCount ,
		             frequency ,
		             result ,
		             segment ,
		             jl ,
		             sg ,
		             testroom ,
		             modelID ,
		             testroomID ,
		             dbo.Fweb_ReturnPXQualityCount(modelID,testroomID,@startdate,@enddate) pxqulifty from #tmp1  	
	 where id>(@pageSize*(@page-1)) and id<=(@pageSize*@page)   
 
    
END





