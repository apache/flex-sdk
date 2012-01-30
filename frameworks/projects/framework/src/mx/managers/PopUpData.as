////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.managers
{

import flash.display.DisplayObject;
import flash.geom.Rectangle;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;
import flash.display.Stage;
import flash.geom.Point;

import mx.core.IUIComponent;
import mx.core.mx_internal;
import mx.effects.Effect;
import mx.events.SandboxMouseEvent;
import mx.managers.ISystemManager;
import mx.managers.PopUpManagerImpl;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: PopUpData
//
////////////////////////////////////////////////////////////////////////////////
[ExcludeClass]

/**
 *  @private
 */
public class PopUpData
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function PopUpData()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     * 
     *  The popup in the normal case but will null in the case where only a 
     *  modal window is displayed over an application.
     */
    public var owner:DisplayObject;

    /**
     *  @private
     */
    public var parent:DisplayObject;

    /**
     *  @private
     */
    public var topMost:Boolean;

    /**
     *  @private
     */
    public var modalWindow:DisplayObject;

    /**
     *  @private
     */
    public var _mouseDownOutsideHandler:Function;

    /**
     *  @private
     */
    public var _mouseWheelOutsideHandler:Function;

    /**
     *  @private
     */
    public var fade:Effect;

    /**
     *  @private
     */
    public var blur:Effect;
    
    /**
     *  @private
     * 
     */
    public var blurTarget:Object;
     
    /**
     *   @private
     * 
     *   The host of the modal dialog.
     */
    public var systemManager:ISystemManager;

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    public function mouseDownOutsideHandler(event:MouseEvent):void
    {
        _mouseDownOutsideHandler(owner, event);
    }

    /**
     *  @private
     */
    public function mouseWheelOutsideHandler(event:MouseEvent):void
    {
        _mouseWheelOutsideHandler(owner, event);
    }

    /**
     *  @private
     *  Set by PopUpManager on modal windows to make sure they cover the whole screen
     */
    public function resizeHandler(event:Event):void
    {
        var s:Rectangle = ISystemManager(event.target).screen;  
        
        if (modalWindow && owner.stage == DisplayObject(event.target).stage)
        {
            modalWindow.width = s.width;
            modalWindow.height = s.height;
            modalWindow.x = s.x;
            modalWindow.y = s.y;
        }
    }
}

}
