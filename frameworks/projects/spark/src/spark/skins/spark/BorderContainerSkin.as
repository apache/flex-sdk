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
import mx.graphics.BitmapResizeMode;
import mx.graphics.RectangularDropShadow;
import mx.graphics.SolidColor;
import mx.graphics.SolidColorStroke;
import mx.states.SetProperty;
import mx.states.State;

import spark.components.Border;
import spark.components.Group;
import spark.components.supportClasses.Skin;
import spark.primitives.Line;
import spark.primitives.Path;
import spark.primitives.Rect;

[HostComponent("Border")]

/**
 *  The default skin class for a Spark Border container.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4 
 */ 
public class BorderSkin extends Skin
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
	public function BorderSkin()
	{
	    super();
	    
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
	    //super.measure();
	    
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
        
        var borderWeight:int = getStyle("borderWeight");
        var borderStyle:String = getStyle("borderStyle");
        var borderVisible:Boolean = getStyle("borderVisible");
        var cornerRadius:Number = getStyle("cornerRadius");
        
        if (hostComponent && hostComponent.borderStroke)
        {
            borderWeight = hostComponent.borderStroke.weight;
        }
        
        if (!borderVisible)
            borderWeight = 0;
        
        if (isNaN(borderWeight))
            borderWeight = 1;
        
        
        // position & size the content group
        contentGroup.x = contentGroup.y = borderWeight;
        contentGroup.width = unscaledWidth - borderWeight * 2;
        contentGroup.height = unscaledHeight - borderWeight * 2;
        
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
                var bitmapFill:BitmapFill = new BitmapFill();
 
                bitmapFill.source = bgImage;
                bitmapFill.resizeMode = getStyle("backgroundImageResizeMode");
                    
                // Adjust the bitmap fill to account for the stroke thickness
                //bitmapFill.x = contentGroup.x;
                //bitmapFill.y = contentGroup.y;
                
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
                    bgRect.fill = null;
            }
        }
        
        // Draw the shadow for the inset style
        if (borderStyle == "inset" && hostComponent.borderStroke == null)
        {
           /* insetLine.xFrom = borderWeight;
            insetLine.xTo = unscaledWidth - borderWeight;
            insetLine.y = borderWeight;
            insetLine.stroke = new SolidColorStroke(0x000000, 1, .12);*/
            
            // FIXME (jszeto) add special case for no corner radius
            
            var bwcr:Number = borderWeight + cornerRadius;
            var w_bt:Number = unscaledWidth - borderWeight;
            var negCR:Number = -cornerRadius;
            var path:String = "M " + borderWeight + " " + bwcr;
            path += " q 0 " + negCR + " " + cornerRadius + " " + negCR;
            path += " l " + (unscaledWidth - ((borderWeight + cornerRadius) * 2)) + " 0";
            path += " q " + cornerRadius + " 0 " + cornerRadius + " " + cornerRadius;
            insetPath.x = 0;
            insetPath.y = 0;
            insetPath.width = unscaledWidth - (borderWeight * 2);
            insetPath.height = cornerRadius;
            insetPath.data = path;
            insetPath.stroke = new SolidColorStroke(0x000000, 1, .12);
            
            //trace('path value',path);           
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