using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using JZ.BLL;
using System.Data;
using System.Data.SqlClient;
using System.Threading;
using System.IO;
using System.Net;
using System.Text;

/// <summary>
/// WMReportService 的摘要说明
/// </summary>
public static class WMReportService
{
    #region 
    /// <summary>
    /// 
    /// </summary>
    private static Thread _ThisThread;

    /// <summary>
    /// 
    /// </summary>
    private static System.Threading.Timer _ThisTimer;



    #endregion

    #region 线程

    /// <summary>
    /// 初始化服务
    /// </summary>
    private static void Init()
    {
        if (_ThisThread != null && _ThisThread.ThreadState != ThreadState.Stopped)
        {
            if (!Dispose())
            {
                return;
            }
        }

        _ThisThread = new Thread(new ThreadStart(ThreadStartVoid));
        _ThisThread.Name = "ForWMReport";
        _ThisThread.IsBackground = true;
    }


    /// <summary>
    /// 启动
    /// </summary>
    /// <returns></returns>
    public static bool Start()
    {
        try
        {
            if (_ThisThread == null)
            {
                Init();
            }
            _ThisThread.Start();
            return true;
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// 终止
    /// </summary>
    /// <returns></returns>
    public static bool Stop()
    {
        try
        {
            _ThisTimer.Change(Timeout.Infinite, Timeout.Infinite);
            _ThisThread.Abort();
            return true;
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// 线程启动回调
    /// </summary>
    private static void ThreadStartVoid()
    {
        _ThisTimer = new System.Threading.Timer(new TimerCallback(_TimerCallback), null, 0, 24 * 60 * 60 * 1000);
    }

    /// <summary>
    /// 定时回调 发送短信
    /// </summary>
    /// <param name="o"></param>
    private static void _TimerCallback(object o)
    {
        string JsonResult = string.Empty;
        string SqlResult = string.Empty;
        //周报
        if (DateTime.Now.DayOfWeek == DayOfWeek.Thursday)
        {
            foreach (DataRow Dr in Lines().Rows)
            {
                JsonResult = Json("W", Dr["ConStr"].ToString());
                //插入数据库
                SqlResult = "";
                ExecuteNonQuery(SqlResult, Dr["ConStr"].ToString());
                //调用接口
                //string postUrl = "http://app.kingrocket.com:9311/notification/send";
                //string paramData = string.Format("lineID={0}&lineTag={1}&testRoom={2}&category={3}&message={4}", LineID, LineTag, TestRoom, MsgType, Msg);
                //string PostResult = PostWebRequest(postUrl, paramData, Encoding.UTF8);
            }
        }

        //月报
        if (DateTime.Now.Day == 25)
        {
            foreach (DataRow Dr in Lines().Rows)
            {
                JsonResult = Json("M", Dr["ConStr"].ToString());
                //插入数据库
                SqlResult = "";
                ExecuteNonQuery(SqlResult, Dr["ConStr"].ToString());
                //调用接口
                //string postUrl = "http://app.kingrocket.com:9311/notification/send";
                //string paramData = string.Format("lineID={0}&lineTag={1}&testRoom={2}&category={3}&message={4}", LineID, LineTag, TestRoom, MsgType, Msg);
                //string PostResult = PostWebRequest(postUrl, paramData, Encoding.UTF8);
            }
        }
    }

    /// <summary>
    /// 停止 释放
    /// </summary>
    /// <returns></returns>
    public static bool Dispose()
    {
        try
        {
            _ThisTimer.Change(Timeout.Infinite, Timeout.Infinite);
            _ThisTimer.Dispose();
            _ThisTimer = null;

            _ThisThread.Abort();
            _ThisThread = null;
            return true;
        }
        catch
        { return false; }
    }

    #endregion

    /// <summary>
    /// 周报月报
    /// </summary>
    /// <param name="RType">W:周 M:月</param>
    /// <param name="StartDate"></param>
    /// <param name="EndDate"></param>
    public static string Json(string RType, string ConnStr)
    {
        string StartDate = string.Empty, EndDate = string.Empty;
        switch (RType)
        {
            case "W":
                StartDate = DateTime.Now.AddDays(-7).ToString("yyyy-MM-dd");
                EndDate = DateTime.Now.ToString("yyyy-MM-dd");
                break;

            case "M":
                StartDate = DateTime.Now.AddMonths(-1).ToString("yyyy-MM-" + 25);
                EndDate = DateTime.Now.ToString("yyyy-MM-" + 25);
                break;
        }



        #region SQL


        string SqlRoom = @"
                        select 
                        tsg.DESCRIPTION as 'segmentName'
                        t.DESCRIPTION as 'companyName',

                        ,t.NodeCode	
                        ,''as 'newInfoNum'
                        ,''as 'infoUpdateNum'	
                        ,''as 'loginNum'
                        ,''as 'mainValueUpdateNum'
                        ,''as 'unqualifiedInfoNum'
                        ,''as 'untreatedUnqualifiedInfoNum'

                        from sys_Tree t
                       
                        left outer join sys_Tree tsg on tsg.nodecode = left(t.nodecode,8)

                        where len(t.NodeCode)=12
                        order by t.OrderID  asc 
                        ";

        string Sql = @" 
                      

                        -- 0 本周资料
                        select left(testroomcode,12) as testroomcode,count(1) as ct from sys_document a 
                        join sys_module b on a.moduleid=b.id
                        where status>0 and b.moduletype=1  and  a.bgrq between 
                         '{0}' and '{1}' group by a.testroomcode
                        
                        --1 本周修改资料次数
                        SELECT left(testroomcode,12) as testroomcode,count(1) as ct
                        FROM sys_request_change
                        where RequestTime between  '{0}' and '{1}'
                        group by TestRoomCode
    
         
                        -- 2 本周系统登录次数
                        SELECT left(testroomcode,12) as testroomcode, COUNT(1) as ct  FROM dbo.sys_loginlog WHERE  FirstAccessTime between  '{0}' and '{1}' AND len(testroomcode)>12  group by testroomcode

                        -- 3 本周已经处理资料
                        SELECT left(testroomcode,12) as testroomcode,count(1) as ct,b.StatisticsCatlog  FROM dbo.sys_invalid_document a
                        join sys_module b on a.moduleid=b.id
                        WHERE AdditionalQualified=0  and status>0   and (DealResult <>'' OR DealResult IS NOT NULL) and
                        bgrq between  '{0}' and '{1}' AND  F_InvalidItem NOT LIKE '%#%'
                        group by a.testroomcode,b.StatisticsCatlog

                        -- 4 本周不合格资料
                        SELECT left(testroomcode,12) as testroomcode,count(1) as ct,b.StatisticsCatlog  FROM dbo.sys_invalid_document a
                        join sys_module b on a.moduleid=b.id
                        WHERE AdditionalQualified=0  and status>0   and 
                        bgrq between  '{0}' and '{1}' AND  F_InvalidItem NOT LIKE '%#%'
                        group by a.testroomcode,b.StatisticsCatlog

                        -- 5 本周未处理资料
                        SELECT left(testroomcode,12) as testroomcode,count(1) as ct,b.StatisticsCatlog  FROM dbo.sys_invalid_document a
                        join sys_module b on a.moduleid=b.id
                        WHERE AdditionalQualified=0  and status>0   and (DealResult='' OR DealResult IS NULL) and
                        bgrq between  '{0}' and '{1}' AND  F_InvalidItem NOT LIKE '%#%'
                        group by a.testroomcode,b.StatisticsCatlog


                        ";


        #endregion


        Sql = string.Format(Sql, StartDate, EndDate);

        Sql = SqlRoom + Sql;

        DataSet Ds = GetDs(Sql,ConnStr);

        DataTable Rooms = Ds.Tables[0];

        foreach (DataRow Dr in Rooms.Rows)
        {
            Dr[2] = Ds.Tables[2].Compute("sum(ct)", " testroomcode ='" + Dr["NodeCode"].ToString() + "'").ToString();
            Dr[3] = Ds.Tables[3].Compute("sum(ct)", " testroomcode ='" + Dr["NodeCode"].ToString() + "'").ToString();
            Dr[4] = Ds.Tables[4].Compute("sum(ct)", " testroomcode ='" + Dr["NodeCode"].ToString() + "'").ToString();
            Dr[5] = Ds.Tables[5].Compute("sum(ct)", " testroomcode ='" + Dr["NodeCode"].ToString() + "'").ToString();
            Dr[6] = Ds.Tables[6].Compute("sum(ct)", " testroomcode ='" + Dr["NodeCode"].ToString() + "'").ToString();
            Dr[7] = Ds.Tables[7].Compute("sum(ct)", " testroomcode ='" + Dr["NodeCode"].ToString() + "'").ToString();

        }
        Rooms.Columns.Remove("NodeCode");

        DataRow All = Rooms.NewRow();
        All[0] = "";
        All[1] = "合计";
        All[2] = Ds.Tables[2].Compute("sum(ct)", "").ToString();
        All[3] = Ds.Tables[3].Compute("sum(ct)", "").ToString();
        All[4] = Ds.Tables[4].Compute("sum(ct)", "").ToString();
        All[5] = Ds.Tables[5].Compute("sum(ct)", "").ToString();
        All[6] = Ds.Tables[6].Compute("sum(ct)", "").ToString();
        All[7] = Ds.Tables[7].Compute("sum(ct)", "").ToString();

        Rooms.Rows.Add(All);


        return  JsonConvert.SerializeObject(Rooms);

    }


    #region 数据库操作



    /// <summary>
    /// 获取线路
    /// </summary>
    /// <returns></returns>
    public static DataTable Lines()
    {
        DataTable Result = new DataTable();
        string _ConnStr = "server={0};database={1};uid={2};pwd={3};";
        string Sql = @"
                        SELECT
                        ID as LineID ,
                        LineName ,
                        [Description] ,
                        DataSourceAddress ,
                        UserName ,
                        PassWord ,
                        DataBaseName ,
                        '', as 'ConStr'
                        FROM [SYGLDB_LIB].[dbo].[sys_line]
                        where isbhz in (2,3) and isactive =1";
        Result = LineDbHelperSQL.Query(Sql).Tables[0];

        foreach (DataRow Dr in Result.Rows)
        {
            Dr["ConStr"] = string.Format(_ConnStr, Dr["DataSourceAddress"].ToString(), Dr["DataBaseName"].ToString(), Dr["UserName"].ToString(), Dr["PassWord"].ToString());

            //Result.Add(string.Format(_ConnStr, Dr["DataSourceAddress"].ToString(), Dr["DataBaseName"].ToString(), Dr["UserName"].ToString(), Dr["PassWord"].ToString()));
        }
        return Result;
    }



    /// <summary>
    /// 获取列表
    /// </summary>
    /// <param name="ConnStr"></param>
    /// <param name="Sql"></param>
    /// <returns></returns>
    public static DataSet GetDs(string Sql, string ConnStr)
    {
        DataSet Result = new DataSet();
        using (SqlConnection _Conn = new SqlConnection(ConnStr))
        {
            _Conn.Open();
            using (SqlCommand _Com = new SqlCommand(Sql, _Conn))
            {
                using (SqlDataAdapter _Adp = new SqlDataAdapter(_Com))
                {
                    _Adp.Fill(Result);
                }
            }
            _Conn.Close();
        }
        return Result;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="Sql"></param>
    /// <param name="ConnStr"></param>
    /// <returns></returns>
    public static int ExecuteNonQuery(string Sql, string ConnStr)
    {
        int Result = 0;
        using (SqlConnection _Conn = new SqlConnection(ConnStr))
        {
            _Conn.Open();
            using (SqlCommand _Com = new SqlCommand(Sql, _Conn))
            {
                Result = _Com.ExecuteNonQuery();
            }
            _Conn.Close();
        }
        return Result;
    }


    #endregion



    /// <summary>
    /// Post提交数据
    /// </summary>
    /// <param name="postUrl"></param>
    /// <param name="paramData"></param>
    /// <param name="dataEncode"></param>
    /// <returns></returns>
    private static string PostWebRequest(string postUrl, string paramData, Encoding dataEncode)
    {
        string ret = string.Empty;
        try
        {
            byte[] byteArray = dataEncode.GetBytes(paramData); //转化
            HttpWebRequest webReq = (HttpWebRequest)WebRequest.Create(new Uri(postUrl));
            webReq.Method = "POST";
            webReq.ContentType = "application/x-www-form-urlencoded";

            webReq.ContentLength = byteArray.Length;
            Stream newStream = webReq.GetRequestStream();
            newStream.Write(byteArray, 0, byteArray.Length);//写入参数
            newStream.Close();
            HttpWebResponse response = (HttpWebResponse)webReq.GetResponse();
            StreamReader sr = new StreamReader(response.GetResponseStream(), Encoding.Default);
            ret = sr.ReadToEnd();
            sr.Close();
            response.Close();
            newStream.Close();
        }
        catch
        {
            return "false";
        }
        return ret;
    }

}