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
import spark.layouts.TileLayout;
import spark.layouts.supportClasses.LayoutBase;

[IconFile("TileGroup.png")]

[Exclude(name="layout", kind="property")]

/**
 *  The TileGroup container is an instance of the Group container 
 *  that uses the TileLayout class.  
 *  Do not modify the <code>layout</code> property. 
 *  Instead, use the properties of the TileGroup class to modify the 
 *  characteristics of the TileLayout class.
 *
 *  <p>The TileGroup container has the following default characteristics:</p>
 *  <table class="innertable">
 *     <tr><th>Characteristic</th><th>Description</th></tr>
 *     <tr><td>Default size</td><td>Large enough to display its children</td></tr>
 *     <tr><td>Minimum size</td><td>0 pixels</td></tr>
 *     <tr><td>Maximum size</td><td>10000 pixels wide and 10000 pixels high</td></tr>
 *  </table>
 * 
 *  @mxml
 *
 *  <p>The <code>&lt;s:TileGroup&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:TileGroup
 *    <strong>Properties</strong>
 *    columnAlign="left"
 *    columnCount="-1"
 *    columnWidth="0"
 *    horizontalAlign="justify"
 *    horizontalGap="6"
 *    orientation="rows"
 *    paddingBottom="0"
 *    paddingLeft="0"
 *    paddingRight="0"
 *    paddingTop="0"
 *    requestedColumnCount"-1"
 *    requestedRowCount="-1"
 *    rowAlign="top"
 *    rowCount="-1"
 *    rowHeight="0"
 *    verticalAlign="justify"
 *    verticalGap="6"
 *  /&gt;
 *  </pre>
 * 
 *  @see spark.layouts.TileLayout
 *  @includeExample examples/TileGroupExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class TileGroup extends Group
{
    include "../core/Version.as";
    
    /**
     *  Constructor. 
     *  Initializes the <code>layout</code> property to an instance of 
     *  the TileLayout class.
     * 
     *  @see spark.layouts.TileLayout
     *  @see spark.components.HGroup
     *  @see spark.components.VGroup
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */  
    public function TileGroup():void
    {
        super();
        super.layout = new TileLayout();
    }
    
    private function get tileLayout():TileLayout
    {
        return TileLayout(layout);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  columnAlign
    //----------------------------------

    [Inspectable(category="General", enumeration="left,justifyUsingGap,justifyUsingWidth", defaultValue="left")]

    /**
     *  @copy spark.layouts.TileLayout#columnAlign
     *  
     *  @default "left"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get columnAlign():String
    {
        return tileLayout.columnAlign;
    }

    /**
     *  @private
     */
    public function set columnAlign(value:String):void
    {
        tileLayout.columnAlign = value;
    }
    
    //----------------------------------
    //  columnCount
    //----------------------------------

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  @copy spark.layouts.TileLayout#columnCount
     * 
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get columnCount():int
    {
        return tileLayout.columnCount;
    }    
    
    //----------------------------------
    //  columnWidth
    //----------------------------------
    
    [Bindable("propertyChange")]
    [Inspectable(category="General", minValue="0.0")]

    /**
     *  @copy spark.layouts.TileLayout#columnWidth
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get columnWidth():int
    {
        return tileLayout.columnWidth;
    }

    /**
     *  @private
     */
    public function set columnWidth(value:int):void
    {
        tileLayout.columnWidth = value;
    }
    
    //----------------------------------
    //  horizontalAlign
    //----------------------------------
    
    [Inspectable(category="General", enumeration="left,right,center,justify", defaultValue="justify")]

    /**
     *  @copy spark.layouts.TileLayout#horizontalAlign
     *  
     *  @default "justify"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get horizontalAlign():String
    {
        return tileLayout.horizontalAlign;
    }

    /**
     *  @private
     */
    public function set horizontalAlign(value:String):void
    {
        tileLayout.horizontalAlign = value;
    }
    
    //----------------------------------
    //  horizontalGap
    //----------------------------------
    
    [Bindable("propertyChange")]
    [Inspectable(category="General", defaultValue="6")]

    /**
     *  @copy spark.layouts.TileLayout#horizontalGap
     * 
     *  @default 6
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get horizontalGap():int
    {
        return tileLayout.horizontalGap;
    }

    /**
     *  @private
     */
    public function set horizontalGap(value:int):void
    {
        tileLayout.horizontalGap = value;
    }

    //----------------------------------
    //  orientation
    //----------------------------------
    
    [Inspectable(category="General", enumeration="rows,columns", defaultValue="rows")]

    /**
     *  @copy spark.layouts.TileLayout#orientation
     * 
     *  @default "rows"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get orientation():String
    {
        return tileLayout.orientation;
    }

    /**
     *  @private
     */
    public function set orientation(value:String):void
    {
        tileLayout.orientation = value;
    }
    
    //----------------------------------
    //  paddingLeft
    //----------------------------------
    
    [Inspectable(category="General", defaultValue="0.0")]
    
    /**
     *  @copy spark.layouts.TileLayout#paddingLeft
     *  
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get paddingLeft():Number
    {
        return tileLayout.paddingLeft;
    }
    
    /**
     *  @private
     */
    public function set paddingLeft(value:Number):void
    {
        tileLayout.paddingLeft = value;
    }    
    
    //----------------------------------
    //  paddingRight
    //----------------------------------
    
    [Inspectable(category="General", defaultValue="0.0")]
    
    /**
     *  @copy spark.layouts.TileLayout#paddingRight
     *  
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get paddingRight():Number
    {
        return tileLayout.paddingRight;
    }
    
    /**
     *  @private
     */
    public function set paddingRight(value:Number):void
    {
        tileLayout.paddingRight = value;
    }    
    
    //----------------------------------
    //  paddingTop
    //----------------------------------
    
    [Inspectable(category="General", defaultValue="0.0")]
    
    /**
     *  @copy spark.layouts.TileLayout#paddingTop
     *  
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get paddingTop():Number
    {
        return tileLayout.paddingTop;
    }
    
    /**
     *  @private
     */
    public function set paddingTop(value:Number):void
    {
        tileLayout.paddingTop = value;
    }    
    
    //----------------------------------
    //  paddingBottom
    //----------------------------------
    
    [Inspectable(category="General", defaultValue="0.0")]
    
    /**
     *  @copy spark.layouts.TileLayout#paddingBottom
     *  
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get paddingBottom():Number
    {
        return tileLayout.paddingBottom;
    }
    
    /**
     *  @private
     */
    public function set paddingBottom(value:Number):void
    {
        tileLayout.paddingBottom = value;
    }    
    
    //----------------------------------
    //  requestedColumnCount
    //----------------------------------

    [Inspectable(category="General", minValue="-1")]

    /**
     *  @copy spark.layouts.TileLayout#requestedColumnCount
     * 
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get requestedColumnCount():int
    {
        return tileLayout.requestedColumnCount;
    }

    /**
     *  @private
     */
    public function set requestedColumnCount(value:int):void
    {
        tileLayout.requestedColumnCount = value;
    }

    //----------------------------------
    //  requestedRowCount
    //----------------------------------

    [Inspectable(category="General", minValue="-1")]

    /**
     *  @copy spark.layouts.TileLayout#requestedRowCount
     * 
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get requestedRowCount():int
    {
        return tileLayout.requestedRowCount;
    }

    /**
     *  @private
     */
    public function set requestedRowCount(value:int):void
    {
        tileLayout.requestedRowCount = value;
    }

    //----------------------------------
    //  rowAlign
    //----------------------------------

    [Inspectable(category="General", enumeration="top,justifyUsingGap,justifyUsingHeight", defaultValue="top")]

    /**
     *  @copy spark.layouts.TileLayout#rowAlign
     * 
     *  @default "top"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get rowAlign():String
    {
        return tileLayout.rowAlign;
    }

    /**
     *  @private
     */
    public function set rowAlign(value:String):void
    {
        tileLayout.rowAlign = value;
    }
    
    //----------------------------------
    //  rowCount
    //----------------------------------

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  @copy spark.layouts.TileLayout#rowCount
     * 
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get rowCount():int
    {
        return tileLayout.rowCount;
    }
    
    //----------------------------------
    //  rowHeight
    //----------------------------------
    
    [Bindable("propertyChange")]
    [Inspectable(category="General", minValue="0.0")]

    /**
     *  @copy spark.layouts.TileLayout#rowHeight
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get rowHeight():int
    {
        return tileLayout.rowHeight;
    }

    /**
     *  @private
     */
    public function set rowHeight(value:int):void
    {
        tileLayout.rowHeight = value;
    }
    
    //----------------------------------
    //  verticalAlign
    //----------------------------------
    
    [Inspectable(category="General", enumeration="top,bottom,middle,justify", defaultValue="justify")]

    /**
     *  @copy spark.layouts.TileLayout#verticalAlign
     *  
     *  @default "justify"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get verticalAlign():String
    {
        return tileLayout.verticalAlign;
    }

    /**
     *  @private
     */
    public function set verticalAlign(value:String):void
    {
        tileLayout.verticalAlign = value;
    }    
    
    //----------------------------------
    //  verticalGap
    //----------------------------------
    
    [Bindable("propertyChange")]
    [Inspectable(category="General", defaultValue="6")]

    /**
     *  @copy spark.layouts.TileLayout#verticalGap
     * 
     *  @default 6
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get verticalGap():int
    {
        return tileLayout.verticalGap;
    }

    /**
     *  @private
     */
    public function set verticalGap(value:int):void
    {
        tileLayout.verticalGap = value;
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
        if (type == "propertyChange")
        {
            if (!hasEventListener(type))
                tileLayout.addEventListener(type, redispatchHandler);
        }
        super.addEventListener(type, listener, useCapture, priority, useWeakReference)
    }    
    
    /**
     * @private
     */
    override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
    {
        super.removeEventListener(type, listener, useCapture);
        if (type == "propertyChange")
        {
            if (!hasEventListener(type))
                tileLayout.removeEventListener(type, redispatchHandler);
        }
    }
    
    private function redispatchHandler(event:Event):void
    {
        dispatchEvent(event);
    }
    
}
}
