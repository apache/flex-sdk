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
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.EventPhase;
import flash.events.IEventDispatcher;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import spark.components.supportClasses.ButtonBarBase;
import spark.events.IndexChangeEvent;
import spark.events.RendererExistenceEvent;

import mx.collections.IList;
import mx.core.EventPriority;
import mx.core.IFactory;
import mx.core.ISelectableList;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.FlexEvent;
import mx.managers.IFocusManagerComponent;

use namespace mx_internal;  //ListBase and List share selection properties that are mx_internal

[IconFile("ButtonBar.png")]

[AccessibilityClass(implementation="spark.accessibility.ButtonBarAccImpl")]

/**
 *  The ButtonBar control defines a horizontal group of 
 *  logically related buttons with a common look and navigation.
 *
 *  <p>The typical use for a button bar is for grouping
 *  a set of related buttons together, which gives them a common look
 *  and navigation, and handling the logic for the <code>change</code> event
 *  in a single place. </p>
 *
 *  <p>The ButtonBar control creates Button controls based on the value of 
 *  its <code>dataProvider</code> property. 
 *  Use methods such as <code>addItem()</code> and <code>removeItem()</code> 
 *  to manipulate the <code>dataProvider</code> property to add and remove data items. 
 *  The ButtonBar control automatically adds or removes the necessary children based on 
 *  changes to the <code>dataProvider</code> property.</p>
 *
 *  <p>You can use the ButtonBar control to set the active child of a ViewStack container, 
 *  as the following example shows:</p>
 *  
 *  <pre>
 *  &lt;s:ButtonBar dataProvider="{myViewStack}"/&gt; 
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
 *  @mxml <p>The <code>&lt;s:ButtonBar&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:ButtonBar
 *
 *  /&gt;
 *  </pre>
 *
 *  @see mx.containers.ViewStack
 *  @see spark.components.ButtonBarButton
 *  @see spark.skins.spark.ButtonBarSkin
 *
 *  @includeExample examples/ButtonBarExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ButtonBar extends ButtonBarBase implements IFocusManagerComponent 
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class mixins
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Placeholder for mixin by ButtonBarAccImpl.
     */
    mx_internal static var createAccessibilityImplementation:Function;

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function ButtonBar()
    {
        super();
        
        itemRendererFunction = defaultButtonBarItemRendererFunction;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  firstButton
    //---------------------------------- 
    
    [SkinPart(required="false", type="mx.core.IVisualElement")]
    
    /**
     * A skin part that defines the first button.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var firstButton:IFactory;
    
    //----------------------------------
    //  lastButton
    //---------------------------------- 
    
    [SkinPart(required="false", type="mx.core.IVisualElement")]
    
    /**
     * A skin part that defines the last button.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var lastButton:IFactory;

    //----------------------------------
    //  middleButton
    //---------------------------------- 
    
    [SkinPart(required="true", type="mx.core.IVisualElement")]
    
    /**
     * A skin part that defines the middle button(s).
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var middleButton:IFactory;

    //--------------------------------------------------------------------------
    //
    //  Overridden Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  dataProvider
    //----------------------------------
     
    /**
     *  @private
     */    
    override public function set dataProvider(value:IList):void
    {
        if (dataProvider)
            dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, resetCollectionChangeHandler);
    
        // not really a default handler, we just want it to run after the datagroup
        if (value)
            value.addEventListener(CollectionEvent.COLLECTION_CHANGE, resetCollectionChangeHandler, false, EventPriority.DEFAULT_HANDLER);

        super.dataProvider = value;
    }

    /**
     *  @private
     */
    private function resetCollectionChangeHandler(event:Event):void
    {
        if (event is CollectionEvent)
        {
            var ce:CollectionEvent = CollectionEvent(event);

            if (ce.kind == CollectionEventKind.ADD || 
                ce.kind == CollectionEventKind.REMOVE)
            {
                // force reset here so first/middle/last skins
                // get reassigned
                if (dataGroup)
                {
                    dataGroup.layout.useVirtualLayout = true;
                    dataGroup.layout.useVirtualLayout = false;
                }
            }
        }
    }

    /**
     *  @private
     *  button bar always keeps something under the caret so don't let it
     *  become -1
     */
    override mx_internal function setCurrentCaretIndex(value:Number):void
    {
        if (value == -1)
            return;

        super.setCurrentCaretIndex(value);
    }

     /**
     *  @private
     *  Called by the initialize() method of UIComponent
     *  to hook in the accessibility code.
     */
    override protected function initializeAccessibility():void
    {
        if (createAccessibilityImplementation != null)
            createAccessibilityImplementation(this);
    }


    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------

    private function defaultButtonBarItemRendererFunction(data:Object):IFactory
    {
        var i:int = dataProvider.getItemIndex(data);
        if (i == 0)
            return firstButton ? firstButton : middleButton;

        var n:int = dataProvider.length - 1;
        if (i == n)
            return lastButton ? lastButton : middleButton;

        return middleButton;
    }
}

}

