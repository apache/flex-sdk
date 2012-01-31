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

package spark.components
{
import flash.events.Event;
import spark.layout.HorizontalLayout;
import spark.layout.supportClasses.LayoutBase;

[IconFile("HGroup.png")]

/**
 * A Group with a HorizontalLayout.  
 * 
 * All of the HorizontalLayout properties exposed by this class are simply
 * delegated to the layout property.
 * 
 * The layout property should not be set or configured directly.
 * 
 * @see spark.layout.HorizontalLayout
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
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
     *  @see spark.layout.HorizontalLayout
     *  @see spark.components.VGroup
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */  
    public function HGroup():void
    {
        super();
        super.layout = new HorizontalLayout();
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
     * @copy spark.layout.HorizontalLayout#gap
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     * @copy spark.layout.HorizontalLayout#columnCount
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get columnCount():int
    {
        return horizontalLayout.columnCount;
    }
    
    //----------------------------------
    //  requestedColumnCount
    //----------------------------------

    /**
     * @copy spark.layout.HorizontalLayout#requestedColumnCount
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     * @copy spark.layout.HorizontalLayout#columnWidth
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     * @copy spark.layout.HorizontalLayout#variableColumnWidth
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     * @copy spark.layout.HorizontalLayout#verticalAlign
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     * @copy spark.layout.HorizontalLayout#firstIndexInView
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     * @copy spark.layout.HorizontalLayout#lastIndexInView
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get lastIndexInView():int
    {
        return horizontalLayout.lastIndexInView;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  layout
    //----------------------------------    
        
    /**
     *  @private
     */
    override public function set layout(value:LayoutBase):void
    {
        throw(new Error(resourceManager.getString("components", "layoutReadOnly")));
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