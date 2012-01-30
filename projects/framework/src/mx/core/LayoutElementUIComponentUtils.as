package mx.core
{
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;

import mx.utils.MatrixUtil;

public class LayoutElementUIComponentUtils
{

    include "../core/Version.as";

	public function LayoutElementUIComponentUtils()
	{
		
	}
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    // When changing these constants, make sure you change
    // the constants with the same name in UIComponent    
    private static const DEFAULT_MAX_WIDTH:Number = 10000;
    private static const DEFAULT_MAX_HEIGHT:Number = 10000;

    /**
     *  @return Returns the preferred width (untransformed) of the IUIComponent.
     *  Takes into account measured width, explicit width, explicit min width
     *  and explicit max width.
     */
    private static function getPreferredUBoundsWidth(obj:IUIComponent):Number
    {
    	var result:Number;
        // explicit trumps measured.
        // measured is restricted by explicitMin and then by explicitMax.
        if (!isNaN(obj.explicitWidth))
        {
			result = obj.explicitWidth;
        }
        else
        {
            result = obj.measuredWidth;

            // We don't check against measuredMinHeight, since
            // measuredMinWidth <= measuredWidth is expected always to be true.
            if (!isNaN(obj.explicitMinWidth))
               result = Math.max(result,
                                                 obj.explicitMinWidth);
            if (!isNaN(obj.explicitMaxWidth))
               result = Math.min(result,
                                                 obj.explicitMaxWidth);
        }

        if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_0)
        {
            // We are already taking scale into account from the transform,
            // so adjust here since IUIComponent mixes it with width/height
            result /= obj.scaleX;
        }
        return result;
    }

    /**
     *  @return Returns the preferred height (untransformed) of the IUIComponent.
     *  Takes into account measured height, explicit height, explicit min height
     *  and explicit max height.
     */
    private static function getPreferredUBoundsHeight(obj:IUIComponent):Number
    {
    	var result:Number;

        // explicit trumps measured.
        // measured is restricted by explicitMin and then by explicitMax.
        if (!isNaN(obj.explicitHeight))
        {
            result = obj.explicitHeight;
        }
        else
        {
            result = obj.measuredHeight;

            // We don't check against measuredMinHeight, since
            // measuredMinHeight <= measuredHeight is expected always to be true.
            if (!isNaN(obj.explicitMinHeight))
                result = Math.max(result,
                                                   obj.explicitMinHeight);
            if (!isNaN(obj.explicitMaxHeight))
                result = Math.min(result,
                                                   obj.explicitMaxHeight);
        }
    
        if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_0)
        {
            // We are already taking scale into account from the transform,
            // so adjust here since IUIComponent mixes it with width/height
            result /= obj.scaleY;
        }
        return result;
    }
    
    private static function getMinUBoundsWidth(obj:IUIComponent):Number
    {
        // explicit trumps explicitMin trumps measuredMin.
        // measuredMin is restricted by explicitMax.
        var minWidth:Number;
        if (!isNaN(obj.explicitMinWidth))
        {
            minWidth = obj.explicitMinWidth;
        }
        else
        {
            minWidth = isNaN(obj.measuredMinWidth) ? 0 : obj.measuredMinWidth;
            if (!isNaN(obj.explicitMaxWidth))
                minWidth = Math.min(minWidth, obj.explicitMaxWidth);
        }

        if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_0)
        {
            // We are already taking scale into account from the transform,
            // so adjust here since IUIComponent mixes it with width/height
            minWidth /= obj.scaleX;
        }
        return minWidth;
    }
    
    private static function getMinUBoundsHeight(obj:IUIComponent):Number
    {
        // explicit trumps explicitMin trumps measuredMin.
        // measuredMin is restricted by explicitMax.
        var minHeight:Number;
        if (!isNaN(obj.explicitMinHeight))
        {
            minHeight = obj.explicitMinHeight;
        }
        else
        {
            minHeight = isNaN(obj.measuredMinHeight) ? 0 : obj.measuredMinHeight;
            if (!isNaN(obj.explicitMaxHeight))
                minHeight = Math.min(minHeight, obj.explicitMaxHeight);
        }

        if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_0)
        {
            // We are already taking scale into account from the transform,
            // so adjust here since IUIComponent mixes it with width/height
            minHeight /= obj.scaleY;
        }
        return minHeight;
    }
    
    private static function getMaxUBoundsWidth(obj:IUIComponent):Number
    {
        // explicit trumps explicitMax trumps Number.MAX_VALUE.
        var maxWidth:Number;
        if (!isNaN(obj.explicitMaxWidth))
            maxWidth = obj.explicitMaxWidth;
        else
            maxWidth = DEFAULT_MAX_WIDTH;

        if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_0)
        {
            // We are already taking scale into account from the transform,
            // so adjust here since IUIComponent mixes it with width/height
            maxWidth /= obj.scaleX;
        }
        return maxWidth;
    }
    
    private static function getMaxUBoundsHeight(obj:IUIComponent):Number
    {
        // explicit trumps explicitMax trumps Number.MAX_VALUE.
        var maxHeight:Number;
        if(!isNaN(obj.explicitMaxHeight))
            maxHeight = obj.explicitMaxHeight;
        else
            maxHeight = DEFAULT_MAX_HEIGHT;

        if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_0)
        {
            // We are already taking scale into account from the transform,
            // so adjust here since IUIComponent mixes it with width/height
            maxHeight /= obj.scaleY;
        }
        return maxHeight;
    }
    


    /**
     *  @inheritDoc
     */
    public static function getPreferredBoundsWidth(obj:IUIComponent,transformMatrix:Matrix):Number
    {
        var width:Number = getPreferredUBoundsWidth(obj);

        if (transformMatrix)
        {
			width = MatrixUtil.transformSize(new Point(width, getPreferredUBoundsHeight(obj)), transformMatrix).x;
        }
        return width;
    }

    public static function getPreferredBoundsHeight(obj:IUIComponent,transformMatrix:Matrix):Number
    {
        var height:Number = getPreferredUBoundsHeight(obj);

        if (transformMatrix)
        {
                height = MatrixUtil.transformSize(new Point(getPreferredUBoundsWidth(obj), height), transformMatrix).y;
        }
        return height;
    }

    /**
     *  @inheritDoc
     */
    public static function getMinBoundsWidth(obj:IUIComponent, transformMatrix:Matrix):Number
    {
        var width:Number = getMinUBoundsWidth(obj);

        if (transformMatrix)
        {
			width = MatrixUtil.transformSize(new Point(width, getMinUBoundsHeight(obj)), transformMatrix).x;
        }

        return width;
    }

    public static function getMinBoundsHeight(obj:IUIComponent,transformMatrix:Matrix):Number
    {
        var height:Number = getMinUBoundsHeight(obj);

        if (transformMatrix)
        {
			height = MatrixUtil.transformSize(new Point(getMinUBoundsWidth(obj), height), transformMatrix).y;
        }

        return height;
    }

    /**
     *  @inheritDoc
     */
    public static function getMaxBoundsWidth(obj:IUIComponent, transformMatrix:Matrix):Number
    {
        var width:Number = getMaxUBoundsWidth(obj);
        if (transformMatrix)
        {
			width = MatrixUtil.transformSize(new Point(width, getMaxUBoundsHeight(obj)), transformMatrix).x;
        }

        return width;
    }

    public static function getMaxBoundsHeight(obj:IUIComponent,transformMatrix:Matrix):Number
    {
        var height:Number = getMaxUBoundsHeight(obj);
        if (transformMatrix)
        {
			height = MatrixUtil.transformSize(new Point(getMaxUBoundsWidth(obj), height), transformMatrix).y;
        }

        return height;
    }

    /**
     *  @inheritDoc
     */
    public static function getLayoutBoundsWidth(obj:IUIComponent,transformMatrix:Matrix):Number
    {
        var width:Number = obj.width;
        if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_0)
        {
            // We are already taking scale into account from the transform,
            // so adjust here since IUIComponent mixes it with width/height
            width /= obj.scaleX;
        }

        if (transformMatrix)
        {
            var height:Number = obj.height;
            if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_0)
            {
                // We are already taking scale into account from the transform,
                // so adjust here since IUIComponent mixes it with width/height
                height /= obj.scaleY;
            }
            
            // By default the IUIComponent's registration point is the same
            // as its untransformed border top-left corner, which is (0,0).
            width = MatrixUtil.transformBounds(new Point(width, height),
                                               transformMatrix,
                                               new Point()).x;
        }
        return width;
    }

    public static function getLayoutBoundsHeight(obj:IUIComponent,transformMatrix:Matrix):Number
    {
        var height:Number = obj.height;
        if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_0)
        {
            // We are already taking scale into account from the transform,
            // so adjust here since IUIComponent mixes it with width/height
            height /= obj.scaleY;
        }

        if (transformMatrix)
        {
            var width:Number = obj.width;
            if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_0)
            {
                // We are already taking scale into account from the transform,
                // so adjust here since IUIComponent mixes it with width/height
                width /= obj.scaleX;
            }
            
            // By default the IUIComponent's registration point is the same
            // as its untransformed border top-left corner, which is (0,0).
            height = MatrixUtil.transformBounds(new Point(width, height),
                                                transformMatrix,
                                                new Point()).y;
        }
        return height;
    }

    /**
     *  @inheritDoc
     */
    public static function getLayoutBoundsX(obj:IUIComponent,transformMatrix:Matrix):Number
    {
        if (transformMatrix == null)
            return obj.x;


        var width:Number = obj.width;
        var height:Number = obj.height;

        if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_0)
        {
            width /= obj.scaleX;
            height /= obj.scaleY;
        }
        
		// We are already taking scale into account from the transform,
		// so adjust here since IUIComponent mixes it with width/height
		var pos:Point = new Point();
		MatrixUtil.transformBounds(new Point(width, height),
                            	   transformMatrix,
                            	   pos);
        return pos.x;
    }

    public static function getLayoutBoundsY(obj:IUIComponent,transformMatrix:Matrix):Number
    {
        if (transformMatrix == null)
            return obj.y;


        var width:Number = obj.width;
        var height:Number = obj.height;

        if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_0)
        {
            width /= obj.scaleX;
            height /= obj.scaleY;
        }
        
        // We are already taking scale into account from the transform,
        // so adjust here since IUIComponent mixes it with width/height
        var pos:Point = new Point();
        MatrixUtil.transformBounds(new Point(width, height),
                                   transformMatrix,
                                   pos);
        return pos.y;
    }

    /**
     *  @inheritDoc
     */
    public static function setLayoutBoundsPosition(obj:IUIComponent,x:Number, y:Number, transformMatrix:Matrix):void
    {
        if (transformMatrix)
        {
        	//race("Setting actual position to " + x + "," + y);
        	//race("\tcurrent x/y is " + obj.x + "," + obj.y); 
        	//race("\tcurrent actual position is " + actualPosition.x + "," + actualPosition.y);
            x = x - getLayoutBoundsX(obj,transformMatrix) + obj.x;
            y = y - getLayoutBoundsY(obj,transformMatrix) + obj.y;
        }
        obj.move(x, y);
    }

    /**
     *  @inheritDoc
     */
    public static function setLayoutBoundsSize(obj:IUIComponent,width:Number,
                                  height:Number,
                                  transformMatrix:Matrix):void
    {
        if (!transformMatrix)
        {
            if (isNaN(width))
                width = getPreferredUBoundsWidth(obj);
            if (isNaN(height))
                height = getPreferredUBoundsHeight(obj);
    
            if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_0)
            {
                // We are already taking scale into account from the transform,
                // so adjust here since IUIComponent mixes it with width/height
                width *= obj.scaleX;
                height *= obj.scaleY;
            }
            obj.setActualSize(width, height);
            return;
        }

        var fitSize:Point = MatrixUtil.fitBounds( width, height, transformMatrix,
                                               getPreferredUBoundsWidth(obj),
                                               getPreferredUBoundsHeight(obj),
                                               getMinUBoundsWidth(obj),
                                               getMinUBoundsHeight(obj),
                                               getMaxUBoundsWidth(obj),
                                               getMaxUBoundsHeight(obj));

        // If we couldn't fit at all, default to the minimum size
        if (!fitSize)
            fitSize = new Point(getMinUBoundsWidth(obj), getMinUBoundsHeight(obj));

        if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_0)
        {
            // We are already taking scale into account from the transform,
            // so adjust here since IUIComponent mixes it with width/height
            obj.setActualSize(fitSize.x * obj.scaleX, fitSize.y * obj.scaleY);
        }
        else
            obj.setActualSize(fitSize.x, fitSize.y);
    }
}
}