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

import flash.events.Event;
import flash.events.IEventDispatcher;

import mx.core.mx_internal;

/**
 *  The PauseInstance class implements the instance class for the Pause effect.
 *  Flex creates an instance of this class when it plays a Pause effect;
 *  you do not create one 
 *  yourself.
 *
 *  @see mx.effects.Pause
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */  
public class PauseInstance extends TweenEffectInstance
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
     *  @param target This argument is ignored by the Pause effect.
     *  It is included for consistency with other effects.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function PauseInstance(target:Object)
    {
        super(target);
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     * We cache the source for the event "eventName" to remove
     * the listener for it when the effect ends.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private var eventSource:IEventDispatcher;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  eventName
    //----------------------------------

    /** 
     * Name of event that Pause is waiting on before ending. 
     * This parameter must be used in conjunction with the
     * <code>target</code> property, which must be of type
     * IEventDispatcher; all events must originate
     * from some dispatcher.
     * 
     * <p>Listening for <code>eventName</code> is also related to the
     * <code>duration</code> property, which acts as a timeout for the
     * event. If the event is not received in the time period specified
     * by <code>duration</code>, the effect will end, regardless.</p>
     * 
     * <p>This property is optional; the default
     * action is to play without waiting for any event.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var eventName:String

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
        
    /**
     *  @private
     */
    override public function play():void
    {
        // Dispatch an effectStart event from the target.
        super.play();
        
        if (eventName && target is IEventDispatcher)
        {
            eventSource = IEventDispatcher(target);
            eventSource.addEventListener(eventName, eventHandler);
        }

        if (duration >= 0)
            tween = createTween(this, 0, 0, duration);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     * This function is called by the target if the named event
     * is dispatched before the duration expires.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function eventHandler(event:Event):void
    {
        if (duration >= 0)
        {
            // Non-negative duration means we must have started
            // a tween; let it end normally
            end();
        }
        else
        {
            // We didn't start a tween, so finish the effect manually
            if (eventSource)
                eventSource.removeEventListener(eventName, eventHandler);
            finishRepeat();
        }
    }

    /**
     * Override this function so that we can remove the listener for the
     * event named in the <code>eventName</code> attribute, if it exists
     * 
     * @private
     */
    override public function onTweenEnd(value:Object):void 
    {
        if (eventSource)
            eventSource.removeEventListener(eventName, eventHandler);
        super.onTweenEnd(value);
    }
}

}
