package mx.skins.spark {

public class ContainerBorderSkin extends BorderSkin
{
    public function ContainerBorderSkin()
    {
        super();
    }
    
    /**
     *  @private
     *  ContainerBorderSkin uses backgroundColor and backgroundAlpha
     *  instead of contentBackgroundColor and contentBackgroundAlpha.
     *  Override the contentItems getter here to return null. This
     *  removes the contentBackgroundColor/Alpha functionality.
     *  The backgroundColor/backgroundAlpha functionality is handled
     *  below in updateDisplayList.
     */
    override public function get contentItems():Array
    {
        return null;
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number) : void
    {
        var cr:Number = getStyle("cornerRadius");
        
        if (cornerRadius != cr)
            cornerRadius = cr;
        
        // Push backgroundColor and backgroundAlpha directly.
        // Handle undefined backgroundColor by hiding the background object.
        if (isNaN(getStyle("backgroundColor")))
        {
            background.visible = false;
        }
        else
        {
            background.visible = true;
            bgFill.color = getStyle("backgroundColor");
            bgFill.alpha = getStyle("backgroundAlpha");
        }
        
        super.updateDisplayList(unscaledWidth, unscaledHeight);
    }

}
}