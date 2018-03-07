USE [SYGLDB_XiCheng]
GO

/****** Object:  View [dbo].[v_bs_codeName]    Script Date: 2013/8/8 17:14:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER view [dbo].[v_bs_codeName] 
  AS
  
  select 
c.���̱���,
c.��������,
d.��α���,
d.�������,
e.��λ����,
e.��λ����,
f.�����ұ���,
f.����������
from 
(select a.NodeCode as '���̱���',b.Description as '��������' from sys_engs_Tree as a,sys_engs_ProjectInfo as b where a.RalationID = b.ID) as c,
(select a.NodeCode as '��α���',b.Description as '�������' from sys_engs_Tree as a,sys_engs_SectionInfo as b where a.RalationID = b.ID) as d,
(select a.NodeCode as '��λ����',b.Description  as '��λ����' from sys_engs_Tree as a,sys_engs_CompanyInfo as b where a.RalationID = b.ID) as e,
(select a.NodeCode as '�����ұ���',b.Description as '����������' from sys_engs_Tree as a,sys_engs_ItemInfo as b where a.RalationID = b.ID) as f
where 
substring(f.�����ұ���,1,4) = c.���̱��� and 
substring(f.�����ұ���,1,8) = d.��α��� and 
substring(f.�����ұ���,1,12) = e.��λ����



GO


