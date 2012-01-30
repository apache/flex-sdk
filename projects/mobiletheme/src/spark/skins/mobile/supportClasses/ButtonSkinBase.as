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
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.geom.Matrix;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.text.TextLineMetrics;
    
    import mx.controls.ButtonLabelPlacement;
    import mx.core.IUITextField;
    import mx.core.UIComponent;
    import mx.core.UITextField;
    import mx.core.mx_internal;
    import mx.states.SetProperty;
    import mx.states.State;
    import mx.utils.ColorUtil;
    
    import spark.components.supportClasses.ButtonBase;
    import spark.skins.MobileSkin;
    
    use namespace mx_internal;
    
    /*    
    ISSUES:
    - should we support textAlign (if not, remove extra code)
    - labelPlacement a style?
    - iconClass a style?
    - need a downIconClass style? 
    - should the label be UITextField or another text class?  
    
    TODO:
    - Add labelPlacement to default.css
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
    public class ButtonSkinBase extends MobileSkin
    {	
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        public function ButtonSkinBase()
        {
            super();
        }
        
        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------
        
        private var iconClassChanged:Boolean = true;
        
        protected var textField:IUITextField;
        protected var textFieldShadow:IUITextField;      
        
        // Holds the icon
        protected var iconDisplay:DisplayObject;
        
        // TODO (jszeto) Either static consts or styles
        protected static const gap:int = 15;
        protected static const paddingLeft:int = 15;
        protected static const paddingRight:int = 15;
        protected static const paddingTop:int = 15;
        protected static const paddingBottom:int = 15;
        
        private static var TEXT_WIDTH_PADDING:Number = UITextField.TEXT_WIDTH_PADDING + 1;
        
        //--------------------------------------------------------------------------
        //
        //  Overridden properties
        //
        //--------------------------------------------------------------------------
        
        /** 
         * @copy spark.skins.spark.ApplicationSkin#hostComponent
         */
        public var hostComponent:ButtonBase; // SkinnableComponent will popuplate
        
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
            textField = IUITextField(createInFontContext(UITextField));
            textFieldShadow = IUITextField(createInFontContext(UITextField));
            
            // TODO (jszeto) Ask XD if shadow color is dependant upon text color
            textFieldShadow.setColor(0x000000);
            textFieldShadow.alpha = .20;
            
            addChild(UITextField(textFieldShadow));
            addChild(UITextField(textField));
            
            updateLabel();
            
            // SkinnableComponent doesn't notify us if we have been removed 
            // from the hostComponent, so we use a weak reference
            if (hostComponent != null) 
            { 
                hostComponent.addEventListener("contentChange", 
                    hostComponent_contentChangeHandler, 
                    false, 0, true);
            }
        }
        
        /**
         *  @private 
         */ 
        override public function styleChanged(styleProp:String):void 
        {    
            if (!styleProp || 
                styleProp == "styleName" || styleProp == "iconClass")
            {
                iconClassChanged = true;
                invalidateProperties();
            }
            
            super.styleChanged(styleProp);
        }
        
        override protected function commitProperties():void
        {
            super.commitProperties();
            
            if (iconClassChanged)
            {
                if (iconDisplay)
                    removeChild(iconDisplay);
                
                var iconClass:Class = getStyle("iconClass");
                
                if (iconClass)
                {
                    // Should be a bitmap
                    iconDisplay = new iconClass();
                    addChild(iconDisplay);
                }
                
                iconClassChanged = false;
            }
        }
        
        /**
         *  @private 
         */ 
        override protected function measure():void
        {        
            super.measure();
            
            var labelPlacement:String = getStyle("labelPlacement");
            if (labelPlacement == null)
                labelPlacement = ButtonLabelPlacement.RIGHT;
            
            var textWidth:Number = 0;
            var textHeight:Number = 0;
            var lineMetrics:TextLineMetrics;
            
            if (hostComponent && hostComponent.label != "")
            {
                lineMetrics = measureText(hostComponent.label);
                textWidth = lineMetrics.width + TEXT_WIDTH_PADDING;
                textHeight = lineMetrics.height + UITextField.TEXT_HEIGHT_PADDING;
            }
            else
            {
                lineMetrics = measureText("Wj");
                textHeight = lineMetrics.height + UITextField.TEXT_HEIGHT_PADDING;
            }
            
            var iconWidth:Number = iconDisplay ? iconDisplay.width : 0;
            var iconHeight:Number = iconDisplay ? iconDisplay.height : 0;
            var w:Number = 0;
            var h:Number = 0;
            
            if (labelPlacement == ButtonLabelPlacement.LEFT ||
                labelPlacement == ButtonLabelPlacement.RIGHT)
            {
                w = textWidth + iconWidth;
                if (textWidth && iconWidth)
                    w += gap; //getStyle("horizontalGap");
                h = Math.max(textHeight, iconHeight);
            }
            else
            {
                w = Math.max(textWidth, iconWidth);
                h = textHeight + iconHeight;
                if (textHeight && iconHeight)
                    h += gap; // getStyle("verticalGap");
            }
            
            // Add padding. !!!Need a hack here to only add padding if we don't
            // have text or icon. This is required to make small buttons (like scroll
            // arrows and numeric stepper buttons) look correct.
            if (textWidth || iconWidth)
            {
                w += paddingLeft + paddingRight; //getStyle("paddingLeft") + getStyle("paddingRight");
                h += paddingTop + paddingBottom; //getStyle("paddingTop") + getStyle("paddingBottom");
            }
            
            measuredMinWidth = measuredWidth = w;
            measuredMinHeight = measuredHeight = h;
        }
        
        /**
         *  @private 
         */ 
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {       
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
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
            
            var labelPlacement:String = getStyle("labelPlacement");
            if (labelPlacement == null)
                labelPlacement = ButtonLabelPlacement.RIGHT;
            
            var textWidth:Number = 0;
            var textHeight:Number = 0;
            
            var lineMetrics:TextLineMetrics;
            
            if (hostComponent && hostComponent.label != "")
            {
                lineMetrics = measureText(hostComponent.label);
                textWidth = lineMetrics.width + TEXT_WIDTH_PADDING;
                textHeight = lineMetrics.height + UITextField.TEXT_HEIGHT_PADDING;
            }
            else
            {
                lineMetrics = measureText("Wj");
                textHeight = lineMetrics.height + UITextField.TEXT_HEIGHT_PADDING;
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
            
            if (iconDisplay)
            {
                iconWidth = iconDisplay.width;
                iconHeight = iconDisplay.height;
            }
            
            if (labelPlacement == ButtonLabelPlacement.LEFT ||
                labelPlacement == ButtonLabelPlacement.RIGHT)
            {
                horizontalGap = gap;
                
                if (iconWidth == 0 || textWidth == 0)
                    horizontalGap = 0;
                
                if (textWidth > 0)
                {
                    labelWidth = 
                        Math.max(Math.min(viewWidth - iconWidth - horizontalGap -
                            paddingLeft - paddingRight, textWidth), 0);
                }
                else
                {
                    labelWidth = 0;
                }
                labelHeight = Math.min(viewHeight, textHeight);
                
                if (textAlign == "left")
                {
                    labelX += paddingLeft;
                }
                else if (textAlign == "right")
                {
                    labelX += (viewWidth - labelWidth - iconWidth - 
                        horizontalGap - paddingRight);
                }
                else // "center" -- default value
                {
                    labelX += ((viewWidth - labelWidth - iconWidth - 
                        horizontalGap - paddingLeft - paddingRight) / 2) + paddingLeft;
                }
                
                if (labelPlacement == ButtonLabelPlacement.RIGHT)
                {
                    labelX += iconWidth + horizontalGap;
                    iconX = labelX - (iconWidth + horizontalGap);
                }
                else
                {
                    iconX  = labelX + labelWidth + horizontalGap; 
                }
                
                iconY  = ((viewHeight - iconHeight - paddingTop - paddingBottom) / 2) + paddingTop;
                labelY = ((viewHeight - labelHeight - paddingTop - paddingBottom) / 2) + paddingTop;
            }
            else
            {
                verticalGap = gap;
                
                if (iconHeight == 0 || !hostComponent || hostComponent.label == "")
                    verticalGap = 0;
                
                if (textWidth > 0)
                {
                    labelWidth = Math.max(viewWidth - paddingLeft - paddingRight, 0);
                    labelHeight =
                        Math.min(viewHeight - iconHeight - paddingTop - paddingBottom - verticalGap, textHeight);
                }
                else
                {
                    labelWidth = 0;
                    labelHeight = 0;
                }
                
                labelX = paddingLeft;
                
                if (textAlign == "left")
                {
                    iconX += paddingLeft;
                }
                else if (textAlign == "right")
                {
                    iconX += Math.max(viewWidth - iconWidth - paddingRight, paddingLeft);
                }
                else
                {
                    iconX += ((viewWidth - iconWidth - paddingLeft - paddingRight) / 2) + paddingLeft;
                }
                
                if (labelPlacement == ButtonLabelPlacement.TOP)
                {
                    labelY += ((viewHeight - labelHeight - iconHeight - 
                        paddingTop - paddingBottom - verticalGap) / 2) + paddingTop;
                    iconY += labelY + labelHeight + verticalGap;
                }
                else
                {
                    iconY += ((viewHeight - labelHeight - iconHeight - 
                        paddingTop - paddingBottom - verticalGap) / 2) + paddingTop;
                    labelY += iconY + iconHeight + verticalGap;
                }
            }
            
            textField.x = Math.round(labelX);
            textField.y = Math.round(labelY);
            textField.height = labelHeight;
            textField.width = labelWidth;
            
            textFieldShadow.x = Math.round(labelX);
            textFieldShadow.y = Math.round(labelY + 1);
            textFieldShadow.height = labelHeight;
            textFieldShadow.width = labelWidth;
            
            if (iconDisplay)
            {                
                iconDisplay.x = Math.round(iconX);
                iconDisplay.y = Math.round(iconY);
            }        
        }
        
        //--------------------------------------------------------------------------
        //
        //  Methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private 
         */ 
        private function hostComponent_contentChangeHandler(event:Event):void 
        {
            updateLabel();
        }
        
        /**
         *  @private 
         */ 
        private function updateLabel():void 
        {
            if (hostComponent != null && textField) 
            {
                textField.text = hostComponent.label;
                textFieldShadow.text = hostComponent.label;
                invalidateSize();
            }
        }
        

        
    }
}