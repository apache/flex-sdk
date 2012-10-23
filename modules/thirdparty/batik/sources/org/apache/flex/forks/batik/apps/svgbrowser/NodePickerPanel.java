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
package org.apache.flex.forks.batik.apps.svgbrowser;

import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.Frame;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.FocusAdapter;
import java.awt.event.FocusEvent;
import java.io.IOException;
import java.io.StringReader;
import java.util.EventListener;
import java.util.EventObject;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.ResourceBundle;
import java.util.Vector;

import javax.swing.AbstractAction;
import javax.swing.Action;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.JTextField;
import javax.swing.SwingUtilities;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.event.EventListenerList;
import javax.swing.event.TableModelEvent;
import javax.swing.event.TableModelListener;
import javax.swing.table.DefaultTableModel;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.apache.flex.forks.batik.dom.AbstractNode;
import org.apache.flex.forks.batik.dom.util.DOMUtilities;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.apache.flex.forks.batik.util.gui.resource.ActionMap;
import org.apache.flex.forks.batik.util.gui.resource.ButtonFactory;
import org.apache.flex.forks.batik.util.gui.resource.MissingListenerException;
import org.apache.flex.forks.batik.util.gui.xmleditor.XMLTextEditor;
import org.apache.flex.forks.batik.util.XMLConstants;
import org.apache.flex.forks.batik.util.resources.ResourceManager;

import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;

import org.xml.sax.ErrorHandler;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

/**
 * Used to preview and edit nodes.
 */
public class NodePickerPanel extends JPanel implements ActionMap {


     // The NodePickerPanel modes of work
    /**
     * View only. Inspects the associated node.
     */
    private static final int VIEW_MODE = 1;

    /**
     * Edit mode. Used for editing the associated node.
     */
    private static final int EDIT_MODE = 2;

    /**
     * Creates new element while in this mode.
     */
    private static final int ADD_NEW_ELEMENT = 3;

    /**
     * The resource file name.
     */
    private static final String RESOURCES =
        "org.apache.flex.forks.batik.apps.svgbrowser.resources.NodePickerPanelMessages";

    /**
     * The resource bundle.
     */
    private static ResourceBundle bundle;

    /**
     * The resource manager.
     */
    private static ResourceManager resources;
    static {
        bundle = ResourceBundle.getBundle(RESOURCES, Locale.getDefault());
        resources = new ResourceManager(bundle);
    }

    /**
     * The attributes table - the table that consists of attribute name and
     * attribute value columns. Shows the element's attributes.
     */
    private JTable attributesTable;

    /**
     * The Attribute table model listener.
     */
    private TableModelListener tableModelListener;

    /**
     * The Attributes table ScrollPane.
     */
    private JScrollPane attributePane;

    /**
     * The Attributes table and buttons Panel.
     */
    private JPanel attributesPanel;

    /**
     * The Button factory.
     */
    private ButtonFactory buttonFactory;

    /**
     * The Add button.
     */
    private JButton addButton;

    /**
     * The Remove button.
     */
    private JButton removeButton;

    /**
     * The Attributes table label.
     */
    private JLabel attributesLabel;

    /**
     * The Apply button.
     */
    private JButton applyButton;

    /**
     * The Reset button.
     */
    private JButton resetButton;

    /**
     * The OK and Cancel button Panel.
     */
    private JPanel choosePanel;

    /**
     * The svg input panel.
     */
    private SVGInputPanel svgInputPanel;

    /**
     * The isWellFormed label.
     */
    private JLabel isWellFormedLabel;

    /**
     * The svgInputPanel name label.
     */
    private JLabel svgInputPanelNameLabel;

    /**
     * If the attribute table listener should process the update event and
     * update node picker after an update on the table had triggered. Used
     * instead of removing and adding the table listener.
     */
    private boolean shouldProcessUpdate = true;

    /**
     * The element that is being previewed or edited it's content (xml
     * representation).
     */
    private Element previewElement;

    /**
     * The copy of the original (preview) element. Used to synchronize svginput
     * area and the attributes table, since the original elements attributes
     * shouldn't be changed while previewing or editing it.
     */
    private Element clonedElement;

    /**
     * The parent Element for the element to be added. It is used when adding
     * the new element, to get the information on where to be appended.
     */
    private Node parentElement;

    /**
     * The panel mode.
     */
    private int mode;

    /**
     * If the element being edited is actually changed.
     */
    private boolean isDirty;

    /**
     * Listeners list.
     */
    private EventListenerList eventListeners =
        new EventListenerList();

    /**
     * The controller for this panel.
     */
    private NodePickerController controller;

    /**
     * The map that contains the listeners
     */
    private Map listeners = new HashMap(10);

    /**
     * Constructor.
     *
     * @param controller
     *            The node picker panel controller
     */
    public NodePickerPanel(NodePickerController controller) {
        super(new GridBagLayout());
        this.controller = controller;
        initialize();
    }

    /**
     * Initalizes this panel.
     */
    private void initialize() {
        // Associate buttons with the actions
        addButtonActions();

        // Add components
        GridBagConstraints grid = new GridBagConstraints();
        grid.gridx = 1;
        grid.gridy = 1;
        grid.anchor = GridBagConstraints.NORTHWEST;
        grid.fill = GridBagConstraints.NONE;
        grid.insets = new Insets(5, 5, 0, 5);
        attributesLabel = new JLabel();
        String attributesLabelValue = resources
                .getString("AttributesTable.name");
        attributesLabel.setText(attributesLabelValue);
        this.add(attributesLabel, grid);

        grid.gridx = 1;
        grid.gridy = 2;
        grid.gridwidth = 2;
        grid.weightx = 1.0;
        grid.weighty = 0.3;
        grid.fill = GridBagConstraints.BOTH;
        grid.anchor = GridBagConstraints.CENTER;
        grid.insets = new Insets(0, 0, 0, 5);
        this.add(getAttributesPanel(), grid);

        grid.weightx = 0;
        grid.weighty = 0;
        grid.gridwidth = 1;
        grid.gridx = 1;
        grid.gridy = 3;
        grid.anchor = GridBagConstraints.NORTHWEST;
        grid.fill = GridBagConstraints.NONE;
        grid.insets = new Insets(0, 5, 0, 5);
        svgInputPanelNameLabel = new JLabel();
        String svgInputLabelValue = resources.getString("InputPanelLabel.name");
        svgInputPanelNameLabel.setText(svgInputLabelValue);
        this.add(svgInputPanelNameLabel, grid);

        grid.gridx = 1;
        grid.gridy = 4;
        grid.gridwidth = 2;
        grid.weightx = 1.0;
        grid.weighty = 1.0;
        grid.fill = GridBagConstraints.BOTH;
        grid.anchor = GridBagConstraints.CENTER;
        grid.insets = new Insets(0, 5, 0, 10);
        this.add(getSvgInputPanel(), grid);

        grid.weightx = 0;
        grid.weighty = 0;
        grid.gridwidth = 1;
        grid.gridx = 1;
        grid.gridy = 5;
        grid.anchor = GridBagConstraints.NORTHWEST;
        grid.fill = GridBagConstraints.NONE;
        grid.insets = new Insets(5, 5, 0, 5);
        isWellFormedLabel = new JLabel();
        String isWellFormedLabelVal =
            resources.getString("IsWellFormedLabel.wellFormed");
        isWellFormedLabel.setText(isWellFormedLabelVal);
        this.add(isWellFormedLabel, grid);

        grid.weightx = 0;
        grid.weighty = 0;
        grid.gridwidth = 1;
        grid.gridx = 2;
        grid.gridy = 5;
        grid.anchor = GridBagConstraints.EAST;
        grid.insets = new Insets(0, 0, 0, 5);
        this.add(getChoosePanel(), grid);

        // Set the default mode
        enterViewMode();
    }

    /**
     * Gets buttonFactory.
     */
    private ButtonFactory getButtonFactory() {
        if (buttonFactory == null) {
            buttonFactory = new ButtonFactory(bundle, this);
        }
        return buttonFactory;
    }

    /**
     * Adds button actions.
     */
    private void addButtonActions() {
        listeners.put("ApplyButtonAction", new ApplyButtonAction());
        listeners.put("ResetButtonAction", new ResetButtonAction());
        listeners.put("AddButtonAction", new AddButtonAction());
        listeners.put("RemoveButtonAction", new RemoveButtonAction());
    }

    /**
     * Gets the Add button.
     */
    private JButton getAddButton() {
        if (addButton == null) {
            addButton = getButtonFactory().createJButton("AddButton");
            addButton.addFocusListener(new NodePickerEditListener());
        }
        return addButton;
    }

    /**
     * Gets the Remove button.
     */
    private JButton getRemoveButton() {
        if (removeButton == null) {
            removeButton = getButtonFactory().createJButton("RemoveButton");
            removeButton.addFocusListener(new NodePickerEditListener());
        }
        return removeButton;
    }

    /**
     * Gets the Apply button.
     */
    private JButton getApplyButton() {
        if (applyButton == null) {
            applyButton = getButtonFactory().createJButton("ApplyButton");
        }
        return applyButton;
    }

    /**
     * Gets the Reset sbutton.
     */
    private JButton getResetButton() {
        if (resetButton == null) {
            resetButton = getButtonFactory().createJButton("ResetButton");
        }
        return resetButton;
    }

    /**
     * Gets the attributesPanel.
     */
    private JPanel getAttributesPanel() {
        if (attributesPanel == null) {
            attributesPanel = new JPanel(new GridBagLayout());

            GridBagConstraints g11 = new GridBagConstraints();
            g11.gridx = 1;
            g11.gridy = 1;
            g11.fill = GridBagConstraints.BOTH;
            g11.anchor = GridBagConstraints.CENTER;
            g11.weightx = 4.0;
            g11.weighty = 1.0;
            g11.gridheight = 5;
            g11.gridwidth = 2;
            g11.insets = new Insets(5, 5, 5, 0);

            GridBagConstraints g12 = new GridBagConstraints();
            g12.gridx = 3;
            g12.gridy = 1;
            g12.fill = GridBagConstraints.HORIZONTAL;
            g12.anchor = GridBagConstraints.NORTH;
            g12.insets = new Insets(5, 20, 0, 5);
            g12.weightx = 1.0;

            GridBagConstraints g32 = new GridBagConstraints();
            g32.gridx = 3;
            g32.gridy = 3;
            g32.fill = GridBagConstraints.HORIZONTAL;
            g32.anchor = GridBagConstraints.NORTH;
            g32.insets = new Insets(5, 20, 0, 5);
            g32.weightx = 1.0;

            attributesTable = new JTable();
            attributesTable.setModel(new AttributesTableModel(10, 2));
            tableModelListener = new AttributesTableModelListener();
            attributesTable.getModel()
                    .addTableModelListener(tableModelListener);
            attributesTable.addFocusListener(new NodePickerEditListener());
            attributePane = new JScrollPane();
            attributePane.getViewport().add(attributesTable);

            attributesPanel.add(attributePane, g11);
            attributesPanel.add(getAddButton(), g12);
            attributesPanel.add(getRemoveButton(), g32);
        }
        return attributesPanel;
    }

    /**
     * Gets the svgInputPanel.
     */
    private SVGInputPanel getSvgInputPanel() {
        if (svgInputPanel == null) {
            svgInputPanel = new SVGInputPanel();
            svgInputPanel.getNodeXmlArea().getDocument().addDocumentListener
                (new XMLAreaListener());
            svgInputPanel.getNodeXmlArea().addFocusListener
                (new NodePickerEditListener());
        }
        return svgInputPanel;
    }

    /**
     * Gets the choosePanel.
     */
    private JPanel getChoosePanel() {
        if (choosePanel == null) {
            choosePanel = new JPanel(new GridBagLayout());

            GridBagConstraints g11 = new GridBagConstraints();
            g11.gridx = 1;
            g11.gridy = 1;
            g11.weightx = 0.5;
            g11.anchor = GridBagConstraints.WEST;
            g11.fill = GridBagConstraints.HORIZONTAL;
            g11.insets = new Insets(5, 5, 5, 5);

            GridBagConstraints g12 = new GridBagConstraints();
            g12.gridx = 2;
            g12.gridy = 1;
            g12.weightx = 0.5;
            g12.anchor = GridBagConstraints.EAST;
            g12.fill = GridBagConstraints.HORIZONTAL;
            g12.insets = new Insets(5, 5, 5, 5);

            choosePanel.add(getApplyButton(), g11);
            choosePanel.add(getResetButton(), g12);
        }
        return choosePanel;
    }

    /**
     * Gets the results of this node picker panel - gets the contents of the xml
     * text area.
     */
    public String getResults() {
        return getSvgInputPanel().getNodeXmlArea().getText();
    }

    /**
     * Update the components and the element after text is being inputted in the
     * xml text area.
     *
     * @param referentElement
     *            The updated element, referent element
     * @param elementToUpdate
     *            The element to update.
     */
    private void updateViewAfterSvgInput(Element referentElement,
            Element elementToUpdate) {
        if (referentElement != null) {
            String isWellFormedLabelVal =
                resources.getString("IsWellFormedLabel.wellFormed");
            isWellFormedLabel.setText(isWellFormedLabelVal);
            getApplyButton().setEnabled(true);
            attributesTable.setEnabled(true);
            updateElementAttributes(elementToUpdate, referentElement);
            shouldProcessUpdate = false;
            updateAttributesTable(elementToUpdate);
            shouldProcessUpdate = true;
        } else {
            String isWellFormedLabelVal =
                resources.getString("IsWellFormedLabel.notWellFormed");
            isWellFormedLabel.setText(isWellFormedLabelVal);
            getApplyButton().setEnabled(false);
            attributesTable.setEnabled(false);
        }
    }

    /**
     * Replaces all of the attributes of the given element with the referent
     * element's attributes.
     *
     * @param elem
     *            The element whose attributes should be replaced
     * @param referentElement
     *            The referentElement to copy the attributes from
     */
    private void updateElementAttributes(Element elem, Element referentElement) {
        // Remove all element attributes
        removeAttributes(elem);

        // Copy all attributes from the referent element to the given element
        NamedNodeMap newNodeMap = referentElement.getAttributes();
        for (int i = newNodeMap.getLength() - 1; i >= 0; i--) {
            Node newAttr = newNodeMap.item(i);
            String qualifiedName = newAttr.getNodeName();
            String attributeValue = newAttr.getNodeValue();
            String prefix = DOMUtilities.getPrefix(qualifiedName);
            String namespaceURI = getNamespaceURI(prefix);
            elem.setAttributeNS(namespaceURI, qualifiedName, attributeValue);
        }
    }

    /**
     * Replaces all of the atributes of a given element with the values from the
     * given table model.
     *
     * @param element
     *            The node whose attributes should update
     * @param tableModel
     *            The tableModel from which to get attributes
     */
    private void updateElementAttributes
            (Element element, AttributesTableModel tableModel) {

        // Remove all element attributes
        removeAttributes(element);

        // Copy all the attribute name - value pairs from the table model to
        // the given element
        for (int i = 0; i < tableModel.getRowCount(); i++) {
            String newAttrName = (String) tableModel.getAttrNameAt(i);
            String newAttrValue = (String) tableModel.getAttrValueAt(i);
            if (newAttrName != null && newAttrName.length() > 0) {
                String namespaceURI;
                if (newAttrName.equals(XMLConstants.XMLNS_PREFIX)) {
                    namespaceURI = XMLConstants.XMLNS_NAMESPACE_URI;
                } else {
                    String prefix = DOMUtilities.getPrefix(newAttrName);
                    namespaceURI = getNamespaceURI(prefix);
                }
                if (newAttrValue != null) {
                    element.setAttributeNS
                        (namespaceURI, newAttrName, newAttrValue);
                } else {
                    element.setAttributeNS(namespaceURI, newAttrName, "");
                }
            }
        }
    }

    /**
     * Removes all the attributes from an element.
     *
     * @param element
     *            The given element
     */
    private void removeAttributes(Element element) {
        NamedNodeMap oldNodeMap = element.getAttributes();
        int n = oldNodeMap.getLength();
        for (int i = n - 1; i >= 0; i--) {
            element.removeAttributeNode((Attr) oldNodeMap.item(i));
        }
    }

    /**
     * Looks up for the namespaceURI based on the given prefix. Uses the
     * Node.lookupNamespaceURI method, starting from the parent element of
     * the element being edited / created.
     *
     * @param prefix
     *            The given prefix
     * @return namespaceURI or null
     */
    private String getNamespaceURI(String prefix) {
        String namespaceURI = null;
        if (prefix != null) {
            if (prefix.equals(SVGConstants.XMLNS_PREFIX)) {
                namespaceURI = SVGConstants.XMLNS_NAMESPACE_URI;
            } else {
                AbstractNode n;
                if (mode == EDIT_MODE) {
                    n = (AbstractNode) previewElement;
                    namespaceURI = n.lookupNamespaceURI(prefix);
                } else if (mode == ADD_NEW_ELEMENT) {
                    n = (AbstractNode) parentElement;
                    namespaceURI = n.lookupNamespaceURI(prefix);
                }

            }
        }
        return namespaceURI;
    }

    /**
     * Fills the attributesTable with the given element attribute name - value
     * pairs.
     *
     * @param elem
     *            The given element
     */
    private void updateAttributesTable(Element elem) {
        NamedNodeMap map = elem.getAttributes();
        AttributesTableModel tableModel =
            (AttributesTableModel) attributesTable.getModel();
        // Remove and update rows from the table if needed...
        for (int i = tableModel.getRowCount() - 1; i >= 0; i--) {
            String attrName = (String) tableModel.getValueAt(i, 0);
            String newAttrValue = "";
            if (attrName != null) {
                newAttrValue = elem.getAttributeNS(null, attrName);
            }
            if (attrName == null || newAttrValue.length() == 0) {
                tableModel.removeRow(i);
            }
            if (newAttrValue.length() > 0) {
                tableModel.setValueAt(newAttrValue, i, 1);
            }
        }

        // Add rows
        for (int i = 0; i < map.getLength(); i++) {
            Node attr = map.item(i);
            String attrName = attr.getNodeName();
            String attrValue = attr.getNodeValue();
            if (tableModel.getValueForName(attrName) == null) {
                Vector rowData = new Vector();
                rowData.add(attrName);
                rowData.add(attrValue);
                tableModel.addRow(rowData);
            }
        }
    }

    /**
     * Shows node's String representation in svgInputPanel
     *
     * @param node
     *            The given node
     */
    private void updateNodeXmlArea(Node node) {
        getSvgInputPanel().getNodeXmlArea().setText(DOMUtilities.getXML(node));
    }

    /**
     * Getter for the preivewElement.
     *
     * @return the preivewElement
     */
    private Element getPreviewElement() {
        return previewElement;
    }

    /**
     * Sets the preview element. Enters the view mode and updates the associated
     * components.
     *
     * @param elem
     *            the element to set
     */
    public void setPreviewElement(Element elem) {
        if (previewElement != elem && isDirty) {
            if (!promptForChanges()) {
                return;
            }
        }

        this.previewElement = elem;
        enterViewMode();

        updateNodeXmlArea(elem);
        updateAttributesTable(elem);
    }

    /**
     * Invoked by the {@link DOMViewer} to inform the
     * <code>NodePickerPanel</code> that it is being hidden.
     */
    boolean panelHiding() {
        return !isDirty || promptForChanges();
    }

    /**
     * Gets the current working mode.
     *
     * @return the mode
     */
    private int getMode() {
        return mode;
    }

    /**
     * Enters the view mode.
     */
    public void enterViewMode() {
        if (mode != VIEW_MODE) {
            mode = VIEW_MODE;
            // Disable appropriate buttons
            getApplyButton().setEnabled(false);
            getResetButton().setEnabled(false);
            // Enable the remove and add buttons
            getRemoveButton().setEnabled(true);
            getAddButton().setEnabled(true);
            // Update the isWellFormed label
            String isWellFormedLabelVal =
                resources.getString("IsWellFormedLabel.wellFormed");
            isWellFormedLabel.setText(isWellFormedLabelVal);
        }
    }

    /**
     * Enters the edit mode.
     */
    public void enterEditMode() {
        if (mode != EDIT_MODE) {
            mode = EDIT_MODE;
            clonedElement = (Element) previewElement.cloneNode(true);

            // Enable appropriate buttons
            getApplyButton().setEnabled(true);
            getResetButton().setEnabled(true);
        }
    }

    /**
     * Enters the add new element mode.
     *
     * @param newElement
     *            The element to be added
     * @param parent
     *            The parent node of the element to be added
     */
    public void enterAddNewElementMode(Element newElement, Node parent) {
        if (mode != ADD_NEW_ELEMENT) {
            mode = ADD_NEW_ELEMENT;
            previewElement = newElement;
            clonedElement = (Element) newElement.cloneNode(true);
            parentElement = parent;
            // Update the appropriate areas
            updateNodeXmlArea(newElement);
            // Enable appropriate buttons
            getApplyButton().setEnabled(true);
            getResetButton().setEnabled(true);
//          // Request focus
//          getSvgInputPanel().getNodeXmlArea().requestFocusInWindow();
        }
    }

    /**
     * Updates the panel when DOM Mutation event occures.
     */
    public void updateOnDocumentChange(String mutationEventType, Node targetNode) {
        if (mode == VIEW_MODE) {
            if (this.isShowing() &&
                    shouldUpdate(mutationEventType,
                                 targetNode,
                                 getPreviewElement())) {
                setPreviewElement(getPreviewElement());
            }
        }
    }

    /**
     * If the panel should update its components after dom mutation event.
     * Checks whether any node that is the child node of the node currently
     * being previewed has changed. If true, updates the xml text area of this
     * NodePicker. In case of DOMAttrModiefied mutation event, the additional
     * condition is added - to check whether the attributes of an element that
     * is being previewed are changed. If true, the xml text area is refreshed.
     *
     * @return True if should update
     */
    private boolean shouldUpdate(String mutationEventType, Node affectedNode,
            Node currentNode) {
        if (mutationEventType.equals("DOMNodeInserted")) {
            if (DOMUtilities.isAncestorOf(currentNode, affectedNode)) {
                return true;
            }
        } else if (mutationEventType.equals("DOMNodeRemoved")) {
            if (DOMUtilities.isAncestorOf(currentNode, affectedNode)) {
                return true;
            }
        } else if (mutationEventType.equals("DOMAttrModified")) {
            if (DOMUtilities.isAncestorOf(currentNode, affectedNode)
                    || currentNode == affectedNode) {
                return true;
            }
        } else if (mutationEventType.equals("DOMCharDataModified")) {
            if (DOMUtilities.isAncestorOf(currentNode, affectedNode)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Parses the given xml and return parsed document's root element.
     * Used to check whether the given xml is well formed.
     *
     * @param xmlString
     *            Xml as a String
     * @return Element
     */
    private Element parseXml(String xmlString) {
        Document doc = null;
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        try {
            javax.xml.parsers.DocumentBuilder parser = factory
                    .newDocumentBuilder();
            parser.setErrorHandler(new ErrorHandler() {
                public void error(SAXParseException exception)
                        throws SAXException {
                }

                public void fatalError(SAXParseException exception)
                        throws SAXException {
                }

                public void warning(SAXParseException exception)
                        throws SAXException {
                }
            });
            doc = parser.parse(new InputSource(new StringReader(xmlString)));
        } catch (ParserConfigurationException e1) {
        } catch (SAXException e1) {
        } catch (IOException e1) {
        }
        if (doc != null) {
            return doc.getDocumentElement();
        }
        return null;
    }

    /**
     * Sets the node picker components to be editable / uneditable.
     *
     * @param editable
     *            Whether to enable or disable edit
     */
    public void setEditable(boolean editable) {
        getSvgInputPanel().getNodeXmlArea().setEditable(editable);
        getResetButton().setEnabled(editable);
        getApplyButton().setEnabled(editable);
        getAddButton().setEnabled(editable);
        getRemoveButton().setEnabled(editable);
        attributesTable.setEnabled(editable);
    }

    /**
     * Checks whether the given component is a part component of the this node
     * picker.
     *
     * @param component
     *            The given component
     * @return True if the given component is a part of the this NodePicker
     */
    private boolean isANodePickerComponent(Component component) {
        return SwingUtilities.getAncestorOfClass(NodePickerPanel.class,
                                                 component) != null;
    }

    /**
     * Shows a dialog to save changes.
     */
    public boolean promptForChanges() {
        // If the xml is well formed
        if (getApplyButton().isEnabled() && isElementModified()) {
            String confirmString = resources.getString("ConfirmDialog.message");
            int option = JOptionPane.showConfirmDialog(getSvgInputPanel(),
                                                       confirmString);
            if (option == JOptionPane.YES_OPTION) {
                getApplyButton().doClick();
            } else if (option == JOptionPane.CANCEL_OPTION) {
                return false;
            } else {
                getResetButton().doClick();
            }
        } else {
            getResetButton().doClick();
        }
        isDirty = false;
        return true;
    }

    /**
     * Whether the element being edit is changed.
     *
     * @return True if the element being edit is changed
     */
    private boolean isElementModified() {
        if (getMode() == EDIT_MODE) {
            return !DOMUtilities.getXML(previewElement).equals
                (getSvgInputPanel().getNodeXmlArea().getText());
        } else if (getMode() == ADD_NEW_ELEMENT) {
            return true;
        }
        return false;
    }

    /**
     * Manages the edits on focus events.
     */
    protected class NodePickerEditListener extends FocusAdapter {

        public void focusGained(FocusEvent e) {
            if (getMode() == VIEW_MODE) {
                enterEditMode();
            }
            setEditable(controller.isEditable()
                    && controller.canEdit(previewElement));
            isDirty = isElementModified();
        }

        // XXX Java 1.3 does not have getOppositeComponent()
        /*public void focusLost(FocusEvent e) {
            // Prompts the user to save changes that he made for an element,
            // when the NodePicker loses focus
            if (!isANodePickerComponent(e.getOppositeComponent())
                    && !e.isTemporary() && isDirty) {
                promptForChanges();
            }
        }*/
    }

    /**
     * Listens for the changes in the xml text area and updates this node picker
     * panel if needed.
     */
    protected class XMLAreaListener implements DocumentListener {
        public void changedUpdate(DocumentEvent e) {
            isDirty = isElementModified();
        }

        public void insertUpdate(DocumentEvent e) {
            updateNodePicker(e);
            isDirty = isElementModified();
        }

        public void removeUpdate(DocumentEvent e) {
            updateNodePicker(e);
            isDirty = isElementModified();
        }

        /**
         * Updates the node picker panel after document changes.
         *
         * @param e
         *            The document event
         */
        private void updateNodePicker(DocumentEvent e) {
            if (getMode() == EDIT_MODE) {
                updateViewAfterSvgInput
                    (parseXml(svgInputPanel.getNodeXmlArea().getText()),
                     clonedElement);
            } else if (getMode() == ADD_NEW_ELEMENT) {
                updateViewAfterSvgInput
                    (parseXml(svgInputPanel.getNodeXmlArea().getText()),
                     previewElement);
            }
        }
    }

    /**
     * Listens for the changes in the table and updates this node picker panel
     * if needed.
     */
    protected class AttributesTableModelListener implements TableModelListener {
        public void tableChanged(TableModelEvent e) {
            if (e.getType() == TableModelEvent.UPDATE && shouldProcessUpdate) {
                updateNodePicker(e);
            }
        }

        /**
         * Updates the node picker panel after document changes.
         *
         * @param e
         *            The document event
         */
        private void updateNodePicker(TableModelEvent e) {
            if (getMode() == EDIT_MODE) {
                updateElementAttributes
                    (clonedElement, (AttributesTableModel) (e.getSource()));
                updateNodeXmlArea(clonedElement);
            } else if (getMode() == ADD_NEW_ELEMENT) {
                updateElementAttributes
                    (previewElement, (AttributesTableModel) (e.getSource()));
                updateNodeXmlArea(previewElement);
            }
        }
    }

    /**
     * The action associated with the 'Apply' button.
     */
    protected class ApplyButtonAction extends AbstractAction {
        public void actionPerformed(ActionEvent e) {
            isDirty = false;
            String xmlAreaText = getResults();
            if (getMode() == EDIT_MODE) {
                fireUpdateElement
                    (new NodePickerEvent
                        (NodePickerPanel.this,
                         xmlAreaText,
                         previewElement,
                         NodePickerEvent.EDIT_ELEMENT));
            } else if (getMode() == ADD_NEW_ELEMENT) {
                fireAddNewElement
                    (new NodePickerEvent
                        (NodePickerPanel.this,
                         xmlAreaText,
                         parentElement,
                         NodePickerEvent.ADD_NEW_ELEMENT));
            }
            enterViewMode();
        }
    }

    /**
     * The action associated with the 'Reset' button.
     */
    protected class ResetButtonAction extends AbstractAction {
        public void actionPerformed(ActionEvent e) {
            isDirty = false;
            setPreviewElement(getPreviewElement());
        }
    }

    /**
     * The action associated with the 'Add' button.
     */
    protected class AddButtonAction extends AbstractAction {
        public void actionPerformed(ActionEvent e) {
            if (getMode() == VIEW_MODE) {
                enterEditMode();
            }
            DefaultTableModel model =
                (DefaultTableModel) attributesTable.getModel();
            shouldProcessUpdate = false;
            model.addRow((Vector) null);
            shouldProcessUpdate = true;
        }
    }

    /**
     * The action associated with the 'Remove' button.
     */
    protected class RemoveButtonAction extends AbstractAction {
        public void actionPerformed(ActionEvent e) {
            if (getMode() == VIEW_MODE) {
                enterEditMode();
            }
            // Find the contextElement
            Element contextElement = clonedElement;
            if (getMode() == ADD_NEW_ELEMENT) {
                contextElement = previewElement;
            }
            DefaultTableModel model =
                (DefaultTableModel) attributesTable.getModel();
            int[] selectedRows = attributesTable.getSelectedRows();
            for (int i = 0; i < selectedRows.length; i++) {
                String attrName = (String) model.getValueAt(selectedRows[i], 0);
                if (attrName != null) {
                    String prefix = DOMUtilities.getPrefix(attrName);
                    String localName = DOMUtilities.getLocalName(attrName);
                    String namespaceURI = getNamespaceURI(prefix);
                    contextElement.removeAttributeNS(namespaceURI, localName);
                }
            }
            shouldProcessUpdate = false;
            updateAttributesTable(contextElement);
            shouldProcessUpdate = true;
            updateNodeXmlArea(contextElement);
        }
    }

    /**
     * Returns the action associated with the given string or null on error
     *
     * @param key
     *            the key mapped with the action to get
     * @throws MissingListenerException
     *             if the action is not found
     */
    public Action getAction(String key) throws MissingListenerException {
        return (Action) listeners.get(key);
    }

    /**
     * The attributesTable model.
     */
    public static class AttributesTableModel extends DefaultTableModel {
        public AttributesTableModel(int rowCount, int columnCount) {
            super(rowCount, columnCount);
        }

        public String getColumnName(int column) {
            if (column == 0) {
                return resources.getString("AttributesTable.column1");
            } else {
                return resources.getString("AttributesTable.column2");
            }
        }

        /**
         * Gets the value of the attribute with the given attribute name.
         *
         * @param attrName
         *            The given attribute name
         */
        public Object getValueForName(Object attrName) {
            for (int i = 0; i < getRowCount(); i++) {
                if (getValueAt(i, 0) != null
                        && getValueAt(i, 0).equals(attrName)) {
                    return getValueAt(i, 1);
                }
            }
            return null;
        }

        /**
         * Gets the name of the attribute with the table row.
         */
        public Object getAttrNameAt(int i) {
            return getValueAt(i, 0);
        }

        /**
         * Gets the value of the attribute with the table row.
         */
        public Object getAttrValueAt(int i) {
            return getValueAt(i, 1);
        }

        /**
         * Gets the first row where the given attribute name appears.
         * @param attrName    The given attribute name
         */
        public int getRow(Object attrName) {
            for (int i = 0; i < getRowCount(); i++) {
                if (getValueAt(i, 0) != null
                        && getValueAt(i, 0).equals(attrName)) {
                    return i;
                }
            }
            return -1;
        }
    }

    // Custom events support
    /**
     * Fires the updateElement event.
     *
     * @param event
     *            The associated NodePickerEvent event
     */
    public void fireUpdateElement(NodePickerEvent event) {
        Object[] listeners = eventListeners.getListenerList();

        int length = listeners.length;
        for (int i = 0; i < length; i += 2) {
            if (listeners[i] == NodePickerListener.class) {
                ((NodePickerListener) listeners[i + 1])
                        .updateElement(event);
            }
        }
    }

    /**
     * Fires the AddNewElement event.
     *
     * @param event
     *            The associated NodePickerEvent event
     */
    public void fireAddNewElement(NodePickerEvent event) {
        Object[] listeners = eventListeners.getListenerList();
        int length = listeners.length;
        for (int i = 0; i < length; i += 2) {
            if (listeners[i] == NodePickerListener.class) {
                ((NodePickerListener) listeners[i + 1])
                        .addNewElement(event);
            }
        }
    }

    /**
     * Adds the listener to the listener list.
     *
     * @param listener
     *            The listener to add
     */
    public void addListener(NodePickerListener listener) {
        eventListeners.add(NodePickerListener.class, listener);
    }

    /**
     * Event to pass to listener.
     */
    public static class NodePickerEvent extends EventObject {

        // The event types
        public static final int EDIT_ELEMENT = 1;

        public static final int ADD_NEW_ELEMENT = 2;

        /**
         * The type of this event.
         */
        private int type;

        /**
         * The string that is to be parsed.
         */
        private String result;

        /**
         * The context node associated with this event.
         */
        private Node contextNode;

        /**
         * Creates the NodePickerEvent.
         *
         * @param source
         *            The NodePicker that initiated the event
         * @param result
         *            the NodePicker result
         * @param contextNode
         *            the associated context node
         */
        public NodePickerEvent(Object source, String result, Node contextNode,
                               int type) {
            super(source);
            this.result = result;
            this.contextNode = contextNode;
        }

        /**
         * Gets the NodePickerPanel result.
         *
         * @return the result
         */
        public String getResult() {
            return result;
        }

        /**
         * Gets the context node.
         * 'EDIT_ELEMENT' event type - the context node is the original element
         * being previewed.
         * 'ADD_NEW_ELEMENT' event type - the context node is the parent node of
         * the element being added
         *
         * @return the context node
         */
        public Node getContextNode() {
            return contextNode;
        }

        /**
         * Gets the type of this event.
         *
         * @return the type
         */
        public int getType() {
            return type;
        }
    }

    /**
     * Node picker listener.
     */
    public static interface NodePickerListener extends EventListener {
        /**
         * Updates the element from the data contained in the NodePickerEvent.
         */
        void updateElement(NodePickerEvent event);

        /**
         * Adds the element from the data contained in the NodePickerEvent.
         */
        void addNewElement(NodePickerEvent event);
    }

    /**
     * The adapter for the NodePicker listener.
     */
    public static class NodePickerAdapter implements NodePickerListener {

        public void addNewElement(NodePickerEvent event) {
        }

        public void updateElement(NodePickerEvent event) {
        }
    }

    /**
     * The panel to view and edit the elements xml representation.
     */
    protected class SVGInputPanel extends JPanel {

        /**
         * The text area.
         */
        protected XMLTextEditor nodeXmlArea;

        /**
         * Constructor.
         */
        public SVGInputPanel() {
            super(new BorderLayout());
            add(new JScrollPane(getNodeXmlArea()));
        }

        /**
         * Gets the nodeXmlArea.
         *
         * @return    the nodeXmlArea
         */
        protected XMLTextEditor getNodeXmlArea() {
            if (nodeXmlArea == null) {
                // Create syntax-highlighted text area
                nodeXmlArea = new XMLTextEditor();
                nodeXmlArea.setEditable(true);
            }
            return nodeXmlArea;
        }
    }

    /**
     * Dialog for choosing element name.
     */
    public static class NameEditorDialog extends JDialog implements ActionMap {

        /**
         * The return value if 'OK' is chosen.
         */
        public static final int OK_OPTION = 0;

        /**
         * The return value if 'Cancel' is chosen.
         */
        public static final int CANCEL_OPTION = 1;

        /**
         * The resource file name.
         */
        protected static final String RESOURCES =
            "org.apache.flex.forks.batik.apps.svgbrowser.resources.NameEditorDialogMessages";

        /**
         * The resource bundle.
         */
        protected static ResourceBundle bundle;

        /**
         * The resource manager.
         */
        protected static ResourceManager resources;
        static {
            bundle = ResourceBundle.getBundle(RESOURCES, Locale.getDefault());
            resources = new ResourceManager(bundle);
        }

        /**
         * The Dialog results.
         */
        protected int returnCode;

        /**
         * The Dialog main panel.
         */
        protected JPanel mainPanel;

        /**
         * The Button factory.
         */
        protected ButtonFactory buttonFactory;

        /**
         * The node name label.
         */
        protected JLabel nodeNameLabel;

        /**
         * The node name field.
         */
        protected JTextField nodeNameField;

        /**
         * The OK button.
         */
        protected JButton okButton;

        /**
         * The Cancel button.
         */
        protected JButton cancelButton;

        /**
         * The map that contains the listeners
         */
        protected Map listeners = new HashMap(10);

        /**
         * Constructor.
         *
         * @param frame
         *            Parent frame
         */
        public NameEditorDialog(Frame frame) {
            super(frame, true);
            this.setResizable(false);
            this.setModal(true);
            initialize();
        }

        /**
         * Initializes the dialog.
         */
        protected void initialize() {
            this.setSize(resources.getInteger("Dialog.width"),
                         resources.getInteger("Dialog.height"));
            this.setTitle(resources.getString("Dialog.title"));
            addButtonActions();
            this.setContentPane(getMainPanel());
        }

        /**
         * Gets buttonFactory.
         */
        protected ButtonFactory getButtonFactory() {
            if (buttonFactory == null) {
                buttonFactory = new ButtonFactory(bundle, this);
            }
            return buttonFactory;
        }

        /**
         * Adds button actions.
         */
        protected void addButtonActions() {
            listeners.put("OKButtonAction", new OKButtonAction());
            listeners.put("CancelButtonAction", new CancelButtonAction());
        }

        /**
         * Shows the dialog.
         *
         * @return OK_OPTION or CANCEL_OPTION.
         */
        public int showDialog() {
            setVisible(true);
            return returnCode;
        }

        /**
         * Gets the Ok button.
         *
         * @return the okButton
         */
        protected JButton getOkButton() {
            if (okButton == null) {
                okButton = getButtonFactory().createJButton("OKButton");
                this.getRootPane().setDefaultButton(okButton);
            }
            return okButton;
        }

        /**
         * Gets the Cancel button.
         *
         * @return the cancelButton
         */
        protected JButton getCancelButton() {
            if (cancelButton == null) {
                cancelButton = getButtonFactory().createJButton("CancelButton");
            }
            return cancelButton;
        }

        /**
         * Gets dialog's main panel.
         *
         * @return the mainPanel
         */
        protected JPanel getMainPanel() {
            if (mainPanel == null) {
                mainPanel = new JPanel(new GridBagLayout());

                GridBagConstraints gridBag = new GridBagConstraints();
                gridBag.gridx = 1;
                gridBag.gridy = 1;
                gridBag.fill = GridBagConstraints.NONE;
                gridBag.insets = new Insets(5, 5, 5, 5);
                mainPanel.add(getNodeNameLabel(), gridBag);

                gridBag.gridx = 2;
                gridBag.weightx = 1.0;
                gridBag.weighty = 1.0;
                gridBag.fill = GridBagConstraints.HORIZONTAL;
                gridBag.anchor = GridBagConstraints.CENTER;
                mainPanel.add(getNodeNameField(), gridBag);

                gridBag.gridx = 1;
                gridBag.gridy = 2;
                gridBag.weightx = 0;
                gridBag.weighty = 0;
                gridBag.anchor = GridBagConstraints.EAST;
                gridBag.fill = GridBagConstraints.HORIZONTAL;
                mainPanel.add(getOkButton(), gridBag);

                gridBag.gridx = 2;
                gridBag.gridy = 2;
                gridBag.anchor = GridBagConstraints.EAST;
                mainPanel.add(getCancelButton(), gridBag);
            }
            return mainPanel;
        }

        /**
         * Gets the node name label.
         *
         * @return the nodeNameLabel
         */
        public JLabel getNodeNameLabel() {
            if (nodeNameLabel == null) {
                nodeNameLabel = new JLabel();
                nodeNameLabel.setText(resources.getString("Dialog.label"));
            }
            return nodeNameLabel;
        }

        /**
         * Gets the text field for node name.
         *
         * @return the nodeNameField
         */
        protected JTextField getNodeNameField() {
            if (nodeNameField == null) {
                nodeNameField = new JTextField();
            }
            return nodeNameField;
        }

        /**
         * Gets the dialog results.
         *
         * @return the element name
         */
        public String getResults() {
            return nodeNameField.getText();
        }

        /**
         * The action associated with the 'OK' button of Attribute Adder Dialog
         */
        protected class OKButtonAction extends AbstractAction {
            public void actionPerformed(ActionEvent e) {
                returnCode = OK_OPTION;
                dispose();
            }
        }

        /**
         * The action associated with the 'Cancel' button of Attribute Adder
         * Dialog
         */
        protected class CancelButtonAction extends AbstractAction {
            public void actionPerformed(ActionEvent e) {
                returnCode = CANCEL_OPTION;
                dispose();
            }
        }

        /**
         * Returns the action associated with the given string or null on error
         *
         * @param key
         *            the key mapped with the action to get
         * @throws MissingListenerException
         *             if the action is not found
         */
        public Action getAction(String key) throws MissingListenerException {
            return (Action) listeners.get(key);
        }
    }
}

