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

package mx.effects.effectClasses
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;

import mx.components.Group;

import mx.core.mx_internal;
import mx.effects.effectClasses.ActionEffectInstance;

/**
 *  The RemoveChildActionInstance class implements the instance class
 *  for the RemoveChildAction effect.
 *  Flex creates an instance of this class when it plays a RemoveChildAction
 *  effect; you do not create one yourself.
 *
 *  @see mx.effects.RemoveChildAction
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
	 */
	public function RemoveActionInstance(target:Object)
	{
		super(target);
        try {
            target.parent;
            hasParent = true;
        } catch (e:Error) {
            hasParent = false;
        }
    }

    private var hasParent:Boolean;
	
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
        if (hasParent)
           return child.parent;
        else
           return child.elementHost;
    }
    
    private function addChild(container:*, child:*):void
    {
        if (hasParent && !(container is Group))
           container.addChild(child);
        else
           container.addItem(child);
    }
    
    private function removeChild(container:*, child:*):void
    {
        if (hasParent && !(container is Group))
           container.removeChild(child);
        else
           container.removeItem(child);
    }
    
    private function addChildAt(container:*, child:*, index:int):void
    {
        if (hasParent && !(container is Group))
           container.addChildAt(child, index);
        else
           container.addItemAt(child, index);
    }
    
    private function getChildIndex(container:*, child:*):int
    {
        if (hasParent && !(container is Group))
           return container.getChildIndex(child);
        else
           return container.getItemIndex(child);
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
		
		if (!mx_internal::playReversed)
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
