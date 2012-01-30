package spark.components
{
    import flash.desktop.NativeApplication;
    import flash.display.StageOrientation;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.StageOrientationEvent;
    import flash.net.registerClassAlias;
    import flash.system.Capabilities;
    import flash.ui.Keyboard;
    
    import mx.core.IVisualElement;
    import mx.core.mx_internal;
    import mx.events.FlexEvent;
    import mx.utils.BitFlagUtil;
    
    import spark.components.supportClasses.ViewHistoryData;
    import spark.components.supportClasses.ViewNavigatorSection;
    import spark.core.managers.IPersistenceManager;
    import spark.core.managers.PersistenceManager;
    import spark.events.ElementExistenceEvent;
    import spark.layouts.supportClasses.LayoutBase;

    use namespace mx_internal;
    
    [DefaultProperty("sections")]
    
    //--------------------------------------
    //  Events
    //--------------------------------------
    
    /**
     *  @inheritDoc
     */
    [Event(name="applicationPersist", type="mx.events.FlexEvent")]
    
    /**
     *  @inheritDoc
     */
    [Event(name="applicationPersisting", type="mx.events.FlexEvent")]
    
    /**
     *  @inheritDoc
     */
    [Event(name="applicationRestore", type="mx.events.FlexEvent")]
    
    /**
     *  @inheritDoc
     */
    [Event(name="applicationRestoring", type="mx.events.FlexEvent")]
    
    public class MobileApplication extends Application
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
        private static const SECTIONS_PROPERTY_FLAG:uint = 1 << 7;
        
        //--------------------------------------------------------------------------
        //
        //  Skin Parts
        //
        //--------------------------------------------------------------------------
        
        [SkinPart(required="false")]
        public var navigator:ViewNavigator;
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        public function MobileApplication()
        {
            super();
        }
        
        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------
        
        private var navigatorProperties:Object = {};
        
        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------
        
        //----------------------------------
        //  firstViewData
        //----------------------------------
        /**
         * @private
         */
        private var _firstViewData:Object;
        
        /**
         * This is the initialization data to pass to the
         * root screen when it is created.
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
        //  sessionCachingEnabled
        //----------------------------------
        
        private var _sessionCachingEnabled:Boolean = false;
        
        public function get sessionCachingEnabled():Boolean
        {
            return _sessionCachingEnabled;
        }
        public function set sessionCachingEnabled(value:Boolean):void
        {
            _sessionCachingEnabled = value;
        }
        
        //----------------------------------
        //  persistenceManager
        //----------------------------------
        private var _persistenceManager:IPersistenceManager;
        
        public function get persistenceManager():IPersistenceManager
        {
            return _persistenceManager;
        }
        
        public function set persistenceManager(value:IPersistenceManager):void
        {
            _persistenceManager = value;
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
         *  This property is the object to use to initialize the first view
         *  of the stack.
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
        //  sections
        //----------------------------------
        
        [ArrayElementType("spark.components.supportClasses.ViewNavigatorSection")]
        /**
         *  Returns the stacks vector of the current navigator.
         */
        public function get sections():Vector.<ViewNavigatorSection>
        {
            if (navigator)
                return navigator.sections;
            else
                return navigatorProperties.sections;
        }
        
        /**
         *  @private
         */
        public function set sections(value:Vector.<ViewNavigatorSection>):void
        {
            if (navigator)
            {
                navigator.sections = (value == null) ? value : value.concat();
                navigatorProperties = BitFlagUtil.update(navigatorProperties as uint,
                    SECTIONS_PROPERTY_FLAG, value != null);
            }
            else
                navigatorProperties.sections = (value == null) ? value : value.concat();
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
         *  Layout for the ActionBar's action content group.
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
         *  Layout for the ActionBar navigation content group.
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
         *  
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
        //  Methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *
         */ 
        protected function deviceKeyDownHandler(event:KeyboardEvent):void
        {
            var key:uint = event.keyCode;
            
            // We want to prevent the default down behavior for back key if navigator
            // is at root
            if (key == Keyboard.BACK && navigator.selectedSectionLength > 1)
                event.preventDefault();
        }
        
        /**
         *
         */ 
        protected function deviceKeyUpHandler(event:KeyboardEvent):void
        {
            var key:uint = event.keyCode;
            
            if (key == Keyboard.BACK && navigator.selectedSectionLength > 1)
                navigator.popView();
        }
        
        public function get landscapeOrientation():Boolean
        {
            return systemManager.stage.deviceOrientation == StageOrientation.ROTATED_LEFT ||
                systemManager.stage.deviceOrientation == StageOrientation.ROTATED_RIGHT;
        }
        
        protected function persistViewData(event:Event = null):void
        {
            if (sessionCachingEnabled)
                persistenceManager.setProperty("sectionData", sections);
        }
        
        protected function orientationChangeHandler(event:StageOrientationEvent):void
        {
            if (navigator)
                navigator.landscapeOrientation = landscapeOrientation;
        }
        
        protected function applicationActivateHandler(event:Event):void
        {
        }
        
        protected function applicationDeactivateHandler(event:Event):void
        {
            // This method called on Android when app run in background
            if (sessionCachingEnabled)
            {
                // Dispatch event for saving persistence data
                var eventDispatched:Boolean = true;
                if (hasEventListener(FlexEvent.APPLICATION_PERSISTING))
                    eventDispatched = dispatchEvent(new FlexEvent(FlexEvent.APPLICATION_PERSISTING, false, true));
                
                if (eventDispatched)
                {
                    // Save version number of application
                    var appDescriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
                    var ns:Namespace = appDescriptor.namespace();
                    
                    persistenceManager.setProperty("applicationVersion", appDescriptor.ns::versionNumber.toString());
                    persistenceManager.setProperty("timestamp", new Date().getMilliseconds());
                    persistenceManager.setProperty("selectedSection", navigator.selectedIndex);
                    persistenceManager.setProperty("sectionData", sections);
                    
                    if (navigator.activeView)
                    {
                        navigator.activeView.active = false;
                        navigator.persistCurrentView();
                    }
                    
                    persistenceManager.flush();
                    
                    if (hasEventListener(FlexEvent.APPLICATION_PERSIST))
                        eventDispatched = dispatchEvent(new FlexEvent(FlexEvent.APPLICATION_PERSIST));
                }
            }
        }
        
        //--------------------------------------------------------------------------
        //
        //  Overridden methods: UIComponent
        //
        //--------------------------------------------------------------------------
        
        override public function initialize():void
        {
            super.initialize();
            
            // Add device key listeners
            NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, applicationActivateHandler);
            
            // We need to listen to different events on desktop and mobile because
            // on desktop, the deactivate event is dispatched whenever the window loses
            // focus.  This could cause persistence to run when the developer doesn't
            // expect it to on desktop.
            var os:String = Capabilities.os;
            if (os.indexOf("Windows") != -1 || os.indexOf("Mac OS") != -1)
                NativeApplication.nativeApplication.addEventListener(Event.EXITING, applicationDeactivateHandler);
            else
                NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, applicationDeactivateHandler);
            
            systemManager.stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, orientationChangeHandler);
            systemManager.stage.addEventListener(KeyboardEvent.KEY_DOWN, deviceKeyDownHandler);
            systemManager.stage.addEventListener(KeyboardEvent.KEY_UP, deviceKeyUpHandler);
            
            // Initialize objects related to session-persistence
            if (sessionCachingEnabled)
            {
                // Register aliases for custom classes that will be written to
                // persistence store by navigator
                registerClassAlias("ViewHistoryData", ViewHistoryData);
                registerClassAlias("ViewNavigatorSection", ViewNavigatorSection);
                
                // Create persistence store
                // Note: The shared object has to be loaded AFTER the class aliases are created
                persistenceManager = new PersistenceManager();
                persistenceManager.initialize();
                
                // Dispatch event for loading persistence data
                var eventDispatched:Boolean = true;
                if (hasEventListener(FlexEvent.APPLICATION_RESTORING))
                    eventDispatched = dispatchEvent(new FlexEvent(FlexEvent.APPLICATION_RESTORING, false, true));

                if (eventDispatched)
                {
                    // Load saved sections
                    var savedSections:Vector.<ViewNavigatorSection>;
                    savedSections = persistenceManager.getProperty("sectionData") as Vector.<ViewNavigatorSection>;
                    
                    if (savedSections != null)
                        sections = savedSections;
                    
                    if (persistenceManager.enabled)
                    {
                        var selectedSection:Number = persistenceManager.getProperty("selectedSection") as Number;
                        
                        if (selectedSection && selectedSection > 0 && selectedSection < savedSections.length)
                            navigator.selectedIndex = selectedSection;
                             
                        if (navigator.tabBar)
                            navigator.tabBar.selectedIndex = navigator.selectedIndex;
                    }
                    
                    // Clear previously persisted data
                    persistenceManager.clear();
                    
                    if (hasEventListener(FlexEvent.APPLICATION_RESTORE))
                        eventDispatched = dispatchEvent(new FlexEvent(FlexEvent.APPLICATION_RESTORE));
                }
            }
            
            // If the sections property is not set by this point, MobileApplication will
            // create a default section to be used by the navigator, and initialize it
            // with the firstView and firstViewData defined by the application
            if (sections == null || sections.length == 0)
            {
                // Create the empty screen stack and initialize it with the
                // desired firstView and its data
                var section:ViewNavigatorSection = new ViewNavigatorSection();
                section.firstView = firstView;
                section.firstViewData = firstViewData;
                
                // Set the stacks of the navigator
                var newSections:Vector.<ViewNavigatorSection> = Vector.<ViewNavigatorSection>([section]);
                sections = newSections;
            }
        }
        
        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);
            
            if (instance == navigator)
            {
                var newNavigatorProperties:uint = 0;
                
                if (navigatorProperties.sections != undefined)
                {
                    navigator.sections = navigatorProperties.sections;
                    newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                                                    SECTIONS_PROPERTY_FLAG, true);
                }
                
                if (navigatorProperties.actionContent != undefined)
                {
                    navigator.actionContent = navigatorProperties.actionContent;
                    newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                                                    ACTION_CONTENT_PROPERTY_FLAG, true);
                }
                
                if (navigatorProperties.actionLayout != undefined)
                {
                    navigator.actionLayout = navigatorProperties.actionLayout;
                    newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                        ACTION_LAYOUT_PROPERTY_FLAG, true);
                }
                
                
                if (navigatorProperties.navigationContent != undefined)
                {
                    navigator.navigationContent = navigatorProperties.navigationContent;
                    newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                        NAVIGATION_CONTENT_PROPERTY_FLAG, true);
                }
                
                if (navigatorProperties.navigationLayout != undefined)
                {
                    navigator.navigationLayout = navigatorProperties.navigationLayout;
                    newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                        NAVIGATION_LAYOUT_PROPERTY_FLAG, true);
                }
                
                if (navigatorProperties.title != undefined)
                {
                    navigator.title = navigatorProperties.title;
                    newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                        TITLE_PROPERTY_FLAG, true);
                }
                
                if (navigatorProperties.titleContent != undefined)
                {
                    navigator.titleContent = navigatorProperties.titleContent;
                    newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                        TITLE_CONTENT_PROPERTY_FLAG, true);
                }
                
                if (navigatorProperties.titleLayout != undefined)
                {
                    navigator.titleLayout = navigatorProperties.titleLayout;
                    newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                        TITLE_LAYOUT_PROPERTY_FLAG, true);
                }
                
                navigatorProperties = newNavigatorProperties;
                navigator.landscapeOrientation = landscapeOrientation;
                
                // Set the stage focus to the navigator
                systemManager.stage.focus = navigator;
            }
        }
        
        override protected function partRemoved(partName:String, instance:Object):void
        {
            super.partRemoved(partName, instance);
            
            if (instance == navigator)
            {
                var newNavigatorProperties:Object = {};
                
                if (BitFlagUtil.isSet(navigatorProperties as uint, SECTIONS_PROPERTY_FLAG))
                    newNavigatorProperties.sections = navigator.sections;
                
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
                
                navigatorProperties = newNavigatorProperties;
            }
        }
    }
}