////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins.mobile
{

import mx.core.DPIClassification;
import mx.core.mx_internal;

import spark.components.ActionBar;
import spark.components.Group;
import spark.components.ViewNavigator;
import spark.core.SpriteVisualElement;
import spark.skins.mobile160.assets.CalloutContentBackground;
import spark.skins.mobile240.assets.CalloutContentBackground;
import spark.skins.mobile320.assets.CalloutContentBackground;

use namespace mx_internal;

/**
 *  The ActionScript-based skin for view navigators inside a callout.
 *  This skin lays out the action bar and content
 *  group in a vertical fashion, where the action bar is on top.
 *  Unlike the default skin, overlay modes are not supported. 
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3 
 *  @productversion Flex 4.5.2
 */
public class CalloutViewNavigatorSkin extends ViewNavigatorSkin
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
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public function CalloutViewNavigatorSkin()
    {
        super();
        
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                contentBackgroundClass = spark.skins.mobile320.assets.CalloutContentBackground;
                contentCornerRadius = 10;
                gap = 20;
                break;
            }
            case DPIClassification.DPI_240:
            {
                contentBackgroundClass = spark.skins.mobile240.assets.CalloutContentBackground;
                contentCornerRadius = 7;
                gap = 15;
                break;
            }
            default:
            {
                // default DPI_160
                contentBackgroundClass = spark.skins.mobile160.assets.CalloutContentBackground;
                contentCornerRadius = 5;
                gap = 10;
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Layout variables
    //
    //--------------------------------------------------------------------------
    
    mx_internal var gap:Number;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    mx_internal var contentBackgroundClass:Class;
    
    mx_internal var contentBackgroundGraphic:SpriteVisualElement;
    
    mx_internal var contentCornerRadius:Number;
    
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
        contentBackgroundGraphic = new contentBackgroundClass() as SpriteVisualElement;
        addChild(contentBackgroundGraphic);
        
        super.createChildren();
    }
    
    /**
     *  @private 
     */ 
    override protected function measure():void
    {
        super.measure();
        
        measuredWidth = Math.max(actionBar.getPreferredBoundsWidth(), 
            contentGroup.getPreferredBoundsWidth());
        measuredHeight = actionBar.getPreferredBoundsHeight()
            + contentGroup.getPreferredBoundsHeight()
            + gap;
    }
    
    /**
     *  @private
     */ 
    override protected function commitCurrentState():void
    {
        super.commitCurrentState();
        
        // Force a layout pass on the components
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  @private
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // omit super call
        
        var actionBarHeight:Number = 0;
        
        // The action bar is always placed at 0,0 and stretches the entire
        // width of the navigator
        if (actionBar.includeInLayout)
        {
            actionBarHeight = Math.min(actionBar.getPreferredBoundsHeight(), unscaledHeight);
            setElementSize(actionBar, unscaledWidth, actionBarHeight);
            setElementPosition(actionBar, 0, 0);
            actionBarHeight = actionBar.getLayoutBoundsHeight();
        }
        
        if (contentGroup.includeInLayout)
        {
            // If the hostComponent is in overlay mode, the contentGroup extends
            // the entire bounds of the navigator and the alpha for the action 
            // bar changes
            // If this changes, also update validateEstimatedSizesOfChild
            var contentGroupHeight:Number = Math.max(unscaledHeight - actionBarHeight - gap, 0);
            
            setElementSize(contentGroup, unscaledWidth, contentGroupHeight);
            setElementPosition(contentGroup, 0, actionBarHeight + gap);
            
            setElementSize(contentBackgroundGraphic, unscaledWidth, contentGroupHeight);
            setElementPosition(contentBackgroundGraphic, 0, actionBarHeight + gap);
        }
    }
    
    /**
     *  @private
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.drawBackground(unscaledWidth, unscaledHeight);
        
        // draw the contentBackgroundColor
        // the shading and highlight are drawn in FXG
        var contentEllipseSize:Number = contentCornerRadius * 2;
        var contentBackgroundAlpha:Number = getStyle("contentBackgroundAlpha");
        
        graphics.beginFill(getStyle("contentBackgroundColor"),
            contentBackgroundAlpha);
        graphics.drawRoundRect(contentBackgroundGraphic.getLayoutBoundsX(),
            contentBackgroundGraphic.getLayoutBoundsY(),
            contentBackgroundGraphic.getLayoutBoundsWidth(),
            contentBackgroundGraphic.getLayoutBoundsHeight(),
            contentEllipseSize,
            contentEllipseSize);
        graphics.endFill();
        
        contentBackgroundGraphic.alpha = contentBackgroundAlpha;
    }
}
}