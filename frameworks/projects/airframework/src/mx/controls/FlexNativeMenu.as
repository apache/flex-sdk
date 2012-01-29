////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.controls
{
	import flash.display.InteractiveObject;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.XMLListCollection;
	import mx.collections.errors.ItemPendingError;
	import mx.controls.menuClasses.IMenuDataDescriptor;
	import mx.controls.treeClasses.DefaultDataDescriptor;
	import mx.core.Application;
	import mx.core.EventPriority;
	import mx.core.UIComponent;
	import mx.core.UIComponentGlobals;
	import mx.core.mx_internal;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.FlexNativeMenuEvent;
	import mx.managers.ILayoutManagerClient;
	import mx.managers.ISystemManager;
	
//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched before a menu or submenu is displayed.
 *
 *  @eventType mx.events.FlexNativeMenuEvent.MENU_SHOW 
 */
[Event(name="menuShow", type="mx.events.FlexNativeMenuEvent")]

/**
 *  Dispatched when a menu item is selected. 
 *
 *  @eventType mx.events.FlexNativeMenuEvent.ITEM_CLICK
 */
[Event(name="itemClick", type="mx.events.FlexNativeMenuEvent")]

/**
 *  FlexNativeMenu is a wrapper class for AIR's NativeMenu.  It presents a Flex 
 *  interface by allowing you to use dataProviders to specify your menu content. 
 * 
 *  @see flash.display.NativeMenu
 */
public class FlexNativeMenu extends EventDispatcher implements ILayoutManagerClient, IFlexContextMenu 
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *  The character to use to indicate the mnemonic index in a label.  By 
     *  default, it is the underscore character, so in "C_ut", u would become
     *  the character for the mnemonic index.
     */
    private static var MNEMONIC_INDEX_CHARACTER:String = "_";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function FlexNativeMenu()
    {
        super();
        
        _nativeMenu.addEventListener(Event.DISPLAYING, menuDisplayHandler, false, 0, true);
    }
       
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    //--------------------------------------------------------------------------
	//
	//  Properties: ILayoutManagerClient 
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  initialized
	//----------------------------------

    /**
	 *  @private
	 *  Storage for the initialized property.
	 */
	private var _initialized:Boolean = false;

    /**
	 *  @copy mx.core.UIComponent#initialized
     */
    public function get initialized():Boolean
	{
		return _initialized;
	}

    /**
     *  @private
     */
    public function set initialized(value:Boolean):void
	{
		_initialized = value;
	}

    //----------------------------------
    //  nestLevel
    //----------------------------------

    /**
	 *  @private
	 *  Storage for the nestLevel property.
	 */
	private var _nestLevel:int = 1;
	
	// no one will likely set nestLevel (but there's a setter in case 
	// someone wants to.  We default nestLevel to 1 as it's a top-level 
	// component that goes in the chrome.
    
	/**
     *  @copy mx.core.UIComponent#nestLevel
     */
	public function get nestLevel():int
	{
		return _nestLevel;
	}
	
	/**
     *  @private
     */
	public function set nestLevel(value:int):void
	{
		_nestLevel = value;
		
		// After nestLevel is initialized, add this object to the
		// LayoutManager's queue, so that it is drawn at least once
		invalidateProperties();
	}
	
	//----------------------------------
	//  processedDescriptors
	//----------------------------------

    /**
     *  @private
	 *  Storage for the processedDescriptors property.
     */
	private var _processedDescriptors:Boolean = false;

    /**
     *  @copy mx.core.UIComponent#processedDescriptors
     */
    public function get processedDescriptors():Boolean
	{
		return _processedDescriptors;
	}

    /**
     *  @private
     */
    public function set processedDescriptors(value:Boolean):void
	{
		_processedDescriptors = value;
	}

	//----------------------------------
	//  updateCompletePendingFlag
	//----------------------------------

    /**
     *  @private
	 *  Storage for the updateCompletePendingFlag property.
     */
	private var _updateCompletePendingFlag:Boolean = false;

    /**
	 *  A flag that determines if an object has been through all three phases
	 *  of layout validation (provided that any were required).
     */
    public function get updateCompletePendingFlag():Boolean
	{
		return _updateCompletePendingFlag;
	}

    /**
     *  @private
     */
    public function set updateCompletePendingFlag(value:Boolean):void
	{
		_updateCompletePendingFlag = value;
	}
    
    //--------------------------------------------------------------------------
    //
    //  Variables: Invalidation
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Whether this component needs to have its
     *  commitProperties() method called.
     */
    private var invalidatePropertiesFlag:Boolean = false;
    
    /**
     * @private
     */
    private var _nativeMenu:NativeMenu = new NativeMenu();
    
    [Bindable("nativeMenuUpdate")]
    
    //----------------------------------
    //  nativeMenu
    //----------------------------------
    
    /**
      *  Returns the flash.display.NativeMenu managed by this object, 
      *  or null if there is not one.
      *
      *  Modifications to the underlying nativeMenu may be lost when changes
      *  to the menu or the underlying dataProvider are made.
      */
	public function get nativeMenu() : NativeMenu
	{
		return _nativeMenu;
	}
	
	//----------------------------------
    //  dataDescriptor
    //----------------------------------

	/**
     *  @private
     */
    private var dataDescriptorChanged:Boolean = false;

    /**
     *  @private
     */
    private var _dataDescriptor:IMenuDataDescriptor =
        new DefaultDataDescriptor();

    [Inspectable(category="Data")]

    /**
     *  The object that accesses and manipulates data in the data provider. 
     *  The FlexNativeMenu control delegates to the data descriptor for information 
     *  about its data. This data is then used to parse and move about the 
     *  data source. The data descriptor defined for the FlexNativeMenu is used for
     *  all child menus and submenus. 
     * 
     *  <p>When you specify this property as an attribute in MXML, you must
     *  use a reference to the data descriptor, not the string name of the
     *  descriptor. Use the following format for setting the property:</p>
     *
     * <pre>&lt;mx:FlexNativeMenu id="flexNativeMenu" dataDescriptor="{new MyCustomDataDescriptor()}"/&gt;</pre>
     *
     *  <p>Alternatively, you can specify the property in MXML as a nested
     *  subtag, as the following example shows:</p>
     *
     *  <pre>&lt;mx:FlexNativeMenu&gt;
     *  &lt;mx:dataDescriptor&gt;
     *     &lt;myCustomDataDescriptor&gt;
     *  &lt;/mx:dataDescriptor&gt;
     *  ...</pre>
     *
     *  <p>The default value is an internal instance of the
     *  DefaultDataDescriptor class.</p>
     */
    public function get dataDescriptor():IMenuDataDescriptor
    {
        return IMenuDataDescriptor(_dataDescriptor);
    }

    /**
     *  @private
     */
    public function set dataDescriptor(value:IMenuDataDescriptor):void
    {
        _dataDescriptor = value;
        
        dataDescriptorChanged = true;
    }
	
	//----------------------------------
    //  dataProvider
    //----------------------------------

	/**
     *  @private
     */
    private var dataProviderChanged:Boolean = false;
    
    /**
     *  @private
     *  Storage variable for the original dataProvider
     */
    mx_internal var _rootModel:ICollectionView;

    [Bindable("collectionChange")]
    [Inspectable(category="Data")]

    /**
     *  The hierarchy of objects that are displayed as NativeMenu items. 
     *  The top-level children all become NativeMenu items, and their children 
     *  become the items in the menus and submenus. 
     * 
     *  The FlexNativeMenu control handles the source data object as follows:
     *  <p>
     *  <ul>
     *  <li>A String containing valid XML text is converted to an XML object.</li>
     *  <li>An XMLNode is converted to an XML object.</li>
     *  <li>An XMLList is converted to an XMLListCollection.</li>
     *  <li>Any object that implements the ICollectionView interface is cast to
     *  an ICollectionView.</li>
     *  <li>An Array is converted to an ArrayCollection.</li>
     *  <li>Any other type object is wrapped in an Array with the object as its sole
     *  entry.</li>
     *  </ul>
     *  </p>
     * 
     *  @default "undefined"
     */
    public function get dataProvider():Object
    {
        if (mx_internal::_rootModel)
        {   
            return mx_internal::_rootModel;
        }
        else return null;
    }

    /**
     *  @private
     */
    public function set dataProvider(value:Object):void
    {
        if (mx_internal::_rootModel)
        {
            mx_internal::_rootModel.removeEventListener(CollectionEvent.COLLECTION_CHANGE, 
                                           collectionChangeHandler);
        }
                            
        // handle strings and xml
        if (typeof(value)=="string")
            value = new XML(value);
        else if (value is XMLNode)
            value = new XML(XMLNode(value).toString());
        else if (value is XMLList)
            value = new XMLListCollection(value as XMLList);
        
        if (value is XML)
        {
            _hasRoot = true;
            var xl:XMLList = new XMLList();
            xl += value;
            mx_internal::_rootModel = new XMLListCollection(xl);
        }
        //if already a collection dont make new one
        else if (value is ICollectionView)
        {
            mx_internal::_rootModel = ICollectionView(value);
            if (mx_internal::_rootModel.length == 1)
                _hasRoot = true;
        }
        else if (value is Array)
        {
            mx_internal::_rootModel = new ArrayCollection(value as Array);
        }
        //all other types get wrapped in an ArrayCollection
        else if (value is Object)
        {
            _hasRoot = true;
            // convert to an array containing this one item
            var tmp:Array = [];
            tmp.push(value);
            mx_internal::_rootModel = new ArrayCollection(tmp);
        }
        else
        {
            mx_internal::_rootModel = new ArrayCollection();
        }
        //add listeners as weak references
        mx_internal::_rootModel.addEventListener(CollectionEvent.COLLECTION_CHANGE,
                                    collectionChangeHandler, false, 0, true);
        //flag for processing in commitProps
        dataProviderChanged = true;
        invalidateProperties();
        
        var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
        event.kind = CollectionEventKind.RESET;
        collectionChangeHandler(event);
        dispatchEvent(event);
    }
    
    //----------------------------------
    //  hasRoot
    //----------------------------------

    /** 
     *  @private
     *  Flag to indicate if the model has a root
     */
    private var _hasRoot:Boolean = false;

    /**
     *  @copy mx.controls.Menu#hasRoot
     */
    public function get hasRoot():Boolean
    {
        return _hasRoot;
    }
    
    //----------------------------------
    //  keyEquivalentField
    //----------------------------------

	/**
     *  @private
     */
    private var keyEquivalentFieldChanged:Boolean = false;

    /**
     *  @private
     */
    private var _keyEquivalentField:String = "keyEquivalent";

    [Bindable("keyEquivalentChanged")]
    [Inspectable(category="Data", defaultValue="keyEquivalent")]

    /**
     *  The name of the field in the data provider that determines the 
     *  key equivalent for each menu item.  For the proper name, especially 
     *  for control characters, such as Home, Insert, etc..., look at the 
     *  Keyboard API KEYNAME_XXX constants.
     * 
     *  Setting the <code>keyEquivalentFunction</code> property overrides this property.
     *
     *  @default "keyEquivalent"
     *  @see flash.ui.Keyboard
     */
    public function get keyEquivalentField():String
    {
        return _keyEquivalentField;
    }

    /**
     *  @private
     */
    public function set keyEquivalentField(value:String):void
    {
        if (_keyEquivalentField != value)
        {
            _keyEquivalentField = value;
            keyEquivalentFieldChanged = true;
            
            invalidateProperties();
            
            dispatchEvent(new Event("keyEquivalentFieldChanged"));
        }
    }

    //----------------------------------
    //  keyEquivalentFunction
    //----------------------------------

    /**
     *  @private
     */
    private var _keyEquivalentFunction:Function;

    [Bindable("keyEquivalentFunctionChanged")]
    [Inspectable(category="Data")]

    /**
     *  The function that determines the key equivalent for each menu item.
     *  For the proper name, especially for control characters, such as 
     *  Home, Insert, etc..., look at the Keyboard API KEYNAME_XXX constants.
     * 
     *  If you omit this property, Flex uses the contents of the field or
     *  attribute specified by the <code>keyEquivalentField</code> property.
     *  If you specify this property, Flex ignores any <code>keyEquivalentField</code>
     *  property value.
     *
     *  The <code>keyEquivalentFunction</code> property is good for handling formatting, 
     *  localization, and platform independence.
     *
     *  <p>The key equivalent function must take a single argument which is the item
     *  in the data provider and return a String.</p>
     *  <pre>
     *  <code>myKeyEquivalentFunction(item:Object):String</code> </pre>
     *
     *  @default "undefined"
     *  @see flash.ui.Keyboard
     */
    public function get keyEquivalentFunction():Function
    {
        return _keyEquivalentFunction;
    }

    /**
     *  @private
     */
    public function set keyEquivalentFunction(value:Function):void
    {
        if (_keyEquivalentFunction != value)
        {
            _keyEquivalentFunction = value;
            keyEquivalentFieldChanged = true;
            
            invalidateProperties();
            
            dispatchEvent(new Event("keyEquivalentFunctionChanged"));
        }
    }
    
    //----------------------------------
    //  keyEquivalentModifiersFunction
    //----------------------------------

	/**
     *  @private
     */
    private var keyEquivalentModifiersFunctionChanged:Boolean = false;

    /**
     *  @private
     */
    private var _keyEquivalentModifiersFunction:Function = keyEquivalentModifiersDefaultFunction;
    	
    private function keyEquivalentModifiersDefaultFunction(data:Object):Array
	{
		var modifiers:Array = [];
		var xmlModifiers:Array = ["@altKey", "@cmdKey", "@ctrlKey", "@shiftKey"];
		var objectModifiers:Array = ["altKey", "cmdKey", "ctrlKey", "shiftKey"];
        var keyboardModifiers:Array = [Keyboard.ALTERNATE, Keyboard.COMMAND, Keyboard.CONTROL, Keyboard.SHIFT];
		
		if (data is XML)
        {
        	for (var i:int = 0; i < xmlModifiers.length; i++)
        	{
        		try
	            {
	            	var modifier:* = data[xmlModifiers[i]];
		            if (modifier[0] == true)
		                modifiers.push(keyboardModifiers[i]);
	            }
	            catch(e:Error)
	            {
	            }
        	}
        }
        else if (data is Object)
        {
            for (i = 0; i < objectModifiers.length; i++)
        	{
        		try
	            {
	            	modifier = data[objectModifiers[i]];
		            if (String(modifier).toLowerCase() == "true")
		                modifiers.push(keyboardModifiers[i]);
	            }
	            catch(e:Error)
	            {
	            }
        	}
        }
        
        return modifiers;
    }

    [Bindable("keyEquivalentModifiersFunctionChanged")]
    [Inspectable(category="Data")]

    /**
     *  The function that determines the key equivalent modifiers for each menu item.
     * 
     *  If you omit this property, Flex uses its own default function to determine the
     *  Array of modifiers.  It looks for boolean fields, altKey, ctrlKey, shiftKey, 
     *  and cmdKey.
     *
     *  The <code>keyEquivalentModifiersFunction</code> property is good for handling 
     *  formatting, localization, and platform independence.
     *
     *  <p>The key equivalent modifiers function must take a single argument which 
     *  is the item in the data provider and return an array of modifiers.</p>
     *  <pre>
     *  <code>myKeyEquivalentModifiersFunction(item:Object):Array</code> </pre>
     *
     *  @default "undefined"
     */
    public function get keyEquivalentModifiersFunction():Function
    {
        return _keyEquivalentModifiersFunction;
    }

    /**
     *  @private
     */
    public function set keyEquivalentModifiersFunction(value:Function):void
    {
        if (_keyEquivalentModifiersFunction != value)
        {
            _keyEquivalentModifiersFunction = value;
            keyEquivalentModifiersFunctionChanged = true;
            
            invalidateProperties();
            
            dispatchEvent(new Event("keyEquivalentModifiersFunctionChanged"));
        }
    }
    
    //----------------------------------
    //  labelField
    //----------------------------------

	/**
     *  @private
     */
    private var labelFieldChanged:Boolean = false;

    /**
     *  @private
     */
    private var _labelField:String = "label";

    [Bindable("labelFieldChanged")]
    [Inspectable(category="Data", defaultValue="label")]

    /**
     *  The name of the field in the data provider that determines the 
     *  text to display for each menu item. If the data provider is an Array of 
     *  Strings, Flex uses each string value as the label. If the data 
     *  provider is an E4X XML object, you must set this property explicitly. 
     *  For example, use @label to specify the label attribute in an E4X XML Object 
     *  as the text to display for each menu item.
     * 
     *  In a label, you can specify the character to be used as the mnemonic index 
     *  by preceding it with an underscore (Example: C_ut sets mnemonic index to 1). 
     *  Only the first underscore present is used for this purpose.  To get an 
     *  underscore to display in the label, you need to escape it with another 
     *  underscore.  So for example: (C__u_t) would show up as (C_ut) with a mnemonic 
     *  index of 3 (on the "t" character). The mnemonicIndex 
     *  property, if greater than zero, takes precedence over this value.  
     * 
     *  Setting the <code>labelFunction</code> property overrides this property.
     *
     *  @default "label"
     */
    public function get labelField():String
    {
        return _labelField;
    }

    /**
     *  @private
     */
    public function set labelField(value:String):void
    {
        if (_labelField != value)
        {
            _labelField = value;
            labelFieldChanged = true;
            
            invalidateProperties();
            
            dispatchEvent(new Event("labelFieldChanged"));
        }
    }

    //----------------------------------
    //  labelFunction
    //----------------------------------

    /**
     *  @private
     */
    private var _labelFunction:Function;

    [Bindable("labelFunctionChanged")]
    [Inspectable(category="Data")]

    /**
     *  The function that determines the text to display for each menu item.
     *  The label function must find the appropriate field or fields in the 
     *  data provider and return a displayable string.
     * 
     *  If you omit this property, Flex uses the contents of the field or
     *  attribute specified by the <code>labelField</code> property.
     *  If you specify this property, Flex ignores any <code>labelField</code>
     *  property value.
     * 
     *  In a label, you can specify the character to be used as the mnemonic index 
     *  by preceding it with an underscore (Example: C_ut sets mnemonic index to 1). 
     *  Only the first underscore present is used for this purpose.  To get an 
     *  underscore to display in the label, you need to escape it with another 
     *  underscore.  So for example: (C__u_t) would show up as (C_ut) with a mnemonic 
     *  index of 3 (on the "t" character). The mnemonicIndex 
     *  property, if greater than zero, takes precedence over this value. 
     *
     *  The <code>labelFunction</code> property is good for handling formatting, 
     *  localization, and platform-independence.
     *
     *  <p>The label function must take a single argument which is the item
     *  in the data provider and return a String.</p>
     *  <pre>
     *  <code>myLabelFunction(item:Object):String</code> </pre>
     *
     *  @default "undefined"
     */
    public function get labelFunction():Function
    {
        return _labelFunction;
    }

    /**
     *  @private
     */
    public function set labelFunction(value:Function):void
    {
        if (_labelFunction != value)
        {
            _labelFunction = value;
            labelFieldChanged = true;
            
            invalidateProperties();
            
            dispatchEvent(new Event("labelFunctionChanged"));
        }
    }
    
    //----------------------------------
    //  mnemonicIndexField
    //----------------------------------

	/**
     *  @private
     */
    private var mnemonicIndexFieldChanged:Boolean = false;

    /**
     *  @private
     */
    private var _mnemonicIndexField:String = "mnemonicIndex";

    [Bindable("mnemonicIndexChanged")]
    [Inspectable(category="Data", defaultValue="mnemonicIndex")]

    /**
     *  The name of the field in the data provider that determines the 
     *  mnemonic index for each menu item.
     * 
     *  If this field returns a number greater than zero, this mnemonic index 
     *  takes precedence over the one specified by an underscore in the label.
     * 
     *  Setting the <code>mnemonicIndexFunction</code> property overrides this property.
     *
     *  @default "mnemonicIndex"
     */
    public function get mnemonicIndexField():String
    {
        return _mnemonicIndexField;
    }

    /**
     *  @private
     */
    public function set mnemonicIndexField(value:String):void
    {
        if (_mnemonicIndexField != value)
        {
            _mnemonicIndexField = value;
            mnemonicIndexFieldChanged = true;
            
            invalidateProperties();
            
            dispatchEvent(new Event("mnemonicIndexFieldChanged"));
        }
    }

    //----------------------------------
    //  mnemonicIndexFunction
    //----------------------------------

    /**
     *  @private
     */
    private var _mnemonicIndexFunction:Function;

    [Bindable("mnemonicIndexFunctionChanged")]
    [Inspectable(category="Data")]

    /**
     *  The function that determines the mnemonic index for each menu item.
     * 
     *  If you omit this property, Flex uses the contents of the field or
     *  attribute specified by the <code>mnemonicIndexField</code> property.
     *  If you specify this property, Flex ignores any <code>mnemonicIndexField</code>
     *  property value.
     *
     *  If this returns a number greater than zero, this mnemonic index 
     *  takes precedence over the one specified by an underscore in the label.
     * 
     *  The <code>mnemonicIndexFunction</code> property is good for handling formatting, 
     *  localization, and platform independence.
     *
     *  <p>The mnemonic index function must take a single argument which is the item
     *  in the data provider and return an int.</p>
     *  <pre>
     *  <code>myMnemonicIndexFunction(item:Object):int</code> </pre>
     *
     *  @default "undefined"
     */
    public function get mnemonicIndexFunction():Function
    {
        return _mnemonicIndexFunction;
    }

    /**
     *  @private
     */
    public function set mnemonicIndexFunction(value:Function):void
    {
        if (_mnemonicIndexFunction != value)
        {
            _mnemonicIndexFunction = value;
            mnemonicIndexFieldChanged = true;
            
            invalidateProperties();
            
            dispatchEvent(new Event("mnemonicIndexFunctionChanged"));
        }
    }
    
    //----------------------------------
    //  showRoot
    //----------------------------------

    /**
     *  @private
     *  Storage variable for showRoot flag.
     */
    private var _showRoot:Boolean = true;

    /**
     *  @private
     */
    private var showRootChanged:Boolean = false;
    
    [Inspectable(category="Data", enumeration="true,false", defaultValue="false")]

    /**
     *  A Boolean flag that specifies whether to display the data provider's 
     *  root node.
     *
     *  If the data provider has a root node, and the <code>showRoot</code> property 
     *  is set to <code>false</code>, the items on the FlexNativeMenu control correspond to
     *  the immediate descendants of the root node.  
     * 
     *  This flag has no effect on data providers without root nodes, 
     *  like Lists and Arrays. 
     *
     *  @default true
     *  @see #hasRoot
     */
    public function get showRoot():Boolean
    {
        return _showRoot;
    }

    /**
     *  @private
     */
    public function set showRoot(value:Boolean):void
    {
        if (_showRoot != value)
        {
            showRootChanged = true;
            _showRoot = value;
            invalidateProperties();
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
   	
   	/**
	 *  @copy mx.core.UIComponent#invalidateProperties()
	 */
    public function invalidateProperties():void
    {
        // Don't try to add the object to the display list queue until we've
		// been assigned a nestLevel, or we'll get added at the wrong place in
		// the LayoutManager's priority queue.
		if (!invalidatePropertiesFlag && nestLevel > 0)
		{
			invalidatePropertiesFlag = true;
			if (UIComponentGlobals.mx_internal::layoutManager)
				UIComponentGlobals.mx_internal::layoutManager.invalidateProperties(this);
			else
			{
				var myTimer:Timer = new Timer(100, 1);
				myTimer.addEventListener(TimerEvent.TIMER, validatePropertiesTimerHandler);
				myTimer.start();
			}
		}
    }
    
    /**
     *  @private
     */
    public function validatePropertiesTimerHandler(event:TimerEvent):void
    {
        validateProperties();
    }
    
    /**
     *  @inheritDoc
     */
    public function validateProperties():void
    {
        if (invalidatePropertiesFlag)
        {
            commitProperties();

            invalidatePropertiesFlag = false;
        }
    }
    
    /**
     *  @inheritDoc
     */
    public function validateSize(recursive:Boolean = false):void
    {
    }
    
    /**
     *  @inheritDoc
     */
    public function validateDisplayList():void
    {
    }
    
    /**
	 *  Validate and update the properties and layout of this object
	 *  and redraw it, if necessary.
	 */
	public function validateNow():void
	{
		// Since we don't have commit/measure/layout phases,
		// all we need to do here is the commit phase
		if (invalidatePropertiesFlag)
			validateProperties();
	}

	/**
	 *  Sets the native menu on the underlying InteractiveObject to the AIR menu
	 */
	public function setContextMenu(component:InteractiveObject):void
	{
		component.contextMenu = nativeMenu;
		
		if (component is Application)
		{
			var systemManager:ISystemManager = Application(component).systemManager;
			
			if (systemManager is InteractiveObject)
        		InteractiveObject(systemManager).contextMenu = nativeMenu;
		}
	}
	
	/**
	 *  Unsets the native menu on the underlying InteractiveObject to the AIR menu
	 */
	public function unsetContextMenu(component:InteractiveObject):void
	{
		component.contextMenu = null;
	}
    
    /**
     *  Processes the properties set on the component.
	 *
	 *  @see mx.core.UIComponent#commitProperties()
     */
    protected function commitProperties():void
    {        
        if (showRootChanged)
        {
            if (!_hasRoot)
                showRootChanged = false;            
        }

        if (dataProviderChanged ||showRootChanged || 
        	labelFieldChanged || dataDescriptorChanged)
        {
            var tmpCollection:ICollectionView;
            
            //reset flags 
            dataProviderChanged = false;
            showRootChanged = false;
            labelFieldChanged = false;
            dataDescriptorChanged = false;
        
            // are we swallowing the root?
            if (mx_internal::_rootModel && !_showRoot && _hasRoot)
            {
                var rootItem:* = mx_internal::_rootModel.createCursor().current;
                if (rootItem != null &&
                    _dataDescriptor.isBranch(rootItem, mx_internal::_rootModel) &&
                    _dataDescriptor.hasChildren(rootItem, mx_internal::_rootModel))
                {
                    // then get rootItem children
                    tmpCollection = 
                        _dataDescriptor.getChildren(rootItem, mx_internal::_rootModel);
                }
            }
            
            // remove all items first.  This is better than creating a new NativeMenu
            // as the root since we have the same reference
            clearMenu(_nativeMenu);
            
            // make top level items            
            if (mx_internal::_rootModel)
            {
                if (!tmpCollection)
                    tmpCollection = mx_internal::_rootModel;
                // not really a default handler, but we need to 
                // be later than the wrapper
                tmpCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE,
                                               collectionChangeHandler,
                                               false,
                                               EventPriority.DEFAULT_HANDLER, true);
             
             	populateMenu(_nativeMenu, tmpCollection);                             
            }
            
            dispatchEvent(new Event("nativeMenuChange"));
        }
    }
    
    /**
     *  Creates a menu and adds appropriate listeners
     * 
     *  @private
     */
    private function createMenu():NativeMenu
    {
        var menu:NativeMenu = new NativeMenu();
        // need to do this in the constructor for the root nativeMenu
        menu.addEventListener(Event.DISPLAYING, menuDisplayHandler, false, 0, true);
        
        return menu;
    }
    
    /**
     *  Clears out all items in a given menu
     * 
     *  @private
     */
    private function clearMenu(menu:NativeMenu):void
    {
        var numItems:int = menu.numItems;
    	for (var i:int = 0; i < numItems; i++)
    	{
    		menu.removeItemAt(0);
    	}
    }
    
    /**
     *  Populates a menu and the related submenus given a collection
     * 
     *  @private
     */
    private function populateMenu(menu:NativeMenu, collection:ICollectionView):NativeMenu
    {
        var collectionLength:int = collection.length;
        for (var i:int = 0; i < collectionLength; i++)
        {
            try
            {
                insertMenuItem(menu, i, collection[i]);
            }
            catch(e:ItemPendingError)
            {
                //we probably dont need to actively recover from here
            }
        }
        
        return menu;
    }
    
    /**
     *  Adds the NativeMenuItem to the NativeMenu.  This methods looks at the
     *  properties of the data sent in and sets them properly on the NativeMenuItem.
     * 
     *  @private
     */
    private function insertMenuItem(menu:NativeMenu, index:int, data:Object):void
    {
        if (dataProviderChanged)
        {
            commitProperties();
            return;
        }

		var type:String = dataDescriptor.getType(data).toLowerCase();
		var isSeparator:Boolean = (type == "separator");
		
		// label changes later, but separator is read-only so need to know here
		var nativeMenuItem:NativeMenuItem = new NativeMenuItem("", isSeparator);
		
		if (!isSeparator)
		{
			// enabled
			nativeMenuItem.enabled = dataDescriptor.isEnabled(data);
			
			// checked
			nativeMenuItem.checked = type == "check" && dataDescriptor.isToggled(data);
			
			// data
			nativeMenuItem.data = dataDescriptor.getData(data, mx_internal::_rootModel);
			
			// key equivalent
			nativeMenuItem.keyEquivalent = itemToKeyEquivalent(data);
			
			// key equivalent modifiers
			nativeMenuItem.keyEquivalentModifiers = itemToKeyEquivalentModifiers(data);
			
			// label and mnemonic index
			var labelData:String = itemToLabel(data);
			var mnemonicIndex:int = itemToMnemonicIndex(data);
			
			if (mnemonicIndex >= 0)
			{
				nativeMenuItem.label = parseLabelToString(labelData);
				nativeMenuItem.mnemonicIndex = mnemonicIndex;
			}
			else
			{
				nativeMenuItem.label = parseLabelToString(labelData);
				nativeMenuItem.mnemonicIndex = parseLabelToMnemonicIndex(labelData);
			}
			
			// event listeners
			nativeMenuItem.addEventListener(flash.events.Event.SELECT, itemSelectHandler, false, 0, true);
			
			// recursive
			if (dataDescriptor.isBranch(data, mx_internal::_rootModel) && 
				dataDescriptor.hasChildren(data, mx_internal::_rootModel))
			{
				nativeMenuItem.submenu = createMenu();
				populateMenu(nativeMenuItem.submenu, 
					dataDescriptor.getChildren(data, mx_internal::_rootModel));
			}
		}
		
		// done!
		menu.addItem(nativeMenuItem);
    }
    
    /**
     *  @copy flash.display.NativeMenu#display()
     */
     public function display(stage:Stage, x:int, y:int):void
     {
     	nativeMenu.display(stage, x, y);     	
     }
     
    /**
     *  Returns the key equivalent for the given data object
     *  based on the keyEquivalentField and keyEquivalentFunction properties.
     *  If the method cannot convert the parameter to a string, it returns an
     *  empty string
     *
     *  @param data Object to be displayed.
     *
     *  @return The key equivalent based on the data.
     */
    protected function itemToKeyEquivalent(data:Object):String
    {
        if (data == null)
            return "";

        if (keyEquivalentFunction != null)
            return keyEquivalentFunction(data);

        if (data is XML)
        {
            try
            {
                if (data[keyEquivalentField].length() != 0)
                {
                    data = data[keyEquivalentField];
                    return data.toString();
                }

                //if (XMLList(data.@keyEquivalent).length() != 0)
                //{
                //  data = data.@keyEquivalent;
                //}
            }
            catch(e:Error)
            {
            }
        }
        else if (data is Object)
        {
            try
            {
                if (data[keyEquivalentField] != null)
                {
                    data = data[keyEquivalentField];
                    return data.toString();
                }
            }
            catch(e:Error)
            {
            }
        }

        return "";
    }
    
    /**
     *  Returns the key equivalent modifiers for the given data object
     *  based on the keyEquivalentModifiersFunction property.
     *  If the method cannot convert the parameter to an array of modifiers, 
     *  it returns an empty array
     *
     *  @param data Object to be displayed.
     *
     *  @return The array of key equivalent modifiers based on the data
     */
    protected function itemToKeyEquivalentModifiers(data:Object):Array
    {
        if (data == null)
            return [];

        if (keyEquivalentModifiersFunction != null)
            return keyEquivalentModifiersFunction(data);

        return [];
    }
    
    /**
     *  Returns the string to display for the given data object
     *  based on the labelField and labelFunction properties.
     *  If the method cannot convert the parameter to a string, it returns a
     *  single space.
     *
     *  @param data Object to be displayed.
     *
     *  @return The string to be displayed based on the data.
     */
    protected function itemToLabel(data:Object):String
    {
        if (data == null)
            return " ";

        if (labelFunction != null)
            return labelFunction(data);

        if (data is XML)
        {
            try
            {
                if (data[labelField].length() != 0)
                    data = data[labelField];

                //if (XMLList(data.@label).length() != 0)
                //{
                //  data = data.@label;
                //}
            }
            catch(e:Error)
            {
            }
        }
        else if (data is Object)
        {
            try
            {
                if (data[labelField] != null)
                    data = data[labelField];
            }
            catch(e:Error)
            {
            }
        }
        else if (data is String)
            return String(data);

        try
        {
            return data.toString();
        }
        catch(e:Error)
        {
        }

        return " ";
    }
    
    /**
     *  Returns the mnemonic index for the given data object
     *  based on the mnemonicIndexField and mnemonicIndexFunction properties.
     *  If the method cannot convert the parameter to an integer, it returns an
     *  -1.
     *
     *  @param data Object to be displayed.
     *
     *  @return The mnemonic index based on the data.
     */
    protected function itemToMnemonicIndex(data:Object):int
    {
        if (data == null)
            return -1;
            
        var mnemonicIndex:int;

        if (mnemonicIndexFunction != null)
            return mnemonicIndexFunction(data);

        if (data is XML)
        {
            try
            {
                if (data[mnemonicIndexField].length() != 0)
                {
                    mnemonicIndex = data[mnemonicIndexField]; // no need for parseInt??
                    return mnemonicIndex;
                }

                //if (XMLList(data.@mnemonicIndex).length() != 0)
                //{
                //  data = data.@mnemonicIndex;
                //}
            }
            catch(e:Error)
            {
            }
        }
        else if (data is Object)
        {
            try
            {
                if (data[mnemonicIndexField] != null)
                {
                    mnemonicIndex = data[mnemonicIndexField];
                    return mnemonicIndex;
                }
            }
            catch(e:Error)
            {
            }
        }

        return -1;
    }
    
    /**
     *  Returns the actual label sent to the NativeMenuItem.
     *  It takes out the leading underscore character if 
     *  there is one
     */
    protected function parseLabelToString(data:String):String
    {
    	const singleCharacter:RegExp = new RegExp(MNEMONIC_INDEX_CHARACTER, "g");
    	const doubleCharacter:RegExp = new RegExp(MNEMONIC_INDEX_CHARACTER + MNEMONIC_INDEX_CHARACTER, "g");
    	var dataWithoutEscapedUnderscores:Array = data.split(doubleCharacter);
    	
    	// now need to find lone underscores and remove it
    	var len:int = dataWithoutEscapedUnderscores.length;
    	for(var i:int = 0; i < len; i++)
    	{
    		var str:String = String(dataWithoutEscapedUnderscores[i]);
    		dataWithoutEscapedUnderscores[i] = str.replace(singleCharacter, "");
    	}
    	
    	return dataWithoutEscapedUnderscores.join(MNEMONIC_INDEX_CHARACTER);
    }
    
    /**
     *  Returns the mnemonic index sent to the NativeMenuItem.
     *  It finds the leading underscore character if 
     *  there is one and uses that as the index.
     */
    protected function parseLabelToMnemonicIndex(data:String):int
    {
    	const doubleCharacter:RegExp = new RegExp(MNEMONIC_INDEX_CHARACTER + MNEMONIC_INDEX_CHARACTER, "g");
        var dataWithoutEscapedUnderscores:Array = data.split(doubleCharacter);
    	
    	// now need to find first underscore
    	var len:int = dataWithoutEscapedUnderscores.length;
    	var strLengthUpTo:int = 0; // length of string accumulator
    	for(var i:int = 0; i < len; i++)
    	{
    		var str:String = String(dataWithoutEscapedUnderscores[i]);
    		var index:int = str.indexOf(MNEMONIC_INDEX_CHARACTER);
    		
    		if (index >= 0)
    			return index + strLengthUpTo;
    		
    		strLengthUpTo += str.length + MNEMONIC_INDEX_CHARACTER.length;
    	}
    	
    	return -1;
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
 	
 	/**
     *  @private
     */
    private function itemSelectHandler(event:Event):void
    {
        var nativeMenuItem:NativeMenuItem = event.target as NativeMenuItem;
        
        var type:String = dataDescriptor.getType(nativeMenuItem.data).toLowerCase();
        if (type == "check")
        {
        	var checked:Boolean = !dataDescriptor.isToggled(nativeMenuItem.data);
        	nativeMenuItem.checked = checked;
        	dataDescriptor.setToggled(nativeMenuItem.data, checked);
        	// this causes an update event which ends up re-creating 
        	// the whole menu... (SDK-13109)
        }
        
        var menuEvent:FlexNativeMenuEvent = new FlexNativeMenuEvent(FlexNativeMenuEvent.ITEM_CLICK);
        menuEvent.nativeMenu = nativeMenuItem.menu;
        menuEvent.index = nativeMenuItem.menu.getItemIndex(nativeMenuItem);
        menuEvent.nativeMenuItem = nativeMenuItem;
        menuEvent.label = nativeMenuItem.label;
        menuEvent.item = nativeMenuItem.data;
        dispatchEvent(menuEvent);
    }
    
    /**
     *  @private
     */
    private function menuDisplayHandler(event:Event):void
    {
        var nativeMenu:NativeMenu = event.target as NativeMenu;
 
        var menuEvent:FlexNativeMenuEvent = new FlexNativeMenuEvent(FlexNativeMenuEvent.MENU_SHOW);
        menuEvent.nativeMenu = nativeMenu;
        dispatchEvent(menuEvent);
    }
 	
 	/**
     *  @private
     */
    private function collectionChangeHandler(ce:CollectionEvent):void
    {
        //trace("[FlexNativeMenu] caught Model changed");
        if (ce.kind == CollectionEventKind.ADD)
        {
            dataProviderChanged = true;
            invalidateProperties();
            // should handle elegantly with better performance
            //trace("[FlexNativeMenu] add event");
        }
        else if (ce.kind == CollectionEventKind.REMOVE)
        {
            dataProviderChanged = true;
            invalidateProperties();
            // should handle elegantly with better performance
            //trace("[FlexNativeMenu] remove event at:", ce.location);
        }
        else if (ce.kind == CollectionEventKind.REFRESH)
        {
            dataProviderChanged = true;
            dataProvider = dataProvider; //start over
            invalidateProperties();
            //trace("[FlexNativeMenu] refresh event");
        }
        else if (ce.kind == CollectionEventKind.RESET)
        {
            dataProviderChanged = true;
            invalidateProperties();
            //trace("[FlexNativeMenu] reset event");
        }
        else if (ce.kind == CollectionEventKind.UPDATE)
        {
         	dataProviderChanged = true;
            invalidateProperties();
            // should handle elegantly with better performance
            // but can't right now
            //trace("[FlexNativeMenu] update event");
        }
    }
}

}
