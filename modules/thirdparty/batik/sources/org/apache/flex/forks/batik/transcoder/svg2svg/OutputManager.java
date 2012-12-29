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
import java.io.Writer;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import org.apache.flex.forks.batik.xml.XMLUtilities;

/**
 * This class is responsible of the output of XML constructs.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: OutputManager.java 475477 2006-11-15 22:44:28Z cam $
 */
public class OutputManager {

    /**
     * The pretty printer.
     */
    protected PrettyPrinter prettyPrinter;

    /**
     * The writer used to output the tokens.
     */
    protected Writer writer;

    /**
     * The indentation level.
     */
    protected int level;

    /**
     * The margin.
     */
    protected StringBuffer margin = new StringBuffer();

    /**
     * The current line.
     */
    protected int line = 1;

    /**
     * The current column.
     */
    protected int column;

    /**
     * The xml:space values.
     */
    protected List xmlSpace = new LinkedList();
    {
        xmlSpace.add(Boolean.FALSE);
    }

    /**
     * Whether the next markup can be indented.
     */
    protected boolean canIndent = true;

    /**
     * The elements starting lines.
     */
    protected List startingLines = new LinkedList();

    /**
     * Whether the attribute layout must be done on a single line.
     */
    protected boolean lineAttributes = false;

    /**
     * Creates a new output manager.
     * @param pp The PrettyPrinter used for formatting the output.
     * @param w The Writer to write the output to.
     */
    public OutputManager(PrettyPrinter pp, Writer w) {
        prettyPrinter = pp;
        writer = w;
    }

    /**
     * Prints a single character.
     */
    public void printCharacter(char c) throws IOException {
        if (c == 10) {
            printNewline();
        } else {
            column++;
            writer.write(c);
        }
    }

    /**
     * Prints a newline.
     */
    public void printNewline() throws IOException {
        String nl = prettyPrinter.getNewline();
        for (int i = 0; i < nl.length(); i++) {
            writer.write(nl.charAt(i));
        }
        column = 0;
        line++;
     }

    /**
     * Prints a string.
     */
    public void printString(String s) throws IOException {
        for (int i = 0; i < s.length(); i++) {
            printCharacter(s.charAt(i));
        }
    }

    /**
     * Prints a char array.
     */
    public void printCharacters(char[] ca) throws IOException {
        for (int i = 0; i < ca.length; i++) {
            printCharacter(ca[i]);
        }
    }

    /**
     * Prints white spaces.
     * @param text The space text.
     * @param opt whether the space is optional.
     */
    public void printSpaces(char[] text, boolean opt) throws IOException {
        if (prettyPrinter.getFormat()) {
            if (!opt) {
                printCharacter(' ');
            }
        } else {
            printCharacters(text);
        }
    }

    /**
     * Prints top level white spaces.
     * @param text The space text.
     */
    public void printTopSpaces(char[] text) throws IOException {
        if (prettyPrinter.getFormat()) {
            int nl = newlines(text);
            for (int i = 0; i < nl; i++) {
                printNewline();
            }
        } else {
            printCharacters(text);
        }
    }

    /**
     * Prints a comment.
     * @param text The comment text.
     */
    public void printComment(char[] text) throws IOException {
        if (prettyPrinter.getFormat()) {
            if (canIndent) {
                printNewline();
                printString(margin.toString());
            }
            printString("<!--");
            if (column + text.length + 3 < prettyPrinter.getDocumentWidth()) {
                printCharacters(text);
            } else {
                formatText(text, margin.toString(), false);
                printCharacter(' ');
            }
            if (column + 3 > prettyPrinter.getDocumentWidth()) {
                printNewline();
                printString(margin.toString());
            }
            printString("-->");
        } else {
            printString("<!--");
            printCharacters(text);
            printString("-->");
        }
    }

    /**
     * Prints an XML declaration.
     */
    public void printXMLDecl(char[] space1,
                             char[] space2,
                             char[] space3,
                             char[] version, char versionDelim,
                             char[] space4,
                             char[] space5,
                             char[] space6,
                             char[] encoding, char encodingDelim,
                             char[] space7,
                             char[] space8,
                             char[] space9,
                             char[] standalone, char standaloneDelim,
                             char[] space10)
        throws IOException {
        printString("<?xml");

        printSpaces(space1, false);

        printString("version");

        if (space2 != null) {
            printSpaces(space2, true);
        }

        printCharacter('=');

        if (space3 != null) {
            printSpaces(space3, true);
        }

        printCharacter(versionDelim);
        printCharacters(version);
        printCharacter(versionDelim);

        if (space4 != null) {
            printSpaces(space4, false);

            if (encoding != null) {
                printString("encoding");
            
                if (space5 != null) {
                    printSpaces(space5, true);
                }

                printCharacter('=');

                if (space6 != null) {
                    printSpaces(space6, true);
                }

                printCharacter(encodingDelim);
                printCharacters(encoding);
                printCharacter(encodingDelim);

                if (space7 != null) {
                    printSpaces(space7, standalone == null);
                }
            }

            if (standalone != null) {
                printString("standalone");
            
                if (space8 != null) {
                    printSpaces(space8, true);
                }

                printCharacter('=');

                if (space9 != null) {
                    printSpaces(space9, true);
                }

                printCharacter(standaloneDelim);
                printCharacters(standalone);
                printCharacter(standaloneDelim);

                if (space10 != null) {
                    printSpaces(space10, true);
                }
            }
        }

        printString("?>");
    }

    /**
     * Prints a processing instruction.
     */
    public void printPI(char[] target, char[] space, char[] data) throws IOException {
        if (prettyPrinter.getFormat()) {
            if (canIndent) {
                printNewline();
                printString(margin.toString());
            }
        }
        printString("<?");
        printCharacters(target);
        printSpaces(space, false);
        printCharacters(data);
        printString("?>");
    }

    /**
     * Prints the portion of the doctype before '['.
     */
    public void printDoctypeStart(char[] space1,
                                  char[] root,
                                  char[] space2,
                                  String externalId,
                                  char[] space3,
                                  char[] string1, char string1Delim,
                                  char[] space4,
                                  char[] string2, char string2Delim,
                                  char[] space5) throws IOException {
        if (prettyPrinter.getFormat()) {
            printString("<!DOCTYPE");

            printCharacter(' ');
            printCharacters(root);
        
            if (space2 != null) {
                printCharacter(' ');
                printString(externalId);
                printCharacter(' ');
            
                printCharacter(string1Delim);
                printCharacters(string1);
                printCharacter(string1Delim);

                if (space4 != null) {
                    if (string2 != null) {
                        if (column + string2.length + 3 >
                            prettyPrinter.getDocumentWidth()) {
                            printNewline();
                            for (int i = 0;
                                 i < prettyPrinter.getTabulationWidth();
                                 i++) {
                                printCharacter(' ');
                            }
                        } else {
                            printCharacter(' ');
                        }
                        printCharacter(string2Delim);
                        printCharacters(string2);
                        printCharacter(string2Delim);
                        printCharacter(' ');
                    }
                }
            }
        } else {
            printString("<!DOCTYPE");

            printSpaces(space1, false);
            printCharacters(root);
        
            if (space2 != null) {
                printSpaces(space2, false);
                printString(externalId);
                printSpaces(space3, false);
            
                printCharacter(string1Delim);
                printCharacters(string1);
                printCharacter(string1Delim);

                if (space4 != null) {
                    printSpaces(space4, string2 == null);

                    if (string2 != null) {
                        printCharacter(string2Delim);
                        printCharacters(string2);
                        printCharacter(string2Delim);
                        
                        if (space5 != null) {
                            printSpaces(space5, true);
                        }
                    }
                }
            }
        }
    }

    /**
     * Prints the portion of the doctype after ']'.
     */
    public void printDoctypeEnd(char[] space) throws IOException {
        if (space != null) {
            printSpaces(space, true);
        }
        printCharacter('>');
    }

    /**
     * Prints a parameter entity reference.
     */
    public void printParameterEntityReference(char[] name) throws IOException {
        printCharacter('%');
        printCharacters(name);
        printCharacter(';');
    }

    /**
     * Prints an entity reference.
     */
    public void printEntityReference(char[] name, 
                                     boolean first) throws IOException {
        if ((prettyPrinter.getFormat()) &&
            (xmlSpace.get(0) != Boolean.TRUE) &&
            first) {
            printNewline();
            printString(margin.toString());
        }
        printCharacter('&');
        printCharacters(name);
        printCharacter(';');
    }

    /**
     * Prints a character entity reference.
     */
    public void printCharacterEntityReference
        (char[] code, boolean first, boolean preceedingSpace) 
        throws IOException {
        if ((prettyPrinter.getFormat()) &&
            (xmlSpace.get(0) != Boolean.TRUE)) {

            if (first) {
                printNewline();
                printString(margin.toString());
            } else if (preceedingSpace) {
                int endCol = column + code.length + 3;
                if (endCol > prettyPrinter.getDocumentWidth()){
                    printNewline();
                    printString(margin.toString());
                } else {
                    printCharacter(' ');
                }
            }
        }
        printString("&#");
        printCharacters(code);
        printCharacter(';');
    }

    /**
     * Prints the start of an element.
     */
    public void printElementStart(char[] name, List attributes, char[] space)
        throws IOException {
        xmlSpace.add(0, xmlSpace.get(0));

        startingLines.add(0, new Integer(line));

        if (prettyPrinter.getFormat()) {
            if (canIndent) {
                printNewline();
                printString(margin.toString());
            }
        }
        printCharacter('<');
        printCharacters(name);

        if (prettyPrinter.getFormat()) {
            Iterator it = attributes.iterator();
            if (it.hasNext()) {
                AttributeInfo ai = (AttributeInfo)it.next();

                if (ai.isAttribute("xml:space")) {
                    xmlSpace.set(0, (ai.value.equals("preserve")
                                     ? Boolean.TRUE
                                     : Boolean.FALSE));
                }
                
                printCharacter(' ');
                printCharacters(ai.name);
                printCharacter('=');
                printCharacter(ai.delimiter);
                printString(ai.value);
                printCharacter(ai.delimiter);
            }
            while (it.hasNext()) {
                AttributeInfo ai = (AttributeInfo)it.next();

                if (ai.isAttribute("xml:space")) {
                    xmlSpace.set(0, (ai.value.equals("preserve")
                                     ? Boolean.TRUE
                                     : Boolean.FALSE));
                }
                
                int len = ai.name.length + ai.value.length() + 4;
                if (lineAttributes ||
                    len + column > prettyPrinter.getDocumentWidth()) {
                    printNewline();
                    printString(margin.toString());
                    for (int i = 0; i < name.length + 2; i++) {
                        printCharacter(' ');
                    }
                } else {
                    printCharacter(' ');
                }
                printCharacters(ai.name);
                printCharacter('=');
                printCharacter(ai.delimiter);
                printString(ai.value);
                printCharacter(ai.delimiter);
            }
        } else {
            Iterator it = attributes.iterator();
            while (it.hasNext()) {
                AttributeInfo ai = (AttributeInfo)it.next();

                if (ai.isAttribute("xml:space")) {
                    xmlSpace.set(0, (ai.value.equals("preserve")
                                     ? Boolean.TRUE
                                     : Boolean.FALSE));
                }
            
                printSpaces(ai.space, false);
                printCharacters(ai.name);

                if (ai.space1 != null) {
                    printSpaces(ai.space1, true);
                }
                printCharacter('=');
                if (ai.space2 != null) {
                    printSpaces(ai.space2, true);
                }

                printCharacter(ai.delimiter);
                printString(ai.value);
                printCharacter(ai.delimiter);
            }
        }

        if (space != null) {
            printSpaces(space, true);
        }
        level++;
        for (int i = 0; i < prettyPrinter.getTabulationWidth(); i++) {
            margin.append(' ');
        }
        canIndent = true;
    }

    /**
     * Prints the end of an element.
     */
    public void printElementEnd(char[] name, char[] space) throws IOException {
        for (int i = 0; i < prettyPrinter.getTabulationWidth(); i++) {
            margin.deleteCharAt(0);
        }
        level--;
        if (name != null) {
            if (prettyPrinter.getFormat()) {
                if (xmlSpace.get(0) != Boolean.TRUE &&
                    (line != ((Integer)startingLines.get(0)).intValue() ||
                     column + name.length + 3 >= prettyPrinter.getDocumentWidth())) {
                    printNewline();
                    printString(margin.toString());
                }
            }
            printString("</");
            printCharacters(name);
            if (space != null) {
                printSpaces(space, true);
            }
            printCharacter('>');
        } else {
            printString("/>");
        }
        startingLines.remove(0);
        xmlSpace.remove(0);
    }

    /**
     * Prints the character data of an element content.
     */
    public boolean printCharacterData(char[] data, 
                                      boolean first,
                                      boolean preceedingSpace) 
        throws IOException {
        if (!prettyPrinter.getFormat()) {
            printCharacters(data);
            return false;
        }

        canIndent = true;
        if (isWhiteSpace(data)) {
            int nl = newlines(data);
            for (int i = 0; i < nl - 1; i++) {
                printNewline();
            }
            return true;
        }

        if (xmlSpace.get(0) == Boolean.TRUE) {
            printCharacters(data);
            canIndent = false;
            return false;
        }

        if (first) {
            printNewline();
            printString(margin.toString());
        }
        return formatText(data, margin.toString(), preceedingSpace);
    }

    /**
     * Prints a CDATA section.
     */
    public void printCDATASection(char[] data) throws IOException {
        printString("<![CDATA[");
        printCharacters(data);
        printString("]]>");
    }

    /**
     * Prints a notation declaration.
     */
    public void printNotation(char[] space1,
                              char[] name,
                              char[] space2,
                              String externalId,
                              char[] space3,
                              char[] string1, char string1Delim,
                              char[] space4,
                              char[] string2, char string2Delim,
                              char[] space5)
        throws IOException {
        writer.write("<!NOTATION");
        printSpaces(space1, false);
        writer.write(name);
        printSpaces(space2, false);
        writer.write(externalId);
        printSpaces(space3, false);

        writer.write(string1Delim);
        writer.write(string1);
        writer.write(string1Delim);
        
        if (space4 != null) {
            printSpaces(space4, false);

            if (string2 != null) {
                writer.write(string2Delim);
                writer.write(string2);
                writer.write(string2Delim);
            }
        }
        if (space5 != null) {
            printSpaces(space5, true);
        }
        writer.write('>');
    }
    
    /**
     * Prints an attribute list declaration start.
     */
    public void printAttlistStart(char[] space, char[] name) throws IOException {
        writer.write("<!ATTLIST");
        printSpaces(space, false);
        writer.write(name);
    }

    /**
     * Prints an attribute list declaration end.
     */
    public void printAttlistEnd(char[] space) throws IOException {
        if (space != null) {
            printSpaces(space, false);
        }
        writer.write('>');
    }

    /**
     * Prints an attribute declaration start.
     */
    public void printAttName(char[] space1, char[] name, char[] space2)
        throws IOException {
        printSpaces(space1, false);
        writer.write(name);
        printSpaces(space2, false);
    }

    /**
     * Prints an enumeration.
     */
    public void printEnumeration(List names) throws IOException {
        writer.write('(');

        Iterator it = names.iterator();
        NameInfo ni = (NameInfo)it.next();
        if (ni.space1 != null) {
            printSpaces(ni.space1, true);
        }
            
        writer.write(ni.name);

        if (ni.space2 != null) {
            printSpaces(ni.space2, true);
        }
        while (it.hasNext()) {
            writer.write('|');

            ni = (NameInfo)it.next();
            if (ni.space1 != null) {
                printSpaces(ni.space1, true);
            }
            
            writer.write(ni.name);

            if (ni.space2 != null) {
                printSpaces(ni.space2, true);
            }
        }

        writer.write(')');
    }

    /**
     * Returns the number of newlines in the given char array.
     */
    protected int newlines(char[] text) {
        int result = 0;
        for (int i = 0; i < text.length; i++) {
            if (text[i] == 10) {
                result++;
            }
        }
        return result;
    }

    /**
     * Tells whether the given character represents white spaces.
     */
    protected boolean isWhiteSpace(char[] text) {
        for (int i = 0; i < text.length; i++) {
            if (!XMLUtilities.isXMLSpace(text[i])) {
                return false;
            }
        }
        return true;
    }

    /**
     * Formats the given text.
     */
    protected boolean formatText(char[] text, String margin,
                                 boolean preceedingSpace) throws IOException {
        int i = 0;
        boolean startsWithSpace = preceedingSpace;
        loop: while (i < text.length) {
            for (;;) {
                if (i >= text.length) {
                    break loop;
                }
                if (!XMLUtilities.isXMLSpace(text[i])) {
                    break;
                }
                startsWithSpace = true;
                i++;
            }
            StringBuffer sb = new StringBuffer();
            for (;;) {
                if (i >= text.length || XMLUtilities.isXMLSpace(text[i])) {
                    break;
                }
                sb.append(text[i++]);
            }
            if (sb.length() == 0) {
                return startsWithSpace;
            }
            if (startsWithSpace) {
                // Consider reformatting ws so things look nicer.
                int endCol = column + sb.length();
                if ((endCol >= prettyPrinter.getDocumentWidth() - 1) &&
                    ((margin.length() + sb.length() <
                      prettyPrinter.getDocumentWidth() - 1) ||
                     (margin.length() < column))) {
                    printNewline();
                    printString(margin);
                } else if (column > margin.length()) {
                    // Don't print space at start of new line.
                    printCharacter(' ');
                }
            }
            printString(sb.toString());
            startsWithSpace = false;
        }
        return startsWithSpace;
    }

    /**
     * To store the informations about a name.
     */
    public static class NameInfo {
        
        /**
         * The space before the name.
         */
        public char[] space1;

        /**
         * The name.
         */
        public char[] name;

        /**
         * The space after the name
         */
        public char[] space2;

        /**
         * Creates a new NameInfo.
         */
        public NameInfo(char[] sp1, char[] nm, char[] sp2) {
            space1 = sp1;
            name = nm;
            space2 = sp2;
        }
    }

    /**
     * To store the informations about an attribute.
     */
    public static class AttributeInfo {

        /**
         * The space before the name.
         */
        public char[] space;

        /**
         * The attribute name.
         */
        public char[] name;

        /**
         * The space before '='.
         */
        public char[] space1;

        /**
         * The space after '='.
         */
        public char[] space2;

        /**
         * The attribute value.
         */
        public String value;

        /**
         * The attribute value delimiter.
         */
        public char delimiter;

        /**
         * Whether the attribute value contains entity references.
         */
        public boolean entityReferences;

        /**
         * Creates a new AttributeInfo.
         */
        public AttributeInfo(char[] sp, char[] n, char[] sp1, char[] sp2,
                             String val, char delim, boolean entity) {
            space = sp;
            name = n;
            space1 = sp1;
            space2 = sp2;
            value = val;
            delimiter = delim;
            entityReferences = entity;
        }

        /**
         * Tells whether the name of the attribute represented by this class
         * equals the given string.
         */
        public boolean isAttribute(String s) {
            if (name.length == s.length()) {
                for (int i = 0; i < name.length; i++) {
                    if (name[i] != s.charAt(i)) {
                        return false;
                    }
                }
                return true;
            }
            return false;
        }
    }
}
