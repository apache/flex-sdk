
package mx.core
{

/**
 *  The IFlexModule interface is used as an optional contract with IFlexModuleFactory.
 *  When an IFlexModule instance is created with the IFlexModuleFactory, the factory
 *  stores a reference to itself after creation.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IFlexModule
{
    /**
     *  @private
     */
    function set moduleFactory(factory:IFlexModuleFactory):void;

    /**
     * @private
     */
    function get moduleFactory():IFlexModuleFactory;

}

}
