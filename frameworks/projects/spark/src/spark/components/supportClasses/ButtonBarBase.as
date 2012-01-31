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

package spark.components.supportClasses
{
import flash.events.Event;
import flash.events.EventPhase;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.collections.IList;
import mx.core.EventPriority;
import mx.core.IFactory;
import mx.core.ISelectableList;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;
import mx.managers.IFocusManagerComponent;

import spark.components.ButtonBarButton;
import spark.components.IItemRenderer;
import spark.events.IndexChangeEvent;
import spark.events.RendererExistenceEvent;

use namespace mx_internal;  // use of ListBase/setCurrentCaretIndex(index);

[AccessibilityClass(implementation="spark.accessibility.ButtonBarBaseAccImpl")]
/**
 *  The ButtonBarBase class defines the common behavior for the ButtonBar, TabBar and similar subclasses.   
 *  This class does not add any new API however it refines selection, keyboard focus and keyboard navigation
 *  behavior for the control's ItemRenderer elements.   
 *  This base class is not intended to be instantiated directly.
 * 
 *  <p>Clicking on an ItemRenderer selects it by setting the <code>selectedIndex</code> and the 
 *  <code>caretIndex</code> properties.  If <code>requireSelection</code> is <code>false</code>, then clicking 
 *  again deselects it.  If the data provider is an <code>ISelectableList</code> object, then its 
 *  <code>selectedIndex</code> is set as well.</p> 
 * 
 *  <p>Arrow key events are handled by adjusting the <code>caretIndex</code>.    
 *  If <code>arrowKeysWrapFocus</code> is <code>true</code>, then the <code>caretIndex</code> wraps.  
 *  Pressing the Space key selects the ItemRenderer at the <code>caretIndex</code>.</p>
 * 
 *  <p>The <code>showsCaret</code> property of the ItemRenderer at <code>caretIndex</code> 
 *  is set to <code>true</code> when the ButtonBarBase object has focus and 
 *  the <code>caretIndex</code> was reached as a consequence
 *  of a keyboard gesture.   
 *  If the <code>caretIndex</code> was set as a side effect of responding to a 
 *  mouse click, then <code>showsCaret</code> is not set.</p>
 * 
 *  <p>The <code>allowDeselection</code> property of <code>ButtonBarButton</code> 
 *  ItemRenderers is set to <code>!requireSelection</code>.</p>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:ButtonBarBase&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds no new tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:ButtonBarBase/&gt;
 *  </pre> 
  * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
public class ButtonBarBase extends ListBase
{
    include "../../core/Version.as";    

    //--------------------------------------------------------------------------
    //
    //  Class mixins
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Placeholder for mixin by ButtonBarBaseAccImpl.
     */
    mx_internal static var createAccessibilityImplementation:Function;

    /**
     *  Constructor.
     * 
     *  <p>Initializes tab processing: tabbing to this component will give it the focus, but not 
     *  clicking on it with the mouse.  Tabbing to the children is disabled.</p> 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function ButtonBarBase()
    {
        super();
        
        tabChildren = false;
        tabEnabled = true;
        tabFocusEnabled = true;
        setCurrentCaretIndex(0);        
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  If false, don't show the focusRing for the tab at caretIndex, see
     *  itemShowingCaret() below.
     * 
     *  If the caret index changes because of something other than a arrow
     *  or space keypress then we don't show the focus ring, i.e. we do not 
     *  set showsCaret=true for the item renderer at caretIndex.
     *     
     *  This flag is valid at commitProperties() time.  It's set to false
     *  if at least one selectedIndex change (see item_clickHandler()) occurred 
     *  because of a mouse click.
     */
    private var enableFocusHighlight:Boolean = true;
    
    /**
     *  @private
     */    
    private var inCollectionChangeHandler:Boolean = false;
    
    /**
     *  @private
     *  Used to distinguish item_clickHandler() calls initiated by the mouse, from calls
     *  initiated by pressing the space bar.
     */
    private var inKeyUpHandler:Boolean = false;
    
    /**
     *  @private
     *  Index of item that is currently pressed by the
     *  spacebar.
     */
    private var pressedIndex:Number;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  requireSelection
    //---------------------------------- 
    
    private var requireSelectionChanged:Boolean;
    
    /**
     *  @private
     *  See commitProperties(). 
     */
    override public function set requireSelection(value:Boolean):void
    {
        if (value == requireSelection)
            return;
        
        super.requireSelection = value;
        requireSelectionChanged = true;
        invalidateProperties();
    }
    
    //----------------------------------
    //  dataProvider
    //----------------------------------
    
    /**
     *  @private
     */    
    override public function set dataProvider(value:IList):void
    {
        if (dataProvider is ISelectableList)
        {
            dataProvider.removeEventListener(FlexEvent.VALUE_COMMIT, dataProvider_changeHandler);
            dataProvider.removeEventListener(IndexChangedEvent.CHANGE, dataProvider_changeHandler);
        }
        
        if (value is ISelectableList)
        {
            value.addEventListener(FlexEvent.VALUE_COMMIT, dataProvider_changeHandler);
            value.addEventListener(IndexChangedEvent.CHANGE, dataProvider_changeHandler);
        }
        
        super.dataProvider = value;
        
        if (value is ISelectableList)
            selectedIndex = ISelectableList(dataProvider).selectedIndex;
    }    
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Called by the initialize() method of UIComponent
     *  to hook in the accessibility code.
     */
    override protected function initializeAccessibility():void
    {
        if (ButtonBarBase.createAccessibilityImplementation != null)
            ButtonBarBase.createAccessibilityImplementation(this);
    }
    
    /**
     *  @private
     *  if the collection is changing and the collection is a viewstack
     *  the viewstack will also adjust the selection and notify us
     *  via dataProvider_changeHandler so we want to 
     *  ignore calls to adjustSelection that the base class
     *  calls so we don't increment or decrement
     *  selectedIndex twice
     */
    override protected function dataProvider_collectionChangeHandler(event:Event):void
    {
        inCollectionChangeHandler = true;

        super.dataProvider_collectionChangeHandler(event);

        inCollectionChangeHandler = false;

    }

    /**
     *  @private
     */
    override protected function adjustSelection(newIndex:int, add:Boolean=false):void
    {
        // see comment in dataProvider_collectionChangeHandler
        if (inCollectionChangeHandler && dataProvider is ISelectableList)
            return;

        super.adjustSelection(newIndex, add);
    }

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (requireSelectionChanged && dataGroup)
        {
            requireSelectionChanged = false;
            const n:int = dataGroup.numElements;
            for (var i:int = 0; i < n; i++)
            {
                var renderer:ButtonBarButton = dataGroup.getElementAt(i) as ButtonBarButton;
                if (renderer)
                    renderer.allowDeselection = !requireSelection;
            }
        }
        
        enableFocusHighlight = true;
    }    
    
    /**
     *  @private
     *  Return the item renderer at the specified index, or null.
     */
    private function getItemRenderer(index:int):IVisualElement
    {
        if (!dataGroup || (index < 0) || (index >= dataGroup.numElements))
            return null;
        
        return dataGroup.getElementAt(index);
    }
    
    /**
     *  @private
     *  Called when setCurrentCaretIndex() moves the caret, or when it's moved as a consequence
     *  of items being moved/removed.   See ListBase/caretIndexAdjusted.
     */
    override protected function itemShowingCaret(index:int, showsCaret:Boolean):void
    {
        super.itemShowingCaret(index, showsCaret);
        
        const renderer:IVisualElement = getItemRenderer(index);
        if (renderer)
        {
            const hasFocus:Boolean = focusManager && (focusManager.getFocus() == this);
            renderer.depth = (showsCaret) ? 1 : 0;
            if (renderer is IItemRenderer)   
                IItemRenderer(renderer).showsCaret = showsCaret && enableFocusHighlight && hasFocus;
        }
    }
    
    /**
     *  @private
     *  Called when the focus is gained/lost by tabbing in or out.
     */
    override public function drawFocus(isFocused:Boolean):void
    {
        const renderer:IVisualElement = getItemRenderer(caretIndex);
        if (renderer)
        {
            renderer.depth = (isFocused) ? 1 : 0;
            if (renderer is IItemRenderer)             
                IItemRenderer(renderer).showsCaret = isFocused;
        }
    }    
    
    /**
     *  @private
     */
    override protected function itemSelected(index:int, selected:Boolean):void
    {
        super.itemSelected(index, selected);
        
        const renderer:IItemRenderer = getItemRenderer(index) as IItemRenderer;
        if (renderer)
        {
            if (selected)
                setCurrentCaretIndex(index);  // causes itemShowingCaret() call
            renderer.selected = selected;
        }
        
        if ((dataProvider is ISelectableList) && selected)
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
            dataGroup.addEventListener(RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler);
            dataGroup.addEventListener(RendererExistenceEvent.RENDERER_REMOVE, dataGroup_rendererRemoveHandler);
        }
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == dataGroup)
        {
            dataGroup.removeEventListener(RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler);
            dataGroup.removeEventListener(RendererExistenceEvent.RENDERER_REMOVE, dataGroup_rendererRemoveHandler);
        }

        super.partRemoved(partName, instance);
    }
    
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function dataProvider_changeHandler(event:Event):void
    {
        selectedIndex = ISelectableList(dataProvider).selectedIndex;
    }
    
    /**
     *  @private
     */
    private function dataGroup_rendererAddHandler(event:RendererExistenceEvent):void
    {
        const renderer:IVisualElement = event.renderer; 
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
     */
    private function dataGroup_rendererRemoveHandler(event:RendererExistenceEvent):void
    {        
        const renderer:IVisualElement = event.renderer;
        if (renderer)
            renderer.removeEventListener(MouseEvent.CLICK, item_clickHandler);
    }
    
    /**
     *  @private
     *  Called synchronously when the space bar is pressed or the mouse is clicked. 
     */
    private function item_clickHandler(event:MouseEvent):void
    {
        var newIndex:int;
        if (event.currentTarget is IItemRenderer)
            newIndex = IItemRenderer(event.currentTarget).itemIndex;
        else
            newIndex = dataGroup.getElementIndex(event.currentTarget as IVisualElement);

        var oldSelectedIndex:int = selectedIndex;
        if (newIndex == selectedIndex)
        {
            if (!requireSelection)
                setSelectedIndex(NO_SELECTION, true);
        }
        else
            setSelectedIndex(newIndex, true);
        
        // Changing the selectedIndex typically causes a call to itemSelected() at 
        // commitProperties() time.   We'll update the caretIndex then.  If this 
        // method was -not- called as a consequence of a keypress, we will not show
        // the focus highlight at caretIndex.  See itemShowingCaret().
        
        if (enableFocusHighlight && (selectedIndex != oldSelectedIndex))
            enableFocusHighlight = inKeyUpHandler;
    }
    
    /**
     *  @private
     *  Increment or decrement the caretIndex.  Wrap if arrowKeysWrapFocus=true.
     */
    private function adjustCaretIndex(delta:int):void
    {
        if (!dataGroup || (caretIndex < 0))
            return;
        
        const oldCaretIndex:int = caretIndex;
        const length:int = dataGroup.numElements;
        
        if (arrowKeysWrapFocus)
            setCurrentCaretIndex((caretIndex + delta + length) % length);
        else
            setCurrentCaretIndex(Math.min(length - 1, Math.max(0, caretIndex + delta)));

        if (oldCaretIndex != caretIndex)
            dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CARET_CHANGE, false, false, oldCaretIndex, caretIndex)); 
    }
    
    /**
     *  @private
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        if (event.eventPhase == EventPhase.BUBBLING_PHASE)
            return;
        
        if (!enabled || !dataGroup || event.isDefaultPrevented())
            return;
        
        // Block input if space bar is being held down.
        if (!isNaN(pressedIndex))
        {
            event.preventDefault();
            return;
        }
        
        super.keyDownHandler(event);
        
        // If rtl layout, need to swap LEFT/UP and RIGHT/DOWN so correct action
        // is done.
        var keyCode:uint = mapKeycodeForLayoutDirection(event, true);
                        
        switch (keyCode)
        {
            case Keyboard.UP:
            case Keyboard.LEFT:
            {
                    adjustCaretIndex(-1);
                event.preventDefault();
                break;
            }
            case Keyboard.DOWN:
            case Keyboard.RIGHT:
            {
                    adjustCaretIndex(+1);
                event.preventDefault();
                break;
            }            
            case Keyboard.SPACE:
            {
                const renderer:IItemRenderer = getItemRenderer(caretIndex) as IItemRenderer;
                if (renderer && ((!renderer.selected && requireSelection) || !requireSelection))
                {
                    renderer.dispatchEvent(event);
                    pressedIndex = caretIndex;
                }
                break;
            }            
        }
    }
    
    /**
     *  @private
     */
    override protected function keyUpHandler(event:KeyboardEvent):void
    {
        if (event.eventPhase == EventPhase.BUBBLING_PHASE)
            return;
        
        if (!enabled)
            return;
        
        super.keyUpHandler(event);
        
        switch (event.keyCode)
        {
            case Keyboard.SPACE:
            {
                inKeyUpHandler = true;
                
                // Need to check pressedIndex for NaN for the case when key up
                // happens on an already selected renderer and under the condition
                // that requireSelection=true.
                if (!isNaN(pressedIndex))
                {
                    // Dispatch key up to the previously pressed item in case focus was lost
                    // through other interaction (e.g. mouse clicks, etc...)
                    const renderer:IItemRenderer = getItemRenderer(pressedIndex) as IItemRenderer;
                    if (renderer && ((!renderer.selected && requireSelection) || !requireSelection))
                    {
                        renderer.dispatchEvent(event);
                        pressedIndex = NaN;
                    }
                }
                inKeyUpHandler = false;
                break;
            }            
        }
    }
}
}