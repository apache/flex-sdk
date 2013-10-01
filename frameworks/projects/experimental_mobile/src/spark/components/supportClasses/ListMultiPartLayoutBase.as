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
import mx.core.IFlexDisplayObject;
import mx.core.ILayoutElement;

import spark.components.itemRenderers.IItemPartRendererBase;

/** @private
 *   Abstract base class for laying out part renderers in a multi-part renderer.
 *   Subclasses must override measure() and layoutContents() methods
 */
public class ListMultiPartLayoutBase extends Object
{
    private var _target:ListMultiPartItemRendererBase;

    public function ListMultiPartLayoutBase(target:ListMultiPartItemRendererBase)
    {
        _target = target;
    }

    public function get target():ListMultiPartItemRendererBase
    {
        return _target;
    }

    protected function get partRendererDescriptors():Vector.<IPartRendererDescriptor>
    {
        return target.partRendererDescriptors;
    }

    protected function get partRenderers():Vector.<IItemPartRendererBase>
    {
        return target.partRenderers;
    }

    public function measure():void
    {

    }

    /* vertical align middle
     * give all columns the requested sizes, and the last column the remaining width  */
    public function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {

    }

    protected function setElementPosition(element:Object, x:Number, y:Number):void
    {
        if (element is ILayoutElement)
        {
            ILayoutElement(element).setLayoutBoundsPosition(x, y, false);
        }
        else if (element is IFlexDisplayObject)
        {
            IFlexDisplayObject(element).move(x, y);
        }
        else
        {
            element.x = x;
            element.y = y;
        }
    }

    protected function setElementSize(element:Object, width:Number, height:Number):void
    {
        if (element is ILayoutElement)
        {
            ILayoutElement(element).setLayoutBoundsSize(width, height, false);
        }
        else if (element is IFlexDisplayObject)
        {
            IFlexDisplayObject(element).setActualSize(width, height);
        }
        else
        {
            element.width = width;
            element.height = height;
        }
    }

    protected function getElementPreferredWidth(element:Object):Number
    {
        var result:Number;

        if (element is ILayoutElement)
        {
            result = ILayoutElement(element).getPreferredBoundsWidth();
        }
        else if (element is IFlexDisplayObject)
        {
            result = IFlexDisplayObject(element).measuredWidth;
        }
        else
        {
            result = element.width;
        }

        return Math.round(result);
    }

    protected function getElementPreferredHeight(element:Object):Number
    {
        var result:Number;

        if (element is ILayoutElement)
        {
            result = ILayoutElement(element).getPreferredBoundsHeight();
        }
        else if (element is IFlexDisplayObject)
        {
            result = IFlexDisplayObject(element).measuredHeight;
        }
        else
        {
            result = element.height;
        }

        return Math.ceil(result);
    }

}
}
