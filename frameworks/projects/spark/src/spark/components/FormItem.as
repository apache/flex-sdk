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
    import mx.core.IDeferredInstance;
    import mx.core.IVisualElement;
    import mx.core.UIComponent;
    import mx.events.FlexEvent;
    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;
    
    import spark.components.supportClasses.TextBase;
    import spark.events.ElementExistenceEvent;
        
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
     *  SkinnableContainer with content and multiple properties. The FormItem's children 
     *  are the content and are placed in the contentGroup skin part. The FormItem 
     *  container defines a number of skin parts, including labelDisplay, 
     *  sequenceLabelDisplay, and helpContentGroup. The content of these skin parts are 
     *  specified in order by the label, sequenceLabel and helpContent properties.     
     */
    public class FormItem extends SkinnableContainer implements IFormItem
    {
        
        public function FormItem()
        {
            super();
            addEventListener(spark.events.ElementExistenceEvent.ELEMENT_ADD, elementAddHandler);
            addEventListener(spark.events.ElementExistenceEvent.ELEMENT_REMOVE, elementRemoveHandler);
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
        public var labelDisplay:TextBase;
                
        /**
         *  A reference to the visual element that displays the FormItem's sequenceLabel.
         */
        [SkinPart(required="false")]
        public var sequenceLabelDisplay:TextBase;
        
        
        [SkinPart(required="false")]
        public var helpContentGroup:Group;
        
        /**
         *  A reference to the visual element that display the FormItem's error strings.
         */
        [SkinPart(required="false")]
        public var errorTextDisplay:TextBase;
        
        // TODO Remove once we have a proper FormItemLayout
        [SkinPart(required="false")]
        public var canvasLayout:Canvas;
        
        //--------------------------------------------------------------------------
        //
        //  Properties 
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Each vector item contains the error string from a content element. 
         *  If none of the content elements are invalid, then the vector will 
         *  be empty. 
         */ 
        
        [Bindable(event="elementErrorStringsChanged")]
        public var elementErrorStrings:Vector.<String> = new Vector.<String>;
        
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
        
        
        private var _helpContentFactory:IDeferredInstance; 
        private var helpContentFactoryChanged:Boolean = false;
        
        public function set helpContent(value:IDeferredInstance):void
        {
            _helpContentFactory = value;
            helpContentFactoryChanged = true;
            invalidateProperties();
        }
        
        public function get helpContent():IDeferredInstance
        {
            return _helpContentFactory;
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
        //  sequenceLabel
        //----------------------------------
        
        private var _sequenceLabel:String = "";
        private var sequenceLabelChanged:Boolean = false;
        
        [Bindable("sequenceLabelChanged")]
        [Inspectable(category="General", defaultValue="")]
        
        /**
         *  The number of the form item if the form creates a 
         *  numbered list out of the form items  
         * 
         *  @default ""
         */
        public function get sequenceLabel():String
        {
            return _sequenceLabel;
        }
        
        /**
         *  @private
         */
        public function set sequenceLabel(value:String):void
        {
            if (_sequenceLabel == value)
                return;
            
            _sequenceLabel = value;
            sequenceLabelChanged = true;
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
            return getBaselinePositionForPart(labelDisplay);
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
                if (labelDisplay)
                    labelDisplay.text = label;
                dispatchEvent(new Event("labelChanged"));
            }
            
            if (sequenceLabelChanged)
            {
                sequenceLabelChanged = false;
                if (sequenceLabelDisplay)
                    sequenceLabelDisplay.text = sequenceLabel;
                dispatchEvent(new Event("sequenceLabelChanged"));
            }
            
            if (layoutColumnWidthsChanged)
            {
                layoutColumnWidthsChanged = false;
                if (canvasLayout)
                    applyConstraintColumns(_layoutColumnWidths);
            }
            
            createHelpContent();
        }    
        
        /**
         *  @private
         */
        override protected function getCurrentSkinState():String
        {
            if (elementErrorStrings.length > 0)
                return "error";
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
            
            if (instance == labelDisplay)
                labelDisplay.text = label;
            else if (instance == sequenceLabelDisplay)
                sequenceLabelDisplay.text = sequenceLabel;
            else if (instance == canvasLayout)
                applyConstraintColumns(_layoutColumnWidths);
            else if (instance == errorTextDisplay)
                applyErrorText();
            else if (instance == helpContentGroup)
                createHelpContent();
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
        
        public function elementAddHandler(event:ElementExistenceEvent):void
        {
            var uicElt:UIComponent = event.element as UIComponent;
            
            if (uicElt)
            {
                uicElt.addEventListener(FlexEvent.VALID, element_validHandler);
                uicElt.addEventListener(FlexEvent.INVALID, element_invalidHandler);
                uicElt.showErrorSkin = true;
                uicElt.showErrorTip = false;
            }
        }
        
        public function elementRemoveHandler(event:ElementExistenceEvent):void
        {
            var uicElt:UIComponent = event.element as UIComponent;
            
            if (uicElt)
            {
                uicElt.removeEventListener(FlexEvent.VALID, element_validHandler);
                uicElt.removeEventListener(FlexEvent.INVALID, element_invalidHandler);
                uicElt.showErrorSkin = true;
                uicElt.showErrorTip = true;
            }
        }
        
        protected function element_validHandler(event:FlexEvent):void
        {
            // update error string
            updateErrorString();
        }
        
        protected function element_invalidHandler(event:FlexEvent):void
        {
            // update error string
            updateErrorString();
        }
        
        private function updateErrorString():void
        {
            var uicElt:UIComponent;
            elementErrorStrings = new Vector.<String>;
            
            for (var i:int = 0; i < numElements; i++)
            {
                uicElt = getElementAt(i) as UIComponent;
                
                if (uicElt)
                {
                    if (uicElt.errorString != "")
                    {
                        elementErrorStrings.push(uicElt.errorString);
                    }
                }
            }
            
            invalidateSkinState();
            
            applyErrorText();
            dispatchEvent(new Event("elementErrorStringsChanged"));
        }
        
        private function applyErrorText():void
        {
            if (!errorTextDisplay)
                return;
            
            var msg:String = "";
            for (var i:int=0; i < elementErrorStrings.length; i++)
            {
                if (msg != "")
                    msg += "\n";
                msg += elementErrorStrings[i];
            }
            
            errorTextDisplay.text = msg;
            
        }
        
        private function createHelpContent():void
        {
            if (_helpContentFactory && helpContentGroup && helpContentFactoryChanged)
            {
                helpContentFactoryChanged = false;
                
                var content:Object = _helpContentFactory.getInstance();
                
                if (!(content is Array))
                {
                    content = [content];
                }
                
                helpContentGroup.mxmlContent = content as Array; 

            }
            /*if (!mxmlContentCreated)
            {
                mxmlContentCreated = true;
                
                if (_mxmlContentFactory)
                {
                    var deferredContent:Object = _mxmlContentFactory.getInstance();
                    mxmlContent = deferredContent as Array;
                    _deferredContentCreated = true;
                    dispatchEvent(new FlexEvent(FlexEvent.CONTENT_CREATION_COMPLETE));
                }
            }*/
        }
        
    }
}