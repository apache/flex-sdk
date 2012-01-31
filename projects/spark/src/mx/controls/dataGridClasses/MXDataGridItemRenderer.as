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

package mx.controls.dataGridClasses
{
import mx.controls.listClasses.MXItemRenderer;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="listData", kind="property")]

/**
 *  The MXDataGridItemRenderer class defines the Spark item renderer class 
 *  for use with the MX DataGrid control.
 *  This class lets you use the Spark item renderer architecture with the 
 *  MX DataGrid control. 
 * 
 *  @mxml
 *
 *  <p>The <code>&lt;s:MXDataGridItemRenderer&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:MXItemRenderer
 *    <strong>Properties</strong>
 *  /&gt;
 *  </pre>
 *  
 *  @see mx.controls.DataGrid
 *  @includeExample examples/MXDataGridItemRenderer.mxml
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class MXDataGridItemRenderer extends MXItemRenderer
{    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function MXDataGridItemRenderer()
    {
        super();
    }
    
    //----------------------------------
    //  dataGridListData
    //----------------------------------

    [Bindable("dataChange")]
    
    /**
     *  The implementation of the <code>listData</code> property
     *  as defined by the IDropInListItemRenderer interface.
     *  Use this property to access information about the 
     *  data item displayed by the item renderer.     
     *
     *  @see mx.controls.listClasses.IDropInListItemRenderer
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get dataGridListData():DataGridListData
    {
        return listData as DataGridListData;
    }


}
}