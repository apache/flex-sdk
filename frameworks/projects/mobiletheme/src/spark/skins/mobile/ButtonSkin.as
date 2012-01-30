package spark.skins.mobile
{

import flash.display.DisplayObject;
import flash.events.EventDispatcher;
import flash.text.TextField;
import flash.text.TextFormat;

import spark.components.Button;

public class ButtonSkin extends SliderSkin  
{    
    public function ButtonSkin()
    {
        super();
    }
    
    //////////////////////////////////////////
    // Properties
    //////////////////////////////////////////
    
    public var hostComponent:Button;
    
    //////////////////////////////////////////
    // Methods
    //////////////////////////////////////////
    
    override protected function commitCurrentState():void
    {
        if (currentState == "down")
        {
            removeChild(bgImg);
            bgImg = new Button_bg_down();
            addChild(bgImg);
            invalidateDisplayList();
        }
        else
        {
            if (!(bgImg is Button_bg_up))
            {
                removeChild(bgImg);
                bgImg = new Button_bg_up();
                addChild(bgImg);
                invalidateDisplayList();
            }
			
			if (currentState == "disabled")
				bgImg.alpha = textField.alpha = 0.5;
			else
				bgImg.alpha = textField.alpha = 1;
        }
    }
    
    override protected function createChildren():void
    {
        var tf:TextFormat = new TextFormat;
        
        textField = new TextField();
        tf.align = "center";
        tf.color = getStyle("color");
        tf.font = getStyle("fontFamily");
        tf.size = getStyle("fontSize");
        textField.defaultTextFormat = tf;
        
        addChild(textField);
        
        bgImg = new Button_bg_up();
        addChild(bgImg);
    }
    
    override protected function commitProperties():void
    {
        textField.text = hostComponent.label;
    }
	
	override public function getExplicitOrMeasuredWidth():Number
	{
		return Math.max(70, textField.textWidth + 20);
	}
	
	override public function getExplicitOrMeasuredHeight():Number
	{
		return 20;
	}
	
    override protected function measure():void
    {
		// !! should use graphic width/height here instead of 70/20
        hostComponent.measuredWidth = Math.max(70, textField.textWidth + 20);    
        hostComponent.measuredHeight = 20;   
    }
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // Show the graphic
        bgImg.x = bgImg.y = 0.5;
        bgImg.width = unscaledWidth;
		bgImg.height = unscaledHeight;
        
        // Center the label
        textField.width = unscaledWidth;
        textField.height = textField.textHeight + 4;
        textField.y = Math.round((unscaledHeight - textField.height) / 2) + 1;
        
        // Put the label on top
        setChildIndex(textField, numChildren - 1);
    }
    
    //////////////////////////////////////////
    // Internals
    //////////////////////////////////////////
    
    private var textField:TextField;
    private var bgImg:DisplayObject;
}
}