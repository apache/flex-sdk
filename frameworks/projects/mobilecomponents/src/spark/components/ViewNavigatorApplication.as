package spark.components
{
    import flash.desktop.NativeApplication;
    import flash.display.StageOrientation;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.StageOrientationEvent;
    import flash.net.registerClassAlias;
    
    import mx.core.IVisualElement;
    import mx.core.mx_internal;
    import mx.utils.BitFlagUtil;
    
    import spark.components.supportClasses.ViewData;
    import spark.components.supportClasses.ViewNavigatorSection;
    import spark.core.managers.IPersistenceManager;
    import spark.core.managers.PersistenceManager;
    import spark.events.ViewNavigatorEvent;
    import spark.layouts.supportClasses.LayoutBase;

    use namespace mx_internal;
    
    [DefaultProperty("sections")]
    
    //--------------------------------------
    //  Events
    //--------------------------------------
    
    /**
     *  @inherit
     */
    [Event(name="applicationRestore", type="flash.events.Event")]
    
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
        //  initialData
        //----------------------------------
        /**
         * @private
         */
        private var _initialData:Object;
        
        /**
         * This is the initialization data to pass to the
         * root screen when it is created.
         */
        public function get initialData():Object
        {
            return _initialData;
        }
        
        /**
         * @private
         */
        public function set initialData(value:Object):void
        {
            _initialData = value;
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
        //  rootView
        //----------------------------------
        /**
         *  @private
         *  The backing variable for the rootView property.
         */
        private var _rootView:Class;
        
        /**
         *  This property is the object to use to initialize the root screen
         *  of the stack.  This can be a Class, instance or Factory that creates
         *  an object that extends <code>Screen</code>.
         */
        public function get rootView():Class
        {
            return _rootView;
        }
        
        /**
         * @private
         */
        public function set rootView(value:Class):void
        {
            _rootView = value;
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
        public function get actionGroupLayout():LayoutBase
        {
            if (navigator)
                return navigator.actionGroupLayout;
            else
                return navigatorProperties.actionGroupLayout;
        }
        /**
         *  @private
         */
        public function set actionGroupLayout(value:LayoutBase):void
        {
            if (navigator)
            {
                navigator.actionGroupLayout = value;
                navigatorProperties = BitFlagUtil.update(navigatorProperties as uint, 
                                            ACTION_LAYOUT_PROPERTY_FLAG, value != null);
            }
            else
                navigatorProperties.actionGroupLayout = value;
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
        
        public function get navigationGroupLayout():LayoutBase
        {
            if (navigator)
                return navigator.navigationGroupLayout;
            else
                return navigatorProperties.navigationGroupLayout;
        }
        /**
         *  @private
         */
        public function set navigationGroupLayout(value:LayoutBase):void
        {
            if (navigator)
            {
                navigator.navigationGroupLayout = value;
                navigatorProperties = BitFlagUtil.update(navigatorProperties as uint, 
                    NAVIGATION_LAYOUT_PROPERTY_FLAG, value != null);
            }
            else
                navigatorProperties.navigationGroupLayout = value;
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
        public function get titleGroupLayout():LayoutBase
        {
            if (navigator)
                return navigator.titleGroupLayout;
            else
                return navigatorProperties.titleGroupLayout;
        }
        /**
         *  @private
         */
        public function set titleGroupLayout(value:LayoutBase):void
        {
            if (navigator)
            {
                navigator.titleGroupLayout = value;
                navigatorProperties = BitFlagUtil.update(navigatorProperties as uint, 
                    NAVIGATION_LAYOUT_PROPERTY_FLAG, value != null);
            }
            else
                navigatorProperties.titleGroupLayout = value;
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
            if (key == 94 && navigator.selectedSectionLength > 1)
                event.preventDefault();
        }
        
        /**
         *
         */ 
        protected function deviceKeyUpHandler(event:KeyboardEvent):void
        {
            var key:uint = event.keyCode;
            
            if (key == 94 && navigator.selectedSectionLength > 1)
                navigator.popView();
        }
        
        public function get isLandscape():Boolean
        {
            return systemManager.stage.orientation == StageOrientation.ROTATED_LEFT ||
                systemManager.stage.orientation == StageOrientation.ROTATED_RIGHT;
        }
        
        protected function persistViewData(event:Event = null):void
        {
            if (sessionCachingEnabled)
                persistenceManager.setProperty("sectionData", sections);
        }
        
        
        protected function navigator_viewAddHandler(event:ViewNavigatorEvent):void
        {
            var view:View = event.view;
            
            if (view)
                view.setCurrentState(view.getCurrentViewState(isLandscape), false);
        }
        
        protected function orientationChangingHandler(event:StageOrientationEvent):void
        {
            
        }
        
        protected function orientationChangeHandler(event:StageOrientationEvent):void
        {
            navigator.activeView.setCurrentState(navigator.activeView.getCurrentViewState(isLandscape), false);
        }
        
        protected function applicationActivateHandler(event:Event):void
        {
        }
        
        protected function applicationDeactivateHandler(event:Event):void
        {
            // This method called on Android when app run in background
            if (sessionCachingEnabled)
            {
                persistenceManager.setProperty("selectedSection", navigator.selectedIndex);
                navigator.persistCurrentView();
                persistenceManager.flush();
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
            NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, applicationDeactivateHandler);
            NativeApplication.nativeApplication.addEventListener(Event.EXITING, applicationDeactivateHandler);
            
            systemManager.stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGING, orientationChangingHandler);
            systemManager.stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, orientationChangeHandler);
            systemManager.stage.addEventListener(KeyboardEvent.KEY_DOWN, deviceKeyDownHandler);
            systemManager.stage.addEventListener(KeyboardEvent.KEY_UP, deviceKeyUpHandler);
            
            // Initialize objects related to session-persistence
            if (sessionCachingEnabled)
            {
                // Register aliases for custom classes that will be written to
                // persistence store by navigator
                registerClassAlias("ViewData", ViewData);
                registerClassAlias("ViewNavigatorSection", ViewNavigatorSection);
                
                // Create persistence store
                // Note: The shared object has to be loaded AFTER the class aliases are created
                persistenceManager = new PersistenceManager();
                persistenceManager.initialize();
                
                // Dispatch event for loading persistence data
                var eventDispatched:Boolean = true;
                if (hasEventListener("applicationRestore"))
                    eventDispatched = dispatchEvent(new Event("applicationRestore", false, true))

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
                }
            }
            
            // If the sections property is not set by this point, MobileApplication will
            // create a default section to be used by the navigator, and initialize it
            // with the rootView and initialData defined by the application
            if (sections == null || sections.length == 0)
            {
                // Create the empty screen stack and initialize it with the
                // desired rootView and initial data
                var section:ViewNavigatorSection = new ViewNavigatorSection();
                section.rootView = rootView;
                section.initialData = initialData;
                
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
                
                if (navigatorProperties.actionGroupLayout != undefined)
                {
                    navigator.actionGroupLayout = navigatorProperties.actionGroupLayout;
                    newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                        ACTION_LAYOUT_PROPERTY_FLAG, true);
                }
                
                
                if (navigatorProperties.navigationContent != undefined)
                {
                    navigator.navigationContent = navigatorProperties.navigationContent;
                    newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                        NAVIGATION_CONTENT_PROPERTY_FLAG, true);
                }
                
                if (navigatorProperties.navigationGroupLayout != undefined)
                {
                    navigator.navigationGroupLayout = navigatorProperties.navigationGroupLayout;
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
                
                if (navigatorProperties.titleGroupLayout != undefined)
                {
                    navigator.titleGroupLayout = navigatorProperties.titleGroupLayout;
                    newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                        TITLE_LAYOUT_PROPERTY_FLAG, true);
                }
                
                navigatorProperties = newNavigatorProperties;
                
                // Add event listeners
                navigator.addEventListener(Event.COMPLETE, persistViewData);
                navigator.addEventListener(ViewNavigatorEvent.VIEW_ADD, navigator_viewAddHandler);
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
                    newNavigatorProperties.actionGroupLayout = navigator.actionGroupLayout;
                
                if (BitFlagUtil.isSet(navigatorProperties as uint, NAVIGATION_CONTENT_PROPERTY_FLAG))
                    newNavigatorProperties.navigationContent = navigator.navigationContent;
                
                if (BitFlagUtil.isSet(navigatorProperties as uint, NAVIGATION_LAYOUT_PROPERTY_FLAG))
                    newNavigatorProperties.navigationGroupLayout = navigator.navigationGroupLayout;
                
                if (BitFlagUtil.isSet(navigatorProperties as uint, TITLE_PROPERTY_FLAG))
                    newNavigatorProperties.title = navigator.title;
                
                if (BitFlagUtil.isSet(navigatorProperties as uint, TITLE_CONTENT_PROPERTY_FLAG))
                    newNavigatorProperties.titleContent = navigator.titleContent;
                
                if (BitFlagUtil.isSet(navigatorProperties as uint, TITLE_LAYOUT_PROPERTY_FLAG))
                    newNavigatorProperties.titleGroupLayout = navigator.titleGroupLayout;
                
                navigatorProperties = newNavigatorProperties;
                
                // TODO (chiedozi): Do i need to null out the properties on navigator?  Applicaiton does.
                navigator.removeEventListener(Event.COMPLETE, persistViewData);
                navigator.removeEventListener(ViewNavigatorEvent.VIEW_ADD, navigator_viewAddHandler);
            }
        }
    }
}