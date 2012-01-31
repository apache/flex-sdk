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
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.core.mx_internal;
import mx.graphics.baseClasses.TextGraphicElement;
import mx.styles.StyleManager;

/**
 *  The ItemRenderer class is the base class for Spark item renderers.
 *  It implements the IItemRenderer interface. 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ItemRenderer extends MXMLComponent implements IItemRenderer
{    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    public function ItemRenderer()
    {
        super();
        
        // Initially state is dirty
        rendererStateIsDirty = true;
        
        addHandlers();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Style-driven properties
    //
    //--------------------------------------------------------------------------
    
    [Bindable("contentBackgroundColorChanged")]
    public function get contentBackgroundColor():uint
    {
        var alternatingColors:Array = getStyle("alternatingItemColors");
        
        if (alternatingColors && alternatingColors.length > 0)
        {
            var idx:int;
            
            // translate these colors into uints
            StyleManager.getColorNames(alternatingColors);
            
            if (parent is DataGroup)
                idx = DataGroup(parent).dataProvider.getItemIndex(data);
            else if (parent is Group)
                idx = Group(parent).getElementIndex(this);
            else
                idx = parent.getChildIndex(this);
             
            return alternatingColors[idx % alternatingColors.length];
        }
        
        return getStyle("contentBackgroundColor");
    }
    
    public function set contentBackgroundColor(value:uint):void
    {
        setStyle("contentBackgroundColor", value);
    }
    
    [Bindable("rollOverColorChanged")]
    public function get rollOverColor():uint
    {
        return getStyle("rollOverColor");
    }
    
    public function set rollOverColor(value:uint):void
    {
        setStyle("rollOverColor", value);
    }
    
    [Bindable("selectionColorChanged")]
    public function get selectionColor():uint
    {
        return getStyle("selectionColor");
    }
    
    public function set selectionColor(value:uint):void
    {
        setStyle("selectionColor", value);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  hovered
    //----------------------------------

    /**
     *  @private
     *  Flag that is set when the mouse is hovered over the item renderer.
     */
    private var hovered:Boolean = false;
    
    /**
     *  @private
     *  Whether the renderer's state is invalid or not.
     */
    private var rendererStateIsDirty:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  allowDeselection
    //----------------------------------

    /**
     *  @private
     *  Storage for the allowDeselection property 
     */
    private var _allowDeselection:Boolean = true;

    /**
     *  @inheritDoc 
     */    
    public function get allowDeselection():Boolean
    {
        return _allowDeselection;
    }
    
    /**
     *  @private
     */    
    public function set allowDeselection(value:Boolean):void
    {
        if (value == _allowDeselection)
            return;
            
        _allowDeselection = value;
    }
    
    //----------------------------------
    //  showFocusIndicator
    //----------------------------------

    /**
     *  @private
     *  Storage for the showFocusIndicator property 
     */
    private var _showFocusIndicator:Boolean = false;

    /**
     *  @inheritDoc 
     */    
    public function get showFocusIndicator():Boolean
    {
        return _showFocusIndicator;
    }
    
    /**
     *  @private
     */    
    public function set showFocusIndicator(value:Boolean):void
    {
        if (value == _showFocusIndicator)
            return;

        _showFocusIndicator = value;
        //mx_internal::drawFocusAnyway = true;
        //drawFocus(value);
    }
    
    //----------------------------------
    //  selected
    //----------------------------------

    private var _selected:Boolean = false;
    
    public function get selected():Boolean
    {
        return _selected;
    }
    
    public function set selected(value:Boolean):void
    {
        if (value != _selected)
        {
            _selected = value;
            currentState = getCurrentSkinState();
        }
    }
       
    //----------------------------------
    //  labelElement
    //----------------------------------
    
    /**
     * Optional item renderer label component. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var labelElement:TextGraphicElement;
 
    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
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
        if (!mx_internal::validateBaselinePosition() || !labelElement)
            return super.baselinePosition;

        var labelPosition:Point = globalToLocal(labelElement.parent.localToGlobal(
            new Point(labelElement.x, labelElement.y)));
            
        return labelPosition.y + labelElement.baselinePosition;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handling
    //
    //--------------------------------------------------------------------------
    
    override public function styleChanged(styleName:String):void
    {
        var allStyles:Boolean = styleName == null || styleName == "styleName";
        
        super.styleChanged(styleName);
        
        if (allStyles || styleName == "alternatingItemColors")
        {
            conditionalEventDispatch("contentBackgroundColorChanged");
        }
        
        if (allStyles || styleName == "contentBackgroundColor")
        {
            conditionalEventDispatch("contentBackgroundColorChanged");
        }
        
        if (allStyles || styleName == "rollOverColor")
        {
            conditionalEventDispatch("rollOverColorChanged");
        }
        
        if (allStyles || styleName == "selectionColor")
        {
            conditionalEventDispatch("selectionColorChanged");
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
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
            currentState = getCurrentSkinState();
            rendererStateIsDirty = false;
        }
    }
    
    /**
     *  @private
     *  Attach the mouse events.
     */
    protected function addHandlers():void
    {
        addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
        addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
        addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
    }
    
    /**
     *  @private
     *  Return the skin state. This can be overridden by subclasses to add more states.
     *  NOTE: Undocumented for now since MXMLComponent class has not been fleshed out.
     */
    protected function getCurrentSkinState():String
    {
        if (selected)
            return "selected";
        
        if (hovered)
            return "hovered";
            
        return "normal";
    }
    
    /**
     *  @private
     */
    private function conditionalEventDispatch(eventName:String):void
    {
        if (hasEventListener(eventName))
           dispatchEvent(new Event(eventName));
    }
    
    /**
     *  @private
     *  Mouse rollOver event handler.
     */
    private function rollOverHandler(event:MouseEvent):void
    {
        hovered = true;
        currentState = getCurrentSkinState();
    }
    
    /**
     *  @private
     *  Mouse rollOut event handler.
     */
    private function rollOutHandler(event:MouseEvent):void
    {
        hovered = false;
        currentState = getCurrentSkinState();
    }
    
    /**
     *  @private
     *  Mouse down event handler.
     */
    private function mouseDownHandler(event:MouseEvent):void
    {
        dispatchEvent(new MouseEvent("click"));
    }
}
}