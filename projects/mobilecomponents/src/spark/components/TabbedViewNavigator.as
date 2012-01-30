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

// TODO (chiedozi): TabbedViewNavigator should override setActive and activate
// the correct ViewNavigator.
package spark.components
{
import flash.display.Stage;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;

import mx.core.ISelectableList;
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

import spark.components.supportClasses.ButtonBarBase;
import spark.components.supportClasses.ViewNavigatorBase;
import spark.effects.Animate;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.events.ElementExistenceEvent;
import spark.events.IndexChangeEvent;
import spark.events.RendererExistenceEvent;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the current view navigator changes as a result of
 *  a change to the <code>selectedIndex</code> property or a change 
 *  to the selected tab in the TabBar control.
 * 
 *  @eventType spark.events.IndexChangeEvent.CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="change", type="spark.events.IndexChangeEvent")]

/**
 *  Dispatched before the selected view navigator is changed.  
 *  Canceling this event prevents the active view navigator
 *  from changing.
 * 
 *  @eventType spark.events.IndexChangeEvent.CHANGING
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="changing", type="spark.events.IndexChangeEvent")]

/**
 *  Dispatched when the collection of view navigators managed by the
 *  TabbedViewNavigator changes.
 * 
 *  @eventType mx.events.CollectionEvent.COLLECTION_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="collectionChange", type="mx.events.CollectionEvent")]

/**
 *  Dispatched when the view navigator's selected index changes.  
 *  When this event is dispatched, the <code>selectedIndex</code> 
 *  and <code>selectedNavigator</code> properties reference the 
 *  newly selected view navigator.
 * 
 *  @eventType mx.events.FlexEvent.VALUE_COMMIT
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="valueCommit", type="mx.events.FlexEvent")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("TabbedViewNavigator.png")]

/**
 *  The TabbedViewNavigator class is a container that manages a collection
 *  of view navigator containers.  
 *  Only one view navigator is active and visible at a time.  
 *  This class includes a TabBar control that provides the ability to toggle between
 *  the collection of view navigators.  
 *
 *  <p>The following image shows a TabbedViewNavigator with three sections: 
 *  Employees, Contacts, and Search:</p>
 *
 * <p>
 *  <img src="../../images/tvn_sections_with_ab_tvn.png" alt="Tabbed view navigator" />
 * </p>
 *
 *  <p>The TabbedViewNavigatorApplication container automatically creates 
 *  a single TabbedViewNavigator container for the entire application. 
 *  You can reference the TabbedViewNavigator object by using the <code>navigator</code>
 *  property of the TabbedViewNavigatorApplication container.</p>
 * 
 *  <p>The active or selected navigator can be changed by clicking the corresponding
 *  tab in the TabBar or by changing the <code>selectedIndex</code> property of
 *  the component.</p>
 * 
 *  <p>The contents of a child view navigator is destroyed when it is deactivate, 
 *  and dynamically created when activated.</p>  
 * 
 *  @see spark.components.View
 *  @see spark.components.ViewNavigator
 *  @see spark.components.TabBar
 *
 *  @includeExample examples/TabbedViewNavigatorExample.mxml -noswf
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class TabbedViewNavigator extends ViewNavigatorBase implements ISelectableList
{
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
  
    // TODO (chiedozi): Consider having a NO_SELECTION constant to differentiate
    // between NO_PROPOSED_SELECTION and clearing the selection.  See List.  It
    // seems redundant because TabbedViewNavigator expects requireSelection to be
    // true on its TabBar.
    /**
     *  @private
     *  Static constant representing no proposed selection.
     */
    private static const NO_PROPOSED_SELECTION:int = -1;
    
    /**
     *  @private
     *  The animation duration used when hiding and showing the action bar.
     */ 
    private static const TAB_BAR_ANIMATION_DURATION:Number = 250;
    
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
    public function TabbedViewNavigator()
    {
        super();
        
        addEventListener(ElementExistenceEvent.ELEMENT_ADD, elementAddHandler);
        addEventListener(ElementExistenceEvent.ELEMENT_REMOVE, elementRemoveHandler);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    [Bindable]
    [SkinPart(required="false")]
    /**
     *  A skin part that defines the tab bar of the navigator. 
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var tabBar:ButtonBarBase;
    
    //--------------------------------------------------------------------------
    //
    // Variables
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private var animateTabBarVisbility:Boolean = false;
    
    /**
     *  @private
     */ 
    private var contentGroupProps:Object;
    
    /**
     *  @private 
     *  Determines if a changing event has already been dispatched.
     *  This was introduced to prevent the IndexChangeEvent from
     *  dispatching twice when the tabBar selection changes.
     */
    private var changingEventDispatched:Boolean = false;
    
    /**
     *  @private
     */ 
    private var dataProviderChanged:Boolean = false;
    
    /**
     *  @private
     */
    private var explicitTabBarMouseEnabled:Boolean = false;
    
    /**
     *  @private
     *  Keeps track of the tab that was last selected.  See 
     *  tabBarRendererClicked() for information on how it's used.
     */ 
    private var lastSelectedIndex:int = -1;
    
    /**
     *  @private
     */
    private var selectedIndexChanged:Boolean = false;
    
    /**
     *  @private
     */
    private var selectedIndexAdjusted:Boolean = false;
    
    /**
     *  @private
     */
    private var showingTabBar:Boolean;
    
    /**
     *  @private
     */
    private var tabBarVisibilityEffect:IEffect;
    
    /**
     *  @private
     */ 
    private var tabBarProps:Object;
    
    /**
     *  @private
     */    
    private var tabBarVisibilityChanged:Boolean = false;
    
    /**
     * @private
     */
    mx_internal var selectedNavigatorChangingView:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    // Properties
    // 
    //--------------------------------------------------------------------------

    //----------------------------------
    //  activeView
    //----------------------------------
    
    [Bindable("viewChangeComplete")]
    /**
     *  @private
     */
    override public function get activeView():View
    {
        if (selectedNavigator)
            return selectedNavigator.activeView;
        
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
        if (selectedNavigator)
            return selectedNavigator.exitApplicationOnBackKey;

        return super.exitApplicationOnBackKey;
    }
    
    //----------------------------------
    //  maintainNavigationStack
    //----------------------------------
    private var _maintainNavigationStack:Boolean = true;
    
    /**
     *  @private 
     *  Specifies whether the navigation stack of the view navigator
     *  should remain intact when the view navigator is deactivated.
     *  If <code>true</code>, when reactivated the view history
     *  remains the same.  
     *  If <code>false</code>, the navigator displays the
     *  first view in its navigation stack.
     * 
     *  @default true
     *  
     *  @see spark.components.ViewNavigator
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    mx_internal function get maintainNavigationStack():Boolean
    {
        return _maintainNavigationStack;
    }
    
    /**
     *  @private
     */ 
    mx_internal function set maintainNavigationStack(value:Boolean):void
    {
        _maintainNavigationStack = value;
    }
    
    //----------------------------------
    //  navigators
    //----------------------------------
    
    /**
     *  The view navigators that are managed by this TabbedViewNavigator.
     *  Each view navigator is represented as a tab in the tab bar 
     *  of this TabbedViewNavigator.
     *  Only one view navigator can be active at a time.
     *  You can reference the active view navigator by using
     *  the <code>selectedNavigator</code> property.
     * 
     *  <p>Changing this property causes the current view navigator to be removed,
     *  and sets the <code>selectedIndex</code> to 0. 
     *  This operation cannot be canceled and is committed immediately.</p>
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get navigators():Vector.<ViewNavigatorBase>
    {
        var mxmlContent:Array = currentContentGroup.getMXMLContent();
        
        if (!mxmlContent)
            return null;
        
        // When this class was first released, navigators was typed Vector
        // and not Array.  In 4.6, TabbedViewNavigator moved away from this 
        // model and uses mxmlContent to manage children.  To maintain backwards 
        // compatibility, the return type for this method remained the same.
        // As a result, the mxmlContent array will need to converted.
        return Vector.<ViewNavigatorBase>(mxmlContent);
    }
    
    /**
     *  @private
     */ 
    public function set navigators(value:Vector.<ViewNavigatorBase>):void
    {
        // When this class was first released, navigators was typed Vector
        // and not Array.  In 4.6, TabbedViewNavigator moved away from this
        // model and uses mxmlContent to manage children.  To maintain backwards 
        // compatibility, the return type for this method remained the same.
        // As a result, the value vector needs to be converted to an array
        var contentArray:Array = new Array();
        
        for each (var navigator:ViewNavigatorBase in value)
        {
            contentArray.push(navigator);
            setupNavigator(navigator);
        }
        
        mxmlContent = contentArray;

        // The proposed selected index is reset because it is no longer valid
        // since the array of navigators has changed.
        selectedIndexChanged = false;
        
        // Invalidate property flags
        dataProviderChanged = true;
        invalidateProperties();
        
        // Notify listeners that the collection changed
        internalDispatchEvent(CollectionEventKind.RESET);
    }
    
    //----------------------------------
    //  selectedNavigator
    //----------------------------------
    
    [Bindable("change")]
    /**
     *  The selected view navigator for the TabbedViewNavigator.  
     *  Only one view navigator can be active at a time.  
     *  The active view navigator can be set by changing the 
     *  <code>selectedIndex</code> property or by selecting 
     *  a tab in the TabBar control.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    public function get selectedNavigator():ViewNavigatorBase
    {
        if (length == 0 || selectedIndex < 0 || selectedIndex >= length) 
            return null;
        
        return getElementAt(selectedIndex) as ViewNavigatorBase;
    }
    
    //--------------------------------------------------------------------------
    //
    // Public Methods
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  Hides the tab bar of the navigator.
     * 
     *  @param animate Indicates whether a hide effect should play
     *  as the tab bar disappears.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function hideTabBar(animate:Boolean = true):void
    {   
        if (!tabBar)
            return;
        
        showingTabBar = false;
        animateTabBarVisbility = animate;
        tabBarVisibilityChanged = true;
        
        invalidateProperties();
    }
    
    /**
     *  Shows the tab bar of the navigator
     *  
     *  @param animate Indicates whether a show effect should play
     *  as the tab bar appears.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function showTabBar(animate:Boolean = true):void
    {
        if (!tabBar)
            return;
        
        showingTabBar = true;
        animateTabBarVisbility = animate;
        tabBarVisibilityChanged = true;
        
        invalidateProperties();
    }
    
    /**
     *  @private
     *  Updates the navigator's state based on the properties set
     *  on the active view.  The main use cases are to hide the
     *  TabBar and the change the overlay state.
     * 
     *  @param view The active view.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function updateControlsForView(view:View):void
    {
        super.updateControlsForView(view);
        
        if (view)
        {
            if (tabBar)
                tabBar.visible = tabBar.includeInLayout = view.tabBarVisible;

            overlayControls = view.overlayControls;
        }
        else
        {
            // If the current view is null, the tab bar is shown so that the
            // user still has a ui for changing the selected tab.
            if (tabBar)
                tabBar.visible = tabBar.includeInLayout = true;

            overlayControls = false;
        }

        tabBarVisibilityChanged = false;
    }
    
    /**
     *  Calls the backKeyUpHandler() of the selected navigator.
     * 
     *  <p>TabbedViewNavigatorApplication automatically calls this method when 
     *  the back key is pressed.</p>
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3.1
     *  @productversion Flex 4.6
     */ 
    override public function backKeyUpHandler():void
    {
        if (selectedNavigator)
            selectedNavigator.backKeyUpHandler();    
    }
    
    //--------------------------------------------------------------------------
    //
    // Private Methods
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Calculates the final positions for the tab bar visibility animations.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function prepareTabBarForAnimation(showAnimation:Boolean):void
    {
        var animateTabBarUp:Boolean;
        
        if (overlayControls)
        {
            // If the control is overlaid on top, the tabBar is animated up if 
            // the tabBar is above the center of the navigator
            animateTabBarUp = (tabBar.y + (tabBar.height / 2)) <= height / 2;
        }            
        else
        {
            // The tabBar is animated up if it is above the contentGroup
            animateTabBarUp = tabBar.y <= contentGroup.y;
        }
        
        // Need to validate to capture final positions and sizes of skin parts
        LayoutManager.getInstance().validateNow();
        
        // This will store the final location and sizes of the components
        tabBarProps.end = captureAnimationValues(tabBar);
        contentGroupProps.end = captureAnimationValues(contentGroup);
        
        if (tabBarVisibilityChanged)
        {
            if (animateTabBarUp)
            {
                if (tabBarProps.start.visible)
                    tabBarProps.end.y = -tabBar.height;
                else
                    tabBarProps.start.y = -tabBar.height;
            }
            else
            {
                if (tabBarProps.start.visible)
                    tabBarProps.end.y = this.height;
                else
                    tabBarProps.start.y = this.height;
            }
        }
        
        tabBar.visible = true;
        tabBar.includeInLayout = false;
        tabBar.cacheAsBitmap = true;
    }
    
    /**
     *  @private
     */
    override mx_internal function canRemoveCurrentView():Boolean
    {
        return (!selectedNavigator || selectedNavigator.canRemoveCurrentView());
    }
    
    /**
     *  @private
     */
    private function addNavigatorListeners(navigator:ViewNavigatorBase):void
    {
        navigator.addEventListener("viewChangeComplete", navigator_viewChangeCompleteHandler);
        navigator.addEventListener("viewChangeStart", navigator_viewChangeStartHandler);
        navigator.addEventListener(ElementExistenceEvent.ELEMENT_ADD, navigator_elementAddHandler);
        navigator.addEventListener(ElementExistenceEvent.ELEMENT_REMOVE, navigator_elementRemoveHandler); 
    }
    
    /**
     *  @private
     */
    private function removeNavigatorListeners(navigator:ViewNavigatorBase):void
    {
        navigator.removeEventListener("viewChangeComplete", navigator_viewChangeCompleteHandler);
        navigator.removeEventListener("viewChangeStart", navigator_viewChangeStartHandler);
        navigator.removeEventListener(ElementExistenceEvent.ELEMENT_ADD, navigator_elementAddHandler);
        navigator.removeEventListener(ElementExistenceEvent.ELEMENT_REMOVE, navigator_elementRemoveHandler); 
    }
    
    /**
     *  @private
     */ 
    private function setupNavigator(navigator:ViewNavigatorBase):void
    {
        navigator.setParentNavigator(this);
        navigator.visible = false;
        navigator.includeInLayout = false;
        
        // All navigators should be inactive when initialized.  The proper
        // navigator will be activated during commitProperties().
        navigator.setActive(false);
        
        startTrackingUpdates(navigator);
    }
    
    /**
     *  @private
     */ 
    private function cleanUpNavigator(navigator:ViewNavigatorBase):void
    {
        navigator.setParentNavigator(null);
        
        if (navigator.isActive)
            navigator.setActive(false);

        if (navigator.activeView)
        {
            navigator.activeView.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, 
                view_propertyChangeHandler);
        }
        
        removeNavigatorListeners(navigator);
        stopTrackingUpdates(navigator);
    }
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override protected function commitProperties():void
    {
        var changeEvent:IndexChangeEvent;
        
        if (selectedIndexChanged || selectedIndexAdjusted || dataProviderChanged)
        {
            var navigator:ViewNavigatorBase;
            
            // Store the old index
            var oldIndex:int = _selectedIndex;
            
            if (selectedIndex >= length)
                selectedIndex = (length > 0) ? 0 : NO_PROPOSED_SELECTION;
            
            var indexChangedPrevented:Boolean = false;
            // The selected index property can be changed programmitically on the
            // TabbedViewNavigator or by its tab bar in response to a user action.  If
            // this was initiated by the tab bar, a chaning event would have already been
            // dispatched in tabBar_indexChanging().
            if (initialized && selectedIndexChanged && !changingEventDispatched)
            {
                // If the active view's REMOVING event or the navigator's
                // CHANGING event was canceled, prevent the index change
                if (!indexCanChange(selectedIndex))
                {
                    _proposedSelectedIndex = NO_PROPOSED_SELECTION;
                    indexChangedPrevented = true;
                }
            }
            
            changingEventDispatched = false;
            
            if (!indexChangedPrevented)
            {
                // If the data provider has changed, the navigator elements have
                // already been removed, so the following code doesn't need to run
                if (!selectedIndexAdjusted && !dataProviderChanged && _selectedIndex >= 0 && _selectedIndex < length)
                {
                    navigator = getElementAt(_selectedIndex) as ViewNavigatorBase;
                    navigator.setActive(false, !maintainNavigationStack);
                    navigator.visible = false;
                    navigator.includeInLayout = false;
                    
                    if (navigator.activeView)
                        navigator.activeView.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, 
                                                                    view_propertyChangeHandler);
                    
                    removeNavigatorListeners(navigator);
                }
                
                commitSelection();
                
                if (_selectedIndex >= 0)
                {
                    // If there is no focus or the item that had focus isn't 
                    // on the display list anymore, update the focus to be
                    // the active view or the view navigator
                    updateFocus();
                    
                    navigator = getElementAt(_selectedIndex) as ViewNavigatorBase;
                    navigator.setActive(true);
                    navigator.visible = true;
                    navigator.includeInLayout = true;
                    
                    addNavigatorListeners(navigator);
                    
                    // Update the states of the controls on the newly activated view navigator.
                    // The updateControlsForView() method will automatically bubble up to all
                    // parents of the navigator.
                    navigator.updateControlsForView(navigator.activeView);
                    
                    // Force a validation of the new navigator to prevent a flicker from
                    // occurring in cases where multiple validation passes are required
                    // to completely validate a view
                    if (initialized)
                        currentContentGroup.validateNow();
                    
                    if (navigator.activeView)
                    {
                        navigator.activeView.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, 
                                                                view_propertyChangeHandler);
                    }
                }
            
                // Dispatch selection change event
                if (hasEventListener(IndexChangeEvent.CHANGE))
                {
                    changeEvent = new IndexChangeEvent(IndexChangeEvent.CHANGE, false, false);
                    changeEvent.oldIndex = oldIndex;
                    changeEvent.newIndex = _selectedIndex;
                }
            }
            
            selectedIndexAdjusted = false;
            dataProviderChanged = false;
            selectedIndexChanged = false;
        }

        if (tabBarVisibilityChanged)
            commitVisibilityChanges();
        
        // When true, this flag prevents tab bar animations from running.  This flag 
        // is only set to  true if the application received an orientation event this 
        // frame (See ViewNavigatorBase).  The flag is reset at the end of commitProperties 
        // so that animations run again.
        if (disableNextControlAnimation)
            disableNextControlAnimation = false;
        
        // Call base class' commitProperties after the above so that state changes
        // as a result of overlayControls are caught.  This should be okay because
        // TabbedViewNavigator doesn't need any properties in its base class being
        // validated to complete the above code
        super.commitProperties();
        
        // Dispatch the index change event after super.commitProperties() has changed
        // so the callbacks can deal with state changes performed by commitProperties.
        if (changeEvent)
            dispatchEvent(changeEvent);
    }
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function commitSelection():void
    {
        _selectedIndex = _proposedSelectedIndex;
        _proposedSelectedIndex = NO_PROPOSED_SELECTION;
        
        lastSelectedIndex = _selectedIndex;
        
        if (hasEventListener(FlexEvent.VALUE_COMMIT))
            dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }    
    
    /**
     *  @private
     *  Commits the requested visibility changes made to the action
     *  bar and tab bar.
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function commitVisibilityChanges():void
    {
        // Can't change the visibility during a view transition
        if (selectedNavigatorChangingView)
            return;
        
        // If an animation is running, end it
        if (tabBarVisibilityEffect)
            tabBarVisibilityEffect.end();
        
        // Change the visibility of the tabBar if the desired state
        // is different than the current state
        if (tabBar && showingTabBar != tabBar.visible)
        {
            // The animateTabBarVisibility flag is set to true if the
            // hideTabBar() or showTabBar() methods are called with the
            // animate flag set to true
            if (!disableNextControlAnimation && transitionsEnabled && animateTabBarVisbility)
            {
                tabBarProps = {target:tabBar, showing:showingTabBar};
                tabBarVisibilityEffect = showingTabBar ? 
                                         createTabBarShowEffect() :
                                         createTabBarHideEffect();
                
                tabBarVisibilityEffect.addEventListener(EffectEvent.EFFECT_END, 
                                                        visibilityAnimation_effectEndHandler);
                tabBarVisibilityEffect.play();
            }
            else
            {
                // Since the visibility is not being animated, toggle the state
                tabBar.visible = tabBar.includeInLayout = showingTabBar;
                
                if (activeView)
                    activeView.setTabBarVisible(showingTabBar);
            }
        }

        tabBarVisibilityChanged = false;
    }

    /**
     *  Creates the effect to play when the TabBar control is shown.
     *  The produced effect is responsible for animating both the 
     *  TabBar and the content group of the navigator.
     * 
     *  <p>TabbedViewNavigator will expect the <code>includeInLayout</code>
     *  and <code>visible</code> properties of the TabBar to be <code>true</code>
     *  after this effect is run.</p>
     * 
     *  @return An effect to play when the TabBar control appears.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function createTabBarShowEffect():IEffect
    {
        return createTabBarVisibilityEffect(true);
    }
    
    /**
     *  Creates the effect to play when the TabBar control is hidden.
     *  The produced effect is responsible for animating both the 
     *  TabBar and the content group of the navigator.
     * 
     *  <p>TabbedViewNavigator expects the <code>includeInLayout</code>
     *  and <code>visible</code> properties of the TabBar to be <code>false</code>
     *  after this effect runs.</p>
     * 
     *  @return An effect to play when the TabBar control is hidden.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected function createTabBarHideEffect():IEffect
    {
        return createTabBarVisibilityEffect(false);
    }
    
    /**
     *  Creates the animation that will be played when the TabBar is
     *  hidden.
     * 
     *  @return The effect ot play
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function createTabBarVisibilityEffect(showAnimation:Boolean):IEffect
    {
        var effect:IEffect;
        var finalEffect:Parallel = new Parallel();
        
        // Grab initial values
        tabBarProps.start = captureAnimationValues(tabBar);
        contentGroupProps = { start:captureAnimationValues(contentGroup) };
        
        // Update actionBar layout properties
        tabBar.visible = tabBar.includeInLayout = showingTabBar;
        
        // Calculate final positions.  This method will force a validation
        prepareTabBarForAnimation(showAnimation);
        
        var animate:Animate = new Animate();
        animate.target = tabBar;
        animate.duration = TAB_BAR_ANIMATION_DURATION;
        animate.motionPaths = new Vector.<MotionPath>();
        animate.motionPaths.push(new SimpleMotionPath("y", tabBarProps.start.y, tabBarProps.end.y));
        
        effect = animate;
        finalEffect.addChild(effect);
        
        // Create content group animation
        animate = new Animate();
        animate.target = contentGroup;
        animate.duration = TAB_BAR_ANIMATION_DURATION;
        animate.motionPaths = new Vector.<MotionPath>();
        animate.motionPaths.push(new SimpleMotionPath("y", contentGroupProps.start.y, 
                                                           contentGroupProps.end.y));
        animate.motionPaths.push(new SimpleMotionPath("height", contentGroupProps.start.height, 
                                                                contentGroupProps.end.height));
 
        contentGroup.includeInLayout = false;
        
        finalEffect.addChild(animate);
        finalEffect.duration = TAB_BAR_ANIMATION_DURATION;
        return finalEffect;
    }
    
    /**
     *  @private
     */
    private function navigator_elementAddHandler(event:ElementExistenceEvent):void
    {
        event.element.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, 
                                                view_propertyChangeHandler);
    }
    
    /**
     *  @private
     */
    private function navigator_elementRemoveHandler(event:ElementExistenceEvent):void
    {
        event.element.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, 
                                                view_propertyChangeHandler);
    }
    
    /**
     *  @private
     *  Dispatched when a property on a child navigator changed.
     */ 
    private function navigator_propertyChangeHandler(event:PropertyChangeEvent):void
    {
        itemUpdated(event.target, event.property, event.oldValue, event.newValue);
    }
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == tabBar)
        {
            tabBar.addEventListener(IndexChangeEvent.CHANGING, tabBar_indexChanging);
            tabBar.dataGroup.addEventListener(RendererExistenceEvent.RENDERER_ADD, tabBar_elementAddHandler);
            tabBar.dataProvider = this;
            tabBar.requireSelection = true;
        }
    }
    
    /**
     *  @private
     */ 
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == tabBar)
        {
            tabBar.dataGroup.removeEventListener(RendererExistenceEvent.RENDERER_ADD, tabBar_elementAddHandler);
            tabBar.removeEventListener(IndexChangeEvent.CHANGING, tabBar_indexChanging);
            tabBar.dataProvider = null;
        }
    }
    
    /**
     *  @private
     */ 
    override public function loadViewData(value:Object):void
    {
        super.loadViewData(value);
        
        var savedStacks:Vector.<Object>;
        var savedSelectedIndex:Number = value.selectedIndex as Number;
        
        // By the time this method is called, all skin parts should be
        // added to the component meaning that it is okay to directly
        // manipulate the child navigators.
        if (!isNaN(savedSelectedIndex) && savedSelectedIndex < length)
            selectedIndex = savedSelectedIndex;
        
        savedStacks = value.childrenStates as Vector.<Object>;
        
        if (savedStacks)
        {
            var navigator:ViewNavigatorBase;
            var len:Number = Math.min(savedStacks.length, length);
            
            for (var i:int = 0; i < len; i++)
            {
                navigator = getElementAt(i) as ViewNavigatorBase;                
                navigator.loadViewData(savedStacks[i]);
            }
        }
    }
    
    /**
     *  @private
     */
    override public function saveViewData():Object
    {
        var savedData:Object = super.saveViewData();
        var childrenStates:Vector.<Object> = new Vector.<Object>();
            
        for (var i:int = 0; i < length; i++)
            childrenStates.push((getElementAt(i) as ViewNavigatorBase).saveViewData());
            
        if (!savedData)
            savedData = {};
            
        savedData.selectedIndex = selectedIndex;
        savedData.childrenStates = childrenStates;
        
        return savedData;
    }
    
    /**
     *  @private
     *  Redispatches the child navigator's COMPLETE event.
     */ 
    private function navigator_viewChangeCompleteHandler(event:Event):void
    {
        if (hasEventListener("viewChangeComplete"))
            dispatchEvent(event);
        
        selectedNavigatorChangingView = false;
        
        if (tabBar)
            tabBar.mouseEnabled = explicitTabBarMouseEnabled;
    }
    
    /**
     *  @private
     */
    private function navigator_viewChangeStartHandler(event:Event):void
    {
        selectedNavigatorChangingView = true;
        
        // Disable mouse interaction with the tabBar 
        if (tabBar)
        {
            explicitTabBarMouseEnabled = tabBar.mouseEnabled;
            tabBar.mouseEnabled = false;
        }
    }
    
    /**
     *  @private
     */ 
    private function tabBar_elementAddHandler(event:RendererExistenceEvent):void
    {
        event.target.addEventListener(MouseEvent.CLICK, tabBarRenderer_clickHandler);
    }
    
    /**
     *  @private
     *  Determines if the selection of the tab bar can change.
     */ 
    private function tabBar_indexChanging(event:IndexChangeEvent):void
    {
        if (!indexCanChange(event.newIndex))
        {
            event.preventDefault();
            
            // Clear changing flag
            changingEventDispatched = false;
        }
    }
    
    /**
     *  @private
     */ 
    private function elementRemoveHandler(event:ElementExistenceEvent):void
    {
        cleanUpNavigator(event.element as ViewNavigatorBase);
        internalDispatchEvent(CollectionEventKind.REMOVE, event.element, event.index);
        
        // Element removed event is called before the element is removed from the
        // display list.  So if the last navigator is about to be removed, numElements
        // should be 1
        if (numElements == 1)
            selectedIndex = -1;
    }
    
    /**
     *  @private
     */ 
    private function elementAddHandler(event:ElementExistenceEvent):void
    {
        setupNavigator(event.element as ViewNavigatorBase);
        internalDispatchEvent(CollectionEventKind.ADD, event.element, event.index);
        
        // If the added element is the first view navigator, update the selection
        // to point to it
        if (numElements == 1)
            selectedIndex = 0;
    }
    
    /**
     *  @private
     *  Method is called when a tab is clicked by the user.  The default 
     *  implementation checks if the clicked tab is currently selected, and if
     *  so, pops the active navigator to its root view.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    mx_internal function tabBarRenderer_clickHandler(event:MouseEvent):void
    {
        // lastSelectedIndex is used instead of tabBar.selectedIndex
        // because by the time this method is called, the tabBar's
        // proposedSelectedIndex has changed, which causes its selectedIndex
        // method to return the proposed index instead of the currently
        // selected index.
        if ((event.target is IItemRenderer) && 
            (IItemRenderer(event.target).itemIndex == lastSelectedIndex))
        {
            if (selectedNavigator is ViewNavigator)
                ViewNavigator(selectedNavigator).popToFirstView();
        }
    }
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function view_propertyChangeHandler(event:PropertyChangeEvent):void
    {
        if (event.property == "tabBarVisible")
        {
            if (event.newValue)
                showTabBar();
            else
                hideTabBar();
        }
        else if (event.property == "overlayControls")
        {
            overlayControls = event.newValue;
        }
    }
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function visibilityAnimation_effectEndHandler(event:EffectEvent):void
    {
        event.target.removeEventListener(EffectEvent.EFFECT_END, visibilityAnimation_effectEndHandler);
        tabBarVisibilityEffect = null;
        
        if (activeView)
            activeView.setTabBarVisible(tabBarProps.showing);
        
        // Check if the visible and cacheAsBitmap properties have been set.  These are
        // only set if the default transitions are used.  If developers create their
        // own animations, these properties won't be set.
        if (tabBarProps.start != undefined)
        {
            tabBar.visible = tabBar.includeInLayout = tabBarProps.end.visible;
            tabBar.cacheAsBitmap = tabBarProps.start.cacheAsBitmap;
        }
        
        tabBarProps = null;
        
        if (contentGroupProps)
        {
            contentGroup.includeInLayout = contentGroupProps.start.includeInLayout;
            contentGroup.cacheAsBitmap = contentGroupProps.start.cacheAsBitmap;
            
            // The default tab bar hide and show animation will animate the width and height
            // of the navigator's contentGroup.  If the explicitWidth or explicitHeight properties
            // were NaN before the animation, they'll be set to real values by the animation.  As
            // a result, it is necessary to restore them to NaN so that layout properly sizes these
            // components. 
            if (isNaN(contentGroupProps.start.explicitHeight))
                contentGroup.explicitHeight = NaN;
            
            if (isNaN(contentGroupProps.start.explicitWidth))
                contentGroup.explicitWidth = NaN;
            
            if (!isNaN(contentGroupProps.start.percentWidth))
                contentGroup.percentWidth = contentGroupProps.start.percentWidth;
            
            if (!isNaN(contentGroupProps.start.percentHeight))
                contentGroup.percentHeight = contentGroupProps.start.percentHeight;
            
            contentGroupProps = null;
        }
    }
    
    
    //--------------------------------------------------------------------------
    //
    //  Methods: ISelectableList
    //
    //--------------------------------------------------------------------------
    //----------------------------------
    //  selectedIndex
    //----------------------------------
    
    /**
     *  @private
     *  The proposed selected index. This is a temporary variable that is
     *  used until the selected index is committed.
     */
    protected var _proposedSelectedIndex:int = NO_PROPOSED_SELECTION;
    
    /**
     * @private
     * The backing variable for selectedIndex.
     */
    protected var _selectedIndex:int = NO_PROPOSED_SELECTION; 
    
    [Bindable("change")]
    [Bindable("valueCommit")]    
    /**
     *  The 0-based index of the selected view navigator, or -1 if none is selected.
     *  Setting the <code>selectedIndex</code> property deselects the currently selected
     *  navigator and selects the navigator at the specified index.
     *
     *  <p>The value is always between -1 and (<code>navigators.length</code> - 1). 
     *  If items at a lower index than <code>selectedIndex</code> are 
     *  removed from the component, the selected index is adjusted downward
     *  accordingly.</p>
     *
     *  <p>If the selected item is removed, the selected index is set to:</p>
     *
     *  <ul>
     *    <li>-1 if there are no remaining items.</li>
     *    <li><code>selectedIndex</code> - 1 if there is at least one item.</li>
     *  </ul>
     *
     *  @default -1
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get selectedIndex():int
    {
        if (_proposedSelectedIndex != NO_PROPOSED_SELECTION)
            return _proposedSelectedIndex;
        
        return _selectedIndex;
    }
    
    /**
     * @private
     */
    public function set selectedIndex(value:int):void
    {
        if (!dataProviderChanged && value == selectedIndex)
            return;
        
        if (activeView)
            activeView.dispatchEvent(new Event("_navigationChange_"));
        
        _proposedSelectedIndex = value;
        selectedIndexChanged = true;
        
        invalidateProperties();
    }
    
    /**
     *  @private
     *  This method determines the navigator can change its selected index.
     *  This function will be called if the selection changed on the
     *  tab bar, or if the selectedIndex property has changed.
     */ 
    private function indexCanChange(proposedSelection:int):Boolean
    {
        changingEventDispatched = true;
        if (!canRemoveCurrentView())
            return false;
        
        if (hasEventListener(IndexChangeEvent.CHANGING))
        {
            var e:IndexChangeEvent = new IndexChangeEvent(IndexChangeEvent.CHANGING, false, true);
            e.oldIndex = _selectedIndex;
            e.newIndex = proposedSelection;
            
            if (!dispatchEvent(e))
                return false;
        }
        
        return true;
    }
    
    //----------------------------------
    //  length
    //----------------------------------
    
    /**
     *  The number of child view navigators being managed by the 
     *  this component.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get length():int
    {
        return numElements;
    }
    
    /**
     *  Add the specified view navigator to the end of the list.  
     *  Equivalent to calling <code>addItemAt(item, length);</code>. 
     * 
     *  @param item The view navigator  to add.  
     *  It must extend the <code>ViewNavigatorBase</code> class.
     *
     *  @see spark.components.supportClasses.ViewNavigatorBase
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function addItem(item:Object):void
    {
        addItemAt(item, length);
    }
    
    /**
     *  Add the view navigator at the specified index.  
     *  Any view navigator that was after this index is moved down by one.  
     * 
     *  @param item The view navigator  to add.  
     *  It must extend the <code>ViewNavigatorBase</code> class.
     *
     *  @param index The index at which to place the item.
     * 
     *  @throws RangeError If index is less than 0 or greater than the length
     * 
     *  @see spark.components.supportClasses.ViewNavigatorBase
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function addItemAt(item:Object, index:int):void
    {
        // If the added type is not a ViewNavigatorBase, we ignore the call
        // TODO (chiedozi): Consider throwing an exception here
        if (!(item is ViewNavigatorBase))
            return;
        
        if (index < 0 || index > length) 
        {
            var message:String = ResourceManager.getInstance().getString(
                "collections", "outOfBounds", [ index ]);
            throw new RangeError(message);
        }
        
        setupNavigator(ViewNavigatorBase(item));
        addElementAt(ViewNavigatorBase(item), index);

        if (selectedIndex == NO_PROPOSED_SELECTION || numElements == 1)
        {
            selectedIndex = 0;
        }
        else if (index <= selectedIndex)
        {
            selectedIndex++;
            selectedIndexAdjusted = true;
        }
    }
    
    /**
     *  Get the view navigator object at the specified index.
     * 
     *  @param  index The index in the list from which to retrieve the item.
     * 
     *  @param  prefetch Indicating both the direction and amount of items
     *          to fetch during the request, should the item not be local.
     * 
     *  @return The navigator at the specified index, or null if there is none.
     * 
     *  @throws RangeError If the index &lt; 0 or index &gt;= length
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function getItemAt(index:int, prefetch:int = 0):Object
    {
        if (index < 0 || index >= length) 
        {
            var message:String = ResourceManager.getInstance().getString(
                "collections", "outOfBounds", [ index ]);
            throw new RangeError(message);
        }
        
        return getElementAt(index);
    }
    
    /**
     *  Return the index of the view navigator if it is in the list 
     *  of view navigators. 
     * 
     *  @param item The view navigator object to locate.
     *
     *  @return The index of the view navigator, or -1 if the item is not in the list.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function getItemIndex(item:Object):int
    {
        return getElementIndex(item as ViewNavigatorBase);
    }
    
    /**
     *  Notify external components that a property on a view navigator has
     *  been updated.
     *
     *  @param item The view navigator that was updated.
     *
     *  @param property A String, QName, or int
     *  specifying the property that was updated.
     *
     *  @param oldValue The old value of that property.
     *  If property was null, this can be the old value of the item.
     *
     *  @param newValue The new value of that property.
     *  If property was null, there's no need to specify this
     *  as the item is assumed to be the new value.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function itemUpdated(item:Object, property:Object = null, 
                                oldValue:Object = null, 
                                newValue:Object = null):void
    {
        var event:PropertyChangeEvent =
            new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
        
        event.kind = PropertyChangeEventKind.UPDATE;
        event.source = item;
        event.property = property;
        event.oldValue = oldValue;
        event.newValue = newValue;
        
        internalDispatchEvent(CollectionEventKind.UPDATE, event);
    }
    
    /**
     *  Remove all child view navigators from the navigator.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function removeAll():void
    {
        // Deactive the active navigator and its view
        if (selectedNavigator)
            selectedNavigator.setActive(false);
        
        // Remove all navigators
        navigators = null;
    }
    
    /**
     *  Remove the view navigator at the specified index and return it.  
     *  The index of any items that were after this index are decreased by one.
     *
     *  @param index The index from which to remove the item.
     *
     *  @return The item that was removed.
     * 
     *  @throws RangeError If index &lt; 0 or index &gt;= length.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function removeItemAt(index:int):Object
    {
        if (index < 0 || index >= length)
        {
            var message:String = ResourceManager.getInstance().getString(
                "collections", "outOfBounds", [ index ]);
            throw new RangeError(message);
        }
        
        if (index <= selectedIndex)
        {
            selectedIndex--;
            selectedIndexAdjusted = true;
        }
        
        var removed:Object = removeElementAt(index);
        return removed;
    }
    
    /**
     *  Add the view navigator at the specified index.  
     *  If an item was already at that index, the new item replaces it, 
     *  and it is returned.
     *
     *  @param  item The view navigator to place at the index.
     * 
     *  @param  index The index at which to place the navigator.
     * 
     *  @return The navigator that was replaced, or null if none.
     * 
     *  @throws RangeError If index is less than 0 or greater than or equal to length
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function setItemAt(item:Object, index:int):Object
    {
        // If the added type is not a ViewNavigatorBase, we ignore the call
        // TODO (chiedozi): Consider throwing an exception here
        if (!(item is ViewNavigator)) 
            return null;
        
        if (index < 0 || index >= length) 
        {
            var message:String = ResourceManager.getInstance().getString(
                "collections", "outOfBounds", [ index ]);
            throw new RangeError(message);
        }
        
        var oldItem:Object = removeElementAt(index);
        addElementAt(item as ViewNavigatorBase, index);
        
        // Let the navigator know that the item at the selectedIndex changed.
        // The commitProperties method will pick this up.
        if (index == selectedIndex)
        {
            selectedIndexAdjusted = true;
            invalidateProperties();
        }
        
        if (hasEventListener(CollectionEvent.COLLECTION_CHANGE))
        {
            var updateInfo:PropertyChangeEvent;
            
            updateInfo = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
            updateInfo.kind = PropertyChangeEventKind.UPDATE;
            updateInfo.oldValue = oldItem;
            updateInfo.newValue = item;
            updateInfo.property = index;
            
            internalDispatchEvent(CollectionEventKind.REPLACE, updateInfo, index);
        }
        
        return oldItem;
    }
    
    /**
     *  Return an Array that is populated in the same order as the IList
     *  implementation. 
     *
     *  @return The Array.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function toArray():Array
    {
        return contentGroup.getMXMLContent();
    }
    
    /**
     *  @private
     *  Dispatches a collection event with the specified information.
     *
     *  @param kind String indicates what the kind property of the event should be
     *  @param item Object reference to the item that was added or removed
     *  @param location int indicating where in the source the item was added.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function internalDispatchEvent(kind:String, item:Object = null, location:int = -1):void
    {
        if (hasEventListener(CollectionEvent.COLLECTION_CHANGE))
        {
            var event:CollectionEvent =
                new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
            event.kind = kind;
            event.items.push(item);
            event.location = location;
            dispatchEvent(event);
        }
        
        // now dispatch a complementary PropertyChangeEvent
        if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE) && 
            (kind == CollectionEventKind.ADD || kind == CollectionEventKind.REMOVE))
        {
            var objEvent:PropertyChangeEvent =
                new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
            
            objEvent.property = location;
            if (kind == CollectionEventKind.ADD)
                objEvent.newValue = item;
            else
                objEvent.oldValue = item;
            
            dispatchEvent(objEvent);
        }
    }
    
    /** 
     *  @private
     *  If the item is an IEventDispatcher watch it for updates.  
     *  This is called by addItemAt and when the source is initially
     *  assigned.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function startTrackingUpdates(item:Object):void
    {
        if (item && (item is IEventDispatcher))
        {
            IEventDispatcher(item).addEventListener(
                PropertyChangeEvent.PROPERTY_CHANGE, 
                navigator_propertyChangeHandler, false, 0, true);
        }
    }
    
    /** 
     *  @private
     *  If the item is an IEventDispatcher stop watching it for updates.
     *  This is called by removeItemAt, removeAll, and before a new
     *  source is assigned.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function stopTrackingUpdates(item:Object):void
    {
        if (item && item is IEventDispatcher)
        {
            IEventDispatcher(item).removeEventListener(
                PropertyChangeEvent.PROPERTY_CHANGE, 
                navigator_propertyChangeHandler);    
        }
    }
}
}