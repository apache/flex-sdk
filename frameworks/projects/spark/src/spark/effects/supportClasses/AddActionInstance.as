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

import spark.components.Group;

import mx.core.mx_internal;
import mx.effects.effectClasses.ActionEffectInstance;
import spark.effects.AddAction;
import mx.core.IVisualElementContainer;

use namespace mx_internal;

/**
 *  The AddActionInstance class implements the instance class
 *  for the AddAction effect.
 *  Flex creates an instance of this class when it plays
 *  an AddAction effect; you do not create one yourself.
 *
 *  @see spark.effects.AddAction
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */  
public class AddActionInstance extends ActionEffectInstance
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
    public function AddActionInstance(target:Object)
    {
        super(target);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  index
    //----------------------------------
    
    /** 
     *  @copy spark.effects.AddAction#index
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var index:int = -1;
    
    //----------------------------------
    //  relativeTo
    //----------------------------------
    
    /** 
     *  @copy spark.effects.AddAction#relativeTo
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var relativeTo:DisplayObjectContainer;
    
    //----------------------------------
    //  position
    //----------------------------------
    
    /** 
     *  @copy spark.effects.AddAction#position
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var position:String;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    private function getContainer(child:*):*
    {
       return child.parent;
    }
    
    private function getNumElements(container:*):int
    {
        if (container is IVisualElementContainer)
            return IVisualElementContainer(container).numElements;
        else
            return container.numChildren;
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
        // Dispatch an effectStart event from the target.
        super.play();   
        
        if (!relativeTo && propertyChanges)
        {
            if (getContainer(propertyChanges.start) == null &&
                getContainer(propertyChanges.end) != null)
            {
                relativeTo = getContainer(propertyChanges.end);
                position = "index";
                index = propertyChanges.end.index;
            }
        }
        
        if (!playReversed)
        {
            // Set the style property
            if (target && getContainer(target) == null && relativeTo)
            {
                switch (position)
                {
                    case AddAction.INDEX:
                    {
                        if (index == -1)
                            addChild(relativeTo, target);
                        else
                            addChildAt(relativeTo, target, 
                                Math.min(index, getNumElements(relativeTo)));
                        break;
                    }
                    
                    case AddAction.BEFORE:
                    {
                        addChildAt(getContainer(relativeTo), target,
                            getChildIndex(getContainer(relativeTo), relativeTo));
                        break;
                    }

                    case AddAction.AFTER:
                    {
                        addChildAt(getContainer(relativeTo), target,
                            getChildIndex(getContainer(relativeTo), relativeTo) + 1);
                        break;
                    }
                    
                    case AddAction.FIRST_CHILD:
                    {
                        addChildAt(relativeTo, target, 0);
                    }
                    
                    case AddAction.LAST_CHILD:
                    {
                        addChild(relativeTo, target);
                    }
                }
            }
        }
        else
        {
            if (target && relativeTo && getContainer(target) == relativeTo)
            {
                removeChild(relativeTo, target);
            }
        }
        
        // We're done...
        finishRepeat();
    }
}   

}
