package spark.skins.mobile
{
import mx.core.DPIClassification;
import mx.core.mx_internal;

use namespace mx_internal;

public class TextAreaHScrollBarSkin extends HScrollBarSkin
{
    public function TextAreaHScrollBarSkin()
    {
        super();

        thumbSkinClass = TextAreaHScrollBarThumbSkin;
        var paddingBottom:int;
        var paddingHorizontal:int;

        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                minHeight = 15;
                paddingBottom = TextAreaHScrollBarThumbSkin.PADDING_BOTTOM_320DPI;
                paddingHorizontal = TextAreaHScrollBarThumbSkin.PADDING_HORIZONTAL_320DPI;
                break;
            }
            case DPIClassification.DPI_240:
            {
                minHeight = 11;
                paddingBottom = TextAreaHScrollBarThumbSkin.PADDING_BOTTOM_240DPI;
                paddingHorizontal = TextAreaHScrollBarThumbSkin.PADDING_HORIZONTAL_240DPI;
                break;
            }
            default:
            {
                // default DPI_160
                minHeight = 9;
                paddingBottom = TextAreaHScrollBarThumbSkin.PADDING_BOTTOM_DEFAULTDPI;
                paddingHorizontal = TextAreaHScrollBarThumbSkin.PADDING_HORIZONTAL_DEFAULTDPI;
                break;
            }
        }
        
        // The minimum width is set such that, at it's smallest size, the thumb appears
        // as wide as it is high.
        minThumbWidth = (minHeight - paddingBottom) + (paddingHorizontal * 2);   
    }
}
}