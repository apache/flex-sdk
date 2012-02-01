////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.filters {  

import flash.display.Shader;
import flash.display.ShaderInput;
import flash.display.ShaderParameter;
import flash.display.ShaderParameterType;
import flash.display.ShaderPrecision;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.filters.BitmapFilter;
import flash.filters.ShaderFilter;
import flash.utils.Proxy;
import flash.utils.flash_proxy;

import mx.filters.BaseFilter;
import mx.filters.IBitmapFilter;

use namespace flash_proxy;

/**
 * The Flex ShaderFilter class abstracts away many of the details of using
 * the Flash ShaderFilter, Shader, and ShaderData classes to apply a
 * Pixel Bender shader as a filter.
 *
 * <p>The ShaderFilter class must be initialized with either an instance of a Shader 
 * object or Class representative of a Shader (such as from an Embed). The ShaderFilter 
 * class then serves as a proxy to the underlying Shader, providing a convenience 
 * mechanism for accessing both scalar and multi-dimensional shader input parameters 
 * directly as simple named properties.</p>
 *
 * <p>To set a simple scalar shader input parameter, such as of type FLOAT or INT, you can 
 * refer to the property directly, for example, <code>myFilter.radius</code>.</p>
 *
 * <p>To set or animate an individual component of a multidimensional shader input parameter, such as 
 * FLOAT2, you can use a property suffix convention to access the individual value directly.  
 * The following code shows two ways to set the first and second components of the FLOAT2
 * property <code>center</code>:
 * <code><pre>
 *     // 'center' is an input parameter of type FLOAT2.
 *     shader.center = [10,20];
 * </pre></code>
 * <code><pre>
 *     // Use property suffix convention to access the first and second component of 'center'. 
 *     shader.center_x = 10;
 *     shader.center_y = 20;
 * </pre></code></p>
 *
 * <p>The full set of supported property suffixes that you can use are as follows: </p>
 *
 * <ul>
 * <li>For shader input parameters of type BOOL2, BOOL3, BOOL4, FLOAT2, FLOAT3, FLOAT4, INT2, 
 * INT3, or INT4, you can use "r g b a", "x y z w", or "s t p q"  
 * to access the 1st, 2nd, 3rd and 4th component, respectively.</li>
 *
 * <li>For shader input parameters of type MATRIX2x2, MATRIX3x3, or MATRIX4x4, you can use 
 * "a b c d e f g h i j k l m n o p" to access the 
 * 1st - 16th component of a given matrix, respectively.</li>
 * </ul>
 *
 * <p>As properties on the ShaderFilter change (such as during animation), the
 * ShaderFilter automatically reapplies itself to the filters array of the visual
 * component it is applied to.</p>
 * 
 *  @mxml 
 *  <p>The <code>&lt;s:ShaderFilter&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:ShaderFilter
 *    <strong>Properties</strong>
 *    bottomExtension="0"
 *    leftExtension="0"
 *    precisionHint="full"
 *    rightExtension="0"
 *    shader="[]"
 *    topExtension="0"
 *  /&gt;
 *  </pre>
 *
 * @see spark.effects.AnimateFilter 
 *
 * @example Simple ShaderFilter example:
 * <listing version="3.0">
 * &lt;?xml version="1.0"?&gt;
 * &lt;s:Application 
 *    xmlns:s="library://ns.adobe.com/flex/spark" 
 *    xmlns:fx="http://ns.adobe.com/mxml/2009"&gt;
 *
 *     &lt;!-- The hypothetical 'spherize' shader applied below has two input parameters, 'center' and 'radius'
 *          with the following attributes:
 *
 *          parameter 'center' ==&lt;
 *              type: float2
 *              minValue: float2(-200,-200)
 *              maxValue: float2(800,500)
 *              defaultValue: float2(400,250)
 *              description: "displacement center"
 *  
 *          parameter 'radius' ==&lt;
 *              type: float
 *              minValue: float(.1)
 *              maxValue: float(400)
 *              defaultValue: float(200)
 *              description: "radius"
 *     --&gt;
 *  
 *     &lt;s:Label text="ABCDEF"&gt;
 *         &lt;s:filters&gt;
 *             &lt;s:ShaderFilter shader="&#64;Embed(source='shaders/spherize.pbj')"
 *                 radius="25" center_x="50" center_y="15" /&gt;
 *        &lt;/s:filters&gt;
 *     &lt;/s:Label&gt;
 *   
 * &lt;/s:Application&gt; 
 * </listing>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public dynamic class ShaderFilter extends Proxy
    implements IBitmapFilter, IEventDispatcher
{  
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
         
    /**
     * Private storage for incoming properties, queued until
     * shader is initialized and available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private var propertyQueue:Object;  
          
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  @param shader Fully realized flash.display.Shader instance, or
     *  Class representing a Shader (such as from an Embed).
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function ShaderFilter(shader:Object=null)  
    {  
        super();
        eventDispatcher = new EventDispatcher();
        this.shader = shader;         
    }  
     
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  shaderInstance
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the shader property.
     */
    private var _shader:Shader;
    
    /**
     *  @private
     *  Storage for the last assigned Shader Class.
     */
    private var _shaderClass:Class;
    
    /**
     * An object representing the Shader to use with this filter. Either a Class 
     * or Shader instance is allowed.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function set shader(value:*):void
    {
        // Create our shader instance from the byteCode provided. Since our 
        // bytecode is sometimes reassigned by the binding infrastructure we 
        // only initialize ourselves upon the first instance.
        if (value is Shader && value != _shader)
        {
            _shader = value;
        }
        else if (value is Class && value != _shaderClass)
        {
            var obj:Object = new value();
            _shader = obj as Shader; 
            _shaderClass = value;
        }

        // Push any pending properties onto the new shader instance. 
        applyQueuedProperties();
            
        // Our new filter is ready to do its work.
        notifyFilterChanged();
    }
    
    /**
     * A flash.display.Shader instance.
     *
     *  @see flash.display.Shader 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */  
    public function get shader():Shader
    {
        return _shader;
    }
 
    //----------------------------------
    //  bottomExtension
    //----------------------------------

    private var _bottomExtension:int = 0;

    /**
     *  @copy flash.filters.ShaderFilter#bottomExtension
     *
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get bottomExtension():int
    {
        return _bottomExtension;
    }

    public function set bottomExtension(value:int):void
    {
        if (value == _bottomExtension)
            return;
        
        _bottomExtension = value;
        notifyFilterChanged();
    }

    //----------------------------------
    //  topExtension
    //----------------------------------

    private var _topExtension:int = 0;

    /**
     *  @copy flash.filters.ShaderFilter#topExtension
     *
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get topExtension():int
    {
        return _topExtension;
    }

    public function set topExtension(value:int):void
    {
        if (value == _topExtension)
            return
        
        _topExtension = value;
        notifyFilterChanged();
    }

    //----------------------------------
    //  leftExtension
    //----------------------------------

    private var _leftExtension:int = 0;

    /**
     *  @copy flash.filters.ShaderFilter#leftExtension
     *
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get leftExtension():int
    {
        return _leftExtension;
    }

    public function set leftExtension(value:int):void
    {
        if (value == _leftExtension)
            return;
        
        _leftExtension = value;
        notifyFilterChanged();
    }

    //----------------------------------
    //  rightExtension
    //----------------------------------

    private var _rightExtension:int = 0;

    /**
     *  @copy flash.filters.ShaderFilter#rightExtension
     *
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get rightExtension():int
    {
        return _rightExtension;
    }

    public function set rightExtension(value:int):void
    {
        if (value == _rightExtension)
            return;
        
        _rightExtension = value;
        notifyFilterChanged();
    }
    
    //----------------------------------
    //  precisionHint
    //----------------------------------

    /**
     * @private
     */  
    private var _precisionHint:String = ShaderPrecision.FULL;

    /**
     *  The precision of math operations performed by the underlying shader.
     *  The set of possible values for the precisionHint property is defined 
     *  by the constants in the ShaderPrecision class.
     *
     *  @default ShaderPrecision.FULL
     * 
     *  @see flash.display.Shader
     *  @see flash.display.ShaderPrecision
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get precisionHint():String
    {
        return _precisionHint;
    }

    public function set precisionHint(value:String):void
    {
        if (value == _precisionHint)
            return;
        
        _precisionHint = value;
        notifyFilterChanged();
    }

    //--------------------------------------------------------------------------
    //
    //  ShaderData Proxy
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     * Proxies all property 'gets' to the owned shader instance or
     * our propertyQueue otherwise.
     */     
    override flash_proxy function getProperty(name:*):*
    {
        return (_shader) ? retrieveShaderProperty(name) : propertyQueue[name];
    }

    /**
     * @private
     * Proxies all property 'sets' to the owned shader instance.
     * If the shader bytecode has yet to be set or instanced, we
     * queue the properties for later application.
     */ 
    override flash_proxy function setProperty(name:*, value:*):void 
    {            
        if (_shader)
        {
            // We have a shader, push all properties to the shader
            // instance itself.
            applyProperty(name.toString(), value);
            notifyFilterChanged();
        }
        else
        {
            // The shader has yet to be initialized, queue any properties,
            // the will be applied upon creation of the shader.
            propertyQueue = propertyQueue ? propertyQueue : new Object();
            propertyQueue[name] = value;
        }
    }
    
    /**
     * @private
     * Proxies method calls to our shader instance.
     */ 
    override flash_proxy function callProperty(name:*, ... args):*
    {
        if (_shader) 
            return _shader[name].apply(_shader, args);
    }

    /**
     * @private
     * Required to support property 'in' operator.
     */ 
    override flash_proxy function hasProperty(name:*):Boolean
    {
        if (!_shader || !name || name == "")
            return false;
            
        var index:int = name.indexOf("_");
        var prefix:String = (index > 0) ? name.substring(0, index) : name;
            
        return (name in _shader || name in _shader.data || prefix in _shader.data);
    }
    
    /**
     * @private
     * Apply our queued properties once our shader instance has
     * been constructed and initialized from its bytecode.
     */
    private function applyQueuedProperties():void
    {
        if (_shader)
        {
            for (var property:String in propertyQueue)
            {   
                applyProperty(property, propertyQueue[property]); 
            }
            
            propertyQueue = null;
        }
    }  
 
    /**
     * @private
     * Apply a single property value, provides special case conventions for 
     * targetting specific indexes of multi-dimensional shader properties.
     * 
     * If the property identifier fits the pattern 'NAME_<S>' and the value
     * being set is a scalar, we look for a matching multidimension shader 
     * input parameter 'NAME' and interpret the provide suffix 'S' as a named 
     * dimension as detailed below (indexForDimension). 
     *
     * We interpret the property name 'as is' otherwise (if 'NAME' does not 
     * match an n-dimensional property, or if the value provided is a scaler).
     */
    private function applyProperty(property:String, value:*):void
    {
        if (value == null) 
            return;
        
        var suffixPattern:RegExp = /_.$/;
        var match:Array = property.match(suffixPattern);
        
        // If this property name contains a suffix, attempt to push the value
        // to the specified component of a multi-dimensional property.
        if (match && match[0] && !(value is Array))
        {
            var suffix:String = match[0];
            var name:String = property.substr(0, property.length - suffix.length);
            var dimension:String = suffix.substr(suffix.length-1, 1);
            
            var propertyInfo:ShaderParameter = _shader.data[name];
            if (propertyInfo)
            {
                var index:int = indexForDimension(propertyInfo.type, dimension);
                if (index != -1)
                {
                    var currentValue:Array = propertyInfo.value ? propertyInfo.value : new Array();
                    currentValue[index] = value;
                    propertyInfo.value = currentValue;
                    return;
                }
            }
        }
        
        // Otherwise if the target property is a ShaderInput instance or
        // array property, set the value.
        if (_shader.data[property] is ShaderInput)
            _shader.data[property].input = value;
        else
            _shader.data[property].value = (value is Array) ? value : [value];
    }  
    
    /**
     * @private
     * Retrieve a single property value, provides special case conventions for 
     * retrieving specific components of multi-dimensional shader properties.
     */
    private function retrieveShaderProperty(name:*):*
    {
        name = (name is QName) ? name.localName : name;
        var suffixPattern:RegExp = /_.$/;
        var match:Array = name.match(suffixPattern);
        
        // If this property name contains a suffix, attempt to retrieve the value
        // from the specified component of a multi-dimensional property.
        if (match && match[0])
        {
            var suffix:String = match[0];
            var prop:String = name.substr(0, name.length - suffix.length);
            var dimension:String = suffix.substr(suffix.length-1, 1);
            
            var propertyInfo:ShaderParameter = _shader.data[prop];
            if (propertyInfo)
            {
                var index:int = indexForDimension(propertyInfo.type, dimension);
                if (index != -1)
                    return propertyInfo.value[index];
            }
        }
        
        // Otherwise return the appropriate value for the property type.
        return (_shader.data[name] is ShaderInput) ? 
            _shader.data[name].input : 
            _shader.data[name].value;  
    }
    
    /**
     * @private
     * Given a property of the form property_<S> where S is a single
     * character representing a named dimension of a multi-dimensional
     * parameter, return the associated numeric index.
     */
    private function indexForDimension(type:String, dimension:String):int
    {
       var index:int = 0;
       
       if (type == ShaderParameterType.MATRIX2X2 ||
           type == ShaderParameterType.MATRIX3X3 ||
           type == ShaderParameterType.MATRIX4X4)
       {
           // "abcdefghijklmnop" convenience access to:
           //   MATRIX 2x2, MATRIX3x3, or MATRIX4x4
           index = dimension.charCodeAt(0) - 0x61; // 'a' 
       }
       else if (Number(type.charAt(type.length - 1)) > 0)
       {
           // "rgba", "xyzw", or "stpq" convenience access to:
           //  BOOL2, BOOL3, BOOL4, FLOAT2, FLOAT3, FLOAT4, 
           //  INT2, INT3, or INT4
           index = "rgba".indexOf(dimension);
           index = (index == -1) ? "xyzw".indexOf(dimension) : index;
           index = (index == -1) ? "stpq".indexOf(dimension) : index;
       }
       
       return index;
    }
    
    //--------------------------------------------------------------------------
    //
    //  IBitmapFilter/BaseFilter
    //
    //--------------------------------------------------------------------------
        
    /**
     * @private
     * Notify of a change to our filter, so that filter stack is ultimately 
     * re-applied by the framework.
     */     
    public function notifyFilterChanged():void
    {
        dispatchEvent(new Event(BaseFilter.CHANGE));
    }

    /**
     * @private 
     * Returns a native flash.filters.ShaderFilter instance suitable
     * for application in a DisplayObject filter stack.
     */ 
    public function clone():BitmapFilter
    {
        var instance:flash.filters.ShaderFilter;
        if (_shader)
        {
            _shader.precisionHint = _precisionHint ? 
                _precisionHint : _shader.precisionHint;
            instance = new flash.filters.ShaderFilter(_shader);
            instance.bottomExtension = _bottomExtension;
            instance.topExtension = _topExtension;
            instance.leftExtension = _leftExtension;
            instance.rightExtension = _rightExtension;
        }
    
        return instance;
    }
    
    //--------------------------------------------------------------------------
    //
    //  IEventDispatcher
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */  
    private var eventDispatcher:EventDispatcher;
 
    /**
     * @private
     */ 
    public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, 
            priority:int = 0, useWeakReference:Boolean = false):void 
    {
        eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    /**
     * @private
     */ 
    public function dispatchEvent(event:Event):Boolean 
    {
        return eventDispatcher.dispatchEvent(event);
    }

    /**
     * @private
     */ 
    public function hasEventListener(type:String):Boolean 
    {
        return eventDispatcher.hasEventListener(type);
    }

    /**
     * @private
     */  
    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void 
    {
        eventDispatcher.removeEventListener(type, listener, useCapture);
    }

    /**
     * @private
     */  
    public function willTrigger(type:String):Boolean 
    {
        return eventDispatcher.willTrigger(type);
    }
    
}  

}  
