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
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import spark.components.View;

[ExcludeClass]

/**
 *  The ViewDescriptor object is a data structure used to store information
 *  about a view that is being managed by a ViewNavigator.
 *
 *  @see spark.components.ViewNavigator
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class ViewDescriptor implements IExternalizable
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     * 
     *  @param viewClass The class used to create the View object.
     * 
     *  @param data The data object to pass to the view when it is created.
     * 
     *  @param context The context of the view.
     * 
     *  @param instance A reference to the instance of the View object.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function ViewDescriptor(viewClass:Class = null, 
                              data:Object = null, 
                              context:Object = null,
                              instance:View = null)
    {
        this.viewClass = viewClass;
        this.data = data;
        this.context = context;
        this.instance = instance;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  context
    //----------------------------------
    
    /**
     *  The string that describes the context in which this view was created.  
     *  This property is assigned to the <code>context</code>
     *  parameter that is passed to the 
     *  <code>ViewNavigator.pushView()</code> method.
     *
     *  @see spark.components.ViewNavigator#pushView()
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var context:Object;
    
    //----------------------------------
    //  data
    //----------------------------------
    
    /**
     *  The current data object that is being used by the view.  
     *  When a view is removed from a navigation stack, this value 
     *  is updated to match the view's instance's current 
     *  <code>data</code> object.
     *
     *  @see spark.components.View#data
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var data:Object;
    
    //----------------------------------
    //  instance
    //----------------------------------
    
    /**
     *  A reference to the View instance that is represented by this object.
     *  The ViewNavigator creates and assigns the instance as needed.  
     *  This property is set to null when a view is destroyed.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var instance:View;
    
    //----------------------------------
    //  persistenceData
    //----------------------------------
    
    /**
     *  The serialized data that the view has requested be saved to disk when
     *  the application is writing data to a shared object or external file.
     *  This object is the result of calling 
     *  the <code>serializeData()</code> method on the View object.
     *   
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var persistenceData:Object;
    
    //----------------------------------
    //  viewClass
    //----------------------------------
    
    /**
     *  The class used to create the view.  
     *  The ViewNavigator expects this class to be a subclass of View.
     *
     *  @see spark.components.View
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var viewClass:Class;
    
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
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5 
     */ 
    public function writeExternal(output:IDataOutput):void
    {
        output.writeObject(context);
        output.writeObject(persistenceData);

        // Have to store the class name of the viewClass because classes can't be
        // written to a shared object
        output.writeObject(getQualifiedClassName(viewClass));
    }
    
    /**
     *  Deserializes the object when being loaded from a shared object.
     *  
     *  @param input The external object to read from.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5 
     */ 
    public function readExternal(input:IDataInput):void 
    {
        context = input.readObject();
        persistenceData = input.readObject();
        
        var className:String = input.readObject();
        viewClass = (className == "null") ? null : getDefinitionByName(className) as Class;
    }
}
}