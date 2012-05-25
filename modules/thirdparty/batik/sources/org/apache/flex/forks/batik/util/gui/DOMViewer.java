/*

   Copyright 2000,2002-2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.util.gui;

import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.ResourceBundle;

import javax.swing.AbstractAction;
import javax.swing.Action;
import javax.swing.BorderFactory;
import javax.swing.ImageIcon;
import javax.swing.JCheckBox;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSplitPane;
import javax.swing.JTable;
import javax.swing.JTextArea;
import javax.swing.JTree;
import javax.swing.event.TreeSelectionEvent;
import javax.swing.event.TreeSelectionListener;
import javax.swing.table.AbstractTableModel;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.DefaultTreeCellRenderer;
import javax.swing.tree.DefaultTreeModel;
import javax.swing.tree.MutableTreeNode;
import javax.swing.tree.TreeNode;

import org.apache.flex.forks.batik.util.gui.resource.ActionMap;
import org.apache.flex.forks.batik.util.gui.resource.ButtonFactory;
import org.apache.flex.forks.batik.util.gui.resource.MissingListenerException;
import org.apache.flex.forks.batik.util.gui.resource.ResourceManager;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.css.CSSStyleDeclaration;
import org.w3c.dom.css.ViewCSS;

/**
 * The components of this class are used to view a DOM tree.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: DOMViewer.java,v 1.8 2005/02/12 01:48:24 deweese Exp $
 */
public class DOMViewer extends JFrame implements ActionMap {
    /**
     * The resource file name
     */
    protected final static String RESOURCE =
	"org.apache.flex.forks.batik.util.gui.resources.DOMViewerMessages";

    /**
     * The resource bundle
     */
    protected static ResourceBundle bundle;

    /**
     * The resource manager
     */
    protected static ResourceManager resources;

    static {
        bundle = ResourceBundle.getBundle(RESOURCE, Locale.getDefault());
        resources = new ResourceManager(bundle);
    }

    /**
     * The map that contains the listeners
     */
    protected Map listeners = new HashMap();

    /**
     * The panel.
     */
    protected Panel panel = new Panel();

    protected boolean showWhitespace = true;

    /**
     * Creates a new DOMViewer panel.
     */
    public DOMViewer() {
	super(resources.getString("Frame.title"));
	setSize(resources.getInteger("Frame.width"),
		resources.getInteger("Frame.height"));

	listeners.put("CloseButtonAction", new CloseButtonAction());
	
	getContentPane().add(panel);

        JPanel p = new JPanel(new BorderLayout());
        
        JCheckBox cb = new JCheckBox("Show Whitespace Text Nodes");
        cb.setSelected(showWhitespace);
        cb.addItemListener(new ItemListener() {
                public void itemStateChanged(ItemEvent ie) {
                    setShowWhitespace
                        (ie.getStateChange() == ItemEvent.SELECTED);
                }
            });

        p.add(cb, BorderLayout.WEST);
        

        ButtonFactory bf = new ButtonFactory(bundle, this);
        p.add(bf.createJButton("CloseButton"), BorderLayout.EAST);
	getContentPane().add("South", p);
    }

    public void setShowWhitespace(boolean state) {
        showWhitespace = state;
        if (panel.document != null)
            panel.setDocument(panel.document);
    }

    /**
     * Sets the document to display.
     */
    public void setDocument(Document doc) {
	panel.setDocument(doc);
    }

    /**
     * Sets the document to display and its ViewCSS.
     */
    public void setDocument(Document doc, ViewCSS view) {
	panel.setDocument(doc, view);
    }

    /**
     * Returns the action associated with the given string
     * or null on error
     * @param key the key mapped with the action to get
     * @throws MissingListenerException if the action is not found
     */
    public Action getAction(String key) throws MissingListenerException {
        return (Action)listeners.get(key);
    }

    /**
     * The action associated with the 'Close' button of the viewer panel
     */
    protected class CloseButtonAction extends AbstractAction {
        public void actionPerformed(ActionEvent e) {
            dispose();
        }
    }

    /**
     * The panel that contains the viewer.
     */
    public class Panel extends JPanel {
	/**
	 * The DOM document.
	 */
	protected Document document;

	/**
	 * The ViewCSS object associated with the document.
	 */
	protected ViewCSS viewCSS;

	/**
	 * The tree.
	 */
	protected JTree tree;

	/**
	 * The split pane.
	 */
	protected JSplitPane splitPane;

	/**
	 * The right panel.
	 */
	protected JPanel rightPanel = new JPanel(new BorderLayout());

	/**
	 * The attributes table.
	 */
	protected JTable attributesTable = new JTable();

	/**
	 * The properties table.
	 */
	protected JTable propertiesTable = new JTable();

	/**
	 * The element panel.
	 */
	protected JPanel elementPanel = new JPanel(new GridLayout(2, 1));
	{
	    JScrollPane pane = new JScrollPane();
	    pane.setBorder(BorderFactory.createCompoundBorder
			   (BorderFactory.createEmptyBorder(2, 0, 2, 2),
			    BorderFactory.createCompoundBorder
			    (BorderFactory.createTitledBorder
			     (BorderFactory.createEmptyBorder(),
			      resources.getString("AttributesPanel.title")),
			     BorderFactory.createLoweredBevelBorder())));
	    pane.getViewport().add(attributesTable);
			
	    JScrollPane pane2 = new JScrollPane();
	    pane2.setBorder(BorderFactory.createCompoundBorder
			    (BorderFactory.createEmptyBorder(2, 0, 2, 2),
			     BorderFactory.createCompoundBorder
			     (BorderFactory.createTitledBorder
			      (BorderFactory.createEmptyBorder(),
			       resources.getString("CSSValuesPanel.title")),
			      BorderFactory.createLoweredBevelBorder())));
	    pane2.getViewport().add(propertiesTable);
			
	    elementPanel.add(pane);
	    elementPanel.add(pane2);
	}

	/**
	 * The CharacterData panel text area.
	 */
	protected JTextArea characterData = new JTextArea();

	/**
	 * The CharacterData node panel.
	 */
	protected JPanel characterDataPanel = new JPanel(new BorderLayout());
	{
	    characterDataPanel.setBorder
                (BorderFactory.createCompoundBorder
                 (BorderFactory.createEmptyBorder(2, 0, 2, 2),
                  BorderFactory.createCompoundBorder
                  (BorderFactory.createTitledBorder
                   (BorderFactory.createEmptyBorder(),
                    resources.getString("CDataPanel.title")),
                   BorderFactory.createLoweredBevelBorder())));
	    JScrollPane pane = new JScrollPane();
	    pane.getViewport().add(characterData);
	    characterDataPanel.add(pane);
	    characterData.setEditable(false);
	}

	/**
	 * The documentInfo panel text area.
	 */
	protected JTextArea documentInfo = new JTextArea();

	/**
	 * The documentInfo node panel.
	 */
	protected JPanel documentInfoPanel = new JPanel(new BorderLayout());
	{
	    documentInfoPanel.setBorder
                (BorderFactory.createCompoundBorder
                 (BorderFactory.createEmptyBorder(2, 0, 2, 2),
                  BorderFactory.createCompoundBorder
                  (BorderFactory.createTitledBorder
                   (BorderFactory.createEmptyBorder(),
                    resources.getString("DocumentInfoPanel.title")),
                   BorderFactory.createLoweredBevelBorder())));
	    JScrollPane pane = new JScrollPane();
	    pane.getViewport().add(documentInfo);
	    documentInfoPanel.add(pane);
	    documentInfo.setEditable(false);
	}

	/**
	 * Creates a new Panel object.
	 */
	public Panel() {
	    super(new BorderLayout());
	    setBorder(BorderFactory.createTitledBorder
		      (BorderFactory.createEmptyBorder(),
		       resources.getString("DOMViewerPanel.title")));

	    TreeNode root;
	    root = new DefaultMutableTreeNode
                (resources.getString("EmptyDocument.text"));
	    tree = new JTree(root);
	    tree.setCellRenderer(new NodeRenderer());
	    tree.putClientProperty("JTree.lineStyle", "Angled");

	    JScrollPane treePane = new JScrollPane();
	    treePane.setBorder(BorderFactory.createCompoundBorder
			       (BorderFactory.createEmptyBorder(2, 2, 2, 0),
				BorderFactory.createCompoundBorder
				(BorderFactory.createTitledBorder
				 (BorderFactory.createEmptyBorder(),
				  resources.getString("DOMViewer.title")),
				 BorderFactory.createLoweredBevelBorder())));
	    treePane.getViewport().add(tree);
	    splitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT,
				       true, // Continuous layout
				       treePane,
				       rightPanel);
	    int loc = resources.getInteger("SplitPane.dividerLocation");
	    splitPane.setDividerLocation(loc);
	    add(splitPane);
	    
	    tree.addTreeSelectionListener(new DOMTreeSelectionListener());
	}

	/**
	 * Sets the document to display.
	 */
	public void setDocument(Document doc) {
	    setDocument(doc, null);
	}

	/**
	 * Sets the document to display and its ViewCSS.
	 */
	public void setDocument(Document doc, ViewCSS view) {
	    document = doc;
	    viewCSS  = view;
	    TreeNode root = createTree(doc, showWhitespace);
	    ((DefaultTreeModel)tree.getModel()).setRoot(root);
	    if (rightPanel.getComponentCount() != 0) {
		rightPanel.remove(0);
		splitPane.revalidate();
		splitPane.repaint();
	    }
	}

	/**
	 * Creates a swing tree from a DOM document.
	 */
	protected MutableTreeNode createTree(Node node, 
                                             boolean showWhitespace) {
	    DefaultMutableTreeNode result;
	    result = new DefaultMutableTreeNode(new NodeInfo(node));
	    for (Node n = node.getFirstChild();
                 n != null;
                 n = n.getNextSibling()) {
                if (!showWhitespace && (n instanceof org.w3c.dom.Text)) {
                    String txt = n.getNodeValue();
                    if (txt.trim().length() == 0)
                        continue;
                }
                    result.add(createTree(n, showWhitespace));
	    }
	    return result;
	}

	/**
	 * To listen to the tree selection.
	 */
	protected class DOMTreeSelectionListener
            implements TreeSelectionListener {
	    /**
	     * Called when the selection changes.
	     */
	    public void valueChanged(TreeSelectionEvent ev) {
		DefaultMutableTreeNode mtn;
		mtn =
                    (DefaultMutableTreeNode)tree.getLastSelectedPathComponent();
		if (mtn == null) {
		    return;
		}

		if (rightPanel.getComponentCount() != 0) {
		    rightPanel.remove(0);
		}

		Object nodeInfo = mtn.getUserObject();
		if (nodeInfo instanceof NodeInfo) {
		    Node node = ((NodeInfo)nodeInfo).getNode();
		    switch (node.getNodeType()) {
		    case Node.DOCUMENT_NODE:
			documentInfo.setText
                            (createDocumentText((Document)node));
			rightPanel.add(documentInfoPanel);
                        break;
		    case Node.ELEMENT_NODE:
			attributesTable.setModel(new NodeAttributesModel(node));
			propertiesTable.setModel(new NodeCSSValuesModel(node));
			rightPanel.add(elementPanel);
			break;
		    case Node.COMMENT_NODE:
		    case Node.TEXT_NODE:
		    case Node.CDATA_SECTION_NODE:
			characterData.setText(node.getNodeValue());
			rightPanel.add(characterDataPanel);
		    }
		}
		splitPane.revalidate();
		splitPane.repaint();
	    }

            protected String createDocumentText(Document doc) {
                StringBuffer sb = new StringBuffer();
                sb.append("Nodes: ");
                sb.append(nodeCount(doc));
                return sb.toString();
            }

            protected int nodeCount(Node node) {
                int result = 1;
                for (Node n = node.getFirstChild();
                     n != null;
                     n = n.getNextSibling()) {
                    result += nodeCount(n);
                }
                return result;
            }
	}

	/**
	 * To render the tree nodes.
	 */
	protected class NodeRenderer extends DefaultTreeCellRenderer {
	    /**
	     * The icon used to represent elements.
	     */
	    ImageIcon elementIcon;

	    /**
	     * The icon used to represent comments.
	     */
	    ImageIcon commentIcon;

	    /**
	     * The icon used to represent processing instructions.
	     */
	    ImageIcon piIcon;

	    /**
	     * The icon used to represent text.
	     */
	    ImageIcon textIcon;

	    /**
	     * Creates a new NodeRenderer object.
	     */
	    public NodeRenderer() {
		String s;
		s = resources.getString("Element.icon");
		elementIcon = new ImageIcon(getClass().getResource(s));
		s = resources.getString("Comment.icon");
		commentIcon = new ImageIcon(getClass().getResource(s));
		s = resources.getString("PI.icon");
		piIcon = new ImageIcon(getClass().getResource(s));
		s = resources.getString("Text.icon");
		textIcon = new ImageIcon(getClass().getResource(s));
	    }

	    /**
	     * Sets the value of the current tree cell.
	     */
	    public Component getTreeCellRendererComponent(JTree tree,
							  Object value,
							  boolean sel,
							  boolean expanded,
							  boolean leaf,
							  int row,
							  boolean hasFocus) {
		super.getTreeCellRendererComponent(tree, value, sel, expanded,
						   leaf, row, hasFocus);
		switch (getNodeType(value)) {
		case Node.ELEMENT_NODE:
		    setIcon(elementIcon);
		    break;
		case Node.COMMENT_NODE:
		    setIcon(commentIcon);
		    break;
		case Node.PROCESSING_INSTRUCTION_NODE:
		    setIcon(piIcon);
		    break;
		case Node.TEXT_NODE:
		case Node.CDATA_SECTION_NODE:
		    setIcon(textIcon);
		    break;
		}
		return this;
	    }

	    /**
	     * Returns the DOM type of the given object.
	     * @return the type or -1.
	     */
	    protected short getNodeType(Object value) {
		DefaultMutableTreeNode mtn = (DefaultMutableTreeNode)value;
		Object obj = mtn.getUserObject();
		if (obj instanceof NodeInfo) {
		    Node node = ((NodeInfo)obj).getNode();
		    return node.getNodeType();
		}
		return -1;
	    }
	}

	/**
	 * To display the attributes of a DOM node attributes in a table.
	 */
	protected class NodeAttributesModel extends AbstractTableModel {
	    /**
	     * The node.
	     */
            protected Node node;
	    
	    /**
	     * Creates a new NodeAttributesModel object.
	     */
	    public NodeAttributesModel(Node n) {
		node = n;
	    }

	    /**
	     * Returns the name to give to a column.
	     */
	    public String getColumnName(int col) {
		if (col == 0) {
		    return resources.getString("AttributesTable.column1");
		} else {
		    return resources.getString("AttributesTable.column2");
		}
	    }

	    /**
	     * Returns the number of columns in the table.
	     */
	    public int getColumnCount() {
		return 2;
	    }

	    /**
	     * Returns the number of rows in the table.
	     */
	    public int getRowCount() {
		return node.getAttributes().getLength();
	    }

	    /**
	     * Whether the given cell is editable.
	     */
	    public boolean isCellEditable(int row, int col) {
		return false;
	    }

	    /**
	     * Returns the value of the given cell.
	     */
	    public Object getValueAt(int row, int col) {
		NamedNodeMap map = node.getAttributes();
		Node n = map.item(row);
		if (col == 0) {
		    return n.getNodeName();
		} else {
		    return n.getNodeValue();
		}
	    }
	}
    
	/**
	 * To display the CSS properties of a DOM node in a table.
	 */
	protected class NodeCSSValuesModel extends AbstractTableModel {
	    /**
	     * The node.
	     */
	    protected Node node;

            /**
             * The computed style.
             */
            protected CSSStyleDeclaration style;
	    
            /**
             * The property names.
             */
            protected java.util.List propertyNames;

	    /**
	     * Creates a new NodeAttributesModel object.
	     */
	    public NodeCSSValuesModel(Node n) {
		node = n;
                if (viewCSS != null) {
                    style = viewCSS.getComputedStyle((Element)n, null);
                    propertyNames = new ArrayList();
                    if (style != null) {
                        for (int i = 0; i < style.getLength(); i++) {
                            propertyNames.add(style.item(i));
                        }
                        Collections.sort(propertyNames);
                    }
                }
	    }

	    /**
	     * Returns the name to give to a column.
	     */
	    public String getColumnName(int col) {
		if (col == 0) {
		    return resources.getString("CSSValuesTable.column1");
		} else {
		    return resources.getString("CSSValuesTable.column2");
		}
	    }

	    /**
	     * Returns the number of columns in the table.
	     */
	    public int getColumnCount() {
		return 2;
	    }

	    /**
	     * Returns the number of rows in the table.
	     */
	    public int getRowCount() {
		if (style == null) {
		    return 0;
		}
		return style.getLength();
	    }

	    /**
	     * Whether the given cell is editable.
	     */
	    public boolean isCellEditable(int row, int col) {
		return false;
	    }

	    /**
	     * Returns the value of the given cell.
	     */
	    public Object getValueAt(int row, int col) {
		String prop = (String)propertyNames.get(row);
		if (col == 0) {
		    return prop;
		} else {
		    return style.getPropertyValue(prop);
		}
	    }
	}
    
    } // class Panel

    /**
     * To store the nodes informations
     */
    protected static class NodeInfo {
        /**
         * The DOM node.
         */
        protected Node node;

        /**
         * Creates a new NodeInfo object.
         */
        public NodeInfo(Node n) {
            node = n;
        }

        /**
         * Returns the DOM Node associated with this node info.
         */
        public Node getNode() {
            return node;
        }

        /**
         * Returns a printable representation of the object.
         */
        public String toString() {
            if (node instanceof Element) {
                String id = ((Element)node).getAttribute("id");
                if (id.length() != 0) {
                    return node.getNodeName() + " \""+id+"\"";
                }
            }
            return node.getNodeName();
        }
    }
}
