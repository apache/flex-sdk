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
import flash.geom.Point;
import flash.utils.describeType;


import mx.collections.ICollectionView;
import mx.collections.ISort;
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
 *  The GridItemEditor class defines the base class for custom item editors
 *  for the Spark grid controls, such as DataGrid and Grid.   
 *  Item editors lets you edit the value of the cell of the grid, and then 
 *  save that value back to the data provider of the control.
 *
 *  <p>Item editors are associated with each column of a grid.
 *  Set the item editor for a column by using 
 *  the <code>GridColumn.itemEditor property</code>.</p> 
 *
 *  @mxml <p>The <code>&lt;s:GridItemEditor&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:GridItemEditor
 *    <strong>Properties</strong>
 *    column="null"
 *    data="null"
 *    imeMode="null"
 *    itemRenderer="null"
 *    rowIndex="0"
 *    value="null"
 *  /&gt;
 *  </pre>
 * 
 *  @see spark.components.DataGrid
 *  @see spark.components.Grid
 *  @see spark.components.gridClasses.GridColumn
 *  @see spark.components.gridClasses.GridColumn#itemEditor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
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
     *  
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
     *  
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get dataGrid():DataGrid
    {
        return DataGrid(owner);
    }
    
    //----------------------------------
    //  enableIME
    //----------------------------------
    
    /**
     *  A flag that indicates whether the IME should
     *  be enabled when the component receives focus.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
     *  Specifies the IME (Input Method Editor) mode.
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
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
     *  The item renderer associated with the edited cell.
     *  
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
     *  
     *  @default 0
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
     *  By default, this property is initialized by the setter method of 
     *  the <code>data</code> property. 
     *  The default value of this property is the cell data from the 
     *  data provider of the grid control.
     *  The item editor can use this property to initialize 
     *  any visual elements in the item editor.
     *
     *  <p>By default, the <code>save()</code> method write the value of 
     *  this property back to the data provider of the grid control 
     *  when the editor closes on a save. </p>
     * 
     *  <p>Many custom item renderers override the getter and setter methods 
     *  of this property.   
     *  Override the setter method to initialize the editor based on the cell value. 
     *  Override the getter method  to return a new cell value to 
     *  the <code>save()</code> method. </p>
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function discard():void
    {
        // Clean up 
        clearErrorStringFromContainer(this);
        removeEventListener(MouseEvent.MOUSE_UP, mouseUpDownMoveHandler);
        removeEventListener(MouseEvent.MOUSE_DOWN, mouseUpDownMoveHandler);
        removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
    }
    
    /**
     *  @inheritDoc 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function prepare():void
    {
        // Stop the item renderer from seeing mouse clicks on the editor.
        addEventListener(MouseEvent.MOUSE_UP, mouseUpDownMoveHandler);
        addEventListener(MouseEvent.MOUSE_DOWN, mouseUpDownMoveHandler);
        
        // Stop hover highlighting on rows underneath the editor.
        addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
    }
    
    /**
     *  @inheritDoc 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
     
        if (property && data[property] !== newData)
        {
            // If the data is sorted, turn off the sort for the edited data.
            var sort:ISort = null;
            if (dataGrid.dataProvider is ICollectionView)
            {
                var dataProvider:ICollectionView = ICollectionView(dataGrid.dataProvider);
                if (dataProvider.sort)
                {
                    sort = dataProvider.sort;
                    dataProvider.sort = null;
                }
            }
            
            var oldData:Object = data[property];
            data[property] = newData;
            dataGrid.dataProvider.itemUpdated(data, property, oldData, newData);
            
            // Restore the sort. The data will not be sorted due to this change.
            if (sort)
                ICollectionView(dataGrid.dataProvider).sort = sort;
        }

        return true;
    }
    
    /**
     *  Tests if the value in the editor is valid and may be saved.
     * 
     *  @return <code>true</code> if the value in the editor is valid. 
     *  Otherwise return <code>false</code>.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
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
    private function mouseUpDownMoveHandler(event:MouseEvent):void
    {
        if (event.cancelable)
            event.preventDefault();
    }

    /**
     *   @private
     *   Stop the data grid from seeing the mouse move events.
     */ 
    private function mouseMoveHandler(event:MouseEvent):void
    {
        // Redispatch the event to the dataGrid's parent and stop
        // the event from propagating past the editor.
        // The stopPropagation() keeps the grid from showing hover from mouse
        // moves within the editor. 
        // Dispatching the mouse move event to the data grid's parent 
        // keeps the data grid from seeing the event and allows the
        // RichEditableText control to see the event (it listens to the stage).
        var pt:Point = dataGrid.parent.globalToLocal(new Point(event.stageX, event.stageY));
        event.localX = pt.x;
        event.localY = pt.y;
        dataGrid.parent.dispatchEvent(event);
        event.stopPropagation();
    }
}
}