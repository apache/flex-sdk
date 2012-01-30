package spark.skins.mobile
{
import mx.core.DPIClassification;
import mx.core.mx_internal;

use namespace mx_internal;

public class TextAreaVScrollBarSkin extends VScrollBarSkin
{
    public function TextAreaVScrollBarSkin()
    {
        super();

        thumbSkinClass = TextAreaVScrollBarThumbSkin;
        var paddingRight:int;
        var paddingVertical:int;

        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                minWidth = 15;
                paddingRight = TextAreaVScrollBarThumbSkin.PADDING_RIGHT_320DPI;
                paddingVertical = TextAreaVScrollBarThumbSkin.PADDING_VERTICAL_320DPI;
                break;
            }
            case DPIClassification.DPI_240:
            {
                minWidth = 11;
                paddingRight = TextAreaVScrollBarThumbSkin.PADDING_RIGHT_240DPI;
                paddingVertical = TextAreaVScrollBarThumbSkin.PADDING_VERTICAL_240DPI;
                break;
            }
            default:
            {
                // default DPI_160
                minWidth = 9;
                paddingRight = TextAreaVScrollBarThumbSkin.PADDING_RIGHT_DEFAULTDPI;
                paddingVertical = TextAreaVScrollBarThumbSkin.PADDING_VERTICAL_DEFAULTDPI;
                break;
            }
        }
        
        // The minimum height is set such that, at it's smallest size, the thumb appears
        // as high as it is wide.
        minThumbHeight = (minWidth - paddingRight) + (paddingVertical * 2);  
    }
}
}