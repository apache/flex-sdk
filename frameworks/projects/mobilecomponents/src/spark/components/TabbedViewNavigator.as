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
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;

import mx.core.ContainerCreationPolicy;
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
import spark.core.ContainerDestructionPolicy;
import spark.effects.Animate;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.events.ElementExistenceEvent;
import spark.events.IndexChangeEvent;
import spark.events.RendererExistenceEvent;

use namespace mx_internal;

[DefaultProperty("navigators")]

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the selected navigator has changed as a result of
 *  the <code>selectedIndex</code> property or the selected
 *  tab changing.
 *  
 */
[Event(name="change", type="spark.events.IndexChangeEvent")]

/**
 *  A cancelable event that is dispatched before the selected navigator
 *  is changed.  Canceling this event will prevent the active navigator
 *  from changing.
 */
[Event(name="changing", type="spark.events.IndexChangeEvent")]

/**
 *  Dispatched when the collection of navigators managed by the
 *  TabbedViewNavigator changes.
 */
[Event(name="collectionChange", type="mx.events.CollectionEvent")]

/**
 *  Dispatched when the navigator's selected index has changed.  When
 *  this event is dispatched, the selectedIndex and activeNavigator
 *  properties will be referencing the newly selected navigator.
 * 
 *  @eventType mx.events.FlexEvent 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="valueCommit", type="mx.events.FlexEvent")]

/**
 *  The TabbedViewNavigator component is a container that manages a collection
 *  of view navigator controls that are stacked on top of each other.  Only
 *  one navigator is active and visible at a time.  This component includes
 *  a TabBar interface control that provides the ability to toggle between
 *  the collection of navigators.  
 * 
 *  <p>The active or selected navigator can be changed by clicking the corresponding
 *  tab in the TabBar or by changing the <code>selectedIndex</code> property of
 *  the component.</p>
 * 
 *  <p>The contents of a child navigator is destroyed when it is deactivate, 
 *  and dynamically created when activated.  This logic can be altered by accessing 
 *  the <code>creationPolicy</code> property of the TabbedViewNavigator and the 
 * <code>destructionPolicy</code> property of its child navigators and active View.</p>
 * 
 *  @see spark.components.View
 *  @see spark.components.ViewNavigator
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
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
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function TabbedViewNavigator()
    {
        super();
        
        _navigators = new Vector.<ViewNavigatorBase>();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    [SkinPart(required="false")]
    /**
     *  A skin part that defines the tab bar of the navigator. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    
    //--------------------------------------------------------------------------
    //
    // Properties
    // 
    //--------------------------------------------------------------------------

    //----------------------------------
    //  activeView
    //----------------------------------
    
    /**
     *  @private
     */
    override public function get activeView():View
    {
        if (activeNavigator)
            return activeNavigator.activeView;
        
        return null;
    }
    
    //----------------------------------
    //  activeNavigator
    //----------------------------------
    
    /**
     *  Returns the active navigator for the TabbedViewNavigator.  Only one
     *  navigator can be active at a time.  The active navigator can be
     *  set by changing the <code>selectedIndex</code> property or by
     *  clicking on a tab.
     * 
     *  @return The active navigator
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    public function get activeNavigator():ViewNavigatorBase
    {
        if (!navigators || length == 0 || selectedIndex < 0) 
            return null;
        
        return navigators[selectedIndex];
    }
    
    //----------------------------------
    //  canCancelBackKeyBehavior
    //----------------------------------
    
    /**
     *  @private
     */ 
    override public function get canCancelBackKeyBehavior():Boolean
    {
        return  activeNavigator && activeNavigator.canCancelBackKeyBehavior;    
    }
    
    //----------------------------------
    //  landscapeOrientation
    //----------------------------------
    
    /**
     *  @private
     */ 
    override public function set landscapeOrientation(value:Boolean):void
    {
        super.landscapeOrientation = value;
        
        if (activeNavigator)
            activeNavigator.landscapeOrientation = value;
    }
    
    //----------------------------------
    //  navigators
    //----------------------------------
    
    private var _navigators:Vector.<ViewNavigatorBase>;
    
    /**
     *  The view navigators that are managed by the the TabbedViewNavigator.
     *  Each navigator isrepresented as a tab in this components tab bar.
     *  Only one navigator can be active at a time, and can be referenced using
     *  the <code>activeNavigator</code> property.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get navigators():Vector.<ViewNavigatorBase>
    {
        return _navigators;
    }
    
    /**
     *  @private
     */ 
    // FIXME (chiedozi): Part of restructuring setSelectedIndex and adjustIndex
    public function set navigators(value:Vector.<ViewNavigatorBase>):void
    {
        var i:int;
        var navigator:ViewNavigatorBase;
        
        // These flags are updated at the beginning of the method so
        // that the selectedIndex setter doesn't ignore passed in value
        dataProviderChanged = true;
        invalidateProperties();
        
        // Clean up and remove all the previous navigators from the display list
        if (_navigators)
        {
            for (i = 0; i < _navigators.length; ++i)
            {
                navigator = _navigators[i];
                
                cleanUpNavigator(navigator);
                removeElement(navigator);
            }
        }
        
        _navigators = value ? value.concat() : null;
        
        if (value)
        {
            for (i = 0; i < value.length; ++i)
            {
                navigator = _navigators[i];
                setupNavigator(navigator);
                addElement(navigator);
            }
        }
       
        if (value && value.length > 0)
            selectedIndex = 0;
        else
            selectedIndex = NO_PROPOSED_SELECTION;
        
        // Notify listeners that the collection changed
        internalDispatchEvent(CollectionEventKind.RESET);
    }
    
    //--------------------------------------------------------------------------
    //
    // Public Methods
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  Hides the tab bar of the navigator.
     * 
     *  @param animate Flag indicating whether a hide effect should play.
     *  This property is <code>true</code> by default.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
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
     *  @param animate Flag indicating whether a hide effect should play.
     *  This property is <code>true</code> by default.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
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
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function updatePropertiesForView(view:View):void
    {
        super.updatePropertiesForView(view);
        
        if (view)
        {
            tabBar.visible = tabBar.includeInLayout = view.tabBarVisible;
            overlayControls = view.overlayControls;
        }
        else
        {
            // If the current view is null, the tab bar is shown so that the
            // user still has a ui for changing the selected tab.
            tabBar.visible = tabBar.includeInLayout = true;
            overlayControls = false;
        }

        tabBarVisibilityChanged = false;
    }
    
    //--------------------------------------------------------------------------
    //
    // Private Methods
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */ 
    override public function backKeyHandler():void
    {
        if (activeNavigator)
            activeNavigator.backKeyHandler();    
    }
    
    /**
     *  @private
     *  Calculates the final positions for the tab bar visibility animations.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function calculateFinalUIPositions():void
    {
        var animateTabBarUp:Boolean;
        
        if (overlayControls)
            animateTabBarUp = (tabBar.y + (tabBar.height / 2)) <= height / 2;
        else
            animateTabBarUp = tabBar.y <= contentGroup.y;
        
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
    }
    
    /**
     *  @private
     */
    override public function canRemoveCurrentView():Boolean
    {
        return (!activeNavigator || activeNavigator.canRemoveCurrentView());
    }
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    private function captureAnimationValues(component:UIComponent):Object
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
     *  @private
     */ 
    private function setupNavigator(navigator:ViewNavigatorBase):void
    {
        navigator.setParentNavigator(this);
        navigator.visible = false;

        // All navigators should be inactive when initialized.  The proper
        // navigator will be activated during commitProperties().
        navigator.setActive(false);
        
        startTrackingUpdates(navigator);

        // TODO (chiedozi): Consider moving this to ViewNavigator or refactoring
        // Create the top view of the navigator if the creationPolicy
        // property indicates that all children should be created.
        if (creationPolicy == ContainerCreationPolicy.ALL)
            navigator.createTopView();
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
        
        navigator.removeEventListener(ElementExistenceEvent.ELEMENT_ADD, 
            navigator_elementAddHandler);
        navigator.removeEventListener(ElementExistenceEvent.ELEMENT_REMOVE, 
            navigator_elementRemoveHandler);
        
        stopTrackingUpdates(navigator);
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
        
        // FIXME (chiedozi): Should cancel any queued view changes of the active view navigator.
        if (selectedIndexChanged || dataProviderChanged)
        {
            var navigator:ViewNavigatorBase;
            
            // Store the old index
            var oldIndex:int = _selectedIndex;
            
            // If the data provider has changed, the navigator elements have
            // already been removed, so the following code doesn't need to run
            if (!selectedIndexAdjusted && !dataProviderChanged && _selectedIndex >= 0)
            {
                navigator = navigators[_selectedIndex];
                navigator.setActive(false);
                navigator.visible = false;
                
                if (navigator.activeView)
                    navigator.activeView.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, 
                                                                view_propertyChangeHandler);
                
                navigator.removeEventListener(ElementExistenceEvent.ELEMENT_ADD, navigator_elementAddHandler);
                navigator.removeEventListener(ElementExistenceEvent.ELEMENT_REMOVE, navigator_elementRemoveHandler);
            }
            
            commitSelection();
            
            if (_selectedIndex >= 0)
            {
                navigator = navigators[_selectedIndex];
                
                navigator.addEventListener(ElementExistenceEvent.ELEMENT_ADD, navigator_elementAddHandler);
                navigator.addEventListener(ElementExistenceEvent.ELEMENT_REMOVE, navigator_elementRemoveHandler);
                
                navigator.landscapeOrientation = landscapeOrientation;
                navigator.setActive(true);
                navigator.visible = true;

                // FIXME (chiedozi): Why do i need to validate here
                // Force a validation of the new navigator to prevent a flicker from
                // occurring since the view will be rendered this frame
                navigator.validateNow();
                
                if (navigator.activeView)
                {
                    updatePropertiesForView(navigator.activeView);
                    navigator.activeView.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, 
                                                            view_propertyChangeHandler);
                    
                    // Force the stage focus to be the activated view
                    systemManager.stage.focus = activeView;
                }
            }
            
            // Dispatch selection change event
            if (hasEventListener(IndexChangeEvent.CHANGE))
            {
                var e:IndexChangeEvent = new IndexChangeEvent(IndexChangeEvent.CHANGE, false, false);
                e.oldIndex = oldIndex;
                e.newIndex = _selectedIndex;
                
                dispatchEvent(e);
            }
            
            selectedIndexAdjusted = false;
            dataProviderChanged = false;
            selectedIndexChanged = false;
        }
        
        if (tabBarVisibilityChanged)
            commitVisibilityChanges();
    }
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
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
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function commitVisibilityChanges():void
    {
        // Can't change the visibility during a view transition
        // FIXME (chiedozi): Shouldn't be able to do this if the child view is animating
        
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
            if (transitionsEnabled && animateTabBarVisbility)
            {
                tabBarVisibilityEffect = createVisibilityAnimation();
                tabBarVisibilityEffect.addEventListener(EffectEvent.EFFECT_END, 
                    visibilityAnimation_completeHandler);
                tabBarVisibilityEffect.play();
            }
            else
            {
                // Since the visibility is not being animated, toggle the state
                tabBar.visible = tabBar.includeInLayout = showingTabBar;
            }
        }

        tabBarVisibilityChanged = false;
    }
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function createTabBarVisibilityEffect(hiding:Boolean, props:Object):IEffect
    {
        var animate:Animate = new Animate();
        animate.target = tabBar;
        animate.duration = TAB_BAR_ANIMATION_DURATION;
        animate.motionPaths = new Vector.<MotionPath>();
        animate.motionPaths.push(new SimpleMotionPath("y", props.start.y, props.end.y));
        
        tabBar.includeInLayout = false;
        tabBar.cacheAsBitmap = true;
        
        return animate;
    }
    
    /**
     *  Creates the animation that will be played when the TabBar is
     *  hidden.
     * 
     *  @return The effect ot play
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function createVisibilityAnimation():IEffect
    {
        var effect:IEffect;
        var finalEffect:Parallel = new Parallel();
        
        // Grab initial values
        tabBarProps = { start:captureAnimationValues(tabBar) };
        contentGroupProps = { start:captureAnimationValues(contentGroup) };
        
        // Update actionBar layout properties
        tabBar.visible = tabBar.includeInLayout = showingTabBar;
        
        // Calculate final positions.  This method will force a validation
        calculateFinalUIPositions();
        
        effect = createTabBarVisibilityEffect(tabBar.visible, tabBarProps);
        effect.target = tabBar;
        tabBar.visible = true;
        finalEffect.addChild(effect);
        
        var animate:Animate = new Animate();
        animate.target = contentGroup;
        animate.duration = TAB_BAR_ANIMATION_DURATION;
        animate.motionPaths = new Vector.<MotionPath>();
        animate.motionPaths.push(new SimpleMotionPath("y", contentGroupProps.start.y, 
                                                           contentGroupProps.end.y));
        animate.motionPaths.push(new SimpleMotionPath("height", contentGroupProps.start.height, 
                                                                contentGroupProps.end.height));
 
        contentGroup.includeInLayout = false;
        contentGroup.cacheAsBitmap = true;  
        
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
    override public function restoreViewData(value:Object):void
    {
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
            var len:Number = Math.min(savedStacks.length, length);
            for (var i:int = 0; i < len; ++i)
                navigators[i].restoreViewData(savedStacks[i]);
        }
    }
    
    /**
     *  @private
     */
    override public function saveViewData():Object
    {
        var savedData:Object = super.saveViewData();
        
        if (navigators)
        {
            var childrenStates:Vector.<Object> = new Vector.<Object>();
            
            for (var i:int = 0; i < navigators.length; ++i)
                childrenStates.push(navigators[i].saveViewData());
            
            if (!savedData)
                savedData = {};
            
            savedData.selectedIndex = selectedIndex;
            savedData.childrenStates = childrenStates;
        }
        
        return savedData;
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
            event.preventDefault();
    }
    
    /**
     *  Method is called when a tab is clicked by the user.  The default 
     *  implementation checks if the clicked tab is currently selected, and if
     *  so, pops the active navigator to its root view.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function tabBarRenderer_clickHandler(event:MouseEvent):void
    {
        // lastSelectedIndex is used instead of tabBar.selectedIndex
        // because by the time this method is called, the tabBar's
        // proposedSelectedIndex has changed, which causes its selectedIndex
        // method to return the proposed index instead of the currently
        // selected index.
        if ((event.target is IItemRenderer) && 
            (IItemRenderer(event.target).itemIndex == lastSelectedIndex))
        {
            if (activeNavigator is ViewNavigator)
                ViewNavigator(activeNavigator).popToFirstView();
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
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function visibilityAnimation_completeHandler(event:EffectEvent):void
    {
        event.target.removeEventListener(EffectEvent.EFFECT_END, visibilityAnimation_completeHandler);

        tabBar.visible = tabBar.includeInLayout = tabBarProps.end.visible;
        tabBar.cacheAsBitmap = tabBarProps.start.cacheAsBitmap;
        
        contentGroup.includeInLayout = contentGroupProps.start.includeInLayout;
        contentGroup.cacheAsBitmap = contentGroupProps.start.cacheAsBitmap;
        
        tabBarVisibilityEffect = null;
        tabBarProps = null;
        contentGroupProps = null;
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
     *  The 0-based index of the selected navigator, or -1 if no item is selected.
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
     *  @playerversion Flash 10.1
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
    // FIXME (chiedozi): Follow ListBase setSelectedIndex pattern
    public function set selectedIndex(value:int):void
    {
        if (value < -1 || value >= length) 
        {
            var message:String = ResourceManager.getInstance().getString(
                "collections", "outOfBounds", [ value ]);
            throw new RangeError(message);
        }
        
        if (!dataProviderChanged && value == selectedIndex)
            return;
        
        // TODO (chiedozi): Add comment about how you can be in here via progromattic setting 
        // of selectedIndex through a tab navigator change and how the changingEventDispatched 
        // is the gating factor there
        if (initialized && !changingEventDispatched)
        {
            // If the active view's REMOVING event or the navigator's
            // CHANGING event was canceled, prevent the index change
            if (!indexCanChange(value))
            {
                _proposedSelectedIndex = NO_PROPOSED_SELECTION;
                return;
            }
        }
        
        _proposedSelectedIndex = value;
        selectedIndexChanged = true;
        changingEventDispatched = false;
        
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
     *  Returns the number of child navigators being managed by the 
     *  this component.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get length():int
    {
        if (!_navigators)
            return 0;
        
        return _navigators.length;
    }
    
    /**
     *  Add the specified item to the end of the list.  Equivalent to 
     *  addItemAt(item, length); 
     * 
     *  @param item The item to add.  Must extend <code>ViewNavigatorBase</code>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function addItem(item:Object):void
    {
        addItemAt(item, length);
    }
    
    /**
     *  Add the item at the specified index.  
     *  Any item that was after this index is moved out by one.  
     * 
     *  @param item the item to place at the index.  Must extend <code>ViewNavigatorBase</code>
     *  @param index the index at which to place the item
     *  @throws RangeError if index is less than 0 or greater than the length
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    // FIXME (chiedozi): Do a separate code path.  Should only dispatch value_commit.
    public function addItemAt(item:Object, index:int):void
    {
        // FIXME (chiedozi): Resource manager
        if (!(item is ViewNavigatorBase)) 
            throw new Error("Objects added to TabbedViewNavigator must extend ViewNavigatorBase.");
        
        if (index < 0 || index > length) 
        {
            var message:String = ResourceManager.getInstance().getString(
                "collections", "outOfBounds", [ index ]);
            throw new RangeError(message);
        }
        
        navigators.splice(index, 0, item);
                    
        setupNavigator(ViewNavigatorBase(item));
        addElementAt(ViewNavigatorBase(item), index);
        
        // FIXME (chiedozi): I feel that this is wrong, shouldn't dispatch this before
        // updating my selection
        internalDispatchEvent(CollectionEventKind.ADD, item, index);
        
        // FIXME (chiedozi): When there is no selectedIndex, this call results in
        // selectedIndex being called 3 times...
        if (selectedIndex == NO_PROPOSED_SELECTION)
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
     *  Get the navigator object at the specified index.
     * 
     *  @param  index the index in the list from which to retrieve the item
     *  @param  prefetch int indicating both the direction and amount of items
     *          to fetch during the request should the item not be local.
     *  @return the navigator at that index, null if there is none
     *  @throws RangeError if the index &lt; 0 or index &gt;= length
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
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
        
        return navigators[index];
    }
    
    /**
     *  Return the index of the navigator if it is in the list such that
     *  getItemAt(index) == item.  
     *  Note that in this implementation the search is linear and is therefore 
     *  O(n).
     * 
     *  @param item the navigator to find
     *  @return the index of the navigator, -1 if the item is not in the list.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function getItemIndex(item:Object):int
    {
        return navigators.indexOf(item);
    }
    
    /**
     *  Notify external components that a property on a navigator has
     *  been updated.
     *
     *  @param item The navigator that was updated.
     *
     *  @param property A String, QName, or int
     *  specifying the property that was updated.
     *
     *  @param oldValue The old value of that property.
     *  (If property was null, this can be the old value of the item.)
     *
     *  @param newValue The new value of that property.
     *  (If property was null, there's no need to specify this
     *  as the item is assumed to be the new value.)
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function itemUpdated(item:Object, property:Object = null, 
                                oldValue:Object = null, 
                                newValue:Object = null):void
    {
        // FIXME (chiedozi): For some reason this gets dispatched twice
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
     *  Remove all child navigators from the navigator.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function removeAll():void
    {
        var item:IVisualElement;
        var len:int = length;
        
        // Deactive the active navigator and its view
        if (activeNavigator)
            activeNavigator.setActive(false);
        
        for (var i:int = 0; i < len; i++)
        {
            item = _navigators[i];
            cleanUpNavigator(ViewNavigatorBase(item));
            removeElement(item);
        }
        
        navigators.length = 0;
        selectedIndex = NO_PROPOSED_SELECTION;
        dataProviderChanged = true;
        
        invalidateProperties();
        
        internalDispatchEvent(CollectionEventKind.RESET);
    }
    
    /**
     *  Remove the navigator at the specified index and return it.  
     *  Any items that were after this index are now one index earlier.
     *
     *  @param index The index from which to remove the item.
     *  @return The item that was removed.
     *  @throws RangeError if index &lt; 0 or index &gt;= length.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
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
        
        var removed:Object = _navigators.splice(index, 1)[0];

        cleanUpNavigator(ViewNavigatorBase(removed));
        removeElement(IVisualElement(removed));
                
        internalDispatchEvent(CollectionEventKind.REMOVE, removed, index);
        
        return removed;
    }
    
    /**
     *  Place the navigator at the specified index.  
     *  If an item was already at that index the new item will replace it and it 
     *  will be returned.
     *
     *  @param  item the navigator to place at the index
     *  @param  index the index at which to place the navigator
     *  @return the navigator that was replaced, null if none
     *  @throws RangeError if index is less than 0 or greater than or equal to length
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function setItemAt(item:Object, index:int):Object
    {
        // FIXME (chiedozi): Resource manager
        if (!(item is ViewNavigator)) 
            throw new Error("Objects added to TabbedViewNavigator must extend ViewNavigatorBase.");
        
        if (index < 0 || index >= length) 
        {
            var message:String = ResourceManager.getInstance().getString(
                "collections", "outOfBounds", [ index ]);
            throw new RangeError(message);
        }
        
        var oldItem:Object = _navigators[index];
        _navigators[index] = item as ViewNavigatorBase;
        
        cleanUpNavigator(ViewNavigatorBase(oldItem));
        setupNavigator(ViewNavigatorBase(item));
        
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
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function toArray():Array
    {
        var n:int = _navigators.length;
        var arraySource:Array = new Array(n);
        
        for (var i:int = 0; i < n; i++)
        {
            arraySource[i] = _navigators[i];
        }
        
        return arraySource;
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
     *  @playerversion Flash 10.1
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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