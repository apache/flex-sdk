////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.binding
{

import flash.events.Event;
import flash.events.IEventDispatcher;
import mx.core.EventPriority;
import mx.core.mx_internal;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 */
public class FunctionReturnWatcher extends Watcher
{
    include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
	 *  @private
	 *  Constructor.
	 */
	public function FunctionReturnWatcher(functionName:String,
										  document:Object,
										  parameterFunction:Function,
										  events:Object,
                                          listeners:Array,
                                          functionGetter:Function = null,
                                          isStyle:Boolean = false)
    {
		super(listeners);

        this.functionName = functionName;
        this.document = document;
        this.parameterFunction = parameterFunction;
        this.events = events;
        this.functionGetter = functionGetter;
        this.isStyle = isStyle;
    }

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
     *  The name of the property, used to actually get the property
	 *  and for comparison in propertyChanged events.
     */
    private var functionName:String;
    
	/**
 	 *  @private
     *  The document is what we need to use to execute the parameter function.
     */
    private var document:Object;
    
	/**
 	 *  @private
     *  The function that will give us the parameters for calling the function.
     */
    private var parameterFunction:Function;
    
    /**
 	 *  @private
     *  The events that indicate the property has changed.
     */
    private var events:Object;
    
	/**
	 *  @private
     *  The parent object of this function.
     */
    private var parentObj:Object;
    
	/**
	 *  @private
     *  The watcher holding onto the parent object.
     */
    public var parentWatcher:Watcher;

    /**
     *  Storage for the functionGetter property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private var functionGetter:Function;

    /**
     *  Storage for the isStyle property.  This will be true, when
     *  watching a function marked with [Bindable(style="true")].  For
     *  example, UIComponent.getStyle().
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    private var isStyle:Boolean;

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

    /**
 	 *  @private
     */
    override public function updateParent(parent:Object):void
    {
        if (!(parent is Watcher))
            setupParentObj(parent);
        
		else if (parent == parentWatcher)
            setupParentObj(parentWatcher.value);
        
		updateFunctionReturn();
    }

    /**
 	 *  @private
     */
    override protected function shallowClone():Watcher
    {
        var clone:FunctionReturnWatcher = new FunctionReturnWatcher(functionName,
                                                                    document,
                                                                    parameterFunction,
                                                                    events,
                                                                    listeners,
                                                                    functionGetter);

        return clone;
    }

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

    /**
 	 *  @private
     *  Get the new return value of the function.
     */
    public function updateFunctionReturn():void
    {
        wrapUpdate(function():void
		{
            if (functionGetter != null)
            {
                value = functionGetter(functionName).apply(parentObj,
                                                           parameterFunction.apply(document));
            }
            else
            {
                value = parentObj[functionName].apply(parentObj,
                                                      parameterFunction.apply(document));
            }
			
			updateChildren();
		});
    }

    /**
 	 *  @private
     */
    private function setupParentObj(newParent:Object):void
    {
		var eventDispatcher:IEventDispatcher;
        var eventName:String;

        // Remove listeners from the old "watched" object.
        if (parentObj != null &&
            parentObj is IEventDispatcher)
        {
            eventDispatcher = parentObj as IEventDispatcher;

            // events can be null when watching a function marked with
            // [Bindable(style="true")].
            if (events != null)
            {
                for (eventName in events)
                {
                    if (eventName != "__NoChangeEvent__")
                    {
                        eventDispatcher.removeEventListener(eventName, eventHandler);
                    }
                }
            }

            if (isStyle)
            {
                // For example, if the data binding expression is
                // {getStyle("color")}, the eventName will be
                // "colorChanged".
                eventName = parameterFunction.apply(document) + "Changed";
                eventDispatcher.removeEventListener(eventName, eventHandler);
                eventDispatcher.removeEventListener("allStylesChanged", eventHandler);
            }
        }
        
		parentObj = newParent;
        
        // Add listeners the new "watched" object.
        if (parentObj != null &&
            parentObj is IEventDispatcher)
        {
            eventDispatcher = parentObj as IEventDispatcher;

            // events can be null when watching a function marked with
            // [Bindable(style="true")].
            if (events != null)
            {
                for (eventName in events)
                {
                    if (eventName != "__NoChangeEvent__")
                    {
                        eventDispatcher.addEventListener(eventName, eventHandler,
                                                         false,
                                                         EventPriority.BINDING,
                                                         true);
                    }
                }
            }

            if (isStyle)
            {
                // For example, if the data binding expression is
                // {getStyle("color")}, the eventName will be
                // "colorChanged".
                eventName = parameterFunction.apply(document) + "Changed";
                eventDispatcher.addEventListener(eventName, eventHandler, false,
                                                 EventPriority.BINDING, true);                
                eventDispatcher.addEventListener("allStylesChanged", eventHandler, false,
                                                 EventPriority.BINDING, true);                
            }
        }
    }

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

    /**
 	 *  @private
     */
    public function eventHandler(event:Event):void
    {
        updateFunctionReturn();

        // events can be null when watching a function marked with
        // [Bindable(style="true")].
        if (events != null)
        {
            notifyListeners(events[event.type]);
        }

        if (isStyle)
        {
            notifyListeners(true);
        }
    }
}

}
