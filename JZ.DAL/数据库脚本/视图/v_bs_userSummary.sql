USE [SYGLDB_XiCheng]
GO

/****** Object:  View [dbo].[v_bs_userSummary]    Script Date: 2013/8/8 17:14:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






ALTER view [dbo].[v_bs_userSummary] 
  AS
  
 select ID,
substring(SCPT,1,Len(SCPT)-4) as �����ұ���,
b.�������,
b.��λ����,
b.����������,
b.��λ����,
col_norm_D6 as '����',
col_norm_G6 as '�Ա�',
col_norm_K6 as '����',
col_norm_D7 as '����ְ��',
col_norm_G7 as 'ְ��',
col_norm_K7 as '��������',
col_norm_D9 as '��ϵ�绰',
col_norm_G8 as 'ѧ��',
col_norm_G9 as '��ҵѧУ',
col_norm_D8 as 'רҵ',
1 AS num
from 
biz_norm_������Ա���� a JOIN dbo.v_bs_codeName b ON substring(SCPT,1,Len(SCPT)-4)=b.�����ұ���





GO


