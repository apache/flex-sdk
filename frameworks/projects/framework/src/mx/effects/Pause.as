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

package mx.effects
{

import mx.effects.effectClasses.PauseInstance;

/**
 *  The Pause effect is useful when sequencing effects.
 *  It does nothing for a specified period of time or until
 *  a specified event is dispatched by the target.
 *  If you add a Pause effect as a child of a Sequence effect,
 *  you can create a pause between the two other effects.
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;mx:Pause&gt;</code> tag
 *  inherits all the tag attributes of its superclass, 
 *  and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;mx:Pause 
 *    id="ID" 
 *    eventName="null"
 *  /&gt;
 *  </pre>
 *  
 *  @see mx.effects.effectClasses.PauseInstance
 *
 *  @includeExample examples/PauseEffectExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class Pause extends TweenEffect
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructor.
     *
     * @param target This argument is ignored by the Pause effect
     * if there is no <code>eventName</code> attribute assigned. If there
     * is an <code>eventName</code>, then the target must be an object
     * of type IEventDispatcher, because it is expected to dispatch
     * that named event. A null target is allowed for this effect since
     * a Pause effect with simply a <code>duration</code> property is
     * not acting on any specific target and therefore does not need one.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function Pause(target:Object = null)
    {
        // Effect requires non-null targets, so if they didn't give us one
        // we will create a dummy object to serve in its place. If the effect
        // is being used to listen to events, then they will supply a real
        // target of type IEventDispatcher instead, either here or separately
        // in the target attribute
        if (!target)
           target = {};
           
        super(target);

        instanceClass = PauseInstance;
    }
    
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

    /** 
     * The duration property controls the amount of time that this effect
     * will pause. The duration also serves as a timeout on waiting for
     * the event to be fired, if <code>eventName</code> was set on this
     * effect. If duration is less than 0, the effect will wait
     * indefinitely for the event to fire. If it is set to any other time,
     * including 0, the effect will end either when that duration has elapsed
     * or when the named event fires, whichever comes first.
     * 
     * @default 500
     * 
     * @see mx.effects.IEffect#duration
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function get duration():Number
    {
        return super.duration;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        super.initInstance(instance);
        
        var pauseInstance:PauseInstance = PauseInstance(instance);

        pauseInstance.eventName = eventName;
    }

    /**
     *  @private
     */
    override public function createInstances(targets:Array = null):Array
    {
        var newInstance:IEffectInstance = createInstance();
        
        return newInstance ? [ newInstance ] : [];
    }
}

}
