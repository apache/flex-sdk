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

package mx.managers
{

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.ui.Mouse;
import mx.core.ApplicationGlobals;
import mx.core.EventPriority;
import mx.core.FlexSprite;
import mx.core.mx_internal;
import mx.core.IUIComponent;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 */
public class CursorManagerImpl implements ICursorManager
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private static var instance:ICursorManager;

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    public static function getInstance():ICursorManager
    {
        if (!instance)
            instance = new CursorManagerImpl();

        return instance;
    }

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    public function CursorManagerImpl(systemManager:ISystemManager = null)
    {
        super();

        if (instance && !systemManager)
            throw new Error("Instance already exists.");

		if (systemManager)
			this.systemManager = systemManager;
		else
			this.systemManager = ApplicationGlobals.application.systemManager;

    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var nextCursorID:int = 1;
    
    /**
     *  @private
     */
    private var cursorList:Array = [];
    
    /**
     *  @private
     */
    private var busyCursorList:Array = [];
    
    /**
     *  @private
     */
    private var initialized:Boolean = false;
    
    /**
     *  @private
     */
    private var cursorHolder:Sprite;
    
    /**
     *  @private
     */
    private var currentCursor:DisplayObject;

	/**
     *  @private
     */
	private var listenForContextMenu:Boolean = false;
    
    /**
     *  @private
     */
    private var overTextField:Boolean = false;
    
    /**
     *  @private
     */
    private var overLink:Boolean = false;
    
    /**
     *  @private
     */
    private var showSystemCursor:Boolean = false;
    
    /**
     *  @private
     */
    private var showCustomCursor:Boolean = false;
    
    /**
     *  @private
     */
    private var systemManager:ISystemManager = null;
    
    /**
     *  @private
     */
    private var sourceArray:Array = [];

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  currentCursorID
    //----------------------------------

    /**
     *  @private
     */
    private var _currentCursorID:int = 0 /* CursorManager.NO_CURSOR */;

    /**
     *  ID of the current custom cursor,
     *  or CursorManager.NO_CURSOR if the system cursor is showing.
     */
    public function get currentCursorID():int
    {
        return _currentCursorID;
    }
    
    /**
     *  @private
     */
    public function set currentCursorID(value:int):void
    {
        _currentCursorID = value;
    }

    //----------------------------------
    //  currentCursorXOffset
    //----------------------------------

    /**
     *  @private
     */
    private var _currentCursorXOffset:Number = 0;

    /**
     *  The x offset of the custom cursor, in pixels,
     *  relative to the mouse pointer.
     *       
     *  @default 0
     */
    public function get currentCursorXOffset():Number 
    {
        return _currentCursorXOffset;
    }
    
    /**
     *  @private
     */
    public function set currentCursorXOffset(value:Number):void
    {
        _currentCursorXOffset = value;
    }

    //----------------------------------
    //  currentCursorYOffset
    //----------------------------------

    /**
     *  @private
     */
    private var _currentCursorYOffset:Number = 0;

    /**
     *  The y offset of the custom cursor, in pixels,
     *  relative to the mouse pointer.
     *
     *  @default 0
     */
    public function get currentCursorYOffset():Number 
    {
        return _currentCursorYOffset;
    }
    
    /**
     *  @private
     */
    public function set currentCursorYOffset(value:Number):void
    {
        _currentCursorYOffset = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Makes the cursor visible.
     *  Cursor visibility is not reference-counted.
     *  A single call to the <code>showCursor()</code> method
     *  always shows the cursor regardless of how many calls
     *  to the <code>hideCursor()</code> method were made.
     */
    public function showCursor():void
    {
        if (cursorHolder)
	        cursorHolder.visible = true;
    }
    
    /**
     *  Makes the cursor invisible.
     *  Cursor visibility is not reference-counted.
     *  A single call to the <code>hideCursor()</code> method
     *  always hides the cursor regardless of how many calls
     *  to the <code>showCursor()</code> method were made.
     */
    public function hideCursor():void
    {
    	if (cursorHolder)
	        cursorHolder.visible = false;
    }

    /**
     *  Creates a new cursor and sets an optional priority for the cursor.
     *  Adds the new cursor to the cursor list.
     *
     *  @param cursorClass Class of the cursor to display.
     *
     *  @param priority Integer that specifies
     *  the priority level of the cursor.
     *  Possible values are <code>CursorManagerPriority.HIGH</code>,
     *  <code>CursorManagerPriority.MEDIUM</code>, and <code>CursorManagerPriority.LOW</code>.
     *
     *  @param xOffset Number that specifies the x offset
     *  of the cursor, in pixels, relative to the mouse pointer.
     *
     *  @param yOffset Number that specifies the y offset
     *  of the cursor, in pixels, relative to the mouse pointer.
     *
     *  @param setter The IUIComponent that set the cursor. Necessary (in multi-window environments) 
     *  to know which window needs to display the cursor. 
     * 
     *  @return The ID of the cursor.
     *
     *  @see mx.managers.CursorManagerPriority
     */
    public function setCursor(cursorClass:Class, priority:int = 2,
                                     xOffset:Number = 0,
                                     yOffset:Number = 0):int 
    {
        /*
        if (!cursorHolder._target)
        {
            // We may have been reloaded by a shell so reset everything.
            currentCursorID = CursorManager.NO_CURSOR;
            nextCursorID = 1;
            cursorList = [];
            busyCursorList = [];
            initialized = false;
            overTextField = false;
            overLink = false;
        }
        */
        
        var cursorID:int = nextCursorID++;
        
        // Create a new CursorQueueItem.
        var item:CursorQueueItem = new CursorQueueItem();
        item.cursorID = cursorID;
        item.cursorClass = cursorClass;
        item.priority = priority;
        item.x = xOffset;
        item.y = yOffset;
        if (systemManager)
        	item.systemManager = systemManager;
        else
        	item.systemManager = ApplicationGlobals.application.systemManager;
        
        // Push it onto the cursor list.
        cursorList.push(item);
        
        // Re-sort the cursor list based on priority level.
        cursorList.sort(priorityCompare);

        // Determine which cursor to display
        showCurrentCursor();
        
        return cursorID;
    }
    
    /**
     *  @private
     */
    private function priorityCompare(a:CursorQueueItem, b:CursorQueueItem):int
    {
        if (a.priority < b.priority)
            return -1;
        else if (a.priority == b.priority)
            return 0;
        
        return 1;
    }

    /**
     *  Removes a cursor from the cursor list.
     *  If the cursor being removed is the currently displayed cursor,
     *  the CursorManager displays the next cursor in the list, if one exists.
     *  If the list becomes empty, the CursorManager displays
     *  the default system cursor.
     *
     *  @param cursorID ID of cursor to remove.
     */
    public function removeCursor(cursorID:int):void 
    {
        for (var i:Object in cursorList)
        {
            var item:CursorQueueItem = cursorList[i];
            if (item.cursorID == cursorID)
            {
                // Remove the element from the array.
                cursorList.splice(i, 1); 

                // Determine which cursor to display.
                showCurrentCursor();
                    
                break;
            }
        }
    }
    
    /**
     *  Removes all of the cursors from the cursor list
     *  and restores the system cursor.
     */
    public function removeAllCursors():void
    {
        cursorList.splice(0);
        
        showCurrentCursor();
    }

    /**
     *  Displays the busy cursor.
     *  The busy cursor has a priority of CursorManagerPriority.LOW.
     *  Therefore, if the cursor list contains a cursor
     *  with a higher priority, the busy cursor is not displayed 
     *  until you remove the higher priority cursor.
     *  To create a busy cursor at a higher priority level,
     *  use the <code>setCursor()</code> method.
     */
    public function setBusyCursor():void 
    {
        var cursorManagerStyleDeclaration:CSSStyleDeclaration =
            StyleManager.getStyleDeclaration("CursorManager");
        
        var busyCursorClass:Class =
            cursorManagerStyleDeclaration.getStyle("busyCursor");
        
        busyCursorList.push(setCursor(busyCursorClass, CursorManagerPriority.LOW));
    }

    /**
     *  Removes the busy cursor from the cursor list.
     *  If other busy cursor requests are still active in the cursor list,
     *  which means you called the <code>setBusyCursor()</code> method more than once,
     *  a busy cursor does not disappear until you remove
     *  all busy cursors from the list.
     */
    public function removeBusyCursor():void 
    {
        if (busyCursorList.length > 0)
            removeCursor(int(busyCursorList.pop()));
    }

    /**
     *  @private
     *  Decides what cursor to display.
     */
    private function showCurrentCursor():void 
    {
        var app:InteractiveObject;
        var sm:InteractiveObject;
            
        if (cursorList.length > 0)
        {
            if (!initialized)
            {
                // The first time a cursor is requested of the CursorManager,
                // create a Sprite to hold the cursor symbol
                cursorHolder = new FlexSprite();
                cursorHolder.name = "cursorHolder";
                cursorHolder.mouseEnabled = false;
          //      systemManager.cursorChildren.addChild(cursorHolder);

                initialized = true;
            }

            // Get the top most cursor.
            var item:CursorQueueItem = cursorList[0];
                
            // If the system cursor was being displayed, hide it.
            if (currentCursorID == CursorManager.NO_CURSOR)
                Mouse.hide();
			
            // If the current cursor has changed...
            if (item.cursorID != currentCursorID)
            {
                if (cursorHolder.numChildren > 0)
                    cursorHolder.removeChildAt(0);
                
                currentCursor = new item.cursorClass(); 
                
                if (currentCursor)
                {
                    if (currentCursor is InteractiveObject)
                        InteractiveObject(currentCursor).mouseEnabled = false;
                    //Figure out which systemManager to hang the cursor off of. 
                    var tempSystemManager:ISystemManager = item.systemManager 
                    				? item.systemManager 
                    				: ApplicationGlobals.application.systemManager;
                    //If this is a different systemManager, remove it from the old one. 
                    if (systemManager && (systemManager != tempSystemManager))
                    	systemManager.cursorChildren.removeChild(cursorHolder);
                    systemManager = tempSystemManager;
                    if (!systemManager.cursorChildren.contains(cursorHolder))
                    	systemManager.cursorChildren.addChild(cursorHolder);
                    cursorHolder.addChild(currentCursor);
                    
                    if (!listenForContextMenu)
                    {
                    	app = systemManager.document as InteractiveObject;
                    	if (app && app.contextMenu)
                    	{
                    		app.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, contextMenu_menuSelectHandler);
                    		listenForContextMenu = true;
                    	}
                    	sm = systemManager as InteractiveObject;
                    	if (sm && sm.contextMenu)
                    	{
                    		sm.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, contextMenu_menuSelectHandler);
                    		listenForContextMenu = true;
                    	}     	
                    } 
                    //make sure systemManager is not other implementation of ISystemManager
                    if (systemManager is SystemManager)
                    {	
                    	cursorHolder.x = SystemManager(systemManager).mouseX + item.x;
                    	cursorHolder.y = SystemManager(systemManager).mouseY + item.y;
                    } 
                    //WindowedSystemManager
                    else if (systemManager is DisplayObject)
                    {
                    	cursorHolder.x = DisplayObject(systemManager).mouseX + item.x;
                    	cursorHolder.y = DisplayObject(systemManager).mouseY + item.y;
                    }
                    //otherwise
                    else
                    {
                    	cursorHolder.x = item.x;
                    	cursorHolder.y = item.y;
                    }
                                       	
                    systemManager.stage.addEventListener(MouseEvent.MOUSE_MOVE,
                                                   mouseMoveHandler,true,EventPriority.CURSOR_MANAGEMENT);
                }
            	
                currentCursorID = item.cursorID;
                currentCursorXOffset = item.x;
                currentCursorYOffset = item.y;
            }
        } 
        else 
        {
            if (currentCursorID != CursorManager.NO_CURSOR)
            {
                // There is no cursor in the cursor list to display,
                // so cleanup and restore the system cursor.
                currentCursorID = CursorManager.NO_CURSOR;
                currentCursorXOffset = 0;
                currentCursorYOffset = 0;
                systemManager.stage.removeEventListener(MouseEvent.MOUSE_MOVE,
                                                  mouseMoveHandler,true);
                cursorHolder.removeChild(currentCursor);
                
                 if (listenForContextMenu)
                {
                	app = systemManager.document as InteractiveObject;
                	if (app && app.contextMenu)
                		app.contextMenu.removeEventListener(ContextMenuEvent.MENU_SELECT, contextMenu_menuSelectHandler);

                	sm = systemManager as InteractiveObject;
                	if (sm && sm.contextMenu)
                		sm.contextMenu.removeEventListener(ContextMenuEvent.MENU_SELECT, contextMenu_menuSelectHandler);
   
                	listenForContextMenu = false; 	
                } 
            }
            Mouse.show();
        }
    }
    
    /**
     *  @private
     *  Called by other components if they want to display
     *  the busy cursor during progress events.
     */
    public function registerToUseBusyCursor(source:Object):void
    {
        if (source && source is EventDispatcher) 
        {
            source.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            source.addEventListener(Event.COMPLETE, completeHandler);
            source.addEventListener(IOErrorEvent.IO_ERROR, completeHandler);
        }
    }

    /**
     *  @private
     *  Called by other components to unregister
     *  a busy cursor from the progress events.
     */
    public function unRegisterToUseBusyCursor(source:Object):void
    {
        if (source && source is EventDispatcher) 
        {
            source.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
            source.removeEventListener(Event.COMPLETE, completeHandler);
            source.removeEventListener(IOErrorEvent.IO_ERROR, completeHandler);
        }
    }
    
    /**
     *  @private
     *  Called when contextMenu is opened
     */
    private function contextMenu_menuSelectHandler(event:ContextMenuEvent):void
    {
    	showCustomCursor = true; // Restore the custom cursor
    	// Standalone player doesn't initially send mouseMove when the contextMenu is closed,
    	// so we need to listen for mouseOver as well.   	
    	systemManager.stage.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
    }
    
    /**
     *  @private
     */
    private function mouseOverHandler(event:MouseEvent):void
    {
    	systemManager.stage.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
    	mouseMoveHandler(event);
    }
    
    /**
     *  @private
     */
    private function findSource(target:Object):int
    {
        var n:int = sourceArray.length;
        for (var i:int = 0; i < n; i++)
        {
            if (sourceArray[i] === target)
                return i;
        }
        return -1;
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function mouseMoveHandler(event:MouseEvent):void
    {
        //trace("mouseMove target", event.target);
        //trace("mouseMove x", event.localX, "y", event.localY,
        //            "root=cursorHolder?", rootApplication === cursorHolder);

		if (systemManager is SystemManager)
        {	
        	cursorHolder.x = SystemManager(systemManager).mouseX + currentCursorXOffset;
        	cursorHolder.y = SystemManager(systemManager).mouseY + currentCursorYOffset;
        }
        else if (systemManager is DisplayObject)
        {
        	cursorHolder.x = DisplayObject(systemManager).mouseX + currentCursorXOffset;
        	cursorHolder.y = DisplayObject(systemManager).mouseY + currentCursorYOffset;
        } 
        else
        {
        	cursorHolder.x = currentCursorXOffset;
        	cursorHolder.y = currentCursorYOffset;
        }
        
        var target:Object = event.target;
        
        // Do target test.
        if (!overTextField &&
            target is TextField && target.type == TextFieldType.INPUT)
        {   
            overTextField = true;
            showSystemCursor = true;
        } 
        else if (overTextField &&
                 !(target is TextField && target.type == TextFieldType.INPUT))
        {
            overTextField = false;
            showCustomCursor = true;
        }
        
        // Handle switching between system and custom cursor.
        if (showSystemCursor)
        {
            showSystemCursor = false;
            cursorHolder.visible = false;
            Mouse.show();
        }
        if (showCustomCursor)
        {
            showCustomCursor = false;
            cursorHolder.visible = true;
            Mouse.hide();
        }
    }
    
    /**
     *  @private
     *  Displays the busy cursor if a component is in a busy state.
     */
    private function progressHandler(event:ProgressEvent):void
    {
        // Only pay attention to the first progress call. Ignore all others.
        var sourceIndex:int = findSource(event.target);
        if (sourceIndex == -1)
        {
            // Add the target to the list of objects we are listening for.
            sourceArray.push(event.target);
            
            setBusyCursor();
        }
    }
    
    /**
     *  @private
     */
    private function completeHandler(event:Event):void
    {
        var sourceIndex:int = findSource(event.target);
        if (sourceIndex != -1)
        {
            // Remove from the list of targets we are listening to.
            sourceArray.splice(sourceIndex, 1);
            
            removeBusyCursor();
        }
    }

}

}

import mx.managers.CursorManager;
import mx.managers.CursorManagerPriority;
import mx.managers.ISystemManager;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: CursorQueueItem
//
////////////////////////////////////////////////////////////////////////////////

/**
 *  @private
 */
class CursorQueueItem
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     */
    public function CursorQueueItem()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    public var cursorID:int = CursorManager.NO_CURSOR;

    /**
     *  @private
     */
    public var cursorClass:Class = null;

    /**
     *  @private
     */
    public var priority:int = CursorManagerPriority.MEDIUM;
    
     /**
     *  @private
     */
    public var systemManager:ISystemManager;

    /**
     *  @private
     */
    public var x:Number;

    /**
     *  @private
     */
    public var y:Number;
}

