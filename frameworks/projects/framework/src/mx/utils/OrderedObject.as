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
package mx.utils
{

import flash.utils.Proxy;
import flash.utils.flash_proxy;
import mx.utils.object_proxy;

use namespace flash_proxy;
use namespace object_proxy;

/**
 *  OrderedObject acts as a wrapper to Object to preserve the ordering of the
 *  properties as they are added. 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */ 
public dynamic class OrderedObject extends flash.utils.Proxy
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructor.
     *
     * @param item An Object containing name/value pairs.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function OrderedObject(item:Object=null)
    {
        super();

        if (!item)
            item = {};
        _item = item;

        propertyList = [];                                
    }    

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  Contains a list of all of the property names for the proxied object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    object_proxy var propertyList:Array;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  object
    //----------------------------------

    /**
     *  Storage for the object property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private var _item:Object;


    /**
     *  @private
     * 
     *  Work around for the Flash Player bug #232854. The Proxy bug occurs when 
     *  the Proxy class is used in a sibling ApplicationDomain of the main 
     *  application's ApplicationDomain. When the Proxy class is used in a 
     *  sibling ApplicationDomain the RTE looks like this:
     * 
     *  ArgumentError: Error #1063: Argument count mismatch on 
     *  Object/http://adobe.com/AS3/2006/builtin::hasOwnProperty(). 
     *  Expected 0, got 2. 
     * 
     *  Returns the specified property value of the proxied object.
     *
     *  @param name Typically a string containing the name of the property, or
     *  possibly a QName where the property name is found by inspecting the
     *  <code>localName</code> property.
     *
     *  @return The value of the property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    object_proxy function getObjectProperty(name:*):*
    {
        return getProperty(name);
    }
    
    /**
     *  @private
     * 
     *  Work around for the Flash Player bug #232854. See the comments in 
     *  getObjectProperty() for more details.
     * 
     *  Call this method to set a property value instead of hashing into an 
     *  OrderObject which would end up calling setProperty().
     *
     *  Updates the specified property on the proxied object.
     *
     *  @param name Object containing the name of the property that should be
     *  updated on the proxied object.
     *
     *  @param value Value that should be set on the proxied object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    object_proxy function setObjectProperty(name:*, value:*):void
    {
        setProperty(name, value);
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Returns the specified property value of the proxied object.
     *
     *  @param name Typically a string containing the name of the property, or
     *  possibly a QName where the property name is found by inspecting the
     *  <code>localName</code> property.
     *
     *  @return The value of the property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override flash_proxy function getProperty(name:*):*
    {
        // if we have a data proxy for this then
        var result:Object = null;
            
        result = _item[name];
        
        return result;
    }

    /**
     *  Returns the value of the proxied object's method with the specified
     *  name.
     *
     *  @param name The name of the method being invoked.
     *  @param rest An array specifying the arguments to the called method.
     *
     *  @return The return value of the called method.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override flash_proxy function callProperty(name:*, ... rest):*
    {
        return _item[name].apply(_item, rest)
    }

    /**
     *  Deletes the specified property on the proxied object.
     * 
     *  @param name Typically a string containing the name of the property,
     *  or possibly a QName where the property name is found by 
     *  inspecting the <code>localName</code> property.
     *
     *  @return A Boolean indicating if the property was deleted.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override flash_proxy function deleteProperty(name:*):Boolean
    {
        var oldVal:Object = _item[name];
        var deleted:Boolean = delete _item[name]; 
        
        var deleteIndex:int = -1;
        for (var i:int = 0; i < propertyList.length; i++)
        {
            if (propertyList[i] == name)
            {
                deleteIndex = i;
                break;
            }
        }
        if (deleteIndex > -1)
        {
            propertyList.splice(deleteIndex, 1);
        }
                
        return deleted;
    }

    /**
     *  This is an internal function that must be implemented by a subclass of
     *  flash.utils.Proxy.
     *  
     *  @param name The property name that should be tested for existence.
     *
     *  @return If the property exists, <code>true</code>; otherwise
     *  <code>false</code>.
     *
     *  @see flash.utils.Proxy#hasProperty()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override flash_proxy function hasProperty(name:*):Boolean
    {
        return(name in _item);
    }

    /**
     *  This is an internal function that must be implemented by a subclass of
     *  flash.utils.Proxy.
     *
     *  @param index The zero-based index value of the object's property.
     *
     *  @return The property's name.
     *
     *  @see flash.utils.Proxy#nextName()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override flash_proxy function nextName(index:int):String
    {
        return propertyList[index -1];
    }

    /**
     *  This is an internal function that must be implemented by a subclass of
     *  flash.utils.Proxy.
     *
     *  @see flash.utils.Proxy#nextNameIndex()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override flash_proxy function nextNameIndex(index:int):int
    {        
        if (index < propertyList.length)
        {
            return index + 1;
        }
        else
        {
            return 0;
        }
    }

    /**
     *  This is an internal function that must be implemented by a subclass of
     *  flash.utils.Proxy.
     *
     *  @param index The zero-based index value of the object's property.
     *
     *  @return The property's value.
     *
     *  @see flash.utils.Proxy#nextValue()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override flash_proxy function nextValue(index:int):*
    {
        return _item[propertyList[index -1]];
    }

    /**
     *  Updates the specified property on the proxied object.
     *
     *  @param name Object containing the name of the property that should be
     *  updated on the proxied object.
     *
     *  @param value Value that should be set on the proxied object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override flash_proxy function setProperty(name:*, value:*):void
    {
        var oldVal:* = _item[name];
        if (oldVal !== value)
        {
            // Update item.
            _item[name] = value;
            
            for (var i:int = 0; i < propertyList.length; i++)
            {
                if (propertyList[i] == name)
                {
                    return;
                }
            }
            propertyList.push(name);
        }
    }               

}

}