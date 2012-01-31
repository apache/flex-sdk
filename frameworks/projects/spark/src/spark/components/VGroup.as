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
import spark.layout.VerticalLayout;
import spark.layout.supportClasses.LayoutBase;

[IconFile("VGroup.png")]

/**
 *  A Group with a VerticalLayout.  
 * 
 *  All of the VerticalLayout properties exposed by this class are simply
 *  delegated to the layout property.
 * 
 *  The layout property should not be set or configured directly.
 * 
 *  @see spark.layout.VerticalLayout
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class VGroup extends Group
{
    include "../core/Version.as";
	
    /**
     *  Initializes the layout property to an instance of VerticalLayout.
     *  
     *  Resetting the layout property or setting its properties directly
     *  is not supported.
     * 
     *  @see spark.layout.VerticalLayout
     *  @see spark.components.HGroup
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */  
    public function VGroup():void
    {
        super();
        super.layout = new VerticalLayout();
    }
    
    private function get verticalLayout():VerticalLayout
    {
        return VerticalLayout(layout);
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
     * @copy spark.layout.VerticalLayout#gap
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get gap():int
    {
        return verticalLayout.gap;
    }

    /**
     *  @private
     */
    public function set gap(value:int):void
    {
        verticalLayout.gap = value;
    }
    
    //----------------------------------
    //  horizontalAlign
    //----------------------------------

    /**
     * @copy spark.layout.VerticalLayout#horizontalAlign
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get horizontalAlign():String
    {
        return verticalLayout.horizontalAlign;
    }

    /**
     *  @private
     */
    public function set horizontalAlign(value:String):void
    {
        verticalLayout.horizontalAlign = value;
    }

    //----------------------------------
    //  rowCount
    //----------------------------------

    [Bindable("propertyChange")]

    /**
     * @copy spark.layout.VerticalLayout#rowCount
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get rowCount():int
    {
        return verticalLayout.rowCount;
    }
    
    //----------------------------------
    //  requestedRowCount
    //----------------------------------

    /**
     * @copy spark.layout.VerticalLayout#requestedRowCount
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get requestedRowCount():int
    {
        return verticalLayout.requestedRowCount;
    }

    /**
     *  @private
     */
    public function set requestedRowCount(value:int):void
    {
        verticalLayout.requestedRowCount = value;
    }    
    
    //----------------------------------
    //  rowHeight
    //----------------------------------
    
    [Inspectable(category="General")]

    /**
     * @copy spark.layout.VerticalLayout#rowHeight
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get rowHeight():Number
    {
        return verticalLayout.rowHeight;
    }

    /**
     *  @private
     */
    public function set rowHeight(value:Number):void
    {
        verticalLayout.rowHeight = value;
    }

    //----------------------------------
    //  variableRowHeight
    //----------------------------------

    [Inspectable(category="General")]

    /**
     * @copy spark.layout.VerticalLayout#variableRowHeight
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get variableRowHeight():Boolean
    {
        return verticalLayout.variableRowHeight;
    }

    /**
     *  @private
     */
    public function set variableRowHeight(value:Boolean):void
    {
        verticalLayout.variableRowHeight = value;
    }
    
    //----------------------------------
    //  firstIndexInView
    //----------------------------------

    [Bindable("indexInViewChanged")]    
 
    /**
     * @copy spark.layout.VerticalLayout#firstIndexInView
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get firstIndexInView():int
    {
        return verticalLayout.firstIndexInView;
    }
    
    //----------------------------------
    //  lastIndexInView
    //----------------------------------

    [Bindable("indexInViewChanged")]    

    /**
     * @copy spark.layout.VerticalLayout#lastIndexInview
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get lastIndexInView():int
    {
        return verticalLayout.lastIndexInView;
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
                    verticalLayout.addEventListener(type, redispatchHandler);
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
                    verticalLayout.removeEventListener(type, redispatchHandler);
                break;
        }
    }
    
    private function redispatchHandler(event:Event):void
    {
        dispatchEvent(event);
    }
    
}
}