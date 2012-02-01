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

package spark.skins.spark
{
    
import mx.graphics.BitmapFill;
import mx.graphics.RectangularDropShadow;
import mx.graphics.SolidColor;
import mx.graphics.SolidColorStroke;
import mx.states.SetProperty;
import mx.states.State;

import spark.components.BorderContainer;
import spark.components.Group;
import spark.components.supportClasses.Skin;
import spark.primitives.Path;
import spark.primitives.Rect;

/** 
 * @copy spark.skins.spark.ApplicationSkin#hostComponent
 */
[HostComponent("spark.components.BorderContainer")]

[States("normal", "disabled")]

/**
 *  The default skin class for a Spark BorderContainer component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4 
 */ 
public class BorderContainerSkin extends Skin
{

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
	public function BorderContainerSkin()
	{
	    super();
       
        minWidth = minHeight = 112;
        
	    states = [
            new State({name:"normal"}), 
            new State({name:"disabled", 
                overrides:[new SetProperty(this, "alpha", 0.5)]})
        ];
	}
	
    /**
     *  The required skin part for SkinnableContainer 
     */ 
	[Bindable]
	public var contentGroup:Group;
    
	private var bgRect:Rect;
    private var insetPath:Path;
    private var rds:RectangularDropShadow;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private 
     */ 
	override protected function createChildren():void
	{
	    super.createChildren();
	    
	    bgRect = new Rect();
	    addElementAt(bgRect, 0);
	    bgRect.left = bgRect.top = bgRect.right = bgRect.bottom = 0;
	    
        contentGroup = new Group();
        addElement(contentGroup);  
        
        insetPath = new Path();
        addElement(insetPath);
	}
	
	
    /**
     *  @private 
     */ 
	override protected function measure():void
	{	    
	    measuredWidth = contentGroup.measuredWidth;
	    measuredHeight = contentGroup.measuredHeight;
	    measuredMinWidth = contentGroup.measuredMinWidth;
	    measuredMinHeight = contentGroup.measuredMinHeight;
	    
        var borderWeight:Number = getStyle("borderWeight");
        
	    if (hostComponent && hostComponent.borderStroke)
            borderWeight = hostComponent.borderStroke.weight;
            
        if (borderWeight > 0)
	    {
	        var borderSize:int = borderWeight * 2;
            measuredWidth += borderSize;
            measuredHeight += borderSize;
            measuredMinWidth += borderSize;
            measuredMinHeight += borderSize;
        }
	}
	
    /**
     *  @private 
     */ 
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number) : void
    {
        graphics.clear();
        
        var borderWeight:int;
        var borderStyle:String = getStyle("borderStyle");
        var borderVisible:Boolean = getStyle("borderVisible");
        var cornerRadius:Number = getStyle("cornerRadius");
                
        if (hostComponent && hostComponent.borderStroke)
            borderWeight = hostComponent.borderStroke.weight;
        else
            borderWeight = getStyle("borderWeight"); 
        
        if (!borderVisible)
            borderWeight = 0;
        
        if (isNaN(borderWeight))
            borderWeight = 1;
        
        contentGroup.setStyle("left", borderWeight);
        contentGroup.setStyle("right", borderWeight);
        contentGroup.setStyle("top", borderWeight);
        contentGroup.setStyle("bottom", borderWeight);
        
        // update the bgRect stroke/fill
        if (hostComponent.borderStroke)
        {
            bgRect.stroke = hostComponent.borderStroke;
        }
        else if (!borderVisible)
        {
            bgRect.stroke = null;
        }
        else
        {
            var borderColor:Number = getStyle("borderColor");
            var borderAlpha:Number = getStyle("borderAlpha");
            
            if (!isNaN(borderColor))
            {
                if (isNaN(borderAlpha))
                    borderAlpha = 1;
                bgRect.stroke = new SolidColorStroke(borderColor, borderWeight, borderAlpha);
            }
        }
        
        if (hostComponent.backgroundFill)
        {
            bgRect.fill = hostComponent.backgroundFill;
        }
        else
        {
            var bgImage:Object = getStyle("backgroundImage");
            
            if (bgImage)
            {
                var bitmapFill:BitmapFill = bgRect.fill is BitmapFill ? BitmapFill(bgRect.fill) : new BitmapFill();
 
                bitmapFill.source = bgImage;
                bitmapFill.fillMode = getStyle("backgroundImageFillMode");
                bitmapFill.alpha = getStyle("backgroundAlpha");
                
                bgRect.fill = bitmapFill;
            }
            else
            {
                var bkgdColor:Number = getStyle("backgroundColor");
                var bkgdAlpha:Number = getStyle("backgroundAlpha");
                
                if (isNaN(bkgdAlpha))
                    bkgdAlpha = 1;
                
                if (!isNaN(bkgdColor))
                    bgRect.fill = new SolidColor(bkgdColor, bkgdAlpha);
                else
                    bgRect.fill = new SolidColor(0, 0);
            }
        }
        
        // Draw the shadow for the inset style
        if (borderStyle == "inset" && hostComponent.borderStroke == null && borderVisible)
        {            
            var negCR:Number = -cornerRadius;
            var path:String = ""; 
            
            if (cornerRadius > 0 && borderWeight < 10)
            {
                // Draw each corner with two quadratics, using the following ratios:
                var a:Number = cornerRadius * 0.292893218813453;
                var s:Number = cornerRadius * 0.585786437626905;
                var right:Number = unscaledWidth - borderWeight;
                
                path += "M 0 " + cornerRadius; // M 0 CR
                path += " Q 0 " + s + " " + a + " " + a; // Q 0 s a a 
                path += " Q " + s + " 0 " + cornerRadius + " 0"; // Q s 0 CR 0
                path += " L " + (right - cornerRadius) + " 0"; // L (right-CR) 0
                path += " Q " + (right - s) + " 0 " + (right - a) + " " + a; // Q (right-s) 0 (right-a) a
                path += " Q " + right + " " + s + " " + right + " " + cornerRadius; // Q right s right CR   
                insetPath.height = cornerRadius;
            }
            else
            {
                path += "M 0 0";
                path += " L " + (unscaledWidth - borderWeight) + " 0";
                insetPath.height = 1; 
            }
            
            insetPath.x = borderWeight;
            insetPath.y = borderWeight;
            insetPath.width = unscaledWidth - (borderWeight * 2);
            insetPath.data = path;
            insetPath.stroke = new SolidColorStroke(0x000000, 1, .12);
        }
        else
        {
            insetPath.data = "";
            insetPath.stroke = null;
        }
        
        bgRect.radiusX = bgRect.radiusY = cornerRadius; 
        
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        if (getStyle("dropShadowVisible") == true)
        {
            if (!rds)
                rds = new RectangularDropShadow();
            
            rds.alpha = 0.4;
            rds.angle = 90;
            rds.color = 0x000000;
            rds.distance = 5;
            rds.tlRadius = rds.trRadius = rds.blRadius = rds.brRadius = cornerRadius + 1;
     
            graphics.lineStyle();
            rds.drawShadow(graphics, 0, 0, unscaledWidth, unscaledHeight);
        }
    }

}
}