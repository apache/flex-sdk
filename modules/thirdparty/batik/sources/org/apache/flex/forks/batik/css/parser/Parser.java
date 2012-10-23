/*

   Copyright 2000-2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.css.parser;

import java.io.IOException;
import java.io.InputStream;
import java.io.Reader;
import java.util.Locale;
import java.util.Map;
import java.util.MissingResourceException;
import java.util.StringTokenizer;
import java.util.TreeMap;

import org.apache.flex.forks.batik.i18n.Localizable;
import org.apache.flex.forks.batik.i18n.LocalizableSupport;
import org.apache.flex.forks.batik.util.CSSConstants;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.w3c.css.sac.CSSException;
import org.w3c.css.sac.CSSParseException;
import org.w3c.css.sac.Condition;
import org.w3c.css.sac.ConditionFactory;
import org.w3c.css.sac.DocumentHandler;
import org.w3c.css.sac.ErrorHandler;
import org.w3c.css.sac.InputSource;
import org.w3c.css.sac.LexicalUnit;
import org.w3c.css.sac.SACMediaList;
import org.w3c.css.sac.Selector;
import org.w3c.css.sac.SelectorFactory;
import org.w3c.css.sac.SelectorList;
import org.w3c.css.sac.SimpleSelector;

/**
 * This class implements the {@link org.w3c.css.sac.Parser} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: Parser.java 569967 2007-08-27 02:54:20Z cam $
 */
public class Parser implements ExtendedParser, Localizable {

    /**
     * The default resource bundle base name.
     */
    public static final String BUNDLE_CLASSNAME =
        "org.apache.flex.forks.batik.css.parser.resources.Messages";

    /**
     * The localizable support.
     */
    protected LocalizableSupport localizableSupport =
        new LocalizableSupport(BUNDLE_CLASSNAME, 
                               Parser.class.getClassLoader());

    /**
     * The scanner used to scan the input source.
     */
    protected Scanner scanner;

    /**
     * The current lexical unit.
     */
    protected int current;

    /**
     * The document handler.
     */
    protected DocumentHandler documentHandler =
        DefaultDocumentHandler.INSTANCE;

    /**
     * The selector factory.
     */
    protected SelectorFactory selectorFactory =
        DefaultSelectorFactory.INSTANCE;

    /**
     * The condition factory.
     */
    protected ConditionFactory conditionFactory =
        DefaultConditionFactory.INSTANCE;

    /**
     * The error handler.
     */
    protected ErrorHandler errorHandler = DefaultErrorHandler.INSTANCE;

    /**
     * To store the current pseudo element.
     */
    protected String pseudoElement;

    /**
     * The document URI.
     */
    protected String documentURI;

    /**
     * A map of namespace prefixes to namespace URIs.
     */
    protected Map namespaces = new TreeMap();

    /**
     * The default namespace for elements with no prefix.
     */
    protected String defaultNamespace;

    /**
     * An offset to add to line numbers.
     */
    protected int lineNumberOffset;
    
    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.Parser#getParserVersion()}.
     * @return "http://www.w3.org/TR/REC-CSS2".
     */
    public String getParserVersion() {
        return "http://www.w3.org/TR/REC-CSS2";
    }
    
    /**
     * <b>SAC</b>: Implements {@link org.w3c.css.sac.Parser#setLocale(Locale)}.
     */
    public void setLocale(Locale locale) throws CSSException {
        localizableSupport.setLocale(locale);
    }
    
    /**
     * Implements {@link org.apache.flex.forks.batik.i18n.Localizable#getLocale()}.
     */
    public Locale getLocale() {
        return localizableSupport.getLocale();
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.i18n.Localizable#formatMessage(String,Object[])}.
     */
    public String formatMessage(String key, Object[] args)
        throws MissingResourceException {
        return localizableSupport.formatMessage(key, args);
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.Parser#setDocumentHandler(DocumentHandler)}.
     */
    public void setDocumentHandler(DocumentHandler handler) {
        documentHandler = handler;
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.Parser#setSelectorFactory(SelectorFactory)}.
     */
    public void setSelectorFactory(SelectorFactory factory) {
        selectorFactory = factory;
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.Parser#setConditionFactory(ConditionFactory)}.
     */
    public void setConditionFactory(ConditionFactory factory) {
        conditionFactory = factory;
    }
    
    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.Parser#setErrorHandler(ErrorHandler)}.
     */
    public void setErrorHandler(ErrorHandler handler) {
        errorHandler = handler;
    }
    
    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.Parser#parseStyleSheet(InputSource)}.
     */
    public void parseStyleSheet(InputSource source) 
        throws CSSException, IOException {
        scanner = createScanner(source);

        try {
            documentHandler.startDocument(source);

            current = scanner.next();
            switch (current) {
            case LexicalUnits.CHARSET_SYMBOL:
                if (nextIgnoreSpaces() != LexicalUnits.STRING) {
                    reportError("charset.string");
                } else {
                    if (nextIgnoreSpaces() != LexicalUnits.SEMI_COLON) {
                        reportError("semicolon");
                    }
                    next();
                }
                break;
            case LexicalUnits.COMMENT:
                documentHandler.comment(scanner.getStringValue());
            }

            skipSpacesAndCDOCDC();
            for (;;) {
                if (current == LexicalUnits.IMPORT_SYMBOL) {
                    nextIgnoreSpaces();
                    parseImportRule();
                    nextIgnoreSpaces();
                } else {
                    break;
                }
            }
            
            loop: for (;;) {
                switch (current) {
                case LexicalUnits.NAMESPACE:
                    nextIgnoreSpaces();
                    parseNamespace();
                    break;
                case LexicalUnits.PAGE_SYMBOL:
                    nextIgnoreSpaces();
                    parsePageRule();
                    break;
                case LexicalUnits.MEDIA_SYMBOL:
                    nextIgnoreSpaces();
                    parseMediaRule();
                    break;
                case LexicalUnits.FONT_FACE_SYMBOL:
                    nextIgnoreSpaces();
                    parseFontFaceRule();
                    break;
                case LexicalUnits.AT_KEYWORD:
                    nextIgnoreSpaces();
                    parseAtRule();
                    break;
                case LexicalUnits.EOF:
                    break loop;
                default:
                    parseRuleSet();
                }
                skipSpacesAndCDOCDC();
            }
        } finally {
            documentHandler.endDocument(source);
            scanner = null;
        }
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.Parser#parseStyleSheet(String)}.
     */
    public void parseStyleSheet(String uri) throws CSSException, IOException {
        parseStyleSheet(new InputSource(uri));
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.Parser#parseStyleDeclaration(InputSource)}.
     */
    public void parseStyleDeclaration(InputSource source) 
        throws CSSException, IOException {

        scanner = createScanner(source);
	parseStyleDeclarationInternal();
    }

    /**
     * @return the column number about to be parsed 
     */
    public int getColumnNumber() {
        int columnNumber = -1;

        if (scanner != null) {
            columnNumber = scanner.getColumn();
        }

        return columnNumber;
    }

    /**
     * @return the line number about to be parsed
     */
    public int getLineNumber() {
        int lineNumber = -1;

        if (scanner != null) {
            lineNumber = scanner.getLine();
        }

        lineNumber += lineNumberOffset;

        return lineNumber;
    }

    /**
     * @return the offset for line number reporting
     */
    public int getLineNumberOffset() {
        return lineNumberOffset;
    }

    /**
     * Sets an offset for line number reporting. 
     * @param value - the number of lines to offset
     */
    public void setLineNumberOffset(int value) {
        lineNumberOffset = value;
    }
    
    /**
     * Parses a style declaration using the current scanner.
     */
    protected void parseStyleDeclarationInternal() 
	throws CSSException, IOException {
        nextIgnoreSpaces();
        try {
            parseStyleDeclaration(false);
        } catch (CSSParseException e) {
            reportStyleDeclarationError(e);
        } finally {
            scanner = null;
        }
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.Parser#parseRule(InputSource)}.
     */
    public void parseRule(InputSource source) 
	throws CSSException, IOException {
        scanner = createScanner(source);
	parseRuleInternal();
    }

    /**
     * Parses a rule using the current scanner.
     */
    protected void parseRuleInternal() throws CSSException, IOException {
        nextIgnoreSpaces();
        parseRule();
        scanner = null;
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.Parser#parseSelectors(InputSource)}.
     */    
    public SelectorList parseSelectors(InputSource source)
        throws CSSException, IOException {
        scanner = createScanner(source);
	return parseSelectorsInternal();
    }

    /**
     * Parses selectors using the current scanner.
     */
    protected SelectorList parseSelectorsInternal() 
	throws CSSException, IOException {
        nextIgnoreSpaces();
        SelectorList ret = parseSelectorList();
        scanner = null;
        return ret;
    }

    /**
     * <b>SAC</b>: Implements
     * {@link org.w3c.css.sac.Parser#parsePropertyValue(InputSource)}.
     */    
    public LexicalUnit parsePropertyValue(InputSource source)
        throws CSSException, IOException {
        scanner = createScanner(source);
	return parsePropertyValueInternal();
    }

    /**
     * Parses property value using the current scanner.
     */
    protected LexicalUnit parsePropertyValueInternal() 
	throws CSSException, IOException {
        nextIgnoreSpaces();
        
        LexicalUnit exp = null;

        try {
            exp = parseExpression(false);
        } catch (CSSParseException e) {
            reportError(e);
            throw e;
        }

        CSSParseException exception = null;
        if (current != LexicalUnits.EOF)
            exception = createCSSParseException("eof.expected");

        scanner = null;

        if (exception != null) {
            errorHandler.fatalError(exception);
        }
        return exp;
    }
    
    /**
     * <b>SAC</b>: Implements
     * {@link org.w3c.css.sac.Parser#parsePriority(InputSource)}.
     */    
    public boolean parsePriority(InputSource source)
        throws CSSException, IOException {
        scanner = createScanner(source);
	return parsePriorityInternal();
    }

    /**
     * Parses the priority using the current scanner.
     */
    protected boolean parsePriorityInternal()
        throws CSSException, IOException {
        nextIgnoreSpaces();

        scanner = null;

        switch (current) {
        case LexicalUnits.EOF:
            return false;
        case LexicalUnits.IMPORT_SYMBOL:
            return true;
        default:
            reportError("token", new Object[] { new Integer(current) });
            return false;
        }
    }

    /**
     * Parses a rule.
     */
    protected void parseRule() {
        switch (scanner.getType()) {
        case LexicalUnits.IMPORT_SYMBOL:
            nextIgnoreSpaces();
            parseImportRule();
            break;
        case LexicalUnits.NAMESPACE:
            nextIgnoreSpaces();
            parseNamespace();
            break;
        case LexicalUnits.AT_KEYWORD:
            nextIgnoreSpaces();
            parseAtRule();
            break;
        case LexicalUnits.FONT_FACE_SYMBOL:
            nextIgnoreSpaces();
            parseFontFaceRule();
            break;
        case LexicalUnits.MEDIA_SYMBOL:
            nextIgnoreSpaces();
            parseMediaRule();
            break;
        case LexicalUnits.PAGE_SYMBOL:
            nextIgnoreSpaces();
            parsePageRule();
            break;
        default:
            parseRuleSet();
        }
    }

    /**
     * Parses an unknown rule.
     */
    protected void parseAtRule() {
        scanner.scanAtRule();
        documentHandler.ignorableAtRule(scanner.getStringValue());
        nextIgnoreSpaces();
    }

    /**
     * Parses an import rule. Assumes the current token is '@import'.
     */
    protected void parseImportRule() {
        String uri = null;
        switch (current) {
        default:
            reportError("string.or.uri");
            return;
        case LexicalUnits.STRING:
        case LexicalUnits.URI:
            uri = scanner.getStringValue();
            nextIgnoreSpaces();
        }

        CSSSACMediaList ml;
        if (current != LexicalUnits.IDENTIFIER) {
            ml = CSSSACMediaList.ALL;
        } else {
            ml = parseMediaList();
        }

        documentHandler.importStyle(uri, ml, null);

        if (current != LexicalUnits.SEMI_COLON) {
            reportError("semicolon");
        } else {
            next();
        }
    }

    /**
     * Parses an namespace rule. Assumes the current token is '@namespace'.
     */
    protected void parseNamespace() {
        String prefix = null;
        String uri = null;
        int lineNumber = getLineNumber();

        switch (current) {
        default:
            reportError("prefix.or.namespace");
            return;
        case LexicalUnits.IDENTIFIER:
            prefix = scanner.getStringValue();
            nextIgnoreSpaces();
            break;
        case LexicalUnits.STRING:
            uri = scanner.getStringValue();
            nextIgnoreSpaces();
            break;
        }

        switch (current) {
        default:
            reportError("namespace");
            return;
        case LexicalUnits.STRING:
            uri = scanner.getStringValue();
            nextIgnoreSpaces();
            break;
        case LexicalUnits.SEMI_COLON:
            break;
        }

        // Record prefix mappings for qualified element selector names 
        if (uri != null) {
            if (prefix == null || "".equals(prefix))
                defaultNamespace = uri;
            else
                namespaces.put(prefix, uri);
        }

        //documentHandler.namespaceDeclaration(prefix, uri);

        if (current != LexicalUnits.SEMI_COLON) {
            reportError(createCSSParseException("semicolon", null, lineNumber));
        } else {
            next();
        }
    }
    
    protected CSSSACMediaExpression parseMediaExpression()
    {
    	String mediaFeature = scanner.getStringValue();
    	nextIgnoreSpaces();
    	switch (current) {
    	default:
    		reportError("colon");
    		break;
    	case LexicalUnits.RIGHT_BRACE:
    		return new CSSSACMediaExpression(mediaFeature, null);
    	case LexicalUnits.COLON:
    		nextIgnoreSpaces();
    		LexicalUnit expr = this.parseExpression(true);
    		return new CSSSACMediaExpression(mediaFeature, expr);
    	}
    	return null;
    }
    
    protected CSSSACMediaQuery parseMediaQuery()
    {
    	CSSSACMediaQuery result = null;
    	// Tells the loop below whether or not
    	// we expect to see an "and" keyword.
    	boolean expectAND = true;
    	switch (current) {
    	case LexicalUnits.IDENTIFIER:
	    	String nextTokenString = scanner.getStringValue();
	    	boolean isNot = false;
	    	if (nextTokenString.equalsIgnoreCase("not")) {
	    		nextIgnoreSpaces();
	    		isNot = true;
	    	}
	    	else if (nextTokenString.equalsIgnoreCase("only")) {
	    		nextIgnoreSpaces();
	    	}
	    	switch (current) {
	    	default:
	    		reportError("identifier");
	    		break;
	    	case LexicalUnits.IDENTIFIER:
	    		String mediaType = scanner.getStringValue();
	    		result = new CSSSACMediaQuery(isNot, mediaType);
	    		nextIgnoreSpaces();
	    		expectAND = true;
	    	}
	    	break;
    	case LexicalUnits.LEFT_BRACE:
    		result = new CSSSACMediaQuery(false, null);
    		expectAND = false;
    		break;
    	default:
    		reportError("identifier");
    	}
    	
		while ((!expectAND ) || (current == LexicalUnits.IDENTIFIER) && (scanner.getStringValue().equalsIgnoreCase("and"))) {
			if (expectAND)
				nextIgnoreSpaces();
			expectAND = true;
			switch (current) {
			default:
				reportError("left.brace");
				break;
			case LexicalUnits.LEFT_BRACE:
				nextIgnoreSpaces();
				switch (current) {
				default:
					reportError("identifier");
					break;
				case LexicalUnits.IDENTIFIER:
					result.appendExpression(parseMediaExpression());
				}
				switch (current) {
				default:
					reportError("right.brace");
					break;
				case LexicalUnits.RIGHT_BRACE:
					nextIgnoreSpaces();
				}
			}
		}
		return result;
    }
    
    /**
     * Parses a media list.
     */
    protected CSSSACMediaList parseMediaList() {
        CSSSACMediaList result = new CSSSACMediaList();
        result.append(parseMediaQuery());
        
        while (current == LexicalUnits.COMMA) {
            nextIgnoreSpaces();

            result.append(parseMediaQuery());
        }
        return result;
    }

    /**
     * Parses a font-face rule.
     */
    protected void parseFontFaceRule() {
        try {
            documentHandler.startFontFace();

            if (current != LexicalUnits.LEFT_CURLY_BRACE) {
                reportError("left.curly.brace");
            } else {
                nextIgnoreSpaces();
        
                try {
                    parseStyleDeclaration(true);
                } catch (CSSParseException e) {
                    reportError(e);
                }
            }
        } finally {
            documentHandler.endFontFace();
        }
    }

    /**
     * Parses a page rule.
     */
    protected void parsePageRule() {
        String page = null;
        String ppage = null;

        if (current == LexicalUnits.IDENTIFIER) {
            page = scanner.getStringValue();
            nextIgnoreSpaces();

            if (current == LexicalUnits.COLON) {
                nextIgnoreSpaces();

                if (current != LexicalUnits.IDENTIFIER) {
                    reportError("identifier");
                    return;
                }
                ppage = scanner.getStringValue();
                nextIgnoreSpaces();
            }
        }

        try {
            documentHandler.startPage(page, ppage);
            
            if (current != LexicalUnits.LEFT_CURLY_BRACE) {
                reportError("left.curly.brace");
            } else {
                nextIgnoreSpaces();
        
                try {
                    parseStyleDeclaration(true);
                } catch (CSSParseException e) {
                    reportError(e);
                }
            }
        } finally {
            documentHandler.endPage(page, ppage);
        }
    }
    
    /**
     * Parses a media rule.
     */
    protected void parseMediaRule() {
    	
		CSSSACMediaList ml = parseMediaList();
        try {
            documentHandler.startMedia(ml);

            if (current != LexicalUnits.LEFT_CURLY_BRACE) {
                reportError("left.curly.brace");
            } else {
                nextIgnoreSpaces();
            
                loop: for (;;) {
                    switch (current) {
                    case LexicalUnits.EOF:
                    	reportStyleDeclarationError(createCSSParseException("eof"));
                    case LexicalUnits.RIGHT_CURLY_BRACE:
                        break loop;
                    default:
                        parseRuleSet();
                    }
                }

                nextIgnoreSpaces();
            }
        } finally {
            documentHandler.endMedia(ml);
        }
    }

    /**
     * Parses a ruleset.
     */
    protected void parseRuleSet() {
        SelectorList sl = null;

        try {
            sl = parseSelectorList();
        } catch (CSSParseException e) {
            reportError(e);
            return;
        }

        try {
            documentHandler.startSelector(sl);

            if (current != LexicalUnits.LEFT_CURLY_BRACE) {
                reportError("left.curly.brace");
                if (current == LexicalUnits.RIGHT_CURLY_BRACE) {
                    nextIgnoreSpaces();
                }
            } else {
                nextIgnoreSpaces();
        
                try {
                    parseStyleDeclaration(true);
                } catch (CSSParseException e) {
                    reportStyleDeclarationError(e);
                }
            }
        } finally {
            documentHandler.endSelector(sl);
        }
    }

    /**
     * Parses a selector list
     */
    protected SelectorList parseSelectorList() {
        CSSSelectorList result = new CSSSelectorList();
        result.append(parseSelector());

        for (;;) {
            if (current != LexicalUnits.COMMA) {
                return result;
            }
            nextIgnoreSpaces();
            result.append(parseSelector());
        }
    }

    /**
     * Parses a selector.
     */
    protected Selector parseSelector() {
        pseudoElement = null;
        Selector result = parseSimpleSelector();

        loop: for (;;) {
            switch (current) {
            default:
                break loop;
            case LexicalUnits.IDENTIFIER:
            case LexicalUnits.ANY:
            case LexicalUnits.HASH:
            case LexicalUnits.DOT:
            case LexicalUnits.LEFT_BRACKET:
            case LexicalUnits.COLON:
                if (pseudoElement != null) {
                    throw createCSSParseException("pseudo.element.position");
                }
                int currentLine = getLineNumber();

                result = selectorFactory.createDescendantSelector
                    (result,
                     parseSimpleSelector());

                if (result != null) {
                    if (result instanceof AbstractSelector) {
                        ((AbstractSelector)result).setLineNumber(currentLine);
                    }
                }

                break;
            case LexicalUnits.PLUS:
                if (pseudoElement != null) {
                    throw createCSSParseException("pseudo.element.position");
                }
                nextIgnoreSpaces();
                result = selectorFactory.createDirectAdjacentSelector
                    ((short)1,
                     result, 
                     parseSimpleSelector());
                break;
            case LexicalUnits.PRECEDE:
                if (pseudoElement != null) {
                    throw createCSSParseException("pseudo.element.position");
                }
                nextIgnoreSpaces();
                result = selectorFactory.createChildSelector
                    (result, 
                     parseSimpleSelector());
             }
        }
        if (pseudoElement != null) {
            result = selectorFactory.createChildSelector
                (result,
                 selectorFactory.createPseudoElementSelector
                 (null, pseudoElement));
        }
        return result;
    }

    /**
     * Parses a simple selector.
     */
    protected SimpleSelector parseSimpleSelector() {
        SimpleSelector result;

        String uri = defaultNamespace;
        int currentLineNumber = getLineNumber();

        switch (current) {
        case LexicalUnits.IDENTIFIER:
            String name = scanner.getStringValue(); 
            next();

            if (current == LexicalUnits.NAMESPACE_QUALIFIED) {
                if (name == null || "".equals(name))
                    uri = ""; // No namespace
                else if ("*".equals(name))
                    uri = null; // All namespaces, including no namespace
                else
                {
                    uri = (String)namespaces.get(name);
                    
                    if (uri == null)
                    {
                        // Don't use reportError() here, because it advances too far.
                        errorHandler.error(createCSSParseException("unresolved.namespace"));
                    }
                }

                next();
                name = scanner.getStringValue();
                next();
            }

            result = selectorFactory.createElementSelector(uri, name);
            break;
        case LexicalUnits.ANY:
            next();
        default:
            result = selectorFactory.createElementSelector(uri, null);
        }

        if (result != null) {
            if (result instanceof AbstractSelector) {
                ((AbstractSelector) result).setLineNumber(currentLineNumber);
            }
        }

        Condition cond = null;
        loop: for (;;) {
            Condition c = null;
            switch (current) {
            case LexicalUnits.HASH:
                c = conditionFactory.createIdCondition
                    (scanner.getStringValue());
                next();
                break;
            case LexicalUnits.DOT:
                if (next() != LexicalUnits.IDENTIFIER) {
                    throw createCSSParseException("identifier");
                }
                c = conditionFactory.createClassCondition
                    (null, scanner.getStringValue());
                next();
                break;
            case LexicalUnits.LEFT_BRACKET:
                if (nextIgnoreSpaces() != LexicalUnits.IDENTIFIER) {
                    throw createCSSParseException("identifier");
                }
                String name = scanner.getStringValue();
                int op = nextIgnoreSpaces();
                switch (op) {
                default:
                    throw createCSSParseException("right.bracket");
                case LexicalUnits.RIGHT_BRACKET:
                    nextIgnoreSpaces();
                    c = conditionFactory.createAttributeCondition
                        (name, null, false, null);
                    break;
                case LexicalUnits.EQUAL:
                case LexicalUnits.INCLUDES:
                case LexicalUnits.DASHMATCH:
                    String val = null;
                    switch (nextIgnoreSpaces()) {
                    default:
                        throw createCSSParseException("identifier.or.string");
                    case LexicalUnits.STRING:
                    case LexicalUnits.IDENTIFIER:
                        val = scanner.getStringValue();
                        nextIgnoreSpaces();
                    }
                    if (current != LexicalUnits.RIGHT_BRACKET) {
                        throw createCSSParseException("right.bracket");
                    }
                    next();
                    switch (op) {
                    case LexicalUnits.EQUAL:
                        c = conditionFactory.createAttributeCondition
                            (name, null, false, val);
                        break;
                    case LexicalUnits.INCLUDES:
                        c = conditionFactory.createOneOfAttributeCondition
                            (name, null, false, val);
                        break;
                    default:
                        c = conditionFactory.
                            createBeginHyphenAttributeCondition
                            (name, null, false, val);
                    }
                }
                break;
            case LexicalUnits.COLON:
                switch (nextIgnoreSpaces()) {
                case LexicalUnits.IDENTIFIER:
                    String val = scanner.getStringValue();
                    if (isPseudoElement(val)) {
                        if (pseudoElement != null) {
                            throw createCSSParseException
                                ("duplicate.pseudo.element");
                        }
                        pseudoElement = val;
                    } else {
                        c = conditionFactory.createPseudoClassCondition
                            (null, val);
                    }
                    next();
                    break;
                case LexicalUnits.FUNCTION:
                    String func = scanner.getStringValue();
                    if (nextIgnoreSpaces() != LexicalUnits.IDENTIFIER) {
                        throw createCSSParseException("identifier");
                    }
                    String lang = scanner.getStringValue();
                    if (nextIgnoreSpaces() != LexicalUnits.RIGHT_BRACE) {
                        throw createCSSParseException("right.brace");
                    }

                    if (!func.equalsIgnoreCase("lang")) {
                        throw createCSSParseException("pseudo.function");
                    }

                    c = conditionFactory.createLangCondition(lang);

                    next();
                    break;
                default:
                    throw createCSSParseException("identifier");
                }
                break;
            default:
                break loop;
            }
            if (c != null) {
                if (cond == null) {
                    cond = c;
                } else {
                    cond = conditionFactory.createAndCondition(cond, c);
                }
            }
        }
        skipSpaces();
        if (cond != null) {
            result = selectorFactory.createConditionalSelector(result, cond);
        }
        return result;
    }

    /**
     * Tells whether or not the given string represents a pseudo-element.
     */
    protected boolean isPseudoElement(String s) {
        switch (s.charAt(0)) {
        case 'a':
        case 'A':
            return s.equalsIgnoreCase("after");
        case 'b':
        case 'B':
            return s.equalsIgnoreCase("before");
        case 'f':
        case 'F':
            return s.equalsIgnoreCase("first-letter") ||
                   s.equalsIgnoreCase("first-line");
        }
        return false;
    }

    /**
     * Parses the given reader.
     */
    protected void parseStyleDeclaration(boolean inSheet)
        throws CSSException {
        for (;;) {
            switch (current) {
            case LexicalUnits.EOF:
                if (inSheet) {
                    throw createCSSParseException("eof");
                }
                return;
            case LexicalUnits.RIGHT_CURLY_BRACE:
                if (!inSheet) {
                    throw createCSSParseException("eof.expected");
                }
                nextIgnoreSpaces();
                return;
            case LexicalUnits.SEMI_COLON:
                nextIgnoreSpaces();
                continue;
            default:
                throw createCSSParseException("identifier");
            case LexicalUnits.IDENTIFIER:
            }

            String name = scanner.getStringValue();
        
            if (nextIgnoreSpaces() != LexicalUnits.COLON) {
                throw createCSSParseException("colon");
            }
            nextIgnoreSpaces();
        
            LexicalUnit exp = null;
            
            try {
                exp = parseExpression(false);
            } catch (CSSParseException e) {
                reportError(e);
            }

            if (exp != null) {
                boolean important = false;
                if (current == LexicalUnits.IMPORTANT_SYMBOL) {
                    important = true;
                    nextIgnoreSpaces();
                }
                documentHandler.property(name, exp, important);
            }
        }
    }

    /**
     * Parses a CSS2 expression.
     * @param param whether the expression to be parsed is a function parameter
     */
    protected LexicalUnit parseExpression(boolean param) {
        LexicalUnit result = parseTerm(null);
        LexicalUnit curr = result;

        for (;;) {
            boolean op = false;
            switch (current) {
            case LexicalUnits.COMMA:
                op = true;
                curr = CSSLexicalUnit.createSimple
                    (LexicalUnit.SAC_OPERATOR_COMMA, curr, getLineNumber());
                nextIgnoreSpaces();
                break;
            case LexicalUnits.EQUAL:            
            case LexicalUnits.DIVIDE:
                op = true;
                curr = CSSLexicalUnit.createSimple
                    (LexicalUnit.SAC_OPERATOR_SLASH, curr, getLineNumber());
                nextIgnoreSpaces();
            }
            if (param) {
                if (current == LexicalUnits.RIGHT_BRACE) {
                    if (op) {
                        throw createCSSParseException
                            ("token", new Object[] { new Integer(current) });
                    }
                    return result;
                }
                curr = parseTerm(curr);
            } else {
                switch (current) {
                case LexicalUnits.IMPORTANT_SYMBOL:
                case LexicalUnits.SEMI_COLON:
                case LexicalUnits.RIGHT_CURLY_BRACE:
                case LexicalUnits.EOF:
                    if (op) {
                        throw createCSSParseException
                            ("token", new Object[] { new Integer(current) });
                    }
                    return result;
                default:
                    curr = parseTerm(curr);
                }
            }
        }
    }

    /**
     * Parses a CSS2 term.
     */
    protected LexicalUnit parseTerm(LexicalUnit prev) {
        boolean plus = true;
        boolean sgn = false;
        int line;

        switch (current) {
        case LexicalUnits.MINUS:
            plus = false;
        case LexicalUnits.PLUS:
            next();
            sgn = true;
        default:
            switch (current) {
            case LexicalUnits.INTEGER:
                String sval = scanner.getStringValue();
                if (!plus) sval = "-"+sval;

                long lVal = Long.parseLong( sval );      // fix #41288
                if ( lVal >= Integer.MIN_VALUE && lVal <= Integer.MAX_VALUE ){
                    // we can safely convert to int
                    int iVal = (int) lVal;
                    line = getLineNumber();
                    nextIgnoreSpaces();                
                    return CSSLexicalUnit.createInteger( iVal, prev, line);
                }

                // we are too large for an int: convert to float
                // we can just fall-through to the float-handling ...
            case LexicalUnits.REAL:
                return CSSLexicalUnit.createFloat(LexicalUnit.SAC_REAL,
                                                  number(plus), prev, getLineNumber());
            case LexicalUnits.PERCENTAGE:
                return CSSLexicalUnit.createFloat(LexicalUnit.SAC_PERCENTAGE,
                                                  number(plus), prev, getLineNumber());
            case LexicalUnits.PT:
                return CSSLexicalUnit.createFloat(LexicalUnit.SAC_POINT,
                                                  number(plus), prev, getLineNumber());
            case LexicalUnits.PC:
                return CSSLexicalUnit.createFloat(LexicalUnit.SAC_PICA,
                                                  number(plus), prev, getLineNumber());
            case LexicalUnits.PX:
                return CSSLexicalUnit.createFloat(LexicalUnit.SAC_PIXEL,
                                                  number(plus), prev, getLineNumber());
            case LexicalUnits.CM:
                return CSSLexicalUnit.createFloat(LexicalUnit.SAC_CENTIMETER,
                                                  number(plus), prev, getLineNumber());
            case LexicalUnits.MM:
                return CSSLexicalUnit.createFloat(LexicalUnit.SAC_MILLIMETER,
                                                  number(plus), prev, getLineNumber());
            case LexicalUnits.IN:
                return CSSLexicalUnit.createFloat(LexicalUnit.SAC_INCH,
                                                  number(plus), prev, getLineNumber());
            case LexicalUnits.EM:
                return CSSLexicalUnit.createFloat(LexicalUnit.SAC_EM,
                                                  number(plus), prev, getLineNumber());
            case LexicalUnits.EX:
                return CSSLexicalUnit.createFloat(LexicalUnit.SAC_EX,
                                                  number(plus), prev, getLineNumber());
            case LexicalUnits.DEG:
                return CSSLexicalUnit.createFloat(LexicalUnit.SAC_DEGREE,
                                                  number(plus), prev, getLineNumber());
            case LexicalUnits.DPI:
                return CSSLexicalUnit.createFloat(LexicalUnit.SAC_DPI,
                                                  number(plus), prev, getLineNumber());
            case LexicalUnits.DPCM:
                return CSSLexicalUnit.createFloat(LexicalUnit.SAC_DPCM,
                                                  number(plus), prev, getLineNumber());
            case LexicalUnits.RAD:
                return CSSLexicalUnit.createFloat(LexicalUnit.SAC_RADIAN,
                                                  number(plus), prev, getLineNumber());
            case LexicalUnits.GRAD:
                return CSSLexicalUnit.createFloat(LexicalUnit.SAC_GRADIAN,
                                                  number(plus), prev, getLineNumber());
            case LexicalUnits.S:
                return CSSLexicalUnit.createFloat(LexicalUnit.SAC_SECOND,
                                                  number(plus), prev, getLineNumber());
            case LexicalUnits.MS:
                return CSSLexicalUnit.createFloat(LexicalUnit.SAC_MILLISECOND,
                                                  number(plus), prev, getLineNumber());
            case LexicalUnits.HZ:
                return CSSLexicalUnit.createFloat(LexicalUnit.SAC_HERTZ,
                                                  number(plus), prev, getLineNumber());
            case LexicalUnits.KHZ:
                return CSSLexicalUnit.createFloat(LexicalUnit.SAC_KILOHERTZ,
                                                  number(plus), prev, getLineNumber());
            case LexicalUnits.DIMENSION:
                return dimension(plus, prev);
            case LexicalUnits.FUNCTION:
                return parseFunction(plus, prev);
            }
            if (sgn) {
                throw createCSSParseException
                    ("token",
                     new Object[] { new Integer(current) });
            }
        }
        switch (current) {
        case LexicalUnits.STRING:
            String val = scanner.getStringValue();
            line = getLineNumber();
            nextIgnoreSpaces();
            return CSSLexicalUnit.createString(LexicalUnit.SAC_STRING_VALUE,
                                               val, prev, line);
        case LexicalUnits.IDENTIFIER:
            val = scanner.getStringValue();
            line = getLineNumber();
            nextIgnoreSpaces();
            if (val.equalsIgnoreCase("inherit")) {
                return CSSLexicalUnit.createSimple(LexicalUnit.SAC_INHERIT,
                                                   prev, line);
            } else {
                return CSSLexicalUnit.createString(LexicalUnit.SAC_IDENT,
                                                   val, prev, line);
            }
        case LexicalUnits.URI:
            val = scanner.getStringValue();
            line = getLineNumber();
            nextIgnoreSpaces();
            return CSSLexicalUnit.createString(LexicalUnit.SAC_URI,
                                               val, prev, line);
        case LexicalUnits.HASH:
            return hexcolor(prev);
        case LexicalUnits.UNICODE_RANGE:
            val = scanner.getStringValue();
            line = getLineNumber();
            nextIgnoreSpaces();
            return CSSLexicalUnit.createString(LexicalUnit.SAC_UNICODERANGE,
                                               val, prev, line);
        default:
            throw createCSSParseException
                ("token",
                 new Object[] { new Integer(current) });
        }
    }

    /**
     * Parses a CSS2 function.
     */
    protected LexicalUnit parseFunction(boolean positive, final LexicalUnit prev) {
        String name = scanner.getStringValue();
        nextIgnoreSpaces();
        
        LexicalUnit params = parseExpression(true);

        if (current != LexicalUnits.RIGHT_BRACE) {
            throw createCSSParseException
                ("token",
                 new Object[] { new Integer(current) });
        }
        int line = getLineNumber();
        nextIgnoreSpaces();

        predefined: switch (name.charAt(0)) {
        case 'r':
        case 'R':
            LexicalUnit lu;
            if (name.equalsIgnoreCase("rgb")) {
                lu = params;
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_INTEGER:
                case LexicalUnit.SAC_PERCENTAGE:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_OPERATOR_COMMA:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_INTEGER:
                case LexicalUnit.SAC_PERCENTAGE:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_OPERATOR_COMMA:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_INTEGER:
                case LexicalUnit.SAC_PERCENTAGE:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu != null) {
                    break;
                }
                return CSSLexicalUnit.createPredefinedFunction
                    (LexicalUnit.SAC_RGBCOLOR, params, prev, line);
            } else if (name.equalsIgnoreCase("rect")) {
                lu = params;
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_INTEGER:
                    if (lu.getIntegerValue() != 0) {
                        break predefined;
                    }
                    lu = lu.getNextLexicalUnit();
                    break;
                case LexicalUnit.SAC_IDENT:
                    if (!lu.getStringValue().equalsIgnoreCase("auto")) {
                        break predefined;
                    }
                    lu = lu.getNextLexicalUnit();
                    break;
                case LexicalUnit.SAC_EM:
                case LexicalUnit.SAC_EX:
                case LexicalUnit.SAC_PIXEL:
                case LexicalUnit.SAC_CENTIMETER:
                case LexicalUnit.SAC_MILLIMETER:
                case LexicalUnit.SAC_INCH:
                case LexicalUnit.SAC_POINT:
                case LexicalUnit.SAC_PICA:
                case LexicalUnit.SAC_PERCENTAGE:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_OPERATOR_COMMA:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_INTEGER:
                    if (lu.getIntegerValue() != 0) {
                        break predefined;
                    }
                    lu = lu.getNextLexicalUnit();
                    break;
                case LexicalUnit.SAC_IDENT:
                    if (!lu.getStringValue().equalsIgnoreCase("auto")) {
                        break predefined;
                    }
                    lu = lu.getNextLexicalUnit();
                    break;
                case LexicalUnit.SAC_EM:
                case LexicalUnit.SAC_EX:
                case LexicalUnit.SAC_PIXEL:
                case LexicalUnit.SAC_CENTIMETER:
                case LexicalUnit.SAC_MILLIMETER:
                case LexicalUnit.SAC_INCH:
                case LexicalUnit.SAC_POINT:
                case LexicalUnit.SAC_PICA:
                case LexicalUnit.SAC_PERCENTAGE:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_OPERATOR_COMMA:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_INTEGER:
                    if (lu.getIntegerValue() != 0) {
                        break predefined;
                    }
                    lu = lu.getNextLexicalUnit();
                    break;
                case LexicalUnit.SAC_IDENT:
                    if (!lu.getStringValue().equalsIgnoreCase("auto")) {
                        break predefined;
                    }
                    lu = lu.getNextLexicalUnit();
                    break;
                case LexicalUnit.SAC_EM:
                case LexicalUnit.SAC_EX:
                case LexicalUnit.SAC_PIXEL:
                case LexicalUnit.SAC_CENTIMETER:
                case LexicalUnit.SAC_MILLIMETER:
                case LexicalUnit.SAC_INCH:
                case LexicalUnit.SAC_POINT:
                case LexicalUnit.SAC_PICA:
                case LexicalUnit.SAC_PERCENTAGE:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_OPERATOR_COMMA:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_INTEGER:
                    if (lu.getIntegerValue() != 0) {
                        break predefined;
                    }
                    lu = lu.getNextLexicalUnit();
                    break;
                case LexicalUnit.SAC_IDENT:
                    if (!lu.getStringValue().equalsIgnoreCase("auto")) {
                        break predefined;
                    }
                    lu = lu.getNextLexicalUnit();
                    break;
                case LexicalUnit.SAC_EM:
                case LexicalUnit.SAC_EX:
                case LexicalUnit.SAC_PIXEL:
                case LexicalUnit.SAC_CENTIMETER:
                case LexicalUnit.SAC_MILLIMETER:
                case LexicalUnit.SAC_INCH:
                case LexicalUnit.SAC_POINT:
                case LexicalUnit.SAC_PICA:
                case LexicalUnit.SAC_PERCENTAGE:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu != null) {
                    break;
                }
                return CSSLexicalUnit.createPredefinedFunction
                    (LexicalUnit.SAC_RECT_FUNCTION, params, prev, line);
            }
            break;
        case 'c':
        case 'C':
            if (name.equalsIgnoreCase("counter")) {
                lu = params;
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_IDENT:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_OPERATOR_COMMA:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_IDENT:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu != null) {
                    break;
                }
                return CSSLexicalUnit.createPredefinedFunction
                    (LexicalUnit.SAC_COUNTER_FUNCTION, params, prev, line);
            } else if (name.equalsIgnoreCase("counters")) {
                lu = params;
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_IDENT:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_OPERATOR_COMMA:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_STRING_VALUE:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_OPERATOR_COMMA:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_IDENT:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu != null) {
                    break;
                }
                return CSSLexicalUnit.createPredefinedFunction
                    (LexicalUnit.SAC_COUNTERS_FUNCTION, params, prev, line);
            }
            break;
        case 'a':
        case 'A':
            if (name.equalsIgnoreCase("attr")) {
                lu = params;
                if (lu == null) {
                    break;
                }
                switch (lu.getLexicalUnitType()) {
                default:
                    break predefined;
                case LexicalUnit.SAC_IDENT:
                    lu = lu.getNextLexicalUnit();
                }
                if (lu != null) {
                    break;
                }
                return CSSLexicalUnit.createString
                    (LexicalUnit.SAC_ATTR, params.getStringValue(), prev, line);
            }
        }

        return CSSLexicalUnit.createFunction(name, params, prev, line);
    }

    /**
     * Converts a hash unit to a RGB color.
     */
    protected LexicalUnit hexcolor(LexicalUnit prev) {
        String val = scanner.getStringValue();
        int len = val.length();
        LexicalUnit params = null;
        switch (len) {
        case 3:
            char rc = Character.toLowerCase(val.charAt(0));
            char gc = Character.toLowerCase(val.charAt(1));
            char bc = Character.toLowerCase(val.charAt(2));
            if (!ScannerUtilities.isCSSHexadecimalCharacter(rc) ||
                !ScannerUtilities.isCSSHexadecimalCharacter(gc) ||
                !ScannerUtilities.isCSSHexadecimalCharacter(bc)) {
                throw createCSSParseException
                    ("rgb.color", new Object[] { val });
            }
            int t;
            int r = t = (rc >= '0' && rc <= '9') ? rc - '0' : rc - 'a' + 10;
            t <<= 4;
            r |= t;
            int g = t = (gc >= '0' && gc <= '9') ? gc - '0' : gc - 'a' + 10;
            t <<= 4;
            g |= t;
            int b = t = (bc >= '0' && bc <= '9') ? bc - '0' : bc - 'a' + 10;
            t <<= 4;
            b |= t;
            params = CSSLexicalUnit.createInteger(r, null, getLineNumber());
            LexicalUnit tmp;
            tmp = CSSLexicalUnit.createSimple
                (LexicalUnit.SAC_OPERATOR_COMMA, params, getLineNumber());
            tmp = CSSLexicalUnit.createInteger(g, tmp, getLineNumber());
            tmp = CSSLexicalUnit.createSimple
                (LexicalUnit.SAC_OPERATOR_COMMA, tmp, getLineNumber());
            tmp = CSSLexicalUnit.createInteger(b, tmp, getLineNumber());
            break;
        case 6:
            char rc1 = Character.toLowerCase(val.charAt(0));
            char rc2 = Character.toLowerCase(val.charAt(1));
            char gc1 = Character.toLowerCase(val.charAt(2));
            char gc2 = Character.toLowerCase(val.charAt(3));
            char bc1 = Character.toLowerCase(val.charAt(4));
            char bc2 = Character.toLowerCase(val.charAt(5));
            if (!ScannerUtilities.isCSSHexadecimalCharacter(rc1) ||
                !ScannerUtilities.isCSSHexadecimalCharacter(rc2) ||
                !ScannerUtilities.isCSSHexadecimalCharacter(gc1) ||
                !ScannerUtilities.isCSSHexadecimalCharacter(gc2) ||
                !ScannerUtilities.isCSSHexadecimalCharacter(bc1) ||
                !ScannerUtilities.isCSSHexadecimalCharacter(bc2)) {
                throw createCSSParseException("rgb.color");
            }
            r = (rc1 >= '0' && rc1 <= '9') ? rc1 - '0' : rc1 - 'a' + 10;
            r <<= 4;
            r |= (rc2 >= '0' && rc2 <= '9') ? rc2 - '0' : rc2 - 'a' + 10;
            g = (gc1 >= '0' && gc1 <= '9') ? gc1 - '0' : gc1 - 'a' + 10;
            g <<= 4;
            g |= (gc2 >= '0' && gc2 <= '9') ? gc2 - '0' : gc2 - 'a' + 10;
            b = (bc1 >= '0' && bc1 <= '9') ? bc1 - '0' : bc1 - 'a' + 10;
            b <<= 4;
            b |= (bc2 >= '0' && bc2 <= '9') ? bc2 - '0' : bc2 - 'a' + 10;
            params = CSSLexicalUnit.createInteger(r, null, getLineNumber());
            tmp = CSSLexicalUnit.createSimple
                (LexicalUnit.SAC_OPERATOR_COMMA, params, getLineNumber());
            tmp = CSSLexicalUnit.createInteger(g, tmp, getLineNumber());
            tmp = CSSLexicalUnit.createSimple
                (LexicalUnit.SAC_OPERATOR_COMMA, tmp, getLineNumber());
            tmp = CSSLexicalUnit.createInteger(b, tmp, getLineNumber());
            break;
        default:
            throw createCSSParseException("rgb.color", new Object[] { val });
        }
        int line = getLineNumber();
        nextIgnoreSpaces();
        return CSSLexicalUnit.createPredefinedFunction
            (LexicalUnit.SAC_RGBCOLOR, params, prev, line);
    }

    /**
     * Creates a scanner, given an InputSource.
     */
    protected Scanner createScanner(InputSource source) {
        documentURI = source.getURI();
        if (documentURI == null) {
            documentURI = "";
        }

        Reader r = source.getCharacterStream();
        if (r != null) {
            return new Scanner(r);
        }

        InputStream is = source.getByteStream();
        if (is != null) {
            return new Scanner(is, source.getEncoding());
        }

        String uri = source.getURI();
        if (uri == null) {
            throw new CSSException(formatMessage("empty.source", null));
        }

        try {
            ParsedURL purl = new ParsedURL(uri);
            is = purl.openStreamRaw(CSSConstants.CSS_MIME_TYPE);
            return new Scanner(is, source.getEncoding());
        } catch (IOException e) {
            throw new CSSException(e);
        }
    }

    /**
     * Skips the white spaces.
     */
    protected int skipSpaces() {
        int lex = scanner.getType();
        while (lex == LexicalUnits.SPACE) {
            lex = next();
        }
        return lex;
    }

    /**
     * Skips the white spaces and CDO/CDC units.
     */
    protected int skipSpacesAndCDOCDC() {
        loop: for (;;) {
            switch (current) {
            default:
                break loop;
            case LexicalUnits.COMMENT:
            case LexicalUnits.SPACE:
            case LexicalUnits.CDO:
            case LexicalUnits.CDC:
            }
            scanner.clearBuffer();
            next();
        }
        return current;
    }

    /**
     * Converts the current lexical unit to a float.
     */
    protected float number(boolean positive) {
        try {
            float sgn = (positive) ? 1 : -1;
            String val = scanner.getStringValue();
            nextIgnoreSpaces();
            return sgn * Float.parseFloat(val);
        } catch (NumberFormatException e) {
            throw createCSSParseException("number.format");
        }
    }

    /**
     * Converts the current lexical unit to a dimension.
     */
    protected LexicalUnit dimension(boolean positive, LexicalUnit prev) {
        try {
            float sgn = (positive) ? 1 : -1;
            String val = scanner.getStringValue();
            int i;
            loop: for (i = 0; i < val.length(); i++) {
                switch (val.charAt(i)) {
                default:
                    break loop;
                case '0': case '1': case '2': case '3': case '4':
                case '5': case '6': case '7': case '8': case '9':
                case '.':
                }
            }
            int line = getLineNumber();
            nextIgnoreSpaces();
            return CSSLexicalUnit.createDimension
                (sgn * Float.parseFloat(val.substring(0, i)),
                 val.substring(i),
                 prev,
                 line);
        } catch (NumberFormatException e) {
            throw createCSSParseException("number.format");
        }
    }

    /**
     * Advances to the next token, ignoring comments.
     */
    protected int next() {
        try {
            for (;;) {
                scanner.clearBuffer();
                current = scanner.next();
                if (current == LexicalUnits.COMMENT) {
                    documentHandler.comment(scanner.getStringValue());
                } else {
                    break;
                }
            }
            return current;
        } catch (ParseException e) {
            reportError(e.getMessage(), e.getParams());
            return current;
        }
    }

    /**
     * Advances to the next token and skip the spaces, ignoring comments.
     */
    protected int nextIgnoreSpaces() {
        try {
            loop: for (;;) {
                scanner.clearBuffer();
                current = scanner.next();
                switch (current) {
                case LexicalUnits.COMMENT:
                    documentHandler.comment(scanner.getStringValue());
                    break;
                default:
                    break loop;
                case LexicalUnits.SPACE:
                }
            }
            return current;
        } catch (ParseException e) {
            errorHandler.error(createCSSParseException(e.getMessage(), e.getParams()));
            return current;
        }
    }

    /**
     * Reports a parsing error.
     */
    protected void reportError(String key) {
        reportError(key, null);
    }

    /**
     * Reports a parsing error.
     */
    protected void reportError(String key, Object[] params) {
        reportError(createCSSParseException(key, params));
    }

    /**
     * Reports a parsing error.
     */
    protected void reportError(CSSParseException e) {
        errorHandler.error(e);

        int cbraces = 1;
        for (;;) {
            switch (current) {
            case LexicalUnits.EOF:
                return;
            case LexicalUnits.SEMI_COLON:
            case LexicalUnits.RIGHT_CURLY_BRACE:
                if (--cbraces == 0) {
                    nextIgnoreSpaces();
                    return;
                }
            case LexicalUnits.LEFT_CURLY_BRACE:
                cbraces++;
            }
            nextIgnoreSpaces();
        }
    }

    /**
     * Reports a parsing error.
     */
    protected void reportStyleDeclarationError(CSSParseException e) {
        errorHandler.error(e);

        int cbraces = 1;
        for (;;) {
            switch (current) {
            case LexicalUnits.EOF:
                return;
            case LexicalUnits.RIGHT_CURLY_BRACE:
                if (--cbraces == 0) {
                    nextIgnoreSpaces();
                    return;
                }
            case LexicalUnits.LEFT_CURLY_BRACE:
                cbraces++;
            }
            nextIgnoreSpaces();
        }
    }

    /**
     * Creates a parse exception.
     */
    protected CSSParseException createCSSParseException(String key) {
        return createCSSParseException(key, null);
    }

    /**
     * Creates a parse exception.
     */
    protected CSSParseException createCSSParseException(String key,
                                                        Object[] params) {
        return createCSSParseException(key, params, getLineNumber());
    }

    /**
     * Creates a parse exception.
     */
    protected CSSParseException createCSSParseException(String key,
                                                        Object[] params,
                                                        int lineNumber) {
        return new CSSParseException(formatMessage(key, params),
                                     documentURI,
                                     lineNumber,
                                     scanner.getColumn());
    }

    // -----------------------------------------------------------------------
    // Extended methods
    // -----------------------------------------------------------------------
    
    /**
     * Implements {@link ExtendedParser#parseStyleDeclaration(String)}.
     */
    public void parseStyleDeclaration(String source) 
	throws CSSException, IOException {
        scanner = new Scanner(source);
	parseStyleDeclarationInternal();
    }

    /**
     * Implements {@link ExtendedParser#parseRule(String)}.
     */
    public void parseRule(String source) throws CSSException, IOException {
        scanner = new Scanner(source);
	parseRuleInternal();
    }
    
    /**
     * Implements {@link ExtendedParser#parseSelectors(String)}.
     */
    public SelectorList parseSelectors(String source)
        throws CSSException, IOException {
        scanner = new Scanner(source);
	return parseSelectorsInternal();
    }

    /**
     * Implements {@link ExtendedParser#parsePropertyValue(String)}.
     */
    public LexicalUnit parsePropertyValue(String source)
        throws CSSException, IOException {
        scanner = new Scanner(source);
	return parsePropertyValueInternal();
    }

    /**
     * Implements {@link ExtendedParser#parsePriority(String)}.
     */
    public boolean parsePriority(String source)
        throws CSSException, IOException {
        scanner = new Scanner(source);
	return parsePriorityInternal();
    }

    /**
     * Implements {@link ExtendedParser#parseMedia(String)}.
     */
    public SACMediaList parseMedia(String mediaText)
        throws CSSException, IOException {
        CSSSACMediaList result = new CSSSACMediaList();
        if (!"all".equalsIgnoreCase(mediaText)) {
            StringTokenizer st = new StringTokenizer(mediaText, " ,");
            while (st.hasMoreTokens()) {
                result.append(st.nextToken());
            }
        }
        return result;
    }
}
