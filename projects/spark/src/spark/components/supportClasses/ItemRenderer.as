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

package spark.components.supportClasses
{
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.DataRenderer;
import spark.components.IItemRenderer;
import spark.components.ResizeMode;

use namespace mx_internal; 

/**
 *  The ItemRenderer class is the base class for Spark item renderers.
 * 
 *  @mxml
 *
 *  <p>The <code>&lt;s:ItemRenderer&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:ItemRenderer
 *    <strong>Properties</strong>
 *    selected="false"
 *    showsCaret="false"
 *  /&gt;
 *  </pre>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ItemRenderer extends DataRenderer implements IItemRenderer
{    
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
    public function ItemRenderer()
    {
        super();
        
        // Initially state is dirty
        rendererStateIsDirty = true;
        
        addHandlers();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Whether the renderer's state is invalid or not.
     */
    private var rendererStateIsDirty:Boolean = false;
    
    /**
     *  @private
     *  A flag determining if this renderer should play any 
     *  associated transitions when a state change occurs. 
     */
    mx_internal var playTransitions:Boolean = true; 
    
    //--------------------------------------------------------------------------
    //
    //  Public Properties 
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  autoDrawBackground
    //----------------------------------
    
    /**
     *  @private
     *  storage for the autoDrawBackground property 
     */ 
    private var _autoDrawBackground:Boolean = true;
    
    /**
     *  Specifies whether the item renderer draws the 
     *  background of the data item during user interaction.
     *  Interactions include moving the mouse over the item, 
     *  selecting the item, and moving the caret of the item .
     * 
     *  <p>If <code>true</code>, the background for 
     *  the item renderer is automatically drawn, and it 
     *  depends on the styles that are set (<code>contentBackgroundColor</code>, 
     *  <code>alternatingItemColor</code>, <code>rollOverColor</code>, 
     *  <code>selectionColor</code>) 
     *  and the state that the item renderer is in.</p>
     *
     *  <p>If <code>false</code>, the item render draws no backgrounds.
     *  Your custom item renderer is responsible for displaying the 
     *  background colors for all user interactions.</p>
     * 
     *  @default true
     */
    public function get autoDrawBackground():Boolean
    {
        return _autoDrawBackground;
    }
    
    /**
     *  @private
     */
    public function set autoDrawBackground(value:Boolean):void
    {
        if (_autoDrawBackground == value)
            return;
        
        _autoDrawBackground = value;
        
        if (_autoDrawBackground)
        {
            redrawRequested = true;
            super.$invalidateDisplayList();
        }
    }
    
    //----------------------------------
    //  hovered
    //----------------------------------
    /**
     *  @private
     *  storage for the selected property 
     */    
    private var _hovered:Boolean = false;
    
    /**
     *  Set to <code>true</code> when the mouse is hovered over the item renderer.
     *
     *  @default false
     */    
    protected function get hovered():Boolean
    {
        return _hovered;
    }
    
    /**
     *  @private
     */    
    protected function set hovered(value:Boolean):void
    {
        if (value != _hovered)
        {
            _hovered = value;
            setCurrentState(getCurrentRendererState(), playTransitions);
            if (autoDrawBackground)
            {
                redrawRequested = true;
                super.$invalidateDisplayList();
            }
        }
    }

    //----------------------------------
    //  itemIndex
    //----------------------------------
    
    /**
     *  @private
     *  storage for the itemIndex property 
     */    
    private var _itemIndex:int;
    
    [Bindable("itemIndexChanged")]
    
    /**
     *  @inheritDoc 
     *
     *  @default 0
     */    
    public function get itemIndex():int
    {
        return _itemIndex;
    }
    
    /**
     *  @private
     */    
    public function set itemIndex(value:int):void
    {
        if (value == _itemIndex)
            return;
        
        _itemIndex = value;
        
        if (autoDrawBackground)
        {
            redrawRequested = true;
            super.$invalidateDisplayList();
        }
        
        dispatchEvent(new Event("itemIndexChanged"));
    }
    
    //----------------------------------
    //  labelDisplay
    //----------------------------------
    
    /**
     *  Optional item renderer label component. 
     *  This component is used to determine the value of the 
     *  <code>baselinePosition</code> property in the host component of 
     *  the item renderer. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var labelDisplay:TextBase;
    
    //----------------------------------
    //  showsCaret
    //----------------------------------

    /**
     *  @private
     *  Storage for the showsCaret property 
     */
    private var _showsCaret:Boolean = false;

    /**
     *  @inheritDoc 
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
        if (value == _showsCaret)
            return;

        _showsCaret = value;
        setCurrentState(getCurrentRendererState(), playTransitions); 
        if (autoDrawBackground)
        {
            redrawRequested = true;
            super.$invalidateDisplayList();
        }
    }
    
    //----------------------------------
    //  selected
    //----------------------------------
    /**
     *  @private
     *  storage for the selected property 
     */    
    private var _selected:Boolean = false;
    
    /**
     *  @inheritDoc 
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
        if (value != _selected)
        {
            _selected = value;
            setCurrentState(getCurrentRendererState(), playTransitions);
            if (autoDrawBackground)
            {
                redrawRequested = true;
                super.$invalidateDisplayList();
            }
        }
    }
       
    //----------------------------------
    //  dragging
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the dragging property. 
     */
    private var _dragging:Boolean = false;

    /**
     *  @inheritDoc  
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
        if (value != _dragging)
        {
            _dragging = value;
            setCurrentState(getCurrentRendererState(), playTransitions);
        }
    }

    //----------------------------------
    //  label
    //----------------------------------
    
    /**
     *  @private 
     *  Storage var for label
     */ 
    private var _label:String = "";
    
    [Bindable("labelChanged")]
    
    /**
     *  @inheritDoc 
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
        if (value == _label)
            return;
        
        _label = value;
            
        // Push the label down into the labelDisplay,
        // if it exists
        if (labelDisplay)
            labelDisplay.text = _label;
        
        dispatchEvent(new Event("labelChanged"));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Properties - UIComponent 
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  baselinePosition
    //----------------------------------

    /**
     *  @private
     */
    override public function get baselinePosition():Number
    {
        if (!validateBaselinePosition() || !labelDisplay)
            return super.baselinePosition;

        var labelPosition:Point = globalToLocal(labelDisplay.parent.localToGlobal(
            new Point(labelDisplay.x, labelDisplay.y)));
            
        return labelPosition.y + labelDisplay.baselinePosition;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods - ItemRenderer State Support 
    //
    //--------------------------------------------------------------------------
    /**
     *  Returns the name of the state to be applied to the renderer. For example, a
     *  very basic List item renderer would return the String "normal", "hovered", 
     *  or "selected" to specify the renderer's state. 
     * 
     *  <p>A subclass of ItemRenderer must override this method to return a value 
     *  if the behavior desired differs from the default behavior.</p>
     * 
     *  @return A String specifying the name of the state to apply to the renderer. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function getCurrentRendererState():String
    {
        if (dragging && hasState("dragging"))
            return "dragging";

        if (selected && showsCaret && hasState("selectedAndShowsCaret"))
            return "selectedAndShowsCaret";
            
        if (hovered && showsCaret && hasState("hoveredAndShowsCaret"))
            return "hoveredAndShowsCaret";
             
        if (showsCaret && hasState("normalAndShowsCaret"))
            return "normalAndShowsCaret"; 
            
        if (selected && hasState("selected"))
            return "selected";
        
        if (hovered && hasState("hovered"))
            return "hovered";
        
        if (hasState("normal"))    
            return "normal";
        
        // If none of the above states are defined in the item renderer,
        // we return the empty string. This means the user-defined renderer
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
        
        if (rendererStateIsDirty)
        {
            setCurrentState(getCurrentRendererState(), playTransitions); 
            rendererStateIsDirty = false;
        }
    }
    
    /**
     *  @private
     */ 
    override public function styleChanged(styleName:String):void
    {
        var allStyles:Boolean = styleName == null || styleName == "styleName";
        
        super.styleChanged(styleName);
        
        if (autoDrawBackground && (allStyles || styleName == "alternatingItemColors" || 
            styleName == "contentBackgroundColor" || styleName == "rollOverColor" || 
            styleName == "selectionColor"))
        {
            redrawRequested = true;
            super.$invalidateDisplayList();
        }
    }
    
    /**
     *  @private
     */
    override mx_internal function drawBackground():void
    {
        // if autoDrawBackground is set to true, we always 
        // draw a background and don't need to worry about mouseEnabledWhereTransparent.
        // However, if it's false, then we should just let super.drawBackground()
        // do its job.
        if (!autoDrawBackground)
        {
            super.drawBackground();
            return;
        }
        
        // TODO (rfrishbe): Would be good to remove this duplicate code with the 
        // super.drawBackground() version
        var w:Number = (resizeMode == ResizeMode.SCALE) ? measuredWidth : unscaledWidth;
        var h:Number = (resizeMode == ResizeMode.SCALE) ? measuredHeight : unscaledHeight;
        
        if (isNaN(w) || isNaN(h))
            return;
        
        graphics.clear();
        
        var backgroundColor:uint;
        var drawBackground:Boolean = true;
        
        if (selected)
            backgroundColor = getStyle("selectionColor");
        else if (hovered)
            backgroundColor = getStyle("rollOverColor");
        else
        {
            var alternatingColors:Array = getStyle("alternatingItemColors");
            
            if (alternatingColors && alternatingColors.length > 0)
            {
                // translate these colors into uints
                styleManager.getColorNames(alternatingColors);
                
                backgroundColor = alternatingColors[itemIndex % alternatingColors.length];
            }            
            else
            {
                // don't draw background if it is the contentBackgroundColor. The
                // list skin handles the background drawing for us.
                drawBackground = false;
            }
        }
        
        graphics.beginFill(backgroundColor, drawBackground ? 1 : 0);
        
        if (showsCaret)
        {
            graphics.lineStyle(1, getStyle("selectionColor"));
            graphics.drawRect(0.5, 0.5, w-1, h-1);
        }
        else 
        {
            graphics.lineStyle();
            graphics.drawRect(0, 0, w, h);
        }
            
        graphics.endFill();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handling
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Attach the mouse events.
     */
    private function addHandlers():void
    {
        addEventListener(MouseEvent.ROLL_OVER, itemRenderer_rollOverHandler);
        addEventListener(MouseEvent.ROLL_OUT, itemRenderer_rollOutHandler);
    }
    
    /**
     *  @private
     */
    private function anyButtonDown(event:MouseEvent):Boolean
    {
        var type:String = event.type;
        return event.buttonDown || (type == "middleMouseDown") || (type == "rightMouseDown"); 
    }
    
    /**
     *  @private
     *  Mouse rollOver event handler.
     */
    protected function itemRenderer_rollOverHandler(event:MouseEvent):void
    {
        if (!anyButtonDown(event))
            hovered = true;
    }
    
    /**
     *  @private
     *  Mouse rollOut event handler.
     */
    protected function itemRenderer_rollOutHandler(event:MouseEvent):void
    {
        hovered = false;
    }

}
}