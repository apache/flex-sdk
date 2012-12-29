/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.xml;

import java.io.IOException;
import java.io.InputStream;
import java.io.Reader;
import java.util.Locale;
import java.util.MissingResourceException;

import org.apache.flex.forks.batik.i18n.Localizable;
import org.apache.flex.forks.batik.i18n.LocalizableSupport;
import org.apache.flex.forks.batik.util.io.NormalizingReader;
import org.apache.flex.forks.batik.util.io.StreamNormalizingReader;
import org.apache.flex.forks.batik.util.io.StringNormalizingReader;

/**
 * This class represents a scanner for XML documents.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: XMLScanner.java 489226 2006-12-21 00:05:36Z cam $
 */
public class XMLScanner implements Localizable {

    /**
     * The document start context.
     */
    public static final int DOCUMENT_START_CONTEXT = 0;

    /**
     * The top level context.
     */
    public static final int TOP_LEVEL_CONTEXT = 1;

    /**
     * The processing instruction context.
     */
    public static final int PI_CONTEXT = 2;

    /**
     * The XML declaration context.
     */
    public static final int XML_DECL_CONTEXT = 3;

    /**
     * The doctype context.
     */
    public static final int DOCTYPE_CONTEXT = 4;

    /**
     * The start tag context.
     */
    public static final int START_TAG_CONTEXT = 5;

    /**
     * The content context.
     */
    public static final int CONTENT_CONTEXT = 6;

    /**
     * The DTD declarations context.
     */
    public static final int DTD_DECLARATIONS_CONTEXT = 7;

    /**
     * The CDATA section context.
     */
    public static final int CDATA_SECTION_CONTEXT = 8;

    /**
     * The end tag context.
     */
    public static final int END_TAG_CONTEXT = 9;

    /**
     * The attribute value context.
     */
    public static final int ATTRIBUTE_VALUE_CONTEXT = 10;

    /**
     * The ATTLIST context.
     */
    public static final int ATTLIST_CONTEXT = 11;

    /**
     * The element declaration context.
     */
    public static final int ELEMENT_DECLARATION_CONTEXT = 12;

    /**
     * The entity context.
     */
    public static final int ENTITY_CONTEXT = 13;

    /**
     * The notation context.
     */
    public static final int NOTATION_CONTEXT = 14;

    /**
     * The notation type context.
     */
    public static final int NOTATION_TYPE_CONTEXT = 15;

    /**
     * The enumeration context.
     */
    public static final int ENUMERATION_CONTEXT = 16;

    /**
     * The entity value context.
     */
    public static final int ENTITY_VALUE_CONTEXT = 17;

    /**
     * The default resource bundle base name.
     */
    protected static final String BUNDLE_CLASSNAME =
        "org.apache.flex.forks.batik.xml.resources.Messages";

    /**
     * The localizable support.
     */
    protected LocalizableSupport localizableSupport =
        new LocalizableSupport(BUNDLE_CLASSNAME,
                               XMLScanner.class.getClassLoader());

    /**
     * The reader.
     */
    protected NormalizingReader reader;

    /**
     * The current char.
     */
    protected int current;

    /**
     * The type of the current lexical unit.
     */
    protected int type;

    /**
     * The recording buffer.
     */
    protected char[] buffer = new char[1024];

    /**
     * The current position in the buffer.
     */
    protected int position;

    /**
     * The start offset of the last lexical unit.
     */
    protected int start;

    /**
     * The end offset of the last lexical unit.
     */
    protected int end;

    /**
     * The current scanning context.
     */
    protected int context;

    /**
     * The depth in the xml tree.
     */
    protected int depth;

    /**
     * A PI end has been previously read.
     */
    protected boolean piEndRead;

    /**
     * The scanner is in the internal DTD.
     */
    protected boolean inDTD;

    /**
     * The last attribute delimiter encountered.
     */
    protected char attrDelimiter;

    /**
     * A CDATA section end is the next token
     */
    protected boolean cdataEndRead;

    /**
     * Creates a new XML scanner.
     * @param r The reader to scan.
     */
    public XMLScanner(Reader r) throws XMLException {
        context = DOCUMENT_START_CONTEXT;
        try {
            reader = new StreamNormalizingReader(r);
            current = nextChar();
        } catch (IOException e) {
            throw new XMLException(e);
        }
    }

    /**
     * Creates a new XML scanner.
     * @param is The input stream to scan.
     * @param enc The character encoding to use.
     */
    public XMLScanner(InputStream is, String enc) throws XMLException {
        context = DOCUMENT_START_CONTEXT;
        try {
            reader = new StreamNormalizingReader(is, enc);
            current = nextChar();
        } catch (IOException e) {
            throw new XMLException(e);
        }
    }

    /**
     * Creates a new XML scanner.
     * @param s The string to parse.
     */
    public XMLScanner(String s) throws XMLException {
        context = DOCUMENT_START_CONTEXT;
        try {
            reader = new StringNormalizingReader(s);
            current = nextChar();
        } catch (IOException e) {
            throw new XMLException(e);
        }
    }

    /**
     * Implements {@link org.apache.flex.forks.batik.i18n.Localizable#setLocale(Locale)}.
     */
    public  void setLocale(Locale l) {
        localizableSupport.setLocale(l);
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
     * Sets the current depth in the XML tree.
     */
    public void setDepth(int i) {
        depth = i;
    }

    /**
     * Returns the current depth in the XML tree.
     */
    public int getDepth() {
        return depth;
    }

    /**
     * Sets the current context.
     */
    public void setContext(int c) {
        context = c;
    }

    /**
     * Returns the current context.
     */
    public int getContext() {
        return context;
    }

    /**
     * The current lexical unit type like defined in LexicalUnits.
     */
    public int getType() {
        return type;
    }

    /**
     * Returns the current line.
     */
    public int getLine() {
        return reader.getLine();
    }

    /**
     * Returns the current column.
     */
    public int getColumn() {
        return reader.getColumn();
    }

    /**
     * Returns the buffer used to store the chars.
     */
    public char[] getBuffer() {
        return buffer;
    }

    /**
     * Returns the start offset of the last lexical unit.
     */
    public int getStart() {
        return start;
    }

    /**
     * Returns the end offset of the last lexical unit.
     */
    public int getEnd() {
        return end;
    }

    /**
     * Returns the last encountered string delimiter.
     */
    public char getStringDelimiter() {
        return attrDelimiter;
    }

    /**
     * Returns the start offset of the current lexical unit.
     */
    public int getStartOffset() {
        switch (type) {
        case LexicalUnits.SECTION_END:
            return -3;

        case LexicalUnits.PI_END:
            return -2;

        case LexicalUnits.STRING:
        case LexicalUnits.ENTITY_REFERENCE:
        case LexicalUnits.PARAMETER_ENTITY_REFERENCE:
        case LexicalUnits.START_TAG:
        case LexicalUnits.FIRST_ATTRIBUTE_FRAGMENT:
            return 1;

        case LexicalUnits.PI_START:
        case LexicalUnits.END_TAG:
        case LexicalUnits.CHARACTER_REFERENCE:
            return 2;

        case LexicalUnits.COMMENT:
            return 4;

        default:
            return 0;
        }
    }

    /**
     * Returns the end offset of the current lexical unit.
     */
    public int getEndOffset() {
        switch (type) {
        case LexicalUnits.STRING:
        case LexicalUnits.ENTITY_REFERENCE:
        case LexicalUnits.CHARACTER_REFERENCE:
        case LexicalUnits.PARAMETER_ENTITY_REFERENCE:
        case LexicalUnits.LAST_ATTRIBUTE_FRAGMENT:
            return -1;

        case LexicalUnits.PI_DATA:
            return -2;

        case LexicalUnits.COMMENT:
            return -3;

        case LexicalUnits.CHARACTER_DATA:
            if (cdataEndRead) {
                return -3;
            }
            return 0;

        default:
            return 0;
        }
    }

    /**
     * Clears the buffer.
     */
    public void clearBuffer() {
        if (position <= 0) {
            position = 0;
        } else {
            buffer[0] = buffer[position - 1];
            position = 1;
        }
    }

    /**
     * Advances to the next lexical unit.
     * @return The type of the lexical unit like defined in LexicalUnits.
     */
    public int next() throws XMLException {
        return next(context);
    }

    /**
     * Advances to the next lexical unit.
     * @param ctx The context to use for scanning.
     * @return The type of the lexical unit like defined in LexicalUnits.
     */
    public int next(int ctx) throws XMLException {
        start = position - 1;
        try {
            switch (ctx) {
            case DOCUMENT_START_CONTEXT:
                type = nextInDocumentStart();
                break;

            case TOP_LEVEL_CONTEXT:
                type = nextInTopLevel();
                break;

            case PI_CONTEXT:
                type = nextInPI();
                break;

            case START_TAG_CONTEXT:
                type = nextInStartTag();
                break;

            case ATTRIBUTE_VALUE_CONTEXT:
                type = nextInAttributeValue();
                break;

            case CONTENT_CONTEXT:
                type = nextInContent();
                break;

            case END_TAG_CONTEXT:
                type = nextInEndTag();
                break;

            case CDATA_SECTION_CONTEXT:
                type = nextInCDATASection();
                break;

            case XML_DECL_CONTEXT:
                type = nextInXMLDecl();
                break;

            case DOCTYPE_CONTEXT:
                type = nextInDoctype();
                break;

            case DTD_DECLARATIONS_CONTEXT:
                type = nextInDTDDeclarations();
                break;

            case ELEMENT_DECLARATION_CONTEXT:
                type = nextInElementDeclaration();
                break;

            case ATTLIST_CONTEXT:
                type = nextInAttList();
                break;

            case NOTATION_CONTEXT:
                type = nextInNotation();
                break;

            case ENTITY_CONTEXT:
                type = nextInEntity();
                break;

            case ENTITY_VALUE_CONTEXT:
                return nextInEntityValue();

            case NOTATION_TYPE_CONTEXT:
                return nextInNotationType();

            case ENUMERATION_CONTEXT:
                return nextInEnumeration();

            default:
                throw new IllegalArgumentException("unexpected ctx:" + ctx );
            }
        } catch (IOException e) {
            throw new XMLException(e);
        }
        end = position - ((current == -1) ? 0 : 1);
        return type;
    }

    /**
     * Reads the first token in the stream.
     */
    protected int nextInDocumentStart() throws IOException, XMLException {
        switch (current) {
        case 0x9:
        case 0xA:
        case 0xD:
        case 0x20:
            do {
                nextChar();
            } while (current != -1 && XMLUtilities.isXMLSpace((char)current));
            context = (depth == 0) ? TOP_LEVEL_CONTEXT : CONTENT_CONTEXT;
            return LexicalUnits.S;

        case '<':
            switch (nextChar()) {
            case '?':
                int c1 = nextChar();
                if (c1 == -1 ||
                    !XMLUtilities.isXMLNameFirstCharacter((char)c1)) {
                    throw createXMLException("invalid.pi.target");
                }
                context = PI_CONTEXT;
                int c2 = nextChar();
                if (c2 == -1 || !XMLUtilities.isXMLNameCharacter((char)c2)) {
                    return LexicalUnits.PI_START;
                }
                int c3 = nextChar();
                if (c3 == -1 || !XMLUtilities.isXMLNameCharacter((char)c3)) {
                    return LexicalUnits.PI_START;
                }
                int c4 = nextChar();
                if (c4 != -1 && XMLUtilities.isXMLNameCharacter((char)c4)) {
                    do {
                        nextChar();
                    } while (current != -1 &&
                             XMLUtilities.isXMLNameCharacter((char)current));
                    return LexicalUnits.PI_START;
                }
                if (c1 == 'x' && c2 == 'm' && c3 == 'l') {
                    context = XML_DECL_CONTEXT;
                    return LexicalUnits.XML_DECL_START;
                }
                if ((c1 == 'x' || c1 == 'X') &&
                    (c2 == 'm' || c2 == 'M') &&
                    (c3 == 'l' || c3 == 'L')) {
                    throw createXMLException("xml.reserved");
                }
                return LexicalUnits.PI_START;

            case '!':
                switch (nextChar()) {
                case '-':
                    return readComment();

                case 'D':
                    context = DOCTYPE_CONTEXT;
                    return readIdentifier("OCTYPE",
                                          LexicalUnits.DOCTYPE_START,
                                          -1);

                default:
                    throw createXMLException("invalid.doctype");
                }

            default:
                context = START_TAG_CONTEXT;
                depth++;
                return readName(LexicalUnits.START_TAG);
            }

        case -1:
            return LexicalUnits.EOF;

        default:
            if (depth == 0) {
                throw createXMLException("invalid.character");
            } else {
                return nextInContent();
            }
        }
    }

    /**
     * Advances to the next lexical unit in the top level context.
     * @return The type of the lexical unit like defined in LexicalUnits.
     */
    protected int nextInTopLevel() throws IOException, XMLException {
        switch (current) {
        case 0x9:
        case 0xA:
        case 0xD:
        case 0x20:
            do {
                nextChar();
            } while (current != -1 &&
                     XMLUtilities.isXMLSpace((char)current));
            return LexicalUnits.S;

        case '<':
            switch (nextChar()) {
            case '?':
                context = PI_CONTEXT;
                return readPIStart();

            case '!':
                switch (nextChar()) {
                case '-':
                    return readComment();

                case 'D':
                    context = DOCTYPE_CONTEXT;
                    return readIdentifier("OCTYPE",
                                          LexicalUnits.DOCTYPE_START,
                                          -1);

                default:
                    throw createXMLException("invalid.character");
                }
            default:
                context = START_TAG_CONTEXT;
                depth++;
                return readName(LexicalUnits.START_TAG);
            }

        case -1:
            return LexicalUnits.EOF;

        default:
            throw createXMLException("invalid.character");
        }
    }

    /**
     * Returns the next lexical unit in the context of a processing
     * instruction.
     */
    protected int nextInPI() throws IOException, XMLException {
        if (piEndRead) {
            piEndRead = false;
            context = (depth == 0) ? TOP_LEVEL_CONTEXT : CONTENT_CONTEXT;
            return LexicalUnits.PI_END;
        }

        switch (current) {
        case 0x9:
        case 0xA:
        case 0xD:
        case 0x20:
            do {
                nextChar();
            } while (current != -1 &&
                     XMLUtilities.isXMLSpace((char)current));
            return LexicalUnits.S;
        case '?':
            if (nextChar() != '>') {
                throw createXMLException("pi.end.expected");
            }
            nextChar();
            if (inDTD) {
                context = DTD_DECLARATIONS_CONTEXT;
            } else if (depth == 0) {
                context = TOP_LEVEL_CONTEXT;
            } else {
                context = CONTENT_CONTEXT;
            }
            return LexicalUnits.PI_END;

        default:
            do {
                do {
                    nextChar();
                } while (current != -1 && current != '?');
                nextChar();
            } while (current != -1 && current != '>');
            nextChar();
            piEndRead = true;
            return LexicalUnits.PI_DATA;
        }
    }

    /**
     * Returns the next lexical unit in the context of a start tag.
     */
    protected int nextInStartTag() throws IOException, XMLException {
        switch (current) {
        case 0x9:
        case 0xA:
        case 0xD:
        case 0x20:
            do {
                nextChar();
            } while (current != -1 && XMLUtilities.isXMLSpace((char)current));
            return LexicalUnits.S;

        case '/':
            if (nextChar() != '>') {
                throw createXMLException("malformed.tag.end");
            }
            nextChar();
            context = (--depth == 0) ? TOP_LEVEL_CONTEXT : CONTENT_CONTEXT;
            return LexicalUnits.EMPTY_ELEMENT_END;

        case '>':
            nextChar();
            context = CONTENT_CONTEXT;
            return LexicalUnits.END_CHAR;

        case '=':
            nextChar();
            return LexicalUnits.EQ;

        case '"':
            attrDelimiter = '"';
            nextChar();

            for (;;) {
                switch (current) {
                case '"':
                    nextChar();
                    return LexicalUnits.STRING;

                case '&':
                    context = ATTRIBUTE_VALUE_CONTEXT;
                    return LexicalUnits.FIRST_ATTRIBUTE_FRAGMENT;

                case '<':
                    throw createXMLException("invalid.character");

                case -1:
                    throw createXMLException("unexpected.eof");
                }
                nextChar();
            }

        case '\'':
            attrDelimiter = '\'';
            nextChar();

            for (;;) {
                switch (current) {
                case '\'':
                    nextChar();
                    return LexicalUnits.STRING;

                case '&':
                    context = ATTRIBUTE_VALUE_CONTEXT;
                    return LexicalUnits.FIRST_ATTRIBUTE_FRAGMENT;

                case '<':
                    throw createXMLException("invalid.character");

                case -1:
                    throw createXMLException("unexpected.eof");
                }
                nextChar();
            }

        default:
            return readName(LexicalUnits.NAME);
        }
    }

    /**
     * Returns the next lexical unit in the context of an attribute value.
     */
    protected int nextInAttributeValue()
        throws IOException, XMLException {
        if (current == -1) {
            return LexicalUnits.EOF;
        }

        if (current == '&') {
            return readReference();

        } else {
            loop: for (;;) {
                switch (current) {
                case '&':
                case '<':
                case -1:
                    break loop;
                case '"':
                case '\'':
                    if (current == attrDelimiter) {
                        break loop;
                    }
                }
                nextChar();
            }

            switch (current) {
            case -1:
                break;

            case '<':
                throw createXMLException("invalid.character");

            case '&':
                return LexicalUnits.ATTRIBUTE_FRAGMENT;

            case '\'':
            case '"':
                nextChar();
                if (inDTD) {
                    context = ATTLIST_CONTEXT;
                } else {
                    context = START_TAG_CONTEXT;
                }
            }
            return LexicalUnits.LAST_ATTRIBUTE_FRAGMENT;
        }
    }

    /**
     * Returns the next lexical unit in the context of an element content.
     */
    protected int nextInContent() throws IOException, XMLException {
        switch (current) {
        case -1:
            return LexicalUnits.EOF;

        case '&':
            return readReference();

        case '<':
            switch (nextChar()) {
            case '?':
                context = PI_CONTEXT;
                return readPIStart();

            case '!':
                switch (nextChar()) {
                case '-':
                    return readComment();
                case '[':
                    context = CDATA_SECTION_CONTEXT;
                    return readIdentifier("CDATA[",
                                          LexicalUnits.CDATA_START,
                                          -1);
                default:
                    throw createXMLException("invalid.character");
                }

            case '/':
                nextChar();
                context = END_TAG_CONTEXT;
                return readName(LexicalUnits.END_TAG);

            default:
                depth++;
                context = START_TAG_CONTEXT;
                return readName(LexicalUnits.START_TAG);
            }

        default:
            loop: for (;;) {
                switch (current) {
                default:
                    nextChar();
                    break;

                case -1:
                case '&':
                case '<':
                    break loop;
                }
            }
            return LexicalUnits.CHARACTER_DATA;
        }
    }

    /**
     * Returns the next lexical unit in the context of a end tag.
     */
    protected int nextInEndTag() throws IOException, XMLException {
        switch (current) {
        case 0x9:
        case 0xA:
        case 0xD:
        case 0x20:
            do {
                nextChar();
            } while (current != -1 &&
                     XMLUtilities.isXMLSpace((char)current));
            return LexicalUnits.S;

        case '>':
            if (--depth < 0) {
                throw createXMLException("unexpected.end.tag");
            } else if (depth == 0) {
                context = TOP_LEVEL_CONTEXT;
            } else {
                context = CONTENT_CONTEXT;
            }
            nextChar();
            return LexicalUnits.END_CHAR;

        default:
            throw createXMLException("invalid.character");
        }
    }

    /**
     * Returns the next lexical unit in the context of a CDATA section.
     */
    protected int nextInCDATASection() throws IOException, XMLException {
        if (cdataEndRead) {
            cdataEndRead = false;
            context = CONTENT_CONTEXT;
            return LexicalUnits.SECTION_END;
        }

        while (current != -1) {
            while (current != ']' && current != -1) {
                nextChar();
            }
            if (current != -1) {
                nextChar();
                if (current == ']') {
                    nextChar();
                    if (current == '>') {
                        break;
                    }
                }
            }
        }
        if (current == -1) {
            throw createXMLException("unexpected.eof");
        }
        nextChar();
        cdataEndRead = true;
        return LexicalUnits.CHARACTER_DATA;
    }

    /**
     * Returns the next lexical unit in the context of an XML declaration.
     */
    protected int nextInXMLDecl() throws IOException, XMLException {
        switch (current) {
        case 0x9:
        case 0xA:
        case 0xD:
        case 0x20:
            do {
                nextChar();
            } while (current != -1 &&
                     XMLUtilities.isXMLSpace((char)current));
            return LexicalUnits.S;
        case 'v':
            return readIdentifier("ersion",
                                  LexicalUnits.VERSION_IDENTIFIER,
                                  -1);
        case 'e':
            return readIdentifier("ncoding",
                                  LexicalUnits.ENCODING_IDENTIFIER,
                                  -1);
        case 's':
            return readIdentifier("tandalone",
                                  LexicalUnits.STANDALONE_IDENTIFIER,
                                  -1);
        case '=':
            nextChar();
            return LexicalUnits.EQ;

        case '?':
            nextChar();
            if (current != '>') {
                throw createXMLException("pi.end.expected");
            }
            nextChar();
            context = TOP_LEVEL_CONTEXT;
            return LexicalUnits.PI_END;

        case '"':
            attrDelimiter = '"';
            return readString();

        case '\'':
            attrDelimiter = '\'';
            return readString();

        default:
            throw createXMLException("invalid.character");
        }
    }

    /**
     * Returns the next lexical unit in the context of a doctype.
     */
    protected int nextInDoctype() throws IOException, XMLException {
        switch (current) {
        case 0x9:
        case 0xA:
        case 0xD:
        case 0x20:
            do {
                nextChar();
            } while (current != -1 &&
                     XMLUtilities.isXMLSpace((char)current));
            return LexicalUnits.S;

        case '>':
            nextChar();
            context = TOP_LEVEL_CONTEXT;
            return LexicalUnits.END_CHAR;

        case 'S':
            return readIdentifier("YSTEM",
                                  LexicalUnits.SYSTEM_IDENTIFIER,
                                  LexicalUnits.NAME);

        case 'P':
            return readIdentifier("UBLIC",
                                  LexicalUnits.PUBLIC_IDENTIFIER,
                                  LexicalUnits.NAME);

        case '"':
            attrDelimiter = '"';
            return readString();

        case '\'':
            attrDelimiter = '\'';
            return readString();

        case '[':
            nextChar();
            context = DTD_DECLARATIONS_CONTEXT;
            inDTD = true;
            return LexicalUnits.LSQUARE_BRACKET;

        default:
            return readName(LexicalUnits.NAME);
        }
    }

    /**
     * Returns the next lexical unit in the context dtd declarations.
     */
    protected int nextInDTDDeclarations() throws IOException, XMLException {
        switch (current) {
        case 0x9:
        case 0xA:
        case 0xD:
        case 0x20:
            do {
                nextChar();
            } while (current != -1 &&
                     XMLUtilities.isXMLSpace((char)current));
            return LexicalUnits.S;

        case ']':
            nextChar();
            context = DOCTYPE_CONTEXT;
            inDTD = false;
            return LexicalUnits.RSQUARE_BRACKET;

        case '%':
            return readPEReference();

        case '<':
            switch (nextChar()) {
            case '?':
                context = PI_CONTEXT;
                return readPIStart();

            case '!':
                switch (nextChar()) {
                case '-':
                    return readComment();

                case 'E':
                    switch (nextChar()) {
                    case 'L':
                        context = ELEMENT_DECLARATION_CONTEXT;
                        return readIdentifier
                            ("EMENT",
                             LexicalUnits.ELEMENT_DECLARATION_START,
                             -1);
                    case 'N':
                        context = ENTITY_CONTEXT;
                        return readIdentifier("TITY",
                                              LexicalUnits.ENTITY_START,
                                              -1);
                    default:
                        throw createXMLException("invalid.character");
                    }

                case 'A':
                    context = ATTLIST_CONTEXT;
                    return readIdentifier("TTLIST",
                                          LexicalUnits.ATTLIST_START,
                                          -1);
                case 'N':
                    context = NOTATION_CONTEXT;
                    return readIdentifier("OTATION",
                                          LexicalUnits.NOTATION_START,
                                          -1);
                default:
                    throw createXMLException("invalid.character");
                }
            default:
                throw createXMLException("invalid.character");
            }
        default:
            throw createXMLException("invalid.character");
        }
    }

    /**
     * Reads a simple string, like the ones used for version, encoding,
     * public/system identifiers...
     * The current character must be the string delimiter.
     * @return type.
     */
    protected int readString() throws IOException, XMLException {
        do {
            nextChar();
        } while (current != -1 && current != attrDelimiter);
        if (current == -1) {
            throw createXMLException("unexpected.eof");
        }
        nextChar();
        return LexicalUnits.STRING;
    }

    /**
     * Reads a comment. '&lt;!-' must have been read.
     */
    protected int readComment() throws IOException, XMLException {
        if (nextChar() != '-') {
            throw createXMLException("malformed.comment");
        }
        int c = nextChar();
        while (c != -1) {
            while (c != -1 && c != '-') {
                c = nextChar();
            }
            c = nextChar();
            if (c == '-') {
                break;
            }
        }
        if (c == -1) {
            throw createXMLException("unexpected.eof");
        }
        c = nextChar();
        if (c != '>') {
            throw createXMLException("malformed.comment");
        }
        nextChar();
        return LexicalUnits.COMMENT;
    }

    /**
     * Reads the given identifier.
     * @param s The portion of the identifier to read.
     * @param type The lexical unit type of the identifier.
     * @param ntype The lexical unit type to set if the identifier do not
     * match or -1 if an error must be signaled.
     */
    protected int readIdentifier(String s, int type, int ntype)
        throws IOException, XMLException {
        int len = s.length();
        for (int i = 0; i < len; i++) {
            nextChar();
            if (current != s.charAt(i)) {
                if (ntype == -1) {
                    throw createXMLException("invalid.character");
                } else {
                    while (current != -1 &&
                           XMLUtilities.isXMLNameCharacter((char)current)) {
                        nextChar();
                    }
                    return ntype;
                }
            }
        }
        nextChar();
        return type;
    }

    /**
     * Reads a name. The current character must be the first character.
     * @param type The lexical unit type to set.
     * @return type.
     */
    protected int readName(int type) throws IOException, XMLException {
        if (current == -1) {
            throw createXMLException("unexpected.eof");
        }
        if (!XMLUtilities.isXMLNameFirstCharacter((char)current)) {
            throw createXMLException("invalid.name");
        }
        do {
            nextChar();
        } while (current != -1 &&
                 XMLUtilities.isXMLNameCharacter((char)current));
        return type;
    }


    /**
     * Reads a processing instruction start.
     * @return type.
     */
    protected int readPIStart() throws IOException, XMLException {
        int c1 = nextChar();
        if (c1 == -1) {
            throw createXMLException("unexpected.eof");
        }
        if (!XMLUtilities.isXMLNameFirstCharacter((char)current)) {
            throw createXMLException("malformed.pi.target");
        }
        int c2 = nextChar();
        if (c2 == -1 || !XMLUtilities.isXMLNameCharacter((char)c2)) {
            return LexicalUnits.PI_START;
        }
        int c3 = nextChar();
        if (c3 == -1 || !XMLUtilities.isXMLNameCharacter((char)c3)) {
            return LexicalUnits.PI_START;
        }
        int c4 = nextChar();
        if (c4 != -1 && XMLUtilities.isXMLNameCharacter((char)c4)) {
            do {
                nextChar();
            } while (current != -1 &&
                     XMLUtilities.isXMLNameCharacter((char)current));
            return LexicalUnits.PI_START;
        }
        if ((c1 == 'x' || c1 == 'X') &&
            (c2 == 'm' || c2 == 'M') &&
            (c3 == 'l' || c3 == 'L')) {
            throw createXMLException("xml.reserved");
        }
        return LexicalUnits.PI_START;
    }

    /**
     * Returns the next lexical unit in the context of a element declaration.
     */
    protected int nextInElementDeclaration() throws IOException, XMLException {
        switch (current) {
        case 0x9:
        case 0xA:
        case 0xD:
        case 0x20:
            do {
                nextChar();
            } while (current != -1 && XMLUtilities.isXMLSpace((char)current));
            return LexicalUnits.S;

        case '>':
            nextChar();
            context = DTD_DECLARATIONS_CONTEXT;
            return LexicalUnits.END_CHAR;

        case '%':
            nextChar();
            int t = readName(LexicalUnits.PARAMETER_ENTITY_REFERENCE);
            if (current != ';') {
                throw createXMLException("malformed.parameter.entity");
            }
            nextChar();
            return t;

        case 'E':
            return readIdentifier("MPTY",
                                  LexicalUnits.EMPTY_IDENTIFIER,
                                  LexicalUnits.NAME);

        case 'A':
            return readIdentifier("NY",
                                  LexicalUnits.ANY_IDENTIFIER,
                                  LexicalUnits.NAME);

        case '?':
            nextChar();
            return LexicalUnits.QUESTION;

        case '+':
            nextChar();
            return LexicalUnits.PLUS;

        case '*':
            nextChar();
            return LexicalUnits.STAR;

        case '(':
            nextChar();
            return LexicalUnits.LEFT_BRACE;

        case ')':
            nextChar();
            return LexicalUnits.RIGHT_BRACE;

        case '|':
            nextChar();
            return LexicalUnits.PIPE;

        case ',':
            nextChar();
            return LexicalUnits.COMMA;

        case '#':
            return readIdentifier("PCDATA",
                                  LexicalUnits.PCDATA_IDENTIFIER,
                                  -1);

        default:
            return readName(LexicalUnits.NAME);
        }
    }

    /**
     * Returns the next lexical unit in the context of an attribute list.
     */
    protected int nextInAttList() throws IOException, XMLException {
        switch (current) {
        case 0x9:
        case 0xA:
        case 0xD:
        case 0x20:
            do {
                nextChar();
            } while (current != -1 && XMLUtilities.isXMLSpace((char)current));
            return LexicalUnits.S;

        case '>':
            nextChar();
            context = DTD_DECLARATIONS_CONTEXT;
            return type = LexicalUnits.END_CHAR;

        case '%':
            int t = readName(LexicalUnits.PARAMETER_ENTITY_REFERENCE);
            if (current != ';') {
                throw createXMLException("malformed.parameter.entity");
            }
            nextChar();
            return t;

        case 'C':
            return readIdentifier("DATA",
                                  LexicalUnits.CDATA_IDENTIFIER,
                                  LexicalUnits.NAME);

        case 'I':
            nextChar();
            if (current != 'D') {
                do {
                    nextChar();
                } while (current != -1 &&
                         XMLUtilities.isXMLNameCharacter((char)current));
                return LexicalUnits.NAME;
            }
            nextChar();
            if (current == -1 ||
                !XMLUtilities.isXMLNameCharacter((char)current)) {
                return LexicalUnits.ID_IDENTIFIER;
            }
            if (current != 'R') {
                do {
                    nextChar();
                } while (current != -1 &&
                         XMLUtilities.isXMLNameCharacter((char)current));
                return LexicalUnits.NAME;
            }
            nextChar();
            if (current == -1 ||
                !XMLUtilities.isXMLNameCharacter((char)current)) {
                return LexicalUnits.NAME;
            }
            if (current != 'E') {
                do {
                    nextChar();
                } while (current != -1 &&
                         XMLUtilities.isXMLNameCharacter((char)current));
                return LexicalUnits.NAME;
            }
            nextChar();
            if (current == -1 ||
                !XMLUtilities.isXMLNameCharacter((char)current)) {
                return LexicalUnits.NAME;
            }
            if (current != 'F') {
                do {
                    nextChar();
                } while (current != -1 &&
                         XMLUtilities.isXMLNameCharacter((char)current));
                return LexicalUnits.NAME;
            }
            nextChar();
            if (current == -1 ||
                !XMLUtilities.isXMLNameCharacter((char)current)) {
                return LexicalUnits.IDREF_IDENTIFIER;
            }
            if (current != 'S') {
                do {
                    nextChar();
                } while (current != -1 &&
                         XMLUtilities.isXMLNameCharacter((char)current));
                return LexicalUnits.NAME;
            }
            nextChar();
            if (current == -1 ||
                !XMLUtilities.isXMLNameCharacter((char)current)) {
                return LexicalUnits.IDREFS_IDENTIFIER;
            }
            do {
                nextChar();
            } while (current != -1 &&
                     XMLUtilities.isXMLNameCharacter((char)current));
            return type = LexicalUnits.NAME;

        case 'N':
            switch (nextChar()) {
            default:
                do {
                    nextChar();
                } while (current != -1 &&
                         XMLUtilities.isXMLNameCharacter((char)current));
                return LexicalUnits.NAME;

            case 'O':
                context = NOTATION_TYPE_CONTEXT;
                return readIdentifier("TATION",
                                      LexicalUnits.NOTATION_IDENTIFIER,
                                      LexicalUnits.NAME);

            case 'M':
                nextChar();
                if (current == -1 ||
                    !XMLUtilities.isXMLNameCharacter((char)current)) {
                    return LexicalUnits.NAME;
                }
                if (current != 'T') {
                    do {
                        nextChar();
                    } while (current != -1 &&
                             XMLUtilities.isXMLNameCharacter((char)current));
                    return LexicalUnits.NAME;
                }
                nextChar();
                if (current == -1 ||
                    !XMLUtilities.isXMLNameCharacter((char)current)) {
                    return LexicalUnits.NAME;
                }
                if (current != 'O') {
                    do {
                        nextChar();
                    } while (current != -1 &&
                             XMLUtilities.isXMLNameCharacter((char)current));
                    return LexicalUnits.NAME;
                }
                nextChar();
                if (current == -1 ||
                    !XMLUtilities.isXMLNameCharacter((char)current)) {
                    return LexicalUnits.NAME;
                }
                if (current != 'K') {
                    do {
                        nextChar();
                    } while (current != -1 &&
                             XMLUtilities.isXMLNameCharacter((char)current));
                    return LexicalUnits.NAME;
                }
                nextChar();
                if (current == -1 ||
                    !XMLUtilities.isXMLNameCharacter((char)current)) {
                    return LexicalUnits.NAME;
                }
                if (current != 'E') {
                    do {
                        nextChar();
                    } while (current != -1 &&
                             XMLUtilities.isXMLNameCharacter((char)current));
                    return LexicalUnits.NAME;
                }
                nextChar();
                if (current == -1 ||
                    !XMLUtilities.isXMLNameCharacter((char)current)) {
                    return LexicalUnits.NAME;
                }
                if (current != 'N') {
                    do {
                        nextChar();
                    } while (current != -1 &&
                             XMLUtilities.isXMLNameCharacter((char)current));
                    return LexicalUnits.NAME;
                }
                nextChar();
                if (current == -1 ||
                    !XMLUtilities.isXMLNameCharacter((char)current)) {
                    return LexicalUnits.NMTOKEN_IDENTIFIER;
                }
                if (current != 'S') {
                    do {
                        nextChar();
                    } while (current != -1 &&
                             XMLUtilities.isXMLNameCharacter((char)current));
                    return LexicalUnits.NAME;
                }
                nextChar();
                if (current == -1 ||
                    !XMLUtilities.isXMLNameCharacter((char)current)) {
                    return LexicalUnits.NMTOKENS_IDENTIFIER;
                }
                do {
                    nextChar();
                } while (current != -1 &&
                         XMLUtilities.isXMLNameCharacter((char)current));
                return LexicalUnits.NAME;
            }

        case 'E':
            nextChar();
            if (current != 'N') {
                do {
                    nextChar();
                } while (current != -1 &&
                         XMLUtilities.isXMLNameCharacter((char)current));
                return LexicalUnits.NAME;
            }
            nextChar();
            if (current == -1 ||
                !XMLUtilities.isXMLNameCharacter((char)current)) {
                return LexicalUnits.NAME;
            }
            if (current != 'T') {
                do {
                    nextChar();
                } while (current != -1 &&
                         XMLUtilities.isXMLNameCharacter((char)current));
                return LexicalUnits.NAME;
            }
            nextChar();
            if (current == -1 ||
                !XMLUtilities.isXMLNameCharacter((char)current)) {
                return LexicalUnits.NAME;
            }
            if (current != 'I') {
                do {
                    nextChar();
                } while (current != -1 &&
                         XMLUtilities.isXMLNameCharacter((char)current));
                return LexicalUnits.NAME;
            }
            nextChar();
            if (current == -1 ||
                !XMLUtilities.isXMLNameCharacter((char)current)) {
                return LexicalUnits.NAME;
            }
            if (current != 'T') {
                do {
                    nextChar();
                } while (current != -1 &&
                         XMLUtilities.isXMLNameCharacter((char)current));
                return type = LexicalUnits.NAME;
            }
            nextChar();
            if (current == -1 ||
                !XMLUtilities.isXMLNameCharacter((char)current)) {
                return LexicalUnits.NAME;
            }
            switch (current) {
            case 'Y':
                nextChar();
                if (current == -1 ||
                    !XMLUtilities.isXMLNameCharacter((char)current)) {
                    return LexicalUnits.ENTITY_IDENTIFIER;
                }
                do {
                    nextChar();
                } while (current != -1 &&
                         XMLUtilities.isXMLNameCharacter((char)current));
                return LexicalUnits.NAME;
            case 'I':
                nextChar();
                if (current == -1 ||
                    !XMLUtilities.isXMLNameCharacter((char)current)) {
                    return LexicalUnits.NAME;
                }
                if (current != 'E') {
                    do {
                        nextChar();
                    } while (current != -1 &&
                             XMLUtilities.isXMLNameCharacter((char)current));
                    return LexicalUnits.NAME;
                }
                nextChar();
                if (current == -1 ||
                    !XMLUtilities.isXMLNameCharacter((char)current)) {
                    return LexicalUnits.NAME;
                }
                if (current != 'S') {
                    do {
                        nextChar();
                    } while (current != -1 &&
                             XMLUtilities.isXMLNameCharacter((char)current));
                    return LexicalUnits.NAME;
                }
                return LexicalUnits.ENTITIES_IDENTIFIER;

            default:
                if (current == -1 ||
                    !XMLUtilities.isXMLNameCharacter((char)current)) {
                    return LexicalUnits.NAME;
                }
                do {
                    nextChar();
                } while (current != -1 &&
                         XMLUtilities.isXMLNameCharacter((char)current));
                return LexicalUnits.NAME;
            }

        case '"':
            attrDelimiter = '"';
            nextChar();
            if (current == -1) {
                throw createXMLException("unexpected.eof");
            }
            if (current != '"' && current != '&') {
                do {
                    nextChar();
                } while (current != -1 && current != '"' && current != '&');
            }
            switch (current) {
            case '&':
                context = ATTRIBUTE_VALUE_CONTEXT;
                return LexicalUnits.FIRST_ATTRIBUTE_FRAGMENT;

            case '"':
                nextChar();
                return LexicalUnits.STRING;

            default:
                throw createXMLException("invalid.character");
            }

        case '\'':
            attrDelimiter = '\'';
            nextChar();
            if (current == -1) {
                throw createXMLException("unexpected.eof");
            }
            if (current != '\'' && current != '&') {
                do {
                    nextChar();
                } while (current != -1 && current != '\'' && current != '&');
            }
            switch (current) {
            case '&':
                context = ATTRIBUTE_VALUE_CONTEXT;
                return LexicalUnits.FIRST_ATTRIBUTE_FRAGMENT;

            case '\'':
                nextChar();
                return LexicalUnits.STRING;

            default:
                throw createXMLException("invalid.character");
            }

        case '#':
            switch (nextChar()) {
            case 'R':
                return readIdentifier("EQUIRED",
                                      LexicalUnits.REQUIRED_IDENTIFIER,
                                      -1);

            case 'I':
                return readIdentifier("MPLIED",
                                      LexicalUnits.IMPLIED_IDENTIFIER,
                                      -1);
            case 'F':
                return readIdentifier("IXED",
                                      LexicalUnits.FIXED_IDENTIFIER,
                                      -1);
            default:
                throw createXMLException("invalid.character");
            }

        case '(':
            nextChar();
            context = ENUMERATION_CONTEXT;
            return LexicalUnits.LEFT_BRACE;

        default:
            return readName(LexicalUnits.NAME);
        }
    }

    /**
     * Returns the next lexical unit in the context of a notation.
     */
    protected int nextInNotation() throws IOException, XMLException {
        switch (current) {
        case 0x9:
        case 0xA:
        case 0xD:
        case 0x20:
            do {
                nextChar();
            } while (current != -1 &&
                     XMLUtilities.isXMLSpace((char)current));
            return LexicalUnits.S;

        case '>':
            nextChar();
            context = DTD_DECLARATIONS_CONTEXT;
            return LexicalUnits.END_CHAR;

        case '%':
            int t = readName(LexicalUnits.PARAMETER_ENTITY_REFERENCE);
            if (current != ';') {
                throw createXMLException("malformed.parameter.entity");
            }
            nextChar();
            return t;
        case 'S':
            return readIdentifier("YSTEM",
                                  LexicalUnits.SYSTEM_IDENTIFIER,
                                  LexicalUnits.NAME);

        case 'P':
            return readIdentifier("UBLIC",
                                  LexicalUnits.PUBLIC_IDENTIFIER,
                                  LexicalUnits.NAME);

        case '"':
            attrDelimiter = '"';
            return readString();

        case '\'':
            attrDelimiter = '\'';
            return readString();

        default:
            return readName(LexicalUnits.NAME);
        }
    }

    /**
     * Returns the next lexical unit in the context of an entity.
     */
    protected int nextInEntity() throws IOException, XMLException {
        switch (current) {
        case 0x9:
        case 0xA:
        case 0xD:
        case 0x20:
            do {
                nextChar();
            } while (current != -1 &&
                     XMLUtilities.isXMLSpace((char)current));
            return LexicalUnits.S;

        case '>':
            nextChar();
            context = DTD_DECLARATIONS_CONTEXT;
            return LexicalUnits.END_CHAR;

        case '%':
            nextChar();
            return LexicalUnits.PERCENT;

        case 'S':
            return readIdentifier("YSTEM",
                                  LexicalUnits.SYSTEM_IDENTIFIER,
                                  LexicalUnits.NAME);

        case 'P':
            return readIdentifier("UBLIC",
                                  LexicalUnits.PUBLIC_IDENTIFIER,
                                  LexicalUnits.NAME);

        case 'N':
            return readIdentifier("DATA",
                                  LexicalUnits.NDATA_IDENTIFIER,
                                  LexicalUnits.NAME);

        case '"':
            attrDelimiter = '"';
            nextChar();
            if (current == -1) {
                throw createXMLException("unexpected.eof");
            }

            if (current != '"' && current != '&' && current != '%') {
                do {
                    nextChar();
                } while (current != -1 &&
                         current != '"' &&
                         current != '&' &&
                         current != '%');
            }
            switch (current) {
            default:
                throw createXMLException("invalid.character");

            case '&':
            case '%':
                context = ENTITY_VALUE_CONTEXT;
                break;

            case '"':
                nextChar();
                return LexicalUnits.STRING;
            }
            return LexicalUnits.FIRST_ATTRIBUTE_FRAGMENT;

        case '\'':
            attrDelimiter = '\'';
            nextChar();
            if (current == -1) {
                throw createXMLException("unexpected.eof");
            }

            if (current != '\'' && current != '&' && current != '%') {
                do {
                    nextChar();
                } while (current != -1 &&
                         current != '\'' &&
                         current != '&' &&
                         current != '%');
            }
            switch (current) {
            default:
                throw createXMLException("invalid.character");

            case '&':
            case '%':
                context = ENTITY_VALUE_CONTEXT;
                break;

            case '\'':
                nextChar();
                return LexicalUnits.STRING;
            }
            return LexicalUnits.FIRST_ATTRIBUTE_FRAGMENT;

        default:
            return readName(LexicalUnits.NAME);
        }
    }

    /**
     * Returns the next lexical unit in the context of an entity value.
     */
    protected int nextInEntityValue() throws IOException, XMLException {
        switch (current) {
        case '&':
            return readReference();

        case '%':
            int t = nextChar();
            readName(LexicalUnits.PARAMETER_ENTITY_REFERENCE);
            if (current != ';') {
                throw createXMLException("invalid.parameter.entity");
            }
            nextChar();
            return t;

        default:
            while (current != -1 &&
                   current != attrDelimiter &&
                   current != '&' &&
                   current != '%') {
                nextChar();
            }
            switch (current) {
            case -1:
                throw createXMLException("unexpected.eof");

            case '\'':
            case '"':
                nextChar();
                context = ENTITY_CONTEXT;
                return LexicalUnits.STRING;
            }
            return LexicalUnits.FIRST_ATTRIBUTE_FRAGMENT;
        }
    }

    /**
     * Returns the next lexical unit in the context of a notation type.
     */
    protected int nextInNotationType() throws IOException, XMLException {
        switch (current) {
        case 0x9:
        case 0xA:
        case 0xD:
        case 0x20:
            do {
                nextChar();
            } while (current != -1 && XMLUtilities.isXMLSpace((char)current));
            return LexicalUnits.S;

        case '|':
            nextChar();
            return LexicalUnits.PIPE;

        case '(':
            nextChar();
            return LexicalUnits.LEFT_BRACE;

        case ')':
            nextChar();
            context = ATTLIST_CONTEXT;
            return LexicalUnits.RIGHT_BRACE;

        default:
            return readName(LexicalUnits.NAME);
        }
    }

    /**
     * Returns the next lexical unit in the context of an enumeration.
     */
    protected int nextInEnumeration() throws IOException, XMLException {
        switch (current) {
        case 0x9:
        case 0xA:
        case 0xD:
        case 0x20:
            do {
                nextChar();
            } while (current != -1 && XMLUtilities.isXMLSpace((char)current));
            return LexicalUnits.S;

        case '|':
            nextChar();
            return LexicalUnits.PIPE;

        case ')':
            nextChar();
            context = ATTLIST_CONTEXT;
            return LexicalUnits.RIGHT_BRACE;

        default:
            return readNmtoken();
        }
    }


    /**
     * Reads an entity or character reference. The current character
     * must be '&amp;'.
     * @return type.
     */
    protected int readReference() throws IOException, XMLException {
        nextChar();
        if (current == '#') {
            nextChar();
            int i = 0;
            switch (current) {
            case 'x':
                do {
                    i++;
                    nextChar();
                } while ((current >= '0' && current <= '9') ||
                         (current >= 'a' && current <= 'f') ||
                         (current >= 'A' && current <= 'F'));
                break;

            default:
                do {
                    i++;
                    nextChar();
                } while (current >= '0' && current <= '9');
                break;

            case -1:
                throw createXMLException("unexpected.eof");
            }
            if (i == 1 || current != ';') {
                throw createXMLException("character.reference");
            }
            nextChar();
            return LexicalUnits.CHARACTER_REFERENCE;
        } else {
            int t = readName(LexicalUnits.ENTITY_REFERENCE);
            if (current != ';') {
                throw createXMLException("character.reference");
            }
            nextChar();
            return t;
        }
    }

    /**
     * Reads a parameter entity reference. The current character must be '%'.
     * @return type.
     */
    protected int readPEReference() throws IOException, XMLException {
        nextChar();
        if (current == -1) {
            throw createXMLException("unexpected.eof");
        }
        if (!XMLUtilities.isXMLNameFirstCharacter((char)current)) {
            throw createXMLException("invalid.parameter.entity");
        }
        do {
            nextChar();
        } while (current != -1 &&
                 XMLUtilities.isXMLNameCharacter((char)current));
        if (current != ';') {
            throw createXMLException("invalid.parameter.entity");
        }
        nextChar();
        return LexicalUnits.PARAMETER_ENTITY_REFERENCE;
    }

    /**
     * Reads a Nmtoken. The current character must be the first character.
     * @return LexicalUnits.NMTOKEN.
     */
    protected int readNmtoken() throws IOException, XMLException {
        if (current == -1) {
            throw createXMLException("unexpected.eof");
        }
        while (XMLUtilities.isXMLNameCharacter((char)current)) {
            nextChar();
        }
        return LexicalUnits.NMTOKEN;
    }

    /**
     * Sets the value of the current char to the next character or -1 if the
     * end of stream has been reached.
     */
    protected int nextChar() throws IOException {
        current = reader.read();

        if (current == -1) {
            return current;
        }

        if (position == buffer.length) {
            char[] t = new char[ 1+ position + position / 2];
            System.arraycopy( buffer, 0, t, 0, position );
            buffer = t;
        }

        return buffer[position++] = (char)current;
    }

    /**
     * Returns an XMLException initialized with the given message key.
     */
    protected XMLException createXMLException(String message) {
        String m;
        try {
            m = formatMessage(message,
                              new Object[] {
                                  new Integer(reader.getLine()),
                                  new Integer(reader.getColumn())
                              });
        } catch (MissingResourceException e) {
            m = message;
        }
        return new XMLException(m);
    }

}
