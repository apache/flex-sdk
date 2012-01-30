package spark.skins.mobile
{
import spark.components.MobileApplication;
import spark.components.ViewNavigator;

public class MobileApplicationSkin extends SliderSkin
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    public function MobileApplicationSkin()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    public var hostComponent:MobileApplication;
    public var navigator:ViewNavigator;
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * 
     */
    override protected function createChildren():void
    {
        navigator = new ViewNavigator();
        addChild(navigator);
    }
    
    /**
     * 
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        navigator.setLayoutBoundsPosition(0, 0);
        navigator.setLayoutBoundsSize(unscaledWidth, unscaledHeight);
    }
}
}