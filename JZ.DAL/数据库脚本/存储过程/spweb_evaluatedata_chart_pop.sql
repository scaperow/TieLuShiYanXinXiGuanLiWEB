USE [SYGLDB_XiCheng]
GO
/****** Object:  StoredProcedure [dbo].[spweb_evaluatedata_chart_pop]    Script Date: 2013/8/15 8:43:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		�ź�ΰ
-- Create date: 2013-7-24
-- Description:	���ϸ񱨸�
-- =============================================
ALTER PROCEDURE [dbo].[spweb_evaluatedata_chart_pop]
	
	@testcode  VARCHAR(5000),
	@startdate VARCHAR(50),
	@enddate VARCHAR(50),
	@ftype TINYINT
	
AS
BEGIN

		CREATE TABLE #tmp
		(
		id bigint identity(1,1)  primary key,
		 ����������  nvarchar(50),
		 �����ұ��� NVARCHAR(50),
		 ncount INT
		 
		) 
		DECLARE 
	@code VARCHAR(50),
	@companyname VARCHAR(50),
	@num INT
 


		DECLARE cur CURSOR FOR	
SELECT �����ұ���,���������� FROM dbo.v_bs_codeName WHERE ��λ����=@testcode

	OPEN cur
	FETCH NEXT FROM cur INTO @code,@companyname
	WHILE @@FETCH_STATUS = 0
	BEGIN		
	
	SELECT @num=COUNT(*) FROM  dbo.v_bs_evaluateData WHERE   TestRoomCode=@code
	
	IF	@num=0
	BEGIN
  INSERT #tmp
        (  ����������, �����ұ���, ncount )
VALUES(@companyname,@testcode,0) 
  END  
	ELSE
  BEGIN  
INSERT #tmp
        (  ����������, �����ұ���, ncount )
SELECT  MAX(TestRoomName)  ,MAX(TestRoomCode) , COUNT(*) FROM  dbo.v_bs_evaluateData WHERE    TestRoomCode=@code
END
	
	  FETCH NEXT FROM cur INTO @code,@companyname
	END
	CLOSE cur
	DEALLOCATE cur


	SELECT ���������� AS testname, �����ұ��� AS companycode, ncount FROM  #tmp

    

END
