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

import static com.adobe.fxg.FXGConstants.FXG_FONTFAMILY_ATTRIBUTE;
import static com.adobe.fxg.FXGConstants.FXG_MARGINBOTTOM_ATTRIBUTE;
import static com.adobe.fxg.FXGConstants.FXG_MARGINLEFT_ATTRIBUTE;
import static com.adobe.fxg.FXGConstants.FXG_MARGINRIGHT_ATTRIBUTE;
import static com.adobe.fxg.FXGConstants.FXG_MARGINTOP_ATTRIBUTE;
import static com.adobe.fxg.FXGConstants.FXG_TRACKING_ATTRIBUTE;

import com.adobe.fxg.dom.FXGNode;
import com.adobe.internal.fxg.dom.GraphicContext;
import com.adobe.internal.fxg.dom.TextGraphicNode;

/**
 * A Flex specific override for TextGraphicNode used to capture the 
 * attributes specified on a &lt;TextGraphic&gt; node in FXG 1.0.
 * 
 * @author Peter Farland
 * @since FXG 1.0
 */
public class FlexTextGraphicNode extends TextGraphicNode
{
    private static final String FXG_TRACKING_RIGHT_PROPERTY = "trackingRight"; 
    private static final String FXG_PARAGRAPH_START_INDENT_PROPERTY = "paragraphStartIndent";
    private static final String FXG_PARAGRAPH_SPACE_BEFORE_PROPERTY = "paragraphSpaceBefore";
    private static final String FXG_PARAGRAPH_END_INDENT_PROPERTY = "paragraphEndIndent";
    private static final String FXG_PARAGRAPH_SPACE_AFT_PROPERTY = "paragraphSpaceAft";

    private static final String DEFAULT_FXG_FONT_FAMILY = "Times New Roman";

    /**
     * Constructor.
     */
    public FlexTextGraphicNode()
    {
        super();
        // Set TextGraphic defaults that should always be set. 
        setAttribute(FXG_FONTFAMILY_ATTRIBUTE, DEFAULT_FXG_FONT_FAMILY);
    }

    /**
     * Flex specific override to keep track of the attributes set on this
     * TextGraphic node.
     * 
     * @param name the attribute name
     * @param value the attribute value
     * @see TextGraphicNode#setAttribute(String, String)
     * @see AbstractTextNode#setAttribute(String, String)
     */
    @Override
    public void setAttribute(String name, String value)
    {
        super.setAttribute(name, value);

        // Translate FXG attributes to equivalent Flex properties
        String newName = FlexTextGraphicNode.translateAttribute(name);
        if (!name.equals(newName))
        {
            if (textAttributes != null)
                textAttributes.remove(name);

            rememberAttribute(newName, value);
        }
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
     * Since TextGraphic is converted to a sprite based ActionScript class
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

    /**
     * Converts an FXG attribute name to a Flex property name.
     *  
     * @param name
     */
    static String translateAttribute(String name)
    {
        if (FXG_TRACKING_ATTRIBUTE.equals(name))
            name = FXG_TRACKING_RIGHT_PROPERTY;
        else if (FXG_MARGINLEFT_ATTRIBUTE.equals(name))
            name = FXG_PARAGRAPH_START_INDENT_PROPERTY;
        else if (FXG_MARGINTOP_ATTRIBUTE.equals(name))
            name = FXG_PARAGRAPH_SPACE_BEFORE_PROPERTY;
        else if (FXG_MARGINRIGHT_ATTRIBUTE.equals(name))
            name = FXG_PARAGRAPH_END_INDENT_PROPERTY;
        else if (FXG_MARGINBOTTOM_ATTRIBUTE.equals(name))
            name = FXG_PARAGRAPH_SPACE_AFT_PROPERTY;

        return name;
    }
}
