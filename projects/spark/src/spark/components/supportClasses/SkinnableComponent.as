////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package flex.core
{

import flash.events.Event;
import flash.system.ApplicationDomain;
import flash.utils.*;

import mx.core.IFactory;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.PropertyChangeEvent;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

include "../styles/metadata/BasicContainerFormatTextStyles.as"
include "../styles/metadata/AdvancedContainerFormatTextStyles.as"
include "../styles/metadata/BasicParagraphFormatTextStyles.as"
include "../styles/metadata/AdvancedParagraphFormatTextStyles.as"
include "../styles/metadata/BasicCharacterFormatTextStyles.as"
include "../styles/metadata/AdvancedCharacterFormatTextStyles.as"

/**
 *  Name of the skin to use for this component. The skin must be a class that extends
 *  the flex.core.Skin class. 
 * 
 *  NOTE: We need to give the "skin" style a different name in order to resolve the
 *  collision with the Flex 3 "skin" style.
 *  This is an obviously bad name to serve as a reminder that it needs to get fixed.
 * 
 *  TODO: Fix name
 */
[Style(name="skinZZ", type="Class")]

/**
 *  @private
 *  TODO: Determine final name for this style.
 */
[Style(name="skinFactory", type="Object")]

/**
 *  The SkinnableComponent class.
 */
public class SkinnableComponent extends UIComponent
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor
     */
    public function SkinnableComponent()
    {
        // Initially state is dirty
        skinStateIsDirty = true;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    private var _selected:Boolean = false;
    
    public function get selected():Boolean
    {
        return _selected;
    }
    
    public function set selected(value:Boolean):void
    {
        if (_selected == value)
            return;
        
        _selected = value;
        
        // TODO: Send notification
    }
    
    // we need all these getters/setters around skinObject so it
    // can be a public read-only Bindable variable and a protected
    // read/write variable.
    private var __skinObject:Skin;
    
    [Bindable("skinObjectChanged")]
    
    /**
     *  @private
     */
    private function get _skinObject():Skin
    {
        return __skinObject;
    }
    
    private function set _skinObject(value:Skin):void
    {
    	if (value === __skinObject)
    	   return;
        
        __skinObject = value;
        dispatchEvent(new Event("skinObjectChanged"));
    }
    
    [Bindable("skinObjectChanged")]
    
    /**
     *  The instantiated skin object. This is a read-only property that
     *  should be set by loadSkin().
     */
    public function get skinObject():Skin
    {
        return _skinObject;
    }
    
    /**
     *  @private
     *  Temporary (?) hack to get skinFactory to work as an attribute that points to an external file.
     */
    public function get skinFactory():IFactory
    {
        return getStyle("skinFactory");
    }
    
    public function set skinFactory(value:IFactory):void
    {
        setStyle("skinFactory", value);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function createChildren():void
    {
        super.createChildren();
        
        skinChanged = true;
    }
    
    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (skinChanged)
        {
            skinChanged = false;
            if (skinObject)
                unloadSkin();
            loadSkin();
        }
        
        if (skinStateIsDirty)
        {
            commitSkinState( getUpdatedSkinState() );
            skinStateIsDirty = false;
        }
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        if (skinObject)
        {
            measuredWidth = skinObject.getExplicitOrMeasuredWidth();
            measuredHeight = skinObject.getExplicitOrMeasuredHeight();
            measuredMinWidth = isNaN( skinObject.explicitWidth ) ? skinObject.minWidth : skinObject.explicitWidth;
            measuredMinHeight = isNaN( skinObject.explicitHeight ) ? skinObject.minHeight : skinObject.explicitHeight;
        }
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        if (skinObject)
            skinObject.setActualSize(unscaledWidth, unscaledHeight);
    }
    
    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        var allStyles:Boolean = styleProp == null || styleProp == "styleName";
        
        if (allStyles || styleProp == "skinZZ" || styleProp == "skinFactory")
        {
            skinChanged = true;
            invalidateProperties();
        }
        
        super.styleChanged(styleProp);
    }
    
    //--------------------------------------------------------------------------
    //
    // Skin states support
    //
    //--------------------------------------------------------------------------

    /**
     *  Returns the name of the state to be applied to the skin. For example, a
     *  Button could have "up", "down", "over", and "disabled" states.
     * 
     *  Subclasses must override to return a value.
     * 
     *  @return A string specifying the name of the state.
     */
    protected function getUpdatedSkinState():String 
    {
        return null; 
    }
    
    /**
     *  Marks the component so that its <code>commitSkinState()</code> method
     *  gets called during a later screen update.
     */
    protected function invalidateSkinState():void
    {
        if (skinStateIsDirty)
            return; // State is already invalidated

        skinStateIsDirty = true;
        invalidateProperties();
    }

    /**
     *  Sets the new state of the skin. Subclasses can override to add 
     *  extra validation logic.
     * 
     *  @param newState A string specifying the name of the state to set.
     */
    protected function commitSkinState(newState:String):void
    {
        skinObject.currentState = newState;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods - Skin/Behavior lifecycle
    //
    //--------------------------------------------------------------------------
    
	/**
	 *  Load the skin for the component. This method should not be called
	 *  directly. Typically, subclasses will not need to override this method.
	 * 
	 *  It instantiates the skin for the component, adds the skin as a child, 
	 *  resolves all part associations, and calls skinLoaded().
	 */
    protected function loadSkin():void
    {
        // Factory
        var skinClassFactory:IFactory = getStyle("skinFactory") as IFactory;        
        
        if (skinClassFactory)
            _skinObject = skinClassFactory.newInstance() as Skin;
        
        // Class
        if (!skinObject)
        {
            var skinClass:Class = getStyle("skinZZ") as Class;
            
            if (skinClass)
                _skinObject = new skinClass();
        }
        
        if (skinObject)
        {
            skinObject.owner = this;
            skinObject.data = this;
            
            // As a convenience if someone has declared hostComponent
            // we assign a reference to ourselves.  If the hostComponent
            // property exists as a direct result of utilizing [HostComponent]
            // metadata it will be strongly typed. We need to do more work
            // here and only assign if the type exactly matches our component
            // type.
            if ("hostComponent" in skinObject)
            {
                try 
                {
                    Object(skinObject).hostComponent = this;
                }
                catch (err:Error) {}
            }
           	
            addChild(skinObject);
        }
        else
        {
            throw(new Error("Skin for " + this + " cannot be found."));
        }
        
        findSkinParts();
                
        skinLoaded();
    }
    
    /**
     *  Find the skin parts and assign them to the properties in the component.
     *  This method is called by loadSkin(), and should not be called directly.
     *  Typically, subclasses will not need to override this method.
     */
    protected function findSkinParts():void
    {
        var className:String = getQualifiedClassName(this);
        var skinParts:Array = getSkinPartMetadata(className);
        
        if (skinParts)
        {
            for (var i:int = 0; i < skinParts.length; i++)
            {
                var part:SkinPartInfo = skinParts[i];
                
                if (part.required)
                {
                    if (!(part.id in skinObject))
                        throw(new Error("Required skin part \"" + part.id + "\" cannot be found.")); 
                }
                
                if (part.id in skinObject)
                {
                    this[part.id] = skinObject[part.id];
                    
                    // If the assigned part has already been instantiated, call partAdded() here,
                    // but only for static parts.
                    if (this[part.id] != null && !(this[part.id] is IFactory))
                        partAdded(part.id, this[part.id]);
                }
            }
        }
    }
    
	/**
	 *  Attach behaviors to the skin object. This method should be overridden
	 *  by subclasses.  The code to attach behaviors to an individual part
	 *  should be put into partAdded().  The code to attach behaviors to 
	 *  the skin object as a whole, should be done here.
	 *  
	 *  It is called by the loadSkin() method.
	 */
    protected function skinLoaded():void
    {
        skinObject.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, skin_propertyChangeHandler);
        
        // Declarative behaviors to the skin get attached here.  
        // Use partAdded for individual part behaviors
    }
    
	/**
	 *  Remove behavior from the skin object. This method should be overridden
	 *  by subclasses. 
	 *
	 *  It is called by the unloadSkin() method.
	 */
    protected function unloadingSkin():void
    {
        skinObject.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, skin_propertyChangeHandler);
        
        // Declarative behaviors to the skin get removed here.
        // Use partRemoved for individual part behaviors
    }
    
    /**
     *  Clear out references to skin parts. This method is called automatically
     *  by unloadSkin(), and should not be called directly.
     *  Typically, subclasses will not need to override this method.
     */
    protected function clearSkinParts():void
    {
        var className:String = getQualifiedClassName(this);
        var parts:Array = getSkinPartMetadata(className);
        
        if (parts)
        {
            for (var i:int = 0; i < parts.length; i++)
            {
                var skinPart:SkinPartInfo = parts[i];
                var skinPartID:String = skinPart.id;
                
                if (!(this[skinPartID] is IFactory))
                {
                    partRemoved(skinPartID, this[skinPartID]);
                }
                else
                {
                    var len:int = numDynamicParts(skinPartID);
                    for (var j:int = 0; j < len; j++)
                        removePartInstance(skinPartID, getDynamicPartAt(skinPartID, j));
                }
                
                this[skinPartID] = null;
            }
        }
    }
    
    /**
     *  Unload the skin for this component. This method should not be called
     *  directly. Typically, subclasses will not need to override this method.
     *
     *  This method is called whenever a skin is changed at runtime. It calls 
     *  unloadingSkin(), removes the skin, and clears all part associations.
     */
    protected function unloadSkin():void
    {       

        unloadingSkin();
        clearSkinParts();
        removeChild(skinObject);
        _skinObject = null;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods - Parts
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Called when a part has been added. Override this function to attach
     *  behavior to the part.
     */
    protected function partAdded(partName:String, instance:Object):void
    {   
    }

    /**
     *  Called when an instance of a dynamic part is being removed. 
     *  Override this function to remove behavior from the part.
     */
    protected function partRemoved(partName:String, instance:Object):void
    {       
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods - Dynamic Parts
    //
    //--------------------------------------------------------------------------
    
    // Private cache of instantiated dynamic parts. This is accessed through
    // the numDynamicParts() and getDynamicPartAt() methods.
    private var dynamicPartsCache:Object;
    
    /**
     *  Create an instance of a dynamic part. Dynamic parts should always be instantiated
     *  by this method, rather than directly calling newInstance() on the factory.
     *  This method creates the part, but does not add it to the display list.
     */
    protected function createPartInstance(partName:String):Object
    {
        var factory:IFactory = this[partName];
        
        if (factory)
        {
            var instance:* = factory.newInstance();
            
            // Add to the dynamic parts cache
            if (!dynamicPartsCache)
                dynamicPartsCache = new Object();
                
            if (!dynamicPartsCache[partName])
                dynamicPartsCache[partName] = new Array();
            
            dynamicPartsCache[partName].push(instance);
            
            // Send notification
            partAdded(partName, instance);
            
            return instance;
        }
        
        return null;
    }
    
    /**
     *  Remove an instance of a dynamic part. This method must be called before a dynamic part is
     *  deleted. This method does not remove the part from the display list.
     */
    protected function removePartInstance(partName:String, instance:Object):void
    {
        // Send notification
        partRemoved(partName, instance);
        
        // Remove from the dynamic parts cache
        var cache:Array = dynamicPartsCache[partName] as Array;
        cache.splice(cache.indexOf(instance), 1);
    }

    /**
     *  Returns the number of instances of a dynamic part.
     */
    protected function numDynamicParts(partName:String):int
    {
        if (dynamicPartsCache && dynamicPartsCache[partName])
            return dynamicPartsCache[partName].length;
        
        return 0;
    }
    
    /**
     *  Returns a specific instance of a dynamic part.
     */
    protected function getDynamicPartAt(partName:String, index:int):Object
    {
        if (dynamicPartsCache && dynamicPartsCache[partName])
            return dynamicPartsCache[partName][index];
        
        return null;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods - Part Metadata
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Cache of found skin parts.
     */
    private static var skinPartsByClassName:Dictionary;
    
    /**
     *  @private
     *  Find the skin part metadata for a given className.
     */
    private static function getSkinPartMetadata(className:String):Array
    {
        // Check cached values first
        if (!skinPartsByClassName)
            skinPartsByClassName = new Dictionary(true);
            
        var skinParts:Array = skinPartsByClassName[className];
        
        if (skinParts != null)
            return skinParts;
            
        var type:Class = ApplicationDomain.currentDomain.getDefinition(className) as Class;             
        skinParts = new Array;
        
        var des:XML = flash.utils.describeType(type);

        // Find Part metadata on variables 
        var metadata:XMLList = des.factory.variable.metadata.(@name == "SkinPart");
        var skinPartInfo:SkinPartInfo;
        var i:int;
        
        for (i = 0; i < metadata.length(); i++)
        {
            skinPartInfo = new SkinPartInfo();
            
            skinPartInfo.id = metadata[i].parent().@name;
            skinPartInfo.required = !(metadata[i].arg.(@key == "required").@value == "false");
            skinParts.push(skinPartInfo);
        }

        // Find Part metadata on getter/setters 
        metadata = des.factory.accessor.metadata.(@name == "SkinPart");
        for (i = 0; i < metadata.length(); i++)
        {
            skinPartInfo = new SkinPartInfo();
            
            skinPartInfo.id = metadata[i].parent().@name;
            skinPartInfo.required = !(metadata[i].arg.(@key == "required").@value == "false");
            skinParts.push(skinPartInfo);
        }
        
        skinPartsByClassName[className] = skinParts;
        return skinParts;           
    }

    //---------------------------------
    //  Utility methods for subclasses
    //---------------------------------
    
    // TODO (chaase): These could actually be static functions in a utility
    // class instead of protected methods in a component superclass. But since
    // they assume access to the systemManager property of the component, this
    // seems like the right place for now. If we're trying to save on footprint
    // at some point, we could extract the methods out of here and pass in
    // the component as an argument to derive the systemManager instead.
    
    /**
     * Add handlers to both the systemManager and stage objects to track this
     * event both on and off the stage. If <code>offstageHandler</code> is
     * <code>null</code> or is not supplied, <code>onstagehandler</code> will
     * be used as the handler for both situations.
     */ 
    protected function addSystemHandlers(eventType:String, onstageHandler:Function,
           offstageHandler:Function = null):void
    {
        if (offstageHandler == null)
            offstageHandler = onstageHandler;
        // For on-stage events
        systemManager.addEventListener(eventType, onstageHandler, true /*capture*/);
        // For off-stage events
        systemManager.stage.addEventListener(eventType, offstageHandler);
    }
    
    /**
     * Removes handlers from both the systemManager and stage objects for this
     * event. If <code>offstageHandler</code> is
     * <code>null</code> or is not supplied, <code>onstagehandler</code> will
     * be used as the handler for both situations. Parameters to this function
     * should match the parameters supplied to <code>addSystemHandlers</code>.
     */ 
    protected function removeSystemHandlers(eventType:String, onstageHandler:Function,
           offstageHandler:Function = null):void
    {
        if (offstageHandler == null)
            offstageHandler = onstageHandler;
        // For on-stage events
        systemManager.removeEventListener(eventType, onstageHandler, true /*capture*/);
        // For off-stage events
        systemManager.stage.removeEventListener(eventType, offstageHandler);
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
     * Called when a slot on the skin has been assigned a value. Deferred parts
     * may be instantiated long after the skin has been created.
     */
    private function skin_propertyChangeHandler(event:PropertyChangeEvent):void
    {
        var className:String = getQualifiedClassName(this);
        var parts:Array = getSkinPartMetadata(className);
        
        if (parts)
        {
            for (var i:int = 0; i < parts.length; i++)
            {
                var skinPart:SkinPartInfo = parts[i];
                
                if (event.property == skinPart.id)
                {
                    this[skinPart.id] = event.newValue;
                    
                    if (!(this[skinPart.id] is IFactory))
                        partAdded(skinPart.id, this[skinPart.id]);
                    break;
                }
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  True if the skin has changed and hasn't gone through validation yet.
     */
    private var skinChanged:Boolean = false;
    
        
    /**
     *  @private
     *  Whether the skin state is invalid or not.
     */
    protected var skinStateIsDirty:Boolean = false;  
}

}

class SkinPartInfo
{
    public function SkinPartInfo()
    {
        super();
    }
    
    public var id:String;

    public var required:Boolean;
}
