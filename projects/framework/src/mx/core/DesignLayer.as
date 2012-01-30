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
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
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
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
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
         *  ID of the layer component. This value becomes the instance name of the layer
         *  and as such, should not contain any white space or special characters. 
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public var id:String;
        
        //----------------------------------
        //  parent
        //----------------------------------
        
        /**
         *  @private
         *  This layer's parent layer. 
         *  
         *  @default null
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        protected var parent:DesignLayer;
        
        //----------------------------------
        //  layerChildren
        //----------------------------------
        
        /**
         * @private
         */  
        private var layerChildren:Array = new Array();
        
        //----------------------------------
        //  visible
        //----------------------------------
        
        /**
         * @private
         */  
        private var _visible:Boolean = true;

        /**
         *  The visibility for this design layer instance.
         *
         *  When updated, the appropriate change event for 
         *  computedVisibility will be dispatched to all layerPropertyChange
         *  listeners for this layer, as well as those of affected
         *  descendant layers if any.
         *
         *  @default true
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function get visible():Boolean
        {
            return _visible;
        }
 
        /**
         * @private
         */
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
         *  Returns the effective visibility of this design layer
         *  (which considers the visibility of this layer as well as
         *  any ancestor layers).  
         * 
         *  @default true
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
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
         * Used to notify the visual elements associated with this layer
         * that the computed visiblity has changed.  Dispatches a 
         * "layerPropertyChange" event with property field set to 
         * "computedVisibility".
         */  
        protected function computedVisibilityChanged(value:Boolean):void
        {
            dispatchEvent(new PropertyChangeEvent("layerPropertyChange", false, 
                false, PropertyChangeEventKind.UPDATE, "computedVisibility", !value, value));
            
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
        
        /**
         *  The alpha for this design layer instance.
         *
         *  When updated, the appropriate change event for 
         *  computedAlpha will be dispatched to all layerPropertyChange
         *  listeners for this layer, as well as those of affected
         *  descendant layers if any.
         *
         *  @default 1.0
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function get alpha():Number
        {
            return _alpha;
        }
 
        /**
         * @private
         */
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
         *  Property that returns the effective alpha of this design layer
         *  (which considers the alpha of this multiplied with the alpha of 
         *  any ancestor layers).  
         * 
         *  @default 1.0
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
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
         * Used to notify the visual elements associated with this layer
         * that the computed alpha has changed.  Dispatches a "layerPropertyChange"
         * event with the property field set to "computedAlpha".
         */  
        protected function computedAlphaChanged(oldAlpha:Number):void
        {
            dispatchEvent(new PropertyChangeEvent("layerPropertyChange", false, 
                false, PropertyChangeEventKind.UPDATE, "computedAlpha", oldAlpha, computedAlpha));
            
            for (var i:int = 0; i < layerChildren.length; i++)
            {
                var layerChild:DesignLayer = layerChildren[i];
                layerChild.computedAlphaChanged(layerChild.alpha);
            }
        }
 
        //----------------------------------
        //  numLayers
        //----------------------------------
        
        /**
         *  The number of DesignLayer children immediately parented by this layer.
         *
         *  @default 0
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function get numLayers():int
        {
            return layerChildren.length;
        }
        
        //----------------------------------------------------------------------
        //
        //  Methods
        //
        //----------------------------------------------------------------------
        
        /**
         *  Adds a DesignLayer child to this layer.
         *
         *  @param value The layer child to add.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function addLayer(value:DesignLayer):void
        {
            value.parent = this;
            layerChildren.push(value);
        }
        
        /**
         *  Returns the DesignLayer child at the specified index.
         *
         *  @param index The 0-based index of a DesignLayer child.
         *
         *  @return The specified DesignLayer child if index is between
         *  0 and <code>numLayers</code> - 1.  Returns
         *  <code>null</code> if the index is invalid.
         * 
         *  @see numLayers
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function getLayerAt(index:int):DesignLayer
        {
            return ((index < layerChildren.length) && index >= 0) ? 
                layerChildren[index] : null;
        }
        
        /**
         *  Removes a DesignLayer child from this layer.
         *
         *  @param value The layer child to remove.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function removeLayer(value:DesignLayer):void
        {
            for (var i:int = 0; i < layerChildren.length; i++)
            {
                if (layerChildren[i] == value)
                {
                    layerChildren.splice(i,1);
                    return;
                }
            }
        }
         
    }
}