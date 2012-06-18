////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package mx.automation
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	import flash.utils.setTimeout;
	
	import mx.automation.delegates.DragManagerAutomationImpl;
	import mx.automation.events.AutomationAirEvent;
	import mx.automation.events.AutomationEvent;
	import mx.automation.events.AutomationRecordEvent;
	import mx.automation.events.AutomationReplayEvent;
	import mx.automation.events.EventDetails;
	import mx.automation.events.MarshalledAutomationEvent;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.Container;
	import mx.core.EventPriority;
	import mx.core.IChildList;
	import mx.core.IDeferredInstantiationUIComponent;
	import mx.core.IFlexModuleFactory;
	import mx.core.IRawChildrenContainer;
	import mx.core.ISWFBridgeProvider;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.DragEvent;
	import mx.events.FlexChangeEvent;
	import mx.events.FlexEvent;
	import mx.events.InterManagerRequest;
	import mx.events.SandboxMouseEvent;
	import mx.managers.IMarshalSystemManager;
	import mx.managers.ISystemManager;
	import mx.managers.SystemManager;
	import mx.managers.SystemManagerProxy;
	import mx.modules.ModuleManager;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	import mx.styles.IStyleClient;

	use namespace mx_internal;
	[Mixin]
 
[ResourceBundle("automation_agent")]
			
/**
 *  Provides the interface for manipulating the automation hierarchy,
 *  and for recording and replaying events.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */         
public class AutomationManager extends EventDispatcher
	   implements IAutomationManager2, IAutomationObjectHelper, 
	   IAutomationMouseSimulator, IAutomationDebugTracer
{
    include "../core/Version.as";
 


	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
     */
	private static const MOUSE_CLICK_TYPES:Array = [ MouseEvent.MOUSE_OVER,
                                                     MouseEvent.MOUSE_DOWN,
                                                     MouseEvent.MOUSE_UP,
                                                     MouseEvent.CLICK ];

    /**
     *  @private
     */
	private static const KEY_CLICK_TYPES:Array = [ KeyboardEvent.KEY_DOWN,
                                                   KeyboardEvent.KEY_UP ];

	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
     *  Dictionary of all app domains/systemManagers
     */
	private static var allSystemManagers:Dictionary = new Dictionary(true);
	
	/**
	 *  @private
	 *  The highest place we can listen for events in our DOM
	 */
	private static var _mainListenerObj:IEventDispatcher; 
	
	
	/**
	 *  @private
	 *  The uniqueAppID of this applicaiton as decided by the 
	 *  root AutomationManager
	 *  This field will be the applicaiton.id for the root appliction
	 */
	private static var _uniqueApplicationId:String; 
	
	/**
	 *  @private
	 *  The start point of this application in screen coordinates
	 */
	private static var _appStartPoint:Point; 
	
	/**
	 *  @private
	 *  the system manager of the current applicaiton domain
	 */
	 
	private static var sm1:ISystemManager;
	private static var _sm1MSm:IMarshalSystemManager;
	
	
	/**
	 *  @private
	 *  The popup's of the current appliation domain
	 */
	 
	private static var popUpObjects:Array;
	
	/**
	 *  @private
	 *  The daragProxy from the sub application
	 */
	 
	private static var currentDragProxyHolder:Array;
	
	
	private static var allAirWindowsToIdDictionary:Dictionary = new Dictionary(true);
	private static var allAirIdToWindowsDictionary:Dictionary = new Dictionary(true);
	private static var allAirWindowList:Array = new Array();
	private static var lastRegisteredWindowCount:int = 0;
	private static const airWindowIdFixedString:String = "_AIRWindow_";
	public static const airWindowIndicatorPropertyName:String = "isAIRWindow";
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	private static function get mainListenerObj():IEventDispatcher
	{
		if(!_mainListenerObj)
			initMainListeners();
		
		return _mainListenerObj;
		
	}
	
	
	private static function get sm1MSm():IMarshalSystemManager
	{
		if(!_sm1MSm)
			initMainListeners();
		
		return _sm1MSm;
		
	}
    /**
     *  @private
     *  Function invoked by the SystemManager. Creates AutomationManager singleton.
     */
	public static function init(root:DisplayObject):void
	{ 
		if(!Automation.initialized)
		{
				
			sm1 = root as ISystemManager;
			var sysMgr:SystemManager = root as SystemManager;
			var tempOj:Object = sysMgr.topLevelSystemManager.getImplementation("mx.managers::IMarshalSystemManager");
			_sm1MSm = IMarshalSystemManager(sysMgr.topLevelSystemManager.getImplementation("mx.managers::IMarshalSystemManager") );
			//sm1MSm = root as IMarshalSystemManager;
			// add event listener for the new sand_box_bridge event.
			// whenver we get the new bridge
			//mainListenerObj = getMainListenerObject(sm1);
				
			Automation.automationManager = new AutomationManager;
			AutomationHelper.registerSystemManager(sm1);
					
		}
	}
	
    /**
     *  @private
     */
    private static function isChild(parent:DisplayObject,
									child:DisplayObject):Boolean
    {
        while (child != null)
        {
            if (parent == child)
                return true;
            
			child = child.parent;
        }

        return false;
    }

    /**
     *  @private
     */
    private static function comparePropertyValues(lhs:Object, rhs:Object):Boolean
    {
        //we should probably be use the DefaultPropertyCodec to transcoding help here
        //parts coming in from the testing tool should be properly typed, but they aren't
        //so pretty much lhs will always be a String or RegExp
        if (lhs == null && rhs == null)
            return true;

	   if ((lhs is String || lhs is Array) && 
            lhs.length == 0 && rhs == null)
            return true;
	   
	   /* Commenting the trimming part below because XMLList is now retruning non-trimmed strings*/
	   //For strings we are trimming because otherwise, it returns false when compared with XML.toString()
	   //because it returns trimmed strings 
	   /*if(rhs is String)
	   		rhs = trim(rhs as String);
	   if(lhs is String)
		   lhs = trim(lhs as String);*/
	   
		if ((lhs is XML ) && 
			(lhs as XML).toXMLString.length == 0 && rhs == null)
			return true;

		if(rhs == null)
		{
			if ((lhs is XMLList ) && 
				((lhs as XMLList).length() == 1))
			{
				var currentVar:XML = lhs[0];
				if(currentVar.toXMLString().length == 0)
					return true;
			}
		}
		
        if (rhs == null)
            return false;

		if(rhs is Boolean)
			return (rhs == Boolean(Number(lhs)));
				
        if (lhs is Array)
        {
            if (!(rhs is Array))
                return false;

            if (lhs.length != rhs.length)
                return false;

            for (var no:int = 0; no < lhs.length; ++no)
            {
                if (!comparePropertyValues(lhs[no], rhs[no]))
                    return false;
            }
            
            return true;
        }
        else if (lhs is RegExp)
            return lhs.test(rhs.toString());
        else if (lhs is String)
            return lhs == rhs.toString();
        else
            return lhs == rhs;
    }

    /**
     * Applies [f] to each item in [list] by calling f(list[i])
     * for i=0..[list].length.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private static function map(f:Function, list:Array):void
    {
    	for (var i:int = 0; i < list.length; i++)
        {
    		f(list[i]);
        }
    }
	
	private static function isWhitespace( ch:String ):Boolean {
		return ch == '\r' || 
			ch == '\n' ||
			ch == '\f' || 
			ch == '\t' ||
			ch == ' '; 
	}
	
	private static function trim(string:String):String 
	{
		var n:int = string.length;
		var i:int;
		while(n>0)
		{
			if(isWhitespace(string.charAt(0)))
			{
				string = string.substring(1,n);
				n--;
			}
			else
				break;
		}
		n = string.length;
		while(n>0)
		{
			if(isWhitespace(string.charAt(n-1)))
			{
				string = string.substring(0,n-1);
				n--;
			}
			else
				break;
		}
		return string;
	}
    
	/**
	 *  @private
	 */
	private  function childAddedHandler(event:Event):void
	{
		if (!Automation.delegateDictionary)
			return;

		var object:DisplayObject = event.target as DisplayObject;
		
		if (object && object.root && object.root is DisplayObject && !allSystemManagers[object.root])
			allSystemManagers[object.root] = object.root;

		
		var delegateCreated:Boolean = createDelegate(event.target as DisplayObject);
		addDelegates(event.target as DisplayObject);
		
		if(delegateCreated == false)
		{
			var component:IAutomationObject = event.target as IAutomationObject;
			if(!component) // the obejct is not an IAutomationObject of the main applicaiton 
			{
				
				if(object.parent )
				{
					// try to get the parents classname.
					var className:String = getQualifiedClassName(object.parent);
					
					// when we get Alerts which are part of the another application
					// we cannot create the delegate here. Here we should send the details
					// to the other application and let them handle the same.
					if((className == "mx.managers::SystemManagerProxy")||
					 ((object.hasOwnProperty("className")&&	(object["className"] == "DragProxy")))||
						(className =="mx.managers.dragClasses::DragProxy"))
					
					//if(className == "mx.managers::SystemManagerProxy")
					{
						
						var tempEventObj:MarshalledAutomationEvent = new MarshalledAutomationEvent(
								MarshalledAutomationEvent.POPUP_HANDLER_REQUEST);
						var tempArr:Array = new Array();
						tempArr.push(object);
						tempEventObj.interAppDataToSubApp = tempArr;
						dispatchMarshalledEventToSubApplications(tempEventObj);
					}
				}
			}
	
		}
	}
	
		
	/**
	 *  @private
     *  Given a object returns the SystemManager object which contains
     *  the applicationDomain containing the object class.
	 */
	private static function getSWFRoot(object:DisplayObject):DisplayObject
	{
		var className:String = getQualifiedClassName(object);

		var domain:ApplicationDomain;
		var compClass:Class;
		for (var p:* in allSystemManagers)
		{
			domain = p.loaderInfo.applicationDomain;
			try
			{
				compClass = Class(domain.getDefinition(className));
				if (object is compClass)
					return p as DisplayObject;
			}
			catch(e:Error)
			{
                 //exception means that the application domain 
                 //doesn't contain the object class.
			}
		}
		
        //we have failed to find the application domain in the dictionary.
        //try the nearest systemManager instance.
		var sm:DisplayObject = object;
		while(sm && !(sm is ISystemManager))
		{
			sm = sm.parent;
		}
		if(sm)
		{
			
			domain = sm.loaderInfo.applicationDomain;
			try	
			{
				compClass = Class(domain.getDefinition(className));
				if (object is compClass)
					return sm;
			}
			catch(e:Error)
			{
				// we didnt get the current object in any of the system manager's domain 
				// and we got this exception. It is quite possible that the class 
				// is an internal class. so let us rerutn the last parent's system manager.
				// FLEXENT-1088, 1090, we should not return the parent's sm as this will prevent
				// the module's app domain getting tried out.
				//return sm;
			}
		}
		
		return null;
	}
	
	/**
	 *  @private
	 */	 
	private static function createDelegate(obj:DisplayObject):Boolean
	{
		var component:IAutomationObject = obj as IAutomationObject;
		//if(!(obj is IAutomationObject || component == null || component.automationDelegate))
		// the above looks to be wrong as we were adding the delegate for the same object more than once
		// so change as follows
		if((component == null)||(component.automationDelegate))
		{
			return false;
		}
		
		var retValue:Boolean = false;
		var appDomain:ApplicationDomain;
		var className:String = getQualifiedClassName(obj);
		var message:String;
		if(!className)
		{
			message = "class name for the object could not be obtained " + obj.toString();
			Automation.automationDebugTracer.traceMessage("AutomationManager","createDelegate()",message);
			return false;
		}
			
		var sm:DisplayObject = getSWFRoot(obj);
		
		if(!sm)
		{
	        var factory:IFlexModuleFactory = ModuleManager.getAssociatedFactory(obj);
	        if (factory != null)
    	    {
        	    appDomain = ApplicationDomain(factory.info()["currentDomain"]);
	        }
	        else
	        {
	        	message = "Factory module failure";
				Automation.automationDebugTracer.traceMessage("AutomationManager","createDelegate()",message);
	        }
		}
		else
		{
			appDomain = (sm.loaderInfo) ? sm.loaderInfo.applicationDomain :
											ApplicationDomain.currentDomain;
		}
		
		var delegateClass:Class = null;
		var compClass:Class = null;
		var mainComponentClass:Class = null;
		try
		{
			if(appDomain)
			{
				compClass = appDomain.getDefinition(className) as Class;
				mainComponentClass = compClass;
				delegateClass = Automation.delegateDictionary[compClass] as Class;
			}
			else
			{
				message = "Failed in getting the definition or the class or getting the delegate. " + 
					"Automation will not work for this component. " + className;
				Automation.automationDebugTracer.traceMessage("AutomationManager","createDelegate()",message);
			}
		}
		catch(e:Error)
		{
			message = "Failed in getting the definition or the class or getting the delegate. " + 
					"Automation will not work for this component. " + className;
			Automation.automationDebugTracer.traceMessage("AutomationManager","createDelegate()",message);
			Automation.automationDebugTracer.traceMessage("AutomationManager","createDelegate()",e.message);
			//return false;
		}
		
		if(!delegateClass && appDomain)
		{
			var componentClass:String = className;
			do 
			{
				try 
				{
					className = getQualifiedSuperclassName(appDomain.getDefinition(className));
					if(className)
					{
						compClass = appDomain.getDefinition(className) as Class;
						delegateClass = Automation.delegateDictionary[compClass] as Class;
					}
				}
				catch(e:Error)
				{
					Automation.automationDebugTracer.traceMessage("AutomationManager","createDelegate()",e.message);
					break;
				}
			}
			while(!delegateClass && className);
			
			Automation.delegateDictionary[mainComponentClass] = delegateClass; 
			//trace("Added mapping for : " + componentClass);
			
			if(!className)
			{
				message = "super class name for the object could not be obtained "+ componentClass;
				Automation.automationDebugTracer.traceMessage("AutomationManager","createDelegate()",message);
				return false;
			}

		}
		

		var c:Class = delegateClass;
		if (c)
		{
			try
			{
				var delegate:Object = new c (obj);
			}
			catch(e:Error)
			{
				Automation.automationDebugTracer.traceMessage("AutomationManager","createDelegate()",e.message);
				message = "Delegate object couldnot be created";
				Automation.automationDebugTracer.traceMessage("AutomationManager","createDelegate()",message);
			}
			
			try
			{
				component.automationDelegate = delegate;
				retValue = true;
			}
			catch(e:Error)
			{
				Automation.automationDebugTracer.traceMessage("AutomationManager","createDelegate()",e.message);
				message = "object created but delegates not set";
				Automation.automationDebugTracer.traceMessage("AutomationManager","createDelegate()",message);
			}
		}
		else{
			message = "Unable to find definition for class : " + className;
			Automation.automationDebugTracer.traceMessage("AutomationManager","createDelegate()",message);
		}
			
		return retValue;
	}

	/**
	 *  @private
	 *  Do a tree walk and add all children you can find.
	 */
	private static function addDelegates(o:DisplayObject):void
	{
		var child:DisplayObject ;
		var i:int;
		
		if (o is DisplayObjectContainer)
		{
			var doc:DisplayObjectContainer = DisplayObjectContainer(o);

			if (o is IRawChildrenContainer)
			{
				// trace("using view rawChildren");
				var rawChildren:IChildList = IRawChildrenContainer(o).rawChildren;
				// recursively visit and add children of components
				// we don't do this for containers because we get individual
				// adds for the individual children
				for (i = 0; i < rawChildren.numChildren; i++)
				{
					try
					{
						child = rawChildren.getChildAt(i);
						createDelegate(child);
						addDelegates(child);
					}
					catch(error:SecurityError)
					{
						// Ignore this child if we can't access it
					}
				}

			}
			else
			{
				// trace("using container's children");
				// recursively visit and add children of components
				// we don't do this for containers because we get individual
				// adds for the individual children
				for (i = 0; i < doc.numChildren; i++)
				{
					try
					{
						child = doc.getChildAt(i);
						createDelegate(child);
						addDelegates(child);
					}
					catch(error:SecurityError)
					{
						// Ignore this child if we can't access it
					}
				}
			}
		}
		
		// do special creation of repeater delegates as they do not
		// get added as children of Containers
		var container:Container;
		var repeaters:Array;
		var count:int;
		if(o is Container)
		{
			container = o as Container;
			repeaters = container.childRepeaters;
			// change for https://bugs.adobe.com/jira/browse/FLEXENT-1044
			//if(!repeaters)
			//	return;
			count = repeaters?repeaters.length:0;
			for(i = 0; i < count; ++i)
			{
				createDelegate(repeaters[i]);
			}
		}

		// do special creation of repeater delegates as they do not
		// get added as children of Containers
		if(o.parent is Container)
		{
			container = o.parent as Container;
			repeaters = container.childRepeaters;
			// change for https://bugs.adobe.com/jira/browse/FLEXENT-1044
			//if(!repeaters)
			//	return;
			count = repeaters?repeaters.length:0;
			for(i = 0; i < count; ++i)
			{
				var repeater:IAutomationObject = repeaters[i] as IAutomationObject;
				if(repeater && !repeater.automationDelegate)
					createDelegate(repeaters[i]);
			}
		}
		
		// let us add one more level of check for the repeaters.
		// change for https://bugs.adobe.com/jira/browse/FLEXENT-1044
		
		if(o is UIComponent)
		{
			var uiComp:UIComponent = o as UIComponent;
			repeaters = uiComp.repeaters;
			count = repeaters? repeaters.length : 0;
			for(i = 0; i < count; ++i)
			{
				var repeater1:IAutomationObject = repeaters[i] as IAutomationObject;
				if(repeater1 && !repeater1.automationDelegate)
					createDelegate(repeaters[i]);
			}
		}
		
	}

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------    
    
    /**
	 *  @private
	 *  Constructor
	 */ 
	public function AutomationManager()
    { 
		super();
		
		//if(mainListenerObj)
		{
			// when the application is completed we need to add listener to the existing bridge
			sm1.addEventListener(FlexEvent.APPLICATION_COMPLETE, applicationCompleteHandler,false,EventPriority.DEFAULT);
			sm1.addEventListener(FlexChangeEvent.ADD_CHILD_BRIDGE , childBridgeHandler);

			sm1.addEventListener(Event.ADDED, childAddedHandler, false, 0, true);
			// FLEXENT-894 or 895 it was observerd that popupmenubutton menu popup object is
			// creatd before application completion. So we need to listen to the event
			// from the main app before the application completion. 
			// this event is removed lated when we listen to the after application completion
			//mainListenerObj.addEventListener(MarshalledAutomationEvent.POPUP_HANDLER_REQUEST , popupHandlerBeforeApplicationCompletion, false, 0, true);
			// FLEXENT-1002
			// when the sdk changes happened with the IMarshaledSystemManager, since the mainListenerObj was not available here
			// we moved the following line to the applicaiton completion handler. But we need this handled before the application completion
			// the popups of the application domain is added to the sandbox root application, we can depend on the sanbox to add to the listener for this
			// event.
			sm1.getSandboxRoot().addEventListener(MarshalledAutomationEvent.POPUP_HANDLER_REQUEST , popupHandlerBeforeApplicationCompletion, false, 0, true);
	
		}
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------    
    
    /**
	 *  @private
	 */
	private var lastMouseTarget:IEventDispatcher = null;
    
    /**
	 *  @private
	 */
    private var hierarchyCacheCounter:int = 0;
    
    /**
	 *  @private
	 */
	private var rebuildPartCache:Boolean = true;
    
    /**
	 *  @private
	 *  Holds automationIDPart objects for reuse.
	 *  The IDParts are cached for the duration of one recording/function call.
	 */
	private var cachedParts:Dictionary = null;
    
    /**
	 *  @private
	 *  Holds the array of automation children for a container.
	 *  The children are cached for the duration of one recording/function call.
	 */
	private var cachedChildren:Dictionary = null;
	
    /**
	 *  @private
	 */
	private var cachedCompositor:Dictionary = null;

    /**
	 *  @private
	 */
    private var cachingEvents:Boolean = false;
    
    /**
	 *  @private
	 */
	private var cachedTargetOriginator:EventDispatcher = null;
    
    /**
	 *  @private
	 */
	private var eventCache:Array = [];
    
    /**
	 *  @private
	 */
	private var flushCacheTimeoutID:int = -1;
    
    /**
	 *  @private
	 */
	private var recordedEventInCurrentMouseSequence:Boolean = false;
    
    /**
	 *  @private
	 */
	private var inMouseSequence:Boolean = false;
    
    /**
	 *  @private
	 */
	private var synchronization:Array = [];

    /**
	 *  @private
	 */
	private var _currentMousePositions:Array = [];
    
    /**
	 *  @private
	 */
	private var _prevMouseTargets:Array = [];
    
	/**
	 *  @private
	 *  Used for accessing localized Error messages.
	 */
	private var resourceManager:IResourceManager =
									ResourceManager.getInstance();

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------    

	//----------------------------------
	//  automationEnvironment
	//----------------------------------

    /**
	 *  @private
	 *  Storage for the automationEnvironment property.
	 */
    private  static var _automationEnvironment:IAutomationEnvironment;
     private static var _automationEnvironmentString:String;
     private static var _automationEnvironmentHandlingClassName:String;

    /**
     *  @private
     */
    public  function get automationEnvironment():Object
    {
    	//For AIR apps it is possible that environment details for main app are set
    	//after the child apps request handlers are handled. So it can be null for child apps
    	//intially. We need a way to get the environment details for AIR apps when actually needed
    	if(!_automationEnvironment)	//happens only for AIR apps
    	{
    		// we will listen to the initial details from our parent.
    		var initialStatusRequest:MarshalledAutomationEvent = 
    			new MarshalledAutomationEvent(MarshalledAutomationEvent.INITIAL_DETAILS_REQUEST);
    		_inInitialDetailsRequestProcessing = true;
    		dispatchToParent(initialStatusRequest);
    	}
        return _automationEnvironment;
    }

    /**
     *  @private
     */
    public  function set automationEnvironment(value:Object):void
    {
        _automationEnvironment = value as IAutomationEnvironment;
        // we expect this method to be called only on the top root applicaiton
    }

 /**
     *  @private
     */
    public function get automationEnvironmentString():String
    {
        return _automationEnvironmentString;
    }

    /**
     *  @private
     */
    public function set automationEnvironmentString(value:String):void
    {
        _automationEnvironmentString = value;
       
    }
    
     
    public function getUniqueApplicationID():String
    {
    	if (_uniqueApplicationId == null)
    	{
	    	if(sm1.isTopLevelRoot() == false)
	    	{
	    		// we should the following approach only for the sub
	    		// applicaiton in the main security domain
	    		// applications across security domain cannot access the
	    		// parents of the system manager
	    		if(sm1.isTopLevel() && (sm1.topLevelSystemManager.getSandboxRoot() == sm1.getSandboxRoot()) )
	 			{
		    		// we need to get the id of the current application from the parent
		    		dispatchUniqueAppIdRequestEvent();
		    			
		    		var currentApplicationId:String = Automation.getMainApplication().className; 
					_uniqueApplicationId = currentApplicationId + "_"+ _uniqueApplicationId;
					//trace(_uniqueApplicationId + "   -   "+ classNameArray.join("|"));

	   			 }
	   			 else
	   			 {
	   			 	// we expect this loop to reach for the sub applicaiton is 
	   			 	// different security domain
	   			 	var temp:int = 0;
	   			 }
	    		
	    	}
	    	else
	    	{
	    		 	if(Automation.getMainApplication().hasOwnProperty("applicationID"))// this should work for AIR app's
					{
						_uniqueApplicationId = Automation.getMainApplication().applicationID;
					}
					else
	    				_uniqueApplicationId = Automation.getMainApplication().id;
	    				
	    			if(!_uniqueApplicationId)
	    				_uniqueApplicationId = AutomationHelper.getAppTitle();
	    			
	    	}
	    }
	    		
    	return _uniqueApplicationId;
    }
    
    //This method is used only by Flex apps which are loaded from air apps
    // to get the start point of their main air app in screen coordinates
    public function getStartPointInScreenCoordinates(windowId:String):Point
    {
    	var startPointRequest:MarshalledAutomationEvent = 
    			new MarshalledAutomationEvent(MarshalledAutomationEvent.START_POINT_REQUEST);
    	_inStartPointRequestProcessing = true;
    	var tempArray:Array = [];
    	tempArray.push(windowId);
    	startPointRequest.interAppDataToMainApp = tempArray;
    	dispatchToParent(startPointRequest);
    	//reply handler for the above event (startPointReplyHandler) would store the 
    	//start point in the variable _appStartPoint
    	
    	return _appStartPoint;
    }
    
    private function dispatchStartPointRequestEvent(windowId:String):void
    {
    	var startPointRequest:MarshalledAutomationEvent = 
    			new MarshalledAutomationEvent(MarshalledAutomationEvent.START_POINT_REQUEST);
    	_inStartPointRequestProcessing = true;
    	var tempArray:Array = [];
    	tempArray.push(windowId);
    	startPointRequest.interAppDataToMainApp = tempArray;
    	dispatchToBridgeParent(startPointRequest);
    }
    
    private static function getChildIndex1(parent:DisplayObjectContainer, child:DisplayObject):int
    {
        try 
        {
            return parent.getChildIndex(child);
        }
        catch(e:Error)
        {
            if (parent is IRawChildrenContainer)
                return IRawChildrenContainer(parent).rawChildren.getChildIndex(child);
            throw e;
        }
        throw new Error("FocusManager.getChildIndex failed");   // shouldn't ever get here
    }

    
     /**
     *  @private
     */
	public function set automationEnvironmentHandlingClassName(className:String):void
	{
		 _automationEnvironmentHandlingClassName = className;
	}
	
	/**
     *  @private
     */
    public function get automationEnvironmentHandlingClassName():String
    {
        return _automationEnvironmentHandlingClassName;
    }
	//----------------------------------
	//  recording
	//----------------------------------

    /**
	 *  @private
	 *  Storage for the recording property.
	 */
	private var _recording:Boolean = false;
    /**
     *  @private
     */
	public function get recording():Boolean
	{
		return _recording;
	}

	//----------------------------------
	//  replaying
	//----------------------------------

    /**
	 *  @private
	 *  Storage for the replaying property.
	 */
    private var _replaying:Boolean = false;
    
    /**
     *  @private
     */
    public function get replaying():Boolean
    {
        return _replaying;
    }
	
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------    

    /**
     *  @private
     */
    public function getParent(
					   obj:IAutomationObject, 
                       parentToStopAt:IAutomationObject = null,
                       ignoreShowInHierarchy:Boolean = false):IAutomationObject
    {
        while (obj)
        {
			var parent:IAutomationObject;
			if(obj is IAutomationObject)
				parent = (obj as IAutomationObject).automationOwner as IAutomationObject;
			
            if (!parent && (obj is IUIComponent ) &&(IUIComponent(obj).systemManager != null) && 
				(IUIComponent(obj).systemManager.document != null) && (obj != IUIComponent(obj).systemManager.document))
			{
				var doc:Object = IUIComponent(obj).systemManager.document;
				parent = (doc as IAutomationObject);
			}
			else 
			{
				var parentObj:DisplayObject;
				if(obj is IAutomationObject)
					parentObj = (obj as IAutomationObject).automationOwner as DisplayObject;
				
				var parentClassName:String = getQualifiedClassName(parentObj);
				if(parentClassName == "mx.managers::SystemManagerProxy")
				{
					parent = (Automation.getMainApplication() as IAutomationObject);
				}
				
			}
			
			if (parent && (parent == parentToStopAt || 
                           ignoreShowInHierarchy ||
                           showInHierarchy(parent)))
			{
				return parent;
			}
			else
			{			
				obj = parent;
			}
        }

        return null;
    }

    /**
     *  @private
     */
    public function getChildrenFromIDPart(
						obj:IAutomationObject,
    					part:AutomationIDPart = null,
                        ignoreShowInHierarchy:Boolean = false):Array
    {
		if (part == null)
		{
			return getChildren(obj, ignoreShowInHierarchy);
		}
		else
		{
			// important to do this check and not rely on it being checked
			// when getChildren is eventually called by resolveIDPart because
			// resolving always ignores the show in hierarchy and automation
			// composite flags because resolving can be delegated to children
			// that are not visible in the hieararchy (see comment in scoreChild)
	        if (!obj || 
	            !(obj is IAutomationObject) || 
	            !(ignoreShowInHierarchy || showInHierarchy(obj)))
			{
	            return [];
			}
		
	    	return resolveIDPart(obj, part);
		}
    }
    
    private function getApplicationChildren(obj:IAutomationObject):Array
    {
    	var result:Array = [];
        if ( (obj is IUIComponent) && (IUIComponent(obj).systemManager != null)&&(obj == IUIComponent(obj).systemManager.document))
        {
			var sm:IChildList = null;
			if(IUIComponent(obj).systemManager is IChildList)
				sm =  IChildList(IUIComponent(obj).systemManager);
                
            var x:DisplayObject;
            var delegate:IAutomationObject;

			var count:int = sm?sm.numChildren:0;
            for (var i:int = 0; i < count; i++)
            {
                //check that the automationParent is null because
                //popup menus will all be children of SM but only one
                //is the root, the rest are automation children of other menus
                x = sm.getChildAt(i);
				
				delegate = (x as IAutomationObject);
				if (delegate && 
                        delegate != obj && 
                        (!(delegate.automationOwner is IAutomationObject) ||
                        delegate.automationOwner == obj))
				{
                    result.push(delegate);
				}
            }
            
			var popupChildren:IChildList = null;
			
			if(IUIComponent(obj).systemManager && 
				(IUIComponent(obj).systemManager.popUpChildren) is IChildList )
				popupChildren=  IChildList(IUIComponent(obj).systemManager.popUpChildren);
			
			var count1:int = popupChildren? popupChildren.numChildren:0;
			
            for (i = 0; i < count1; i++)
            {
                //check that the automationParent is null because
                //popup menus will all be children of SM but only one
                //is the root, the rest are automation children of other menus
                x = popupChildren.getChildAt(i);
				
				delegate = (x as IAutomationObject);
				if (delegate && 
                        delegate != obj && 
                        (!(delegate.automationOwner is IAutomationObject) ||
                        delegate.automationOwner == obj))
				{
                    result.push(delegate);
				}
            }
        }
        return result;
    }

    /**
     *  @private
     */
    public function getChildren(obj:IAutomationObject,
                                ignoreShowInHierarchy:Boolean = false):Array
    {
        if (!obj || 
            !(obj is IAutomationObject) || 
            !(ignoreShowInHierarchy || showInHierarchy(obj)))
		{
            return [];
		}

        var result:Array = cachedChildren != null ? cachedChildren[obj] : null;

        if (result == null)
        {
            result = getChildrenRecursively(obj);
            
            if( (obj is IUIComponent) && (IUIComponent(obj).systemManager != null) && (obj == IUIComponent(obj).systemManager.document))
	        {
	        	 var children:Array = getApplicationChildren(obj);
	        	 result = result ? result.concat(children) : children;
	        }

            result = result || [];
            
            if (hierarchyCacheCounter > 0)
                cachedChildren[obj] = result;
        }

        return result;
    }

    /**
     *  @private
     */
    private function getChildrenRecursively(
							aoc:IAutomationObject):Array
    {
        var result:Array = null;
		// code modified below to avoid the usage of numAutomationChildren and
		// getAutomationChildAt in a loop
		//var childList:Array = aoc.getAutomationChildren();
		var childList:Array = getAutomationChildrenArray(aoc);
		var numAutomationChildren:int = childList?childList.length:0;
		
        //var numAutomationChildren:int = aoc.numAutomationChildren;
        for (var i:int = 0; i < numAutomationChildren; i++)
        {
            //var ao:IAutomationObject = aoc.getAutomationChildAt(i);
			var ao:IAutomationObject = childList[i] as IAutomationObject;
			if(ao)
			{
	            if (isAutomationComposite(ao))
	                continue;
	            
				if (! result)
	                result = [];
	            result.push(ao);
	            
				if (showInHierarchy(ao))
	                continue;
	            
				// we dont need this check as this check itself needs to
				// calculate all its children
				//if (ao.numAutomationChildren > 0)
	            {
	                var x:Array =
						getChildrenRecursively(ao)
	
	                if (x && x.length)
	                    result = result ? result.concat(x) : x;
	            }
			}
        }

        return result;
    }

    /**
     *  @private
     */
    public function getAutomationName(obj:IAutomationObject):String
    {
        if (!obj)
            return null;

        var result:Object = createIDPart(obj);
        return result.automationName;
    }

    /**
     *  @private
     */
    public function getAutomationClassName(obj:IAutomationObject):String
    {
        if (!obj)
            return null;
       
  	   if(automationEnvironment)
        {
			var automationClass:IAutomationClass = 
            	automationEnvironment.getAutomationClassByInstance(obj);
        
			return automationClass ? automationClass.name : null;
        }
        else
        	return null;
    }

    /**
     *  @private
     */
    public function getProperties(obj:IAutomationObject, 
                                  names:Array = null, 
                                  forVerification:Boolean = true, 
                                  forDescription:Boolean = true):Array
    {
        if (!obj)
            return null;

        try
        {
            incrementCacheCounter();

			// in the marshalle application if the tool libraries have not
			// handled the requriemetns all applications will not be getting the 
			// env details.
			if(!automationEnvironment)
				return null;
			
            var automationClass:IAutomationClass =
                automationEnvironment.getAutomationClassByInstance(obj);
            var propertMap:Object = automationClass.propertyNameMap;
            var i:int;
            var result:Array = [];
            if (!names)
            {
	            var propertyDescriptors:Array = 
	                automationClass.getPropertyDescriptors(obj, 
	                                                    forVerification, 
	                                                    forDescription);
                names = [];
                for (i = 0; i < propertyDescriptors.length; i++)
                {
                    names[i] = propertyDescriptors[i].name;
                }
            }
            var part:Object = createIDPartForSpecifiedProperties(names,obj as IAutomationObject);
            for (i = 0; i < names.length; i++)
            {
                var propertyDescriptor:IAutomationPropertyDescriptor = 
                    propertMap[ names[i] ];
                var value:Object = (propertyDescriptor 
                                    ? getPropertyValueFromPart(part,obj, propertyDescriptor)
                                    : null);
                //don't convert to String, testing tools want it 
                //delivered in the correct type
				
				
                result.push(value);
            }
            
            decrementCacheCounter();
        }
        catch(e:Error)
        {
            decrementCacheCounter();
            
            throw e;
        }

        return result;
    }

    /**
     *  @private
     */
    public function getTabularData(obj:IAutomationObject):IAutomationTabularData
    {
        return obj.automationTabularData as IAutomationTabularData;
    }

    /**
     *  @private
     */
    public function replayAutomatableEvent(event:AutomationReplayEvent):Boolean
    {
        var re:AutomationReplayEvent = event as AutomationReplayEvent;
        
       // check the recorded line count whether it is the max allowed limit 	
       var recordedLinesCount:Number=  Automation.incrementRecordedLinesCount();
       var licencePresent:Boolean = Automation.isLicensePresent();
       if((recordedLinesCount > Automation.recordReplayLimit ) && (licencePresent == false))
       {
       	 _replaying = false;
       	if(Automation.errorShown == false)
       	{
       		var warningMessage:String = resourceManager.getString(
					"automation_agent", "replayLimitReached");
					
          	Alert.show( warningMessage );
      		Automation.errorShown = true;
      	}
        return false;

       }
       
		// required to make MouseMove work
        if (re.replayableEvent is MouseEvent || 
            ("triggerEvent" in re.replayableEvent && 
            re.replayableEvent["triggerEvent"] is MouseEvent))
        {
            var evDispatcher:IEventDispatcher = re.automationObject as IEventDispatcher;
            var rollOver:MouseEvent = new MouseEvent(MouseEvent.ROLL_OVER, false);
            replayMouseEventInternal(evDispatcher, rollOver);
            var mouseOver:MouseEvent = new MouseEvent(MouseEvent.MOUSE_OVER);
            replayMouseEventInternal(evDispatcher, mouseOver);
        }
        
        if (! isVisible(re.automationObject as DisplayObject))
		{
            var message:String = resourceManager.getString(
				"automation_agent", "notVisible",
				[re.automationObject.automationName]);
			throw new AutomationError(message,
									  AutomationError.OBJECT_NOT_VISIBLE);
		}
        
        pushMouseSimulator(re.automationObject, 
                           re.replayableEvent);
        _replaying = true;
        var uiObject:IAutomationObject = re.automationObject as IAutomationObject;
        if (uiObject && !(uiObject.automationVisible && uiObject.automationEnabled))
        {
            re.succeeded = false;
        }    
        else
        { 
            re.succeeded = re.automationObject.replayAutomatableEvent(re.replayableEvent);
        }
        _replaying = false;
        popMouseSimulator();

        return dispatchEvent(re);
    }
	
    /**
     *  @private
     *
     */
     // commented out the sandbox mouse events as it was causing the event overflow when we have the air window
     // in the application. Found all the trial cases worked even without that. when we face an issue we need to
     // analyse the WindowedSystemManager -> System Manager otherSystemManagerMouseListener sequence to analyse the
     // event overflow reason.
    public  function beginRecording():void
    {   
        if (!recording)
        {
            _recording = true;
                     
            sm1.addEventListener(AutomationRecordEvent.RECORD,
            						recordHandler, false, EventPriority.DEFAULT_HANDLER, true);
            sm1.getSandboxRoot().addEventListener(MouseEvent.MOUSE_DOWN,
                                captureIDFromMouseDownEvent, true, 0, true);
                                
            //sm1.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE,
             //                   captureIDFromMouseDownEvent, true, 0, true);
            sm1.addEventListener(KeyboardEvent.KEY_DOWN,
                                captureIDFromKeyDownEvent, true, 0, true);
            //ideally we would listen in the bubble phase so
            //we'd get this last and all components have had a chance
            //to react and record events, but some components are stopping
            //the propagation so capture first and flush events
            //in a delayed manner
            sm1.getSandboxRoot().addEventListener(MouseEvent.CLICK,
                                onEndMouseSequence, true, 0, true);
            sm1.getSandboxRoot().addEventListener(MouseEvent.DOUBLE_CLICK,
                                onEndMouseSequence, true, 0, true);
                                
           	//sm1.getSandboxRoot().addEventListener(SandboxMouseEvent.CLICK_SOMEWHERE,
                               // onEndMouseSequence, true, 0, true);
           // sm1.getSandboxRoot().addEventListener(SandboxMouseEvent.DOUBLE_CLICK_SOMEWHERE,
                               // onEndMouseSequence, true, 0, true);
                                
            sm1.addEventListener(KeyboardEvent.KEY_UP,
                                onEndKeySequence, true, 0, true);
            //Ideally we'd flush events after the last click (or double click)
            //however the player has a bug where it doesn't always send click
            //events (and also there can be legitimate times when a click
            //event won't come through, souch as a mouse down, mouse move off 
            //the component then a mouse up), so do a timed flush after the
            //mouse up (it needs to be after any click events that might occur)
            sm1.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP,
                                onEndMouseSequence, true, 0, true);
            //sm1.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE,
                                //onEndMouseSequence, true, 0, true);
			sm1.getSandboxRoot().addEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler, false, 0, true);
			
            dispatchEvent(new AutomationEvent);
            
            // if we are the top level automation Manager, we should have recieved this call.
            // we need to inform other managers about this record starting
           if(sm1.isTopLevelRoot())
           {
	        	var beginRecordMarshalledEvent:MarshalledAutomationEvent = new MarshalledAutomationEvent
	        		(MarshalledAutomationEvent.BEGIN_RECORDING);
	        	dispatchMarshalledEventToSubApplications(beginRecordMarshalledEvent);
           }
        }
    }
    
    /**
     *  @private
     */
    public function endRecording():void
    {
        if (recording)
        {
            _recording = false;
            
            dispatchEvent(new AutomationEvent(AutomationEvent.END_RECORD));
            
            sm1.removeEventListener(AutomationRecordEvent.RECORD,
            					   recordHandler);
            sm1.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_DOWN,
                                   captureIDFromMouseDownEvent, true);
            sm1.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE,
                                   captureIDFromMouseDownEvent, true);
            sm1.removeEventListener(KeyboardEvent.KEY_DOWN,
                                   captureIDFromKeyDownEvent, true);
            sm1.getSandboxRoot().removeEventListener(MouseEvent.CLICK,
                                   onEndMouseSequence, true);
            sm1.getSandboxRoot().removeEventListener(MouseEvent.DOUBLE_CLICK,
                                   onEndMouseSequence, true);
            sm1.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP,
                                   onEndMouseSequence, true);
            sm1.getSandboxRoot().removeEventListener(SandboxMouseEvent.CLICK_SOMEWHERE,
                                   onEndMouseSequence, true);
            sm1.getSandboxRoot().removeEventListener(SandboxMouseEvent.DOUBLE_CLICK_SOMEWHERE,
                                   onEndMouseSequence, true);
            sm1.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE,
                                   onEndMouseSequence, true);                       
            sm1.removeEventListener(KeyboardEvent.KEY_UP,
                                   onEndKeySequence, true);

            clearHierarchyCache();
            clearEventCache();

            recordedEventInCurrentMouseSequence = false;
            inMouseSequence = false;
        }
    }

	public function getElementFromPoint2(x:int, y:int,windowId:String ):IAutomationObject
	{
		var stage:Stage = getAIRWindow(windowId).stage;
		return getElementFromPointOnRequiredWindow(x,y,stage);
	}
	
	private function getElementFromPointOnRequiredWindow(x:int, y:int, requiredStage:Stage):IAutomationObject
	{
		var o:Array = requiredStage.getObjectsUnderPoint(new Point(x, y));
        for (var i:int = o.length - 1; i >= 0; i--)
        {
            var displayObject:DisplayObject = o[i];
            while (displayObject != null)
            {
                // don't use showInHierarchy because that would prevent
                // checkpoints on things like boxes
                var delegate:IAutomationObject = (displayObject as IAutomationObject);
                if (delegate &&
                    // check that it's an IAutomationObject before
                    // checking visible since some components
                    // such as stage (which aren't IAutomationObjects)
                    // will yell and shout if you call visible on them
                    displayObject.visible)
                {
                	var obj:IAutomationObject ;
                	if(isAutomationComposite(delegate))
                		obj = getAutomationComposite(delegate);
                	else
                		obj = delegate;

                	return obj;
                }
                
                displayObject = displayObject.parent;
            }
        }
        return null;
	}
    /**
     *  @private
     */
    public function getElementFromPoint(x:int, y:int):IAutomationObject
    {
		//use the stage, not the system manager to find elements
		//because popups do not appear as children of the system manager
		//and so things like alerts wouldn't be found
        var stage:Stage = Automation.getMainApplication().stage;
      	return getElementFromPointOnRequiredWindow(x,y,stage);
    }

    /**
     *  @private
     */
    public function getRectangle(obj:DisplayObject):Array
    {
		var p:Point = new Point(0,0);
		p = obj.localToGlobal(p);
		// it was observed that the start points and the width and height are getting as
		// non interger values, which makes those values as zero at the other end.
		// so we are converting to the near int and passing.
        return [int(p.x), int(p.y),int( p.x + obj.width), int(p.y + obj.height)];
    }
    
    /**
     *  @private
     */
    public function isVisible(obj:DisplayObject):Boolean
    {
        while (obj && obj != obj.root && obj != obj.stage)
        {
            if (!obj.visible)
                return false;
            obj = obj.parent;
        }
        return true;
    }

    /**
     *  @private
     */
    private function getDistanceFromOriginalEvent(event:AutomationRecordEvent):int
    {
        var distance:int = 0;
        var displayObject:DisplayObject = cachedTargetOriginator as DisplayObject;
        
        while (displayObject != null && displayObject != event.automationObject)
        {
            ++distance;
            displayObject = displayObject.parent;
        }
        
        return displayObject == event.automationObject ? distance : int.MAX_VALUE;
    }

    /**
     *  @private
     */
    public function onEndKeySequence(event:KeyboardEvent):void
    {
/* 		if (flushCachedEvents() == null)
	        onFinishEventSequence();

        inMouseSequence = false;
 */    }
    
    /**
     *  @private
     */
    public function onEndMouseSequence(event:Event):void
    {
    	if (flushCacheTimeoutID != -1)
			clearTimeout(flushCacheTimeoutID);
		
		if(event.type == MouseEvent.MOUSE_UP || event.type == SandboxMouseEvent.MOUSE_UP_SOMEWHERE ||
		 event.type == SandboxMouseEvent.CLICK_SOMEWHERE)
			rebuildPartCache = true;
		
        // we're in the capture phase of mouse up sometimes,
        // so put in the timeout in either case.  so don't try
        // to optimize by checking eventCache.length
        flushCacheTimeoutID = setTimeout(endMouseSequence, 
                                         event.type == MouseEvent.MOUSE_UP || 
                                         event.type == SandboxMouseEvent.MOUSE_UP_SOMEWHERE ||
                                          event.type == SandboxMouseEvent.CLICK_SOMEWHERE ? 500 : 1);
    }
    
    /**
     *  @private
     */
    protected function keyFocusChangeHandler(event:FocusEvent):void
    {
         var focusTarget:Object = event.target;
	    // check whether the focus target is from the same application
	    // else do not record this event
	    // we want to avoid the recording of the bubbled event from other applications
	    if(focusTarget.root != sm1)
	    	return;
	    
	
	    var dispatcher:IAutomationObject = null;
		if(Automation.getMainApplication() is IAutomationObject)
			dispatcher = IAutomationObject(Automation.getMainApplication());
	 	
       	var ao:IAutomationObject = (focusTarget as IAutomationObject);
	    if (ao)
	        dispatcher = (getAutomationComposite(ao) || ao);
	  
	    recordAutomatableEvent(dispatcher, event);
    }   

    /**
     *  @private
     */
    private function endMouseSequence():void
    {
		if (flushCacheTimeoutID != -1)
		{
			clearTimeout(flushCacheTimeoutID);
			flushCacheTimeoutID = -1;
        }

		if (flushCachedEvents() == null)
	        onFinishEventSequence();

        inMouseSequence = false;
    }

    /**
     *  @private
     * 
     *  This is only public because the test harness needs to call this
     *  due to a bug in the player.  No one should call this.
     */
    public function flushCachedEvents():Event
    {
		var event:AutomationRecordEvent;

        if (eventCache.length > 0)
        {
            var closestEvents:Array = [];
            var closestDistance:int = int.MAX_VALUE;
            
            for (var i:int = 0; i < eventCache.length; ++i)
            {
                event = eventCache[i];
                var distance:int = getDistanceFromOriginalEvent(event);

                if (distance < closestDistance)
                {
				    closestDistance = distance;
                    closestEvents = [];
                    closestEvents.push(event);
                }
                else if (distance == closestDistance)
                {
                    closestEvents.push(event);
                }
            }
                
            if (closestEvents.length > 0)
            	event = closestEvents[0];
        }

		if (event != null)
		{
        	dispatchRecordEvent(event, true);
        	
        	  // at this place we record a new line hence increment the counter
        	  // since this happened with a previous decrement, we need not check the
        	  // boundary conditions
        	  var recordedLinesCount:Number= Automation.incrementRecordedLinesCount();
  		}

		return event;
    }

    /**
     *  @private
     */
    public function resolveIDToSingleObject(rid:AutomationID, 
                                            currentParent:IAutomationObject = null):IAutomationObject
    {
        
		var childArray:Array = resolveID(rid, currentParent);
        
        var message:String;
		
		if (childArray == null || childArray.length == 0)
		{
			message = resourceManager.getString(
				"automation_agent", "idNotResolved", [rid.toString()]);
            throw new AutomationError(message,
									  AutomationError.OBJECT_NOT_FOUND);
		}

        if (childArray.length > 1)
        {
            message = resourceManager.getString(
				"automation_agent", "matchesMsg", [childArray.length,
				rid.toString().replace(/\n/, ' ')]) + ":\n"; 

            for (var i:int = 0; i < childArray.length; i++)
			{
                message += AutomationClass.getClassName(childArray[i]) + 
						   "(" + childArray[i].automationName + ")\n";
			}

            throw new AutomationError(message,
									  AutomationError.OBJECT_NOT_UNIQUE);
        }
        return (childArray[0] as IAutomationObject);
    }
    
    private function isApplication(part:AutomationIDPart):Boolean
    {
    	// for Air we have top level parents which are notapplications
    	// they will be of the class 
    	// TBD this is just for prototype. This will not work if the user
    	// has extended the Window class
    	/*if(part["className"] == "mx.core.Window")
    		return true;*/
    		
    	if(part.hasOwnProperty(AutomationManager.airWindowIndicatorPropertyName))
    		return true;
    			
		if(scoreChild((Automation.getMainApplication() as IAutomationObject), part,true) >= 0)
			return true;
		
		return false;
    }

    /**
     *  @private
     */
    public function resolveID(rid:AutomationID, 
                              currentParent:IAutomationObject = null):Array
    {
    	var part:AutomationIDPart;
        var id:AutomationID = rid.clone();
		var message:String;
        if (currentParent == null)
        {
	        //remove the application
	        part = id.removeFirst();
	        if (!isApplication(part))
			{
				message = resourceManager.getString(
					"automation_agent", "rootApplication",[ id.toString()]);
	            throw new AutomationError(message,
	                                      AutomationError.ILLEGAL_RUNTIME_ID);
			}
	
			// check for the AIR window.we can get the current parent as null even for 
			// window object
			if (part.hasOwnProperty(AutomationManager.airWindowIndicatorPropertyName))	
        	{
        		// get the automationName
        		//var currentAutomationName:String = part["automationName"];
        		var currentAutomationName:String = getPassedUniqueName(part);
        		currentParent = getAIRWindow(currentAutomationName) as IAutomationObject;
        	}
        	else
            	currentParent = (Automation.getMainApplication() as IAutomationObject);
        }

        var result:Array = null;
        var currentChildArray:Array = [currentParent];
        
        while (true)
        {
            if (id.isEmpty())
            {
                result = currentChildArray;
                break;
            }

            // contains part for resolving
            part = id.removeFirst();

            // child found by resolving
            currentChildArray = currentParent.resolveAutomationIDPart(part);
            
            //check for nothing found
            if (currentChildArray.length == 0)
            {
				//null results are legal on the last node for regex searches
				//because it just means there was no match, but not legal
				//when still traversing the parent nodes
				if (!id.isEmpty())
				{
					message = resourceManager.getString(
						"automation_agent", "notResolved", [part.automationName,
						part.className, currentParent.automationName]);
	                throw new AutomationError(message,
	                                          AutomationError.OBJECT_NOT_FOUND);
				}
            }
			else
			{
	            //check for too many parents found
	            if (currentChildArray.length > 1 && !id.isEmpty())
				{
	                message = resourceManager.getString(
						"automation_agent", "matchesMsg",
						[currentChildArray.length, part.toString()]);
					throw new AutomationError(message,
	                                          AutomationError.OBJECT_NOT_UNIQUE);
				}

	            //check for parent = child
	            if (currentChildArray[0] == currentParent)
				{
					message = resourceManager.getString(
						"automation_agent", "resolvedTo",
						[currentParent, currentChildArray[0]]);
	                throw new AutomationError(message,
	                                          AutomationError.ILLEGAL_OPERATION);
				}

	            //traverse into the next parent
	            if (currentChildArray[0].numAutomationChildren > 0)
	                currentParent = currentChildArray[0] ;
	            //check for nothing found
	            else if (!id.isEmpty())
				{
					message = resourceManager.getString(
						"automation_agent", "idResolved",[ id.toString()]);
	                throw new AutomationError(message,
	                                          AutomationError.ILLEGAL_RUNTIME_ID);
				}
			}
        }
        return result;
    }

    /**
     *  @private
     */
    public function resolveIDPartToSingleObject(parent:IAutomationObject,
                                                part:AutomationIDPart):IAutomationObject
    {
        var rid:AutomationID = new AutomationID();
        rid.addFirst(part);

        return resolveIDToSingleObject(rid, parent);
    }

    /**
     *  @private
     */
    public function resolveIDPart(parent:IAutomationObject,
                                  part:AutomationIDPart):Array
    {
        var rid:AutomationID = new AutomationID();
        rid.addFirst(part);

        return resolveID(rid, parent);
    }

    /**
     *  @private
     */
	public function createID(obj:IAutomationObject, 
                             relativeToParent:IAutomationObject = null):AutomationID
	{
        var result:AutomationID = new AutomationID();
        
        if (obj == relativeToParent)
        	return result;
        
        do 
        {
            //if relativeToParent is not in the hiearchy, then we need to do a special
            //getParent so that we don't skip this parent
            var parent:IAutomationObject = 
                getParent(obj, relativeToParent, true);
            // use the real parent for creating child ids
            var part:AutomationIDPart = createIDPart(obj, parent);
            result.addFirst(part);

            // respect showInHierarchy when walking parent chain
            obj = getParent(obj, relativeToParent);
            
            if (obj == relativeToParent)
                break;
        } while (obj);
        return result;
	}

    /**
     *  @private
     */
    public function createIDPart(obj:IAutomationObject, 
                                 parent:IAutomationObject = null):AutomationIDPart
    {
        if (parent == null)
            parent = getParent(obj, null, true);

        var part:AutomationIDPart = (cachedParts 
                                     ? cachedParts[obj] as AutomationIDPart
                                     : null);

        if (!part)
        {
            part = (parent 
                    ? parent.createAutomationIDPart(obj) as AutomationIDPart
                    : helpCreateIDPart(null, obj));
                    
            if (hierarchyCacheCounter > 0)
                cachedParts[obj] = part;
        }

        return part;
    }
    
    /**
     *  @private
     */
    public function showInHierarchy(obj:IAutomationObject):Boolean
    {
        return  obj == null || 
                !(obj is IAutomationObject) ||
                (!isAutomationComposite(obj) && obj.showInAutomationHierarchy);
    }

    /**
     *  @private
     *
     *  Helper implementation of IAutomationIDHelper.  Resolves an id based 
     *  on a set of properties.  This should not be used, instead use 
     *  resolveID, resolveIDToSingleObject, or resolveIDPart.
     */
    public function helpResolveIDPart(parent:IAutomationObject,
                                      partObj:Object):Array
    {
    	var part:AutomationIDPart = partObj as AutomationIDPart;
    	if(!part)
    		return [];
        //        trace("--- searching for child [" + ObjectUtil.toString(part) +
        //              "] in parent [" + parent.automationName + "]");
        
        //Because resolving can be delegated to a child composite
        //we need to ignore hierarchy.  An example is
        //ComboBox composites List.  List will call helpResolveIDPart
        //but will appear to have no children since it's not in the
        //hierarchy, so pass true to getChildren to ignore showInHierarchy
        //Note that resolving off ComboBox instead of List would
        //not be appropriate since ComboBox may have other children (such
        //as edit propertyName or button)
        var children:Array = getChildren(parent, true);
		var winners:Array  = getWinners(children,part,false);
		if(winners.length > 1)
			winners = getWinners(children,part,true);
        return winners;
    }

	/**
	 *  @private
	 *
	 */
	 private function getWinners(children:Array, part:AutomationIDPart,forceIndexCalculation:Boolean):Array
	 {
		 //Because resolving can be delegated to a child composite
		 //we need to ignore hierarchy.  An example is
		 //ComboBox composites List.  List will call helpResolveIDPart
		 //but will appear to have no children since it's not in the
		 //hierarchy, so pass true to getChildren to ignore showInHierarchy
		 //Note that resolving off ComboBox instead of List would
		 //not be appropriate since ComboBox may have other children (such
		 //as edit propertyName or button)
		 var winners:Array = [];
		 var bestScore:int = -1;
		 for (var i:int = 0; i < children.length; i++)
		 {
			 var child:IAutomationObject = children[i]; 
			 /*
			 if (!child)
			 {
			 var message:String = resourceManager.getString(
			 "automation_agent", "nullReturned",
			 [i, parent.automationName, children.length]);
			 throw new Error(message);
			 }
			 */
			 // we are commenting out the checks above for the following reason
			 // this check stops the automation of the application if any cheild of the application
			 // is null. Initially since the automation framework was supporting only flex, all components
			 // by default will be inheriting IAutomationObject. But when the flash-flex compoenets got added
			 // to the application, it broke the automation of other flex components also because of this check.
			 // reason: flex-flash components were not implementing the IAutomationObjects and hence the components
			 // corresponding to that became null and hence the automation stopped.
			 // to avoid such a scenario we have commented out this check.
			 // and the flash-flex components are planning to be changed to implement this interface soon.
			 // till then the usage of this change will allow the users to continue with automation of other components.
			 
			 var score:int = -1;
			 if (child != null)
			 {
				 score = scoreChild(child, part,forceIndexCalculation);
			 }
			 
			 if (score == -1)
				 continue;
			 
			 // we are not processing all possible objects to match
			 // if we got an object with all the required properties of the part.
			 if(score == int.MAX_VALUE)
				 return [child];
			 
			 if (score > bestScore)
			 {
				 bestScore = score;
				 winners = [];
			 }
			 
			 if (score == bestScore)
				 winners.push(child);
		 }
		 
		 return winners;

	 }
    /**
     *  @private
     *
     *  Helper implementation of IAutomationIDHelper.  Creates an id for
     *  a given child.  This should not be used, instead use createID,
     *  or createIDPart.
     */
     
    public function helpCreateIDPart(parent:IAutomationObject,
                                     child:IAutomationObject,
                                     automationNameCallback:Function = null,
                                     automationIndexCallback:Function = null):AutomationIDPart
    {
        var part:AutomationIDPart = new AutomationIDPart();
        if(!automationEnvironment)
        	return part;
        	
        var automationClass:IAutomationClass =
            automationEnvironment.getAutomationClassByInstance(child);
        if(!automationClass)
        	return part;
        	
        var propertyDescriptors:Array = 
            automationClass.getPropertyDescriptors(child, false, true);

		if(!propertyDescriptors)
			return part;
			
		//It doesn't matter if a property is null
		//add it anyways, because the callee asked for it
		//and not adding it will confuse QTP since we've
		//told it already about the properties in the env file
		//If this causes a problem and we need to add the if
		//null checks back, then be sure to update QTPAdapter
		//to not return null properties in Learn and ActiveScreen

        for (var propNo:int = 0; propNo < propertyDescriptors.length; ++propNo)
        {
            var propertyName:String = propertyDescriptors[propNo].name;
            
            if (propertyName == "id")
            {
                part.id = child is IDeferredInstantiationUIComponent
                			? IDeferredInstantiationUIComponent(child).id
                			: null;    
               if ((part.id == null) && (parent == null))
               { 
               	   //trace ("inside the helpCreateIDPart - id "+ child.automationName);
	                // currently we are in the application object.
	                // this is a temp fix till we have AIR delegates in place.
	                // we need the application iD of this component instead of the id
	               	if(Automation.getMainApplication().hasOwnProperty("applicationID"))// this should work for AIR app's
					{
						part.id = Automation.getMainApplication().applicationID;
						 //trace ("inside the helpCreateIDPart - id "+ part.id );
					}
					else
					{
						//we are in flex app hosted from Air app
						part.id = processAppIDFromUniqueAppID();						
					}
               }
            }
            else if (propertyName == "automationName")
                part.automationName = (automationNameCallback == null 
                                       ? child.automationName 
                                       : automationNameCallback(child));
            else if (propertyName == "automationIndex")
				//note that parent can be null if it's the parentApplication
                part.automationIndex = (automationIndexCallback == null ? 
                				getChildIndex(getParent(child), child)
                				: automationIndexCallback(child));
            else if (propertyName == "className")
                part.className = AutomationClass.getClassName(child);
            else if (propertyName == "automationClassName")
                part.automationClassName = getAutomationClassName(child);
            else if (propertyName == AutomationManager.airWindowIndicatorPropertyName)
            {
            	// we added this property to identify the airtoplevel windows
            	part.isAIRWindow = true;
            }
            else
            {
                if (propertyName in child)
	                part[propertyName] = child[propertyName];
				else if (child is IStyleClient)
					part[propertyName] = IStyleClient(child).getStyle(propertyName);
	            else
				{
					var message:String = resourceManager.getString(
						"automation_agent", "notDefined", [propertyName, child]);
					traceMessage("AutomationManager", "helpCreateIDPart()", message);
                   // throw new Error(message);
				}
            }
        }

        if ("automationName" in part && ((part.automationName == null)||(part.automationName.length == 0)))
            part.automationName = part.automationIndex;
            
        return part;
    }
    
    private function processAppIDFromUniqueAppID():String
    {
    	var appId:String = getUniqueApplicationID();
    	var index:int = appId.lastIndexOf("_");
    	if(index != -1)
    	{
    		appId = appId.substring(index + 1, appId.length );
    	}
    	else
    	{
    		appId = null;
    	}
    	return appId;
    }
    
    /**
     *  @private
     */
    private function isClassAvailable(className:String):Boolean
    {
    	try
    	{
    		if(getDefinitionByName(className) != null)
    			return true;
    	}
    	catch(e:Error)
		{
			return false;
		}
		
		return false;
    }

    /**
     * Dispatch the event as a replayable event.  Causes the 
     * ReplayableEventEvent with REPLAYABLE_EVENT type to be fired.  
     * However, this method will not attempt the dispatch if there are no 
     * listeners.
     *
     * @param eventReplayer The IEventReplayer dispatching this 
     *                            event since event.target may not be 
     *                            accurate
     * @param event The event that represents the replayable event.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function recordAutomatableEvent(recorder:IAutomationObject, event:Event,
                                           cacheable:Boolean = false):void
    {
    	// this method should not get called with null event.
    	// However during some usage of the events being dispatched programmatically
    	// the trigger events may be null and the record of the same is called with the
    	// null. Eventhough this is not the expected way of usage, a check is added.
    	if (event == null)
       		return;
       		
        if (!recording)
        	return;
        	
		var message:String;
        	
        var re:AutomationRecordEvent;
        if (event is AutomationRecordEvent)
        	re = event as AutomationRecordEvent;
        else
        {
        	re = new AutomationRecordEvent(AutomationRecordEvent.RECORD);
		    re.automationObject = recorder;
    		re.replayableEvent = event;
        	re.cacheable = cacheable;
        }
        	
		//swallow orphan clicks when not following a mouseDown
		if (re.replayableEvent.type == MouseEvent.CLICK && !inMouseSequence)
			return;

		// in the marshalled application if the tool libraries have not
		// handled the requriemetns all applications will not be getting the 
		// env details.
		if(!automationEnvironment)
				return ;
				
        var automationClass:IAutomationClass = 
                automationEnvironment.getAutomationClassByInstance(re.automationObject as IAutomationObject);

         if (automationClass == null)
		 {
			  message = resourceManager.getString(
			      "automation_agent", "classNotFound",
				  [AutomationClass.getClassName(re.automationObject)]);
              throw new Error(message);
		 }

         var eventDescriptor:IAutomationEventDescriptor =
               automationClass.getDescriptorForEvent(re.replayableEvent);

         if (eventDescriptor == null)
		 {
			   message = resourceManager.getString(
			       "automation_agent", "methodNotFound",
				   [AutomationClass.getClassName(re.replayableEvent),
				   automationClass]); 
               throw new Error(message);
		 } 
                
         re.name = eventDescriptor.name;
         re.args = eventDescriptor.record(re.automationObject, re.replayableEvent);

 		// check the recorded line count whether it is the max allowed limit 	
       var recordedLinesCount:Number=  Automation.incrementRecordedLinesCount();
       var licencePresent:Boolean = Automation.isLicensePresent();
       if((recordedLinesCount > Automation.recordReplayLimit ) && (licencePresent == false))
       {
      	endRecording();
      	
      	  var warningMessage:String = resourceManager.getString(
					"automation_agent", "recordLimitReached");
					
          Alert.show( warningMessage );
         return;
 
       }
       	
       	// if the components are part of the Popup winodws (e.g Alert and objects
       	// hosted by the popUpManager and if they belong to the non root applicaiotn
       	// they are hosted by the main application. So it looks like the events dispatched on
       	// them does not reach the appropriate application. So to handle the special case,
       	// we directly call the record Handler.
       	 if(isObjectChildOfSystemManagerProxy (re.automationObject) )
       	 	recordHandler(re);
       	 	
       	 if(getQualifiedClassName(re.automationObject) == "mx.controls::FlexNativeMenu")
       	 	recordHandler(re);
         if (re.bubbles && re.automationObject is IEventDispatcher)
		 	IEventDispatcher(re.automationObject).dispatchEvent(re);
		 else
			recordHandler(re);
    }
    
     /**
     *  @private
     */
    public function isObjectChildOfSystemManagerProxy(automationObject:IAutomationObject):Boolean
	{
		var obj:DisplayObject = automationObject as DisplayObject;
		if(obj == null)	//this happens for FlexNativeMenu in AIR as it is not a DisplayObject
			return false;
		if(obj.parent == null)
		{
			// when the focus of the popup objects are taken to some other application
			// it is obsreverd that the parent is becoming null.
			// dont know whether it is an issue with sdk.
			// however since we have the list of poppup objects applicable to us
			// we can check in that.
			if((lastRemovedpopUpObject == automationObject as DisplayObject ) || (popUpObjects.indexOf(obj) != -1))
				return true;

		}
		
		while(obj.parent)
		{
			if(obj.parent is SystemManagerProxy)
				return true;
			obj = obj.parent;

		}
		return false;
	}   
     
    /**
     *  @private
     */
    public function isObjectPopUp(automationObject:IAutomationObject):Boolean
	{
		var obj:DisplayObject = automationObject as DisplayObject;
		if(obj == null) //this happens for FlexNativeMenu in AIR as it is not a DisplayObject
			return false;
		if(obj.parent == null)
		{
			// when the focus of the popup objects are taken to some other application
			// it is obsreverd that the parent is becoming null.
			// dont know whether it is an issue with sdk.
			// however since we have the list of poppup objects applicable to us
			// we can check in that.
			if((lastRemovedpopUpObject == automationObject as DisplayObject ) || (popUpObjects.indexOf(obj) != -1))
				return true;

		}
		// we need to find out whether the object belongs to the system manager before it belongs to an application
		// this is also needed to find the popups from the main application.
		var applicationFound:Boolean = (obj is Application || isSparkApplication(obj))?true:false;
		while(obj.parent)
		{
			if(obj.parent is SystemManagerProxy)
				return true;
			else
			{
				if(obj.parent is Application || isSparkApplication(obj.parent))
					applicationFound = true;
				else if ((obj.parent == sm1)&&(!applicationFound))
					return true;
			}

			obj = obj.parent;

		}
		return false;
	}   
    
    /**
     *  @private
     */
    public function recordHandler(te:Event):void
	{
		var re:AutomationRecordEvent = te as AutomationRecordEvent;
		if(re == null)
			return;
		if (re.isDefaultPrevented())
		{
			
			// decrement the recording counter 
        	// as the recording does not happen here
        	var recordedLinesCount1:Number= Automation.decrementRecordedLinesCount();
			return;
		}

        if (!isAutomationComposite(re.automationObject))
        {
            if (re.cacheable && cachingEvents)
            {
                eventCache.push(re);
	            // decrement the recording counter 
	        	// as the recording does not happen here
	        	var recordedLinesCount2:Number= Automation.decrementRecordedLinesCount();
            }
            else
                dispatchRecordEvent(re, false);
        }
        else
        {
        	// decrement the recording counter 
        	// as the recording does not happen here
        	  var recordedLinesCount3:Number= Automation.decrementRecordedLinesCount();
        }
    }

    /**
     *  @private
     */
    public function addSynchronization(isComplete:Function,
                                       target:Object = null):void
    {
        synchronization.push({isComplete: isComplete, target: target });
    }

    /**
     *  @private
     */
    public  function isSynchronized(target:IAutomationObject):Boolean
    {
        for (var i:int = 0; i < synchronization.length; i++)
        {
            if (synchronization[i].isComplete())
                 synchronization.splice(i--, 1);
            else if (target == synchronization[i].target || 
            		(target && target == synchronization[i].target) ||
            		 synchronization[i].target == null)
                return false;
            }
        return true;
    }

    /**
     *  @private
     */ 
    public function getMemberFromObject(obj:Object, 
                                        name:String):Object
    {
    	var part:Object;
    	var component:Object;

        part = createIDPart(obj as IAutomationObject);
        component = obj;
	    	
        var result:Object = null;

        if (part != null && name in part)
            result = part[name];
        else if (name in obj)
            result = obj[name];
        else if (component != null)
        {
        	if (name in component)
	            result = component[name];
    	    else if (component is IStyleClient)
        	    result = IStyleClient(component).getStyle(name);
        }
       
        return result;
    }
    
    /**
     *  @private
     */
    public function getPropertyValue(obj:Object, 
                                     pd:IAutomationPropertyDescriptor,
                                     relativeParent:IAutomationObject = null):Object
    {
        return getMemberFromObject(obj, pd.name);
    }

	//--------------------------------------------------------------------------
	//
    //  Mouse simulator methods
    //
	//--------------------------------------------------------------------------

    /**
     *  @private
     */
    public function getMouseX(item:DisplayObject):Number
    {
        return item.globalToLocal(_currentMousePositions[_currentMousePositions.length - 1]).x;
    }

    /**
     *  @private
     */
    public function getMouseY(item:DisplayObject):Number
    {
        return item.globalToLocal(_currentMousePositions[_currentMousePositions.length - 1]).y;
    }

    /**
     *  @private
     */
    private function replayMouseEventInternal(target:IEventDispatcher, event:MouseEvent):Boolean
    {
		//feed mouseOut and rollOut events to the last-clicked object, for defocussing purposes.		
		if (lastMouseTarget && lastMouseTarget != target)
		{
			var sendMouseEvents:Boolean = true;
			// check whether the new target is child of the last target.
			// if it is a child we should not send mouseOut, rollOut events
			if(lastMouseTarget is DisplayObjectContainer && target is DisplayObject)
			{
				if(DisplayObjectContainer(lastMouseTarget).contains(target as DisplayObject))
				{
                    // make the inner most component as the last target.
                    // should we have a stack of these inner components
                    // so that we can playback rollOut for all of them?
					lastMouseTarget = target;
					sendMouseEvents = false;
				}
				
			}
			if(sendMouseEvents)
			{
				var mouseOut:MouseEvent = new MouseEvent(MouseEvent.MOUSE_OUT);
				var rollOut:MouseEvent = new MouseEvent(MouseEvent.ROLL_OUT, false);
				lastMouseTarget.dispatchEvent(mouseOut);
				lastMouseTarget.dispatchEvent(rollOut);
				lastMouseTarget = target as IEventDispatcher;
			}
		}

		if(!lastMouseTarget)
			lastMouseTarget = target as IEventDispatcher;

        return target.dispatchEvent(event);
    }

    private static var fakeMouseX:QName = new QName(mx_internal, "_mouseX");
    private static var fakeMouseY:QName = new QName(mx_internal, "_mouseY");

    /**
     *  @private
     */
    private function pushMouseSimulator(targetObj:Object, eventObj:Object):void
    {
        var target:DisplayObject = (targetObj is DisplayObject 
                                    ? DisplayObject(targetObj) 
                                    : null);
        var event:MouseEvent = (eventObj is MouseEvent 
                                ? MouseEvent(eventObj) 
                                : null);
        
        var pt:Point = (event != null 
                        ? new Point(event.localX, event.localY) 
                        : new Point(0, 0));

;
		
        pt = target != null ? target.localToGlobal(pt) : pt;

        _currentMousePositions.push(pt);
        _prevMouseTargets.push(target);
        
    
    	try
    	{
   			target.root[fakeMouseX] = pt.x;
   			target.root[fakeMouseY] = pt.y;
   		}
   		catch(e:Error)
   		{
			traceMessage("AutomationManager", "pushMouseSimulator()", AutomationConstants.invalidInAIR);
   		}
     
       
        
        Automation.mouseSimulator = this;
    }

    /**
     *  @private
     */
    private function popMouseSimulator():void
    {
        _currentMousePositions.pop();
		_prevMouseTargets.pop();
        var target:Object = _prevMouseTargets[_prevMouseTargets.length-1];
        if(target && target.root)
        {   
    	    try
	    	{
		        target.root[fakeMouseX] = _currentMousePositions[_currentMousePositions.length-1].x;
	    	    target.root[fakeMouseY] = _currentMousePositions[_currentMousePositions.length-1].y;
  	   		}
	   		catch(e:Error)
	   		{
				traceMessage("AutomationManager", "popMouseSimulator()", AutomationConstants.invalidInAIR);
	   		}
    	}
    	else
    	{
            //var sm:ISystemManager = Application.application.systemManager;
	        try
	    	{
	  			sm1[fakeMouseX] = undefined;
				sm1[fakeMouseY] = undefined; 		
			}
	   		catch(e:Error)
	   		{
				traceMessage("AutomationManager", "popMouseSimulator()", AutomationConstants.invalidInAIR);
	   		}
		
		
			if (!_currentMousePositions.length)
				Automation.mouseSimulator = null;
    	}
    }

	//--------------------------------------------------------------------------
	//
    //  Replay helper methods
    //
	//--------------------------------------------------------------------------

    /**
     *  @private
     */
    public function replayKeyboardEvent(to:IEventDispatcher, event:KeyboardEvent):Boolean
    {
        return replayKeyDownKeyUp(to, event.keyCode, event.ctrlKey, event.shiftKey);
    }
    
    /**
     *  @private
     */
    public function replayKeyDownKeyUp(to:IEventDispatcher,
                                       keyCode:uint,
                                       ctrlKey:Boolean = false,
                                       shiftKey:Boolean = false,
                                       altKey:Boolean = false):Boolean
	{		
		map(function(type:String):void
			{
				var event:KeyboardEvent = new KeyboardEvent(type);
				event.keyCode = keyCode;
				event.ctrlKey = ctrlKey;
				event.shiftKey = shiftKey;
				event.altKey = altKey;
				to.dispatchEvent(event);
			},
			KEY_CLICK_TYPES);
        
		return true;
	}    									

    /**
     *  @private
     */
    public function replayMouseEvent(target:IEventDispatcher, event:MouseEvent):Boolean
    {
        pushMouseSimulator(target, event);
    	replayMouseEventInternal(target, event);
        popMouseSimulator();
        
        return true;
    }
    
    /**
     *  @private
     */
    public function replayClick(to:IEventDispatcher, sourceEvent:MouseEvent = null):Boolean
    {
        sourceEvent = sourceEvent || new MouseEvent(MouseEvent.CLICK);

        pushMouseSimulator(to, sourceEvent);
       
    	map(function(type:String):void
    		{
                var localX:int = sourceEvent && !isNaN(sourceEvent.localX) ? sourceEvent.localX : 2;
                var localY:int = sourceEvent && !isNaN(sourceEvent.localY) ? sourceEvent.localY : 2;
                var event:MouseEvent = new MouseEvent(type, true, false, localX, localY);
                event.ctrlKey = sourceEvent.ctrlKey;
                event.shiftKey = sourceEvent.shiftKey;
                event.altKey = sourceEvent.altKey;
                event.buttonDown = (type == MouseEvent.MOUSE_DOWN);
    			replayMouseEventInternal(to, event);
    		},
    		MOUSE_CLICK_TYPES);

        popMouseSimulator();

        return true;
    }

    /**
     * @private
     */
    public function replayClickOffStage():Boolean
    {
    	var x:Number = Automation.getMainApplication().screen.left - 1000;
    	var y:Number = Automation.getMainApplication().screen.top - 1000;

		map(function(type:String):void
			{
				var event:MouseEvent = new MouseEvent(type);
				event.localX = x;
				event.localY = y;
				replayMouseEventInternal(
					IEventDispatcher(Automation.getMainApplication()), event);
			},
			MOUSE_CLICK_TYPES);
        return true;
    }

    /**
     *  @private
     *  The cache of IDParts and children cannot be maintained indefinetely because 
     *  they get stale as application state chagnes. Hence control is required over 
     *  the life of cache. The incrementCacheCounter and decrementCacheCounter
     *  APIs provide this control. The calls to these two APIs should be matched to maintian
     *  cache in a healthy state.
     */
    public function incrementCacheCounter():int
    {
        ++hierarchyCacheCounter;
        
        if (cachedParts == null)
        	cachedParts = new Dictionary();
        
        if (cachedChildren == null)
        	cachedChildren = new Dictionary();
        	
       	if(cachedCompositor == null)
       		cachedCompositor = new Dictionary();

        return hierarchyCacheCounter;
    }
    
    /**
     *  @private
     *  Takes a flag to force clear the cache.
     */
    public function decrementCacheCounter(clearNow:Boolean = false):int
    {
        if (clearNow || hierarchyCacheCounter < 1)
            hierarchyCacheCounter = 1;
        
        --hierarchyCacheCounter;
        
        if (hierarchyCacheCounter <= 0)
            clearHierarchyCache();
        
        return hierarchyCacheCounter;
    }
    
    /**
     *  @private
     *  Helper function to clear the cache contents.
     */
    private function clearHierarchyCache():void
    {
        hierarchyCacheCounter = 0;
        cachedParts = null;
        cachedChildren = null;
        cachedCompositor = null;
    }
    
    /**
     *  @private
     */
    private function clearEventCache():void
    {
        eventCache = [];
        cachingEvents = false;
        cachedTargetOriginator = null;
    }

    /**
     *  @private
     */
    private function dispatchRecordEvent(event:AutomationRecordEvent, 
                                         cacheable:Boolean = false):void
    {
        //the event is disqualifed if another event has already
        //been dispatched in the current mouse down, up, click sequence
		//should we limit this check to just cacheable event?  maybe not
		//but it may impact the text events that are cached
        if (!cacheable || !inMouseSequence || !recordedEventInCurrentMouseSequence)
		{
	        if (inMouseSequence)
	        {
				//Events that are recorded during a mouse sequence, but are
				//not from the same location of the current mouse target
				//do not count.  This is to avoid issues from text fields
				//that do their own event caching, dispatch events late
				//and look like they are part of the current mouse sequence
				//but aren't.  For example, in a datagrid, if a user clicks
				//on an editable item and types something, that typing is
				//queued, if they then click on another item, the text field
				//will flush the typing.  After that the data grid will record
				//a new item click.  We don't want to through that out because
				//text field did some caching.  They are unrelated.  Do this
				//check by looking seeing if the current target is on the path 
				//between cachedTargetOriginator and the root.
				//trace(event.methodName + " " + getDistanceFromOriginalEvent(event) + ", r:" + event.automationObject + ", ct:" + cachedTargetOriginator);
				if (getDistanceFromOriginalEvent(event) != int.MAX_VALUE)
		            recordedEventInCurrentMouseSequence = true;
	        }

			dispatchEvent(event);
		}

		//The cache should only be cleared when the last event has occurred 
		//as a result of a low-level interaction.  It's possible to dispatch
		//several non-cached events during a mouse sequence, such as drag scroll events
		if (cacheable || !inMouseSequence)
			onFinishEventSequence();
    }
    
   public function  recordCustomAutomationEvent(event:AutomationRecordEvent):Boolean
   {
   		if(!recording)
   			return false;
   			
   	 	if(event.type != AutomationRecordEvent.CUSTOM_RECORD)
   	 		return false;
   	 	
   	 	if(!event.automationObject)
   	 		return false;
   	 		
   	 	// create the AutomatioRecord event
   	 	var eventObj:AutomationRecordEvent = new AutomationRecordEvent( AutomationRecordEvent.RECORD,
   	 		event.bubbles,event.cancelable,event.automationObject,event.replayableEvent,
   	 		event.args,event.name,event.cacheable);
   	 	if(!eventObj.args)
   	 		eventObj.args = new Array();
   	 	if(!eventObj.name)
   	 		eventObj.name = "NoNamePassedByUser";
   	 	eventObj.recordTriggeredByCustomHandling = true;
   	 	
   	 	
   	 	//dispatch this new event
   	 	dispatchEvent(eventObj);
   	 	return true;
   }

    /**
     *  @private
     */
	private function onFinishEventSequence():void
	{
        rebuildPartCache = true;
	    clearEventCache();
    	decrementCacheCounter();
	}

    /**
     *  @private
     */
    private function getChildIndex(parent:IAutomationObject,
                                   child:IAutomationObject):String
    {
		//parent shouldn't be null, unless it's the parentApplication
		if (parent != null)
		{
	        parent = showInHierarchy(parent) ? parent : getParent(parent);
	        var parentsChildren:Array = getChildren(parent); 
	
	        for (var childNo:int = 0; childNo < parentsChildren.length; ++childNo)
	        {
	            if (child == parentsChildren[childNo])
	                return "index:" + childNo;
	        }
		}

        return "index:-1";
    }
 
    /**
     *  @private
     */
    private function captureIDFromMouseDownEvent(event:Event):void
    {
    	captureID(event);

        cachingEvents = true;
        cachedTargetOriginator = EventDispatcher(event.target);
        inMouseSequence = true;
        recordedEventInCurrentMouseSequence = false;
    }

    /**
     *  @private
     */
    private function captureIDFromKeyDownEvent(event:Event):void
    {
/*      captureID(event);

        cachingEvents = true;
        cachedTargetOriginator = EventDispatcher(event.target);
        inMouseSequence = true;
        recordedEventInCurrentMouseSequence = false;
 */    }
    
    /**
     *  @private
     */
    private function captureID(event:Event):void
    {
		if (flushCacheTimeoutID != -1)
			clearTimeout(flushCacheTimeoutID);

        //flush cached events because:
        //
        //a) sometimes there is no CLICK or DOUBLE_CLICK event
		//the events will only get flushed after a time out of about
		//500 MS.  It's possible for someone to mouse down before that
		//timeout so check to here to see if any events need to be flushed
		//
		//b) keyboard events are never involved in caching
		flushCachedEvents();

        if (rebuildPartCache)
        {
            //force the clear of the cache because even though
            //we match the increment here with a decrement after
            //an automation event is recorded, not all
            //low-level events will result in an automation
            //event being dispatched 
            decrementCacheCounter(true);
            incrementCacheCounter();

            var o:Object = event.target;
            while (o != null)
            {
                if (o is IAutomationObject)
                {
                    if (isAutomationComposite(o as IAutomationObject))
                        o = getAutomationComposite(o as IAutomationObject);
                    else
                        break;
                }
                else
                    o = DisplayObject(o).parent;
            }

            var obj:IAutomationObject = (o as IAutomationObject);
            while (obj)
            {
	            var ao:IAutomationObject = (obj as IAutomationObject);
				
				// Earlier we were just using automationOwner as parent which is different
				// from the parent we get while calculating id using createIdPart().
				// http://bugs.adobe.com/jira/browse/FLEXENT-1126
				// http://bugs.adobe.com/jira/browse/FLEXENT-1251
				// So using getParent() method here also which returns main application as
				// parent in special cases.
				var parent:IAutomationObject = getParent(obj, null, true);
				
				cachedParts[obj] = 
                    (parent ? parent.createAutomationIDPart(ao)
                     : helpCreateIDPart(null, ao));

                if(isAutomationComposite(ao))
                {
                	obj = getAutomationComposite(ao) as IAutomationObject;
                }
                else
                {
                	obj = parent;
                }
            }
            rebuildPartCache = false;
        }
    }

	
	/**
	 *  @private
	 */
	private var className2previousClassName:Object = {};
	
    /**
     *  @private
     */
    private function scoreChild(child:IAutomationObject,
                                part:Object,calculateIndexAnyway:Boolean):int
    {
		// this method is a very expensive method
		// which tries to find the score for the passed child with the
		// passed part.
		
		//get the properties to score against from getProperties
		//rather than introspecting the automation object
		//directly, this will get any cached values and ensure
		//we use the same logic for automationName
		
		// first let us check whether the automation class name is matching,
		// if not we can give a negative score and return.
		
		var propertyNames:Array = [];
		var automationIndexNeeded:Boolean = false;	
		
		var automationClassNameRequired:Boolean = false;
		var propertyName:String;
		for (propertyName in part)
		{
			if(propertyName  != "automationIndex")
			{
				if(propertyName == "automationClassName")
					automationClassNameRequired = true;
				else
					propertyNames.push(propertyName);
			}
			else
				automationIndexNeeded = true;
				
		}
		
		var n:int = 0;
		var i:int = 0;
		//special case automationClassName because it's not a real property
		//and we currently aren't putting it in the environment info so
		//helpCreateIDPart will not populate it even if you ask for it
		//because it has no descriptor
		// we can ignore the other properties, if this is not equal.
		var partPropertyValue:Object = null;
		if (automationClassNameRequired)
		{
			childPropertyValue = getAutomationClassName(child);
			partPropertyValue = part["automationClassName"];
			
			equal = comparePropertyValues(partPropertyValue, childPropertyValue);
			
			//if they are not equal it is possible that a script recorded in one version
			//is being used in another. So we check for compatible versions of this class
			if((!equal)&&(automationEnvironment))
			{
				var previousVersionClassNames:Array = className2previousClassName[childPropertyValue];
				
				if(	previousVersionClassNames == null)
				{
					// in the marshalled application if the tool libraries have not
					// handled the requriemetns all applications will not be getting the 
					// env details.
					var automationClass:IAutomationClass =
						automationEnvironment.getAutomationClassByInstance(child);
					
					if(automationClass is IAutomationClass2)
					{
						previousVersionClassNames = IAutomationClass2(automationClass).previousVersionClassNames;
						if(previousVersionClassNames == null)
							previousVersionClassNames = [];
						className2previousClassName[childPropertyValue] = previousVersionClassNames;
						
					}
				}
				n = previousVersionClassNames.length;
				for( i = 0; i < n; i++)
				{
					equal = comparePropertyValues(partPropertyValue, previousVersionClassNames[i]);
					if(equal)
						break;
				}
			}
		}
		
		if((!equal)&&(automationClassNameRequired))
		{
			// we can ignore the other properties, if this is not equal.
			score = -1;
			allEqual = false;
		}
		else
		{
			var childProperties:Array = getProperties(child, propertyNames);
			var childPropertyMap:Object = {};
			
			for (var childPropertyNo:int = 0; childPropertyNo < childProperties.length; ++childPropertyNo)
	        {
				childPropertyMap[propertyNames[childPropertyNo]] = childProperties[childPropertyNo];
	        }

            var score:int = 0;
	        var allEqual:Boolean = true;	
			var criticalPropertiesToMatch:Array=["automationIndex","automationClassName","className","automationName","id"];
			var criticalPropertiesMismatchFound:Boolean = false;
			var automationNameNeeded:Boolean = false;	
			
	        // iterate through part
	        for (propertyName in part)
	        {
	        	// calculating automation index is a very expensive process.
	        	// so we will delay it till all other required properties matches.
	        	if((propertyName.toLowerCase()  != "automationindex")&&(propertyName.toLowerCase()  != "automationclassname"))
	        	{
		        	var equal:Boolean;
					partPropertyValue = part[propertyName];
		            var childPropertyValue:Object = (propertyName in childPropertyMap)
		                                             ? childPropertyMap[propertyName] 
		                                             : null;
					
		            equal = comparePropertyValues(partPropertyValue, childPropertyValue);					
					if((!equal)&&(propertyName.toLowerCase()  == "automationname")&&((childPropertyValue=="")||(childPropertyValue==null)))
					{
						// in some components if the automationName is not specified, it is considered using the automationIndex.
						// since we are not creating automation index, we will leave it the benefit of doubt and will 
						// create it again when we are forming automation index.
						automationNameNeeded = true;
						equal = true;
					}


		            if (equal)
		            	++score;
		            else
					{
						// check what is not matching is not the critical property
						if(criticalPropertiesToMatch.indexOf(propertyName) != -1)
							criticalPropertiesMismatchFound = true;
						
		                allEqual = false;
					}
		  		}
		         
    		}
	        if(allEqual || (!criticalPropertiesMismatchFound) || calculateIndexAnyway) 
	        {
				var requiredPropList:Array  = new Array();
				
				if( automationIndexNeeded)
					requiredPropList.push("automationIndex");
				if(automationNameNeeded)
					requiredPropList.push("automationName");
				if(requiredPropList.length)
				{
		        	var childProperties1:Array = getProperties(child, requiredPropList);
					
					childPropertyMap = {};
					for (var childPropertyNo1:int = 0; childPropertyNo1 < childProperties1.length; childPropertyNo1++)
					{
						childPropertyMap[requiredPropList[childPropertyNo1]] = childProperties1[childPropertyNo1];
					}

		        	if(childProperties1 && (childProperties1.length == requiredPropList.length))
		        	{
						n = childProperties1.length;
						for(i = 0; i < n; i++)
						{
			        		//equal = comparePropertyValues("automationIndex", childProperties[0]);
							var partPropertyValue1:Object = part[requiredPropList[i]];
							propertyName = requiredPropList[i];
							var childPropertyValue1:Object = (propertyName in childPropertyMap)
								? childPropertyMap[propertyName] 
								: null;
							equal = comparePropertyValues(partPropertyValue1, childPropertyValue1);
			        		 if (equal)
				            	++score;
							 else
							 {
								 // check what is not matching is not the critical property
								 if(criticalPropertiesToMatch.indexOf(propertyName) != -1)
									 criticalPropertiesMismatchFound = true;
								 allEqual = false;
							 }
						}
		        	}
				}
	        }
			if(criticalPropertiesMismatchFound)
			{
				score = -1;
			}
		}
		
		if(allEqual)
		{
			if(automationIndexNeeded)
				score = int.MAX_VALUE; // in this case we dont need to analyse the children for further match
				// there will be only one child with index matching and all other properties also matched.
			else
				score = int.MAX_VALUE-1;
		}
         return score;
    }
    
    /**
     *  @private
     */
    public function getAutomationComposite(obj:IAutomationObject):IAutomationObject
    {
    	if(cachedCompositor)
    	{
    		var val:IAutomationObject = cachedCompositor[obj];
    		if(val != null)
    		{
    			if(val != obj)
	    			return val;
	    		else
	    			return null;
	    	}
    	}

		var childFound:IAutomationObject = compositeAnalysis(obj);
    	if(cachedCompositor)
			cachedCompositor[obj] = childFound;
			
	    if(childFound == obj)
	    	return null;

    	return childFound;
    }
    
	private function compositeAnalysis(obj:IAutomationObject):IAutomationObject
	{
    	var hierarchyArray:Array = [obj];

    	//build an array of parents till we reach null.
    	// do not call is getParent as it would call isAutomationComposite
		var parent:IAutomationObject = getParent(obj, null, true);
		while(parent)
		{
			hierarchyArray.push(parent);
			parent = getParent(parent, null, true);
		}    	

    	//start from the top finding each child
    	// if we do not find any child then the given object is composite.
    	// if we find all the children till the given object then it is not a composite. 

   		parent = hierarchyArray.pop();
		var childFound:IAutomationObject = parent;

    	if(!hierarchyArray.length)
	    	return childFound;
		
   		var childToBeFound:IAutomationObject = hierarchyArray.pop();
   		var ch:IAutomationObject;
   		do
    	{
			// code modified below to avoid the usage of numAutomationChildren and
			// getAutomationChildAt in a loop
			//var childList:Array = parent.getAutomationChildren();
			var childList:Array = getAutomationChildrenArray(parent);
			var numChildren:int = childList?childList.length:0;
			
    		//var numChildren:int = parent.numAutomationChildren;
    		for(var i:int = 0; i < numChildren; ++i)
    		{
    			//ch = parent.getAutomationChildAt(i);
				ch = childList[i] as IAutomationObject;
				if(ch)
				{
			    	if(cachedCompositor)
						cachedCompositor[ch] = ch;
	    			
	    			if(ch == childToBeFound)
	    			{
	    				childFound = childToBeFound;
	    				break;
	    			}
				}
    		}
    		
    		// have we found the child?
    		if(i == numChildren)
    		{
				if((childToBeFound  is IUIComponent)&&(parent is IUIComponent ))
				{
					// if ((IUIComponent(obj).systemManager != null) && (parent == IUIComponent(parent).systemManager.document))
					// https://bugs.adobe.com/jira/browse/FLEXENT-1038 .
					// when the passed object is a non ui object like repeater, using the same for the
					// above check will result in skipping the below condition and hence 
					// it skips the identification of repeaters in popup objects like title window
					// which are application children.
					//if ((IUIComponent(childToBeFound).systemManager != null) && (parent == IUIComponent(parent).systemManager.document))
					// chnaging the condition checking for https://bugs.adobe.com/jira/browse/FLEXENT-1044
					if ((IUIComponent(childToBeFound)) &&
						(IUIComponent(childToBeFound).systemManager != null) &&
						(IUIComponent(parent))&&
						(IUIComponent(parent).systemManager)&& 
						(parent == IUIComponent(parent).systemManager.document))
		    		{
						var children:Array = getApplicationChildren(parent);
			    		numChildren = children.length;
			    		for(i = 0; i < numChildren; ++i)
			    		{
			    			ch = children[i];
					    	if(cachedCompositor)
								cachedCompositor[ch] = ch;
			    			if(ch == childToBeFound)
			    			{
	    						childFound = childToBeFound;
			    				break;
			    			}
			    		}
		    		}
		
		    		// have we found the child?
		    		if(i == numChildren)
	    			{
				    	if(cachedCompositor)
							cachedCompositor[childToBeFound] = parent;
				   		childToBeFound = hierarchyArray.pop();
				   		continue;
	    			}	
	    		}
			}
	   		parent = childToBeFound;
	   		childToBeFound = hierarchyArray.pop();
	    }
	    while(childToBeFound);
	    
	    return childFound;
	}
    
    /**
     *  @private
     */
    public function isAutomationComposite(obj:IAutomationObject):Boolean
    {
    	if(cachedCompositor)
    	{
    		var val:IAutomationObject = cachedCompositor[obj];
    		if(val != null)
    		{
    			if(val == obj)
	    			return false;
	    		else
	    			return true;
	    	}
    	}

		var childFound:IAutomationObject = compositeAnalysis(obj);
    	if(cachedCompositor)
			cachedCompositor[obj] = childFound;

		if(obj == childFound)
	    	return false;

		return true;
    }
 
	 /**
     *  @private
     */
	private function uniqueAppIdReplyHandler(event:Event):void
	{
		// Marshalling events are needeed across applicaiton domain
		// so this conversion shall fail in the same domain
		if(event is MarshalledAutomationEvent)
			return;
			
		if(_inUniqueAppIdRequestProcessing == false)
			return;
		
		_inUniqueAppIdRequestProcessing = false;
	
		// in the reply event we expect two parameter
		if(sm1.isTopLevelRoot() == false)
		{
			if(mainListenerObj)
			{
				_uniqueApplicationId = event["interAppDataToSubApp"][0] as String;
				
			}
		}
	}
	 /**
     *  @private
     * this method is to get the provider for the swf bridge from different possible system managers
     * In the main application of the AIR, we can have different system managers if we  have the
     * air windows open. so we need to check in all of them to find the bridge provider and use
     * the identification based on the origin of the bridge provider.
     */
	private function getSwfBridgeProviderDetails(bridgeParent:IEventDispatcher):Object
	{
		var providerType:int = -1;
		var providerName:String;
		// the bridge can be in the current application or in the windows.
		// this will be applicable for the root application only as only the root application can 
		// have child windows.
		
		// first let us search in the main applicaiton system manager.
		var bp:ISWFBridgeProvider;
		
		if(sm1MSm && (sm1MSm.swfBridgeGroup ))
		{
			bp = sm1MSm.swfBridgeGroup.getChildBridgeProvider(bridgeParent);
			initUniqueAppId();
			providerName = _uniqueApplicationId;
			providerType = -1;
		} 
		if (!bp)
		{
			// now let us seach in the windows.
			var count:int  = allAirWindowList.length;
	    	var index:int = 0;
	    	while((!bp) && (index  <  count))
	    	{
	    		var currentWindow:IUIComponent = allAirWindowList[index]  as IUIComponent;
	    		if(currentWindow)
	    		{
		    		var currentWindowSysManager:IMarshalSystemManager = currentWindow.systemManager as IMarshalSystemManager;
					if(currentWindowSysManager)
					{
						if(currentWindowSysManager.swfBridgeGroup)
							bp = currentWindowSysManager.swfBridgeGroup.getChildBridgeProvider(bridgeParent); 
						if(bp)
						{
							providerName = getAIRWindowUniqueID(currentWindow  as DisplayObject);
							providerType = index;
						}
					}
				
	    		}
	    		index++;
	    	}
		}
		var returnObject:Object = new Object();
		returnObject["ISWFBridgeProvider"] = bp;
		returnObject["providerType"] = providerType;
		returnObject["providerName"] = providerName;
		
		
		return returnObject;
	}
	
	private function initUniqueAppId():void
	{
		if(!_uniqueApplicationId)
		{
			if(sm1.isTopLevelRoot() == false)
			{
				// we need to get the uniqueapplication id from the parentapplication 
				dispatchUniqueAppIdRequestEvent();
				_uniqueApplicationId = Automation.getMainApplication().className + "_" + _uniqueApplicationId;
			}
			else
			{
				_uniqueApplicationId = Automation.getMainApplication().className;
			}
		}
	}
	private function uniqueAppIdRequestHandler(event:Event):void
	{
		// Marshalling events are needeed across applicaiton domain
		// so this conversion shall fail in the same domain
		if(event is MarshalledAutomationEvent)
			return;
		
		// we get the bridge corresponding to the requesting application
		// we need to find the swfLoader corresponding to the bridge
		// get its index in its parents till we reach the sm of the
		// current application.
		//var bp:ISWFBridgeProvider = sm1.swfBridgeGroup.
		//	getChildBridgeProvider(event["interAppDataToMainApp"][0]);
		
		var providerType:int = -1; // -1 indicates the main application and any othe value indicates the window index 
		var providerName:String;
		var returnObject:Object = getSwfBridgeProviderDetails ((event["interAppDataToMainApp"][0]));
		
		var bp:ISWFBridgeProvider = returnObject["ISWFBridgeProvider"];
		providerType = returnObject["providerType"];
		providerName = returnObject["providerName"];
		if(bp)
		{
			var unique_id_processed:String = getObjectIdInCurrentApplication(bp as DisplayObject);
			// initUniqueAppId(); moved inside the getSwfBridgeProviderDetails
			//unique_id_processed = unique_id_processed + "_" + _uniqueApplicationId;
			unique_id_processed = unique_id_processed + "_" + providerName;
				
			if(mainListenerObj)
			{
				// unique id handling logic
				var event1:MarshalledAutomationEvent = new MarshalledAutomationEvent(
				MarshalledAutomationEvent.UNIQUE_APPID_REPLY);
				var temp:Array = new Array();
				temp.push(unique_id_processed);
				event1.interAppDataToSubApp =  temp;
				//dispatchMarshalledEventToSubApplications(event1);
				dispatchToSwfBridgeChildren(event1);
			}
		}
	}
		
	private var inEndRecordDetailsPassingDownToChildren:Boolean = false;
	public  function marhsalledEndRecordHandler(event:Event):void
    {   
    	if(!sm1MSm)
    		return;
    		
    	if(sm1MSm.useSWFBridge() == false)
    		return;
    		
    	// Marshalling events are needeed across applicaiton domain
		// so this conversion shall fail in the same domain
		if(event is MarshalledAutomationEvent)
			return;
		
		if(inEndRecordDetailsPassingDownToChildren == true)
			return;
			
    	endRecording();
    	
    	inEndRecordDetailsPassingDownToChildren = true;
    	// we should pass the information to our children also
    	var event1:MarshalledAutomationEvent = MarshalledAutomationEvent.marshal(event);
    	dispatchMarshalledEventToSubApplications(event1);
    	inEndRecordDetailsPassingDownToChildren = false;
    }
    
    private var inBeginRecordDetailsPassingDownToChildren:Boolean = false;
	public  function marhsalledBeginRecordHandler(event:Event):void
    {  
    	if(!sm1MSm)
    		return;
    		
    	if(sm1MSm.useSWFBridge() == false) // we are the root application
    		return;
    		
    	// Marshalling events are needeed across applicaiton domain
		// so this conversion shall fail in the same domain
		if(event is MarshalledAutomationEvent)
			return;
			
		if(inBeginRecordDetailsPassingDownToChildren == true)
			return;
		 
    	beginRecording();
    	
    	inBeginRecordDetailsPassingDownToChildren = true;
    	
    	// we should pass the information to our children also
    	var event1:MarshalledAutomationEvent = MarshalledAutomationEvent.marshal(event);
    	dispatchMarshalledEventToSubApplications(event1);
    	
    	inBeginRecordDetailsPassingDownToChildren = false;
    	
    }
    
    
    private   function dispatchMarshalledEventToSubApplications(event:Event):void
    {
    	dispatchToAllChildren(event);
    }
    
    
   // FLEXENT-894 or 895 it was observerd that popupmenubutton menu popup object is
   // creatd before application completion. So we need to listen to the event
   // from the main app before the application completion. 
   // we cannot process these objects as and when we get it, as our appDomain may not be
   // ready then. So we store it and once the application creation is over we process these
   // objects
    private var possiblePopupsBeforeAppComplete:Array;
    private  function popupHandlerBeforeApplicationCompletion (event:Event):void
    {
   		var currentAppObj:IAutomationObject = event["interAppDataToSubApp"][0] as IAutomationObject;
   		if(!(currentAppObj is IUIComponent) || currentAppObj == null || currentAppObj.automationDelegate)
		{
			return ;
		}
		else
		{
			if(!possiblePopupsBeforeAppComplete)
				possiblePopupsBeforeAppComplete = new Array();
			// these are our objects. And some may be popups.
			// let us add to a list and keep it so that once our application is complete 
			// we will try to add the delegate for the same.
			possiblePopupsBeforeAppComplete.push(currentAppObj);
		}
   		
    }
   
   // FLEXENT-894 or 895 it was observerd that popupmenubutton menu popup object is
   // creatd before application completion. 
   // So we store it and once the application creation is over we process these
   // objects
    private  function processPopupsBeforeApplicationComplete():void
    {
    	if(possiblePopupsBeforeAppComplete)
    	{
	    	var count:int = possiblePopupsBeforeAppComplete.length;
	    	var index:int = 0;
	    	while(index < count)
	    	{
	    		handlePopupObject(possiblePopupsBeforeAppComplete.shift());
	    		index++;
	    	}
    	
    	}
    }
    private var inPopupDataSendingDownToChildren:Boolean = false;
    
    private  function popupHandler (event:Event):void
    {
    	if(event is MarshalledAutomationEvent)
    		return ;
    		
    	if(inPopupDataSendingDownToChildren)
    		return;
    		
    	var currentAppObj:DisplayObject = event["interAppDataToSubApp"][0] as DisplayObject;
    	handlePopupObject(currentAppObj, event);
    	
    }
    
    private function handlePopupObject(currentAppObj:DisplayObject, event:Event=null):void
    {
    	if(createDelegate(currentAppObj)== true)
    	{
			// we got a new popup.
			// we need to add this to our pop up list also
			// this is neeeded beause in automation we need to consider the popup's as the
			// children of the application which has created the same
			if(!popUpObjects)
				popUpObjects = new Array();
			
			if(currentAppObj as IUIComponent)
			{
				if( (currentAppObj as IUIComponent).owner == (currentAppObj as IUIComponent).parent )
					popUpObjects.push(currentAppObj);
				else if ((currentAppObj as IUIComponent).owner is Application ||
					isSparkApplication((currentAppObj as IUIComponent).owner))
					// for the popups which are direct children of application we need to store
					popUpObjects.push(currentAppObj);
			}
			/*
			if(!((currentAppObj as IUIComponent)&&
	    			((currentAppObj as IUIComponent).owner != (currentAppObj as IUIComponent).parent)))
			popUpObjects.push(currentAppObj);

			*/
			
    		addDelegates(currentAppObj);
    	
    		// we only added the delegate for the outer object.
    		// we need to add for the children also.
    		currentAppObj.addEventListener(FlexEvent.CREATION_COMPLETE, popupCompleteHandler);
    		currentAppObj.parent.addEventListener(FlexEvent.REMOVE, popupRemoveHandler);
    	}
    	else
    	{
    		inPopupDataSendingDownToChildren = true;
    		var eventX:MarshalledAutomationEvent;
    		if(event)
    		{
    			// we should pass the information to our children also
    		 	eventX= MarshalledAutomationEvent.marshal(event);
    		}
    		else
    		{
    			eventX = new MarshalledAutomationEvent(
								MarshalledAutomationEvent.POPUP_HANDLER_REQUEST);
				var tempArr:Array = new Array();
				tempArr.push(currentAppObj);
				eventX.interAppDataToSubApp = tempArr;
    		}
    	
    		dispatchMarshalledEventToSubApplications(eventX);
    		inPopupDataSendingDownToChildren = false;
    	}
    }
    private static var lastRemovedpopUpObject:DisplayObject;
    private static function popupRemoveHandler(event:Event):void
    {
    	lastRemovedpopUpObject = null;
    	if(!popUpObjects)
    	{
			Automation.automationDebugTracer.traceMessage("AutomationManager", "popupRemoveHandler()", "How did we get an obejct to remove without adding ? ");
    		return;
    	}
    	var obejctToBeRemoved:Object = event.target;
    	
    	// remove the current objects from the popUps
    	var currentCount:int = popUpObjects.length;
    	var index:int = 0;
    	var requiredCount: int = 0;
    	var tempArray:Array = new Array();
    	var objFound:Boolean = false;
    	while (index < currentCount)
    	{
    		if( ((popUpObjects[index]as DisplayObject).parent) != obejctToBeRemoved)
    			tempArray.push(popUpObjects[index]);
    		else
    			lastRemovedpopUpObject = popUpObjects[index];
    		index ++;
    	}
    	popUpObjects = tempArray;
    	
    
    }
    
    public function getPopUpChildren():Array
    { 
      	return popUpObjects;
    }
	
	
	public function getPopUpChildrenCount():Number
	{ 
		if (!popUpObjects)
			return 0;
		
		return popUpObjects.length;
	}
    
    public function getPopUpChildObject(index:int):IAutomationObject
    { 
    	if(index < popUpObjects.length)
    		return popUpObjects[index] as IAutomationObject;
    	
    	return null;
    }
    
    private function popupCompleteHandler(event:Event):void
    {
    	var currentObject:DisplayObjectContainer = event.target as DisplayObjectContainer;
    	addPopupChildDelegates(currentObject);
		currentObject.addEventListener(Event.ADDED, childAddedHandler, false, 0, true);
    }
    
    
    private static function addPopupChildDelegates(currentObject: DisplayObjectContainer):void
    {
    	if(currentObject)
    	{
	    	var childCount:int = currentObject.numChildren;
	    	var index:int = 0;
	    	
	    	while(index < childCount)
	    	{
	    		var childObj:DisplayObject = currentObject.getChildAt(index);
	    		createDelegate(childObj);
	    		addDelegates(childObj);
	    		addPopupChildDelegates(childObj as DisplayObjectContainer);
	    		index++;
	    	}
    	}
    }
    
    private static function dragproxyStoreRequesthandler(event:Event):void
    {
    	// we will only store one dragProxyObject
    	if(!currentDragProxyHolder)
    		currentDragProxyHolder = new Array();
    	currentDragProxyHolder[0] = event["interAppDataToMainApp"][0] as DisplayObject;
    	
    }
    
    
    private  function dragproxyRetrieveRequesthandler(event:Event):void
    {
		var tempEventObj:MarshalledAutomationEvent = new MarshalledAutomationEvent(
				MarshalledAutomationEvent.DRAG_DROP_PROXY_RETRIEVE_REPLY);
		var tempArr:Array = new Array();
		if(currentDragProxyHolder && currentDragProxyHolder.length!= 0)
			tempArr.push(currentDragProxyHolder[0]);
		else
			tempArr.push(null);
		tempEventObj.interAppDataToSubApp = tempArr;
		currentDragProxyHolder = new Array();
					
    	dispatchMarshalledEventToSubApplications(tempEventObj);
    }
    
    public  function storeDragProxy(dragProxy:Object):void
    {
    	// if the drag start happened in the sandbox root we wont get the event 
    	// corresponding to the dragProxyReciever, so we need to store it explicitly
    	if(!currentDragProxyHolder)
       			currentDragProxyHolder = new Array();
       			
	    	currentDragProxyHolder[0] = dragProxy;
    }
    private static function dragProxyReciever(event:Event):void
    {
       	if(event["name"] == "popUpChildren.addChild")
       	{
       		if(!currentDragProxyHolder)
       			currentDragProxyHolder = new Array();
       			
	    	currentDragProxyHolder[0] = event["value"];
       	}
    }
    
    private var inSynchronizationSendingToChildren:Boolean = false;
    private  function synchronizationHandler(event:Event):void
    {
    	// we get this event when an application has started drag start
    	// and we get this in all applications. 
    	
    	if(event is MarshalledAutomationEvent)
    		return;
    		
    	if(inSynchronizationSendingToChildren)
    		return;
    		
    	// we need this method so that it calls the synchronization 
    	// method to clear the current status.
    	isSynchronized(null);
    	
    	inSynchronizationSendingToChildren = true;
    	
    	// we should pass the information to our children also
    	var event1:MarshalledAutomationEvent = MarshalledAutomationEvent.marshal(event);
    	dispatchMarshalledEventToSubApplications(event1);
    	
    	inSynchronizationSendingToChildren = false;
    }
    
    private static function isCurrentAppSandboxRoot(passedSystemManager:ISystemManager):Boolean
    {
    	var retVal:Boolean = false;
    	try
		{
			// get the root of the system manager of the current application
			if(passedSystemManager["root"] && (passedSystemManager.getSandboxRoot() == passedSystemManager["root"]))
				retVal =  true;
		}
		catch(e:Error)
		{
			
		}
		
		return retVal;
    }
    
    private static function getMainListenerObject(passedSystemManager:ISystemManager, passedMarshaledSystemManager:IMarshalSystemManager):IEventDispatcher
    {
    	var requiredObj:IEventDispatcher ;
    	if(passedSystemManager)
		{
			// we need to use the sanbox root if we belong to the 
    		// same security domain as that of the root applucation
			requiredObj = passedSystemManager.getSandboxRoot();
			//var passedMarshaledSystemManager:IMarshalSystemManager = passedSystemManager as IMarshalSystemManager;
		
			if (passedMarshaledSystemManager && passedMarshaledSystemManager.useSWFBridge() && (isCurrentAppSandboxRoot(passedSystemManager) == true))
			{
				// this application is not the root level application, but it is 
				// first application of the security domain. So this objects's mainListenerObj is 
				// parent brige
				requiredObj = passedMarshaledSystemManager.swfBridgeGroup.parentBridge;
			}
		}
		return requiredObj;
    }
    
    private  function addListenerToParentApplication(obj:IEventDispatcher):void
    {
		// as an application X we need to listen to the events coming from the parent. 
		// these events are always sent from the parent to the child. So these events are listened by 
		// the children on their parent. When we recieve the event,if we are not handling these, we should 
		// pass the same to the children. i.e always sent from the parent -> child. These events are 
		// handled by the children. i,e these are always added on the parent. 
   			
	 		obj.addEventListener(MarshalledAutomationEvent.BEGIN_RECORDING, marhsalledBeginRecordHandler,false,0,true);
   			
			obj.addEventListener(MarshalledAutomationEvent.END_RECORDING, marhsalledEndRecordHandler,false,0,true);
   			
			//obj.addEventListener(MarshalledAutomationEvent.ENV_DETAILS , envDetailsEventHandler, false, 0, true);
   			if((obj as SystemManager)&& (obj as SystemManager).getSandboxRoot())
				((obj as SystemManager).getSandboxRoot()).removeEventListener(MarshalledAutomationEvent.POPUP_HANDLER_REQUEST , popupHandlerBeforeApplicationCompletion, false);
			
			obj.addEventListener(MarshalledAutomationEvent.POPUP_HANDLER_REQUEST , popupHandler, false, 0, true);
   			
			obj.addEventListener(MarshalledAutomationEvent.UPDATE_SYCHRONIZATION,synchronizationHandler, false, 0, true);
   			
			obj.addEventListener(MarshalledAutomationEvent.INITIAL_DETAILS_REPLY,initialDetailsReplyHandler, false, 0, true);
			
			 obj.addEventListener(MarshalledAutomationEvent.START_POINT_REPLY,startPointReplyHandler, false, 0, true);
   			
			obj.addEventListener(MarshalledAutomationEvent.UNIQUE_APPID_REPLY , uniqueAppIdReplyHandler, false, 0, true);
			
			obj.addEventListener(MarshalledAutomationEvent.DRAG_DROP_PERFORM_REQUEST_TO_SUB_APP ,dragDropPerformRequesthandlerInSubApp, false, 0, true);
	
    }
    private  function addListenerToChildApplications(obj:IEventDispatcher):void 
    {
        // as an application x, we need to listen to these events coming from the children. 
        // these events will be processed only by the root application. so if we are not the root applicaiton 
        // we just need to dispatch these events on the parent. So always these events are from the child -> Parent.
        // i.e these events are always handled by the parent. So the listneres of the events should be added to the children.
   			
   		obj.addEventListener(MarshalledAutomationEvent.DRAG_DROP_PROXY_RETRIEVE_REQUEST, dragproxyRetrieveRequesthandler);
   			
  		obj.addEventListener(InterManagerRequest.SYSTEM_MANAGER_REQUEST,dragProxyReciever, false, 0, true);
   			
   		obj.addEventListener(MarshalledAutomationEvent.UPDATE_SYCHRONIZATION,synchronizationHandler, false, 0, true);
   			
  		obj.addEventListener(MarshalledAutomationEvent.INITIAL_DETAILS_REQUEST,initialDetailsRequestHandler, false, 0, true);
   			
   		obj.addEventListener(MarshalledAutomationEvent.UNIQUE_APPID_REQUEST , uniqueAppIdRequestHandler, false, 0, true);
   		
   		obj.addEventListener(MarshalledAutomationEvent.START_POINT_REQUEST , startPointRequestHandler, false, 0, true);
   		
   		obj.addEventListener(MarshalledAutomationEvent.DRAG_DROP_PERFORM_REQUEST_TO_ROOT_APP,dragDropPerformRequesthandlerInRootApp, false, 0, true);
	

	  }
    
    private function dragDropPerformRequesthandlerInSubApp(event:Event):void
    {
    	if(event is MarshalledAutomationEvent)
    		return;
    	
    	// take the details and check whether the object belongs to us.
    	var details:Array  = event["interAppDataToSubApp"];
    	if(details && details.length  == 2)
    	{
	    	var target:IUIComponent = details[0] as IUIComponent;
	    	if(target)
	    	{
	    		DragManagerAutomationImpl.setForcefulDragStart();
	    		var passedEventObj:Object = details[1];
	    		var dragEventInCurrentDomain:DragEvent = new DragEvent(passedEventObj["type"]);
	    		dragEventInCurrentDomain.action = passedEventObj["action"];
	    		dragEventInCurrentDomain.localX = passedEventObj["localX"];
	    		dragEventInCurrentDomain.localY= passedEventObj["localY"];
	    		
	    		DragManagerAutomationImpl.recordAutomatableDragDrop1(target as DisplayObject , dragEventInCurrentDomain);
	    	}
	    
    	}
    		
    }
    
    private function dragDropPerformRequesthandlerInRootApp(event:Event):void
    {
    	if(event is MarshalledAutomationEvent)
    		return;
    	
    	// take the details and check whether the object belongs to us.
    	var details:Array  = event["interAppDataToMainApp"];
    	if(details.length  == 2)
    	{
	    	var target:IUIComponent = details[0] as IUIComponent;
	    	if(target)
	    	{
	    		DragManagerAutomationImpl.setForcefulDragStart();
	    		var passedEventObj:Object = details[1];
	    		var dragEventInCurrentDomain:DragEvent = new DragEvent(passedEventObj["type"]);
	    		dragEventInCurrentDomain.action = passedEventObj["action"];
	    		dragEventInCurrentDomain.localX = passedEventObj["localX"];
	    		dragEventInCurrentDomain.localY= passedEventObj["localY"];
	    		DragManagerAutomationImpl.recordAutomatableDragDrop1(target as DisplayObject ,dragEventInCurrentDomain );
	    	}
	    	else
	    	{
	    		var eventObj:MarshalledAutomationEvent = new MarshalledAutomationEvent(MarshalledAutomationEvent.DRAG_DROP_PERFORM_REQUEST_TO_SUB_APP );
	    		eventObj.interAppDataToSubApp = details;
	    		dispatchToAllChildren(eventObj);
	    		
	    	}
    	}
    		
    }
    
    private static var listenerAdded:Boolean = false;
    /* this funciton is to add the required event listeners of
    automation manger */
    
    private  function addListenerToAllApplications(passedListenerObj:IEventDispatcher,
    	passedSystemManager:ISystemManager,passedMarshaledSystemManager:IMarshalSystemManager,fromAirWindow:Boolean = false):void
    {
    	
    	//var passedMarshaledSystemManager:IMarshalSystemManager = passedSystemManager as IMarshalSystemManager;
    	if(!passedMarshaledSystemManager)
    		return;
    		
    	// we need to take all the children and add listener to all the child 
    	// bridges in these application.
    	// an application in a different securty domain or applicaiton domain, when they
    	// have their child application, they have a bridge corresponding to their child application
    	// so the main application need to listen to all their child applications.
    	
		addListenerToParentApplication(passedListenerObj);
		
		if(passedMarshaledSystemManager.useSWFBridge())
		{
			// we need a special listener to the uniqueIdReply
			// this event we will listen always to the parentBridge rather than the main
			// communication object
	    	var bridgeParent:IEventDispatcher = passedMarshaledSystemManager.swfBridgeGroup.parentBridge;
	    	if(bridgeParent)
	    	{
	    		bridgeParent.addEventListener(MarshalledAutomationEvent.UNIQUE_APPID_REPLY,
	    			uniqueAppIdReplyHandler, false, 0, true);
	    		bridgeParent.addEventListener(MarshalledAutomationEvent.START_POINT_REPLY,
	    			startPointReplyHandler, false, 0, true);
	    	}
    	}
    
		
		// only the sandbox root applicaiton needs to listen to the communication over the main listener object
		if (fromAirWindow || (isCurrentAppSandboxRoot(passedSystemManager as ISystemManager)))
    		addListenerToChildApplications(passedSystemManager.getSandboxRoot());
  		
  			
		if (!passedMarshaledSystemManager.swfBridgeGroup)
			return;
		
    	var children:Array = passedMarshaledSystemManager.swfBridgeGroup.getChildBridges();
		for (var i:int; i < children.length; i++)
		{
		 	var childBridge:IEventDispatcher = IEventDispatcher(children[i]);
		 	addListenerToChildApplications(childBridge);
		}
		listenerAdded = true;
	
    }    
     
    public  function dispatchToParent(event:Event):void
    {
    	if(mainListenerObj.hasEventListener(event.type))
    		mainListenerObj.dispatchEvent(event);
    }
    
    private  function dispatchToBridgeParent(event:Event):void
    {
    	if(!sm1MSm)
    		return;
    		
    	var bridgeParent:IEventDispatcher = sm1MSm.swfBridgeGroup.parentBridge;
    	if(bridgeParent.hasEventListener(event.type))
    		bridgeParent.dispatchEvent(event);
    }
    
 
 	private  function dispatchToSwfBridgeChildren(event:Event):void
    {
         dispatchToSwfBridgeChildrenOfPassedSystemManager(sm1,sm1MSm,event);
         // we need to consider the possible swf bridge children from the windows also
         dispatchToSwfBridgeChildrenOfAllWindows(event);
    }
   
    private  function dispatchToSwfBridgeChildrenOfAllWindows(event:Event):void
    {
    	var count:int  = allAirWindowList.length;
    	var index:int = 0;
    	while(index  <  count)
    	{
    		var currentWindow:IUIComponent = allAirWindowList[index]  as IUIComponent;
    		if(currentWindow)
    		{
	    		var currentWindowSysManager:ISystemManager = currentWindow.systemManager;
	    	    var currentWindowMarshaledSysManager:IMarshalSystemManager = IMarshalSystemManager(
	    	    	currentWindow.systemManager.getImplementation("mx.managers::IMarshalSystemManager"));
		
				if(currentWindowSysManager)
				{
					dispatchToSwfBridgeChildrenOfPassedSystemManager(currentWindowSysManager,currentWindowMarshaledSysManager,event);
				}
			
    		}
    		index++;
    	}
    }
    
    private function dispatchToSwfBridgeChildrenOfPassedSystemManager(passedSystemManager:ISystemManager, 
    		passedMarshalledSystemManger:IMarshalSystemManager,
    		event:Event):void
    {
    	//var passedMarshalledSystemManger:IMarshalSystemManager = passedSystemManager as IMarshalSystemManager;
    	if(!passedMarshalledSystemManger)
    		return;
    		
    	 if (!passedMarshalledSystemManger.swfBridgeGroup)
			return;
		
    	var children:Array = passedMarshalledSystemManger.swfBridgeGroup.getChildBridges();
		for (var i:int; i < children.length; i++)
		{
		 	var childBridge:IEventDispatcher = IEventDispatcher(children[i]);
		 	if(childBridge.hasEventListener(event.type))
		 		childBridge.dispatchEvent(event);
		}
    }
    
    
    public  function dispatchToAllChildren(event:Event):void
    {
    	dispatchToAllChildrenOfPassedSystemManager(sm1,sm1MSm,event,false);
    	// we need to consider the possible children of the windows also.
    	dispathcToAllWindowChildApplications(event);
		
    }
    
    private function dispathcToAllWindowChildApplications(event:Event):void
    {
    	var count:int  = allAirWindowList.length;
    	var index:int = 0;
    	while(index  <  count)
    	{
    		var currentWindow:IUIComponent = allAirWindowList[index]  as IUIComponent;
    		if(currentWindow)
    		{
	    		var currentWindowSysManager:ISystemManager = currentWindow.systemManager;
	    		var currentWindowMarshaledSysManager:IMarshalSystemManager = IMarshalSystemManager(currentWindow.systemManager.getImplementation("mx.managers::IMarshalSystemManager"));
				if(currentWindowSysManager)
				{
					dispatchToAllChildrenOfPassedSystemManager(currentWindowSysManager,currentWindowMarshaledSysManager,event,true);
				}
			
    		}
    		index++;
    	}
    }
    
    private function dispatchToAllChildrenOfPassedSystemManager(passedSystemManager:ISystemManager, passedMarshalledSystemManger:IMarshalSystemManager,event:Event, fromAirWindow:Boolean):void
    {
    	//var passedMarshalledSystemManger:IMarshalSystemManager = passedSystemManager as IMarshalSystemManager;
    	if(!passedMarshalledSystemManger)
    		return;
   
   
    	// some children (of the same application domain)
    	// will be listening to the sandboxroot of the main app only
    	// hence we need to dispatch event on this object also.
    	if(fromAirWindow || (isCurrentAppSandboxRoot(passedSystemManager)))
    		passedSystemManager.getSandboxRoot().dispatchEvent(event);
    		
       	
    	if (!passedMarshalledSystemManger.swfBridgeGroup)
			return;
		
    	var children:Array = passedMarshalledSystemManger.swfBridgeGroup.getChildBridges();
		for (var i:int; i < children.length; i++)
		{
		 	var childBridge:IEventDispatcher = IEventDispatcher(children[i]);
		 	if(childBridge.hasEventListener(event.type))
		 		childBridge.dispatchEvent(event);
		}
    }
     
    private var _inInitialDetailsRequestProcessing:Boolean = false;
    private var _inStartPointRequestProcessing:Boolean = false;
    
    private static function initMainListeners():void
    {
    	if(!_sm1MSm)
			_sm1MSm = IMarshalSystemManager(sm1.getImplementation("mx.managers::IMarshalSystemManager"));
     	
     	if(!_mainListenerObj)
     		_mainListenerObj = getMainListenerObject(sm1,_sm1MSm);
     
    }
    private  function applicationCompleteHandler(event:Event):void
    {
    	if(!(event is FlexEvent))
    		return;
    	
    	initMainListeners();
     	//_mainListenerObj.addEventListener(MarshalledAutomationEvent.POPUP_HANDLER_REQUEST , popupHandlerBeforeApplicationCompletion, false, 0, true);
     		
    	// add listener to the child bridges
    	addListenerToAllApplications(_mainListenerObj,sm1,sm1MSm);
    	
    	// process the possible popops
    	processPopupsBeforeApplicationComplete();
         // we will listen to the initial details from our parent.
	    var initialStatusRequest:MarshalledAutomationEvent = 
	    		new MarshalledAutomationEvent(MarshalledAutomationEvent.INITIAL_DETAILS_REQUEST);
	   _inInitialDetailsRequestProcessing = true;
	    dispatchToParent(initialStatusRequest);
    	
    }
   
    private  var eventDetailsFromToolToChildren:Array;
    public function addEventListenersToAllParentApplications(eventDetailsArray:Array):void
    {
    	// we dont need to store the events as we will never get a new parent.
    	addEventListeners(mainListenerObj,eventDetailsArray);
    }
    
    
    public function addEventListenersToAllChildApplications(eventDetailsArray:Array):void
    {
    	eventDetailsFromToolToChildren = eventDetailsArray;
    	
    	addEventListenersToAllChildApplicationsOfPassedSystemManager(sm1,sm1MSm,eventDetailsFromToolToChildren,false);
    	// we need to consider the child application of the windows also
    	addEventListenersToAllChildApplicationsOfAllWindows(eventDetailsFromToolToChildren);
	
    }
    
    private function addEventListenersToAllChildApplicationsOfAllWindows(eventDetailsArray:Array):void
    {
    	var count:int  = allAirWindowList.length;
    	var index:int = 0;
    	while(index  <  count)
    	{
    		var currentWindow:IUIComponent = allAirWindowList[index]  as IUIComponent;
    		if(currentWindow)
    		{
	    		var currentWindowSysManager:ISystemManager = currentWindow.systemManager;
	    		var currentWindowMarshalSysManager:IMarshalSystemManager = IMarshalSystemManager(
	    									currentWindow.systemManager.getImplementation("mx.manager::IMarshalSystemManager"));
				if(!currentWindowSysManager)
				{
					addEventListenersToAllChildApplicationsOfPassedSystemManager(currentWindowSysManager,currentWindowMarshalSysManager,eventDetailsArray,true);
				}
			
    		}
    		index++;
    	}
    }
    
    private function addEventListenersToAllChildApplicationsOfPassedSystemManager(passedSystemManager:ISystemManager,
    	passedMarshalledSystemManger:IMarshalSystemManager,
    		eventDetailsArray:Array,fromAirWindow:Boolean):void
    {
   	  	//var passedMarshalledSystemManger:IMarshalSystemManager = passedSystemManager as IMarshalSystemManager;
    	if(!passedMarshalledSystemManger)
    		return;
   
   
    	if(fromAirWindow || (isCurrentAppSandboxRoot(passedSystemManager)))
    		addEventListeners(passedSystemManager.getSandboxRoot(),eventDetailsArray);
    	
 		
    	if (!passedMarshalledSystemManger.swfBridgeGroup)
			return;
		
    	var children:Array = passedMarshalledSystemManger.swfBridgeGroup.getChildBridges();
		for (var i:int; i < children.length; i++)
		{
		 	var childBridge:IEventDispatcher = IEventDispatcher(children[i]);
		 	addEventListeners(childBridge,eventDetailsArray);
		}
    } 
    
    private function childBridgeHandler(event:FlexChangeEvent):void
    {
    	// get the new bridge of the current application and add listeners to the same
    	var currentBridge:IEventDispatcher = event.data as IEventDispatcher;
    	handleBridge(currentBridge);
    	
    }
    
    private function handleBridge(currentBridge:IEventDispatcher):void
    {
    	if(currentBridge)
    	{
    		addEventListeners(currentBridge,eventDetailsFromToolToChildren);
    		addListenerToChildApplications(currentBridge);
    	}
    }
    
    private function addEventListeners(obj:IEventDispatcher, eventDetailsArray:Array):void
    {
    	// it is quite possible that tool library has not supported marshaling
    	// and hence these arrays would not have been initialised
    	if(!eventDetailsArray)
    		return;
    	var count:int = eventDetailsArray.length;
    	var index:int = 0;
    	
    	while(index < count)
    	{
    		var currentEventDetailsObj:EventDetails = eventDetailsArray[index] as EventDetails;
    		if(currentEventDetailsObj)
			{
		    			obj.addEventListener(currentEventDetailsObj.eventType, 
		    				currentEventDetailsObj.handlerFunction,
		    				currentEventDetailsObj.useCapture, 
		    				currentEventDetailsObj.priority, 
		    				currentEventDetailsObj.useWeekRef);
			}
    		index++;
    	}
    } 
   
    
    private function initialDetailsRequestHandler(event:Event):void
    {
    	if (event is MarshalledAutomationEvent)
    		return;
    		
       	var replyEvent:MarshalledAutomationEvent = new 
    		 MarshalledAutomationEvent(MarshalledAutomationEvent.INITIAL_DETAILS_REPLY);
    	// order of the elements in the array should not changed across versions.
    	// if some information is needed in further versions it needs to be added after this
    	// and handler can handle the data appropriately.
    	var tempArr:Array = new Array();
		tempArr.push(_recording);
		tempArr.push(_automationEnvironmentHandlingClassName);
		tempArr.push(_automationEnvironmentString);
		replyEvent.interAppDataToSubApp = tempArr;
		dispatchToAllChildren(replyEvent);
    }
  
  	private function startPointRequestHandler(event:Event):void
    {
    	if (event is MarshalledAutomationEvent)
    		return;
    	var windowId:String = event["interAppDataToMainApp"][0] as String;	
       	var replyEvent:MarshalledAutomationEvent = new 
    		 MarshalledAutomationEvent(MarshalledAutomationEvent.START_POINT_REPLY);
    	if(sm1.isTopLevelRoot() == false)
    	{
    		dispatchStartPointRequestEvent(windowId);
    		var tempArr:Array = new Array();
    		//var p:Point = AutomationHelper.getStageStartPointInScreenCoords(windowId);
    		tempArr.push(_appStartPoint.x);
    		tempArr.push(_appStartPoint.y);
		
			replyEvent.interAppDataToSubApp = tempArr;
			dispatchToAllChildren(replyEvent);
    	}	 
    		 
    	if(sm1.isTopLevelRoot() == true)
    	{	//start point request should be handled only by main application
    		//i.e., top level root application
    		var tempArr1:Array = new Array();
    		var p:Point = AutomationHelper.getStageStartPointInScreenCoords(windowId);
    		tempArr1.push(p.x);
    		tempArr1.push(p.y);
		
			replyEvent.interAppDataToSubApp = tempArr1;
			dispatchToAllChildren(replyEvent);
    	}
    }
    
    private function initialDetailsReplyHandler(event:Event):void
	{
		// Marshalling events are needeed across applicaiton domain
		// so this conversion shall fail in the same domain
		if(event is MarshalledAutomationEvent)
			return;
		
		 if (!_inInitialDetailsRequestProcessing)
    		return;
    	
    	_inInitialDetailsRequestProcessing = false;
    	

		
		if(sm1.isTopLevelRoot() == false)
		{
			try
	        {
				var interAppData:Array = event["interAppDataToSubApp"];
				_recording = interAppData[0] as Boolean;
				if(_recording == true)
				{
					_recording = false; // to make the beginRecording call happen
					beginRecording();
				}
				_automationEnvironmentString = interAppData[2];
				_automationEnvironmentHandlingClassName = interAppData[1];
				var envClass:Class = Class(getDefinitionByName(_automationEnvironmentHandlingClassName)); //( "mx.automation.tool.ToolEnvironment"));
				if (envClass != null)
	            {
	              _automationEnvironment = new envClass(new XML(_automationEnvironmentString));
	            }
			}
	        catch(e:Error)
	        {
	        	
	        }
		}  
	}
	
	private function startPointReplyHandler(event:Event):void
	{
		// Marshalling events are needeed across application domain
		// so this conversion shall fail in the same domain
		if(event is MarshalledAutomationEvent)
			return;
		
		 if (!_inStartPointRequestProcessing)
    		return;
    	
    	_inStartPointRequestProcessing = false;
		
		if(sm1.isTopLevelRoot() == false)
		{
			try
	        {
				var interAppData:Array = event["interAppDataToSubApp"];
				_appStartPoint = new Point(interAppData[0] as Number, interAppData[1] as Number);
			}
	        catch(e:Error)
	        {
	        	
	        }
		}  
	}
	
	
	private function getObjectIdInCurrentApplication(objectPassed:DisplayObject):String
	{
		
		if(!objectPassed)
			return null;
		
		var idString:String = null;
		var orderArraay:Array = new Array();
		try
		{
    		var object:DisplayObject = objectPassed;
    		var parent:DisplayObjectContainer = object.parent;
    		while(object &&  parent && (parent!= sm1))
    		{
    			orderArraay.push(getChildIndex1(parent,object));
    			object = parent;
    			parent = object.parent;
    		}
    		idString = orderArraay.join("");
		}
		catch(e:Error)
		{
			
		}
		return idString;
	}	
	private var _inUniqueAppIdRequestProcessing:Boolean = false;
	
	private function dispatchUniqueAppIdRequestEvent():void
	{
		if(!sm1MSm)
			return;
			
		_inUniqueAppIdRequestProcessing = true;
		var appIdReqEvent:MarshalledAutomationEvent = new MarshalledAutomationEvent(
	    			MarshalledAutomationEvent.UNIQUE_APPID_REQUEST);
		var tempArray:Array = new Array();
		tempArray.push(sm1MSm.swfBridgeGroup.parentBridge);
		appIdReqEvent.interAppDataToMainApp = tempArray;
		
		dispatchToBridgeParent(appIdReqEvent);
		    	
	}
	
	public function registerNewApplication(application:DisplayObject):void
	{
		if(!(application is Application || isSparkApplication(application)))
			return;
		
		if(application.root == sm1)
			return;
		
		application.root.addEventListener(FlexChangeEvent.ADD_CHILD_BRIDGE , childBridgeHandler);
		handleAlreadyPresentBridges(application);
	}
	
	private function handleAlreadyPresentBridges(application:DisplayObject):void
	{
		var currentSysManager:IMarshalSystemManager = (application as IUIComponent).systemManager as IMarshalSystemManager
		
		if(!currentSysManager)
			return;
			
		var childBridges:Array;
		if(currentSysManager && currentSysManager.swfBridgeGroup)
			childBridges = currentSysManager.swfBridgeGroup.getChildBridges();
		if(childBridges && childBridges.length)
		{
			var len:int = childBridges.length;
			var index:int = 0;
			while(index < len)
			{
				handleBridge(childBridges[index] as IEventDispatcher);
				index++;
			}
		}
	}
	
	public function registerNewFlexNativeMenu(menu:Object, sm:DisplayObject):void
	{
		createDelegateForFlexNativeMenu(menu, sm);
	}
	
	private function createDelegateForFlexNativeMenu(menu:Object, sm:DisplayObject):Boolean
	{
		var component:IAutomationObject = menu as IAutomationObject;
		var retValue:Boolean = false;
		var appDomain:ApplicationDomain;
		var className:String = "mx.controls::FlexNativeMenu";
		if(!sm)
		{
	        var factory:IFlexModuleFactory = ModuleManager.getAssociatedFactory(menu);
	        if (factory != null)
    	    {
        	    appDomain = ApplicationDomain(factory.info()["currentDomain"]);
	        }
	        else
	        {
	        	var message:String = "Factory module failure";
				traceMessage("AutomationManager","createDelegateForFlexNativeMenu()",message);
	        }
		}
		else
		{
			appDomain = (sm.loaderInfo) ? sm.loaderInfo.applicationDomain :
											ApplicationDomain.currentDomain;
		}
		
		var compClass:Class = appDomain.getDefinition(className) as Class;
		var mainComponentClass:Class = compClass;
		var delegateClass:Class = Automation.delegateDictionary[compClass] as Class;
		
		if(!delegateClass)
		{
			var componentClass:String = className;
			do 
			{
				try 
				{
					className = getQualifiedSuperclassName(appDomain.getDefinition(className));
					compClass = appDomain.getDefinition(className) as Class;
					delegateClass = Automation.delegateDictionary[compClass] as Class;
				}
				catch(e:Error)
				{
					traceMessage("AutomationManager","createDelegateForFlexNativeMenu()",e.message);
					break;
				}
			}
			while(!delegateClass);
			
			Automation.delegateDictionary[mainComponentClass] = delegateClass; 
			//trace("Added mapping for : " + componentClass);
		}

		var c:Class = delegateClass;
		if (c)
		{
			try
			{
				var delegate:Object = new c (menu);
			}
			catch(e:Error)
			{
				Automation.automationDebugTracer.traceMessage("AutomationManager","createDelegateForFlexNativeMenu()",e.message);
				Automation.automationDebugTracer.traceMessage("AutomationManager","createDelegateForFlexNativeMenu()","Delegate object could not be created");
			}
			
			try
			{
				component.automationDelegate = delegate;
				retValue = true;
			}
			catch(e:Error)
			{
				Automation.automationDebugTracer.traceMessage("AutomationManager","createDelegateForFlexNativeMenu()",e.message);
				Automation.automationDebugTracer.traceMessage("AutomationManager","createDelegateForFlexNativeMenu()","object created but delegates not set");
			}
		}
		else
			Automation.automationDebugTracer.traceMessage("AutomationManager","createDelegateForFlexNativeMenu()", "Unable to find definition for class : " + className);
			
		return retValue;
	}
	
	public function registerNewWindow(newWindow:DisplayObject):void
	{
		// we need to find a uniqueId for this window in Automation Manager
		// we are forming the unique id string as 
		// 'applicationName'::_::AIRWindow_index
		lastRegisteredWindowCount++;
		var currentWindowId:String = Automation.getMainApplication().automationName+ airWindowIdFixedString+
			String(lastRegisteredWindowCount);
		
		// we need bi directional mapping as we get the id we need to identify the window
		// later from the plugin
		allAirWindowsToIdDictionary[newWindow] = currentWindowId;
		allAirIdToWindowsDictionary[currentWindowId] = newWindow;
		// store the window in the list so that we can analyse the windows for eventhandling part.
		allAirWindowList.push(newWindow);
		
		// we need to dispatch an event so that tool library will try to coomunicate 
		// to the plugin using this id to get associate the hwnd with this id.
		dispatchEvent(new AutomationAirEvent(AutomationAirEvent.NEW_AIR_WINDOW,
			true,true,currentWindowId));
			
		inMouseSequence = false;
		createDelegate(newWindow);
		addDelegates(newWindow);
		newWindow.stage.addEventListener(Event.ADDED, childAddedHandler, false, 0, true);
		
		
		
		
		var sm2:ISystemManager = (newWindow  as IUIComponent).systemManager;
		var sm2MSm:IMarshalSystemManager = IMarshalSystemManager((newWindow  as IUIComponent).systemManager.getImplementation("mx.managers::IMarshalSystemManager"));
		if(!sm2)
			return;
			
			var windowMainListenerObj:IEventDispatcher = getMainListenerObject(sm2,sm2MSm);
			
			addListenerToAllApplications(windowMainListenerObj,sm2,sm2MSm,true);
			addEventListenersToAllChildApplicationsOfPassedSystemManager(sm2,sm2MSm,eventDetailsFromToolToChildren,true);
			
			sm2.addEventListener(FlexChangeEvent.ADD_CHILD_BRIDGE , childBridgeHandler);
			sm2.addEventListener(AutomationRecordEvent.RECORD,
            						recordHandler, false, EventPriority.DEFAULT_HANDLER, true);
         
            sm2.getSandboxRoot().addEventListener(MouseEvent.MOUSE_DOWN,
                                captureIDFromMouseDownEvent, true, 0, true);
                               
            sm2.addEventListener(KeyboardEvent.KEY_DOWN,
                                captureIDFromKeyDownEvent, true, 0, true);
            //ideally we would listen in the bubble phase so
            //we'd get this last and all components have had a chance
            //to react and record events, but some components are stopping
            //the propagation so capture first and flush events
            //in a delayed manner
            sm2.getSandboxRoot().addEventListener(MouseEvent.CLICK,
                                onEndMouseSequence, true, 0, true);
            sm2.getSandboxRoot().addEventListener(MouseEvent.DOUBLE_CLICK,
                                onEndMouseSequence, true, 0, true);
                                
           //	sm2.getSandboxRoot().addEventListener(SandboxMouseEvent.CLICK_SOMEWHERE,
           //                     onEndMouseSequence, true, 0, true);
           // sm2.getSandboxRoot().addEventListener(SandboxMouseEvent.DOUBLE_CLICK_SOMEWHERE,
            //                    onEndMouseSequence, true, 0, true);
                                
            sm2.addEventListener(KeyboardEvent.KEY_UP,
                                onEndKeySequence, true, 0, true);
            //Ideally we'd flush events after the last click (or double click)
            //however the player has a bug where it doesn't always send click
            //events (and also there can be legitimate times when a click
            //event won't come through, souch as a mouse down, mouse move off 
            //the component then a mouse up), so do a timed flush after the
            //mouse up (it needs to be after any click events that might occur)
            sm2.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP,
                                onEndMouseSequence, true, 0, true);
            //sm2.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE,
              //                  onEndMouseSequence, true, 0, true);
			sm2.getSandboxRoot().addEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler, false, 0, true);
		
			
			
	}
	
    public function getAIRWindowUniqueID(newWindow:DisplayObject):String
    {
    	return allAirWindowsToIdDictionary[newWindow];
    }
  
	
	 public function getApplicationNameFromAutomationIDPart(objectIdPart:AutomationIDPart):String
     {
     	
        // check whether the current class is an AIR window as it is the another object
        // which can be the first level 
        // we have added a property by name 'applicationName' which is applicable only 
        // for the top level windows for AIR
        if (objectIdPart.hasOwnProperty(AutomationManager.airWindowIndicatorPropertyName))	
        {
        	// get the automationName
        	//var currentAutomationName:String = objectIdPart["automationName"];
        	var currentAutomationName:String = getPassedUniqueName(objectIdPart);
        	var appNameArray:Array = currentAutomationName.split(airWindowIdFixedString);
        	if(appNameArray && appNameArray.length)
        		return appNameArray[0];
        }
        	
        // if we reach here we are not the AIR top level window 
        // hence we can use the automationName to get the automation class name
	  	 //return (objectIdPart["automationName"].toString());
	  	 return getPassedUniqueName(objectIdPart);
     }
	private function getPassedUniqueName(part:AutomationIDPart):String
	{
		if(part.hasOwnProperty("automationName"))
	 	{
	 		if(part["automationName"] is RegExp)
	 		{
	 			var obj1:RegExp = part["automationName"] as RegExp;
	 			return obj1.source;
	 		}
	 		else
	   			return (part["automationName"].toString());
	   		
	  	}
	 	else if(part.hasOwnProperty("id"))
	 	{
	 		if(part["id"] is RegExp)
	 		{
	 			var obj:RegExp = part["id"] as RegExp;
	 			return obj.source;
	 		}
	 		else
	   			return (part["id"].toString());
	  	}
	  	else
 		{
 			// if we dont get any of the above conditions, we cannot support the
 			// marhslling. Hence we assume it is a single application scenario
 			// and get the current application name
   			return getUniqueApplicationID();
   		}
	}
	
	public function getAIRWindow(windowId:String):DisplayObject
	{
		if(windowId=="")
			return Automation.getMainApplication() as DisplayObject;
			
		return allAirIdToWindowsDictionary[windowId];
	}
	
	
	
   
   public function getAIRWindowUniqueIDFromObjectIDString(objectId:String ):String
   {
   		var objectID:AutomationID  = AutomationID.parse(objectId);
   		
   		// clone the automationID
	    var rid:AutomationID = objectID.clone();
           
        //remove the application
        var objectIdPart:AutomationIDPart = rid.removeFirst();
        
        return getAIRWindowUniqueIDFromAutomationIDPart(objectIdPart);
   }
   
   public function getAIRWindowUniqueIDFromAutomationIDPart(objectIdPart:AutomationIDPart ):String
   {
        
   	   // check whether the current class is an AIR window as it is the another object
        // which can be the first level 
        // we have added a property by name 'applicationName' which is applicable only 
        // for the top level windows for AIR
        if (objectIdPart.hasOwnProperty(AutomationManager.airWindowIndicatorPropertyName))	
        {
        	// get the automationName
        	//return objectIdPart["automationName"];
        	return getPassedUniqueName(objectIdPart);
        
        }
        // if we reach here we are not the AIR top level window 
        // hence we can use the automationName to get the automation class name
	  	 return null;
   }
   
   public  function getTopApplicationIndex(objectList:Array):int
    {
    	// we need to find the application which can be on the top. This is based on 
    	// the order of the SWFLoader not based on the order of applicaiton loading.
    	// let us for the application name list.
    	if(objectList)
    	{
    		var count:int  = objectList.length;
    		if(count > 1)
    		{
	    		var appNames:Array = new Array();
	    		var selectedObjectIndices:Array = new Array();
	    		var index:int  = 0;
	    		while(index < count)
	    		{
	    			var curentObj:Object = objectList[index];
	    			appNames.push(curentObj["applicationName"]); 
	    			selectedObjectIndices.push(index);
	    			index++;
	    		}
	    		
	    		var requiredIndex:int = 0;
	    		var higherOrderObject:Array = new Array();
	    		var indexToSort:int = 1;
	    		while(selectedObjectIndices.length > 1)
	    		{
	    			 var resultObj:Object = sortCurrentList(appNames,selectedObjectIndices,indexToSort);
	    			 appNames = new Array();
	    			 selectedObjectIndices = new Array();
	    			 appNames = resultObj["slectedAppNames"] as Array;
	    			 selectedObjectIndices = resultObj["selectedObjectIndices"]  as Array;
	    			 indexToSort = indexToSort+2;
	    		}
	    		
	    		return selectedObjectIndices[0];
    		}
    		else 
    			return 0;
    		
    		
    	}
    	return -1; 
    }
    
    private function sortCurrentList(passedNamesArray:Array , passesSelectedObjectIndices:Array, indexToSort:int):Object
    {
    	// find the higher order swf loader number from the current object.
    	var  highestSwfOrder:int = -1;
    	var count:int = passedNamesArray.length;
    	var index:int  = 0;
    	var selectedAppNames:Array = new Array();
    	var selectedObjectIndices:Array = new Array();
      	while(index < count)
    	{
    		var splitNames:Array = (passedNamesArray[index]as String).split("_");// TBD use constant
    		if(splitNames.length > indexToSort)
    		{
    			var currentOrderNumber:int = int(splitNames[splitNames.length-indexToSort-1]);
    			if( currentOrderNumber > highestSwfOrder)
    			{
    				highestSwfOrder = currentOrderNumber;
    				// clear the current order info arrays 
    				selectedAppNames = new Array();
    				selectedObjectIndices = new Array();
    				selectedAppNames.push(passedNamesArray[index]);
    				selectedObjectIndices.push(passesSelectedObjectIndices[index]);
    			}
    			else if (currentOrderNumber == highestSwfOrder)
    			{
    				selectedAppNames.push(passedNamesArray[index]);
    				selectedObjectIndices.push(passesSelectedObjectIndices[index]);
    			}
    		}
    		index++;
    	}
    	
    	var resultObj:Object = { slectedAppNames:selectedAppNames, selectedObjectIndices:selectedObjectIndices};
    	
    	return resultObj;
    	
    }
	
	public  function getAutomationChildrenArray(object:Object):Array
	{
		var automationObject:IAutomationObject = object as IAutomationObject;
		var childArray:Array = null;
		if (automationObject)
		{
			childArray =  automationObject.getAutomationChildren();
		}
		/*
		if(object.hasOwnProperty("getAutomationChildren") )
			return object.getAutomationChildren();
		if(object.automationDelegate.hasOwnProperty("getAutomationChildren") )
			return object.automationDelegate.getAutomationChildren();
		*/
		if(childArray)
			return childArray;
		
		// let us ensure that we are not returning a null array.
		return new Array();
	}
	public function  getPropertyValueFromPart(part:Object,obj:Object, 
											  pd:IAutomationPropertyDescriptor,
											  relativeParent:IAutomationObject = null):Object
	{
		return getMemberFromPartOrObject(part,obj, pd.name);
		
	}
	
	
	
	public function getMemberFromPartOrObject(part:Object,obj:Object, 
											  name:String):Object
	{
		//var part:Object;
		var component:Object;
		
		//part = createIDPart(obj as IAutomationObject);
		component = obj;
		
		var result:Object = null;
		
		if (part != null && name in part)
			result = part[name];
		else if (name in obj)
			result = obj[name];
		else if (component != null)
		{
			if (name in component)
				result = component[name];
			else if (component is IStyleClient)
				result = IStyleClient(component).getStyle(name);
		}
		
		return result;
	}
	
	
	/**
	 *  @private
	 */
	/*
	public function createIDPartForSpecifiedProperties(properties:Array,
													   obj:IAutomationObject, 
													   parent:IAutomationObject = null):AutomationIDPart
	{
		// create the part only with the requried properties
		if (parent == null)
			parent = getParent(obj, null, true);
	
		return helpCreateIDPartWithRequiredProperties(parent, obj,properties);		
	}
	*/
	
	/**
	 *  @private
	 */
	public function createIDPartForSpecifiedProperties(properties:Array,obj:IAutomationObject, 
								 parent:IAutomationObject = null):AutomationIDPart
	{
		if (parent == null)
			parent = getParent(obj, null, true);
		
		var parentObj:Object = parent as Object;
		// temp solution till we get the interfaces part of UIComponent
		
			var part:AutomationIDPart = parent 
			? parent.createAutomationIDPartWithRequiredProperties(obj,properties) as AutomationIDPart
			: helpCreateIDPartWithRequiredProperties(null, obj,properties);

		/*
		var part:AutomationIDPart = (parentObj &&(parentObj.automationDelegate) && (parentObj.automationDelegate.hasOwnProperty("createAutomationIDPartWithRequiredProperties")))
				? parentObj.automationDelegate.createAutomationIDPartWithRequiredProperties(obj,properties) as AutomationIDPart
				: helpCreateIDPartWithRequiredProperties(null, obj,properties);
		*/
		
		return part;
	}
	
	
	/**
	 *  @private
	 *
	 *  Helper implementation of IAutomationIDHelper.  Creates an id for
	 *  a given child.  This should not be used, instead use createID,
	 *  or createIDPart.
	 */
	
	public function helpCreateIDPartWithRequiredProperties(parent:IAutomationObject,
														  child:IAutomationObject,properyNamesList:Array,
														  automationNameCallback:Function = null,
														  automationIndexCallback:Function = null):AutomationIDPart
	{
		if(!properyNamesList)
			return helpCreateIDPart(parent,child,automationNameCallback,automationIndexCallback);
		else
			return getIdPart(parent,child,properyNamesList,automationNameCallback,automationIndexCallback);
	}
	
	
	private function getIdPart(parent:IAutomationObject,
							   child:IAutomationObject,properyNamesList:Array = null,
							   automationNameCallback:Function = null,
							   automationIndexCallback:Function = null):AutomationIDPart
	{
		var part:AutomationIDPart = new AutomationIDPart();
		//It doesn't matter if a property is null
		//add it anyways, because the callee asked for it
		//and not adding it will confuse QTP since we've
		//told it already about the properties in the env file
		//If this causes a problem and we need to add the if
		//null checks back, then be sure to update ToolAdapter
		//to not return null properties in Learn and ActiveScreen
		var indexCalculated:Boolean = false;
		for (var propNo:int = 0; propNo < properyNamesList.length; ++propNo)
		{
			var propertyName:String = properyNamesList[propNo];
			
			if (propertyName == "id")
			{
				part.id = child is IDeferredInstantiationUIComponent
					? IDeferredInstantiationUIComponent(child).id
					: null;    
				
				if ((part.id == null) && (parent == null))
				{ 
					//trace ("inside the helpCreateIDPart - id "+ child.automationName);
					// currently we are in the application object.
					// this is a temp fix till we have AIR delegates in place.
					// we need the application iD of this component instead of the id
					if(Automation.getMainApplication().hasOwnProperty("applicationID"))// this should work for AIR app's
					{
						part.id = Automation.getMainApplication().applicationID;
						//trace ("inside the helpCreateIDPart - id "+ part.id );
					}
					else
					{
						//we are in flex app hosted from Air app
						part.id = processAppIDFromUniqueAppID();
					}
				}
			}
			else if (propertyName == "automationName")
				part.automationName = (automationNameCallback == null 
					? child.automationName 
					: automationNameCallback(child));
			else if (propertyName == "automationIndex")
			{
				//note that parent can be null if it's the parentApplication
				part.automationIndex = (automationIndexCallback == null ? 
					getChildIndex(getParent(child), child)
					: automationIndexCallback(child));
				indexCalculated = true;
			}
			else if (propertyName == "className")
				part.className = AutomationClass.getClassName(child);
			else if (propertyName == "automationClassName")
				part.automationClassName = getAutomationClassName(child);
			else if (propertyName == AutomationManager.airWindowIndicatorPropertyName)
			{
				// we added this property to identify the airtoplevel windows
				part.isAIRWindow = true;
			}
			else
			{
				if (propertyName in child)
					part[propertyName] = child[propertyName];
				else
				{
					part[propertyName] = "";
					/// TBD
					
					var message:String = resourceManager.getString(
						"automation_agent", "notDefined", [propertyName, child]);
					//trace(message);
					/*
					throw new Error(message);
					*/
				}
			}
		}
		
		if ("automationName" in part && part.automationName == null)
		{
			
			if(indexCalculated)
				part.automationName = part.automationIndex;
			else
			{
				// calculate the index and assign the same as the automation value
				part.automationName = (automationIndexCallback == null ? 
					getChildIndex(getParent(child), child)
					: automationIndexCallback(child));
			}
		}
		
		return part;
	}
	
	public function traceMessage(className:String, methodName:String, message:String):void
	{
		trace(className+":"+methodName+" - "+message);
	}
	
	private function isSparkApplication(obj:DisplayObject):Boolean
	{
		if(AutomationHelper.isRequiredSparkClassPresent()){
			var sparkAppClass:Class = Class(ApplicationDomain.currentDomain.getDefinition("spark.components.Application"));
			if(obj is sparkAppClass)	
				return true;
		}
			
		return false;
	}
}

}
