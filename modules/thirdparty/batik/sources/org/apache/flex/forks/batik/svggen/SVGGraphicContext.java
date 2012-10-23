/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.svggen;

import java.util.HashMap;
import java.util.Map;

import org.apache.flex.forks.batik.ext.awt.g2d.TransformStackElement;
import org.apache.flex.forks.batik.util.SVGConstants;

/**
 * Represents the SVG equivalent of a Java 2D API graphic
 * context attribute.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGGraphicContext.java 478176 2006-11-22 14:50:50Z dvholten $
 */
public class SVGGraphicContext implements SVGConstants, ErrorConstants {
    // this properties can only be set of leaf nodes =>
    // if they have default values they can be ignored
    private static final String[] leafOnlyAttributes = {
        SVG_OPACITY_ATTRIBUTE,
        SVG_FILTER_ATTRIBUTE,
        SVG_CLIP_PATH_ATTRIBUTE
    };

    private static final String[] defaultValues = {
        "1",
        SVG_NONE_VALUE,
        SVG_NONE_VALUE
    };

    private Map context;
    private Map groupContext;
    private Map graphicElementContext;
    private TransformStackElement[] transformStack;

    /**
     * @param context Set of style attributes in this context.
     * @param transformStack Sequence of transforms that where
     *        applied to create the context's current transform.
     */
    public SVGGraphicContext(Map context,
                             TransformStackElement[] transformStack) {
        if (context == null)
            throw new SVGGraphics2DRuntimeException(ERR_MAP_NULL);
        if (transformStack == null)
            throw new SVGGraphics2DRuntimeException(ERR_TRANS_NULL);
        this.context = context;
        this.transformStack = transformStack;
        computeGroupAndGraphicElementContext();
    }

    /**
     * @param groupContext Set of attributes that apply to group
     * @param graphicElementContext Set of attributes that apply to
     *        elements but not to groups (e.g., opacity, filter).
     * @param transformStack Sequence of transforms that where
     *        applied to create the context's current transform.
     */
    public SVGGraphicContext(Map groupContext, Map graphicElementContext,
                             TransformStackElement[] transformStack) {
        if (groupContext == null || graphicElementContext == null)
            throw new SVGGraphics2DRuntimeException(ERR_MAP_NULL);
        if (transformStack == null)
            throw new SVGGraphics2DRuntimeException(ERR_TRANS_NULL);

        this.groupContext = groupContext;
        this.graphicElementContext = graphicElementContext;
        this.transformStack = transformStack;
        computeContext();
    }


    /**
     * @return set of all attributes.
     */
    public Map getContext() {
        return context;
    }

    /**
     * @return set of attributes that can be set on a group
     */
    public Map getGroupContext() {
        return groupContext;
    }

    /**
     * @return set of attributes that can be set on leaf node
     */
    public Map getGraphicElementContext() {
        return graphicElementContext;
    }

    /**
     * @return set of TransformStackElement for this context
     */
    public TransformStackElement[] getTransformStack() {
        return transformStack;
    }

    private void computeContext() {
        if (context != null)
            return;

        context = new HashMap(groupContext);
        context.putAll(graphicElementContext);
    }

    private void computeGroupAndGraphicElementContext() {
        if (groupContext != null)
            return;
        //
        // Now, move attributes that only apply to
        // leaf elements to a separate map.
        //
        groupContext = new HashMap(context);
        graphicElementContext = new HashMap();
        for (int i=0; i< leafOnlyAttributes.length; i++) {
            Object attrValue = groupContext.get(leafOnlyAttributes[i]);
            if (attrValue != null){
                if (!attrValue.equals(defaultValues[i]))
                    graphicElementContext.put(leafOnlyAttributes[i], attrValue);
                groupContext.remove(leafOnlyAttributes[i]);
            }
        }
    }
}
