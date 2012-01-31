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

import mx.components.DataGroup;
import mx.components.baseClasses.FxContainerBase;
import mx.events.FlexEvent;
import mx.events.ItemExistenceChangedEvent;
import mx.layout.LayoutBase;

import mx.collections.IList;
import mx.core.IFactory;
import mx.managers.IFocusManagerContainer;

[DefaultProperty("dataProvider")]

[IconFile("FxDataContainer.png")]

/**
 *  The FxDataContainer class is the base class for all skinnable components that have 
 *  data content. This class is not typically instantiated in MXML. It is primarily
 *  used as a base class, or as a skin part.
 *
 *  @see FxContainer
 */
public class FxDataContainer extends FxContainerBase
{
    include "../core/Version.as";

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
    public var dataGroup:DataGroup;
    
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
    //  content
    //----------------------------------    
    
    private var _dataProvider:IList;
    
    /**
     *  @copy mx.components.DataGroup#dataProvider
     */
    [Bindable]
    public function get dataProvider():IList
    {       
        if (dataGroup)
            return dataGroup.dataProvider;
        else
            return _dataProvider; 
    }
    
    public function set dataProvider(value:IList):void
    {
        if (value == _dataProvider)
            return;
            
        _dataProvider = value;  
        
        if (dataGroup)
            dataGroup.dataProvider = value;
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
        return (dataGroup) ? dataGroup.layout : _layout;
    }

    /**
     *  @private
     */
    public function set layout(value:LayoutBase):void
    {
        if (value != _layout) {
            _layout = value;
            if (dataGroup) {
                dataGroup.layout = _layout;
            }
        }
    }
    
    //----------------------------------
    //  itemRenderer
    //----------------------------------
    
    private var _itemRenderer:IFactory;
    
    /**
     *  The custom item renderer for the control. 
     *  You can specify a drop-in, inline, or custom item renderer. 
     */
    public function get itemRenderer():IFactory
    {
        if (dataGroup)
            return dataGroup.itemRenderer;
        
        return _itemRenderer;
    }
    
    /**
     *  @private
     */
    public function set itemRenderer(value:IFactory):void
    {
        if (value == _itemRenderer)
            return;
            
        _itemRenderer = value;
        
        if (dataGroup)
            dataGroup.itemRenderer = _itemRenderer;
    }
    
    //----------------------------------
    //  itemRendererFunction
    //----------------------------------
    
    private var _itemRendererFunction:Function;
    
    /**
     *  @copy mx.components.DataGroup#itemRendererFunction
     */
    public function get itemRendererFunction():Function
    {
        if (dataGroup)
            return dataGroup.itemRendererFunction;
        
        return _itemRendererFunction;
    }
    
    /**
     *  @private
     */
    public function set itemRendererFunction(value:Function):void
    {
        if (value == _itemRendererFunction)
            return;
        
        _itemRendererFunction = value;
        
        if (dataGroup)
            dataGroup.itemRendererFunction = _itemRendererFunction;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @inheritDoc
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        if (instance == dataGroup)
        {
            if (_dataProvider != null)
            {
                dataGroup.dataProvider = _dataProvider;
            }
            if (_layout != null)
                dataGroup.layout = _layout;
            if (_itemRenderer != null || _itemRendererFunction != null)
            {
                dataGroup.itemRenderer = _itemRenderer;
                dataGroup.itemRendererFunction = _itemRendererFunction;
            }
        }
    }
}

}
