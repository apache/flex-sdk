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

package mx.controls.dataGridClasses
{

import mx.controls.listClasses.ListBase;
import mx.controls.listClasses.ListBaseContentHolder;

/**
 *  The DataGridLockedRowContentHolder class defines a container in a DataGrid control
 *  of all of the control's item renderers and item editors.
 *  Flex uses it to mask areas of the renderers that extend outside
 *  of the control, and to block certain styles, such as <code>backgroundColor</code>, 
 *  from propagating to the renderers so that highlights and 
 *  alternating row colors can show through the control.
 *
 *  @see mx.controls.DataGrid
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class DataGridLockedRowContentHolder extends ListBaseContentHolder
{

    /**
     *  Constructor.
     *
     *  @param parentList The DataGrid control.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function DataGridLockedRowContentHolder(parentList:ListBase)
    {
        super(parentList);
        if (parentList.dataProvider)
            iterator = parentList.dataProvider.createCursor();
    }
    

    /**
     * The measured height of the DataGrid control.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function get measuredHeight():Number
    {
        var rc:Number = rowInfo.length;
        if (rc == 0)
            return 0;

        return rowInfo[rc - 1].y + rowInfo[rc - 1].height;
    }
}

}