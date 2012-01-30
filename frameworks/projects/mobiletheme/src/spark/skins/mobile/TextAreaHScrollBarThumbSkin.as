package spark.skins.mobile
{
import mx.core.DPIClassification;
import mx.core.mx_internal;

use namespace mx_internal;

/**
 *  The ActionScript-based skin used for TextAreaHScrollBarThumb components
 *  in mobile applications.
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 * 
 */
public class TextAreaHScrollBarThumbSkin extends HScrollBarThumbSkin
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    // These constants are also accessed from HScrollBarSkin
    mx_internal static const PADDING_BOTTOM_320DPI:int = 8;
    mx_internal static const PADDING_HORIZONTAL_320DPI:int = 12;
    mx_internal static const PADDING_BOTTOM_240DPI:int = 6;
    mx_internal static const PADDING_HORIZONTAL_240DPI:int = 6;
    mx_internal static const PADDING_BOTTOM_DEFAULTDPI:int = 4;
    mx_internal static const PADDING_HORIZONTAL_DEFAULTDPI:int = 6;
    
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
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function TextAreaHScrollBarThumbSkin()
    {
        super();
        
        // Depending on density set padding
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                paddingBottom = PADDING_BOTTOM_320DPI;
                paddingHorizontal = PADDING_HORIZONTAL_320DPI;
                break;
            }
            case DPIClassification.DPI_240:
            {
                paddingBottom = PADDING_BOTTOM_240DPI;
                paddingHorizontal = PADDING_HORIZONTAL_240DPI;
                break;
            }
            default:
            {
                paddingBottom = PADDING_BOTTOM_DEFAULTDPI;
                paddingHorizontal = PADDING_HORIZONTAL_DEFAULTDPI;
                break;
            }
        }
    }
}
}