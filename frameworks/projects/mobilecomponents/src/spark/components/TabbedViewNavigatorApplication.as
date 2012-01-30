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

package spark.components
{
import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.events.KeyboardEvent;

import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.supportClasses.ViewNavigatorApplicationBase;
import spark.components.supportClasses.ViewNavigatorBase;

use namespace mx_internal;

[DefaultProperty("navigators")]

/**
 *  The TabbedViewNavigatorApplication container defines an application 
 *  with multiple sections. 
 *  The TabbedViewNavigatorApplication container automatically creates 
 *  a TabbedMobileNavigator container. 
 *  The TabbedViewNavigator container creates the TabBar control to 
 *  support navigation among the sections of the application.
 *
 *  <p>The only allowable child of the TabbedViewNavigatorApplication 
 *  container is ViewNavigator. 
 *  Define one ViewNavigator for each section of the application.</p> 
 *
 *  <p>The TabbedViewNavigatorApplication container has the following 
 *  default characteristics:</p>
 *     <table class="innertable">
 *        <tr>
 *           <th>Characteristic</th>
 *           <th>Description</th>
 *        </tr>
 *        <tr>
 *           <td>Default size</td>
 *           <td>100% high and 100% wide to take up all available screen space.</td>
 *        </tr>
 *        <tr>
 *           <td>Child layout</td>
 *           <td>Defined by the individual View containers 
 *               that make up the views of the application.</td>
 *        </tr>
 *        <tr>
 *           <td>Scroll bars</td>
 *           <td>None. If you do add scroll bars, users can scroll the entire application. 
 *              That includes the ActionBar and TabBar area of the application. 
 *              Because you typically do not want those areas of the view to scroll, 
 *              add scroll bars to the individual View containers of the application, 
 *              rather than to the application container itself. </td>
 *        </tr>
 *        <tr>
 *           <td>Default skin class</td>
 *           <td>spark.skins.mobile.TabbedViewNavigatorApplicationSkin</td>
 *        </tr>
 *     </table>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:TabbedViewNavigatorApplication&gt;</code> tag inherits all of the tag
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:TabbedViewNavigatorApplication
 *    <strong>Properties</strong>
 *    navigators="null"
 * 
 *  /&gt;
 *  </pre>
 *
 *  @see spark.components.TabbedViewNavigator
 *  @see spark.components.TabBar
 *  @see spark.skins.mobile.TabbedViewNavigatorApplicationSkin
 *  @includeExample examples/TabbedViewNavigatorApplicationExample.mxml -noswf
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class TabbedViewNavigatorApplication extends ViewNavigatorApplicationBase
{
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    [Bindable]
    [SkinPart(required="false")]
    /**
     *  The main tabbedNavigator for the application.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var tabbedNavigator:TabbedViewNavigator;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function TabbedViewNavigatorApplication()
    {
        super();

        NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, activateHandler);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    /**
     *  @private
     */
    private var navigatorProperties:Object = {};
    
    //----------------------------------
    //  activeView
    //----------------------------------
    
    /**
     *  @private
     */ 
    override mx_internal function get activeView():View
    {
        if (tabbedNavigator)
            return tabbedNavigator.activeView;
        
        return null;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  exitApplicationOnBackKey
    //----------------------------------
    /**
     *  @private
     */ 
    override mx_internal function get exitApplicationOnBackKey():Boolean
    {
        if (tabbedNavigator)
            return tabbedNavigator.exitApplicationOnBackKey;
        
        return super.exitApplicationOnBackKey;
    }
    
    //----------------------------------
    //  navigators
    //----------------------------------
    /**
     *  @copy TabbedViewNavigator#navigators
     *  
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get navigators():Vector.<ViewNavigatorBase>
    {
        if (tabbedNavigator)
            return tabbedNavigator.navigators;
        else
            return navigatorProperties.navigators;
    }
    /**
     *  @private
     */
    public function set navigators(value:Vector.<ViewNavigatorBase>):void
    {
        if (tabbedNavigator)
            tabbedNavigator.navigators = value;
        else
            navigatorProperties.navigators = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
	 *  Activates the current view of the application if one exists.  This
	 *  method doesn't do anything at initial launch because the activate
	 *  event isn't dispatched when the application is first launched.  Only
	 *  the invoke event is.
     */
    private function activateHandler(event:Event):void
    {
		// Activate the top most view of the navigator if it exists.  Note that
		// in some launch situations, this will occur before the stage has properly
		// resized itself.  The orientation state of the view will be manually
		// updated when the stage RESIZE event is received.  See invokeHandler
		// and stage_resizeHandler.
		if (tabbedNavigator && tabbedNavigator.activeView)
		{
            // Set the stage focus to the navigator's active view
            tabbedNavigator.updateFocus();
            
			if (!tabbedNavigator.activeView.isActive)
				tabbedNavigator.activeView.setActive(true);
		}
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden Methods: ViewNavigatorApplicationBase
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function invokeHandler(event:InvokeEvent):void
    {
        super.invokeHandler(event);
        
        // If the navigator and view are created, this means that the application
        // is restoring its state after being suspended by the operating system.
        // In this case, the activeView is currently deactivated and it orientation 
        // state could potentially be wrong.  Wait for the next stage resize event
        // so that the runtime has a chance to discover its orientation and then 
        // properly update and activate the view
        if (tabbedNavigator)
        {
            if (tabbedNavigator.activeView)
                systemManager.stage.addEventListener(Event.RESIZE, stage_resizeHandler, false, 0, true);

            // Set the stage focus to the navigator's active view
            tabbedNavigator.updateFocus();
        }
    }
    
    /**
     *  @private
     *  This method is called on the first resize event after an application
     *  has been invoked after being suspended in the background.
     */
    private function stage_resizeHandler(event:Event):void
    {
        systemManager.stage.removeEventListener(Event.RESIZE, stage_resizeHandler);
		
		// Update the orientaion state of the view because at this
		// point the runtime doesn't dispatch stage orientation events.
		activeView.updateOrientationState();
    }
    
    /**
     *  @private
     */ 
    override protected function deactivateHandler(event:Event):void
    {
        if (tabbedNavigator && tabbedNavigator.activeView)
            tabbedNavigator.activeView.setActive(false);
        
        // super is called after so that the active view can get the
        // viewDeactive event before the persistence process begins.
        super.deactivateHandler(event);
    }
    
    /**
     *  @private
     */ 
    override protected function backKeyUpHandler(event:KeyboardEvent):void
    {
        super.backKeyUpHandler(event);
        
        if (viewMenuOpen)
            viewMenuOpen = false;
        else if (tabbedNavigator)
            tabbedNavigator.backKeyUpHandler();
    }
    
    /**
     *  @private
     */
    override protected function saveNavigatorState():void
    {
        super.saveNavigatorState();
        
        if (navigators.length > 0)
            persistenceManager.setProperty("navigatorState", tabbedNavigator.saveViewData());
    }

    /**
     *  @private
     */
    override protected function loadNavigatorState():void
    {
        super.loadNavigatorState();
        
        var savedState:Object = persistenceManager.getProperty("navigatorState");
        
        if (savedState)
            tabbedNavigator.loadViewData(savedState);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: SkinnableContainer
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Since this class doesn't have and children and serves as  proxy for 
     *  TabbedViewNavigator, we consider our deferredContent created as
     *  long as we have a valid tabbedNavigator skinPart.  This allows the
     *  states includeIn and excludeFrom mechanism from working with this
     *  component's provided MXML.   
     */
    override public function get deferredContentCreated():Boolean
    {
        if (tabbedNavigator)
            return true;

        return false;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == tabbedNavigator)
        {
            if (navigatorProperties.navigators !== undefined)
            {
                tabbedNavigator.navigators = navigatorProperties.navigators;
            }
            
            // We consider our content created when the tabbedNavigator
            // skinPart is added.  This allows states to know when all deferred content
            // has been created.
            if (hasEventListener(FlexEvent.CONTENT_CREATION_COMPLETE))
                dispatchEvent(new FlexEvent(FlexEvent.CONTENT_CREATION_COMPLETE));
            
            // Set the stage focus to the navigator
            systemManager.stage.focus = tabbedNavigator;
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: IVisualElementContainer
    //
    //--------------------------------------------------------------------------
    
    /**
     *  TabbedViewNavigatorApplication proxies the IVisualElementContainer
     *  interface to its tabbedNavigator skinPart.
     */ 
    
    /**
     *  @private
     */
    override public function get numElements():int
    {
        if (tabbedNavigator)
            return tabbedNavigator.numElements;
        
        return 0;
    }
    
    /**
     *  @private
     */ 
    override public function getElementAt(index:int):IVisualElement
    {
        if (tabbedNavigator)
            return tabbedNavigator.getElementAt(index);
        
        return null;
    }
        
    //----------------------------------
    //  Visual Element addition
    //----------------------------------
    
    /**
     *  @private
     */
    override public function addElement(element:IVisualElement):IVisualElement
    {
        if (tabbedNavigator)
            return tabbedNavigator.addElement(element);
        
        // TODO (chiedozi): Consider throwing an exception in this case
        return null;
    }
    
    /**
     *  @private
     */
    override public function addElementAt(element:IVisualElement, index:int):IVisualElement
    {
        if (tabbedNavigator)
            return tabbedNavigator.addElementAt(element, index);
        
        // TODO (chiedozi): Consider throwing an exception in this case
        return null;
    }
    
    //----------------------------------
    //  Visual Element removal
    //----------------------------------
    
    /**
     *  @private
     */
    override public function removeElement(element:IVisualElement):IVisualElement
    {
        if (tabbedNavigator)
            return tabbedNavigator.removeElement(element);
        
        // TODO (chiedozi): Consider throwing an exception in this case
        return null;
    }
    
    /**
     *  @private
     */
    override public function removeElementAt(index:int):IVisualElement
    {
        if (tabbedNavigator)
            return tabbedNavigator.removeElementAt(index);
        
        // TODO (chiedozi): Consider throwing an exception in this case
        return null;
    }
    
    /**
     *  @private
     */
    override public function removeAllElements():void
    {
        if (tabbedNavigator)
            return tabbedNavigator.removeAllElements();
    }
    
    //----------------------------------
    //  Visual Element index
    //----------------------------------
    
    /**
     *  @private
     */ 
    override public function getElementIndex(element:IVisualElement):int
    {
        if (tabbedNavigator)
            return tabbedNavigator.getElementIndex(element);
        
        throw ArgumentError(resourceManager.getString("components", "elementNotFoundInGroup", [element]));
    }
    
    /**
     *  @private
     */
    override public function setElementIndex(element:IVisualElement, index:int):void
    {
        if (tabbedNavigator)
            tabbedNavigator.setElementIndex(element, index);
        
        throw ArgumentError(resourceManager.getString("components", "elementNotFoundInGroup", [element]));
    }
    
    //----------------------------------
    //  Visual Element swapping
    //----------------------------------
    
    /**
     *  @private
     */
    override public function swapElements(element1:IVisualElement, element2:IVisualElement):void
    {
        if (tabbedNavigator)
            tabbedNavigator.swapElements(element1, element2);
        
        throw ArgumentError(resourceManager.getString("components", "elementNotFoundInGroup", [element1]));
    }
    
    /**
     *  @private
     */
    override public function swapElementsAt(index1:int, index2:int):void
    {
        if (tabbedNavigator)
            tabbedNavigator.swapElementsAt(index1, index2);
        
        throw new RangeError(resourceManager.getString("components", "indexOutOfRange", [index1]));
    }
}
}