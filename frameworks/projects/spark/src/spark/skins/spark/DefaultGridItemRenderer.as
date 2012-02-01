package spark.skins.spark
{
    
import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.text.TextFieldAutoSize;

import mx.core.LayoutElementUIComponentUtils;
import mx.core.UIComponent;
import mx.core.UITextField;

import spark.components.Grid;
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
    
    /**
     *  Padding added to the labelDisplay's textWidth and textHeight properties to compute 
     *  the renderer's measured width and height.
     */
    private static const TEXT_WIDTH_PADDING:Number = 15;
    private static const TEXT_HEIGHT_PADDING:Number = 10;
    
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

            labelDisplay.multiline = true;
            labelDisplay.wordWrap = true;
            labelDisplay.autoSize = TextFieldAutoSize.LEFT;

            addChild(DisplayObject(labelDisplay));
            if (_label != "")
                labelDisplay.text = _label;
        }
    }
    
    /**
     *  @private
     *  The renderer's measuredWidth,Height are just padded versions of the labelDisplay's
     *  textWidth,Height properties.   The code below is based on the UITextField
     *  meausuredWidth,Height get methods, although we do not call validateNow() here (as
     *  they do).
     *  
     */
    private function updateMeasuredSize():void
    {
        if (!labelDisplay.stage || labelDisplay.embedFonts)
        {
            measuredWidth = labelDisplay.textWidth + TEXT_WIDTH_PADDING;
            measuredHeight = labelDisplay.textHeight + TEXT_HEIGHT_PADDING;
        }
        else 
        {
            const m:Matrix = labelDisplay.transform.concatenatedMatrix;      
            measuredWidth = Math.abs((labelDisplay.textWidth * m.a / m.d)) + TEXT_WIDTH_PADDING;
            measuredHeight = Math.abs((labelDisplay.textHeight * m.a / m.d)) + TEXT_HEIGHT_PADDING;
        }        
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();  // initializes measured{Min}Width,Height to 0
        updateMeasuredSize();
    }
    
    /**
     *  @private
     *  True if the labelDisplay's scrollRect has been set.  See below.
     */
    private var clippingEnabled:Boolean = false;
    
    /**
     *  @private
     *  Watch Out: this code relies on the fact that UITextField/setActualSize() can cause
     *  labelDisplay.textHeight to change, if the text wraps.  The text field's measuredHeight
     *  is just a padded version of textHeight.  This is the only place where labelDisplay.setActualSize() 
     *  is called, so we update the measuredHeight of this render here.  Very unconventional.
     *  Doing so is essential because after this code runs, i.e. after GridLayout/layoutGridElement()
     *  invokes validateNow() on this renderer, it uses the renderer's preferredBoundsHeight()
     *  (that's the measuredHeight in our case) to update the overall row height.
     */
    override protected function updateDisplayList(width:Number, height:Number):void
    {
        super.updateDisplayList(width, height);

        labelDisplay.setActualSize(width - 10, height - 5);  // setActualSize() side-effects labelDisplay.textHeight
        updateMeasuredSize();  // See @private comment above 
        
        // If the Grid's row heights are fixed and the labelDisplay will not fit, then clip.
        
        const grid:Grid = column.grid; 
        if (grid && !grid.variableRowHeight && (measuredHeight > grid.rowHeight))
        {
            clippingEnabled = true;
            labelDisplay.scrollRect = new Rectangle(0, 0, width - 10, height - 5);
        }
        else if (clippingEnabled)
        {
            clippingEnabled = false;
            labelDisplay.scrollRect = null;
        }
        
        labelDisplay.move(5, 5);
    }
 
        
}   
}