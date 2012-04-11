/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package com.adobe.internal.fxg.sax;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import com.adobe.fxg.FXGVersion;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.internal.fxg.dom.BitmapGraphicNode;
import com.adobe.internal.fxg.dom.ContentPropertyNode;
import com.adobe.internal.fxg.dom.DefinitionNode;
import com.adobe.internal.fxg.dom.DelegateNode;
import com.adobe.internal.fxg.dom.EllipseNode;
import com.adobe.internal.fxg.dom.GradientEntryNode;
import com.adobe.internal.fxg.dom.GraphicNode;
import com.adobe.internal.fxg.dom.GroupDefinitionNode;
import com.adobe.internal.fxg.dom.GroupNode;
import com.adobe.internal.fxg.dom.LibraryNode;
import com.adobe.internal.fxg.dom.LineNode;
import com.adobe.internal.fxg.dom.MaskPropertyNode;
import com.adobe.internal.fxg.dom.PathNode;
import com.adobe.internal.fxg.dom.RectNode;
import com.adobe.internal.fxg.dom.TextGraphicNode;
import com.adobe.internal.fxg.dom.fills.BitmapFillNode;
import com.adobe.internal.fxg.dom.fills.LinearGradientFillNode;
import com.adobe.internal.fxg.dom.fills.RadialGradientFillNode;
import com.adobe.internal.fxg.dom.fills.SolidColorFillNode;
import com.adobe.internal.fxg.dom.filters.BevelFilterNode;
import com.adobe.internal.fxg.dom.filters.BlurFilterNode;
import com.adobe.internal.fxg.dom.filters.ColorMatrixFilterNode;
import com.adobe.internal.fxg.dom.filters.DropShadowFilterNode;
import com.adobe.internal.fxg.dom.filters.GlowFilterNode;
import com.adobe.internal.fxg.dom.filters.GradientBevelFilterNode;
import com.adobe.internal.fxg.dom.filters.GradientGlowFilterNode;
import com.adobe.internal.fxg.dom.strokes.LinearGradientStrokeNode;
import com.adobe.internal.fxg.dom.strokes.RadialGradientStrokeNode;
import com.adobe.internal.fxg.dom.strokes.SolidColorStrokeNode;
import com.adobe.internal.fxg.dom.text.BRNode;
import com.adobe.internal.fxg.dom.text.ParagraphNode;
import com.adobe.internal.fxg.dom.text.SpanNode;
import com.adobe.internal.fxg.dom.transforms.ColorTransformNode;
import com.adobe.internal.fxg.dom.transforms.MatrixNode;

import static com.adobe.fxg.FXGConstants.*;

/**
 * FXGVersionHandler for FXG 1.0
 * 
 * @author Sujata Das
 */
public class FXG_v1_0_Handler extends AbstractFXGVersionHandler
{

    private boolean initialized = false;

    protected FXG_v1_0_Handler()
    {
        super();
        handlerVersion = FXGVersion.v1_0;
    }

    /**
     * initializes the version handler with FXG 1.0 specific information
     * 
     * @override
     */
    protected void init()
    {
        if (initialized)
            return;

        Map<String, Class<? extends FXGNode>> elementNodes = new HashMap<String, Class<? extends FXGNode>>(DEFAULT_FXG_1_0_NODES.size() + 4);
        elementNodes.putAll(DEFAULT_FXG_1_0_NODES);
        elementNodesByURI = new HashMap<String, Map<String, Class<? extends FXGNode>>>(1);
        elementNodesByURI.put(FXG_NAMESPACE, elementNodes);

        // Skip <Private> by default for FXG 1.0
        HashSet<String> skippedElements = new HashSet<String>(1);
        skippedElements.add(FXG_PRIVATE_ELEMENT);
        skippedElementsByURI = new HashMap<String, Set<String>>(1);
        skippedElementsByURI.put(FXG_NAMESPACE, skippedElements);

        initialized = true;
    }

    /**
     * The default FXGNode Classes to handle elements in the FXG 1.0 namespace
     * i.e. http://ns.adobe.com/fxg/2008
     */
    public static Map<String, Class<? extends FXGNode>> DEFAULT_FXG_1_0_NODES = new HashMap<String, Class<? extends FXGNode>>();
    static
    {
        DEFAULT_FXG_1_0_NODES.put(FXG_GRAPHIC_ELEMENT, GraphicNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_DEFINITION_ELEMENT, DefinitionNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_LIBRARY_ELEMENT, LibraryNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_BEVELFILTER_ELEMENT, BevelFilterNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_BITMAPFILL_ELEMENT, BitmapFillNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_BITMAPGRAPHIC_ELEMENT, BitmapGraphicNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_BLURFILTER_ELEMENT, BlurFilterNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_BR_ELEMENT, BRNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_COLORMATRIXFILTER_ELEMENT, ColorMatrixFilterNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_COLORTRANSFORM_ELEMENT, ColorTransformNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_DROPSHADOWFILTER_ELEMENT, DropShadowFilterNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_ELLIPSE_ELEMENT, EllipseNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_GLOWFILTER_ELEMENT, GlowFilterNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_GRADIENTENTRY_ELEMENT, GradientEntryNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_GRADIENTBEVELFILTER_ELEMENT, GradientBevelFilterNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_GRADIENTGLOWFILTER_ELEMENT, GradientGlowFilterNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_GROUP_ELEMENT, GroupNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_LINE_ELEMENT, LineNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_LINEARGRADIENT_ELEMENT, LinearGradientFillNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_LINEARGRADIENTSTROKE_ELEMENT, LinearGradientStrokeNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_MATRIX_ELEMENT, MatrixNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_P_ELEMENT, ParagraphNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_PATH_ELEMENT, PathNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_RADIALGRADIENT_ELEMENT, RadialGradientFillNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_RADIALGRADIENTSTROKE_ELEMENT, RadialGradientStrokeNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_RECT_ELEMENT, RectNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_SOLIDCOLOR_ELEMENT, SolidColorFillNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_SOLIDCOLORSTROKE_ELEMENT, SolidColorStrokeNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_SPAN_ELEMENT, SpanNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_TEXTGRAPHIC_ELEMENT, TextGraphicNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_TRANSFORM_ELEMENT, DelegateNode.class);

        // Special delegate property nodes
        DEFAULT_FXG_1_0_NODES.put(FXG_COLORTRANSFORM_PROPERTY_ELEMENT, DelegateNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_CONTENT_PROPERTY_ELEMENT, ContentPropertyNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_FILL_PROPERTY_ELEMENT, DelegateNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_FILTERS_PROPERTY_ELEMENT, DelegateNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_MASK_PROPERTY_ELEMENT, MaskPropertyNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_MATRIX_PROPERTY_ELEMENT, DelegateNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_STROKE_PROPERTY_ELEMENT, DelegateNode.class);
        DEFAULT_FXG_1_0_NODES.put(FXG_TRANSFORM_PROPERTY_ELEMENT, DelegateNode.class);

        // Special nodes
        DEFAULT_FXG_1_0_NODES.put(FXG_GROUP_DEFINITION_ELEMENT, GroupDefinitionNode.class);
    }

}
