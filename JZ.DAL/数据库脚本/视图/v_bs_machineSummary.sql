USE [SYGLDB_XiCheng]
GO

/****** Object:  View [dbo].[v_bs_machineSummary]    Script Date: 2013/8/8 17:14:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







ALTER view [dbo].[v_bs_machineSummary] 
  AS
  


select
ID,
substring(SCPT,1,Len(SCPT)-4) as �����ұ���,
����������,
��λ����,
��λ����,
������,
�������,
��α���,
�豸����,
��������,
����ͺ�,
��������,
����,
��ע
from [biz_norm_�������豸�б�]  a JOIN dbo.v_bs_codeName b ON substring(SCPT,1,Len(SCPT)-4)=b.�����ұ���
where ������ is not null or �豸���� is not null




GO


