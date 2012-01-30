package spark.components
{
    import flash.desktop.NativeApplication;
    import flash.display.StageOrientation;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.StageOrientationEvent;
    import flash.net.registerClassAlias;
    
    import spark.components.supportClasses.ViewData;
    import spark.components.supportClasses.ViewNavigatorSection;
    import spark.core.managers.IPersistenceManager;
    import spark.core.managers.PersistenceManager;
    import spark.events.ViewNavigatorEvent;

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
        
        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------
        
        
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
        //  sections
        //----------------------------------
        
        private var _sections:Vector.<ViewNavigatorSection>;
        private var _sectionsChanged:Boolean = false;
        
        [ArrayElementType("spark.components.supportClasses.ViewNavigatorSection")]
        /**
         *  Returns the stacks vector of the current navigator.
         */
        public function get sections():Vector.<ViewNavigatorSection>
        {
            if (navigator)
                return navigator.sections;
            
            return _sections;
        }
        
        /**
         *  @private
         */
        public function set sections(value:Vector.<ViewNavigatorSection>):void
        {
            if (navigator)
                navigator.sections = (value == null) ? value : value.concat();
            else
                _sections = value.concat();
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
                        navigator.selectedIndex = persistenceManager.getProperty("selectedSection") as Number;
                        
                        if (navigator.tabBar)
                            navigator.tabBar.selectedIndex = navigator.selectedIndex;
                    }
                }
            }
        }
        
        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);
            
            if (instance == navigator)
            {
                navigator.addEventListener(Event.COMPLETE, persistViewData);
                navigator.addEventListener(ViewNavigatorEvent.VIEW_ADD, navigator_viewAddHandler);
                
                navigator.sections = _sections;
                _sections = null;
            }
        }
        
        override protected function partRemoved(partName:String, instance:Object):void
        {
            super.partRemoved(partName, instance);
        }
    }
}