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
import mx.utils.BitFlagUtil;

import spark.components.supportClasses.NavigationStack;
import spark.components.supportClasses.ViewNavigatorApplicationBase;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

[DefaultProperty("navigationStack")]

/**
 *  The ViewNavigatorApplication class is an application class meant to provide a simple
 *  framework for applications that employ a view-based navigation model.
 *  When used, this class functions as the main entry point for the application
 *  and provides support for hardware device keys, orientation detection and
 *  application session persistence.
 * 
 *  <p>A view-based navigation model is characterized by a user interface
 *  where the end user navigates between a series of full screen views in
 *  response to user interaction.  
 *  This is a paradigm commonly used by mobile applications and is accomplished 
 *  through the use of a built in ViewNavigator container.</p>
 * 
 *  <p>Use the <code>firstView</code> property to specify
 *  the View displayed first when the application is initialized.</p>
 * 
 *  <p>Unlike Application, ViewNavigatorApplication is not meant to accept
 *  UIComponent objects as children.  
 *  Instead, all visual components should be children of the 
 *  views managed by the application.</p>
 *
 *  <p>The ViewNavigatorApplication container has the following 
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
 *           <td>spark.skins.mobile.ViewNavigatorApplicationSkin</td>
 *        </tr>
 *     </table>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:ViewNavigatorApplication&gt;</code> tag inherits all of the tag
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:ViewNavigatorApplication
 *    <strong>Properties</strong>
 *    actionContent="null"
 *    actionLayout="null"
 *    firstView="null"
 *    firstViewData="null"
 *    navigationContent="null"
 *    navigationLayout="null"
 *    title=""
 *    titleContent="null"
 *    titleLayout="null"
 * 
 *  /&gt;
 *  </pre>
 *
 *  @see spark.components.ViewNavigator
 *  @see spark.components.View
 *  @see spark.skins.mobile.ViewNavigatorApplicationSkin
 *  @includeExample examples/ViewNavigatorApplicationExample.mxml -noswf
 *  @includeExample examples/views/ViewNavigatorApplicationHomeView.mxml -noswf
 *  @includeExample examples/views/ViewNavigatorApplicationView2.mxml -noswf
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class ViewNavigatorApplication extends ViewNavigatorApplicationBase
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    // The following constants are used to indicate whether the developer
    // has explicitly set one of the navigator template properties.  This
    // allows us to properly store these set properties if the navigator skin
    // changes.
    
    /**
     *  @private
     */
    private static const ACTION_CONTENT_PROPERTY_FLAG:uint = 1 << 0;
    
    /**
     *  @private
     */
    private static const ACTION_LAYOUT_PROPERTY_FLAG:uint = 1 << 1;
    
    /**
     *  @private
     */
    private static const NAVIGATION_CONTENT_PROPERTY_FLAG:uint = 1 << 2;
    
    /**
     *  @private
     */
    private static const NAVIGATION_LAYOUT_PROPERTY_FLAG:uint = 1 << 3;
    
    /**
     *  @private
     */
    private static const TITLE_PROPERTY_FLAG:uint = 1 << 4;
    
    /**
     *  @private
     */
    private static const TITLE_CONTENT_PROPERTY_FLAG:uint = 1 << 5;
    
    /**
     *  @private
     */
    private static const TITLE_LAYOUT_PROPERTY_FLAG:uint = 1 << 6;
    
    /**
     *  @private
     */
    private static const NAVIGATION_STACK_PROPERTY_FLAG:uint = 1 << 7;
    
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
    public function ViewNavigatorApplication()
    {
        super();

        NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, activateHandler);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    [Bindable]
    [SkinPart(required="false")]
    /**
     *  The main view navigator for the application.  This component is 
     *  responsible for managing the view navigation model for the application.  
     */ 
    public var navigator:ViewNavigator;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    private var navigatorProperties:Object = {};
    
    /**
     *  @private
     *  Proxy setter for the view navigator's navigationStack property.
     */
    private function get navigationStack():NavigationStack
    {
        if (navigator)
            return navigator.navigationStack;
        else
            return navigatorProperties.navigationStack;
    }
    
    /**
     *  @private
     */
    private function set navigationStack(value:NavigationStack):void
    {
        if (navigator)
        {
            navigator.navigationStack = value;
            navigatorProperties = BitFlagUtil.update(navigatorProperties as uint,
                NAVIGATION_STACK_PROPERTY_FLAG, value != null);
        }
        else
            navigatorProperties.navigationStack = value;
    }
    
    //----------------------------------
    //  activeView
    //----------------------------------
    
    /**
     *  @private
     */ 
    override mx_internal function get activeView():View
    {
        if (navigator)
            return navigator.activeView;
        
        return null;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  actionBar
    //----------------------------------
    
    /**
     *  A reference to the view navigator's ActionBar control,
     *  if one exists.  
     *  This property is only valid after the 
     *  view navigator has been added to the display list.
     *
     *  @see ActionBar
     *  @see ViewNavigator
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function get actionBar():ActionBar
    {
        if (navigator)
            return navigator.actionBar;
        
        return null;
    }
    
    //----------------------------------
    //  exitApplicationOnBackKey
    //----------------------------------
    /**
     *  @private
     */  
    override mx_internal function get exitApplicationOnBackKey():Boolean
    {
        if (viewMenuOpen)
            return false;

        if (navigator)
            return navigator.exitApplicationOnBackKey;
        
        return super.exitApplicationOnBackKey;
    }
    
    //----------------------------------
    //  firstViewData
    //----------------------------------
    /**
     * @private
     */
    private var _firstViewData:Object;
    
    /**
     *  @copy ViewNavigator#firstViewData
     * 
     *  @default null
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get firstViewData():Object
    {
        return _firstViewData;
    }
    
    /**
     * @private
     */
    public function set firstViewData(value:Object):void
    {
        _firstViewData = value;
    }
    
    //----------------------------------
    //  firstView
    //----------------------------------
    /**
     *  @private
     *  The backing variable for the firstView property.
     */
    private var _firstView:Class;
    
    /**
     *  @copy ViewNavigator#firstView
     * 
     *  @default null
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get firstView():Class
    {
        return _firstView;
    }
    
    /**
     * @private
     */
    public function set firstView(value:Class):void
    {
        _firstView = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  UI Template Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  actionContent
    //----------------------------------
    
    [ArrayElementType("mx.core.IVisualElement")]
    /**
     *  This property overrides the <code>actionContent</code>
     *  property in the ActionBar control.
     * 
     *  @copy ActionBar#actionContent
     *
     *  @default null
     *
     *  @see spark.components.ActionBar#actionContent
     *  @see spark.components.View#actionContent
     *  @see spark.components.ViewNavigator#actionContent
     *  @see spark.skins.mobile.ActionBarSkin
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get actionContent():Array
    {
        if (navigator)
            return navigator.actionContent;
        else
            return navigatorProperties.actionContent;
    }
    
    /**
     *  @private
     */
    public function set actionContent(value:Array):void
    {
        if (navigator)
        {
            navigator.actionContent = value;
            navigatorProperties = BitFlagUtil.update(navigatorProperties as uint,
                                        ACTION_CONTENT_PROPERTY_FLAG, value != null);
        }
        else
            navigatorProperties.actionContent = value;
    }
    
    //----------------------------------
    //  actionLayout
    //----------------------------------
    
    /**
     *  @copy ActionBar#actionLayout
     *
     *  @default null
     *  
     *  @see spark.components.ActionBar#actionLayout
     *  @see spark.components.View#actionLayout
     *  @see spark.components.ViewNavigator#actionLayout
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get actionLayout():LayoutBase
    {
        if (navigator)
            return navigator.actionLayout;
        else
            return navigatorProperties.actionLayout;
    }
    
    /**
     *  @private
     */
    public function set actionLayout(value:LayoutBase):void
    {
        if (navigator)
        {
            navigator.actionLayout = value;
            navigatorProperties = BitFlagUtil.update(navigatorProperties as uint, 
                                        ACTION_LAYOUT_PROPERTY_FLAG, value != null);
        }
        else
            navigatorProperties.actionLayout = value;
    }
    
    //----------------------------------
    //  navigationContent
    //----------------------------------
    
    [ArrayElementType("mx.core.IVisualElement")]
    /**
     *  This property overrides the <code>navigationContent</code>
     *  property in the ActionBar control.
     * 
     *  @copy ActionBar#navigationContent
     *
     *  @default null
     * 
     *  @see spark.components.ActionBar#navigationContent
     *  @see spark.components.View#navigationContent
     *  @see spark.components.ViewNavigator#navigationContent
     *  @see spark.skins.mobile.ActionBarSkin
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get navigationContent():Array
    {
        if (navigator)
            return navigator.navigationContent;
        else
            return navigatorProperties.navigationContent;
    }
    
    /**
     *  @private
     */
    public function set navigationContent(value:Array):void
    {
        if (navigator)
        {
            navigator.navigationContent = value;
            navigatorProperties = BitFlagUtil.update(navigatorProperties as uint, 
                NAVIGATION_CONTENT_PROPERTY_FLAG, value != null);
        }
        else
            navigatorProperties.navigationContent = value;
    }
    
    //----------------------------------
    //  navigationLayout
    //----------------------------------
    
    /**
     *  @copy ActionBar#navigationLayout
     *
     *  @default null
     *  
     *  @see spark.components.ActionBar#navigationLayout
     *  @see spark.components.View#navigationLayout
     *  @see spark.components.ViewNavigator#navigationLayout
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get navigationLayout():LayoutBase
    {
        if (navigator)
            return navigator.navigationLayout;
        else
            return navigatorProperties.navigationLayout;
    }
    
    /**
     *  @private
     */
    public function set navigationLayout(value:LayoutBase):void
    {
        if (navigator)
        {
            navigator.navigationLayout = value;
            navigatorProperties = BitFlagUtil.update(navigatorProperties as uint, 
                NAVIGATION_LAYOUT_PROPERTY_FLAG, value != null);
        }
        else
            navigatorProperties.navigationLayout = value;
    }
    
    //----------------------------------
    //  title
    //----------------------------------
    
    [Bindable]
    /**
     *  This property overrides the <code>title</code>
     *  property in the ActionBar control.
     * 
     *  @copy ActionBar#title
     *
     *  @default ""
     *  
     *  @see spark.components.ActionBar#title
     *  @see spark.components.View#title
     *  @see spark.components.ViewNavigator#title
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function get title():String
    {
        if (navigator)
            return navigator.title;
        else
            return navigatorProperties.title;
    }
    
    /**
     *  @private
     */ 
    public function set title(value:String):void
    {
        if (navigator)
        {
            navigator.title = value;
            navigatorProperties = BitFlagUtil.update(navigatorProperties as uint, 
                TITLE_PROPERTY_FLAG, value != null);
        }
        else
            navigatorProperties.title = value;
    }
    
    //----------------------------------
    //  titleContent
    //----------------------------------
    
    [ArrayElementType("mx.core.IVisualElement")]
    /**
     *  This property overrides the <code>titleContent</code>
     *  property in the ActionBar and ViewNavigatorApplication components.
     * 
     *  @copy ActionBar#titleContent
     *
     *  @default null
     * 
     *  @see spark.components.ActionBar#titleContent
     *  @see spark.components.View#titleContent
     *  @see spark.components.ViewNavigator#titleContent
     *  @see spark.skins.mobile.ActionBarSkin
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get titleContent():Array
    {
        if (navigator)
            return navigator.titleContent;
        else
            return navigatorProperties.titleContent;
    }
    
    /**
     *  @private
     */
    public function set titleContent(value:Array):void
    {
        if (navigator)
        {
            navigator.titleContent = value;
            navigatorProperties = BitFlagUtil.update(navigatorProperties as uint, 
                TITLE_CONTENT_PROPERTY_FLAG, value != null);
        }
        else
            navigatorProperties.titleContent = value;
    }
    
    //----------------------------------
    //  titleLayout
    //----------------------------------
    
    /**
     *  @copy ActionBar#titleLayout
     *
     *  @default null
     * 
     *  @see spark.components.ActionBar#titleLayout
     *  @see spark.components.View#titleLayout
     *  @see spark.components.ViewNavigator#titleLayout
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get titleLayout():LayoutBase
    {
        if (navigator)
            return navigator.titleLayout;
        else
            return navigatorProperties.titleLayout;
    }
    
    /**
     *  @private
     */
    public function set titleLayout(value:LayoutBase):void
    {
        if (navigator)
        {
            navigator.titleLayout = value;
            navigatorProperties = BitFlagUtil.update(navigatorProperties as uint, 
                NAVIGATION_LAYOUT_PROPERTY_FLAG, value != null);
        }
        else
            navigatorProperties.titleLayout = value;
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
        if (navigator && navigator.activeView)
        {
            if (!navigator.activeView.isActive)
                navigator.activeView.setActive(true);
            
            // Set the stage focus to the navigator's active view
            navigator.updateFocus();
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
        if (navigator)
        {
            if (navigator.activeView)
                systemManager.stage.addEventListener(Event.RESIZE, stage_resizeHandler, false, 0, true);

            // Set the stage focus to the navigator's active view
            navigator.updateFocus();
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
		
		// Update the orientaion state of the view at launch because at this
		// point the runtime doesn't dispatch stage orientation events.
		activeView.updateOrientationState();
    }
    
    /**
     *  @private
     */ 
    override protected function deactivateHandler(event:Event):void
    {
        if (navigator && navigator.activeView)
            navigator.activeView.setActive(false);

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
        else if (navigator)
            navigator.backKeyUpHandler();
    }
    
    /**
     *  @private
     */ 
    override protected function saveNavigatorState():void
    {
        super.saveNavigatorState();

        if (navigator)
            persistenceManager.setProperty("navigatorState", navigator.saveViewData());
    }
    
    /**
     * @private
     */
    override protected function loadNavigatorState():void
    {
        super.loadNavigatorState();
        
        var savedState:Object = persistenceManager.getProperty("navigatorState");
        
        if (savedState)
            navigator.loadViewData(savedState);
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
        
        if (instance == navigator)
        {
            var newNavigatorProperties:uint = 0;
                
            if (navigatorProperties.actionContent !== undefined)
            {
                navigator.actionContent = navigatorProperties.actionContent;
                newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                                                ACTION_CONTENT_PROPERTY_FLAG, true);
            }
            
            if (navigatorProperties.actionLayout !== undefined)
            {
                navigator.actionLayout = navigatorProperties.actionLayout;
                newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                    ACTION_LAYOUT_PROPERTY_FLAG, true);
            }
            
            if (navigatorProperties.navigationContent !== undefined)
            {
                navigator.navigationContent = navigatorProperties.navigationContent;
                newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                    NAVIGATION_CONTENT_PROPERTY_FLAG, true);
            }
            
            if (navigatorProperties.navigationLayout !== undefined)
            {
                navigator.navigationLayout = navigatorProperties.navigationLayout;
                newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                    NAVIGATION_LAYOUT_PROPERTY_FLAG, true);
            }
            
            if (navigatorProperties.title !== undefined)
            {
                navigator.title = navigatorProperties.title;
                newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                    TITLE_PROPERTY_FLAG, true);
            }
            
            if (navigatorProperties.titleContent !== undefined)
            {
                navigator.titleContent = navigatorProperties.titleContent;
                newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                    TITLE_CONTENT_PROPERTY_FLAG, true);
            }
            
            if (navigatorProperties.titleLayout !== undefined)
            {
                navigator.titleLayout = navigatorProperties.titleLayout;
                newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                    TITLE_LAYOUT_PROPERTY_FLAG, true);
            }
            
            navigatorProperties = newNavigatorProperties;
            navigator.firstView = firstView;
            navigator.firstViewData = firstViewData;
            navigator.navigationStack = navigationStack;
            
            // Set the stage focus to the navigator
            systemManager.stage.focus = navigator;
        }
    }
     
    /**
     *  @private
     */ 
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == navigator)
        {
            var newNavigatorProperties:Object = {};
                
            if (BitFlagUtil.isSet(navigatorProperties as uint, ACTION_CONTENT_PROPERTY_FLAG))
                newNavigatorProperties.actionContent = navigator.actionContent;
            
            if (BitFlagUtil.isSet(navigatorProperties as uint, ACTION_LAYOUT_PROPERTY_FLAG))
                newNavigatorProperties.actionLayout = navigator.actionLayout;
            
            if (BitFlagUtil.isSet(navigatorProperties as uint, NAVIGATION_CONTENT_PROPERTY_FLAG))
                newNavigatorProperties.navigationContent = navigator.navigationContent;
            
            if (BitFlagUtil.isSet(navigatorProperties as uint, NAVIGATION_LAYOUT_PROPERTY_FLAG))
                newNavigatorProperties.navigationLayout = navigator.navigationLayout;
            
            if (BitFlagUtil.isSet(navigatorProperties as uint, TITLE_PROPERTY_FLAG))
                newNavigatorProperties.title = navigator.title;
            
            if (BitFlagUtil.isSet(navigatorProperties as uint, TITLE_CONTENT_PROPERTY_FLAG))
                newNavigatorProperties.titleContent = navigator.titleContent;
            
            if (BitFlagUtil.isSet(navigatorProperties as uint, TITLE_LAYOUT_PROPERTY_FLAG))
                newNavigatorProperties.titleLayout = navigator.titleLayout;
               
            // Always want to save the navigation stack
            newNavigatorProperties.navigationStack = navigator.navigationStack;
            navigatorProperties = newNavigatorProperties;
        }
    }
}
}