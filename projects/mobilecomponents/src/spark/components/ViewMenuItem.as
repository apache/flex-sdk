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
    
import flash.events.Event;
import flash.events.MouseEvent;

import spark.components.supportClasses.ButtonBase;
    
/**
 *  Caret State of the Button
 */
[SkinState("showsCaret")]

/**
 *  Displays a label and icon inside of an ViewMenu. Typically, you should 
 *  listen for the itemClick event to perform some operation based on clicking
 *  this item. 
 */ 
public class ViewMenuItem extends ButtonBase
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    /**
     *  Constructor 
     */ 
    public function ViewMenuItem()
    {
        super();
    }
    
    //----------------------------------
    //  showsCaret
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the showsCaret property 
     */
    private var _showsCaret:Boolean = false;
    
    /**
     *  True if the ViewMenuItem is in the caret state. 
     *
     *  @default false  
     */    
    public function get showsCaret():Boolean
    {
        return _showsCaret;
    }
    
    /**
     *  @private
     */    
    public function set showsCaret(value:Boolean):void
    {
        if (value == _showsCaret)
            return;
        
        _showsCaret = value;
        invalidateSkinState();
        invalidateDisplayList();
    }
    
    /**
     *  @private
     */
    override protected function getCurrentSkinState():String
    {
        var skinState:String = super.getCurrentSkinState();
        
        // showsCaret has lower priority than disabled and down states
        if (showsCaret && enabled && skinState != "down")
            return "showsCaret";
        
        return skinState;
    }

}
}