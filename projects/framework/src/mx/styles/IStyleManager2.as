////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.styles
{

import flash.events.IEventDispatcher;
import flash.system.ApplicationDomain;
import flash.system.SecurityDomain;

[ExcludeClass]

/**
 *  @private
 *  This interface is used internally by Flex 3.
 *  Flex 2.0.1 used the IStyleManager interface.
 */
public interface IStyleManager2 extends IStyleManager
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *   
     *  The style manager that is the parent of this StyleManager.
     *  
     *  @return the parent StyleManager or null if this is the top-level StyleManager.
     */
    function get parent():IStyleManager2;
    
    /**
     *  @private
     */
    function set parent(parent:IStyleManager2):void;
    
    //----------------------------------
	//  selectors
    //----------------------------------
	
	/**
	 *  @private
	 */
	function get selectors():Array;

    //----------------------------------
    //  typeHierarchyCache
    //----------------------------------

    function get typeHierarchyCache():Object;
    function set typeHierarchyCache(value:Object):void;

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    function getStyleDeclarations(subject:String):Array;

    /**
     * @private
     */ 
    function hasPseudoCondition(value:String):Boolean;

    /**
     * @private
     */ 
    function hasAdvancedSelectors():Boolean;

	/**
	 *  @private
	 *  In Flex 2, the static method StyleManager.loadStyleDeclarations()
	 *  had three parameters and called loadStyleDeclarations()
	 *  on IStyleManager.
	 *  In Flex 3, the static method has four parameters and calls
	 *  this method.
	 */
	function loadStyleDeclarations2(
				url:String, update:Boolean = true,
				applicationDomain:ApplicationDomain = null,
				securityDomain:SecurityDomain = null):IEventDispatcher;
}

}
