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

import spark.components.itemRenderers.IItemPartRendererBase;

/**  @private
 *  This is the base class for multi-part renderers that manages a vector of part renderers.
 *  This class is responsible for creating and storing  the actual renderers from their descriptors
 *  the layout of the part renderers is delegated to a subclass of ListMultiPartLayoutBase;
 */
public class ListMultiPartItemRendererBase extends ItemRendererBase
{
    private var _partRendererDescriptors:Vector.<IPartRendererDescriptor>;
    private var _partRenderers:Vector.<IItemPartRendererBase>;
    private var _partRenderersLayout:ListMultiPartLayoutBase;

    public function ListMultiPartItemRendererBase()
    {
    }

    /* set by DataGridMobile Factory */
    public function set partRendererDescriptors(value:Vector.<IPartRendererDescriptor>):void
    {
        _partRendererDescriptors = value;
        _partRenderers = new Vector.<IItemPartRendererBase>(_partRendererDescriptors.length);
    }

    public function get partRendererDescriptors():Vector.<IPartRendererDescriptor>
    {
        return _partRendererDescriptors;
    }

    public function get partRenderersLayout():ListMultiPartLayoutBase
    {
        return _partRenderersLayout;
    }

    public function set partRenderersLayout(value:ListMultiPartLayoutBase):void
    {
        _partRenderersLayout = value;
    }

    public function get partRenderers():Vector.<IItemPartRendererBase>
    {
        return _partRenderers;
    }

    override protected function createChildren():void
    {
        super.createChildren();
        var desc:IPartRendererDescriptor;
        var pr:IItemPartRendererBase;
        for (var i:int = 0; i < _partRendererDescriptors.length; i++)
        {
            desc = _partRendererDescriptors[i];
            pr = desc.createPartRenderer();
            if (pr != null)
            {
                pr.styleProvider = this;
                addChild(DisplayObject(pr));
                _partRenderers[i] = pr;
            }
            else
            {
                //TODO move to resource bundle
                throw  new Error("MobileGridColumn item renderer must implement spark.components.itemRenderers.IItemPartRendererBase") ;
            }
        }
    }

    override protected function measure():void
    {
        super.measure();
        _partRenderersLayout.measure();
    }

   /** delegate children layout to its partRendererLayout
    subclasses can override this method to layout chrome content
    */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        _partRenderersLayout.layoutContents(unscaledWidth, unscaledHeight);
    }

    override protected function onDataChanged():void
    {
        var dpr:IItemPartRendererBase;
        for (var i:int = 0; i < _partRenderers.length; i++)
        {
            dpr = _partRenderers[i];
            dpr.data = data;
        }
        invalidateSize();
    }



}

}
