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

package flex.effects.effectClasses
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import flex.core.Group;

import mx.core.mx_internal;
import mx.effects.effectClasses.ActionEffectInstance;

/**
 *  The AddChildActionInstance class implements the instance class
 *  for the AddChildAction effect.
 *  Flex creates an instance of this class when it plays
 *  an AddChildAction effect; you do not create one yourself.
 *
 *  @see mx.effects.AddChildAction
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
        try {
            target.parent;
            hasParent = true;
        } catch (e:Error) {
            hasParent = false;
        }
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	private var hasParent:Boolean;
	
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
	    try {
	        target.parent;
	        hasParent = true;
	    } catch (e:Error) {
	        hasParent = false;
	    }
	    
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
					case "index":
					{
						if (index == -1)
							addChild(relativeTo, target);
						else
							addChildAt(relativeTo, target, 
												Math.min(index, relativeTo.numChildren));
						break;
					}
					
					case "before":
					{
						addChildAt(getContainer(relativeTo), target,
							getChildIndex(getContainer(relativeTo), relativeTo));
						break;
					}

					case "after":
					{
						addChildAt(getContainer(relativeTo), target,
							getChildIndex(getContainer(relativeTo), relativeTo) + 1);
						break;
					}
					
					case "firstChild":
					{
						addChildAt(relativeTo, target, 0);
					}
					
					case "lastChild":
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
