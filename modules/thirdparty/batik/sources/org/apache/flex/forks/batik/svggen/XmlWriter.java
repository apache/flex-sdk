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

package org.apache.flex.forks.batik.svggen;

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;

import org.apache.flex.forks.batik.util.SVGConstants;
import org.w3c.dom.Attr;
import org.w3c.dom.CDATASection;
import org.w3c.dom.Comment;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.Text;

/**
 * Writes a Node as text output. Package access. This is
 * *not* a full Xml printout implementation. It only covers
 * what is needed by the Graphics2D class.
 * The code for this class draws heavily from the work done
 * for Sun's Project X by David Brownell.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: XmlWriter.java 478176 2006-11-22 14:50:50Z dvholten $
 */
class XmlWriter implements SVGConstants {

    private static String EOL;
    private static final String TAG_END = "/>";
    private static final String TAG_START = "</";

    private static final char[] SPACES =
    { ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
      ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ' };
    private static final int    SPACES_LEN = SPACES.length;

    static {
        String  temp;
        try { temp = System.getProperty ("line.separator", "\n"); }
        catch (SecurityException e) { temp = "\n"; }
        EOL = temp;
    }

    static class IndentWriter extends Writer {
        protected Writer proxied;
        protected int    indentLevel;
        protected int    column;

        public IndentWriter(Writer proxied){
            if (proxied == null)
                throw new SVGGraphics2DRuntimeException
                    (ErrorConstants.ERR_PROXY);

            this.proxied = proxied;
        }

        public void setIndentLevel(int indentLevel){
            this.indentLevel = indentLevel;
        }

        public int getIndentLevel(){
            return indentLevel;
        }

        public void printIndent() throws IOException{
            proxied.write(EOL);
            int temp = indentLevel;
            while(temp > 0){
                if (temp > SPACES_LEN) {
                    proxied.write(SPACES, 0, SPACES_LEN);
                    temp -= SPACES_LEN;
                } else {
                    proxied.write(SPACES, 0, temp);
                    break;
                }
            }
            column = indentLevel;
        }

        public Writer getProxied(){
            return proxied;
        }

        public int getColumn() { return column; }

        public void write(int c) throws IOException {
            column++;
            proxied.write(c);
        }

        public void write(char[] cbuf) throws IOException {
            column+=cbuf.length;
            proxied.write(cbuf);
        }

        public void write(char[] cbuf, int off, int len) throws IOException{
            column+=len;
            proxied.write(cbuf, off, len);
        }

        public void write(String str) throws IOException {
            column+=str.length();
            proxied.write(str);
        }

        public void write(String str, int off, int len) throws IOException {
            column+=len;
            proxied.write(str, off, len);
        }

        public void flush() throws IOException{
            proxied.flush();
        }

        public void close() throws IOException{
            column = -1;
            proxied.close();
        }
    }

    private static void writeXml(Attr attr, IndentWriter out,
                                 boolean escaped)
        throws IOException{
        String name = attr.getName();
        out.write (name);
        out.write ("=\"");
        writeChildrenXml(attr, out, escaped);
        out.write ('"');
    }

    /**
     * Writes the attribute's value.
     */
    private static void writeChildrenXml(Attr attr, IndentWriter out,
                                         boolean escaped)
        throws IOException {
        char[] data = attr.getValue().toCharArray();
        if (data == null) return;

        int         length = data.length;
        int         start=0, last=0;
        while (last < length) {
            char c = data[last];
            switch (c) {
            case '<':
                out.write (data, start, last - start);
                start = last + 1;
                out.write ("&lt;");
                break;
            case '>':
                out.write (data, start, last - start);
                start = last + 1;
                out.write ("&gt;");
                break;
            case '&':
                out.write (data, start, last - start);
                start = last + 1;
                out.write ("&amp;");
                break;
            case '\'':
                out.write (data, start, last - start);
                start = last + 1;
                out.write ("&apos;");
                break;
            case '"':
                out.write (data, start, last - start);
                start = last + 1;
                out.write ("&quot;");
                break;
            default: // to be able to escape characters if allowed
                if (escaped && (c > 0x007F)) {
                    out.write (data, start, last - start);
                    String hex = "0000"+Integer.toHexString(c);
                    out.write("&#x"+hex.substring(hex.length()-4)+";");
                    start = last + 1;
                }
                break;
            }
            last++;
        }
        out.write (data, start, last - start);
    }

    /**
     * Writes out the comment.  Note that spaces may be added to
     * prevent illegal comments:  between consecutive dashes ("--")
     * or if the last character of the comment is a dash.
     */
    private static void writeXml(Comment comment, IndentWriter out,
                                 boolean escaped)
        throws IOException {

        char[] data = comment.getData().toCharArray();

        if (data == null) {
            out.write("<!---->");
            return;
        }

        out.write ("<!--");
        boolean     sawDash = false;
        int         length = data.length;
        int         start=0, last=0;

        // "--" illegal in comments, insert a space.
        while (last < length) {
            char c = data[last];
            if (c == '-') {
                if (sawDash) {
                    out.write (data, start, last - start);
                    start = last;
                    out.write (' ');
                }
                sawDash = true;
            } else {
                sawDash = false;
            }
            last++;
        }
        out.write (data, start, last - start);
        if (sawDash)
            out.write (' ');
        out.write ("-->");
    }

    private static void writeXml(Text text, IndentWriter out, boolean escaped)
        throws IOException {
        writeXml(text, out, false, escaped);
    }

    private static void writeXml(Text text, IndentWriter out, boolean trimWS,
                                 boolean escaped)
        throws IOException {
        char[] data = text.getData().toCharArray();

        // XXX saw this once -- being paranoid
        if (data == null)
            { System.err.println ("Null text data??"); return; }

        int length = data.length;
        int start = 0, last = 0;
        if (trimWS) {
            while (last < length) {
                char c = data[last];
                switch (c) {
                case ' ': case '\t': case '\n': case '\r': last++; continue;
                default: break;
                }
                break;
            }
            start = last;
        }

        while (last < length) {
            char c = data [last];

            // escape markup delimiters only ... and do bulk
            // writes wherever possible, for best performance
            //
            // note that character data can't have the CDATA
            // termination "]]>"; escaping ">" suffices, and
            // doing it very generally helps simple parsers
            // that may not be quite correct.
            //
            switch(c) {
            case ' ': case '\t': case '\n': case '\r':
                if (trimWS) {
                    int wsStart = last; last++;
                    while (last < length) {
                        switch(data[last]) {
                        case ' ': case '\t': case '\n': case '\r':
                            last++; continue;
                        default: break;
                        }
                        break;
                    }
                    if (last == length) {
                        out.write(data, start, wsStart-start);
                        return;
                    } else {
                        continue;
                    }
                }
                break;
            case '<':                     // not legal in char data
                out.write (data, start, last - start);
                start = last + 1;
                out.write ("&lt;");
                break;
            case '>':                     // see above
                out.write (data, start, last - start);
                start = last + 1;
                out.write ("&gt;");
                break;
            case '&':                    // not legal in char data
                out.write (data, start, last - start);
                start = last + 1;
                out.write ("&amp;");
                break;
            default: // to be able to escape characters if allowed
                if (escaped && (c > 0x007F)) {
                    out.write (data, start, last - start);
                    String hex = "0000"+Integer.toHexString(c);
                    out.write("&#x"+hex.substring(hex.length()-4)+";");
                    start = last + 1;
                }
                break;
            }
            last++;
        }
        out.write (data, start, last - start);
    }

    private static void writeXml(CDATASection cdataSection, IndentWriter out,
                                 boolean escaped)
        throws IOException {
        char[] data = cdataSection.getData().toCharArray();
        if (data == null) {
            out.write ("<![CDATA[]]>");
            return;
        }

        out.write ("<![CDATA[");
        int length = data.length;
        int  start = 0, last = 0;
        while (last < length) {
            char c = data [last];

            // embedded "]]>" needs to be split into adjacent
            // CDATA blocks ... can be split at either point
            if (c == ']') {
                if (((last + 2) < data.length) &&
                    (data [last + 1] == ']')   &&
                    (data [last + 2] == '>')) {
                    out.write (data, start, last - start);
                    start = last + 1;
                    out.write ("]]]]><![CDATA[>");
                    continue;
                }
            }
            last++;
        }
        out.write (data, start, last - start);
        out.write ("]]>");
    }

    private static void writeXml(Element element, IndentWriter out,
                                 boolean escaped)
        throws IOException, SVGGraphics2DIOException {
        out.write (TAG_START, 0, 1);    // "<"
        out.write (element.getTagName());

        NamedNodeMap attributes = element.getAttributes();
        if (attributes != null){
            int nAttr = attributes.getLength();
            for(int i=0; i<nAttr; i++){
                Attr attr = (Attr)attributes.item(i);
                out.write(' ');
                writeXml(attr, out, escaped);
            }
        }

        boolean lastElem = (element.getParentNode().getLastChild()==element);

        //
        // Write empty nodes as "<EMPTY />" to make sure version 3
        // and 4 web browsers can read empty tag output as HTML.
        // XML allows "<EMPTY/>" too, of course.
        //
        if (!element.hasChildNodes()) {
            if (lastElem)
                out.setIndentLevel(out.getIndentLevel()-2);
            out.printIndent ();
            out.write(TAG_END, 0, 2);   // "/>"
            return;
        }
        Node child = element.getFirstChild();
        out.printIndent ();
        out.write(TAG_END, 1, 1);   // ">"
        if ((child.getNodeType() != Node.TEXT_NODE) ||
            (element.getLastChild() != child)) { // one text node child..
            out.setIndentLevel(out.getIndentLevel()+2);
        }

        writeChildrenXml(element, out, escaped);

        out.write (TAG_START, 0, 2);        // "</"
        out.write (element.getTagName());
        if (lastElem)
            out.setIndentLevel(out.getIndentLevel()-2);
        out.printIndent ();
        out.write (TAG_END, 1, 1);  // ">"
    }

    private static void writeChildrenXml(Element element, IndentWriter out,
                                         boolean escaped)
        throws IOException, SVGGraphics2DIOException {
        Node child = element.getFirstChild();
        while (child != null) {
            writeXml(child, out, escaped);
            child = child.getNextSibling();
        }
    }

    private static void writeDocumentHeader(IndentWriter out)
        throws IOException {
        String  encoding = null;

        if (out.getProxied() instanceof OutputStreamWriter) {
            OutputStreamWriter osw = (OutputStreamWriter)out.getProxied();
            encoding = java2std(osw.getEncoding());
        }

        out.write ("<?xml version=\"1.0\"");
        if (encoding != null) {
            out.write (" encoding=\"");
            out.write (encoding);
            out.write ('\"');
        }
        out.write ("?>");
        out.write (EOL);

        // Write DOCTYPE declaration here. Skip until specification is released.
        out.write ("<!DOCTYPE svg PUBLIC '");
        out.write (SVG_PUBLIC_ID);
        out.write ("'"); out.write (EOL);

        out.write ("          '");
        out.write (SVG_SYSTEM_ID);
        out.write ("'"); out.write (">"); out.write (EOL);
    }

    private static void writeXml(Document document, IndentWriter out,
                                 boolean escaped)
        throws IOException, SVGGraphics2DIOException {
        writeDocumentHeader(out);
        NodeList childList = document.getChildNodes();
        writeXml(childList, out, escaped);
    }

    private static void writeXml(NodeList childList, IndentWriter out,
                                 boolean escaped)
        throws IOException, SVGGraphics2DIOException {
        int     length = childList.getLength ();

        if (length == 0)
            return;
        for (int i = 0; i < length; i++) {
            Node child = childList.item(i);
            writeXml(child, out, escaped);
            out.write (EOL);
        }
    }

    static String java2std(String encodingName) {
        if (encodingName == null)
            return null;

        //
        // ISO-8859-N is a common family of 8 bit encodings;
        // N=1 is the eight bit subset of UNICODE, and there
        // seem to be at least drafts for some N >10.
        //
        if (encodingName.startsWith ("ISO8859_"))       // JDK 1.2
            return "ISO-8859-" + encodingName.substring (8);
        if (encodingName.startsWith ("8859_"))          // JDK 1.1
            return "ISO-8859-" + encodingName.substring (5);

        // XXX seven bit encodings ISO-2022-* ...
        // XXX EBCDIC encodings ...

        if ("ASCII7".equalsIgnoreCase (encodingName)
            || "ASCII".equalsIgnoreCase (encodingName))
            return "US-ASCII";

        //
        // All XML parsers _must_ support UTF-8 and UTF-16.
        // (UTF-16 ~= ISO-10646-UCS-2 plus surrogate pairs)
        //
        if ("UTF8".equalsIgnoreCase (encodingName))
            return "UTF-8";
        if (encodingName.startsWith ("Unicode"))
            return "UTF-16";

        //
        // Some common Japanese character sets.
        //
        if ("SJIS".equalsIgnoreCase (encodingName))
            return "Shift_JIS";
        if ("JIS".equalsIgnoreCase (encodingName))
            return "ISO-2022-JP";
        if ("EUCJIS".equalsIgnoreCase (encodingName))
            return "EUC-JP";

        // else we force UTF-8 encoding, better than nothing...
        return "UTF-8";
    }

    public static void writeXml(Node node, Writer writer, boolean escaped)
        throws SVGGraphics2DIOException {
        try {
            IndentWriter out = null;
            if (writer instanceof IndentWriter)
                out = (IndentWriter)writer;
            else
                out = new IndentWriter(writer);

            switch (node.getNodeType()) {
            case Node.ATTRIBUTE_NODE:
                writeXml((Attr)node, out, escaped);
                break;
            case Node.COMMENT_NODE:
                writeXml((Comment)node, out, escaped);
                break;
            case Node.TEXT_NODE:
                writeXml((Text)node, out, escaped);
                break;
            case Node.CDATA_SECTION_NODE:
                writeXml((CDATASection)node, out, escaped);
                break;
            case Node.DOCUMENT_NODE:
                writeXml((Document)node, out, escaped);
                break;
            case Node.DOCUMENT_FRAGMENT_NODE:
                writeDocumentHeader(out);
                NodeList childList = node.getChildNodes();
                writeXml(childList, out, escaped);
                break;
            case Node.ELEMENT_NODE:
                writeXml((Element)node, out, escaped);
                break;
            default:
                throw new SVGGraphics2DRuntimeException
                    (ErrorConstants.INVALID_NODE+node.getClass().getName());
            }
        } catch (IOException io) {
            throw new SVGGraphics2DIOException(io);
        }
    }
}
