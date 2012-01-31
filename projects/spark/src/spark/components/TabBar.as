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
 *  Defines the radius of the TabBar buttons' top-left and top-right corners for the default
 *  TabBarButton skin.
 *
 *  @default 4
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="cornerRadius", type="Number", format="Length", inherit="no", theme="spark")]

/**
 *  The TabBar class displays a set of identical tabs.  
 *  One tab can be selected at a time, and the first tab is selected by default.
 *  The TabBarSkin class arranges the tabs in a single row.  
 *  Use the TabBar <code>cornerRadius</code> style to configure the corner radius 
 *  of the tabs.
 * 
 *  <p>The set of tabs is defined by the <code>dataProvider</code> property.
 *  The appearance of each tab is defined by the TabBarSkin class.
 *  By default, each tab is defined as a ButtonBarButton component 
 *  with a skin defined by the TabBarButtonSkin class.</p>
 *
 *  <p>You can use the TabBar control to set the active child of a ViewStack container, 
 *  as the following example shows:</p>
 *  
 *  <pre>
 *  &lt;s:TabBar dataProvider="{myViewStack}"/&gt; 
 *  
 *  &lt;mx:ViewStack id="myViewStack" 
 *      borderStyle="solid"&gt; 
 *  
 *      &lt;s:NavigatorContent id="search" label="Search"&gt; 
 *          &lt;s:Label text="Search Screen"/&gt; 
 *          &lt;/s:NavigatorContent&gt; 
 *  
 *      &lt;s:NavigatorContent id="custInfo" label="Customer Info"&gt; 
 *          &lt;s:Label text="Customer Info"/&gt; 
 *          &lt;/s:NavigatorContent&gt; 
 *  
 *      &lt;s:NavigatorContent id="accountInfo" label="Account Info"&gt; 
 *          &lt;s:Label text="Account Info"/&gt; 
 *          &lt;/s:NavigatorContent&gt; 
 *      &lt;/mx:ViewStack&gt; </pre>
 *  
 *  @mxml <p>The <code>&lt;s:TabBar&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:TabBar
 *    <b>Styles</b>
 *    cornerRadius="4"
 *  /&gt;
 *  </pre>
 *
 *  @see mx.containers.ViewStack
 *  @see spark.skins.spark.TabBarSkin
 *  @see spark.skins.spark.TabBarButtonSkin
 *  @see spark.components.ButtonBarButton
 * 
 *  @includeExample examples/TabBarExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class TabBar extends ButtonBarBase implements IFocusManagerComponent
{
    include "../core/Version.as";
    
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function TabBar()
    {
        super();

        requireSelection = true;
        mouseFocusEnabled = false;        
    }
}
}