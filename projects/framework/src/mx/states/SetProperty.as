////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
//  AdobePatentID="B770"
//
////////////////////////////////////////////////////////////////////////////////

package mx.states
{

import mx.core.FlexVersion;
import mx.core.UIComponent;
import mx.core.mx_internal;

use namespace mx_internal;

/**
 *  The SetProperty class specifies a property value that is in effect only 
 *  during the parent view state.
 *  You use this class in the <code>overrides</code> property of the State class.
 * 
 *  @mxml
 *
 *  <p>The <code>&lt;mx:SetProperty&gt;</code> tag
 *  has the following attributes:</p>
 *  
 *  <pre>
 *  &lt;mx:SetProperty
 *   <b>Properties</b>
 *   name="null"
 *   target="null"
 *   value="undefined"
 *  /&gt;
 *  </pre>
 *
 *  @see mx.states.State
 *  @see mx.states.SetEventHandler
 *  @see mx.states.SetStyle
 *  @see mx.effects.SetPropertyAction
 *
 *  @includeExample examples/StatesExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class SetProperty extends OverrideBase implements IOverride
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  This is a table of pseudonyms.
     *  Whenever the property being overridden is found in this table,
     *  the pseudonym is saved/restored instead.
     */
    private static const PSEUDONYMS:Object =
    {
        width: "explicitWidth",
        height: "explicitHeight",
        currentState: "currentStateDeferred"
    };

    /**
     *  @private
     *  This is a table of related properties.
     *  Whenever the property being overridden is found in this table,
     *  the related property is also saved and restored.
     */
    private static const RELATED_PROPERTIES:Object =
    {
        explicitWidth: [ "percentWidth" ],
        explicitHeight: [ "percentHeight" ]
    };

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @param target The object whose property is being set.
     *  By default, Flex uses the immediate parent of the State object.
     *
     *  @param name The property to set.
     *
     *  @param value The value of the property in the view state.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function SetProperty(target:Object = null, name:String = null,
                                value:* = undefined)
    {
        super();

        this.target = target;
        this.name = name;
        this.value = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Storage for the old property value.
     */
    private var oldValue:Object;
    
    /**
     *  @private
     *  Storage for the old related property values, if used.
     */
    private var oldRelatedValues:Array;
    
    /**
     *  @private
     *  Flag which tracks if we're actively overriding a property.
     */
    private var applied:Boolean = false;
    
    /**
     *  @private
     *  Our most recent parent context.
     */
    private var parentContext:UIComponent = null;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  name
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  The name of the property to change.
     *  You must set this property, either in 
     *  the SetProperty constructor or by setting
     *  the property value directly.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var name:String;

    //----------------------------------
    //  target
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  The object containing the property to be changed.
     *  If the property value is <code>null</code>, Flex uses the
     *  immediate parent of the State object.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var target:Object;
    
    /**
     *  The cached target for which we applied our override.
     *  We keep track of the applied target while applied since
     *  our target may be swapped out in the owning document and 
     *  we want to make sure we roll back the correct (original) 
     *  element. 
     *
     *  @private
     */
    private var appliedTarget:Object;

    //----------------------------------
    //  value
    //----------------------------------

    [Inspectable(category="General")]
    
    /**
     *  @private
     *  Storage for the value property.
     */
    public var _value:*;
    
    /**
     *  The new value for the property.
     *
     *  @default undefined
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get value():*
    {
        return _value;
    }

    /**
     *  @private
     */
    public function set value(val:*):void
    {
        _value = val;
        
        // Reapply if necessary.
        if (applied) 
        {
            apply(parentContext);
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: IOverride
    //
    //--------------------------------------------------------------------------

    /**
     *  IOverride interface method; this class implements it as an empty method.
     * 
     *  @copy IOverride#initialize()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function initialize():void
    {
    }

    /**
     * Utility function to return the pseudonym of the property
     * name if it exists on the object
     */
    private function getPseudonym(obj:*, name:String):String
    {
        var propName:String;
        if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_0)
            return (PSEUDONYMS[name] in obj) ?
                PSEUDONYMS[name] :
                name;
        propName = PSEUDONYMS[name];
        if (!(PSEUDONYMS[name] in obj))
        {
            // 'in' does not work for mx_internal properties 
            // like currentStateDeferred
            try
            {
                // Check if we can access the property; if it doesn't
                // exist, it'll throw a ReferenceError
                var tmp:* = obj[PSEUDONYMS[name]];
            }
            catch (e:ReferenceError)
            {
                propName = name;
            }
        }
        else
        {
            propName = name;
        }
        return propName;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function apply(parent:UIComponent):void
    {   
        var obj:* = getOverrideContext(target, parent);
        if (obj != null)
        {
        	appliedTarget = obj;
            var propName:String = PSEUDONYMS[name] ? getPseudonym(obj, name) : name;
	
	        var relatedProps:Array = RELATED_PROPERTIES[propName] ?
	                                 RELATED_PROPERTIES[propName] :
	                                 null;
	
	        var newValue:* = value;
	
	        // Remember the original value so it can be restored later
	        // after we are asked to remove our override (and only if we
	        // aren't being asked to re-apply a value).
	        if (!applied)
	        {
	            oldValue = obj[propName];
	        }
	
	        if (relatedProps)
	        {
	            oldRelatedValues = [];
	
	            for (var i:int = 0; i < relatedProps.length; i++)
	                oldRelatedValues[i] = obj[relatedProps[i]];
	        }
	
	        // Special case for width and height. If they are percentage values,
	        // set the percentWidth/percentHeight instead.
	        if (name == "width" || name == "height")
	        {
	            if (newValue is String && newValue.indexOf("%") >= 0)
	            {
	                propName = name == "width" ? "percentWidth" : "percentHeight";
	                newValue = newValue.slice(0, newValue.indexOf("%"));
	            }
	            else
	            {
	                // Need to set width/height instead of explicitWidth/explicitHeight
	                // otherwise width/height are out of sync until the target is validated.
	                propName = name;
	            }
	        }
	
	        // Set new value
	        setPropertyValue(obj, propName, newValue, oldValue);
	        
	        // Save state in case our value is changed again while applied.  This can
	        // occur when our value property is databound.
	        applied = true;
	        this.parentContext = parent;
        }
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function remove(parent:UIComponent):void
    {   
        var obj:* = getOverrideContext(appliedTarget, parent);
        if (obj != null && applied)
        {
            var propName:String = PSEUDONYMS[name] ? getPseudonym(obj, name) : name;
	        
            var relatedProps:Array = RELATED_PROPERTIES[propName] ?
	                                 RELATED_PROPERTIES[propName] :
	                                 null;
	
	        // Special case for width and height. Restore the "width" and
	        // "height" properties instead of explicitWidth/explicitHeight
	        // so they can be kept in sync.
	        if ((name == "width" || name == "height") && !isNaN(Number(oldValue)))
	        {
	            propName = name;
	        }
	        
	        // Restore the old value
	        setPropertyValue(obj, propName, oldValue, oldValue);
	
	        // Restore related value, if needed
	        if (relatedProps)
	        {
	            for (var i:int = 0; i < relatedProps.length; i++)
	            {
	                setPropertyValue(obj, relatedProps[i],
	                        oldRelatedValues[i], oldRelatedValues[i]);
	            }
	        }
	        
	        // Clear our flags and override context.
	        applied = false;
	        parentContext = null;
	        appliedTarget = null;
        }
    }

    /**
     *  @private
     *  Sets the property to a value, coercing if necessary.
     */
    private function setPropertyValue(obj:Object, name:String, value:*,
                                      valueForType:Object):void
    {
        if (valueForType is Number)
            obj[name] = Number(value);
        else if (valueForType is Boolean)
            obj[name] = toBoolean(value);
        else
            obj[name] = value;
    }

    /**
     *  @private
     *  Converts a value to a Boolean true/false.
     */
    private function toBoolean(value:Object):Boolean
    {
        if (value is String)
            return value.toLowerCase() == "true";

        return value != false;
    }
}

}
