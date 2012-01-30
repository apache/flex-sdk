package spark.components
{
import flash.events.Event;

import mx.core.ISelectableList;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;
import mx.events.PropertyChangeEventKind;
import mx.resources.ResourceManager;

import spark.components.supportClasses.ViewHistoryData;
import spark.components.supportClasses.ViewNavigatorSection;
import spark.effects.IViewTransition;
import spark.events.IndexChangeEvent;
import spark.layouts.supportClasses.LayoutBase;

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

//--------------------------------------
//  SkinStates
//--------------------------------------

/**
 *  
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("portrait")]

/**
 *  
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("landscape")]

/**
 *  
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("portraitAndOverlay")]

/**
 *  
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("landscapeAndOverlay")]

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
    private static const CHANGE_SECTION_ACTION:int = 2;
    
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
    public var defaultPushTransition:IViewTransition;
    
    [SkinPart(required="false")]
    public var defaultPopTransition:IViewTransition;
    
    //--------------------------------------------------------------------------
    //
    // Variables
    // 
    //--------------------------------------------------------------------------
    
    /**
     *
     */
    private var currentViewData:ViewHistoryData = null;
    
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
    private var pendingViewData:ViewHistoryData = null;
    
    /**
     *
     */ 
    private var pendingViewTransition:IViewTransition = null;
    
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
    
    mx_internal function get selectedSection():ViewNavigatorSection
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
    
    private var _overlayMode:String;
    
    public function get overlayMode():String
    {
        return _overlayMode;
    }
    
    public function set overlayMode(value:String):void
    {
        if (value != _overlayMode)
        {
            _overlayMode = value;
            invalidateSkinState();
        }
    }
    
    //----------------------------------
    //  sections
    //----------------------------------
    
    protected var _sections:Vector.<ViewNavigatorSection> = null;
    
    [ArrayElementType("spark.components.supportClasses.ViewNavigatorSection")]
    /**
     *  The collection of <code>ViewNavigatorSection</code> objects
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
		currentViewChanged = true;
		selectedSectionChanged = true;
		
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
        
		internalDispatchEvent(CollectionEventKind.RESET);
		
		if (tabBar)
			tabBar.visible = tabBar.includeInLayout = (_sections != null && _sections.length > 1);
		
		// Changing the section always forces a validation to happened immediately
		if (initialized)
        	validateNow();
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
        
        if (!selectedSectionChanged && value == selectedIndex)
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
    
    //----------------------------------
    //  transitionsEnabled
    //----------------------------------
    private var _transitionsEnabled:Boolean = true;
    
    public function get transitionsEnabled():Boolean
    {
        return _transitionsEnabled;
    }
    
    /**
     *  @private
     */
    public function set transitionsEnabled(value:Boolean):void
    {
        _transitionsEnabled = value;
    }
    
    //----------------------------------
    //  useDefaultTransitions
    //----------------------------------
    private var _useDefaultTransitions:Boolean = true;
    
    public function get useDefaultTransitions():Boolean
    {
        return _useDefaultTransitions;
    }
    
    /**
     *  @private
     */
    public function set useDefaultTransitions(value:Boolean):void
    {
        _useDefaultTransitions = value;
    }
    
    //--------------------------------------------------------------------------
    //
    // Public Methods
    // 
    //--------------------------------------------------------------------------
    
    public function popAll(transition:IViewTransition = null):void
    {
        if (currentSection.length == 0 || !canRemoveCurrentView())
            return;
             
        lastAction = POP_ACTION;
        
        pendingViewTransition = transition;
        if (pendingViewTransition == null && useDefaultTransitions)
            pendingViewTransition = defaultPopTransition;
        
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
    
    public function popView(transition:IViewTransition = null):void
    {
        if (currentSection.length == 0 || !canRemoveCurrentView())
            return;
        
        lastAction = POP_ACTION;
        
        pendingViewTransition = transition;
        if (pendingViewTransition == null && useDefaultTransitions)
            pendingViewTransition = defaultPopTransition;
        
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
    
    public function popToFirstView(transition:IViewTransition = null):void
    {
        if (currentSection.length < 2 || !canRemoveCurrentView())
            return;
        
        lastAction = POP_ACTION;
        
        pendingViewTransition = transition;
        if (pendingViewTransition == null && useDefaultTransitions)
            pendingViewTransition = defaultPopTransition;
        
        currentSection.popToFirstView();
        
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
                             transition:IViewTransition = null):void
    {
        if (!canRemoveCurrentView())
            return;
        
        lastAction = PUSH_ACTION;
        
        pendingViewTransition = transition;
        if (pendingViewTransition == null && useDefaultTransitions)
            pendingViewTransition = defaultPushTransition;
        
        currentSection.push(viewFactory, initializationData);
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
     *  actionContent when this view is active.
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
        actionContentInvalidated = true;
        
        invalidateProperties();
    }
    
    //----------------------------------
    //  actionGroupLayout
    //----------------------------------
    
    /**
     *  Layout for the ActionBar's action content group.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private var _actionGroupLayout:LayoutBase;
    private var actionGroupLayoutInvalidated:Boolean = false;
    
    public function get actionGroupLayout():LayoutBase
    {
        return _actionGroupLayout;
    }
    /**
     *  @private
     */
    public function set actionGroupLayout(value:LayoutBase):void
    {
        _actionGroupLayout = value;
        actionGroupLayoutInvalidated = true;
        
        invalidateProperties();
    }
    
    //----------------------------------
    //  navigationContent
    //----------------------------------
    
    private var _navigationContent:Array;
    private var navigationContentInvalidated:Boolean = false;
    
    [ArrayElementType("mx.core.IVisualElement")]
    /**
     *  Array of visual elements that are used as the ActionBar's
     *  navigationContent when this view is active.
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
        navigationContentInvalidated = true;
        
        invalidateProperties();
    }
    
    //----------------------------------
    //  navigationGroupLayout
    //----------------------------------
    
    /**
     *  Layout for the ActionBar navigation content group.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private var _navigationGroupLayout:LayoutBase;
    private var navigationGroupLayoutInvalidated:Boolean = false;
    
    public function get navigationGroupLayout():LayoutBase
    {
        return _navigationGroupLayout;
    }
    /**
     *  @private
     */
    public function set navigationGroupLayout(value:LayoutBase):void
    {
        _navigationGroupLayout = value;
        navigationGroupLayoutInvalidated = true;
        
        invalidateProperties();
    }
    
    //----------------------------------
    //  title
    //----------------------------------
    
    private var _title:String;
    private var titleInvalidated:Boolean = false;
    
    [Bindable]
    /**
     *  
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
            titleInvalidated = true;
            
            invalidateProperties();
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
     *  titleContent when this view is active.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
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
        titleContentInvalidated = true;
            
        invalidateProperties();
    }
    
    //----------------------------------
    //  titleGroupLayout
    //----------------------------------
    
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
    private var _titleGroupLayout:LayoutBase;
    private var titleGroupLayoutInvalidated:Boolean = false;
    
    public function get titleGroupLayout():LayoutBase
    {
        return _titleGroupLayout;
    }
    /**
     *  @private
     */
    public function set titleGroupLayout(value:LayoutBase):void
    {
        _titleGroupLayout = value;
        titleGroupLayoutInvalidated = true;
        
        invalidateProperties();
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
    
    /**
     *  This method checks if the current view can be removed
     *  from the display list.
     * 
     *  @return Returns true if the screen can be removed
     */
    protected function canRemoveCurrentView():Boolean
    {
        var view:View;
        
        if (!currentViewData)
            return true;

        view = currentViewData.instance;
        return (view == null || view.canRemove);
    }
    
    override protected function commitProperties():void
    {
        // If the sections property is not set by this point, ViewNavigator will
        // create a default section to be used by the navigator, and initialize it
        // with the firstView and firstViewData defined by the application
        if (sections == null || sections.length == 0)
        {
            // TODO: ViewNavigator should have a firstView and rootData convenience property
            // Create the empty screen stack and initialize it with the
            // desired firstView and initial data
            var section:ViewNavigatorSection = new ViewNavigatorSection();
            section.firstView = null;
            section.firstViewData = null;
            
            // Set the stacks of the navigator
            var newSections:Vector.<ViewNavigatorSection> = Vector.<ViewNavigatorSection>([section]);
            sections = newSections;
        }
            
        if (currentViewChanged)
            executeViewChange();
        else
            updateActionBarProperties(activeView);
        
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
            currentSection.push(currentSection.firstView, currentSection.firstViewData);
        
        pendingViewTransition = null;
        return true;
    }
    
    protected function endViewChange():void
    {
        var currentView:View;
        
        if (currentViewData)
        {
            currentView = currentViewData.instance;
            
            currentView.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, view_propertyChangeHandler);
            removeElement(currentView);
            
            // FIXME (chiedozi): Figure out how to use focus manager to manage focus
            // when a component in the current view has focus.
            stage.focus = null;
            
            // Grab the data from the old view and persist it
            if (lastAction == PUSH_ACTION || lastAction == CHANGE_SECTION_ACTION)
            {
                // TODO (chiedozi): Should not be automatically persisting
                currentViewData.data = currentView.data;
                currentViewData.persistedData = currentView.getPersistenceData();
            }
            
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

        if (currentViewData)
        {
            currentView = currentViewData.instance;
            
            if (currentView)
            {
                currentView.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, view_propertyChangeHandler);
                
                currentViewData.persistedData = currentView.getPersistenceData();
                currentView.active = true;
                
            }
        }
        
        // Restore mouse children properties before revalidation occurs
        mouseChildren = explicitMouseChildren;
        mouseEnabled = explicitMouseEnabled;
        
        if (revalidateWhenComplete)
        {
            revalidateWhenComplete = false;
            currentViewChanged = true;
            executeViewChange();
        }
        
        
        lastAction = NO_ACTION;
        viewChanging = false;
        
        // Notify listeners that the view change is complete
        if (hasEventListener(Event.COMPLETE))
            dispatchEvent(new Event(Event.COMPLETE));
    }
    
    protected function executeViewChange():void
    {
        // Private event used for performance tests
        if (hasEventListener("viewChangeStart"))
            dispatchEvent(new Event("viewChangeStart"));
        
        if (selectedSectionChanged)
        {
            commitSelection();
            selectedSectionChanged = false;
        }
        
        beginViewChange();
        
        if (currentSection)
            pendingViewData = currentSection.topView;
        
        if (pendingViewData && pendingViewData.factory != null)
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
            
            addElement(view);
        }
        
        // Put this before viewAdded() so another validation pass won't cause this to happen
        currentViewChanged = false; 
        viewAdded(transitionsEnabled ? pendingViewTransition : null);
        pendingViewTransition = null;
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
    
    // Only current because previous views are already persisted
    mx_internal function persistCurrentView():void
    {
        if (currentViewData && currentViewData.instance)
            currentViewData.persistedData = currentViewData.instance.getPersistenceData();
    }
    
    protected function viewAdded(transition:IViewTransition = null):void
    {
        var currentView:View;
        var pendingView:View;
        
        // Deactivate the current view
        if (currentViewData)
        {
            currentView = currentViewData.instance;
            currentView.active = false;
            currentView.includeInLayout = false;
            
            // Need to validateNow() to make sure our old screen is currently 
            // up to date before starting the transition and possibly storing a bitmap 
            // for the transition
            currentView.validateNow();
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
        
        // Invalidate the actionBar properties
        if (actionBar)
            updateActionBarProperties(pendingView, true);
        
        // Need to validate my children now to prevent flicker when no transition,
        // or so sizes can be measured before transition
        validateNow();
        
        // Run transition
        if (transition)
        {
            // Notify listeners that a new view has been successfully added to the stage
            if (hasEventListener("transitionStart"))
                dispatchEvent(new Event("transitionStart", false, false));
            
            transition.play();
        }
        else
        {
            endViewChange();
        }
    }

    override protected function getCurrentSkinState():String
    {
        return null;    
    }
    
    protected function transitionComplete(event:Event):void
    {
        IViewTransition(event.target).removeEventListener(Event.COMPLETE, transitionComplete);
        
        // Notify listeners that a new view has been successfully added to the stage
        if (hasEventListener("transitionEnd"))
            dispatchEvent(new Event("transitionEnd", false, false));
        
        endViewChange();
    }
    
    protected function updateActionBarProperties(view:View, forceUpdate:Boolean = false):void
    {
        if (!actionBar)
            return;
 
        // If there is no view, update the actionBar should display the 
        // navigator defaults
        if (view == null)
        {
            actionBar.actionContent = actionContent;
            actionBar.actionGroupLayout = actionGroupLayout;
            actionBar.navigationContent = navigationContent;
            actionBar.navigationGroupLayout = navigationGroupLayout;
            actionBar.title = title;
            actionBar.titleContent = titleContent;
            actionBar.titleGroupLayout = titleGroupLayout;
        }
        else if (forceUpdate)
        {
            actionBar.actionContent = view && view.actionContent ? view.actionContent : actionContent;
            actionBar.actionGroupLayout = view && view.actionGroupLayout ? view.actionGroupLayout : actionGroupLayout;
            actionBar.navigationContent = view && view.navigationContent ? view.navigationContent : navigationContent;
            actionBar.navigationGroupLayout = view && view.navigationGroupLayout ? view.navigationGroupLayout : navigationGroupLayout;
            actionBar.title = view && view.title ? view.title : title;
            actionBar.titleContent = view && view.titleContent ? view.titleContent : titleContent;
            actionBar.titleGroupLayout = view && view.titleGroupLayout ? view.titleGroupLayout : titleGroupLayout;
            
            actionContentInvalidated = false;
            actionGroupLayoutInvalidated = false;
            navigationContentInvalidated = false;
            navigationGroupLayoutInvalidated = false;
            titleInvalidated = false;
            titleContentInvalidated = false;
            titleGroupLayoutInvalidated = false;
        }
        else
        {
            if (actionContentInvalidated)
            {
                actionBar.actionContent = view && view.actionContent ? 
                    view.actionContent : actionContent;
                actionContentInvalidated = false;
            }
            
            if (actionGroupLayoutInvalidated)
            {
                actionBar.actionGroupLayout = view && view.actionGroupLayout ? 
                    view.actionGroupLayout : actionGroupLayout;
                actionGroupLayoutInvalidated = false;
            }
            
            if (navigationContentInvalidated)
            {
                actionBar.navigationContent = view && view.navigationContent ? 
                    view.navigationContent : navigationContent;
                navigationContentInvalidated = false;
            }
            
            if (navigationGroupLayoutInvalidated)
            {
                actionBar.navigationGroupLayout = view && view.navigationGroupLayout ? 
                    view.navigationGroupLayout : navigationGroupLayout;
                navigationGroupLayoutInvalidated = false;
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
            
            if (titleGroupLayoutInvalidated)
            {
                actionBar.titleGroupLayout = view && view.titleGroupLayout ? 
                    view.titleGroupLayout : titleGroupLayout;
                titleGroupLayoutInvalidated = false;
            }        
        }
    }
    
    /**
     *
     */ 
    protected function view_propertyChangeHandler(event:PropertyChangeEvent):void
    {
        var property:Object = event.property;
        
        // Check for actionBar related property changes
        if (actionBar)
        {
            if (property == "title")
                titleInvalidated = true;
            else if (property == "titleContent")
                titleContentInvalidated = true;
            else if (property == "titleGroupLayout")
                titleGroupLayoutInvalidated = true;
            else if (property == "actionContent")
                actionContentInvalidated = true;
            else if (property == "actionGroupLayout")
                actionGroupLayoutInvalidated  = true;
			else if (property == "navigationContent")
				navigationContentInvalidated = true;
			else if (property == "navigationGroupLayout")
				navigationGroupLayoutInvalidated  = true;
            
            invalidateProperties();
        }
    }
    
    
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        // Tab bar should only be visible only if there is more than 1 section
        if (instance == tabBar && sections)
            tabBar.visible = tabBar.includeInLayout = sections.length > 1;
        
        // If the actionBar changes, need to reset the properties on it
        if (instance == actionBar)
        {
            actionContentInvalidated = true;
            actionGroupLayoutInvalidated = true;
            navigationContentInvalidated = true;
            navigationGroupLayoutInvalidated = true;
            titleInvalidated = true;
            titleContentInvalidated = true;
            titleGroupLayoutInvalidated = true;
            
            invalidateProperties();   
        }
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
            throw new Error("You can only add ViewNavigatorSections to a ViewNavigator");
        
        _sections.push(item);
        internalDispatchEvent(CollectionEventKind.ADD, item, _sections.length - 1);
    }
    
    /**
     *  @inheritDoc
     */
    public function addItemAt(item:Object, index:int):void
    {
        if (!(item is ViewNavigatorSection)) 
            throw new Error("You can only add ViewNavigatorSections to a ViewNavigator");
        
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
     *  This method is not supported by ViewNavigator.  Any changes
     *  made to individual views inside a <code>ViewNavigatorSection</code>
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
            throw new Error("You can only add ViewNavigatorSection to a ViewNavigator");
        
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