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
    
    import spark.components.supportClasses.TextBase;
    import spark.events.ElementExistenceEvent;
        
    /**
     *  TODO
     *  - Remove canvasLayout skin part once FormItemLayout is ready
     *  - Remove measuredColumnWidths and layoutColumnWidths once 
     *    FormItemLayout and FormLayout are ready
     *  - Remove implements IFormItem
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
         *   A reference to the visual element that displays this FormItem's label.
         */
        [Bindable] // compatability with Halo FormItem itemLabel property
        [SkinPart(required="false")]
        public var labelDisplay:TextBase;
                
        /**
         *  A reference to the visual element that displays the FormItem's sequenceLabel.
         */
        [SkinPart(required="false")]
        public var sequenceLabelDisplay:TextBase;
        
        /**
         *  A reference to the Group that contains the FormItem's helpContentGroup.
         */
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
        //  measuredColumnWidths
        //----------------------------------
        
        private var _measuredColumnWidths:Vector.<Number>;
        
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
        
        
        //----------------------------------
        //  helpContent
        //----------------------------------
        private var _helpContent:IDeferredInstance; 
        private var helpContentChanged:Boolean = false;
        
        [Bindable("labelChanged")]
        [Inspectable(category="General", defaultValue="")]
        
        /**
         *  A factory object that creates the mxmlContent for the
         *  <code>helpContentGroup</code> skin part. 
         * 
         *  @default undefined
         */
        public function set helpContent(value:IDeferredInstance):void
        {
            _helpContent = value;
            helpContentChanged = true;
            invalidateProperties();
        }
        
        public function get helpContent():IDeferredInstance
        {
            return _helpContent;
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
              
        
        //--------------------------------------------------------------------------
        //
        //  Overridden Properties
        //
        //--------------------------------------------------------------------------
        
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
            if (required)
            {
                if (!enabled)
                    return "requiredAndDisabled";
                else if (elementErrorStrings.length > 0)
                    return "requiredAndError";
                else
                    return "required";
            }
            else
            {
                if (!enabled)
                    return "disabled";
                else if (elementErrorStrings.length > 0)
                    return "error";
                else
                    return "normal";       
            }
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
        
        //--------------------------------------------------------------------------
        //
        //  Event Handlers 
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         */
        private function elementAddHandler(event:ElementExistenceEvent):void
        {
            if (event.isDefaultPrevented())
                return;
            
            var uicElt:UIComponent = event.element as UIComponent;
            
            if (uicElt)
            {
                uicElt.addEventListener(FlexEvent.VALID, element_validHandler);
                uicElt.addEventListener(FlexEvent.INVALID, element_invalidHandler);
            }
        }
        
        /**
         *  @private
         */
        private function elementRemoveHandler(event:ElementExistenceEvent):void
        {
            if (event.isDefaultPrevented())
                return;
            
            var uicElt:UIComponent = event.element as UIComponent;
            
            if (uicElt)
            {
                uicElt.removeEventListener(FlexEvent.VALID, element_validHandler);
                uicElt.removeEventListener(FlexEvent.INVALID, element_invalidHandler);
            }
        }
        
        /**
         *  @private
         */
        private function element_validHandler(event:FlexEvent):void
        {
            // update error string
            updateErrorString();
        }
        
        /**
         *  @private
         */
        private function element_invalidHandler(event:FlexEvent):void
        {
            // update error string
            updateErrorString();
        }
        
        /**
         *  @private
         */
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
        
        /**
         *  @private
         */
        protected function applyErrorText():void
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
        
        /**
         *  @private
         */
        private function createHelpContent():void
        {
            if (_helpContent && helpContentGroup && helpContentChanged)
            {
                helpContentChanged = false;
                
                var content:Object = _helpContent.getInstance();
                
                if (!(content is Array))
                    content = [content];
                
                helpContentGroup.mxmlContent = content as Array; 
            }
        }
        
    }
}