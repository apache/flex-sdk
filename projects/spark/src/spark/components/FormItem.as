package spark.components
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
        
    import mx.containers.Canvas;
    import mx.containers.utilityClasses.ConstraintColumn;
    import mx.core.IVisualElement;
    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;
        
    /**
     *  TODO
     *  - Remove canvasLayout skin part once FormItemLayout is ready
     * 
     * 
     * 
     *  ISSUES:
     *  - Consider turning helpText into a helpContentGroup to allow arbitrary content
     *  
     * 
     */ 

    
    /**
     *  FormItem represents an item in a Form. It typically has a label, an optional indicator and a set of input components.
     */
    public class FormItem extends SkinnableContainer implements IFormItem
    {
        
        public function FormItem()
        {
            super();
        }
        
        //--------------------------------------------------------------------------
        //
        //  Skin Parts
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Displays this FormItem's label.
         */
        [Bindable] // compatability with Halo FormItem itemLabel property
        [SkinPart(required="false")]
        public var labelElement:Label;
        
        /**
         *  A reference to the visual element that indicates that this FormItem's value is required.
         * 
         *  <p>Typically the skin only includes the required indicator in the layout for states
         *  "required" and "disabledAndRequired".</p>
         */
        [SkinPart(required="false")]
        public var indicatorElement:IVisualElement;
        
        /**
         *  A reference to the visual element that displays the FormItem's numberLabel.
         */
        [SkinPart(required="false")]
        public var numberLabelElement:Label;
        
        /**
         *  A reference to the visual element that display the FormItem's helpText.
         */
        [SkinPart(required="false")]
        public var helpTextElement:RichText;
        
        // TODO Remove once we have a proper FormItemLayout
        [SkinPart(required="false")]
        public var canvasLayout:Canvas;
        
        //--------------------------------------------------------------------------
        //
        //  Properties 
        //
        //--------------------------------------------------------------------------
        
        //----------------------------------
        //  resourceManager
        //----------------------------------
        
        /**
         *  @private
         *  Used for accessing localized Error messages.
         */
        private static function get resourceManager():IResourceManager
        {
            return ResourceManager.getInstance();
        }
 
        //----------------------------------
        //  measuredColumnWidths
        //----------------------------------
        
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
        
        
        
        //----------------------------------
        //  layoutColumnWidths
        //----------------------------------
        
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
        
        
        //----------------------------------
        //  helpText
        //----------------------------------
        
        private var _helpText:String = "";
        private var helpTextChanged:Boolean = false;
        
        [Bindable("helpTextChanged")]
        [Inspectable(category="General", defaultValue="")]
        
        /**
         *  Text that provides a description of the form item or instructions for filling it out.   
         * 
         *  @default ""
         */
        public function get helpText():String
        {
            return _helpText;
        }
        
        /**
         *  @private
         */
        public function set helpText(value:String):void
        {
            if (_helpText == value)
                return;
            
            _helpText = value;
            helpTextChanged = true;
            invalidateProperties();
        }
        
        //----------------------------------
        //  label
        //----------------------------------
        
        private var _label:String = "";
        private var labelChanged:Boolean = false;
        
        [Bindable("labelChanged")]
        [Inspectable(category="General", defaultValue="")]
        
        /**
         *  Text that names the form content. For example, a FormItem to 
         *  select a state might have a form label of "State"  
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
        
        //----------------------------------
        //  numberLabel
        //----------------------------------
        
        private var _numberLabel:String = "";
        private var numberLabelChanged:Boolean = false;
        
        [Bindable("numberLabelChanged")]
        [Inspectable(category="General", defaultValue="")]
        
        /**
         *  The number of the form item if the form creates a 
         *  numbered list out of the form items  
         * 
         *  @default ""
         */
        public function get numberLabel():String
        {
            return _numberLabel;
        }
        
        /**
         *  @private
         */
        public function set numberLabel(value:String):void
        {
            if (_numberLabel == value)
                return;
            
            _numberLabel = value;
            numberLabelChanged = true;
            invalidateProperties();
        }
        
        //----------------------------------
        //  required
        //----------------------------------
        
        private var _required:Boolean = false;
        
        [Bindable("requiredChanged")]
        [Inspectable(category="General", defaultValue="false")]
        
        /**
         *  If <code>true</code>, puts the FormItem skin into the
         *  <code>required</code> state. By default, this displays 
         *  an indicator that the FormItem children require user input.
         *  If <code>false</code>, indicator is not displayed.
         *
         *  <p>This property controls skin's state only.
         *  You must attach a validator to the children
         *  if you require input validation.</p>
         *
         *  @default false
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4.5
         */
        public function get required():Boolean
        {
            return _required;
        }
        
        /**
         *  @private
         */
        public function set required(value:Boolean):void
        {
            if (value == _required)
                return;
            
            _required = value;
            invalidateSkinState();
        }
       
        
        
        
        //----------------------------------
        //  baselinePosition
        //----------------------------------
        
        /**
         *  @private
         */
        override public function get baselinePosition():Number
        {
            return getBaselinePositionForPart(labelElement);
        }     
        
        //--------------------------------------------------------------------------
        //
        //  Overridden Methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         */
        override protected function commitProperties():void
        {
            super.commitProperties();
            
            if (labelChanged)
            {
                labelChanged = false;
                if (labelElement)
                    labelElement.text = label;
                dispatchEvent(new Event("labelChanged"));
            }
            
            if (numberLabelChanged)
            {
                numberLabelChanged = false;
                if (numberLabelElement)
                    numberLabelElement.text = numberLabel;
                dispatchEvent(new Event("numberLabelChanged"));
            }
            
            if (helpTextChanged)
            {
                helpTextChanged = false;
                if (helpTextElement)
                    helpTextElement.text = helpText;
                dispatchEvent(new Event("helpTextChanged"));
            }
            
            if (layoutColumnWidthsChanged)
            {
                layoutColumnWidthsChanged = false;
                if (canvasLayout)
                    applyConstraintColumns(_layoutColumnWidths);
            }
        }    
        
        /**
         *  @private
         */
        override protected function getCurrentSkinState():String
        {
            if(required && (enabled == false))
                return "requiredAndDisabled";
            if (required)
                return "required";
            return "normal";
        }
        
        /**
         *  @private
         */
        override protected function partAdded(partName:String, instance:Object) : void
        {
            super.partAdded(partName, instance);
            
            if (instance == labelElement)
                labelElement.text = label;
            else if (instance == numberLabelElement)
                numberLabelElement.text = numberLabel;
            else if (instance == helpTextElement)
                helpTextElement.text = helpText;
            else if (instance == canvasLayout)
                applyConstraintColumns(_layoutColumnWidths);
        }
        
        /**
         *  @private
         */
        override public function styleChanged(styleProp:String):void
        {
            super.styleChanged(styleProp);
            
            var allStyles:Boolean = (styleProp == null) || (styleProp == "styleName"); 
            if (allStyles || (layoutStyles.indexOf(styleProp) != -1))
            {
                invalidateSize();
                invalidateDisplayList();
            }
        }
        
        private static const layoutStyles:Array = 
            ["indicatorGap", "labelWidth", "paddingBottom", "paddingTop", "paddingLeft", "paddingRight"];
        
        
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