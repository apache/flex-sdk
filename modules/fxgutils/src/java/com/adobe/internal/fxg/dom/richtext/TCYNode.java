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
 * Represents a &lt;br /&gt; child tag of FXG &lt;RichText&gt; content. A
 * &lt;br /&gt; tag starts a new tcy in text content.
 * <p>
 * This is an empty tag - text content or child tags are not expected.
 * </p>
 * 
 * @since 2.0
 * @author Min Plunkett
 */
public class TCYNode extends AbstractRichTextLeafNode
{    
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

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
     * A tcy node can also have special child property nodes that represent
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
     * 
     * @return The unqualified name of a tcy node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_TCY_ELEMENT;
    }
    
    /**
     * Add a FXG child node to this TCY node. Supported child nodes
     * include text content nodes (e.g. &lt;span&gt;, &lt;br&gt;, 
     * &lt;tab&gt;, &lt;img&gt;, &lt;a&gt;, and CDATANode).
     * 
     * Note that link format nodes (e.g. linkNormalFormat, linkHoverFormat, and
     * linkActiveFormat) are complex properties rather than child nodes.
     * 
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
                || child instanceof LinkNode
                || child instanceof CDATANode)
        {
        	if (child instanceof LinkNode && (((LinkNode)child).href == null))
        	{
        		// Exception: Missing href attribute in <a> element.
                throw new FXGException(getStartLine(), getStartColumn(), "MissingHref");        		
        	}  
        	/**
        	 * When <a> has a <tcy> child, the <tcy> child is FORBIDDEN to have 
        	 * an <a> child of its own. AND vice versa. If a <tcy> has an <a> 
        	 * child, the <a> child is FORBIDDEN to have a <tcy> child.
        	 */
        	if (child instanceof LinkNode && this.parentNode instanceof LinkNode)
        	{
                // Exception: <tcy> element is forbidden as child of <a>, which 
        		// is child of another <tcy>. And vice versa.
                throw new FXGException(getStartLine(), getStartColumn(), "InvalidNestingElements");
        	}
            if (content == null)
                content = new ArrayList<TextNode>();

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
}
