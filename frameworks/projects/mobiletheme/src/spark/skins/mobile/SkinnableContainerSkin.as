////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins.mobile
{
import mx.core.IContainerInvalidating;
import mx.core.IFactory;
import mx.core.ILayoutElement;
import mx.core.mx_internal;
import mx.managers.ILayoutManagerContainerClient;
use namespace mx_internal;

import spark.components.Group;
import spark.components.SkinnableContainer;
import spark.components.View;
import spark.skins.mobile.supportClasses.MobileSkin;

/**
 *  ActionScript-based skin for SkinnableContainer.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class SkinnableContainerSkin extends MobileSkin
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    /**
     *  Constructor. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     * 
     */ 
    public function SkinnableContainerSkin()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  SkinParts
    //
    //--------------------------------------------------------------------------
    /**
     *  An optional skin part that defines the Group where the content 
     *  children get pushed into and laid out.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var contentGroup:Group;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /** 
     * @copy spark.skins.spark.ApplicationSkin#hostComponent
     */
    public var hostComponent:SkinnableContainer; // SkinnableComponent will popuplate
    
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
        super.commitCurrentState();
        
        alpha = currentState.indexOf("disabled") == -1 ? 1 : 0.5;
    }
    
    /**
     *  @private 
     */ 
    override protected function createChildren():void
    {      
        contentGroup = new Group();
        contentGroup.id = "contentGroup";
        contentGroup.left = contentGroup.right = contentGroup.top = contentGroup.bottom = 0;
        contentGroup.minWidth = contentGroup.minHeight = 0;
        
        addChild(contentGroup);
    }
    
    /**
     *  @private 
     */ 
    override protected function measure():void
    {        
        super.measure();
        
        measuredWidth = contentGroup.getPreferredBoundsWidth();
        measuredHeight = contentGroup.getPreferredBoundsHeight();
    }
    
    /**
     *  @private
     */
    override mx_internal function validateEstimatedSizesOfChild(child:ILayoutElement):void
    {
        var cw:Number;
        var ch:Number;
        var c:Number;
        var oldcw:Number = child.estimatedWidth;
        var oldch:Number = child.estimatedHeight;
        // the child contentGroup is constrained to the size of the skin
        cw = estimatedWidth;
        if (isNaN(cw) && !isNaN(explicitWidth))
            cw = explicitWidth;
        ch = estimatedHeight;
        if (isNaN(ch) && !isNaN(explicitHeight))
            ch = explicitHeight;
        
        child.setEstimatedSize(cw, ch);
        if (child is ILayoutManagerContainerClient)
        {
            var sameWidth:Boolean = isNaN(cw) && isNaN(oldcw) || cw == oldcw;
            var sameHeight:Boolean = isNaN(ch) && isNaN(oldch) || ch == oldch;
            if (!(sameHeight && sameWidth))
            {
                if (child is IContainerInvalidating)
                    IContainerInvalidating(child).invalidateEstimatedSizesOfChildren();
                ILayoutManagerContainerClient(child).validateEstimatedSizesOfChildren();
            }
        }
    }    
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        graphics.clear();
        
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        // contentGroup is constrained to the size of the skin.
        // if you change this, also update validateEstimatedSizesOfChild
        contentGroup.setLayoutBoundsSize(unscaledWidth, unscaledHeight);
        contentGroup.setLayoutBoundsPosition(0, 0);
        
        // Draw the background
        var bgColor:uint = getStyle("backgroundColor");
        var bgAlpha:Number = getStyle("backgroundAlpha");
        
        graphics.beginFill(bgColor, bgAlpha);
        graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
        graphics.endFill();
    }
}
}