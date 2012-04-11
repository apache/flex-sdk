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

package flex2.compiler.fxg;

import com.adobe.fxg.dom.FXGNode;
import com.adobe.internal.fxg.dom.GraphicContext;
import com.adobe.internal.fxg.dom.RichTextNode;

/**
 * A Flex specific override for RichTextNode used to capture the 
 * attributes specified on a &lt;RichText&gt; node in FXG 2.0.
 * 
 * @author Peter Farland
 * @since FXG 2.0
 */
public class FlexRichTextNode extends RichTextNode
{
    /**
     * Constructor.
     */
    public FlexRichTextNode()
    {
        super();
    }

    /**
     * If the document root is a FlexGraphicNode, it records that the document
     * makes use of TextGraphic and thus will need to generate symbol classes to
     * programmatically draw the text (as there is no equivalent to TextGraphic
     * in SWF).
     */
    @Override
    public void setDocumentNode(FXGNode root)
    {
        super.setDocumentNode(root);

        if (root instanceof FlexGraphicNode)
        {
            ((FlexGraphicNode)root).hasText = true;
        }
    }

    /**
     * Since RichText is converted to a sprite based ActionScript class
     * and rendered using Flex's RichText API, we do not report
     * attributes on the graphic context that are going to be set as properties
     * in ActionScript (as otherwise you would end up with duplicate
     * transformations).
     * <p>
     * The ignored graphic context attributes include:
     * <pre>
     * x="..."
     * y="..."
     * scaleX="..."
     * scaleY="..."
     * rotation="..."
     * blendMode="..."
     * alpha="..."
     * </pre>
     * </p>
     */
    @Override
    public GraphicContext createGraphicContext()
    {
        GraphicContext graphicContext = new GraphicContext();

        if (colorTransform != null)
        {
            graphicContext.colorTransform = colorTransform;
        }

        if (filters != null)
            graphicContext.addFilters(filters);

        if (maskTypeSet)
            graphicContext.maskType = maskType;

        return graphicContext;
    }


}
