////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.modules
{
import flash.events.Event;

import mx.core.ContainerCreationPolicy;
import mx.modules.IModule;
import spark.components.SkinnableContainer;

[Frame(factoryClass="mx.core.FlexModuleFactory")]

//--------------------------------------
//  Other metadata
//--------------------------------------

/**
 *  Modules are not supported for AIR mobile applications.
 */
[DiscouragedForProfile("mobileDevice")]

/**
 *  The base class for MXML-based dynamically-loadable modules. You extend this
 *  class in MXML by using the <code>&lt;s:Module&gt;</code> tag in an MXML file, as the
 *  following example shows:
 *  
 *  <pre>
 *  &lt;?xml version="1.0"?&gt;
 *  &lt;!-- This module loads an image. --&gt;
 *  &lt;s:Module  width="100%" height="100%" xmlns:s="library://ns.adobe.com/flex/spark"&gt;
 *  
 *    &lt;s:Image source="trinity.gif"/&gt;
 *  
 *  &lt;/s:Module&gt;
 *  </pre>
 *  
 *  @see mx.modules.ModuleManager
 *  @see spark.modules.ModuleLoader
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10.2
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class Module extends SkinnableContainer 
       implements IModule
{
    include "../core/Version.as";
    

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function Module()
    {
        super();
    }
        
}

}
