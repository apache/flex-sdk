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

        setStyle("textAlign", "center");
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  iconDisplay skin part.
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
     */
    public var labelDisplay:StyleableTextField;

    /**
     *  If true, then create the iconDisplay using the icon style
     *
     *  @default true
     */
    protected var useIconStyle:Boolean = true;

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
     *  Left padding for icon or labelDisplay
     */
    protected var layoutPaddingLeft:int;

    /**
     *  Right padding for icon or labelDisplay
     */
    protected var layoutPaddingRight:int;

    /**
     *  Top padding for icon or labelDisplay
     */
    protected var layoutPaddingTop:int;

    /**
     *  Bottom padding for icon or labelDisplay
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
        var iconDisplay:DisplayObject = getIconDisplay();

        // reset text if it was truncated before.
        if (hostComponent && labelDisplay.isTruncated)
            labelDisplay.text = hostComponent.label;
        labelDisplay.commitStyles();

        if (labelDisplay.text)
        {
            // +1 originates from MX Button without explaination
            var textSize:Point = labelDisplay.measuredTextSize;
            labelWidth = textSize.x + 1;
            labelHeight = textSize.y;
        }
        else if (!iconDisplay)
        {
            // only get empty label height when there no icon is present
            labelHeight = measureText("Wj").height + UITextField.TEXT_HEIGHT_PADDING;
        }
        
        var w:Number = layoutPaddingLeft + layoutPaddingRight;
        var h:Number = layoutPaddingTop + layoutPaddingBottom;
        
        var iconWidth:Number = 0;
        var iconHeight:Number = 0;

        if (iconDisplay is ILayoutElement)
        {
            // why postLayoutTransform=false vs. true in desktop skin?
            iconWidth = ILayoutElement(iconDisplay).getPreferredBoundsWidth(false);
            iconHeight = ILayoutElement(iconDisplay).getPreferredBoundsHeight(false);
        }
        else if (iconDisplay)
        {
            iconWidth = iconDisplay.width;
            iconHeight = iconDisplay.height;
        }
        
        var iconPlacement:String = getStyle("iconPlacement");

        if (iconPlacement == IconPlacement.LEFT ||
            iconPlacement == IconPlacement.RIGHT)
        {
            w += labelWidth + iconWidth;
            if (labelWidth && iconWidth)
                w += layoutGap;
            h += Math.max(labelHeight, iconHeight);
        }
        else
        {
            w += Math.max(labelWidth, iconWidth);
            h += labelHeight + iconHeight;
            if (labelHeight && iconHeight)
                h += layoutGap;
        }

        // minimums
        measuredMinWidth = w
        measuredMinHeight = h;

        // measured sizes are no smaller than spec for touch-based sizes
        measuredWidth = Math.max(w, layoutMeasuredWidth);
        measuredHeight = Math.max(h, layoutMeasuredHeight);
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        var labelWidth:Number = 0;
        var labelHeight:Number = 0;

        var labelX:Number = 0;
        var labelY:Number = 0;

        var iconWidth:Number = 0;
        var iconHeight:Number = 0;

        var iconX:Number = 0;
        var iconY:Number = 0;

        var horizontalGap:Number = 0;
        var verticalGap:Number = 0;

        var iconPlacement:String = getStyle("iconPlacement");

        var textWidth:Number = 0;
        var textHeight:Number = 0;
        var textDescent:Number = 0;

        // reset text if it was truncated before.
        if (hostComponent && labelDisplay.isTruncated)
            labelDisplay.text = hostComponent.label;
        labelDisplay.commitStyles();

        if (hostComponent && hostComponent.label != "")
        {
            // +1 originates from MX Button without explaination
            var textSize:Point = labelDisplay.measuredTextSize;
            textWidth = textSize.x + 1;
            textHeight = textSize.y;
            textDescent = labelDisplay.getLineMetrics(0).descent;
        }
        else
        {
            var metrics:TextLineMetrics = measureText("Wj");
            textHeight = metrics.height + UITextField.TEXT_HEIGHT_PADDING;
            textDescent = metrics.descent;
        }

        var textAlign:String = "center"; // getStyle("textAlign");
        // Map new Spark values that might be set in a selector
        // affecting both Halo and Spark components.
        /*if (textAlign == "start")
        textAlign = TextFormatAlign.LEFT;
        else if (textAlign == "end")
        textAlign = TextFormatAlign.RIGHT;*/

        var viewWidth:Number = unscaledWidth;
        var viewHeight:Number = unscaledHeight;

        var iconDisplay:DisplayObject = getIconDisplay();
        if (iconDisplay)
        {
            if (iconDisplay is ILayoutElement)
            {
                iconWidth = ILayoutElement(iconDisplay).getPreferredBoundsWidth();
                iconHeight = ILayoutElement(iconDisplay).getPreferredBoundsHeight();
            }
            else
            {
                iconWidth = iconDisplay.width;
                iconHeight = iconDisplay.height;
            }
        }

        if (iconPlacement == IconPlacement.LEFT ||
            iconPlacement == IconPlacement.RIGHT)
        {
            horizontalGap = layoutGap;

            if (iconWidth == 0 || textWidth == 0)
                horizontalGap = 0;

            if (textWidth > 0)
            {
                labelWidth =
                    Math.max(Math.min(viewWidth - iconWidth - horizontalGap -
                        layoutPaddingLeft - layoutPaddingRight, textWidth), 0);
            }
            else
            {
                labelWidth = 0;
            }

            // button viewHeight may be smaller than the labelDisplay textHeight
            labelHeight = Math.min(viewHeight, textHeight);

            if (textAlign == "left")
            {
                labelX += layoutPaddingLeft;
            }
            else if (textAlign == "right")
            {
                labelX += (viewWidth - labelWidth - iconWidth -
                    horizontalGap - layoutPaddingRight);
            }
            else // "center" -- default value
            {
                labelX += ((viewWidth - labelWidth - iconWidth -
                    horizontalGap - layoutPaddingLeft - layoutPaddingRight) / 2) + layoutPaddingLeft;
            }

            if (iconPlacement == IconPlacement.LEFT)
            {
                labelX += iconWidth + horizontalGap;
                iconX = labelX - (iconWidth + horizontalGap);
            }
            else
            {
                iconX  = labelX + labelWidth + horizontalGap;
            }

            iconY = ((viewHeight - iconHeight - layoutPaddingTop - layoutPaddingBottom) / 2) + layoutPaddingTop;

            // vertial center labelDisplay based on ascent
            // text "height" = min(measuredTextSize.y, viewHeight) - descent + gutter
            labelY = ((viewHeight - labelHeight + textDescent - StyleableTextField.TEXT_HEIGHT_PADDING) / 2);
        }
        else
        {
            verticalGap = layoutGap;

            if (iconHeight == 0 || !hostComponent || hostComponent.label == "")
                verticalGap = 0;

            if (textWidth > 0)
            {
                // label width is constrained to left and right edges
                labelWidth = Math.max(viewWidth - layoutPaddingLeft - layoutPaddingRight, 0);

                // label height is constrained to available height after icon, padding and gap heights
                labelHeight = Math.max(viewHeight - iconHeight - layoutPaddingTop - layoutPaddingBottom - verticalGap, 0);
                labelHeight = Math.min(labelHeight, textHeight);
            }
            else
            {
                labelWidth = 0;
                labelHeight = 0;
            }

            labelX = layoutPaddingLeft;

            if (textAlign == "left")
            {
                iconX += layoutPaddingLeft;
            }
            else if (textAlign == "right")
            {
                iconX += Math.max(viewWidth - iconWidth - layoutPaddingRight, layoutPaddingLeft);
            }
            else
            {
                iconX += ((viewWidth - iconWidth - layoutPaddingLeft - layoutPaddingRight) / 2) + layoutPaddingLeft;
            }

            if (iconPlacement == IconPlacement.BOTTOM)
            {
                labelY += ((viewHeight - labelHeight - iconHeight -
                    layoutPaddingTop - layoutPaddingBottom - verticalGap) / 2) + layoutPaddingTop;
                iconY += labelY + labelHeight + verticalGap;
            }
            else
            {
                // label bottom is constrained by layoutPaddingBottom
                labelY = viewHeight - layoutPaddingBottom - labelHeight;

                // icon is vertically centered in the space above the label
                iconY = Math.max(((labelY - iconHeight - verticalGap) / 2), layoutPaddingTop);
            }
        }

        labelX = Math.max(0, Math.round(labelX));
        labelY = Math.max(0, Math.round(labelY));

        labelDisplay.commitStyles();
        setElementSize(labelDisplay, labelWidth, labelHeight);
        setElementPosition(labelDisplay, labelX, labelY);

        if (textWidth > labelWidth)
        {
            labelDisplay.truncateToFit();
        }

        if (iconDisplay)
        {
            setElementSize(iconDisplay, iconWidth, iconHeight);
            setElementPosition(iconDisplay, Math.max(0, Math.round(iconX)), Math.max(0, Math.round(iconY)));
        }

        // draw chromeColor after parts have been positioned
        super.updateDisplayList(unscaledWidth, unscaledHeight);
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
     */
    protected function getIconDisplay():DisplayObject
    {
        return iconHolder ? iconHolder : iconInstance as DisplayObject;
    }

    /**
     *  Sets the current icon for the iconDisplay skin part.
     *  The iconDisplay skin part is created/set-up on demand.
     *
     *  @see #getIconDisplay
     *  @see #useIconStyle
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
            iconHolder = new Group();
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