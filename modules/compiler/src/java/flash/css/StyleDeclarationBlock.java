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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * A StyleDeclarationBlock contains a collection of StyleProperty
 * declarations. This class was introduced to support "media queries" which
 * restrict when styles should be applied based on runtime capabilities at
 * startup, such as resolution. The media query is recorded on this data
 * structure to honor the existing generated ActionScript for the Flex
 * framework.
 * 
 * The existing generated code presents the compiler with an unfortunate
 * challenge because re-occurring selectors are merged into a single Flex
 * CSSStyleDeclaration in a function closure. This forces the media query to be
 * checked inside the closure for a subset of property declarations.
 * 
 * A summary of the style class hierarchy at compile time is as follows:
 * 
 * <pre>
 * StyleSheet
 *   StyleRule[]
 *     SelectorList
 *       Selector[]
 *         (each Selector subject)  --&gt;  StyleDef 
 *                                            StyleDeclaration[]
 *                                              StyleDeclarationBlock[]  * you are here
 *                                                StyleProperty[]
 * </pre>
 * 
 * The list of Selectors are re-organized by "subject" (the right most simple
 * type selector in a potential chain of selectors). The same subject may
 * appear in many Selectors. The compiler creates a StyleDef per subject and
 * maintains a collection of StyleDeclarations from each relevant Selector.
 */
public class StyleDeclarationBlock
{
    private MediaList mediaList;
    private Map<String, StyleProperty> properties;
    private List<String> effectStyles;

    /**
     * Constructor.
     * 
     * @param Optional media query to restrict whether these styles apply based
     * on device capabilities at runtime.
     */
    public StyleDeclarationBlock(MediaList mediaList)
    {
        this.mediaList = mediaList;
        // TODO: For backwards compatibility, this has to remain HashMap and
        // not an ordered map.
        properties = new HashMap<String, StyleProperty>();
        effectStyles = new ArrayList<String>();
    }

    /**
     * @return whether we have a media list for this style block.
     */
    public boolean hasMediaList()
    {
        return mediaList != null;
    }

    /**
     * @return an optional media list query that was set to restrict whether
     * these styles apply based on runtime capabilities.
     */
    public MediaList getMediaList()
    {
        return mediaList;
    }

    /**
     * @return the collection of property declarations for this style
     * declaration block.
     */
    public Map<String, StyleProperty> getProperties()
    {
        return properties;
    }

    /**
     * Override the collection of style properties for this style declaration 
     * block.
     * @param properties the new collection of style property declarations.
     */
    public void setProperties(Map<String, StyleProperty> properties)
    {
        this.properties = properties;
    }
    
    /**
     * @return the list of effects properties to be special cased by the
     * Flex framework at runtime. 
     */
    public List<String> getEffectStyles()
    {
        return effectStyles;
    }

    /**
     * Mark a style property as an effect style for special handling at runtime.
     * @param propertyName
     */
    public void addEffectStyle(String propertyName)
    {
        effectStyles.add(propertyName);
    }
}
