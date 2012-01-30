
package mx.modules
{

import flash.events.EventDispatcher;

[Frame(factoryClass="mx.core.FlexModuleFactory")]

/**
 *  The base class for ActionScript-based dynamically-loadable modules.
 *  If you write an ActionScript-only module, you should extend this class.
 *  If you write an MXML-based module by using the <code>&lt;mx:Module&gt;</code> 
 *  tag in an MXML file, you instead extend the Module class.
 *  
 *  @see mx.modules.Module
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class ModuleBase extends EventDispatcher implements IModule
{
    include "../core/Version.as";
}

}
