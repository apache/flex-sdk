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

package mx.controls.olapDataGridClasses
{

import mx.formatters.Formatter;

/**
 *  An OLAPDataGridItemRendererProvider instance lets you specify a formatter 
 *  for the items in the OLAPDataGrid control. 
 *
 *  @see mx.controls.OLAPDataGrid
 *  @see mx.formatters.Formatter
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPDataGridItemRendererProvider extends OLAPDataGridRendererProvider
{
	include "../../core/Version.as";
	
	//--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------   
    
    //----------------------------------
    // formatter
    //----------------------------------
    
    /**
     *  An instance of the Formatter class, or of a subclass of the Formatter class, 
     *  applied to the text to of the associated IOLAPElement.
     *
     *  <p>For example, you apply a CurrencyFormatter formatter to an OLAPDataGrid control,
     *  as the following example shows:</p>
     *
     *  <pre>
     *  &lt;mx:CurrencyFormatter id="usdFormatter" precision="2" 
     *      currencySymbol="$" decimalSeparatorFrom="."
     *      decimalSeparatorTo="." useNegativeSign="true" 
     *      useThousandsSeparator="true" alignSymbol="left"/&gt;
     *  
     *  ...
     *  
     *  &lt;mx:OLAPDataGrid id="myOLAPDG" 
     *      width="100%" height="100%"&gt;
     *  
     *      &lt;mx:itemRendererProviders&gt;
     *          &lt;mx:OLAPDataGridItemRendererProvider 
     *              uniqueName="[QuarterDim].[Quarter]"
     *              type="{OLAPDataGrid.OLAP_HIERARCHY}"
     *              formatter="{usdFormatter}"/&gt;
     *      &lt;/mx:itemRendererProviders&gt;
     *  &lt;/mx:OLAPDataGrid&gt;</pre>
     *
     *  <p>In this example, the <code>uniqueName</code> and <code>type</code> properties 
     *  specify that Quarter is a hierarchy of the QuarterDim dimension. </p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
     public var formatter:Formatter
}

}