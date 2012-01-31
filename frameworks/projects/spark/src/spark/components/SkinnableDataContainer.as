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

package mx.components
{

import mx.collections.IList;
import mx.components.DataGroup;
import mx.components.baseClasses.FxContainerBase;
import mx.core.IFactory;
import mx.core.IViewport;
import mx.core.ScrollUnit;
import mx.events.FlexEvent;
import mx.events.ItemExistenceChangedEvent;
import mx.events.PropertyChangeEvent;
import mx.layout.LayoutBase;
import mx.managers.IFocusManagerContainer;
import mx.utils.BitFlagUtil;

/**
 *  Dispatched when an item is added to the content holder.
 *  event.
 *
 *  @eventType mx.events.ItemExistenceChangedEvent.ITEM_ADD
 */
[Event(name="itemAdd", type="mx.events.ItemExistenceChangedEvent")]

/**
 *  Dispatched when an item is removed from the content holder.
 *  event.
 *
 *  @eventType mx.events.ItemExistenceChangedEvent.ITEM_REMOVE
 */
[Event(name="itemRemove", type="mx.events.ItemExistenceChangedEvent")]

[DefaultProperty("dataProvider")]

[IconFile("FxDataContainer.png")]

/**
 *  The FxDataContainer class is the base class for all skinnable components that have 
 *  data content.
 *
 *  @see FxContainer
 */
public class FxDataContainer extends FxContainerBase implements IViewport
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
    private static const CLIP_CONTENT_PROPERTY_FLAG:uint = 1 << 0;
    
    /**
     *  @private
     */
    private static const LAYOUT_PROPERTY_FLAG:uint = 1 << 1;
    
    /**
     *  @private
     */
    private static const HORIZONTAL_SCROLL_POSITION_PROPERTY_FLAG:uint = 1 << 2;
    
    /**
     *  @private
     */
    private static const VERTICAL_SCROLL_POSITION_PROPERTY_FLAG:uint = 1 << 3;
    
    /**
     *  @private
     */
    private static const DATA_PROVIDER_PROPERTY_FLAG:uint = 1 << 4;
    
    /**
     *  @private
     */
    private static const ITEM_RENDERER_PROPERTY_FLAG:uint = 1 << 5;
    
    /**
     *  @private
     */
    private static const ITEM_RENDERER_FUNCTION_PROPERTY_FLAG:uint = 1 << 6;

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */
    public function FxDataContainer()
    {
        super();
        
        tabChildren = true;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    [SkinPart]
    
    /**
     *  A required skin part that defines the DataGroup where the data 
     *  items get pushed into, rendered, and laid out.
     */
    public var dataGroup:DataGroup;
    
    /**
     *  @private
     *  Several properties are proxied to dataGroup.  However, when dataGroup
     *  is not around, we need to store values set on FxDataContainer.  This object 
     *  stores those values.  If dataGroup is around, the values are stored 
     *  on the dataGroup directly.  However, we need to know what values 
     *  have been set by the developer on the FxDataContainer (versus set on 
     *  the dataGroup or defaults of the dataGroup) as those are values 
     *  we want to carry around if the dataGroup changes (via a new skin). 
     *  In order to store this info effeciently, dataGroupProperties becomes 
     *  a uint to store a series of BitFlags.  These bits represent whether a 
     *  property has been explicitely set on this FxDataContainer.  When the 
     *  dataGroup is not around, dataGroupProperties is a typeless 
     *  object to store these proxied properties.  When dataGroup is around,
     *  dataGroupProperties stores booleans as to whether these properties 
     *  have been explicitely set or not.
     */
    private var dataGroupProperties:Object = {};
    
    //--------------------------------------------------------------------------
    //
    //  Properties 
    //
    //--------------------------------------------------------------------------
    
    //--------------------------------------------------------------------------
    //
    //  Properties proxied to dataGroup
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  clipContent
    //----------------------------------
    
    /**
     *  @inheritDoc
     */
    public function get clipContent():Boolean 
    {
        return (dataGroup) 
            ? dataGroup.clipContent 
            : dataGroupProperties.clipContent;
    }

    /**
     *  @private
     */
    public function set clipContent(value:Boolean):void 
    {       
        if (skin)  // TEMPORARY fix for SDK-17751
            skin.clipContent = value;
        if (dataGroup)
        {
            dataGroup.clipContent = value;
            dataGroupProperties = BitFlagUtil.update(dataGroupProperties as uint, 
                                                     CLIP_CONTENT_PROPERTY_FLAG, true);
        }
        else
            dataGroupProperties.clipContent = value;
    }
    
    //----------------------------------
    //  contentWidth
    //---------------------------------- 
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]    

    /**
     *  @inheritDoc
     */
    public function get contentWidth():Number 
    {
        return (dataGroup) ? dataGroup.contentWidth : 0;  
    }

    //----------------------------------
    //  contentHeight
    //---------------------------------- 
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]    

    /**
     *  @inheritDoc
     */
    public function get contentHeight():Number 
    {
        return (dataGroup) ? dataGroup.contentHeight : 0;
    }
    
    //----------------------------------
    //  content
    //----------------------------------    
    
    /**
     *  @copy mx.components.DataGroup#dataProvider
     */
    [Bindable]
    public function get dataProvider():IList
    {       
        return (dataGroup) 
            ? dataGroup.dataProvider 
            : dataGroupProperties.dataProvider;
    }
    
    public function set dataProvider(value:IList):void
    {
        if (dataGroup)
        {
            dataGroup.dataProvider = value;
            dataGroupProperties = BitFlagUtil.update(dataGroupProperties as uint, 
                                                     DATA_PROVIDER_PROPERTY_FLAG, true);
        }
        else
            dataGroupProperties.dataProvider = value;
    }
    
    //----------------------------------
    //  horizontalScrollPosition
    //----------------------------------
        
    [Bindable("propertyChange")]

    /**
     *  @inheritDoc
     */
    public function get horizontalScrollPosition():Number 
    {
        return (dataGroup) 
            ? dataGroup.horizontalScrollPosition 
            : dataGroupProperties.horizontalScrollPosition;
    }

    /**
     *  @private
     */
    public function set horizontalScrollPosition(value:Number):void 
    {
        if (dataGroup)
        {
            dataGroup.horizontalScrollPosition = value;
            dataGroupProperties = BitFlagUtil.update(dataGroupProperties as uint, 
                                                     HORIZONTAL_SCROLL_POSITION_PROPERTY_FLAG, true);
        }
        else
            dataGroupProperties.horizontalScrollPosition = value;
    }
    
    //----------------------------------
    //  itemRenderer
    //----------------------------------
    
    /**
     *  @copy mx.components.DataGroup#itemRenderer
     */
    public function get itemRenderer():IFactory
    {
        return (dataGroup) 
            ? dataGroup.itemRenderer 
            : dataGroupProperties.itemRenderer;
    }
    
    /**
     *  @private
     */
    public function set itemRenderer(value:IFactory):void
    {
        if (dataGroup)
        {
            dataGroup.itemRenderer = value;
            dataGroupProperties = BitFlagUtil.update(dataGroupProperties as uint, 
                                                     ITEM_RENDERER_PROPERTY_FLAG, true);
        }
        else
            dataGroupProperties.itemRenderer = value;
    }
    
    //----------------------------------
    //  itemRendererFunction
    //----------------------------------
    
    /**
     *  @copy mx.components.DataGroup#itemRendererFunction
     */
    public function get itemRendererFunction():Function
    {
        return (dataGroup) 
            ? dataGroup.itemRendererFunction 
            : dataGroupProperties.itemRendererFunction;
    }
    
    /**
     *  @private
     */
    public function set itemRendererFunction(value:Function):void
    {
        if (dataGroup)
        {
            dataGroup.itemRendererFunction = value;
            dataGroupProperties = BitFlagUtil.update(dataGroupProperties as uint, 
                                                     ITEM_RENDERER_FUNCTION_PROPERTY_FLAG, true);
        }
        else
            dataGroupProperties.itemRendererFunction = value;
    }
    
    //----------------------------------
    //  layout
    //----------------------------------
    
    private var _layout:LayoutBase;
    
    /**
     *  @copy mx.components.baseClasses.GroupBase#layout
     */     
    public function get layout():LayoutBase
    {
        return (dataGroup) 
            ? dataGroup.layout 
            : dataGroupProperties.layout;
    }

    /**
     *  @private
     */
    public function set layout(value:LayoutBase):void
    {
        if (dataGroup)
        {
            dataGroup.layout = value;
            dataGroupProperties = BitFlagUtil.update(dataGroupProperties as uint, 
                                                     LAYOUT_PROPERTY_FLAG, true);
        }
        else
            dataGroupProperties.layout = value;
    }
    
    //----------------------------------
    //  verticalScrollPosition
    //----------------------------------
    
    [Bindable("propertyChange")]
    
    /**
     *  @inheritDoc
     */
    public function get verticalScrollPosition():Number 
    {
        return (dataGroup) 
            ? dataGroup.verticalScrollPosition 
            : dataGroupProperties.verticalScrollPosition;
    }

    /**
     *  @private
     */
    public function set verticalScrollPosition(value:Number):void 
    {
        if (dataGroup)
        {
            dataGroup.verticalScrollPosition = value;
            dataGroupProperties = BitFlagUtil.update(dataGroupProperties as uint, 
                                                     VERTICAL_SCROLL_POSITION_PROPERTY_FLAG, true);
        }
        else
            dataGroupProperties.verticalScrollPosition = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods proxied to dataGroup
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  getHorizontal,VerticalScrollPositionDelta
    //----------------------------------

    /**
     *  @inheritDoc
     */
    public function getHorizontalScrollPositionDelta(unit:ScrollUnit):Number
    {
        return (dataGroup) ? 
            dataGroup.getHorizontalScrollPositionDelta(unit) : 0;     
    }
    
    /**
     *  @inheritDoc
     */
    public function getVerticalScrollPositionDelta(unit:ScrollUnit):Number
    {
        return (dataGroup) ? 
            dataGroup.getVerticalScrollPositionDelta(unit) : 0;     
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        if (instance == dataGroup)
        {
            // copy proxied values from dataGroupProperties (if set) to dataGroup
            
            var newDataGroupProperties:uint = 0;
            
            if (dataGroupProperties.clipContent !== undefined)
            {
                dataGroup.clipContent = dataGroupProperties.clipContent;
                skin.clipContent = dataGroupProperties.clipContent;  // TEMPORARY fix for SDK-17751
                newDataGroupProperties = BitFlagUtil.update(newDataGroupProperties as uint, 
                                                            CLIP_CONTENT_PROPERTY_FLAG, true);
            }
            
            if (dataGroupProperties.layout !== undefined)
            {
                dataGroup.layout = dataGroupProperties.layout;
                newDataGroupProperties = BitFlagUtil.update(newDataGroupProperties as uint, 
                                                            LAYOUT_PROPERTY_FLAG, true);;
            }
            
            if (dataGroupProperties.horizontalScrollPosition !== undefined)
            {
                dataGroup.horizontalScrollPosition = dataGroupProperties.horizontalScrollPosition;
                newDataGroupProperties = BitFlagUtil.update(newDataGroupProperties as uint, 
                                                            HORIZONTAL_SCROLL_POSITION_PROPERTY_FLAG, true);
            }
            
            if (dataGroupProperties.verticalScrollPosition !== undefined)
            {
                dataGroup.verticalScrollPosition = dataGroupProperties.verticalScrollPosition;
                newDataGroupProperties = BitFlagUtil.update(newDataGroupProperties as uint, 
                                                            VERTICAL_SCROLL_POSITION_PROPERTY_FLAG, true);
            }
            
            if (dataGroupProperties.dataProvider !== undefined)
            {
                dataGroup.dataProvider = dataGroupProperties.dataProvider;
                newDataGroupProperties = BitFlagUtil.update(newDataGroupProperties as uint, 
                                                            DATA_PROVIDER_PROPERTY_FLAG, true);
            }
            
            if (dataGroupProperties.itemRenderer !== undefined)
            {
                dataGroup.itemRenderer = dataGroupProperties.itemRenderer;
                newDataGroupProperties = BitFlagUtil.update(newDataGroupProperties as uint, 
                                                            ITEM_RENDERER_PROPERTY_FLAG, true);
            }
            
            if (dataGroupProperties.itemRendererFunction !== undefined)
            {
                dataGroup.itemRendererFunction = dataGroupProperties.itemRendererFunction;
                newDataGroupProperties = BitFlagUtil.update(newDataGroupProperties as uint, 
                                                            ITEM_RENDERER_FUNCTION_PROPERTY_FLAG, true);
            }
            
            dataGroupProperties = newDataGroupProperties;
            
            dataGroup.addEventListener(
                ItemExistenceChangedEvent.ITEM_ADD, dataGroup_itemAddedHandler);
            dataGroup.addEventListener(
                ItemExistenceChangedEvent.ITEM_REMOVE, dataGroup_itemRemovedHandler);
            dataGroup.addEventListener(
                PropertyChangeEvent.PROPERTY_CHANGE, dataGroup_propertyChangeHandler);
        }
    }
    
    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == dataGroup)
        {
            dataGroup.removeEventListener(
                ItemExistenceChangedEvent.ITEM_ADD, dataGroup_itemAddedHandler);
            dataGroup.removeEventListener(
                ItemExistenceChangedEvent.ITEM_REMOVE, dataGroup_itemRemovedHandler);
            dataGroup.removeEventListener(
                PropertyChangeEvent.PROPERTY_CHANGE, dataGroup_propertyChangeHandler);
            
            // copy proxied values from dataGroup (if explicitely set) to dataGroupProperties
            
            var newDataGroupProperties:Object = {};
            
            if (BitFlagUtil.isSet(dataGroupProperties as uint, CLIP_CONTENT_PROPERTY_FLAG))
                newDataGroupProperties.clipContent = dataGroup.clipContent;
            
            if (BitFlagUtil.isSet(dataGroupProperties as uint, LAYOUT_PROPERTY_FLAG))
                newDataGroupProperties.layout = dataGroup.layout;
            
            if (BitFlagUtil.isSet(dataGroupProperties as uint, HORIZONTAL_SCROLL_POSITION_PROPERTY_FLAG))
                newDataGroupProperties.horizontalScrollPosition = dataGroup.horizontalScrollPosition;
            
            if (BitFlagUtil.isSet(dataGroupProperties as uint, VERTICAL_SCROLL_POSITION_PROPERTY_FLAG))
                newDataGroupProperties.verticalScrollPosition = dataGroup.verticalScrollPosition;
            
            if (BitFlagUtil.isSet(dataGroupProperties as uint, DATA_PROVIDER_PROPERTY_FLAG))
                newDataGroupProperties.dataProvider = dataGroup.dataProvider;
            
            if (BitFlagUtil.isSet(dataGroupProperties as uint, ITEM_RENDERER_PROPERTY_FLAG))
                newDataGroupProperties.itemRenderer = dataGroup.itemRenderer;
            
            if (BitFlagUtil.isSet(dataGroupProperties as uint, ITEM_RENDERER_FUNCTION_PROPERTY_FLAG))
                newDataGroupProperties.itemRendererFunction = dataGroup.itemRendererFunction;
                
            dataGroupProperties = newDataGroupProperties;
            
            dataGroup.dataProvider = null;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    private function dataGroup_itemAddedHandler(event:ItemExistenceChangedEvent):void
    {
        // Re-dispatch the event
        dispatchEvent(event);
    }
    
    private function dataGroup_itemRemovedHandler(event:ItemExistenceChangedEvent):void
    {
        // Re-dispatch the event
        dispatchEvent(event);
    }
    
   /**
    * @private
    */
    private function dataGroup_propertyChangeHandler(event:PropertyChangeEvent):void
    {
        // Re-dispatch the event if it's one other people are binding too
        switch (event.property)
        {
            case 'contentWidth':
            case 'contentHeight':
            case 'horizontalScrollPosition':
            case 'verticalScrollPosition':
            {
                dispatchEvent(event);
            }
        }
    }
}

}
