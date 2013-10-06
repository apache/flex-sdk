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

import mx.core.IDataRenderer;
import mx.styles.IStyleClient;

[Experimental]

/**
 * This is the base interface that all mobile grid cell renderers must implement.
 * <p>Contrary to desktop DataGrid control, there is no default implementation for this interface,
 * because mobile renderers must be lightweight, and derive directly for an existing component, (eg.. s:Button or s:CheckBox ).</p>
 *
 *  @langversion 3.0
 *  @playerversion AIR 3.8
 *  @productversion Flex 4.11
 */
public interface IMobileGridCellRenderer extends IDataRenderer
{
    /** @private
     *  Object to be used for providing styles to the part renderer.
     * Mobile part  items renders being lightweight classes, they usually don't manage styles by themselves.
     * This property is automatically set
     */
    function set styleProvider(value:IStyleClient):void ;

    /** Flag indicating whether the layout manager can stretch the width of this renderer to match the column's width.
     <p> default value is false.  Override the getter to return a difference value </p>
     */
    function get canSetContentWidth():Boolean;

    /** Flag indicating whether the layout manager can stretch the height of this renderer to match the column's height.
     <p> default value is false.  Override the getter to return a difference value </p>
     */
    function get canSetContentHeight():Boolean;

    /** this property is set with the GridColumn's styleName property.
     <p> you can override it to extract information from the style and pass them to this renderer.</p>
     */
    function set cssStyleName(value:String):void;

    /**
     * @private
     */
    function getPreferredBoundsWidth(postLayoutTransform:Boolean = true):Number;

    /**
     * @private
     */
    function getPreferredBoundsHeight(postLayoutTransform:Boolean = true):Number;


}
}
