////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////'
// TODO (chiedozi): Make private talk to QE
package spark.components.supportClasses
{    
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import spark.components.View;

/**
 *  The ViewHistoryData object is a data structure used to store information
 *  about a view that is being managed by a ViewNavigator.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class ViewHistoryData implements IExternalizable
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     * 
     *  @param factory The class used to create the View
     *  @param data The data object to pass to the view when created
     *  @param instance A reference to the instance of the View
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function ViewHistoryData(factory:Class = null, data:Object = null, instance:View = null)
    {
        this.factory = factory;
        this.data = data;
        this.instance = instance;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  data
    //----------------------------------
    
    /**
     *  The current data object that is being used by the view.  When a view
     *  is removed from a navigation stack, this value will be updated to
     *  match the view's instance's current data object.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var data:Object;
    
    //----------------------------------
    //  factory
    //----------------------------------
    
    /**
     *  The class used to create the view.  ViewNavigator will expect this
     *  class to subclass View.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var factory:Class;
    
    //----------------------------------
    //  instance
    //----------------------------------
    
    /**
     *  A reference to the instance that is represented by this view object.
     *  ViewNavigator will create and assign the instance as needed.  This
     *  property will be nulled out when a view is destroyed.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var instance:View;
    
    //----------------------------------
    //  persistedData
    //----------------------------------
    
    /**
     *  The serialized data that the view has requested be saved to disk when
     *  the application is writing data to a shared object or external file.
     *  This object is the result of the <code>serializeData()</code> method
     *  on View.
     *   
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var persistedData:Object;
    
    //--------------------------------------------------------------------------
    //
    //  Methods: IExternalizable
    //
    //--------------------------------------------------------------------------

    // TODO (chiedozi): This method isn't module safe because it doesn't properly
    // check application domains when using getDefinitionByName.  Should use
    // systemManager to do this. (SDK-27424)
    /**
     *  Serializes this object stack in an IDataOutput object so that it
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
        output.writeObject(persistedData);

        // Have to store the class name of the factory because classes can't be
        // written to a shared object
        output.writeObject(getQualifiedClassName(factory));
    }
    
    /**
     *  Deserializes the object when being loaded from a shared object.
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
        persistedData = input.readObject();
        
        var className:String = input.readObject();
        factory = (className == "null") ? null : getDefinitionByName(className) as Class;
    }
}
}