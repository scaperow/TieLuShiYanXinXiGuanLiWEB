USE [SYGLDB_XiCheng]
GO
/****** Object:  StoredProcedure [dbo].[spweb_userSummary_chart_pop]    Script Date: 2013/8/15 8:47:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		�ź�ΰ
-- Create date: 2013-7-24
-- Description:	��Ա���
-- =============================================
ALTER PROCEDURE [dbo].[spweb_userSummary_chart_pop]
	
	@testcode  VARCHAR(5000),
	@startdate VARCHAR(50),
	@enddate VARCHAR(50),
	@ftype TINYINT
	
AS
BEGIN

		CREATE TABLE #tmp
		(
		id bigint identity(1,1)  primary key,
		 testname  nvarchar(50),
		 Testcode NVARCHAR(50),
		 Companycode NVARCHAR(50),
		 company NVARCHAR(50),
		 ncount INT
		 
		) 
 
 IF	@ftype=1  --�����������ҷ���ͳ��
 BEGIN
 
		 INSERT #tmp
				 ( 
				   testname ,
				   Testcode ,
				   Companycode ,
				   company,
				   ncount
				 )
		 SELECT MAX(����������), �����ұ���,MAX(��λ����),MAX(��λ����),COUNT(1) FROM dbo.v_bs_userSummary WHERE ��λ����=@testcode  GROUP BY  �����ұ���
 END
 
  IF	@ftype=2  --������ְ�Ʒ���ͳ��
 BEGIN
 
		 INSERT #tmp
				 ( 
				   testname ,
				   Testcode ,
				   Companycode ,
				   company,
				   ncount
				 )
		 SELECT ����ְ��, MAX(�����ұ���),MAX(��λ����),MAX(��λ����),COUNT(1) FROM dbo.v_bs_userSummary WHERE ��λ����=@testcode  GROUP BY  ����ְ��
 END
 
   IF	@ftype=3  --������ѧ������ͳ��
 BEGIN
 
		 INSERT #tmp
				 ( 
				   testname ,
				   Testcode ,
				   Companycode ,
				   company,
				   ncount
				 )
		 SELECT ѧ��, MAX(�����ұ���),MAX(��λ����),MAX(��λ����),COUNT(1) FROM dbo.v_bs_userSummary WHERE ��λ����=@testcode  GROUP BY  ѧ��
 END
 
    IF	@ftype=4  --�����ǹ������޷���ͳ��
 BEGIN
 
		 INSERT #tmp
				 ( 
				   testname ,
				   Testcode ,
				   Companycode ,
				   company,
				   ncount
				 )
		 SELECT REPLACE(��������,'��','')+'��', MAX(�����ұ���),MAX(��λ����),MAX(��λ����),COUNT(1) FROM dbo.v_bs_userSummary WHERE ��λ����=@testcode  GROUP BY  REPLACE(��������,'��','')
 END

	SELECT * FROM #tmp
END
