
package mx.rpc.wsdl
{

[ExcludeClass]

/**
 * A portType lists a set of named operations and defines abstract interface or
 * "messages" used to interoperate with each operation.
 * 
 * @private
 */ 
public class WSDLPortType
{
    public function WSDLPortType(name:String)
    {
        super();
        _name = name;
        _operations = {};
    }


    //--------------------------------------------------------------------------
    //
    // Properties
    // 
    //--------------------------------------------------------------------------

    /**
     * The unique name for this portType.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get name():String
    {
        return _name;
    }

    public function operations():Object
    {
        return _operations;
    }


    //--------------------------------------------------------------------------
    //
    // Methods
    // 
    //--------------------------------------------------------------------------
    
    public function addOperation(operation:WSDLOperation):void
    {
        _operations[operation.name] = operation;
    }

    public function getOperation(name:String):WSDLOperation
    {
        return _operations[name];
    }

    private var _name:String;
    private var _operations:Object;
}

}
