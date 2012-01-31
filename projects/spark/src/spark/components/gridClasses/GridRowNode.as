package spark.components.supportClasses
{

[ExcludeClass]
    
/**
 *  A GridRowNode contains the heights of each cell
 *  for the row at rowIndex.
 */
public final class GridRowNode
{
    public var rowIndex:int;
    
    private var cellHeights:Vector.<Number>;
    public var maxCellHeight:Number = NaN;
    public var fixedHeight:Number = NaN;
    
    public var next:GridRowNode;
    public var prev:GridRowNode;
    
    /**
     *  Constructor.
     */
    public function GridRowNode(numColumns:uint, rowIndex:int)
    {
        super();
        
        this.rowIndex = rowIndex;
        _numColumns = numColumns;
        
        // initialize cellHeights. all are 0 to start out with.
        cellHeights = new Vector.<Number>(numColumns);
    }
    
    private var _numColumns:uint;
    
    /**
     *  Number of columns
     */
    public function get numColumns():uint
    {
        return _numColumns;
    }
    
    public function set numColumns(value:uint):void
    {
        if (value == _numColumns)
            return;
        
        cellHeights.length = value;
        
        if (value > _numColumns)
        {
            for (var i:int = value - _numColumns; i < value; i++)
                cellHeights[i] = 0;
        }
        else
        {
            updateMaxHeight();
        }
        
        _numColumns = value;
    }

    /**
     *  Updates the current max height.
     * 
     *  @return true if changed
     */
    private function updateMaxHeight():Boolean
    {
        // FIXME (klin): use max heap? might not be worth the overhead.
        var max:Number = 0;
        var changed:Boolean = false;
        for (var i:int = 0; i < _numColumns; i++)
            max = Math.max(max, cellHeights[i]);
        
        changed = maxCellHeight != max;
        maxCellHeight = max;
        return changed;
    }
    
    /**
     *  Returns the cell height at the specified index.
     *  
     *  @return the cell height at the given index. NaN if index
     *  is out of bounds.
     */
    public function getCellHeight(index:int):Number
    {
        if (index < 0 || index >= cellHeights.length)
            return NaN;
        return cellHeights[index];
    }
    
    /**
     *  Updates the height at the specified column.
     * 
     *  @return true if max height has changed.
     */
    public function setCellHeight(index:int, value:Number):Boolean
    {
        if (cellHeights[index] == value)
            return false;
        
        cellHeights[index] = value;
        
        return updateMaxHeight();
    }
    
    
    public function toString():String
    {
        var s:String = "";
        
        s += "(" + rowIndex + ", " + maxCellHeight + ") ";
        s += cellHeights + "\n";
        if (prev)
            s += prev.rowIndex;
        else
            s += "null";
        
        s += " <- -> ";
        if (next)
            s += next.rowIndex;
        else
            s += "null";
        
        return s;
    }
    
}
}