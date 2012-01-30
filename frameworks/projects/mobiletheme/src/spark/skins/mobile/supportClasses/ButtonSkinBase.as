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
import flash.geom.Point;
import flash.text.TextLineMetrics;

import mx.core.ILayoutElement;
import mx.core.UITextField;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.Group;
import spark.components.IconPlacement;
import spark.components.ResizeMode;
import spark.components.supportClasses.ButtonBase;
import spark.components.supportClasses.StyleableTextField;
import spark.primitives.BitmapImage;

use namespace mx_internal;

/*
ISSUES:
- should we support textAlign (if not, remove extra code)
*/
/**
 *  ActionScript-based skin for mobile applications. The skin supports
 *  icon and iconPlacement. It uses FXG classes to
 *  implement the vector drawing.
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class ButtonSkinBase extends MobileSkin
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
    public function ButtonSkinBase()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  iconDisplay skin part.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private var iconChanged:Boolean = false;
    private var iconInstance:Object;    // Can be either DisplayObject or BitmapImage
    private var iconHolder:Group;       // Needed when iconInstance is a BitmapImage
    private var _icon:Object;           // The currently set icon, can be Class, DisplayObject, URL
    
    /**
     *  @private
     *  Flag that is set when the currentState changes from enabled to disabled
     */
    private var enabledChanged:Boolean = false;
    
    /**
     *  labelDisplay skin part.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var labelDisplay:StyleableTextField;
    
    /**
     *  If true, then create the iconDisplay using the icon style.
     *
     *  @default true
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var useIconStyle:Boolean = true;
    
    /**
     *  If true, then the labelDisplay and iconDisplay are centered.
     *
     *  @default true
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var useCenterAlignment:Boolean = true;
    
    private var _hostComponent:ButtonBase;
    
    /**
     * @copy spark.skins.spark.ApplicationSkin#hostComponent
     */
    public function get hostComponent():ButtonBase
    {
        return _hostComponent;
    }
    
    /**
     * @private
     */
    public function set hostComponent(value:ButtonBase):void
    {
        _hostComponent = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Layout variables
    //
    //--------------------------------------------------------------------------
    
    protected var layoutBorderSize:uint;
    
    protected var layoutGap:int;
    
    /**
     *  Left padding for icon or labelDisplay.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var layoutPaddingLeft:int;
    
    /**
     *  Right padding for icon or labelDisplay.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var layoutPaddingRight:int;
    
    /**
     *  Top padding for icon or labelDisplay.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var layoutPaddingTop:int;
    
    /**
     *  Bottom padding for icon or labelDisplay.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var layoutPaddingBottom:int;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function set currentState(value:String):void
    {
        var isDisabled:Boolean = currentState && currentState.indexOf("disabled") >= 0;
        
        super.currentState = value;
        
        if (isDisabled != currentState.indexOf("disabled") >= 0)
        {
            enabledChanged = true;
            invalidateProperties();
        }
    }
    
    /**
     *  @private
     */
    override protected function createChildren():void
    {
        labelDisplay = StyleableTextField(createInFontContext(StyleableTextField));
        labelDisplay.styleName = this;
        
        // update shadow when labelDisplay changes
        labelDisplay.addEventListener(FlexEvent.VALUE_COMMIT, labelDisplay_valueCommitHandler);
        
        addChild(labelDisplay);
    }
    
    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        var allStyles:Boolean = !styleProp || styleProp == "styleName";
        
        if (allStyles || styleProp == "iconPlacement")
        {
            invalidateSize();
            invalidateDisplayList();
        }
        
        if (useIconStyle && (allStyles || styleProp == "icon"))
        {
            iconChanged = true;
            invalidateProperties();
        }
        
        if (styleProp == "textShadowAlpha")
        {
            invalidateDisplayList();
        }
        
        super.styleChanged(styleProp);
    }
    
    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (useIconStyle && iconChanged)
        {
            // force enabled update when icon changes
            enabledChanged = true;
            iconChanged = false;
            setIcon(getStyle("icon"));
        }
        
        if (enabledChanged)
        {
            commitDisabled();
            enabledChanged = false;
        }
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        
        var labelWidth:Number = 0;
        var labelHeight:Number = 0;
        var textDescent:Number = 0;
        var iconDisplay:DisplayObject = getIconDisplay();
        
        // reset text if it was truncated before.
        if (hostComponent && labelDisplay.isTruncated)
            labelDisplay.text = hostComponent.label;
        
        // we want to get the label's width and height if we have text or there's
        // no icon present
        if (labelDisplay.text != "" || !iconDisplay)
        {
            labelWidth = getElementPreferredWidth(labelDisplay);
            labelHeight = getElementPreferredHeight(labelDisplay);
            textDescent = labelDisplay.getLineMetrics(0).descent;
        }
        
        var w:Number = layoutPaddingLeft + layoutPaddingRight;
        var h:Number = 0;
        
        var iconWidth:Number = 0;
        var iconHeight:Number = 0;
        
        if (iconDisplay)
        {
            iconWidth = getElementPreferredWidth(iconDisplay);
            iconHeight = getElementPreferredHeight(iconDisplay);
        }
        
        var iconPlacement:String = getStyle("iconPlacement");
        
        // layoutPaddingBottom is from the bottom of the button to the text
        // baseline or the bottom of the icon.
        // It must be adjusted when descent grows larger than the padding.
        var adjustablePaddingBottom:Number = layoutPaddingBottom;
        
        if (iconPlacement == IconPlacement.LEFT ||
            iconPlacement == IconPlacement.RIGHT)
        {
            w += labelWidth + iconWidth;
            if (labelWidth && iconWidth)
                w += layoutGap;
            
            var viewHeight:Number = Math.max(labelHeight, iconHeight);
            h += viewHeight;
        }
        else
        {
            w += Math.max(labelWidth, iconWidth);
            h += labelHeight + iconHeight;
            
            adjustablePaddingBottom = layoutPaddingBottom;
            
            if (labelHeight && iconHeight)
            {
                if (iconPlacement == IconPlacement.BOTTOM)
                {
                    // adjust gap if descent is larger
                    h += Math.max(textDescent, layoutGap);
                }
                else
                {
                    adjustablePaddingBottom = Math.max(layoutPaddingBottom, textDescent);
                    
                    h += layoutGap;
                }
            }
        }
        
        h += layoutPaddingTop + adjustablePaddingBottom;
        
        // measuredMinHeight for width and height for a square measured minimum size
        measuredMinWidth = h;
        measuredMinHeight = h;
        
        measuredWidth = w
        measuredHeight = h;
    }
    
    /**
     *  @private
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        var hasLabel:Boolean = (hostComponent && hostComponent.label != "");
        var labelX:Number = 0;
        var labelY:Number = 0;
        var labelWidth:Number = 0;
        var labelHeight:Number = 0;
        
        var textWidth:Number = 0;
        var textHeight:Number = 0;
        var textDescent:Number = 0;
        
        var iconPlacement:String = getStyle("iconPlacement");
        var isHorizontal:Boolean = (iconPlacement == IconPlacement.LEFT || iconPlacement == IconPlacement.RIGHT);
        
        var iconX:Number = 0;
        var iconY:Number = 0;
        var unscaledIconWidth:Number = 0;
        var unscaledIconHeight:Number = 0;
        
        // vertical gap grows when text descent > gap
        var adjustableGap:Number = 0;
        
        // bottom constraint grows when text descent > layoutPaddingBottom
        var adjustablePaddingBottom:Number = layoutPaddingBottom;
        
        // reset text if it was truncated before.
        if (hostComponent && labelDisplay.isTruncated)
            labelDisplay.text = hostComponent.label;
        
        if (hasLabel)
        {
            var metrics:TextLineMetrics = labelDisplay.getLineMetrics(0);
            textWidth = getElementPreferredWidth(labelDisplay);
            textHeight = getElementPreferredHeight(labelDisplay);
            textDescent = metrics.descent;
        }
        
        var iconDisplay:DisplayObject = getIconDisplay();
        
        if (iconDisplay)
        {
            unscaledIconWidth = getElementPreferredWidth(iconDisplay);
            unscaledIconHeight = getElementPreferredHeight(iconDisplay);
            adjustableGap = (hasLabel) ? layoutGap : 0;
        }
        
        // compute padding bottom based on descent and text position
        if (iconPlacement == IconPlacement.BOTTOM)
        {
            // icon bottom constrained by padding
            adjustablePaddingBottom = layoutPaddingBottom;
        }
        else if (iconPlacement == IconPlacement.TOP)
        {
            // adjust padding if descent is larger
            adjustablePaddingBottom = Math.max(layoutPaddingBottom, textDescent);
        }
        
        var viewWidth:Number = Math.max(unscaledWidth - layoutPaddingLeft - layoutPaddingRight, 0);
        var viewHeight:Number = Math.max(unscaledHeight - layoutPaddingTop - adjustablePaddingBottom, 0);
        
        var iconViewWidth:Number = Math.min(unscaledIconWidth, viewWidth);
        var iconViewHeight:Number = Math.min(unscaledIconHeight, viewHeight);
        
        // snap label to left and right bounds
        labelWidth = viewWidth;
        
        // default label vertical positioning is ascent centered
        labelHeight = Math.min(viewHeight, textHeight);
        labelY = (viewHeight - labelHeight) / 2;
        
        if (isHorizontal)
        {
            // label width constrained by icon width
            labelWidth = Math.max(Math.min(viewWidth - iconViewWidth - adjustableGap, textWidth), 0);
            
            if (useCenterAlignment)
                labelX = (viewWidth - labelWidth - iconViewWidth - adjustableGap) / 2;
            else
                labelX = 0;
            
            if (iconPlacement == IconPlacement.LEFT)
            {
                iconX = labelX;
                labelX += iconViewWidth + adjustableGap;
            }
            else
            {
                iconX  = labelX + labelWidth + adjustableGap;
            }
            
            iconY = (viewHeight - iconViewHeight) / 2;
        }
        else if (iconViewHeight)
        {
            // icon takes precedence over label
            labelHeight = Math.min(Math.max(viewHeight - iconViewHeight - adjustableGap, 0), textHeight);
            
            // adjust gap for descent when text is above icon
            if (hasLabel && (iconPlacement == IconPlacement.BOTTOM))
                adjustableGap = Math.max(adjustableGap, textDescent);
            
            if (useCenterAlignment)
            {
                // labelWidth already set to viewWidth with textAlign=center
                labelX = 0;
                
                // y-position for vertical center of both icon and label
                labelY = (viewHeight - labelHeight - iconViewHeight - adjustableGap) / 2;
            }
            else
            {
                // label horizontal center with textAlign=left
                labelWidth = Math.min(textWidth, viewWidth);
                labelX = (viewWidth - labelWidth) / 2;
            }
            
            // horizontally center iconWidth
            iconX = (viewWidth - iconViewWidth) / 2;
            
            var availableIconHeight:Number = viewHeight - labelHeight - adjustableGap;
            
            if (iconPlacement == IconPlacement.TOP)
            {
                if (useCenterAlignment)
                {
                    iconY = labelY;
                    labelY = iconY + adjustableGap + iconViewHeight;
                }
                else
                {
                    if (unscaledIconHeight >= availableIconHeight)
                    {
                        // constraint to top
                        iconY = 0;
                    }
                    else
                    {
                        // center icon in available height (above label) including gap
                        // remove padding top since we offset again later
                        iconY = ((availableIconHeight + layoutPaddingTop + adjustableGap - unscaledIconHeight) / 2) - layoutPaddingTop;
                    }
                    
                    labelY = viewHeight - labelHeight;
                }
            }
            else // IconPlacement.BOTTOM
            {
                if (useCenterAlignment)
                {
                    iconY = labelY + labelHeight + adjustableGap;
                }
                else
                {
                    if (unscaledIconHeight >= availableIconHeight)
                    {
                        // constraint to bottom
                        iconY = viewHeight - iconViewHeight;
                    }
                    else
                    {
                        // center icon in available height (below label) including gap
                        iconY = ((availableIconHeight + adjustablePaddingBottom + adjustableGap - unscaledIconHeight) / 2) + labelHeight;
                    }
                    
                    labelY = 0;
                }
            }
        }
        
        // adjust labelHeight for vertical clipping at the bottom edge
        if (isHorizontal && (labelHeight < textHeight))
        {
            // allow gutter to be outside skin bounds
            // this appears as clipping by the bottom border
            var labelViewHeight:Number = Math.min(unscaledHeight - layoutPaddingTop - labelY 
                - textDescent + (StyleableTextField.TEXT_HEIGHT_PADDING / 2), textHeight);
            labelHeight = Math.max(labelViewHeight, labelHeight);
        }
        
        labelX = Math.max(0, Math.round(labelX)) + layoutPaddingLeft;
        // text looks better a little high as opposed to low, so we use floor instead of round
        labelY = Math.max(0, Math.floor(labelY)) + layoutPaddingTop;
        
        iconX = Math.max(0, Math.round(iconX)) + layoutPaddingLeft;
        iconY = Math.max(0, Math.round(iconY)) + layoutPaddingTop;
        
        setElementSize(labelDisplay, labelWidth, labelHeight);
        setElementPosition(labelDisplay, labelX, labelY);
        
        if (textWidth > labelWidth)
            labelDisplay.truncateToFit();
        
        if (iconDisplay)
        {
            setElementSize(iconDisplay, iconViewWidth, iconViewHeight);
            setElementPosition(iconDisplay, iconX, iconY);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Commit alpha values for the skin when in a disabled state.
     *
     *  @see mx.core.UIComponent#enabled
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function commitDisabled():void
    {
        alpha = hostComponent.enabled ? 1 : 0.5;
    }
    
    /**
     *  The current skin part that displays the icon.
     *  If the icon is a Class, then the iconDisplay is an instance of that class.
     *  If the icon is a DisplayObject instance, then the iconDisplay is that instance.
     *  If the icon is URL, then iconDisplay is the Group that holds the BitmapImage with that URL.
     *
     *  @see #setIcon
     *  @see #useIconStyle
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function getIconDisplay():DisplayObject
    {
        return iconHolder ? iconHolder : iconInstance as DisplayObject;
    }
    
    /**
     *  Sets the current icon for the iconDisplay skin part.
     *  The iconDisplay skin part is created/set-up on demand.
     *
     * @param icon The current icon. 
     * 
     *  @see #getIconDisplay
     *  @see #useIconStyle
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function setIcon(icon:Object):void
    {
        if (_icon == icon)
            return;
        _icon = icon;
        
        // Clean-up the iconInstance
        if (iconInstance)
        {
            if (iconHolder)
                iconHolder.removeAllElements();
            else
                this.removeChild(iconInstance as DisplayObject);
        }
        iconInstance = null;
        
        // Set-up the iconHolder
        var needsHolder:Boolean = icon && !(icon is Class) && !(icon is DisplayObject);
        if (needsHolder && !iconHolder)
        {
            // layoutContents() will set icon size no larger than it's unscaled size
            // icon will only scale down when limited by button size
            iconHolder = new Group();
            iconHolder.resizeMode = ResizeMode.SCALE;
            addChild(iconHolder);
        }
        else if (!needsHolder && iconHolder)
        {
            this.removeChild(iconHolder);
            iconHolder = null;
        }
        
        // Set-up the icon
        if (icon)
        {
            if (needsHolder)
            {
                iconInstance = new BitmapImage();
                iconInstance.source = icon;
                iconHolder.addElementAt(iconInstance as BitmapImage, 0);
            }
            else
            {
                if (icon is Class)
                    iconInstance = new (Class(icon))();
                else
                    iconInstance = icon;
                
                addChild(iconInstance as DisplayObject);
            }
        }
        
        // explicitly invalidate, since addChild/removeChild don't invalidate for us
        invalidateSize();
        invalidateDisplayList();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    protected function labelDisplay_valueCommitHandler(event:FlexEvent):void
    {
        invalidateSize();
        invalidateDisplayList();
    }
    
}
}