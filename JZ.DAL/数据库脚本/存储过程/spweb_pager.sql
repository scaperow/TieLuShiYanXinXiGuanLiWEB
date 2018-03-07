USE [SYGLDB_XiCheng]
GO
/****** Object:  StoredProcedure [dbo].[spweb_pager]    Script Date: 2013/8/15 8:44:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[spweb_pager]
(
@tblName     nvarchar(200),        ----Ҫ��ʾ�ı�����������
@fldName     nvarchar(500) = '*',    ----Ҫ��ʾ���ֶ��б�
@pageSize    int = 1,        ----ÿҳ��ʾ�ļ�¼����
@page        int = 10,        ----Ҫ��ʾ��һҳ�ļ�¼
@pageCount    int = 1 output,            ----��ѯ�����ҳ�����ҳ��
@Counts    int = 1 output,                ----��ѯ���ļ�¼��
@fldSort    nvarchar(200) = null,    ----�����ֶ��б������
@Sort        bit = 1,        ----���򷽷���0Ϊ����1Ϊ����(����Ƕ��ֶ�����Sortָ�����һ�������ֶε�����˳��(���һ�������ֶβ���������)--���򴫲��磺' SortA Asc,SortB Desc,SortC ')
@strCondition    nvarchar(4000) = null,    ----��ѯ����,����where
@ID        nvarchar(150),        ----���������
@Dist                 bit = 0           ----�Ƿ���Ӳ�ѯ�ֶε� DISTINCT Ĭ��0�����/1���
)
AS
SET NOCOUNT ON
Declare @sqlTmp nvarchar(1000)        ----��Ŷ�̬���ɵ�SQL���
Declare @strTmp nvarchar(1000)        ----���ȡ�ò�ѯ��������Ĳ�ѯ���
Declare @strID     nvarchar(1000)        ----���ȡ�ò�ѯ��ͷ���βID�Ĳ�ѯ���

Declare @strSortType nvarchar(10)    ----�����������A
Declare @strFSortType nvarchar(10)    ----�����������B

Declare @SqlSelect nvarchar(50)         ----�Ժ���DISTINCT�Ĳ�ѯ����SQL����
Declare @SqlCounts nvarchar(50)          ----�Ժ���DISTINCT��������ѯ����SQL����


if @Dist  = 0
begin
    set @SqlSelect = 'select '
    set @SqlCounts = 'Count(*)'
end
else
begin
    set @SqlSelect = 'select distinct '
    set @SqlCounts = 'Count(DISTINCT '+@ID+')'
end


if @Sort=0
begin
    set @strFSortType=' ASC '
    set @strSortType=' DESC '
end
else
begin
    set @strFSortType=' DESC '
    set @strSortType=' ASC '
end

 

--------���ɲ�ѯ���--------
--�˴�@strTmpΪȡ�ò�ѯ������������
if @strCondition is null or @strCondition=''     --û��������ʾ����
begin
    set @sqlTmp =  @fldName + ' From ' + @tblName
    set @strTmp = @SqlSelect+' @Counts='+@SqlCounts+' FROM '+@tblName
    set @strID = ' From ' + @tblName
end
else
begin
    set @sqlTmp = + @fldName + 'From ' + @tblName + ' where (1>0) ' + @strCondition
    set @strTmp = @SqlSelect+' @Counts='+@SqlCounts+' FROM '+@tblName + ' where (1>0) ' + @strCondition
    set @strID = ' From ' + @tblName + ' where (1>0) ' + @strCondition
end

----ȡ�ò�ѯ���������-----
exec sp_executesql @strTmp,N'@Counts int out ',@Counts out
declare @tmpCounts int
if @Counts = 0
    set @tmpCounts = 1
else
    set @tmpCounts = @Counts

    --ȡ�÷�ҳ����
    set @pageCount=(@tmpCounts+@pageSize-1)/@pageSize

    /**//**��ǰҳ������ҳ�� ȡ���һҳ**/
    if @page>@pageCount
        set @page=@pageCount

    --/*-----���ݷ�ҳ2�ִ���-------*/
    declare @pageIndex int --����/ҳ��С
    declare @lastcount int --����%ҳ��С 

    set @pageIndex = @tmpCounts/@pageSize
    set @lastcount = @tmpCounts%@pageSize
    if @lastcount > 0
        set @pageIndex = @pageIndex + 1
    else
        set @lastcount = @pagesize
 --//***��ʾ��ҳ
    if @strCondition is null or @strCondition=''     --û��������ʾ����
    begin
        if @pageIndex<2 or @page<=@pageIndex / 2 + @pageIndex % 2   --ǰ�벿�����ݴ���
            begin 
                set @strTmp=@SqlSelect+' top '+ CAST(@pageSize as VARCHAR(4))+' '+ @fldName+' from '+@tblName
                        +' where '+@ID+' not in('+ @SqlSelect+' top '+ CAST(@pageSize*(@page-1) as Varchar(20)) +' '+ @ID +' from '+@tblName
                        +' order by '+ @fldSort +' '+ @strFSortType+')'
                        +' order by '+ @fldSort +' '+ @strFSortType 
            end
        else
            begin
            set @page = @pageIndex-@page+1 --��벿�����ݴ���
                if @page <= 1 --���һҳ������ʾ
                    set @strTmp=@SqlSelect+' * from ('+@SqlSelect+' top '+ CAST(@lastcount as VARCHAR(4))+' '+ @fldName+' from '+@tblName
                        +' order by '+ @fldSort +' '+ @strSortType+') AS TempTB'+' order by '+ @fldSort +' '+ @strFSortType 
                else                
                    set @strTmp=@SqlSelect+' * from ('+@SqlSelect+' top '+ CAST(@pageSize as VARCHAR(4))+' '+ @fldName+' from '+@tblName
                        +' where '+@ID+' not in('+ @SqlSelect+' top '+ CAST(@pageSize*(@page-2)+@lastcount as Varchar(20)) +' '+ @ID +' from '+@tblName
                        +' order by '+ @fldSort +' '+ @strSortType+')'

                        +' order by '+ @fldSort +' '+ @strSortType+') AS TempTB'+' order by '+ @fldSort +' '+ @strFSortType 
            end
    end

    else --�в�ѯ����
    begin
        if @pageIndex<2 or @page<=@pageIndex / 2 + @pageIndex % 2   --ǰ�벿�����ݴ���
        begin 
                set @strTmp=@SqlSelect+' top '+ CAST(@pageSize as VARCHAR(4))+' '+ @fldName +' from  '+@tblName
                    +' where '+@ID+' not in('+ @SqlSelect+' top '+ CAST(@pageSize*(@page-1) as Varchar(20)) +' '+ @ID +' from '+@tblName
                    +' Where (1>0) ' + @strCondition + ' order by '+ @fldSort +' '+ @strFSortType+')'
                    +' ' + @strCondition + ' order by '+ @fldSort +' '+ @strFSortType                 
        end
        else
        begin 
            set @page = @pageIndex-@page+1 --��벿�����ݴ���
            if @page <= 1 --���һҳ������ʾ
                    set @strTmp=@SqlSelect+' * from ('+@SqlSelect+' top '+ CAST(@lastcount as VARCHAR(4))+' '+ @fldName+' from '+@tblName
                        +' where (1>0) '+ @strCondition +' order by '+ @fldSort +' '+ @strSortType+') AS TempTB'+' order by '+ @fldSort +' '+ @strFSortType
            else
                    set @strTmp=@SqlSelect+' * from ('+@SqlSelect+' top '+ CAST(@pageSize as VARCHAR(4))+' '+ @fldName+' from '+@tblName
                        +' where '+@ID+' not in('+ @SqlSelect+' top '+ CAST(@pageSize*(@page-2)+@lastcount as Varchar(20)) +' '+ @ID +' from '+@tblName
                        +' where (1>0) '+ @strCondition +' order by '+ @fldSort +' '+ @strSortType+')'
                        + @strCondition +' order by '+ @fldSort +' '+ @strSortType+') AS TempTB'+' order by '+ @fldSort +' '+ @strFSortType 
        end    
    end

------���ز�ѯ���-----
exec sp_executesql @strTmp
--print @strTmp
SET NOCOUNT OFF 


