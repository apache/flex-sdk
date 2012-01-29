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

package mx.controls.fileSystemClasses
{

import flash.display.DisplayObject;
import flash.filesystem.File;
import mx.controls.FileSystemComboBox;
import mx.controls.fileSystemClasses.FileSystemControlHelper;
import mx.controls.listClasses.ListItemRenderer;
import mx.core.mx_internal;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 */
public class FileSystemComboBoxRenderer extends ListItemRenderer
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function FileSystemComboBoxRenderer()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();

        if (!listData || !data)
            return;

        var comboBox:FileSystemComboBox =
            FileSystemComboBox(listData.owner.owner);
        if (!comboBox.showIcons)
            return;

        var iconClass:Class = comboBox.getStyle(
            comboBox.helper.isComputer(File(data)) ?
            "computerIcon" :
            "directoryIcon");

        if (iconClass)
        {
            icon = new iconClass();
            addChild(DisplayObject(icon));
        }
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        if (!listData || !data)
            return;

        var comboBox:FileSystemComboBox =
            FileSystemComboBox(listData.owner.owner);
        if (comboBox.indent == 0)
            return;

        var delta:Number = comboBox.indent * getNestLevel(File(data));
        if (icon)
            icon.x += delta;
        label.x += delta;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function getNestLevel(item:File):int
    {
        if (!item || !item.exists)
            return 0;

        var nestLevel:int = 0;
        for (var f:File = item; f != null; f = f.parent)
        {
            nestLevel++;
        }
        return nestLevel;
    }
}
}
