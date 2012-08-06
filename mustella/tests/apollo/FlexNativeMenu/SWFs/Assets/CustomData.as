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
package Assets
{
	import flash.text.TextField;
	
	import mx.controls.treeClasses.DefaultDataDescriptor;
	import flash.utils.Dictionary;
	import mx.collections.ArrayCollection;
	import mx.collections.CursorBookmark;
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	import mx.controls.menuClasses.IMenuDataDescriptor;
	import mx.utils.UIDUtil;

	public class CustomData extends DefaultDataDescriptor
	{
		
		
		public function CustomData()
		{
		}

    /**
     *  Returns whether the node is toggled.
     *  This method is used by menu-based controls.
     *
     *  @param node The node for which to get the status.
     *  @return The value of the node's <code>toggled</code>
     *  attribute or field, or <code>false</code> if there is no such
     *  entry.
     */
    override public function isToggled(node:Object):Boolean
    {
        if (node is XML)
        {
            var toggled:* = node.@myToggled;
            if (toggled[0] == true)
                return true;
        }
        else if (node is Object)
        {
            try
            {
                return Boolean(node.toggled);
            }
            catch(e:Error)
            {
            }
        }
        return false;
    }
    
    override public function setToggled(node:Object, value:Boolean):void
        {
            if (node is XML)
            {
                node.@myToggled = value;
            }
            else if (node is Object)
            {
                try
                {
                    node.toggled = value;
                }
                catch(e:Error)
                {
                }
            }
    }
    
    /**
     *  Returns whether the node is enabled.
     *  This method is used by menu-based controls.
     *  @param node The node for which to get the status.
     *  @return the value of the node's <code>enabled</code>
     *  attribute or field, or <code>true</code> if there is no such
     *  entry or the value is not false.
     */
     override public function isEnabled(node:Object):Boolean
        {
            var enabled:*;
            if (node is XML)
            {
                enabled = node.@myEnabled;
                if (enabled[0] == false)
                    return false;
            }
            else if (node is Object)
            {
                try
                {
                    return !("false" == String(node.enabled))
                }
                catch(e:Error)
                {
                }
            }
            return true;
        }
   
   /**
        *  Sets the value of the field or attribute in the data provider
        *  that identifies whether the node is enabled.
        *  This method sets the value of the node's <code>enabled</code>
        *  attribute or field.
        *  This method is used by menu-based controls.
        *
        *  @param node The node for which to set the status.
        *  @param value Whether the node is enabled.
        */
       override public function setEnabled(node:Object, value:Boolean):void
       {
           if (node is XML)
           {
               node.@myEnabled = value;
           }
           else if (node is Object)
           {
               try
               {
                   node.enabled = value;
               }
               catch(e:Error)
               {
               }
           }
        }

	override public function getData(node:Object, model:Object = null):Object
	{
		if (model == null)
			return null;
		return (Object(node.@changeMe));
   	 }
    
    /**
         *  Returns the type identifier of a node.
         *  This method is used by menu-based controls to determine if the
         *  node represents a separator, radio button,
         *  a check box, or normal item.
         *
         *  @param node The node object for which to get the type.
         *  @return  the value of the <code>type</code> attribute or field,
         *  or the empty string if there is no such field.
         */
        override public function getType(node:Object):String
        {
            if (node is XML)
            {
                return String(node.@myType);
            }
            else if (node is Object)
            {
                try
                {
                    return String(node.type);
                }
                catch(e:Error)
                {
                }
            }
            return "";
  	}
      
  }

}


