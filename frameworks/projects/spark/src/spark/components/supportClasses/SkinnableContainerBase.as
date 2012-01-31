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
import flash.display.Sprite;

import mx.components.baseClasses.FxComponent;

import mx.managers.IFocusManagerContainer;


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
        updateMouseShield();
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
        
        if (mouseShield)
        {
            mouseShield.width = unscaledWidth;
            mouseShield.height = unscaledHeight;
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Private methods
    //
    //--------------------------------------------------------------------------
     
    /**
     *  @private
     *  Mouse shield that is put up when this component is disabled.
     */
    private var mouseShield:Sprite;
    
    /**
     *  @private
     */
	private function updateMouseShield():void
	{
        if (enabled)
        {
            if (mouseShield)
            {
                removeChild(mouseShield);
                mouseShield = null;
            }
        }
        else
        {
            if (!mouseShield)
            {
				// Create a 100x100 invisible shape that will
				// be scaled to the component size by 
				// setting width and height, below.
				mouseShield = new Sprite();
				mouseShield.graphics.beginFill(0, 0);
				mouseShield.graphics.drawRect(0, 0, 100, 100);
				mouseShield.graphics.endFill();
				addChild(mouseShield);
            }
            
            mouseShield.width = width;
            mouseShield.height = height;
        }
    }
}
}