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

package spark.skins.mobile.supportClasses
{
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.events.Event;
import flash.text.TextLineMetrics;

import mx.core.DPIClassification;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.ButtonBarButton;
import spark.components.IconPlacement;
import spark.components.supportClasses.ButtonBase;
import spark.components.supportClasses.ViewNavigatorBase;
import spark.skins.mobile.ButtonSkin;

use namespace mx_internal;

/**
 *  ButtonBarButton skin base class for TabbedViewNavigator ButtonBarButtons.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class TabbedViewNavigatorTabBarTabSkinBase extends ButtonBarButtonSkinBase
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
     */
    public function TabbedViewNavigatorTabBarTabSkinBase()
    {
        super();
        
        useCenterAlignment = false;
        
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                layoutBorderSize = 2;
                layoutPaddingTop = 12;
                layoutPaddingBottom = 12;
                layoutPaddingLeft = 12;
                layoutPaddingRight = 12;
                layoutGap = 10;
                measuredDefaultHeight = 102;
                
                break;
            }
            case DPIClassification.DPI_240:
            {
                layoutBorderSize = 1;
                layoutPaddingTop = 9;
                layoutPaddingBottom = 9;
                layoutPaddingLeft = 9;
                layoutPaddingRight = 9;
                layoutGap = 7;
                measuredDefaultHeight = 76;
                
                break;
            }
            default:
            {
                // default DPI_160
                layoutBorderSize = 1;
                layoutPaddingTop = 6;
                layoutPaddingBottom = 6;
                layoutPaddingLeft = 6;
                layoutPaddingRight = 6;
                layoutGap = 5;
                measuredDefaultHeight = 51;
                
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function set hostComponent(value:ButtonBase):void
    {
        if (hostComponent)
        {
            hostComponent.removeEventListener(FlexEvent.DATA_CHANGE, dataChanged);
        }
        
        super.hostComponent = value;
        
        // look for enabled in hostComponent data
        if (hostComponent)
        {
            hostComponent.addEventListener(FlexEvent.DATA_CHANGE, dataChanged);
            dataChanged();
        }
    }
    
    /**
     *  @private
     */
    override protected function commitDisabled():void
    {
        var alphaValue:Number = (currentState.indexOf("disabled") >= 0) ? 0.25 : 1;
        
        labelDisplay.alpha = alphaValue;
        labelDisplayShadow.alpha = alphaValue;
        
        var icon:DisplayObject = getIconDisplay();
        
        if (icon != null)
            icon.alpha = alphaValue;
    }
    
    /**
     *  @private
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // omit super.drawBackground() to drawRect instead
        // use transparent ButtonBarButtons to support ViewNavigatorBase#overlayControls
        graphics.beginFill(0, 0);
        graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
        graphics.endFill();
    }
    
    /**
     *  @private
     *  Set enabled on ButtonBarButton host component based on ViewNavigator
     *  enabled value.
     */
    private function dataChanged(event:Event=null):void
    {
        var buttonBarButtonHost:ButtonBarButton = ButtonBarButton(hostComponent);
        
        // TabbedViewNavigator dataProvider for ButtonBar is
        // navigators:Vector.<ViewNavigatorBase>
        if (buttonBarButtonHost.data && (buttonBarButtonHost.data is ViewNavigatorBase))
        {
            var viewNavigator:ViewNavigatorBase = ViewNavigatorBase(buttonBarButtonHost.data);
            viewNavigator.addEventListener("enabledChanged", dataEnabledChanged);
            
            dataEnabledChanged();
        }
    }
    
    /**
     *  @private
     *  Update enabled state when ViewNavigator enabled value changes.
     */
    private function dataEnabledChanged(event:Event=null):void
    {
        hostComponent.enabled = ViewNavigatorBase(ButtonBarButton(hostComponent).data).enabled;
    }
}
}