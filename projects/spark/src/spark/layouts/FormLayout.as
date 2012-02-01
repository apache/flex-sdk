package spark.layouts
{
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
    
    import mx.containers.utilityClasses.ConstraintColumn;
    import mx.core.IVisualElement;
    import mx.core.UIComponent;
    
    import spark.components.IFormItem;
    import spark.components.supportClasses.GroupBase;
    
    /**
     *  The default layout for Spark Form skins.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public class FormLayout extends VerticalLayout
    {
                
        public function FormLayout()
        {
            super();
        }
        
        private var columnMaxWidths:Vector.<Number>;
        
        //----------------------------------
        //  constraintColumns
        //----------------------------------
        
        private var _constraintColumns:Array;
        private var constraintColumnsChanged:Boolean = false;
        
        [Bindable("constraintColumnsChanged")]
        [Inspectable(category="General", defaultValue="")]
        
        /**
         * 
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 3
         */
        public function get constraintColumns():Array
        {
            return _constraintColumns;
        }
        
        /**
         *  @private
         */
        public function set constraintColumns(value:Array):void
        {
            if (_constraintColumns == value)
                return;
            
            _constraintColumns = value;
            constraintColumnsChanged = true;
            invalidateTargetSizeAndDisplayList();
        }
        
        /**
         *  @private
         *  If the style's value is undefined or NaN for the layout target, return 0.
         */
        private static function getStyleNumericValue(c:UIComponent, styleName:String):Number
        {
            const n:Number =  Number(c.getStyle(styleName));  // Number(undefined) => NaN
            return (isNaN(n)) ? 0 : n;
        }
        
        private function invalidateTargetSizeAndDisplayList():void
        {
            var g:GroupBase = target;
            if (!g)
                return;
            
            g.invalidateSize();
            g.invalidateDisplayList();
        }
        
        /**
         *  @private
         *  The layoutTarget is assumed to be the contentGroup, it's owner is the skin,
         *  and the skin's hostComponent is the Form.
         */
        /*private static function getForm(layoutTarget:GroupBase):Form
        {
            const skin:Skin = layoutTarget.owner as Skin;
            return (skin) ? Object(skin).hostComponent as Form : null;
            
        }*/
        
        /**
         *  @private
         */
        override public function measure():void
        {
            
            var colsMaxWidth:Vector.<Number>;
            
            
            
            // Apply constraint columns before measuring
            const layoutTarget:GroupBase = target;
            if (!layoutTarget)
                return;
            
            const nElts:int = layoutTarget.numElements;
            var formItem:IFormItem 
            var elt:IVisualElement
            
            for(var i:int = 0; i < nElts; i++)
            {
                elt = layoutTarget.getElementAt(i);
                if (elt is IFormItem)
                {
                    formItem = IFormItem(elt);
                    var cols:Vector.<Number> = formItem.measuredColumnWidths;
                    
                    if (colsMaxWidth == null)
                    {
                        colsMaxWidth = new Vector.<Number>();
                        for (var j:int = 0; j < cols.length; j++)
                            colsMaxWidth[j] = 0;
                    }
                    
                    for (var k:int = 0; k < cols.length; k++)
                    {
                        colsMaxWidth[k] = Math.max(colsMaxWidth[k], cols[k]);
                    }
                    
                    //formItem.constraintColumns = constraintColumns;
                }
            }
            
            columnMaxWidths = colsMaxWidth.slice(0);
            
            for(i = 0; i < nElts; i++)
            {
                elt = layoutTarget.getElementAt(i);
                if (elt is IFormItem)
                {
                    formItem = IFormItem(elt);
                    formItem.layoutColumnWidths = columnMaxWidths;
                }
            }
            super.measure();
            
            /*const layoutTarget:GroupBase = target;
            if (!layoutTarget)
                return;
            
            var maxLabelColumnW:Number = 0;
            var maxIndicatorColumnW:Number = 0;
            var maxContentColumnW:Number = 0;
            
            const nElts:int = layoutTarget.numElements;
            for(var i:int = 0; i < nElts; i++)
            {
                var elt:IVisualElement = layoutTarget.getElementAt(i);
                if (elt is FormItem)
                {
                    var formItem:FormItem = FormItem(elt);
                    var paddingLeft:Number = getStyleNumericValue(formItem, "paddingLeft");
                    var labelColumnW:Number = formItem.labelColumnWidth + paddingLeft;
                    var indicatorColumnW:Number = formItem.indicatorColumnWidth;
                    var totalW:Number = formItem.getPreferredBoundsWidth();
                    
                    maxLabelColumnW = Math.max(maxLabelColumnW, labelColumnW); 
                    maxIndicatorColumnW = Math.max(maxIndicatorColumnW, indicatorColumnW); 
                    maxContentColumnW = Math.max(maxContentColumnW, totalW - indicatorColumnW - labelColumnW);
                }
                else if (elt is FormHeading)
                    maxContentColumnW = Math.max(maxContentColumnW, elt.getPreferredBoundsWidth());
            }
            
            maxLabelColumnW = Math.ceil(maxLabelColumnW);
            maxIndicatorColumnW = Math.ceil(maxIndicatorColumnW);
            maxContentColumnW = Math.ceil(maxContentColumnW);
            
            var superMeasuredW:Number = layoutTarget.measuredWidth;
            var formMeasuredW:Number = maxLabelColumnW + maxIndicatorColumnW + maxContentColumnW;
            layoutTarget.measuredWidth = Math.max(superMeasuredW, formMeasuredW); 
            layoutTarget.measuredMinWidth = layoutTarget.measuredWidth;
            
            const form:Form = getForm(layoutTarget);
            if (form)
            {
                form.labelColumnWidth = maxLabelColumnW;
                form.indicatorColumnWidth = maxIndicatorColumnW;
            }*/
        }
        
        /**
         *  @private
         */
        override public function updateDisplayList(width:Number, height:Number):void
        {
            super.updateDisplayList(width, height);
            
            /*const layoutTarget:GroupBase = target;
            if (!layoutTarget)
                return;
            
            const form:Form = getForm(layoutTarget);
            if (!form)
                return;
            
            const nElts:int = layoutTarget.numElements;
            const contentColumnLeft:Number = form.labelColumnWidth + form.indicatorColumnWidth;
            for(var i:int = 0; i < nElts; i++)
            {
                var formHeading:FormHeading = layoutTarget.getElementAt(i) as FormHeading;
                if (!formHeading)
                    continue;
                
                var labelDisplay:IVisualElement = formHeading.labelDisplay;
                if (labelDisplay)
                {
                    labelDisplay.setLayoutBoundsSize(NaN, NaN);  // preferred size
                    labelDisplay.setLayoutBoundsPosition(contentColumnLeft, labelDisplay.getLayoutBoundsY());
                }
            }*/
        }
    }
}
    
