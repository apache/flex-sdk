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
        /**
         *  TODO
         */                  
        public function FormLayout()
        {
            super();
        }
        
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
                    
                }
            }
            
            var columnMaxWidths:Vector.<Number> = colsMaxWidth.slice(0);
            
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
         }
    }
}
    
