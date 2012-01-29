////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2006-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
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