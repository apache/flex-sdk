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

package mx.effects
{

import flash.events.Event;
import flash.events.EventDispatcher;

import mx.core.FlexVersion;
import mx.core.IFlexDisplayObject;
import mx.core.mx_internal;
import mx.effects.effectClasses.AddRemoveEffectTargetFilter;
import mx.effects.effectClasses.HideShowEffectTargetFilter;
import mx.effects.effectClasses.PropertyChanges;
import mx.events.EffectEvent;
import mx.managers.LayoutManager;
import mx.styles.IStyleClient;
import mx.utils.NameUtil;

use namespace mx_internal;

/**
 *  Dispatched when the effect finishes playing,
 *  either when the effect finishes playing or when the effect has 
 *  been interrupted by a call to the <code>end()</code> method.
 *
 *  @eventType mx.events.EffectEvent.EFFECT_END
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="effectEnd", type="mx.events.EffectEvent")]

/**
 *  Dispatched when the effect has been stopped,
 *  which only occurs when the effect has 
 *  been interrupted by a call to the <code>stop()</code> method.
 *  The EFFECT_END event will also be dispatched to indicate that
 *  the effect has ended. This extra event is sent first, as an
 *  indicator to listeners that the effect did not reach its
 *  end state.
 *
 *  @eventType mx.events.EffectEvent.EFFECT_STOP
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="effectStop", type="mx.events.EffectEvent")]

/**
 *  Dispatched when the effect starts playing.
 *
 *  @eventType mx.events.EffectEvent.EFFECT_START
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="effectStart", type="mx.events.EffectEvent")]

/**
 *  The Effect class is an abstract base class that defines the basic 
 *  functionality of all Flex effects.
 *  The Effect class defines the base factory class for all effects.
 *  The EffectInstance class defines the base class for all effect
 *  instance subclasses.
 *
 *  <p>You do not create an instance of the Effect class itself
 *  in an application.
 *  Instead, you create an instance of one of the subclasses,
 *  such as Fade or WipeLeft.</p>
 *  
 *  @mxml
 *
 *  <p>The Effect class defines the following properties,
 *  which all of its subclasses inherit:</p>
 *  
 *  <pre>
 *  &lt;mx:<i>tagname</i>
 *    <b>Properties</b>
 *    customFilter=""
 *    duration="500"
 *    filter=""
 *    hideFocusRing="false"
 *    perElementOffset="0"
 *    repeatCount="1"
 *    repeatDelay="0"
 *    startDelay="0"
 *    suspendBackgroundProcessing="false|true"
 *    target="<i>effect target</i>"
 *    targets="<i>array of effect targets</i>"
 *     
 *    <b>Events</b>
 *    effectEnd="<i>No default</i>"
 *    efectStart="<i>No default</i>"
 *  /&gt;
 *  </pre>
 *
 *  @see mx.effects.EffectInstance
 * 
 *  @includeExample examples/SimpleEffectExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class Effect extends EventDispatcher implements IEffect
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private static function mergeArrays(a1:Array, a2:Array):Array
    {
        if (a2)
        {
            for (var i2:int = 0; i2 < a2.length; i2++)
            {
                var addIt:Boolean = true;
                
                for (var i1:int = 0; i1 < a1.length; i1++)
                {
                    if (a1[i1] == a2[i2])
                    {
                        addIt = false;
                        break;
                    }
                }
                
                if (addIt)
                    a1.push(a2[i2]);
            }
        }
        
        return a1;
    }

    /**
     *  @private
     */
    private static function stripUnchangedValues(propChanges:Array):Array
    {
        // Go through and remove any before/after values that are the same.
        for (var i:int = 0; i < propChanges.length; i++)
        {
            if (propChanges[i].stripUnchangedValues == false)
                continue;

            for (var prop:Object in propChanges[i].start)
            {
                if ((propChanges[i].start[prop] ==
                     propChanges[i].end[prop]) ||
                    (typeof(propChanges[i].start[prop]) == "number" &&
                     typeof(propChanges[i].end[prop])== "number" &&
                     isNaN(propChanges[i].start[prop]) &&
                     isNaN(propChanges[i].end[prop])))
                {
                    delete propChanges[i].start[prop];
                    delete propChanges[i].end[prop];
                }
            }
        }
            
        return propChanges;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  <p>Starting an effect is usually a three-step process:</p>
     *
     *  <ul>
     *    <li>Create an instance of the effect object
     *    with the <code>new</code> operator.</li>
     *    <li>Set properties on the effect object,
     *    such as <code>duration</code>.</li>
     *    <li>Call the <code>play()</code> method
     *    or assign the effect to a trigger.</li>
     *  </ul>
     *
     *  @param target The Object to animate with this effect.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function Effect(target:Object = null)
    {
        super();

        this.target = target;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    // Transitions will force the values animated by this effect to get set to
    // their final values, as specified in the end state, when the effect finishes.
    // This flag is set to true when the effect is being played by a transition,
    // but applying the values is still gated by the value of the
    // applyTransitionEndProperties flag, which is set on a per-Effect basis.
    mx_internal var applyEndValuesWhenDone:Boolean = false;

    // This is new behavior for the Flex4 effects; previously, we would not
    // set the end-state values automatically. Because of this switch, the
    // default value is hinged on a compatibility check, so that applications
    // can choose to have the older behavior instead.
    /**
     * This flag controls whether the effect, when run in a transition,
     * will automatically apply the property values according to the end
     * state, as opposed to leaving values as set by the effect itself.
     * 
     * @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var applyTransitionEndProperties:Boolean = 
        (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_0) ? 
        false : true;
    
    /**
     *  @private
     */
    private var _instances:Array /* of EffectInstance */ = [];
    
    /**
     *  @private
     */
    private var _callValidateNow:Boolean = false;
        
    /**
     *  @private
     */
    private var isPaused:Boolean = false;
    
    /**
     *  @private
     */
    mx_internal var filterObject:EffectTargetFilter;
    
    /**
     *  @private
	 *  Used in applyValueToTarget()
     */
    mx_internal var applyActualDimensions:Boolean = true;
    
    /**
     *  @private
     *  Holds the init object passed in by the Transition.
     */
    mx_internal var propertyChangesArray:Array; 
    
    private var effectStopped:Boolean;
        
    /**
     *  @private
     *  Pointer back to the CompositeEffect that created this instance.
     *  Value is null if we are not the child of a CompositeEffect
     */
    mx_internal var parentCompositeEffect:Effect;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  className
    //----------------------------------

    /**
     *  @copy mx.effects.IEffect#className
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get className():String
    {
        return NameUtil.getUnqualifiedClassName(this);
    }
        
    //----------------------------------
    //  customFilter
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the customFilter property.
     */
    private var _customFilter:EffectTargetFilter;
        
    /**
     *  @copy mx.effects.IEffect#customFilter
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get customFilter():EffectTargetFilter
    {
        return _customFilter;
    }

    /**
     *  @private
     */
    public function set customFilter(value:EffectTargetFilter):void
    {
        _customFilter = value;
        filterObject = value;
    }
    
    //----------------------------------
    //  duration
    //----------------------------------

    /**
     *  @private
     *  Storage for the duration property.
     */
    private var _duration:Number = 500;
    
    /**
	 *  @private
	 */
	mx_internal var durationExplicitlySet:Boolean = false;

    [Inspectable(category="General", defaultValue="500")]
    
    /** 
     *  @copy mx.effects.IEffect#duration
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get duration():Number
    {
        if (!durationExplicitlySet &&
            parentCompositeEffect)
        {
            return parentCompositeEffect.duration;
        }
        else
        {
            return _duration;
        }
    }
    
    /**
     *  @private
     */
    public function set duration(value:Number):void
    {
        durationExplicitlySet = true;
        _duration = value;
    }
    
    //----------------------------------
    //  effectTargetHost
    //----------------------------------

    /**
	 *  @private
	 *  Storage for the effectTargetHost property.
	 */
	private var _effectTargetHost:IEffectTargetHost;
    
    /**
     *  @copy mx.effects.IEffect#effectTargetHost
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get effectTargetHost():IEffectTargetHost
    {
        return _effectTargetHost;
    }

    /**
     *  @private 
     */
    public function set effectTargetHost(value:IEffectTargetHost):void
    {
        _effectTargetHost = value;
    }
    
    //----------------------------------
    //  endValuesCaptured
    //----------------------------------

    /**
     *  A flag containing <code>true</code> if the end values
	 *  of an effect have already been determined, 
     *  or <code>false</code> if they should be acquired from the
	 *  current properties of the effect targets when the effect runs. 
     *  This property is required by data effects because the sequence
	 *  of setting up the data effects, such as DefaultListEffect
	 *  and DefaultTileListEffect, is more complicated than for
	 *  normal effects.
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var endValuesCaptured:Boolean = false;

    //----------------------------------
    //  filter
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the filter property.
     */
    private var _filter:String;
    
    [Inspectable(category="General", enumeration="add,remove,show,hide,move,resize,addItem,removeItem,replacedItem,replacementItem,none", defaultValue="none")]
     
    /**
     *  @copy mx.effects.IEffect#filter
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get filter():String
    {
        return _filter;
    }

    /**
     *  @private
     */
    public function set filter(value:String):void
    {
        if (!customFilter)
        {
            _filter = value;
            
            switch (value)
            {
                case "add":
                case "remove":
                {
                    filterObject =
                        new AddRemoveEffectTargetFilter();
                    AddRemoveEffectTargetFilter(filterObject).add =
                        (value == "add");
                    break;
                }
                
                case "hide":
                case "show":
                {
                    filterObject =
                        new HideShowEffectTargetFilter();
                    HideShowEffectTargetFilter(filterObject).show =
                        (value == "show");
                    break;
                }
                
                case "move":
                {
                    filterObject =
                        new EffectTargetFilter();
                    filterObject.filterProperties =
                        [ "x", "y" ];
                    break;
                }
                
                case "resize":
                {
                    filterObject =
                        new EffectTargetFilter();
                    filterObject.filterProperties =
                        [ "width", "height" ];
                    break;
                }
                
                case "addItem":
                {
                    filterObject = new EffectTargetFilter();
                    filterObject.requiredSemantics = {added:true};
                    break;
                }         

                case "removeItem":
                {
                    filterObject = new EffectTargetFilter();
                    filterObject.requiredSemantics = {removed:true};
                    break;
                }                
                
                case "replacedItem":
                {
                    filterObject = new EffectTargetFilter();
                    filterObject.requiredSemantics = {replaced:true};
                    break;
                }                
                
                case "replacementItem":
                {
                    filterObject = new EffectTargetFilter();
                    filterObject.requiredSemantics = {replacement:true};
                    break;
                }                

                default:
                {
                    filterObject = null;
                    break;          
                }
            }
        }
    }

    //----------------------------------
    //  hideFocusRing
    //----------------------------------
    
	/**
	 *  @private
	 *  Storage for the hideFocusRing property.
	 */
	private var _hideFocusRing:Boolean = false;

    /**
     *  @copy mx.effects.IEffect#hideFocusRing
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get hideFocusRing():Boolean
    {
        return _hideFocusRing;
    }
    
    /**
     *  @private
     */
    public function set hideFocusRing(value:Boolean):void
    {
        _hideFocusRing = value;
    }
    
    //----------------------------------
    //  instanceClass
    //----------------------------------

    /**
     *  An object of type Class that specifies the effect
     *  instance class class for this effect class. 
     *  
     *  <p>All subclasses of the Effect class must set this property 
     *  in their constructor.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public var instanceClass:Class = IEffectInstance;

    
    //----------------------------------
    //  isPlaying
    //----------------------------------

    /**
     *  @copy mx.effects.IEffect#isPlaying
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get isPlaying():Boolean
    {
        return _instances && _instances.length > 0;
    }
    
    //----------------------------------
    //  perElementOffset
    //----------------------------------

	/**
	 *  @private
	 *  Storage for the perElementOffset property.
	 */
	private var _perElementOffset:Number = 0;

    [Inspectable(defaultValue="0", category="General", verbose="0")]

    /**
     *  @copy mx.effects.IEffect#perElementOffset
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    public function get perElementOffset():Number
	{
		return _perElementOffset;
	}

	/**
	 *  @private
	 */
	public function set perElementOffset(value:Number):void
	{
		_perElementOffset = value;
	}
    
    //----------------------------------
    //  relevantProperties
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the relevantProperties property.
     */
    private var _relevantProperties:Array /* of String */;
        
    /**
     *  @copy mx.effects.IEffect#relevantProperties
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get relevantProperties():Array /* of String */
    {
        if (_relevantProperties)
            return _relevantProperties;
        else
            return getAffectedProperties();
    }

    /**
     *  @private
     */
    public function set relevantProperties(value:Array /* of String */):void
    {
        _relevantProperties = value;
    }
    
    //----------------------------------
    //  relevantStyles
    //----------------------------------
    
    /**
     *  @private
	 *  Storage for the relevantStyles property.
     */
    private var _relevantStyles:Array /* of String */ = [];
        
    /**
     *  @copy mx.effects.IEffect#relevantStyles
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get relevantStyles():Array /* of String */
    {
        return _relevantStyles;
    }

    /**
     *  @private
     */
    public function set relevantStyles(value:Array /* of String */):void
    {
        _relevantStyles = value;
    }
    
    //----------------------------------
    //  repeatCount
    //----------------------------------

    [Inspectable(category="General", defaultValue="1")]

    /**
     *  Number of times to repeat the effect.
     *  Possible values are any integer greater than or equal to 0.
     *  A value of 1 means to play the effect once.
     *  A value of 0 means to play the effect indefinitely
     *  until stopped by a call to the <code>end()</code> method.
     *
     *  @default 1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var repeatCount:int = 1;
        
    
    //----------------------------------
    //  repeatDelay
    //----------------------------------

    [Inspectable(category="General", defaultValue="0")]

    /**
     *  Amount of time, in milliseconds, to wait before repeating the effect.
     *  Possible values are any integer greater than or equal to 0.
     *
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var repeatDelay:int = 0;


    //----------------------------------
    //  startDelay
    //----------------------------------

    [Inspectable(category="General", defaultValue="0")]

    /**
     *  Amount of time, in milliseconds, to wait before starting the effect.
     *  Possible values are any int greater than or equal to 0.
     *  If the effect is repeated by using the <code>repeatCount</code>
     *  property, the <code>startDelay</code> is only applied
     *  to the first time the effect is played.
     *
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var startDelay:int = 0;

    //----------------------------------
    //  suspendBackgroundProcessing
    //----------------------------------

    /**
     *  If <code>true</code>, blocks all background processing
     *  while the effect is playing.
     *  Background processing includes measurement, layout, and
     *  processing responses that have arrived from the server.
     *  The default value is <code>false</code>.
     *
     *  <p>You are encouraged to set this property to
     *  <code>true</code> in most cases, because it improves
     *  the performance of the application.
     *  However, the property should be set to <code>false</code>
     *  if either of the following is true:</p>
     *  <ul>
     *    <li>User input may arrive while the effect is playing,
     *    and the application must respond to the user input
     *    before the effect finishes playing.</li>
     *    <li>A response may arrive from the server while the effect
     *    is playing, and the application must process the response
     *    while the effect is still playing.</li>
     *  </ul>
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var suspendBackgroundProcessing:Boolean = false;


    //----------------------------------
    //  target
    //----------------------------------

    /** 
     *  @copy mx.effects.IEffect#target
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get target():Object
    {
        if (_targets.length > 0)
            return _targets[0]; 
        else
            return null;
    }
    
    /**
     *  @private
     */
    public function set target(value:Object):void
    {
        _targets.splice(0);
        
        if (value)
            _targets[0] = value;
    }

    //----------------------------------
    //  targets
    //----------------------------------

    /**
     *  @private
     *  Storage for the targets property.
     */
    private var _targets:Array = [];
    
    [Inspectable(arrayType="Object")]
    [ArrayElementType("Object")]

    /**
     *  @copy mx.effects.IEffect#targets
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get targets():Array
    {
        return _targets;
    }

    /**
     *  @private
     */
    public function set targets(value:Array):void
    {
        // Strip out null values.
        // Binding will trigger again when the null targets are created.
        var n:int = value.length;
        for (var i:int = n - 1; i >= 0; i--)
        {
            if (value[i] == null)
                value.splice(i,1);
        }

        _targets = value;
    }
    
    //----------------------------------
    //  triggerEvent
    //----------------------------------

    /**
     *  @private
     *  Storage for the triggerEvent property.
     */
    private var _triggerEvent:Event;
    
    /**
     *  @copy mx.effects.IEffect#triggerEvent
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get triggerEvent():Event
	{
		return _triggerEvent;
	}
    
    /**
     *  @private
     */
    public function set triggerEvent(value:Event):void
    {
        _triggerEvent = value;
    }

    //----------------------------------
    // playheadTime
    //----------------------------------

    /**
     * @private
     * Backing storage for the playheadTime property. Note that this
     * value is just a backup, used if the effect is not currently running.
     * A running effect will query its effect instance for the value
     * instead.
     */
    private var _playheadTime:Number = 0;
    
    /**
     *  Current time position of the effect.
     *  This property has a value between 0 and the total duration, 
     *  which includes the Effect's <code>startDelay</code>, 
     *  <code>repeatCount</code>, and <code>repeatDelay</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get playheadTime():Number 
    {
        for (var i:int = 0; i < _instances.length; i++)
        {
            if (_instances[i])
                return IEffectInstance(_instances[i]).playheadTime;
        }
        // Effect isn't running: return the cached value
        return _playheadTime;
    }
    public function set playheadTime(value:Number):void
    {
        // If the effect is not yet playing, it should still be possible
        // to seek into it. playing and then pausing it provides that
        // capability
        // FIXME (chaase): Need better overall mechanism to seek into a
        // non-playing effect. The internals of seeking in Animation
        // are complicated and don't end up giving us the behavior we
        // want, especially for successive seeks.
        var started:Boolean = false;
        if (_instances.length == 0)
        {
            play();
            started = true;
        }
        for (var i:int = 0; i < _instances.length; i++)
        {
            if (_instances[i])
                EffectInstance(_instances[i]).playheadTime = value;
        }
        if (started)
            pause();
        _playheadTime = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    


    /**
     *  @copy mx.effects.IEffect#getAffectedProperties()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getAffectedProperties():Array /* of String */
    {
        // Every subclass should override this method.
        return [];
    }
    
    /**
     *  @copy mx.effects.IEffect#createInstances()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function createInstances(targets:Array = null):Array /* of EffectInstance */
    {
        if (!targets)
            targets = this.targets;
            
        var newInstances:Array = [];
        
        // Multiple target support
        var n:int = targets.length;
        var offsetDelay:Number = 0;
        
        for (var i:int = 0; i < n; i++) 
        {
            var newInstance:IEffectInstance = createInstance(targets[i]);
            
            if (newInstance)
            {
                newInstance.startDelay += offsetDelay;
                offsetDelay += perElementOffset;
                newInstances.push(newInstance);
            }
        }
        
        triggerEvent = null;
        
        return newInstances; 
    }

    /**
     *  @copy mx.effects.IEffect#createInstance()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function createInstance(target:Object = null):IEffectInstance
    {       
        if (!target)
            target = this.target;
        
        var newInstance:IEffectInstance = null;
        var props:PropertyChanges = null;
        var create:Boolean = true;
        var setPropsArray:Boolean = false;
                
        if (propertyChangesArray)
        {
            setPropsArray = true;
            create = filterInstance(propertyChangesArray,
                                    target);    
        }
         
        if (create) 
        {
            newInstance = IEffectInstance(new instanceClass(target));
            
            initInstance(newInstance);
            
            if (setPropsArray)
            {
                var n:int = propertyChangesArray.length;
                for (var i:int = 0; i < n; i++)
                {
                    if (propertyChangesArray[i].target == target)
                    {
                        newInstance.propertyChanges =
                            propertyChangesArray[i];
                    }
                }
            }
                
            EventDispatcher(newInstance).addEventListener(EffectEvent.EFFECT_START, effectStartHandler);
            EventDispatcher(newInstance).addEventListener(EffectEvent.EFFECT_STOP, effectStopHandler);
            EventDispatcher(newInstance).addEventListener(EffectEvent.EFFECT_END, effectEndHandler);
            
            _instances.push(newInstance);
            
            if (triggerEvent)
                newInstance.initEffect(triggerEvent);
        }
        
        return newInstance;
    }

    /**
     *  Copies properties of the effect to the effect instance. 
     *
     *  <p>Flex calls this method from the <code>Effect.createInstance()</code>
     *  method; you do not have to call it yourself. </p>
     *
     *  <p>When you create a custom effect, override this method to 
     *  copy properties from the Effect class to the effect instance class. 
     *  In your override, you must call <code>super.initInstance()</code>. </p>
     *
     *  @param EffectInstance The effect instance to initialize.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function initInstance(instance:IEffectInstance):void
    {
        instance.duration = duration;
        Object(instance).durationExplicitlySet = durationExplicitlySet;
        instance.effect = this;
		instance.effectTargetHost = effectTargetHost;
		instance.hideFocusRing = hideFocusRing;
        instance.repeatCount = repeatCount;
        instance.repeatDelay = repeatDelay;
        instance.startDelay = startDelay;
        instance.suspendBackgroundProcessing = suspendBackgroundProcessing;
    }
    
    /**
     *  @copy mx.effects.IEffect#deleteInstance()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function deleteInstance(instance:IEffectInstance):void
    {
        EventDispatcher(instance).removeEventListener(
			EffectEvent.EFFECT_START, effectStartHandler);
        EventDispatcher(instance).removeEventListener(
            EffectEvent.EFFECT_STOP, effectStopHandler);
        EventDispatcher(instance).removeEventListener(
            EffectEvent.EFFECT_END, effectEndHandler);
        
        var n:int = _instances.length;
        for (var i:int = 0; i < n; i++)
        {
            if (_instances[i] === instance)
                _instances.splice(i, 1);
        }
    }

    /**
     *  @copy mx.effects.IEffect#play()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    public function play(targets:Array = null,
                         playReversedFromEnd:Boolean = false):
                         Array /* of EffectInstance */
    {
        effectStopped = false;
        isPaused = false;
        
        // If we have a propertyChangesArray, capture the current values
        // if they haven't been captured already, strip out any unchanged 
        // values, then apply the start values.
        if (targets == null && propertyChangesArray != null)
        {
            if (_callValidateNow)
                LayoutManager.getInstance().validateNow();
            
            if (!endValuesCaptured)
                propertyChangesArray =
                    captureValues(propertyChangesArray, false);
            
            propertyChangesArray =
                stripUnchangedValues(propertyChangesArray);
            
            applyStartValues(propertyChangesArray,
                             this.targets);

            // Revalidate after applying the start values, to get everything
            // back the way it should be before starting the animation
            // FIXME (chaase): should we skip this step if the effect has asked
            // to disable layout while it runs? Otherwise we are about to validate
            // the targets in a layout that has potentially been set to a post-effect
            // value
            LayoutManager.getInstance().validateNow();
            
            applyEndValuesWhenDone = true;
        }
        
        var newInstances:Array = createInstances(targets);
                
        var n:int = newInstances.length;
        for (var i:int = 0; i < n; i++) 
        {
            var newInstance:IEffectInstance = IEffectInstance(newInstances[i]);

            Object(newInstance).playReversed = playReversedFromEnd;
            
            newInstance.startEffect();
        }
        
        return newInstances; 
    }
    
    /**
     *  @copy mx.effects.IEffect#pause()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function pause():void
    {   
        if (isPlaying && !isPaused)
        {
            isPaused = true;
            
            var n:int = _instances.length;
            for (var i:int = 0; i < n; i++)
            {
                IEffectInstance(_instances[i]).pause();
            }       
        }
    }

    /**
     *  @copy mx.effects.IEffect#stop()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function stop():void
    {   
        var n:int = _instances.length;
        for (var i:int = n; i >= 0; i--)
        {
            var instance:IEffectInstance = IEffectInstance(_instances[i]);
            if (instance)
                instance.stop();
        }
    }
    
    /**
     *  @copy mx.effects.IEffect#resume()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function resume():void
    {
        if (isPlaying && isPaused)
        {
            isPaused = false;
            var n:int = _instances.length;
            for (var i:int = 0; i < n; i++)
            {
                IEffectInstance(_instances[i]).resume();
            }
        }
    }
        
    /**
     *  @copy mx.effects.IEffect#reverse()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function reverse():void
    {
        if (isPlaying)
        {
            var n:int = _instances.length;
            for (var i:int = 0; i < n; i++)
            {
                IEffectInstance(_instances[i]).reverse();
            }
        }
    }
    
    /**
     *  @copy mx.effects.IEffect#end()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function end(effectInstance:IEffectInstance = null):void
    {
        if (effectInstance)
        {
            effectInstance.end();
        }
        else
        {
            var n:int = _instances.length;
            for (var i:int = n; i >= 0; i--)
            {
                var instance:IEffectInstance = IEffectInstance(_instances[i]);
                if (instance)
                    instance.end();
            }
        }
    }
    
    /**
     *  Determines the logic for filtering out an effect instance.
     *  The CompositeEffect class overrides this method.
     *
     *  @param propChanges The properties modified by the effect.
     *
     *  @param targ The effect target.
     *
     *  @return Returns <code>true</code> if the effect instance should play.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function filterInstance(propChanges:Array, target:Object):Boolean 
    {
        if (filterObject)
            return filterObject.filterInstance(propChanges, effectTargetHost, target);
        
        return true;
    }
    
    /**
     *  @copy mx.effects.IEffect#captureStartValues()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function captureStartValues():void
    {       
        if (targets.length > 0)
        {
            // Reset the PropertyChanges array by passing in 'null'
            propertyChangesArray = captureValues(null, true);

            _callValidateNow = true;
        }
        endValuesCaptured = false;
    }

    /**
     *  @copy mx.effects.IEffect#captureMoreStartValues()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function captureMoreStartValues(targets:Array):void
    {       
        if (targets.length > 0)
        {
            // make temporary PropertyChangesArray
            var additionalPropertyChangesArray:Array = captureValues(null, true);
            
            propertyChangesArray = 
                propertyChangesArray.concat(additionalPropertyChangesArray);
        }
    }
    
    /**
     *  @copy mx.effects.IEffect#captureEndValues()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function captureEndValues():void
    {
        // captureValues will create propertyChangesArray if it does not
        // yet exist
        propertyChangesArray =
            captureValues(propertyChangesArray, false);
        endValuesCaptured = true;
    }
        
    /**
     *  @private
     *  Used internally to grab the values of the relevant properties
     */
    mx_internal function captureValues(propChanges:Array,
									   setStartValues:Boolean,
									   targetsToCapture:Array = null):Array
    {
        var n:int;
        var i:int;
        if (!propChanges)
        {
            propChanges = [];
                        
            // Create a new PropertyChanges object for the sum of all targets.
            n = targets.length;
            for (i = 0; i < n; i++)
                propChanges.push(new PropertyChanges(targets[i]));
        }
                    
        // Merge Effect.filterProperties and filterObject.filterProperties
        var effectProps:Array = !filterObject ?
                                relevantProperties :
                                mergeArrays(relevantProperties,
                                filterObject.filterProperties);
        
        var valueMap:Object;
        var target:Object;      
        var m:int;  
        var j:int;
        
        // For each target, grab the property's value
        // and put it into the propChanges Array. 
        // Walk the targets.
        if (effectProps && effectProps.length > 0)
        {
            n = propChanges.length;
            for (i = 0; i < n; i++)
            {
                target = propChanges[i].target;
                if (targetsToCapture == null || targetsToCapture.length == 0 ||
                    targetsToCapture.indexOf(target) >= 0)
                {
                    valueMap = setStartValues ? propChanges[i].start : propChanges[i].end;
                                            
                    // Walk the properties in the target
                    m = effectProps.length;
                    for (j = 0; j < m; j++)
                    {
                        // Don't clobber values already set
                        if (valueMap[effectProps[j]] === undefined)
                        {
                            valueMap[effectProps[j]] = 
                                getValueFromTarget(target,effectProps[j]);
                        }
                    }
                }
            }
        }
        
        var styles:Array = !filterObject ?
                           relevantStyles :
                           mergeArrays(relevantStyles,
                           filterObject.filterStyles);
        
        if (styles && styles.length > 0)
        {         
            n = propChanges.length;
            for (i = 0; i < n; i++)
            {
                target = propChanges[i].target;
                if (targetsToCapture == null || targetsToCapture.length == 0 ||
                    targetsToCapture.indexOf(target) >= 0)
                {
                    if (!(target is IStyleClient))
                        continue;
                        
                    valueMap = setStartValues ? propChanges[i].start : propChanges[i].end;
                                            
                    // Walk the properties in the target.
                    m = styles.length;
                    for (j = 0; j < m; j++)
                    {
                        // Don't clobber values set by relevantProperties
                        if (valueMap[styles[j]] === undefined)
                        {
                            var value:* = target.getStyle(styles[j]);
                            valueMap[styles[j]] = value;
                        }
                    }
                }
            }
        }
        
        return propChanges;
    }
    
    /**
     *  Called by the <code>captureStartValues()</code> method to get the value
     *  of a property from the target.
     *  This function should only be called internally
     *  by the effects framework.
     *  The default behavior is to simply return <code>target[property]</code>.
     *  Effect developers can override this function
     *  if you need a different behavior. 
     *
     *  @param target The effect target.
     *
     *  @param property The target property.
     *
     *  @return The value of the target property. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function getValueFromTarget(target:Object, property:String):*
    {
        if (property in target)
            return target[property];
        
        return undefined;
    }
    
    /**
     *  @private
     *  Applies the start values found in the array of PropertyChanges
     *  to the relevant targets.
     */
    mx_internal function applyStartValues(propChanges:Array,
                                     targets:Array):void
    {
        var effectProps:Array = relevantProperties;
                    
        var n:int = propChanges.length;
        for (var i:int = 0; i < n; i++)
        {
            var m:int;
            var j:int;

            var target:Object = propChanges[i].target;
            var apply:Boolean = false;
            
            m = targets.length;
            for (j = 0; j < m; j++)
            {
                if (targets[j] == target)
                {   
                    apply = filterInstance(propChanges, target);
                    break;
                }
            }
            
            if (apply)
            {
                // Walk the properties in the target
                m = effectProps.length;
                for (j = 0; j < m; j++)
                {
                    var propName:String = effectProps[j];
                    var startVal:* = propChanges[i].start[propName];
                    var endVal:* = propChanges[i].end[propName];
                    if (propName in propChanges[i].start &&
                        endVal != startVal &&
                        (!(startVal is Number) ||
                         !(isNaN(endVal) && isNaN(startVal))))
                    {
                        applyValueToTarget(target, effectProps[j],
                                propChanges[i].start[effectProps[j]],
                                propChanges[i].start);
                    }
                }
                
                // Walk the styles in the target
                m = relevantStyles.length;
                for (j = 0; j < m; j++)
                {
                    var styleName:String = relevantStyles[j];
                    var startStyle:* = propChanges[i].start[styleName];
                    var endStyle:* = propChanges[i].end[styleName];
                    if (styleName in propChanges[i].start &&
                        endStyle != startStyle &&
                        (!(startStyle is Number) ||
                         !(isNaN(endStyle) && isNaN(startStyle))) &&
                        target is IStyleClient)
                    {
                        if (propChanges[i].end[relevantStyles[j]] !== undefined)
                            target.setStyle(relevantStyles[j], propChanges[i].start[relevantStyles[j]]);
                        else
                            target.clearStyle(relevantStyles[j]);
                    }
                }
            }
        }
    }
    
    /**
     *  @private
     *  Applies the start values found in the array of PropertyChanges
     *  to the relevant targets.
     */
    mx_internal function applyEndValues(propChanges:Array,
                                    targets:Array):void
    {
        // For now, only new Flex4 effects will apply end values when transitions
        // are over, to preserve the previous behavior of Flex3 effects
        if (!applyTransitionEndProperties)
            return;
            
        var effectProps:Array = relevantProperties;
                    
        var n:int = propChanges.length;
        for (var i:int = 0; i < n; i++)
        {
            var m:int;
            var j:int;

            var target:Object = propChanges[i].target;
            var apply:Boolean = false;
            
            m = targets.length;
            for (j = 0; j < m; j++)
            {
                if (targets[j] == target)
                {   
                    apply = filterInstance(propChanges, target);
                    break;
                }
            }
            
            if (apply)
            {
                // Walk the properties in the target
                m = effectProps.length;
                for (j = 0; j < m; j++)
                {
                    var propName:String = effectProps[j];
                    var startVal:* = propChanges[i].start[propName];
                    var endVal:* = propChanges[i].end[propName];
                    if (propName in propChanges[i].end &&
                        endVal != startVal &&
                        (!(endVal is Number) ||
                         !(isNaN(endVal) && isNaN(startVal))))
                    {
                        applyValueToTarget(target, propName,
                                propChanges[i].end[propName],
                                propChanges[i].end);
                    }
                }
                
                // Walk the styles in the target
                m = relevantStyles.length;
                for (j = 0; j < m; j++)
                {
                    var styleName:String = relevantStyles[j];
                    var startStyle:* = propChanges[i].start[styleName];
                    var endStyle:* = propChanges[i].end[styleName];
                    if (styleName in propChanges[i].end &&
                        endStyle != startStyle &&
                        (!(endStyle is Number) ||
                         !(isNaN(endStyle) && isNaN(startStyle))) &&
                        target is IStyleClient)
                    {
                        if (propChanges[i].end[styleName] !== undefined)
                            target.setStyle(styleName, propChanges[i].end[styleName]);
                        else
                            target.clearStyle(styleName);
                    }
                }
            }
        }
    }
    
    /**
     *  Used internally by the Effect infrastructure.
     *  If <code>captureStartValues()</code> has been called,
     *  then when Flex calls the <code>play()</code> method, it uses this function
     *  to set the targets back to the starting state.
     *  The default behavior is to take the value captured
     *  using the <code>getValueFromTarget()</code> method
     *  and set it directly on the target's property. For example: <pre>
     *  
     *  target[property] = value;</pre>
     *
     *  <p>Only override this method if you need to apply
     *  the captured values in a different way.
     *  Note that style properties of a target are set
     *  using a different mechanism.
     *  Use the <code>relevantStyles</code> property to specify
     *  which style properties to capture and apply. </p>
     *
     *  @param target The effect target.
     *
     *  @param property The target property.
     *
     *  @param value The value of the property. 
     *
     *  @param props Array of Objects, where each Array element contains a 
     *  <code>start</code> and <code>end</code> Object
     *  for the properties that the effect is monitoring. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function applyValueToTarget(target:Object, property:String, 
                                          value:*, props:Object):void
    {
        if (property in target)
        {
            // The "property in target" test only tells if the property exists
            // in the target, but does not distinguish between read-only and
            // read-write properties. Put a try/catch around the setter and 
            // ignore any errors.
            try
            {
                
                if (applyActualDimensions &&
                    target is IFlexDisplayObject &&
                    property == "height")
                {
                    target.setActualSize(target.width,value);
                }
                else if (applyActualDimensions &&
                         target is IFlexDisplayObject &&
                         property == "width")
                {
                    target.setActualSize(value,target.height);
                }
                else
                {
                    target[property] = value;
                }
            }
            catch(e:Error)
            {
                // Ignore errors
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  This method is called when the effect instance starts playing. 
     *  If you override this method, ensure that you call the super method. 
     *
     *  @param event An event object of type EffectEvent.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function effectStartHandler(event:EffectEvent):void 
    {
        dispatchEvent(event);
    }
    
    /**
     *  Called when an effect instance has been stopped by a call
     *  to the <code>stop()</code> method. 
     *  If you override this method, ensure that you call the super method.
     *
     *  @param event An event object of type EffectEvent.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function effectStopHandler(event:EffectEvent):void
    {
        dispatchEvent(event);
        // We use this event to determine whether we should set final
        // state values in the ensuing endHandler() call
        effectStopped = true;
    }
    
    /**
     *  Called when an effect instance has finished playing. 
     *  If you override this method, ensure that you call the super method.
     *
     *  @param event An event object of type EffectEvent.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function effectEndHandler(event:EffectEvent):void 
    {
        // Transitions should set the end values when done
        if (applyEndValuesWhenDone && !effectStopped)   
            applyEndValues(propertyChangesArray, targets);

        var instance:IEffectInstance = IEffectInstance(event.effectInstance);
        
        deleteInstance(instance);
        propertyChangesArray = null;
        applyEndValuesWhenDone = false;

        dispatchEvent(event);

    }

}

}
