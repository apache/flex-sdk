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

import mx.components.Group;

import mx.core.mx_internal;
import mx.effects.effectClasses.ActionEffectInstance;
import mx.effects.AddAction;

/**
 *  The AddActionInstance class implements the instance class
 *  for the AddAction effect.
 *  Flex creates an instance of this class when it plays
 *  an AddAction effect; you do not create one yourself.
 *
 *  @see mx.effects.AddAction
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
	 *  The index of the child within the parent.
	 */
	public var index:int = -1;
	
	//----------------------------------
	//  relativeTo
	//----------------------------------
	
	/** 
	 *  The location where the child component is added.
	 */
	public var relativeTo:DisplayObjectContainer;
	
	//----------------------------------
	//  position
	//----------------------------------
	
	/** 
	 *  The position of the child component, relative to relativeTo, where it is added.
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
	
    private function addChild(container:*, child:*):void
    {
        if (container is Group)
           container.addItem(child);
        else
           container.addChild(child);
    }
    
    private function removeChild(container:*, child:*):void
    {
        if (container is Group)
           container.removeItem(child);
        else
           container.removeChild(child);
    }
    
    private function addChildAt(container:*, child:*, index:int):void
    {
        if (container is Group)
           container.addItemAt(child, index);
        else
           container.addChildAt(child, index);
    }
    
    private function getChildIndex(container:*, child:*):int
    {
        if (container is Group)
           return container.getItemIndex(child);
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
		
		if (!mx_internal::playReversed)
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
												Math.min(index, relativeTo.numChildren));
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
