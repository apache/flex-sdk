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

package mx.controls.advancedDataGridClasses
{
    
import mx.controls.AdvancedDataGrid;

/**
 *  The IAdvancedDataGridRendererProvider interface defines the interface 
 *  implemented by the AdvancedDataGridRendererProvider class, 
 *  which defines the item renderer for the AdvancedDataGrid control. 
 *
 *  @see mx.controls.AdvancedDataGrid
 *  @see mx.controls.advancedDataGridClasses.AdvancedDataGridRendererProvider
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */    
public interface IAdvancedDataGridRendererProvider
{
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /** 
     *  Updates the IAdvancedDataGridRendererDescription instance with 
     *  information about this IAdvancedDataGridRendererProvider.
     * 
     *  @param data The data item to display.
     * 
     *  @param dataDepth The depth of the data item in the AdvancedDataGrid control.
     * 
     *  @param column The column associated with the item.
     * 
     *  @param description The AdvancedDataGridRendererDescription object 
     *  populated with the renderer and column span information.
     * 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function describeRendererForItem(data:Object, 
                                       dataDepth:int, 
                                       column:AdvancedDataGridColumn,
                                       description:AdvancedDataGridRendererDescription):void;
}
}