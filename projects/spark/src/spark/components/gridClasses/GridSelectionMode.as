package spark.components.supportClasses
{

/**
 *  The GridSelectionMode class defines the legal constant values for the DataGrid 
 *  <code>selectionMode</code> property.
 */
public final class GridSelectionMode
{
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
     *  Specifies that there is no selection allowed.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public static const NONE:String = "none";

    /**
     *  Specifies that one row can be selected.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public static const SINGLE_ROW:String = "row";

    /**
     *  Specifies that one or more rows can be selected.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public static const MULTIPLE_ROWS:String = "multipleRows";

    /**
     *  Specifies that one cell can be selected.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public static const SINGLE_CELL:String = "cell";

    /**
     *  Specifies that one or more cells can be selected.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public static const MULTIPLE_CELLS:String = "multipleCells";
    
}
}