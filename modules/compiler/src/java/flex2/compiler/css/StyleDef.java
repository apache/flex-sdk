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

package flex2.compiler.css;

import flash.css.Descriptor;
import flash.css.MediaList;
import flash.css.StyleDeclaration;
import flash.css.StyleDeclarationBlock;
import flash.css.StyleProperty;
import flash.css.StyleSelector;
import flex2.compiler.Source;
import flex2.compiler.mxml.MxmlConfiguration;
import flex2.compiler.mxml.lang.FrameworkDefs;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.rep.AtEmbed;
import flex2.compiler.mxml.rep.MxmlDocument;
import flex2.compiler.util.CompilerMessage.CompilerError;
import flex2.compiler.util.ThreadLocalToolkit;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;

import macromedia.asc.util.ContextStatics;

import org.w3c.css.sac.LexicalUnit;

/**
 * A helper class to aggregate style declarations for a particular subject
 * (essentially a "type" or in Flex's case, a "component", or the special case
 * of 'global' which applies to all components).
 * 
 * From Flex 4 onwards, advanced selector support was added which changes the
 * focus of this class and it must now consider multiple style declarations
 * for a given subject. In Flex 3 the style declaration would only apply to a
 * single type:
 * 
 *     Button { color: #FF0000; }
 * 
 * or a universal class selector:
 * 
 *     .special { color:#FF9900; }
 * 
 * In Flex 4, real class selectors are supported on a type-by-type basis and 
 * many selectors can target a type:
 * 
 *     Button { color: #FF0000; }
 *     Button.special { color: #0000FF; }
 *     VBox Panel Button { color: #FF0000; }
 *     Button#clickButton { color: #CCCCCC; }
 * 
 * These declarations are used to emit an ActionScript class for the subject
 * which is linked into the top level application as a mix-in as needed.
 * 
 * This class is complicated by the fact that it supports both Flex 3 and
 * Flex 4 style subsystems independently.
 *
 * @author Paul Reilly
 * @author Pete Farland
 */
public class StyleDef
{
    private String subject;
    private List<String> effectStyles = new ArrayList<String>();

    // Flex 4 properties
    private Map<String, StyleDeclaration> declarations;
    private boolean advanced;

    // Deprecated Flex 3 properties
    private boolean isTypeSelector;
    private Map<String, StyleProperty> styles = new HashMap<String, StyleProperty>();

    private MxmlDocument mxmlDocument;
    private MxmlConfiguration mxmlConfiguration;    // may be null if passed in from a StyleModule
    private Source source;
    private int lineNumber;
    private ContextStatics perCompileData;

    private static final String CLASS_REFERENCE = "ClassReference(";
    private static final String EMBED = "Embed(";
    public static final String GLOBAL = "global"; // A special Flex root selector
    public static final String UNIVERSAL = "*";
    private static final String PROPERTY_REFERENCE = "PropertyReference(";

    // Flex 4 Constructor
    StyleDef(String subject,
            MxmlDocument mxmlDocument,
            MxmlConfiguration mxmlConfiguration,
            Source source,
            int lineNumber,
            ContextStatics perCompileData)
   {
       this.subject = subject;
       this.mxmlDocument = mxmlDocument;
       this.mxmlConfiguration = mxmlConfiguration;
       this.source = source;
       this.lineNumber = lineNumber;
       this.perCompileData = perCompileData;
       advanced = true;
       isTypeSelector = !GLOBAL.equals(subject) && !UNIVERSAL.equals(subject);
   }

    // Deprecated Flex 3 Constructor
    StyleDef(String name,
             boolean isTypeSelector,
             MxmlDocument mxmlDocument,
             MxmlConfiguration mxmlConfiguration,
             Source source,
             int lineNumber,
             ContextStatics perCompileData)
    {
        this.subject = name;
        this.isTypeSelector = isTypeSelector;
        this.mxmlDocument = mxmlDocument;
        this.mxmlConfiguration = mxmlConfiguration;
        this.source = source;
        this.lineNumber = lineNumber;
        this.perCompileData = perCompileData;
    }

    //--------------------------------------------------------------------------
    //
    // Flex 4 Entry Point
    //
    //--------------------------------------------------------------------------

    /**
     * Flex 4 method of declaring styles using advanced selectors, including
     * type selectors, conditional class, id or pseudo-class (states) selectors,
     * and descendant selectors.
     * 
     * This method assumes the selector applies to the subject of this StyleDef.
     * 
     * @param declaration The style declaration for this rule (which contains
     * the list of property descriptors).
     */
    void addAdvancedDeclaration(StyleDeclaration declaration, MediaList mediaList)
    {
        if (declarations == null)
            declarations = new LinkedHashMap<String, StyleDeclaration>();

        StyleSelector selector = declaration.getSelector();
        String selectorString = selector.toString();
        StyleDeclaration existingDeclaration = declarations.get(selectorString);
        // This may be the first time we've seen this declaration
        if (existingDeclaration == null)
        {
            existingDeclaration = declaration;
            declarations.put(selectorString, existingDeclaration);
        }

        // TODO: We should resolve the differences between Descriptor and
        // StyleProperty and just merge them into the same entity. Special
        // processing could be done on those descriptors directly.

        // Extract the properties from the declaration and record them in a 
        // style declaration block. We merge properties from new declaration
        // blocks to existing declaration blocks because selectors can be
        // declared multiple times with different properties. This is primarily
        // done to avoid redundant ClassReferences when it can be determined at
        // compile time that only the last occurrence of a selector with the
        // same property will matter at runtime (because the last one wins).
        // This helps keep SWF size down by avoiding linking in unused classes.
        StyleDeclarationBlock block = existingDeclaration.getDeclarationBlock(selector, mediaList);
        extractProperties(declaration, block.getProperties(), block.getEffectStyles());

        // If the new declaration does not have a media list, we merge its
        // properties into all other existing declaration blocks for this
        // selector that have any of the same properties. This is necessary to
        // ensure that later declaration blocks clobber all earlier declaration
        // blocks.
        if (mediaList == null)
        {
            Map<String, StyleProperty> properties = block.getProperties();

            List<StyleDeclarationBlock> existingBlocks = existingDeclaration.getDeclarationBlocks();
            for (StyleDeclarationBlock existingBlock : existingBlocks)
            {
                if (existingBlock != block)
                {
                    Map<String, StyleProperty> existingProperties = existingBlock.getProperties();
                    for (String property : properties.keySet())
                    {
                        if (existingProperties.get(property) != null)
                            existingProperties.put(property, properties.get(property));
                    }
                }
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    // Deprecated Flex 3 Entry Point
    //
    //--------------------------------------------------------------------------

    /**
     * Deprecated Flex 3 method of declaring styles for a single type or
     * universal class selector.  
     */
    void addDeclaration(StyleDeclaration declaration)
    {
        extractProperties(declaration, styles, effectStyles);
    }

    /**
     * Determines whether this definition expects to generate Flex 4 styled
     * Advanced StyleDeclarations.
     * @return true if advanced style declarations should be generated,
     * otherwise false.
     */
    public boolean isAdvanced()
    {
        return advanced;
    }

    public void setAdvanced(boolean value)
    {
        advanced = value;
    }

    /**
     * 
     * @return true if a style manager will store style declarations that are 
     * the same as its parent style manager.
     */
    public boolean getAllowDuplicateDefaultStyleDeclarations()
    {
        if (mxmlConfiguration != null)
            return mxmlConfiguration.getAllowDuplicateDefaultStyleDeclarations();
        
        return false;   // default value
    }
    
    public Set<AtEmbed> getAtEmbeds()
    {
        Set<AtEmbed> result = new HashSet<AtEmbed>();

        if (advanced)
        {
            if (declarations != null)
            {
                for (StyleDeclaration styleDeclaration : declarations.values())
                {
                    Collection<StyleDeclarationBlock> declarationBlocks = styleDeclaration.getDeclarationBlocks();
                    for (StyleDeclarationBlock block : declarationBlocks)
                    {
                        Map<String, StyleProperty> properties = block.getProperties();
    
                        if (properties != null)
                        {
                            extractAtEmbeds(result, properties.values());
                        }
                    }
                }
            }
        }
        else if (styles != null)
        {
            extractAtEmbeds(result, styles.values());
        }

        return result;
    }

    /**
     * Extracts the AtEmbeds from the <code>styleProperties</code> and
     * puts them into the <code>atEmbeds</code>.
     */
    private static void extractAtEmbeds(Set<AtEmbed> atEmbeds,
                                        Collection<StyleProperty> styleProperties)
    {
        for (StyleProperty styleProperty : styleProperties)
        {
            Object value = styleProperty.getValue();

            if (value instanceof AtEmbed)
            {
                atEmbeds.add((AtEmbed) value);
            }
        }
    }

    // Flex 4 Method
    /**
     * List of all of the style declarations for the subject represented by
     * this StyleDef.
     */
    public Map<String, StyleDeclaration> getDeclarations()
    {
        return declarations;
    }

    public List<String> getEffectStyles()
    {
        return effectStyles;
    }

    public Set<Import> getImports()
    {
        Set<Import> result = new HashSet<Import>();

        if (advanced)
        {
            if (declarations != null)
            {
                for (StyleDeclaration styleDeclaration : declarations.values())
                {
                    Collection<StyleDeclarationBlock> declarationBlocks = styleDeclaration.getDeclarationBlocks();
                    for (StyleDeclarationBlock block : declarationBlocks)
                    {
                        Map<String, StyleProperty> properties = block.getProperties();

                        if (properties != null)
                        {
                            extractImports(result, properties.values());
                        }
                    }
                }
            }
        }
        else if (styles != null)
        {
            extractImports(result, styles.values());
        }

        return result;
    }

    /**
     * Extracts the imports from the <code>styleProperties</code> and
     * puts them into the <code>imports</code>.
     */
    private static void extractImports(Set<Import> imports,
                                       Collection<StyleProperty> styleProperties)
    {
        for (StyleProperty styleProperty : styleProperties)
        {
            Object value = styleProperty.getValue();

            if (value instanceof Reference)
            {
                Reference reference = (Reference) value;
                
                if (reference.isClassReference() && !reference.getValue().equals("null"))
                {
                    imports.add(new Import(reference.getValue(), reference.getLineNumber()));
                }
            }
        }
    }

    // Deprecated Flex 3 Method
    public int getLineNumber()
    {
        return lineNumber;
    }

    // Deprecated Flex 3 Method
    /** 
     * Flex 3 only supported a single "style declaration" per type or universal
     * class selector, so this
     */
    public Map<String, StyleProperty> getStyles()
    {
        return styles;
    }

    /**
     * The subject is defined as the right most simple type selector in a
     * potential chain of selectors. A StyleDef contains all of the style
     * declarations that have selectors with this subject. 
     * 
     * @return the subject name
     */
    public String getSubject()
    {
        return subject;
    }

    /**
     * The typeName is used to construct the class name of the ActionScript
     * mix-in that represents this subject. Essentially it is the subject
     * name.
     */
    public String getTypeName()
    {
        if (UNIVERSAL.equals(subject))
            return GLOBAL;
        else
            return createTypeName(subject);
    }

    // Deprecated Flex 3 Method
    public boolean isTypeSelector()
    {
        return isTypeSelector;
    }

    //--------------------------------------------------------------------------
    //
    // Helper Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Converts a subject into a safe type name so that it can be used in
     * a generated ActionScript class.
     */
    public static String createTypeName(String subject)
    {
        subject = subject.replace('.', '_');
        return subject;
    }

    /**
     * This method is useful for converting CSS style declaration
     * names, like font-size, into valid ActionScript identifiers,
     * like fontSize.
     */
    public static String dehyphenize(String string)
    {
        StringBuilder stringBuffer = new StringBuilder();

        int start = 0;
        int end = string.indexOf('-');

        while (end >= 0)
        {
            stringBuffer.append( string.substring(start, end) );
            stringBuffer.append( Character.toUpperCase( string.charAt(end + 1) ) );
            start = end + 2;
            end = string.indexOf('-', start);
        }

        stringBuffer.append( string.substring(start) );

        return stringBuffer.toString();
    }

    /**
     * Convert SAC based CSS parser "Descriptors" into simple
     * StyleProperties while looking for special Flex syntax such as
     * Embed(), ClassReference(), and PropertyReference().
     */
    private void extractProperties(StyleDeclaration declaration, Map<String, StyleProperty> properties, List<String> effectsStyles)
    {
        Iterator<Entry<String, Descriptor>> propertyIterator = declaration.iterator();

        while (propertyIterator.hasNext())
        {
            Entry<String, Descriptor> entry = propertyIterator.next();
            Descriptor descriptor = entry.getValue();
            String propertyName = dehyphenize(descriptor.getName());

            try
            {
                if (propertyName.equals("fontFamily"))
                {
                    processFontFamily(properties, descriptor);
                }
                else
                {
                    processPropertyDescriptor(propertyName, descriptor, properties, effectsStyles);
                }
            }
            catch (CompilerError compilerError)
            {
                compilerError.setPath(descriptor.getPath());
                compilerError.setLine(descriptor.getLineNumber());
                ThreadLocalToolkit.log(compilerError);
            }
        }
    }

    /**
     * Process ClassReference and PropertyReference CSS functions.
     */
    private Reference processReference(String value, String styleSheetPath,
                                       int line, boolean isClassReference)
    {
        Reference result = null;
        int prefixLength;

        if (isClassReference)
        {
            prefixLength = CLASS_REFERENCE.length();
        }
        else
        {
            prefixLength = PROPERTY_REFERENCE.length();
        }

        String parameter = value.substring(prefixLength, value.length() - 1).trim();

        if ((parameter.charAt(0) == '"') && (parameter.indexOf('"', 1) == parameter.length() - 1))
        {
            String substring = parameter.substring(1, parameter.length() - 1);

            if (!isClassReference && (mxmlDocument == null))
            {
                PropertyReferenceRequiresDocument propertyReferenceRequiresDocument =
                    new PropertyReferenceRequiresDocument();
                propertyReferenceRequiresDocument.path = styleSheetPath;
                propertyReferenceRequiresDocument.line = line;
                ThreadLocalToolkit.log(propertyReferenceRequiresDocument);
            }
            else
            {
                result = new Reference(substring, isClassReference, styleSheetPath, line);
            }
        }
        else if (parameter.equals("null"))
        {
            result = new Reference(parameter, isClassReference, styleSheetPath, line);
        }
        else
        {
            InvalidReference invalidReference = new InvalidReference(isClassReference);
            invalidReference.path = styleSheetPath;
            invalidReference.line = line;
            ThreadLocalToolkit.log(invalidReference);
        }

        return result;
    }

    private void processFontFamily(Map<String, StyleProperty> properties, Descriptor descriptor)
    {
        String propertyName = "fontFamily";
        String fontFamily = descriptor.getIdentAsString();
        StyleProperty stylesProperty = new StyleProperty(propertyName,
                                                         "\"" + fontFamily + "\"",
                                                         descriptor.getPath(),
                                                         descriptor.getLineNumber());
        properties.put(propertyName, stylesProperty);
    }

    private void processPropertyDescriptor(String propertyName, Descriptor descriptor,
                                           Map<String, StyleProperty> properties,
                                           List<String> effectStyles)
        throws CompilerError
    {
        if (propertyName.endsWith("Effect"))
        {
            effectStyles.add(propertyName);
        }

        Object value = processPropertyValue(descriptor);        

        if (value != null)
        {
            StyleProperty styleProperty = new StyleProperty(propertyName, value,
                                                            descriptor.getPath(),
                                                            descriptor.getLineNumber());
            properties.put(propertyName, styleProperty);
        }
    }

    private Object processPropertyValue(Descriptor descriptor)
        throws CompilerError
    {
        String value = descriptor.getValueAsString();
        Object result = value;

        if (value.startsWith(EMBED))
        {
            result = AtEmbed.create(perCompileData, source, value,
                                    descriptor.getPath(), descriptor.getLineNumber(),
                                    "_embed_css_");
        }
        else if (value.startsWith(CLASS_REFERENCE))
        {
            result = processReference(value, descriptor.getPath(), descriptor.getLineNumber(), true);
        }
        else if (value.startsWith(PROPERTY_REFERENCE))
        {
            result = processReference(value, descriptor.getPath(), descriptor.getLineNumber(), false);
        }

        // Strip the quotes for CSS identifiers, which are properties
        // of the Mxml document.  This allows us to support minimal
        // data binding functionality for the CSS object styling feature.
        //
        // The "advanced" check is really a check for compatibility
        // version greater than 3.0.  If the way advanced gets set
        // changes, this should be updated.
        //
        if (!advanced &&
            (mxmlDocument != null) &&
            (descriptor.getValue().getLexicalUnitType() == LexicalUnit.SAC_IDENT) &&
            (value != null) && 
            (value.length() > 2) &&
            ((value.charAt(0) == '\'') || (value.charAt(0) == '\"')) &&
            ((value.charAt(value.length() - 1) == '\'') || (value.charAt(value.length() - 1) == '\"')))
        {
            String potentialProperty = value.substring(1, value.length() - 1);

            Type type = mxmlDocument.getRoot().getType();

            if (type != null && type.getProperty(potentialProperty) != null)
            {
                result = potentialProperty;
            }

            // deprecated - Flex 1.5 support only
            if ( FrameworkDefs.isBuiltinEffectName(potentialProperty) )
            {
                mxmlDocument.addTypeRef(mxmlDocument.getStandardDefs().getEffectsPackage() + '.' + potentialProperty,
                                        descriptor.getLineNumber());
            }
        }

        return result;
    }

    //--------------------------------------------------------------------------
    //
    // Errors
    //
    //--------------------------------------------------------------------------

    public static class InvalidReference extends CompilerError
    {
        private static final long serialVersionUID = 3730898410175891394L;
        public String type;

        public InvalidReference(boolean isClassReference)
        {
            if (isClassReference)
            {
                type = "Class";
            }
            else
            {
                type = "Property";
            }
        }
    }

    public static class PropertyReferenceRequiresDocument extends CompilerError
    {
        private static final long serialVersionUID = 3730898410175891396L;

        public PropertyReferenceRequiresDocument()
        {
        }
    }
}
