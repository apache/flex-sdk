package spark.skins.mobile
{
import mx.core.DPIClassification;


public class TextAreaHScrollBarThumbSkin extends HScrollBarThumbSkin
{
    public function TextAreaHScrollBarThumbSkin()
    {
        super();
        
        // Depending on density set padding
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                paddingBottom = 8;
                paddingHorizontal = 12;
                break;
            }
            case DPIClassification.DPI_240:
            {
                paddingBottom = 6;
                paddingHorizontal = 6;
                break;
            }
            default:
            {
                paddingBottom = 4;
                paddingHorizontal = 6;
                break;
            }
        }
    }
}
}