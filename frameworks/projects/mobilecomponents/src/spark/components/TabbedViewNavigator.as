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
import mx.core.ISelectableList;
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
import mx.resources.ResourceManager;

import spark.components.supportClasses.ButtonBarBase;
import spark.components.supportClasses.NavigationStack;
import spark.components.supportClasses.ViewNavigatorBase;
import spark.effects.Move;
import spark.events.ElementExistenceEvent;
import spark.events.IndexChangeEvent;

use namespace mx_internal;

[DefaultProperty("navigators")]

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  
 */
[Event(name="change", type="spark.events.IndexChangeEvent")]

/**
 *  
 */
[Event(name="changing", type="spark.events.IndexChangeEvent")]

/**
 *  
 */
[Event(name="collectionChange", type="mx.events.CollectionEvent")]

/**
 *  
 */
[Event(name="valueCommit", type="mx.events.FlexEvent")]

/**
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
    //  Constants
    //
    //--------------------------------------------------------------------------
    /**
     *  @private
     *  Static constant representing no proposed selection.
     */
    private static const NO_PROPOSED_SELECTION:int = -1;
    
    private static const NO_ACTION:int = -1;
    private static const CHANGE_SECTION_ACTION:int = 0;
    
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
     */
    private var tabBarVisibilityEffect:IEffect;
    
    /**
     *  @private
     */
    private var selectedNavigatorChanged:Boolean = false;
    
    /**
     *  @private
     */ 
    private var tabBarProps:Object;
    
    /**
     *  @private
     */    
    private var tabBarVisibilityInvalidated:Boolean = false;

    /**
     *  @private
     */    
    public var transitionsEnabled:Boolean = true;
    
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
    public function set navigators(value:Vector.<ViewNavigatorBase>):void
    {
        var i:int;
        
        if (_navigators)
        {
            for (i = 0; i < _navigators.length; ++i)
                _navigators[i].parentNavigator = null;
        }
        
        _navigators = value;   
        
        if (value)
        {
            for (i = 0; i < value.length; ++i)
                _navigators[i].parentNavigator = this;
            
            selectedIndex = 0;
        }
        
        selectedNavigatorChanged = true;
    }
    
    //--------------------------------------------------------------------------
    //
    // Public Methods
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  Hides the tab bar of the navigator.
     * 
     *  @param animate Flag indicating whether a hide effect should play.  True by default.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function hideTabBar(animate:Boolean = true):void
    {	
        if (tabBar && tabBar.visible)
        {
            animateTabBarVisbility = animate;
            tabBarVisibilityInvalidated = true;
            invalidateProperties();
        }
        else
        {
            tabBarVisibilityInvalidated = false;
        }
    }
    
    /**
     *  Shows the tab bar of the navigtor
     *  
     *  @param animate Flag indicating whether a hide effect should play.  True by default.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function showTabBar(animate:Boolean = true):void
    {
        if (tabBar && navigators.length > 1 && !tabBar.visible)
        {
            animateTabBarVisbility = animate;
            tabBarVisibilityInvalidated = true;
            invalidateProperties();
        }
        else
        {
            tabBarVisibilityInvalidated = false;
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
    override public function updatePropertiesForView(view:View):void
    {
        if (view)
        {
            tabBar.visible = tabBar.includeInLayout = view.tabBarVisible;
            overlayControls = view.overlayControls;
        }
        else
        {
            tabBar.visible = tabBar.includeInLayout = false;
            overlayControls = false;
        }
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
        validateNow();
        
        // This will store the final location and sizes of the components
        tabBarProps.end = captureAnimationValues(tabBar);
        contentGroupProps.end = captureAnimationValues(contentGroup);
        
        if (tabBarVisibilityInvalidated)
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
            
            tabBar.visible = true;
        }
    }
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    protected function captureAnimationValues(component:UIComponent):Object
    {
        var values:Object = {   y:component.y, 
                                visible: component.visible,
                                includeInLayout: component.includeInLayout,
                                cacheAsBitmap: component.cacheAsBitmap };
        
        return values;
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
        
        // FIXME (chiedozi): Should cancel any queue view changes 
        // of the active view.
        if (selectedNavigatorChanged)
        {
            var navigator:ViewNavigatorBase;
            
            if (_selectedIndex != -1)
            {
                navigator = navigators[_selectedIndex];
                navigator.active = false;
                removeElement(navigator);
                
                navigator.removeEventListener(ElementExistenceEvent.ELEMENT_ADD, navigator_elementAddHandler);
                navigator.removeEventListener(ElementExistenceEvent.ELEMENT_REMOVE, navigator_elementRemoveHandler);
            }
            
            commitSelection();
            
            if (_selectedIndex > -1)
            {
                navigator = navigators[_selectedIndex];
                navigator.active = true;
                navigator.landscapeOrientation = landscapeOrientation;
                
                addElement(navigator);
                navigator.addEventListener(ElementExistenceEvent.ELEMENT_ADD, navigator_elementAddHandler);
                navigator.addEventListener(ElementExistenceEvent.ELEMENT_REMOVE, navigator_elementRemoveHandler);
                
                UIComponent(navigator).invalidateProperties();
            }
            
            selectedNavigatorChanged = false;
        }
        
        if (tabBarVisibilityInvalidated)
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
        
        if (hasEventListener(FlexEvent.VALUE_COMMIT))
            dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
        
        var currentStack:NavigationStack = null; 
        if (_selectedIndex > -1)
            currentStack = navigators[_selectedIndex].navigationStack;

        // FIXME (chiedozi): When a selection changes, old navigator should
        // destory its current view
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
    protected function commitVisibilityChanges():void
    {
        // Can't change the visibility during a view transition
        // FIXME (chiedozi): Shouldn't be able to do this if the child view
        // is animating
//        if (viewChanging)
//        {
//            tabBarVisibilityInvalidated = false;
//            return;
//        }
        
        // If an animation is running, end it
        if (tabBarVisibilityEffect)
            tabBarVisibilityEffect.end();
        
        if (transitionsEnabled && animateTabBarVisbility)
        {
            tabBarVisibilityEffect = createVisibilityAnimation();
            tabBarVisibilityEffect.addEventListener(EffectEvent.EFFECT_END, visibilityAnimation_completeHandler);
            tabBarVisibilityEffect.play();
        }
        else
        {
            if (tabBarVisibilityInvalidated)
                tabBar.visible = tabBar.includeInLayout = !tabBar.visible;
            tabBarVisibilityInvalidated = false;
        }
    }
    
    /**
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function createTabBarVisibilityEffect(hiding:Boolean, props:Object):IEffect
    {
        var effect:Move = new Move();
        
        effect.target = tabBar;
        effect.yFrom = props.start.y;
        effect.yTo = props.end.y;
        
        tabBar.includeInLayout = false;
        tabBar.cacheAsBitmap = true;
        
        return effect;
    }
    
    /**
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
        if (tabBarVisibilityInvalidated)
            tabBar.visible = tabBar.includeInLayout = !tabBarProps.start.visible;
        
        // Calculate final positions.  This method will force a validation
        calculateFinalUIPositions();
        
        // The actionbar will be visible if we are animating it
        if (tabBar.visible)
        {
            effect = createTabBarVisibilityEffect(tabBar.visible, tabBarProps);
            effect.target = tabBar;
            
            finalEffect.addChild(effect);
        }
        
        var moveEffect:Move = new Move();
        moveEffect.target = contentGroup;
        moveEffect.yFrom = contentGroupProps.start.y;
        moveEffect.yTo = contentGroup.y;
        contentGroup.includeInLayout = false;
        contentGroup.cacheAsBitmap = true;
        finalEffect.addChild(moveEffect);
        
        finalEffect.duration = 250;
        return finalEffect;
    }
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function navigator_elementAddHandler(event:ElementExistenceEvent):void
    {
        event.element.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, view_propertyChangeHandler);
    }
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function navigator_elementRemoveHandler(event:ElementExistenceEvent):void
    {
        event.element.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, view_propertyChangeHandler);
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
        if (instance == tabBar)
            tabBar.dataProvider = this;
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
        
        if (tabBarVisibilityInvalidated)
            tabBar.visible = tabBar.includeInLayout = !tabBarProps.start.visible;
        else
            tabBar.includeInLayout = tabBarProps.start.includeInLayout;
        
        // Restore includeInLayout and cacheAsBitmap properties for each component
        contentGroup.includeInLayout = contentGroupProps.start.includeInLayout;
        
        tabBar.cacheAsBitmap = tabBarProps.start.cacheAsBitmap;
        contentGroup.cacheAsBitmap = contentGroupProps.start.cacheAsBitmap;
        
        tabBarVisibilityEffect = null;
        tabBarProps = null;
        contentGroupProps = null;
        
        tabBarVisibilityInvalidated = false;
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
     *  @private
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
    // TODO (chiedozi): Follow ListBase setSelectedIndex pattern
    public function set selectedIndex(value:int):void
    {
        var cancelIndexChange:Boolean = false;
        
        if (value < -1 || value >= length) 
        {
            var message:String = ResourceManager.getInstance().getString(
                "collections", "outOfBounds", [ value ]);
            throw new RangeError(message);
        }
        
        if (!selectedNavigatorChanged && value == selectedIndex)
            return;
        
        // FIXME (chiedozi): Need to be able to cancel this event
//        if (activeView && !canRemoveCurrentView())
//            cancelIndexChange = true;
        
        if (initialized)
        {
            if (hasEventListener(IndexChangeEvent.CHANGING))
            {
                var e:IndexChangeEvent = new IndexChangeEvent(IndexChangeEvent.CHANGING, false, true);
                e.oldIndex = _selectedIndex;
                e.newIndex = value;
                
                if (!dispatchEvent(e))
                    cancelIndexChange = true;
            }
            
            // If the active view's REMOVING event or the navigator's
            // CHANGING event was canceled, prevent the index change
            if (cancelIndexChange)
            {
                _proposedSelectedIndex = NO_PROPOSED_SELECTION;
                return;
            }
        }
        
        _proposedSelectedIndex = value;
        selectedNavigatorChanged = true;
        
        invalidateProperties();
    }
    
    //----------------------------------
    //  length
    //----------------------------------
    
    /**
     *  @private
     */
    public function get length():int
    {
        if (!_navigators)
            return 0;
        
        return _navigators.length;
    }
    
    /**
     *  @private
     */
    public function addItem(item:Object):void
    {
        if (!(item is ViewNavigatorBase)) 
            throw new Error("You can only add ViewNavigatorBase objects");
        
        ViewNavigatorBase(item).parentNavigator = parentNavigator ? parentNavigator : this;
        
        _navigators.push(item);
        internalDispatchEvent(CollectionEventKind.ADD, item, _navigators.length - 1);
    }
    
    /**
     *  @private
     */
    public function addItemAt(item:Object, index:int):void
    {
        if (!(item is ViewNavigatorBase)) 
            throw new Error("You can only add ViewNavigators");
        
        if (index < 0 || index > length) 
        {
            var message:String = ResourceManager.getInstance().getString(
                "collections", "outOfBounds", [ index ]);
            throw new RangeError(message);
        }
        
        ViewNavigatorBase(item).parentNavigator = parentNavigator ? parentNavigator : this;
        _navigators.splice(index, 0, item);
        internalDispatchEvent(CollectionEventKind.ADD, item, index);
    }
    
    /**
     *  @private
     */
    public function getItemAt(index:int, prefetch:int = 0):Object
    {
        if (index < 0 || index >= length) 
        {
            var message:String = ResourceManager.getInstance().getString(
                "collections", "outOfBounds", [ index ]);
            throw new RangeError(message);
        }
        
        return _navigators[index];
    }
    
    /**
     *  @private
     */
    public function getItemIndex(item:Object):int
    {
        return _navigators.indexOf(item);
    }
    
    /**
     *  This method is not supported by ViewNavigator.  Any changes
     *  made to individual views inside a <code>NavigationStack</code>
     *  are ignored.
     */
    public function itemUpdated(item:Object, property:Object = null, 
                                oldValue:Object = null, 
                                newValue:Object = null):void
    {
    }
    
    /**
     *  @private
     */
    public function removeAll():void
    {
        _navigators.length = 0;
        internalDispatchEvent(CollectionEventKind.RESET);
    }
    
    /**
     *  @private
     */
    public function removeItemAt(index:int):Object
    {
        if (index < 0 || index >= length)
        {
            var message:String = ResourceManager.getInstance().getString(
                "collections", "outOfBounds", [ index ]);
            throw new RangeError(message);
        }
        
        var removed:Object = _navigators.splice(index, 1)[0];
        internalDispatchEvent(CollectionEventKind.REMOVE, removed, index);
        
        return removed;
    }
    
    /**
     *  @private
     */
    public function setItemAt(item:Object, index:int):Object
    {
        if (!(item is ViewNavigator)) 
            throw new Error("You can only add NavigationStack to a ViewNavigator");
        
        if (index < 0 || index >= length) 
        {
            var message:String = ResourceManager.getInstance().getString(
                "collections", "outOfBounds", [ index ]);
            throw new RangeError(message);
        }
        
        var oldItem:Object = _navigators[index];
        _navigators[index] = item as ViewNavigatorBase;
        
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
     *  @private
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
    }
}
}