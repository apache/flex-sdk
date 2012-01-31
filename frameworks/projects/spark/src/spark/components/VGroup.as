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
import flex.layout.VerticalLayout;
import flash.events.Event;

/**
 *  A Group with a VerticalLayout.  
 * 
 *  All of the VerticalLayout properties exposed by this class are simply
 *  delegated to the layout property.
 * 
 *  The layout property should not be set or configured directly.
 * 
 *  @see flex.layout.VerticalLayout
 */
public class VGroup extends Group
{
    /**
     *  Initializes the layout property to an instance of VerticalLayout.
     *   
     *  @see flex.layout.VerticalLayout
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
     * @copy flex.layout.VerticalLayout#gap
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
    //  rowCount
    //----------------------------------
        
    /**
     * @copy flex.layout.VerticalLayout#rowCount
     */
    public function get rowCount():int
    {
        return verticalLayout.rowCount;
    }
    
    //----------------------------------
    //  requestedRowCount
    //----------------------------------

    /**
     * @copy flex.layout.VerticalLayout#requestedRowCount
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
     * @copy flex.layout.VerticalLayout#rowHeight
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
     * @copy flex.layout.VerticalLayout#variableRowHeight
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
 
    /**
     * @copy flex.layout.VerticalLayout#firstIndexInView
     */
    public function get firstIndexInView():int
    {
        return verticalLayout.firstIndexInView;
    }
    
    //----------------------------------
    //  lastIndexInView
    //----------------------------------

    /**
     * @copy flex.layout.VerticalLayout#lastIndexInview
     */
    public function get lastIndexInView():int
    {
        return verticalLayout.lastIndexInView;
    }   
    
}
}