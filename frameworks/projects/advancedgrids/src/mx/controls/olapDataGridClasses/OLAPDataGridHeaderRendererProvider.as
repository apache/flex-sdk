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

package mx.controls.olapDataGridClasses
{

/**
 *  The OLAPDataGridHeaderRendererProvider class lets you specify a 
 *  custom header renderer for the columns in the OLAPDataGrid control. 
 *
 *  <p>To specify a custom header renderer to the OLAPDataGrid control, 
 *  create your customer header renderer as a subclass of the OLAPDataGridHeaderRenderer class,
 *  create an instance of the OLAPDataGridHeaderRendererProvider, 
 *  set the <code>OLAPDataGridHeaderRendererProvider.renderer</code> property to
 *  your customer header renderer, and  
 *  then pass the OLAPDataGridHeaderRendererProvider instance to the OLAPDATAGrid control
 *  by setting the <code>OLAPDataGrid.headerRendererProviders</code> property.</p>
 *
 *  @see mx.controls.OLAPDataGrid
 *  @see mx.controls.olapDataGridClasses.OLAPDataGridHeaderRenderer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPDataGridHeaderRendererProvider extends OLAPDataGridRendererProvider
{
	include "../../core/Version.as";
	
	//--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------   
    
    //----------------------------------
    // headerWordWrap
    //----------------------------------
    
    /**
     *  Set to <code>true</code> to wrap the text in the column header.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var headerWordWrap:*
}    
}
