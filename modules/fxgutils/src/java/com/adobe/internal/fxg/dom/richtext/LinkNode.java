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

package com.adobe.internal.fxg.dom.richtext;

import static com.adobe.fxg.FXGConstants.*;

import java.util.ArrayList;
import java.util.HashMap;

import com.adobe.fxg.FXGException;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.internal.fxg.dom.CDATANode;
import com.adobe.internal.fxg.dom.TextNode;

/**
 * Represents a &lt;p /&gt; FXG link node.
 * 
 * @since 2.0
 * @author Min Plunkett
 */
public class LinkNode extends AbstractRichTextLeafNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    // Link attributes
    /** Link attribute: The href. */
    public String href;  // Required
    
    /** Link attribute: The target. */
    public String target = "";
    
    // Link format properties
    /** Link format property: The link normal format. */
    public TextLayoutFormatNode linkNormalFormat = null;
    
    /** Link format property: The link hover format. */
    public TextLayoutFormatNode linkHoverFormat = null;
    
    /** Link format property: The link active format. */
    public TextLayoutFormatNode linkActiveFormat = null;    

    //--------------------------------------------------------------------------
    //
    // TextNode Helpers
    //
    //--------------------------------------------------------------------------

    /**
     * This node's child property nodes.
     */
    protected HashMap<String, TextNode> properties;

    /**
     * Gets the text properties.
     * 
     * @return The List of child property nodes of this text node.
     */
    public HashMap<String, TextNode> getTextProperties()
    {
        return properties;
    }

    /**
     * A link node can also have special child property nodes that represent
     * complex property values that cannot be set via a simple attribute.
     * 
     * @param propertyName the property name
     * @param node the node
     */
    public void addTextProperty(String propertyName, TextNode node)
    {
        if (node instanceof TextLayoutFormatNode)
        {
            if (FXG_LINKACTIVEFORMAT_PROPERTY_ELEMENT.equals(propertyName))
            {
                if (linkActiveFormat == null)
                {
                    linkActiveFormat = (TextLayoutFormatNode)node;
                    linkActiveFormat.setParent(this);

                    if (properties == null)
                        properties = new HashMap<String, TextNode>(3);
                    properties.put(propertyName, linkActiveFormat);
                }
                else
                {
                    // Exception: Multiple LinkFormat elements are not allowed.
                    throw new FXGException(getStartLine(), getStartColumn(), "MultipleLinkFormatElements");
                }
            }
            else if (FXG_LINKHOVERFORMAT_PROPERTY_ELEMENT.equals(propertyName))
            {
                if (linkHoverFormat == null)
                {
                    linkHoverFormat = (TextLayoutFormatNode)node;
                    linkHoverFormat.setParent(this);

                    if (properties == null)
                        properties = new HashMap<String, TextNode>(3);
                    properties.put(propertyName, linkHoverFormat);
                }
                else
                {
                    // Exception: Multiple LinkFormat elements are not allowed.
                    throw new FXGException(getStartLine(), getStartColumn(), "MultipleLinkFormatElements");
                }
            }
            else if (FXG_LINKNORMALFORMAT_PROPERTY_ELEMENT.equals(propertyName))
            {
                if (linkNormalFormat == null)
                {
                    linkNormalFormat = (TextLayoutFormatNode)node;
                    linkNormalFormat.setParent(this);

                    if (properties == null)
                        properties = new HashMap<String, TextNode>(3);
                    properties.put(propertyName, linkNormalFormat);
                }
                else
                {
                    // Exception: Multiple LinkFormat elements are not allowed. 
                    throw new FXGException(getStartLine(), getStartColumn(), "MultipleLinkFormatElements");
                }
            }
            else
            {
                // Exception: Unknown LinkFormat element. 
                throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownLinkFormat", propertyName);
            }
        }
        else
        {
            super.addTextProperty(propertyName, node);
        }
    }


    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /** 
     * Gets the node name.
     * @return The unqualified name of a link node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_A_ELEMENT;
    }

    /**
     * Add a FXG child node to this link node. Supported child nodes
     * include text content nodes: &lt;span&gt;, 
     * &lt;tab&gt;, &lt;img&gt;, &lt;tcy&gt; and CDATANode.
     * @param child - a child FXG node to be added to this node.
     * 
     * @throws FXGException if the child is not supported by this node.
     * @see com.adobe.internal.fxg.dom.richtext.AbstractRichTextNode#addChild(FXGNode)
     */
    @Override
    public void addChild(FXGNode child)
    {
        if (child instanceof SpanNode
                || child instanceof BRNode
                || child instanceof TabNode
                || child instanceof ImgNode
                || child instanceof TCYNode
                || child instanceof CDATANode)
        {
        	/**
        	 * When <a> has a <tcy> child, the <tcy> child is FORBIDDEN to have 
        	 * an <a> child of its own. AND vice versa. If a <tcy> has an <a> 
        	 * child, the <a> child is FORBIDDEN to have a <tcy> child.
        	 */
        	if (child instanceof TCYNode && this.parentNode instanceof TCYNode)
        	{
                // Exception: <tcy> element is forbidden as child of <a>, which 
        		// is child of another <tcy>. And vice versa.
                throw new FXGException(getStartLine(), getStartColumn(), "InvalidNestingElements");
        	}
            if (content == null)
            {
                content = new ArrayList<TextNode>();
            }
            content.add((TextNode)child);
        }
        else 
        {
            super.addChild(child);
            return;
        }

        if (child instanceof AbstractRichTextNode)
        	((AbstractRichTextNode)child).setParent(this);                
    }

    /**
     * This implementation processes link attributes that are relevant to
     * the &lt;a&gt; tag, as well as delegates to the parent class to process
     * character attributes that are also relevant to the &lt;a&gt; tag.
     * 
     * @param name the attribute name
     * @param value the attribute value
     * 
     * @see com.adobe.internal.fxg.dom.richtext.AbstractRichTextLeafNode#setAttribute(String, String)
     */
    @Override
    public void setAttribute(String name, String value)
    {
        if (FXG_HREF_ATTRIBUTE.equals(name))
        {
            href = value;
        }
        else if(FXG_TARGET_ATTRIBUTE.equals(name))
        {
            target = value;
        }
        else
        {
            super.setAttribute(name, value);
            return;
        }

        // Remember attribute was set on this node.
        rememberAttribute(name, value);        
    }
}
