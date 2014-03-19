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

import mx.core.mx_internal;

import spark.components.LabelItemRenderer;

import spark.components.itemRenderers.IMobileGridCellRenderer;
import spark.core.DisplayObjectSharingMode;
import spark.core.IGraphicElement;
import spark.core.IGraphicElementContainer;
import spark.core.ISharedDisplayObject;

use namespace mx_internal;

// for asdoc
[Experimental]

/**  @private
 *  This is the base class for multi-part renderers that manages a vector of part renderers.
 *  This class is responsible for creating and storing  the actual renderers from their descriptors
 *  the layout of the part renderers is delegated to a subclass of ListMultiPartLayoutBase;

 *    This is the internal list itemRenderer used for rendering grid cells in a single row of a MobileGrid.
 *    It inherits all its behavior for its parent class and only sets the part renderers layout.
 *
 *   @langversion 3.0
 *  @playerversion AIR 3.8
 *  @productversion Flex 4.11
 *
 */
public class MobileGridRowRenderer extends LabelItemRenderer implements IGraphicElementContainer, ISharedDisplayObject
{
    private var _columns:Vector.<MobileGridColumn>;
    private var _partRenderers:Vector.<IMobileGridCellRenderer>;
    private var _graphicElementPartRenderers:Vector.<IGraphicElement>;
    private var _partRenderersLayout:ListMultiPartColumnLayout;

    /**
     * Management of graphicElement part renderers  lifeCycle
     */
    private var _redrawRequested:Boolean = false;
    private var graphicElementsNeedValidateProperties:Boolean = false;
    private var graphicElementsNeedValidateSize:Boolean = false;

    public function MobileGridRowRenderer()
    {
        _partRenderersLayout = new ListMultiPartColumnLayout(this);
    }

    /** @private
     * set in List itemRenderer Factory properties */
    public function set columns(value:Vector.<MobileGridColumn>):void
    {
        _columns = value;
        _partRenderers = new Vector.<IMobileGridCellRenderer>(_columns.length, true);
        _graphicElementPartRenderers = new Vector.<IGraphicElement>();
    }

    public function get columns():Vector.<MobileGridColumn>
    {
        return _columns;
    }

    public function get partRenderers():Vector.<IMobileGridCellRenderer>
    {
        return _partRenderers;
    }

    public function get graphicElementPartRenderers():Vector.<IGraphicElement>
    {
        return _graphicElementPartRenderers;
    }


    override public function get baselinePosition():Number
    {
        return NaN;
    }

    override protected function createChildren():void
    {
    //    super.createChildren();
        var desc:MobileGridColumn;
        var pr:IMobileGridCellRenderer;
        var ge:IGraphicElement;
        for (var i:int = 0; i < _columns.length; i++)
        {
            desc = _columns[i];
            pr = desc.createPartRenderer();
            if (pr != null)
            {
                pr.styleProvider = this;

                if (pr is IGraphicElement)
                {
                    ge = IGraphicElement(pr);
                    ge.parentChanged(this);
                    if (ge.setSharedDisplayObject(this))
                    {
                        ge.displayObjectSharingMode = DisplayObjectSharingMode.USES_SHARED_OBJECT;
                    }
                    _graphicElementPartRenderers.push(ge);
                }
                else if (pr is DisplayObject)
                {
                    addChild(DisplayObject(pr));
                }
                _partRenderers[i] = pr;
            }
            else
            {
                //TODO move to resource bundle
                throw  new Error("MobileGridColumn item renderer must implement spark.components.itemRenderers.IMobileGridCellRenderer");
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


    override public function set data(value:Object):void
    {
        super.data = value;
        var dpr:IMobileGridCellRenderer;
        for (var i:int = 0; i < _partRenderers.length; i++)
        {
            dpr = _partRenderers[i];
            dpr.data = data;
        }
        invalidateSize();
    }

    /*  graphic element sub renderers lifecycle management */

    override protected function commitProperties():void
    {
        if (graphicElementsNeedValidateProperties)
        {
            graphicElementsNeedValidateProperties = false;
            for (var i:int = 0; i < _graphicElementPartRenderers.length; i++)
            {
                _graphicElementPartRenderers[i].validateProperties();
            }
        }
        super.commitProperties();
    }


    override public function validateSize(recursive:Boolean = false):void
    {
        if (graphicElementsNeedValidateSize)
        {
            graphicElementsNeedValidateSize = false;
            for (var i:int = 0; i < _graphicElementPartRenderers.length; i++)
            {
                _graphicElementPartRenderers[i].validateSize();
            }
        }
        super.validateSize(recursive);
    }


    /* copied from Group*/
    override public function validateDisplayList():void
    {
        super.validateDisplayList();
        if (_redrawRequested)
        {
            for (var i:int = 0; i < _graphicElementPartRenderers.length; i++)
            {
                _graphicElementPartRenderers[i].validateDisplayList();
            }
        }
    }

    /* interfaces implementation, copied from spark.components.IconItemRender  */

    /**
     *  @inheritDoc
     *
     *  <p>We implement this as part of ISharedDisplayObject so the iconDisplay
     *  can share our display object.</p>
     *
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get redrawRequested():Boolean
    {
        return _redrawRequested;
    }

    /**
     *  @private
     */
    public function set redrawRequested(value:Boolean):void
    {
        _redrawRequested = value;
    }

    //--------------------------------------------------------------------------
    //
    //  IGraphicElementContainer
    //
    // -------------------------------------------------------------------------

    /**
     * @private
     *
     *  Notify the host component that an element changed and needs to validate properties.
     */
    public function invalidateGraphicElementSharing(element:IGraphicElement):void
    {
        //do nothing because all has been done in createChildren and won't change
    }

    /**
     * @private
     *
     *  Notify the host component that an element changed and needs to validate properties.
     */
    public function invalidateGraphicElementProperties(element:IGraphicElement):void
    {
        graphicElementsNeedValidateProperties = true;
        invalidateProperties();
    }

    /**
     * @private
     */
    public function invalidateGraphicElementSize(element:IGraphicElement):void
    {
        graphicElementsNeedValidateSize = true;
        invalidateSize();
    }

    /**
     * @private
     *
     */
    public function invalidateGraphicElementDisplayList(element:IGraphicElement):void
    {
        if (element.displayObject is ISharedDisplayObject)
            ISharedDisplayObject(element.displayObject).redrawRequested = true;
        invalidateDisplayList();
    }

}
}
