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
public class TextAreaVScrollBarThumbSkin extends VScrollBarThumbSkin
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    // These constants are also accessed from TextAreaVScrollBarSkin
    mx_internal static const PADDING_RIGHT_320DPI:int = 8;
    mx_internal static const PADDING_VERTICAL_320DPI:int = 12;
    mx_internal static const PADDING_RIGHT_240DPI:int = 6;
    mx_internal static const PADDING_VERTICAL_240DPI:int = 6;
    mx_internal static const PADDING_RIGHT_DEFAULTDPI:int = 4;
    mx_internal static const PADDING_VERTICAL_DEFAULTDPI:int = 6;
    
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
     * 
     */
    public function TextAreaVScrollBarThumbSkin()
    {
        super();
        
        // Depending on density set padding
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                paddingRight = PADDING_RIGHT_320DPI;
                paddingVertical = PADDING_VERTICAL_320DPI;
                break;
            }
            case DPIClassification.DPI_240:
            {
                paddingRight = PADDING_RIGHT_240DPI;
                paddingVertical = PADDING_VERTICAL_240DPI;
                break;
            }
            default:
            {
                paddingRight = PADDING_RIGHT_DEFAULTDPI;
                paddingVertical = PADDING_VERTICAL_DEFAULTDPI;
                break;
            }
        }
    }
}
}