////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins.mobile
{
    import flash.display.DisplayObject;
    import flash.display.GradientType;
    import flash.geom.Matrix;
    
    import mx.states.SetProperty;
    import mx.states.State;
    import mx.utils.ColorUtil;
    
/*    
    ISSUES:
    - should we support textAlign
    - labelPlacement a style?
    - iconClass a style?
    - need a downIconClass style? 
    - should the label be UITextField or another text class?  

    TODO:
    - remove spark ButtonLabelPlacement and move mx ButtonLabelPlacement
*/
/**
 *  Actionscript based skin for mobile applications. The skin supports 
 *  iconClass and labelPlacement. It uses a couple of FXG classes to 
 *  implement the vector drawing.  
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ButtonSkin extends ButtonSkinBase
{	
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    public function ButtonSkin()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    private var bgImg:DisplayObject;
    
    private var changeFXGSkin:Boolean = false;
    private var backgroundClass:Class;
    
    private static var matrix:Matrix = new Matrix();
    
    // Used for gradient background
    private static const alphas:Array = [1, 1, 1];
    private static const ratios:Array = [0, 127.5, 255];
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private 
     */
    override protected function commitCurrentState():void
    {          
        if (currentState == "down") 
            backgroundClass = Button_bg_down;
        else
            backgroundClass = Button_bg_up;
        
        if (!(bgImg is backgroundClass))
        {
            changeFXGSkin = true;
            invalidateDisplayList();
        }
        
    }
     
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        var colors:Array = [];
        
        graphics.clear();
        
        // Size the FXG background   
        if (changeFXGSkin)
        {
            changeFXGSkin = false;
            
            if (bgImg)
                removeChild(bgImg);
            bgImg = new backgroundClass();
            addChildAt(bgImg, 0);
        }
        
        if (bgImg != null) 
        {	
            // TODO (jszeto) Figure out why this is .5 Should it be 0?
            bgImg.x = bgImg.y = 0.5;
            bgImg.width = unscaledWidth;
            bgImg.height = unscaledHeight;
        }
        
        // Draw the gradient background
        matrix.createGradientBox(unscaledWidth - 1, unscaledHeight - 2, Math.PI / 2, 0, 0);
        var chromeColor:uint = getStyle("chromeColor");
        colors[0] = ColorUtil.adjustBrightness2(chromeColor, 20);
        colors[1] = chromeColor;
        colors[2] = ColorUtil.adjustBrightness2(chromeColor, -20);
        
        graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
        
        // Draw the background rectangle within the border, so the corners of the rect don't 
        // spill over into the rounded corners of the Button
        graphics.drawRect(1, 1, unscaledWidth - 1, unscaledHeight - 2);
        graphics.endFill();
        
        // The label and icon should be placed on top of the FXG skins
        super.updateDisplayList(unscaledWidth, unscaledHeight);
    }

}
}