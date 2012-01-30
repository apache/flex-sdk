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

package mx.core
{

/**
 *  The ApplicationDomainTarget class defines the possible values for the 
 *  <code>applicationDomainTarget</code> property of the <code>RSLData</code>
 *  class. Each application domain target specifies a relative application 
 *  domain that is resolved at runtime.
 *
 *  @see mx.core.RSLData
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.2
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public final class ApplicationDomainTarget
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The default behavior for RSL loading is to load an RSL as high in 
     *  the parent module factory chain as possible. In order to load an RSL
     *  into a parent module factory, that module factory must have been 
     *  compiled with that RSL specified in the compiler options. If no parent module 
     *  factories were compiled with that RSL , then the RSL will be loaded in
     *  the application domain of the module factory loading the RSL.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const DEFAULT:String = "default";
    
    /**
     *  The application domain of the current module factory.
     *   
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const CURRENT:String = "current";
    
    /**
     *  The application domain of the parent module factory.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const PARENT:String = "parent";
    
    /**
     *  The application domain of the top-level module factory.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const TOP_LEVEL:String = "top-level";
    
}
    
}
