USE [SYGLDB_XiCheng]
GO
/****** Object:  StoredProcedure [dbo].[spweb_machineSummary_chart]    Script Date: 2013/8/15 8:43:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		�ź�ΰ
-- Create date: 2013-7-24
-- Description:	�豸
-- =============================================
ALTER PROCEDURE [dbo].[spweb_machineSummary_chart]
	
	@testcode  VARCHAR(5000),
	@startdate VARCHAR(50),
	@enddate VARCHAR(50),
	@ftype TINYINT
	
AS
BEGIN

		CREATE TABLE #tmp
		(
		id bigint identity(1,1)  primary key,
		����������   nvarchar(50),
		 �����ұ��� NVARCHAR(50),
		 ncount INT
		 
		) 
		DECLARE 
	@testid VARCHAR(50),
	@testname VARCHAR(50),
	@num INT,
		@sqls nvarchar(4000)
 


		DECLARE cur CURSOR FOR	
SELECT  �����ұ���, ���������� FROM dbo.v_bs_codeName  GROUP BY �����ұ���, ����������

	OPEN cur
	FETCH NEXT FROM cur INTO @testid,@testname
	WHILE @@FETCH_STATUS = 0
	BEGIN		
	
	SELECT @num=COUNT(*) FROM  dbo.v_bs_machineSummary WHERE �����ұ���=@testid
	
	IF	@num=0
	BEGIN
  INSERT #tmp
        (  ����������, �����ұ���, ncount )
VALUES(@testname,@testid,0) 
  END  
	ELSE
  BEGIN  
INSERT #tmp
        (  ����������, �����ұ���, ncount )
SELECT  MAX(����������)  ,MAX(�����ұ���) , COUNT(*) FROM  dbo.v_bs_machineSummary WHERE    �����ұ���=@testid
END
	
	  FETCH NEXT FROM cur INTO @testid,@testname
	END
	CLOSE cur
	DEALLOCATE cur

	    
IF @ftype=1
		begin
  
		  IF @testcode!=''
		  BEGIN
					SET @sqls='SELECT SUM(a.ncount) as ncount,b.��λ����  companyname,b.��λ���� AS companycode, b.������� as segment FROM  #tmp a JOIN dbo.v_bs_codeName b ON a.�����ұ��� = b.�����ұ��� WHERE a.�����ұ��� IN('+@testcode+')  GROUP BY b.��λ����,b.��λ����,b.�������'
					EXEC	sp_executesql @sqls
			END
		  ELSE
		  BEGIN
		  SELECT '' as ncount,'' as  companyname,'' AS companycode, '' as segment FROM  #tmp WHERE 1=0
		  END
    

		END   
IF @ftype=2
		begin

		IF  @testcode!=''
		  BEGIN
			 SET @sqls=' SELECT SUM(a.ncount) as ncount,b.���������� AS companyname,b.�����ұ��� AS companycode,b.������� as segment  FROM  #tmp a JOIN dbo.v_bs_codeName b ON a.�����ұ��� = b.�����ұ��� WHERE a.�����ұ��� IN('+@testcode+')  GROUP BY b.�����ұ���,b.����������,b.������� '
					 EXEC	sp_executesql @sqls
					 END
		   ELSE
		  BEGIN
		  SELECT '' as ncount,'' as  companyname,'' AS companycode, '' as segment FROM  #tmp WHERE 1=0
		  END           
		END
   ELSE
	  BEGIN
   SELECT '' as ncount,'' as  companyname,'' AS companycode, '' as segment FROM  #tmp WHERE 1=0
	  END   
 


END
