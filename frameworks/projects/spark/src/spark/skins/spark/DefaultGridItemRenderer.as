package spark.skins.spark
{
    
import flash.display.DisplayObject;
import flash.events.Event;
import flash.text.TextFieldAutoSize;

import mx.core.LayoutElementUIComponentUtils;
import mx.core.UIComponent;
import mx.core.UITextField;

import spark.components.IGridItemRenderer;
import spark.components.supportClasses.GridColumn;

/**
 *  TBD
 */
public class DefaultGridItemRenderer extends UIComponent implements IGridItemRenderer
{
    public function DefaultGridItemRenderer()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties 
    //
    //--------------------------------------------------------------------------
    
    private function dispatchChangeEvent(type:String):void
    {
        if (hasEventListener(type))
            dispatchEvent(new Event(type));
    }
    
    //----------------------------------
    //  column
    //----------------------------------
    
    private var _column:GridColumn = null;
    
    [Bindable("columnChanged")]
    
    /**
     *  @inheritDoc
     * 
     *  <p>The Grid's <code>updateDisplayList()</code> method sets this property 
     *  before calling <code>preprare()</code></p>. 
     *  
     *  @default null
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
        if (_column == value)
            return;
        
        _column = value;
        dispatchChangeEvent("columnChanged");
    }
    
    //----------------------------------
    //  data
    //----------------------------------
    
    private var _data:Object = null;
    
    [Bindable("dataChange")]  // compatible with FlexEvent.DATA_CHANGE
    
    /**
     *  The value of the dataProvider "item" for this row, i.e. <code>dataProvider.getItemAt(itemIndex)</code>.
     *  Item renderers often bind visual element attributes to data properties.  Note 
     *  that, despite its name, this property does not depend on the column's "dataField". 
     *  
     *  @default null
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
        if (_data == value)
            return;
        
        _data = value;
        dispatchChangeEvent("dataChange");
    }
    
    //----------------------------------
    //  rowIndex
    //----------------------------------
    
    private var _rowIndex:int = -1;
    
    [Bindable("rowIndexChanged")]
    
    /**
     *  @inheritDoc
     * 
     *  <p>The Grid's <code>updateDisplayList()</code> method sets this property 
     *  before calling <code>prepare()</code></p>.   
     * 
     *  @default -1
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
        if (_rowIndex == value)
            return;
        
        _rowIndex = value;
        dispatchChangeEvent("rowIndexChanged");        
    }
    
    //----------------------------------
    //  showsCaret
    //----------------------------------
    
    private var _showsCaret:Boolean = false;
    
    [Bindable("showsCaretChanged")]    
    
    /**
     *  @inheritDoc
     * 
     *  <p>The Grid's <code>updateDisplayList()</code> method sets this property 
     *  before calling <code>preprare()</code></p>.   
     * 
     *  @default false
     */    
    public function get showsCaret():Boolean
    {
        return _showsCaret;
    }
    
    /**
     *  @private
     */    
    public function set showsCaret(value:Boolean):void
    {
        if (_showsCaret == value)
            return;
        
        // TBD(hmuller): state change
        _showsCaret = value;
        dispatchChangeEvent("labelDisplayChanged");           
    }
    
    //----------------------------------
    //  selected
    //----------------------------------
    
    private var _selected:Boolean = false;
    
    [Bindable("selectedChanged")]    
    
    /**
     *  @inheritDoc
     * 
     *  <p>The Grid's <code>updateDisplayList()</code> method sets this property 
     *  before calling <code>preprare()</code></p>.   
     * 
     *  @default false
     */    
    public function get selected():Boolean
    {
        return _selected;
    }
    
    /**
     *  @private
     */    
    public function set selected(value:Boolean):void
    {
        if (_selected == value)
            return;
        
        // TBD(hmuller): state change       
        _selected = value;
        dispatchChangeEvent("selectedChanged");        
    }
    
    //----------------------------------
    //  dragging
    //----------------------------------
    
    private var _dragging:Boolean = false;
    
    [Bindable("draggingChanged")]        
    
    /**
     *  @inheritDoc
     * 
     *  @default false
     */
    public function get dragging():Boolean
    {
        return _dragging;
    }
    
    /**
     *  @private  
     */
    public function set dragging(value:Boolean):void
    {
        if (_dragging == value)
            return;
        
        // TBD(hmuller): state change             
        _dragging = value;
        dispatchChangeEvent("draggingChanged");        
    }
    
    //----------------------------------
    //  label
    //----------------------------------
    
    private var _label:String = "";
    
    [Bindable("labelChanged")]
    
    /**
     *  @inheritDoc
     *  
     *  <p>The Grid sets this property to the value of the column's <code>itemToLabel()</code> method, before
     *  calling <code>preprare()</code>.</p>   
     *
     *  @default ""  
     */
    public function get label():String
    {
        return _label;
    }
    
    /**
     *  @private
     */ 
    public function set label(value:String):void
    {
        if (_label == value)
            return;
        
        _label = value;
        
        if (labelDisplay)
            labelDisplay.text = _label;
        
        dispatchChangeEvent("labelChanged");
    }
    
    //----------------------------------
    //  labelDisplay
    //----------------------------------
    
    private var _labelDisplay:UITextField = null;
    
    [Bindable("labelDisplayChanged")]
    
    /**
     *  An optional component for displaying the label property.   If specified, this component's
     *  <code>text</code> will be kept in sync with this renderer's <code>label</code>.
     * 
     *  @default null
     */    
    public function get labelDisplay():UITextField
    {
        return _labelDisplay
    }
    
    /**
     *  @private
     */    
    public function set labelDisplay(value:UITextField):void
    {
        if (_labelDisplay == value)
            return;
        
        _labelDisplay = value;
        invalidateSize();
        dispatchChangeEvent("labelDisplayChanged");        
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------    
    
    /**
     *  @inheritDoc
     */
    public function prepare(willBeRecycled:Boolean):void
    {
    }
    
    /**
     *  @inheritDoc
     */
    public function discard(hasBeenRecycled:Boolean):void
    {
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function createChildren():void
    {
        super.createChildren();
        
        if (!labelDisplay)
        {
            labelDisplay = new UITextField();
            /*
            labelDisplay.autoSize = TextFieldAutoSize.LEFT;
            labelDisplay.wordWrap = true;
            */
            addChild(DisplayObject(labelDisplay));
            if (_label != "")
                labelDisplay.text = _label;
        }
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        
        // labelDisplay layout: padding of 3 on left and right and padding of 5 on top and bottom.
          
        measuredWidth = LayoutElementUIComponentUtils.getPreferredBoundsWidth(labelDisplay, null) + 6;
        measuredHeight = LayoutElementUIComponentUtils.getPreferredBoundsHeight(labelDisplay, null) + 10;
        
        measuredMinWidth = measuredWidth;
        measuredMinHeight = measuredHeight;
    }
    
    private var textIsTruncated:Boolean = false;
    
    /**
     *  @private
     */
    override protected function updateDisplayList(width:Number, height:Number):void
    {
        super.updateDisplayList(width, height);

        // labelDisplay layout: padding of 3 on left and right and padding of 5 on top and bottom.
        
        labelDisplay.setActualSize(width-6, height-10);
        
        if (textIsTruncated)
            labelDisplay.text = _label;
        textIsTruncated = labelDisplay.truncateToFit();
        
        labelDisplay.move(3, 5);
    }
    
}   
}