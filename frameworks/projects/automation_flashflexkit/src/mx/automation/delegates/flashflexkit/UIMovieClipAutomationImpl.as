////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////


package mx.automation.delegates.flashflexkit
{ 
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.ui.Keyboard;
    
    import mx.automation.Automation;
    import mx.automation.IAutomationManager;
    import mx.automation.IAutomationObject;
    import mx.automation.IAutomationObjectHelper;
    import mx.automation.delegates.DragManagerAutomationImpl;
    import mx.automation.events.AutomationDragEvent;
    import mx.core.EventPriority;
    import mx.core.IUIComponent;
    import mx.core.UIComponent;
    import mx.core.UIComponentGlobals;
    import mx.core.mx_internal;
    import mx.events.EffectEvent;
    import mx.events.FlexEvent;
    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;
    import mx.flash.UIMovieClip;
    use namespace mx_internal;
    
    [Mixin]
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  UIMovieclip control.
     * 
     *  @see mx.flash.UIMovieClip
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    public class UIMovieClipAutomationImpl extends EventDispatcher 
        implements IAutomationObject
    {
        include "../../../core/Version.as";
        
        //--------------------------------------------------------------------------
        //
        //  Class methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Registers the delegate class for a component class with automation manager.
         *  @param root DisplayObject object representing the application root. 
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public static function init(root:DisplayObject):void
        {
            Automation.registerDelegateClass(UIMovieClip, UIMovieClipAutomationImpl);
        }   
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructor.
         *
         *  @param obj UIComponent object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public function UIMovieClipAutomationImpl(obj:UIMovieClip)
        {
            super();
            
            movieClip = obj;
            
            
            obj.addEventListener(MouseEvent.CLICK, mouseClickHandler, false, EventPriority.DEFAULT+1, true);
            
            recordClick = true;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------
        
        /**
         *  A reference to the object which manages all of the application's localized resources.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        protected var resourceManager:IResourceManager =
            ResourceManager.getInstance();
        
        /**
         *  @private
         */
        private var effectsPlaying:Boolean = false;
        
        /**
         *  @private
         */
        private var layoutPending:Boolean = false;
        
        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------
        
        //---------------------------------
        //  automationEnabled
        //---------------------------------
        public function get automationEnabled():Boolean
        {
            trace("Reading should not be done here");
            return false;
        }
        
        //---------------------------------
        //  automationOwner
        //---------------------------------
        public function get automationOwner():DisplayObjectContainer
        {
            return null;
        }
        
        //---------------------------------
        //  automationParent
        //---------------------------------
        public function get automationParent():DisplayObjectContainer
        {
            return null;
        }
        
        //---------------------------------
        //  automationVisible
        //---------------------------------
        public function get automationVisible():Boolean
        {
            trace("Reading should not be done here");
            return false;
        }
        
        //----------------------------------
        //  automationName
        //----------------------------------
        
        /**
         *  @inheritDoc
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public function get automationName():String
        {
            if (movieClip is DisplayObject)
                if(DisplayObject(movieClip).name) return (DisplayObject(movieClip).name);
            
            return movieClip.id;
        }
        
        /**
         *  @private
         */
        public function set automationName(value:String):void
        {
            uiAutomationObject.automationName = value;
        }
        
        //----------------------------------
        //  automationValue
        //----------------------------------
        
        /**
         *  @inheritDoc
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public function get automationValue():Array
        {
            return [ automationName ];
        }
        
        
        //------------- ---------------------
        //  recordClick
        //----------------------------------
        
        /**
         *  @private
         *  Storage for the recordClick property.
         */
        private var _recordClick:Boolean = false;
        
        /**
         *  @private
         *  Indicates whether this component should dispatch all click
         *  events as replayable interaction
         */
        public function get recordClick():Boolean
        {
            return _recordClick;
        }
        
        /**
         *  @private
         */
        public function set recordClick(val:Boolean):void
        {
            // we don't want to add/remove the event listeners multiple times
            if (_recordClick != val)
            {
                _recordClick = val;
                if (val)
                    movieClip.addEventListener(MouseEvent.CLICK, mouseClickHandler);
                else
                    movieClip.removeEventListener(MouseEvent.CLICK, mouseClickHandler);
            }
        }
        
        /**
         *  @private
         */
        public function get showInAutomationHierarchy():Boolean
        {
            trace("Reading should not be done here");
            return true;
        }
        
        /**
         *  @private
         */
        public function set showInAutomationHierarchy(value:Boolean):void
        {
            trace("Setting should not be done here");
            IAutomationObject(movieClip).showInAutomationHierarchy = value;
        }
        
        /**
         *  @private
         */
        protected var _movieClip:UIMovieClip;
        
        /**
         *  Returns the component instance associated with this delegate instance.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public function get movieClip():UIMovieClip
        {
            return _movieClip;
        }
        
        /**
         *  @private
         */
        public function set movieClip(obj:UIMovieClip):void
        {
            _movieClip = obj as UIMovieClip;
        }
        
        
        /**
         *  @private
         */
        protected function get uiAutomationObject():IAutomationObject
        {
            return _movieClip as IAutomationObject;
        }
        
        
        /**
         *  @private
         *  Dispatch a replayable interaction.
         *
         *  Usually a developer would intend to dispatch the event
         *  as a normal event at the same time, so this function
         *  will do a regular dispatchEvent() along with dispatching
         *  to the AutomationManager.
         *  If you wish to not dispatch the regular event,
         *  set the second parameter to false.
         *
         *  This method will also test to make sure that the event
         *  really should be dispatched by checking
         *  shouldDispatchReplayableInteraction.
         *  Component authors can override that method to ensure correct behavior.
         *
         *  @param event The Event to dispatch
         *
         *  @param doRegular If true (default) dispatch the regular event using
         *  dispatchEvent(event)
         *
         *  @param cacheable
         *
         */
        public function recordAutomatableEvent(event:Event,
                                               cacheable:Boolean = false):void
        {
            var am:IAutomationManager = Automation.automationManager;
            if (am && am.recording)
            {
                am.recordAutomatableEvent(movieClip as IAutomationObject, event, cacheable);
            }
        }
        
        /**
         *  @private
         *  Replay the specified interaction.
         *  Returns whether or not a replay was successful.
         *  A component author should probably call super.replayInteraction()
         *  in case default replay behavior has been defined in a superclass.
         *  UIComponent returns false since it does not know
         *  how to replay any events.
         *
         *  @param event The event to replay
         */
        public function replayAutomatableEvent(event:Event):Boolean
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            if (event is MouseEvent && event.type == MouseEvent.CLICK)
                return help.replayClick(movieClip, event as MouseEvent);
            else if (event is KeyboardEvent)
                return movieClip.dispatchEvent(event);
            else if (event is FocusEvent && 
                event.type == FocusEvent.KEY_FOCUS_CHANGE)
            {
                var ke:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
                ke.keyCode = Keyboard.TAB;
                ke.shiftKey = FocusEvent(event).shiftKey;
                movieClip.dispatchEvent(ke);
                
                movieClip.dispatchEvent(event);
                
                ke = new KeyboardEvent(KeyboardEvent.KEY_UP);
                ke.keyCode = Keyboard.TAB;
                return UIComponent(movieClip).getFocus().dispatchEvent(ke);
            }
            else if (event is AutomationDragEvent)
                return DragManagerAutomationImpl.replayAutomatableEvent(uiAutomationObject, event);
            else
                return false;
        }
        
        /**
         *  Sets up a automation synchronization with layout manager update complete event.
         *  When certain actions are being replayed automation needs to wait before it can
         *  replay the next event. This wait is required to allow the framework to complete
         *  actions requested by the component. Normally a layout manager update complte event 
         *  signals end of all updates. This method adds syncrhonization which gets signaled as 
         *  complete when update_complete event is received.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        protected function addLayoutCompleteSynchronization():void    
        {
            UIComponentGlobals.layoutManager.addEventListener(FlexEvent.UPDATE_COMPLETE, layoutHandler);
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            if (help && help.replaying)
            {
                layoutPending = true;
                help.addSynchronization(function():Boolean
                {
                    return layoutPending == false;
                }, movieClip);
            }
        }
        
        
        
        
        
        
        /**
         *  @private
         */
        private function mouseClickHandler(event:MouseEvent):void
        {
            var am:IAutomationManager = Automation.automationManager;
            if (recordClick && am && am.recording)
            {
                var ao:IAutomationObject = null;
                var o:Object = event.target;
                while (o)
                {
                    ao = o as IAutomationObject;
                    if (ao)
                        break;
                    o = o.parent;
                }
                if (ao == movieClip)
                    recordAutomatableEvent(event, false);
            }
        }
        
        
        /**
         *  @private
         */
        protected function layoutHandler(event:FlexEvent):void
        {
            layoutPending = false;
            UIComponentGlobals.layoutManager.removeEventListener(FlexEvent.UPDATE_COMPLETE, layoutHandler);
        }
        
        /**
         *  @private
         */
        public function createAutomationIDPart(child:IAutomationObject):Object
        {
            return null;
        }
        
        /**
         *  @private
         */
        public function createAutomationIDPartWithRequiredProperties(child:IAutomationObject, properties:Array):Object
        {
            return null;
        }
        
        /**
         *  @private
         */
        public function resolveAutomationIDPart(criteria:Object):Array
        {
            return [];
        }
        
        /**
         *  @private
         */
        public function get numAutomationChildren():int
        {
            return 0;
        }
        
        /**
         *  @private
         */
        public function getAutomationChildAt(index:int):IAutomationObject
        {
            return null;
        }
        
        /**
         *  @private
         */
        public function getAutomationChildren():Array
        {
            return null;
        }
        
        /**
         *  @private
         */
        public function get automationTabularData():Object
        {
            return null;    
        }
        
        /**
         *  @private
         */
        public function get owner():DisplayObjectContainer
        {
            return (movieClip as IUIComponent).owner;
        }
        
        /**
         *  @private
         */
        public function set automationDelegate(val:Object):void
        {
            trace("Invalid setter function call. Should have been called on the component");
        }
        
        /**
         *  @private
         */
        public function get automationDelegate():Object
        {
            trace("Invalid getter function call. Should have been called on the component");
            return this;
        }
        
        /**
         *  @private
         */
        public function getLocalPoint(po1:Point, targetObj:DisplayObject):Point
        {
            //var p:Point = new Point(event.localX, event.localY);
            // when the dragevent base object on which the coordinate is recorded 
            // then the delegate of that componet needs to override the method.
            // refer for details in Chartbase
            return po1;
        }
        /**
         *  @private
         */
        public function isDragEventPositionBased():Boolean
        {
            // for almost all components it is not.
            // however for compoents like chart it is coordinate based
            return false;
        }
    }
}


