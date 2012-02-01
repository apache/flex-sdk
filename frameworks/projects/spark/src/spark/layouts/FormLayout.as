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
    import mx.core.mx_internal;
    
    import spark.components.FormHeading;
    import spark.components.FormItem;
    import spark.components.IFormItem;
    import spark.components.SkinnableContainer;
    import spark.components.supportClasses.GroupBase;
    import spark.layouts.supportClasses.LayoutBase;
    
    use namespace mx_internal;
    
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
        /**
         *  TODO
         */                  
        public function FormLayout()
        {
            super();
        }
        
        /**
         *  @private
         */
        private var colsMaxWidth:Vector.<Number>;
        
        //--------------------------------------------------------------------------
        //
        //  Overridden Methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         */
        override public function measure():void
        {
            super.measure();
            
            const layoutTarget:GroupBase = target;
            if (!layoutTarget)
                return;

            getColumnWidthsMax();
            
            var formWidth:Number = getColumnWidthsSum();
            
            // use measured column widths to set Form's measuredWidth
            layoutTarget.measuredWidth = Math.max(formWidth, layoutTarget.measuredWidth);
            layoutTarget.measuredMinWidth = Math.max(formWidth, layoutTarget.measuredMinWidth);
        }
        
        /**
         *  @private
         */
        override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            // TODO add logic for getting measuredWidths again
            
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            getColumnWidthsMax();
            
            var eltWidth:Number = getColumnWidthsSum();
            
            var layout:LayoutBase;
            var fiLayout:FormItemLayout;
            
            // Apply constraint columns before measuring
            const layoutTarget:GroupBase = target;
            if (!layoutTarget)
                return;
            
            const nElts:int = layoutTarget.numElements;
            var formItem:IFormItem 
            var elt:IVisualElement
            
            if (colsMaxWidth != null)
            {
                var eltHeight:Number;
                
                for(var i:int = 0; i < nElts; i++)
                {
                    elt = layoutTarget.getElementAt(i);
                    
                    if (elt is GroupBase)
                        layout = GroupBase(elt).layout;
                    else if (elt is FormItem)
                        layout = FormItem(elt).skin["layout"];
                    else if (elt is FormHeading)
                        layout = FormHeading(elt).skin["layout"];
                    else if (elt is SkinnableContainer)
                        layout = SkinnableContainer(elt).layout;
                    
                    if (layout is FormItemLayout)
                    {
                        fiLayout = layout as FormItemLayout;
                        fiLayout.setLayoutColumnWidths(colsMaxWidth);
                        
                        eltHeight = elt.getLayoutBoundsHeight(false);
                        
                        elt.setLayoutBoundsSize(eltWidth, eltHeight); 
                    }
                    
                }
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
        private function getColumnWidthsMax():void
        { 
            const layoutTarget:GroupBase = target;
            
            var layout:LayoutBase;
            var fiLayout:FormItemLayout;
                        
            const nElts:int = layoutTarget.numElements;
            var formItem:IFormItem 
            var elt:IVisualElement
            
            for(var i:int = 0; i < nElts; i++)
            {
                elt = layoutTarget.getElementAt(i);
                if (elt is GroupBase)
                    layout = GroupBase(elt).layout;
                else if (elt is FormItem)
                    layout = FormItem(elt).skin["layout"];
                else if (elt is FormHeading)
                    layout = FormHeading(elt).skin["layout"];
                else if (elt is SkinnableContainer)
                    layout = SkinnableContainer(elt).layout;
                
                if (layout is FormItemLayout)
                {
                    fiLayout = layout as FormItemLayout;
                    var cols:Vector.<Number> = fiLayout.getMeasuredColumnWidths();
                    
                    if (colsMaxWidth == null)
                    {
                        colsMaxWidth = new Vector.<Number>();
                        for (var j:int = 0; j < cols.length; j++)
                            colsMaxWidth[j] = 0;
                    }
                    
                    // TODO add logic to throw RTE if column lengths don't match
                    
                    for (var k:int = 0; k < cols.length; k++)
                    {
                        colsMaxWidth[k] = Math.max(colsMaxWidth[k], cols[k]);
                    }
                }
            }
        }
        
        /**
         *  @private
         */
        private function getColumnWidthsSum():Number
        {
            if (colsMaxWidth == null)
                return 0;
            
            var sum:Number = 0;
            for (var i:int = 0; i < colsMaxWidth.length; i++)
            {
                sum += colsMaxWidth[i];
            }
            
            return sum;
        }
    }
}
    
