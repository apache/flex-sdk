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
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.describeType;


import mx.core.IIMESupport;
import mx.core.IInvalidating;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.mx_internal;
import mx.core.UIComponent;
import mx.validators.IValidatorListener;

import spark.components.gridClasses.GridColumn;
import spark.components.DataGrid;
import spark.components.Group;

use namespace mx_internal;

/**
 *  Base class for grid item editors. 
 */
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
     *  @inheritDoc 
     */
    public function get columnIndex():int
    {
        return column.columnIndex;;
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
        
        if (_data && column.dataField)
        {
            this.value = _data[column.dataField];            
        }
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
    
    private var _value:Object;
    
    [Bindable("valueChanged")]

    /** 
     *  Many custom GridItemEditor subclasses will only need to override the 
     *  get and set methods for this property.   Override the set method to 
     *  initialize the editor’s input  controls based on the value. The value
     *  property is initialized by the set data method, which sets the value 
     *  to data.dataField. The get value method should be overridden to return
     *  a new value for data.dataField based on the user’s input. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */ 
    public function get value():Object
    {
        return _value;
    }
    
    /**
     *  @private
     */
    public function set value(newValue:Object):void
    {
        if (newValue != value)
        {
            _value = newValue
            
            if (hasEventListener("valueChanged"))
            {
                dispatchEvent(new Event("valueChanged"));
            }
        }
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
    public function discard():void
    {
        // Clean up 
        clearErrorStringFromContainer(this);
        removeEventListener(MouseEvent.MOUSE_UP, mouseUpDownHandler);
        removeEventListener(MouseEvent.MOUSE_DOWN, mouseUpDownHandler);
    }
    
    /**
     *  @inheritDoc 
     */
    public function prepare():void
    {
        // Stop the item renderer from seeing mouse clicks on the editor.
        addEventListener(MouseEvent.MOUSE_UP, mouseUpDownHandler);
        addEventListener(MouseEvent.MOUSE_DOWN, mouseUpDownHandler);
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
        
        if (typeInfo == "" && newData != null)
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
            {
                var strNewData:String = newData.toString();
                if (strNewData)
                {
                    newData = (strNewData.toLowerCase() == "true") ? true : false;
                }
            }
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
     *  Tests if the value in the editor is valid and may be saved.
     * 
     *  @returns true if the value in the editor is valid. Otherwise
     *  false is returned.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */  
    protected function validate():Boolean
    {
        return validateContainer(this);
    }
    
    /**
     *  @private
     *  
     *  Verify the container's children are valid.
     *  @param container container to verify, may not be null.
     *  @return true if the container and its children are valid, false otherwise. 
     */
    private function validateContainer(container:IVisualElementContainer):Boolean
    {
        if (container is IValidatorListener && IValidatorListener(container).errorString)
            return false;
        
        // loop thru the children, looking for errors.
        var n:int = container.numElements;
        for (var i:int = 0; i < n; i++)
        {
            var child:IVisualElement = container.getElementAt(i);
            if (child is IValidatorListener && IValidatorListener(child).errorString)
            {
                return false;
            }
            
            if (child is IVisualElementContainer &&
                !validateContainer(IVisualElementContainer(child)))
            {
                return false;
            }
                
        }
        
        return true;
    }
    
    /**
     *  @private
     *  
     *  Clear the error strings left by any validators. This will ensure any
     *  tooltips left by a validator are torn down.
     * 
     *  @param container container to verify, may not be null.
     */
    private function clearErrorStringFromContainer(container:IVisualElementContainer):void
    {
        if (container is IValidatorListener && IValidatorListener(container).errorString)
        {
            clearErrorString(IValidatorListener(container));
        }
        
        // loop thru the children, looking for errors to clear.
        var n:int = container.numElements;
        for (var i:int = 0; i < n; i++)
        {
            var child:IVisualElement = container.getElementAt(i);
            if (child is IValidatorListener && IValidatorListener(child).errorString)
            {
                clearErrorString(IValidatorListener(child));
            }
            
            if (child is IVisualElementContainer)
            {
                clearErrorStringFromContainer(IVisualElementContainer(child));
            }
        }
        
    }    
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  
     *  Clear the error string left by a validator. This will ensure any
     *  tooltips left by a validator are torn down.
     * 
     *  @param validatorListener listener to clear error message in.
     */
    private function clearErrorString(validatorListener:IValidatorListener):void
    {
        validatorListener.errorString = "";
        if (validatorListener is IInvalidating)
        {
            IInvalidating(validatorListener).validateNow();
        }
    }
    
    /**
     *   @private
     *   Stop the item renderer from getting the click.
     */ 
    private function mouseUpDownHandler(event:MouseEvent):void
    {
        event.preventDefault();
    }
}
}