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

import flash.css.FontFaceRule;
import flash.css.MediaList;
import flash.css.MediaRule;
import flash.css.Rule;
import flash.css.StyleCondition;
import flash.css.StyleDeclaration;
import flash.css.StyleRule;
import flash.css.StyleSelector;
import flash.css.StyleSheet;
import flash.util.Trace;
import flex2.compiler.Source;
import flex2.compiler.Transcoder;
import flex2.compiler.mxml.rep.AtEmbed;
import flex2.compiler.util.DualModeLineNumberMap;
import flex2.compiler.util.NameMappings;
import flex2.compiler.util.ThreadLocalToolkit;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.flex.forks.batik.css.parser.AbstractSelector;
import org.w3c.css.sac.AttributeCondition;
import org.w3c.css.sac.CombinatorCondition;
import org.w3c.css.sac.Condition;
import org.w3c.css.sac.ConditionalSelector;
import org.w3c.css.sac.DescendantSelector;
import org.w3c.css.sac.ElementSelector;
import org.w3c.css.sac.Selector;
import org.w3c.css.sac.SelectorList;
import org.w3c.css.sac.SimpleSelector;

import macromedia.asc.util.ContextStatics;

/**
 * This class is used by the CssCompiler as an object model for a CSS
 * document.  StyleModule instances are used as input for code
 * generation.
 *
 * @author Paul Reilly
 * @author Pete Farland
 */
public class StyleModule
{
    protected Map<String, AtEmbed> atEmbeds = new LinkedHashMap<String, AtEmbed>();
    protected List<FontFaceRule> fontFaceRules;
    protected boolean advanced = true;
    protected boolean qualifiedTypeSelectors = true;
    protected String name;
    protected ContextStatics perCompileData;
    protected Source source;
    protected Map<String, StyleDef> styleDefs;
    protected NameMappings nameMappings;

    private DualModeLineNumberMap lineNumberMap;

    public StyleModule(Source source, ContextStatics perCompileData)
    {
        this.source = source;
        this.perCompileData = perCompileData;
        fontFaceRules = new ArrayList<FontFaceRule>();
        styleDefs = new LinkedHashMap<String, StyleDef>();
    }

    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------

    //----------------
    // atEmbeds
    //----------------
    
    public Set<AtEmbed> getAtEmbeds()
    {
        Set<AtEmbed> result = new HashSet<AtEmbed>(atEmbeds.values());

        for (StyleDef styleDef : styleDefs.values())
        {
            for (AtEmbed atEmbed : styleDef.getAtEmbeds())
            {
                if (!result.contains(atEmbed))
                {
                    result.add(atEmbed);
                }
            }
        }

        return result;
    }

    //----------------
    // fontFaceRules
    //----------------
    
    public List<FontFaceRule> getFontFaceRules()
    {
        return fontFaceRules;
    }

    //----------------
    // advanced
    //----------------

    /**
     * Determines whether this module intends to generate Flex 4 Advanced
     * StyleDefs.
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

    //------------------------
    // qualifiedTypeSelectors
    //------------------------

    /**
     * Determines whether this module requires type selectors to be
     * namespace qualified.
     * @return true if type selectors must be qualified, otherwise false.
     */
    public boolean getQualifiedTypeSelectors()
    {
        return qualifiedTypeSelectors;
    }

    public void setQualifiedTypeSelectors(boolean value)
    {
        qualifiedTypeSelectors = value;
    }
    
    //----------------
    // imports
    //----------------
    
    public Set<Import> getImports()
    {
        Set<Import> result = new HashSet<Import>();
        Iterator<StyleDef> styleDefIterator = styleDefs.values().iterator();

        while ( styleDefIterator.hasNext() )
        {
            StyleDef styleDef = styleDefIterator.next();
            result.addAll(styleDef.getImports());
        }

        return result;
    }

    //----------------
    // lineNumberMap
    //----------------
    
    public DualModeLineNumberMap getLineNumberMap()
    {
        return lineNumberMap;
    }

    public void setLineNumberMap(DualModeLineNumberMap lineNumberMap)
    {
        this.lineNumberMap = lineNumberMap;
    }

    public NameMappings getNameMappings()
    {
        return nameMappings;
    }

    public void setNameMappings(NameMappings mappings)
    {
        nameMappings = mappings;
    }
    
    //----------------
    // name
    //----------------

    public String getName()
    {
        return name;
    }

    public void setName(String name)
    {
        this.name = name;
    }

    //----------------
    // source
    //----------------

    public Source getSource()
    {
        return source;
    }

    //----------------
    // styleDefs
    //----------------

    public Collection<StyleDef> getStyleDefs()
    {
        return styleDefs.values();
    }

    public StyleDef getStyleDef(String name)
    {
        return styleDefs.get(name);
    }

    //--------------------------------------------------------------------------
    //
    // Methods - Public Entry Points 
    //
    //--------------------------------------------------------------------------

    /**
     * Called by CSSCompiler.parse1(), or DocumentBuilder.analyze(StyleNode)
     * for local MXML Style nodes (or internally by
     * StylesContainer.processStyleSheet() while loading default stylesheets).
     * 
     * @param styleSheet - the parsed style sheet representing the rule set.
     * @param isLocal - whether the style sheet was declared locally in a
     * document.
     * @see flex2.compiler.css.StylesContainer
     */
    public void extractStyles(StyleSheet styleSheet, boolean isLocal)
    {
        if (styleSheet == null)
            return;

        List<Rule> sheetRules = styleSheet.getCssRules();

        if (sheetRules == null)
            return;

        // Aggregate rules by selector
        Iterator<Rule> ruleIterator = sheetRules.iterator();
        while (ruleIterator.hasNext())
        {
            Rule rule = ruleIterator.next();

            if (rule instanceof StyleRule)
            {
                addStyleRule((StyleRule)rule, null, isLocal);
            }
            else if (rule instanceof FontFaceRule)
            {
                addFontFaceRule((FontFaceRule)rule);
            }
            else if (rule instanceof MediaRule)
            {
                if (advanced)
                    addMediaRule((MediaRule)rule, isLocal);
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    // Helper Methods - Media Rules 
    //
    //--------------------------------------------------------------------------
    
    /**
     * Adds a media rule
     * 
     * @param mediaRule
     * @param isLocal - whether the style sheet was declared locally in a
     * document.
     */
    protected void addMediaRule(MediaRule mediaRule, boolean isLocal)
    {
        List<Rule> childRules = mediaRule.getRules();

        // Aggregate rules by selector
        Iterator<Rule> ruleIterator = childRules.iterator();
        while (ruleIterator.hasNext())
        {
            Rule rule = ruleIterator.next();

            if (rule instanceof StyleRule)
            {
                addStyleRule((StyleRule)rule, mediaRule.getMediaList(), isLocal);
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    // Helper Methods - Selectors 
    //
    //--------------------------------------------------------------------------

    /**
     * Adds a rule set, converting a potential list of selectors (and their 
     * conditions) into a form suitable for ActionScript code generation.
     * 
     * @param rule
     * @param mediaList
     * @param isLocal
     */
    protected void addStyleRule(StyleRule rule, MediaList mediaList, boolean isLocal)
    {
        // for each selector in this rule
        SelectorList selectors = rule.getSelectorList();
        int nSelectors = selectors.getLength();
        for (int i = 0; i < nSelectors; i++)
        {
            Selector selector = selectors.item(i);
            StyleDeclaration declaration = rule.getStyleDeclaration();

            // If we have a list of selectors, copy the shared
            // StyleDeclaration so that we can independently track
            // subject and selectors per instance.
            if (i > 0)
                declaration = declaration.shallowCopy();

            if (selector.getSelectorType() == Selector.SAC_ELEMENT_NODE_SELECTOR)
            {
                addSimpleTypeSelector((ElementSelector)selector, declaration, mediaList, isLocal);
            }
            else if (selector.getSelectorType() == Selector.SAC_CONDITIONAL_SELECTOR)
            {
                addConditionalSelector((ConditionalSelector)selector, declaration, mediaList);
            }
            else if (selector.getSelectorType() == Selector.SAC_DESCENDANT_SELECTOR)
            {
                addDescendantSelector((DescendantSelector)selector, declaration, mediaList);
            }
            else
            {
                int lineNumber = getSelectorLineNumber(selector, declaration);
                String path = getPathForReporting(declaration);
                unsupportedSelector(selector, path, lineNumber);
            }
        }
    }
    
    /**
     * Adds a type selector with a condition to the subject's StyleDef. The
     * subject is interpreted as the right most simple type selector in the
     * chain.
     * 
     * If legacy Flex 3, only class conditions for the universal selector is
     * supported. 
     * 
     * If advanced, the support conditions are id, class and pseudo-class for
     * any type selector.
     * 
     * Other conditions are not supported and will log a
     * ConditionTypeNotSupported compiler error.
     */
    protected void addConditionalSelector(ConditionalSelector selector, StyleDeclaration declaration, MediaList mediaList)
    {
        int lineNumber = getSelectorLineNumber(selector, declaration);
        if (advanced)
        {
            StyleSelector baseSelector = convertSelector(selector, declaration);
            if (baseSelector != null)
            {
                String subject = baseSelector.getValue();
                declaration.setSubject(subject);
                declaration.setSelector(baseSelector);
                addAdvancedSelectorToStyleDef(declaration, mediaList, false, lineNumber);
            }
        }
        else
        {
            Condition condition = selector.getCondition();
    
            if (condition.getConditionType() == Condition.SAC_CLASS_CONDITION)
            {
                String name = ((AttributeCondition) condition).getValue();
                assert name != null : "parsed CSS class selector name is null";
    
                addSelectorToStyleDef(name, declaration, false, false, lineNumber);
            }
            else
            {
                String path = getPathForReporting(declaration);
                unsupportedCondition(condition, path, lineNumber);
            }
        }
    }

    /**
     * Adds a descendant selector to the subject's StyleDef.
     * 
     * This is only supported if advanced is true and is not supported by 
     * Flex 3 legacy styles functionality.
     */
    protected void addDescendantSelector(DescendantSelector selector, StyleDeclaration declaration, MediaList mediaList)
    {
        int lineNumber = getSelectorLineNumber(selector, declaration);
        if (advanced)
        {
            StyleSelector baseSelector = convertSelector(selector, declaration);
            if (baseSelector != null)
            {
                String subject = baseSelector.getValue();
                declaration.setSubject(subject);
                declaration.setSelector(baseSelector);
                addAdvancedSelectorToStyleDef(declaration, mediaList, false, lineNumber);
            }
        }
        else
        {
            String path = getPathForReporting(declaration);
            unsupportedSelector(selector, path, lineNumber);
        }
    }

    /**
     * Adds a simple type selector to the subject's StyleDef.
     */
    protected void addSimpleTypeSelector(ElementSelector selector, StyleDeclaration declaration, MediaList mediaList, boolean isLocal)
    {
        // Batik seems to generate an empty element
        // selector when @charset, so filter those out.
        String name = selector.getLocalName();

        if (name != null || StyleDef.UNIVERSAL.equals(selector.toString()))
        {
            int lineNumber = getSelectorLineNumber(selector, declaration);
            if (advanced)
            {
                StyleSelector baseSelector = convertSelector(selector, declaration);
                if (baseSelector != null)
                {
                    String subject = baseSelector.getValue();
                    declaration.setSelector(baseSelector);
                    declaration.setSubject(subject);
                    addAdvancedSelectorToStyleDef(declaration, mediaList, isLocal, lineNumber);
                }
            }
            else
            {
                addSelectorToStyleDef(name, declaration, true, isLocal, lineNumber);
            }
        }
    }

    /**
     * Logs a SelectorTypeNotSupported warning.
     */
    protected void unsupportedSelector(Selector selector, String path, int lineNumber)
    {
        SelectorTypeNotSupported selectorTypeNotSupported =
            new SelectorTypeNotSupported(path, lineNumber, selector.toString());
        ThreadLocalToolkit.log(selectorTypeNotSupported);
    }

    /**
     * Logs a ConditionTypeNotSupported warning.
     */
    protected void unsupportedCondition(Condition condition, String path, int lineNumber)
    {
        ConditionTypeNotSupported conditionTypeNotSupported =
            new ConditionTypeNotSupported(path, lineNumber,
                                          condition.toString());
        ThreadLocalToolkit.log(conditionTypeNotSupported);
    }

    /**
     * This legacy Flex 3 uses one StyleDef per type or universal class selector
     * only.
     * 
     * @param subject The subject of the selector chain.
     * @param rule The original rule.
     * @param isTypeSelector Whether this rule has a type selector.
     * @param isLocal Whether the style sheet was declared locally in a
     * document.
     * @param lineNumber The line number of the style declaration.
     */
    protected void addSelectorToStyleDef(String subject, StyleDeclaration declaration,
            boolean isTypeSelector, boolean isLocal, int lineNumber)
    {
        StyleDef styleDef = styleDefs.get(subject);

        if (styleDef == null)
        {
            styleDef = new StyleDef(subject, isTypeSelector, null, null, source, lineNumber, perCompileData);
            styleDefs.put(subject, styleDef);
        }

        styleDef.addDeclaration(declaration);
    }

    /**
     * This implementation differs from Flex 3 in that multiple style
     * declarations specified for a subject are retained individually (given
     * that we now support advanced selectors such as conditional and
     * descendant). 
     * 
     * @param rule The original rule.
     * @param lineNumber The line number of the style declaration.
     */
    protected void addAdvancedSelectorToStyleDef(StyleDeclaration declaration, 
            MediaList mediaList, boolean isLocal, int lineNumber)
    {
        String subject = declaration.getSubject();
        StyleSelector selector = declaration.getSelector();
        StyleDef styleDef;
        String styleDefKey = subject;

        // Treat a "*" subject like Flex's special "global" subject to fit
        // in with mxmlc's treatment of type selectors vs. universal selectors.
        if (StyleDef.UNIVERSAL.equals(subject))
        {
            styleDefKey = StyleDef.GLOBAL;

            // If we have conditions, we can make "*" implied.
            if (selector.getConditions() != null && selector.getConditions().size() > 0)
            {
                selector.setValue("");
            }
        }

        if (styleDefs.containsKey(styleDefKey))
        {
            styleDef = styleDefs.get(styleDefKey);
        }
        else
        {
            styleDef = new StyleDef(subject, null, null, source, lineNumber, perCompileData);
            styleDefs.put(styleDefKey, styleDef);
        }

        styleDef.addAdvancedDeclaration(declaration, mediaList);
    }

    /**
     * Converts a SAC CSS Selector to our StyleSelector construct that is used
     * for ActionScript codegen of advanced selectors. This method will continue
     * to log Flex 3 style compiler errors for unsupported selector types. 
     * 
     * @param selector The SAC CSS Selector.
     * @param lineNumber The corrected lineNumber on which this selectors was
     * declared. 
     * @return converted StyleSelector
     */
    private StyleSelector convertSelector(Selector selector, StyleDeclaration declaration)
    {
        StyleSelector simpleTypeSelector = null;

        // Type Selector
        if (selector instanceof ElementSelector)
        {
            simpleTypeSelector = convertTypeSelector((ElementSelector)selector, declaration);
        }
        // Conditional Selector
        else if (selector instanceof ConditionalSelector)
        {
            ConditionalSelector conditionalSelector = (ConditionalSelector)selector;
            SimpleSelector simpleSelector = conditionalSelector.getSimpleSelector();
            if (simpleSelector instanceof ElementSelector)
            {
                simpleTypeSelector = convertTypeSelector((ElementSelector)simpleSelector, declaration);
            }

            if (simpleTypeSelector != null)
            {
                Condition condition = conditionalSelector.getCondition();
                boolean supportedCondition = convertCondition(simpleTypeSelector, condition);
                if (!supportedCondition)
                {
                    int lineNumber = getSelectorLineNumber(selector, declaration);
                    String path = getPathForReporting(declaration);
                    unsupportedCondition(condition, path, lineNumber);
                    return null;
                }
            }
            else
            {
                int lineNumber = getSelectorLineNumber(selector, declaration);
                String path = getPathForReporting(declaration);
                unsupportedSelector(selector, path, lineNumber);
            }
        }
        // Descendant Selector
        else if (selector instanceof DescendantSelector)
        {
            DescendantSelector descendantSelector = (DescendantSelector)selector;
            SimpleSelector simpleSelector = descendantSelector.getSimpleSelector();

            // We may have conditions too, so we call convertSelector().
            simpleTypeSelector = convertSelector(simpleSelector, declaration);
            if (simpleTypeSelector != null)
            {
                Selector ancestorSelector = descendantSelector.getAncestorSelector();
                simpleTypeSelector.setAncestor(convertSelector(ancestorSelector, declaration));
            }
        }
        else
        {
            int lineNumber = getSelectorLineNumber(selector, declaration);
            String path = getPathForReporting(declaration);
            unsupportedSelector(selector, path, lineNumber);
        }

        return simpleTypeSelector;
    }
    
    /**
     * Convert SAC CSS ElementSelector to a simple type selector. Only simple
     * ElementSelector instances are supported for now, pseudo-element selectors
     * are not supported and pseudo-selectors are expected to be provided as
     * conditions as pseudo-class selectors.
     * 
     * @param selector A SAC CSS Selector to convert.
     * @return converted StyleSelector.
     */
    private StyleSelector convertTypeSelector(ElementSelector selector, StyleDeclaration declaration)
    {
        StyleSelector result = null;

        // Simple Type Selector
        if (selector != null && selector.getSelectorType() == Selector.SAC_ELEMENT_NODE_SELECTOR)
        {
            String name = selector.getLocalName();
            String uri = selector.getNamespaceURI();

            if (name == null && "*".equals(selector.toString()))
            {
                name = "*";
            }
            else if (!StyleDef.GLOBAL.equals(name) && qualifiedTypeSelectors)
            {
                if (uri != null)
                {
                    // Try to resolve the qualified ActionScript type in the
                    // given namespace URI.
                    String className = getQualifiedClassName(uri, name);

                    if (className != null)
                    {
                        name = className;
                    }
                    else
                    {
                        // Warn that a qualified type selector was unresolved
                        int lineNumber = getSelectorLineNumber(selector, declaration);
                        String path = getPathForReporting(declaration);
                        UnresolvedQualifiedTypeSelector unresolvedType =
                            new UnresolvedQualifiedTypeSelector(path, lineNumber, name, selector.toString());
                        ThreadLocalToolkit.log(unresolvedType);
                    }
                }
                else
                {
                    // Warn that a type selector was unqualified
                    int lineNumber = getSelectorLineNumber(selector, declaration);
                    String path = getPathForReporting(declaration);
                    UnqualifiedTypeSelector unqualifiedTypeSelector =
                        new UnqualifiedTypeSelector(path, lineNumber, name, selector.toString());
                    ThreadLocalToolkit.log(unqualifiedTypeSelector);
                }
            }

            // If the local name is null, do not create a selector.
            if (name != null)
            {
                result = new StyleSelector();
                result.setValue(name);
            }
        }

        return result;
    }

    /**
     * Converts an SAC Condition to our StyleCondition construct that is used
     * for ActionScript codegen of advanced selectors.
     * 
     * @param condition The SAC Condition to convert.
     * @return StyleCondition equivalent
     */
    private boolean convertCondition(StyleSelector selector, Condition condition)
    {
        boolean supportedCondition = true;

        if (condition instanceof CombinatorCondition)
        {
            CombinatorCondition cc = (CombinatorCondition)condition;

            // Convert the first condition
            supportedCondition = convertCondition(selector, cc.getFirstCondition());

            // Then try the second condition
            if (supportedCondition)
                supportedCondition = convertCondition(selector, cc.getSecondCondition());
        }
        else if (condition instanceof AttributeCondition)
        {
            AttributeCondition attributeCondition = (AttributeCondition)condition;
            short conditionType = condition.getConditionType();
            StyleCondition styleCondition = null;

            // Class Selector
            if (conditionType == Condition.SAC_CLASS_CONDITION)
            {
                styleCondition = new StyleCondition(StyleCondition.CLASS_CONDITION,
                        attributeCondition.getValue());
            }
            // id Selector
            else if (conditionType == Condition.SAC_ID_CONDITION)
            {
                styleCondition = new StyleCondition(StyleCondition.ID_CONDITION,
                        attributeCondition.getValue());
            }
            // Pseudo Class Selector
            else if (conditionType == Condition.SAC_PSEUDO_CLASS_CONDITION)
            {
                styleCondition = new StyleCondition(StyleCondition.PSEUDO_CONDITION,
                        attributeCondition.getValue());
            }

            if (styleCondition != null)
            {
                selector.addCondition(styleCondition);
            }
            else
            {
                supportedCondition = false;
            }
        }
        else
        {
            supportedCondition = false;
        }

        return supportedCondition;
    }

    protected String getPathForReporting(StyleDeclaration declaration)
    {
        String path = getSource().getName();

        if (declaration != null && declaration.getPath() != null)
            path = declaration.getPath();

        return path;
    }
    
    /**
     * Since a list of selectors can be declared on multiple lines, this method
     * allows a selector to report a more specific line number information
     * (if available). 
     * 
     * @param selector - the selector to search for a local line number
     * @param defaultLineNumber - the default number for the style declaration 
     * @return if the selector declares a line number, otherwise the default
     */
    protected int getSelectorLineNumber(Selector selector, StyleDeclaration declaration)
    {
        int lineNumber = declaration.getLineNumber();

        if (selector instanceof AbstractSelector)
        {
            AbstractSelector s = (AbstractSelector)selector;
            if (s.getLineNumber() > 0)
                lineNumber = s.getLineNumber();
        }

        return lineNumber;
    }

    /**
     * Resolves a namespace qualified class name to a fully qualified
     * ActionScript class name using the configured name mappings.
     * 
     * @param uri - the namespace URI
     * @param name - the local class name
     * @return a qualified ActionScript class name, or null if a mapping did
     * not exist
     */
    protected String getQualifiedClassName(String uri, String name)
    {
    	String className = null;

        if (uri != null)
        {
            assert nameMappings != null;
            className = nameMappings.resolveClassName(uri, name);
            if (className != null)
            {
                className = className.replace(':', '.');
            }
        }

        return className;
    }
    
    //--------------------------------------------------------------------------
    //
    // Helper Methods - Font Face Rules 
    //
    //--------------------------------------------------------------------------

    protected void addFontFaceRule(FontFaceRule fontFaceRule)
    {
        assert fontFaceRule != null;

        String family = fontFaceRule.getFamily();
        boolean bold = fontFaceRule.isBold();
        boolean italic = fontFaceRule.isItalic();

        if (FontFaceRule.getRule(fontFaceRules, family, bold, italic) == null)
        {
            fontFaceRules.add(fontFaceRule);

            //    add embed for font
            String propName = "_embed__font_" + family + "_" + (bold? "bold":"medium") + "_" + (italic? "italic":"normal");
            Map<String, Object> embedParams = fontFaceRule.getEmbedParams();
            StyleDeclaration styleDeclaration = fontFaceRule.getStyleDeclaration();
            String path = styleDeclaration.getPath();

            if (path.indexOf('\\') > -1)
            {
                embedParams.put( Transcoder.FILE, path.replace('\\', '/') );
                embedParams.put( Transcoder.PATHSEP, "true" );
            }
            else
            {
                embedParams.put( Transcoder.FILE, path );            
            }

            embedParams.put( Transcoder.LINE, Integer.toString(styleDeclaration.getLineNumber()) );
            AtEmbed atEmbed = AtEmbed.create(propName, source, styleDeclaration.getPath(),
                                             styleDeclaration.getLineNumber(), embedParams, false);
            addAtEmbed(atEmbed);
        }
        else if (Trace.font)
        {
            Trace.trace("Font face already existed for " + family + " bold? " + bold + " italic? " + italic);
        }
    }

    //--------------------------------------------------------------------------
    //
    // Helper Methods - AtEmbed 
    //
    //--------------------------------------------------------------------------

    protected void addAtEmbed(AtEmbed atEmbed)
    {
        atEmbeds.put(atEmbed.getPropName(), atEmbed);
    }
}
