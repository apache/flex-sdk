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

import spark.components.supportClasses.ListBase;
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
public class ButtonBar extends ListBase implements IFocusManagerComponent 
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constants
    //
    //--------------------------------------------------------------------------
    
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
        
        tabChildren = false;
        tabEnabled = true;
        tabFocusEnabled = true;

        addEventListener(IndexChangeEvent.CARET_CHANGE, caretChangeHandler);

        // start off with a button under the caret
        _caretIndex = 0;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private var inKeyUpHandler:Boolean;

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

    private var requireSelectionChanging:Boolean;
    
    //----------------------------------
    //  requireSelection
    //---------------------------------- 
    
    /**
     *  @private
     */
    override public function set requireSelection(value:Boolean):void
    {
        super.requireSelection = value;
        requireSelectionChanging = true;
    }

    //----------------------------------
    //  dataProvider
    //----------------------------------
     
    /**
     *  @private
     */    
    override public function set dataProvider(value:IList):void
    {
        if (dataProvider)
        {
            dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, resetCollectionChangeHandler);
            if (dataProvider is ISelectableList)
                dataProvider.removeEventListener(Event.CHANGE, navigationChangeHandler);
        }
    
        // not really a default handler, we just want it to run after the datagroup
        if (value)
        {
            value.addEventListener(CollectionEvent.COLLECTION_CHANGE, resetCollectionChangeHandler, false, EventPriority.DEFAULT_HANDLER);
            if (value is ISelectableList)
                value.addEventListener(Event.CHANGE, navigationChangeHandler);
        }

        super.dataProvider = value;

        if (value is ISelectableList)
            if (ISelectableList(dataProvider).selectedIndex != selectedIndex)
                selectedIndex = ISelectableList(dataProvider).selectedIndex;
    }

    /**
     *  @private
     */
    private function navigationChangeHandler(event:Event):void
    {
        if (ISelectableList(dataProvider).selectedIndex != selectedIndex)
            selectedIndex = ISelectableList(dataProvider).selectedIndex;
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
                ce = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
                ce.kind = CollectionEventKind.RESET;
                dataProvider.dispatchEvent(ce);
            }
        }
    }

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();

        if (requireSelectionChanging && dataProvider)
        {
            requireSelectionChanging = false;
            var n:int = dataProvider.length;
            for (var i:int = 0; i < n; i++)
            {
                var renderer:ButtonBarButton = 
                    dataGroup.getElementAt(i) as ButtonBarButton;
                if (renderer)
                    renderer.allowDeselection = !requireSelection;
            }
        }
    }
    
    /**
     *  @private
     */
    override public function drawFocus(isFocused:Boolean):void
    {
        adjustLayering(caretIndex);
        drawButtonFocus(caretIndex, isFocused);
    }


    /**
     *  @private
     */
    override protected function itemSelected(index:int, selected:Boolean):void
    {
        super.itemSelected(index, selected);
        
        var renderer:IItemRenderer = 
            dataGroup.getElementAt(index) as IItemRenderer;
        
        if (renderer)
        {
            setCurrentCaretIndex(index);
            renderer.selected = selected;
        }
        if (dataProvider is ISelectableList && selected)
            ISelectableList(dataProvider).selectedIndex = index;
    }
        
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        if (instance == dataGroup)
        {
            dataGroup.addEventListener(
                RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler);
            dataGroup.addEventListener(
                RendererExistenceEvent.RENDERER_REMOVE, dataGroup_rendererRemoveHandler);
        }
    }

    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == dataGroup)
        {
            dataGroup.removeEventListener(
                RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler);
            dataGroup.removeEventListener(
                RendererExistenceEvent.RENDERER_REMOVE, dataGroup_rendererRemoveHandler);
        }
        
        super.partRemoved(partName, instance);
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

    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Called when an item has been added to this component.
     */
    private function dataGroup_rendererAddHandler(event:RendererExistenceEvent):void
    {
        var renderer:IVisualElement = event.renderer; 
        var index:int = event.index;
        
        if (renderer)
        {
            renderer.addEventListener(MouseEvent.CLICK, item_clickHandler);
            if (renderer is IFocusManagerComponent)
                IFocusManagerComponent(renderer).focusEnabled = false;
            if (renderer is ButtonBarButton)
                ButtonBarButton(renderer).allowDeselection = !requireSelection;
        }
    }
    
    /**
     *  @private
     *  Called when an item has been removed from this component.
     */
    private function dataGroup_rendererRemoveHandler(event:RendererExistenceEvent):void
    {        
        var renderer:IVisualElement = event.renderer;
        
        if (renderer)
            renderer.removeEventListener(MouseEvent.CLICK, item_clickHandler);
    }
    
    /**
     *  @private
     *  Called when an item is clicked.
     */
    private function item_clickHandler(event:MouseEvent):void
    {
        var newIndex:int
        if (event.currentTarget is IItemRenderer)
            newIndex = IItemRenderer(event.currentTarget).index;
        else
            newIndex = dataGroup.getElementIndex(event.currentTarget as IVisualElement);

        var currentRenderer:IItemRenderer;
        if (caretIndex >= 0 && !inKeyUpHandler) // don't remove caret when keybd nav
        {
            currentRenderer = dataGroup.getElementAt(caretIndex) as IItemRenderer;
            currentRenderer.showsCaret = false;
        }

        if (newIndex == selectedIndex)
        {
            if (!requireSelection)
                selectedIndex = NO_SELECTION;
        }
        else
        {
            selectedIndex = newIndex;
        }

    }
    
    /**
     *  @private
     */
    private function caretChangeHandler(event:Event):void
    {
        adjustLayering(caretIndex);
    }

    /**
     *  @private
     *  Attempt to lift the focused button above the others
     *  so that the focus ring can show.
     */
    private function adjustLayering(caretIndex:int):void
    {
        var n:int = dataProvider ? dataProvider.length : 0;
        for (var i:int = 0; i < n; i++)
        {
            var renderer:IVisualElement = IVisualElement(dataGroup.getElementAt(i));
            // renderer may not exist in commitProps
            // should get called again when we get focus
            if (renderer)
            {
                if (i == caretIndex)
                    renderer.depth = 1;
                else
                    renderer.depth = 0;
            }
        }
    }

    /**
     *  @private
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        var currentRenderer:IItemRenderer;
        var renderer:IItemRenderer;
        
        if (event.eventPhase == EventPhase.BUBBLING_PHASE)
            return;

        if (!enabled || !dataProvider || event.isDefaultPrevented())
            return;
        
        super.keyDownHandler(event);

        var oldCaretIndex:Number = caretIndex; 
        var e:IndexChangeEvent;
        var length:int = dataProvider.length;
        switch (event.keyCode)
        {
            case Keyboard.UP:
            case Keyboard.LEFT:
            {
                currentRenderer = dataGroup.getElementAt(caretIndex) as IItemRenderer;
                if (caretIndex > 0 || arrowKeysWrapFocus)
                {
                    if (currentRenderer)
                        currentRenderer.showsCaret = false;
                    setCurrentCaretIndex((caretIndex - 1 + length) % length);
                    adjustLayering(caretIndex);
                    renderer = dataGroup.getElementAt(caretIndex) as IItemRenderer;
                    if (renderer)
                        renderer.showsCaret = true;
                    e = new IndexChangeEvent(IndexChangeEvent.CARET_CHANGE); 
                    e.oldIndex = oldCaretIndex; 
                    e.newIndex = caretIndex; 
                    dispatchEvent(e);    
                }

                event.preventDefault();
                break;
            }
            case Keyboard.DOWN:
            case Keyboard.RIGHT:
            {
                currentRenderer = dataGroup.getElementAt(caretIndex) as IItemRenderer;
                if (caretIndex < dataProvider.length - 1 || arrowKeysWrapFocus)
                {
                    if (currentRenderer)
                        currentRenderer.showsCaret = false;
                    setCurrentCaretIndex((caretIndex + 1) % length);
                    adjustLayering(caretIndex);
                    renderer = dataGroup.getElementAt(caretIndex) as IItemRenderer;
                    if (renderer)
                        renderer.showsCaret = true;
                    e = new IndexChangeEvent(IndexChangeEvent.CARET_CHANGE); 
                    e.oldIndex = oldCaretIndex; 
                    e.newIndex = caretIndex; 
                    dispatchEvent(e);    
                }

                event.preventDefault();
                break;
            }            
            case Keyboard.SPACE:
            {
                currentRenderer = dataGroup.getElementAt(caretIndex) as IItemRenderer;
                if (!currentRenderer || (currentRenderer.selected && requireSelection))
                    return;
                currentRenderer.dispatchEvent(event);
                break;
            }            
        }
    }
  
    /**
     *  @private
     */
    override protected function keyUpHandler(event:KeyboardEvent):void
    {
        var currentRenderer:IItemRenderer;
        var renderer:IItemRenderer;

        if (event.eventPhase == EventPhase.BUBBLING_PHASE)
            return;

        if (!enabled)
            return;

        inKeyUpHandler = true;

        super.keyUpHandler(event);

        switch (event.keyCode)
        {
            case Keyboard.SPACE:
            {
                  currentRenderer = dataGroup.getElementAt(caretIndex) as IItemRenderer;
                if (!currentRenderer || (currentRenderer.selected && requireSelection))
                    return;
                currentRenderer.dispatchEvent(event);
                break;
            }            
        }

        inKeyUpHandler = false;
    }

    /**
     *  @private
     */
    private function drawButtonFocus(index:int, focused:Boolean):void
    {
        var n:int = dataProvider ? dataProvider.length : 0;
        if (n > 0 && index < n)
        {
            var renderer:IItemRenderer = 
                dataGroup.getElementAt(index) as IItemRenderer;
            if (renderer)
                renderer.showsCaret = focused;
        }
    }
}

}

