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

package mx.automation.tool
{
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	
	import mx.automation.Automation;
	import mx.automation.AutomationClass;
	import mx.automation.AutomationConstants;
	import mx.automation.AutomationError;
	import mx.automation.AutomationHelper;
	import mx.automation.AutomationID;
	import mx.automation.AutomationIDPart;
	import mx.automation.IAutomationClass;
	import mx.automation.IAutomationEventDescriptor;
	import mx.automation.IAutomationManager2;
	import mx.automation.IAutomationMethodDescriptor;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationPropertyDescriptor;
	import mx.automation.IAutomationTabularData;
	import mx.automation.codec.AdvancedDataGridSelectedCellCodec;
	import mx.automation.codec.ArrayPropertyCodec;
	import mx.automation.codec.AssetPropertyCodec;
	import mx.automation.codec.AutomationObjectPropertyCodec;
	import mx.automation.codec.ChartItemCodec;
	import mx.automation.codec.ColorPropertyCodec;
	import mx.automation.codec.DatePropertyCodec;
	import mx.automation.codec.DateRangePropertyCodec;
	import mx.automation.codec.DateScrollDetailPropertyCodec;
	import mx.automation.codec.DefaultPropertyCodec;
	import mx.automation.codec.FilePropertyCodec;
	import mx.automation.codec.HitDataCodec;
	import mx.automation.codec.IAutomationPropertyCodec;
	import mx.automation.codec.KeyCodePropertyCodec;
	import mx.automation.codec.KeyModifierPropertyCodec;
	import mx.automation.codec.ListDataObjectCodec;
	import mx.automation.codec.RendererPropertyCodec;
	import mx.automation.codec.ScrollDetailPropertyCodec;
	import mx.automation.codec.ScrollDirectionPropertyCodec;
	import mx.automation.codec.TabObjectCodec;
	import mx.automation.codec.TriggerEventPropertyCodec;
	import mx.automation.events.AutomationAirEvent;
	import mx.automation.events.AutomationCustomReplayEvent;
	import mx.automation.events.AutomationRecordEvent;
	import mx.automation.events.EventDetails;
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.controls.SWFLoader;
	import mx.core.EventPriority;
	import mx.core.FlexGlobals;
	import mx.core.mx_internal;
	import mx.managers.IMarshalSystemManager;
	import mx.managers.ISystemManager;
	import mx.managers.PopUpManager;
	import mx.managers.SystemManager;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import spark.automation.codec.SparkDropDownListBaseSelectedItemCodec;
	
	use namespace mx_internal;
	
	[ResourceBundle("automation_agent")]
	[ResourceBundle("tool_air")]
	
	/** 
	 *  @private
	 */
	public class ToolAdapter implements IToolCodecHelper
	{
		include "../../core/Version.as";
		
		
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Captures all properties of all objects in the application's active 
		 *  window/dialog box/Web page in the Active Screen of each step.
		 *  This means that all objects can be added to object repository /
		 *  added checkpoints, etc. 
		 *  @private
		 */
		public static const COMPLETE:uint = 0;
		
		/**
		 *  (Default). Captures all properties of all objects in the application's
		 *  active window/dialog box/Web page in the Active Screen of the first
		 *  step performed in an application's window, plus all properties
		 *  of the recorded object in subsequent steps in the same window
		 *  (it is an optimization of Complete mode). 
		 *  As in Complete mode, in this mode, all objects can be added to object 
		 *  repository / added checkpoints, etc. 
		 *  @private
		 */
		public static const PARTIAL:uint = 1;
		
		/**
		 *  Captures properties only for the recorded object and its parent in the
		 *  Active Screen of each step.
		 *  This means that only the recorded objects and its parents can be added
		 *  to object repository / added checkpoints, etc. 
		 *  @private
		 */
		public static const MINIMUM:uint = 2;
		
		/**
		 *  Disables capturing of Active Screen files for all applications
		 *  and Web pages.
		 *  This means no Active Screen will be shown. 
		 *  @private
		 */
		public static const NONE:uint = 3;
		
		
		// indicates what type of application is being automation currently.
		/**
		 *  @private
		 */	
		public static const ApplicationType_Flex:int = 0;
		/**
		 *  @private
		 */
		public static const ApplicationType_AIR:int = 1;
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */	
		private static var isInitialized:Boolean = false;
		
		/**
		 *  @private
		 */	
		private static var qtpCodecHelper:IToolCodecHelper;
		
		
		/**
		 *  @private
		 */
		public static var _applicationType:int = -1;
		
		/**
		 *  @private
		 */
		public static var _applicationId:String;
		
		/**
		 *  @private
		 */	
		//private  var sandboxRoot:IEventDispatcher;
		
		
		/**
		 *  @private
		 *  The highest place we can listen for events in our DOM
		 */
		private static var mainListenerObj:IEventDispatcher;
		
		
		/**
		 *  @private
		 */	
		private var lastApplicationName:String;
		
		/**
		 *  @private
		 */	
		private var lastRequestName:String;
		
		
		/**
		 *  @private
		 */	
		private var requestPending:Boolean;
		
		
		/**
		 *  @private
		 */	
		private var requestResultObjArray:Array;
		
		/**
		 *  @private
		 */	
		private var resultRecieved:Boolean;
		
		/**
		 *  @private
		 */
		private var sm:ISystemManager;
		
		/**
		 *  @private
		 */
		// private var _smMSm:IMarshalSystemManager;
		
		/*
		public function get smMSm():IMarshalSystemManager
		{
		if(!_smMSm)
		_smMSm = IMarshalSystemManager(sm.getImplementation("mx.managers::IMarshalSystemManager"));
		
		return _smMSm;
		}
		*/
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function ToolAdapter()
		{
			super();
			sm = FlexGlobals.topLevelApplication.systemManager;
			//smMSm = sm as IMarshalSystemManager;
			//_smMSm = IMarshalSystemManager((FlexGlobals.topLevelApplication.systemManager as SystemManager).getImplementation("max.manager::IMarshalSystemManager"));
			//_smMSm = IMarshalSystemManager((Automation.getMainApplication().systemManager as SystemManager).getImplementation("max.manager::IMarshalSystemManager"));
			// working line _smMSm = IMarshalSystemManager(sm.getImplementation("mx.managers::IMarshalSystemManager"));
			
			
			// the following code is to take care of Marshalling in Automation
			// we need to handle all the methods which can reach Tool (which will be a part of
			// main applicaiton. We need to send the information about this function call to other applications.
			//sandboxRoot = sm.getSandboxRoot();
			
			// these events are coming from the main application and the children are listening to the main application
			if(sm.isTopLevelRoot() == false)
			{
				var eventDetailsToListenFromParent:Array = new Array();
				eventDetailsToListenFromParent.push(new EventDetails(ToolMarshallingEvent.FIND_OBJECTIDS,
					interAppRequestHandler));
				eventDetailsToListenFromParent.push(new EventDetails(ToolMarshallingEvent.RUN,
					interAppRequestHandler));
				eventDetailsToListenFromParent.push(new EventDetails(ToolMarshallingEvent.GET_ACTIVESCREEN,
					interAppRequestHandler));
				eventDetailsToListenFromParent.push(new EventDetails(ToolMarshallingEvent.GET_PARENT,
					interAppRequestHandler));
				eventDetailsToListenFromParent.push(new EventDetails(ToolMarshallingEvent.GET_RECTANGLE,
					interAppRequestHandler));
				eventDetailsToListenFromParent.push(new EventDetails(ToolMarshallingEvent.GET_ELEMENT_FROM_POINT,
					interAppRequestHandler));
				eventDetailsToListenFromParent.push(new EventDetails(ToolMarshallingEvent.GET_ELEMENT_TYPE,
					interAppRequestHandler));
				eventDetailsToListenFromParent.push(new EventDetails(ToolMarshallingEvent.GET_DISPLAY_NAME,
					interAppRequestHandler));
				eventDetailsToListenFromParent.push(new EventDetails(ToolMarshallingEvent.GET_PROPERTIES,
					interAppRequestHandler));
				eventDetailsToListenFromParent.push(new EventDetails(ToolMarshallingEvent.BUILD_DESCRIPTION,
					interAppRequestHandler));
				eventDetailsToListenFromParent.push(new EventDetails(ToolMarshallingEvent.GET_CHILDREN,
					interAppRequestHandler));
				eventDetailsToListenFromParent.push(new EventDetails(ToolMarshallingEvent.LEARN_CHILD_OBJECTS,
					interAppRequestHandler));
				eventDetailsToListenFromParent.push(new EventDetails(ToolMarshallingEvent.GET_LAST_ERROR,
					interAppRequestHandler));
				eventDetailsToListenFromParent.push(new EventDetails(ToolMarshallingEvent.SET_LAST_ERROR,
					interAppRequestHandler));
				eventDetailsToListenFromParent.push(new EventDetails(ToolMarshallingEvent.GET_TABULAR_ATTRIBUTES,
					interAppRequestHandler));
				eventDetailsToListenFromParent.push(new EventDetails(ToolMarshallingEvent.GET_TABULAR_DATA,
					interAppRequestHandler));
				
				automationManager.addEventListenersToAllParentApplications(eventDetailsToListenFromParent);
				//addEventListenersToAllParentApplications(eventDetailsToListenFromParent);
			}
			
			
			
			
			var eventDetailsToListenFromChildren:Array = new Array();
			eventDetailsToListenFromChildren.push(new EventDetails(ToolMarshallingEvent.FIND_OBJECTIDS_REPLY,
				interAppReplyHandler));
			eventDetailsToListenFromChildren.push(new EventDetails(ToolMarshallingEvent.RUN_REPLY,
				interAppReplyHandler));
			eventDetailsToListenFromChildren.push(new EventDetails(ToolMarshallingEvent.GET_ACTIVESCREEN_REPLY,
				interAppReplyHandler));
			eventDetailsToListenFromChildren.push(new EventDetails(ToolMarshallingEvent.GET_PARENT_REPLY,
				interAppReplyHandler));
			eventDetailsToListenFromChildren.push(new EventDetails(ToolMarshallingEvent.GET_RECTANGLE_REPLY,
				interAppReplyHandler));
			eventDetailsToListenFromChildren.push(new EventDetails(ToolMarshallingEvent.GET_ELEMENT_FROM_POINT_REPLY,
				interAppReplyHandler));
			eventDetailsToListenFromChildren.push(new EventDetails(ToolMarshallingEvent.GET_ELEMENT_TYPE_REPLY,
				interAppReplyHandler));
			eventDetailsToListenFromChildren.push(new EventDetails(ToolMarshallingEvent.GET_DISPLAY_NAME_REPLY,
				interAppReplyHandler));
			eventDetailsToListenFromChildren.push(new EventDetails(ToolMarshallingEvent.GET_PROPERTIES_REPLY,
				interAppReplyHandler));
			eventDetailsToListenFromChildren.push(new EventDetails(ToolMarshallingEvent.BUILD_DESCRIPTION_REPLY,
				interAppReplyHandler));
			eventDetailsToListenFromChildren.push(new EventDetails(ToolMarshallingEvent.GET_CHILDREN_REPLY,
				interAppReplyHandler));
			eventDetailsToListenFromChildren.push(new EventDetails(ToolMarshallingEvent.LEARN_CHILD_OBJECTS_REPLY,
				interAppReplyHandler));
			eventDetailsToListenFromChildren.push(new EventDetails(ToolMarshallingEvent.GET_LAST_ERROR_REPLY,
				interAppReplyHandler));
			eventDetailsToListenFromChildren.push(new EventDetails(ToolMarshallingEvent.GET_TABULAR_ATTRIBUTES_REPLY,
				interAppReplyHandler));
			eventDetailsToListenFromChildren.push(new EventDetails(ToolMarshallingEvent.GET_TABULAR_DATA_REPLY,
				interAppReplyHandler));
			eventDetailsToListenFromChildren.push(new EventDetails(ToolMarshallingEvent.RECORD,
				marhsalledRecordHandler));
			
			automationManager.addEventListenersToAllChildApplications(eventDetailsToListenFromChildren);
			
			automationManager.addEventListener(AutomationRecordEvent.RECORD,recordHandler, false, EventPriority.DEFAULT_HANDLER, true);
			automationManager.addEventListener(AutomationAirEvent.NEW_AIR_WINDOW,newWindowHandler);
			
			if (!isInitialized)
			{
				isInitialized = true;
				
				qtpCodecHelper = this;
				
				// Add the default serializers.
				addPropertyCodec(
					"object", new DefaultPropertyCodec());
				
				addPropertyCodec(
					"keyCode", new KeyCodePropertyCodec());
				
				addPropertyCodec(
					"keyModifier", new KeyModifierPropertyCodec());
				
				addPropertyCodec(
					"object[]", new ArrayPropertyCodec(new DefaultPropertyCodec()));
				
				addPropertyCodec(
					"color", new ColorPropertyCodec());
				
				addPropertyCodec(
					"color[]", new ArrayPropertyCodec(new ColorPropertyCodec()));
				
				addPropertyCodec(
					"automationObject", new AutomationObjectPropertyCodec());
				
				addPropertyCodec(
					"automationObject[]",
					new ArrayPropertyCodec(new AutomationObjectPropertyCodec()));
				
				addPropertyCodec(
					"asset", new AssetPropertyCodec());
				
				addPropertyCodec(
					"asset[]", new ArrayPropertyCodec(new AssetPropertyCodec()));
				
				addPropertyCodec(
					"listDataObject", new ListDataObjectCodec());
				
				addPropertyCodec(
					"listDataObject[]",
					new ArrayPropertyCodec(new ListDataObjectCodec()));
				
				addPropertyCodec(
					"rendererObject", new RendererPropertyCodec());
				
				addPropertyCodec(
					"dateRange", new DateRangePropertyCodec());
				
				addPropertyCodec(
					"dateObject", new DatePropertyCodec());
				
				addPropertyCodec(
					"dateRange[]",
					new ArrayPropertyCodec(new DateRangePropertyCodec()));
				
				addPropertyCodec(
					"event", new TriggerEventPropertyCodec());
				
				addPropertyCodec(
					"tab", new TabObjectCodec());
				
				addPropertyCodec(
					"scrollDetail", new ScrollDetailPropertyCodec());
				
				addPropertyCodec(
					"dateScrollDetail", new DateScrollDetailPropertyCodec());
				
				addPropertyCodec(
					"scrollDirection", new ScrollDirectionPropertyCodec());
				
				addPropertyCodec(
					"AdvancedDataGridSelectedCell[]", new ArrayPropertyCodec(new AdvancedDataGridSelectedCellCodec()));
				
				addPropertyCodec(
					"ChartItemCodec", new ChartItemCodec()); 
				
				addPropertyCodec(
					"ChartItemCodec[]", new ArrayPropertyCodec(new ChartItemCodec()));
				
				addPropertyCodec(
					"hitDataCodec[]", new ArrayPropertyCodec(new HitDataCodec()));
				
				addPropertyCodec(
					"fileCodec", new FilePropertyCodec());
				
				addPropertyCodec(
					"SparkDropDownListBaseSelectedItem", new SparkDropDownListBaseSelectedItemCodec());
				
				
				/*
				This portion of the code is removed to make the automation_dmv source compilable in Flex Builder source.
				
				Why this code was used :
				To make the application which does not need the datavisuaalisation components, not including these codes
				The required codecs were supposed to be present in the automation_dmv swc and hence only if the user
				provides this swc, these classes would have been loaded.
				But to make these classes under the automation_dmv , we bring the dependancy of qtp and automation source
				as the codecs use IToolProper.... class. Hence we cannot compile them independantly
				
				try
				{
				// check for availability of chart codec.
				// it may not be available if user has not included chart delegates
				var codec:Object = getDefinitionByName("mx.automation.codec.HitDataCodec");
				
				addPropertyCodec(
				"hitDataCodec[]", new ArrayPropertyCodec(new codec()));
				}
				catch(e:Error)
				{
				}
				*/
				
				var message:String;
				/*
				
				
				if (Capabilities.playerType != "ActiveX")
				{
				message = resourceManager.getString(
				"automation_agent", "notActiveX");
				trace(message);
				return;
				}
				
				if (! Capabilities.os.match(/^Windows/))
				{
				message = resourceManager.getString(
				"automation_agent", "notWindows", [Capabilities.os]);
				trace(message);
				return;
				}
				
				if (!ExternalInterface.available)
				{
				message = resourceManager.getString(
				"automation_agent", "noExternalInterface");
				trace(message);
				return;
				}
				
				if (!playerID || playerID.length == 0)
				{
				message = resourceManager.getString(
				"automation_agent", "noPlayerID");
				trace(message);
				return;
				}
				
				if (playerID.match(/[\.-]/))
				{
				message = resourceManager.getString(
				"automation_agent", "invalidPlayerID", [playerID]);
				trace(message);
				return;
				}
				*/
				
				try
				{
					//ToolAgent.initSocket();
					//beginRecording();
					
					/*
					// for js driver
					ExternalInterface.addCallback("SetTestingEnvironment", 
					setTestingEnvironment);
					
					// Add QTP callbacks
					ExternalInterface.addCallback("GetParent", getParent);
					ExternalInterface.addCallback("GetChildren", getChildren);
					ExternalInterface.addCallback("BuildDescription", buildDescription);
					ExternalInterface.addCallback("FindObjectId", findObjectID);
					ExternalInterface.addCallback("FindObjectId2", findObjectIDs);
					ExternalInterface.addCallback("GetDisplayName", getDisplayName);
					ExternalInterface.addCallback("GetElementType", getElementType);
					ExternalInterface.addCallback("GetProperties", getProperties);
					ExternalInterface.addCallback("GetTabularData", getTabularData);
					ExternalInterface.addCallback("GetTabularAttributes", 
					getTabularAttributes);
					ExternalInterface.addCallback("Run", run);
					ExternalInterface.addCallback("GetLastError", getLastError);
					ExternalInterface.addCallback("SetLastError", setLastError);
					ExternalInterface.addCallback("BeginRecording", beginRecording);
					ExternalInterface.addCallback("EndRecording", endRecording);
					ExternalInterface.addCallback("GetElementFromPoint", 
					getElementFromPoint);
					ExternalInterface.addCallback("GetRectangle", getRectangle);
					ExternalInterface.addCallback("GetActiveScreen", getActiveScreen);
					ExternalInterface.addCallback("LearnChildObjects", learnChildObjects);
					
					// Register ActiveX plugin
					ExternalInterface.call("eval", 
					"try { window._mx_testing_plugin_" + playerID + 
					" = new ActiveXObject('TEAPluginIE.TEAFlexAgentIE'); }" +
					"catch(e) { document.getElementById('" + playerID + 
					"').SetLastError(e.message); } ");
					
					if (lastError)
					{
					message = resourceManager.getString(
					"automation_agent", "unableToLoadPluginGeneric",
					[lastError.message]);
					trace(message);
					return;
					}
					
					ExternalInterface.call("eval", 
					"if (!window._mx_testing_plugin_" + playerID + 
					".RegisterPluginWithQTP(self, " + "'" + playerID + "')) {" +
					"document.getElementById('" + playerID + 
					"').SetLastError('TEAPluginIE.TEAFlexAgentIE is not scriptable'); }");
					
					if (lastError)
					{
					message = resourceManager.getString(
					"automation_agent", "unableToLoadPluginGeneric",
					[lastError.message]);
					trace(message);
					return;
					}
					
					// Load environment XML
					var te:String = ExternalInterface.call("window._mx_testing_plugin_" + 
					playerID + 
					".GetTestingEnvironment");               
					setTestingEnvironment(te);
					*/
					
				}
				catch (se:SecurityError)
				{
					message = resourceManager.getString(
						"automation_agent", "unableToLoadPluginGeneric",
						[se.message]);
					Automation.automationDebugTracer.traceMessage("ToolAdapter","ToolAdapter()",message);
				}
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
		private var lastError:Error;
		
		/**
		 *  @private
		 */
		private var propertyCodecMap:Object = [];
		
		/**
		 *  @private
		 *  Used for accessing localized Error messages.
		 */
		private static var resourceManager:IResourceManager =
			ResourceManager.getInstance();
		
		/**
		 *  @private
		 *  Used for accessing localized Error messages.
		 */
		private var detailsSentToTool :Boolean = false;
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  automationManager
		//----------------------------------
		
		/**
		 *  @private
		 */
		private function get automationManager():IAutomationManager2
		{
			//return Automation.automationManager ;
			return Automation.automationManager2 as IAutomationManager2;
		}
		
		//----------------------------------
		//  playerID
		//----------------------------------
		
		/**
		 *  @private
		 */
		private function get playerID():String 
		{ 
			return FlexGlobals.topLevelApplication.id;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Registers a custom codec to encoding an decoding of object properties and
		 *  event properties to and from a testing tool.  For example, ColorPicker
		 *  events can contain the selected color.  A special color codec is provided
		 *  to encode and decode colors from their native number format to hex.
		 *
		 *  Predefined codecs include:
		 *      "" - The default codec that supports basic types such as String, Number, int and uint.
		 *      "color" - Converts a number to hex.
		 *      "keyCode" - Converts a keyCode number to a human readable string
		 *      "keyState" - Converts ctrlKey, shiftKey and altKey booleans to a human 
		 *                   readable bitfield string.
		 *      "skin" - Converts a skin asset class name to closely resemble it's 
		 *               original asset name.  Path separators and periods in the orignal
		 *               path name will be converted to underscores.  This is only available
		 *               on readonly properties.
		 *      "automationObject" - Converts an object to it's automationName.
		 *
		 *  @param codecName the name of the codec.
		 * 
		 *  @param codec the implementation of the codec.
		 */
		private function addPropertyCodec(codecName:String, codec:IAutomationPropertyCodec):void
		{
			propertyCodecMap[codecName] = codec;
		}
		
		
		/**
		 *  @private
		 */
		public function setTestingEnvironment(te:String):void
		{
			//trace (te);
			automationManager.automationEnvironment = new ToolEnvironment(new XML(te));
			
			// For supportig Marshalling we need the env information as string and
			// the name of the class which interprets the information
			// this information will be used by the Automation Manger in each of the AppDomain
			// to intialise the class with the details.
			// #IMP: MARSHALLING NOTE#: The name of the class needs to be maintained across versions
			// However the implementation of the class can be different in each version.
			automationManager.automationEnvironmentString = te;
			automationManager.automationEnvironmentHandlingClassName = "mx.automation.tool.ToolEnvironment";
		}
		
		/**
		 *  Encodes a single value to a testing tool value.  Unlike encodeProperties which
		 *  takes an object which contains all the properties to encode, this method
		 *  takes the actual value to encode.  This is useful for encoding return values.
		 *
		 *  @param obj the value to be encoded.
		 * 
		 *  @param propertyDescriptor the property descriptor that describes this value.
		 * 
		 *  @param relativeParent the IAutomationObject that is related to this value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function encodeValue(value:Object, 
									testingToolType:String,
									codecName:String,
									relativeParent:IAutomationObject):Object
		{
			//setup a fake descriptor and object to send to the codec
			var pd:ToolPropertyDescriptor = 
				new ToolPropertyDescriptor("value",
					false, 
					false, 
					testingToolType, 
					codecName);
			var obj:Object = {value:value};
			return getPropertyValue(obj, pd, relativeParent);
		}
		
		
		public function getPropertyValue(obj:Object, 
										 pd:ToolPropertyDescriptor,
										 relativeParent:IAutomationObject = null):Object
		{
			var codec:IAutomationPropertyCodec = propertyCodecMap[pd.codecName];
			
			if (codec == null)
				codec = propertyCodecMap["object"];
			
			if (relativeParent == null)
				relativeParent = obj as IAutomationObject;
			
			return codec.encode(automationManager, obj, pd, relativeParent);
		}
		
		/**
		 *  Encodes properties in an AS object to an array of values for a testing tool
		 *  using the codecs.  Since the object being passed in may not be an IAutomationObject 
		 *  (it could be an event class) and some of the properties require the
		 *  IAutomationObject to be transcoded (such as the item renderers in
		 *  a list event), relativeParent should always be set to the relevant
		 *  IAutomationObject.
		 *
		 *  @param obj the object that contains the properties to be encoded.
		 * 
		 *  @param propertyDescriptors the property descriptors that describes the properties for this object.
		 * 
		 *  @param relativeParent the IAutomationObject that is related to this object.
		 *
		 *  @return the encoded property value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function encodeProperties(obj:Object,
										 propertyDescriptors:Array,
										 interactionReplayer:IAutomationObject):Array
		{
			var result:Array = [];
			var consecutiveDefaultValueCount:Number = 0;
			for (var i:int = 0; i < propertyDescriptors.length; i++)
			{
				var val:Object = getPropertyValue(obj, 
					propertyDescriptors[i],
					interactionReplayer);
				
				var isDefaultValueNull:Boolean = propertyDescriptors[i].defaultValue == "null";
				
				consecutiveDefaultValueCount = (!(val == null && isDefaultValueNull) &&
					(propertyDescriptors[i].defaultValue == null || 
						val == null ||
						propertyDescriptors[i].defaultValue != val.toString())
					? 0
					: consecutiveDefaultValueCount + 1);
				
				result.push(val);
			}
			
			result.splice(result.length - consecutiveDefaultValueCount, 
				consecutiveDefaultValueCount);
			
			return result;
		}
		
		
		
		/**
		 *  @private
		 */
		private function getValuesWithTypeInformation(elemetnsArray:Array):Array
		{
			var count:int = elemetnsArray.length;
			var index:int = 0;
			
			var currentArgsArray:Array= new Array();
			
			while(index  < count)
			{
				var currentObject:Object =  elemetnsArray[index];
				var currentObjectType:String = getQualifiedClassName(currentObject);
				
				var currentobjString:String;
				if(currentObject == null)
					currentobjString = ClientSocketHandler.nullValueIndicator;
				else
					currentobjString = currentObject.toString();
				
				var currentArgString:String = currentObjectType+ ClientSocketHandler.typeValueSeparator + currentobjString;
				currentArgsArray.push(currentArgString);
				
				index++;
			}
			
			return  currentArgsArray;
		}
		
		/**
		 *  @private
		 */
		private function handleIncompleteRecord(event:Event):void
		{
			if (!automationManager.isSynchronized(null))
			{
				var myTimer:Timer = new Timer(1000,1);
				myTimer.addEventListener("timer", handleIncompleteRecord);
				myTimer.start();
			}
			else
			{
				
				var objectId2Object:Object = findObjectIDs(currentDescriptionXMLString);
				var objectId2Array:Array = (objectId2Object["result"] as Array);
				var objectId2String:String ="";
				if(objectId2Array)
				{
					var completeString:String;
					objectId2String = objectId2Array.join(ClientSocketHandler.objectIdSeparators);
					objectId2String = objectId2Array.join(ClientSocketHandler.objectIdSeparators);
					completeString = recordInfoString+ objectId2String + ClientSocketHandler.recordInfoSeparator;
					
					var request1:RequestData = new RequestData();
					request1.requestID = ClientSocketHandler.activeScreenDataStoreRequestString;
					request1.requestData = activeScreenString;
					
					var request2:RequestData = new RequestData();
					request2.requestID = ClientSocketHandler.recordRequestString;
					request2.requestData = completeString;
					
					if(sm.isTopLevelRoot() == false)
					{
						// send the event to the root applicaiton and let it take care of the socket communication.
						var marshalledEvent:ToolMarshallingEvent = new ToolMarshallingEvent(
							ToolMarshallingEvent.RECORD);
						
						// #IMP: MARSHALLING NOTE#: This order of ariguments should not be changed 
						// across versions. If any new arguements is needed in new versions 
						// add them to the end of the list and handle appropriately in the 
						// handler of this event.
						var recordDetails:Array = new Array();
						recordDetails.push(request1);
						recordDetails.push(request2);
						marshalledEvent.interAppDataToMainApp = recordDetails;
						
						dispatchEventToParent(marshalledEvent);
						
					}
					else
					{
						if(ToolAgent.clientSocketHandler)
						{
							(ToolAgent.clientSocketHandler).addToRecordRequestQueue(request1);
							(ToolAgent.clientSocketHandler).addToRecordRequestQueue(request2);
							
							//trace ("calling processQueuedRecordRequests ToolAgent");
							(ToolAgent.clientSocketHandler).processQueuedRecordRequests(true);
						}
					}
					/*
					Application.application.alpha= appAlpha;
					Application.application.enabled = true; */
					ClientSocketHandler.enableApplication();
				}
			}
		}
		
		private var recordInfoString:String;
		private var activeScreenString:String;
		private var currentDescriptionXMLString:String;
		private var appAlpha:int = -1;
		private function recordHandler(event:AutomationRecordEvent):void
		{
			if(event.isDefaultPrevented())
				return;
			
			automationManager.incrementCacheCounter();
			
			try
			{
				var obj:IAutomationObject = event.automationObject ;
				var rid:AutomationID = automationManager.createID(obj);
				var descriptionXML:XML = getDescriptionXML(rid, obj);
				
				// We are storing the actual pretty printing value so that we can
				// reset it back when we are done with our operation.
				// Ref: http://bugs.adobe.com/jira/browse/FLEXENT-1140
				var actualPrettyPrinting:Boolean = XML.prettyPrinting;
				
				XML.prettyPrinting = false;
				var parentRids:Array = [];
				
				while (obj)
				{
					rid = automationManager.createID(obj);
					parentRids.push(rid.toString());
					obj = automationManager.getParent(obj);
				}
				
				// the last rid corresponds to the highest parent
				// get the window id for this obejct
				// clone the automationID
				var rid1:AutomationID = rid.clone();
				//get the first part
				var objectIdPart:AutomationIDPart = rid1.removeFirst();
				var windowId:String = automationManager.getAIRWindowUniqueIDFromAutomationIDPart(objectIdPart);
				
				
				var completeString:String = parentRids.join(":|:");
				completeString=completeString.concat(ClientSocketHandler.recordInfoSeparator,descriptionXML.toXMLString(),ClientSocketHandler.recordInfoSeparator,event.name);
				// now we have parentRids | descriptionXML | event name in the complete string
				
				
				// for the argument arrays
				var argsArray:Array = event.args as Array;
				if(argsArray)
				{
					var argLength:int = argsArray.length;
					
					if(argLength != 0)
					{
						var argString :String = (getValuesWithTypeInformation(event.args as Array)).join(ClientSocketHandler.eventArgsSeparator) ;
						//completeString=completeString.concat(ClientSocketHandler.recordInfoSeparator,event.args.join(ClientSocketHandler.eventArgsSeparator),ClientSocketHandler.recordInfoSeparator);
						completeString=completeString.concat(ClientSocketHandler.recordInfoSeparator,argString,ClientSocketHandler.recordInfoSeparator);
						
					}
					else
						completeString=completeString.concat(ClientSocketHandler.recordInfoSeparator,ClientSocketHandler.recordNoArgIndicator,ClientSocketHandler.recordInfoSeparator);
				}
				else
					completeString=completeString.concat(ClientSocketHandler.recordInfoSeparator,ClientSocketHandler.recordNoArgIndicator,ClientSocketHandler.recordInfoSeparator);
				// now we have the argument details also in the complete string
				
				
				// get the active screen details
				// before sending the record details , capture the active screen details and send
				// for the time being we dont have the player coordinates in screen coordinates
				// we need the top offset and left offset of the player
				
				// we need the stage start points
				
				//get the point for sub apps using automation manager's API, that returns main 
				//air app's start point. Retuns null if this is main air app
				var stageStartCoordinate:Point = automationManager.getStartPointInScreenCoordinates(windowId);
				
				if(!stageStartCoordinate)	//null if this is main air app
					stageStartCoordinate = getStageStartPointInScreenCoords(windowId);
				
				if(!stageStartCoordinate)
					stageStartCoordinate = new Point(0,0);
				
				// we would have got the message for this. so the user is not expected to proceed.
				// the above is done to avoid the null obejct access.
				
				
				var resultObj:Object = getActiveScreen(0,parentRids[0],stageStartCoordinate.x,stageStartCoordinate.y);
				// var activeScreenData:String = resultObj.result;
				activeScreenString = resultObj.result;
				
				// calculate object ID string
				var objectId2Object:Object = findObjectIDs(descriptionXML.toXMLString());
				var objectId2Array:Array = (objectId2Object["result"] as Array);
				var objectId2String:String ="";
				if(objectId2Array)
				{
					objectId2String = objectId2Array.join(ClientSocketHandler.objectIdSeparators);	
					completeString = completeString+ objectId2String + ClientSocketHandler.recordInfoSeparator;
					
					var request1:RequestData = new RequestData();
					request1.requestID = ClientSocketHandler.activeScreenDataStoreRequestString;
					request1.requestData = activeScreenString;
					
					var request2:RequestData = new RequestData();
					request2.requestID = ClientSocketHandler.recordRequestString;
					request2.requestData = completeString;
					
					
					if(sm.isTopLevelRoot() == false)
					{
						// send the event to the root applicaiton and let it take care of the socket communication.
						var marshalledEvent:ToolMarshallingEvent = new ToolMarshallingEvent(
							ToolMarshallingEvent.RECORD);
						
						// #IMP: MARSHALLING NOTE#: This order of ariguments should not be changed 
						// across versions. If any new arguements is needed in new versions 
						// add them to the end of the list and handle appropriately in the 
						// handler of this event.
						var recordDetails:Array = new Array();
						recordDetails.push(request1);
						recordDetails.push(request2);
						marshalledEvent.interAppDataToMainApp = recordDetails;
						
						dispatchEventToParent(marshalledEvent);
						
					}
					else
					{
						if(ToolAgent.clientSocketHandler)
						{
							(ToolAgent.clientSocketHandler).addToRecordRequestQueue(request1);
							(ToolAgent.clientSocketHandler).addToRecordRequestQueue(request2);
							
							//trace ("calling processQueuedRecordRequests ToolAgent");
							(ToolAgent.clientSocketHandler).processQueuedRecordRequests(true);
						}
					}
					
				}
				else
				{
					/*
					appAlpha = Application.application.alpha;
					Application.application.alpha= .4;
					Application.application.enabled = false;
					*/
					
					ClientSocketHandler.disableApplication();
					
					currentDescriptionXMLString = descriptionXML.toXMLString();
					recordInfoString = completeString;
					var myTimer:Timer = new Timer(1000,1);
					myTimer.addEventListener("timer", handleIncompleteRecord);
					myTimer.start();
				}
				
				
				
				
				
				
				
				//rani
				/*
				ExternalInterface.call("window._mx_testing_plugin_" + playerID + ".Record", 
				parentRids,
				descriptionXML.toXMLString(),
				event.name,
				event.args);*/
				XML.prettyPrinting = actualPrettyPrinting;
				
			}
			catch (e:Error)
			{
				lastError = e;
				Automation.automationDebugTracer.traceMessage("ToolAdapter","recordHandler()",e.message);
			}
			
			automationManager.decrementCacheCounter();
		}
		
		private function marhsalledRecordHandler(event:Event):void
		{
			// Marshalling events are needeed across applicaiton domain
			// so this conversion shall fail in the same domain
			// i.e the above check is to avoid the echoing
			if(event is ToolMarshallingEvent)
				return;
			
			// this handler is only for the main app. so if we are not the main app root 
			// application, we should not handle it, we should just pass to our parent.
			
			//if(smMSm && (smMSm.useSWFBridge() == true))
			if(sm.isTopLevelRoot() == false)
			{
				var event1:ToolMarshallingEvent = ToolMarshallingEvent.marshal(event);
				dispatchEventToParent(event1);
			}
			else
			{
				// i.e take the deta send from the sub app and call the external interface call.
				// #IMP: MARSHALLING NOTE#:
				var recordDetails:Array = event["interAppDataToMainApp"];
				if(recordDetails && recordDetails.length == 2)
				{
					/* ExternalInterface.call("window._mx_testing_plugin_" + playerID + ".Record", 
					recordDetails[0], //parentRids,
					recordDetails[1], //descriptionXML.toXMLString(),
					recordDetails[2], //event.name,
					recordDetails[3]); // event.args); */
					if(ToolAgent.clientSocketHandler)
					{
						(ToolAgent.clientSocketHandler).addToRecordRequestQueue(recordDetails[0]);
						(ToolAgent.clientSocketHandler).addToRecordRequestQueue(recordDetails[1]);
						
						//trace ("calling processQueuedRecordRequests ToolAgent");
						(ToolAgent.clientSocketHandler).processQueuedRecordRequests(true);
					}
				}
			}
		}
		
		/**
		 *  @private
		 */
		public function beginRecording():Object
		{
			return useErrorHandler(function():Object
			{
				var o:Object = { result:null, error:0 };
				automationManager.addEventListener(AutomationRecordEvent.RECORD,
					recordHandler, false, EventPriority.DEFAULT_HANDLER, true);
				automationManager.beginRecording();
				
				
				return o;
			});
		}
		
		/**
		 *  @private
		 */
		public function endRecording():Object
		{
			return useErrorHandler(function():Object
			{
				var o:Object = { result:null, error:0 };
				automationManager.endRecording();
				automationManager.removeEventListener(AutomationRecordEvent.RECORD,
					recordHandler);
				return o;
			});
		}
		
		/**
		 *  @private
		 */
		public function getElementType(objID:String, fromTool:Boolean = true):Object
		{
			return useErrorHandler(function():Object
			{
				var o:Object = { result:null, error:0 };
				try{
					var rid:AutomationID = AutomationID.parse(objID);
					var requiredApplicationName:String = getApplicationNameFromAutomationID(rid);
					var currentApplicationName:String  = getApplicationName();
					if(requiredApplicationName == currentApplicationName)
					{
						if (fromTool == true)
							detailsSentToTool = true; 
						var target:IAutomationObject = automationManager.resolveIDToSingleObject(rid);
						o.result = automationManager.getAutomationClassName(target);
					}
					else
					{
						// we need to send this as information to the other application 
						// and let the appropriate application handle it.
						
						// #IMP: MARSHALLING NOTE#: This order of ariguments should not be changed 
						// across versions. If any new arguements is needed in new versions 
						// add them to the end of the list and handle appropriately in the 
						// handler of this event.
						
						var details:Array = new Array();
						details.push(objID);	
						
						if(fromTool == true)
						{
							requestPending = false;
							resultRecieved = false;
						}
						o.result =   handleRequestToDifferentApplication(requiredApplicationName,
							ToolMarshallingEvent.GET_ELEMENT_TYPE,details);
						
						if((resultRecieved == true)&&(fromTool == true))
						{
							// since we have recieved the result, we can send the information back to QTP
							o =  requestResultObjArray[0] as Object;
							detailsSentToTool = true;
						}
					}
				}
				catch (e:Error)
				{
					throw e;
				}
				return o;
			});
		}
		
		/**
		 *  @private
		 */
		public function getDisplayName(objID:String, fromTool:Boolean = true):Object
		{
			return useErrorHandler(function():Object
			{
				var o:Object = { result:null, error:0 };
				try
				{
					var rid:AutomationID  = AutomationID.parse(objID);
					// we need to find out whether the current app and the 
					// reuired app are the same.
					var requiredApplicationName:String = getApplicationNameFromAutomationID(rid);
					var currentApplicationName:String  = getApplicationName();
					if(requiredApplicationName == currentApplicationName)
					{
						
						if (fromTool == true)
							detailsSentToTool = true;
						var target:IAutomationObject = automationManager.resolveIDToSingleObject(rid);
						o.result = automationManager.getAutomationName(target);
					}
					else
					{
						// we need to send this as information to the other application 
						// and let the appropriate application handle it.
						
						
						// #IMP: MARSHALLING NOTE#: This order of ariguments should not be changed 
						// across versions. If any new arguements is needed in new versions 
						// add them to the end of the list and handle appropriately in the 
						// handler of this event.
						
						var details:Array = new Array();
						details.push(objID);
						if(fromTool == true)
						{
							requestPending = false;
							resultRecieved = false;
						}
						o.result =   handleRequestToDifferentApplication(requiredApplicationName,
							ToolMarshallingEvent.GET_DISPLAY_NAME,details);
						if((resultRecieved == true)&&(fromTool == true))
						{
							// since we have recieved the result, we can send the information back to QTP
							o =  requestResultObjArray[0] as Object;
							detailsSentToTool = true;
						}
					}
				}
				catch(e:Error)
				{
					throw e;
				}
				return o;
			});
		}
		
		private function replayEvent(target:IAutomationObject, eventName:String, args:Array):Object
		{
			var automationClass:IAutomationClass = 
				automationManager.automationEnvironment.getAutomationClassByInstance(target);
			
			var message:String;
			
			// try to find the automation class
			if (! automationClass)
			{
				message = resourceManager.getString(
					"automation_agent", "classNotFound",
					[AutomationClass.getClassName(target)]);
				throw new Error(message);
			}
			
			var eventDescriptor:IAutomationEventDescriptor =
				automationClass.getDescriptorForEventByName(eventName);
			
			if (!eventDescriptor)
			{
				message = resourceManager.getString(
					"automation_agent", "methodNotFound",
					[eventName, automationClass]);
				throw new Error(message);
			}
			
			var retValue:Object = eventDescriptor.replay(target, args);
			return {value:retValue, type:null};
		}
		
		private function replayMethod(target:IAutomationObject, method:String, args:Array):Object
		{
			var automationClass:IAutomationClass = 
				automationManager.automationEnvironment.getAutomationClassByInstance(target);
			
			var message:String;
			
			// try to find the automation class
			if (! automationClass)
			{
				message = resourceManager.getString(
					"automation_agent", "classNotFound",
					[AutomationClass.getClassName(target)]);
				throw new Error(message);
			}
			
			var methodDescriptor:IAutomationMethodDescriptor =
				automationClass.getDescriptorForMethodByName(method);
			
			if (!methodDescriptor)
			{
				message = resourceManager.getString(
					"automation_agent", "methodNotFound",
					[method, automationClass]);
				throw new Error(message);
			}
			
			var retValue:Object = methodDescriptor.replay(target, args);
			
			if(retValue is IAutomationObject)
				retValue = automationManager.createID(IAutomationObject(retValue)).toString();
			
			return {value:retValue, type:methodDescriptor.returnType};
		}
		
		private var replayResultObj:Object = null;
		private function replayDefaultHandler(event:AutomationCustomReplayEvent):void
		{
			replayResultObj = { result:null, error:0 };
			if(event.isDefaultPrevented())
				return;
			
			automationManager.removeEventListener(AutomationCustomReplayEvent.CUSTOM_REPLAY,replayDefaultHandler);
			
			if((event.type != AutomationCustomReplayEvent.CUSTOM_REPLAY) || 
				(event.automationObject == null )||
				(event.name == null))
				return;
			
			
			
			//var o:Object = { result:null, error:0 };
			
			try
			{
				replayResultObj.result = replayMethod(event.automationObject, event.name, event.args);        	
			}
			catch(e:Error)
			{
				try
				{
					//replayResultObj.result = replayEvent(target, method, args);
					replayResultObj.result = replayEvent(event.automationObject, event.name, event.args);    	
				}
				catch(e:Error)
				{
					automationManager.decrementCacheCounter();
					throw e;
				}
			}
			
		}
		/**
		 *  @private
		 */
		public function replay(target:IAutomationObject, method:String, args:Array):Object
		{   
			// first let us dispatch the custom replay event.
			replayResultObj = null;
			
			// create the custom replay event and dispatch the same
			var customReplayEventObj:AutomationCustomReplayEvent = 
				new AutomationCustomReplayEvent(AutomationCustomReplayEvent.CUSTOM_REPLAY,false,true);
			//customReplayEventObj.cancelable should be  true. We need to make this true as the default handler can prevent the default.
			
			customReplayEventObj.automationObject = target;
			customReplayEventObj.name = method;
			customReplayEventObj.args = args;
			
			
			// dispatch the event from the automation manager.
			automationManager.addEventListener(AutomationCustomReplayEvent.CUSTOM_REPLAY,replayDefaultHandler,false,
				EventPriority.DEFAULT_HANDLER,false);
			
			automationManager.dispatchEvent(customReplayEventObj);
			return replayResultObj;
			
			
		}
		
		
		/**
		 *  @private
		 */
		public function run(objID:String, method:String, args:String, fromTool:Boolean = true):Object
		{
			return useErrorHandler(function():Object
			{
				var resultObj:Object;
				try
				{
					var rid:AutomationID = AutomationID.parse(objID);
					var requiredApplicationName:String = getApplicationNameFromAutomationID(rid);
					var currentAppName:String = getApplicationName();
					
					if(requiredApplicationName != currentAppName)
					{
						// we need to send this as information to the other application 
						// and let the appropriate application handle it.
						
						// #IMP: MARSHALLING NOTE#: This order of ariguments should not be changed 
						// across versions. If any new arguements is needed in new versions 
						// add them to the end of the list and handle appropriately in the 
						// handler of this event.
						
						var details:Array = new Array();
						details.push(objID);
						details.push(method);
						details.push(args);	
						
						if(fromTool == true)
						{
							requestPending = false;
							resultRecieved = false;
						}
						
						resultObj =  handleRequestToDifferentApplication(requiredApplicationName, 
							ToolMarshallingEvent.RUN,details);
						if((resultRecieved == true)&&(fromTool == true))
						{
							// since we have recieved the result, we can send the information back to QTP
							resultObj = requestResultObjArray[0];
							detailsSentToTool = true;
						}
					}
					else
					{
						
						if (fromTool == true)
							detailsSentToTool = true; 
						
						// *************************************** 
						var target:IAutomationObject = automationManager.resolveIDToSingleObject(rid);
						resultObj = replay(target, method, convertArrayFromCrazyToAs(args));
					}
					
					// if we have not sent the request to QTP, we need to send the error message that we are not yet synchronised
					// we need this message only if the request to this method has come from QTP			
					if((detailsSentToTool == false)&&(fromTool == true))
					{
						// we dont expect this case to happen. But just to be on the
						// safe side we are keeping this error
						var message:String = resourceManager.getString(
							"automation_agent", "notSynchronized");
						throw new AutomationError(message,
							AutomationError.OBJECT_NOT_VISIBLE);	
					}
				}
				catch(e:Error)
				{
					throw e;
				}
				
				return resultObj;
			});
		}
		
		/**
		 *  @private
		 */
		public function findObjectID(descriptionXML:String):Object
		{
			// this method is not used in 3 onwards
			// hence this method is modified to support Marshalling
			return useErrorHandler(function():Object
			{
				var o:Object = { result:null, error:0 };
				try
				{
					var rid:AutomationID = new AutomationID();
					var x:XML = new XML(descriptionXML);
					while (x)
					{
						var part:AutomationIDPart = new AutomationIDPart();
						part.automationClassName = x.@type.toString();
						var automationClass:IToolAutomationClass =
						automationManager.automationEnvironment.getAutomationClassByName(part.automationClassName) as IToolAutomationClass;
						var propertyCaseRemapping:Object = automationClass.propertyLowerCaseMap;
						
						for (var property:Object in x.Property)
						{
							var propertyName:String = x.Property[property].@name.toString().toLowerCase();
							
							if (propertyName in propertyCaseRemapping)
							{
								var propertyDescriptor:ToolPropertyDescriptor = 
								propertyCaseRemapping[propertyName];
								
								propertyName = propertyDescriptor.name;
								
								var regEx:String = x.Property[property].@regExp;
								var value:String = x.Property[property].@value;
								
								if (regEx == "true" || regEx == "t")
									part[propertyName] = new RegExp(value);
								else
									part[propertyName] = value;
							}
						}
						rid.addLast(part);
						x = x.Element.length() == 1 ? x.Element[0] : null;
					}
					
					var message:String;
					if (!automationManager.isSynchronized(null))
					{
						message = resourceManager.getString(
							"automation_agent", "notSynchronized");
						throw new AutomationError(message,
							AutomationError.OBJECT_NOT_VISIBLE);
					}	
					var obj:IAutomationObject = automationManager.resolveIDToSingleObject(rid);
					if (!automationManager.isSynchronized(obj))
					{
						message = resourceManager.getString(
							"automation_agent", "notSynchronized");
						throw new AutomationError(message,
							AutomationError.OBJECT_NOT_VISIBLE);
					}
					if (!automationManager.isVisible(obj as DisplayObject))
					{
						message = resourceManager.getString(
							"automation_agent", "invisible");
						throw new AutomationError(message,
							AutomationError.OBJECT_NOT_VISIBLE);
					}
					o.result = automationManager.createID(obj).toString();
				}
				catch(e:Error)
				{
					throw e;
				}
				
				return o;
			});
		}
		
		/**
		 *  @private
		 */
		public function findObjectIDs(descriptionXML:String, fromTool :Boolean = true):Object
		{
			return useErrorHandler(function():Object
			{
				var o:Object = { result:null, error:0 };
				var message:String;
				try
				{
					var rid:AutomationID = new AutomationID();
					var x:XML = new XML(descriptionXML);
					var partIndex:int = 0;
					
					var sameApplication:Boolean = true;
					var requiredApplicationName :String ;
					while (x && sameApplication)
					{
						var part:AutomationIDPart = new AutomationIDPart();
						part.automationClassName = x.@type.toString();
						var automationClass:IToolAutomationClass =
						automationManager.automationEnvironment.getAutomationClassByName(part.automationClassName) as IToolAutomationClass;
						var propertyCaseRemapping:Object = automationClass.propertyLowerCaseMap;
						
						for (var property:Object in x.Property)
						{
							var propertyName:String = x.Property[property].@name.toString().toLowerCase();
							
							if (propertyName in propertyCaseRemapping)
							{
								var propertyDescriptor:ToolPropertyDescriptor = 
								propertyCaseRemapping[propertyName];
								
								propertyName = propertyDescriptor.name;
								
								var regEx:String = x.Property[property].@regExp;
								var value:String = x.Property[property].@value;
								
								if (regEx == "true" || regEx == "t")
									part[propertyName] = new RegExp(value);
								else
									part[propertyName] = value;
							}
						}
						rid.addLast(part);
						
						// we need to decide whehter we are in the correct application
						if((partIndex == 0) && (fromTool == true))
						{
							requiredApplicationName = automationManager.getApplicationNameFromAutomationIDPart(part);
							//requiredApplicationName = part["automationName"][0].toString();
							var currentAppName:String = getApplicationName();
							
							// we need to check whether this request is for the
							// root application or sub application.	
							// if it is for the sub applicaiton, we need to send the information as event to the other
							// applications and wait for the result.
							if(requiredApplicationName != currentAppName )
								sameApplication = false;
						}
						partIndex++;
						x = x.Element.length() == 1 ? x.Element[0] : null;
					}
					
					if (!automationManager.isSynchronized(null))
					{
						message = resourceManager.getString(
							"automation_agent", "notSynchronized");
						throw new AutomationError(message,
							AutomationError.OBJECT_NOT_VISIBLE);	
					}	
					
					// before we call methods on the automation manger, whether this request is for the
					// root application or sub application.
					// if it is for the sub applicaiton, we need to send the information as event to the other
					// applications and wait for the result.
					if(sameApplication == true )
					{
						
						if (fromTool == true)
							detailsSentToTool = true; 
						
						//here we can proceed with the root applicaiton.
						var autObjects:Array = automationManager.resolveID(rid);
						for (var i:int = 0; i < autObjects.length; ++i)
						{
							autObjects[i] = automationManager.createID(autObjects[i]).toString();
						}
						o.result = autObjects;
						detailsSentToTool = true;
					}
					else
					{
						// #IMP: MARSHALLING NOTE#: This order of ariguments should not be changed 
						// across versions. If any new arguements is needed in new versions 
						// add them to the end of the list and handle appropriately in the 
						// handler of this event.
						
						var details:Array = new Array();
						details.push(descriptionXML);
						
						if(fromTool == true)
						{
							requestPending = false;
							resultRecieved = false;
						}
						o.result = handleRequestToDifferentApplication(requiredApplicationName,
							ToolMarshallingEvent.FIND_OBJECTIDS ,
							details); 
						
						if((resultRecieved == true)&&(fromTool == true))
						{
							// since we have recieved the result, we can send the information back to Tool
							o.result = requestResultObjArray[0];
							detailsSentToTool = true;
						}
					}
					
					// if we have not sent the request to QTP, we need to send the error message that we are not yet synchronised
					// we need this message only if the request to this method has come from QTP			
					if((detailsSentToTool == false)&&(fromTool == true))
					{
						// we dont expect this case to happen. But just to be on the
						// safe side we are keeping this error
						var message1:String = resourceManager.getString(
							"automation_agent", "notSynchronized");
						throw new AutomationError(message1,
							AutomationError.OBJECT_NOT_VISIBLE);	
					}
				}
				catch(e:Error)
				{
					throw e;
				}
				
				return o;
			});
		}
		
		/**
		 *  @private
		 */
		public function buildDescription(objID:String, fromTool:Boolean = true):Object
		{
			return useErrorHandler(function():Object
			{
				var o:Object = { result:null, error:0 };
				try
				{
					var rid:AutomationID = AutomationID.parse(objID);
					// we need to find out whether the current app and the 
					// reuired app are the same.
					var requiredApplicationName:String = getApplicationNameFromAutomationID(rid);
					var currentApplicationName:String  = getApplicationName();
					if(requiredApplicationName == currentApplicationName)
					{
						if (fromTool == true)
							detailsSentToTool = true; 
						var obj:IAutomationObject = automationManager.resolveIDToSingleObject(rid);
						//Don't use getDescriptionXML because it uses the attributes
						//that were sent into us, and in theory those attributes could
						//be regular expressions used to find the item
						//var result:XML = getDescriptionXML(rid, obj);
						//XML.prettyPrinting = false;
						//o.result = stripSlashRHack(result.toXMLString());
						o.result = getActiveOrLearnXMLTree(objID, false).learnChildrenXML;
					}
					else
					{
						// #IMP: MARSHALLING NOTE#: This order of ariguments should not be changed 
						// across versions. If any new arguements is needed in new versions 
						// add them to the end of the list and handle appropriately in the 
						// handler of this event.
						
						var details:Array = new Array();
						details.push(objID);
						
						if(fromTool == true)
						{
							requestPending = false;
							resultRecieved = false;
						}
						o.result = handleRequestToDifferentApplication(requiredApplicationName,
							ToolMarshallingEvent.BUILD_DESCRIPTION ,
							details); 
						
						if((resultRecieved == true)&&(fromTool == true))
						{
							// since we have recieved the result, we can send the information back to Tool
							o = requestResultObjArray[0];
							detailsSentToTool = true;
						}
					}
					
					// if we have not sent the request to QTP, we need to send the error message that we are not yet synchronised
					// we need this message only if the request to this method has come from QTP			
					if((detailsSentToTool == false)&&(fromTool == true))
					{
						// we dont expect this case to happen. But just to be on the
						// safe side we are keeping this error
						var message:String = resourceManager.getString(
							"automation_agent", "notSynchronized");
						throw new AutomationError(message,
							AutomationError.OBJECT_NOT_VISIBLE);	
					}
				}
				catch (e:Error)
				{
					throw e;
				}
				return o;
			});
		}
		
		/**
		 *  @private
		 */
		public function getPropertyDescriptors(obj:IAutomationObject, 
											   names:Array = null, 
											   forVerification:Boolean = true, 
											   forDescription:Boolean = true):Array
		{
			if (!obj)
				return null;
			
			try
			{
				automationManager.incrementCacheCounter();
				
				var automationClass:IToolAutomationClass =
					automationManager.automationEnvironment.getAutomationClassByInstance(obj) as IToolAutomationClass;
				var i:int;
				var propertyCaseRemapping:Object = automationClass.propertyLowerCaseMap;
				
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
				for (i = 0; i < names.length; i++)
				{
					var lowerCaseName:String = names[i].toLowerCase();
					var propertyDescriptor:ToolPropertyDescriptor = 
						propertyCaseRemapping[lowerCaseName];
					result.push(propertyDescriptor);
				}
				
				automationManager.decrementCacheCounter();
			}
			catch(e:Error)
			{
				automationManager.decrementCacheCounter();
				
				throw e;
			}
			
			return result;
		}
		
		private function encodeValues(obj:IAutomationObject, values:Array, descriptors:Array):Array
		{
			var result:Array = [];
			for (var i:int = 0; i < values.length; ++i)
			{
				var descriptor:ToolPropertyDescriptor = descriptors[i];
				var codec:IAutomationPropertyCodec = propertyCodecMap[descriptor.codecName];
				
				if (codec == null)
					codec = propertyCodecMap["object"];
				
				var relativeParent:IAutomationObject = obj;
				
				var retValue:Object = codec.encode(automationManager, obj, descriptor, relativeParent);
				result.push({value:retValue, descriptor:descriptor});
			}
			
			return result;
		}
		
		
		/**
		 *  @private
		 */
		public function getProperties(objID:String, names:String, fromTool:Boolean = true):Object
		{
			return useErrorHandler(function():Object
			{
				var o:Object = { result:null, error:0 };
				try
				{
					var rid:AutomationID = AutomationID.parse(objID);
					// we need to find out whether the current app and the 
					// reuired app are the same.
					var requiredApplicationName:String = getApplicationNameFromAutomationID(rid);
					var currentApplicationName:String  = getApplicationName();
					if(requiredApplicationName == currentApplicationName)
					{
						
						if (fromTool == true)
							detailsSentToTool = true; 
						
						// we are in the same applicaiton, and hence we can proceed.
						var obj:IAutomationObject = automationManager.resolveIDToSingleObject(rid);
						var asNames:Array = convertArrayFromCrazyToAs(names);
						
						var descriptors:Array = [];
						if(asNames && asNames.length)
						{
							//trace("getProperties 1- Lenght of Name"+ asNames.length);
							var automationClass:IToolAutomationClass =
							automationManager.automationEnvironment.getAutomationClassByInstance(obj) as IToolAutomationClass;;
							var propertyCaseRemapping:Object = automationClass.propertyLowerCaseMap;
							for (var i:int = 0; i < asNames.length; i++)
							{
								
								var lowerCaseName:String = asNames[i].toLowerCase();
								var propertyDescriptor:IAutomationPropertyDescriptor = 
								propertyCaseRemapping[lowerCaseName];
								// trace("getProperties 2 + Name - "+ lowerCaseName);
								if(propertyDescriptor)
								{
									asNames[i] = propertyDescriptor.name;
									descriptors.push(propertyDescriptor);
									//trace("getProperties  3 + Name -  found"+ lowerCaseName);
								}
								else
								{
									// descriptor was not found delete the entry.
									asNames.splice(i, 1);
									//trace("getProperties  3 + Name - Not found"+ lowerCaseName);
								}
								
							}
							
						}
						
						var values:Array = automationManager.getProperties(obj, asNames);
						var x:Array = encodeValues(obj, values, descriptors);
						
						//trace("getProperties  4 + found values"+  x.length);
						for (var no:int = 0; no < x.length; ++no)
						{
							x[no] = x[no].value;
						}
						
						
						o.result = getValuesWithTypeInformation(x);
					}
					else
					{
						// we need to send this as information to the other application 
						// and let the appropriate application handle it.
						
						// #IMP: MARSHALLING NOTE#: This order of ariguments should not be changed 
						// across versions. If any new arguements is needed in new versions 
						// add them to the end of the list and handle appropriately in the 
						// handler of this event.
						
						var details:Array = new Array();
						details.push(objID);
						details.push(names);
						
						if(fromTool == true)
						{
							requestPending = false;
							resultRecieved = false;
						}
						o.result =   handleRequestToDifferentApplication(requiredApplicationName, 
							ToolMarshallingEvent.GET_PROPERTIES,details);
						if((resultRecieved == true)&&(fromTool == true))
						{
							// since we have recieved the result, we can send the information back to QTP
							o =  requestResultObjArray[0] as Object;
							detailsSentToTool = true;
						}
					}
				}
				catch (e:Error)
				{
					throw e;
				}
				return o;
			});
		}
		
		/**
		 *  @private
		 */
		public function getParent(objID:String, fromTool:Boolean = true):Object
		{
			return useErrorHandler(function():Object
			{
				var o:Object = { result:null, error:0 };
				try
				{
					var rid:AutomationID = AutomationID.parse(objID);
					// we need to find out whether the current app and the 
					// reuired app are the same.
					var requiredApplicationName:String = getApplicationNameFromAutomationID(rid);
					var currentApplicationName:String  = getApplicationName();
					if(requiredApplicationName == currentApplicationName)
					{
						
						if (fromTool == true)
							detailsSentToTool = true;
						var obj:IAutomationObject = automationManager.resolveIDToSingleObject(rid);
						obj = automationManager.getParent(obj);
						o.result = (obj 
							? automationManager.createID(obj).toString() 
							: null);
					}
					else
					{
						// we need to send this as information to the other application 
						// and let the appropriate application handle it.
						
						// #IMP: MARSHALLING NOTE#: This order of ariguments should not be changed 
						// across versions. If any new arguements is needed in new versions 
						// add them to the end of the list and handle appropriately in the 
						// handler of this event.
						
						var details:Array = new Array();
						details.push(objID);	
						
						if(fromTool == true)
						{
							requestPending = false;
							resultRecieved = false;
						}
						o.result =   handleRequestToDifferentApplication(requiredApplicationName, 
							ToolMarshallingEvent.GET_PARENT,details);
						if((resultRecieved == true)&&(fromTool == true))
						{
							// since we have recieved the result, we can send the information back to QTP
							o =  requestResultObjArray[0] as Object;
							detailsSentToTool = true;
						}
					}
					
					// if we have not sent the request to QTP, we need to send the error message that we are not yet synchronised
					// we need this message only if the request to this method has come from QTP			
					if((detailsSentToTool == false)&&(fromTool == true))
					{
						// we dont expect this case to happen. But just to be on the
						// safe side we are keeping this error
						var message:String = resourceManager.getString(
							"automation_agent", "notSynchronized");
						throw new AutomationError(message,
							AutomationError.OBJECT_NOT_VISIBLE);	
					}
				}
				catch(e:Error)
				{
					throw e;
				}
				return o;
			});
		}
		
		/**
		 *  @private
		 */
		public function getChildren(objID:String, 
									filterXMLString:String = null, fromTool:Boolean = true):Object
		{
			return useErrorHandler(function():Object
			{
				var o:Object = { result:null, error:0 };
				try
				{
					var rid:AutomationID = AutomationID.parse(objID);
					// we need to find out whether the current app and the 
					// reuired app are the same.
					var requiredApplicationName:String = getApplicationNameFromAutomationID(rid);
					var currentApplicationName:String  = getApplicationName();
					if(requiredApplicationName == currentApplicationName)
					{
						
						if (fromTool == true)
							detailsSentToTool = true; 
						var autObject:IAutomationObject = automationManager.resolveIDToSingleObject(rid);
						var children:Array;
						if (autObject.numAutomationChildren > 0)
						{
							var part:AutomationIDPart = createPartFromFilterXML(filterXMLString);
							children = automationManager.getChildrenFromIDPart(autObject, part);
							
							for (var i:int = 0; i < children.length; ++i)
							{
								children[i] = automationManager.createID(children[i]).toString();
							}
						}
						else
							children = [automationManager.createID(autObject).toString()];
						
						o.result = children;
					}
					else
					{
						// we need to send this as information to the other application 
						// and let the appropriate application handle it.
						
						// #IMP: MARSHALLING NOTE#: This order of ariguments should not be changed 
						// across versions. If any new arguements is needed in new versions 
						// add them to the end of the list and handle appropriately in the 
						// handler of this event.
						
						var details:Array = new Array();
						details.push(objID);
						details.push(filterXMLString);	
						
						if(fromTool == true)
						{
							requestPending = false;
							resultRecieved = false;
						}
						o.result =   handleRequestToDifferentApplication(requiredApplicationName, 
							ToolMarshallingEvent.GET_CHILDREN,details);
						if((resultRecieved == true)&&(fromTool == true))
						{
							// since we have recieved the result, we can send the information back to QTP
							o =  requestResultObjArray[0] as Object;
							detailsSentToTool = true;
						}
					}
				}
				catch (e:Error)
				{
					throw e;
				}
				return o;
			});
		}
		
		/**
		 *  @private
		 */
		public function setLastError(message:String, fromTool:Boolean = true):void
		{
			// we need to find out which was the last responded application.
			var currentAppname:String = getApplicationName();
			if ((fromTool == false) || (currentAppname == lastResponseRecievedApplicationName))
			{
				lastError = new Error(message);
			}
			else
			{
				// this will be called if the fromTool == true and currentAppname != lastResponseRecievedApplicationName
				// we need to dispatch the event and get the error details from the appropriate application
				
				// we need to send this as information to the other application 
				// and let the appropriate application handle it.
				
				// #IMP: MARSHALLING NOTE#: This order of ariguments should not be changed 
				// across versions. If any new arguements is needed in new versions 
				// add them to the end of the list and handle appropriately in the 
				// handler of this event.
				
				var details:Array = new Array();
				details.push(message);	
				handleRequestToDifferentApplication(lastResponseRecievedApplicationName, 
					ToolMarshallingEvent.SET_LAST_ERROR,details);
				
			}
		}
		
		/**
		 *  @private
		 */
		public function getLastError(fromTool:Boolean = true):Object
		{
			// we need to find out which was the last responded application.
			var currentAppname:String = getApplicationName();
			if ((fromTool == false) || (currentAppname == lastResponseRecievedApplicationName))
			{
				detailsSentToTool = true;
				return { result: (lastError ? lastError.message.substr(0, 1 << 9) : null), 
					error: 0 };
			}
			else
			{
				var o:Object = { result:null, error:0 };
				// we will reach this condition only when fromTool == true and 
				// currentAppname != lastResponseRecievedApplicationName
				// we need to dispatch the event and get the error details from the appropriate application
				
				// we need to send this as information to the other application 
				// and let the appropriate application handle it.
				
				// #IMP: MARSHALLING NOTE#: This order of ariguments should not be changed 
				// across versions. If any new arguements is needed in new versions 
				// add them to the end of the list and handle appropriately in the 
				// handler of this event.
				
				var details:Array = new Array();
				//details.push(lastResponseRecievedApplicationName);	
				
				if(fromTool == true)
				{
					requestPending = false;
					resultRecieved = false;
				}
				
				o.result =   handleRequestToDifferentApplication(lastResponseRecievedApplicationName, 
					ToolMarshallingEvent.GET_LAST_ERROR,details);
				if((resultRecieved == true)&&(fromTool == true))
				{
					// since we have recieved the result, we can send the information back to QTP
					o =  requestResultObjArray[0] as Object;
					detailsSentToTool = true;
				}
				
				return o;
			}
		}
		
		/**
		 *  @private
		 */
		protected function getRectangle(objID:String, fromTool:Boolean = true):Object
		{
			return useErrorHandler(function():Object
			{
				var o:Object = { result:null, error:0 };
				try
				{
					var rid:AutomationID = AutomationID.parse(objID);
					// we need to find out whether the current app and the 
					// reuired app are the same.
					var requiredApplicationName:String = getApplicationNameFromObjectIDString(objID);
					var currentApplicationName:String  = getApplicationName();
					if(requiredApplicationName == currentApplicationName)
					{
						
						if (fromTool == true)
							detailsSentToTool = true;
						var obj:IAutomationObject = automationManager.resolveIDToSingleObject(rid);
						o.result = automationManager.getRectangle(obj as DisplayObject);
					}
					else
					{
						// we need to send this as information to the other application 
						// and let the appropriate application handle it.
						
						// #IMP: MARSHALLING NOTE#: This order of ariguments should not be changed 
						// across versions. If any new arguements is needed in new versions 
						// add them to the end of the list and handle appropriately in the 
						// handler of this event.
						var details:Array = new Array();
						details.push(objID);	
						
						if(fromTool == true)
						{
							requestPending = false;
							resultRecieved = false;
						}
						
						o.result =   handleRequestToDifferentApplication(requiredApplicationName,
							ToolMarshallingEvent.GET_RECTANGLE,details);
						if((resultRecieved == true)&&(fromTool == true))
						{
							// since we have recieved the result, we can send the information back to QTP
							o =  requestResultObjArray[0] as Object;
							detailsSentToTool = true;
						}
					}
					
				}
				catch(e:Error)
				{
					throw e;
				}
				return o;
			});
		}
		
		public function getRectangleInScreenCoordinates(objID:String):Array
		{
			// for AIR, we need to add the chromeHeight and Chrome width to get the screen coordinates
			// as the app 0,0 does not include the chrome details.
			
			var boundarObj:Object = getRectangle(objID);
			var objBoundaryInAppCoordinates:Array =  boundarObj["result"] as Array;
			var objBoundaryInScreenCoordinates:Array = new Array();
			
			var windowId:String = automationManager.getAIRWindowUniqueIDFromObjectIDString(objID);
			
			if(objBoundaryInAppCoordinates.length == 4)
			{
				var stageStartScreenCoordinate:Point = getStageStartPointInScreenCoords(windowId);
				
				if(!stageStartScreenCoordinate)
					stageStartScreenCoordinate = new Point(0,0);
				// we would have got the message for this. so the user is not expected to proceed.
				// the above is done to avoid the null obejct access.
				
				
				//var chromeHeight:int = getChromeHeight(); // for flex this will return 0
				//var chromeWidth:int = getChromeWidth(); // for flex this will return 0
				
				var chromeHeight:int = 0; // for flex this will return 0
				var chromeWidth:int = 0; // for flex this will return 0
				
				objBoundaryInScreenCoordinates.push(objBoundaryInAppCoordinates[0] + stageStartScreenCoordinate.x+chromeWidth);
				objBoundaryInScreenCoordinates.push(objBoundaryInAppCoordinates[1] + stageStartScreenCoordinate.y+chromeHeight);
				objBoundaryInScreenCoordinates.push(objBoundaryInAppCoordinates[2] + stageStartScreenCoordinate.x+chromeWidth);
				objBoundaryInScreenCoordinates.push(objBoundaryInAppCoordinates[3] + stageStartScreenCoordinate.y+chromeHeight);
				/*trace (String(objBoundaryInScreenCoordinates[0]) + 
				String(objBoundaryInScreenCoordinates[1]) +
				String( objBoundaryInScreenCoordinates[2] )	+
				String( objBoundaryInScreenCoordinates[3])
				);*/
			}
			
			return objBoundaryInScreenCoordinates;
			
		}
		/**
		 *  @private
		 */
		public function getElementFromPoint(x:int, y:int, windowId:String, fromTool:Boolean= true):Object
		{
			return useErrorHandler(function():Object
			{
				var o:Object = { result:null, error:0 };
				
				try
				{
					var details:Array = new Array();
					details.push(x);
					details.push(y);
					details.push(windowId);
					
					// here the handling is different from the other methods
					// here we need just let the sub application handle the point
					// first. if no sub application handles the point, then the main application needs to handle the same
					if(fromTool == true)
					{
						// we need to send this as information to the other application 
						// and let the appropriate application handle it.
						
						// #IMP: MARSHALLING NOTE#: This order of ariguments should not be changed 
						// across versions. If any new arguements is needed in new versions 
						// add them to the end of the list and handle appropriately in the 
						// handler of this event.
						
						if(fromTool == true)
						{
							requestPending = false;
							resultRecieved = false;
						}
						
						// in the case of this method, we need to let all application process
						// the request. If the application is able to process the details, we need to 
						// get the details. If we get a Popup or Alerts we need to give the importance of the same.
						// secondly we need to give priority of a non SWFLoader object.
						
						// first let us call from the main applicaiton
						var appWindow:DisplayObject =  automationManager.getAIRWindow(windowId);
						//Application.application as DisplayObject;
						var appPoint:Point = convertScreenPointToStagePoint(new Point(x,y),windowId);
						var appGlobalPoint:Point = appWindow.localToGlobal(appPoint);
						var obj:IAutomationObject = automationManager.getElementFromPoint2(appGlobalPoint.x, appGlobalPoint.y,windowId);
						var result:AutomationID;
						var mainAppObj:Object = null;
						
						
						// add the result to the resultObejct array  if the result is not a SWFLoader
						// Note: we need to check how the object is to be handled when the 
						// application is loaded using Loader
						if((obj != null) && (!(isObjectSWFLoader(obj1))))
						{		
							
							var currentAppName1:String =  getApplicationName();
							// we dont need to find out if the object belong to popup
							// if we dont get a pop up from child, and if we got and
							// object from main application, main application object has the 
							// preference.
							var isPopup1:Boolean = automationManager.isObjectPopUp(obj);
							mainAppObj = { result:null, applicationName:currentAppName1, 
								isPopup:isPopup1, error:0 };			    		
							var resultY:AutomationID = automationManager.createID(obj);
							mainAppObj.result = resultY.toString();
						}
						
						// irrespective of the result from the main application we 
						// to check what is the object at this point by other application.
						handleRequestToDifferentApplication(null, 
							ToolMarshallingEvent.GET_ELEMENT_FROM_POINT,details);
						
						if(mainAppObj)
						{
							var tempArray:Array = new Array();
							tempArray.push(mainAppObj);
							requestResultObjArray = tempArray.concat(requestResultObjArray);
						}	
						
						// we would have got replies from all applicaitons which could process the object
						var count:int = requestResultObjArray.length;
						if(count != 0)
						{
							var index:int = 0;
							var requiredObjectIdentified:Boolean = false;
							// process each object
							var currentObj:Object = null;
							while((!requiredObjectIdentified) && (index < count))
							{
								currentObj = requestResultObjArray[index];
								if(currentObj["isPopup"]  == true) 
								{
									// NOTE: TBD: we need to handle the case of other objects which can be
									// hosted by the PopupManager
									requiredObjectIdentified = true;
								}
								index++;
							}
							
							if(requiredObjectIdentified == true)
							{
								lastApplicationName = currentObj["applicationName" ];
								o.result = currentObj.result;
							}
							else
							{
								// the last loaded application need not be the application on the top.
								// this depends on the order of the swfloader in an application.
								// so we need to get the index of the last application.
								var lastRequiredObjectIndex:int =  automationManager.getTopApplicationIndex(requestResultObjArray);
								
								//var lastRequiredObjectIndex:int = requestResultObjArray.length - 1;			    			
								
								if(lastRequiredObjectIndex != -1)
								{
									currentObj = requestResultObjArray[lastRequiredObjectIndex];
									lastApplicationName = currentObj["applicationName" ];
									o.result = currentObj.result;
								}
							}
						}
						
						detailsSentToTool = true;
					}
					else
					{
						appWindow =   FlexGlobals.topLevelApplication as DisplayObject;
						appPoint = convertScreenPointToStagePoint(new Point(x,y),windowId);
						if(appPoint)
						{
							appGlobalPoint = appWindow.localToGlobal(appPoint);
							var obj1:IAutomationObject = automationManager.getElementFromPoint(appGlobalPoint.x, appGlobalPoint.y);
							
							// check whether the object is a child of system manager
							// we expect the Alerts and object hosted by the PopupManager 
							// only to get a special treatment
							if((obj1 != null) && (!isObjectSWFLoader(obj1)))
							{
								var isPopup:Boolean = automationManager.isObjectPopUp(obj1);
								
								var result1:AutomationID = automationManager.createID(obj1);
								
								var currentAppName:String =  getApplicationName();
								var o2:Object = { result:null, applicationName:currentAppName, 
									isPopup:isPopup, error:0 };
								o2.result = result1.toString();
								return o2;
							}
						}
					}
				}
				catch (e:Error)
				{
					throw e;
				}
				return o;
			});
		}
		
		
		private function isObjectSWFLoader(obj:Object):Boolean
		{
			var retValue:Boolean = false;
			if(obj is SWFLoader)
			{
				// Image is also a SWFLoader. But we should not ignore that.
				if(!(obj is Image))
					retValue = true;
			}
			return retValue
		}
		
		/**
		 *  @private
		 */
		public function getActiveScreen(level:uint, 
										objID:String,
										leftOffset:int,
										topOffset:int, fromTool:Boolean = true):Object
		{
			return useErrorHandler(function():Object
			{
				var o:Object = { result:null, error:0 };
				try
				{
					// we need to find out whether the current app and the 
					// reuired app are the same.
					var requiredApplicationName:String = getApplicationNameFromObjectIDString(objID);
					var currentApplicationName:String  = getApplicationName();
					if(requiredApplicationName == currentApplicationName)
					{
						if (fromTool == true)
							detailsSentToTool = true; 
						//we could make the 2nd parameter true if we wanted to support
						//the complete level
						o.result = getActiveOrLearnXMLTree(objID, false, "", true, leftOffset, topOffset).learnChildrenXML;
					}
					else
					{
						// we need to send this as information to the other application 
						// and let the appropriate application handle it.
						
						// #IMP: MARSHALLING NOTE#: This order of ariguments should not be changed 
						// across versions. If any new arguements is needed in new versions 
						// add them to the end of the list and handle appropriately in the 
						// handler of this event.
						var details:Array = new Array();
						details.push(level);
						details.push(objID);
						details.push(leftOffset);
						details.push(topOffset);	
						
						if(fromTool == true)
						{
							requestPending = false;
							resultRecieved = false;
						}
						
						o.result =   handleRequestToDifferentApplication(requiredApplicationName,
							ToolMarshallingEvent.GET_ACTIVESCREEN,details);
						if((resultRecieved == true)&&(fromTool == true))
						{
							// since we have recieved the result, we can send the information back to QTP
							o =  requestResultObjArray[0] as Object;
							detailsSentToTool = true;
						}
					}
					
				}
				catch(e:Error)
				{
					throw e;
				}
				return o;
			});
		}
		
		/**
		 *  @private
		 */
		public function learnChildObjects(objID:String,
										  filterXMLString:String, fromTool:Boolean = true):Object
		{
			return useErrorHandler(function():Object
			{
				var o:Object = { result:null, error:0 };
				try
				{
					// we need to find out whether the current app and the 
					// reuired app are the same.
					var requiredApplicationName:String = getApplicationNameFromObjectIDString(objID);
					var currentApplicationName:String  = getApplicationName();
					if(requiredApplicationName == currentApplicationName)
					{
						if (fromTool == true)
							detailsSentToTool = true; 
						//we could make the 2nd parameter true if we wanted to support
						//the complete level
						o.result = getActiveOrLearnXMLTree(objID, true, filterXMLString);
					}
					else
					{
						// we need to send this as information to the other application 
						// and let the appropriate application handle it.
						
						// #IMP: MARSHALLING NOTE#: This order of ariguments should not be changed 
						// across versions. If any new arguements is needed in new versions 
						// add them to the end of the list and handle appropriately in the 
						// handler of this event.
						var details:Array = new Array();
						details.push(objID);			
						details.push(filterXMLString);	
						
						if(fromTool == true)
						{
							requestPending = false;
							resultRecieved = false;
						}
						o.result =   handleRequestToDifferentApplication(requiredApplicationName, 
							ToolMarshallingEvent.LEARN_CHILD_OBJECTS,details);
						if((resultRecieved == true)&&(fromTool == true))
						{
							// since we have recieved the result, we can send the information back to QTP
							o =  requestResultObjArray[0] as Object;
							detailsSentToTool = true;
						}
					}
					
				}
				catch(e:Error)
				{
					throw e;
				}
				return o;
			});
		}
		
		/**
		 *  @private
		 */
		public function getTabularData(objID:String, begin:uint = 0, end:uint = 0, fromTool:Boolean = true):Object
		{
			return useErrorHandler(function():Object
			{
				var o:Object = { result:null, error:0 };
				try
				{
					var rid:AutomationID = AutomationID.parse(objID);
					// we need to find out whether the current app and the 
					// reuired app are the same.
					var requiredApplicationName:String = getApplicationNameFromAutomationID(rid);
					var currentApplicationName:String  = getApplicationName();
					if(requiredApplicationName == currentApplicationName)
					{
						if (fromTool == true)
							detailsSentToTool = true; 
						var obj:IAutomationObject = automationManager.resolveIDToSingleObject(rid);
						var td:IAutomationTabularData = automationManager.getTabularData(obj);
						o.result = {
							columnTitles: td ? td.columnNames : [],
							tableData: (td 
								? td.getValues(begin, end) 
								: [[]])
						};
					}
					else
					{
						// we need to send this as information to the other application 
						// and let the appropriate application handle it.
						
						// #IMP: MARSHALLING NOTE#: This order of ariguments should not be changed 
						// across versions. If any new arguements is needed in new versions 
						// add them to the end of the list and handle appropriately in the 
						// handler of this event.
						var details:Array = new Array();
						details.push(objID);			
						details.push(begin);				
						details.push(end);			    	
						if(fromTool == true)
						{
							requestPending = false;
							resultRecieved = false;
						}
						o.result =   handleRequestToDifferentApplication(requiredApplicationName, 
							ToolMarshallingEvent.GET_TABULAR_DATA,details);
						if((resultRecieved == true)&&(fromTool == true))
						{
							// since we have recieved the result, we can send the information back to QTP
							o =  requestResultObjArray[0] as Object;
							detailsSentToTool = true;
						}
					}
					
				}
				catch(e:Error)
				{
					throw e;
				}
				return o;
			});
		}
		
		public function getTabularAttributes(objID:String, fromTool:Boolean = true):Object
		{
			return useErrorHandler(function():Object
			{
				var o:Object = { result:null, error:0 };
				try
				{
					var rid:AutomationID = AutomationID.parse(objID);
					// we need to find out whether the current app and the 
					// reuired app are the same.
					var requiredApplicationName:String = getApplicationNameFromAutomationID(rid);
					var currentApplicationName:String  = getApplicationName();
					if(requiredApplicationName == currentApplicationName)
					{
						if (fromTool == true)
							detailsSentToTool = true;
						var obj:IAutomationObject = automationManager.resolveIDToSingleObject(rid);
						var td:IAutomationTabularData = automationManager.getTabularData(obj);
						o.result = {
							minVisibleRow: td ? td.firstVisibleRow : [],
							maxVisibleRow: td ? td.lastVisibleRow : [],
							fullSize: td ? td.numRows : []
						};
					}
					else
					{
						// we need to send this as information to the other application 
						// and let the appropriate application handle it.
						
						// #IMP: MARSHALLING NOTE#: This order of ariguments should not be changed 
						// across versions. If any new arguements is needed in new versions 
						// add them to the end of the list and handle appropriately in the 
						// handler of this event.
						var details:Array = new Array();
						details.push(objID);		    	
						if(fromTool == true)
						{
							requestPending = false;
							resultRecieved = false;
						}
						o.result =   handleRequestToDifferentApplication(requiredApplicationName, 
							ToolMarshallingEvent.GET_TABULAR_ATTRIBUTES,details);
						if((resultRecieved == true)&&(fromTool == true))
						{
							// since we have recieved the result, we can send the information back to QTP
							o =  requestResultObjArray[0] as Object;
							detailsSentToTool = true;
						}
					}
					
				}
				catch(e:Error)
				{
					throw e;
				}
				return o;
			});
		}
		
		/**
		 *  @private
		 */
		private function useErrorHandler(f:Function):Object
		{
			var o:Object = { result:null, error:0 };
			try
			{
				o = f();
			}
			catch (e:Error)
			{
				lastError = e;
				o.error = (e is AutomationError 
					? AutomationError(e).code 
					: AutomationError.ILLEGAL_OPERATION);
				Automation.automationDebugTracer.traceMessage("ToolAdapter","setErrorHandler()",e.message);
			}
			return o;
		}
		
		/**
		 *  @private
		 */
		private function getDescriptionXML(rid:AutomationID, 
										   target:IAutomationObject):XML
		{
			var obj:IAutomationObject = target;
			var result:XML;
			while (obj)
			{
				var part:AutomationIDPart = rid.removeLast();
				if (automationManager.showInHierarchy(obj) || target == obj)
				{
					var automationClass:String = automationManager.getAutomationClassName(obj);
					var automationName:String = part.automationName;
					
					//build description xml - probably could use the same methods
					//that learn and activescreen use, but those were added later
					//and this has been working so don't fix it
					var x:XML = (<Element type={automationClass}
						name={automationName}/>);
					for (var i:String in part)
						x.appendChild(<Property name={i} value={part[i] != null ? part[i] : ""}/>);
					
					if (result)
						x.appendChild(result);
					result = x;
				}
				obj = automationManager.getParent(obj);
			}
			return new XML(result);
		}
		
		/**
		 *  @private
		 */
		private function createPartFromFilterXML(filterXMLString:String):AutomationIDPart
		{
			var part:AutomationIDPart = new AutomationIDPart();
			var filterXML:XML = new XML(filterXMLString);
			for (var o:Object in filterXML.Property)
			{
				var propertyNode:XML = filterXML.Property[o];
				var name:String = propertyNode.@Name.toString();
				var value:String = propertyNode.@Value.toString();
				
				if(name.toLowerCase() == "automationname")
					name = "automationName";
				else if(name.toLowerCase() == "automationindex")
					name = "automationIndex";
				else if(name.toLowerCase() == "classname")
					name = "className";
				else if(name.toLowerCase() == "id")
					name = "id";
				
				if (propertyNode.@RegExp.toString() == "true")
					part[name] = new RegExp(value);
				else
					part[name] = value;
			}
			
			if (filterXML.@Type && filterXML.@Type.toString().length != 0)
				part["automationClassName"] = filterXML.@Type.toString();
			
			return part;
		}    
		
		/**
		 *  @private
		 */
		private function getActiveOrLearnXMLTree(objID:String,
												 addChildren:Boolean,
												 filterXML:String = "",
												 addActiveInfo:Boolean = false,
												 leftOffset:int = -1,
												 topOffset:int = -1):Object
		{
			var rid:AutomationID = AutomationID.parse(objID);
			var activeAO:IAutomationObject = automationManager.resolveIDToSingleObject(rid);
			var rids:Array = addActiveInfo ? null : [];
			
			//add the current item
			var activeNode:XML = getActiveOrLearnScreenXML(rids, 
				activeAO, 
				true, 
				addActiveInfo, 
				leftOffset, 
				topOffset);
			
			//add the children
			if (addChildren)
				getActiveOrLearnChildrenXML(rids, 
					activeAO, 
					filterXML, 
					activeNode, 
					addActiveInfo, 
					leftOffset, 
					topOffset);
			
			//add the parents
			var result:XML = getActiveOrLearnParentsXML(rids, 
				automationManager.getParent(activeAO), 
				activeNode, 
				addActiveInfo, 
				leftOffset, 
				topOffset);
			
			// We are storing the actual pretty printing value so that we can
			// reset it back when we are done with our operation.
			// Ref: http://bugs.adobe.com/jira/browse/FLEXENT-1140
			var actualPrettyPrinting:Boolean = XML.prettyPrinting;
			
			XML.prettyPrinting = false;
			var resultXMLString:String;
			var objectIdPart:AutomationIDPart = rid.removeFirst();
			var windowId:String = automationManager.getAIRWindowUniqueIDFromAutomationIDPart(objectIdPart);
			// using the check to see if we are requesting activeScreen XML or learn XML
			// activeScreenXML requires the outermost element to contain the bounding rectangle
			// learn XML doesnot require this.
			
			// We are using activeWindow API in order to get the rectangle corresponding to
			// the active window instead of getting the top level application's always.
			// http://bugs.adobe.com/jira/browse/FLEXENT-1123
			var appObj:Object = AutomationHelper.getActiveWindow(windowId);
			var rect:Array = automationManager.getRectangle(appObj as DisplayObject);
			
			if(leftOffset != -1)
			{
				var wrapper:XML = <Element> 
									<Rectangle left={leftOffset} top={topOffset} 
				right={leftOffset + rect[0] + appObj.screen.right}
				bottom = {topOffset + rect[1] + appObj.screen.bottom}/> 
		  </Element>;
				wrapper.appendChild(result);
				resultXMLString = String(wrapper.toXMLString());
			}
				
			else
				resultXMLString = String(result.toXMLString());
			
			XML.prettyPrinting = actualPrettyPrinting;
			return {learnChildrenXML: resultXMLString, childrenIDs: rids};
		}
		
		/**
		 *  @private
		 */
		private function getActiveOrLearnParentsXML(rids:Array,
													currentAO:IAutomationObject,
													currentNode:XML = null,
													addActiveInfo:Boolean = false,
													leftOffset:int = -1,
													topOffset:int = -1):XML
		{
			while (currentAO != null)
			{
				var newNode:XML = getActiveOrLearnScreenXML(rids, 
					currentAO, 
					false, 
					addActiveInfo, 
					leftOffset, 
					topOffset);
				newNode.appendChild(currentNode);
				
				currentNode = newNode;
				currentAO = automationManager.getParent(currentAO);
			}
			
			return currentNode;
		}
		
		/**
		 *  @private
		 */
		private function getActiveOrLearnChildrenXML(rids:Array,
													 parentAO:IAutomationObject,
													 filterXMLString:String,
													 parentNode:XML,
													 addActiveInfo:Boolean = false,
													 leftOffset:int = -1,
													 topOffset:int = -1):void
		{
			if (parentAO.numAutomationChildren == 0)
				return;
			
			//convert the XML filter to a part - note QTP hasn't implemented the filter part yet
			var part:AutomationIDPart = createPartFromFilterXML(filterXMLString);
			var children:Array = automationManager.getChildrenFromIDPart(parentAO, part);
			
			for (var i:int = 0; i < children.length; ++i)
			{
				var childAO:IAutomationObject = children[i];
				
				//we probably can skip anything that doesn't show in the hieararchy
				//remove this if this assumption turns out to be untrue (but comment as to why)
				if (!automationManager.showInHierarchy(childAO))
					continue;
				
				var childNode:XML = getActiveOrLearnScreenXML(rids, childAO, false, addActiveInfo, leftOffset, topOffset);
				parentNode.appendChild(childNode);
				
				getActiveOrLearnChildrenXML(rids, childAO, filterXMLString, childNode, false, leftOffset, topOffset);
			}
		}
		
		/**
		 *  @private
		 *  Prepares the XML description of the component along with bounding rectangle.
		 *  This function is used for active screen recording as well as returning information
		 *  for learning objects.
		 *
		 *  @param leftOffset left coordinate of the player
		 * 
		 *  @param topOffset top coordinate of player
		 */
		private function getActiveOrLearnScreenXML(rids:Array,
												   currentAO:IAutomationObject,
												   isActiveAO:Boolean = false,
												   addActiveInfo:Boolean = false,
												   leftOffset:int = -1,
												   topOffset:int= -1):XML
		{
			var automationClass:String = automationManager.getAutomationClassName(currentAO);
			var automationName:String = automationManager.getAutomationName(currentAO);
			
			if (rids != null)
				rids.push(automationManager.createID(currentAO).toString());
			
			// build description xml
			var result:XML = (addActiveInfo
				? (<Element type={automationClass} 
					name={automationName} 
					isActiveElement={isActiveAO}>
					</Element>)
				: (<Element type={automationClass} 
					name={automationName} 
					index={rids != null ? rids.length - 1 : 0}>
					</Element>)
				
			);
			
			//add properties
			var values:Array = automationManager.getProperties(currentAO, null, addActiveInfo, true);
			
			var descriptors:Array = getPropertyDescriptors(currentAO, null, addActiveInfo, true);
			
			var properties:Array = encodeValues(currentAO, values, descriptors);
			
			for (var i:uint = 0; i < properties.length; i++)
			{
				var name:String = properties[i].descriptor.name;
				var value:String = properties[i].value != null ? properties[i].value : "";
				var forDescription:Boolean = properties[i].descriptor.forDescription;
				
				var childXML:XML = (addActiveInfo
					? <Property name={name} 
					value={value} 
					forDescription={forDescription}/>
					: <Property name={name} 
					value={value}/>);
				
				result.appendChild(childXML);
			}
			
			//add screen coordinates
			if (addActiveInfo)
			{
				var rect:Array = automationManager.getRectangle(currentAO as DisplayObject);
				result.appendChild(<Rectangle left={leftOffset + rect[0]}
					top={topOffset + rect[1]} 
					right={leftOffset + rect[2]}
					bottom={topOffset + rect[3]} />);
			}
			
			return result; 
		}
		
		/**
		 *  @private
		 *  Converts Tool specific strings to proper values.
		 */
		private function convertArrayFromCrazyToAs(a:String):Array
		{
			var result:Array = a.split("__MX_ARG_SEP__");
			for (var i:uint = 0; i < result.length; i++)
			{
				if (result[i] == "__MX_NULL__")
					result[i] = null;
			}
			return result;
		}
		
		/**
		 *  Decodes an array of properties from a testing tool into an AS object.
		 *  using the codecs.
		 *
		 *  @param obj the object that contains the properties to be encoded.
		 * 
		 *  @param args the property values to transcode.
		 * 
		 *  @param propertyDescriptors the property descriptors that describes the properties for this object.
		 * 
		 *  @param relativeParent the IAutomationObject that is related to this object.
		 *
		 *  @return the decoded property value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function decodeProperties(obj:Object,
										 args:Array,
										 propertyDescriptors:Array,
										 interactionReplayer:IAutomationObject):void
		{	
			for (var i:int = 0; i < propertyDescriptors.length; i++)
			{
				var value:String = null;
				if (args != null && 
					i < args.length && 
					args[i] == "null" && 
					propertyDescriptors[i].defaultValue == "null")
					args[i] = null;
				if (args != null && 
					i < args.length && 
					((args[i] != null  && args[i] != "")  || propertyDescriptors[i].defaultValue == null))
					setPropertyValue(obj, 
						args[i],
						propertyDescriptors[i],
						interactionReplayer);
				else if (propertyDescriptors[i].defaultValue != null)
					setPropertyValue(obj, 
						(propertyDescriptors[i].defaultValue == "null" 
							? null 
							: propertyDescriptors[i].defaultValue), 
						propertyDescriptors[i], 
						interactionReplayer);
				else
				{
					var message:String = resourceManager.getString(
						"automation_agent", "missingArgument",
						[propertyDescriptors[i].name]);
					throw new Error(message);
				} 
			}
		}
		
		
		/**
		 *  @private
		 */
		public function setPropertyValue(obj:Object, 
										 value:Object,
										 pd:ToolPropertyDescriptor,
										 relativeParent:IAutomationObject = null):void
		{
			var codec:IAutomationPropertyCodec = propertyCodecMap[pd.codecName];
			
			if (codec == null)
				codec = propertyCodecMap["object"];
			
			if (relativeParent == null)
				relativeParent = obj as IAutomationObject;
			
			codec.decode(automationManager, obj, value, pd, relativeParent);
		}
		
		/**
		 *  @private
		 */
		public static function getCodecHelper():IToolCodecHelper
		{
			return qtpCodecHelper;
		}
		
		public static function set applicationType( appType:int):void
		{
			_applicationType = appType;
		}
		
		public  static function get applicationType():int
		{
			return _applicationType; 
		}
		
		public static function set applicationId( appId:String):void
		{
			_applicationId = appId;
		}
		
		public  static function get applicationId():String
		{
			return _applicationId; 
		}
		/*
		// this will give the stage boundary for AIR apps.
		public static function getStageBoundaryInScreenCoords(applicationId:String):Rectangle
		{
		
		var stageBoundary:Rectangle;
		var stageHeight:int;
		var stageWidth:int;
		var allPropFound:Boolean= false;
		
		// get the application start cooridnate in screen points
		//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
		var stageStartPointInScreenCoordinates:Point;
		
		// get the type of the application.
		if(_applicationType == ToolAdapter.ApplicationType_AIR)
		{
		var airFunctionHandler:Class = null;
		try
		{
		allPropFound = true;
		airFunctionHandler = getAirFunctionHelperClass("stageHeight,stageWidth,stageStartCoordinates");
		if(airFunctionHandler)
		{
		var obj:Object = new airFunctionHandler(applicationId);
		
		if(obj.hasOwnProperty("stageStartCoordinates"))
		stageStartPointInScreenCoordinates = obj["stageStartCoordinates"];
		else
		allPropFound = false;
		
		
		if(obj.hasOwnProperty("stageWidth"))
		stageWidth = obj["stageWidth"];
		else
		allPropFound = false;
		
		
		if(obj.hasOwnProperty("stageHeight"))
		stageHeight = obj["stageHeight"];
		else
		allPropFound = false;
		
		
		}
		
		}
		catch(e:Error)
		{
		trace("stageHeight,stageWidth, stageStartCoordinates - In AIR we are supposed to have class 'mx.automation.air.AirFunctionsHelper'.");
		// TBD. Converting this as user message and adding this in the locales.
		
		}
		if(allPropFound == false)
		{
		trace("stageHeight - In AIR we are supposed to have class 'mx.automation.air.AirFunctionsHelper' with stageHeight,stageWidth, stageStartCoordinates  as properties.");
		// TBD. Converting this as user message and adding this in the locales.
		}
		}
		else // we are in flex app
		{
		// get the application start coordinate  from the browsers
		//stageStartPointInScreenCoordinates = ExternalInterfaceMethods_AS.getApplicationStartPointInScreenCoordinates(_applicationId);
		stageHeight = Application.application.height;
		stageWidth = Application.application.width;
		stageStartPointInScreenCoordinates = new Point(0, 0);
		//stageStartPointInScreenCoordinates = (Automation.automationManager2 as IAutomationManager2).getStartPoint();
		
		}
		//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
		if(stageStartPointInScreenCoordinates)
		{
		
		// get the application boudary Array in screen cooridnates.
		
		stageBoundary =  new Rectangle(stageStartPointInScreenCoordinates.x,
		stageStartPointInScreenCoordinates.y,
		stageWidth, 
		stageHeight);
		}
		
		return stageBoundary;
		} 
		*/
		
		public static function getStageStartPointInScreenCoords(windowId:String ):Point
		{			
			var stageStartPoint:Point = new Point(0,0)
			try
			{
				stageStartPoint = AutomationHelper.getStageStartPointInScreenCoords(windowId);
			}
			catch(e:Error)
			{
				showAirHelperNotFoundMessage();				
				Automation.automationDebugTracer.traceMessage("ToolAdapter","stageStartCoordinates()", AutomationConstants.missingAIRClass);
			}
			return stageStartPoint;
		}
		
		public  function convertScreenPointToStagePoint(screenPoint:Point, applicationId:String):Point
		{
			var stageStartPoint:Point = getStageStartPointInScreenCoords(applicationId)
			var stagePoint:Point;
			
			// convert the point to app cooridnates
			stagePoint = new Point(screenPoint.x-stageStartPoint.x, screenPoint.y-stageStartPoint.y);
			return stagePoint;
			
		}
		
		
		public function getAppTitle():String
		{
			var title:String = "";
			try
			{
				title = AutomationHelper.getAppTitle();
			}
			catch(e:Error)
			{
				showAirHelperNotFoundMessage();				
				Automation.automationDebugTracer.traceMessage("ToolAdapter","appTitle()", AutomationConstants.missingAIRClass);
				// TBD. Converting this as user message and adding this in the locales.
			}
			return title;
		}
		
		
		/*public function getChromeHeight():int
		{
		var chromeHeight:int = 0; // default for flex = 0;
		var allPropFound:Boolean= false;
		
		// get the type of the application.
		if(_applicationType == ToolAdapter.ApplicationType_AIR)
		{
		var airFunctionHandler:Class = null;
		try
		{
		airFunctionHandler = getAirFunctionHelperClass("chromeHeight");
		if(airFunctionHandler)
		{
		var obj:Object = new airFunctionHandler(null);
		
		if(obj.hasOwnProperty("chromeHeight"))
		{
		chromeHeight = obj["chromeHeight"];
		allPropFound = true;
		}
		}
		
		}
		catch(e:Error)
		{
		trace("chromeHeight - In AIR we are supposed to have class 'mx.automation.air.AirFunctionsHelper'.");
		// TBD. Converting this as user message and adding this in the locales.
		
		}
		if(allPropFound == false)
		{
		trace("chromeHeight - In AIR we are supposed to have class 'mx.automation.air.AirFunctionsHelper' with chromeHeight property.");
		// TBD. Converting this as user message and adding this in the locales.
		}
		}
		return chromeHeight;
		
		
		}
		private static var classLoadingFailed:Boolean = false;
		public function isAirClassLoaded():Boolean
		{
		return  !classLoadingFailed;
		}
		
		private static function getAirFunctionHelperClass(prpertyName:String):Class
		{
		if(!classLoadingFailed)
		{
		try
		{
		return Class(getDefinitionByName("mx.automation.air.AirFunctionsHelper"));
		}
		catch (e:Error)
		{
		var message:String = showAirHelperNotFoundMessage();
		classLoadingFailed = true;
		throw new Error(message);
		}
		}
		return null;
		
		}
		public function getChromeWidth():int
		{
		var chromeWidth:int = 0; // default for flex = 0;
		var allPropFound:Boolean= false;
		
		// get the type of the application.
		if(_applicationType == ToolAdapter.ApplicationType_AIR)
		{
		var airFunctionHandler:Class = null;
		try
		{
		airFunctionHandler = getAirFunctionHelperClass("chromeWidth");
		if(airFunctionHandler)
		{
		var obj:Object = new airFunctionHandler(null);
		
		if(obj.hasOwnProperty("chromeWidth"))
		{
		chromeWidth = obj["chromeWidth"];
		allPropFound = true;
		}
		}
		
		}
		catch(e:Error)
		{
		trace("chromeWidth - In AIR we are supposed to have class 'mx.automation.air.AirFunctionsHelper'.");
		// TBD. Converting this as user message and adding this in the locales.
		
		}
		if(allPropFound == false)
		{
		trace("chromeWidth - - In AIR we are supposed to have class 'mx.automation.air.AirFunctionsHelper' with chromeWidth property.");
		// TBD. Converting this as user message and adding this in the locales.
		}
		}
		return chromeWidth;	
		}*/
		
		private function getApplicationName():String
		{
			return automationManager.getUniqueApplicationID();
		}
		
		private function getApplicationNameFromObjectIDString(objectID:String):String
		{
			var rid:AutomationID = AutomationID.parse(objectID);      
			
			return getApplicationNameFromAutomationID(rid);
		}
		
		private function getApplicationNameFromAutomationID(objectID:AutomationID):String
		{
			// clone the automationID
			var rid:AutomationID = objectID.clone();
			
			//remove the application
			var part:AutomationIDPart = rid.removeFirst();
			
			return automationManager.getApplicationNameFromAutomationIDPart (part);
			
			/*
			
			
			
			// check whether the current class is an AIR window as it is the another object
			// which can be the first level 
			// we have added a property by name 'applicationName' which is applicable only 
			// for the top level windows for AIR
			if (part.hasOwnProperty("applicationName"))	
			return (part["applicationName"].toString());
			
			
			// if we reach here we are not the AIR top level window 
			// hence we can use the automationName to get the automation class name
			return (part["automationName"].toString());
			*/
		}
		
		
		public function dispatchMarshalledEvent(type:String, applicationName:String , details1:Array):void
		{
			
			// This method is called to send all events from the root Automation Manager to the sub applicaitons.
			// we need to store the information that the we have sent the information and we are waiting 
			// for the reply
			lastApplicationName = applicationName;
			lastRequestName = type;
			requestPending = true;
			
			var marshalledEvent:ToolMarshallingEvent
			= new ToolMarshallingEvent(type); 
			marshalledEvent.applicationName =    applicationName;
			marshalledEvent.interAppDataToSubApp = details1;
			
			
			dispatchEventToChildren(marshalledEvent);
			
		}
		
		
		public function dispatchMarshalledReplyEvent(type:String, applicationName:String , details:Array):void
		{
			
			
			var marshalledEvent:ToolMarshallingEvent
			= new ToolMarshallingEvent(type); 
			marshalledEvent.applicationName =   applicationName;
			marshalledEvent.interAppDataToMainApp =   details;
			
			
			dispatchEventToParent(marshalledEvent); 
			
		}
		
		private function dispatchEventToParent(event:Event):void
		{
			automationManager.dispatchToParent(event);
		}
		
		private function dispatchEventToChildren(event:Event):void
		{
			automationManager.dispatchToAllChildren(event);
		}
		
		
		private function handleRequestToDifferentApplication(requiredApplicationName:String,
															 requestType:String , details:Array):Array
		{
			// clear the result object array so that  we have only the result of the
			// current request
			requestResultObjArray = new Array();
			
			dispatchMarshalledEvent( requestType,requiredApplicationName,details );
			return null;
		}
		
		
		/**
		 *  @private
		 */
		private var lastResponseRecievedApplicationName:String;
		
		
		/**
		 *  @private
		 */
		private var inReplySendingToParent:Boolean = false; 
		private function interAppReplyHandler(eventObj:Event) :void
		{
			// Marshalling events are needeed across applicaiton domain
			// so this conversion shall fail in the same domain
			// i.e the above check is to avoid the echoing
			if(eventObj is ToolMarshallingEvent)
				return;
			
			if(inReplySendingToParent)
				return;
			
			// if we are not the root application we need not handle the reply, just pass it to the parent
			//if(smMSm && (smMSm.useSWFBridge() == true))
			if(sm.isTopLevelRoot() == false)
			{
				inReplySendingToParent = true;
				var eventObj1:ToolMarshallingEvent = ToolMarshallingEvent.marshal(eventObj);
				dispatchEventToParent(eventObj1);
				inReplySendingToParent = false;
			}
			else
			{
				// we got the last event details
				resultRecieved = true;
				// this handler happens in the root application
				// so we need to find out which was the application last responded to the last request
				// we need this information to get the last error.
				// the only case where we recieve reply from a non relevant application also
				// is for the getElementFromPoint. However for this case, we dont expect 
				// a  last error. and the final handling of the getElement from happens in the
				// main application, hence we will handle this variable appropriately in that 
				// method separately.
				lastResponseRecievedApplicationName = (eventObj["applicationName"]);
				
				// we need a special handling if the event was 
				// get element from point as we expect results from different applicaiton
				// so we need to add them to the array instead of storing in the result object.
				
				if(eventObj.type == ToolMarshallingEvent.GET_ELEMENT_FROM_POINT_REPLY)
				{
					// dont assign the value to the array, instead add to the array
					requestResultObjArray.push(eventObj["interAppDataToMainApp"][0]);
				}
				else
					requestResultObjArray= (eventObj["interAppDataToMainApp"]);
			}
			
			
		}
		
		private var inRequestSendingToChildren:Boolean = false;
		/**
		 *  @private
		 */
		private function interAppRequestHandler(eventObj:Event) :void
		{
			// Marshalling events are needeed across applicaiton domain
			// so this conversion shall fail in the same domain
			// i.e the above check is to avoid the echoing
			if(eventObj is ToolMarshallingEvent)
				return;
			
			if(inRequestSendingToChildren)
				return;
			
			var appName:String = getApplicationName();
			var details:Array = new Array();
			var type:String;
			var resultObj:Object;
			var objectID:String;
			var filterXML:String;
			
			if((eventObj["applicationName"] == appName)||(eventObj["applicationName"] == null))
			{
				var dispatchEvent:Boolean = true;
				
				if(eventObj.type == ToolMarshallingEvent.FIND_OBJECTIDS)
				{
					var descriptionXML:String = eventObj["interAppDataToSubApp"][0] as String;
					resultObj = findObjectIDs(descriptionXML, false)["result"];
					details.push(resultObj);
					type = ToolMarshallingEvent.FIND_OBJECTIDS_REPLY;
				}
				else if (eventObj.type == ToolMarshallingEvent.RUN)
				{
					//run(objID:String, method:String, args:String):Object
					objectID = eventObj["interAppDataToSubApp"][0];
					var method:String = eventObj["interAppDataToSubApp"][1];
					var args:String = eventObj["interAppDataToSubApp"][2];
					resultObj = run(objectID,method,args,false);
					details.push(resultObj);
					type = ToolMarshallingEvent.RUN_REPLY;
					
				}
				else if (eventObj.type == ToolMarshallingEvent.GET_ACTIVESCREEN)
				{
					//run(objID:String, method:String, args:String):Object
					var level:int = eventObj["interAppDataToSubApp"][0];
					objectID = eventObj["interAppDataToSubApp"][1];
					var leftOffset:int = eventObj["interAppDataToSubApp"][2];
					var topOffset:int = eventObj["interAppDataToSubApp"][3];
					resultObj = getActiveScreen(level,objectID,leftOffset,topOffset,false);
					details.push(resultObj);
					type = ToolMarshallingEvent.GET_ACTIVESCREEN_REPLY;
				}
				else if (eventObj.type == ToolMarshallingEvent.GET_PARENT)
				{
					objectID = eventObj["interAppDataToSubApp"][0];
					resultObj = getParent(objectID,false);
					details.push(resultObj);
					type = ToolMarshallingEvent.GET_RECTANGLE_REPLY;
				}
				else if (eventObj.type == ToolMarshallingEvent.GET_RECTANGLE)
				{
					objectID = eventObj["interAppDataToSubApp"][0];
					resultObj = getRectangle(objectID,false);
					details.push(resultObj);
					type = ToolMarshallingEvent.GET_RECTANGLE_REPLY;
				}
				else if (eventObj.type == ToolMarshallingEvent.GET_ELEMENT_FROM_POINT)
				{
					var x:int = eventObj["interAppDataToSubApp"][0];
					var y:int = eventObj["interAppDataToSubApp"][1];
					var appId:String =  eventObj["interAppDataToSubApp"][2] as String;
					resultObj = getElementFromPoint(x,y,appId,false);
					if((resultObj["result"] == "" )||(resultObj["result"] == null))
						dispatchEvent = false;
					else
					{
						details.push(resultObj);
						type = ToolMarshallingEvent.GET_ELEMENT_FROM_POINT_REPLY;
					}
				}
				else if (eventObj.type == ToolMarshallingEvent.GET_ELEMENT_TYPE)
				{
					objectID = eventObj["interAppDataToSubApp"][0];
					resultObj = getElementType(objectID,false);
					details.push(resultObj);
					type = ToolMarshallingEvent.GET_ELEMENT_TYPE_REPLY;
				}
				else if (eventObj.type == ToolMarshallingEvent.GET_DISPLAY_NAME)
				{
					objectID = eventObj["interAppDataToSubApp"][0];
					resultObj = getDisplayName(objectID,false);
					details.push(resultObj);
					type = ToolMarshallingEvent.GET_DISPLAY_NAME_REPLY;
				}
				else if (eventObj.type == ToolMarshallingEvent.GET_PROPERTIES)
				{
					objectID = eventObj["interAppDataToSubApp"][0];
					var names:String = eventObj["interAppDataToSubApp"][1];
					resultObj = getProperties(objectID,names,false);
					details.push(resultObj);
					type = ToolMarshallingEvent.GET_PROPERTIES_REPLY;
				}
				else if (eventObj.type == ToolMarshallingEvent.BUILD_DESCRIPTION)
				{
					objectID = eventObj["interAppDataToSubApp"][0];
					resultObj = buildDescription(objectID,false);
					details.push(resultObj);
					type = ToolMarshallingEvent.BUILD_DESCRIPTION_REPLY;
				}
				else if (eventObj.type == ToolMarshallingEvent.GET_CHILDREN)
				{
					objectID = eventObj["interAppDataToSubApp"][0];
					filterXML = eventObj["interAppDataToSubApp"][1];
					resultObj = getChildren(objectID,filterXML,false);
					details.push(resultObj);
					type = ToolMarshallingEvent.GET_CHILDREN_REPLY;
				}
				else if (eventObj.type == ToolMarshallingEvent.LEARN_CHILD_OBJECTS)
				{
					objectID = eventObj["interAppDataToSubApp"][0];
					var filterXML1:String = eventObj["interAppDataToSubApp"][1];
					resultObj = learnChildObjects(objectID,filterXML1,false);
					details.push(resultObj);
					type = ToolMarshallingEvent.LEARN_CHILD_OBJECTS_REPLY;
				}
				else if (eventObj.type == ToolMarshallingEvent.GET_LAST_ERROR)
				{
					resultObj = getLastError(false);
					details.push(resultObj);
					type = ToolMarshallingEvent.GET_LAST_ERROR_REPLY;
				}
				else if (eventObj.type == ToolMarshallingEvent.SET_LAST_ERROR)
				{
					var message:String = eventObj["interAppDataToSubApp"][0];
					setLastError(message,false);
					dispatchEvent = false; // there is no reply for the setLast error
				}
				else if (eventObj.type == ToolMarshallingEvent.GET_TABULAR_ATTRIBUTES)
				{
					objectID = eventObj["interAppDataToSubApp"][0];
					resultObj = getTabularAttributes(objectID,false);
					details.push(resultObj);
					type = ToolMarshallingEvent.GET_TABULAR_ATTRIBUTES_REPLY;
				}
				else if (eventObj.type == ToolMarshallingEvent.GET_TABULAR_DATA)
				{
					objectID = eventObj["interAppDataToSubApp"][0];
					var begin:int = eventObj["interAppDataToSubApp"][1];
					var end:int = eventObj["interAppDataToSubApp"][2];
					resultObj = getTabularData(objectID,begin,end,false);
					details.push(resultObj);
					type = ToolMarshallingEvent.GET_TABULAR_DATA_REPLY;
				}
				
				if	(dispatchEvent == true)
					dispatchMarshalledReplyEvent(type,appName,details);
				if(eventObj.type == ToolMarshallingEvent.GET_ELEMENT_FROM_POINT)
				{
					inRequestSendingToChildren = true;
					var eventObj1:ToolMarshallingEvent = ToolMarshallingEvent.marshal(eventObj);
					dispatchEventToChildren(eventObj1);
					inRequestSendingToChildren = false;
				}
				
			}
			else
			{
				inRequestSendingToChildren = true;
				var eventObj2:ToolMarshallingEvent = ToolMarshallingEvent.marshal(eventObj);
				dispatchEventToChildren(eventObj2);
				inRequestSendingToChildren = false;
			}
			
		}
		
		
		private function newWindowHandler(event:AutomationAirEvent):void
		{
			// we need to inform the socket handler to communicate to the plugin 
			// to get the   hwnd for this new window. 
			if(ToolAgent.clientSocketHandler)
				(ToolAgent.clientSocketHandler).processNewWindowInformation(event.windowId);
		}
		
		
		
		
		
		
		private static var connectionAttemptAlert:Alert;	
		private static var successMessageAlert:Alert;		
		public static function showConnectionAttemptMessage():String
		{
			var message:String = resourceManager.getString("tool_air","qtpConnectionAttempt");
			connectionAttemptAlert = Alert.show( message);	
			return message;
		}
		
		public static function showConnectionSuccessMessage():String
		{
			if(connectionAttemptAlert)
				PopUpManager.removePopUp(connectionAttemptAlert);
			
			var message:String = resourceManager.getString("tool_air","qtpConnectionSuccess");
			successMessageAlert = Alert.show(message);
			
			removeSuccessMessageAlert();
			// let us close this 
			return message;
		}
		
		
		// we need only one type of error message.
		private static var errorMessageDisplayed:Boolean = false;
		
		public static function showioErrorMessage(eventString:String):String
		{
			if(connectionAttemptAlert)
				PopUpManager.removePopUp(connectionAttemptAlert);
			
			var message :String  =  resourceManager.getString(
				"tool_air", "noConnectionToTool");
			
			message = message + "\n" + resourceManager.getString(
				"tool_air", "noConnectionToTool_Recommendation");
			
			if(!errorMessageDisplayed)
				Alert.show(message);
			
			errorMessageDisplayed = true;
			
			return message;
		}
		
		
		public static function showSecurityErrorMessage(eventString:String):String
		{
			if(connectionAttemptAlert)
				PopUpManager.removePopUp(connectionAttemptAlert);
			
			var message :String  =  resourceManager.getString(
				"tool_air", "securityError");
			
			message = message + "\n" + "\n";
			message =  message + "securityErrorHandler: " + eventString;
			//trace (message);
			if(!errorMessageDisplayed)
				Alert.show(message);
			
			errorMessageDisplayed = true;
			
			return message;
		}
		
		
		public static function showConnectionFailureMessage():String
		{
			if(connectionAttemptAlert)
				PopUpManager.removePopUp(connectionAttemptAlert);
			
			// we wait for 3000 milliseconds 3 times to check whether we 
			// could connect to QTP.
			var message:String = resourceManager.getString("tool_air","qtpConnectionFailed");
			if(!errorMessageDisplayed)
				Alert.show(message);
			
			
			errorMessageDisplayed = true;
			ClientSocketHandler.enableApplication();
			return message;
		}
		
		
		
		public static function showAirHelperNotFoundMessage():String
		{
			if(connectionAttemptAlert)
				PopUpManager.removePopUp(connectionAttemptAlert);
			
			var message:String = resourceManager.getString("tool_air", "airHelperClassNotFound");
			if(!errorMessageDisplayed)
				Alert.show(message);
			
			errorMessageDisplayed = true;
			return message;
		}
		
		public static function removeSuccessMessageAlert():void
		{
			var tempTimer:Timer = new Timer(3000,1);
			tempTimer.addEventListener(TimerEvent.TIMER,removeSuccessMessageAlertTimerHandler);
			tempTimer.start();
		}
		
		public static function removeSuccessMessageAlertTimerHandler(event:Event):void
		{
			if(successMessageAlert)
				PopUpManager.removePopUp(successMessageAlert);
		}
	}
}
