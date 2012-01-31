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

package flex.component
{
import flex.core.Group;
import flex.intf.ILayout;
import flex.layout.HorizontalLayout;

/**
 * A Group with a HorizontalLayout.  
 * 
 * All of the HorizontalLayout properties exposed by this class are simply
 * delegated to the layout property.
 * 
 * The layout property should not be set or configured directly.
 * 
 * @see flex.layout.HorizontalLayout
 */
public class HGroup extends Group
{

    /**
     *  Initializes the layout property to an instance of HorizontalLayout.
     * 
     *  @see flex.layout.HorizontalLayout
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
     * @copy flex.layout.HorizontalLayout#gap
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
        
    /**
     * @copy flex.layout.HorizontalLayout#columnCount
     */
    public function get columnCount():int
    {
        return horizontalLayout.columnCount;
    }
    
    //----------------------------------
    //  requestedColumnCount
    //----------------------------------

    /**
     * @copy flex.layout.HorizontalLayout#requestedColumnCount
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
     * @copy flex.layout.HorizontalLayout#columnWidth
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
     * @copy flex.layout.HorizontalLayout#variableColumnWidth
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
    
}

}