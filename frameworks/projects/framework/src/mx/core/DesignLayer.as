////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.core
{
    import flash.events.EventDispatcher;
    import mx.events.PropertyChangeEvent;
    import mx.events.PropertyChangeEventKind;
        
    /**
     *  Dispatched by the layer when either computedVisibility or 
     *  computedAlpha changes.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    [Event(name="layerPropertyChange", type="mx.events.PropertyChangeEvent")]
    
    /**
     *  The DesignLayer class represents a "visibility group" that can be associated
     *  with one or more IVisualElement instances at runtime.  
     * 
     *  DesignLayer instances support a visible and alpha property that when set will
     *  propagate to the assocaited layer children.
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    public class DesignLayer extends EventDispatcher
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
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 4
         */
        public function DesignLayer()
        {
            super();
        }
        
        //----------------------------------
        //  id
        //----------------------------------
        
        /**
         * @private
         */  
        public var id:String;
        
        //----------------------------------
        //  parent
        //----------------------------------
        
        /**
         * @private
         */  
        public var parent:DesignLayer;
        
        //----------------------------------
        //  layerChildren
        //----------------------------------
        
        /**
         * @private
         */  
        private var layerChildren:Array = new Array();
        
        //--------------------------------------------------------------------------
        //  Methods
        //--------------------------------------------------------------------------
        
        /**
         * @private
         */  
        public function addLayer(value:DesignLayer):void
        {
            value.parent = this;
            layerChildren.push(value);
        }

        //----------------------------------
        //  visible
        //----------------------------------
        
        /**
         * @private
         */  
        private var _visible:Boolean = true;
        
        public function get visible():Boolean
        {
            return _visible;
        }
        
        public function set visible(value:Boolean):void
        {
            if (_visible != value)
            {
                _visible = value;
                computedVisibilityChanged(computedVisibility);
            }
        }
        
        //----------------------------------
        //  computedVisibility
        //----------------------------------
        
        /**
         * @private
         */  
        public function get computedVisibility():Boolean
        {
            var isVisible:Boolean = _visible;
            var currentLayer:DesignLayer = this;
            while (isVisible && currentLayer.parent)
            {
                currentLayer = currentLayer.parent;
                isVisible = currentLayer.visible;
            }
            return isVisible;
        }
        
        /**
         * @private
         */  
        protected function computedVisibilityChanged(value:Boolean):void
        {
            dispatchEvent(new PropertyChangeEvent("layerPropertyChange", false, 
                false, PropertyChangeEventKind.UPDATE, "visible", !value, value));
            
            for (var i:int = 0; i < layerChildren.length; i++)
            {
                var layerChild:DesignLayer = layerChildren[i];
                
                // We only need to notify those layers that are visible, because
                // those that aren't don't really care about their layer parents
                // visibility.
                if (layerChild.visible)
                    layerChild.computedVisibilityChanged(value);
            }
        }
        
        //----------------------------------
        //  alpha
        //----------------------------------
        
        /**
         * @private
         */  
        private var _alpha:Number = 1.0;
        
        public function get alpha():Number
        {
            return _alpha;
        }
        
        public function set alpha(value:Number):void
        {
            if (_alpha != value)
            {
                var oldAlpha:Number = _alpha;
                _alpha = value;
                computedAlphaChanged(oldAlpha);
            }
        }
        
        //----------------------------------
        //  computedAlpha
        //----------------------------------
        
        /**
         * @private
         */  
        public function get computedAlpha():Number
        {
            var currentAlpha:Number = _alpha;
            var currentLayer:DesignLayer = this;
            while (currentLayer.parent)
            {
                currentLayer = currentLayer.parent;
                currentAlpha = currentAlpha * currentLayer.alpha;
            }
            return currentAlpha;
        }
        
        /**
         * @private
         */  
        protected function computedAlphaChanged(oldAlpha:Number):void
        {
            dispatchEvent(new PropertyChangeEvent("layerPropertyChange", false, 
                false, PropertyChangeEventKind.UPDATE, "alpha", oldAlpha, computedAlpha));
            
            for (var i:int = 0; i < layerChildren.length; i++)
            {
                var layerChild:DesignLayer = layerChildren[i];
                layerChild.computedAlphaChanged(layerChild.alpha);
            }
        }
        
    }
}