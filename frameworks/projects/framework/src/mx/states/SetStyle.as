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

import mx.core.UIComponent;
import mx.styles.IStyleClient;
import mx.styles.StyleManager;

/**
 *  The SetStyle class specifies a style that is in effect only during the parent view state.
 *  You use this class in the <code>overrides</code> property of the State class.
 *
 *  @mxml
 *
 *  <p>The <code>&lt;mx:SetStyle&gt;</code> tag
 *  has the following attributes:</p>
 *  
 *  <pre>
 *  &lt;mx:SetStyle
 *   <b>Properties</b>
 *   name="null"
 *   target="null"
 *   value"null"
 *  /&gt;
 *  </pre>
 *
 *  @see mx.states.State
 *  @see mx.states.SetEventHandler
 *  @see mx.states.SetProperty
 *  @see mx.effects.SetStyleAction
 *
 *  @includeExample examples/StatesExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class SetStyle extends OverrideBase implements IOverride
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  This is a table of related properties.
     *  Whenever the property being overridden is found in this table,
     *  the related property is also saved and restored.
     */
    private static const RELATED_PROPERTIES:Object =
    {
        left: [ "x" ],
        top: [ "y" ],
        right: [ "x" ],
        bottom: [ "y" ]
    };
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @param target The object whose style is being set.
     *  By default, Flex uses the immediate parent of the State object.
     *
     *  @param name The style to set.
     *
     *  @param value The value of the style in the view state.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function SetStyle(
            target:IStyleClient = null,
            name:String = null,
            value:Object = null)
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
     *  Storage for the old style value.
     */
    private var oldValue:Object;

    /**
     *  @private
     *  Storage for the old related property values, if used.
     */
    private var oldRelatedValues:Array;
    
    /**
     *  @private
     *  Flag which tracks if we're actively overriding a style.
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
     *
     *  The name of the style to change.
     *  You must set this property, either in 
     *  the SetStyle constructor or by setting
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
     *
     *  The object whose style is being changed.
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
     *  Storage for the style value.
     */
    public var _value:Object;
    
    /**
     *  The new value for the style.
     *
     *  @default undefined
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get value():Object
    {
        return _value;
    }

    /**
     *  @private
     */
    public function set value(val:Object):void
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
    //  IOverride methods
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
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function apply(parent:UIComponent):void
    {
        var context:Object = getOverrideContext(target, parent);
        if (context != null)
        {
        	appliedTarget = context;
        	var obj:IStyleClient = IStyleClient(appliedTarget);
        	
	        var relatedProps:Array = RELATED_PROPERTIES[name] ?
	                                 RELATED_PROPERTIES[name] :
	                                 null;
	
	        // Remember the original value so it can be restored later
	        // after we are asked to remove our override (and only if we
	        // aren't being asked to re-apply a value).
	        if (!applied)
	        {
	            oldValue = obj.getStyle(name);
	        }
	
	        if (relatedProps)
	        {
	            oldRelatedValues = [];
	
	            for (var i:int = 0; i < relatedProps.length; i++)
	                oldRelatedValues[i] = obj[relatedProps[i]];
	        }
	
	        // Set new value
	        if (value === null)
	        {
	            obj.clearStyle(name);
	        }
	        else if (oldValue is Number)
	        {
	            // The "value" for colors can be several different formats:
	            // 0xNNNNNN, #NNNNNN or "red". We can't use
	            // StyleManager.isColorStyle() because that only returns true
	            // for inheriting color styles and misses non-inheriting styles like
	            // backgroundColor.
                if (name.toLowerCase().indexOf("color") != -1)
                {
	                obj.setStyle(name, StyleManager.getColorName(value));
                }
                else if (value is String && 
                         String(value).lastIndexOf("%") == 
                         String(value).length - 1)
                {
                    obj.setStyle(name, value);
                }
                else
                {
	                obj.setStyle(name, Number(value));
                }               
	        }
	        else if (oldValue is Boolean)
	        {
	            obj.setStyle(name, toBoolean(value));
	        }
	        else
	        {
	            obj.setStyle(name, value);
	        }
	        
	        // Save state in case our value is changed again while applied.  This can
	        // occur when our style value is databound.
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
        var obj:IStyleClient = IStyleClient(getOverrideContext(appliedTarget, parent));
        if (obj != null && applied)
        {
	        // Restore the old value
	        if (oldValue is Number)
	            obj.setStyle(name, Number(oldValue));
	        else if (oldValue is Boolean)
	            obj.setStyle(name, toBoolean(oldValue));
	        else if (oldValue === null)
	            obj.clearStyle(name);
	        else
	            obj.setStyle(name, oldValue);
	
	
	        var relatedProps:Array = RELATED_PROPERTIES[name] ?
	                                 RELATED_PROPERTIES[name] :
	                                 null;
	
	        // Restore related property values, if needed
	        if (relatedProps)
	        {
	            for (var i:int = 0; i < relatedProps.length; i++)
	            {
	                obj[relatedProps[i]] = oldRelatedValues[i];
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
