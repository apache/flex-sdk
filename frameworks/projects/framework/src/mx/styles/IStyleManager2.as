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
    //  qualifiedTypeSelectors
    //----------------------------------

    /**
     *  @private
     *  Qualified type selectors were added in Flex 4 to support styling
     *  components with the same local name, e.g. 'spark.components.Button'.
     *  Prior to this type selectors were always unqualified class names  e.g.
     *  'Button'. To ease migration of Flex 3 application, this property can
     *  control whether CSS type selectors must be fully qualified class names
     *  when the compatibility version is 4 or later.
     */
    function get qualifiedTypeSelectors():Boolean;
    
    /**
     *  @private
     */
    function set qualifiedTypeSelectors(value:Boolean):void;
    
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
    function getMergedStyleDeclaration(selector:String):CSSStyleDeclaration;    

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
