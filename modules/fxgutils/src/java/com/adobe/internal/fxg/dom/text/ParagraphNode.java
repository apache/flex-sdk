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

package com.adobe.internal.fxg.dom.text;

import java.util.ArrayList;

import static com.adobe.fxg.FXGConstants.*;

import com.adobe.fxg.FXGException;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.internal.fxg.dom.CDATANode;
import com.adobe.internal.fxg.dom.DOMParserHelper;
import com.adobe.internal.fxg.dom.TextNode;

/**
 * Represents a &lt;p /&gt; child tag of FXG &lt;TextGraphic&gt; content. A
 * &lt;p&gt; tag starts a new paragraph in text content.
 * 
 * @author Peter Farland
 */
public class ParagraphNode extends AbstractCharacterTextNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    // Paragraph Attributes
    /** Paragraph Attribute: The text align. */
    public String textAlign = "left";
    
    /** Paragraph Attribute: The text align last. */
    public String textAlignLast = "left";
    
    /** Paragraph Attribute: The text indent. */
    public double textIndent = 0.0;
    
    /** Paragraph Attribute: The margin left. */
    public double marginLeft = 0.0;
    
    /** Paragraph Attribute: The margin right. */
    public double marginRight = 0.0;
    
    /** Paragraph Attribute: The margin top. */
    public double marginTop = 0.0;
    
    /** Paragraph Attribute: The margin bottom. */
    public double marginBottom = 0.0;
    
    /** Paragraph Attribute: The direction. */
    public String direction = "ltr";
    
    /** Paragraph Attribute: The block progression. */
    public String blockProgression = "tb";

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * A &lt;p&gt; allows child &lt;span&gt; and &lt;br /&gt; tags, as
     * well as character data (text content).
     * 
     * @param child the child
     */
    @Override
    public void addChild(FXGNode child)
    {
        if (child instanceof BRNode
                || child instanceof SpanNode
                || child instanceof CDATANode)
        {
            if (content == null)
                content = new ArrayList<TextNode>();

            content.add((TextNode)child);
        }
        else 
        {
            super.addChild(child);
        }
    }

    /**
     * Gets the node name.
     * 
     * @return The unqualified name of a paragraph node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_P_ELEMENT;
    }

    /**
     * This implementation processes paragraph attributes that are relevant to
     * the &lt;p&gt; tag, as well as delegates to the parent class to process
     * character attributes that are also relevant to the &lt;p&gt; tag.
     * Delegates to the 
     * parent class to process attributes that are not in the list below.
     * <p>
     * Paragraph attributes include:
     * <ul>
     * <li><b>textAlign</b> (String): [left, center, right, justify]  The
     * alignment of the text relative to the text box edges. Default is left.</li>
     * <li><b>textAlignLast</b> (String): [left, center, right, justify]: The
     * alignment of the last line of the paragraph, applies if textAlign is
     * justify. Default is left.</li>
     * <li><b>textIndent</b> (Number): The indentation of the first line of
     * text in a paragraph. The indent is relative to the left margin.
     * Measured in pixels. Default is 0. Can be negative.</li>
     * <li><b>marginLeft</b> (Number): The indentation applied to the left edge.
     * Measured in pixels. Default is 0.</li>
     * <li><b>marginRight</b> (Number): The indentation applied to the right
     * edge. Measured in pixels. Default is 0.</li>
     * <li><b>marginTop</b> (Number): This is the "space before" the paragraph.
     * Default is 0. Minimum is 0.</li>
     * <li><b>marginBottom</b> (Number): This is the "spaceAfter" the paragraph.
     * Default is 0. Minimum is 0.</li>
     * <li><b>direction</b> (String): [ltr, rtl] Controls the dominant writing
     * direction for the paragraphs (left-to-right or right-to-left), Default
     * is ltr.</li>
     * <li><b>blockProgression</b> (String): [tb, rl] Controls the direction in which
     * lines are stacked.</li>
     * </ul>
     * </p>
     * 
     * @param name the attribute name
     * @param value the attribute value
     * 
     * @throws FXGException if a value is out of the valid range.
     * @see com.adobe.internal.fxg.dom.text.AbstractTextNode#addChild(FXGNode)
     */
    @Override
    public void setAttribute(String name, String value)
    {
        if (FXG_TEXTALIGN_ATTRIBUTE.equals(name))
        {
            textAlign = value;
        }
        else if (FXG_TEXTALIGNLAST_ATTRIBUTE.equals(name))
        {
            textAlignLast = value;
        }
        else if (FXG_TEXTINDENT_ATTRIBUTE.equals(name))
        {
            textIndent = DOMParserHelper.parseDouble(this, value, name);
        }
        else if (FXG_MARGINLEFT_ATTRIBUTE.equals(name))
        {
            marginLeft = DOMParserHelper.parseDouble(this, value, name);
        }
        else if (FXG_MARGINRIGHT_ATTRIBUTE.equals(name))
        {
            marginRight = DOMParserHelper.parseDouble(this, value, name);
        }
        else if (FXG_MARGINTOP_ATTRIBUTE.equals(name))
        {
            marginTop = DOMParserHelper.parseDouble(this, value, name);
        }
        else if (FXG_MARGINBOTTOM_ATTRIBUTE.equals(name))
        {
            marginBottom = DOMParserHelper.parseDouble(this, value, name);
        }
        else if (FXG_DIRECTION_ATTRIBUTE.equals(name))
        {
            direction = value;
        }
        else if (FXG_BLOCKPROGRESSION_ATTRIBUTE.equals(name))
        {
            blockProgression = value;
        }
        else
        {
            super.setAttribute(name, value);
            return;
        }

        // Remember that this attribute was set on this node.
        rememberAttribute(name, value);
    }
}
