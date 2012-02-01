////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2006-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.modules
{
import flash.events.Event;
import flash.system.ApplicationDomain;
import flash.system.SecurityDomain;
import flash.utils.ByteArray;
import mx.core.ContainerCreationPolicy;
import mx.core.FlexVersion;
import mx.core.IDeferredContentOwner;
import mx.core.IFlexModuleFactory;
import mx.core.INavigatorContent;
import mx.core.IVisualElement;
import mx.events.FlexEvent;
import mx.events.ModuleEvent;
import mx.modules.IModuleInfo;
import mx.modules.ModuleManager;
import spark.components.Group;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the ModuleLoader starts to load a URL.
 *
 *  @eventType mx.events.FlexEvent.LOADING
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.2
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="loading", type="flash.events.Event")]

/**
 *  Dispatched when the ModuleLoader is given a new URL.
 *
 *  @eventType mx.events.FlexEvent.URL_CHANGED
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.2
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="urlChanged", type="flash.events.Event")]

/**
 *  Dispatched when information about the module is 
 *  available (with the <code>info()</code> method), 
 *  but the module is not yet ready.
 *
 *  @eventType mx.events.ModuleEvent.SETUP
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.2
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="setup", type="mx.events.ModuleEvent")]

/**
 *  Dispatched when the module is finished loading.
 *
 *  @eventType mx.events.ModuleEvent.READY
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.2
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="ready", type="mx.events.ModuleEvent")]

/**
 *  Dispatched when the module throws an error.
 *
 *  @eventType mx.events.ModuleEvent.ERROR
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.2
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="error", type="mx.events.ModuleEvent")]

/**
 *  Dispatched at regular intervals as the module loads.
 *
 *  @eventType mx.events.ModuleEvent.PROGRESS
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.2
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="progress", type="mx.events.ModuleEvent")]

/**
 *  Dispatched when the module data is unloaded.
 *
 *  @eventType mx.events.ModuleEvent.UNLOAD
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.2
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="unload", type="mx.events.ModuleEvent")]

[ResourceBundle("modules")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("ModuleLoader.png")]

/**
 *  Modules are not supported for AIR mobile applications.
 */
[DiscouragedForProfile("mobileDevice")]

/**
 *  ModuleLoader is a component that behaves much like a SWFLoader except
 *  that it follows a contract with the loaded content. This contract dictates that the child
 *  SWF file implements IFlexModuleFactory and that the factory
 *  implemented can be used to create multiple instances of the child class
 *  as needed.
 *
 *  <p>The ModuleLoader is connected to deferred instantiation and ensures that
 *  only a single copy of the module SWF file is transferred over the network by using the
 *  ModuleManager singleton.</p>
 *  
 *  <pre>
 *  &lt;s:ModuleLoader
 *    <strong>Properties</strong>
 *    url="<i>No default</i>"
 *    trustContent="false|true"
 *  
 *    <strong>Events</strong>
 *    error="<i>No default</i>"
 *    loading="<i>No default</i>"
 *    progress="<i>No default</i>"
 *    ready="<i>No default</i>"
 *    setup="<i>No default</i>"
 *    unload="<i>No default</i>"
 *  /&gt;
 *  </pre>
 * 
 *  @see mx.modules.ModuleManager
 *  @see spark.modules.Module
 *  @see mx.controls.SWFLoader
 * 
 *  @includeExample examples/ModuleLoaderExample.mxml
 *  @includeExample examples/ModuleVerticalLayout.mxml -noswf
 *  @includeExample examples/ModuleHorizontalLayout.mxml -noswf
 *
 *  @langversion 3.0
 *  @playerversion Flash 10.2
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class ModuleLoader extends Group
                          implements INavigatorContent
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function ModuleLoader()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var module:IModuleInfo;

    /**
     *  @private
     */
    private var loadRequested:Boolean = false;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  applicationDomain
    //----------------------------------

    /**
     *  The application domain to load your module into.
     *  Application domains are used to partition classes that are in the same 
     *  security domain. They allow multiple definitions of the same class to 
     *  exist and allow children to reuse parent definitions.
     *  
     *  @see flash.system.ApplicationDomain
     *  @see flash.system.SecurityDomain
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var applicationDomain:ApplicationDomain;

    //----------------------------------
    //  child
    //----------------------------------

    /**
     *  The IVisualElement created from the module factory.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var child:IVisualElement;

    //----------------------------------
    //  trustContent
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the trustContent property.
     */
    private var _trustContent:Boolean = false;
    
    [Bindable("trustContentChanged")]
    [Inspectable(defaultValue="false")]
    
    /**
     *  If <code>true</code>, the content is loaded
     *  into your security domain.
     *  This means that the load fails if the content is in another domain
     *  and that domain does not have a crossdomain.xml file allowing your
     *  domain to access it. 
     *  This property only has an affect on the next load,
     *  it will not start a new load on already loaded content.
     *
     *  <p>The default value is <code>false</code>, which means load
     *  any content without failing, but you cannot access the content.
     *  Most importantly, the loaded content cannot 
     *  access your objects and code, which is the safest scenario.
     *  Do not set this property to <code>true</code> unless you are absolutely sure of the safety
     *  of the loaded content</p>
     *
     *  @default false
     *  @see flash.system.SecurityDomain
     *  @see flash.system.ApplicationDomain
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.6
     *  @productversion Flex 4.5.1
     */
    public function get trustContent():Boolean
    {
        return _trustContent;
    }
    
    /**
     *  @private
     */
    public function set trustContent(value:Boolean):void
    {
        if (_trustContent != value)
        {
            _trustContent = value;
            
            invalidateProperties();
            invalidateSize();
            invalidateDisplayList();
            
            dispatchEvent(new Event("trustContentChanged"));
        }
    }
    
    //----------------------------------
    //  url
    //----------------------------------

    /**
     *  @private
     *  Storage for the url property.
     */
    private var _url:String = null;
    
    [Inspectable(category="General")]

    /**
     *  The location of the module, expressed as a URL.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get url():String
    {
        return _url;
    }

    /**
     *  @private
     */
    public function set url(value:String):void
    {
        if (value == _url)
            return;

        var wasLoaded:Boolean = false;
        
        if (module)
        {
            module.removeEventListener(ModuleEvent.PROGRESS,
                                       moduleProgressHandler);
            module.removeEventListener(ModuleEvent.SETUP, moduleSetupHandler);
            module.removeEventListener(ModuleEvent.READY, moduleReadyHandler);
            module.removeEventListener(ModuleEvent.ERROR, moduleErrorHandler);
            module.removeEventListener(ModuleEvent.UNLOAD, moduleUnloadHandler);

            module.release();
            module = null;

            if (child)
            {
                removeElement(child);
                child = null;
            }
        }

        _url = value;

        dispatchEvent(new FlexEvent(FlexEvent.URL_CHANGED));

        if (_url != null && _url != "" && loadRequested)
            loadModule();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden Properties 
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  moduleFactory
    //----------------------------------
    /**
     *  @private
     */
    override public function set moduleFactory(moduleFactory:IFlexModuleFactory):void
    {
        super.moduleFactory = moduleFactory;
        
        // Register the _creationPolicy style as inheriting. See the creationPolicy
        // getter for details on usage of this style.
        styleManager.registerInheritingStyle("_creationPolicy");
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties: INavigatorContent
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  creationPolicy
    //----------------------------------
    
    // Internal flag used when creationPolicy="none".
    // When set, the value of the backing store _creationPolicy
    // style is "auto" so descendants inherit the correct value.
    private var creationPolicyNone:Boolean = false;
    
    [Inspectable(enumeration="auto,all,none", defaultValue="auto")]
    
    /**
     *  @inheritDoc
     *
     *  @default auto
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get creationPolicy():String
    {
        // Use an inheriting style as the backing storage for this property.
        // This allows the property to be inherited by either mx or spark
        // containers, and also to correctly cascade through containers that
        // don't have this property (ie Group).
        // This style is an implementation detail and should be considered
        // private. Do not set it from CSS.
        var result:String = getStyle("_creationPolicy");
        
        if (result == null)
            result = ContainerCreationPolicy.AUTO;
        
        if (creationPolicyNone)
            result = ContainerCreationPolicy.NONE;
        
        return result;
    }
    
    /**
     *  @private
     */
    public function set creationPolicy(value:String):void
    {
        if (value == ContainerCreationPolicy.NONE)
        {
            // creationPolicy of none is not inherited by descendants.
            // In this case, set the style to "auto" and set a local
            // flag for subsequent access to the creationPolicy property.
            creationPolicyNone = true;
            value = ContainerCreationPolicy.AUTO;
        }
        else
        {
            creationPolicyNone = false;
        }
        
        setStyle("_creationPolicy", value);
    }
    
    //----------------------------------
    //  icon
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the icon property.
     */
    private var _icon:Class = null;
    
    [Bindable("iconChanged")]
    [Inspectable(category="General", defaultValue="", format="EmbeddedFile")]
    
    /**
     *  The Class of the icon displayed by some navigator
     *  containers to represent this Container.
     *
     *  <p>For example, if this Container is a child of a TabNavigator,
     *  this icon appears in the corresponding tab.
     *  If this Container is a child of an Accordion,
     *  this icon appears in the corresponding header.</p>
     *
     *  <p>To embed the icon in the SWF file, use the &#64;Embed()
     *  MXML compiler directive:</p>
     *
     *  <pre>
     *    icon="&#64;Embed('filepath')"
     *  </pre>
     *
     *  <p>The image can be a JPEG, GIF, PNG, SVG, or SWF file.</p>
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get icon():Class
    {
        return _icon;
    }
    
    /**
     *  @private
     */
    public function set icon(value:Class):void
    {
        _icon = value;
        
        dispatchEvent(new Event("iconChanged"));
    }
    
    //----------------------------------
    //  label
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the label property.
     */
    private var _label:String = "";
    
    [Bindable("labelChanged")]
    [Inspectable(category="General", defaultValue="")]
    
    /**
     *  The text displayed by some navigator containers to represent
     *  this Container.
     *
     *  <p>For example, if this Container is a child of a TabNavigator,
     *  this string appears in the corresponding tab.
     *  If this Container is a child of an Accordion,
     *  this string appears in the corresponding header.</p>
     *
     *  @default ""
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get label():String
    {
        return _label;
    }
    
    /**
     *  @private
     */
    public function set label(value:String):void
    {
        _label = value;
        
        dispatchEvent(new Event("labelChanged"));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods: INavigatorContent
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    public function get deferredContentCreated():Boolean
    {
        return loadRequested;
    }
    
    /**
     *  @private
     */
    public function createDeferredContent():void
    {
        loadRequested = true;
        loadModule();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Create components that are children of this Container.
     */
    override protected function createChildren():void
    {
        // if nobody has overridden creationPolicy, get it from the
        // navigator parent
        if (creationPolicy == ContainerCreationPolicy.AUTO)
        {
            if (parent is IDeferredContentOwner)
            {
                var parentCreationPolicy:String = IDeferredContentOwner(parent).creationPolicy;
                creationPolicy = parentCreationPolicy == 
                    ContainerCreationPolicy.ALL ? ContainerCreationPolicy.ALL : 
                    ContainerCreationPolicy.NONE;
                
            }
        }

        if (!loadRequested && creationPolicy != ContainerCreationPolicy.NONE)
            createDeferredContent();
        
        super.createChildren();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Loads the module. When the module is finished loading, the ModuleLoader adds
     *  it as a child with the <code>addElement()</code> method. This is normally 
     *  triggered with deferred instantiation.
     *  
     *  <p>If the module has already been loaded, this method does nothing. It does
     *  not load the module a second time.</p>
     * 
     *  @param url The location of the module, expressed as a URL. This is an  
     *  optional parameter. If this parameter is null the value of the
     *  <code>url</code> property will be used. If the url parameter is provided
     *  the <code>url</code> property will be updated to the value of the url.
     * 
     *  @param bytes A ByteArray object. The ByteArray is expected to contain 
     *  the bytes of a SWF file that represents a compiled Module. The ByteArray
     *  object can be obtained by using the URLLoader class. If this parameter
     *  is specified the module will be loaded from the ByteArray and the url 
     *  parameter will be used to identify the module in the 
     *  <code>ModuleManager.getModule()</code> method and must be non-null. If
     *  this parameter is null the module will be load from the url, either 
     *  the url parameter if it is non-null, or the url property as a fallback.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function loadModule(url:String = null, bytes:ByteArray = null):void
    {
        
        if (url != null)
            _url = url;
            
        if (_url == null || _url == "")
        {
            //trace("loadModule() - null url or empty string url");
            return;
        }
        
        if (child)
        {
            //trace("loadModule() - already created the child");
            return;
        }

        if (module)
        {
            //trace("loadModule() - load already initiated");
            return;
        }

        dispatchEvent(new FlexEvent(FlexEvent.LOADING));

        module = ModuleManager.getModule(_url);
        
        module.addEventListener(ModuleEvent.PROGRESS, moduleProgressHandler);
        module.addEventListener(ModuleEvent.SETUP, moduleSetupHandler);
        module.addEventListener(ModuleEvent.READY, moduleReadyHandler);
        module.addEventListener(ModuleEvent.ERROR, moduleErrorHandler);
        module.addEventListener(ModuleEvent.UNLOAD, moduleUnloadHandler);

        // If an applicationDomain has not been specified and we have a module factory,
        // then create a child application domain from the application domain
        // this module factory is in.
        // This is a change in behavior so only do it for Flex 4 and newer
        // applications.
        var tempApplicationDomain:ApplicationDomain = applicationDomain; 
        
        if (tempApplicationDomain == null && moduleFactory &&         
            FlexVersion.compatibilityVersion >= FlexVersion.VERSION_4_0)
        {
            var currentDomain:ApplicationDomain = moduleFactory.info()["currentDomain"];
            tempApplicationDomain = new ApplicationDomain(currentDomain); 
        }
            
        module.load(tempApplicationDomain, 
                    trustContent ? SecurityDomain.currentDomain : null, 
                    bytes, 
                    moduleFactory);
    }

    /**
     *  Unloads the module and sets it to <code>null</code>.
     *  If an instance of the module was previously added as a child,
     *  this method calls the <code>removeChild()</code> method on the child. 
     *  <p>If the module does not exist or has already been unloaded, this method does
     *  nothing.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function unloadModule():void
    {
        if (child)
        {
            removeElement(child);
            child = null;
        }

        if (module)
        {
            module.removeEventListener(ModuleEvent.PROGRESS,
                                       moduleProgressHandler);
            module.removeEventListener(ModuleEvent.SETUP, moduleSetupHandler);
            module.removeEventListener(ModuleEvent.READY, moduleReadyHandler);
            module.removeEventListener(ModuleEvent.ERROR, moduleErrorHandler);

            module.unload();
            module.removeEventListener(ModuleEvent.UNLOAD, moduleUnloadHandler);
            module = null;
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function moduleProgressHandler(event:ModuleEvent):void
    {
        dispatchEvent(event);
    }

    /**
     *  @private
     */
    private function moduleSetupHandler(event:ModuleEvent):void
    {
        // Not ready for creation yet, but can call factory.info().

        dispatchEvent(event);
    }

    /**
     *  @private
     */
    private function moduleReadyHandler(event:ModuleEvent):void
    {
        child = module.factory.create() as IVisualElement;
        dispatchEvent(event);

        if (child)
        {
            addElement(child);
        }
        else
        {
            var message:String = resourceManager.getString(
                "modules", "couldNotCreateModule", [ module.factory.info()["mainClassName"] ]);
            var moduleEvent:ModuleEvent = new ModuleEvent(
                ModuleEvent.ERROR, false, false, 
                event.bytesLoaded, event.bytesTotal,
                message, event.module);
            dispatchEvent(moduleEvent);
        }
    }

    /**
     *  @private
     */
    private function moduleErrorHandler(event:ModuleEvent):void
    {
        unloadModule();
        dispatchEvent(event);
    }

    /**
     *  @private
     */
    private function moduleUnloadHandler(event:ModuleEvent):void
    {
        dispatchEvent(event);
    }
}

}
