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
package spark.core
{
/**
 *  The ISharedDisplayObject interface defines the minimum requirements 
 *  that a DisplayObject must implement to be shared between 
 *  <code>IGraphicElement</code> objects.
 *
 *  The Group class uses the ISharedDisplayObject interface to manage
 *  invalidation and redrawing of sequences of IGraphicElement
 *  objects that share a DisplayObject.
 *
 *  <p>Typically, when implementing a custom IGraphicElement class,
 *  you also implement this interface for the DisplayObject
 *  that the custom IGraphicElement creates.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface ISharedDisplayObject
{
    /**
     *  Contains <code>true</code> when any of the IGraphicElement objects that share
     *  this DisplayObject need to redraw.  
     *  This property is used internally by the Group class 
     *  and you do not typically use it.
     *  The Group class sets and reads back this property to
     *  determine which graphic elements to validate.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get redrawRequested():Boolean;
    
    /**
     *  @private
     */    
    function set redrawRequested(value:Boolean):void;
}
}