/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* 
 * This Xerces 2.9.1 class was updated for use by the Flex SDK at Adobe. These
 * updates were based on the changes originally made against Xerces 2.4.0 at
 * Macromedia. The changes are labeled with the comment "modified by rsun" and
 * the date the original modifications were made.
 */

package org.apache.xerces.parsers;

import org.apache.xerces.impl.Constants;
import org.apache.xerces.util.SymbolTable;
import org.apache.xerces.xni.grammars.XMLGrammarPool;
import org.apache.xerces.xni.parser.XMLParserConfiguration;

//modified by rsun 11/06/03 - use AbstractSAXParserMMImpl
//instead of AbstractSAXParserImpl
import org.apache.xerces.parsers.AbstractSAXParserMMImpl;

/**
 * This is the main Xerces SAX parser class. It uses the abstract SAX
 * parser with a document scanner, a dtd scanner, and a validator, as
 * well as a grammar pool.
 *
 * @author Arnaud  Le Hors, IBM
 * @author Andy Clark, IBM
 *
 * @version $Id: SAXParser.java 447239 2006-09-18 05:08:26Z mrglavas $
 */
//modified by rsun 11/06/03 - subclass AbstractSAXParserMMImpl instead
//of AbstractSAXParserImpl
public class SAXParserMMImpl
    extends AbstractSAXParserMMImpl {

    //
    // Constants
    //

    // features

    /** Feature identifier: notify built-in refereces. */
    protected static final String NOTIFY_BUILTIN_REFS =
        Constants.XERCES_FEATURE_PREFIX + Constants.NOTIFY_BUILTIN_REFS_FEATURE;

    /** Recognized features. */
    private static final String[] RECOGNIZED_FEATURES = {
        NOTIFY_BUILTIN_REFS,
    };

    // properties

    /** Property identifier: symbol table. */
    protected static final String SYMBOL_TABLE =
        Constants.XERCES_PROPERTY_PREFIX + Constants.SYMBOL_TABLE_PROPERTY;

    /** Property identifier: XML grammar pool. */
    protected static final String XMLGRAMMAR_POOL =
        Constants.XERCES_PROPERTY_PREFIX+Constants.XMLGRAMMAR_POOL_PROPERTY;

    /** Recognized properties. */
    private static final String[] RECOGNIZED_PROPERTIES = {
        SYMBOL_TABLE,
        XMLGRAMMAR_POOL,
    };

    //
    // Constructors
    //

    /**
     * Constructs a SAX parser using the specified parser configuration.
     */
    public SAXParserMMImpl(XMLParserConfiguration config) {
        super(config);
    } // <init>(XMLParserConfiguration)

    /**
     * Constructs a SAX parser using the dtd/xml schema parser configuration.
     */
    public SAXParserMMImpl() {
        this(null, null);
    } // <init>()

    /**
     * Constructs a SAX parser using the specified symbol table.
     */
    public SAXParserMMImpl(SymbolTable symbolTable) {
        this(symbolTable, null);
    } // <init>(SymbolTable)

    /**
     * Constructs a SAX parser using the specified symbol table and
     * grammar pool.
     */
    public SAXParserMMImpl(SymbolTable symbolTable, XMLGrammarPool grammarPool) {
        // modified by rsun 11/06/03 - use XML11ConfigurationMMImpl instead
        // of XML11ConfigurationImpl
        super((XMLParserConfiguration)ObjectFactory.createObject(
            "org.apache.xerces.xni.parser.XMLParserConfiguration",
            "org.apache.xerces.parsers.XML11ConfigurationMMImpl"
            ));

        // set features
        fConfiguration.addRecognizedFeatures(RECOGNIZED_FEATURES);
        fConfiguration.setFeature(NOTIFY_BUILTIN_REFS, true);

        // set properties
        fConfiguration.addRecognizedProperties(RECOGNIZED_PROPERTIES);
        if (symbolTable != null) {
            fConfiguration.setProperty(SYMBOL_TABLE, symbolTable);
        }
        if (grammarPool != null) {
            fConfiguration.setProperty(XMLGRAMMAR_POOL, grammarPool);
        }

    } // <init>(SymbolTable,XMLGrammarPool)

} // class SAXParserMMImpl
