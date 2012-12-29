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
package org.apache.flex.forks.batik.transcoder.svg2svg;

import java.io.IOException;
import java.io.Reader;
import java.io.Writer;
import java.util.LinkedList;
import java.util.List;

import org.apache.flex.forks.batik.transcoder.ErrorHandler;
import org.apache.flex.forks.batik.transcoder.TranscoderException;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.apache.flex.forks.batik.xml.LexicalUnits;
import org.apache.flex.forks.batik.xml.XMLException;
import org.apache.flex.forks.batik.xml.XMLScanner;

/**
 * This class represents an SVG source files pretty-printer.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: PrettyPrinter.java 478176 2006-11-22 14:50:50Z dvholten $
 */
public class PrettyPrinter {

    // The doctype options.
    public static final int DOCTYPE_CHANGE = 0;
    public static final int DOCTYPE_REMOVE = 1;
    public static final int DOCTYPE_KEEP_UNCHANGED = 2;

    /**
     * The document scanner.
     */
    protected XMLScanner scanner;

    /**
     * The output manager.
     */
    protected OutputManager output;

    /**
     * The writer used to output the document.
     */
    protected Writer writer;

    /**
     * The error handler.
     */
    protected ErrorHandler errorHandler = SVGTranscoder.DEFAULT_ERROR_HANDLER;

    /**
     * The newline characters.
     */
    protected String newline = "\n";

    /**
     * Whether the output must be formatted.
     */
    protected boolean format = true;

    /**
     * The tabulation width.
     */
    protected int tabulationWidth = 4;

    /**
     * The document width.
     */
    protected int documentWidth = 80;

    /**
     * The doctype option.
     */
    protected int doctypeOption = DOCTYPE_KEEP_UNCHANGED;

    /**
     * The public id.
     */
    protected String publicId;

    /**
     * The system id.
     */
    protected String systemId;

    /**
     * The XML declaration.
     */
    protected String xmlDeclaration;

    /**
     * The type of the current lexical unit.
     */
    protected int type;

    /**
     * Sets the XML declaration text.
     */
    public void setXMLDeclaration(String s) {
        xmlDeclaration = s;
    }

    /**
     * Sets the doctype option.
     */
    public void setDoctypeOption(int i) {
        doctypeOption = i;
    }

    /**
     * Sets the public ID.
     */
    public void setPublicId(String s) {
        publicId = s;
    }

    /**
     * Sets the system ID.
     */
    public void setSystemId(String s) {
        systemId = s;
    }

    /**
     * Sets the newline characters.
     */
    public void setNewline(String s) {
        newline = s;
    }

    /**
     * Returns the newline characters.
     */
    public String getNewline() {
        return newline;
    }

    /**
     * Sets the format attribute.
     */
    public void setFormat(boolean b) {
        format = b;
    }

    /**
     * Returns whether the output must be formatted.
     */
    public boolean getFormat() {
        return format;
    }

    /**
     * Sets the tabulation width.
     */
    public void setTabulationWidth(int i) {
        tabulationWidth = Math.max(i, 0);
    }

    /**
     * Returns whether the tabulation width.
     */
    public int getTabulationWidth() {
        return tabulationWidth;
    }

    /**
     * Sets the document width.
     */
    public void setDocumentWidth(int i) {
        documentWidth = Math.max(i, 0);
    }

    /**
     * Returns whether the document width.
     */
    public int getDocumentWidth() {
        return documentWidth;
    }

    /**
     * Prints an SVG document from the given reader to the given writer.
     */
    public void print(Reader r, Writer w) throws TranscoderException,
                                                 IOException {
        try {
            scanner = new XMLScanner(r);
            output = new OutputManager(this, w);
            writer = w;
            type = scanner.next();

            printXMLDecl();

            misc1: for (;;) {
                switch (type) {
                case LexicalUnits.S:
                    output.printTopSpaces(getCurrentValue());
                    scanner.clearBuffer();
                    type = scanner.next();
                    break;
                case LexicalUnits.COMMENT:
                    output.printComment(getCurrentValue());
                    scanner.clearBuffer();
                    type = scanner.next();
                    break;
                case LexicalUnits.PI_START:
                    printPI();
                    break;
                default:
                    break misc1;
                }
            }

            printDoctype();

            misc2: for (;;) {
                scanner.clearBuffer();
                switch (type) {
                case LexicalUnits.S:
                    output.printTopSpaces(getCurrentValue());
                    scanner.clearBuffer();
                    type = scanner.next();
                    break;
                case LexicalUnits.COMMENT:
                    output.printComment(getCurrentValue());
                    scanner.clearBuffer();
                    type = scanner.next();
                    break;
                case LexicalUnits.PI_START:
                    printPI();
                    break;
                default:
                    break misc2;
                }
            }

            if (type != LexicalUnits.START_TAG) {
                throw fatalError("element", null);
            }

            printElement();

            misc3: for (;;) {
                switch (type) {
                case LexicalUnits.S:
                    output.printTopSpaces(getCurrentValue());
                    scanner.clearBuffer();
                    type = scanner.next();
                    break;
                case LexicalUnits.COMMENT:
                    output.printComment(getCurrentValue());
                    scanner.clearBuffer();
                    type = scanner.next();
                    break;
                case LexicalUnits.PI_START:
                    printPI();
                    break;
                default:
                    break misc3;
                }
            }
        } catch (XMLException e) {
            errorHandler.fatalError(new TranscoderException(e.getMessage()));
        }
    }

    /**
     * Prints the XML declaration.
     */
    protected void printXMLDecl()
        throws TranscoderException,
               XMLException,
               IOException {
        if (xmlDeclaration == null) {
            if (type == LexicalUnits.XML_DECL_START) {
                if (scanner.next() != LexicalUnits.S) {
                    throw fatalError("space", null);
                }
                char[] space1 = getCurrentValue();

                if (scanner.next() != LexicalUnits.VERSION_IDENTIFIER) {
                    throw fatalError("token", new Object[] { "version" });
                }
                type = scanner.next();

                char[] space2 = null;
                if (type == LexicalUnits.S) {
                    space2 = getCurrentValue();
                    type = scanner.next();
                }
                if (type != LexicalUnits.EQ) {
                    throw fatalError("token", new Object[] { "=" });
                }
                type = scanner.next();

                char[] space3 = null;
                if (type == LexicalUnits.S) {
                    space3 = getCurrentValue();
                    type = scanner.next();
                }

                if (type != LexicalUnits.STRING) {
                    throw fatalError("string", null);
                }

                char[] version = getCurrentValue();
                char versionDelim = scanner.getStringDelimiter();

                char[] space4 = null;
                char[] space5 = null;
                char[] space6 = null;
                char[] encoding = null;
                char encodingDelim = 0;
                char[] space7 = null;
                char[] space8 = null;
                char[] space9 = null;
                char[] standalone = null;
                char standaloneDelim = 0;
                char[] space10 = null;

                type = scanner.next();
                if (type == LexicalUnits.S) {
                    space4 = getCurrentValue();
                    type = scanner.next();

                    if (type == LexicalUnits.ENCODING_IDENTIFIER) {
                        type = scanner.next();
                        if (type == LexicalUnits.S) {
                            space5 = getCurrentValue();
                            type = scanner.next();
                        }
                        if (type != LexicalUnits.EQ) {
                            throw fatalError("token", new Object[] { "=" });
                        }
                        type = scanner.next();
                        if (type == LexicalUnits.S) {
                            space6 = getCurrentValue();
                            type = scanner.next();
                        }
                        if (type != LexicalUnits.STRING) {
                            throw fatalError("string", null);
                        }

                        encoding = getCurrentValue();
                        encodingDelim = scanner.getStringDelimiter();

                        type = scanner.next();
                        if (type == LexicalUnits.S) {
                            space7 = getCurrentValue();
                            type = scanner.next();
                        }
                    }

                    if (type == LexicalUnits.STANDALONE_IDENTIFIER) {
                        type = scanner.next();
                        if (type == LexicalUnits.S) {
                            space8 = getCurrentValue();
                            type = scanner.next();
                        }
                        if (type != LexicalUnits.EQ) {
                            throw fatalError("token", new Object[] { "=" });
                        }
                        type = scanner.next();
                        if (type == LexicalUnits.S) {
                            space9 = getCurrentValue();
                            type = scanner.next();
                        }
                        if (type != LexicalUnits.STRING) {
                            throw fatalError("string", null);
                        }

                        standalone = getCurrentValue();
                        standaloneDelim = scanner.getStringDelimiter();

                        type = scanner.next();
                        if (type == LexicalUnits.S) {
                            space10 = getCurrentValue();
                            type = scanner.next();
                        }
                    }
                }
                if (type != LexicalUnits.PI_END) {
                    throw fatalError("pi.end", null);
                }

                output.printXMLDecl(space1, space2, space3,
                                    version, versionDelim,
                                    space4, space5, space6,
                                    encoding, encodingDelim,
                                    space7, space8, space9,
                                    standalone, standaloneDelim,
                                    space10);

                type = scanner.next();
            }
        } else {
            output.printString(xmlDeclaration);
            output.printNewline();

            if (type == LexicalUnits.XML_DECL_START) {
                // Skip the XML declaraction.
                if (scanner.next() != LexicalUnits.S) {
                    throw fatalError("space", null);
                }

                if (scanner.next() != LexicalUnits.VERSION_IDENTIFIER) {
                    throw fatalError("token", new Object[] { "version" });
                }
                type = scanner.next();

                if (type == LexicalUnits.S) {
                    type = scanner.next();
                }
                if (type != LexicalUnits.EQ) {
                    throw fatalError("token", new Object[] { "=" });
                }
                type = scanner.next();

                if (type == LexicalUnits.S) {
                    type = scanner.next();
                }

                if (type != LexicalUnits.STRING) {
                    throw fatalError("string", null);
                }

                type = scanner.next();
                if (type == LexicalUnits.S) {
                    type = scanner.next();

                    if (type == LexicalUnits.ENCODING_IDENTIFIER) {
                        type = scanner.next();
                        if (type == LexicalUnits.S) {
                            type = scanner.next();
                        }
                        if (type != LexicalUnits.EQ) {
                            throw fatalError("token", new Object[] { "=" });
                        }
                        type = scanner.next();
                        if (type == LexicalUnits.S) {
                            type = scanner.next();
                        }
                        if (type != LexicalUnits.STRING) {
                            throw fatalError("string", null);
                        }

                        type = scanner.next();
                        if (type == LexicalUnits.S) {
                            type = scanner.next();
                        }
                    }

                    if (type == LexicalUnits.STANDALONE_IDENTIFIER) {
                        type = scanner.next();
                        if (type == LexicalUnits.S) {
                            type = scanner.next();
                        }
                        if (type != LexicalUnits.EQ) {
                            throw fatalError("token", new Object[] { "=" });
                        }
                        type = scanner.next();
                        if (type == LexicalUnits.S) {
                            type = scanner.next();
                        }
                        if (type != LexicalUnits.STRING) {
                            throw fatalError("string", null);
                        }

                        type = scanner.next();
                        if (type == LexicalUnits.S) {
                            type = scanner.next();
                        }
                    }
                }
                if (type != LexicalUnits.PI_END) {
                    throw fatalError("pi.end", null);
                }

                type = scanner.next();
            }
        }
    }

    /**
     * Prints a processing instruction.
     */
    protected void printPI()
        throws TranscoderException,
               XMLException,
               IOException {
        char[] target = getCurrentValue();

        type = scanner.next();
        char[] space = {};
        if (type == LexicalUnits.S) {
            space = getCurrentValue();
            type = scanner.next();
        }
        if (type != LexicalUnits.PI_DATA) {
            throw fatalError("pi.data", null);
        }
        char[] data = getCurrentValue();

        type = scanner.next();
        if (type != LexicalUnits.PI_END) {
            throw fatalError("pi.end", null);
        }

        output.printPI(target, space, data);

        type = scanner.next();
    }

    /**
     * Prints the doctype.
     */
    protected void printDoctype()
        throws TranscoderException,
               XMLException,
               IOException {
        switch (doctypeOption) {
        default:
            if (type == LexicalUnits.DOCTYPE_START) {
                type = scanner.next();

                if (type != LexicalUnits.S) {
                    throw fatalError("space", null);
                }
                char[] space1 = getCurrentValue();
                type = scanner.next();

                if (type != LexicalUnits.NAME) {
                    throw fatalError("name", null);
                }

                char[] root = getCurrentValue();
                char[] space2 = null;
                String externalId = null;
                char[] space3 = null;
                char[] string1 = null;
                char string1Delim = 0;
                char[] space4 = null;
                char[] string2 = null;
                char string2Delim = 0;
                char[] space5 = null;

                type = scanner.next();
                if (type == LexicalUnits.S) {
                    space2 = getCurrentValue();
                    type = scanner.next();

                    switch (type) {
                    case LexicalUnits.PUBLIC_IDENTIFIER:
                        externalId = "PUBLIC";

                        type = scanner.next();
                        if (type != LexicalUnits.S) {
                            throw fatalError("space", null);
                        }
                        space3 = getCurrentValue();
                        type = scanner.next();

                        if (type != LexicalUnits.STRING) {
                            throw fatalError("string", null);
                        }

                        string1 = getCurrentValue();
                        string1Delim = scanner.getStringDelimiter();

                        type = scanner.next();
                        if (type != LexicalUnits.S) {
                            throw fatalError("space", null);
                        }
                        space4 = getCurrentValue();
                        type = scanner.next();

                        if (type != LexicalUnits.STRING) {
                            throw fatalError("string", null);
                        }

                        string2 = getCurrentValue();
                        string2Delim = scanner.getStringDelimiter();

                        type = scanner.next();
                        if (type == LexicalUnits.S) {
                            space5 = getCurrentValue();
                            type = scanner.next();
                        }
                        break;
                    case LexicalUnits.SYSTEM_IDENTIFIER:
                        externalId = "SYSTEM";

                        type = scanner.next();
                        if (type != LexicalUnits.S) {
                            throw fatalError("space", null);
                        }
                        space3 = getCurrentValue();
                        type = scanner.next();

                        if (type != LexicalUnits.STRING) {
                            throw fatalError("string", null);
                        }

                        string1 = getCurrentValue();
                        string1Delim = scanner.getStringDelimiter();

                        type = scanner.next();
                        if (type == LexicalUnits.S) {
                            space4 = getCurrentValue();
                            type = scanner.next();
                        }
                    }
                }

                if (doctypeOption == DOCTYPE_CHANGE) {
                    if (publicId != null) {
                        externalId = "PUBLIC";
                        string1 = publicId.toCharArray();
                        string1Delim = '"';
                        if (systemId != null) {
                            string2 = systemId.toCharArray();
                            string2Delim = '"';
                        }
                    } else if (systemId != null) {
                        externalId = "SYSTEM";
                        string1 = systemId.toCharArray();
                        string1Delim = '"';
                        string2 = null;
                    }
                }
                output.printDoctypeStart(space1, root, space2,
                                         externalId, space3,
                                         string1, string1Delim,
                                         space4,
                                         string2, string2Delim,
                                         space5);

                if (type == LexicalUnits.LSQUARE_BRACKET) {
                    output.printCharacter('[');
                    type = scanner.next();

                    dtd: for (;;) {
                        switch (type) {
                        case LexicalUnits.S:
                            output.printSpaces(getCurrentValue(), true);
                            scanner.clearBuffer();
                            type = scanner.next();
                            break;
                        case LexicalUnits.COMMENT:
                            output.printComment(getCurrentValue());
                            scanner.clearBuffer();
                            type = scanner.next();
                            break;
                        case LexicalUnits.PI_START:
                            printPI();
                            break;
                        case LexicalUnits.PARAMETER_ENTITY_REFERENCE:
                            output.printParameterEntityReference(getCurrentValue());
                            scanner.clearBuffer();
                            type = scanner.next();
                            break;
                        case LexicalUnits.ELEMENT_DECLARATION_START:
                            scanner.clearBuffer();
                            printElementDeclaration();
                            break;
                        case LexicalUnits.ATTLIST_START:
                            scanner.clearBuffer();
                            printAttlist();
                            break;
                        case LexicalUnits.NOTATION_START:
                            scanner.clearBuffer();
                            printNotation();
                            break;
                        case LexicalUnits.ENTITY_START:
                            scanner.clearBuffer();
                            printEntityDeclaration();
                            break;
                        case LexicalUnits.RSQUARE_BRACKET:
                            output.printCharacter(']');
                            scanner.clearBuffer();
                            type = scanner.next();
                            break dtd;
                        default:
                            throw fatalError("xml", null);
                        }
                    }
                }
                char[] endSpace = null;
                if (type == LexicalUnits.S) {
                    endSpace = getCurrentValue();
                    type = scanner.next();
                }

                if (type != LexicalUnits.END_CHAR) {
                    throw fatalError("end", null);
                }
                type = scanner.next();
                output.printDoctypeEnd(endSpace);
            } else {
                if (doctypeOption == DOCTYPE_CHANGE) {
                    String externalId = "PUBLIC";
                    char[] string1 = SVGConstants.SVG_PUBLIC_ID.toCharArray();
                    char[] string2 = SVGConstants.SVG_SYSTEM_ID.toCharArray();
                    if (publicId != null) {
                        string1 = publicId.toCharArray();
                        if (systemId != null) {
                            string2 = systemId.toCharArray();
                        }
                    } else if (systemId != null) {
                        externalId = "SYSTEM";
                        string1 = systemId.toCharArray();
                        string2 = null;
                    }
                    output.printDoctypeStart(new char[] { ' ' },
                                             new char[] { 's', 'v', 'g' },
                                             new char[] { ' ' },
                                             externalId,
                                             new char[] { ' ' },
                                             string1, '"',
                                             new char[] { ' ' },
                                             string2, '"',
                                             null);
                    output.printDoctypeEnd(null);
                }
            }

            break;

        case DOCTYPE_REMOVE:
            if (type == LexicalUnits.DOCTYPE_START) {
                type = scanner.next();

                if (type != LexicalUnits.S) {
                    throw fatalError("space", null);
                }
                type = scanner.next();

                if (type != LexicalUnits.NAME) {
                    throw fatalError("name", null);
                }

                type = scanner.next();
                if (type == LexicalUnits.S) {
                    type = scanner.next();

                    switch (type) {
                    case LexicalUnits.PUBLIC_IDENTIFIER:

                        type = scanner.next();
                        if (type != LexicalUnits.S) {
                            throw fatalError("space", null);
                        }
                        type = scanner.next();

                        if (type != LexicalUnits.STRING) {
                            throw fatalError("string", null);
                        }

                        type = scanner.next();
                        if (type != LexicalUnits.S) {
                            throw fatalError("space", null);
                        }
                        type = scanner.next();

                        if (type != LexicalUnits.STRING) {
                            throw fatalError("string", null);
                        }

                        type = scanner.next();
                        if (type == LexicalUnits.S) {
                            type = scanner.next();
                        }
                        break;
                    case LexicalUnits.SYSTEM_IDENTIFIER:

                        type = scanner.next();
                        if (type != LexicalUnits.S) {
                            throw fatalError("space", null);
                        }
                        type = scanner.next();

                        if (type != LexicalUnits.STRING) {
                            throw fatalError("string", null);
                        }

                        type = scanner.next();
                        if (type == LexicalUnits.S) {
                            type = scanner.next();
                        }
                    }
                }

                if (type == LexicalUnits.LSQUARE_BRACKET) {
                    do {
                        type = scanner.next();
                    } while (type != LexicalUnits.RSQUARE_BRACKET);
                }
                if (type == LexicalUnits.S) {
                    type = scanner.next();
                }

                if (type != LexicalUnits.END_CHAR) {
                    throw fatalError("end", null);
                }
            }
            type = scanner.next();
        }
    }

    /**
     * Prints an element.
     */
    protected String printElement()
        throws TranscoderException,
               XMLException,
               IOException {
        char[] name = getCurrentValue();
        String nameStr = new String(name);
        List attributes = new LinkedList();
        char[] space = null;

        type = scanner.next();
        while (type == LexicalUnits.S) {
            space = getCurrentValue();

            type = scanner.next();
            if (type == LexicalUnits.NAME) {
                char[] attName = getCurrentValue();
                char[] space1 = null;

                type = scanner.next();
                if (type == LexicalUnits.S) {
                    space1 = getCurrentValue();
                    type = scanner.next();
                }
                if (type != LexicalUnits.EQ) {
                    throw fatalError("token", new Object[] { "=" });
                }
                type = scanner.next();

                char[] space2 = null;
                if (type == LexicalUnits.S) {
                    space2 = getCurrentValue();
                    type = scanner.next();
                }
                if (type != LexicalUnits.STRING &&
                    type != LexicalUnits.FIRST_ATTRIBUTE_FRAGMENT) {
                    throw fatalError("string", null);
                }

                char valueDelim = scanner.getStringDelimiter();
                boolean hasEntityRef = false;

                StringBuffer sb = new StringBuffer();
                sb.append(getCurrentValue());
                loop: for (;;) {
                    scanner.clearBuffer();
                    type = scanner.next();
                    switch (type) {
                    case LexicalUnits.STRING:
                    case LexicalUnits.FIRST_ATTRIBUTE_FRAGMENT:
                    case LexicalUnits.LAST_ATTRIBUTE_FRAGMENT:
                    case LexicalUnits.ATTRIBUTE_FRAGMENT:
                        sb.append(getCurrentValue());
                        break;
                    case LexicalUnits.CHARACTER_REFERENCE:
                        hasEntityRef = true;
                        sb.append("&#");
                        sb.append(getCurrentValue());
                        sb.append(";");
                        break;
                    case LexicalUnits.ENTITY_REFERENCE:
                        hasEntityRef = true;
                        sb.append("&");
                        sb.append(getCurrentValue());
                        sb.append(";");
                        break;
                    default:
                        break loop;
                    }
                }

                attributes.add(new OutputManager.AttributeInfo(space,
                                                               attName,
                                                               space1, space2,
                                                               new String(sb),
                                                               valueDelim,
                                                               hasEntityRef));
                space = null;
            }
        }
        output.printElementStart(name, attributes, space);

        switch (type) {
        default:
            throw fatalError("xml", null);
        case LexicalUnits.EMPTY_ELEMENT_END:
            output.printElementEnd(null, null);
            break;
        case LexicalUnits.END_CHAR:
            output.printCharacter('>');
            type = scanner.next();
            printContent(allowSpaceAtStart(nameStr));
            if (type != LexicalUnits.END_TAG) {
                throw fatalError("end.tag", null);
            }
            name = getCurrentValue();

            type = scanner.next();
            space = null;
            if (type == LexicalUnits.S) {
                space = getCurrentValue();
                type = scanner.next();
            }

            output.printElementEnd(name, space);

            if (type != LexicalUnits.END_CHAR) {
                throw fatalError("end", null);
            }
        }

        type = scanner.next();
        return nameStr;
    }

    boolean allowSpaceAtStart(String tagName) {
        return true;
        /**
         * This would be a real hack for SVG.  This should be
         * driven by a configuration paramater as well as
         * needing to be really namespace aware...
         */
        // return !(tagName.equals("tspan")||
        //         tagName.endsWith(":tspan"));
    }

    /**
     * Prints the content of an element.
     */
    protected void printContent(boolean spaceAtStart)
        throws TranscoderException,
               XMLException,
               IOException {
        boolean preceedingSpace = false;
        content: for (;;) {
            switch (type) {
            case LexicalUnits.COMMENT:
                output.printComment(getCurrentValue());
                scanner.clearBuffer();
                type = scanner.next();
                preceedingSpace = false;
                break;
            case LexicalUnits.PI_START:
                printPI();
                preceedingSpace = false;
                break;
            case LexicalUnits.CHARACTER_DATA:
                preceedingSpace = output.printCharacterData
                    (getCurrentValue(), spaceAtStart, preceedingSpace);
                scanner.clearBuffer();
                type = scanner.next();
                spaceAtStart = false;
                break;
            case LexicalUnits.CDATA_START:
                type = scanner.next();
                if (type != LexicalUnits.CHARACTER_DATA) {
                    throw fatalError("character.data", null);
                }
                output.printCDATASection(getCurrentValue());
                if (scanner.next() != LexicalUnits.SECTION_END) {
                    throw fatalError("section.end", null);
                }
                scanner.clearBuffer();
                type = scanner.next();
                preceedingSpace = false;
                spaceAtStart = false;
                break;
            case LexicalUnits.START_TAG:
                String name = printElement();
                spaceAtStart = allowSpaceAtStart(name);
                break;
            case LexicalUnits.CHARACTER_REFERENCE:
                output.printCharacterEntityReference(getCurrentValue(),
                                                     spaceAtStart,
                                                     preceedingSpace);
                scanner.clearBuffer();
                type = scanner.next();
                spaceAtStart = false;
                preceedingSpace = false;
                break;
            case LexicalUnits.ENTITY_REFERENCE:
                output.printEntityReference(getCurrentValue(), spaceAtStart);
                scanner.clearBuffer();
                type = scanner.next();
                spaceAtStart = false;
                preceedingSpace = false;
                break;
            default:
                break content;
            }
        }
    }

    /**
     * Prints a notation declaration.
     */
    protected void printNotation()
        throws TranscoderException,
               XMLException,
               IOException {
        int t = scanner.next();
        if (t != LexicalUnits.S) {
            throw fatalError("space", null);
        }
        char[] space1 = getCurrentValue();
        t = scanner.next();

        if (t != LexicalUnits.NAME) {
            throw fatalError("name", null);
        }
        char[] name = getCurrentValue();
        t = scanner.next();

        if (t != LexicalUnits.S) {
            throw fatalError("space", null);
        }
        char[] space2 = getCurrentValue();
        t = scanner.next();

        String externalId = null;
        char[] space3 = null;
        char[] string1 = null;
        char string1Delim = 0;
        char[] space4 = null;
        char[] string2 = null;
        char string2Delim = 0;

        switch (t) {
        default:
            throw fatalError("notation.definition", null);
        case LexicalUnits.PUBLIC_IDENTIFIER:
            externalId = "PUBLIC";

            t = scanner.next();
            if (t != LexicalUnits.S) {
                throw fatalError("space", null);
            }
            space3 = getCurrentValue();
            t = scanner.next();

            if (t != LexicalUnits.STRING) {
                throw fatalError("string", null);
            }
            string1 = getCurrentValue();
            string1Delim = scanner.getStringDelimiter();
            t = scanner.next();

            if (t == LexicalUnits.S) {
                space4 = getCurrentValue();
                t = scanner.next();

                if (t == LexicalUnits.STRING) {
                    string2 = getCurrentValue();
                    string2Delim = scanner.getStringDelimiter();
                    t = scanner.next();
                }
            }

            break;
        case LexicalUnits.SYSTEM_IDENTIFIER:
            externalId = "SYSTEM";

            t = scanner.next();
            if (t != LexicalUnits.S) {
                throw fatalError("space", null);
            }
            space3 = getCurrentValue();
            t = scanner.next();

            if (t != LexicalUnits.STRING) {
                throw fatalError("string", null);
            }
            string1 = getCurrentValue();
            string1Delim = scanner.getStringDelimiter();
            t = scanner.next();
        }

        char[] space5 = null;
        if (t == LexicalUnits.S) {
            space5 = getCurrentValue();
            t = scanner.next();
        }
        if (t != LexicalUnits.END_CHAR) {
            throw fatalError("end", null);
        }
        output.printNotation(space1, name, space2, externalId, space3,
                             string1, string1Delim, space4,
                             string2, string2Delim, space5);

        scanner.next();
    }

    /**
     * Prints an ATTLIST declaration.
     */
    protected void printAttlist()
        throws TranscoderException,
               XMLException,
               IOException {
        type = scanner.next();
        if (type != LexicalUnits.S) {
            throw fatalError("space", null);
        }
        char[] space = getCurrentValue();
        type = scanner.next();

        if (type != LexicalUnits.NAME) {
            throw fatalError("name", null);
        }
        char[] name = getCurrentValue();
        type = scanner.next();

        output.printAttlistStart(space, name);

        while (type == LexicalUnits.S) {
            space = getCurrentValue();
            type = scanner.next();

            if (type != LexicalUnits.NAME) {
                break;
            }
            name = getCurrentValue();
            type = scanner.next();

            if (type != LexicalUnits.S) {
                throw fatalError("space", null);
            }
            char[] space2 = getCurrentValue();
            type = scanner.next();

            output.printAttName(space, name, space2);

            switch (type) {
            case LexicalUnits.CDATA_IDENTIFIER:
            case LexicalUnits.ID_IDENTIFIER:
            case LexicalUnits.IDREF_IDENTIFIER:
            case LexicalUnits.IDREFS_IDENTIFIER:
            case LexicalUnits.ENTITY_IDENTIFIER:
            case LexicalUnits.ENTITIES_IDENTIFIER:
            case LexicalUnits.NMTOKEN_IDENTIFIER:
            case LexicalUnits.NMTOKENS_IDENTIFIER:
                output.printCharacters(getCurrentValue());
                type = scanner.next();
                break;
            case LexicalUnits.NOTATION_IDENTIFIER:
                output.printCharacters(getCurrentValue());
                type = scanner.next();

                if (type != LexicalUnits.S) {
                    throw fatalError("space", null);
                }
                output.printSpaces(getCurrentValue(), false);
                type = scanner.next();

                if (type != LexicalUnits.LEFT_BRACE) {
                    throw fatalError("left.brace", null);
                }
                type = scanner.next();

                List names = new LinkedList();
                space = null;

                if (type == LexicalUnits.S) {
                    space = getCurrentValue();
                    type = scanner.next();
                }

                if (type != LexicalUnits.NAME) {
                    throw fatalError("name", null);
                }
                name = getCurrentValue();
                type = scanner.next();

                space2 = null;
                if (type == LexicalUnits.S) {
                    space2 = getCurrentValue();
                    type = scanner.next();
                }

                names.add(new OutputManager.NameInfo(space, name, space2));

                loop: for (;;) {
                    switch (type) {
                    default:
                        break loop;
                    case LexicalUnits.PIPE:
                        type = scanner.next();

                        space = null;
                        if (type == LexicalUnits.S) {
                            space = getCurrentValue();
                            type = scanner.next();
                        }

                        if (type != LexicalUnits.NAME) {
                            throw fatalError("name", null);
                        }
                        name = getCurrentValue();
                        type = scanner.next();

                        space2 = null;
                        if (type == LexicalUnits.S) {
                            space2 = getCurrentValue();
                            type = scanner.next();
                        }

                        names.add(new OutputManager.NameInfo(space, name, space2));
                    }
                }
                if (type != LexicalUnits.RIGHT_BRACE) {
                    throw fatalError("right.brace", null);
                }

                output.printEnumeration(names);
                type = scanner.next();
                break;
            case LexicalUnits.LEFT_BRACE:
                type = scanner.next();

                names = new LinkedList();
                space = null;

                if (type == LexicalUnits.S) {
                    space = getCurrentValue();
                    type = scanner.next();
                }

                if (type != LexicalUnits.NMTOKEN) {
                    throw fatalError("nmtoken", null);
                }
                name = getCurrentValue();
                type = scanner.next();

                space2 = null;
                if (type == LexicalUnits.S) {
                    space2 = getCurrentValue();
                    type = scanner.next();
                }

                names.add(new OutputManager.NameInfo(space, name, space2));

                loop: for (;;) {
                    switch (type) {
                    default:
                        break loop;
                    case LexicalUnits.PIPE:
                        type = scanner.next();

                        space = null;
                        if (type == LexicalUnits.S) {
                            space = getCurrentValue();
                            type = scanner.next();
                        }

                        if (type != LexicalUnits.NMTOKEN) {
                            throw fatalError("nmtoken", null);
                        }
                        name = getCurrentValue();
                        type = scanner.next();

                        space2 = null;
                        if (type == LexicalUnits.S) {
                            space2 = getCurrentValue();
                            type = scanner.next();
                        }

                        names.add(new OutputManager.NameInfo(space, name, space2));
                    }
                }
                if (type != LexicalUnits.RIGHT_BRACE) {
                    throw fatalError("right.brace", null);
                }

                output.printEnumeration(names);
                type = scanner.next();

            }

            if (type == LexicalUnits.S) {
                output.printSpaces(getCurrentValue(), true);
                type = scanner.next();
            }

            switch (type) {
            default:
                throw fatalError("default.decl", null);
            case LexicalUnits.REQUIRED_IDENTIFIER:
            case LexicalUnits.IMPLIED_IDENTIFIER:
                output.printCharacters(getCurrentValue());
                type = scanner.next();
                break;
            case LexicalUnits.FIXED_IDENTIFIER:
                output.printCharacters(getCurrentValue());
                type = scanner.next();

                if (type != LexicalUnits.S) {
                    throw fatalError("space", null);
                }
                output.printSpaces(getCurrentValue(), false);
                type = scanner.next();

                if (type != LexicalUnits.STRING &&
                    type != LexicalUnits.FIRST_ATTRIBUTE_FRAGMENT) {
                    throw fatalError("space", null);
                }
            case LexicalUnits.STRING:
            case LexicalUnits.FIRST_ATTRIBUTE_FRAGMENT:
                output.printCharacter(scanner.getStringDelimiter());
                output.printCharacters(getCurrentValue());
                loop: for (;;) {
                    type = scanner.next();
                    switch (type) {
                    case LexicalUnits.STRING:
                    case LexicalUnits.ATTRIBUTE_FRAGMENT:
                    case LexicalUnits.FIRST_ATTRIBUTE_FRAGMENT:
                    case LexicalUnits.LAST_ATTRIBUTE_FRAGMENT:
                        output.printCharacters(getCurrentValue());
                        break;
                    case LexicalUnits.CHARACTER_REFERENCE:
                        output.printString("&#");
                        output.printCharacters(getCurrentValue());
                        output.printCharacter(';');
                        break;
                    case LexicalUnits.ENTITY_REFERENCE:
                        output.printCharacter('&');
                        output.printCharacters(getCurrentValue());
                        output.printCharacter(';');
                        break;
                    default:
                        break loop;
                    }
                }
                output.printCharacter(scanner.getStringDelimiter());
            }
            space = null;
        }

        if (type != LexicalUnits.END_CHAR) {
            throw fatalError("end", null);
        }
        output.printAttlistEnd(space);
        type = scanner.next();
    }

    /**
     * Prints an entity declaration.
     */
    protected void printEntityDeclaration()
        throws TranscoderException,
               XMLException,
               IOException {
        writer.write("<!ENTITY");

        type = scanner.next();
        if (type != LexicalUnits.S) {
            throw fatalError("space", null);
        }
        writer.write(getCurrentValue());
        type = scanner.next();

        boolean pe = false;

        switch (type) {
        default:
            throw fatalError("xml", null);
        case LexicalUnits.NAME:
            writer.write(getCurrentValue());
            type = scanner.next();
            break;
        case LexicalUnits.PERCENT:
            pe = true;
            writer.write('%');
            type = scanner.next();

            if (type != LexicalUnits.S) {
                throw fatalError("space", null);
            }
            writer.write(getCurrentValue());
            type = scanner.next();

            if (type != LexicalUnits.NAME) {
                throw fatalError("name", null);
            }
            writer.write(getCurrentValue());
            type = scanner.next();
        }

        if (type != LexicalUnits.S) {
            throw fatalError("space", null);
        }
        writer.write(getCurrentValue());
        type = scanner.next();

        switch (type) {
        case LexicalUnits.STRING:
        case LexicalUnits.FIRST_ATTRIBUTE_FRAGMENT:
            char sd = scanner.getStringDelimiter();
            writer.write(sd);
            loop: for (;;) {
                switch (type) {
                case LexicalUnits.STRING:
                case LexicalUnits.ATTRIBUTE_FRAGMENT:
                case LexicalUnits.FIRST_ATTRIBUTE_FRAGMENT:
                case LexicalUnits.LAST_ATTRIBUTE_FRAGMENT:
                    writer.write(getCurrentValue());
                    break;
                case LexicalUnits.ENTITY_REFERENCE:
                    writer.write('&');
                    writer.write(getCurrentValue());
                    writer.write(';');
                    break;
                case LexicalUnits.PARAMETER_ENTITY_REFERENCE:
                    writer.write('&');
                    writer.write(getCurrentValue());
                    writer.write(';');
                    break;
                default:
                    break loop;
                }
                type = scanner.next();
            }
            writer.write(sd);

            if (type == LexicalUnits.S) {
                writer.write(getCurrentValue());
                type = scanner.next();
            }

            if (type != LexicalUnits.END_CHAR) {
                throw fatalError("end", null);
            }
            writer.write(">");
            type = scanner.next();
            return;
        case LexicalUnits.PUBLIC_IDENTIFIER:
            writer.write("PUBLIC");
            type = scanner.next();
            if (type != LexicalUnits.S) {
                throw fatalError("space", null);
            }
            type = scanner.next();
            if (type != LexicalUnits.STRING) {
                throw fatalError("string", null);
            }

            writer.write(" \"");
            writer.write(getCurrentValue());
            writer.write("\" \"");

            type = scanner.next();
            if (type != LexicalUnits.S) {
                throw fatalError("space", null);
            }
            type = scanner.next();
            if (type != LexicalUnits.STRING) {
                throw fatalError("string", null);
            }

            writer.write(getCurrentValue());
            writer.write('"');
            break;

        case LexicalUnits.SYSTEM_IDENTIFIER:
            writer.write("SYSTEM");
            type = scanner.next();
            if (type != LexicalUnits.S) {
                throw fatalError("space", null);
            }
            type = scanner.next();
            if (type != LexicalUnits.STRING) {
                throw fatalError("string", null);
            }
            writer.write(" \"");
            writer.write(getCurrentValue());
            writer.write('"');
        }

        type = scanner.next();
        if (type == LexicalUnits.S) {
            writer.write(getCurrentValue());
            type = scanner.next();
            if (!pe && type == LexicalUnits.NDATA_IDENTIFIER) {
                writer.write("NDATA");
                type = scanner.next();
                if (type != LexicalUnits.S) {
                    throw fatalError("space", null);
                }
                writer.write(getCurrentValue());
                type = scanner.next();
                if (type != LexicalUnits.NAME) {
                    throw fatalError("name", null);
                }
                writer.write(getCurrentValue());
                type = scanner.next();
            }
            if (type == LexicalUnits.S) {
                writer.write(getCurrentValue());
                type = scanner.next();
            }
        }

        if (type != LexicalUnits.END_CHAR) {
            throw fatalError("end", null);
        }
        writer.write('>');
        type = scanner.next();
    }

    /**
     * Prints an element declaration.
     */
    protected void printElementDeclaration()
        throws TranscoderException,
               XMLException,
               IOException {
        writer.write("<!ELEMENT");

        type = scanner.next();
        if (type != LexicalUnits.S) {
            throw fatalError("space", null);
        }
        writer.write(getCurrentValue());
        type = scanner.next();
        switch (type) {
        default:
            throw fatalError("name", null);
        case LexicalUnits.NAME:
            writer.write(getCurrentValue());
        }

        type = scanner.next();
        if (type != LexicalUnits.S) {
            throw fatalError("space", null);
        }
        writer.write(getCurrentValue());

        switch (type = scanner.next()) {
        case LexicalUnits.EMPTY_IDENTIFIER:
            writer.write("EMPTY");
            type = scanner.next();
            break;
        case LexicalUnits.ANY_IDENTIFIER:
            writer.write("ANY");
            type = scanner.next();
            break;
        case LexicalUnits.LEFT_BRACE:
            writer.write('(');
            type = scanner.next();
            if (type == LexicalUnits.S) {
                writer.write(getCurrentValue());
                type = scanner.next();
            }
            mixed: switch (type) {
            case LexicalUnits.PCDATA_IDENTIFIER:
                writer.write("#PCDATA");
                type = scanner.next();

                for (;;) {
                    switch (type) {
                    case LexicalUnits.S:
                        writer.write(getCurrentValue());
                        type = scanner.next();
                        break;
                    case LexicalUnits.PIPE:
                        writer.write('|');
                        type = scanner.next();
                        if (type == LexicalUnits.S) {
                            writer.write(getCurrentValue());
                            type = scanner.next();
                        }
                        if (type != LexicalUnits.NAME) {
                            throw fatalError("name", null);
                        }
                        writer.write(getCurrentValue());
                        type = scanner.next();
                        break;
                    case LexicalUnits.RIGHT_BRACE:
                        writer.write(')');
                        type = scanner.next();
                        break mixed;
                    }
                }

            case LexicalUnits.NAME:
            case LexicalUnits.LEFT_BRACE:
                printChildren();
                if (type != LexicalUnits.RIGHT_BRACE) {
                    throw fatalError("right.brace", null);
                }
                writer.write(')');
                type = scanner.next();
                if (type == LexicalUnits.S) {
                    writer.write(getCurrentValue());
                    type = scanner.next();
                }
                switch (type) {
                case LexicalUnits.QUESTION:
                    writer.write('?');
                    type = scanner.next();
                    break;
                case LexicalUnits.STAR:
                    writer.write('*');
                    type = scanner.next();
                    break;
                case LexicalUnits.PLUS:
                    writer.write('+');
                    type = scanner.next();
                }
            }
        }

        if (type == LexicalUnits.S) {
            writer.write(getCurrentValue());
            type = scanner.next();
        }

        if (type != LexicalUnits.END_CHAR) {
            throw fatalError("end", null);
        }
        writer.write('>');
        scanner.next();
    }

    /**
     * Prints the children of an element declaration.
     */
    protected void printChildren()
        throws TranscoderException,
               XMLException,
               IOException {
        int op = 0;
        loop: for (;;) {
            switch (type) {
            default:
                throw new RuntimeException("Invalid XML");
            case LexicalUnits.NAME:
                writer.write(getCurrentValue());
                type = scanner.next();
                break;
            case LexicalUnits.LEFT_BRACE:
                writer.write('(');
                type = scanner.next();
                if (type == LexicalUnits.S) {
                    writer.write(getCurrentValue());
                    type = scanner.next();
                }
                printChildren();
                if (type != LexicalUnits.RIGHT_BRACE) {
                    throw fatalError("right.brace", null);
                }
                writer.write(')');
                type = scanner.next();
            }

            if (type == LexicalUnits.S) {
                writer.write(getCurrentValue());
                type = scanner.next();
            }

            switch (type) {
            case LexicalUnits.RIGHT_BRACE:
                break loop;
            case LexicalUnits.STAR:
                writer.write('*');
                type = scanner.next();
                break;
            case LexicalUnits.QUESTION:
                writer.write('?');
                type = scanner.next();
                break;
            case LexicalUnits.PLUS:
                writer.write('+');
                type = scanner.next();
                break;
            }

            if (type == LexicalUnits.S) {
                writer.write(getCurrentValue());
                type = scanner.next();
            }

            switch (type) {
            case LexicalUnits.PIPE:
                if (op != 0 && op != type) {
                    throw new RuntimeException("Invalid XML");
                }
                writer.write('|');
                op = type;
                type = scanner.next();
                break;
            case LexicalUnits.COMMA:
                if (op != 0 && op != type) {
                    throw new RuntimeException("Invalid XML");
                }
                writer.write(',');
                op = type;
                type = scanner.next();
            }

            if (type == LexicalUnits.S) {
                writer.write(getCurrentValue());
                type = scanner.next();
            }
        }
    }

    /**
     * Returns the current lexical unit value.
     */
    protected char[] getCurrentValue() {
        int off = scanner.getStart() + scanner.getStartOffset();
        int len = scanner.getEnd() + scanner.getEndOffset() - off;
        char[] result = new char[len];
        char[] buffer = scanner.getBuffer();
        System.arraycopy( buffer, off, result, 0, len );
        return result;
    }

    /**
     * Creates a transcoder exception.
     */
    protected TranscoderException fatalError(String key, Object[] params)
        throws TranscoderException {
        TranscoderException result = new TranscoderException(key);
        errorHandler.fatalError(result);
        return result;
    }
}
