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

package com.adobe.internal.fxg.dom;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.adobe.fxg.FXGConstants.*;

import com.adobe.fxg.FXGException;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.internal.fxg.dom.richtext.TextHelper;
import com.adobe.internal.fxg.dom.text.BRNode;
import com.adobe.internal.fxg.dom.CDATANode;
import com.adobe.internal.fxg.dom.text.ParagraphNode;
import com.adobe.internal.fxg.dom.text.SpanNode;
import com.adobe.internal.fxg.dom.text.AbstractCharacterTextNode;
import com.adobe.internal.fxg.dom.types.Kerning;
import com.adobe.internal.fxg.dom.types.LineBreak;
import com.adobe.internal.fxg.dom.types.WhiteSpaceCollapse;

/**
 * The Class TextGraphicNode.
 * 
 * @author Peter Farland
 */
public class TextGraphicNode extends GraphicContentNode implements TextNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    // Text Attributes
    /** The width. */
    public double width = 0.0;
    
    /** The height. */
    public double height = 0.0;
    
    /** The padding left. */
    public double paddingLeft = 0.0;
    
    /** The padding right. */
    public double paddingRight = 0.0;
    
    /** The padding bottom. */
    public double paddingBottom = 0.0;
    
    /** The padding top. */
    public double paddingTop = 0.0;

    // Character Attributes
    /** The font family. */
    public String fontFamily = "Times New Roman";
    
    /** The font size. */
    public double fontSize = 12.0;
    
    /** The font style. */
    public String fontStyle = "normal";
    
    /** The font weight. */
    public String fontWeight = "normal";
    
    /** The line height. */
    public double lineHeight = 120.0;
    
    /** The text decoration. */
    public String textDecoration = "none";
    
    /** The white space collapse. */
    public WhiteSpaceCollapse whiteSpaceCollapse = WhiteSpaceCollapse.PRESERVE;
    
    /** The line break. */
    public LineBreak lineBreak = LineBreak.TOFIT;
    
    /** The line through. */
    public boolean lineThrough = false;
    
    /** The tracking. */
    public double tracking = 0.0;
    
    /** The kerning. */
    public Kerning kerning = Kerning.AUTO;
    
    /** The text alpha. */
    public double textAlpha = 1.0;
    
    /** The color. */
    public int color = COLOR_BLACK;

    // Paragraph Attributes
    /** The text align. */
    public String textAlign = "left";
    
    /** The text align last. */
    public String textAlignLast = "left";
    
    /** The text indent. */
    public double textIndent = 0.0;
    
    /** The margin left. */
    public double marginLeft = 0.0;
    
    /** The margin right. */
    public double marginRight = 0.0;
    
    /** The margin top. */
    public double marginTop = 0.0;
    
    /** The margin bottom. */
    public double marginBottom = 0.0;
    
    /** The direction. */
    public String direction = "ltr";
    
    /** The block progression. */
    public String blockProgression = "tb";
    
    private boolean contiguous = false;

    //--------------------------------------------------------------------------
    //
    // Text Node Attribute Helpers
    //
    //--------------------------------------------------------------------------
    /**
     * The attributes set on this node.
     */
    protected Map<String, String> textAttributes;

    /**
     * Gets the text attributes.
     * 
     * @return A Map recording the attribute names and values set on this
     * text node.
     */
    public Map<String, String> getTextAttributes()
    {
        return textAttributes;
    }

    /**
     * This nodes child text nodes.
     */
    protected List<TextNode> content;

    /**
     * Gets the text children.
     * 
     * @return The List of child nodes of this text node.
     */
    public List<TextNode> getTextChildren()
    {
        return content;
    }

    /**
     * Gets the text properties.
     * 
     * @return The List of child property nodes of this text node.
     */
    public HashMap<String, TextNode> getTextProperties()
    {
        return null;
    }

    /**
     * A text node may also have special child property nodes that represent
     * complex property values that cannot be set via a simple attribute.
     * 
     * @param propertyName the property name
     * @param node the node
     */
    public void addTextProperty(String propertyName, TextNode node)
    {
        addChild(node);
    }

    /**
     * Remember that an attribute was set on this node.
     * 
     * @param name - the unqualified attribute name.
     * @param value - the attribute value.
     */
    protected void rememberAttribute(String name, String value)
    {
        if (textAttributes == null)
            textAttributes = new HashMap<String, String>(4);

        textAttributes.put(name, value);
    }

    /**
     * &lt;TextGraphic&gt; content allows child &lt;p&gt;, &lt;span&gt; and
     * &lt;br /&gt; tags, as well as character data (text content).
     * 
     * @param child - a child FXG node to be added to this node.
     * 
     * @throws FXGException if the child is not supported by this node.
     */
    public void addContentChild(FXGNode child)
    {
        if (child instanceof ParagraphNode
                || child instanceof BRNode
                || child instanceof SpanNode
                || child instanceof CDATANode)
        {
            if (content == null)
            {
                content = new ArrayList<TextNode>();
                contiguous = true;
            }
            
            if (!contiguous)
            {
            	throw new FXGException(child.getStartLine(), child.getStartColumn(), "InvalidTextGraphicContent");            	
            }

            content.add((TextNode)child);
        }
    }

    
    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * This method is invoked for only non-content children. Content needs to 
     * be contigous.
     * 
     * @param child - a child FXG node to be added to this node.
     * 
     * @throws FXGException if the child is not supported by this node.
     */
    @Override
    public void addChild(FXGNode child)
    {
    	if (child instanceof CDATANode)
        {
            if(TextHelper.ignorableWhitespace(((CDATANode)child).content))
            {
            	/**
            	 * Ignorable white spaces don't break content contiguous 
            	 * rule and should be ignored.
            	 */
            	return;
            }
            else
            {
            	throw new FXGException(child.getStartLine(), child.getStartColumn(), "InvalidTextGraphicContent");
            }
        }
        else 
        {
            super.addChild(child);
            contiguous = false;
        }
    }

    /**
     * Gets the node name.
     * 
     * @return The unqualified name of a TextGraphic node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_TEXTGRAPHIC_ELEMENT;
    }

    /**
     * Sets an FXG attribute on this TextGraphic node. Delegates to the parent 
     * class to process attributes that are not in the list below.
     * 
     * In addition to the attributes supported by all graphic content nodes,
     * TextGraphic supports the following attributes.
     * 
     * <p>
     * <ul>
     * <li><b>width</b> (Number): The width of the text box to render text
     * in.</li>
     * <li><b>height</b> (Number): The height of the text box to render text
     * in.</li>
     * <li><b>paddingLeft</b> (Number): Inset from left edge to content area.
     * Units in pixels, defaults to 0.</li>
     * <li><b>paddingRight</b> (Number): Inset from right edge to content area.
     * Units in pixels, defaults to 0.</li>
     * <li><b>paddingTop</b> (Number): Inset from top edge to content area.
     * Units in pixels, defaults to 0.</li>
     * <li><b>paddingBottom</b> (Number): Inset from bottom edge to content
     * area. Units in pixels, defaults to 0.</li>
     * </ul>
     * </p>
     * 
     * @param name - the unqualified attribute name.
     * @param value - the attribute value.
     * @throws FXGException if a value is out of the valid range.
     * @see com.adobe.internal.fxg.dom.GraphicContentNode#setAttribute(java.lang.String, java.lang.String)
     */
    @Override
    public void setAttribute(String name,  String value)
    {
        
        if (FXG_WIDTH_ATTRIBUTE.equals(name))
        {
            width = DOMParserHelper.parseDouble(this, value, name);
        }
        else if (FXG_HEIGHT_ATTRIBUTE.equals(name))
        {
            height = DOMParserHelper.parseDouble(this, value, name);
        }
        else if (FXG_PADDINGLEFT_ATTRIBUTE.equals(name))
        {
            paddingLeft = DOMParserHelper.parseDouble(this, value, name);
        }
        else if (FXG_PADDINGRIGHT_ATTRIBUTE.equals(name))
        {
            paddingRight = DOMParserHelper.parseDouble(this, value, name);
         }
        else if (FXG_PADDINGBOTTOM_ATTRIBUTE.equals(name))
        {
            paddingBottom = DOMParserHelper.parseDouble(this, value, name);
        }
        else if (FXG_PADDINGTOP_ATTRIBUTE.equals(name))
        {
            paddingTop = DOMParserHelper.parseDouble(this, value, name);
        }
        else if (FXG_FONTFAMILY_ATTRIBUTE.equals(name))
        {
            fontFamily = value;
        }
        else if (FXG_FONTSIZE_ATTRIBUTE.equals(name))
        {
            fontSize = DOMParserHelper.parseDouble(this, value, name);
        }
        else if (FXG_FONTSTYLE_ATTRIBUTE.equals(name))
        {
            fontStyle = value;
        }
        else if (FXG_FONTWEIGHT_ATTRIBUTE.equals(name))
        {
            fontWeight = value;
        }
        else if (FXG_LINEHEIGHT_ATTRIBUTE.equals(name))
        {
            lineHeight = DOMParserHelper.parsePercent(this, value, name);
        }
        else if (FXG_TEXTDECORATION_ATTRIBUTE.equals(name))
        {
            textDecoration = value;
        }
        else if (FXG_WHITESPACECOLLAPSE_ATTRIBUTE.equals(name))
        {
            whiteSpaceCollapse = AbstractCharacterTextNode.getWhiteSpaceCollapse(this, value);
        }
        else if (FXG_LINEBREAK_ATTRIBUTE.equals(name))
        {
            lineBreak = AbstractCharacterTextNode.getLineBreak(this, value);
        }
        else if (FXG_TRACKING_ATTRIBUTE.equals(name))
        {
            tracking = DOMParserHelper.parsePercent(this, value, name);
        }
        else if (FXG_KERNING_ATTRIBUTE.equals(name))
        {
            kerning = AbstractCharacterTextNode.getKerning(this, value);
        }
        else if (FXG_TEXTALPHA_ATTRIBUTE.equals(name))
        {
            textAlpha = DOMParserHelper.parseDouble(this, value, name, ALPHA_MIN_INCLUSIVE, ALPHA_MAX_INCLUSIVE, textAlpha);
        }
        else if (FXG_COLOR_ATTRIBUTE.equals(name))
        {
            color = DOMParserHelper.parseRGB(this, value, name);
        }
        else if (FXG_TEXTALIGN_ATTRIBUTE.equals(name))
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
        else if (FXG_X_ATTRIBUTE.equals(name))
        {
            x = DOMParserHelper.parseDouble(this, value, name);
            translateSet = true;
        }
        else if (FXG_Y_ATTRIBUTE.equals(name))
        {
            y = DOMParserHelper.parseDouble(this, value, name);
            translateSet = true;
        }
        else if (FXG_ROTATION_ATTRIBUTE.equals(name))
        {
            rotation = DOMParserHelper.parseDouble(this, value, name);
            rotationSet = true;
        }
        else if (FXG_SCALEX_ATTRIBUTE.equals(name))
        {
            scaleX = DOMParserHelper.parseDouble(this, value, name);
            scaleSet = true;
        }
        else if (FXG_SCALEY_ATTRIBUTE.equals(name))
        {
            scaleY = DOMParserHelper.parseDouble(this, value, name);
            scaleSet = true;
        }
        else if (FXG_ALPHA_ATTRIBUTE.equals(name))
        {
            alpha = DOMParserHelper.parseDouble(this, value, name, ALPHA_MIN_INCLUSIVE, ALPHA_MAX_INCLUSIVE, alpha);
            alphaSet = true;
        }
        else if (FXG_BLENDMODE_ATTRIBUTE.equals(name))
        {
            blendMode = parseBlendMode(this, value, blendMode);
        }
        else if (FXG_MASKTYPE_ATTRIBUTE.equals(name))
        {
            maskType = DOMParserHelper.parseMaskType(this, value, name, maskType);
            maskTypeSet = true;
        }
        else if (FXG_VISIBLE_ATTRIBUTE.equals(name))
        {
            visible = DOMParserHelper.parseBoolean(this, value, name);
        }      
        else if ( FXG_LINETHROUGH_ATTRIBUTE.equals(name))
        {
            lineThrough = DOMParserHelper.parseBoolean(this, value, name);
        }        
        else if (FXG_ID_ATTRIBUTE.equals(name))
        {
            //id = value;
        }
        else
        {
        	//Exception:Attribute, {0}, not supported by node: {1}.
            throw new FXGException(getStartLine(), getStartColumn(), "InvalidNodeAttribute", name, getNodeName());
        }
        
        // Remember attribute was set on this node.
        rememberAttribute(name, value);                
    }
}
