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

/**
 *  The OLAPDataGridHeaderRendererProvider class lets you specify a 
 *  custom header renderer for the columns in the OLAPDataGrid control. 
 *
 *  <p>To specify a custom header renderer to the OLAPDataGrid control, 
 *  create your customer header renderer as a subclass of the OLAPDataGridHeaderRenderer class,
 *  create an instance of the OLAPDataGridHeaderRendererProvider, 
 *  set the <code>OLAPDataGridHeaderRendererProvider.renderer</code> property to
 *  your customer header renderer, and  
 *  then pass the OLAPDataGridHeaderRendererProvider instance to the OLAPDATAGrid control
 *  by setting the <code>OLAPDataGrid.headerRendererProviders</code> property.</p>
 *
 *  @see mx.controls.OLAPDataGrid
 *  @see mx.controls.olapDataGridClasses.OLAPDataGridHeaderRenderer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPDataGridHeaderRendererProvider extends OLAPDataGridRendererProvider
{
	include "../../core/Version.as";
	
	//--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------   
    
    //----------------------------------
    // headerWordWrap
    //----------------------------------
    
    /**
     *  Set to <code>true</code> to wrap the text in the column header.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var headerWordWrap:*
}    
}
