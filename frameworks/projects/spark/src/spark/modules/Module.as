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
 *  The Spark equivalent of mx:Module 
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
