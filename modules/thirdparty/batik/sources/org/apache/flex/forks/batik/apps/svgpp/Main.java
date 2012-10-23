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

package org.apache.flex.forks.batik.apps.svgpp;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import org.apache.flex.forks.batik.i18n.LocalizableSupport;
import org.apache.flex.forks.batik.transcoder.Transcoder;
import org.apache.flex.forks.batik.transcoder.TranscoderInput;
import org.apache.flex.forks.batik.transcoder.TranscoderOutput;
import org.apache.flex.forks.batik.transcoder.svg2svg.SVGTranscoder;

/**
 * This class is the main class of the svgpp application.
 * <p>
 * svgpp is a pretty-printer for SVG source files.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: Main.java 478160 2006-11-22 13:35:06Z dvholten $
 */
public class Main {

    /**
     * The application main method.
     * @param args The command-line arguments.
     */
    public static void main(String[] args) {
        new Main(args).run();
    }

    /**
     * The default resource bundle base name.
     */
    public static final String BUNDLE_CLASSNAME =
        "org.apache.flex.forks.batik.apps.svgpp.resources.Messages";

    /**
     * The localizable support.
     */
    protected static LocalizableSupport localizableSupport =
        new LocalizableSupport(BUNDLE_CLASSNAME, Main.class.getClassLoader());

    /**
     * The arguments.
     */
    protected String[] arguments;

    /**
     * The current index.
     */
    protected int index;

    /**
     * The option handlers.
     */
    protected Map handlers = new HashMap();
    {
        handlers.put("-doctype", new DoctypeHandler());
        handlers.put("-doc-width", new DocWidthHandler());
        handlers.put("-newline", new NewlineHandler());
        handlers.put("-public-id", new PublicIdHandler());
        handlers.put("-no-format", new NoFormatHandler());
        handlers.put("-system-id", new SystemIdHandler());
        handlers.put("-tab-width", new TabWidthHandler());
        handlers.put("-xml-decl", new XMLDeclHandler());
    }

    /**
     * The transcoder.
     */
    protected Transcoder transcoder = new SVGTranscoder();

    /**
     * Initializes the application.
     * @param args The command-line arguments.
     */
    public Main(String[] args) {
        arguments = args;
    }

    /**
     * Runs the pretty printer.
     */
    public void run() {
        if (arguments.length == 0) {
            printUsage();
            return;
        }
        try {
            for (;;) {
                OptionHandler oh = (OptionHandler)handlers.get(arguments[index]);
                if (oh == null) {
                    break;
                }
                oh.handleOption();
            }
            TranscoderInput in;
            in = new TranscoderInput(new java.io.FileReader(arguments[index++]));
            TranscoderOutput out;
            if (index < arguments.length) {
                out = new TranscoderOutput(new java.io.FileWriter(arguments[index]));
            } else {
                out = new TranscoderOutput(new java.io.OutputStreamWriter(System.out));
            }
            transcoder.transcode(in, out);
        } catch (Exception e) {
            e.printStackTrace();
            printUsage();
        }
    }

    /**
     * Prints the command usage.
     */
    protected void printUsage() {
        printHeader();
        System.out.println(localizableSupport.formatMessage("syntax", null));
        System.out.println();
        System.out.println(localizableSupport.formatMessage("options", null));
        Iterator it = handlers.keySet().iterator();
        while (it.hasNext()) {
            String s = (String)it.next();
            System.out.println(((OptionHandler)handlers.get(s)).getDescription());
        }
    }

    /**
     * Prints the command header.
     */
    protected void printHeader() {
        System.out.println(localizableSupport.formatMessage("header", null));
    }

    /**
     * This interface represents an option handler.
     */
    protected interface OptionHandler {
        /**
         * Handles the current option.
         */
        void handleOption();

        /**
         * Returns the option description.
         */
        String getDescription();
    }

    /**
     * To handle the '-doctype' option.
     */
    protected class DoctypeHandler implements OptionHandler {
        protected final Map values = new HashMap(6);
        {
            values.put("remove", SVGTranscoder.VALUE_DOCTYPE_REMOVE);
            values.put("change", SVGTranscoder.VALUE_DOCTYPE_CHANGE);
        }
        public void handleOption() {
            index++;
            if (index >= arguments.length) {
                throw new IllegalArgumentException();
            }
            Object val = values.get(arguments[index++]);
            if (val == null) {
                throw new IllegalArgumentException();
            }
            transcoder.addTranscodingHint(SVGTranscoder.KEY_DOCTYPE, val);
        }

        public String getDescription() {
            return localizableSupport.formatMessage("doctype.description", null);
        }
    }

    /**
     * To handle the '-newline' option.
     */
    protected class NewlineHandler implements OptionHandler {
        protected final Map values = new HashMap(6);
        {
            values.put("cr",    SVGTranscoder.VALUE_NEWLINE_CR);
            values.put("cr-lf", SVGTranscoder.VALUE_NEWLINE_CR_LF);
            values.put("lf",    SVGTranscoder.VALUE_NEWLINE_LF);
        }
        public void handleOption() {
            index++;
            if (index >= arguments.length) {
                throw new IllegalArgumentException();
            }
            Object val = values.get(arguments[index++]);
            if (val == null) {
                throw new IllegalArgumentException();
            }
            transcoder.addTranscodingHint(SVGTranscoder.KEY_NEWLINE, val);
        }

        public String getDescription() {
            return localizableSupport.formatMessage("newline.description", null);
        }
    }

    /**
     * To handle the '-no-format' option.
     */
    protected class NoFormatHandler implements OptionHandler {
        public void handleOption() {
            index++;
            transcoder.addTranscodingHint(SVGTranscoder.KEY_FORMAT, Boolean.FALSE);
        }

        public String getDescription() {
            return localizableSupport.formatMessage("no-format.description", null);
        }
    }

    /**
     * To handle the '-public-id' option.
     */
    protected class PublicIdHandler implements OptionHandler {
        public void handleOption() {
            index++;
            if (index >= arguments.length) {
                throw new IllegalArgumentException();
            }
            String s = arguments[index++];
            transcoder.addTranscodingHint(SVGTranscoder.KEY_PUBLIC_ID, s);
        }

        public String getDescription() {
            return localizableSupport.formatMessage("public-id.description", null);
        }
    }

    /**
     * To handle the '-system-id' option.
     */
    protected class SystemIdHandler implements OptionHandler {
        public void handleOption() {
            index++;
            if (index >= arguments.length) {
                throw new IllegalArgumentException();
            }
            String s = arguments[index++];
            transcoder.addTranscodingHint(SVGTranscoder.KEY_SYSTEM_ID, s);
        }

        public String getDescription() {
            return localizableSupport.formatMessage("system-id.description", null);
        }
    }

    /**
     * To handle the '-xml-decl' option.
     */
    protected class XMLDeclHandler implements OptionHandler {
        public void handleOption() {
            index++;
            if (index >= arguments.length) {
                throw new IllegalArgumentException();
            }
            String s = arguments[index++];
            transcoder.addTranscodingHint(SVGTranscoder.KEY_XML_DECLARATION, s);
        }

        public String getDescription() {
            return localizableSupport.formatMessage("xml-decl.description", null);
        }
    }

    /**
     * To handle the '-tab-width' option.
     */
    protected class TabWidthHandler implements OptionHandler {
        public void handleOption() {
            index++;
            if (index >= arguments.length) {
                throw new IllegalArgumentException();
            }
            transcoder.addTranscodingHint(SVGTranscoder.KEY_TABULATION_WIDTH,
                                          new Integer(arguments[index++]));
        }

        public String getDescription() {
            return localizableSupport.formatMessage("tab-width.description", null);
        }
    }

    /**
     * To handle the '-doc-width' option.
     */
    protected class DocWidthHandler implements OptionHandler {
        public void handleOption() {
            index++;
            if (index >= arguments.length) {
                throw new IllegalArgumentException();
            }
            transcoder.addTranscodingHint(SVGTranscoder.KEY_DOCUMENT_WIDTH,
                                          new Integer(arguments[index++]));
        }

        public String getDescription() {
            return localizableSupport.formatMessage("doc-width.description", null);
        }
    }
}
