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

package spark.skins.mobile.supportClasses
{
import mx.core.IFlexDisplayObject;
import mx.core.ILayoutElement;
import mx.core.UIComponent;

/**
 *  Actionscript based skin for mobile applications. This skin is the 
 *  base class for all of the actionscript mobile skins. As an optimization, 
 *  it removes state transition support.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
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
            _currentState = value;
            commitCurrentState();
        }
    }
        
    /**
     *  Called whenever the currentState changes. Skins should override
     *  this function if they make any appearance changes during 
     *  a state change
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */ 
    protected function commitCurrentState():void
    {
    }

    /**
     *  A helper method for positioning skin parts.
     * 
     *  Developers can use this method instead of checking for and using
     *  various interfaces such as ILayoutElement, IFlexDisplayObject, etc.
     *
     *  @see #resizePart  
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected function positionPart(part:Object, x:Number, y:Number):void
    {
        if (part is ILayoutElement)
        {
            ILayoutElement(part).setLayoutBoundsPosition(x, y, false);
        }
        else if (part is IFlexDisplayObject)
        {
            IFlexDisplayObject(part).move(x, y);   
        }
        else
        {
            part.x = x;
            part.y = y;
        }
    }

    /**
     *  A helper method for resizing skin parts.
     * 
     *  Developers can use this method instead of checking for and using
     *  various interfaces such as ILayoutElement, IFlexDisplayObject, etc.
     *
     *  @see #positionPart  
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected function resizePart(part:Object, width:Number, height:Number):void
    {
        if (part is ILayoutElement)
        {
            ILayoutElement(part).setLayoutBoundsSize(width, height, false);
        }
        else if (part is IFlexDisplayObject)
        {
            IFlexDisplayObject(part).setActualSize(width, height);
        }
        else
        {
            part.width = width;
            part.height = height;
        }
    }
}
}