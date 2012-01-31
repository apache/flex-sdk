package spark.components.supportClasses
{

/**
 *  The SelectionMode class defines the legal constant values for the DataGrid 
 *  <code>slectionMode</code> property
 */
public final class SelectionMode
{
    public function SelectionMode()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    public static const NONE:String = "none";
    public static const SINGLE_ROW:String = "row";
    public static const MULTIPLE_ROWS:String = "multipleRows";
    public static const SINGLE_CELL:String = "cell";
    public static const MULTIPLE_CELLS:String = "multipleCells";
    
}
}