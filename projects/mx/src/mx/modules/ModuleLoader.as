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

package mx.modules
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;
import mx.containers.VBox;
import mx.core.FlexVersion;
import mx.core.IDeferredInstantiationUIComponent;
import mx.events.FlexEvent;
import mx.events.ModuleEvent;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the ModuleLoader starts to load a URL.
 *
 *  @eventType mx.events.FlexEvent.LOADING
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="loading", type="flash.events.Event")]

/**
 *  Dispatched when the ModuleLoader is given a new URL.
 *
 *  @eventType mx.events.FlexEvent.URL_CHANGED
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
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
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="setup", type="mx.events.ModuleEvent")]

/**
 *  Dispatched when the module is finished loading.
 *
 *  @eventType mx.events.ModuleEvent.READY
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="ready", type="mx.events.ModuleEvent")]

/**
 *  Dispatched when the module throws an error.
 *
 *  @eventType mx.events.ModuleEvent.ERROR
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="error", type="mx.events.ModuleEvent")]

/**
 *  Dispatched at regular intervals as the module loads.
 *
 *  @eventType mx.events.ModuleEvent.PROGRESS
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="progress", type="mx.events.ModuleEvent")]

/**
 *  Dispatched when the module data is unloaded.
 *
 *  @eventType mx.events.ModuleEvent.UNLOAD
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="unload", type="mx.events.ModuleEvent")]

//--------------------------------------
//  Other metadata
//--------------------------------------

/*   NOTE: This class does not use the "containers" resource bundle. This 
 *   metadata is here to add the "containers" resource bundle to an 
 *   application loading a module. We do this because we know a Module will
 *   pull in the "containers" resource bundle and if the Module uses a resource
 *   bundle that is not already in use it will cause the module to be leaked.
 *
 *   This is only an issue for Spark applications because they do not link in
 *   the CanvasLayout class, which has the "containers" resource bundle. Halo
 *   applications always use the CanvasLayout class. This can be removed
 *   after the module leak caused by the ResourceManager has been fixed.
 *   
 */
[ResourceBundle("containers")]
[IconFile("ModuleLoader.png")]

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
 *  @see mx.controls.SWFLoader
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class ModuleLoader extends VBox
                          implements IDeferredInstantiationUIComponent
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var applicationDomain:ApplicationDomain;

    //----------------------------------
    //  child
    //----------------------------------

    /**
     *  The DisplayObject created from the module factory.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var child:DisplayObject;

    //----------------------------------
    //  url
    //----------------------------------

    /**
     *  @private
     *  Storage for the url property.
     */
    private var _url:String = null;

    /**
     *  The location of the module, expressed as a URL.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
                removeChild(child);
                child = null;
            }
        }

        _url = value;

        dispatchEvent(new FlexEvent(FlexEvent.URL_CHANGED));

        if (_url != null && loadRequested)
            loadModule();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: Container
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function createComponentsFromDescriptors(
                                                recurse:Boolean = true):void
    {
        super.createComponentsFromDescriptors(recurse);

        loadRequested = true;
        loadModule();
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Loads the module. When the module is finished loading, the ModuleLoader adds
     *  it as a child with the <code>addChild()</code> method. This is normally 
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function loadModule(url:String = null, bytes:ByteArray = null):void
    {
        
        if (url != null)
            _url = url;
            
        if (_url == null)
        {
            //trace("loadModule() - null url");
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
            if (currentDomain)
                tempApplicationDomain = new ApplicationDomain(currentDomain); 
        }
            
        module.load(tempApplicationDomain, null, bytes, moduleFactory);
    }

    /**
     *  Unloads the module and sets it to <code>null</code>.
     *  If an instance of the module was previously added as a child,
     *  this method calls the <code>removeChild()</code> method on the child. 
     *  <p>If the module does not exist or has already been unloaded, this method does
     *  nothing.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function unloadModule():void
    {
        if (child)
        {
            removeChild(child);
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
        child = module.factory.create() as DisplayObject;
        dispatchEvent(event);

        if (child)
        {
            var p:DisplayObjectContainer = parent;
            // p.removeChild(this);
            addChild(child);
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
