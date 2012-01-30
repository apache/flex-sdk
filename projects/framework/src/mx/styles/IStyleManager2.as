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

/**
 *  The IStyleManager2 class manages the following:
 *  <ul>
 *    <li>Which CSS style properties the class inherits</li>
 *    <li>Which style properties are colors, and therefore get special handling</li>
 *    <li>A list of strings that are aliases for color values</li>
 *  </ul>
 *
 *  @see mx.styles.CSSStyleDeclaration
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 *
 */
public interface IStyleManager2 extends IStyleManager
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
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
     *  Returns an Array of all the CSS selectors that are registered with the StyleManager.
     *  You can pass items in this Array to the <code>getStyleDeclaration()</code> method to get the corresponding CSSStyleDeclaration object.
     *  Class selectors are prepended with a period.
     *  
     *  @return An Array of all of the selectors
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
	function get selectors():Array;

    //----------------------------------
    //  typeHierarchyCache
    //----------------------------------

    /**
     *  @private
     */
    function get typeHierarchyCache():Object;

    /**
     *  @private
     */
    function set typeHierarchyCache(value:Object):void;

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Gets the list of style declarations for the given subject. The subject
     *  is the right most simple type selector in a potential selector chain.
     * 
     *  @param subject The style subject.
     *  @return Array of StyleDeclarations for this subject.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    function getStyleDeclarations(subject:String):Array;

    /** 
     * Gets a CSSStyleDeclaration object that stores the rules 
     * for the specified CSS selector. The CSSStyleDeclaration object is 
     * created by merging the properties of the specified CSS selector in
     * this style manager with the properties of any parent style managers.
     * 
     * <p>If the <code>selector</code> parameter starts with a period (.), 
     * the returned CSSStyleDeclaration is a class selector and applies only to those instances 
     * whose <code>styleName</code> property specifies that selector 
     * (not including the period). 
     * For example, the class selector <code>".bigMargins"</code> 
     * applies to any UIComponent whose <code>styleName</code> 
     * is <code>"bigMargins"</code>.</p> 
     * 
     * <p>If the <code>selector</code> parameter does not start with a period, 
     * the returned CSSStyleDeclaration is a type selector and applies to all instances 
     * of that type. 
     * For example, the type selector <code>"Button"</code> 
     * applies to all instances of Button and its subclasses.</p> 
     * 
     * <p>The <code>global</code> selector is similar to a type selector 
     * and does not start with a period.</p> 
     * 
     * @param selector The name of the CSS selector. 
     * 
     * @return The style declaration whose name matches the <code>selector</code> property. 
     *  
     * @langversion 3.0 
     * @playerversion Flash 10 
     * @playerversion AIR 1.5 
     * @productversion Flex 4 
     */     
    function getMergedStyleDeclaration(selector:String):CSSStyleDeclaration;    

    /**
     *  @private 
     *  Determines whether any of the selectors declared a pseudo selector
     *  for the given state. This is used to avoid unnecessary style
     *  regeneration between state changes.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    function hasPseudoCondition(value:String):Boolean;

    /**
     *  @private
     *  Determines whether any of the selectors registered with the style
     *  manager have been advanced selectors (descendant selector, id selector,
     *  non-global class selector, or pseudo selector).
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
