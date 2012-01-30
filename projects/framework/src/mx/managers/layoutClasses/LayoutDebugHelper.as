
////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.managers.layoutClasses
{

import flash.display.Sprite;
import flash.events.Event;
import flash.utils.Dictionary;
import flash.utils.getTimer;
import flash.geom.Point;
import flash.geom.Rectangle;
import mx.core.ILayoutElement;

[ExcludeClass]

/**
 *  @private
 *  The LayoutDebugHelper class renders the layout bounds for the most
 *  recently validated visual items.
 */
public class LayoutDebugHelper extends Sprite
{
    include "../../core/Version.as";

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
    public function LayoutDebugHelper()
    {
        super();
        activeInvalidations = new Dictionary();
        addEventListener("enterFrame", onEnterFrame);
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private static const highlightDelay:Number = 2500;
    
    /**
     *  @private
     */
    private static const highlightColor:Number = 0xFF00;
    
    /**
     *  @private
     */
    private var activeInvalidations:Dictionary;
    
    /**
     *  @private
     */
    private var lastUpdate:Number = 0;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    public function addElement(item:ILayoutElement):void
    {       
        activeInvalidations[item] = getTimer();
    }
    
    /**
     *  @private
     */
    public function removeElement(item:ILayoutElement):void
    {       
        activeInvalidations[item] = null;
        delete activeInvalidations[item];
    }
   
    /**
     *  @private
     */
     import flash.display.DisplayObject;
    private function render():void
    {       
        graphics.clear();
        for (var item:* in activeInvalidations)
        {
            var lifespan:Number = getTimer() - activeInvalidations[item];
            if (lifespan > highlightDelay) 
            {
                removeElement(item);
            }
            else
            {
                var alpha:Number = 1.0 - (lifespan / highlightDelay);

                if (item.parent)
                { 
                    var w:Number = item.getLayoutBoundsWidth(true);
                    var h:Number = item.getLayoutBoundsHeight(true);
                    
                    var position:Point = new Point();
                    position.x = item.getLayoutBoundsX(true);
                    position.y = item.getLayoutBoundsY(true);
                    position = item.parent.localToGlobal(position);
                    
                    graphics.lineStyle(2, highlightColor, alpha);        
                    graphics.drawRect(position.x, position.y, w, h);
                    graphics.endFill();         
               }
            }
        }
    }
    
    /**
     *  @private
     */
    public function onEnterFrame(e:Event):void
    {       
        if (getTimer() - lastUpdate >= 100)
        {
            render();
            lastUpdate = getTimer();
        }
    }
}

}
