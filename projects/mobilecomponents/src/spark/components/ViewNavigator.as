package spark.components
{
import flash.events.Event;

import mx.core.ISelectableList;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;
import mx.events.PropertyChangeEventKind;
import mx.resources.ResourceManager;

import spark.components.supportClasses.ViewData;
import spark.components.supportClasses.ViewNavigatorSection;
import spark.effects.SlideViewTransition;
import spark.effects.ViewTransition;
import spark.events.IndexChangeEvent;
import spark.events.NavigatorEvent;
import spark.events.ViewNavigatorEvent;

use namespace mx_internal;

[DefaultProperty("sections")]

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  @inherit
 */
[Event(name="changing", type="spark.events.IndexChangeEvent")]

/**
 *  Dispatched when the IList has been updated in some way.
 *  
 *  @eventType mx.events.CollectionEvent.COLLECTION_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="collectionChange", type="mx.events.CollectionEvent")]

// FIXME (chiedozi): Figure out valueCommit and change event pattern
/**
 * 
 */
[Event(name="valueCommit", type="mx.events.FlexEvent")]

/**
 *  Dispatched when a new view has been added to the display
 *  list.
 * 
 *  @eventType spark.events.NavigatorEvent.ADD
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="viewAdd", type="spark.events.NavigatorEvent")]

/**
 *  Dispatched when a view has been removed from the display
 *  list.
 * 
 *  @eventType spark.events.NavigatorEvent.REMOVE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="viewRemove", type="spark.events.NavigatorEvent")]

/**
 * 
 */
public class ViewNavigator extends SkinnableContainer implements ISelectableList
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
    private static const PUSH_ACTION:int = 0;
    private static const POP_ACTION:int = 1;
    private static const REPLACE_ACTION:int = 2;
    private static const CHANGE_SECTION_ACTION:int = 3;
    
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
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function ViewNavigator()
    {
        super();
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
    public var tabBar:ButtonBar;
    
    [SkinPart(required="false")]
    public var actionBar:ActionBar;
    
    [SkinPart(required="false")]
    public var viewContainer:Group;
    
    //--------------------------------------------------------------------------
    //
    // Variables
    // 
    //--------------------------------------------------------------------------
    
    /**
     *
     */
    private var currentViewData:ViewData = null;
    
    /**
     *
     */
    private var currentViewChanged:Boolean = false;
    
    /**
     * @private
     * This following property stores the <code>mouseEnabled</code>
     * value defined on the navigator so that it can be
     * restored after a view transition.
     */
    private var explicitMouseEnabled:Boolean;
    
    /**
     * @private
     * This following property stores the <code>mouseChildren</code>
     * value defined on the navigator so that it can be
     * restored after a view transition.
     */
    private var explicitMouseChildren:Boolean;
    
    /**
     *
     */
    protected var lastAction:int = NO_ACTION;
    
    /**
     *
     */ 
    private var pendingViewData:ViewData = null;
    
    /**
     *
     */ 
    private var pendingViewTransition:ViewTransition = null;
    
    /**
     *
     */
    private var revalidateWhenComplete:Boolean = false;
    
    /**
     *
     */
    private var selectedSectionChanged:Boolean = false;
    
    //----------------------------------
    //  selectedSection
    //----------------------------------
    
    public function get selectedSection():ViewNavigatorSection
    {
        if (selectedIndex == -1)
            return null;
        
        return _sections[selectedIndex];
    }
    
    //----------------------------------
    //  selectedSectionLength
    //----------------------------------
    
    /**
     *  The length of the currently selected section.
     *
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectedSectionLength():int
    {
        return currentSection.length;	
    }
    
    private var viewChanging:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    // Properties
    // 
    //--------------------------------------------------------------------------

    //----------------------------------
    //  activeView
    //----------------------------------
    
    public function get activeView():View
    {
        if (currentViewData)
            return currentViewData.instance;
        
        return null;
    }
    
    //----------------------------------
    //  currentSection
    //----------------------------------
    
    /**
     *  The currently selected section.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private function get currentSection():ViewNavigatorSection
    {
        if (_sections == null)
            return null;
        
        if (_sections.length > 0)
            return _sections[selectedIndex];
        
        return null;
    }
    
    //----------------------------------
    //  length
    //----------------------------------

    /**
     *  @inheritDoc
     */
    public function get length():int
    {
        if (!_sections)
            return 0;
        
        return _sections.length;
    }
    
    //----------------------------------
    //  sections
    //----------------------------------
    
    protected var _sections:Vector.<ViewNavigatorSection> = null;
    
    [ArrayElementType("spark.components.supportClasses.ViewNavigatorSection")]
    /**
     *  The collection of <code>ScreenStack</code> objects
     *  being managed by the navigator.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get sections():Vector.<ViewNavigatorSection>
    {
        return _sections ? _sections.concat() : null;
    }
    
    /**
     * @private
     */
    public function set sections(value:Vector.<ViewNavigatorSection>):void
    {
        if (value)
        {
            _sections = value.concat();
            selectedIndex = 0;
        }
        else
        {
            _sections = null;
            selectedIndex = -1;
        }
        
        currentViewChanged = true;
        selectedSectionChanged = true;
        invalidateProperties();
        
        if (tabBar)
            tabBar.visible = tabBar.includeInLayout = (_sections != null && _sections.length > 1);
    }
    
    
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
    protected var _selectedIndex:int = -1; 
    
    
    [Bindable("change")]
    [Bindable("valueCommit")]
    /**
     *  @inheritDoc
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
        if (value < -1 || value >= length) 
        {
            var message:String = ResourceManager.getInstance().getString(
                "collections", "outOfBounds", [ value ]);
            throw new RangeError(message);
        }
        
        if (value == selectedIndex)
            return;
        
        
        if (hasEventListener(IndexChangeEvent.CHANGING))
        {
            var e:IndexChangeEvent = new IndexChangeEvent(IndexChangeEvent.CHANGING, false, true);
            e.oldIndex = _selectedIndex;
            e.newIndex = value;
            
            if (!dispatchEvent(e))
            {
                // The event was cancelled. Cancel the selection change and return.
                _proposedSelectedIndex = NO_PROPOSED_SELECTION;
                return;
            }
        }
        
        _proposedSelectedIndex = value;
        currentViewChanged = true;
        selectedSectionChanged = true;
        lastAction = CHANGE_SECTION_ACTION;
        
        // If a validation pass is in progress, we need to revalidate when the
        // transition is complete
        if (viewChanging)
            revalidateWhenComplete = true;
        else
            invalidateProperties();
    }
    
    //--------------------------------------------------------------------------
    //
    // Public Methods
    // 
    //--------------------------------------------------------------------------
    
    public function popAll(transition:ViewTransition = null):void
    {
        if (currentSection.length == 0)
            return;
        
        lastAction = POP_ACTION;
        pendingViewTransition = transition ? transition : 
            new SlideViewTransition(400, SlideViewTransition.SLIDE_RIGHT);
        
        currentSection.clear();
        
        if (viewChanging)
        {
            revalidateWhenComplete = true;
        }
        else
        {
            currentViewChanged = true;
            invalidateProperties();
        }
    }
    
    public function popView(transition:ViewTransition = null):void
    {
        if (currentSection.length == 0)
            return;
        
        lastAction = POP_ACTION;
        pendingViewTransition = transition ? transition : 
            new SlideViewTransition(400, SlideViewTransition.SLIDE_RIGHT);
        
        currentSection.pop();
        
        if (viewChanging)
        {
            revalidateWhenComplete = true;
        }
        else
        {
            currentViewChanged = true;
            invalidateProperties();
        }
    }
    
    public function popToRoot(transition:ViewTransition = null):void
    {
        if (currentSection.length < 2)
            return;
        
        lastAction = POP_ACTION;
        pendingViewTransition = transition ? transition : 
            new SlideViewTransition(400, SlideViewTransition.SLIDE_RIGHT);
        
        currentSection.popToRoot();
        
        if (viewChanging)
        {
            revalidateWhenComplete = true;
        }
        else
        {
            currentViewChanged = true;
            invalidateProperties();
        }
    }
    
    public function pushView(viewFactory:Class, 
                             initializationData:Object = null,
                             transition:ViewTransition = null):void
    {
        lastAction = PUSH_ACTION;
        
        var newViewData:ViewData = new ViewData();
        newViewData.data = initializationData;
        newViewData.factory = viewFactory;
        pendingViewTransition = transition ? transition : 
            new SlideViewTransition(400, SlideViewTransition.SLIDE_LEFT);
        
        currentSection.push(newViewData);
        currentViewChanged = true;
        
        if (viewChanging)
        {
            revalidateWhenComplete = true;
        }
        else
        {
            currentViewChanged = true;
            invalidateProperties();
        }
    }
    
    public function replaceCurrentView(viewFactory:Class,
                                       initializationData:Object = null,
                                       transition:ViewTransition = null):void
    {
        if (currentSection.length > 0)
            currentSection.pop();
        
        pushView(viewFactory, initializationData, transition);
        
        pendingViewTransition = null;
        lastAction = REPLACE_ACTION;
    }
    
    //--------------------------------------------------------------------------
    //
    // Private Methods
    // 
    //--------------------------------------------------------------------------
    
    protected function beginViewChange():void
    {
        viewChanging = true;
        
        explicitMouseChildren = mouseChildren;
        explicitMouseEnabled = mouseEnabled;
        
        mouseEnabled = false;
        mouseChildren = false;
    }
    
    override protected function commitProperties():void
    {
        executeViewChange();
        
        super.commitProperties();
    }
    
    protected function commitSelection():Boolean
    {
        _selectedIndex = _proposedSelectedIndex;
        _proposedSelectedIndex = NO_PROPOSED_SELECTION;
        
        if (hasEventListener(FlexEvent.VALUE_COMMIT))
            dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
        
        // Check if we need to push the root view
        if (currentSection && currentSection.length == 0)
            currentSection.push(new ViewData(currentSection.rootScreen, currentSection.initialData));
        
        return true;
    }
    
    protected function endViewChange():void
    {
        if (currentViewData)
        {
            var currentView:View = currentViewData.instance;
            removeElement(currentView);
            
            // FIXME (chiedozi): Figure out how to use focus manager to manage focus
            // when a component in the current view has focus.
            stage.focus = null;
            
            // Grab the data from the old view and persist it
            if (lastAction == PUSH_ACTION || lastAction == CHANGE_SECTION_ACTION)
            {
                currentViewData.data = currentView.data;
                currentViewData.persistedData = currentView.getPersistenceData();
            }
            
            // Notify listeners that the current view will be removed
            if (hasEventListener(ViewNavigatorEvent.VIEW_REMOVE))
                dispatchEvent(new ViewNavigatorEvent(ViewNavigatorEvent.VIEW_REMOVE, false, false, currentView));
            
            // Check if we can delete the reference for the view instance
            if (lastAction == POP_ACTION || currentView.destructionPolicy == "auto")
            {
                currentView.navigator = null;
                currentViewData.instance = null;
            }
        }

        // Update view pointers
        currentViewData = pendingViewData;
        pendingViewData = null;
        
        if (revalidateWhenComplete)
        {
            revalidateWhenComplete = false;
            currentViewChanged = true;
            executeViewChange();
        }
        else
        {
            if (currentViewData)
            {
                currentViewData.instance.active = true;
                currentViewData.persistedData = currentViewData.instance.getPersistenceData();
            }
        }
        
        mouseChildren = explicitMouseChildren;
        mouseEnabled = explicitMouseEnabled;
        
        lastAction = NO_ACTION;
        viewChanging = false;
        
        // Notify listeners that the view change is complete
        if (hasEventListener(Event.COMPLETE))
            dispatchEvent(new Event(Event.COMPLETE));
    }
    
    protected function executeViewChange():void
    {
        if (currentViewChanged)
        {
            if (selectedSectionChanged)
            {
                commitSelection();
                selectedSectionChanged = false;
            }
            
            beginViewChange();
            
            if (currentSection)
                pendingViewData = currentSection.top;
            
            if (pendingViewData)
            {
                var view:View;
                
                if (pendingViewData.instance == null)
                {
                    view = new pendingViewData.factory();
                    pendingViewData.instance = view;
                }
                else
                {
                    view = pendingViewData.instance;
                }
                
                // Restore persistence data if necessary
                if (pendingViewData.data == null && pendingViewData.persistedData != null)
                    pendingViewData.data = view.deserializePersistenceData(pendingViewData.persistedData);
                
                view.navigator = this;
                view.data = pendingViewData.data;
                
                // TODO: I Needed an event that occurred before view was added to the display list
                // so that I could change its orientation state in MobileApplication.  Otherwise, it would
                // happen later.  Would it be a problem if this happened on viewAdded?
                // Notify listeners that a new view has been successfully initialized but not added to stage
                if (hasEventListener(ViewNavigatorEvent.VIEW_INITIALIZED))
                    dispatchEvent(new ViewNavigatorEvent(ViewNavigatorEvent.VIEW_INITIALIZED, false, false, view, pendingViewTransition));
                
                addElement(view);
            }
            
            // Put this before viewAdded() so another validation pass won't cause this to happen
            currentViewChanged = false; 
            viewAdded(pendingViewTransition);
            pendingViewTransition = null;
        }            
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    
    // Only current because previous screens are already persisted
    public function persistCurrentView():void
    {
        if (currentViewData && currentViewData.instance)
            currentViewData.persistedData = currentViewData.instance.getPersistenceData();
    }
    
    protected function viewAdded(transition:ViewTransition = null):void
    {
        var currentView:View;
        var pendingView:View;
        
        // Deactivate the current view
        if (currentViewData)
        {
            currentView = currentViewData.instance;
            currentView.active = false;
            currentView.includeInLayout = false;
        }
        
        // Store new view
        if (pendingViewData)
            pendingView = pendingViewData.instance;
        
        if (transition)
        {
            transition.addEventListener(Event.COMPLETE, transitionComplete);
            transition.currentView = currentView;
            transition.nextView = pendingView;
            transition.navigator = this;
            
            // Give the transition a chance to prepare before the view updates
            transition.prepare();
        }
        
        // Notify listeners that a new view has been successfully added to the stage
        if (hasEventListener(ViewNavigatorEvent.VIEW_ADD))
            dispatchEvent(new ViewNavigatorEvent(ViewNavigatorEvent.VIEW_ADD, false, false, pendingView, transition));
        
        // Need to validate my children now to prevent flicker when no transition,
        // or so sizes can be measured before transition
        validateNow();
        
        // Run transition
        if (transition)
        {
            transition.play();
        }
        else
        {
            endViewChange();
        }
    }
    
    protected function transitionComplete(event:Event):void
    {
        ViewTransition(event.target).removeEventListener(Event.COMPLETE, transitionComplete);
        
        endViewChange();
    }
    
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == tabBar && sections)
            tabBar.visible = tabBar.includeInLayout = sections.length > 1;
    }
    
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods: ISelectableList
    //
    //--------------------------------------------------------------------------
    /**
     *  @inheritDoc
     */
    public function addItem(item:Object):void
    {
        if (!(item is ViewNavigatorSection)) 
            throw new Error("You can only add ScreenStacks to a ViewNavigator");
        
        _sections.push(item);
        internalDispatchEvent(CollectionEventKind.ADD, item, _sections.length - 1);
    }
    
    /**
     *  @inheritDoc
     */
    public function addItemAt(item:Object, index:int):void
    {
        if (!(item is ViewNavigatorSection)) 
            throw new Error("You can only add ScreenStacks to a ViewNavigator");
        
        if (index < 0 || index > length) 
        {
            var message:String = ResourceManager.getInstance().getString(
                "collections", "outOfBounds", [ index ]);
            throw new RangeError(message);
        }
        
        _sections.splice(index, 0, item);
        internalDispatchEvent(CollectionEventKind.ADD, item, index);
    }
    
    /**
     *  @inheritDoc
     */
    public function getItemAt(index:int, prefetch:int = 0):Object
    {
        if (index < 0 || index >= length) 
        {
            var message:String = ResourceManager.getInstance().getString(
                "collections", "outOfBounds", [ index ]);
            throw new RangeError(message);
        }
        
        return _sections[index];
    }
    
    /**
     *  @inheritDoc
     */
    public function getItemIndex(item:Object):int
    {
        return _sections.indexOf(item);
    }
    
    /**
     *  This method is not supported by ScreenNavigator.  Any changes
     *  made to individual screens inside a <code>ScreenStack</code>
     *  are ignored.
     */
    public function itemUpdated(item:Object, property:Object = null, 
                                oldValue:Object = null, 
                                newValue:Object = null):void
    {
    }
    
    /**
     *  @inheritDoc
     */
    public function removeAll():void
    {
        _sections.length = 0;
        internalDispatchEvent(CollectionEventKind.RESET);
    }
    
    /**
     *  @inheritDoc
     */
    public function removeItemAt(index:int):Object
    {
        if (index < 0 || index >= length)
        {
            var message:String = ResourceManager.getInstance().getString(
                "collections", "outOfBounds", [ index ]);
            throw new RangeError(message);
        }
        
        var removed:Object = _sections.splice(index, 1)[0];
        internalDispatchEvent(CollectionEventKind.REMOVE, removed, index);
        
        return removed;
    }
    
    /**
     *  @inheritDoc
     */
    public function setItemAt(item:Object, index:int):Object
    {
        if (!(item is ViewNavigatorSection)) 
            throw new Error("You can only add ScreenStacks to a ViewNavigator");
        
        if (index < 0 || index >= length) 
        {
            var message:String = ResourceManager.getInstance().getString(
                "collections", "outOfBounds", [ index ]);
            throw new RangeError(message);
        }
        
        var oldItem:Object = _sections[index];
        _sections[index] = item as ViewNavigatorSection;
        
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
     *  @inheritDoc
     */
    public function toArray():Array
    {
        var n:int = _sections.length;
        var arraySource:Array = new Array(n);
        
        for (var i:int = 0; i < n; i++)
        {
            arraySource[i] = _sections[i];
        }
        
        return arraySource;
    }
}
}