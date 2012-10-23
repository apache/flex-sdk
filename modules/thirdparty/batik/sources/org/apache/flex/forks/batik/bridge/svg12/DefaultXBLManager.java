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
package org.apache.flex.forks.batik.bridge.svg12;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Set;
import java.util.TreeSet;
import java.util.List;
import java.util.Map;

import javax.swing.event.EventListenerList;

import org.apache.flex.forks.batik.bridge.BridgeContext;
import org.apache.flex.forks.batik.bridge.BridgeException;
import org.apache.flex.forks.batik.bridge.ErrorConstants;
import org.apache.flex.forks.batik.dom.AbstractAttrNS;
import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.AbstractNode;
import org.apache.flex.forks.batik.dom.events.NodeEventTarget;
import org.apache.flex.forks.batik.dom.svg12.BindableElement;
import org.apache.flex.forks.batik.dom.svg12.XBLEventSupport;
import org.apache.flex.forks.batik.dom.svg12.XBLOMContentElement;
import org.apache.flex.forks.batik.dom.svg12.XBLOMDefinitionElement;
import org.apache.flex.forks.batik.dom.svg12.XBLOMImportElement;
import org.apache.flex.forks.batik.dom.svg12.XBLOMShadowTreeElement;
import org.apache.flex.forks.batik.dom.svg12.XBLOMTemplateElement;
import org.apache.flex.forks.batik.dom.xbl.NodeXBL;
import org.apache.flex.forks.batik.dom.xbl.ShadowTreeEvent;
import org.apache.flex.forks.batik.dom.xbl.XBLManager;
import org.apache.flex.forks.batik.dom.xbl.XBLManagerData;
import org.apache.flex.forks.batik.dom.xbl.XBLShadowTreeElement;
import org.apache.flex.forks.batik.util.DoublyIndexedTable;
import org.apache.flex.forks.batik.util.XBLConstants;
import org.apache.flex.forks.batik.util.XMLConstants;

import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.events.DocumentEvent;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventListener;
import org.w3c.dom.events.EventTarget;
import org.w3c.dom.events.MutationEvent;

/**
 * A full featured sXBL manager.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: DefaultXBLManager.java 592621 2007-11-07 05:58:12Z cam $
 */
public class DefaultXBLManager implements XBLManager, XBLConstants {

    /**
     * Whether XBL processing is currently taking place.
     */
    protected boolean isProcessing;

    /**
     * The document.
     */
    protected Document document;

    /**
     * The BridgeContext.
     */
    protected BridgeContext ctx;

    /**
     * Map of namespace URI/local name pairs to ordered sets of
     * definition records.
     */
    protected DoublyIndexedTable definitionLists = new DoublyIndexedTable();

    /**
     * Map of definition element/import element pairs to definition records.
     */
    protected DoublyIndexedTable definitions = new DoublyIndexedTable();

    /**
     * Map of shadow trees to content managers.
     */
    protected Map contentManagers = new HashMap();

    /**
     * Map of import elements to import records.
     */
    protected Map imports = new HashMap();

    /**
     * DOM node inserted listener for the document.
     */
    protected DocInsertedListener docInsertedListener
        = new DocInsertedListener();

    /**
     * DOM node removed listener for the document.
     */
    protected DocRemovedListener docRemovedListener
        = new DocRemovedListener();

    /**
     * DOM subtree mutation listener for the document.
     */
    protected DocSubtreeListener docSubtreeListener
        = new DocSubtreeListener();

    /**
     * DOM attribute listener for import elements.
     */
    protected ImportAttrListener importAttrListener = new ImportAttrListener();

    /**
     * DOM attribute listener for referencing definition elements.
     */
    protected RefAttrListener refAttrListener = new RefAttrListener();

    /**
     * Global event listener list for XBL binding related events.
     */
    protected EventListenerList bindingListenerList = new EventListenerList();

    /**
     * Global event listener list for ContentSelectionChanged events.
     */
    protected EventListenerList contentSelectionChangedListenerList
        = new EventListenerList();

    /**
     * Creates a new DefaultXBLManager for the given document.
     */
    public DefaultXBLManager(Document doc, BridgeContext ctx) {
        document = doc;
        this.ctx = ctx;
        ImportRecord ir = new ImportRecord(null, null);
        imports.put(null, ir);
    }

    /**
     * Starts XBL processing on the document.
     */
    public void startProcessing() {
        if (isProcessing) {
            return;
        }

        // Get list of all current definitions in the document.
        NodeList nl = document.getElementsByTagNameNS(XBL_NAMESPACE_URI,
                                                      XBL_DEFINITION_TAG);
        XBLOMDefinitionElement[] defs
            = new XBLOMDefinitionElement[nl.getLength()];
        for (int i = 0; i < defs.length; i++) {
            defs[i] = (XBLOMDefinitionElement) nl.item(i);
        }

        // Get list of all imports in the document.
        nl = document.getElementsByTagNameNS(XBL_NAMESPACE_URI,
                                             XBL_IMPORT_TAG);
        Element[] imports
            = new Element[nl.getLength()];
        for (int i = 0; i < imports.length; i++) {
            imports[i] = (Element) nl.item(i);
        }

        // Add document listeners.
        AbstractDocument doc = (AbstractDocument) document;
        XBLEventSupport es = (XBLEventSupport) doc.initializeEventSupport();
        es.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMNodeRemoved",
             docRemovedListener, true);
        es.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMNodeInserted",
             docInsertedListener, true);
        es.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMSubtreeModified",
             docSubtreeListener, true);

        // Add definitions.
        for (int i = 0; i < defs.length; i++) {
            if (defs[i].getAttributeNS(null, XBL_REF_ATTRIBUTE).length() != 0) {
                addDefinitionRef(defs[i]);
            } else {
                String ns = defs[i].getElementNamespaceURI();
                String ln = defs[i].getElementLocalName();
                addDefinition(ns, ln, defs[i], null);
            }
        }

        // Add imports.
        for (int i = 0; i < imports.length; i++) {
            addImport(imports[i]);
        }

        // Bind all of the bindable elements in the document that have a
        // matching definition.
        isProcessing = true;
        bind(document.getDocumentElement());
    }

    /**
     * Stops XBL processing on the document.
     */
    public void stopProcessing() {
        if (!isProcessing) {
            return;
        }
        isProcessing = false;

        // Remove document listeners.
        AbstractDocument doc = (AbstractDocument) document;
        XBLEventSupport es = (XBLEventSupport) doc.initializeEventSupport();
        es.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMNodeRemoved",
             docRemovedListener, true);
        es.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMNodeInserted",
             docInsertedListener, true);
        es.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMSubtreeModified",
             docSubtreeListener, true);

        // Remove all imports.
        int nSlots = imports.values().size();
        ImportRecord[] irs = new ImportRecord[ nSlots ];
        imports.values().toArray( irs );
        for (int i = 0; i < irs.length; i++) {
            ImportRecord ir = irs[i];
            if (ir.importElement.getLocalName().equals(XBL_DEFINITION_TAG)) {
                removeDefinitionRef(ir.importElement);
            } else {
                removeImport(ir.importElement);
            }
        }

        // Remove all bindings.
        Object[] defRecs = definitions.getValuesArray();
        definitions.clear();
        for (int i = 0; i < defRecs.length; i++) {
            DefinitionRecord defRec = (DefinitionRecord) defRecs[i];
            TreeSet defs = (TreeSet) definitionLists.get(defRec.namespaceURI,
                                                         defRec.localName);
            if (defs != null) {
                while (!defs.isEmpty()) {
                    defRec = (DefinitionRecord) defs.first();
                    defs.remove(defRec);
                    removeDefinition(defRec);
                }
                definitionLists.put(defRec.namespaceURI, defRec.localName, null);
            }
        }
        definitionLists = new DoublyIndexedTable();
        contentManagers.clear();
    }

    /**
     * Returns whether XBL processing is currently enabled.
     */
    public boolean isProcessing() {
        return isProcessing;
    }

    /**
     * Adds a definition through its referring definition element (one
     * with a 'ref' attribute).
     */
    protected void addDefinitionRef(Element defRef) {
        String ref = defRef.getAttributeNS(null, XBL_REF_ATTRIBUTE);
        Element e = ctx.getReferencedElement(defRef, ref);
        if (!XBL_NAMESPACE_URI.equals(e.getNamespaceURI())
                || !XBL_DEFINITION_TAG.equals(e.getLocalName())) {
            throw new BridgeException
                (ctx, defRef, ErrorConstants.ERR_URI_BAD_TARGET,
                 new Object[] { ref });
        }
        ImportRecord ir = new ImportRecord(defRef, e);
        imports.put(defRef, ir);

        NodeEventTarget et = (NodeEventTarget) defRef;
        et.addEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMAttrModified",
             refAttrListener, false, null);

        XBLOMDefinitionElement d = (XBLOMDefinitionElement) defRef;
        String ns = d.getElementNamespaceURI();
        String ln = d.getElementLocalName();
        addDefinition(ns, ln, (XBLOMDefinitionElement) e, defRef);
    }

    /**
     * Removes a definition through its referring definition element (one
     * with a 'ref' attribute).
     */
    protected void removeDefinitionRef(Element defRef) {
        ImportRecord ir = (ImportRecord) imports.get(defRef);
        NodeEventTarget et = (NodeEventTarget) defRef;
        et.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMAttrModified",
             refAttrListener, false);
        DefinitionRecord defRec
            = (DefinitionRecord) definitions.get(ir.node, defRef);
        removeDefinition(defRec);
        imports.remove(defRef);
    }

    /**
     * Imports bindings from another document.
     */
    protected void addImport(Element imp) {
        String bindings = imp.getAttributeNS(null, XBL_BINDINGS_ATTRIBUTE);
        Node n = ctx.getReferencedNode(imp, bindings);
        if (n.getNodeType() == Node.ELEMENT_NODE
                && !(XBL_NAMESPACE_URI.equals(n.getNamespaceURI())
                        && XBL_XBL_TAG.equals(n.getLocalName()))) {
            throw new BridgeException
                (ctx, imp, ErrorConstants.ERR_URI_BAD_TARGET,
                 new Object[] { n });
        }
        ImportRecord ir = new ImportRecord(imp, n);
        imports.put(imp, ir);

        NodeEventTarget et = (NodeEventTarget) imp;
        et.addEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMAttrModified",
             importAttrListener, false, null);

        et = (NodeEventTarget) n;
        et.addEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeInserted",
             ir.importInsertedListener, false, null);
        et.addEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeRemoved",
             ir.importRemovedListener, false, null);
        et.addEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMSubtreeModified",
             ir.importSubtreeListener, false, null);
        addImportedDefinitions(imp, n);
    }

    /**
     * Adds the definitions in the given imported subtree.
     */
    protected void addImportedDefinitions(Element imp, Node n) {
        if (n instanceof XBLOMDefinitionElement) {
            XBLOMDefinitionElement def = (XBLOMDefinitionElement) n;
            String ns = def.getElementNamespaceURI();
            String ln = def.getElementLocalName();
            addDefinition(ns, ln, def, imp);
        } else {
            n = n.getFirstChild();
            while (n != null) {
                addImportedDefinitions(imp, n);
                n = n.getNextSibling();
            }
        }
    }

    /**
     * Removes an import.
     */
    protected void removeImport(Element imp) {
        ImportRecord ir = (ImportRecord) imports.get(imp);
        NodeEventTarget et = (NodeEventTarget) ir.node;
        et.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeInserted",
             ir.importInsertedListener, false);
        et.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeRemoved",
             ir.importRemovedListener, false);
        et.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMSubtreeModified",
             ir.importSubtreeListener, false);

        et = (NodeEventTarget) imp;
        et.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMAttrModified",
             importAttrListener, false);

        Object[] defRecs = definitions.getValuesArray();
        for (int i = 0; i < defRecs.length; i++) {
            DefinitionRecord defRec = (DefinitionRecord) defRecs[i];
            if (defRec.importElement == imp) {
                removeDefinition(defRec);
            }
        }
        imports.remove(imp);
    }

    /**
     * Adds an xbl:definition element to the list of definitions that
     * could possibly affect elements with the specified QName.  This
     * may or may not actually cause a new binding to come in to effect,
     * as this new definition element may be added earlier in the
     * document than another already in effect.
     *
     * @param namespaceURI the namespace URI of the bound elements
     * @param localName the local name of the bound elements
     * @param def the xbl:definition element
     * @param imp the xbl:import or xbl;definition element through which
     *            this definition is being added, or null if the binding
     *            is in the original document
     */
    protected void addDefinition(String namespaceURI,
                                 String localName,
                                 XBLOMDefinitionElement def,
                                 Element imp) {
        ImportRecord ir = (ImportRecord) imports.get(imp);
        DefinitionRecord oldDefRec = null;
        DefinitionRecord defRec;
        TreeSet defs = (TreeSet) definitionLists.get(namespaceURI, localName);
        if (defs == null) {
            defs = new TreeSet();
            definitionLists.put(namespaceURI, localName, defs);
        } else if (defs.size() > 0) {
            oldDefRec = (DefinitionRecord) defs.first();
        }
        XBLOMTemplateElement template = null;
        for (Node n = def.getFirstChild(); n != null; n = n.getNextSibling()) {
            if (n instanceof XBLOMTemplateElement) {
                template = (XBLOMTemplateElement) n;
                break;
            }
        }
        defRec = new DefinitionRecord(namespaceURI, localName, def,
                                      template, imp);
        defs.add(defRec);
        definitions.put(def, imp, defRec);
        addDefinitionElementListeners(def, ir);
        if (defs.first() != defRec) {
            return;
        }
        if (oldDefRec != null) {
            XBLOMDefinitionElement oldDef = oldDefRec.definition;
            XBLOMTemplateElement oldTemplate = oldDefRec.template;
            if (oldTemplate != null) {
                removeTemplateElementListeners(oldTemplate, ir);
            }
            removeDefinitionElementListeners(oldDef, ir);
        }
        if (template != null) {
            addTemplateElementListeners(template, ir);
        }
        if (isProcessing) {
            rebind(namespaceURI, localName, document.getDocumentElement());
        }
    }

    /**
     * Adds DOM mutation listeners to the given definition element.
     */
    protected void addDefinitionElementListeners(XBLOMDefinitionElement def,
                                                 ImportRecord ir) {
        XBLEventSupport es = (XBLEventSupport) def.initializeEventSupport();
        es.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMAttrModified",
             ir.defAttrListener, false);
        es.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMNodeInserted",
             ir.defNodeInsertedListener, false);
        es.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMNodeRemoved",
             ir.defNodeRemovedListener, false);
    }

    /**
     * Adds DOM mutation listeners to the given template element.
     */
    protected void addTemplateElementListeners(XBLOMTemplateElement template,
                                               ImportRecord ir) {
        XBLEventSupport es
            = (XBLEventSupport) template.initializeEventSupport();
        es.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMAttrModified",
             ir.templateMutationListener, false);
        es.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMNodeInserted",
             ir.templateMutationListener, false);
        es.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMNodeRemoved",
             ir.templateMutationListener, false);
        es.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMCharacterDataModified",
             ir.templateMutationListener, false);
    }

    /**
     * Removes an xbl:definition element from the list of definitions that
     * could possibly affect elements with the specified QName.  This
     * will only cause a new binding to come in to effect if it is currently
     * active.
     */
    protected void removeDefinition(DefinitionRecord defRec) {
        TreeSet defs = (TreeSet) definitionLists.get(defRec.namespaceURI,
                                                     defRec.localName);
        if (defs == null) {
            return;
        }
        Element imp = defRec.importElement;
        ImportRecord ir = (ImportRecord) imports.get(imp);
        DefinitionRecord activeDefRec = (DefinitionRecord) defs.first();
        defs.remove(defRec);
        definitions.remove(defRec.definition, imp);
        removeDefinitionElementListeners(defRec.definition, ir);
        if (defRec != activeDefRec) {
            return;
        }
        if (defRec.template != null) {
            removeTemplateElementListeners(defRec.template, ir);
        }
        rebind(defRec.namespaceURI, defRec.localName,
               document.getDocumentElement());
    }

    /**
     * Removes DOM mutation listeners from the given definition element.
     */
    protected void removeDefinitionElementListeners
            (XBLOMDefinitionElement def,
             ImportRecord ir) {
        XBLEventSupport es = (XBLEventSupport) def.initializeEventSupport();
        es.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMAttrModified",
             ir.defAttrListener, false);
        es.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMNodeInserted",
             ir.defNodeInsertedListener, false);
        es.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMNodeRemoved",
             ir.defNodeRemovedListener, false);
    }

    /**
     * Removes DOM mutation listeners from the given template element.
     */
    protected void removeTemplateElementListeners
            (XBLOMTemplateElement template,
             ImportRecord ir) {
        XBLEventSupport es
            = (XBLEventSupport) template.initializeEventSupport();
        es.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMAttrModified",
             ir.templateMutationListener, false);
        es.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMNodeInserted",
             ir.templateMutationListener, false);
        es.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMNodeRemoved",
             ir.templateMutationListener, false);
        es.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMCharacterDataModified",
             ir.templateMutationListener, false);
    }

    /**
     * Returns the definition record of the active definition for namespace
     * URI/local name pair.
     */
    protected DefinitionRecord getActiveDefinition(String namespaceURI,
                                                   String localName) {
        TreeSet defs = (TreeSet) definitionLists.get(namespaceURI, localName);
        if (defs == null || defs.size() == 0) {
            return null;
        }
        return (DefinitionRecord) defs.first();
    }

    /**
     * Unbinds each bindable element in the given element's subtree.
     */
    protected void unbind(Element e) {
        if (e instanceof BindableElement) {
            setActiveDefinition((BindableElement) e, null);
        } else {
            NodeList nl = getXblScopedChildNodes(e);
            for (int i = 0; i < nl.getLength(); i++) {
                Node n = nl.item(i);
                if (n.getNodeType() == Node.ELEMENT_NODE) {
                    unbind((Element) n);
                }
            }
        }
    }

    /**
     * Binds each bindable element in the given element's subtree.
     */
    protected void bind(Element e) {
        AbstractDocument doc = (AbstractDocument) e.getOwnerDocument();
        if (doc != document) {
            XBLManager xm = doc.getXBLManager();
            if (xm instanceof DefaultXBLManager) {
                ((DefaultXBLManager) xm).bind(e);
                return;
            }
        }

        if (e instanceof BindableElement) {
            DefinitionRecord defRec
                = getActiveDefinition(e.getNamespaceURI(),
                                      e.getLocalName());
            setActiveDefinition((BindableElement) e, defRec);
        } else {
            NodeList nl = getXblScopedChildNodes(e);
            for (int i = 0; i < nl.getLength(); i++) {
                Node n = nl.item(i);
                if (n.getNodeType() == Node.ELEMENT_NODE) {
                    bind((Element) n);
                }
            }
        }
    }

    /**
     * Rebinds each bindable element of the given name in the given element's
     * subtree.
     */
    protected void rebind(String namespaceURI, String localName, Element e) {
        AbstractDocument doc = (AbstractDocument) e.getOwnerDocument();
        if (doc != document) {
            XBLManager xm = doc.getXBLManager();
            if (xm instanceof DefaultXBLManager) {
                ((DefaultXBLManager) xm).rebind(namespaceURI, localName, e);
                return;
            }
        }

        if (e instanceof BindableElement
                && namespaceURI.equals(e.getNamespaceURI())
                && localName.equals(e.getLocalName())) {
            DefinitionRecord defRec
                = getActiveDefinition(e.getNamespaceURI(),
                                      e.getLocalName());
            setActiveDefinition((BindableElement) e, defRec);
        } else {
            NodeList nl = getXblScopedChildNodes(e);
            for (int i = 0; i < nl.getLength(); i++) {
                Node n = nl.item(i);
                if (n.getNodeType() == Node.ELEMENT_NODE) {
                    rebind(namespaceURI, localName, (Element) n);
                }
            }
        }
    }

    /**
     * Sets the given definition as the active one for a particular
     * bindable element.
     */
    protected void setActiveDefinition(BindableElement elt,
                                       DefinitionRecord defRec) {
        XBLRecord rec = getRecord(elt);
        rec.definitionElement = defRec == null ? null : defRec.definition;
        if (defRec != null
                && defRec.definition != null
                && defRec.template != null) {
            setXblShadowTree(elt, cloneTemplate(defRec.template));
        } else {
            setXblShadowTree(elt, null);
        }
    }

    /**
     * Sets the shadow tree for the given bindable element.
     */
    protected void setXblShadowTree(BindableElement elt,
                                    XBLOMShadowTreeElement newShadow) {
        XBLOMShadowTreeElement oldShadow
            = (XBLOMShadowTreeElement) getXblShadowTree(elt);
        if (oldShadow != null) {
            fireShadowTreeEvent(elt, XBL_UNBINDING_EVENT_TYPE, oldShadow);
            ContentManager cm = getContentManager(oldShadow);
            if (cm != null) {
                cm.dispose();
            }
            elt.setShadowTree(null);
            XBLRecord rec = getRecord(oldShadow);
            rec.boundElement = null;
            oldShadow.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI,
                 "DOMSubtreeModified",
                 docSubtreeListener, false);
        }
        if (newShadow != null) {
            newShadow.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI,
                 "DOMSubtreeModified",
                 docSubtreeListener, false, null);
            fireShadowTreeEvent(elt, XBL_PREBIND_EVENT_TYPE, newShadow);
            elt.setShadowTree(newShadow);
            XBLRecord rec = getRecord(newShadow);
            rec.boundElement = elt;
            AbstractDocument doc
                = (AbstractDocument) elt.getOwnerDocument();
            XBLManager xm = doc.getXBLManager();
            ContentManager cm = new ContentManager(newShadow, xm);
            setContentManager(newShadow, cm);
        }
        invalidateChildNodes(elt);
        if (newShadow != null) {
            NodeList nl = getXblScopedChildNodes(elt);
            for (int i = 0; i < nl.getLength(); i++) {
                Node n = nl.item(i);
                if (n.getNodeType() == Node.ELEMENT_NODE) {
                    bind((Element) n);
                }
            }
            dispatchBindingChangedEvent(elt, newShadow);
            fireShadowTreeEvent(elt, XBL_BOUND_EVENT_TYPE, newShadow);
        } else {
            dispatchBindingChangedEvent(elt, newShadow);
        }
    }

    /**
     * Fires a ShadowTreeEvent of the given type on this element.
     */
    protected void fireShadowTreeEvent(BindableElement elt,
                                       String type,
                                       XBLShadowTreeElement e) {
        DocumentEvent de = (DocumentEvent) elt.getOwnerDocument();
        ShadowTreeEvent evt
            = (ShadowTreeEvent) de.createEvent("ShadowTreeEvent");
        evt.initShadowTreeEventNS(XBL_NAMESPACE_URI, type, true, false, e);
        elt.dispatchEvent(evt);
    }

    /**
     * Clones a template element for use as a shadow tree.
     */
    protected XBLOMShadowTreeElement cloneTemplate
            (XBLOMTemplateElement template) {
        XBLOMShadowTreeElement clone =
            (XBLOMShadowTreeElement)
            template.getOwnerDocument().createElementNS(XBL_NAMESPACE_URI,
                                                        XBL_SHADOW_TREE_TAG);
        NamedNodeMap attrs = template.getAttributes();
        for (int i = 0; i < attrs.getLength(); i++) {
            Attr attr = (Attr) attrs.item(i);
            if (attr instanceof AbstractAttrNS) {
                clone.setAttributeNodeNS(attr);
            } else {
                clone.setAttributeNode(attr);
            }
        }
        for (Node n = template.getFirstChild();
                n != null;
                n = n.getNextSibling()) {
            clone.appendChild(n.cloneNode(true));
        }
        return clone;
    }

    /**
     * Get the parent of a node in the fully flattened tree.
     */
    public Node getXblParentNode(Node n) {
        Node contentElement = getXblContentElement(n);
        Node parent = contentElement == null
                        ? n.getParentNode()
                        : contentElement.getParentNode();
        if (parent instanceof XBLOMContentElement) {
            parent = parent.getParentNode();
        }
        if (parent instanceof XBLOMShadowTreeElement) {
            parent = getXblBoundElement(parent);
        }
        return parent;
    }

    /**
     * Get the list of child nodes of a node in the fully flattened tree.
     */
    public NodeList getXblChildNodes(Node n) {
        XBLRecord rec = getRecord(n);
        if (rec.childNodes == null) {
            rec.childNodes = new XblChildNodes(rec);
        }
        return rec.childNodes;
    }

    /**
     * Get the list of child nodes of a node in the fully flattened tree
     * that are within the same shadow scope.
     */
    public NodeList getXblScopedChildNodes(Node n) {
        XBLRecord rec = getRecord(n);
        if (rec.scopedChildNodes == null) {
            rec.scopedChildNodes = new XblScopedChildNodes(rec);
        }
        return rec.scopedChildNodes;
    }

    /**
     * Get the first child node of a node in the fully flattened tree.
     */
    public Node getXblFirstChild(Node n) {
        NodeList nl = getXblChildNodes(n);
        return nl.item(0);
    }

    /**
     * Get the last child node of a node in the fully flattened tree.
     */
    public Node getXblLastChild(Node n) {
        NodeList nl = getXblChildNodes(n);
        return nl.item(nl.getLength() - 1);
    }

    /**
     * Get the node which directly precedes a node in the xblParentNode's
     * xblChildNodes list.
     */
    public Node getXblPreviousSibling(Node n) {
        Node p = getXblParentNode(n);
        if (p == null || getRecord(p).childNodes == null) {
            return n.getPreviousSibling();
        }
        XBLRecord rec = getRecord(n);
        if (!rec.linksValid) {
            updateLinks(n);
        }
        return rec.previousSibling;
    }

    /**
     * Get the node which directly follows a node in the xblParentNode's
     * xblChildNodes list.
     */
    public Node getXblNextSibling(Node n) {
        Node p = getXblParentNode(n);
        if (p == null || getRecord(p).childNodes == null) {
            return n.getNextSibling();
        }
        XBLRecord rec = getRecord(n);
        if (!rec.linksValid) {
            updateLinks(n);
        }
        return rec.nextSibling;
    }

    /**
     * Get the first element child of a node in the fully flattened tree.
     */
    public Element getXblFirstElementChild(Node n) {
        n = getXblFirstChild(n);
        while (n != null && n.getNodeType() != Node.ELEMENT_NODE) {
            n = getXblNextSibling(n);
        }
        return (Element) n;
    }

    /**
     * Get the last element child of a node in the fully flattened tree.
     */
    public Element getXblLastElementChild(Node n) {
        n = getXblLastChild(n);
        while (n != null && n.getNodeType() != Node.ELEMENT_NODE) {
            n = getXblPreviousSibling(n);
        }
        return (Element) n;
    }

    /**
     * Get the first element that precedes the a node in the
     * xblParentNode's xblChildNodes list.
     */
    public Element getXblPreviousElementSibling(Node n) {
        do {
            n = getXblPreviousSibling(n);
        } while (n != null && n.getNodeType() != Node.ELEMENT_NODE);
        return (Element) n;
    }

    /**
     * Get the first element that follows a node in the
     * xblParentNode's xblChildNodes list.
     */
    public Element getXblNextElementSibling(Node n) {
        do {
            n = getXblNextSibling(n);
        } while (n != null && n.getNodeType() != Node.ELEMENT_NODE);
        return (Element) n;
    }

    /**
     * Get the bound element whose shadow tree a node resides in.
     */
    public Element getXblBoundElement(Node n) {
        while (n != null && !(n instanceof XBLShadowTreeElement)) {
            XBLOMContentElement content = getXblContentElement(n);
            if (content != null) {
                n = content;
            }
            n = n.getParentNode();
        }
        if (n == null) {
            return null;
        }
        return getRecord(n).boundElement;
    }

    /**
     * Get the shadow tree of a node.
     */
    public Element getXblShadowTree(Node n) {
        if (n instanceof BindableElement) {
            BindableElement elt = (BindableElement) n;
            return elt.getShadowTree();
        }
        return null;
    }

    /**
     * Get the xbl:definition elements currently binding an element.
     */
    public NodeList getXblDefinitions(Node n) {
        final String namespaceURI = n.getNamespaceURI();
        final String localName = n.getLocalName();
        return new NodeList() {
            public Node item(int i) {
                TreeSet defs = (TreeSet) definitionLists.get(namespaceURI, localName);
                if (defs != null && defs.size() != 0 && i == 0) {
                    DefinitionRecord defRec = (DefinitionRecord) defs.first();
                    return defRec.definition;
                }
                return null;
            }
            public int getLength() {
                Set defs = (TreeSet) definitionLists.get(namespaceURI, localName);
                return defs != null && defs.size() != 0 ? 1 : 0;
            }
        };
    }

    /**
     * Returns the XBL record for the given node.
     */
    protected XBLRecord getRecord(Node n) {
        XBLManagerData xmd = (XBLManagerData) n;
        XBLRecord rec = (XBLRecord) xmd.getManagerData();
        if (rec == null) {
            rec = new XBLRecord();
            rec.node = n;
            xmd.setManagerData(rec);
        }
        return rec;
    }

    /**
     * Updates the xblPreviousSibling and xblNextSibling properties of the
     * given XBL node.
     */
    protected void updateLinks(Node n) {
        XBLRecord rec = getRecord(n);
        rec.previousSibling = null;
        rec.nextSibling = null;
        rec.linksValid = true;
        Node p = getXblParentNode(n);
        if (p != null) {
            NodeList xcn = getXblChildNodes(p);
            if (xcn instanceof XblChildNodes) {
                ((XblChildNodes) xcn).update();
            }
        }
    }

    /**
     * Returns the content element that caused the given node to be
     * present in the flattened tree.
     */
    public XBLOMContentElement getXblContentElement(Node n) {
        return getRecord(n).contentElement;
    }

    /**
     * Determines the number of nodes events should bubble if the
     * mouse pointer has moved from one element to another.
     * @param from the element from which the mouse pointer moved
     * @param to   the element to which the mouse pointer moved
     */
    public static int computeBubbleLimit(Node from, Node to) {
        ArrayList fromList = new ArrayList(10);
        ArrayList toList = new ArrayList(10);
        while (from != null) {
            fromList.add(from);
            from = ((NodeXBL) from).getXblParentNode();
        }
        while (to != null) {
            toList.add(to);
            to = ((NodeXBL) to).getXblParentNode();
        }
        int fromSize = fromList.size();
        int toSize = toList.size();
        for (int i = 0; i < fromSize && i < toSize; i++) {
            Node n1 = (Node) fromList.get(fromSize - i - 1);
            Node n2 = (Node) toList.get(toSize - i - 1);
            if (n1 != n2) {
                Node prevBoundElement = ((NodeXBL) n1).getXblBoundElement();
                while (i > 0 && prevBoundElement != fromList.get(fromSize - i - 1)) {
                    i--;
                }
                return fromSize - i - 1;
            }
        }
        return 1;
    }

    /**
     * Returns the ContentManager that handles the shadow tree the given
     * node resides in.
     */
    public ContentManager getContentManager(Node n) {
        Node b = getXblBoundElement(n);
        if (b != null) {
            Element s = getXblShadowTree(b);
            if (s != null) {
                ContentManager cm;
                Document doc = b.getOwnerDocument();
                if (doc != document) {
                    DefaultXBLManager xm = (DefaultXBLManager)
                        ((AbstractDocument) doc).getXBLManager();
                    cm = (ContentManager) xm.contentManagers.get(s);
                } else {
                    cm = (ContentManager) contentManagers.get(s);
                }
                return cm;
            }
        }
        return null;
    }

    /**
     * Records the ContentManager that handles the given shadow tree.
     */
    void setContentManager(Element shadow, ContentManager cm) {
        if (cm == null) {
            contentManagers.remove(shadow);
        } else {
            contentManagers.put(shadow, cm);
        }
    }

    /**
     * Mark the xblChildNodes and xblScopedChildNodes variables
     * as invalid.
     */
    public void invalidateChildNodes(Node n) {
        XBLRecord rec = getRecord(n);
        if (rec.childNodes != null) {
            rec.childNodes.invalidate();
        }
        if (rec.scopedChildNodes != null) {
            rec.scopedChildNodes.invalidate();
        }
    }

    /**
     * Adds the specified ContentSelectionChangedListener to the
     * global listener list.
     */
    public void addContentSelectionChangedListener
            (ContentSelectionChangedListener l) {
        contentSelectionChangedListenerList.add
            (ContentSelectionChangedListener.class, l);
    }

    /**
     * Removes the specified ContentSelectionChangedListener from the
     * global listener list.
     */
    public void removeContentSelectionChangedListener
            (ContentSelectionChangedListener l) {
        contentSelectionChangedListenerList.remove
            (ContentSelectionChangedListener.class, l);
    }

    /**
     * Returns an array of the gloabl ContentSelectionChangedListeners.
     */
    protected Object[] getContentSelectionChangedListeners() {
        return contentSelectionChangedListenerList.getListenerList();
    }

    /**
     * Called by the ContentManager of a shadow tree to indicate some
     * selected nodes have changed.
     */
    void shadowTreeSelectedContentChanged(Set deselected, Set selected) {
        Iterator i = deselected.iterator();
        while (i.hasNext()) {
            Node n = (Node) i.next();
            if (n.getNodeType() == Node.ELEMENT_NODE) {
                unbind((Element) n);
            }
        }
        i = selected.iterator();
        while (i.hasNext()) {
            Node n = (Node) i.next();
            if (n.getNodeType() == Node.ELEMENT_NODE) {
                bind((Element) n);
            }
        }
    }

    /**
     * Adds the specified BindingListener to the global listener list.
     */
    public void addBindingListener(BindingListener l) {
        bindingListenerList.add(BindingListener.class, l);
    }

    /**
     * Removes the specified BindingListener from the global listener list.
     */
    public void removeBindingListener(BindingListener l) {
        bindingListenerList.remove(BindingListener.class, l);
    }

    /**
     * Dispatches a BindingEvent the registered listeners.
     * @param bindableElement the bindable element whose binding has changed
     * @param shadowTree the new shadow tree of the bindable element
     */
    protected void dispatchBindingChangedEvent(Element bindableElement,
                                               Element shadowTree) {
        Object[] ls = bindingListenerList.getListenerList();
        for (int i = ls.length - 2; i >= 0; i -= 2) {
            BindingListener l = (BindingListener) ls[i + 1];
            l.bindingChanged(bindableElement, shadowTree);
        }
    }

    /**
     * Returns whether the given definition element is the active one
     * for its element name.
     */
    protected boolean isActiveDefinition(XBLOMDefinitionElement def,
                                         Element imp) {
        DefinitionRecord defRec = (DefinitionRecord) definitions.get(def, imp);
        if (defRec == null) {
            return false;
        }
        return defRec == getActiveDefinition(defRec.namespaceURI,
                                             defRec.localName);
    }

    /**
     * Record class for storing information about an XBL definition.
     */
    protected class DefinitionRecord implements Comparable {

        /**
         * The namespace URI.
         */
        public String namespaceURI;

        /**
         * The local name.
         */
        public String localName;

        /**
         * The definition element.
         */
        public XBLOMDefinitionElement definition;

        /**
         * The template element for this definition.
         */
        public XBLOMTemplateElement template;

        /**
         * The import element that imported this definition.
         */
        public Element importElement;

        /**
         * Creates a new DefinitionRecord.
         */
        public DefinitionRecord(String ns,
                                String ln,
                                XBLOMDefinitionElement def,
                                XBLOMTemplateElement t,
                                Element imp) {
            namespaceURI = ns;
            localName = ln;
            definition = def;
            template = t;
            importElement = imp;
        }

        /**
         * Returns whether two definition records are the same.
         */
        public boolean equals(Object other) {
            return compareTo(other) == 0;
        }

        /**
         * Compares two definition records.
         */
        public int compareTo(Object other) {
            DefinitionRecord rec = (DefinitionRecord) other;
            AbstractNode n1, n2;
            if (importElement == null) {
                n1 = definition;
                if (rec.importElement == null) {
                    n2 = rec.definition;
                } else {
                    n2 = (AbstractNode) rec.importElement;
                }
            } else if (rec.importElement == null) {
                n1 = (AbstractNode) importElement;
                n2 = rec.definition;
            } else if (definition.getOwnerDocument()
                        == rec.definition.getOwnerDocument()) {
                n1 = definition;
                n2 = rec.definition;
            } else {
                n1 = (AbstractNode) importElement;
                n2 = (AbstractNode) rec.importElement;
            }
            short comp = n1.compareDocumentPosition(n2);
            if ((comp & AbstractNode.DOCUMENT_POSITION_PRECEDING) != 0) {
                return -1;
            }
            if ((comp & AbstractNode.DOCUMENT_POSITION_FOLLOWING) != 0) {
                return 1;
            }
            return 0;
        }
    }

    /**
     * Record class for storing information about an XBL import.
     */
    protected class ImportRecord {

        /**
         * The import element.
         */
        public Element importElement;

        /**
         * The imported tree.
         */
        public Node node;

        /**
         * The DOM node inserted listener for definitions accessed through
         * this import.
         */
        public DefNodeInsertedListener defNodeInsertedListener;

        /**
         * The DOM node removed listener for definitions accessed through
         * this import.
         */
        public DefNodeRemovedListener defNodeRemovedListener;

        /**
         * The DOM attribute mutation listener for definitions accessed through
         * this import.
         */
        public DefAttrListener defAttrListener;

        /**
         * The DOM node inserted listener for the imported tree.
         */
        public ImportInsertedListener importInsertedListener;

        /**
         * The DOM node removed listener for the imported tree.
         */
        public ImportRemovedListener importRemovedListener;

        /**
         * The DOM subtree modified listener for the imported tree.
         */
        public ImportSubtreeListener importSubtreeListener;

        /**
         * The DOM subtree modified listener for templates of definitions
         * accessed through this import.
         */
        public TemplateMutationListener templateMutationListener;

        /**
         * Creates a new ImportRecord.
         */
        public ImportRecord(Element imp, Node n) {
            importElement = imp;
            node = n;
            defNodeInsertedListener = new DefNodeInsertedListener(imp);
            defNodeRemovedListener = new DefNodeRemovedListener(imp);
            defAttrListener = new DefAttrListener(imp);
            importInsertedListener = new ImportInsertedListener(imp);
            importRemovedListener = new ImportRemovedListener();
            importSubtreeListener
                = new ImportSubtreeListener(imp, importRemovedListener);
            templateMutationListener = new TemplateMutationListener(imp);
        }
    }

    /**
     * DOM node inserted listener for imported XBL trees.
     */
    protected class ImportInsertedListener implements EventListener {

        /**
         * The import element.
         */
        protected Element importElement;

        /**
         * Creates a new ImportInsertedListener.
         */
        public ImportInsertedListener(Element importElement) {
            this.importElement = importElement;
        }

        /**
         * Handles the event.
         */
        public void handleEvent(Event evt) {
            EventTarget target = evt.getTarget();
            if (target instanceof XBLOMDefinitionElement) {
                XBLOMDefinitionElement def = (XBLOMDefinitionElement) target;
                addDefinition(def.getElementNamespaceURI(),
                              def.getElementLocalName(),
                              def,
                              importElement);
            }
        }
    }

    /**
     * DOM node removed listener for imported XBL trees.
     */
    protected class ImportRemovedListener implements EventListener {

        /**
         * List of definition elements to be removed from the document.
         */
        protected LinkedList toBeRemoved = new LinkedList();

        /**
         * Handles the event.
         */
        public void handleEvent(Event evt) {
            toBeRemoved.add(evt.getTarget());
        }
    }

    /**
     * DOM subtree listener for imported XBL trees.
     */
    protected class ImportSubtreeListener implements EventListener {

        /**
         * The import element.
         */
        protected Element importElement;

        /**
         * The ImportedRemovedListener to check for to-be-removed definitions.
         */
        protected ImportRemovedListener importRemovedListener;

        /**
         * Creates a new ImportSubtreeListener.
         */
        public ImportSubtreeListener(Element imp,
                                     ImportRemovedListener irl) {
            importElement = imp;
            importRemovedListener = irl;
        }

        /**
         * Handles the event.
         */
        public void handleEvent(Event evt) {
            Object[] defs = importRemovedListener.toBeRemoved.toArray();
            importRemovedListener.toBeRemoved.clear();
            for (int i = 0; i < defs.length; i++) {
                XBLOMDefinitionElement def = (XBLOMDefinitionElement) defs[i];
                DefinitionRecord defRec
                    = (DefinitionRecord) definitions.get(def, importElement);
                removeDefinition(defRec);
            }
        }
    }

    /**
     * DOM node inserted listener for the document.
     */
    protected class DocInsertedListener implements EventListener {

        /**
         * Handles the event.
         */
        public void handleEvent(Event evt) {
            EventTarget target = evt.getTarget();
            if (target instanceof XBLOMDefinitionElement) {
                // only handle definition elements in document-level scope
                if (getXblBoundElement((Node) target) == null) {       // ??? suspect cast ???
                    XBLOMDefinitionElement def
                        = (XBLOMDefinitionElement) target;
                    if (def.getAttributeNS(null, XBL_REF_ATTRIBUTE).length()
                            == 0) {
                        addDefinition(def.getElementNamespaceURI(),
                                      def.getElementLocalName(),
                                      def,
                                      null);
                    } else {
                        addDefinitionRef(def);
                    }
                }
            } else if (target instanceof XBLOMImportElement) {
                // only handle import elements in document-level scope
                if (getXblBoundElement((Node) target) == null) {      // ??? suspect cast ???
                    addImport((Element) target);
                }
            } else {
                evt = XBLEventSupport.getUltimateOriginalEvent(evt);
                target = evt.getTarget();
                Node parent = getXblParentNode((Node) target);
                if (parent != null) {
                    invalidateChildNodes(parent);
                }
                if (target instanceof BindableElement) {
                    // Only bind it if it's not the descendent of a bound
                    // element.  If it is, and this new element will be
                    // selected by an xbl:content element in the shadow tree,
                    // the ContentManager will bind it.
                    for (Node n = ((Node) target).getParentNode();
                            n != null;
                            n = n.getParentNode()) {
                        if (n instanceof BindableElement
                                && getRecord(n).definitionElement != null) {
                            return;
                        }
                    }
                    bind((Element) target);
                }
            }
        }
    }

    /**
     * DOM node removed listener for the document.
     */
    protected class DocRemovedListener implements EventListener {

        /**
         * List of definition elements to be removed from the document.
         */
        protected LinkedList defsToBeRemoved = new LinkedList();

        /**
         * List of import elements to be removed from the document.
         */
        protected LinkedList importsToBeRemoved = new LinkedList();

        /**
         * List of nodes to have their XBL child lists invalidated.
         */
        protected LinkedList nodesToBeInvalidated = new LinkedList();

        /**
         * Handles the event.
         */
        public void handleEvent(Event evt) {
            EventTarget target = evt.getTarget();
            if (target instanceof XBLOMDefinitionElement) {
                // only handle definition elements in document-level scope
                if (getXblBoundElement((Node) target) == null) {
                    defsToBeRemoved.add(target);
                }
            } else if (target instanceof XBLOMImportElement) {
                // only handle import elements in document-level scope
                if (getXblBoundElement((Node) target) == null) {
                    importsToBeRemoved.add(target);
                }
            }

            Node parent = getXblParentNode((Node) target);
            if (parent != null) {
                nodesToBeInvalidated.add(parent);
            }
        }
    }

    /**
     * DOM subtree mutation listener for the document.
     */
    protected class DocSubtreeListener implements EventListener {

        /**
         * Handles the event.
         */
        public void handleEvent(Event evt) {
            Object[] defs = docRemovedListener.defsToBeRemoved.toArray();
            docRemovedListener.defsToBeRemoved.clear();
            for (int i = 0; i < defs.length; i++) {
                XBLOMDefinitionElement def = (XBLOMDefinitionElement) defs[i];
                if (def.getAttributeNS(null, XBL_REF_ATTRIBUTE).length() == 0) {
                    DefinitionRecord defRec
                        = (DefinitionRecord) definitions.get(def, null);
                    removeDefinition(defRec);
                } else {
                    removeDefinitionRef(def);
                }
            }

            Object[] imps = docRemovedListener.importsToBeRemoved.toArray();
            docRemovedListener.importsToBeRemoved.clear();
            for (int i = 0; i < imps.length; i++) {
                removeImport((Element) imps[i]);
            }

            Object[] nodes = docRemovedListener.nodesToBeInvalidated.toArray();
            docRemovedListener.nodesToBeInvalidated.clear();
            for (int i = 0; i < nodes.length; i++) {
                invalidateChildNodes((Node) nodes[i]);
            }
        }
    }

    /**
     * DOM mutation listener for template elements.
     */
    protected class TemplateMutationListener implements EventListener {

        /**
         * The import element.
         */
        protected Element importElement;

        /**
         * Creates a new TemplateMutationListener.
         */
        public TemplateMutationListener(Element imp) {
            importElement = imp;
        }

        /**
         * Handles the event.
         */
        public void handleEvent(Event evt) {
            Node n = (Node) evt.getTarget();
            while (n != null && !(n instanceof XBLOMDefinitionElement)) {
                n = n.getParentNode();
            }

            DefinitionRecord defRec
                = (DefinitionRecord) definitions.get(n, importElement);
            if (defRec == null) {
                return;
            }

            rebind(defRec.namespaceURI, defRec.localName,
                   document.getDocumentElement());
        }
    }

    /**
     * DOM attribute mutation listener for definition elements.
     */
    protected class DefAttrListener implements EventListener {

        /**
         * The import element.
         */
        protected Element importElement;

        /**
         * Creates a new DefAttrListener.
         */
        public DefAttrListener(Element imp) {
            importElement = imp;
        }

        /**
         * Handles the event.
         */
        public void handleEvent(Event evt) {
            EventTarget target = evt.getTarget();
            if (!(target instanceof XBLOMDefinitionElement)) {
                return;
            }

            XBLOMDefinitionElement def = (XBLOMDefinitionElement) target;
            if (!isActiveDefinition(def, importElement)) {
                return;
            }

            MutationEvent mevt = (MutationEvent) evt;
            String attrName = mevt.getAttrName();
            if (attrName.equals(XBL_ELEMENT_ATTRIBUTE)) {
                DefinitionRecord defRec =
                    (DefinitionRecord) definitions.get(def, importElement);
                removeDefinition(defRec);

                addDefinition(def.getElementNamespaceURI(),
                              def.getElementLocalName(),
                              def,
                              importElement);
            } else if (attrName.equals(XBL_REF_ATTRIBUTE)) {
                if (mevt.getNewValue().length() != 0) {
                    DefinitionRecord defRec =
                        (DefinitionRecord) definitions.get(def, importElement);
                    removeDefinition(defRec);
                    addDefinitionRef(def);
                }
            }
        }
    }

    /**
     * DOM node inserted listener for definition elements.
     */
    protected class DefNodeInsertedListener implements EventListener {

        /**
         * The import element.
         */
        protected Element importElement;

        /**
         * Creates a new DefNodeInsertedListener.
         */
        public DefNodeInsertedListener(Element imp) {
            importElement = imp;
        }

        /**
         * Handles the event.
         */
        public void handleEvent(Event evt) {
            MutationEvent mevt = (MutationEvent) evt;
            Node parent = mevt.getRelatedNode();
            if (!(parent instanceof XBLOMDefinitionElement)) {
                return;
            }

            EventTarget target = evt.getTarget();
            if (!(target instanceof XBLOMTemplateElement)) {
                return;
            }
            XBLOMTemplateElement template = (XBLOMTemplateElement) target;

            DefinitionRecord defRec
                = (DefinitionRecord) definitions.get(parent, importElement);
            if (defRec == null) {
                return;
            }

            ImportRecord ir = (ImportRecord) imports.get(importElement);

            if (defRec.template != null) {
                for (Node n = parent.getFirstChild();
                        n != null;
                        n = n.getNextSibling()) {
                    if (n == template) {
                        removeTemplateElementListeners(defRec.template, ir);
                        defRec.template = template;
                        break;
                    } else if (n == defRec.template) {
                        return;
                    }
                }
            } else {
                defRec.template = template;
            }
            addTemplateElementListeners(template, ir);
            rebind(defRec.namespaceURI, defRec.localName,
                   document.getDocumentElement());
        }
    }

    /**
     * DOM node removed listener for definition elements.
     */
    protected class DefNodeRemovedListener implements EventListener {

        /**
         * The import element.
         */
        protected Element importElement;

        /**
         * Creates a new DefNodeRemovedListener.
         */
        public DefNodeRemovedListener(Element imp) {
            importElement = imp;
        }

        /**
         * Handles the event.
         */
        public void handleEvent(Event evt) {
            MutationEvent mevt = (MutationEvent) evt;
            Node parent = mevt.getRelatedNode();
            if (!(parent instanceof XBLOMDefinitionElement)) {
                return;
            }

            EventTarget target = evt.getTarget();
            if (!(target instanceof XBLOMTemplateElement)) {
                return;
            }
            XBLOMTemplateElement template = (XBLOMTemplateElement) target;

            DefinitionRecord defRec
                = (DefinitionRecord) definitions.get(parent, importElement);
            if (defRec == null || defRec.template != template) {
                return;
            }

            ImportRecord ir = (ImportRecord) imports.get(importElement);

            removeTemplateElementListeners(template, ir);
            defRec.template = null;

            for (Node n = template.getNextSibling();
                    n != null;
                    n = n.getNextSibling()) {
                if (n instanceof XBLOMTemplateElement) {
                    defRec.template = (XBLOMTemplateElement) n;
                    break;
                }
            }

            addTemplateElementListeners(defRec.template, ir);
            rebind(defRec.namespaceURI, defRec.localName,
                   document.getDocumentElement());
        }
    }

    /**
     * DOM attribute mutation listener for import elements.
     */
    protected class ImportAttrListener implements EventListener {

        /**
         * Handles the event.
         */
        public void handleEvent(Event evt) {
            EventTarget target = evt.getTarget();
            if (target != evt.getCurrentTarget()) {
                return;
            }

            MutationEvent mevt = (MutationEvent) evt;
            if (mevt.getAttrName().equals(XBL_BINDINGS_ATTRIBUTE)) {
                Element imp = (Element) target;
                removeImport(imp);
                addImport(imp);
            }
        }
    }

    /**
     * DOM attribute mutation listener for referencing definition elements.
     */
    protected class RefAttrListener implements EventListener {

        /**
         * Handles the event.
         */
        public void handleEvent(Event evt) {
            EventTarget target = evt.getTarget();
            if (target != evt.getCurrentTarget()) {
                return;
            }

            MutationEvent mevt = (MutationEvent) evt;
            if (mevt.getAttrName().equals(XBL_REF_ATTRIBUTE)) {
                Element defRef = (Element) target;
                removeDefinitionRef(defRef);
                if (mevt.getNewValue().length() == 0) {
                    XBLOMDefinitionElement def
                        = (XBLOMDefinitionElement) defRef;
                    String ns = def.getElementNamespaceURI();
                    String ln = def.getElementLocalName();
                    addDefinition(ns, ln,
                                  (XBLOMDefinitionElement) defRef, null);
                } else {
                    addDefinitionRef(defRef);
                }
            }
        }
    }

    /**
     * XBL record.
     */
    protected class XBLRecord {

        /**
         * The node.
         */
        public Node node;

        /**
         * The xblChildNodes NodeList for this node.
         */
        public XblChildNodes childNodes;

        /**
         * The xblScopedChildNodes NodeList for this node.
         */
        public XblScopedChildNodes scopedChildNodes;

        /**
         * The content element which caused this node to appear in the
         * flattened tree.
         */
        public XBLOMContentElement contentElement;

        /**
         * The definition element that applies to this element.
         */
        public XBLOMDefinitionElement definitionElement;

        /**
         * The bound element that owns this shadow tree, if this node
         * is an XBLOMShadowTreeElement.
         */
        public BindableElement boundElement;

        /**
         * Whether the next/previous links are valid.
         */
        public boolean linksValid;

        /**
         * The following sibling in the flattened tree.
         */
        public Node nextSibling;

        /**
         * The previous sibling in the flattened tree.
         */
        public Node previousSibling;
    }

    /**
     * To iterate over the XBL child nodes.
     */
    protected class XblChildNodes implements NodeList {

        /**
         * The XBLRecord.
         */
        protected XBLRecord record;

        /**
         * The nodes.
         */
        protected List nodes;

        /**
         * The number of nodes.
         */
        protected int size;

        /**
         * Creates a new XblChildNodes.
         */
        public XblChildNodes(XBLRecord rec) {
            record = rec;
            nodes = new ArrayList();
            size = -1;
        }

        /**
         * Update the NodeList.
         */
        protected void update() {
            size = 0;
            Node shadowTree = getXblShadowTree(record.node);
            Node last = null;
            Node m = shadowTree == null ? record.node.getFirstChild()
                                        : shadowTree.getFirstChild();
            while (m != null) {
                last = collectXblChildNodes(m, last);
                m = m.getNextSibling();
            }
            if (last != null) {
                XBLRecord rec = getRecord(last);
                rec.nextSibling = null;
                rec.linksValid = true;
            }
        }

        /**
         * Find the XBL child nodes of this element.
         */
        protected Node collectXblChildNodes(Node n, Node prev) {
            boolean isChild = false;
            if (n.getNodeType() == Node.ELEMENT_NODE) {
                if (!XBL_NAMESPACE_URI.equals(n.getNamespaceURI())) {
                    isChild = true;
                } else if (n instanceof XBLOMContentElement) {
                    ContentManager cm = getContentManager(n);
                    if (cm != null) {
                        NodeList selected =
                            cm.getSelectedContent((XBLOMContentElement) n);
                        for (int i = 0; i < selected.getLength(); i++) {
                            prev = collectXblChildNodes(selected.item(i),
                                                        prev);
                        }
                    }
                }
            } else {
                isChild = true;
            }
            if (isChild) {
                nodes.add(n);
                size++;
                if (prev != null) {
                    XBLRecord rec = getRecord(prev);
                    rec.nextSibling = n;
                    rec.linksValid = true;
                }
                XBLRecord rec = getRecord(n);
                rec.previousSibling = prev;
                rec.linksValid = true;
                prev = n;
            }
            return prev;
        }

        /**
         * Mark the xblNextSibling and xblPreviousSibling variables
         * on each node in the list as invalid, then invalidate the
         * NodeList.
         */
        public void invalidate() {
            for (int i = 0; i < size; i++) {
                XBLRecord rec = getRecord((Node) nodes.get(i));
                rec.previousSibling = null;
                rec.nextSibling = null;
                rec.linksValid = false;
            }
            nodes.clear();
            size = -1;
        }

        /**
         * Returns the first node in the list.
         */
        public Node getFirstNode() {
            if (size == -1) {
                update();
            }
            return size == 0 ? null : (Node) nodes.get(0);
        }

        /**
         * Returns the last node in the list.
         */
        public Node getLastNode() {
            if (size == -1) {
                update();
            }
            return size == 0 ? null : (Node) nodes.get( nodes.size() -1 );
        }

        /**
         * <b>DOM</b>: Implements {@link org.w3c.dom.NodeList#item(int)}.
         */
        public Node item(int index) {
            if (size == -1) {
                update();
            }
            if (index < 0 || index >= size) {
                return null;
            }
            return (Node) nodes.get(index);
        }

        /**
         * <b>DOM</b>: Implements {@link org.w3c.dom.NodeList#getLength()}.
         */
        public int getLength() {
            if (size == -1) {
                update();
            }
            return size;
        }
    }

    /**
     * To iterate over the scoped XBL child nodes.
     */
    protected class XblScopedChildNodes extends XblChildNodes {

        /**
         * Creates a new XblScopedChildNodes object.
         */
        public XblScopedChildNodes(XBLRecord rec) {
            super(rec);
        }

        /**
         * Update the NodeList.
         */
        protected void update() {
            size = 0;
            Node shadowTree = getXblShadowTree(record.node);
            Node n = shadowTree == null ? record.node.getFirstChild()
                                        : shadowTree.getFirstChild();
            while (n != null) {
                collectXblScopedChildNodes(n);
                n = n.getNextSibling();
            }
        }

        /**
         * Find the XBL child nodes of this element.
         */
        protected void collectXblScopedChildNodes(Node n) {
            boolean isChild = false;
            if (n.getNodeType() == Node.ELEMENT_NODE) {
                if (!n.getNamespaceURI().equals(XBL_NAMESPACE_URI)) {
                    isChild = true;
                } else if (n instanceof XBLOMContentElement) {
                    ContentManager cm = getContentManager(n);
                    if (cm != null) {
                        NodeList selected =
                            cm.getSelectedContent((XBLOMContentElement) n);
                        for (int i = 0; i < selected.getLength(); i++) {
                            collectXblScopedChildNodes(selected.item(i));
                        }
                    }
                }
            } else {
                isChild = true;
            }
            if (isChild) {
                nodes.add(n);
                size++;
            }
        }
    }
}
