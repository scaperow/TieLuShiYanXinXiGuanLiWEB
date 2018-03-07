USE [SYGLDB_XiCheng]
GO
/****** Object:  StoredProcedure [dbo].[spweb_userSummary_chart]    Script Date: 2013/8/15 8:47:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		�ź�ΰ
-- Create date: 2013-7-24
-- Description:	��Ա���
-- =============================================
ALTER PROCEDURE [dbo].[spweb_userSummary_chart]
	
	@testcode  VARCHAR(5000),
	@startdate VARCHAR(50),
	@enddate VARCHAR(50),
	@ftype TINYINT
	
	
AS
BEGIN

		CREATE TABLE #tmp
		(
		id bigint identity(1,1)  primary key,
		 ��λ����  nvarchar(50),
		 ��λ���� NVARCHAR(50),
		 ncount INT
		 
		) 
		DECLARE 
	@code VARCHAR(50),
	@companyname VARCHAR(50),
	@num INT,
	@sqls nvarchar(4000)
 

	CREATE TABLE #t1
	(
	testcode VARCHAR(50)
	)
	IF @testcode !='' 
  
  BEGIN  
SET @sqls='INSERT #t1 ( testcode ) SELECT  DISTINCT (LEFT(NodeCode,12) )   FROM sys_engs_Tree where LEFT(NodeCode,16) IN ('+@testcode+')    Group BY LEFT(NodeCode,12)'

 	  EXEC	sp_executesql @sqls

	  END

		DECLARE cur CURSOR FOR	


SELECT  ��λ����,��λ���� FROM #t1 a JOIN dbo.v_bs_codeName b ON a.testcode=��λ����  GROUP BY  ��λ����,��λ����

	OPEN cur
	FETCH NEXT FROM cur INTO @code,@companyname
	WHILE @@FETCH_STATUS = 0
	BEGIN		
	
	SELECT @num=COUNT(*) FROM  dbo.v_bs_userSummary WHERE ��λ����=@code
	
	IF	@num=0
	BEGIN
  INSERT #tmp
        (  ��λ����, ��λ����, ncount )
VALUES(@companyname,@code,0) 
  END  
	ELSE
  BEGIN  
INSERT #tmp
        (  ��λ����, ��λ����, ncount )
SELECT  MAX(��λ����)  ,MAX(��λ����) , COUNT(*) FROM  dbo.v_bs_userSummary WHERE    ��λ����=@code
END
	
	  FETCH NEXT FROM cur INTO @code,@companyname
	END
	CLOSE cur
	DEALLOCATE cur


	SELECT ��λ���� AS companyname, ��λ���� AS companycode, ncount FROM  #tmp



END



