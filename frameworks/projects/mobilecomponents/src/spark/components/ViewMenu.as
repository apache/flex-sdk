////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//       
////////////////////////////////////////////////////////////////////////////////
package spark.components
{
import flash.display.StageOrientation;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.StageOrientationEvent;
import flash.ui.Keyboard;

import mx.core.FlexGlobals;
import mx.core.InteractionMode;
import mx.core.mx_internal;
import mx.events.SandboxMouseEvent;
import mx.managers.IFocusManagerComponent;

import spark.core.NavigationUnit;

use namespace mx_internal;

[DefaultProperty("items")]

//--------------------------------------
//  States
//--------------------------------------

/**
 *  Normal and landscape state.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[SkinState("normalAndLandscape")]

/**
 *  Closed and landscape state.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[SkinState("closedAndLandscape")]

/**
 *  Disabled and landscape state.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[SkinState("disabledAndLandscape")]

/**
 *  The ViewMenu container defines a menu in a View container.
 *  Each menu item is defined by using the ViewMenuItem control. 
 *  The application container automatically creates and displays a 
 *  ViewMenu container when the user presses the device's menu button. 
 *  You can also use the <code>ViewNavigatorApplicationBase.viewMenuOpen</code> property
 *  to open the menu programmatically.
 *
 *  <p>The following image shows a ViewMenu at the bottom of the screen 
 *  with five menu items:</p>
 *
 * <p>
 *  <img src="../../images/vm_open_menu_vm.png" alt="View menu" />
 * </p>
 *
 *  <p>The ViewMenuLayout class define the layout of the menu.
 *  Alternatively, you can create your own custom layout class.</p>
 *
 *  <p>Define the menu items by using the <code>View.viewMenuItems</code> property,
 *  as the following example shows:</p>
 *  
 *  <pre>
 *  &lt;s:View xmlns:fx="http://ns.adobe.com/mxml/2009" 
 *      xmlns:s="library://ns.adobe.com/flex/spark" 
 *      title="Home"&gt; 
 *
 *    ...
 *
 *    &lt;s:viewMenuItems&gt; 
 *        &lt;s:ViewMenuItem label="Add" click="itemClickInfo(event);"/&gt; 
 *        &lt;s:ViewMenuItem label="Cancel" click="itemClickInfo(event);"/&gt; 
 *        &lt;s:ViewMenuItem label="Delete" click="itemClickInfo(event);"/&gt; 
 *        &lt;s:ViewMenuItem label="Edit" click="itemClickInfo(event);"/&gt; 
 *        &lt;s:ViewMenuItem label="Search" click="itemClickInfo(event);"/&gt; 
 *    &lt;/s:viewMenuItems&gt;
 *
 *  &lt;/s:View&gt;
 *  </pre>
 *
 *  <p>Notice that you do not explicitly define the ViewMenu container in MXML. 
 *  The ViewMenu container is created automatically 
 *  to hold the ViewMenuItem controls.</p>
 *  
 *  @see spark.components.ViewMenuItem
 *  @see spark.layouts.ViewMenuLayout
 *  @see spark.components.supportClasses.ViewNavigatorApplicationBase
 *  @see spark.skins.mobile.ViewMenuSkin
 *
 *  @includeExample examples/ViewMenuExampleHome.mxml -noswf
 *  @includeExample examples/ViewMenuExample.mxml -noswf
 *
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
public class ViewMenu extends SkinnablePopUpContainer
                      implements IFocusManagerComponent
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
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function ViewMenu()
    {
        super();
        // Listen for orientation change events when we are attached to the stage
        addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    // Tracks whether the mouse is down on the ViewMenu. If so, prevent keyboard
    private var isMouseDown:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  caretIndex
    //----------------------------------
    
    private var _caretIndex:int = -1;
    private var oldCaretIndex:int = -1;
    private var caretIndexChanged:Boolean = false;
    
    /**
     *  The menu item that is currently in the caret state. 
     *  A value of -1 means that no item is in the caret state.  
     * 
     *  @default -1
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */   
    public function get caretIndex():int
    {
        return _caretIndex;
    }
    
    /**
     *  @private
     */   
    public function set caretIndex(value:int):void
    {
        if (_caretIndex == value)
            return;
     
        oldCaretIndex = _caretIndex;
        
        _caretIndex = value;
        caretIndexChanged = true;
        invalidateProperties();
    }
    
    //----------------------------------
    //  items
    //----------------------------------
    
    private var _items:Vector.<ViewMenuItem>;
    
    /**
     *  The Vector of ViewMenuItem controls to display 
     *  in the ViewMenu container.
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    public function get items():Vector.<ViewMenuItem>
    {
        return _items;
    }
    
    /**
     *  @private
     */   
    public function set items(value:Vector.<ViewMenuItem>):void
    {
        _items = value;
        
        var elements:Array = [];
        
        if (value)
        {
            for (var i:int = 0; i < value.length; i++)
            {
                elements.push(_items[i]);
            }
        }
        
        mxmlContent = elements;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */   
    override protected function commitProperties():void
    {
        super.commitProperties();
            
        if (caretIndexChanged)
        {
            caretIndexChanged = false;
            
            // Hide the old caret and show the new one
            setShowsCaret(oldCaretIndex, false);
            setShowsCaret(caretIndex, true);
        }
    }
    
    /**
     *  @private
     *  Build in basic keyboard navigation support in ViewMenu. 
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {   
        super.keyDownHandler(event);
                
        if (!items || !layout || event.isDefaultPrevented() || isMouseDown)
            return;
        
        // 3. Was a navigation key hit (like an arrow key,
        // or Shift+arrow key)?  
        // Delegate to the layout to interpret the navigation
        // key and adjust the selection and caret item based
        // on the combination of keystrokes encountered.      
        adjustSelectionAndCaretUponNavigation(event); 
    }
    
    /**
     *  @private
     */   
    override protected function getCurrentSkinState():String
    {
        var skinState:String = super.getCurrentSkinState();
        if (FlexGlobals.topLevelApplication.aspectRatio == "portrait")
            return super.getCurrentSkinState();
        else
            return skinState + "AndLandscape";                
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Adjusts the selection based on what keystroke or 
     *  keystroke combinations were encountered. The keystroke
     *  is sent down to the layout and it is up to the layout's
     *  getNavigationDestinationIndex() method to determine 
     *  what the index to navigate to based on the item that 
     *  is currently in focus. Once the index is determined, 
     *  single selection, caret item and if necessary, multiple 
     *  selections are updated to reflect the newly selected
     *  item.  
     *
     *  @param event The Keyboard Event encountered
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function adjustSelectionAndCaretUponNavigation(event:KeyboardEvent):void
    {
        // If rtl layout, need to swap Keyboard.LEFT and Keyboard.RIGHT.
        var navigationUnit:uint = mapKeycodeForLayoutDirection(event);
        
        // Some unrecognized key stroke was entered, return. 
        if (!NavigationUnit.isNavigationUnit(event.keyCode))
            return; 
        
        // Delegate to the layout to tell us what the next item is we should select or focus into.
        // TODO (dsubrama): At some point we should refactor this so we don't depend on layout
        // for keyboard handling. If layout doesn't exist, then use some other keyboard handler
        var proposedNewIndex:int = layout.getNavigationDestinationIndex(caretIndex, navigationUnit, false); 
        
        // Note that the KeyboardEvent is canceled even if the current selected or in focus index
        // doesn't change because we don't want another component to start handling these
        // events when the index reaches a limit.
        if (proposedNewIndex == -1)
            return;
        
        event.preventDefault(); 
        
        // Entering the caret state with the Ctrl key down 
        // TODO (rfrishbe): shouldn't just check interactionMode but should depend on 
        // either the platform or whether it was a 5-way button or whether 
        // soem other keyboardSelection style.
        if (event.ctrlKey || getStyle("interactionMode") == InteractionMode.TOUCH)
        {
            setShowsCaret(caretIndex, false);
            _caretIndex = proposedNewIndex;
            setShowsCaret(caretIndex, true);
        }
    }
   
    /**
     *  Called when a particular item is selected using the ENTER or SPACE key 
     *  @private
     */
    private function selectItemAt(index:int):void
    {
        if (index < 0 || !items || index >= items.length)
            return;
        
        var item:ViewMenuItem = ViewMenuItem(getElementAt(index));
        
        if (item.enabled)
            item.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
    }
    
    /**
     *  Helper function which updates the item's caret state
     *  @private
     */
    private function setShowsCaret(index:int, showsCaret:Boolean):void
    {
        if (index < 0 || !items || index >= items.length)
            return;
        
        var item:ViewMenuItem = ViewMenuItem(getElementAt(index));
        item.showsCaret = showsCaret;
        
        if (showsCaret)
            item.setFocus();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    private function addedToStageHandler(event:Event):void
    {
        addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
        systemManager.stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, orientationChangeHandler, true);
    }
    
    private function removedFromStageHandler(event:Event):void
    {
        removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
        systemManager.stage.removeEventListener(StageOrientationEvent.ORIENTATION_CHANGE, orientationChangeHandler, true);
    }
    
    private function orientationChangeHandler(event:StageOrientationEvent):void
    {
        invalidateSkinState();
    }
    
    private function mouseDownHandler(event:MouseEvent):void
    {
        // Clear the caret
        caretIndex = -1;
        
        isMouseDown = true;
        
        // Listen for mouse up anywhere
        systemManager.getSandboxRoot().addEventListener(
            MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true /* useCapture */);
        
        systemManager.getSandboxRoot().addEventListener(
            SandboxMouseEvent.MOUSE_UP_SOMEWHERE, systemManager_mouseUpHandler);
    }
    
    private function systemManager_mouseUpHandler(event:Event):void
    {
        systemManager.getSandboxRoot().removeEventListener(
            MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true /* useCapture */);
        
        systemManager.getSandboxRoot().removeEventListener(
            SandboxMouseEvent.MOUSE_UP_SOMEWHERE, systemManager_mouseUpHandler);
        
        isMouseDown = false;
    }
}
}