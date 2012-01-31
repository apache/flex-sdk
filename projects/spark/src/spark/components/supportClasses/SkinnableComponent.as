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

package mx.components.baseClasses
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.geom.Point;
import flash.system.ApplicationDomain;
import flash.utils.*;

import mx.components.Skin;
import mx.core.ClassFactory;
import mx.core.IFactory;
import mx.core.IFlexModuleFactory;
import mx.core.IInvalidating;
import mx.core.ILayoutElement;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.PropertyChangeEvent;
import mx.managers.ISystemManager;
import mx.modules.ModuleManager;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

include "../../styles/metadata/BasicContainerFormatTextStyles.as"
include "../../styles/metadata/AdvancedContainerFormatTextStyles.as"
include "../../styles/metadata/BasicParagraphFormatTextStyles.as"
include "../../styles/metadata/AdvancedParagraphFormatTextStyles.as"
include "../../styles/metadata/BasicCharacterFormatTextStyles.as"
include "../../styles/metadata/AdvancedCharacterFormatTextStyles.as"
include "../../styles/metadata/SelectionFormatTextStyles.as"
include "../../styles/metadata/SparkColorStyles.as"

/**
 *  Name of the skin class to use for this component. The skin must be a class that extends
 *  the mx.components.Skin class. 
 */
[Style(name="skinClass", type="Class")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="errorColor", kind="style")]
[Exclude(name="focusBlendMode", kind="style")]
[Exclude(name="focusThickness", kind="style")]
[Exclude(name="themeColor", kind="style")]

/**
 *  The FxComponent class defines the base class for skinnable components. 
 *  The skins used by a FxComponent class are child classes of the Skin class.
 *
 *  <p>Associate a skin class with a component class by setting the <code>skinClass</code> style property of the 
 *  component class. You can set the <code>skinClass</code> property in CSS, as the following example shows:</p>
 *
 *  <pre>MyComponent
 *  {
 *    skinClass: ClassReference("my.skins.MyComponentSkin")
 *  }</pre>
 *
 *  <p>The following example sets the <code>skinClass</code> property in MXML:</p>
 *
 *  <pre>
 *  &lt;MyComponent skinClass="my.skins.MyComponentSkin"/&gt;</pre>
 *
 *
 *  @see mx.components.Skin
 */
public class FxComponent extends UIComponent
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     */
    public function FxComponent()
    {
        // Initially state is dirty
        skinStateIsDirty = true;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private 
     * Storage for skin instance
     */ 
    private var _skin:Skin;
    
    [Bindable("skinChanged")]
    
    /**
     *  The instance of the skin class for this component instance. 
     *  This is a read-only property that you set 
     *  by calling the <code>loadSkin()</code> method.
     */
    public function get skin():Skin
    {
        return _skin;
    }
    
    /**
     *  @private
     *  Setter for the skin instance.  This is so the bindable event
     *  is dispatched
     */ 
    private function setSkin(value:Skin):void
    {
        if (value === _skin)
           return;
        
        _skin = value;
        dispatchEvent(new Event("skinChanged"));
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
  
            // If our new skin Class happens to match our existing skin Class there is no
            // reason to fully unload then reload our skin.  
            var skipReload:Boolean = false;
            
            if (_skin)
            {
                var factory:Object = getStyle("skinFactory");
                
                var newSkinClass:Class = (factory && factory is ClassFactory) ? 
                    ClassFactory(factory).generator :
                    getStyle("skinClass");
                    
                skipReload = newSkinClass && 
                    getQualifiedClassName(newSkinClass) == getQualifiedClassName(_skin);
            }
            
            if (!skipReload)
            {
                if (skin)
                    unloadSkin();
                loadSkin();
            }
        }
        
        if (skinStateIsDirty)
        {
            skin.currentState = getCurrentSkinState();
            skinStateIsDirty = false;
        }
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        if (skin)
        {
            measuredWidth = skin.getExplicitOrMeasuredWidth();
            measuredHeight = skin.getExplicitOrMeasuredHeight();
            measuredMinWidth = isNaN( skin.explicitWidth ) ? skin.minWidth : skin.explicitWidth;
            measuredMinHeight = isNaN( skin.explicitHeight ) ? skin.minHeight : skin.explicitHeight;
        }
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        if (skin)
            skin.setActualSize(unscaledWidth, unscaledHeight);

        if (focusObj && focusObj is IInvalidating)
            IInvalidating(focusObj).invalidateDisplayList();
    }
    
    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        var allStyles:Boolean = styleProp == null || styleProp == "styleName";
        
        if (allStyles || styleProp == "skinClass" || styleProp == "skinFactory")
        {
            skinChanged = true;
            invalidateProperties();
        }
        
        super.styleChanged(styleProp);
    }
    
    /**
     *  @private
     */
    mx_internal var focusObj:DisplayObject;
    
    override public function drawFocus(isFocused:Boolean):void
    {
        if (isFocused)
        {
            // For some composite components, the focused object may not
            // be "this". If so, we don't want to draw the focus.
            if (focusManager.getFocus() != this)
                return;
                
            if (!focusObj)
            {
                var focusSkinClass:Class = getStyle("focusSkin");
                
                if (focusSkinClass)
                    focusObj = new focusSkinClass();
                    
                super.addChildAt(focusObj, 0);
            }
        }
        else
        {
            if (focusObj)
                super.removeChild(focusObj);
            focusObj = null;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    // Skin states support
    //
    //--------------------------------------------------------------------------

    /**
     *  Returns the name of the state to be applied to the skin. For example, a
     *  Button component could return the String "up", "down", "over", or "disabled" 
     *  to specify the state.
     * 
     *  <p>A subclass of FxComponent must override this method to return a value.</p>
     * 
     *  @return A string specifying the name of the state to apply to the skin.
     */
    protected function getCurrentSkinState():String 
    {
        return null; 
    }
    
    /**
     *  Marks the component so that the new state of the skin will get set
     *  during a later screen update.
     */
    protected function invalidateSkinState():void
    {
        if (skinStateIsDirty)
            return; // State is already invalidated

        skinStateIsDirty = true;
        invalidateProperties();
    }

    //--------------------------------------------------------------------------
    //
    //  Methods - Skin/Behavior lifecycle
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Load the skin for the component. 
     *  You do not call this method directly. 
     *  Flex calls it automatically when it calls 
     *  the <code>UIComponent.commitProperties()</code> method.
     *  Typically, a subclass of FxComponent does not override this method.
     * 
     *  <p>This method instantiates the skin for the component, 
     *  adds the skin as a child of the component, and 
     *  resolves all part associations for the skin</p>
     */
    protected function loadSkin():void
    {
        // Factory
        var skinClassFactory:IFactory = getStyle("skinFactory") as IFactory;        
        
        if (skinClassFactory)
            setSkin( skinClassFactory.newInstance() as Skin );
        
        // Class
        if (!skin)
        {
            var skinClass:Class = getStyle("skinClass") as Class;
            
            if (skinClass)
                setSkin( new skinClass() );
        }
        
        if (skin)
        {
            skin.owner = this;
            skin.fxComponent = this;
            
            // As a convenience if someone has declared hostComponent
            // we assign a reference to ourselves.  If the hostComponent
            // property exists as a direct result of utilizing [HostComponent]
            // metadata it will be strongly typed. We need to do more work
            // here and only assign if the type exactly matches our component
            // type.
            if ("hostComponent" in skin)
            {
                try 
                {
                    Object(skin).hostComponent = this;
                }
                catch (err:Error) {}
            }
            
            super.addChild(skin);
            
            skin.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, skin_propertyChangeHandler);
        }
        else
        {
            throw(new Error("Skin for " + this + " cannot be found."));
        }
        
        findSkinParts();
        
        invalidateSkinState();
    }
    
    /**
     *  Find the skin parts in the skin class and assign them to the properties of the component.
     *  You do not call this method directly. 
     *  Flex calls it automatically when it calls the <code>loadSkin()</code> method.
     *  Typically, a subclass of FxComponent does not override this method.
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
                    if (!(part.id in skin))
                        throw(new Error("Required skin part \"" + part.id + "\" cannot be found.")); 
                }
                
                if (part.id in skin)
                {
                    this[part.id] = skin[part.id];
                    
                    // If the assigned part has already been instantiated, call partAdded() here,
                    // but only for static parts.
                    if (this[part.id] != null && !(this[part.id] is IFactory))
                        partAdded(part.id, this[part.id]);
                }
            }
        }
    }
    
    /**
     *  Clear out references to skin parts. 
     *  You do not call this method directly. 
     *  Flex calls it automatically when it calls the <code>unloadSkin()</code> method.
     *
     *  <p>Typically, subclasses of FxComponent do not override this method.</p>
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
                
                if (this[skinPartID] != null)
                {
                if (!(this[skinPartID] is IFactory))
                {
                    partRemoved(skinPartID, this[skinPartID]);
                }
                else
                {
                    var len:int = numDynamicParts(skinPartID);
                    for (var j:int = 0; j < len; j++)
                        removeDynamicPartInstance(skinPartID, getDynamicPartAt(skinPartID, j));
                }
            }
                this[skinPartID] = null;
            }
        }
    }
    
    /**
     *  Unload the skin for this component. 
     *  You do not call this method directly. 
     *  Flex calls it automatically when a skin is changed at runtime.
     *
     *  This method removes the skin and clears all part associations.
     *
     *  <p>Typically, subclasses of FxComponent do not override this method.</p>
     */
    protected function unloadSkin():void
    {       
        skin.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, skin_propertyChangeHandler);
        
        clearSkinParts();
        super.removeChild(skin);
        setSkin(null);
    }

    //--------------------------------------------------------------------------
    //
    //  Methods - Parts
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Called when a skin part is added. 
     *  You do not call this method directly. 
     *  For static parts, Flex calls it automatically when it calls the <code>loadSkin()</code> method. 
     *  For dynamic parts, Flex calls it automatically when it calls 
     *  the <code>createDynamicPartInstance()</code> method. 
     *
     *  <p>Override this function to attach behavior to the part. 
     *  If you want to override behavior on a skin part that is inherited from a base class, 
     *  make sure that you do not call the <code>super.partAdded()</code> method. 
     *  Otherwise, you should always call the <code>super.partAdded()</code> method.</p>
     *
     *  @param partname The name of the part.
     *
     *  @param instance The part.
     */
    protected function partAdded(partName:String, instance:Object):void
    {   
    }

    /**
     *  Called when an instance of a skin part is being removed. 
     *  You do not call this method directly. 
     *  For static parts, Flex calls it automatically when it calls the <code>unloadSkin()</code> method. 
     *  For dynamic parts, Flex calls it automatically when it calls 
     *  the <code>removeDynamicPartInstance()</code> method. 
     *
     *  <p>Override this function to remove behavior from the part.</p>
     *
     *  @param partname The name of the part.
     *
     *  @param instance The part.
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
     *  Create an instance of a dynamic skin part. 
     *  Dynamic skin parts should always be instantiated by this method, 
     *  rather than directly by calling the <code>newInstance()</code> method on the factory.
     *  This method creates the part, but does not add it to the display list.
     *  The componet must call the <code>Group.addElement()</code> method, or the appropriate 
     *  method to add the skin part to the display list. 
     *
     *  @param partName The name of the part.
     *
     *  @return The instance of the part, or null if it cannot create the part.
     */
    protected function createDynamicPartInstance(partName:String):Object
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
     *  Remove an instance of a dynamic part. 
     *  You must call this method  before a dynamic part is deleted.
     *  This method does not remove the part from the display list.
     *
     *  @param partname The name of the part.
     *
     *  @param instance The part.
     */
    protected function removeDynamicPartInstance(partName:String, instance:Object):void
    {
        // Send notification
        partRemoved(partName, instance);
        
        // Remove from the dynamic parts cache
        var cache:Array = dynamicPartsCache[partName] as Array;
        cache.splice(cache.indexOf(instance), 1);
    }

    /**
     *  Returns the number of instances of a dynamic part.
     *
     *  @param partName The name of the dynamic part.
     *
     *  @return The number of instances of the dynamic part.
     */
    protected function numDynamicParts(partName:String):int
    {
        if (dynamicPartsCache && dynamicPartsCache[partName])
            return dynamicPartsCache[partName].length;
        
        return 0;
    }
    
    /**
     *  Returns a specific instance of a dynamic part.
     *
     *  @param partName The name of the dynamic part.
     *
     *  @param index The index of the dynamic part.
     *
     *  @return The instance of the part, or null if it the part does not exist.
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
    private function getSkinPartMetadata(className:String):Array
    {
        // Check cached values first
        if (!skinPartsByClassName)
            skinPartsByClassName = new Dictionary(true);
            
        var skinParts:Array = skinPartsByClassName[className];
        
        if (skinParts != null)
            return skinParts;
            
        var myApplicationDomain:ApplicationDomain;
        
        var factory:IFlexModuleFactory = ModuleManager.getAssociatedFactory(this);
        if (factory != null)
        {
            myApplicationDomain = ApplicationDomain(factory.info()["currentDomain"]);
        }
        else
        {
            myApplicationDomain = systemManager ? 
                                    systemManager.loaderInfo.applicationDomain :
                                    ApplicationDomain.currentDomain;
        }
        
        var type:Class = myApplicationDomain.getDefinition(className) as Class;             
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
     * Add handlers to both the SystemManager and stage objects to track this
     * event both on and off the stage. 
     *
     *  @param eventType The event type to handle.
     *
     *  @param onstageHandler The handler added to the SystemManager object. 
     *
     *  @param offstageHandler The handler added to the stage.  
     *  If <code>null</code> or not specified, the <code>onstagehandler</code> 
     *  is used.
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
     * event. 
     * Parameters passed to this method should match the 
     * parameters supplied to the corresponding <code>addSystemHandlers()</code> method.
     *
     *  @param eventType The event type to handle.
     *
     *  @param onstageHandler The handler added to the SystemManager object. 
     *
     *  @param offstageHandler The handler added to the stage.  
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

    /**
     * @private
     * 
     * Utility method to calculate a skin part's position relative to our component.
     *
     * @param part The skin part instance to obtain coordinates of.
     *
     * @return The component relative position of the part.
     */ 
    protected function getSkinPartPosition(part:IVisualElement):Point
    {
        return (!part || !part.parent) ? new Point(0, 0) :
            globalToLocal(part.parent.localToGlobal(new Point((part as ILayoutElement).getLayoutBoundsX(), (part as ILayoutElement).getLayoutBoundsY())));
    }
    
    /**
     * @private
     * 
     * Utility method to calculate a skin part's baseline position relative to 
     * the component.
     *
     * @param part The skin part instance to obtain baseline of.
     *
     * @return The baseline position of the part.
     */ 
    protected function getBaselinePositionForPart(part:IVisualElement):Number
    {
        if (!part || !mx_internal::validateBaselinePosition())
            return super.baselinePosition;

        return getSkinPartPosition(part).y + part.baselinePosition;
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
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function addChild(child:DisplayObject):DisplayObject
    {
        throw(new Error("addChild is not available in FxComponent. " + 
                "Instead, modify the skin directly or use addItem."));
    }
    
    /**
     *  @private
     */
    override public function addChildAt(child:DisplayObject, index:int):DisplayObject
    {
        throw(new Error("addChildAt is not available in FxComponent. " + 
                "Instead, modify the skin directly or use addItemAt."));
    }
    
    /**
     *  @private
     */
    override public function removeChild(child:DisplayObject):DisplayObject
    {
        throw(new Error("removeChild is not available in FxComponent. " + 
                "Instead, modify the skin directly or use removeItem."));
    }
    
    /**
     *  @private
     */
    override public function removeChildAt(index:int):DisplayObject
    {
        throw(new Error("removeChildAt is not available in FxComponent. " + 
                "Instead, modify the skin directly or use removeItemAt."));
    }
    
    /**
     *  @private
     */
    override public function setChildIndex(child:DisplayObject, index:int):void
    {
        throw(new Error("setChildIndex is not available in FxComponent. " + 
                "Instead, modify the skin directly or setItemIndex."));
    }
    
    /**
     *  @private
     */
    override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
    {
        throw(new Error("swapChildren is not available in FxComponent. " + 
                "Instead, modify the skin directly or use swapItems."));
    }
    
    /**
     *  @private
     */
    override public function swapChildrenAt(index1:int, index2:int):void
    {
        throw(new Error("swapChildrenAt is not available in FxComponent. " + 
                "Instead, modify the skin directly or use swapItemsAt."));
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
    private var skinStateIsDirty:Boolean = false;
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
