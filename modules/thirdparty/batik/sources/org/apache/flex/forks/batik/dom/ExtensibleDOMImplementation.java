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
package org.apache.flex.forks.batik.dom;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.ListIterator;
import java.util.Locale;
import java.util.MissingResourceException;

import org.apache.flex.forks.batik.css.engine.CSSContext;
import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.value.ShorthandManager;
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.css.parser.ExtendedParser;
import org.apache.flex.forks.batik.css.parser.ExtendedParserWrapper;
import org.apache.flex.forks.batik.dom.util.DOMUtilities;
import org.apache.flex.forks.batik.i18n.Localizable;
import org.apache.flex.forks.batik.i18n.LocalizableSupport;
import org.apache.flex.forks.batik.util.DoublyIndexedTable;
import org.apache.flex.forks.batik.util.Service;
import org.apache.flex.forks.batik.util.XMLResourceDescriptor;

import org.w3c.css.sac.Parser;
import org.w3c.dom.DOMException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.css.DOMImplementationCSS;
import org.w3c.dom.css.ViewCSS;

/**
 * This class implements the {@link org.w3c.dom.DOMImplementation} interface.
 * It allows the user to extend the set of elements supported by a
 * Document, directly or through the Service API (see
 * {@link org.apache.flex.forks.batik.util.Service}).
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ExtensibleDOMImplementation.java 592621 2007-11-07 05:58:12Z cam $
 */
public abstract class ExtensibleDOMImplementation
    extends AbstractDOMImplementation
    implements DOMImplementationCSS,
               StyleSheetFactory,
               Localizable {

    /**
     * The custom elements factories.
     */
    protected DoublyIndexedTable customFactories;

    /**
     * The custom value managers.
     */
    protected List customValueManagers;

    /**
     * The custom shorthand value managers.
     */
    protected List customShorthandManagers;

    /**
     * The error messages bundle class name.
     */
    protected static final String RESOURCES =
        "org.apache.flex.forks.batik.dom.resources.Messages";

    /**
     * The localizable support for the error messages.
     */
    protected LocalizableSupport localizableSupport;

    /**
     * Creates a new DOMImplementation.
     */
    public ExtensibleDOMImplementation() {
        initLocalizable();

        Iterator iter = getDomExtensions().iterator();

        while(iter.hasNext()) {
            DomExtension de = (DomExtension)iter.next();
            de.registerTags(this);
        }
    }

    // Localizable //////////////////////////////////////////////////////

    /**
     * Implements {@link Localizable#setLocale(Locale)}.
     */
    public void setLocale(Locale l) {
        localizableSupport.setLocale(l);
    }

    /**
     * Implements {@link Localizable#getLocale()}.
     */
    public Locale getLocale() {
        return localizableSupport.getLocale();
    }

    protected void initLocalizable() {
        localizableSupport =
            new LocalizableSupport(RESOURCES, getClass().getClassLoader());
    }

    /**
     * Implements {@link Localizable#formatMessage(String,Object[])}.
     */
    public String formatMessage(String key, Object[] args)
        throws MissingResourceException {
        return localizableSupport.formatMessage(key, args);
    }

    /**
     * Allows the user to register a new element factory.
     */
    public void registerCustomElementFactory(String namespaceURI,
                                             String localName,
                                             ElementFactory factory) {
        if (customFactories == null) {
            customFactories = new DoublyIndexedTable();
        }
        customFactories.put(namespaceURI, localName, factory);
    }

    /**
     * Allows the user to register a new CSS value manager.
     */
    public void registerCustomCSSValueManager(ValueManager vm) {
        if (customValueManagers == null) {
            customValueManagers = new LinkedList();
        }
        customValueManagers.add(vm);
    }

    /**
     * Allows the user to register a new shorthand CSS value manager.
     */
    public void registerCustomCSSShorthandManager(ShorthandManager sm) {
        if (customShorthandManagers == null) {
            customShorthandManagers = new LinkedList();
        }
        customShorthandManagers.add(sm);
    }

    /**
     * Creates new CSSEngine and attach it to the document.
     */
    public CSSEngine createCSSEngine(AbstractStylableDocument doc,
                                     CSSContext ctx) {
        String pn = XMLResourceDescriptor.getCSSParserClassName();
        Parser p;
        try {
            p = (Parser)Class.forName(pn).newInstance();
        } catch (ClassNotFoundException e) {
            throw new DOMException(DOMException.INVALID_ACCESS_ERR,
                                   formatMessage("css.parser.class",
                                                 new Object[] { pn }));
        } catch (InstantiationException e) {
            throw new DOMException(DOMException.INVALID_ACCESS_ERR,
                                   formatMessage("css.parser.creation",
                                                 new Object[] { pn }));
        } catch (IllegalAccessException e) {
            throw new DOMException(DOMException.INVALID_ACCESS_ERR,
                                   formatMessage("css.parser.access",
                                                 new Object[] { pn }));
        }
        ExtendedParser ep = ExtendedParserWrapper.wrap(p);

        ValueManager[] vms;
        if (customValueManagers == null) {
            vms = new ValueManager[0];
        } else {
            vms = new ValueManager[customValueManagers.size()];
            Iterator it = customValueManagers.iterator();
            int i = 0;
            while (it.hasNext()) {
                vms[i++] = (ValueManager)it.next();
            }
        }

        ShorthandManager[] sms;
        if (customShorthandManagers == null) {
            sms = new ShorthandManager[0];
        } else {
            sms = new ShorthandManager[customShorthandManagers.size()];
            Iterator it = customShorthandManagers.iterator();
            int i = 0;
            while (it.hasNext()) {
                sms[i++] = (ShorthandManager)it.next();
            }
        }

        CSSEngine result = createCSSEngine(doc, ctx, ep, vms, sms);
        doc.setCSSEngine(result);
        return result;
    }

    public abstract CSSEngine createCSSEngine(AbstractStylableDocument doc,
                                              CSSContext               ctx,
                                              ExtendedParser           ep,
                                              ValueManager     []      vms,
                                              ShorthandManager []      sms);

    /**
     * Creates a ViewCSS.
     */
    public abstract ViewCSS createViewCSS(AbstractStylableDocument doc);

    /**
     * Implements the behavior of Document.createElementNS() for this
     * DOM implementation.
     */
    public Element createElementNS(AbstractDocument document,
                                   String           namespaceURI,
                                   String           qualifiedName) {
        if (namespaceURI != null && namespaceURI.length() == 0) {
            namespaceURI = null;
        }
        if (namespaceURI == null)
            return new GenericElement(qualifiedName.intern(), document);

        if (customFactories != null) {
            String name = DOMUtilities.getLocalName(qualifiedName);
            ElementFactory cef;
            cef = (ElementFactory)customFactories.get(namespaceURI, name);
            if (cef != null) {
                return cef.create(DOMUtilities.getPrefix(qualifiedName),
                                  document);
            }
        }
        return new GenericElementNS(namespaceURI.intern(),
                                    qualifiedName.intern(),
                                    document);
    }

    // The element factories /////////////////////////////////////////////////

    /**
     * This interface represents a factory for elements.
     */
    public interface ElementFactory {
        /**
         * Creates an instance of the associated element type.
         */
        Element create(String prefix, Document doc);
    }

    // Service /////////////////////////////////////////////////////////

    protected static List extensions = null;

    protected static synchronized List getDomExtensions() {
        if (extensions != null)
            return extensions;

        extensions = new LinkedList();

        Iterator iter = Service.providers(DomExtension.class);

        while (iter.hasNext()) {
            DomExtension de = (DomExtension)iter.next();
            float priority  = de.getPriority();
            ListIterator li = extensions.listIterator();
            for (;;) {
                if (!li.hasNext()) {
                    li.add(de);
                    break;
                }
                DomExtension lde = (DomExtension)li.next();
                if (lde.getPriority() > priority) {
                    li.previous();
                    li.add(de);
                    break;
                }
            }
        }

        return extensions;
    }
}
