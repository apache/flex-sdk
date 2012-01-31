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

// AdobePatentID="B976"

package spark.components.supportClasses
{

import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Point;
import flash.utils.*;

import mx.core.FlexVersion;
import mx.core.IFactory;
import mx.core.ILayoutElement;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.PropertyChangeEvent;

import spark.events.SkinPartEvent;
import spark.utils.FTETextUtil;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  @copy spark.components.supportClasses.GroupBase#style:chromeColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="chromeColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  Name of the skin class to use for this component when a validation error occurs. 
 *  
 *  @default spark.skins.spark.ErrorSkin
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="errorSkin", type="Class")]

/**
 *  Name of the skin class to use for this component. The skin must be a class 
 *  that extends UIComponent. 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="skinClass", type="Class")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="themeColor", kind="style")]
[Exclude(name="addChild", kind="method")]
[Exclude(name="addChildAt", kind="method")]
[Exclude(name="removeChild", kind="method")]
[Exclude(name="removeChildAt", kind="method")]
[Exclude(name="setChildIndex", kind="method")]
[Exclude(name="swapChildren", kind="method")]
[Exclude(name="swapChildrenAt", kind="method")]
[Exclude(name="numChildren", kind="property")]
[Exclude(name="getChildAt", kind="method")]
[Exclude(name="getChildIndex", kind="method")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[ResourceBundle("components")]

/**
 *  The SkinnableComponent class defines the base class for skinnable components. 
 *  The skins used by a SkinnableComponent class are typically child classes of 
 *  the Skin class.
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
 *  @see spark.components.supportClasses.Skin
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class SkinnableComponent extends UIComponent
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    
    private var _skinDestructionPolicy:String = "never";
    private var skinDestructionPolicyChanged:Boolean = false;
    
    /**
     *  @private
     * 
     *  If set to "auto", then the component will call detachSkin when it has been
     *  removed from the Stage. If it is then added back to the Stage, the component
     *  will call attachSkin. Set this to "auto" if you want to reduce the memory 
     *  usage of this component while it is not attached to the Stage. 
     * 
     *  Possible values are "auto" and "never".    
     * 
     *  @default "never"
     */ 
    mx_internal function get skinDestructionPolicy():String
    {
        return _skinDestructionPolicy;
    }
    
    mx_internal function set skinDestructionPolicy(value:String):void
    {
        if (value == _skinDestructionPolicy)
            return;
     
        _skinDestructionPolicy = value;
        
        skinDestructionPolicyChanged = true;
        invalidateProperties();
    }
    
    /**
     * @private 
     * 
     * Contains a flat list of all the skin parts. This includes
     * inherited skin parts. It is best to use a for...in to loop
     * through the skin parts. The property name will be the name of the 
     * skin part and it's value will be a boolean specifying if it is required
     * or not.
     */
    protected function get skinParts():Object
    {
        return null;
    }
    
    //----------------------------------
    //  skin
    //----------------------------------
    
    /**
     * @private 
     * Storage for skin instance
     */ 
    private var _skin:UIComponent;
    
    [Bindable("skinChanged")]
    
    /**
     *  The instance of the skin class for this component instance. 
     *  This is a read-only property that gets set automomatically when Flex 
     *  calls the <code>attachSkin()</code> method.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get skin():UIComponent
    {
        return _skin;
    }
    
    /**
     *  @private
     *  Setter for the skin instance.  This is so the bindable event
     *  is dispatched
     */ 
    private function setSkin(value:UIComponent):void
    {
        if (value === _skin)
           return;
        
        _skin = value;
        dispatchEvent(new Event("skinChanged"));
    }

    //----------------------------------
    //  suggestedFocusSkinExclusions
    //----------------------------------
    
    /**
     *  Lists the skin parts that are
     *  excluded from bitmaps captured and used to
     *  show focus. This list is only used if
     *  the skin's <code>focusSkinExclusions</code> property is <code>null</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get suggestedFocusSkinExclusions():Array
    {
        return null;
    }
    

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  baselinePosition
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function get baselinePosition():Number
    {
        if (!validateBaselinePosition())
            return NaN;

        // Unless the height is very small, the baselinePosition
        // of a generic UIComponent is calculated as if there was
        // a UITextField using the component's styles
        // whose top coincides with the component's top.
        // If the height is small, the baselinePosition is calculated
        // as if there were text within whose ascent the component
        // is vertically centered.
        // At the crossover height, these two calculations
        // produce the same result.

        return FTETextUtil.calculateFontBaseline(this, height, moduleFactory);
    }

    //----------------------------------
    //  currentCSSState
    //----------------------------------

    /**
     *  The state to be used when matching CSS pseudo-selectors. This override
     *  returns the current skin state instead of the component state.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    override protected function get currentCSSState():String
    {
        return getCurrentSkinState();
    }

    //----------------------------------
    //  enabled
    //----------------------------------

    [Inspectable(category="General", enumeration="true,false", defaultValue="true")]

    /**
     *  @private
     */
    override public function set enabled(value:Boolean):void
    {
        super.enabled = value;
        invalidateSkinState();

        // If enabled, reset the mouseChildren, mouseEnabled to the previously
        // set explicit value, otherwise disable mouse interaction.
        super.mouseChildren = value ? _explicitMouseChildren : false;
        super.mouseEnabled  = value ? _explicitMouseEnabled  : false; 
    }

    //----------------------------------
    //  errorString
    //----------------------------------

    /**
     *  @private
     */
    private var errorObj:DisplayObject;
    private var errorStringChanged:Boolean;
    
    /**
     *  @private
     */
    override public function set errorString(value:String):void
    {
        super.errorString = value;
        
        errorStringChanged = true;
        invalidateProperties();
    }
    
    //----------------------------------
    //  mouseEnabled
    //----------------------------------

    private var _explicitMouseEnabled:Boolean = true;

    /**
     *  @private
     */
    override public function set mouseEnabled(value:Boolean):void
    {
        if (enabled)
            super.mouseEnabled = value;
        _explicitMouseEnabled = value;
    }
    
    //----------------------------------
    //  mouseChildren
    //----------------------------------

    private var _explicitMouseChildren:Boolean = true;

    /**
     *  @private
     */
    override public function set mouseChildren(value:Boolean):void
    {
        if (enabled)
            super.mouseChildren = value;
        _explicitMouseChildren = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private 
     */
    override public function matchesCSSState(cssState:String):Boolean
    {
        return getCurrentSkinState() == cssState || currentState == cssState;
    }

    /**
     *  @private
     */
    override protected function createChildren():void
    {
        super.createChildren();
        
        if (moduleFactory)
            validateSkinChange();
    }
    
    /**
     *  @private
     */
    private function validateSkinChange():void
    {
        // If our new skin Class happens to match our existing skin Class there is no
        // reason to fully unload then reload our skin.  
        var skipReload:Boolean = false;
        
        if (_skin)
        {
            var factory:Object = getStyle("skinFactory");
            var newSkinClass:Class;
            
            // if it's a factory, only reload the skin if the skinFactory
            // style has been explicitly changed.  right now this style is only 
            // used by design view, and this is the contract we have with them.
            if (factory)
                skipReload = !skinFactoryStyleChanged;
            else
            {
                newSkinClass = getStyle("skinClass");
                
                skipReload = newSkinClass && 
                    getQualifiedClassName(newSkinClass) == getQualifiedClassName(_skin);
            }
            
            skinFactoryStyleChanged = false;
        }
        
        if (!skipReload)
        {
            if (skin)
                detachSkin();
            attachSkin();
        }
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
            validateSkinChange();
        }

        if (skinStateIsDirty)
        {
            // This component must first be updated to the pending state as the
            // skin inherits styles from this component.
            var pendingState:String = getCurrentSkinState();
            stateChanged(skin.currentState, pendingState, false);
            skin.currentState = pendingState;
            skinStateIsDirty = false;
        }
        
        if (errorStringChanged)
        {
            updateErrorSkin();
            errorStringChanged = false;
        }
        
        if (skinDestructionPolicyChanged)
        {
            if (skinDestructionPolicy == "auto")
            {
                addEventListener(Event.ADDED_TO_STAGE, adddedToStageHandler);
                addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
            }
            else
            {
                removeEventListener(Event.ADDED_TO_STAGE, adddedToStageHandler);
                removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
            }
            
            skinDestructionPolicyChanged = false;
        }
    }

    /**
     *  @private
     */
    override protected function measure():void
    {
        if (skin)
        {
            if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_5)
            {
                measuredWidth = skin.getExplicitOrMeasuredWidth();
                measuredHeight = skin.getExplicitOrMeasuredHeight();

                measuredMinWidth = isNaN( skin.explicitWidth ) ? skin.minWidth : skin.explicitWidth;
                measuredMinHeight = isNaN( skin.explicitHeight ) ? skin.minHeight : skin.explicitHeight;
            }
            else
            {
                measuredWidth = skin.getExplicitOrMeasuredWidth(); 
                measuredHeight = skin.getExplicitOrMeasuredHeight();

                measuredMinWidth = skin.minWidth;
                measuredMinHeight = skin.minHeight;
            }
        }
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        if (skin)
            skin.setActualSize(unscaledWidth, unscaledHeight);
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
            
            if (styleProp == "skinFactory")
                skinFactoryStyleChanged = true;
        }
        
        super.styleChanged(styleProp);
    }
    
    /**
     *  @private
     */
    mx_internal var focusObj:DisplayObject;
    mx_internal var drawFocusAnyway:Boolean;
    
    /**
     *  @private
     */
    override public function drawFocus(isFocused:Boolean):void
    {
        if (isFocused)
        {
            // For some composite components, the focused object may not
            // be "this". If so, we don't want to draw the focus.
            if (!drawFocusAnyway && focusManager.getFocus() != this)
                return;
                
            if (!focusObj)
            {
                var focusSkinClass:Class = getStyle("focusSkin");
                
                if (focusSkinClass)
                    focusObj = new focusSkinClass();
                
                if (focusObj)
                    super.addChildAt(focusObj, 0);
            }
            if (focusObj && "target" in focusObj)
                focusObj["target"] = this;
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
     *  <p>A subclass of SkinnableComponent must override this method to return a value.</p>
     * 
     *  @return A string specifying the name of the state to apply to the skin.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function getCurrentSkinState():String 
    {
        return null; 
    }
    
    /**
     *  Marks the component so that the new state of the skin is set
     *  during a later screen update.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function invalidateSkinState():void
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
     *  Create the skin for the component. 
     *  You do not call this method directly. 
     *  Flex calls it automatically when it calls <code>createChildren()</code> or  
     *  the <code>UIComponent.commitProperties()</code> method.
     *  Typically, a subclass of SkinnableComponent does not override this method.
     * 
     *  <p>This method instantiates the skin for the component, 
     *  adds the skin as a child of the component, and 
     *  resolves all part associations for the skin</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function attachSkin():void
    {
        // Factory
        var skinClassFactory:IFactory = getStyle("skinFactory") as IFactory;        
        
        if (skinClassFactory)
            setSkin( skinClassFactory.newInstance() as UIComponent );
        
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
            
            // the skin's styles should be the same as the components
            skin.styleName = this;
             
            // Note: The Spark PanelAccImpl adds a child Sprite at index 0.
            // The skin should be in front of that.
            super.addChild(skin);
            
            skin.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, skin_propertyChangeHandler);
        }
        else
        {
            throw(new Error(resourceManager.getString("components", "skinNotFound", [this])));
        }
        
        findSkinParts();
        
        invalidateSkinState();
    }
    
    /**
     *  Find the skin parts in the skin class and assign them to the properties of the component.
     *  You do not call this method directly. 
     *  Flex calls it automatically when it calls the <code>attachSkin()</code> method.
     *  Typically, a subclass of SkinnableComponent does not override this method.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function findSkinParts():void
    {
        if (skinParts)
        {
            for (var id:String in skinParts)
            {
                if (skinParts[id] == true)
                {
                    if (!(id in skin))
                        throw(new Error(resourceManager.getString("components", "requiredSkinPartNotFound", [id])));
                }
                
                if (id in skin)
                {
                    this[id] = skin[id];
                    
                    // If the assigned part has already been instantiated, call partAdded() here,
                    // but only for static parts.
                    if (this[id] != null && !(this[id] is IFactory))
                        partAdded(id, this[id]);
                }
            }
        }
    }
    
    /**
     *  Clear out references to skin parts. 
     *  You do not call this method directly. 
     *  Flex calls it automatically when it calls the <code>detachSkin()</code> method.
     *
     *  <p>Typically, subclasses of SkinnableComponent do not override this method.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function clearSkinParts():void
    {
        if (skinParts)
        {
            for (var id:String in skinParts)
            {
                if (this[id] != null)
                {
                    if (!(this[id] is IFactory))
                    {
                        partRemoved(id, this[id]);
                    }
                    else
                    {
                        var len:int = numDynamicParts(id);
                        for (var j:int = len - 1; j >= 0; j--)
                            removeDynamicPartInstance(id, getDynamicPartAt(id, j));
                    }
                }
              
                this[id] = null;
            }
        }
    }
    
    /**
     *  Destroys and removes the skin for this component. 
     *  You do not call this method directly. 
     *  Flex calls it automatically when a skin is changed at runtime.
     *
     *  This method removes the skin and clears all part associations.
     *
     *  <p>Typically, subclasses of SkinnableComponent do not override this method.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function detachSkin():void
    {       
        skin.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, skin_propertyChangeHandler);
        
        skin.styleName = null;
        clearSkinParts();
        super.removeChild(skin);
        setSkin(null);
    }
    
    /**
     *  @private
     *  Method to draw or remove the error skin. The error skin is added as a sibling of the skin. 
     */
    mx_internal function updateErrorSkin():void
    {
        if (errorString != null && errorString != "" && getStyle("showErrorSkin"))
        {
            if (!errorObj)
            {
                var errorObjClass:Class = getStyle("errorSkin");
                
                if (errorObjClass)
                    errorObj = new errorObjClass();
                
                if (errorObj)
                {
                    if ("target" in errorObj)
                        errorObj["target"] = this;
                    super.addChild(errorObj);
                }
            }
        }
        else
        {
            if (errorObj)
                super.removeChild(errorObj);
            
            errorObj = null;
        }
    }
    //--------------------------------------------------------------------------
    //
    //  Methods - Parts
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Called when a skin part is added. 
     *  You do not call this method directly. 
     *  For static parts, Flex calls it automatically when it calls the <code>attachSkin()</code> method. 
     *  For dynamic parts, Flex calls it automatically when it calls 
     *  the <code>createDynamicPartInstance()</code> method. 
     *
     *  <p>Override this function to attach behavior to the part. 
     *  If you want to override behavior on a skin part that is inherited from a base class, 
     *  do not call the <code>super.partAdded()</code> method. 
     *  Otherwise, you should always call the <code>super.partAdded()</code> method.</p>
     *
     *  @param partname The name of the part.
     *
     *  @param instance The instance of the part.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function partAdded(partName:String, instance:Object):void
    {
        // Dispatch a partAdded event.
        // This event is an internal implementation detail subject to change.
        // The accessibility implementation classes listen for this to know
        // when to add their event listeners to skin parts being added.
        var event:SkinPartEvent = new SkinPartEvent(SkinPartEvent.PART_ADDED);
        event.partName = partName;
        event.instance = instance;
        dispatchEvent(event);
    }

    /**
     *  Called when an instance of a skin part is being removed. 
     *  You do not call this method directly. 
     *  For static parts, Flex calls it automatically when it calls the <code>detachSkin()</code> method. 
     *  For dynamic parts, Flex calls it automatically when it calls 
     *  the <code>removeDynamicPartInstance()</code> method. 
     *
     *  <p>Override this function to remove behavior from the part.</p>
     *
     *  @param partname The name of the part.
     *
     *  @param instance The instance of the part.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function partRemoved(partName:String, instance:Object):void
    {       
        // Dispatch a partRemoved event.
        // This event is an internal implementation detail subject to change.
        // The accessibility implementation classes listen for this to know
        // when to remove their event listeners from skin parts being removed
        var event:SkinPartEvent = new SkinPartEvent(SkinPartEvent.PART_REMOVED);
        event.partName = partName;
        event.instance = instance;
        dispatchEvent(event);
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
     *  The component must call the <code>Group.addElement()</code> method, or the appropriate 
     *  method to add the skin part to the display list. 
     *
     *  @param partName The name of the part.
     *
     *  @return The instance of the part, or null if it cannot create the part.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  @param instance The instance of the part.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function getDynamicPartAt(partName:String, index:int):Object
    {
        if (dynamicPartsCache && dynamicPartsCache[partName])
            return dynamicPartsCache[partName][index];
        
        return null;
    }

    //---------------------------------
    //  Utility methods for subclasses
    //---------------------------------

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
        if (!part || !validateBaselinePosition())
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
        if (skinParts)
        {
            var skinPartID:String = event.property as String;
            if (skinParts[skinPartID] != null)
            {
                if (event.newValue == null)
                {
                    if (!(this[skinPartID] is IFactory))
                        partRemoved(skinPartID, this[skinPartID]);
                    this[skinPartID] = event.newValue;
                }
                else
                {
                    this[skinPartID] = event.newValue;                
                    if (!(this[skinPartID] is IFactory))
                        partAdded(skinPartID, this[skinPartID]);
                }
            }
        }
    }
    
    /**
     *  @private
     */
    private function adddedToStageHandler(event:Event):void
    {
        if (skin == null)
        {
            attachSkin();
        }
    }
    
    /**
     *  @private
     */
    private function removedFromStageHandler(event:Event):void
    {
        detachSkin();
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
        throw(new Error(resourceManager.getString("components", "addChildError")));
    }
    
    /**
     *  @private
     */
    override public function addChildAt(child:DisplayObject, index:int):DisplayObject
    {
        throw(new Error(resourceManager.getString("components", "addChildAtError")));
    }
    
    /**
     *  @private
     */
    override public function removeChild(child:DisplayObject):DisplayObject
    {
        throw(new Error(resourceManager.getString("components", "removeChildError")));
    }
    
    /**
     *  @private
     */
    override public function removeChildAt(index:int):DisplayObject
    {
        throw(new Error(resourceManager.getString("components", "removeChildAtError")));
    }
    
    /**
     *  @private
     */
    override public function setChildIndex(child:DisplayObject, index:int):void
    {
        throw(new Error(resourceManager.getString("components", "setChildIndexError")));
    }
    
    /**
     *  @private
     */
    override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
    {
        throw(new Error(resourceManager.getString("components", "swapChildrenError")));
    }
    
    /**
     *  @private
     */
    override public function swapChildrenAt(index1:int, index2:int):void
    {
        throw(new Error(resourceManager.getString("components", "swapChildrenAtError")));
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
     *  True if the skinFactory style has explicitly changed or not.  We use 
     *  this to determine whether we need to actually create a new skin or 
     *  not in validateSkinChange().
     */
    private var skinFactoryStyleChanged:Boolean = false;
    
        
    /**
     *  @private
     *  Whether the skin state is invalid or not.
     */
    private var skinStateIsDirty:Boolean = false;
}

}
