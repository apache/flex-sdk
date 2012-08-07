////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

<%@ WebService Language="C#" CodeBehind="CustomerList.asmx.cs" Class="CustomerList" %>
using System.Xml;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Web.Services.Description;
using System.Data;
using System.Data.SqlClient;
using System;


public class CustomerList : WebService
{
    //Privies
    private const String _colCustomerID = "CustomerID";
    private const String _colCompanyName = "CompanyName";
    private const String _colContactName = "ContactName";
    private const String _colContactTitle = "ContactTitle";
    private const String _colAddress = "Address";
    private const String _colCity = "City";
    private const String _colRegion = "Region";
    private const String _colPostalCode = "PostalCode";
    private const String _colCountry = "Country";
    private const String _colPhone = "Phone";
    private const String _colFax = "Fax";

    //Datatables
    private DataTable _dtCustomers = new DataTable();
    private DataSet _dsCustomers = new DataSet("Customers");


    //Construction and init
    public CustomerList()
    {
    }

    private void ClearAndFillTable(Int32 rows)
    {
        String[] columns = new String[] { _colCustomerID, _colCompanyName, _colContactName, _colContactTitle, _colAddress, _colCity, _colRegion, _colPostalCode, _colCountry, _colPhone, _colFax };

        ClearAndFillUniqueTable(columns, rows);
    }

    private void ClearAndFillUniqueTable(String[] columns, Int32 rows)
    {
        _dtCustomers = new DataTable();
        _dsCustomers = new DataSet();

        //Add concerned cols
        for (Int32 i = 0; i < columns.Length; i++)
        {
            _dtCustomers.Columns.Add(new DataColumn(columns[i], typeof(String)));
        }

        //Fill with data
        for (Int32 i = 0; i < rows; i++)
        {
            DataRow dr = _dtCustomers.NewRow();

            for (Int32 j = 0; j < columns.Length; j++)
            {
                dr[columns[j]] = columns[j] + "_" + j.ToString();
            }

            _dtCustomers.Rows.Add(dr);
        }

        //Associate table and set
        _dsCustomers.Tables.Add(_dtCustomers);
    }



    [WebMethod]
    public DataTable getCustomersAsDT()
    {
        this.ClearAndFillTable(10);

        return (this._dtCustomers);
    }

    [WebMethod]
    public DataTable getDataTypeSurveyAsDT()
    {
        this.ClearAndFillTable(10);

        return (this._dtCustomers);
    }

    [WebMethod]
    public DataSet getDatTypeSurveyAsDS()
    {
        this.ClearAndFillTable(10);

        return (this._dsCustomers);
    }

    [WebMethod]
    public DataSet getEmptyDataTypeSurveyDS()
    {
        this.ClearAndFillTable(0);

        return (this._dsCustomers);
    }

    [WebMethod]
    public DataSet getEmptyDS()
    {
        this.ClearAndFillTable(0);

        return (this._dsCustomers);
    }

    [WebMethod]
    [SoapDocumentMethod(
    Use = SoapBindingUse.Literal,
    ParameterStyle = SoapParameterStyle.Wrapped)]
    public DataSet getCustomersAsDS()
    {
        this.ClearAndFillTable(10);

        return (this._dsCustomers);

    }

    [WebMethod]
    public DataSet getCustomersAsComplexDS()
    {
        this.ClearAndFillUniqueTable(new String[] { _colCustomerID, _colCompanyName }, 50);

        return (this._dsCustomers);
    }


    [WebMethod]
    public DataSet getXMLDataSet()
    {
        DataSet xds = new DataSet();
        XmlDocument xdoc = new XmlDocument();

        xdoc.AppendChild(xdoc.CreateElement("Root"));

        for (Int32 i = 0; i < 10; i++)
        {
            xdoc.DocumentElement.AppendChild(xdoc.CreateElement("PhoneNumber")).InnerXml = "415-832-222" + i.ToString();
        }

        XmlTextReader reader = new XmlTextReader(xdoc.OuterXml, XmlNodeType.Element, null);

        xds.ReadXml(reader, XmlReadMode.InferSchema);

        return (xds);
    }

    [WebMethod]
    public DataTable[] getDataTableArray()
    {
        DataTable[] dtArr = new DataTable[3];

        this.ClearAndFillUniqueTable(new String[] { _colCustomerID, _colCompanyName }, 30);

        dtArr[0] = this._dtCustomers;
        dtArr[1] = this._dtCustomers;
        dtArr[2] = this._dtCustomers;

        return (dtArr);
    }

    [WebMethod]
    public DataSet[] getDataSetArray()
    {
        DataSet[] dsArr = new DataSet[3];

        this.ClearAndFillUniqueTable(new String[] { _colCustomerID, _colCompanyName }, 25);

        dsArr[0] = this._dsCustomers;
        dsArr[1] = this._dsCustomers;
        dsArr[2] = this._dsCustomers;

        return (dsArr);
    }

    [WebMethod]
    [SoapDocumentMethod(
    Use = SoapBindingUse.Literal,
    ParameterStyle = SoapParameterStyle.Wrapped)]
    public DataTable getCustomersRaiseError(string customerId)
    {
        string sqlAllCustomers = "SELECT * FROM Customers WHERE CustomerID = '" + customerId + "'"; //WHERE CustomerID = 'ALFKI'
        string cnStr =
       @"Data Source=(local);Initial Catalog=northwind;Integrated Security=False;User='northwind';Password='';";
        using (SqlConnection cn = new SqlConnection(cnStr))
        {
            cn.Open();
            SqlCommand cmd = new SqlCommand(sqlAllCustomers, cn);
            SqlDataAdapter adpt = new SqlDataAdapter(cmd);
            DataTable dtCust1 = new DataTable("Customers");
            adpt.Fill(dtCust1);
            return dtCust1;
        }
    }
}

