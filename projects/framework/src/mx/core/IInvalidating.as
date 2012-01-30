////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.core
{

/**
 *  The IInvalidating interface defines the interface for components
 *  that use invalidation to do delayed -- rather than immediate --
 *  property commitment, measurement, drawing, and layout.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IInvalidating
{
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Calling this method results in a call to the component's
	 *  <code>validateProperties()</code> method
	 *  before the display list is rendered.
	 *
	 *  <p>For components that extend UIComponent, this implies
	 *  that <code>commitProperties()</code> is called.</p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function invalidateProperties():void;

	/**
	 *  Calling this method results in a call to the component's
	 *  <code>validateSize()</code> method
	 *  before the display list is rendered.
	 *
	 *  <p>For components that extend UIComponent, this implies
	 *  that <code>measure()</code> is called, unless the component
	 *  has both <code>explicitWidth</code> and <code>explicitHeight</code>
	 *  set.</p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function invalidateSize():void;

	/**
	 *  Calling this method results in a call to the component's
	 *  <code>validateDisplayList()</code> method
	 *  before the display list is rendered.
	 *
	 *  <p>For components that extend UIComponent, this implies
	 *  that <code>updateDisplayList()</code> is called.</p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function invalidateDisplayList():void;

    /**
     *  Validates and updates the properties and layout of this object
     *  by immediately calling <code>validateProperties()</code>,
	 *  <code>validateSize()</code>, and <code>validateDisplayList()</code>,
	 *  if necessary.
     *
     *  <p>When properties are changed, the new values do not usually have
	 *  an immediate effect on the component.
	 *  Usually, all of the application code that needs to be run
	 *  at that time is executed. Then the LayoutManager starts
	 *  calling the <code>validateProperties()</code>,
	 *  <code>validateSize()</code>, and <code>validateDisplayList()</code>
	 *  methods on components, based on their need to be validated and their 
	 *  depth in the hierarchy of display list objects.</p>
	 *
     *  <p>For example, setting the <code>width</code> property is delayed, because
	 *  it may require recalculating the widths of the object's children
	 *  or its parent.
     *  Delaying the processing also prevents it from being repeated
     *  multiple times if the application code sets the <code>width</code> property
	 *  more than once.
     *  This method lets you manually override this behavior.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function validateNow():void;
}

}
