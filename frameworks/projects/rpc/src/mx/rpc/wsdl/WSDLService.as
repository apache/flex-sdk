
package mx.rpc.wsdl
{

[ExcludeClass]

/**
 * A service groups a set of related ports together for a given WSDL.
 * 
 * @private
 */
public class WSDLService
{
    public function WSDLService(name:String)
    {
        super();
        _name = name;
        _ports = {};
    }


    //--------------------------------------------------------------------------
    //
    // Properties
    // 
    //--------------------------------------------------------------------------

    public function get defaultPort():WSDLPort
    {
        return _defaultPort;
    }

    /**
     * The unique name of this service.
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

    /**
     * Provides access to this service's map of ports.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get ports():Object
    {
        return _ports;
    }


    //--------------------------------------------------------------------------
    //
    // Methods
    // 
    //--------------------------------------------------------------------------

    /**
     * Registers a port with this service.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function addPort(port:WSDLPort):void
    {
        _ports[port.name] = port;
        if (_defaultPort == null)
            _defaultPort = port;
    }    

    /**
     * Retrieves a port by name.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getPort(name:String):WSDLPort
    {
        return _ports[name];
    }

    
    private var _defaultPort:WSDLPort;
    private var _name:String;
    private var _ports:Object;
}

}
