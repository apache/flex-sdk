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

package mx.collections {
    import mx.collections.ArrayCollection;

    public class DataNode {
        private var _label:String;
        private var _children:ArrayCollection;
        private var _isSelected:Boolean = false;
        private var _isPreviousSiblingRemoved:Boolean = false;
        private var _parent:DataNode;

        public function DataNode(label:String)
        {
            _label = label;
        }

        public function get children():ArrayCollection
        {
            return _children;
        }

        public function set children(value:ArrayCollection):void
        {
            _children = value;
        }

        public function get label():String
        {
            return _label + (_isSelected ? " [SEL]" : "") + (_isPreviousSiblingRemoved ? " [PREV ITEM REMOVED]" : "");
        }

        public function toString():String
        {
            return label;
        }

        public function addChild(node:DataNode):void
        {
            if(!_children)
                _children = new ArrayCollection();

            _children.addItem(node);
            node.parent = this;
        }

        public function set isSelected(value:Boolean):void
        {
            _isSelected = value;
        }

        public function get isSelected():Boolean
        {
            return _isSelected;
        }

        public function clone():DataNode
        {
            var newNode:DataNode = new DataNode(_label);
            for each(var childNode:DataNode in children)
            {
                newNode.addChild(childNode.clone());
            }

            return newNode;
        }

        public function set isPreviousSiblingRemoved(value:Boolean):void
        {
            _isPreviousSiblingRemoved = value;
        }

        public function get parent():DataNode
        {
            return _parent;
        }

        public function set parent(value:DataNode):void
        {
            _parent = value;
        }
    }
}
