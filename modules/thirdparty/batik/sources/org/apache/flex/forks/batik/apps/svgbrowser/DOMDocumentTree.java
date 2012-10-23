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

import java.awt.Component;
import java.awt.Graphics;
import java.awt.Insets;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.Transferable;
import java.awt.datatransfer.UnsupportedFlavorException;
import java.awt.dnd.Autoscroll;
import java.awt.dnd.DnDConstants;
import java.awt.dnd.DragGestureEvent;
import java.awt.dnd.DragGestureListener;
import java.awt.dnd.DragGestureRecognizer;
import java.awt.dnd.DragSource;
import java.awt.dnd.DragSourceDragEvent;
import java.awt.dnd.DragSourceDropEvent;
import java.awt.dnd.DragSourceEvent;
import java.awt.dnd.DragSourceListener;
import java.awt.dnd.DropTarget;
import java.awt.dnd.DropTargetContext;
import java.awt.dnd.DropTargetDragEvent;
import java.awt.dnd.DropTargetDropEvent;
import java.awt.dnd.DropTargetEvent;
import java.awt.dnd.DropTargetListener;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;
import java.util.ArrayList;
import java.util.EventListener;
import java.util.EventObject;
import java.util.Iterator;

import javax.swing.JPanel;
import javax.swing.JRootPane;
import javax.swing.JTree;
import javax.swing.JViewport;
import javax.swing.SwingUtilities;
import javax.swing.Timer;
import javax.swing.UIManager;
import javax.swing.event.EventListenerList;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.TreeNode;
import javax.swing.tree.TreePath;

import org.apache.flex.forks.batik.dom.util.DOMUtilities;
import org.apache.flex.forks.batik.apps.svgbrowser.DOMViewer.NodeInfo;

import org.w3c.dom.Node;

/**
 * A swing tree to represent DOM Document.
 */
public class DOMDocumentTree extends JTree implements Autoscroll {

    /**
     * Listeners list.
     */
    protected EventListenerList eventListeners = new EventListenerList();

    /**
     * The insets where autoscrolling is active.
     */
    protected Insets autoscrollInsets = new Insets(20, 20, 20, 20);

    /**
     * How much to scroll.
     */
    protected Insets scrollUnits = new Insets(25, 25, 25, 25);

    /**
     * The controller for this tree.
     */
    protected DOMDocumentTreeController controller;

    /**
     * Creates the DOMDocumentTree.
     *
     * @param root
     *            Root node
     * @param controller
     *            The tree controller
     */
    public DOMDocumentTree(TreeNode root, DOMDocumentTreeController controller) {
        super(root);
        this.controller = controller;
        new TreeDragSource(this, DnDConstants.ACTION_COPY_OR_MOVE);
        new DropTarget(this, new TreeDropTargetListener(this));
    }

    // DND Support

    /**
     * The JTree drag source wrapper.
     */
    public class TreeDragSource implements DragSourceListener,
                                           DragGestureListener {

        /**
         * The drag source.
         */
        protected DragSource source;

        /**
         * The drag gesture recognizer.
         */
        protected DragGestureRecognizer recognizer;

        /**
         * The transferable tree node(s).
         */
        protected TransferableTreeNode transferable;

        /**
         * The sourceTree.
         */
        protected DOMDocumentTree sourceTree;

        /**
         * Constructor.
         *
         * @param tree
         *            The source tree
         * @param actions
         *            The permitted action
         */
        public TreeDragSource(DOMDocumentTree tree, int actions) {
            sourceTree = tree;
            source = new DragSource();
            recognizer =
                source.createDefaultDragGestureRecognizer(sourceTree, actions,
                                                          this);
        }

        public void dragGestureRecognized(DragGestureEvent dge) {
            if (!controller.isDNDSupported()) {
                return;
            }
            TreePath[] paths = sourceTree.getSelectionPaths();
            // If an empty selection is 'being dragged'
            if (paths == null) {
                return;
            }
            ArrayList nodeList = new ArrayList();
            for (int i = 0; i < paths.length; i++) {
                TreePath path = paths[i];
                // If the root node 'being dragged'
                if (path.getPathCount() > 1) {
                    DefaultMutableTreeNode node =
                        (DefaultMutableTreeNode) path.getLastPathComponent();
                    Node associatedNode = getDomNodeFromTreeNode(node);
                    if (associatedNode != null) {
                        nodeList.add(associatedNode);
                    }
                }
            }
            if (nodeList.isEmpty()) {
                return;
            }
            transferable = new TransferableTreeNode(new TransferData(nodeList));

            // Sets the default cursor behavior
            source.startDrag(dge, null, transferable, this);
        }

        public void dragEnter(DragSourceDragEvent dsde) {
        }

        public void dragExit(DragSourceEvent dse) {
        }

        public void dragOver(DragSourceDragEvent dsde) {
        }

        public void dropActionChanged(DragSourceDragEvent dsde) {
        }

        public void dragDropEnd(DragSourceDropEvent dsde) {
        }
    }

    /**
     * Tree as a drop target listener.
     */
    public class TreeDropTargetListener implements DropTargetListener {

        /**
         * Insert node before the current node.
         */
        private static final int BEFORE = 1;

        /**
         * Insert node after the current node.
         */
        private static final int AFTER = 2;

        /**
         * Insert node as a child of the current node.
         */
        private static final int CURRENT = 3;

        /**
         * The associated transfer data.
         */
        private TransferData transferData;

        /**
         * The original glass pane of the tree is stored here.
         */
        private Component originalGlassPane;

        /**
         * The vertical offset where to catch the 'visual tips' of the tree node
         * items rectangle.
         */
        private int visualTipOffset = 5;

        /**
         * The thickness of the visual tip.
         */
        private int visualTipThickness = 2;

        /**
         * Indicates the potential drop position relative to the current node
         * where the dragged nodes are to be inserted.
         */
        private int positionIndicator;

        /**
         * The start point of the 'visual tip' line.
         */
        private Point startPoint;

        /**
         * The end point of the 'visual tip' line.
         */
        private Point endPoint;

        /**
         * Glasspane where 'visual tip' line is drawn
         */
        protected JPanel visualTipGlassPane = new JPanel() {
            public void paint(Graphics g) {
                g.setColor(UIManager.getColor("Tree.selectionBackground"));
                if (startPoint == null || endPoint == null) {
                    return;
                }
                int x1 = startPoint.x;
                int x2 = endPoint.x;
                int y1 = startPoint.y;

                // Draws the visualTipThickness number of lines
                int start = -visualTipThickness / 2;
                start += visualTipThickness % 2 == 0 ? 1 : 0;
                for (int i = start; i <= visualTipThickness / 2; i++) {
                    g.drawLine(x1 + 2, y1 + i, x2 - 2, y1 + i);
                }
            }
        };

        /**
         * The timer that controls the delay of expanding the tree path that is
         * being dragged over.
         */
        private Timer expandControlTimer;

        /**
         * The delay for expanding.
         */
        private int expandTimeout = 1500;

        /**
         * The tree path that is being dragged over.
         */
        private TreePath dragOverTreePath;

        /**
         * The tree path that is scheduled for expand.
         */
        private TreePath treePathToExpand;

        /**
         * Constructor.
         */
        public TreeDropTargetListener(DOMDocumentTree tree) {
            addOnAutoscrollListener(tree);
        }

        public void dragEnter(DropTargetDragEvent dtde) {
            JTree tree = (JTree) dtde.getDropTargetContext().getComponent();
            JRootPane rootPane = tree.getRootPane();
            // Set glass pane
            originalGlassPane = rootPane.getGlassPane();
            rootPane.setGlassPane(visualTipGlassPane);
            visualTipGlassPane.setOpaque(false);
            visualTipGlassPane.setVisible(true);
            updateVisualTipLine(tree, null);
            // Set transferable
            try {
                // XXX Java 1.3 and 1.4 workaround for:
                // http://bugs.sun.com/bugdatabase/view_bug.do?bug_id=4378091
                Transferable transferable =
                    new DropTargetDropEvent(dtde.getDropTargetContext(),
                                            dtde.getLocation(), 0, 0)
                        .getTransferable();
                // Transferable transferable = dtde.getTransferable();
                DataFlavor[] flavors = transferable.getTransferDataFlavors();
                for (int i = 0; i < flavors.length; i++) {
                    if (transferable.isDataFlavorSupported(flavors[i])) {
                        transferData = (TransferData) transferable
                                .getTransferData(flavors[i]);
                        return;
                    }
                }
            } catch (UnsupportedFlavorException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        public void dragOver(DropTargetDragEvent dtde) {
            JTree tree = (JTree) dtde.getDropTargetContext().getComponent();
            TreeNode targetTreeNode = getNode(dtde);
            if (targetTreeNode != null) {
                // Get the parent and sibling paths and nodes
                updatePositionIndicator(dtde);
                Point p = dtde.getLocation();
                TreePath currentPath = tree.getPathForLocation(p.x, p.y);
                TreePath parentPath = getParentPathForPosition(currentPath);
                TreeNode parentNode = getNodeForPath(parentPath);
                TreePath nextSiblingPath =
                    getSiblingPathForPosition(currentPath);
                TreeNode nextSiblingNode = getNodeForPath(nextSiblingPath);
                Node potentialParent =
                    getDomNodeFromTreeNode((DefaultMutableTreeNode) parentNode);
                Node potentialSibling =
                    getDomNodeFromTreeNode
                        ((DefaultMutableTreeNode) nextSiblingNode);
                // Check the drop target:
                // - Checks if any node from the dragged nodes can be appended
                // to the parent node
                // - Checks whether the sibling node is among the nodes being
                // dragged
                if (DOMUtilities.canAppendAny(transferData.getNodeList(),
                                              potentialParent)
                        && !transferData.getNodeList()
                            .contains(potentialSibling)) {
                    dtde.acceptDrag(dtde.getDropAction());
                    // Draw the 'visual tip' line
                    updateVisualTipLine(tree, currentPath);
                    // Expand the path
                    dragOverTreePath = currentPath;
                    if (!tree.isExpanded(currentPath)) {
                        scheduleExpand(currentPath, tree);
                    }
                } else {
                    dtde.rejectDrag();
                }
            } else {
                dtde.rejectDrag();
            }
        }

        public void dropActionChanged(DropTargetDragEvent dtde) {
        }

        public void drop(DropTargetDropEvent dtde) {
            Point p = dtde.getLocation();
            DropTargetContext dtc = dtde.getDropTargetContext();
            JTree tree = (JTree) dtc.getComponent();
            // Sets the original glass pane
            setOriginalGlassPane(tree);
            // Cancel tree item expanding
            dragOverTreePath = null;
            // Get the parent and sibling paths and nodes
            TreePath currentPath = tree.getPathForLocation(p.x, p.y);
            DefaultMutableTreeNode parent =
                (DefaultMutableTreeNode) getNodeForPath
                    (getParentPathForPosition(currentPath));
            Node dropTargetNode = getDomNodeFromTreeNode(parent);
            DefaultMutableTreeNode sibling =
                (DefaultMutableTreeNode)
                    getNodeForPath(getSiblingPathForPosition(currentPath));
            Node siblingNode = getDomNodeFromTreeNode(sibling);
            if (this.transferData != null) {
                ArrayList nodelist =
                    getNodeListForParent(this.transferData.getNodeList(),
                                         dropTargetNode);
                fireDropCompleted
                    (new DOMDocumentTreeEvent
                        (new DropCompletedInfo
                            (dropTargetNode, siblingNode, nodelist)));
                dtde.dropComplete(true);
                return;
            }
            dtde.rejectDrop();
        }

        public void dragExit(DropTargetEvent dte) {
            setOriginalGlassPane
                ((JTree) dte.getDropTargetContext().getComponent());
            // Set the current dragover path
            dragOverTreePath = null;
        }

        /**
         * Sets the position indicator according to the current cursor location.
         *
         * @param dtde
         *            DropTargetDragEvent
         */
        private void updatePositionIndicator(DropTargetDragEvent dtde) {
            Point p = dtde.getLocation();
            DropTargetContext dtc = dtde.getDropTargetContext();
            JTree tree = (JTree) dtc.getComponent();
            // Current path
            TreePath currentPath = tree.getPathForLocation(p.x, p.y);
            Rectangle bounds = tree.getPathBounds(currentPath);
            // Upper area of the tree node
            if (p.y <= bounds.y + visualTipOffset) {
                positionIndicator = BEFORE;
            }
            // Lower area of the tree node
            else if (p.y >= bounds.y + bounds.height - visualTipOffset) {
                positionIndicator = AFTER;
            }
            // Somewhere between the upper and the lower area of the tree node
            else {
                positionIndicator = CURRENT;
            }
        }

        /**
         * Finds the parent TreePath of the given current path, according to the
         * position indicator, where the dragged nodes should be appended.
         *
         * @param currentPath
         *            The current path (the items are dragged over this path)
         * @param positionIndicator
         *            AFTER or BEFORE - nodes should be appended to the parent
         *            path of the given path, as siblings of the current path
         *            CURRENT - nodes should be appended to the current path, as
         *            its children
         * @return TreePath where dragged nodes are to be inserted
         */
        private TreePath getParentPathForPosition(TreePath currentPath) {
            if (currentPath == null) {
                return null;
            }
            TreePath parentPath = null;
            if (positionIndicator == AFTER) {
                parentPath = currentPath.getParentPath();
            } else if (positionIndicator == BEFORE) {
                parentPath = currentPath.getParentPath();
            } else if (positionIndicator == CURRENT) {
                parentPath = currentPath;
            }
            return parentPath;
        }

        /**
         * Finds the TreePath that is going to be next sibling to the nodes that
         * are being dragged.
         *
         * @param currentPath
         *            The current path (the items are dragged over this path)
         * @return sibling TreePath
         */
        private TreePath getSiblingPathForPosition(TreePath currentPath) {
            TreePath parentPath = getParentPathForPosition(currentPath);
            TreePath nextSiblingPath = null;
            if (positionIndicator == AFTER) {
                TreeNode parentNode = getNodeForPath(parentPath);
                TreeNode currentNode = getNodeForPath(currentPath);
                if (parentPath != null && parentNode != null
                        && currentNode != null) {
                    int siblingIndex = parentNode.getIndex(currentNode) + 1;
                    if (parentNode.getChildCount() > siblingIndex) {
                        nextSiblingPath =
                            parentPath.pathByAddingChild
                                (parentNode.getChildAt(siblingIndex));
                    }
                }
            } else if (positionIndicator == BEFORE) {
                nextSiblingPath = currentPath;
            } else if (positionIndicator == CURRENT) {
                nextSiblingPath = null;
            }
            return nextSiblingPath;
        }

        /**
         * Gets the TreeNode from the given TreePath.
         *
         * @param path
         *            The given TreePath
         * @return The TreeNode
         */
        private TreeNode getNodeForPath(TreePath path) {
            if (path == null || path.getLastPathComponent() == null) {
                return null;
            }
            return (TreeNode) path.getLastPathComponent();
        }

        /**
         * Gets the TreeNode from the DropTargetDragEvent
         *
         * @param dtde
         *            The DropTargetDragEvent
         * @return Associated TreeNode or null
         */
        private TreeNode getNode(DropTargetDragEvent dtde) {
            Point p = dtde.getLocation();
            DropTargetContext dtc = dtde.getDropTargetContext();
            JTree tree = (JTree) dtc.getComponent();
            TreePath path = tree.getPathForLocation(p.x, p.y);
            if (path == null || path.getLastPathComponent() == null) {
                return null;
            }
            return (TreeNode) path.getLastPathComponent();
        }

        // Visual tips
        /**
         * Draws the 'visual tip' line on the glass pane.
         *
         * @param tree
         *            The tree
         * @param path
         *            The path to get the bounds
         */
        private void updateVisualTipLine(JTree tree, TreePath path) {
            if (path == null) {
                startPoint = null;
                endPoint = null;
            } else {
                Rectangle bounds = tree.getPathBounds(path);
                if (positionIndicator == BEFORE) {
                    startPoint = bounds.getLocation();
                    endPoint = new Point(startPoint.x + bounds.width,
                            startPoint.y);
                } else if (positionIndicator == AFTER) {
                    startPoint = new Point(bounds.x, bounds.y + bounds.height);
                    endPoint = new Point(startPoint.x + bounds.width,
                            startPoint.y);
                    positionIndicator = AFTER;
                } else if (positionIndicator == CURRENT) {
                    startPoint = null;
                    endPoint = null;
                }
                if (startPoint != null && endPoint != null) {
                    startPoint = SwingUtilities.convertPoint(tree, startPoint,
                            visualTipGlassPane);
                    endPoint = SwingUtilities.convertPoint(tree, endPoint,
                            visualTipGlassPane);
                }
            }
            visualTipGlassPane.getRootPane().repaint();
        }

        /**
         * Adds the onAutoscroll listener.
         *
         * @param tree
         *            The DOMDocumentTree
         */
        private void addOnAutoscrollListener(DOMDocumentTree tree) {
            tree.addListener(new DOMDocumentTreeAdapter() {
                public void onAutoscroll(DOMDocumentTreeEvent event) {
                    // Whenever autoscroll is triggered,
                    // the 'visual tip' line should be hidden
                    startPoint = null;
                    endPoint = null;
                }
            });
        }

        /**
         * Sets the original glass pane.
         *
         * @param dte
         *            DropTargetEvent to get the tree
         */
        private void setOriginalGlassPane(JTree tree) {
            JRootPane rootPane = tree.getRootPane();
            rootPane.setGlassPane(originalGlassPane);
            originalGlassPane.setVisible(false);
            rootPane.repaint();
        }

        // Expand scheduling
        /**
         * Schedules the expand of the given treePath on a tree.
         *
         * @param treePath
         *            The treePath to expand
         * @param tree
         *            The JTree
         */
        private void scheduleExpand(TreePath treePath, JTree tree) {
            // If the treepath to schedule for expand isn't already scheduled
            if (treePath != treePathToExpand) {
                getExpandTreeTimer(tree).stop();
                treePathToExpand = treePath;
                getExpandTreeTimer(tree).start();
            }
        }

        /**
         * Gets the timer for treepath expand.
         *
         * @param tree
         *            The JTree
         * @return Timer
         */
        private Timer getExpandTreeTimer(final JTree tree) {
            if (expandControlTimer == null) {
                expandControlTimer = new Timer(expandTimeout,
                        new ActionListener() {
                            public void actionPerformed(ActionEvent arg0) {
                                // If the treepath scheduled for expand is the
                                // same one that is being dragged over
                                if (treePathToExpand != null
                                        && treePathToExpand == dragOverTreePath) {
                                    tree.expandPath(treePathToExpand);
                                }
                                getExpandTreeTimer(tree).stop();
                            }
                        });
            }
            return expandControlTimer;
        }
    }

    /**
     * Transferable tree node.
     */
    public static class TransferableTreeNode implements Transferable {

        /**
         * A flavor that supports the node transfer.
         */
        protected static final DataFlavor NODE_FLAVOR =
            new DataFlavor(TransferData.class, "TransferData");

        /**
         * The supported flavors.
         */
        protected static final DataFlavor[] FLAVORS =
            new DataFlavor[] { NODE_FLAVOR, DataFlavor.stringFlavor };

        /**
         * The data being transfered.
         */
        protected TransferData data;

        public TransferableTreeNode(TransferData data) {
            this.data = data;
        }

        public synchronized DataFlavor[] getTransferDataFlavors() {
            return FLAVORS;
        }

        /**
         * Checks if the given date flavor is supported.
         *
         * @param flavor
         *            DataFlavor
         * @return boolean
         */
        public boolean isDataFlavorSupported(DataFlavor flavor) {
            for (int i = 0; i < FLAVORS.length; i++) {
                if (flavor.equals(FLAVORS[i])) {
                    return true;
                }
            }
            return false;
        }

        /**
         * Data that is being transfered.
         *
         * @param flavor
         *            DataFlavor
         * @return (TransferData data, String xmlString)
         */
        public synchronized Object getTransferData(DataFlavor flavor) {
            if (!isDataFlavorSupported(flavor)) {
                return null;
            }
            if (flavor.equals(NODE_FLAVOR)) {
                return data;
            } else if (flavor.equals(DataFlavor.stringFlavor)) {
                return data.getNodesAsXML();
            } else {
                return null;
            }
        }
    }

    /**
     * The data being transfered on dnd.
     */
    public static class TransferData {

        /**
         * The nodes to transfer.
         */
        protected ArrayList nodeList;

        /**
         * Creates the TransferData.
         *
         * @param nodeList
         *            the nodeList
         */
        public TransferData(ArrayList nodeList) {
            this.nodeList = nodeList;
        }

        /**
         * Gets the nodeList.
         *
         * @return the nodeList
         */
        public ArrayList getNodeList() {
            return nodeList;
        }

        /**
         * Gets the concatenated string representation of the nodes in the node
         * list. (To support string data flavor)
         */
        public String getNodesAsXML() {
            String toReturn = "";
            Iterator iterator = nodeList.iterator();
            while (iterator.hasNext()) {
                Node node = (Node) iterator.next();
                toReturn += DOMUtilities.getXML(node);
            }
            return toReturn;
        }
    }

    // Autoscroll support

    public void autoscroll(Point point) {
        JViewport viewport =
            (JViewport) SwingUtilities.getAncestorOfClass(JViewport.class,
                                                          this);
        if (viewport == null) {
            return;
        }

        Point viewportPos = viewport.getViewPosition();
        int viewHeight = viewport.getExtentSize().height;
        int viewWidth = viewport.getExtentSize().width;

        // Scroll
        if ((point.y - viewportPos.y) < autoscrollInsets.top) {
            // Up
            viewport.setViewPosition
                (new Point(viewportPos.x,
                           Math.max(viewportPos.y - scrollUnits.top, 0)));
            fireOnAutoscroll(new DOMDocumentTreeEvent(this));
        } else if ((viewportPos.y + viewHeight - point.y)
                    < autoscrollInsets.bottom) {
            // Down
            viewport.setViewPosition
                (new Point(viewportPos.x,
                           Math.min(viewportPos.y + scrollUnits.bottom,
                                    getHeight() - viewHeight)));
            fireOnAutoscroll(new DOMDocumentTreeEvent(this));
        } else if ((point.x - viewportPos.x) < autoscrollInsets.left) {
            // Left
            viewport.setViewPosition
                (new Point(Math.max(viewportPos.x - scrollUnits.left, 0),
                           viewportPos.y));
            fireOnAutoscroll(new DOMDocumentTreeEvent(this));
        } else if ((viewportPos.x + viewWidth - point.x)
                    < autoscrollInsets.right) {
            // Right
            viewport.setViewPosition
                (new Point(Math.min(viewportPos.x + scrollUnits.right,
                                    getWidth() - viewWidth),
                           viewportPos.y));
            fireOnAutoscroll(new DOMDocumentTreeEvent(this));
        }
    }

    public Insets getAutoscrollInsets() {
        int topAndBottom = getHeight();
        int leftAndRight = getWidth();
        return new Insets
            (topAndBottom, leftAndRight, topAndBottom, leftAndRight);
    }

    // Custom event support

    /**
     * Event to pass to listener.
     */
    public static class DOMDocumentTreeEvent extends EventObject {

        public DOMDocumentTreeEvent(Object source) {
            super(source);
        }
    }

    /**
     * The DOMDocumentTreeListener.
     */
    public static interface DOMDocumentTreeListener extends EventListener {

        /**
         * Fired after successfully completed drop.
         *
         * @param event
         *            the DOMDocumentTreeEvent
         */
        void dropCompleted(DOMDocumentTreeEvent event);

        /**
         * Fired when autoscroll is invoked
         *
         * @param event
         *            the DOMDocumentTreeEvent
         */
        void onAutoscroll(DOMDocumentTreeEvent event);
    }

    /**
     * The adapter for the DOMDocumentTreeListener.
     */
    public static class DOMDocumentTreeAdapter
            implements DOMDocumentTreeListener {

        public void dropCompleted(DOMDocumentTreeEvent event) {
        }

        public void onAutoscroll(DOMDocumentTreeEvent event) {
        }
    }

    /**
     * Adds the listener to the listener list.
     *
     * @param listener
     *            The listener to add
     */
    public void addListener(DOMDocumentTreeListener listener) {
        eventListeners.add(DOMDocumentTreeListener.class, listener);
    }

    /**
     * Fires the dropCompleted event.
     *
     * @param event
     *            The associated DndTreeSupportEvent event
     */
    public void fireDropCompleted(DOMDocumentTreeEvent event) {
        Object[] listeners = eventListeners.getListenerList();
        int length = listeners.length;
        for (int i = 0; i < length; i += 2) {
            if (listeners[i] == DOMDocumentTreeListener.class) {
                ((DOMDocumentTreeListener) listeners[i + 1])
                        .dropCompleted(event);
            }
        }
    }

    /**
     * Fires the dropCompleted event.
     *
     * @param event
     *            The associated DndTreeSupportEvent event
     */
    public void fireOnAutoscroll(DOMDocumentTreeEvent event) {
        Object[] listeners = eventListeners.getListenerList();
        int length = listeners.length;
        for (int i = 0; i < length; i += 2) {
            if (listeners[i] == DOMDocumentTreeListener.class) {
                ((DOMDocumentTreeListener) listeners[i + 1])
                        .onAutoscroll(event);
            }
        }
    }

    /**
     * Contains the info for the 'dropCompleted' Event.
     */
    public static class DropCompletedInfo {

        /**
         * Parent node.
         */
        protected Node parent;

        /**
         * Nodes to be appended.
         */
        protected ArrayList children;

        /**
         * Next sibling node.
         */
        protected Node sibling;

        /**
         * @param parent
         *            Parent node
         * @param children
         *            Nodes to be appended
         */
        public DropCompletedInfo(Node parent, Node sibling,
                                 ArrayList children) {
            this.parent = parent;
            this.sibling = sibling;
            this.children = children;
        }

        /**
         * Gets the children.
         *
         * @return the children
         */
        public ArrayList getChildren() {
            return children;
        }

        /**
         * Getter for the parent.
         *
         * @return the parent
         */
        public Node getParent() {
            return parent;
        }

        /**
         * Getter for the sibling.
         *
         * @return the sibling
         */
        public Node getSibling() {
            return sibling;
        }
    }

    // Utility methods

    /**
     * Gets the associated org.w3c.dom.Node from the DefaultMutableTreeNode
     *
     * @param treeNode
     *            The given DefaultMutableTreeNode
     * @return the associated Node
     */
    protected Node getDomNodeFromTreeNode(DefaultMutableTreeNode treeNode) {
        if (treeNode == null) {
            return null;
        }
        if (treeNode.getUserObject() instanceof NodeInfo) {
            return ((NodeInfo) treeNode.getUserObject()).getNode();
        }
        return null;
    }

    /**
     * Finds and returns a group of nodes that can be appended to the given
     * parent node.
     *
     * @param potentialChildren
     *            The given potential children
     * @param parentNode
     *            The given parent node
     * @return list of nodes that can be appended to the given parent
     */
    protected ArrayList getNodeListForParent(ArrayList potentialChildren,
                                             Node parentNode) {
        ArrayList children = new ArrayList();
        int n = potentialChildren.size();
        for (int i = 0; i < n; i++) {
            Node node = (Node) potentialChildren.get(i);
            if (DOMUtilities.canAppend(node, parentNode)) {
                children.add(node);
            }
        }
        return children;
    }
}
