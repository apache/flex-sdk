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

package spark.components.supportClasses
{    
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;

import mx.core.mx_internal;

import spark.components.supportClasses.ViewDescriptor;
use namespace mx_internal;

[ExcludeClass]

/**
 *  The NavigationStack class is a data structure that is internally used by 
 *  ViewNavigator to track the current set of views that are being managed 
 *  by the navigator.
 *
 *  @see spark.components.ViewNavigator
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
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
        
        _source = new Vector.<ViewDescriptor>();
    }
    
    //--------------------------------------------------------------------------
    //
    // Variables
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private var _source:Vector.<ViewDescriptor>;
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    mx_internal function get source():Vector.<ViewDescriptor>
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
     *  The length of the stack.
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
     *  Returns the object at the top of the stack.  
     *  If the stack is empty, this property is null.
     * 
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    mx_internal function get topView():ViewDescriptor
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
     *  Pushing a view changes the display of the application to 
     *  the new view on the stack.
     * 
     *  @param viewClass The class of the View to create.
     *
     *  @param data The data object to pass to the view when it is created.
     *  The new view accesses this Object by using 
     *  the <code>View.data</code> property.
     *
     *  @param context The context identifier to pass to the view when 
     *  it is created.
     *  
     *  @return The data structure that represents the current view.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function pushView(viewClass:Class, data:Object, context:Object = null):ViewDescriptor
    {
        var viewData:ViewDescriptor = new ViewDescriptor(viewClass, data, context);
        _source.push(viewData);
        
        return viewData;
    }
    
    /**
     *  Removes the top view off the stack.
     *  Returns control from the current view back to 
     *  the previous view on the stack.
     * 
     *  @return The data structure that represented the View that was removed.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function popView():ViewDescriptor
    {
        return _source.pop();
    }
    
    /**
     *  Removes all but the root object from the navigation stack.
     *  The root object becomes the current view.
     *  
     *  @return The data structure that represented the View that was at 
     *  the top of the stack when this method was called, or null if
     *  nothing was removed.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function popToFirstView():ViewDescriptor
    {
        if (_source.length > 1)
        {
            var viewData:ViewDescriptor = topView;
            _source.length = 1;
            
            return viewData;
        }
        
        return null;
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
     *  Deserializes the navigation stack when it is being loaded 
     *  from a shared object.
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
        _source = input.readObject() as Vector.<ViewDescriptor>;
    }
}
}