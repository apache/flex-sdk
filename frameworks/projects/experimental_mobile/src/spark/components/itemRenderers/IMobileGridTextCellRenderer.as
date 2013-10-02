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
package spark.components.itemRenderers
{

/**  Extended interface for renderer that include text
 *  @langversion 3.0
 *  @playerversion AIR 3.8
 *  @productversion Flex 4.11
 */

public interface IMobileGridTextCellRenderer extends IMobileGridCellRenderer
{
    /* implement this property so that the renderer can receive the dataField from the renderer's MobileGridColumn*/
    function set labelField(value:String):void;

    /* implement this property so that the renderer can receive the labelFunction from the renderers' MobileGridColumn*/
    function set labelFunction(value:Function):void;

    /* implement this property so that the renderer can receive the textAlign property from the renderers' MobileGridColumn*/
    function set textAlign(textAlign:String):void;
}
}
