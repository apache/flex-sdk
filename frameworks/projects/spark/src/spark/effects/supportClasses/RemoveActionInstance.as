////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
