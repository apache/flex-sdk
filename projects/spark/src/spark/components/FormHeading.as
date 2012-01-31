package spark.components
{
    
    import mx.containers.Canvas;
    import mx.containers.utilityClasses.ConstraintColumn;
    
    import spark.components.supportClasses.SkinnableComponent;
    import spark.components.supportClasses.TextBase;

    /**
     *  TODO
     *  - Remove implements IFormItem  
     *  - Remove canvasLayout skin part once FormItemLayout is ready
     *  - Remove measuredColumnWidths and layoutColumnWidths once 
     *    FormItemLayout and FormLayout are ready
     * 
     * 
     *  ISSUES:
     *  - Ideally this would subclass Label, but Label is not a SkinnableComponent
     *  - Should we use text or label property? (PARB says label)
     *  - What if we don't implement column spanning?
     * 
     */ 
    
    /**
     * A simple form item component which contains a label. It is used to 
     * provide a heading to a set of form items. It is basically a FormItem 
     * without any content, sequenceLabel or helpContent. Since it is 
     * a separate class from FormItem, it has a default style 
     * (larger font size) and its own skin.
     */ 
    public class FormHeading extends SkinnableComponent implements IFormItem
    {
        public function FormHeading()
        {
        }
        
        //--------------------------------------------------------------------------
        //
        //  Skin Parts
        //
        //--------------------------------------------------------------------------
        
        /**
         *   A reference to the visual element that displays this FormItem's label.
         */
        [Bindable]
        [SkinPart(required="false")]
        public var labelDisplay:TextBase;
        
        
        [SkinPart(required="false")]
        public var canvasLayout:Canvas;
        
        private var _measuredColumnWidths:Vector.<Number>;
        //private var measuredColumnWidthsChanged:Boolean = false;
        
        /**
         *  Used by layout to get the measured column widths
         */
        public function set measuredColumnWidths(value:Vector.<Number>):void
        {
            _measuredColumnWidths = value;
            /*measuredColumnWidthsChanged = true;
            invalidateProperties();*/
        }
        
        public function get measuredColumnWidths():Vector.<Number>
        {
            // TODO For now, just return the canvas's constraintColumns
            var measuredCols:Vector.<Number> = new Vector.<Number>;
            var columns:Array = canvasLayout.constraintColumns;
            
            for (var i:int = 0; i < columns.length; i++)
            {
                var column:ConstraintColumn = columns[i];
                if (columns[i] != undefined)
                    measuredCols.push(columns[i].width);
            } 
            
            return measuredCols;
            //return _measuredColumnWidths;
        }
        
        private var _layoutColumnWidths:Vector.<Number>;
        private var layoutColumnWidthsChanged:Boolean = false;
        
        /**
         *  Used by layout to set the column widths
         */
        public function set layoutColumnWidths(value:Vector.<Number>):void
        {
            _layoutColumnWidths = value;
            layoutColumnWidthsChanged = true;
            invalidateProperties();
        }
        
        public function get layoutColumnWidths():Vector.<Number>
        {
            return _layoutColumnWidths;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Properties 
        //
        //--------------------------------------------------------------------------
        
        //----------------------------------
        //  label
        //----------------------------------
        
        private var _label:String = "";
        private var labelChanged:Boolean = false;
        
        [Bindable("labelChanged")]
        [Inspectable(category="General", defaultValue="")]
        
        /**
         *  Text to display in the FormHeading 
         * 
         *  @default ""
         */
        public function get label():String
        {
            return _label;
        }
        
        /**
         *  @private
         */
        public function set label(value:String):void
        {
            if (_label == value)
                return;
            
            _label = value;
            labelChanged = true;
            invalidateProperties();
        }
        
        //--------------------------------------------------------------------------
        //
        //  Overridden Methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         */
        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);
            
            if (instance == labelDisplay)
                labelDisplay.text = label;
        }
        
        /**
         *  @private
         */
        override protected function commitProperties():void
        {
            super.commitProperties();
            
            if (layoutColumnWidthsChanged)
            {
                layoutColumnWidthsChanged = false;
                if (canvasLayout)
                    applyConstraintColumns(_layoutColumnWidths);
            }
            if (labelChanged)
            {
                labelChanged = false;
                if (labelDisplay)
                    labelDisplay.text = label;
            }
        }
        
        // TODO Remove once we switch from Canvas to FormItemLayout
        private function applyConstraintColumns(columns:Vector.<Number>):void
        {
            if (!columns)
                return;
            
            // TODO apply columns to canvasLayout
            if (columns.length != canvasLayout.constraintColumns.length)
            {
                trace("FormItem.applyConstraintColumns lengths don't match");
                return;
            }
            
            
            for (var i:int = 0; i < columns.length; i++)
            {
                var column:ConstraintColumn = canvasLayout.constraintColumns[i];
                if (columns[i] != undefined)
                    column.width = columns[i];
                //column.setActualWidth(columns[i]);
            }
        }
    }
}