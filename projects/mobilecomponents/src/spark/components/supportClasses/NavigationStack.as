////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

// TODO (chiedozi): Make private in view nav?
package spark.components.supportClasses
{    
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;

import spark.components.supportClasses.ViewHistoryData;

import mx.core.mx_internal;
use namespace mx_internal;

/**
 *  The NavigationStack class is a data structure that is internally used by 
 *  ViewNavigator to track the current set of views that are being managed 
 *  by the navigator.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class NavigationStack implements IExternalizable
{
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function NavigationStack()
    {
        super();
        
        _source = new Vector.<ViewHistoryData>();
    }
    
    //--------------------------------------------------------------------------
    //
    // Variables
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private var _source:Vector.<ViewHistoryData>;
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    mx_internal function get source():Vector.<ViewHistoryData>
    {
        return _source;
    }
    
    //--------------------------------------------------------------------------
    //
    // Properties
    // 
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  length
    //----------------------------------
    
    /**
     *  Returns the length of the stack.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */        
    public function get length():int
    {
        return _source.length;
    }
    
    //----------------------------------
    //  top
    //----------------------------------
    
    /**
     *  Returns the object at the top of the stack.  If the stack is empty, 
     *  this propety is null.
     * 
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    mx_internal function get topView():ViewHistoryData
    {
        return _source.length == 0 ? null : _source[_source.length - 1];
    }
    
    //--------------------------------------------------------------------------
    //
    // Methods
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  Clears the entire stack.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function clear():void
    {
        _source.length = 0;    
    }
    
    /**
     *  Adds a view to the top of the navigation stack.
     * 
     *  @param factory The class of the View to create.
     *  @param data The data object to pass to the view when it is created
     *  
     *  @return The data structure that represents the current view.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function push(factory:Class, data:Object):ViewHistoryData
    {
        var viewData:ViewHistoryData = new ViewHistoryData(factory, data);
        _source.push(viewData);
        
        return viewData;
    }
    
    /**
     *  Removes the top view off the stack.
     * 
     *  @return The data structure that represented the View.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function pop():ViewHistoryData
    {
        return _source.pop();
    }
    
    /**
     *  Removes all but the root object from the navigation stack.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function popToFirstView():void
    {
        if (_source.length > 1)
            _source.length = 1;
    }
    
    //--------------------------------------------------------------------------
    //
    // Methods: IExternalizable
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  Serializes the navigation stack in an IDataOutput object so that it
     *  can be written to a shared object.
     *  
     *  @param output The data output object used to write the data.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5 
     */ 
    public function writeExternal(output:IDataOutput):void
    {
        output.writeObject(_source);
    }
    
    /**
     *  Deserializes the navigation stack when being loaded from a shared
     *  object.
     *  
     *  @param input The external object to read from.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5 
     */ 
    public function readExternal(input:IDataInput):void 
    {
        _source = input.readObject() as Vector.<ViewHistoryData>;
    }
}
}