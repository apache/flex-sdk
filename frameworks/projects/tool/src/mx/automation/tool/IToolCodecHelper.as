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

package mx.automation.tool
{

import mx.automation.IAutomationObject;	
	
public interface IToolCodecHelper
{
    /**
     *  Encodes properties in an AS object to an array of values for a testing tool
     *  using the codecs.  Since the object being passed in may not be an IAutomationObject 
     *  (it could be an event class) and some of the properties require the
     *  IAutomationObject to be transcoded (such as the item renderers in
     *  a list event), relativeParent should always be set to the relevant
     *  IAutomationObject.
     *
     *  @param obj the object that contains the properties to be encoded.
     * 
     *  @param propertyDescriptors the property descriptors that describes the properties for this object.
     * 
     *  @param relativeParent the IAutomationObject that is related to this object.
     *
     *  @return the encoded property value.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function encodeProperties(obj:Object, 
                              propertyDescriptors:Array, 
                              relativeParent:IAutomationObject):Array;

    /**
     *  Encodes a single value to a testing tool value.  Unlike encodeProperties which
     *  takes an object which contains all the properties to encode, this method
     *  takes the actual value to encode.  This is useful for encoding return values.
     *
     *  @param obj the value to be encoded.
     * 
     *  @param propertyDescriptor the property descriptor that describes this value.
     * 
     *  @param relativeParent the IAutomationObject that is related to this value.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
     
    function encodeValue(value:Object, 
                         testingToolType:String,
                         codecName:String,
                         relativeParent:IAutomationObject):Object;

    /**
     *  Decodes an array of properties from a testing tool into an AS object.
     *  using the codecs.
     *
     *  @param obj the object that contains the properties to be encoded.
     * 
     *  @param args the property values to transcode.
     * 
     *  @param propertyDescriptors the property descriptors that describes the properties for this object.
     * 
     *  @param relativeParent the IAutomationObject that is related to this object.
     *
     *  @return the decoded property value.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function decodeProperties(obj:Object, 
                              args:Array,
                              propertyDescriptors:Array,
                              relativeParent:IAutomationObject):void;

}		
}
