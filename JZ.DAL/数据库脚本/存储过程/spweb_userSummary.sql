USE [SYGLDB_XiCheng]
GO
/****** Object:  StoredProcedure [dbo].[spweb_userSummary]    Script Date: 2013/8/15 8:46:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		�ź�ΰ
-- Create date: 2013-7-24
-- Description:	��Ա���
-- =============================================
ALTER PROCEDURE [dbo].[spweb_userSummary]
	@testcode varchar(5000), --Ϊ��
	@ftype TINYINT, -- Ϊ��
	@startdate varchar(30),--Ϊ��
	@enddate varchar(30),--Ϊ��
	@pageSize int=10,
	@page        int, 
	@fldSort    varchar(200) = null,    ----�����ֶ��б������
	@Sort        bit = 0,    
	@pageCount    int = 1 output,           
	@Counts    int = 1 output
AS
BEGIN

		CREATE TABLE #tmp
		(
		id bigint identity(1,1)  primary key,
		userid VARCHAR(50),
		 �����ұ���  varchar(36),
		 �������  nvarchar(50),
		 ��λ����  nvarchar(50),
		 ����������  nvarchar(50),
		 ����  nvarchar(80),
		 �Ա�  nvarchar(80),
		 ����  nvarchar(80),
		 ����ְ��  nvarchar(80),
		 ְ��  nvarchar(80),
		 ��������  nvarchar(80),
		 ��ϵ�绰  nvarchar(80),
		 ѧ��  nvarchar(80),
		 ��ҵѧУ  nvarchar(80),
		 רҵ  nvarchar(80),
		num  int
		) 
		DECLARE 
	@modelID varchar(50),--�α���ʹ��
	@count INT,
	@sqls  NVARCHAR(4000)




	CREATE TABLE #t1
	(
	testcode VARCHAR(50)
	)
	IF @testcode !='' 
  
  BEGIN  
SET @sqls='INSERT #t1 ( testcode ) SELECT  DISTINCT (LEFT(NodeCode,16) )   FROM sys_engs_Tree where LEFT(NodeCode,16) IN ('+@testcode+')    ORDER BY LEFT(NodeCode,16)'

 	  EXEC	sp_executesql @sqls

	  END

		

		DECLARE cur CURSOR FOR	

 SELECT * FROM #t1

	OPEN cur
	FETCH NEXT FROM cur INTO @modelID
	WHILE @@FETCH_STATUS = 0
	BEGIN		


	SELECT @count=COUNT(*) FROM  dbo.v_bs_userSummary WHERE   �����ұ���=@modelID

	IF @count=0
	BEGIN
  INSERT #tmp
          (
		  userid,
		   �����ұ��� ,
            ������� ,
            ��λ���� ,
            ���������� ,
            ���� ,
            �Ա� ,
            ���� ,
            ����ְ�� ,
            ְ�� ,
            �������� ,
            ��ϵ�绰 ,
            ѧ�� ,
            ��ҵѧУ ,
            רҵ ,
            num
          )
		  SELECT '',�����ұ���,�������,��λ����,����������,'','','' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,0 FROM dbo.v_bs_codeName WHERE �����ұ���=@modelID
	END
  ELSE
	BEGIN
		INSERT #tmp
		        (
				userid, 
				�����ұ��� ,
		          ������� ,
		          ��λ���� ,
		          ���������� ,
		          ���� ,
		          �Ա� ,
		          ���� ,
		          ����ְ�� ,
		          ְ�� ,
		          �������� ,
		          ��ϵ�绰 ,
		          ѧ�� ,
		          ��ҵѧУ ,
		          רҵ ,
		          num
		        )
SELECT  ID,�����ұ���,�������,��λ����,����������,����,�Ա�,����,����ְ��,ְ��,��������,��ϵ�绰,ѧ��,��ҵѧУ,רҵ,1 FROM  dbo.v_bs_userSummary WHERE �����ұ���=@modelID

	END
    
 
	
	  FETCH NEXT FROM cur INTO @modelID
	END
	CLOSE cur
	DEALLOCATE cur


  declare @totalcounts int
  select @totalcounts=count(id) from #tmp

    --ȡ�÷�ҳ����

	  declare @pageIndex int --����/ҳ��С
    declare @lastcount int --����%ҳ��С  

	 set @pageIndex = @totalcounts/@pageSize
    set @lastcount = @totalcounts%@pageSize
    if @lastcount > 0
        set @pageCount = @pageIndex + 1
    else
        set @pageCount = @pageIndex 

 
	--select @Counts=count(ID) from #tmp where  id>(@pageSize*(@page-1)) and id<=(@pageSize*(@page))  

		SET @Counts=@totalcounts

	select * from #tmp where id>(@pageSize*(@page-1)) and id<=(@pageSize*@page)  

END
