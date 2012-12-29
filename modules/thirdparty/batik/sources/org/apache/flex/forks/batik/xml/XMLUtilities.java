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

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PushbackInputStream;
import java.io.Reader;

import org.apache.flex.forks.batik.util.EncodingUtilities;

/**
 * A collection of utility functions for XML.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: XMLUtilities.java 588550 2007-10-26 07:52:41Z dvholten $
 */
public class XMLUtilities extends XMLCharacters {

    /**
     * This class does not need to be instantiated.
     */
    protected XMLUtilities() {
    }

    /**
     * Tests whether the given character is a valid space.
     */
    public static boolean isXMLSpace(char c) {
      return (c <= 0x0020) &&
             (((((1L << 0x0009) |
                 (1L << 0x000A) |
                 (1L << 0x000D) |
                 (1L << 0x0020)) >> c) & 1L) != 0);
    }

    /**
     * Tests whether the given character is usable as the
     * first character of an XML name.
     */
    public static boolean isXMLNameFirstCharacter(char c) {
        return (NAME_FIRST_CHARACTER[c / 32] & (1 << (c % 32))) != 0;
    }

    /**
     * Tests whether the given character is usable as the
     * first character of an XML 1.1 name.
     */
    public static boolean isXML11NameFirstCharacter(char c) {
        return (NAME11_FIRST_CHARACTER[c / 32] & (1 << (c % 32))) != 0;
    }

    /**
     * Tests whether the given character is a valid XML name character.
     */
    public static boolean isXMLNameCharacter(char c) {
        return (NAME_CHARACTER[c / 32] & (1 << (c % 32))) != 0;
    }

    /**
     * Tests whether the given character is a valid XML 1.1 name character.
     */
    public static boolean isXML11NameCharacter(char c) {
        return (NAME11_CHARACTER[c / 32] & (1 << (c % 32))) != 0;
    }

    /**
     * Tests whether the given 32 bits character is valid in XML documents.
     * Because the majority of code-points is covered by the table-lookup-test,
     * we do it first.
     * This method gives meaningful results only for c >= 0 .
     */
    public static boolean isXMLCharacter(int c) {

        return ( ( ( XML_CHARACTER[c >>> 5 ] & (1 << (c & 0x1F ))) != 0 )
                || (c >= 0x10000 && c <= 0x10ffff) );
    }

    /**
     * Tests whether the given 32 bit character is a valid XML 1.1 character.
     */
    public static boolean isXML11Character(int c) {
        return c >= 1 && c <= 0xd7ff
            || c >= 0xe000 && c <= 0xfffd
            || c >= 0x10000 && c <= 0x10ffff;
    }

    /**
     * Tests whether the given character is a valid XML public ID character.
     */
    public static boolean isXMLPublicIdCharacter(char c) {
        return (c < 128) &&
            (PUBLIC_ID_CHARACTER[c / 32] & (1 << (c % 32))) != 0;
    }

    /**
     * Tests whether the given character is a valid XML version character.
     */
    public static boolean isXMLVersionCharacter(char c) {
        return (c < 128) &&
            (VERSION_CHARACTER[c / 32] & (1 << (c % 32))) != 0;
    }

    /**
     * Tests whether the given character is a valid aphabetic character.
     */
    public static boolean isXMLAlphabeticCharacter(char c) {
        return (c < 128) &&
            (ALPHABETIC_CHARACTER[c / 32] & (1 << (c % 32))) != 0;
    }

    /**
     * Creates a Reader initialized to scan the characters in the given
     * XML document's InputStream.
     * @param is The input stream positionned at the beginning of an
     *        XML document.
     * @return a Reader positionned at the beginning of the XML document
     *         It is created from an encoding figured out from the first
     *         few bytes of the document. As a consequence the given
     *         input stream is not positionned anymore at the beginning
     *         of the document when this method returns.
     */
    public static Reader createXMLDocumentReader(InputStream is)
        throws IOException {
        PushbackInputStream pbis = new PushbackInputStream(is, 128);
        byte[] buf = new byte[4];

        int len = pbis.read(buf);
        if (len > 0) {
            pbis.unread(buf, 0, len);
        }

        if (len == 4) {
            switch (buf[0] & 0x00FF) {
            case 0:
                if (buf[1] == 0x003c && buf[2] == 0x0000 && buf[3] == 0x003f) {
                    return new InputStreamReader(pbis, "UnicodeBig");
                }
                break;

            case '<':
                switch (buf[1] & 0x00FF) {
                case 0:
                    if (buf[2] == 0x003f && buf[3] == 0x0000) {
                        return new InputStreamReader(pbis, "UnicodeLittle");
                    }
                    break;

                case '?':
                    if (buf[2] == 'x' && buf[3] == 'm') {
                        Reader r = createXMLDeclarationReader(pbis, "UTF8");
                        String enc = getXMLDeclarationEncoding(r, "UTF8");
                        return new InputStreamReader(pbis, enc);
                    }
                }
                break;

            case 0x004C:
                if (buf[1] == 0x006f &&
                    (buf[2] & 0x00FF) == 0x00a7 &&
                    (buf[3] & 0x00FF) == 0x0094) {
                    Reader r = createXMLDeclarationReader(pbis, "CP037");
                    String enc = getXMLDeclarationEncoding(r, "CP037");
                    return new InputStreamReader(pbis, enc);
                }
                break;

            case 0x00FE:
                if ((buf[1] & 0x00FF) == 0x00FF) {
                    return new InputStreamReader(pbis, "Unicode");
                }
                break;

            case 0x00FF:
                if ((buf[1] & 0x00FF) == 0x00FE) {
                    return new InputStreamReader(pbis, "Unicode");
                }
            }
        }

        return new InputStreamReader(pbis, "UTF8");
    }

    /**
     * Creates a reader from the given input stream and encoding.
     * This method assumes the input stream working buffer is at least
     * 128 byte long. The input stream is restored before this method
     * returns. The 4 first bytes are skipped before creating the reader.
     */
    protected static Reader createXMLDeclarationReader(PushbackInputStream pbis,
                                                       String enc)
        throws IOException {
        byte[] buf = new byte[128];
        int len = pbis.read(buf);

        if (len > 0) {
            pbis.unread(buf, 0, len);
        }

        return new InputStreamReader(new ByteArrayInputStream(buf, 4, len), enc);
    }

    /**
     * Reads an XML declaration to get the encoding declaration value.
     * @param r a reader positioned just after '&lt;?xm'.
     * @param e the encoding to return by default or on error.
     */
    protected static String getXMLDeclarationEncoding(Reader r, String e)
        throws IOException {
        int c;

        if ((c = r.read()) != 'l') {
            return e;
        }

        if (!isXMLSpace((char)(c = r.read()))) {
            return e;
        }

        while (isXMLSpace((char)(c = r.read())));

        if (c != 'v') {
            return e;
        }
        if ((c = r.read()) != 'e') {
            return e;
        }
        if ((c = r.read()) != 'r') {
            return e;
        }
        if ((c = r.read()) != 's') {
            return e;
        }
        if ((c = r.read()) != 'i') {
            return e;
        }
        if ((c = r.read()) != 'o') {
            return e;
        }
        if ((c = r.read()) != 'n') {
            return e;
        }

        c = r.read();
        while (isXMLSpace((char)c)) {
            c = r.read();
        }

        if (c != '=') {
            return e;
        }

        while (isXMLSpace((char)(c = r.read())));

        if (c != '"' && c != '\'') {
            return e;
        }
        char sc = (char)c;

        for (;;) {
            c = r.read();
            if (c == sc) {
                break;
            }
            if (!isXMLVersionCharacter((char)c)) {
                return e;
            }
        }

        if (!isXMLSpace((char)(c = r.read()))) {
            return e;
        }
        while (isXMLSpace((char)(c = r.read())));

        if (c != 'e') {
            return e;
        }
        if ((c = r.read()) != 'n') {
            return e;
        }
        if ((c = r.read()) != 'c') {
            return e;
        }
        if ((c = r.read()) != 'o') {
            return e;
        }
        if ((c = r.read()) != 'd') {
            return e;
        }
        if ((c = r.read()) != 'i') {
            return e;
        }
        if ((c = r.read()) != 'n') {
            return e;
        }
        if ((c = r.read()) != 'g') {
            return e;
        }

        c = r.read();
        while (isXMLSpace((char)c)) {
            c = r.read();
        }

        if (c != '=') {
            return e;
        }

        while (isXMLSpace((char)(c = r.read())));

        if (c != '"' && c != '\'') {
            return e;
        }
        sc = (char)c;

        StringBuffer enc = new StringBuffer();
        for (;;) {
            c = r.read();
            if (c == -1) {
                return e;
            }
            if (c == sc) {
                return encodingToJavaEncoding(enc.toString(), e);
            }
            enc.append((char)c);
        }
    }

    /**
     * Converts the given standard encoding representation to the
     * corresponding Java encoding string.
     * @param e the encoding string to convert.
     * @param de the encoding string if no corresponding encoding was found.
     */
    public static String encodingToJavaEncoding(String e, String de) {
        String result = EncodingUtilities.javaEncoding(e);
        return (result == null) ? de : result;
    }
}
