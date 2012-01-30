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

package mx.core
{

/**
 *  Dispatched after the content for this component has been created. With deferred 
 *  instantiation, the content for a component can be created long after the 
 *  component is created.
 *
 *  @eventType mx.events.FlexEvent.CONTENT_CREATION_COMPLETE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="contentCreationComplete", type="mx.events.FlexEvent")]

/**
 *  The IDeferredContentOwner interface defines the properties and methods
 *  for deferred instantiation.
 * 
 *  @see spark.components.SkinnableContainer
 *  @see mx.core.Container
 *  @see mx.core.INavigatorContent
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface IDeferredContentOwner extends IUIComponent
{
    [Inspectable(enumeration="auto, all, none", defaultValue="auto")]

    /**
     *  Content creation policy for this component.
     *
     *  <p>Possible values are:
     *    <ul>
     *      <li><code>auto</code> - Automatically create the content immediately before it is needed.</li>
     *      <li><code>all</code> - Create the content as soon as the parent component is created. This
     *          option should only be used as a last resort because it increases startup time and memory usage.</li>
     *      <li><code>none</code> - Content must be created manually by calling 
     *          the <code>createDeferredContent()</code> method.</li>
     *    </ul>
     *  </p>
     *  
     *  <p>If no <code>creationPolicy</code> is specified for a container, that container inherits the value of 
     *  its parent's <code>creationPolicy</code> property.</p>
     *
     *  @default "auto"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get creationPolicy():String;
    function set creationPolicy(value:String):void;

    /**
     *  Create the content for this component. If the value of the <code>creationPolicy</code> property
     *  is <code>auto</code> or <code>all</code>, this the Flex framework calls this method. If the value of the 
     *  <code>creationPolicy</code> property is <code>none</code>, you must explicitly call this method
     *  to create the content for the component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function createDeferredContent():void;

    /**
     *  A flag that indicates whether the deferred content has been created.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get deferredContentCreated():Boolean;
}

}