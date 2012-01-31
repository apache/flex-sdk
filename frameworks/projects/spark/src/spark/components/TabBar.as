////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{
import flash.events.EventPhase;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.core.EventPriority;
import mx.core.IFactory;
import mx.core.ISelectableList;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.managers.IFocusManagerComponent;

import spark.components.supportClasses.ButtonBarBase;
import spark.components.supportClasses.ItemRenderer;
import spark.events.IndexChangeEvent;
import spark.events.RendererExistenceEvent;

use namespace mx_internal;  // ListBase/setCurrentCaretIndex(index);

/**
 *  The radius of the tab bar buttons' top and right corners.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="cornerRadius", type="Number", format="Length", inherit="no", theme="spark")]

/**
 *  Displays a list of identical buttons called "tabs".  One tab can be selected at a time
 *  and the first tab is selected by default.
 * 
 *  <p>The list of tabs is defined by the <code>dataProvider</code> and their appearance is
 *  defined by the <code>dataGroup's</code> ItemRenderer, typically a <code>ButtonBarButton</code>.</p>
 * 
 *  <p>The default TabBar skin arranges ButtonBarButton tabs in a single row.  The TabBar 
 *  <code>cornerRadius</code> style is used by the default skin to configure the cornerRadius 
 *  of ButtonBarButton tabs, setting the style on the TabBar affects all tabs.</p>
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class TabBar extends ButtonBarBase implements IFocusManagerComponent
{
    include "../core/Version.as";
    
    
    public function TabBar()
    {
        super();

        requireSelection = true;
        mouseFocusEnabled = false;        
    }
}
}