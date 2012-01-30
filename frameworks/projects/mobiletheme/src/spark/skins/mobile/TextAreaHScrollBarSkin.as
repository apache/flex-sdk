package spark.skins.mobile
{
import mx.core.DPIClassification;


public class TextAreaHScrollBarSkin extends HScrollBarSkin
{
    public function TextAreaHScrollBarSkin()
    {
        super();

        thumbSkinClass = TextAreaHScrollBarThumbSkin;

        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                minHeight = 15;
                break;
            }
            case DPIClassification.DPI_240:
            {
                minHeight = 11;
                break;
            }
            default:
            {
                // default PPI160
                minHeight = 9;
                break;
            }
        }
    }
}
}