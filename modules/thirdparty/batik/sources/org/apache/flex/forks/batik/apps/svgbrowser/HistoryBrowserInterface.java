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

import java.util.ArrayList;

import org.apache.flex.forks.batik.apps.svgbrowser.HistoryBrowser.CommandController;
import org.apache.flex.forks.batik.apps.svgbrowser.HistoryBrowser.HistoryBrowserEvent;
import org.apache.flex.forks.batik.dom.util.DOMUtilities;
import org.apache.flex.forks.batik.util.SVGConstants;

import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 * The wrapper for the history browser. The commands for the historyBrowser
 * are implemented here
 *
 * @version $Id$
 */
public class HistoryBrowserInterface {

    // ATOM COMMANDS
    private static final String ATTRIBUTE_ADDED_COMMAND = "Attribute added: ";

    private static final String ATTRIBUTE_REMOVED_COMMAND = "Attribute removed: ";

    private static final String ATTRIBUTE_MODIFIED_COMMAND = "Attribute modified: ";

    private static final String NODE_INSERTED_COMMAND = "Node inserted: ";

    private static final String NODE_REMOVED_COMMAND = "Node removed: ";

    private static final String CHAR_DATA_MODIFIED_COMMAND = "Node value changed: ";

    // OTHER COMMANDS
    /**
     * The changes being performed outside of the DOMViewer.
     */
    private static final String OUTER_EDIT_COMMAND = "Document changed outside DOM Viewer";

    /**
     * Compound tree node dropped command name.
     */
    private static final String COMPOUND_TREE_NODE_DROP = "Node moved";

    /**
     * Remove selected nodes command name.
     */
    private static final String REMOVE_SELECTED_NODES = "Nodes removed";

    /**
     * The history browser.
     */
    protected HistoryBrowser historyBrowser;

    /**
     * Used to group custom number of changes into a single command.
     */
    protected AbstractCompoundCommand currentCompoundCommand;

    /**
     * Constructor. Creates the history browser.
     */
    public HistoryBrowserInterface(CommandController commandController) {
        historyBrowser = new HistoryBrowser(commandController);
    }

    /**
     * Sets the history browser's command controller.
     *
     * @param newCommandController
     *            The commandController to set
     */
    public void setCommmandController(CommandController newCommandController) {
        historyBrowser.setCommandController(newCommandController);
    }

    /**
     * Creates the compound update command, that consists of custom number of
     * commands.
     *
     * @param commandName
     *            Compound command name
     * @return CompoundUpdateCommand
     */
    public CompoundUpdateCommand
            createCompoundUpdateCommand(String commandName) {
        CompoundUpdateCommand cmd = new CompoundUpdateCommand(commandName);
        return cmd;
    }

    /**
     * Creates the compound NodeChangedCommand. Used to create the 'dynamic'
     * NodeChangedCommand name
     *
     * @return the CompoundUpdateCommand
     */
    public CompoundUpdateCommand createNodeChangedCommand(Node node) {
        return new CompoundUpdateCommand(getNodeChangedCommandName(node));
    }

    /**
     * Creates the compound NodesDroppedCommand. Used to create the 'dynamic'
     * NodesDroppedCommand name
     *
     * @param nodes
     *            The list of the nodes that are being dropped
     * @return the CompoundUpdateCommand
     */
    public CompoundUpdateCommand createNodesDroppedCommand(ArrayList nodes) {
        return new CompoundUpdateCommand(COMPOUND_TREE_NODE_DROP);
    }

    /**
     * Creates the compound RemoveSelectedTreeNodesCommand. Used to create the
     * 'dynamic' RemoveSelectedTreeNodesCommand name
     *
     * @param nodes
     *            The list of the nodes that are selected and should be removed
     * @return the RemoveSelectedTreeNodesCommand
     */
    public CompoundUpdateCommand
            createRemoveSelectedTreeNodesCommand(ArrayList nodes) {
        return new CompoundUpdateCommand(REMOVE_SELECTED_NODES);
    }

    /**
     * Executes the given compound update command.
     *
     * @param command
     *            The given compound update command
     */
    public void performCompoundUpdateCommand(UndoableCommand command) {
        historyBrowser.addCommand(command);
    }

    /**
     * The compound command.
     */
    public static class CompoundUpdateCommand extends AbstractCompoundCommand {

        /**
         * Constructor.
         *
         * @param commandName
         *            The compound command name
         */
        public CompoundUpdateCommand(String commandName) {
            setName(commandName);
        }
    }

    /**
     * Gets the history browser.
     *
     * @return the historyBrowser
     */
    public HistoryBrowser getHistoryBrowser() {
        return historyBrowser;
    }


    // ATOM COMMANDS

    /**
     * Adds the NodeInsertedCommand to historyBrowser.
     *
     * @param newParent
     *            New parent node
     * @param newSibling
     *            New (next) sibling node
     * @param contextNode
     *            The node to be appended
     */
    public void nodeInserted(Node newParent, Node newSibling, Node contextNode) {
        historyBrowser.addCommand(createNodeInsertedCommand(newParent,
                newSibling, contextNode));
    }

    /**
     * Creates the NodeInserted command.
     *
     * @param newParent
     *            New parent node
     * @param newSibling
     *            New (next) sibling node
     * @param contextNode
     *            The node to be appended
     */
    public NodeInsertedCommand createNodeInsertedCommand(Node newParent,
                                                         Node newSibling,
                                                         Node contextNode) {
        return new NodeInsertedCommand
            (NODE_INSERTED_COMMAND + getBracketedNodeName(contextNode),
             newParent, newSibling, contextNode);
    }

    /**
     * Inserts the given node as a child of another.
     */
    public static class NodeInsertedCommand extends AbstractUndoableCommand {

        /**
         * The node's next sibling.
         */
        protected Node newSibling;

        /**
         * The node's new parent.
         */
        protected Node newParent;

        /**
         * The node to be appended.
         */
        protected Node contextNode;

        /**
         * Constructor.
         */
        public NodeInsertedCommand(String commandName, Node parent,
                                   Node sibling, Node contextNode) {
            setName(commandName);
            this.newParent = parent;
            this.contextNode = contextNode;
            this.newSibling = sibling;
        }

        public void execute() {
        }

        public void undo() {
            newParent.removeChild(contextNode);
        }

        public void redo() {
            if (newSibling != null) {
                newParent.insertBefore(contextNode, newSibling);
            } else {
                newParent.appendChild(contextNode);
            }
        }

        public boolean shouldExecute() {
            if (newParent == null || contextNode == null) {
                return false;
            }
            return true;
        }
    }

    /**
     * Adds the NodeRemovedCommand to historyBrowser.
     *
     * @param oldParent
     *            The node's old parent
     * @param oldSibling
     *            The node's old next sibling
     * @param contextNode
     *            The node to be removed
     */
    public void nodeRemoved(Node oldParent, Node oldSibling, Node contextNode) {
        historyBrowser.addCommand
            (createNodeRemovedCommand(oldParent, oldSibling, contextNode));
    }

    /**
     * Creates the NodeRemoved command.
     *
     * @param oldParent
     *            The node's old parent
     * @param oldSibling
     *            The node's old next sibling
     * @param contextNode
     *            The node to be removed
     */
    public NodeRemovedCommand createNodeRemovedCommand(Node oldParent,
                                                       Node oldSibling,
                                                       Node contextNode) {
        return new NodeRemovedCommand
            (NODE_REMOVED_COMMAND + getBracketedNodeName(contextNode),
             oldParent, oldSibling, contextNode);
    }

    /**
     * Removes the node from its parent node.
     */
    public static class NodeRemovedCommand extends AbstractUndoableCommand {

        /**
         * The node's old sibling.
         */
        protected Node oldSibling;

        /**
         * The node's new parent.
         */
        protected Node oldParent;

        /**
         * The node to be appended.
         */
        protected Node contextNode;

        /**
         * Constructor.
         */
        public NodeRemovedCommand(String commandName, Node oldParent,
                                  Node oldSibling, Node contextNode) {
            setName(commandName);
            this.oldParent = oldParent;
            this.contextNode = contextNode;
            this.oldSibling = oldSibling;
        }

        public void execute() {
        }

        public void undo() {
            if (oldSibling != null) {
                oldParent.insertBefore(contextNode, oldSibling);
            } else {
                oldParent.appendChild(contextNode);
            }
        }

        public void redo() {
            oldParent.removeChild(contextNode);
        }

        public boolean shouldExecute() {
            if (oldParent == null || contextNode == null) {
                return false;
            }
            return true;
        }
    }

    /**
     * Adds the AttributeAddedCommand to historyBrowser.
     *
     * @param contextElement
     *            The context element
     * @param attributeName
     *            The attribute name
     * @param newAttributeValue
     *            The attribute value
     * @param namespaceURI
     *            The namespaceURI
     */
    public void attributeAdded(Element contextElement, String attributeName,
                               String newAttributeValue, String namespaceURI) {
        historyBrowser.addCommand
            (createAttributeAddedCommand(contextElement, attributeName,
                                         newAttributeValue, namespaceURI));
    }

    /**
     * Creates the AttributeAdded command.
     *
     * @param contextElement
     *            The context element
     * @param attributeName
     *            The attribute name
     * @param newAttributeValue
     *            The attribute value
     * @param namespaceURI
     *            The namespaceURI
     */
    public AttributeAddedCommand
            createAttributeAddedCommand(Element contextElement,
                                        String attributeName,
                                        String newAttributeValue,
                                        String namespaceURI) {
        return new AttributeAddedCommand
            (ATTRIBUTE_ADDED_COMMAND + getBracketedNodeName(contextElement),
             contextElement, attributeName, newAttributeValue, namespaceURI);
    }

    /**
     * Adds the attribute to an element (MutationEvent.ADDITION)
     */
    public static class AttributeAddedCommand extends AbstractUndoableCommand {

        /**
         * The context element.
         */
        protected Element contextElement;

        /**
         * The attribute name.
         */
        protected String attributeName;

        /**
         * The attribute value.
         */
        protected String newValue;

        /**
         * The namespaceURI.
         */
        protected String namespaceURI;

        /**
         * Constructor.
         *
         * @param commandName
         *            The name of this command.
         * @param contextElement
         *            The context element
         * @param attributeName
         *            The attribute name
         * @param newAttributeValue
         *            The attribute value
         * @param namespaceURI
         *            The namespaceURI
         */
        public AttributeAddedCommand(String commandName,
                                     Element contextElement,
                                     String attributeName,
                                     String newAttributeValue,
                                     String namespaceURI) {
            setName(commandName);
            this.contextElement = contextElement;
            this.attributeName = attributeName;
            this.newValue = newAttributeValue;
            this.namespaceURI = namespaceURI;
        }

        public void execute() {
        }

        public void undo() {
            contextElement.removeAttributeNS(namespaceURI, attributeName);
        }

        public void redo() {
            contextElement.setAttributeNS
                (namespaceURI, attributeName, newValue);
        }

        public boolean shouldExecute() {
            if (contextElement == null || attributeName.length() == 0) {
                return false;
            }
            return true;
        }
    }

    /**
     * Adds the AttributeRemovedCommand to historyBrowser.
     *
     * @param contextElement
     *            The context element
     * @param attributeName
     *            The attribute name
     * @param prevAttributeValue
     *            The previous attribute value
     * @param namespaceURI
     *            The namespaceURI
     */
    public void attributeRemoved(Element contextElement,
                                 String attributeName,
                                 String prevAttributeValue,
                                 String namespaceURI) {
        historyBrowser.addCommand
            (createAttributeRemovedCommand(contextElement, attributeName,
                                           prevAttributeValue, namespaceURI));
    }

    /**
     * Creates the AttributeRemoved command.
     *
     * @param contextElement
     *            The context element
     * @param attributeName
     *            The attribute name
     * @param prevAttributeValue
     *            The previous attribute value
     * @param namespaceURI
     *            The namespaceURI
     */
    public AttributeRemovedCommand
            createAttributeRemovedCommand(Element contextElement,
                                          String attributeName,
                                          String prevAttributeValue,
                                          String namespaceURI) {
        return new AttributeRemovedCommand
            (ATTRIBUTE_REMOVED_COMMAND + getBracketedNodeName(contextElement),
             contextElement, attributeName, prevAttributeValue, namespaceURI);
    }

    /**
     * Removes the attribute of an element (MutationEvent.REMOVAL)
     */
    public static class AttributeRemovedCommand extends AbstractUndoableCommand {

        /**
         * The context element.
         */
        protected Element contextElement;

        /**
         * The attribute name.
         */
        protected String attributeName;

        /**
         * The previous attribute value.
         */
        protected String prevValue;

        /**
         * The namespaceURI.
         */
        protected String namespaceURI;

        /**
         * Constructor.
         *
         * @param commandName
         *            The name of this command.
         * @param contextElement
         *            The context element
         * @param attributeName
         *            The attribute name
         * @param prevAttributeValue
         *            The previous attribute value
         * @param namespaceURI
         *            The namespaceURI
         */
        public AttributeRemovedCommand(String commandName,
                                       Element contextElement,
                                       String attributeName,
                                       String prevAttributeValue,
                                       String namespaceURI) {
            setName(commandName);
            this.contextElement = contextElement;
            this.attributeName = attributeName;
            this.prevValue = prevAttributeValue;
            this.namespaceURI = namespaceURI;
        }

        public void execute() {
        }

        public void undo() {
            contextElement.setAttributeNS
                (namespaceURI, attributeName, prevValue);
        }

        public void redo() {
            contextElement.removeAttributeNS(namespaceURI, attributeName);
        }

        public boolean shouldExecute() {
            if (contextElement == null || attributeName.length() == 0) {
                return false;
            }
            return true;
        }
    }

    /**
     * Adds the AttributeModifiedCommand to historyBrowser.
     *
     * @param contextElement
     *            The context element
     * @param attributeName
     *            The attribute name
     * @param prevAttributeValue
     *            The previous attribute value
     * @param newAttributeValue
     *            The new attribute value
     * @param namespaceURI
     *            The namespaceURI
     */
    public void attributeModified(Element contextElement,
                                  String attributeName,
                                  String prevAttributeValue,
                                  String newAttributeValue,
                                  String namespaceURI) {
        historyBrowser.addCommand
            (createAttributeModifiedCommand(contextElement, attributeName,
                                            prevAttributeValue,
                                            newAttributeValue, namespaceURI));
    }

    /**
     * Creates the AttributeModified command.
     *
     * @param contextElement
     *            The context element
     * @param attributeName
     *            The attribute name
     * @param prevAttributeValue
     *            The previous attribute value
     * @param newAttributeValue
     *            The new attribute value
     * @param namespaceURI
     *            The namespaceURI
     */
    public AttributeModifiedCommand
            createAttributeModifiedCommand(Element contextElement,
                                           String attributeName,
                                           String prevAttributeValue,
                                           String newAttributeValue,
                                           String namespaceURI) {
        return new AttributeModifiedCommand
            (ATTRIBUTE_MODIFIED_COMMAND + getBracketedNodeName(contextElement),
             contextElement, attributeName, prevAttributeValue,
             newAttributeValue, namespaceURI);
    }

    /**
     * Modifies the attribute of an element (MutationEvent.MODIFICATION)
     */
    public static class AttributeModifiedCommand extends AbstractUndoableCommand {

        /**
         * The context element.
         */
        protected Element contextElement;

        /**
         * The attribute name.
         */
        protected String attributeName;

        /**
         * Previous attribute value.
         */
        protected String prevAttributeValue;

        /**
         * New attribute value.
         */
        protected String newAttributeValue;

        /**
         * The namespaceURI.
         */
        protected String namespaceURI;

        /**
         * Constructor.
         *
         * @param commandName
         *            The name of this command.
         * @param contextElement
         *            The context element
         * @param attributeName
         *            The attribute name
         * @param prevAttributeValue
         *            The previous attribute value
         * @param newAttributeValue
         *            The new attribute value
         * @param namespaceURI
         *            The namespaceURI
         */
        public AttributeModifiedCommand(String commandName,
                                        Element contextElement,
                                        String attributeName,
                                        String prevAttributeValue,
                                        String newAttributeValue,
                                        String namespaceURI) {
            setName(commandName);
            this.contextElement = contextElement;
            this.attributeName = attributeName;
            this.prevAttributeValue = prevAttributeValue;
            this.newAttributeValue = newAttributeValue;
            this.namespaceURI = namespaceURI;
        }

        public void execute() {
        }

        public void undo() {
            contextElement.setAttributeNS
                (namespaceURI, attributeName, prevAttributeValue);
        }

        public void redo() {
            contextElement.setAttributeNS
                (namespaceURI, attributeName, newAttributeValue);
        }

        public boolean shouldExecute() {
            if (contextElement == null || attributeName.length() == 0) {
                return false;
            }
            return true;
        }
    }

    /**
     * Adds CharDataModifiedCommand to historyBrowser.
     *
     * @param contextNode
     *            The node whose nodeValue changed
     * @param oldValue
     *            The old node value
     * @param newValue
     *            The new node value
     */
    public void charDataModified(Node contextNode, String oldValue,
                                 String newValue) {
        historyBrowser.addCommand
            (createCharDataModifiedCommand(contextNode, oldValue, newValue));
    }

    /**
     * Creates the CharDataModified command.
     *
     * @param contextNode
     *            The node whose nodeValue changed
     * @param oldValue
     *            The old node value
     * @param newValue
     *            The new node value
     */
    public CharDataModifiedCommand
            createCharDataModifiedCommand(Node contextNode,
                                          String oldValue,
                                          String newValue) {
        return new CharDataModifiedCommand
            (CHAR_DATA_MODIFIED_COMMAND + getBracketedNodeName(contextNode),
             contextNode, oldValue, newValue);
    }

    /**
     * Sets the node value.
     */
    public static class CharDataModifiedCommand extends AbstractUndoableCommand {

        /**
         * The node whose value changed.
         */
        protected Node contextNode;

        /**
         * Old node value.
         */
        protected String oldValue;

        /**
         * New node value.
         */
        protected String newValue;

        /**
         * Constructor.
         *
         * @param commandName
         *            The command name
         * @param contextNode
         *            Context node
         * @param oldValue
         *            Old node value
         * @param newValue
         *            New node value
         */
        public CharDataModifiedCommand(String commandName, Node contextNode,
                String oldValue, String newValue) {
            setName(commandName);
            this.contextNode = contextNode;
            this.oldValue = oldValue;
            this.newValue = newValue;
        }

        public void execute() {
        }

        public void undo() {
            contextNode.setNodeValue(oldValue);
        }

        public void redo() {
            contextNode.setNodeValue(newValue);
        }

        public boolean shouldExecute() {
            if (contextNode == null) {
                return false;
            }
            return true;
        }
    }

    // OTHER COMMANDS

    /**
     * Adds and executes the AppendChildCommand to historyBrowser.
     *
     * @param parent
     *            The given parent
     * @param child
     *            The node to be appended
     */
    public void appendChild(Node parent, Node child) {
        historyBrowser.addCommand(createAppendChildCommand(parent, child));
    }


    /**
     * Creates and return the AppendChild command.
     *
     * @param parent
     *            The given parent
     * @param child
     *            The node to be appended
     * @return the AppendChild command
     */
    public AppendChildCommand createAppendChildCommand(Node parent,
                                                       Node child) {
        return new AppendChildCommand
            (getAppendChildCommandName(parent, child), parent, child);
    }

    /**
     * The AppendChild command. Appends the given node to the given parent node
     * as a last child.
     */
    public static class AppendChildCommand extends AbstractUndoableCommand {

        /**
         * The node's previous parent.
         */
        protected Node oldParentNode;

        /**
         * The node's previous next sibling.
         */
        protected Node oldNextSibling;

        /**
         * The node's new parent.
         */
        protected Node parentNode;

        /**
         * The node to be appended.
         */
        protected Node childNode;

        /**
         * Constructor.
         */
        public AppendChildCommand(String commandName, Node parentNode,
                                  Node childNode) {
            setName(commandName);
            this.oldParentNode = childNode.getParentNode();
            this.oldNextSibling = childNode.getNextSibling();
            this.parentNode = parentNode;
            this.childNode = childNode;
        }

        public void execute() {
            parentNode.appendChild(childNode);
        }

        public void undo() {
            if (oldParentNode != null) {
                oldParentNode.insertBefore(childNode, oldNextSibling);
            } else {
                parentNode.removeChild(childNode);
            }
        }

        public void redo() {
            execute();
        }

        public boolean shouldExecute() {
            if (parentNode == null || childNode == null) {
                return false;
            }
            return true;
        }
    }

    /**
     * Adds and executes the InsertNodeBeforeCommand to historyBrowser.
     *
     * @param parent
     *            The given parent
     * @param sibling
     *            Points where to be inserted
     * @param child
     *            The node to insert
     */
    public void insertChildBefore(Node parent, Node sibling, Node child) {
        if (sibling == null) {
            historyBrowser.addCommand(createAppendChildCommand(parent, child));
        } else {
            historyBrowser.addCommand
                (createInsertNodeBeforeCommand(parent, sibling, child));
        }
    }

    /**
     * Creates InsertChildBefore or AppendChild command, depending on the value
     * of siblingNode.
     *
     * @param parent
     *            The parent node
     * @param sibling
     *            The sibling node
     * @param child
     *            The child node
     * @return AppendChild command if sibling node is null, InsertChildBefore
     *         otherwise
     */
    public UndoableCommand createInsertChildCommand(Node parent,
                                                    Node sibling,
                                                    Node child) {
        if (sibling == null) {
            return createAppendChildCommand(parent, child);
        } else {
            return createInsertNodeBeforeCommand(parent, sibling, child);
        }
    }
    /**
     * Creates and returns the InsertNodeBeforeCommand.
     *
     * @param parent
     *            The given parent
     * @param sibling
     *            Points where to be inserted
     * @param child
     *            The node to insert
     * @return the InsertNodeBeforeCommand
     */
    public InsertNodeBeforeCommand createInsertNodeBeforeCommand(Node parent,
                                                                 Node sibling,
                                                                 Node child) {
        return new InsertNodeBeforeCommand
            (getInsertBeforeCommandName(parent, child, sibling),
             parent, sibling, child);
    }

    /**
     * Inserts the given node as a child to the given parent node before the
     * specified sibling node, or as the last child of the given parent, if the
     * sibling node is null.
     */
    public static class InsertNodeBeforeCommand extends AbstractUndoableCommand {

        /**
         * The node's previous parent.
         */
        protected Node oldParent;

        /**
         * The node's previous next sibling.
         */
        protected Node oldNextSibling;

        /**
         * The node's new next sibling.
         */
        protected Node newNextSibling;

        /**
         * The node's new parent.
         */
        protected Node parent;

        /**
         * The node to be appended.
         */
        protected Node child;

        /**
         * Constructor.
         */
        public InsertNodeBeforeCommand(String commandName, Node parent,
                                       Node sibling, Node child) {
            setName(commandName);
            this.oldParent = child.getParentNode();
            this.oldNextSibling = child.getNextSibling();
            this.parent = parent;
            this.child = child;
            this.newNextSibling = sibling;
        }

        public void execute() {
            if (newNextSibling != null) {
                parent.insertBefore(child, newNextSibling);
            } else {
                parent.appendChild(child);
            }
        }

        /* (non-Javadoc)
         * @see org.apache.flex.forks.batik.util.gui.AbstractUndoableCommand#undo()
         */
        public void undo() {
            if (oldParent != null) {
                oldParent.insertBefore(child, oldNextSibling);
            } else {
                parent.removeChild(child);
            }
        }

        public void redo() {
            execute();
        }

        public boolean shouldExecute() {
            if (parent == null || child == null) {
                return false;
            }
            return true;
        }
    }


    /**
     * Adds and executes the ReplaceChild command to historyBrowser.
     *
     * @param parent
     *            The parent node
     * @param newChild
     *            Points where to be inserted
     * @param oldChild
     *            The node to be appended
     */
    public void replaceChild(Node parent, Node newChild, Node oldChild) {
//        if (sibling == null) {
//            historyBrowser.addCommand(new AppendChildCommand(
//                    APPEND_CHILD_COMMAND, parent, child));
//        } else {
//            historyBrowser.addCommand(new InsertNodeBeforeCommand(
//                    REPLACE_CHILD_COMMAND, parent, sibling, child));
//        }
    }

    /**
     * insertBefore
     */
    public static class ReplaceChildCommand extends AbstractUndoableCommand {

        /**
         * The node's previous parent.
         */
        protected Node oldParent;

        /**
         * The node's previous next sibling.
         */
        protected Node oldNextSibling;

        /**
         * The node's new next sibling.
         */
        protected Node newNextSibling;

        /**
         * The node's new parent.
         */
        protected Node parent;

        /**
         * The node to be appended.
         */
        protected Node child;

        /**
         * Constructor.
         */
        public ReplaceChildCommand(String commandName, Node parent,
                                   Node sibling, Node child) {
            setName(commandName);
            this.oldParent = child.getParentNode();
            this.oldNextSibling = child.getNextSibling();
            this.parent = parent;
            this.child = child;
            this.newNextSibling = sibling;
        }

        public void execute() {
            if (newNextSibling != null) {
                parent.insertBefore(child, newNextSibling);
            } else {
                parent.appendChild(child);
            }
        }

        public void undo() {
            if (oldParent != null) {
                oldParent.insertBefore(child, oldNextSibling);
            } else {
                parent.removeChild(child);
            }
        }

        public void redo() {
            execute();
        }

        public boolean shouldExecute() {
            if (parent == null || child == null) {
                return false;
            }
            return true;
        }
    }

    /**
     * Adds and executes the RemoveChild command to the History Browser.
     *
     * @param parent
     *            The given parent
     * @param child
     *            The given child
     */
    public void removeChild(Node parent, Node child) {
        historyBrowser.addCommand(createRemoveChildCommand(parent, child));
    }

    /**
     * Creates and returns the RemoveChild command.
     *
     * @param parent
     *            The parent node
     * @param child
     *            The child node
     * @return The RemoveChild command
     */
    public RemoveChildCommand createRemoveChildCommand(Node parent,
                                                       Node child) {
        return new RemoveChildCommand
            (getRemoveChildCommandName(parent, child), parent, child);
    }

    /**
     * The RemoveChild command. Removes the given child node from its given
     * parent node.
     */
    public static class RemoveChildCommand extends AbstractUndoableCommand {

        /**
         * Node's previous parent.
         */
        protected Node parentNode;

        /**
         * The node to be removed.
         */
        protected Node childNode;

        /**
         * Node's index in parent's children array.
         */
        protected int indexInChildrenArray;

        /**
         * Constructor.
         */
        public RemoveChildCommand(String commandName, Node parentNode,
                                  Node childNode) {
            setName(commandName);
            this.parentNode = parentNode;
            this.childNode = childNode;
        }

        public void execute() {
            indexInChildrenArray =
                DOMUtilities.getChildIndex(childNode, parentNode);
            parentNode.removeChild(childNode);
        }

        public void undo() {
            Node refChild =
                parentNode.getChildNodes().item(indexInChildrenArray);
            parentNode.insertBefore(childNode, refChild);
        }

        public void redo() {
            parentNode.removeChild(childNode);
        }

        public boolean shouldExecute() {
            if (parentNode == null || childNode == null) {
                return false;
            }
            return true;
        }
    }

    /**
     * Adds and executes the ChangeNodeValueCommand to historyBrowser.
     *
     * @param contextNode
     *            The node whose nodeValue changed
     * @param newValue
     *            The new node value
     */
    public void setNodeValue(Node contextNode, String newValue) {
        historyBrowser.addCommand
            (createChangeNodeValueCommand(contextNode, newValue));
    }

    /**
     * Creates and returns the ChangeNodeValue command.
     *
     * @param contextNode
     *            The node whose nodeValue changed
     * @param newValue
     *            The new node value
     * @return the ChangeNodeValue command
     */
    public ChangeNodeValueCommand
            createChangeNodeValueCommand(Node contextNode, String newValue) {
        return new ChangeNodeValueCommand
            (getChangeNodeValueCommandName(contextNode, newValue),
             contextNode, newValue);
    }

    /**
     * The Change Node Value command. Sets the given node value to the given
     * node.
     */
    public static class ChangeNodeValueCommand extends AbstractUndoableCommand {

        /**
         * The node whose value changed.
         */
        protected Node contextNode;

        /**
         * New node value.
         */
        protected String newValue;

        /**
         * Constructor.
         */
        public ChangeNodeValueCommand(String commandName, Node contextNode,
                                      String newValue) {
            setName(commandName);
            this.contextNode = contextNode;
            this.newValue = newValue;
        }

        public void execute() {
            String oldNodeValue = contextNode.getNodeValue();
            contextNode.setNodeValue(newValue);
            newValue = oldNodeValue;
        }

        public void undo() {
            execute();
        }

        public void redo() {
            execute();
        }

        public boolean shouldExecute() {
            if (contextNode == null) {
                return false;
            }
            return true;
        }
    }

    /**
     * Gets the current compound command.
     *
     * @return the currentCompoundCommand
     */
    public AbstractCompoundCommand getCurrentCompoundCommand() {
        if (currentCompoundCommand == null) {
            currentCompoundCommand =
                createCompoundUpdateCommand(OUTER_EDIT_COMMAND);
        }
        return currentCompoundCommand;
    }

    /**
     * Adds the given command to current compound command.
     *
     * @param cmd
     *            The command to add
     */
    public void addToCurrentCompoundCommand(AbstractUndoableCommand cmd) {
        getCurrentCompoundCommand().addCommand(cmd);
        // Fire the 'doCompoundEdit' event
        historyBrowser.fireDoCompoundEdit
            (new HistoryBrowserEvent(getCurrentCompoundCommand()));
    }

    /**
     * Adds and executes the current compound command to history browser.
     */
    public void performCurrentCompoundCommand() {
        if (getCurrentCompoundCommand().getCommandNumber() > 0) {
            historyBrowser.addCommand(getCurrentCompoundCommand());
            // Fire the 'compoundEditPerformed' event
            historyBrowser.fireCompoundEditPerformed
                (new HistoryBrowserEvent(currentCompoundCommand));
            // Reset the current compound command
            currentCompoundCommand = null;
        }
    }

    // Command names
    /**
     * Gets the node name and the nodes id (nodeName + "nodeId").
     *
     * @param node
     *            The given node
     * @return e.g. node name with quoted node id or node name if id is empty
     *         String
     */
    private String getNodeAsString(Node node) {
        String id = "";
        if (node.getNodeType() == Node.ELEMENT_NODE) {
            Element e = (Element) node;
            id = e.getAttributeNS(null, SVGConstants.SVG_ID_ATTRIBUTE);
        }
        if (id.length() != 0) {
            return node.getNodeName() + " \"" + id + "\"";
        }
        return node.getNodeName();
    }

    /**
     * Gets the node info in brackets.
     *
     * @param node
     *            The given node
     * @return e.g (rect "23")
     */
    private String getBracketedNodeName(Node node) {
        return "(" + getNodeAsString(node) + ")";
    }

    /**
     * Generates the "Append Child" command name.
     *
     * @param parentNode
     *            The parent node
     * @param childNode
     *            The child node
     * @return The command name
     */
    private String getAppendChildCommandName(Node parentNode, Node childNode) {
        return "Append " + getNodeAsString(childNode) + " to "
                + getNodeAsString(parentNode);
    }

    /**
     * Generates the "Insert Child Before" command name.
     *
     * @param parentNode
     *            The parentNode
     * @param childNode
     *            The node being inserted
     * @param siblingNode
     *            The new sibling node
     * @return The command name
     */
    private String getInsertBeforeCommandName(Node parentNode, Node childNode,
                                              Node siblingNode) {
        return "Insert " + getNodeAsString(childNode) + " to "
                + getNodeAsString(parentNode) + " before "
                + getNodeAsString(siblingNode);
    }

    /**
     * Generates the "Remove Child" command name.
     *
     * @param parent
     *            The parent node
     * @param child
     *            The child node
     * @return The command name
     */
    private String getRemoveChildCommandName(Node parent, Node child) {
        return "Remove " + getNodeAsString(child) + " from "
                + getNodeAsString(parent);
    }

    /**
     * Generates the "Change Node Value" command name.
     *
     * @param contextNode
     *            The node whose value is to be changed
     * @param newValue
     *            The new node value
     * @return The command name
     */
    private String getChangeNodeValueCommandName(Node contextNode,
                                                 String newValue) {
        return "Change " + getNodeAsString(contextNode) + " value to "
                + newValue;
    }

    /**
     * Generates the "Node Changed" command name.
     * @return    The command name
     */
    private String getNodeChangedCommandName(Node node) {
        return "Node " + getNodeAsString(node) + " changed";
    }
}
