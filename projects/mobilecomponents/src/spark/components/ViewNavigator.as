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
import flash.display.Stage;
import flash.events.Event;
import flash.geom.Rectangle;

import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.effects.IEffect;
import mx.effects.Parallel;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;
import mx.events.PropertyChangeEventKind;
import mx.managers.LayoutManager;
import mx.resources.ResourceManager;

import spark.components.supportClasses.NavigationStack;
import spark.components.supportClasses.ViewNavigatorBase;
import spark.components.supportClasses.ViewDescriptor;
import spark.components.supportClasses.ViewReturnObject;
import spark.core.ContainerDestructionPolicy;
import spark.effects.Animate;
import spark.effects.Fade;
import spark.effects.Move;
import spark.effects.Resize;
import spark.effects.SlideViewTransition;
import spark.effects.ViewTransition;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.events.IndexChangeEvent;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

[DefaultProperty("navigationStack")]

//--------------------------------------
//  SkinStates
//--------------------------------------

/**
 *  The state used when the navigator is in portrait orientation
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[SkinState("portrait")]

/**
 *  The state used when the navigator is in landscape orientation
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[SkinState("landscape")]

/**
 *  The state used when the navigator is in portrait orientation
 *  and the navigator controls are overlaid on top.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[SkinState("portraitAndOverlay")]

/**
 *  The state used when the navigator is in landscape orientation
 *  and the navigator controls are overlaid on top.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[SkinState("landscapeAndOverlay")]

/**
 *  The ViewNavigator component is a container that consists of a collection of
 *  View objects, where only the top most view is visible and active.  Views can
 *  be added and removed by using the popView() and pushView() methods on the
 *  navigator.  
 * 
 *  <p>When a new view becomes active, the old view's instance is destroyed.
 *  When a view is pushed on top of navigator's stack, the old view's data 
 *  property is automatically persisted and restored when it is reactived
 *  through one of the pop methods.</p>
 * 
 *  <p>ViewNavigator doesn't provide index information about the Views that
 *  it is currently managing and strictly follows a stack navigation model. 
 *  Jumping between a set of views similar to a ViewStack is not supported 
 *  by this component.</p>
 *  
 *  <p>ViewNavigator displays an optional action bar that displays contextual
 *  information defined by the active view.  When the active view changes, the
 *  action bar is automatically updated.</p>
 *  
 *  @see spark.components.View
 *  @see spark.components.ActionBar
 *  @see spark.effects.ViewTransition
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class ViewNavigator extends ViewNavigatorBase
{
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  The animation duration used when hiding and showing the action bar.
     */ 
    private static const ACTION_BAR_ANIMATION_DURATION:Number = 250;

    /**
     *  @private
     *  The animation duration used when running a default view transition.
     */     
    private static const DEFAULT_VIEW_TRANSITION_DURATION:Number = 300;
    
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
    public function ViewNavigator()
    {
        super();
        
        defaultPushTransition = new SlideViewTransition(DEFAULT_VIEW_TRANSITION_DURATION, SlideViewTransition.SLIDE_LEFT);
        defaultPopTransition = new SlideViewTransition(DEFAULT_VIEW_TRANSITION_DURATION, SlideViewTransition.SLIDE_RIGHT);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------------
    // Navigator Controls
    //----------------------------------------
    
    [SkinPart(required="false")]    
    
    /**
    *  A skin part that defines the action bar of the navigator. 
    *  
    *  @langversion 3.0
    *  @playerversion Flash 10
    *  @playerversion AIR 1.5
    *  @productversion Flex 4
    */
    public var actionBar:ActionBar;

    // FIXME (chiedozi): Docs
    /**
     *  A skin part that defines the default transition to play when
     *  a view is pushed onto the navigation stack. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    mx_internal var defaultPushTransition:ViewTransition;
    
    /**
     *  A skin part that defines the default transition to play when
     *  a view is popped off the navigation stack. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    mx_internal var defaultPopTransition:ViewTransition;
    
    //--------------------------------------------------------------------------
    //
    // Variables
    // 
    //--------------------------------------------------------------------------

    /**
     *  @private
     */ 
    private var actionBarProps:Object;
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    private function get actionBarPropertyInvalidated():Boolean
    {
        return 	actionContentInvalidated ||
                actionLayoutInvalidated ||
                navigationContentInvalidated ||
                navigationLayoutInvalidated ||
                titleInvalidated ||
                titleContentInvalidated ||
                titleLayoutInvalidated;
    }
    
    /**
     *  @private
     *  The show/hide effect that is currently being played on the action bar. 
     */
    private var actionBarVisibilityEffect:IEffect;
    
    /**
     *  @private
     */ 
    private var contentGroupProps:Object;
    
    /**
     *  @private
     *  Internal flag used to track whether a show/hide effect should be
     *  played when the action bar visibility is updated.
     */ 
    private var animateActionBarVisbility:Boolean = false;
    
    /**
     *  @private
     *  Flag indicating the that actionBar visiblity has been invalidated
     *  by the active view. 
     */
    private var actionBarVisibilityInvalidated:Boolean = false;
    
    /**
     *  @private
     *  The view data for the active view.
     */
    private var currentViewDescriptor:ViewDescriptor = null;
    
    /**
     *  @private
     */ 
    private var delayedNavigationActions:Vector.<Object> = new Vector.<Object>();
    
    /**
     *  @private
     *  Flag indicates that the navigator has been requested to show
     *  a different view. 
     */
    mx_internal var viewChangeRequested:Boolean = false;
	
    /**
     *  @private
     */ 
    private var emptyViewDescriptor:ViewDescriptor = null;
    
    /**
     *  @private
     */
    private var explicitFrameRate:Number;
    
    /**
     *  @private
     *  This following property stores the <code>mouseEnabled</code>
     *  value defined on the navigator so that it can be
     *  restored after a view transition.
     */
    private var explicitMouseEnabled:Boolean;
    
    /**
     *  @private
     *  This following property stores the <code>mouseChildren</code>
     *  value defined on the navigator so that it can be
     *  restored after a view transition.
     */
    private var explicitMouseChildren:Boolean;
    
    /**
     *  @private
     *  The last action performed by the navigator.
     */
    private var lastAction:String = ViewNavigatorAction.NONE;
    
    /**
     *  @private
     *  The view data for the pending view.
     */ 
    private var pendingViewDescriptor:ViewDescriptor = null;
    
    /**
     *  @private
     *  The transition to play when the pending view is activated.
     */ 
    private var pendingViewTransition:ViewTransition = null;
    
	/**
	 *  @private
	 *  A variable used to store the trantiion to play after a
	 *  validation pass.  This needs to be a different variable than
	 *  pendingViewTransition because the pending transition can
	 *  change as push and pops come in.
	 */
	private var finalViewTransition:ViewTransition;
	
    /**
     *  @private
     *  This flag is set to true if a navigation operation, e.g., pushView()
     *  is called during a transition.  If so, another validation pass is
     *  run after the transition is complete.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private var revalidateWhenComplete:Boolean = false;
    
    /**
     *  @private
     */
    private var showingActionBar:Boolean;
    
    /**
     *  @private
     *  Flag indicates whether the navigator is in the process of
     *  changing a view.
     */ 
    // mx_internal so that TabbedViewNavigator can access
    mx_internal var viewChanging:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    // 
    //--------------------------------------------------------------------------

    //----------------------------------
    //  active
    //----------------------------------
    
    /**
     *  @private
     *  Only gets called by TabbedViewNavigator.
     */ 
    override mx_internal function setActive(value:Boolean):void
    {
        if (value == isActive)
            return;
        
        if (value)
        {
            createTopView();
            
            // Need to force a validation on the actionBar
            invalidateActionBarProperties();
        }
        else
        {
            if (activeView)
            {            
                if ((activeView.destructionPolicy != ContainerDestructionPolicy.NEVER && 
                    destructionPolicy != ContainerDestructionPolicy.NEVER) ||
                    !maintainNavigationStack)
                    destroyViewInstance(navigationStack.topView);
            }
            
            if (!maintainNavigationStack)
                navigationStack.popToFirstView();
        }
        
        // Call super after the above code so that the view has a chance
        // to be created before its active property is set.
        super.setActive(value);
    }
    
    //----------------------------------
    //  activeView
    //----------------------------------
    
    /**
     *  @private
     */
    override public function get activeView():View
    {
        if (currentViewDescriptor && currentViewDescriptor != emptyViewDescriptor)
            return currentViewDescriptor.instance;
        
        return null;
    }
    
    //----------------------------------
    //  cancelBackKeyBehavior
    //----------------------------------
    
    /**
     *  @private
     */  
    override public function get canCancelBackKeyBehavior():Boolean
    {
        return length > 1;
    }
    
    //----------------------------------
    //  context
    //----------------------------------
    
    /**
     *  The string that describes the context in which the current view was
     *  created.  This property is assigned to the <code>context</code>
     *  parameter that is passed into <code>ViewNavigator.pushView()</code>.
     * 
     *  @default null
     * 
     *  @see spark.components.ViewNavigator
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get context():Object
    {
        if (pendingViewDescriptor)
            return pendingViewDescriptor.context;
        else if (currentViewDescriptor)
            return currentViewDescriptor.context;
            
        return null;
    }
    
    //----------------------------------
    //  firstView
    //----------------------------------
    
    private var _firstView:Class;
    
    /**
     *  This property is the object to use to initialize the first view
     *  of the stack.  This must be a class that extends <code>View</code>.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
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
    
    //----------------------------------
    //  firstViewData
    //----------------------------------
    
    private var _firstViewData:Object;
    
    /**
     * This is the initialization data to pass to the first view when the
     * navigator is initialized.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
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
    //  landscapeOrientation
    //----------------------------------
    /**
     *  @private
     */
    override public function set landscapeOrientation(value:Boolean):void
    {
        if (value != landscapeOrientation)
        {
            super.landscapeOrientation = value;
            
            if (activeView)
                activeView.setCurrentState(activeView.getCurrentViewState(landscapeOrientation), false);
        }
    }
    
    //----------------------------------
    //  length
    //----------------------------------
    
    /**
     *  @private
     */
    public function get length():int
    {
        return navigationStack.length;
    }
    
    //----------------------------------
    //  maintainNavigationStack
    //----------------------------------
    private var _maintainNavigationStack:Boolean = true;
    
    /**
     *  This property indicates whether the navigation stack of the view
     *  should remain intact when the navigator is deactivated by its
     *  parent navigator.  If set to true, when reactivated the view history
     *  will remain the same.  If false, the navigator will display the
     *  first view in its navigation stack.
     * 
     *  @default true
     *  
     *  @see spark.components.TabbedViewNavigator
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get maintainNavigationStack():Boolean
    {
        return _maintainNavigationStack;
    }
    
    /**
     *  @private
     */ 
    public function set maintainNavigationStack(value:Boolean):void
    {
        _maintainNavigationStack = value;
    }
    
    //----------------------------------
    //  navigationStack
    //----------------------------------
    
    /**
     *  @private
     */
     // FIXME (chiedozi): Should this be on base class?
    override mx_internal function set navigationStack(value:NavigationStack):void
    {
        super.navigationStack = value;
        
        viewChangeRequested = true;
        lastAction = ViewNavigatorAction.REPLACE_STACK;
        
        invalidateProperties();
    }
    
    //----------------------------------
    //  returnedObject
    //----------------------------------
    // FIXME (chiedozi): PARB - HTTPService uses lastResult, maybe we should match - lastReturnedObject?
    private var _poppedViewReturnedObject:ViewReturnObject = null;

    /**
     *  Holds the return object returned by the last view that was popped
     *  off the navigation stack or replaced by another view.  This object 
     *  is only available when the navigator is in the process of switching 
     *  views in response to a pop or replace navigation operation.  
     * 
     *  <p>This object is guarenteed to be valid when the new view receives 
     *  the <code>FlexEvent.ADD</code> event, and is destroyed after
     *  the view receives a <code>FlexEvent.VIEW_ACTIVATE</code> event.</p>
     * 
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function get poppedViewReturnedObject():ViewReturnObject
    {
        return _poppedViewReturnedObject;
    }
    
    //--------------------------------------------------------------------------
    //
    //  UI Template Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  actionContent
    //----------------------------------
    
    private var _actionContent:Array;
    private var actionContentInvalidated:Boolean = false;
    
    [ArrayElementType("mx.core.IVisualElement")]
    /**
     *  Array of visual elements that are used as the ActionBar's
     *  actionContent when a view doesn't define any.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get actionContent():Array
    {
        return _actionContent;
    }
    /**
     *  @private
     */
    public function set actionContent(value:Array):void
    {
        _actionContent = value;
        
        if (!activeView || (activeView && !activeView.actionContent))
        {
            actionContentInvalidated = true;
            invalidateProperties();
        }
    }
    
    //----------------------------------
    //  actionLayout
    //----------------------------------
    
    private var _actionLayout:LayoutBase;
    private var actionLayoutInvalidated:Boolean = false;
    
    /**
     *  The default layout for the ActionBar's action content group if
     *  the view doesn't define one.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get actionLayout():LayoutBase
    {
        return _actionLayout;
    }
    /**
     *  @private
     */
    public function set actionLayout(value:LayoutBase):void
    {
        _actionLayout = value;
        
        if (!activeView || (activeView && !activeView.actionLayout))
        {
            actionLayoutInvalidated = true;
            invalidateProperties();
        }
    }
    
    //----------------------------------
    //  navigationContent
    //----------------------------------
    
    private var _navigationContent:Array;
    private var navigationContentInvalidated:Boolean = false;
    
    [ArrayElementType("mx.core.IVisualElement")]
    /**
     *  Array of visual elements that are used as the ActionBar's
     *  navigationContent when a view doesn't assign any.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get navigationContent():Array
    {
        return _navigationContent;
    }
    /**
     *  @private
     */
    public function set navigationContent(value:Array):void
    {
        _navigationContent = value;
        
        if (!activeView || (activeView && !activeView.navigationContent))
        {
            navigationContentInvalidated = true;
            invalidateProperties();
        }
    }
    
    //----------------------------------
    //  navigationLayout
    //----------------------------------
    
    private var _navigationLayout:LayoutBase;
    private var navigationLayoutInvalidated:Boolean = false;
    
    /**
     *  The default layout for the ActionBar navigation content group if
     *  a view doesn't define one.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get navigationLayout():LayoutBase
    {
        return _navigationLayout;
    }
    /**
     *  @private
     */
    public function set navigationLayout(value:LayoutBase):void
    {
        _navigationLayout = value;
        
        if (!activeView || (activeView && !activeView.navigationLayout))
        {            
            navigationLayoutInvalidated = true;
            invalidateProperties();
        }
    }
    
    //----------------------------------
    //  title
    //----------------------------------
    
    private var _title:String;
    private var titleInvalidated:Boolean = false;
    
    [Bindable]
    
    /**
     *  The default title that should be used by the ActionBar if the
     *  view doesn't provide one.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function get title():String
    {
        return _title;
    }
    
    /**
     *  @private
     */ 
    public function set title(value:String):void
    {
        if (_title != value)
        {
            _title = value;
            
            // title will only have an effect on the view if titleContent or title isn't
            // set anywhere else
            if (!activeView || (activeView && !activeView.title && !activeView.titleContent && !titleContent))
            {
                titleInvalidated = true;
                invalidateProperties();
            }
        }
    }
    
    //----------------------------------
    //  titleContent
    //----------------------------------
    
    private var _titleContent:Array;
    private var titleContentInvalidated:Boolean = false;
    
    [ArrayElementType("mx.core.IVisualElement")]
    /**
     *  Array of visual elements that are used as the ActionBar's
     *  titleContent when a view doesn't define one.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get titleContent():Array
    {
        return _titleContent;
    }
    /**
     *  @private
     */
    public function set titleContent(value:Array):void
    {
        _titleContent = value;
        
        if (!activeView || (activeView && !activeView.titleContent))
        {
            titleContentInvalidated = true;
            invalidateProperties();
        }
    }
    
    //----------------------------------
    //  titleLayout
    //----------------------------------
    
    private var _titleLayout:LayoutBase;
    private var titleLayoutInvalidated:Boolean = false;
    
    /**
     *  Layout for the ActionBar's titleContent group.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get titleLayout():LayoutBase
    {
        return _titleLayout;
    }
    /**
     *  @private
     */
    public function set titleLayout(value:LayoutBase):void
    {
        _titleLayout = value;
        
        if (!activeView || (activeView && !activeView.titleLayout))
        {
            titleLayoutInvalidated = true;
            invalidateProperties();
        }
    }
    
    //--------------------------------------------------------------------------
    //
    // Public Methods
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  Removes all of the views from the navigator.  This will transition
     *  the current view to a blank screen.  
     *
     *  @param transition The view transition to play
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function popAll(transition:ViewTransition = null):void
    {
        if (navigationStack.length == 0 || !canRemoveCurrentView())
            return;
        
        scheduleAction(ViewNavigatorAction.POP_ALL, null, null, null, transition);
    }
    
    /**
     *  Pops the top view off the navigation stack.
     * 
     *  @param transition The view transition to play
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    public function popView(transition:ViewTransition = null):void
    {
        if (navigationStack.length == 0 || !canRemoveCurrentView())
            return;
        
        scheduleAction(ViewNavigatorAction.POP, null, null, null, transition);
    }
    
    /**
     *  Removes all views except the bottom one from the navigation stack.
     *  
     *  @param transition The view transition to play
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function popToFirstView(transition:ViewTransition = null):void
    {
        if (navigationStack.length < 2 || !canRemoveCurrentView())
            return;
        
        scheduleAction(ViewNavigatorAction.POP_TO_FIRST, null, null, null, transition);
    }
    
    /**
     *  Pushes a new view to the top of the navigation stack.
     * 
     *  @param viewClass The class used to create the view
     *  @param data The data object to pass to the view
     *  @param context An arbitrary string that can be used to describe the context
     *         of the push.  When the new view is created, it will be able to reference
     *         this property.
     *  @param transition The view transition to play
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function pushView(viewClass:Class, 
                             data:Object = null,
                             context:Object = null,
                             transition:ViewTransition = null):void
    {
        if (viewClass == null || !canRemoveCurrentView())
            return;
        
        scheduleAction(ViewNavigatorAction.PUSH, viewClass, data, context, transition);
    }

    /**
     *  Replaces the top view of the navigation stack with a View.
     * 
     *  @param viewClass The class used to create the view
     *  @param data The data object to pass to the view
     *  @param context An arbitrary string that can be used to describe the context
     *         of the push.  When the new view is created, it will be able to reference
     *         this property.
     *  @param transition The view transition to play
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function replaceView(viewClass:Class,
                                data:Object = null,
                                context:Object = null,
                                transition:ViewTransition = null):void
    {
        if (viewClass == null || !canRemoveCurrentView())
            return;
        
        scheduleAction(ViewNavigatorAction.REPLACE_VIEW, viewClass, data, context, transition);
    }
    
    /**
     *  Shows the action bar.
     * 
     *  @param animate Indicates whether a show effect should be played.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
	public function showActionBar(animate:Boolean = true):void
	{
        if (!actionBar)
            return;
        
        showingActionBar = true;
        animateActionBarVisbility = animate;
        actionBarVisibilityInvalidated = true;
        
        invalidateProperties();
	}
    
    /**
     *  Hides the action bar.
     * 
     *  @param animate Indicates whether a hide effect should be played.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
	public function hideActionBar(animate:Boolean = true):void
	{	
        if (!actionBar)
            return;
        
        showingActionBar = false;
        animateActionBarVisbility = animate;
        actionBarVisibilityInvalidated = true;
        
        invalidateProperties();
	}
	
    //--------------------------------------------------------------------------
    //
    // Private Methods
    // 
    //--------------------------------------------------------------------------
	
    /**
     *  @private
     *  Initializes the view change process by disabling inputs on the
     *  navigator.  If the navigator has a parent, the parents mouse
     *  interaction flags are disabled.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function beginViewChange():void
    {
        viewChanging = true;

        // TODO (chiedozi): Figure out a pattern for disabling parent navigator as well
        explicitMouseChildren = mouseChildren;
        explicitMouseEnabled = mouseEnabled;
        mouseEnabled = false;
        mouseChildren = false;
    }
    
    /**
     *  @private
     */
    override public function canRemoveCurrentView():Boolean
    {
        var view:View;
        
        if (!currentViewDescriptor)
            return true;

        view = currentViewDescriptor.instance;
        return (view == null || view.canRemove());
    }
    
    /**
     *  @private
     *  Helper method that clears the action bar property invalidation flags.
     * 
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function clearActionBarInvalidationFlags():void
    {
        actionContentInvalidated = false;
        actionLayoutInvalidated = false;
        navigationContentInvalidated = false;
        navigationLayoutInvalidated = false;
        titleInvalidated = false;
        titleContentInvalidated = false;
        titleLayoutInvalidated = false;
    }
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (!isActive)
            return;
        
        // If this is the components first validation pass, push the firstView
        // on the stack if possible, otherwise set the currentViewChange flag
        // to true so that an empty screen is created.  If the currentViewDescriptor
        // property exists, that means an empty view was previously created 
        // because a firstView property wasn't supplied.
        if (!initialized && navigationStack.length == 0 && !currentViewDescriptor)
        {
            if (firstView)
                navigationStack.pushView(firstView, firstViewData);
            
            viewChangeRequested = true;
        }
        
        if (viewChangeRequested)
            commitViewChange();
        
        // Updating the action bar properties and visibility is the responsibility
        // of commitViewChange if the current view has changed because they must take
        // part in transitions. If the view change is processed during this validation,
        // the following flags will be false.
		if (actionBarPropertyInvalidated)
        	updatePropertiesForView(activeView);
			
		if (actionBarVisibilityInvalidated)
            commitVisibilityChanges();
    }
    
    /**
     *  @private
     *  This method registers a navigation operation with the navigators
     *  action queue.  Navigation operations aren't performed until the
     *  following frame to allow components to properly update their
     *  visual state before any complicated actionScript code is run by the
     *  navigator.
     * 
     *  <p>This method will execute all operations when the next ENTER_FRAME
     *  event is dispatched by the runtime.</P.
     * 
     *  @param action The navigation operation that is being performed.  Should
     *  be one of the constants in ViewNavigatorAction.
     *  @param viewClass The class that will be created in the case of a push action
     *  @param data The data object to pass to the view in the case of a push action
     *  @param transition The view transition to play
     *  @param context An arbitrary string that can be used to describe the context
     *         of the push.  When the new view is created, it will be able to reference
     *         this property.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */  
    private function scheduleAction(action:String, 
                                    viewClass:Class = null, 
                                    data:Object = null, 
                                    context:Object = null,
                                    transition:ViewTransition = null):void
    {
        // If the action queue doesn't exist, create it
        if (delayedNavigationActions.length == 0)
        {
            addEventListener(Event.ENTER_FRAME, executeDelayedActions);
            
            // Up the framerate so that we get the next ENTER_FRAME event
            // as fast as possible.  This will be restored when this event
            // is handled.
            try
            {
                explicitFrameRate = systemManager.stage.frameRate;
                systemManager.stage.frameRate = 1000;
            }
            catch (e:SecurityError)
            {
                // Ignore the possible security error
            }
        }
        
        delayedNavigationActions.push({action:action, viewClass:viewClass, 
            data:data, transition:transition, context:context});
    }
    
    /**
     *  @private
     *  Executes all the navigation operations that have been queued
     *  by the navigation methods (e.g., popView, pushView).  

     *  @param transition The view transition to play
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */  
    private function executeDelayedActions(event:Event):void
    {
        removeEventListener(Event.ENTER_FRAME, executeDelayedActions);
        
        // Restore framerate
        try
        {
            systemManager.stage.frameRate = explicitFrameRate;
        }
        catch (e:SecurityError)
        {
            // Ignore the possible securtiy error
        }
        
        if (delayedNavigationActions.length == 0)
            return;
        
        var parameters:Object;
        var n:int = delayedNavigationActions.length;
        for (var i:int = 0; i < n; ++i)
        {
            parameters = delayedNavigationActions[i];
            executeAction(parameters.action, parameters.viewClass, 
                parameters.data, parameters.context, parameters.transition); 
        }
        
        delayedNavigationActions.length = 0;
        
        // If there is a parent navigator, we need to validate from the parent
        // down to prevent renderering flickers due to invalid layout values
        // TODO (chiedozi): Investigate why i have to do this
        if (parentNavigator)
            parentNavigator.validateNow();
        else
            validateNow();
    }
    
    /**
     *  @private
     *  Helper method that executes navigation operations for the navigator.
     * 
     *  @param action The navigation operation that is being performed.  Should
     *  be one of the constants in ViewNavigatorAction.
     *  @param viewClass The class that will be created in the case of a push action
     *  @param data The data object to pass to the view in the case of a push action
     *  @param transition The view transition to play
     *  @param context An arbitrary string that can be used to describe the context
     *         of the push.  When the new view is created, it will be able to reference
     *         this property.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    private function executeAction(action:String, viewClass:Class = null, 
                                   data:Object = null,
                                   context:Object = null,
                                   transition:ViewTransition = null):void
    {
        var defaultTransition:ViewTransition;
        
        // Perform the correct operation on the navigation stack based on
        // the navigation action
        if (action == ViewNavigatorAction.PUSH)
        {
            lastAction = ViewNavigatorAction.PUSH;
            defaultTransition = defaultPushTransition;
            navigationStack.pushView(viewClass, data, context);
        }
        else if (action == ViewNavigatorAction.REPLACE_VIEW)
        {
        	lastAction = ViewNavigatorAction.REPLACE_VIEW;
            defaultTransition = defaultPushTransition;
            navigationStack.popView();
            navigationStack.pushView(viewClass, data, context);
        }
        else
        {
            defaultTransition = defaultPopTransition;
            
            if (action == ViewNavigatorAction.POP)
            {
                navigationStack.popView();
            }
            else if (action == ViewNavigatorAction.POP_TO_FIRST)
            {
                navigationStack.popToFirstView();
            }
            else if (action == ViewNavigatorAction.POP_ALL)
            {
                navigationStack.clear();
            }
            
            // If the currentView navigation data object is the same as the
            // new one, the activeView doesn't need to be changed.  This can
            // happen if a pushView() is followed immediately by a popView().
            if (navigationStack.topView == currentViewDescriptor)
            {
                if (viewChanging)
                {
                    revalidateWhenComplete = false;
                }
                else
                {
                    viewChangeRequested = false;    
                }
                
                lastAction = ViewNavigatorAction.NONE;
                return;
            }
            
            lastAction = ViewNavigatorAction.POP;
        }
        
        pendingViewTransition = transition;
        if (pendingViewTransition == null && useDefaultTransitions)
            pendingViewTransition = defaultTransition;

        // TODO (chiedozi): Comment this more
        if (viewChanging)
        {
            revalidateWhenComplete = true;
        }
        else
        {
            viewChangeRequested = true;
            invalidateProperties();
        }
    }
    
    /**
     *  @private
     *  Invalidates all action bar property flags.
     */
    private function invalidateActionBarProperties():void
    {
        actionContentInvalidated =
        actionLayoutInvalidated =
        navigationContentInvalidated =
        navigationLayoutInvalidated =
        titleInvalidated =
        titleContentInvalidated =
        titleLayoutInvalidated = true;
        
        invalidateProperties();
    }
    
    /**
     *  @private
     *  Commits the visiblity changes that have been requested.  This method
     *  is called during an invalidation pass if the current view has not changed
     *  and the action bar's visibility has changed.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function commitVisibilityChanges():void
    {
        // TODO (chiedozi): Check if spark effects handles include in layout for you
        // Can't change the visibility during a view transition
        if (viewChanging)
        {
            actionBarVisibilityInvalidated = false;
            return;
        }
        
        // If an animation is running, end it
        // FIXME (chiedozi): There is an issue here when you do two hides/shows in a row
        if (actionBarVisibilityEffect)
            actionBarVisibilityEffect.end();
        
        if (actionBar && showingActionBar != actionBar.visible)
        {
            if (transitionsEnabled && animateActionBarVisbility)
            {
                actionBarVisibilityEffect = createVisibilityAnimation();
                actionBarVisibilityEffect.addEventListener(EffectEvent.EFFECT_END, 
                    visibilityAnimation_completeHandler);
                actionBarVisibilityEffect.play();
            }
            else
            {
                if (actionBarVisibilityInvalidated)
                    actionBar.visible = actionBar.includeInLayout = !actionBar.visible;
            }
        }
        
        actionBarVisibilityInvalidated = false;
    }
    
    /**
     *  Creates the effect to play when the actionBar is hidden or shown.
     *  The produced effect is responsible for animating both the actionBar and
     *  the contentGroup of the navigator.
     * 
     *  @return An effect to play
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
	protected function createVisibilityAnimation():IEffect
	{
		var effect:IEffect;
		var finalEffect:Parallel = new Parallel();
        
        // Grab initial values
		actionBarProps = { target:actionBar, start:captureAnimationValues(actionBar) };
        contentGroupProps = { target:contentGroup, start:captureAnimationValues(contentGroup) };
        
        // Update actionBar layout properties
        if (actionBarVisibilityInvalidated)
            actionBar.visible = actionBar.includeInLayout = !actionBarProps.start.visible;
        
        // Calculate final positions.  This method will force a validation
        calculateFinalUIPositions();
		
        // The actionbar will be visible if we are animating it
		if (actionBar.visible)
		{
            effect = createActionBarVisibilityEffect(actionBar.visible, actionBarProps);
            effect.target = actionBar;
            
            finalEffect.addChild(effect);
		}
		
        effect = createContentVisibilityEffect(actionBar.visible, contentGroupProps);
        effect.target = contentGroup;
        
		finalEffect.addChild(effect);
		
        return finalEffect;
	}

    /**
     *  @private
     *  Responsible for calculating the final positions of the action bar
     *  when it's visiblity is changed.  This method will force a validation
     *  pass.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function calculateFinalUIPositions():void
    {
        var animateActionBarUp:Boolean;
        
        // Determine whether the action bar should be animated up or down
        if (overlayControls)
        {
            // The actionBar is animated up if the actionBar is above the center
            // of the navigator
            animateActionBarUp = (actionBar.y + (actionBar.height / 2)) <= height / 2;
        }
        else
        {
            // The actionBar is animated up if it is above the contentGroup
            animateActionBarUp = actionBar.y <= contentGroup.y;
        }
        
        // Need to validate to capture final positions and sizes of skin parts.
        // If the navigator is a child of another, we need the root navigator
        // to perform the validation so that all widths and heights of all
        // containers are sized.
        LayoutManager.getInstance().validateNow();
        
        // This will store the final location and sizes of the components
        actionBarProps.end = captureAnimationValues(actionBar);
        contentGroupProps.end = captureAnimationValues(contentGroup);
        
        // Update the end position of the animation based on whether the
        // actionBar is showing/hiding and if it is animating up or down.
        if (actionBarVisibilityInvalidated)
        {
            if (animateActionBarUp)
            {
                if (actionBarProps.start.visible)
                    actionBarProps.end.y = -actionBar.height;
                else
                    actionBarProps.start.y = -actionBar.height;
            }
            else
            {
                if (actionBarProps.start.visible)
                    actionBarProps.end.y = this.height;
                else
                    actionBarProps.start.y = this.height;
            }
            
            actionBar.visible = true;
        }
    }
    
    /**
     *  @private
     *  Captures the important animation values of component to use
     *  when animating the actionBar's visiblity.
     *  
     *  @param component The component to capture the values from
     * 
     *  @return Returns an object that contains the properties 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    protected function captureAnimationValues(component:UIComponent):Object
    {
        var values:Object = {   x:component.x,
                                y:component.y,
                                width:component.width,
                                height:component.height,
                                visible: component.visible,
                                includeInLayout: component.includeInLayout,
                                cacheAsBitmap: component.cacheAsBitmap };
        
        return values;
    }
    
    /**
     *  Creates the effect to play on the actionBar component when the navigator
     *  is generating the animation.  This effect should only target the actionBar
     *  as it will be played in parallel with other effects that animate the other
     *  navigator skin parts.
     * 
     *  @param hiding Indicates whether the acton bar is hiding or showing
     *  @param props The bounds properties that were captured for the actionBar.  
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function createActionBarVisibilityEffect(hiding:Boolean, props:Object):IEffect
    {
        var animate:Animate = new Animate();
        animate.target = actionBar;
        animate.duration = ACTION_BAR_ANIMATION_DURATION;
        animate.motionPaths = new Vector.<MotionPath>();
        animate.motionPaths.push(new SimpleMotionPath("y", props.start.y, props.end.y));

        actionBar.includeInLayout = false;
        actionBar.cacheAsBitmap = true;
        
        return animate;
    }
    
    /**
     *  @private
     *  Creates the effect to play on the contentGroup when the navigator is
     *  generating an animation to play to hide or show the action bar.  This effect
     *  should only target the contentGroup as it will be played in parallel with
     *  other effects that animate the other navigator skin parts.
     * 
     *  @param hiding Indicates whether the acton bar is hiding or showing
     *  @param props The bounds properties that were captured for the actionBar.  
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function createContentVisibilityEffect(hiding:Boolean, props:Object):IEffect
    {
        var animate:Animate = new Animate();
        animate.target = contentGroup;
        animate.duration = ACTION_BAR_ANIMATION_DURATION;
        animate.motionPaths = new Vector.<MotionPath>();
        animate.motionPaths.push(new SimpleMotionPath("height", props.start.height, props.end.height));
        animate.motionPaths.push(new SimpleMotionPath("y", props.start.y, props.end.y));

        props.target.includeInLayout = false;
        props.target.cacheAsBitmap = true;    
        
        return animate;
    }
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
	private function visibilityAnimation_completeHandler(event:EffectEvent):void
	{
        // Update the actionBar visibility and includeInLayout flags		
		actionBar.visible = actionBar.includeInLayout = !actionBarProps.start.visible;
		
        // Restore includeInLayout and cacheAsBitmap properties for each component
        actionBar.cacheAsBitmap = actionBarProps.start.cacheAsBitmap;
		contentGroup.includeInLayout = contentGroupProps.start.includeInLayout;
		contentGroup.cacheAsBitmap = contentGroupProps.start.cacheAsBitmap;
		
        // Clear flags and temporary properties
		actionBarVisibilityEffect = null;
		actionBarProps = null;
		contentGroupProps = null;
		actionBarVisibilityInvalidated = false;
        
        event.target.removeEventListener(EffectEvent.EFFECT_END, visibilityAnimation_completeHandler);
	}
    
    /**
     *  @private
     *  This method is responsible for completing a view change validation pass.
     *  It is responsible for cleaning up and destroying the old view, as well as
     *  activating the new one.
     * 
     *  <p>If a transition was played, this method is called after the transition
     *  completes.</p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function endViewChange():void
    {
        // Destroy the previous view
        if (currentViewDescriptor)
            destroyViewInstance(currentViewDescriptor);
        
        // Update view pointers
        currentViewDescriptor = pendingViewDescriptor;
        pendingViewDescriptor = null;

        // Clear empty flag if necessary
        if (emptyViewDescriptor && currentViewDescriptor != emptyViewDescriptor)
            emptyViewDescriptor = null;
        
        // If there is no focus or the item that had focus isn't 
        // on the display list anymore, update the focus to be
        // the active view or the view navigator
        var stage:Stage = systemManager.stage;
        if (!stage.focus || !stage.focus.stage || stage.focus == this)
        {
            if (activeView)
                stage.focus = activeView;
            else
                stage.focus = this;
        }
        
        // At this point, currentViewDescriptor points to the new view
        if (currentViewDescriptor)
        {
            var currentView:View= currentViewDescriptor.instance;
            
            if (currentView)
            {
                currentView.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, 
                                                view_propertyChangeHandler);
                currentView.setActive(true);
            }
        }
        
        // Clear the returned object
        _poppedViewReturnedObject = null;
        
        // Restore mouse children properties before revalidation occurs.  This
        // needs to occur before a possible revalidation occurs so that the
        // saved mouseChildren and mouseEnabled flags aren't overwritten.
        mouseChildren = explicitMouseChildren;
        mouseEnabled = explicitMouseEnabled;
        
        if (revalidateWhenComplete)
        {
            revalidateWhenComplete = false;
            viewChangeRequested = true;
            commitViewChange();
        }
        else
        {
            lastAction = ViewNavigatorAction.NONE;
            viewChanging = false;
            
            // Notify listeners that the view change is complete
            if (hasEventListener(Event.COMPLETE))
                dispatchEvent(new Event(Event.COMPLETE));
        }
    }
    
    /**
     *  @private
     *  Called in commitProperties() and begins the view transition
     *  process.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function commitViewChange():void
    {
        // TODO (chiedozi): Perf only
//        CONFIG::performanceInstrumentation
        {
            // Private event used for performance tests
            if (hasEventListener("viewChangeStart"))
                dispatchEvent(new Event("viewChangeStart"));
        }
        
        if (!isActive)
            return;
        
        // If a ui control is animating, force it to end
        if (actionBarVisibilityEffect)
            actionBarVisibilityEffect.end();
        
        if (activeView && (lastAction == ViewNavigatorAction.POP || 
                           lastAction == ViewNavigatorAction.REPLACE_VIEW))
        {
            _poppedViewReturnedObject = createViewReturnObject(currentViewDescriptor);
        }
        
        beginViewChange();
        
        pendingViewDescriptor = navigationStack.topView;
        
        // Create an empty view if no firstView viewClass is defined
        if (pendingViewDescriptor == null)
        {
            emptyViewDescriptor = new ViewDescriptor(View);
            pendingViewDescriptor = emptyViewDescriptor;
        }
        
        if(pendingViewDescriptor.viewClass != null)
        {
            createViewInstance(pendingViewDescriptor);
            
            viewChangeRequested = false;
            
            // Schedule the view added method to occur at a later time so to allow developers
            // to take advantage of validation lifecycle events, such as CREATION_COMPLETE,
            // to update properties and states on the view.  If this wasn't done, it would be
            // possible to lose invalidation calls since ViewNavigator is still in its 
            // commitProperties call.
            callLater(viewAdded, [(transitionsEnabled ? pendingViewTransition : null)]);
        }
        else
        {
            // Cancel operation if the viewClass class is null
            viewChangeRequested = false;
            endViewChange();
        }
        
        pendingViewTransition = null;
    }
    
    /**
     *  @private
     */ 
    override mx_internal function createTopView():void
    {
        // Check if the top view already exists
        if (activeView)
            return;
        
        invalidateActionBarProperties();
        
        // If the navigation stack is empty, push on the firstView for the
        // navigator.
        if (navigationStack.length == 0)
        {
            if (firstView != null)
                navigationStack.pushView(firstView, firstViewData);
            else
                return;
        }
        
        // Update the current view reference
        currentViewDescriptor = navigationStack.topView;
        
        // Create the view if needed
        var view:View = currentViewDescriptor.instance;
        if (!view)
        {
            view = createViewInstance(currentViewDescriptor);
            view.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, view_propertyChangeHandler);
        }
        
        // Cancel any view change requests that occurred prior to this call
        // since the top most view was just created.
        viewChangeRequested = false;
    }
    
    /**
     *  @private
     */
    private function createViewInstance(viewProxy:ViewDescriptor):View
    {
        var view:View;
        
        if (viewProxy.instance == null)
        {
            view = new viewProxy.viewClass();
            viewProxy.instance = view;
        }
        else
        {
            view = viewProxy.instance;
        }
        
        // Restore persistence data if necessary
        if (viewProxy.data == null && viewProxy.persistenceData != null)
            viewProxy.data = view.deserializePersistedData(viewProxy.persistenceData);
        
        view.navigator = this;
        view.data = viewProxy.data;
        view.percentWidth = view.percentHeight = 100;
        
        // Update the views orientation state
        if ((landscapeOrientation && view.hasState("landscape")) ||
            (!landscapeOrientation && view.hasState("portrait")))
        {
            view.setCurrentState(view.getCurrentViewState(landscapeOrientation), false);
        }
        
        addElement(view);
        
        return view;
    }
    
    /**
     *  @private
     */ 
    private function createViewReturnObject(viewProxy:ViewDescriptor):ViewReturnObject
    {
        var view:View = viewProxy.instance;
        
        if (view)
            return new ViewReturnObject(view.createReturnObject(), viewProxy.context);

        return null;
    }
    
    /**
     *  @private
     */ 
    private function destroyViewInstance(viewProxy:ViewDescriptor):void
    {
        var currentView:View = viewProxy.instance;
        
        if (!currentView)
            return;
        
        // Deactivate the view if it is active
        if (currentView.isActive)
            currentView.setActive(false);
        
        removeElement(currentView);
        
        currentView.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, 
            view_propertyChangeHandler);
        
        // Grab the data from the old view and persist it
        if (lastAction == ViewNavigatorAction.PUSH)
        {
            viewProxy.data = currentView.data;
            viewProxy.persistenceData = currentView.serializeData();
        }
        
        // Check if we can delete the reference for the view instance.  If the current
        // view is being replaced or popped of the stack, we know we can delete it.
        // Otherwise a push is happening and we need to check the destructionPolicy
        // of the view.
        if (lastAction == ViewNavigatorAction.POP || 
            lastAction == ViewNavigatorAction.REPLACE_VIEW || 
            currentView.destructionPolicy != ContainerDestructionPolicy.NEVER)
        {
            currentView.navigator = null;
            viewProxy.instance = null;
        }
    }
    
    /**
     *  @private
     */
    override public function saveViewData():Object
    {
        var savedData:Object = super.saveViewData();
        
        if (currentViewDescriptor && currentViewDescriptor.instance)
            currentViewDescriptor.persistenceData = currentViewDescriptor.instance.serializeData();
        
        if (!savedData)
            savedData = {};
        
        savedData.navigationStack = navigationStack;
        return savedData;
    }
    
    /**
     *  @private
     */ 
    override public function restoreViewData(value:Object):void
    {
        super.restoreViewData(value);
        
        if (value)
            navigationStack = value.navigationStack as NavigationStack; 
    }
    
    /**
     *  @private
     *  Method is called during the view transition process after the
     *  instance of the new view is added to the display list.  It initializes
     *  the underlying ViewDescriptor object and prepares the transition.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function viewAdded(transition:ViewTransition = null):void
    {
        var currentView:View;
        var pendingView:View;
        
        // Deactivate the current view
        if (currentViewDescriptor)
        {
            // FIXME (chiedozi): Do we need to remove view from layout?
            currentView = currentViewDescriptor.instance;
            currentView.setActive(false);
            currentView.includeInLayout = false;
            
            // Need to validateNow() to make sure our old screen is currently 
            // up to date before starting the transition and possibly storing a bitmap 
            // for the transition
            currentView.validateNow();
            
            // Restore the includeInLayout flag on the currentView
            currentView.includeInLayout = true;
        }
        
        // Store new view
        if (pendingViewDescriptor)
        {
            pendingView = pendingViewDescriptor.instance;
            pendingView.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, 
                            view_propertyChangeHandler);
        }
        
        if (transition)
        {
            transition.addEventListener(Event.COMPLETE, transitionComplete);
            transition.currentView = currentView;
            transition.nextView = pendingView;
            transition.navigator = this;
            
            // Give the transition a chance to prepare before the view updates
            transition.captureStartValues();
        }
        
        // Invalidate the actionBar properties
        if (actionBar)
        {
            invalidateActionBarProperties();
            updatePropertiesForView(pendingView);
        }
        
        if (parentNavigator)
            parentNavigator.updatePropertiesForView(pendingView);
        
        // Need to force state change by calling validate properties again
        if (overlayControls != pendingView.overlayControls)
        {
		    overlayControls = pendingView.overlayControls;
            
            // We need to force a commitProperties on the SkinnableComponent so that
            // state changes are validated this frame.
            super.commitProperties();
        }
        
        // Only force validation for the navigator if initialized to avoid
        // validation from occurring with wrong measured dimensions
        if (initialized)
        {
            // Need to validate my children now to prevent flicker when no transition,
            // or so sizes can be measured before transition
            if (parentNavigator)
                UIComponent(parentNavigator).validateNow();
            else
                validateNow();
        }
        
        // Run transition a frame later so that the overhead of creating the view
		// and the time the player takes to render isn't included in the duration.
		// See SDK-27793.
        if (transition)
        {
			transition.prepareFinalState();
			finalViewTransition = transition;
			
			addEventListener(Event.ENTER_FRAME, startViewTransition);
        }
        else
        {
            endViewChange();
        }
    }

	/**
	 *  @private
	 *  Starts the view transition.
	 */
	private function startViewTransition(event:Event):void
	{
		removeEventListener(Event.ENTER_FRAME, startViewTransition);
		
//        CONFIG::performanceInstrumentation
		{
			if (hasEventListener("transitionStart"))
				dispatchEvent(new Event("transitionStart", false, false));
		}
		
		finalViewTransition.play();
	}
	
    /**
     *  @private
     *  Called when a transition dispatches a COMPLETE event.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function transitionComplete(event:Event):void
    {
        ViewTransition(event.target).removeEventListener(Event.COMPLETE, transitionComplete);
        
//        CONFIG::performanceInstrumentation
        {
            if (hasEventListener("transitionEnd"))
               dispatchEvent(new Event("transitionEnd", false, false));
        }
        
		finalViewTransition = null;
        endViewChange();
    }
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function backKeyHandler():void
    {
        popView();
    }
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function updatePropertiesForView(view:View):void
    {
        super.updatePropertiesForView(view);
        
        if (!actionBar)
            return;
 
        // If there is no view, update the actionBar should display the 
        // navigator defaults
        if (view == null)
        {
            actionBar.actionContent = actionContent;
            actionBar.actionLayout = actionLayout;
            actionBar.navigationContent = navigationContent;
            actionBar.navigationLayout = navigationLayout;
            actionBar.title = title;
            actionBar.titleContent = titleContent;
            actionBar.titleLayout = titleLayout;
        }
        else
        {
            if (actionContentInvalidated)
            {
                actionBar.actionContent = view && view.actionContent ? 
                    view.actionContent : actionContent;
                actionContentInvalidated = false;
            }
            
            if (actionLayoutInvalidated)
            {
                actionBar.actionLayout = view && view.actionLayout ? 
                    view.actionLayout : actionLayout;
                actionLayoutInvalidated = false;
            }
            
            if (navigationContentInvalidated)
            {
                actionBar.navigationContent = view && view.navigationContent ? 
                    view.navigationContent : navigationContent;
                navigationContentInvalidated = false;
            }
            
            if (navigationLayoutInvalidated)
            {
                actionBar.navigationLayout = view && view.navigationLayout ? 
                    view.navigationLayout : navigationLayout;
                navigationLayoutInvalidated = false;
            }
            
            if (titleInvalidated)
            {
                actionBar.title = view && view.title ? view.title : title;
                titleInvalidated = false;
            }
            
            if (titleContentInvalidated)
            {
                actionBar.titleContent = view && view.titleContent ? 
                    view.titleContent : titleContent;
                titleContentInvalidated = false;
            }
            
            if (titleLayoutInvalidated)
            {
                actionBar.titleLayout = view && view.titleLayout ? 
                    view.titleLayout : titleLayout;
                titleLayoutInvalidated = false;
            }
			
			actionBar.visible = actionBar.includeInLayout = view && view.actionBarVisible;
            actionBarVisibilityInvalidated = false;
        }
    }
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function view_propertyChangeHandler(event:PropertyChangeEvent):void
    {
        var property:Object = event.property;
        
        // Check for actionBar related property changes
        if (actionBar)
        {
            if (property == "title")
                titleInvalidated = true;
            else if (property == "titleContent")
                titleContentInvalidated = true;
            else if (property == "titleLayout")
                titleLayoutInvalidated = true;
            else if (property == "actionContent")
                actionContentInvalidated = true;
            else if (property == "actionLayout")
                actionLayoutInvalidated  = true;
			else if (property == "navigationContent")
				navigationContentInvalidated = true;
			else if (property == "navigationLayout")
				navigationLayoutInvalidated  = true;
            else if (property == "overlayControls")
            {
                overlayControls = event.newValue;
            }
                
            invalidateProperties();
        }
    }
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
     
        // If the actionBar changes, need to reset the properties on it
        if (instance == actionBar)
        {
            actionContentInvalidated = true;
            actionLayoutInvalidated = true;
            navigationContentInvalidated = true;
            navigationLayoutInvalidated = true;
            titleInvalidated = true;
            titleContentInvalidated = true;
            titleLayoutInvalidated = true;
            
            invalidateProperties();   
        }
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        // Clear out all the content that is within the actionBar
        if (instance == actionBar)
        {
            actionBar.actionContent = null;
            actionBar.actionLayout = null;
            actionBar.titleContent = null;
            actionBar.titleLayout = null;
            actionBar.navigationContent = null;
            actionBar.navigationContent = null;
        }
    }
}
}


/**
 * @private
 */
class ViewNavigatorAction
{
    public static const NONE:String = "none";
    public static const PUSH:String = "push";
    public static const POP:String = "pop";
    public static const POP_ALL:String = "popAll";
    public static const POP_TO_FIRST:String = "popToFirst";
    public static const REPLACE_VIEW:String = "replaceView";
    public static const REPLACE_STACK:String = "replaceStack";    
}