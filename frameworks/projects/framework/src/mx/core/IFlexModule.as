////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2006-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

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
