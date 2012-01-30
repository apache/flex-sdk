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

package spark.skins
{
import mx.core.UIComponent;

/**
 *  Actionscript based skin for mobile applications. This skin is the 
 *  base class for all of the actionscript mobile skins. As an optimization, 
 *  it removes state transition support.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class MobileSkin extends UIComponent 
{
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    public function MobileSkin()
    {
    }
    
    //----------------------------------
    //  currentState
    //----------------------------------
    
    private var _currentState:String;
    
    /**
     *  @private 
     */ 
    override public function get currentState():String
    {
        return _currentState;
    }
    
    /**
     *  @private 
     */ 
    override public function set currentState(value:String):void
    {
        if (value != _currentState)
        {
            _previoustState = _currentState;
            _currentState = value;
            commitCurrentState();
        }
    }
    
    //----------------------------------
    //  previousState
    //----------------------------------
    
    private var _previoustState:String;
    
    /**
     *  The previous value of currentState 
     */ 
    protected function get previousState():String
    {
        return _previoustState;
    }
        
    /**
     *  Called whenever the currentState changes. Skins should override
     *  this function if they make any appearance changes during 
     *  a state change
     */ 
    protected function commitCurrentState():void
    {
    }
}
}