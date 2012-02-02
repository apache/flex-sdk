////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.controls.advancedDataGridClasses
{

import mx.core.IFactory;
    
/**
 *  The AdvancedDataGridRendererDescription class contains information 
 *  that describes an item renderer for the AdvancedDataGrid control.
 *
 *  @see mx.controls.AdvancedDataGrid
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class AdvancedDataGridRendererDescription
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function AdvancedDataGridRendererDescription()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------   
    
    //----------------------------------
    // columnSpan
    //----------------------------------
    
    /**
     *  Specifies the number of columns that the item renderer spans.
     *  The AdvancedDataGrid control uses this information to set the width 
     *  of the item renderer.
     *  If the <code>columnSpan</code> property has value of 0, 
     *  the item renderer spans the entire row.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var columnSpan:int;
    
    //----------------------------------
    // renderer
    //----------------------------------
    
    /**
     *  The item renderer factory.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */     
    public var renderer:IFactory;
    
    //----------------------------------
    // rowSpan
    //----------------------------------
    
    /**
     *  Specifies the number of rows that the item renderer spans.
     *  The AdvancedDataGrid control uses this information 
     *  to set the height of the item renderer.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var rowSpan:int;
}

}