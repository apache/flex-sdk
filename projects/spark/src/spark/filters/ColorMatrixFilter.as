package flex.filters
{
import flash.filters.BitmapFilter;
import flash.filters.ColorMatrixFilter;

public class ColorMatrixFilter extends BaseFilter implements IBitmapFilter
{
	public function ColorMatrixFilter(matrix:Array = null)
	{
		if (matrix != null)
		{
			this.matrix = matrix;
		} 
	}
	
	//----------------------------------
    //  matrix
    //----------------------------------
	
	private var _matrix:Array =  [1,0,0,0,0,0,
								  1,0,0,0,0,0,
								  1,0,0,0,0,0,
								  1,0];
	
	/**
	 *  The amount of horizontal blur. Valid values are 0 to 255. A blur of 1
	 *  or less means that the original image is copied as is. The default 
	 *  value is 4. Values that are a power of 2 (such as 2, 4, 8, 16, and 32) 
	 *  are optimized to render more quickly than other values.
	 */
	public function get matrix():Array
	{
		return _matrix;
	}
	
	public function set matrix(value:Array):void
	{
		if (value != _matrix)
		{
			_matrix = value;
			notifyFilterChanged();
		}
	}
	
	public function clone():BitmapFilter
	{
		return new flash.filters.ColorMatrixFilter(matrix);
	}
	
}
}