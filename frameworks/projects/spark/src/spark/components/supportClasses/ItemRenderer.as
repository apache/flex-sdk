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
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.components.DataGroup;
import mx.components.MXMLComponent;
import mx.core.mx_internal;
import mx.graphics.graphicsClasses.TextGraphicElement;
import mx.layout.HorizontalLayout;
import mx.layout.VerticalLayout;
import flash.events.Event;

/**
 *  The ItemRenderer class is the base class for List item renderers.
 */
public class ItemRenderer extends MXMLComponent
{    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
	public function ItemRenderer()
	{
		super();
		
		addHandlers();
	}
    
    //--------------------------------------------------------------------------
    //
    //  Style-driven properties
    //
    //--------------------------------------------------------------------------
    
    [Bindable("contentColorChanged")]
    public function get contentColor():uint
    {
        var alternatingColors:Array = getStyle("alternatingItemColors");
        
        if (alternatingColors)
        {
            var idx:int;
            
            if (parent is DataGroup)
                idx = DataGroup(parent).dataProvider.getItemIndex(data);
            else if (parent is Group)
                idx = Group(parent).getItemIndex(this);
            else
                idx = parent.getChildIndex(this);
             
            return alternatingColors[idx % alternatingColors.length];
        }
        
        return getStyle("contentColor");
    }
    
    public function set contentColor(value:uint):void
    {
        setStyle("contentColor", value);
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
    //  Properties
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
    //  labelField
    //----------------------------------
	
    /**
     * Optional item renderer label component, used primarily for 
     * auto-computation of baseline.
     */
    public var labelField:TextGraphicElement;

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
        if (!mx_internal::validateBaselinePosition() || !labelField)
            return super.baselinePosition;

        var labelPosition:Point = globalToLocal(labelField.parent.localToGlobal(
            new Point(labelField.x, labelField.y)));
            
        return labelPosition.y + labelField.baselinePosition;
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
            conditionalEventDispatch("contentColorChanged");
        }
        
        if (allStyles || styleName == "contentColor")
        {
            conditionalEventDispatch("contentColorChanged");
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