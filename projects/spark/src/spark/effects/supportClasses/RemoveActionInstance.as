////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.effects.supportClasses
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;

import spark.components.Group;

import mx.core.mx_internal;
import mx.effects.effectClasses.ActionEffectInstance;
import mx.core.IVisualElementContainer;

use namespace mx_internal;

/**
 *  The RemoveActionInstance class implements the instance class
 *  for the RemoveAction effect.
 *  Flex creates an instance of this class when it plays a RemoveAction
 *  effect; you do not create one yourself.
 *
 *  @see spark.effects.RemoveAction
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */  
public class RemoveActionInstance extends ActionEffectInstance
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
     *  @param target The Object to animate with this effect.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function RemoveActionInstance(target:Object)
    {
        super(target);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var _startIndex:Number;

    /**
     *  @private
     */
    private var _startParent:*;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function initEffect(event:Event):void
    {
        super.initEffect(event);
    }
    
    private function getContainer(child:*):*
    {
       return child.parent;
    }
    
    private function addChild(container:*, child:*):void
    {
        if (container is IVisualElementContainer)
           IVisualElementContainer(container).addElement(child);
        else
           container.addChild(child);
    }
    
    private function removeChild(container:*, child:*):void
    {
        if (container is IVisualElementContainer)
           IVisualElementContainer(container).removeElement(child);
        else
           container.removeChild(child);
    }
    
    private function addChildAt(container:*, child:*, index:int):void
    {
        if (container is IVisualElementContainer)
           IVisualElementContainer(container).addElementAt(child, index);
        else
           container.addChildAt(child, index);
    }
    
    private function getChildIndex(container:*, child:*):int
    {
        if (container is IVisualElementContainer)
           return IVisualElementContainer(container).getElementIndex(child);
        else
           return container.getChildIndex(child);
    }
    

    /**
     *  @private
     */
    override public function play():void
    {
        var doRemove:Boolean = true;
        
        // Dispatch an effectStart event from the target.
        super.play();   
        
        if (propertyChanges)
        {
            doRemove = (getContainer(propertyChanges.start) != null &&
                        getContainer(propertyChanges.end) == null)
        }
        
        if (!playReversed)
        {
            // Set the style property
            if (doRemove && target && getContainer(target) != null)
                removeChild(getContainer(target), target);
        }
        else if (_startParent && !isNaN(_startIndex))
        {
            addChildAt(_startParent, target, _startIndex);
        }
        
        // We're done...
        finishRepeat();
    }
    
    /** 
     *  @private
     */
    override protected function saveStartValue():*
    {
        if (target && getContainer(target) != null)
        {
            _startIndex =
                getChildIndex(getContainer(target), target);
            _startParent = getContainer(target);
        }
    }
}

}
