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

package spark.skins
{
    import mx.core.IVisualElement;
    import spark.components.Button;
    import spark.components.Group;
    import spark.components.IconPlacement;
    import spark.components.supportClasses.ButtonBase;
    import spark.core.IDisplayText;
    import spark.layouts.*;
    import spark.primitives.BitmapImage;
    import spark.skins.SparkSkin;
    
    /**
     *  Base class for Spark button skins. Primarily used for
     *  pay-as-you-go icon management.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */    
    public class SparkButtonSkin extends SparkSkin
    {              
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         * Constructor.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4.5
         */
        public function SparkButtonSkin()
        {
            super();
        }    
        
        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------
        
        /**
         * @private
         * Internal flag used to determine if we should consider icon construction,
         * placement, or layout in commitProperties.
         */  
        private var iconChanged:Boolean = true;
        private var iconPlacementChanged:Boolean = false;
        private var groupPaddingChanged:Boolean = true;
        
        /**
         * @private
         * Our transient icon and label Group.
         */ 
        private var iconGroup:Group;
        
        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------
           
        //----------------------------------
        //  autoIconManagement
        //----------------------------------
        
        private var _autoIconManagement:Boolean = true;
        
        /**
         *  If enabled will automatically construct the necessary
         *  constructs to present and layout an iconDisplay
         *  part.
         * 
         *  @default true
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function get autoIconManagement():Boolean
        {
            return _autoIconManagement;
        }
        
        /**
         *  @private
         */
        public function set autoIconManagement(value:Boolean):void
        {
            _autoIconManagement = value;
            invalidateProperties();
        }
        
        //----------------------------------
        //  gap
        //----------------------------------
        
        private var _gap:Number = 6;
        
        /**
         *  Number of pixels between the buttons's icon and
         *  label.
         * 
         *  @default 6
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function get gap():Number
        {
            return _gap;
        }
        
        /**
         *  @private
         */
        public function set gap(value:Number):void
        {
            _gap = value;
            groupPaddingChanged = true;
            invalidateProperties();
        }
                
        //----------------------------------
        //  hostComponent
        //----------------------------------
        
        /**
         *  @private
         */
        private var _hostComponent:ButtonBase;
        
        /**
         *  @private 
         */ 
        public function set hostComponent(value:ButtonBase):void
        {
            if (_hostComponent)
            {
                _hostComponent.removeEventListener("iconChange", iconChangeHandler);
                _hostComponent.removeEventListener("contentChange", contentChangeHandler);
            }
            
            _hostComponent = value;
            
            if (value)
            {
                // Detect changes to our icon or label content so that we can
                // realize the necessary component parts and layout as appropriate.
                _hostComponent.addEventListener("iconChange", iconChangeHandler);
                _hostComponent.addEventListener("contentChange", contentChangeHandler);
            }
        }
        
        /**
         *  @private 
         */ 
        public function get hostComponent():ButtonBase
        {
            return _hostComponent;
        }
        
        //----------------------------------
        //  iconDisplay
        //----------------------------------
        
        /**
         * @copy spark.components.supportClasses.ButtonBase#iconDisplay
         */  
        [Bindable]
        public var iconDisplay:BitmapImage;
        
        //----------------------------------
        //  labelDisplay
        //----------------------------------
        
        /**
         * @copy spark.components.supportClasses.ButtonBase#labelDisplay
         */  
        [Bindable]
        public var labelDisplay:IDisplayText;

        
        //----------------------------------
        //  paddingLeft
        //----------------------------------
        
        private var _iconGroupPaddingLeft:Number = 10;
        
        /**
         *  The minimum number of pixels between the buttons's left edge and
         *  the left edge of the icon or label.
         * 
         *  @default 0
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4.5
         */
        public function get iconGroupPaddingLeft():Number
        {
            return _iconGroupPaddingLeft;
        }
        
        /**
         *  @private
         */
        public function set iconGroupPaddingLeft(value:Number):void
        {
            _iconGroupPaddingLeft = value;
            groupPaddingChanged = true;
            invalidateProperties();
        }    
        
        //----------------------------------
        //  paddingRight
        //----------------------------------
        
        private var _iconGroupPaddingRight:Number = 10;
        
        [Inspectable(category="General")]
        
        /**
         *  The minimum number of pixels between the buttons's right edge and
         *  the right edge of the icon or label.
         * 
         *  @default 0
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function get iconGroupPaddingRight():Number
        {
            return _iconGroupPaddingRight;
        }
        
        /**
         *  @private
         */
        public function set iconGroupPaddingRight(value:Number):void
        {
            _iconGroupPaddingRight = value;
            groupPaddingChanged = true;
            invalidateProperties();
        }    
        
        //----------------------------------
        //  paddingTop
        //----------------------------------
        
        private var _iconGroupPaddingTop:Number = 4;
                
        /**
         *  Number of pixels between the buttons's top edge
         *  and the top edge of the first icon or label.
         * 
         *  @default 0
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function get iconGroupPaddingTop():Number
        {
            return _iconGroupPaddingTop;
        }
        
        /**
         *  @private
         */
        public function set iconGroupPaddingTop(value:Number):void
        {
            _iconGroupPaddingTop = value;
            groupPaddingChanged = true;
            invalidateProperties();
        }    
        
        //----------------------------------
        //  paddingBottom
        //----------------------------------
        
        private var _iconGroupPaddingBottom:Number = 4;
        
        /**
         *  Number of pixels between the buttons's bottom edge
         *  and the bottom edge of the icon or label.
         * 
         *  @default 0
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function get iconGroupPaddingBottom():Number
        {
            return _iconGroupPaddingBottom;
        }
        
        /**
         *  @private
         */
        public function set iconGroupPaddingBottom(value:Number):void
        {
            _iconGroupPaddingBottom = value;
            groupPaddingChanged = true;
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
        override protected function commitProperties():void
        {
            super.commitProperties();
            
            if (!((iconChanged || iconPlacementChanged || groupPaddingChanged) 
                && autoIconManagement))
                return;
            
            // If we have an icon to render we ensure the necessary
            // parts are created and we configure a linear layout
            // instance to manage our icon and label parts.
            if (_hostComponent.icon && labelDisplay)
            {
                if (iconChanged)
                    constructIconParts(true);
                
                if (groupPaddingChanged)
                {
                    iconGroup.left = _iconGroupPaddingLeft;
                    iconGroup.right = _iconGroupPaddingRight;
                    iconGroup.top = _iconGroupPaddingTop;
                    iconGroup.bottom = _iconGroupPaddingBottom;
                    groupPaddingChanged = false;
                }
                
                var iconPlacement:String = getStyle("iconPlacement");
                
                var horizontal:Boolean = 
                    iconPlacement == IconPlacement.LEFT ||
                    iconPlacement == IconPlacement.RIGHT;
                
                iconGroup.layout =  horizontal ? 
                    new HorizontalLayout() : new VerticalLayout();
                
                // Initialize our layout alignment and position the icon in 
                // the correct child slot per our iconPlacement.
                Object(iconGroup.layout).horizontalAlign = HorizontalAlign.CENTER;
                Object(iconGroup.layout).verticalAlign = VerticalAlign.MIDDLE;
                Object(iconGroup.layout).gap = _gap;
                
                var firstElement:IVisualElement = 
                    (iconPlacement == IconPlacement.LEFT || 
                        iconPlacement == IconPlacement.TOP) ? 
                    iconDisplay : IVisualElement(labelDisplay);
                
                iconGroup.setElementIndex(firstElement, 0);
                
                // Ensure we account for empty layout so that we don't apply layout gap.
                IVisualElement(labelDisplay).includeInLayout = labelDisplay.text && labelDisplay.text.length;
            }
            else
            {
                // If we've previously realized our iconDisplay or iconGroup
                // remove them from the display list as they are no long required.
                constructIconParts(false);
            }
            
            iconChanged = false;
            iconPlacementChanged = false;
        }
        
        /**
         *  @private 
         *  Detected changes to iconPlacement and update as necessary.
         */ 
        override public function styleChanged(styleProp:String):void 
        {    
            if (!styleProp || 
                styleProp == "styleName" || styleProp == "iconPlacement")
            {
                iconPlacementChanged = true;
                invalidateProperties();
            }
            
            super.styleChanged(styleProp);
        }
        
        //--------------------------------------------------------------------------
        //
        //  Methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private 
         *  Creates our iconDisplay and containing Group
         *  or removes them from the display list and restores
         *  our single labelDisplay.
         */ 
        private function constructIconParts(construct:Boolean):void
        {
            if (!autoIconManagement)
                return;
            
            if (construct)
            {
                if (!iconDisplay)
                {
                    iconDisplay = new BitmapImage();
                    iconDisplay.verticalCenter = 0;
                    iconDisplay.horizontalCenter = 0;
                }
                
                if (!iconGroup)
                    iconGroup = new Group();
                                            
                iconGroup.addElement(iconDisplay);
                iconGroup.addElement(IVisualElement(labelDisplay));
                addElement(iconGroup);
            }
            else
            {
                if (iconDisplay && iconDisplay.parent)
                    iconGroup.removeElement(iconDisplay);
                
                if (iconGroup && iconGroup.parent)
                {
                    removeElement(iconGroup);
                    addElement(IVisualElement(labelDisplay));
                }
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
        private function iconChangeHandler(event:Event):void
        {
            iconChanged = true;
            invalidateProperties();
        }
        
        /**
         *  @private 
         */ 
        protected function contentChangeHandler(event:Event):void
        {
            // Ensure empty label is not included in layout else
            // a gap between icon and label would be applied.
            IVisualElement(labelDisplay).includeInLayout = labelDisplay.text != null 
                && labelDisplay.text.length;
        }
    }
}
