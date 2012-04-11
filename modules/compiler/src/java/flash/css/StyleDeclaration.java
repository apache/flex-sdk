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

package flash.css;

import org.w3c.css.sac.LexicalUnit;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

/**
 * This class functions as a context for a rule's style declaration block. An
 * instance is created for each Selector. This class describes the subject,
 * selector and "style" property declarations.
 * 
 * Update: A list of style declaration blocks were introduced to support media
 * queries. See: {@link flash.css.StyleDeclarationBlock}
 * 
 * A summary of the style class hierarchy at compile time is as follows:
 * 
 * <pre>
 * StyleSheet
 *   StyleRule[]
 *     SelectorList
 *       Selector[]
 *         (each Selector subject)  --&gt;  StyleDef 
 *                                            StyleDeclaration[] * you are here
 *                                              StyleDeclarationBlock[]
 *                                                StyleProperty[]
 * </pre>
 * 
 * The compiler re-organizes the list of Selectors by "subject" (the right most
 * simple type selector in a potential chain of selectors). The same subject
 * may appear in many Selectors. The compiler creates a StyleDef per subject
 * and maintains a collection of StyleDeclarations from each relevant Selector.
 * 
 * TODO: For now, StyleDef converts the Descriptors which are heavily tied to
 * the SAC based CSS parser, into simpler StyleProperty instances for
 * ActionScript code gen. It would be nice if this was encapsulated and not a
 * concern of StyleDef.
 *
 * @author Peter Farland
 */
public class StyleDeclaration
{
    private int lineNumber;
    private String path;
    private String subject;
    private StyleSelector selector;
    private Map<String, StyleDeclarationBlock> blockCache;
    private List<StyleDeclarationBlock> declarationBlocks;

    // Cache of the original Descriptors that have the raw values parsed by Batik
    private Map<String, Descriptor> descriptors;

    /**
     * Constructor.
     * 
     * @param path - Source path of the containing style sheet.
     * @param lineNumber - line number on which the style declaration started.
     */
    public StyleDeclaration(String path, int lineNumber)
    {
        this.path = path;
        this.lineNumber = lineNumber;
        blockCache = new HashMap<String, StyleDeclarationBlock>(2);
        declarationBlocks = new ArrayList<StyleDeclarationBlock>(2);

        descriptors = new LinkedHashMap<String, Descriptor>();
    }

    /**
     * @return path to the owning style sheet source file.
     */
    public String getPath()
    {
        return path;
    }

    /**
     * The line number in the source on which this style declaration started.  
     * (Used in error reporting).
     */
    public int getLineNumber()
    {
        return lineNumber;
    }

    public void setLineNumber(int lineNumber)
    {
        this.lineNumber = lineNumber;
    }

    //--------------------------------------------------------------------------
    //
    // Methods used for ActionScript styles code generation
    //
    //--------------------------------------------------------------------------

    /**
     * @return The subject of the selector associated with this style
     * declaration.
     */
    public String getSubject()
    {
        return subject;
    }

    /**
     * Set the subject of the selector associated with this style declaration.
     * 
     * @param subject - the right most simple type selector in a potential
     * chain of selectors.
     */
    public void setSubject(String subject)
    {
        this.subject = subject;
    }

    /**
     * A selector of the rule that is associated with this style declaration. 
     */
    public StyleSelector getSelector()
    {
        return selector;
    }

    /**
     * 
     * @param selector
     */
    public void setSelector(StyleSelector selector)
    {
        this.selector = selector;
    }

    /**
     * @return true if any style declaration blocks declare at least one
     * property, otherwise false.
     */
    public boolean hasProperties()
    {
        for (StyleDeclarationBlock block : declarationBlocks)
        {
            if (block.getProperties().size() > 0)
                return true;
        }

        return false;
    }

    /**
     * @return true if any style declaration blocks declare at least one
     * effect property, otherwise false.
     */
    public boolean hasEffectStyles()
    {
        for (StyleDeclarationBlock block : declarationBlocks)
        {
            if (block.getEffectStyles().size() > 0)
                return true;
        }

        return false;
    }

    /**
     * @return a list of potentially several declaration blocks.
     */
    public List<StyleDeclarationBlock> getDeclarationBlocks()
    {
        return declarationBlocks;
    }

    /**
     * StyleDeclarations may be merged into other StyleDeclarations
     * by the compiler, so this method compares the selector and media-list to
     * determine whether a declaration block already exists for these given 
     * values.
     * 
     * @param selector - selector associated with the StyleDeclaration to
     * be merged into this StyleDeclaration.
     * @param mediaList - optional list of media queries restricting when this
     * style declaration block applies at runtime. Can be null.
     * 
     * @return a new StyleDeclarationBlock
     */
    public StyleDeclarationBlock getDeclarationBlock(StyleSelector selector, MediaList mediaList)
    {
        StyleDeclarationBlock block;

        // We don't merge a media list block as its properties conditionally
        // apply based on runtime capabilities... so, we return a new style
        // declaration block.
        if (mediaList != null)
        {
            block = new StyleDeclarationBlock(mediaList);    
            declarationBlocks.add(block);
        }
        else
        {
            String key = getDeclarationBlockKey(selector, mediaList);
            block = blockCache.get(key);
            if (block == null)
            {
                block = new StyleDeclarationBlock(mediaList);
                blockCache.put(key, block);
                declarationBlocks.add(block);
            }
        }

        return block;
    }

    /**
     * Generates a key to locate a cached style declaration block.
     * 
     * @param selector - a single CSS selector
     * @param mediaList - an @media rule
     * @return a String key for the given selector and media list.
     */
    private static String getDeclarationBlockKey(StyleSelector selector, MediaList mediaList)
    {
        StringBuilder sb = new StringBuilder();
        sb.append('(').append(selector.toString()).append(')');
        sb.append('(');
        if (mediaList != null)
        {
            for (String query : mediaList.getQueries())
            {
                sb.append(query);
            }
        }
        sb.append(')');
        return sb.toString();
    }

    //--------------------------------------------------------------------------
    //
    // Methods that keep track of the Descriptors found from SAC based CSS
    // parsing... These will eventually be converted into simpler StyleProperty
    // instances.
    //
    //--------------------------------------------------------------------------

    public Descriptor getDescriptorValue(String name)
    {
        return (Descriptor)descriptors.get(name);
    }

    public void setDescriptor(String propertyName, LexicalUnit value, String priority)
    {
        descriptors.put(propertyName, new Descriptor(propertyName, value, path));
    }

    public Descriptor removeDescriptor(String name)
    {
        return (Descriptor)descriptors.remove(name);
    }

    public Iterator<Entry<String, Descriptor>> iterator()
    {
        return descriptors.entrySet().iterator();
    }

    /**
     * Shallow copy of StyleDeclaration to allow for a list of multiple
     * selectors to share the same set of descriptors.
     */
    public StyleDeclaration shallowCopy()
    {
        StyleDeclaration decl = new StyleDeclaration(path, lineNumber);
        decl.subject = this.subject;
        decl.selector = this.selector;
        decl.descriptors = this.descriptors;
        //decl.blockCache = this.blockCache;
        //decl.declarationBlocks = this.declarationBlocks;
        return decl;
    }
}
