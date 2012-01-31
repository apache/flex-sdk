////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.supportClasses
{
    import flash.display.DisplayObject;
    import flash.events.EventDispatcher;
    
    import mx.resources.ResourceManager;
    
    import spark.events.DisplayLayerObjectExistenceEvent;
    
    /**
     *  A DisplayLayer class maintains an ordered list of DisplayObjects sorted on
     *  depth.
     *  You do not instantiate this class, but use the <code>overlay</code>
     *  property of <code>Group</code> and <code>DataGroup</code>.
     *
     *  @see spark.components.Group#overlay
     *  @see spark.components.DataGroup#overlay
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public class DisplayLayer extends EventDispatcher
    {
        /**
         *  Constructor. 
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function DisplayLayer()
        {
            super();
        }
        
        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------
        
        private var _depth:Vector.<Number>;
        private var _objects:Vector.<DisplayObject>;
        
        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Number of objects in the DisplayLayer. 
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function get numDisplayObjects():int
        {
            return _objects ? _objects.length : 0;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Returns the DisplayObject with the specified index. 
         *
         *  @param index The index of the object.
         *
         *  @return The object.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function getDisplayObjectAt(index:int):DisplayObject
        {
            if (!_objects || index < 0 || index >= _objects.length)
                throw new RangeError(ResourceManager.getInstance().getString("components", "indexOutOfRange", [index]));
            
            return _objects[index];
        }
        
        /**
         *  Returns the depth for the specified DisplayObject.
         *
         *  @param displayObject The object.
         *
         *  @return The depth of the object.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function getDisplayObjectDepth(displayObject:DisplayObject):Number
        {
            var index:int = _objects.indexOf(displayObject);
            if (index == -1)
                throw new RangeError(ResourceManager.getInstance().getString("components", "objectNotFoundInDisplayLayer", [displayObject]));
            
            return _depth[index];
        }
        
        /**
         *  Adds a <code>displayObject</code> with the specified depth to the ordered list.
         *  The position of the <code>displayObject</code> in the sorted lists is based on
         *  its depth.
         *  The object is inserted after all objects with less than or equal
         *  <code>depth</code> value.
         *
         *  @param displayObject The object to add.
         *
         *  @param depth The depth of the object.   
         * 
         *  @return The index of the object.
         *
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function addDisplayObject(displayObject:DisplayObject, depth:Number = OverlayDepth.TOP):DisplayObject
        {
            // Find index to insert
            var index:int = 0;
            if (!_depth)
            {
                _depth = new Vector.<Number>;
                _objects = new Vector.<DisplayObject>;
            }
            else
            {
                // Simple linear search
                var count:int = _depth.length;
                for (; index < count; index++)
                    if (depth < _depth[index])
                        break;
            }
            
            // Insert at index:
            _depth.splice(index, 0, depth);
            _objects.splice(index, 0, displayObject);
            
            // Notify that the object has been added
            dispatchEvent(new DisplayLayerObjectExistenceEvent(DisplayLayerObjectExistenceEvent.OBJECT_ADD,
                false /*bubbles*/,
                false /*cancelable*/,
                displayObject,
                index));
            
            return displayObject;
        }
        
        /**
         *  Removes the specified <code>displayObject</code> from the sorted list.
         *
         *  @param displayObject The object.
         *
         *  @return The removed object.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function removeDisplayObject(displayObject:DisplayObject):DisplayObject
        {
            var index:int = _objects.indexOf(displayObject);
            if (index == -1)
                throw new RangeError(ResourceManager.getInstance().getString("components", "objectNotFoundInDisplayLayer", [displayObject]));
            
            // Notify that the object is to be deleted
            dispatchEvent(new DisplayLayerObjectExistenceEvent(DisplayLayerObjectExistenceEvent.OBJECT_REMOVE,
                false /*bubbles*/,
                false /*cancelable*/,
                displayObject,
                index));
            _depth.splice(index, 1);
            _objects.splice(index, 1);
            return displayObject;
        }
        
    }
}