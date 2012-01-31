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
import flash.events.Event;
import mx.components.Group;
import mx.layout.HorizontalLayout;

[IconFile("HGroup.png")]

/**
 * A Group with a HorizontalLayout.  
 * 
 * All of the HorizontalLayout properties exposed by this class are simply
 * delegated to the layout property.
 * 
 * The layout property should not be set or configured directly.
 * 
 * @see mx.layout.HorizontalLayout
 */
public class HGroup extends Group
{
	include "../core/Version.as";

    /**
     *  Initializes the layout property to an instance of HorizontalLayout.
     * 
     *  Resetting the layout property or setting its properties directly
     *  is not supported.
     * 
     *  @see mx.layout.HorizontalLayout
     *  @see mx.components.VGroup
     */  
    public function HGroup():void
    {
        super();
        layout = new HorizontalLayout();
    }
    
    private function get horizontalLayout():HorizontalLayout
    {
        return HorizontalLayout(layout);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  gap
    //----------------------------------

    /**
     * @copy mx.layout.HorizontalLayout#gap
     */
    public function get gap():int
    {
        return horizontalLayout.gap;
    }

    /**
     *  @private
     */
    public function set gap(value:int):void
    {
        horizontalLayout.gap = value;
    }

    //----------------------------------
    //  columnCount
    //----------------------------------

    [Bindable("propertyChange")]    
        
    /**
     * @copy mx.layout.HorizontalLayout#columnCount
     */
    public function get columnCount():int
    {
        return horizontalLayout.columnCount;
    }
    
    //----------------------------------
    //  requestedColumnCount
    //----------------------------------

    /**
     * @copy mx.layout.HorizontalLayout#requestedColumnCount
     */
    public function get requestedColumnCount():int
    {
        return horizontalLayout.requestedColumnCount;
    }

    /**
     *  @private
     */
    public function set requestedColumnCount(value:int):void
    {
        horizontalLayout.requestedColumnCount = value;
    }    
    
    //----------------------------------
    //  columnHeight
    //----------------------------------
    
    [Inspectable(category="General")]

    /**
     * @copy mx.layout.HorizontalLayout#columnWidth
     */
    public function get columnWidth():Number
    {
        return horizontalLayout.columnWidth;
    }

    /**
     *  @private
     */
    public function set columnWidth(value:Number):void
    {
        horizontalLayout.columnWidth = value;
    }

    //----------------------------------
    //  variablecolumnHeight
    //----------------------------------

    [Inspectable(category="General")]

    /**
     * @copy mx.layout.HorizontalLayout#variableColumnWidth
     */
    public function get variableColumnWidth():Boolean
    {
        return horizontalLayout.variableColumnWidth;
    }

    /**
     *  @private
     */
    public function set variableColumnWidth(value:Boolean):void
    {
        horizontalLayout.variableColumnWidth = value;
    }
    
    //----------------------------------
    //  verticalAlign
    //----------------------------------

    /**
     * @copy mx.layout.HorizontalLayout#verticalAlign
     */
    public function get verticalAlign():String
    {
        return horizontalLayout.verticalAlign;
    }

    /**
     *  @private
     */
    public function set verticalAlign(value:String):void
    {
        horizontalLayout.verticalAlign = value;
    }
    
    //----------------------------------
    //  firstIndexInView
    //----------------------------------
 
    [Bindable("indexInViewChanged")]    

    /**
     * @copy mx.layout.HorizontalLayout#firstIndexInView
     */
    public function get firstIndexInView():int
    {
        return horizontalLayout.firstIndexInView;
    }
    
    //----------------------------------
    //  lastIndexInView
    //----------------------------------
    
    [Bindable("indexInViewChanged")]    

    /**
     * @copy mx.layout.HorizontalLayout#lastIndexInView
     */
    public function get lastIndexInView():int
    {
        return horizontalLayout.lastIndexInView;
    } 
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
     */
    override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
    {
        switch(type)
        {
            case "indexInViewChanged":
            case "propertyChange":
                if (!hasEventListener(type))
                    horizontalLayout.addEventListener(type, redispatchHandler);
                break;
        }
        super.addEventListener(type, listener, useCapture, priority, useWeakReference)
    }    
    
    /**
     * @private
     */
    override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
    {
        super.removeEventListener(type, listener, useCapture);
        switch(type)
        {
            case "indexInViewChanged":
            case "propertyChange":
                if (!hasEventListener(type))
                    horizontalLayout.removeEventListener(type, redispatchHandler);
                break;
        }
    }
    
    private function redispatchHandler(event:Event):void
    {
        dispatchEvent(event);
    }      
}

}