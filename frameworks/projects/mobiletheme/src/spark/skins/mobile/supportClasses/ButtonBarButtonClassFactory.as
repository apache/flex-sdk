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

package spark.skins.mobile.supportClasses
{
import mx.core.ClassFactory;
import mx.core.IFactory;

import spark.components.ButtonBarButton;
import spark.components.supportClasses.SkinnableComponent;

/**
 *  Adds skinClass style support to ClassFactory.
 * 
 *  @see spark.skins.mobile.ButtonBarSkin
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class ButtonBarButtonClassFactory extends ClassFactory
{
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    public function ButtonBarButtonClassFactory(generator:Class)
    {
        super(generator);
    }
    
    private var _skinClass:Class;
    
    /**
     * The skin class that should be applied to button bar buttons created
     * by this factory.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    public function get skinClass():Class
    {
        return _skinClass;
    }
    
    public function set skinClass(skinClass:Class):void
    {
        _skinClass = skinClass;
    }
    
    override public function newInstance():*
    {
        var instance:Object = new generator();
        
        if (properties != null)
        {
            for (var p:String in properties)
            {
                instance[p] = properties[p];
            }
        }
        
        if (instance is SkinnableComponent && _skinClass)
        {
            SkinnableComponent(instance).setStyle("skinClass", _skinClass);
            SkinnableComponent(instance).setStyle("focusSkin", null);
        }
        
        return instance;
    }
}
}