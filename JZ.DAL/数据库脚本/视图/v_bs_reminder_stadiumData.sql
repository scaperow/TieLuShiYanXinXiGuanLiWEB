USE [SYGLDB_XiCheng]
GO

/****** Object:  View [dbo].[v_bs_reminder_stadiumData]    Script Date: 2013/8/8 17:14:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







ALTER view [dbo].[v_bs_reminder_stadiumData] 
  AS
  

 

  SELECT f.id, m.������� , m.��λ���� , m.���������� ,m.�����ұ��� AS testroomcode,f.F_Name as ����,f.F_PH as ����,f.F_ZJRQ as �Ƽ�����,f.F_SJBH as �Լ����,f.F_SJSize as �Լ��ߴ�,f.F_SYXM as ������Ŀ,f.F_BGBH as ������,f.F_WTBH as ί�б��   FROM 
  dbo.sys_biz_reminder_stadiumInfo e JOIN   
  dbo.sys_biz_reminder_stadiumData f ON    f.ModelIndex=e.ID AND CAST( DATEDIFF(day, DATEADD(DAY, f.DateSpan, f.F_ZJRQ), GETDATE()) AS NVARCHAR(50)) IN (e.SearchRange) JOIN 
 dbo.v_bs_codeName m ON LEFT(f.ModelCode,16)=m.�����ұ��� 
            




GO


