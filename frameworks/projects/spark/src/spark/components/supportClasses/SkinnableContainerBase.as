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

package mx.components.baseClasses
{
import flash.display.DisplayObject;

import mx.components.baseClasses.FxComponent;
import mx.managers.IFocusManagerContainer;
import mx.utils.MouseShieldUtil;


/**
 *  Skin states for this component.
 */
[SkinStates("normal", "disabled")]

/**
 *  Base class for skinnable container components.
 */
public class FxContainerBase extends FxComponent implements IFocusManagerContainer
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */
    public function FxContainerBase()
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
    override public function set enabled(value:Boolean):void
    {
        super.enabled = value;
        invalidateSkinState();
        
        // We update the mouseShield that prevents clicks to propagate to
        // children in our updateDisplayList.
        invalidateDisplayList();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
 
    /**
     *  @inheritDoc
     */
    override protected function getCurrentSkinState():String
    {
        return enabled ? "normal" : "disabled";
    }
    
    /**
     *  @inheritDoc
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        mouseShield = MouseShieldUtil.updateMouseShield(this, mouseShield);
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
     
    /**
     *  @private
     *  Mouse shield that is put up when this component is disabled.
     */
    private var mouseShield:DisplayObject;
}
}