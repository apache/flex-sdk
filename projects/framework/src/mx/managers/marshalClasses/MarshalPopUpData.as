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

package mx.managers.marshalClasses
{

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;

import mx.core.IUIComponent;
import mx.core.mx_internal;
import mx.effects.Effect;
import mx.events.SandboxMouseEvent;
import mx.managers.ISystemManager;
import mx.managers.PopUpData;

use namespace mx_internal;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: MarshalPopUpData
//
////////////////////////////////////////////////////////////////////////////////
[ExcludeClass]

/**
 *  @private
 */
public class MarshalPopUpData extends PopUpData
{
 
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function MarshalPopUpData()
    {
        super();
        useExclude = true;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    //--------------------------------------
    //  fields only for remote modal windows
    //--------------------------------------

    /**
     *   @private
     * 
     *   Is this popup just a modal window for a popup 
     *   in an untrusted sandbox?
     */
    public var isRemoteModalWindow:Boolean;
    
    /**
     *   @private
     */
    public var modalTransparencyDuration:Number;
    
    /**
     *   @private
     */
    public var modalTransparency:Number;
    
    /**
     *   @private
     */
    public var modalTransparencyBlur:Number;
    
    /**
     *   @private
     */
    public var modalTransparencyColor:Number;
    
    /**
     *   @private
     * 
     *   Object to exclude from the modal dialog. The area of the 
     *   display object will be excluded from the modal dialog.
     */  
    public var exclude:IUIComponent;
    
    /**
     *   @private
     * 
     *   Flag to determine if the exclude property should be used
     *   or ignored. Typically the exclude field is used when a
     *   SystemManager contains its exclude child. But this isn't
     *   true when the child is in a pop up window. In this case
     *   useExclude is false.
     */  
    public var useExclude:Boolean;
     
    /**
     *   @private
     * 
     *   Rectangle to exclude from the <code>exclude</code> component
     *   which is in turn excluded from the modal dialog.
     *   This is passed within a sandbox so A.2 can tell A what
     *   the size of A.2.3 was. Each top-level application
     *   calculates excludeRect if there is mutual trust with its parent. 
     *   If there is no trust this property will be null.
     */  
    public var excludeRect:Rectangle;
     
    /**
     *   @private
     * 
     *   Mask created from the modalWindow and exclude fields.
     */  
    public var modalMask:Sprite;

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    public function marshalMouseOutsideHandler(event:Event):void
    {
        if (!(event is SandboxMouseEvent))
            event = SandboxMouseEvent.marshal(event);
            
        if (owner)
            owner.dispatchEvent(event);
    }

    /**
     *  @private
     *  Set by PopUpManager on modal windows to make sure they cover the whole screen
     */
    override public function resizeHandler(event:Event):void
    {
        // Resize the modal window if either the popup or the modal window are on the
        // same stage as the resize event target.
        // A modal window may have no popup in the case where the popup originated
        // from an untrusted application.
        if ((owner && owner.stage == DisplayObject(event.target).stage) ||
            (modalWindow && modalWindow.stage == DisplayObject(event.target).stage))
        {
            var s:Rectangle = systemManager.screen;  
        
            modalWindow.width = s.width;
            modalWindow.height = s.height;
            modalWindow.x = s.x;
            modalWindow.y = s.y;
            if (modalMask)
                PopUpManagerMarshalMixin.updateModalMask(systemManager, modalWindow, 
                                                              exclude, excludeRect, modalMask);    
        }
    }
}

}
