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
import mx.core.IIMESupport;

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
    //  editorUsesEnterKey
    //----------------------------------
    
    private var _editorUsesEnterKey:Boolean = false;

    [Inspectable(category="General", defaultValue="false")]
    
    /**
     *  @inheritdoc
     */
    public function get editorUsesEnterKey():Boolean
    {
        return _editorUsesEnterKey;
    }
    
    /**
     *  @private
     */
    public function set editorUsesEnterKey(value:Boolean):void
    {
        _editorUsesEnterKey = value;
    }
    
    //----------------------------------
    //  enableIME
    //----------------------------------
    
    /**
     *  @inheritdoc
     */
    public function get enableIME():Boolean
    {
        return true;
    }
    
    //----------------------------------
    //  imeMode
    //----------------------------------
    
    /**
     *  @private
     */
    private var _imeMode:String = null;
    
    [Inspectable(environment="none")]
    
    /**
     *  Specifies the IME (input method editor) mode.
     *  The IME enables users to enter text in Chinese, Japanese, and Korean.
     *  Flex sets the specified IME mode when the control gets the focus,
     *  and sets it back to the previous value when the control loses the focus.
     *
     * <p>The flash.system.IMEConversionMode class defines constants for the
     *  valid values for this property.
     *  You can also specify <code>null</code> to specify no IME.</p>
     *
     *  @see flash.system.IMEConversionMode
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get imeMode():String
    {
        return _imeMode;
    }
    
    /**
     *  @private
     */
    public function set imeMode(value:String):void
    {
        _imeMode = value;
        
        // set the ime mode in child controls
        var n:int = numElements;
        for (var i:int = 0; i < n; i++)
        {
            var child:IIMESupport = getElementAt(i) as IIMESupport;
            if (child)
            {
                child.imeMode = value;
            }
        }
        
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
        
        if (typeInfo == "")
        {
            if (data[property] is String)
                typeInfo = "String";
            else if (data[property] is uint)
                typeInfo = "uint";
            else if (data[property] is int)
                typeInfo = "int";
            else if (data[property] is Number)
                typeInfo = "Number";
            else if (data[property] is Boolean)
                typeInfo = "Boolean";
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
            if (!(newData is Number))
                newData = Number(newData);
        }
        else if (typeInfo == "Boolean")
        {
            if (!(newData is Boolean))
                newData = Boolean(newData);
        }
     
        if (property && data[property] != newData)
        {
            data[property] = newData;
            dataGrid.dataProvider.itemUpdated(data, property, data[property], newData);
            dataGrid.validateNow();
        }

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