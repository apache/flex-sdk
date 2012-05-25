/*

   Copyright 2002-2004  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.bridge;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.StringReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.jar.Manifest;

import org.apache.flex.forks.batik.dom.svg.XMLBaseSupport;
import org.apache.flex.forks.batik.dom.util.XLinkSupport;
import org.apache.flex.forks.batik.script.Interpreter;
import org.apache.flex.forks.batik.script.InterpreterException;
import org.apache.flex.forks.batik.script.ScriptHandler;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.events.DocumentEvent;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventListener;
import org.w3c.dom.events.EventTarget;
import org.w3c.flex.forks.dom.svg.SVGDocument;
import org.w3c.flex.forks.dom.svg.SVGSVGElement;
import org.w3c.flex.forks.dom.svg.EventListenerInitializer;

/**
 * This class is the base class for SVG scripting.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: BaseScriptingEnvironment.java,v 1.35 2005/03/27 08:58:30 cam Exp $
 */
public class BaseScriptingEnvironment {
    /**
     * Constant used to describe inline scripts.
     * <pre>
     * {0} - URL of document containing script.
     * {1} - Element tag
     * {2} - line number of element.
     * </pre>
     */
    public static final String INLINE_SCRIPT_DESCRIPTION
        = "BaseScriptingEnvironment.constant.inline.script.description";

    /**
     * Constant used to describe inline scripts.
     * <pre>
     * {0} - URL of document containing script.
     * {1} - Event attribute name
     * {2} - line number of element.
     * </pre>
     */
    public static final String EVENT_SCRIPT_DESCRIPTION
        = "BaseScriptingEnvironment.constant.event.script.description";

    /**
     * Tells whether the given SVG document is dynamic.
     */
    public static boolean isDynamicDocument(BridgeContext ctx, Document doc) {
        Element elt = doc.getDocumentElement();
        if ((elt != null) &&
            SVGConstants.SVG_NAMESPACE_URI.equals(elt.getNamespaceURI())) {
            if (elt.getAttributeNS
                (null, SVGConstants.SVG_ONABORT_ATTRIBUTE).length() > 0) {
                return true;
            }
            if (elt.getAttributeNS
                (null, SVGConstants.SVG_ONERROR_ATTRIBUTE).length() > 0) {
                return true;
            }
            if (elt.getAttributeNS
                (null, SVGConstants.SVG_ONRESIZE_ATTRIBUTE).length() > 0) {
                return true;
            }
            if (elt.getAttributeNS
                (null, SVGConstants.SVG_ONUNLOAD_ATTRIBUTE).length() > 0) {
                return true;
            }
            if (elt.getAttributeNS
                (null, SVGConstants.SVG_ONSCROLL_ATTRIBUTE).length() > 0) {
                return true;
            }
            if (elt.getAttributeNS
                (null, SVGConstants.SVG_ONZOOM_ATTRIBUTE).length() > 0) {
                return true;
            }
            return isDynamicElement(ctx, doc.getDocumentElement());
        }
        return false;
    }

    public static boolean isDynamicElement(BridgeContext ctx, Element elt) {
        List bridgeExtensions = ctx.getBridgeExtensions(elt.getOwnerDocument());
        return isDynamicElement(elt, ctx, bridgeExtensions);
    }

    /**
     * Tells whether the given SVG element is dynamic.
     */
    public static boolean isDynamicElement
        (Element elt, BridgeContext ctx, List bridgeExtensions) {
        Iterator i = bridgeExtensions.iterator();
        while (i.hasNext()) {
            BridgeExtension bridgeExtension = (BridgeExtension) i.next();
            if (bridgeExtension.isDynamicElement(elt)) {
                return true;
            }
        }
        if (SVGConstants.SVG_NAMESPACE_URI.equals(elt.getNamespaceURI())) {
            if (elt.getAttributeNS
                (null, SVGConstants.SVG_ONKEYUP_ATTRIBUTE).length() > 0) {
                return true;
            }
            if (elt.getAttributeNS
                (null, SVGConstants.SVG_ONKEYDOWN_ATTRIBUTE).length() > 0) {
                return true;
            }
            if (elt.getAttributeNS
                (null, SVGConstants.SVG_ONKEYPRESS_ATTRIBUTE).length() > 0) {
                return true;
            }
            if (elt.getAttributeNS
                (null, SVGConstants.SVG_ONLOAD_ATTRIBUTE).length() > 0) {
                return true;
            }
            if (elt.getAttributeNS
                (null, SVGConstants.SVG_ONERROR_ATTRIBUTE).length() > 0) {
                return true;
            }
            if (elt.getAttributeNS
                (null, SVGConstants.SVG_ONACTIVATE_ATTRIBUTE).length() > 0) {
                return true;
            }
            if (elt.getAttributeNS
                (null, SVGConstants.SVG_ONCLICK_ATTRIBUTE).length() > 0) {
                return true;
            }
            if (elt.getAttributeNS
                (null, SVGConstants.SVG_ONFOCUSIN_ATTRIBUTE).length() > 0) {
                return true;
            }
            if (elt.getAttributeNS
                (null, SVGConstants.SVG_ONFOCUSOUT_ATTRIBUTE).length() > 0) {
                return true;
            }
            if (elt.getAttributeNS
                (null, SVGConstants.SVG_ONMOUSEDOWN_ATTRIBUTE).length() > 0) {
                return true;
            }
            if (elt.getAttributeNS
                (null, SVGConstants.SVG_ONMOUSEMOVE_ATTRIBUTE).length() > 0) {
                return true;
            }
            if (elt.getAttributeNS
                (null, SVGConstants.SVG_ONMOUSEOUT_ATTRIBUTE).length() > 0) {
                return true;
            }
            if (elt.getAttributeNS
                (null, SVGConstants.SVG_ONMOUSEOVER_ATTRIBUTE).length() > 0) {
                return true;
            }
            if (elt.getAttributeNS
                (null, SVGConstants.SVG_ONMOUSEUP_ATTRIBUTE).length() > 0) {
                return true;
            }
        }

        for (Node n = elt.getFirstChild();
             n != null;
             n = n.getNextSibling()) {
            if (n.getNodeType() == Node.ELEMENT_NODE) {
                if (isDynamicElement(ctx, (Element)n)) {
                    return true;
                }
            }
        }
        return false;
    }


    protected final static String EVENT_NAME = "event";
    protected final static String ALTERNATE_EVENT_NAME = "evt";

    /**
     * The bridge context.
     */
    protected BridgeContext bridgeContext;

    /**
     * The user-agent.
     */
    protected UserAgent userAgent;

    /**
     * The document to manage.
     */
    protected Document document;

    /**
     * The URL of the document ot manage
     */
    protected ParsedURL docPURL;

    protected Set languages = new HashSet();

    /**
     * The default Interpreter for the document
     */
    protected Interpreter interpreter;

    /**
     * Creates a new BaseScriptingEnvironment.
     * @param ctx the bridge context
     */
    public BaseScriptingEnvironment(BridgeContext ctx) {
        bridgeContext = ctx;
        document = ctx.getDocument();
        docPURL = new ParsedURL(((SVGDocument)document).getURL());
        userAgent     = bridgeContext.getUserAgent();
    }

    /**
     * Creates a new Window object.
     */
    public org.apache.flex.forks.batik.script.Window createWindow
        (Interpreter interp, String lang) {
        return new Window(interp, lang);
    }

    /**
     * Creates a new Window object.
     */
    public org.apache.flex.forks.batik.script.Window createWindow() {
        return createWindow(null, null);
    }

    /**
     * Returns the default Interpreter for this document.
     */
    public Interpreter getInterpreter() {
        if (interpreter != null)
            return interpreter;

        SVGSVGElement root = (SVGSVGElement)document.getDocumentElement();
        String lang = root.getContentScriptType();
        return getInterpreter(lang);
    }

    public Interpreter getInterpreter(String lang) {
        interpreter = bridgeContext.getInterpreter(lang);
        if (interpreter == null) {
            if (languages.contains(lang)) {
                // Already issued warning so just return null;
                return null;
            }

            // So we know we have processed this interpreter.
            languages.add(lang);
            return null;
        }

        if (!languages.contains(lang)) {
            languages.add(lang);
            initializeEnvironment(interpreter, lang);
        }
        return interpreter;
    }

    /**
     * Initializes the environment of the given interpreter.
     */
    public void initializeEnvironment(Interpreter interp, String lang) {
        interp.bindObject("window", createWindow(interp, lang));
    }

    /**
     * Loads the scripts contained in the <script> elements.
     */
    public void loadScripts() {
        org.apache.flex.forks.batik.script.Window window = null;

        NodeList scripts = document.getElementsByTagNameNS
            (SVGConstants.SVG_NAMESPACE_URI, SVGConstants.SVG_SCRIPT_TAG);
        int len = scripts.getLength();

        if (len == 0) {
            return;
        }

        for (int i = 0; i < len; i++) {
            Element script = (Element)scripts.item(i);
            String type = script.getAttributeNS
                (null, SVGConstants.SVG_TYPE_ATTRIBUTE);

            if (type.length() == 0) {
                type = SVGConstants.SVG_SCRIPT_TYPE_DEFAULT_VALUE;
            }

            //
            // Java code invocation.
            //
            if (type.equals(SVGConstants.SVG_SCRIPT_TYPE_JAVA)) {
                try {
                    String href = XLinkSupport.getXLinkHref(script);
                    ParsedURL purl = new ParsedURL
                        (XMLBaseSupport.getCascadedXMLBase(script), href);

                    checkCompatibleScriptURL(type, purl);

                    DocumentJarClassLoader cll;
                    URL docURL = null;
                    try {
                        docURL = new URL(docPURL.toString());
                    } catch (MalformedURLException mue) {
                        /* nothing just let docURL be null */
                    }
                    cll = new DocumentJarClassLoader
                        (new URL(purl.toString()), docURL);

                    // Get the 'Script-Handler' entry in the manifest.
                    URL url = cll.findResource("META-INF/MANIFEST.MF");
                    if (url == null) {
                        continue;
                    }
                    Manifest man = new Manifest(url.openStream());

                    String sh;

                    sh = man.getMainAttributes().getValue("Script-Handler");
                    if (sh != null) {
                        // Run the script handler.
                        ScriptHandler h;
                        h = (ScriptHandler)cll.loadClass(sh).newInstance();

                        if (window == null) {
                            window = createWindow();
                        }

                        h.run(document, window);
                    }

                    sh = man.getMainAttributes().getValue("SVG-Handler-Class");
                    if (sh != null) {
                        // Run the initializer
                        EventListenerInitializer initializer;
                        initializer =
                            (EventListenerInitializer)cll.loadClass(sh).newInstance();

                        if (window == null) {
                            window = createWindow();
                        }

                        initializer.initializeEventListeners((SVGDocument)document);
                    }
                } catch (Exception e) {
                    if (userAgent != null) {
                        userAgent.displayError(e);
                    }
                }
                continue;
            }

            //
            // Scripting language invocation.
            //
            Interpreter interpreter = getInterpreter(type);
            if (interpreter == null)
                // Can't find interpreter so just skip this script block.
                continue;

            try {
                String href = XLinkSupport.getXLinkHref(script);
                String desc = null;
                Reader reader;

                if (href.length() > 0) {
                    desc = href;

                    // External script.
                    ParsedURL purl = new ParsedURL
                        (XMLBaseSupport.getCascadedXMLBase(script), href);

                    checkCompatibleScriptURL(type, purl);
                    reader = new InputStreamReader(purl.openStream());
                } else {
                    checkCompatibleScriptURL(type, docPURL);
                    DocumentLoader dl = bridgeContext.getDocumentLoader();
                    Element e = script;
                    SVGDocument d = (SVGDocument)e.getOwnerDocument();
                    int line = dl.getLineNumber(script);
                    desc = Messages.formatMessage
                        (INLINE_SCRIPT_DESCRIPTION,
                         new Object [] {d.getURL(),
                                        "<"+script.getNodeName()+">", 
                                        new Integer(line)});
                    // Inline script.
                    Node n = script.getFirstChild();
                    if (n != null) {
                        StringBuffer sb = new StringBuffer();
                        while (n != null) {
                            if (n.getNodeType() == Node.CDATA_SECTION_NODE
                                || n.getNodeType() == Node.TEXT_NODE)
                                sb.append(n.getNodeValue());
                            n = n.getNextSibling();
                        }
                        reader = new StringReader(sb.toString());
                    } else {
                        continue;
                    }
                }

                interpreter.evaluate(reader, desc);

            } catch (IOException e) {
                if (userAgent != null) {
                    userAgent.displayError(e);
                }
                return;
            } catch (InterpreterException e) {
                System.err.println("InterpExcept: " + e);
                handleInterpreterException(e);
                return;
            } catch (SecurityException e) {
                if (userAgent != null) {
                    userAgent.displayError(e);
                }
            }
        }
    }

    /**
     * Checks that the script URLs and the document url are
     * compatible. A SecurityException is thrown if loading
     * the script is not allowed.
     */
    protected void checkCompatibleScriptURL(String scriptType,
                                          ParsedURL scriptPURL){
        userAgent.checkLoadScript(scriptType, scriptPURL, docPURL);
    }

    /**
     * Recursively dispatch the SVG 'onload' event.
     */
    public void dispatchSVGLoadEvent() {
        SVGSVGElement root = (SVGSVGElement)document.getDocumentElement();
        String lang = root.getContentScriptType();
        dispatchSVGLoad(root, true, lang);
    }

    /**
     * Auxiliary method for dispatchSVGLoad.
     */
    protected void dispatchSVGLoad(Element elt,
                                   boolean checkCanRun,
                                   String lang) {
        for (Node n = elt.getFirstChild();
             n != null;
             n = n.getNextSibling()) {
            if (n.getNodeType() == Node.ELEMENT_NODE) {
                dispatchSVGLoad((Element)n, checkCanRun, lang);
            }
        }

        Event ev;
        DocumentEvent de = (DocumentEvent)elt.getOwnerDocument();
        ev = de.createEvent("SVGEvents");
        ev.initEvent("SVGLoad", false, false);
        EventTarget t = (EventTarget)elt;

        final String s =
            elt.getAttributeNS(null, SVGConstants.SVG_ONLOAD_ATTRIBUTE);
        if (s.length() == 0) {
            // No script to run so just dispatch the event to DOM
            // (For java presumably).
            t.dispatchEvent(ev);
            return;
        }

        final Interpreter interp = getInterpreter();
        if (interp == null) {
            // Can't load interpreter so just dispatch normal event
            // to the DOM (for java presumably).
            t.dispatchEvent(ev);
            return;
        }

        if (checkCanRun) {
            // Check that it is ok to run embeded scripts
            checkCompatibleScriptURL(lang, docPURL);
            checkCanRun = false; // we only check once for onload handlers
        }

        DocumentLoader dl = bridgeContext.getDocumentLoader();
        SVGDocument d = (SVGDocument)elt.getOwnerDocument();
        int line = dl.getLineNumber(elt);
        final String desc = Messages.formatMessage
            (EVENT_SCRIPT_DESCRIPTION,
             new Object [] {d.getURL(),
                            SVGConstants.SVG_ONLOAD_ATTRIBUTE, 
                            new Integer(line)});

        EventListener l = new EventListener() {
                public void handleEvent(Event evt) {
                    try {
                        interp.bindObject(EVENT_NAME, evt);
                        interp.bindObject(ALTERNATE_EVENT_NAME, evt);
                        interp.evaluate(new StringReader(s), desc);
                    } catch (IOException io) {
                    } catch (InterpreterException e) {
                        handleInterpreterException(e);
                    }
                }
            };
        t.addEventListener("SVGLoad", l, false);
        t.dispatchEvent(ev);
        t.removeEventListener("SVGLoad", l, false);
    }

    /**
     * Method to dispatch SVG Zoom event.
     */
    protected void dispatchSVGZoomEvent() {
        dispatchSVGDocEvent("SVGZoom");
    }

    /**
     * Method to dispatch SVG Scroll event.
     */
    protected void dispatchSVGScrollEvent() {
        dispatchSVGDocEvent("SVGScroll");
    }

    /**
     * Method to dispatch SVG Resize event.
     */
    protected void dispatchSVGResizeEvent() {
        dispatchSVGDocEvent("SVGResize");
    }

    protected void dispatchSVGDocEvent(String eventType) {
        SVGSVGElement root =
            (SVGSVGElement)document.getDocumentElement();
        // Event is dispatched on outermost SVG element.
        EventTarget t = root;

        DocumentEvent de = (DocumentEvent)document;
        Event ev = de.createEvent("SVGEvents");
        ev.initEvent(eventType, false, false);
        t.dispatchEvent(ev);
    }

    /**
     * Handles the given exception.
     */
    protected void handleInterpreterException(InterpreterException ie) {
        if (userAgent != null) {
            Exception ex = ie.getException();
            userAgent.displayError((ex == null) ? ie : ex);
        }
    }

    /**
     * Handles the given exception.
     */
    protected void handleSecurityException(SecurityException se) {
        if (userAgent != null) {
            userAgent.displayError(se);
        }
    }

    /**
     * Represents the window object of this environment.
     */
    protected class Window implements org.apache.flex.forks.batik.script.Window {

        /**
         * The associated interpreter.
         */
        protected Interpreter interpreter;

        /**
         * The associated language.
         */
        protected String language;

        /**
         * Creates a new Window.
         */
        public Window(Interpreter interp, String lang) {
            interpreter = interp;
            language = lang;
        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.script.Window#setInterval(String,long)}.
         */
        public Object setInterval(final String script, long interval) {
            return null;
        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.script.Window#setInterval(Runnable,long)}.
         */
        public Object setInterval(final Runnable r, long interval) {
            return null;
        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.script.Window#clearInterval(Object)}.
         */
        public void clearInterval(Object interval) {
        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.script.Window#setTimeout(String,long)}.
         */
        public Object setTimeout(final String script, long timeout) {
            return null;
        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.script.Window#setTimeout(Runnable,long)}.
         */
        public Object setTimeout(final Runnable r, long timeout) {
            return null;
        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.script.Window#clearTimeout(Object)}.
         */
        public void clearTimeout(Object timeout) {
        }

        /**
         * Parses the given XML string into a DocumentFragment of the
         * given document or a new document if 'doc' is null.
         * The implementation in this class always returns 'null'
         * @return The document/document fragment or null on error.
         */
        public Node parseXML(String text, Document doc) {
            return null;
        }

        /**
         * Gets data from the given URI.
         * @param uri The URI where the data is located.
         * @param h A handler called when the data is available.
         */
        public void getURL(String uri, org.apache.flex.forks.batik.script.Window.URLResponseHandler h) {
            getURL(uri, h, "UTF8");
        }

        /**
         * Gets data from the given URI.
         * @param uri The URI where the data is located.
         * @param h A handler called when the data is available.
         * @param enc The character encoding of the data.
         */
        public void getURL(String uri,
                           org.apache.flex.forks.batik.script.Window.URLResponseHandler h,
                           String enc) {
        }

        public void postURL(String uri, String content, 
                            org.apache.flex.forks.batik.script.Window.URLResponseHandler h) {
            postURL(uri, content, h, "text/plain", null);
        }

        public void postURL(String uri, String content, 
                            org.apache.flex.forks.batik.script.Window.URLResponseHandler h, 
                     String mimeType) {
            postURL(uri, content, h, mimeType, null);
        }

        public void postURL(String uri, 
                            String content, 
                            org.apache.flex.forks.batik.script.Window.URLResponseHandler h, 
                            String mimeType, 
                            String fEnc) { 
        }



        /**
         * Displays an alert dialog box.
         */
        public void alert(String message) {
        }

        /**
         * Displays a confirm dialog box.
         */
        public boolean confirm(String message) {
            return false;
        }

        /**
         * Displays an input dialog box.
         */
        public String prompt(String message) {
            return null;
        }

        /**
         * Displays an input dialog box, given the default value.
         */
        public String prompt(String message, String defVal) {
            return null;
        }

        /**
         * Returns the current BridgeContext.
         */
        public BridgeContext getBridgeContext() {
            return bridgeContext;
        }

        /**
         * Returns the associated interpreter.
         */
        public Interpreter getInterpreter() {
            return interpreter;
        }

    }
}
