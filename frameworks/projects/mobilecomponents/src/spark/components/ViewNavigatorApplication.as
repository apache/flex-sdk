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
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.events.KeyboardEvent;
import flash.events.StageOrientationEvent;
import flash.net.registerClassAlias;

import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.utils.BitFlagUtil;

import spark.components.supportClasses.MobileApplicationBase;
import spark.components.supportClasses.NavigationStack;
import spark.components.supportClasses.ViewDescriptor;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

[DefaultProperty("navigationStack")]

/**
 *  MobileApplication is an application class meant to provide a simple
 *  framework for applications that employ a view-based navigation model.
 *  When used, this class functions as the main entry point for the application
 *  and provides support for hardware device keys, orientation detection and
 *  application session persistence.
 * 
 *  <p>A view=based navigation model is characterized by a user interface
 *  where the end user navigates between a series of full screen views in
 *  response to user interaction.  This is a paradigm commonly used by
 *  mobile applications and is accomplished through the use of a built in
 *  <code>ViewNavigator</code> that lives in the application's skin.</p>
 * 
 *  <p>The <code>firstView</code> property can be used to define
 *  what View should be displayed first when the application is
 *  initialized.</p>
 * 
 *  <p>Unlike Application, MobileApplication is not meant to accept
 *  UIComponents has children.  Instead, all visual components should
 *  children of the various views managed by the application.</p>
 *
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class MobileApplication extends MobileApplicationBase
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
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function MobileApplication()
    {
        super();
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
     *  Provides access to the main navigator's actionBar
     *  if one exists.  This property will only be valid after the 
     *  navigator has been added to the display list.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
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
     *  This is the initialization data to pass to the
     *  first view when it is created.  This object will need to be set
     *  before the first initialization pass for it to be considered
     *  by the view navigator.
     * 
     *  @default null
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
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
     *  The class used to create the first view of the view navigator.
     *  This property must be set before the first initialization pass
     *  it to be considered by the application's navigator.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
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
     *  The default array of visual elements that are used as the 
     *  ActionBar's actionContent when the current view does not
     *  define one.
     *
     *  @default null
     * 
     *  @see spark.components.View#actionContent
     *  @see spark.components.ViewNavigator#actionContent
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
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
     *  The default layout to apply to the ActionBar's action content 
     *  container when the current view does not define one.
     *
     *  @default null
     *  
     *  @see spark.components.View#actionLayout
     *  @see spark.components.ViewNavigator#actionLayout
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
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
     *  The default array of visual elements that are used as the 
     *  ActionBar's navigation content when the current view doesn't
     *  define any.
     *
     *  @default null
     *  
     *  @see spark.components.View#navigationContent
     *  @see spark.components.ViewNavigator#navigationContent
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
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
     *  The default layout for the ActionBar navigation content container
     *  when the active view doesn't define one.
     *
     *  @default null
     *  
     *  @see spark.components.View#navigationLayout
     *  @see spark.components.ViewNavigator#navigationLayout
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
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
     *  The default title that should be used by the ActionBar if the
     *  active view doesn't provide one.
     *
     *  @default null
     *  
     *  @see spark.components.View#title
     *  @see spark.components.ViewNavigator#title
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
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
     *  The default array of visual elements that are used as the 
     *  ActionBar's title content when the active view doesn't define
     *  one.
     *
     *  @default null
     *  
     *  @see spark.components.View#titleContent
     *  @see spark.components.ViewNavigator#titleContent
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
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
     *  The default layout for the ActionBar's title content container
     *  when the active view doesn't define one.
     *
     *  @default null
     * 
     *  @see spark.components.View#titleLayout
     *  @see spark.components.ViewNavigator#titleLayout
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
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
    //  Overridden Methods: MobileApplicationBase
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function nativeApplication_invokeHandler(event:InvokeEvent):void
    {
        super.nativeApplication_invokeHandler(event);

        // Set the stage focus to the navigator's active view
        if (systemManager.stage.focus == null && navigator)
        {
            if (navigator.activeView)
                systemManager.stage.focus = navigator.activeView;
            else
                systemManager.stage.focus = navigator;
        }
    }
    
    /**
     *  @private
     */ 
    override protected function nativeApplication_deactivateHandler(event:Event):void
    {
        if (navigator && navigator.activeView)
            navigator.activeView.setActive(false);

        // super is called after so that the active view can get the
        // viewDeactive event before the persistence process begins.
        super.nativeApplication_deactivateHandler(event);
    }
    
    /**
     *  @private
     */ 
    override protected function backKeyHandler(event:KeyboardEvent):void
    {
        super.backKeyHandler(event);
        
        if (viewMenuOpen)
            viewMenuOpen = false;
        else
            navigator.backKeyHandler();
    }
    
    /**
     *  @private
     */ 
    override protected function persistApplicationState():void
    {
        super.persistApplicationState();

        // TODO (chiedozi): Rename save to maybe get?
        if (navigator)
            persistenceManager.setProperty("navigatorState", navigator.saveViewData());
    }
    
    /**
     *  @private
     */ 
    override protected function registerPersistenceClassAliases():void
    {
        super.registerPersistenceClassAliases();
        
        // Register aliases for custom classes that will be written to
        // persistence store by navigator
        registerClassAlias("ViewDescriptor", ViewDescriptor);
        registerClassAlias("NavigationStack", NavigationStack);
    }
    
    /**
     * @private
     */
    override protected function restoreApplicationState():void
    {
        // TODO (chiedozi): Figure out how to refactor this into base class.  Need navigator
        // to be a part of the base class
        super.restoreApplicationState();
        
        var savedState:Object = persistenceManager.getProperty("navigatorState");
        
        if (savedState)
            navigator.restoreViewData(savedState);
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
            // TODO (chiedozi): I'm not doing this right...
            newNavigatorProperties.navigationStack = navigator.navigationStack;
            navigatorProperties = newNavigatorProperties;
        }
    }
}
}