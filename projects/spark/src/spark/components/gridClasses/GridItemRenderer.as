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
import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.IToolTip;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.ToolTipEvent;
import mx.managers.ISystemManager;

import spark.components.Grid;
import spark.components.Group;
import spark.components.supportClasses.TextBase;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the bindable <code>data</code> property changes.
 *
 *  @eventType mx.events.FlexEvent.DATA_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="dataChange", type="mx.events.FlexEvent")]

/**
 *  A convenient base class for custom grid item renderers.   Grid item renderers
 *  are only required to display some column-specific aspect of their data.  They're
 *  not responsible for displaying the selection or hover indicators, the alternating
 *  background color (if any), or row/column separators.
 */
public class GridItemRenderer extends Group implements IGridItemRenderer
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
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function GridItemRenderer()
    {
        super();
        
        setCurrentStateNeeded = true;
        
        addEventListener(ToolTipEvent.TOOL_TIP_SHOW, toolTipShowHandler);           
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  True if the renderer has been created and commitProperties hasn't
     *  run yet. See commitProperties.
     */
    private var setCurrentStateNeeded:Boolean = false;
    
    /**
     *  @private
     *  A flag determining if this renderer should play any 
     *  associated transitions when a state change occurs. 
     */
    mx_internal var playTransitions:Boolean = false; 
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function dispatchChangeEvent(type:String):void
    {
        if (hasEventListener(type))
            dispatchEvent(new Event(type));
    }
    
    //----------------------------------
    //  baselinePosition override
    //----------------------------------
    
    /**
     *  @private
     */
    override public function get baselinePosition():Number
    {
        if (!validateBaselinePosition() || !labelDisplay)
            return super.baselinePosition;
        
        const labelPosition:Point = globalToLocal(labelDisplay.parent.localToGlobal(
            new Point(labelDisplay.x, labelDisplay.y)));
        
        return labelPosition.y + labelDisplay.baselinePosition;
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
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
     *  The value of the dataProvider "item" for this row, i.e. <code>dataProvider.getItemAt(rowIndex)</code>.
     *  Item renderers often bind visual element attributes to data properties.  Note 
     *  that, despite its name, this property does not depend on the column's "dataField". 
     *  
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
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
        if (_data == value)
            return;
        
        _data = value;
        
        const eventType:String = "dataChange"; 
        if (hasEventListener(eventType))
            dispatchEvent(new FlexEvent(eventType));  
    }
    
    //----------------------------------
    //  down
    //----------------------------------
    
    /**
     *  @private
     *  storage for the down property 
     */
    private var _down:Boolean = false;
    
    /**
     *  @inheritDoc
     *
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */    
    public function get down():Boolean
    {
        return _down;
    }
    
    /**
     *  @private
     */    
    public function set down(value:Boolean):void
    {
        if (value == _down)
            return;
        
        _down = value;
        setCurrentState(getCurrentRendererState(), playTransitions);
    }
    
    //----------------------------------
    //  grid
    //----------------------------------
    
    /**
     *  Returns the Grid associated with this item renderer (same value as <code>column.grid</code>).
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */
    public function get grid():Grid
    {
        return (column) ? column.grid : null;
    }    

    //----------------------------------
    //  hovered
    //----------------------------------
    
    private var _hovered:Boolean = false;
    
    /**
     *  Set to <code>true</code> when the mouse is hovered over the item renderer.
     *
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */    
    public function get hovered():Boolean
    {
        return _hovered;
    }
    
    /**
     *  @private
     */    
    public function set hovered(value:Boolean):void
    {
        if (value == _hovered)
            return;
        
        _hovered = value;
        setCurrentState(getCurrentRendererState(), playTransitions);
    }
    
    //----------------------------------
    //  rowIndex
    //----------------------------------

    private var _rowIndex:int = -1;
    
    [Bindable("rowIndexChanged")]
    
    /**
     *  The index of the dataProvider item for this item renderer's row.
     * 
     *  <p>The Grid's <code>updateDisplayList()</code> method sets this property 
     *  before calling <code>prepare()</code></p>.   
     * 
     *  @default -1
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
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
     *  True if the item renderer's cell is contained within the caret indicator.  
     *  As with the selected property,  grid item renderers do not have exclusive 
     *  responsibility for displaying the caret indicator.
     * 
     *  <p>The Grid's <code>updateDisplayList()</code> method sets this property 
     *  before calling <code>preprare()</code></p>.   
     * 
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
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
        
        _showsCaret = value;
        setCurrentState(getCurrentRendererState(), playTransitions);
        dispatchChangeEvent("labelDisplayChanged");           
    }
    
    //----------------------------------
    //  selected
    //----------------------------------

    private var _selected:Boolean = false;
    
    [Bindable("selectedChanged")]    
    
    /**
     *  True if the item renderer's cell is part of the current selection.  Unlike a list item renderer, 
     *  grid item renderers do not have exclusive responsibility for displaying the selection indicator.   
     *  The Grid itself renders the selection indicator for the selected row or cell.  The item renderer 
     *  can also change its visual properties to emphasize that it's part of the selection.
     * 
     *  <p>The Grid's <code>updateDisplayList()</code> method sets this property 
     *  before calling <code>preprare()</code></p>.   
     * 
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
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
        
        _selected = value;
        setCurrentState(getCurrentRendererState(), playTransitions);
        dispatchChangeEvent("selectedChanged");        
    }
    
    //----------------------------------
    //  dragging
    //----------------------------------
    
    private var _dragging:Boolean = false;
    
    [Bindable("draggingChanged")]        
    
    /**
     *  TBD
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
        
        _dragging = value;
        setCurrentState(getCurrentRendererState(), playTransitions);
        dispatchChangeEvent("draggingChanged");        
    }
    
    //----------------------------------
    //  label
    //----------------------------------
    
    private var _label:String = "";
    
    [Bindable("labelChanged")]
    
    /**
     *  The string to display in the item renderer's cell.  This method copies
     *  the (non null) value to the <code>text</code> property of <code>labelDisplay</code>.
     *  
     *  <p>The Grid sets this property to the value of the column's <code>itemToLabel()</code> method, before
     *  calling <code>preprare()</code>.</p>   
     *
     *  @default ""
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
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
    
    private var _labelDisplay:TextBase = null;
    
    [Bindable("labelDisplayChanged")]
    
    /**
     *  An optional component for displaying the label property.   If specified, this component's
     *  <code>text</code> will be kept in sync with this renderer's <code>label</code>.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */    
    public function get labelDisplay():TextBase
    {
        return _labelDisplay
    }
    
    /**
     *  @private
     */    
    public function set labelDisplay(value:TextBase):void
    {
        if (_labelDisplay == value)
            return;
        
        _labelDisplay = value;
        dispatchChangeEvent("labelDisplayChanged");        
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods - ItemRenderer State Support 
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Returns the name of the state to be applied to the renderer. For example, a
     *  very basic Grid item renderer would return the String "normal", "hovered", 
     *  or "selected" to specify the renderer's state. 
     *  If dealing with touch interactions (or mouse interactions where selection
     *  is ignored), "down" and "downAndSelected" are also important states.
     * 
     *  <p>A subclass of GridItemRenderer must override this method to return a value 
     *  if the behavior desired differs from the default behavior.</p>
     * 
     *  <p>In Flex 4.0, the 3 main states were "normal", "hovered", and "selected".
     *  In Flex 4.5, "down" and "downAndSelected" have been added.</p>
     *  
     *  <p>The full set of states supported (in order of precedence) are: 
     *    <ul>
     *      <li>dragging</li>
     *      <li>downAndSelected</li>
     *      <li>selectedAndShowsCaret</li>
     *      <li>hoveredAndShowsCaret</li>
     *      <li>normalAndShowsCaret</li>
     *      <li>down</li>
     *      <li>selected</li>
     *      <li>hovered</li>
     *      <li>normal</li>
     *    </ul>
     *  </p>
     * 
     *  @return A String specifying the name of the state to apply to the renderer. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    protected function getCurrentRendererState():String
    {
        // this code is pretty confusing without multi-dimensional states, but it's
        // defined in order of precedence.
        
        if (dragging && hasState("dragging"))
            return "dragging";
        
        if (selected && down && hasState("downAndSelected"))
            return "downAndSelected";
        
        if (selected && showsCaret && hasState("selectedAndShowsCaret"))
            return "selectedAndShowsCaret";
        
        if (hovered && showsCaret && hasState("hoveredAndShowsCaret"))
            return "hoveredAndShowsCaret";
        
        if (showsCaret && hasState("normalAndShowsCaret"))
            return "normalAndShowsCaret"; 
        
        if (down && hasState("down"))
            return "down";
        
        if (selected && hasState("selected"))
            return "selected";
        
        if (hovered && hasState("hovered"))
            return "hovered";
        
        if (hasState("normal"))    
            return "normal";
        
        // If none of the above states are defined in the item renderer,
        // we return null. This means the user-defined renderer
        // will display but essentially be non-interactive visually. 
        return null;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */ 
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (setCurrentStateNeeded)
        {
            setCurrentState(getCurrentRendererState(), playTransitions); 
            setCurrentStateNeeded = false;
        }
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(width, height);
        
        // If the effective value of showDataTips has changed for this column, then
        // set the renderer's tooltTip property to a placeholder.  The real tooltip
        // text is computed in the TOOL_TIP_SHOW handler below.
        
        // TBD(hmuller) - this code should be common with DefaultGridItemRenderer        
        
        const showDataTips:Boolean = rowIndex != -1 && column && column.getShowDataTips();
        const dataTip:String = toolTip;
        if (showDataTips && !dataTip)
            toolTip = "<dataTip>";
        else if (!showDataTips && dataTip)
            toolTip = null;
    } 
        
    /**
     *  @inheritDoc
     */
    public function prepare(hasBeenRecycled:Boolean):void
    {
    }

    /**
     *  @inheritDoc
     */
    public function discard(willBeRecycled:Boolean):void
    {
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //-------------------------------------------------------------------------- 
    
    // TBD(hmuller) - this code should be common with DefaultGridItemRenderer
    private function toolTipShowHandler(event:ToolTipEvent):void
    {
        var toolTip:IToolTip = event.toolTip;
        
        toolTip.text = column.itemToDataTip(data);  // Lazily compute the tooltip text
        
        // Move the origin of the tooltip to the origin of this item renderer
        
        var sm:ISystemManager = systemManager.topLevelSystemManager;
        var sbRoot:DisplayObject = sm.getSandboxRoot();
        var screen:Rectangle = sm.getVisibleApplicationRect(null, true);
        var pt:Point = new Point(0, 0);
        pt = localToGlobal(pt);
        pt = sbRoot.globalToLocal(pt);          
        
        toolTip.move(pt.x, Math.round(pt.y + (height - toolTip.height) / 2));
        
        var screenRight:Number = screen.x + screen.width;
        pt.x = toolTip.x;
        pt.y = toolTip.y;
        pt = sbRoot.localToGlobal(pt);
        if (pt.x + toolTip.width > screenRight)
            toolTip.move(toolTip.x - (pt.x + toolTip.width - screenRight), toolTip.y);
    }
}
}