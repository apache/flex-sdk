////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.gridClasses
{

/**
 *  The GridSelectionMode class defines the valid constant values for the 
 *  <code>selectionMode</code> property of the Spark DataGrid and Grid controls.
 *  
 *  <p>Use the constants in ActionsScript, as the following example shows: </p>
 *  <pre>
 *    myDG.selectionMode = GridSelectionMode.MULTIPLE_CELLS;
 *  </pre>
 *
 *  <p>In MXML, use the String value of the constants, 
 *  as the following example shows:</p>
 *  <pre>
 *    &lt;s:DataGrid id="myGrid" width="350" height="150"
 *        selectionMode="multipleCells"&gt; 
 *        ...
 *    &lt;/s:DataGrid&gt; 
 *  </pre>
 * 
 *  @see spark.components.DataGrid#selectionMode
 *  @see spark.components.Grid#selectionMode
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public final class GridSelectionMode
{
    
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function GridSelectionMode()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Specifies that no selection is allowed.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const NONE:String = "none";

    /**
     *  Specifies that one row can be selected.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const SINGLE_ROW:String = "singleRow";

    /**
     *  Specifies that one or more rows can be selected.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const MULTIPLE_ROWS:String = "multipleRows";

    /**
     *  Specifies that one cell can be selected.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const SINGLE_CELL:String = "singleCell";

    /**
     *  Specifies that one or more cells can be selected.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const MULTIPLE_CELLS:String = "multipleCells";
    
}
}