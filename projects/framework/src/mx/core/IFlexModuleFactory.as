////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.core
{

/**
 *  The IFlexModuleFactory interface represents the contract expected
 *  for bootstrapping Flex applications and dynamically loaded
 *  modules.
 *
 *  <p>Calling the <code>info()</code> method is legal immediately after
 *  the <code>complete</code> event is dispatched.</p>
 *
 *  <p>A well-behaved module dispatches a <code>ready</code> event when
 *  it is safe to call the <code>create()</code> method.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IFlexModuleFactory
{
    import flash.display.LoaderInfo;    
    import flash.utils.Dictionary;

    import mx.core.RSLData;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The RSLs loaded by this SystemManager or FlexModuleFactory before the
     *  application starts. This dictionary may also include RSLs loaded into this 
     *  module factory's application domain by other modules or 
     *  sub-applications. When a new dictionary entry is added by a child module
     *  factory an <code>RSLEvent.RSL_ADD_PRELOADED</code> event is dispatched
     *  by module factory owning the dictionary.
     * 
     *  Information about preloadedRSLs is stored in a Dictionary. The key is
     *  the RSL's LoaderInfo. The value is the a Vector of RSLData where the 
     *  first element is the primaray RSL and the remaining elements are 
     *  failover RSLs.
     */   
    function get preloadedRSLs():Dictionary;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Adds an RSL to the preloadedRSLs list. This method is called by child
     *  module factories when they add load an RSL into this module factory's
     *  application domain.
     * 
     *  <p>You do not call this method directly. This method is called by child
     *  module factories when they add load an RSL into this module factory's
     *  application domain.</p>
     *
     *  @param loaderInfo The loaderInfo of the loaded RSL.
     *  @param rsl The RSL's configuration information. A Vector of RSLData.
     *  The first element in the array is the primary RSL. The remaining 
     *  elements are failover RSLs.
     */ 
    function addPreloadedRSL(loaderInfo:LoaderInfo, rsl:Vector.<RSLData>):void;

    /**
     *  Calls the <code>Security.allowDomain()</code> method for the SWF associated with this IFlexModuleFactory
     *  plus all the SWFs assocatiated with RSLs preloaded by this IFlexModuleFactory.
     * 
     */  
    function allowDomain(... domains):void;
    
    /**
     *  Calls the <code>Security.allowInsecureDomain()</code> method for the SWF associated with this IFlexModuleFactory
     *  plus all the SWFs assocatiated with RSLs preLoaded by this IFlexModuleFactory.
     * 
     */  
    function allowInsecureDomain(... domains):void;
    
    /**
     *  A way to call a method in this IFlexModuleFactory's context
     *
     *  @param fn The function or method to call.
     *  @param thisArg The <code>this</code> pointer for the function.
     *  @param argArray The arguments for the function.
     *  @param returns If <code>true</code>, the function returns a value.
     *
     *  @return Whatever the function returns, if anything.
     *  
     *  @see Function.apply
	 *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 3
     */
    function callInContext(fn:Function, thisArg:Object,
						   argArray:Array, returns:Boolean = true):*;

    /**
     *  A factory method that requests
     *  an instance of a definition known to the module.
     *
     *  <p>You can provide an optional set of parameters to let
     *  building factories change what they create based
     *  on the input.
     *  Passing <code>null</code> indicates that the default
     *  definition is created, if possible.</p>
     *
     *  @param parameters An optional list of arguments. You can pass any number
     *  of arguments, which are then stored in an Array called <code>parameters</code>.
     *
     *  @return An instance of the module, or <code>null</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function create(... parameters):Object;

    /**
     *  Get the implementation for an interface.
     *  Similar to <code>Singleton.getInstance()</code> method, but per-
     *  IFlexModuleFactory.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getImplementation(interfaceName:String):Object;
    
    /**
     *  Returns a block of key/value pairs
     *  that hold static data known to the module.
     *  This method always succeeds, but can return an empty object.
     *
     *  @return An object containing key/value pairs. Typically, this object
     *  contains information about the module or modules created by this 
     *  factory; for example:
     * 
     *  <pre>
     *  return {"description": "This module returns 42."};
     *  </pre>
     *  
     *  Other common values in the returned object include the following:
     *  <ul>
     *   <li><code>fonts</code>: A list of embedded font faces.</li>
     *   <li><code>rsls</code>: A list of run-time shared libraries.</li>
     *   <li><code>mixins</code>: A list of classes initialized at startup.</li>
     *  </ul>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function info():Object;
    
    /**
     *  Register an implementation for an interface.
     *  Similar to the <code>Singleton.registerClass()</code> method, but per-
     *  IFlexModuleFactory, and takes an instance not a class.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function registerImplementation(interfaceName:String,
                                    impl:Object):void;
    
}

}
