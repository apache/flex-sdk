////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.gridClasses
{
import flash.utils.describeType;

import mx.core.mx_internal;

import spark.components.supportClasses.GridColumn;
import spark.components.DataGrid;
import spark.components.Group;
import spark.components.IGridItemEditor;
import spark.components.IGridItemRenderer;
import mx.validators.IValidatorListener;

use namespace mx_internal;
    
public class GridItemEditor extends Group implements IGridItemEditor
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
    public function GridItemEditor()
    {
    }
    
   //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  column
    //----------------------------------

    /**
     *  @private
     */
    private var _column:GridColumn;
    
    /**
     *  @inheritDoc 
     */
    public function get column():GridColumn
    {
        return _column;    
    }
    
    /**
     *  @private
     */
    public function set column(value:GridColumn):void
    {
        _column = value;   
    }
    
    //----------------------------------
    //  columnIndex
    //----------------------------------

    /**
     *  @private
     */
    private var _columnIndex:int;
    
    /**
     *  @inheritDoc 
     */
    public function get columnIndex():int
    {
        return _columnIndex;
    }

    /**
     *  @private
     */
    public function set columnIndex(value:int):void
    {
        _columnIndex = value;
    }
    
    //----------------------------------
    //  data
    //----------------------------------
    
    private var _data:Object = null;
    
    /**
     *  @inheritDoc 
     */
    public function get data():Object
    {
        return _data;
    }
    
    /**
     *  @private
     */
    public function set data(value:Object):void
    {
        _data = value;
    }

    //----------------------------------
    //  dataGrid
    //----------------------------------
    
    /**
     *  @inheritdoc
     */
    public function get dataGrid():DataGrid
    {
        return DataGrid(owner);
    }
    
    //----------------------------------
    //  itemRenderer
    //----------------------------------
    
    /**
     *  @private
     */
    private var _itemRenderer:IGridItemRenderer;
    
    /**
     *  @inheritDoc 
     */
    public function get itemRenderer():IGridItemRenderer
    {
        return _itemRenderer;
    }
    
    /**
     *  @private
     */
    public function set itemRenderer(value:IGridItemRenderer):void
    {
        _itemRenderer = value;
    }

    //----------------------------------
    //  rowIndex
    //----------------------------------
    
    /**
     *  @private
     */
    private var _rowIndex:int;
    
    /**
     *  @inheritDoc 
     */
    public function get rowIndex():int
    {
        return _rowIndex;
    }
    
    /**
     *  @private
     */
    public function set rowIndex(value:int):void
    {
        _rowIndex = value;
    }
    
    //----------------------------------
    //  value
    //----------------------------------
    
    /**
     *  @inheritDoc 
     */
    public function get value():Object
    {
        return null;
    }
    
    /**
     *  @private
     */
    public function set value(newValue:Object):void
    {
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
   //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    /**
     *  @inheritDoc 
     */
    public function cancel():void
    {
    }
    
    /**
     *  @inheritDoc 
     */
    public function discard():void
    {
    }
    
    /**
     *  @inheritDoc 
     */
    public function prepare():void
    {
    }
    
    /**
     *  @inheritDoc 
     */
    public function save():Boolean
    {
        if (!validate())
            return false;
        
        var newData:Object = value;
        var property:String = column.dataField;
        var data:Object = data;
        var typeInfo:String = "";
        for each(var variable:XML in describeType(data).variable)
        {
            if (property == variable.@name.toString())
            {
                typeInfo = variable.@type.toString();
                break;
            }
        }
        
        if (typeInfo == "String")
        {
            if (!(newData is String))
                newData = newData.toString();
        }
        else if (typeInfo == "uint")
        {
            if (!(newData is uint))
                newData = uint(newData);
        }
        else if (typeInfo == "int")
        {
            if (!(newData is int))
                newData = int(newData);
        }
        else if (typeInfo == "Number")
        {
            if (!(newData is int))
                newData = Number(newData);
        }
        
        data[property] = newData;
        dataGrid.dataProvider.itemUpdated(data, property, data[property], newData);
        dataGrid.validateNow();

        return true;
    }
    
    /**
     *  @inheritDoc 
     */
    public function validate():Boolean
    {
        // loop thru the children, looking for errors.
        var n:int = numElements;
        for (var i:int = 0; i < n; i++)
        {
            var child:IValidatorListener = getElementAt(i) as IValidatorListener;
            if (child && child.errorString)
            {
                return false;
            }
        }
        
        return true;
    }
    
}
}