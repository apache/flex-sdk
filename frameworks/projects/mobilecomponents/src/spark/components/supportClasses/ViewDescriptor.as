package spark.components.supportClasses
{    
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import spark.components.View;

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
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    public var instance:View;
    
    // Runtime data
    public var data:Object;
    
    // Serialized data
    public var persistedData:Object;
    
    public var factory:Class;
    
    
    //--------------------------------------------------------------------------
    //
    //  Methods: IExternalizable
    //
    //--------------------------------------------------------------------------

    public function writeExternal(output:IDataOutput):void
    {
        output.writeObject(persistedData);
        
        // Need to get class name using describe type
        output.writeObject(getQualifiedClassName(factory));
    }
    
    public function readExternal(input:IDataInput):void 
    {
        persistedData = input.readObject();
        
        var className:String = input.readObject();
        factory = getDefinitionByName(className) as Class;
    }
}
}