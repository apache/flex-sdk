package spark.skins.mobile
{
import mx.core.DPIClassification;


public class TextAreaVScrollBarThumbSkin extends VScrollBarThumbSkin
{
    public function TextAreaVScrollBarThumbSkin()
    {
        super();
        
        // Depending on density set padding
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                paddingRight = 8;
                paddingVertical = 12;
                break;
            }
            case DPIClassification.DPI_240:
            {
                paddingRight = 6;
                paddingVertical = 6;
                break;
            }
            default:
            {
                paddingRight = 4;
                paddingVertical = 6;
                break;
            }
        }
    }
}
}