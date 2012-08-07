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
package data
{
    import mx.controls.treeClasses.ITreeDataDescriptor;
    import mx.collections.ICollectionView;
    import mx.collections.ArrayCollection;
    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;
    import mx.events.PropertyChangeEvent;
    import mx.events.PropertyChangeEventKind;
    import flash.events.Event;
    
    public class LTDescriptor
        implements ITreeDataDescriptor
    {
        public function addChildAt(node:Object, child:Object, index:int, model:Object = null):Boolean
        {
            return false;
        }
        
        public function getChildren(node:Object, model:Object = null):ICollectionView
        {
            return ICollectionView(node);
         }

        public function getData(node:Object, model:Object = null):Object
        {
            return null;
        }
        
        public function hasChildren(node:Object, model:Object = null):Boolean
        {
        	/*if (node is ICollectionView)
        	{
	        	if (node.length == 0)
	        	{
	        		node.addEventListener(CollectionEvent.COLLECTION_CHANGE, 
	        							  handleEmptyBranch, 
	        							  false, 0, true);
	        							  
	        	    
	        	}
	        	else
	        	{
					return (node.length > 0);
	        	}
	        }*/
            return true;
        }

        public function isBranch(node:Object, model:Object = null):Boolean
        {
            return true;
        }
        
        public function removeChildAt(node:Object, child:Object, index:int, model:Object = null):Boolean
        {
            return false;
        }
        
        private function handleEmptyBranch(event:CollectionEvent):void
        {
        	if (event.kind == CollectionEventKind.ADD)
        	{
        		/*
        		var parentNode:ICollectionView = ICollectionView(event.target);
        		parentNode.removeEventListener( CollectionEvent.COLLECTION_CHANGE, handleEmptyBranch);
        		parentNode.dispatchEvent(new PropertyChangeEvent( PropertyChangeEvent.PROPERTY_CHANGE,
                                        false,
                                        true,
                                        PropertyChangeEventKind.UPDATE) );
                */
         	}
        }
    }
}