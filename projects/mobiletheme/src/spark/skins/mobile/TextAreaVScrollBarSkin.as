package spark.skins.mobile
{
import mx.core.DPIClassification;


public class TextAreaVScrollBarSkin extends VScrollBarSkin
{
    public function TextAreaVScrollBarSkin()
    {
        super();

        thumbSkinClass = TextAreaVScrollBarThumbSkin;

        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                minWidth = 15;
                break;
            }
            case DPIClassification.DPI_240:
            {
                minWidth = 11;
                break;
            }
            default:
            {
                // default PPI160
                minWidth = 9;
                break;
            }
        }
    }
}
}