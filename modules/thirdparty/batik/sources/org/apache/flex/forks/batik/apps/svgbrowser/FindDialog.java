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
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Frame;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.Shape;
import java.awt.event.ActionEvent;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.text.AttributedCharacterIterator;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.ResourceBundle;

import javax.swing.AbstractAction;
import javax.swing.Action;
import javax.swing.BorderFactory;
import javax.swing.ButtonGroup;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.JTextField;

import org.apache.flex.forks.batik.gvt.GVTTreeWalker;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.TextNode;
import org.apache.flex.forks.batik.gvt.text.Mark;
import org.apache.flex.forks.batik.swing.JSVGCanvas;
import org.apache.flex.forks.batik.util.resources.ResourceManager;
import org.apache.flex.forks.batik.util.gui.ExtendedGridBagConstraints;
import org.apache.flex.forks.batik.util.gui.resource.ActionMap;
import org.apache.flex.forks.batik.util.gui.resource.ButtonFactory;
import org.apache.flex.forks.batik.util.gui.resource.MissingListenerException;

/**
 * This class represents a Dialog that lets the user searching for text inside
 * an SVG document.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: FindDialog.java 592619 2007-11-07 05:47:24Z cam $
 */
public class FindDialog extends JDialog implements ActionMap {

    /**
     * The resource file name
     */
    protected static final String RESOURCES =
        "org.apache.flex.forks.batik.apps.svgbrowser.resources.FindDialog";

    // action names
    public static final String FIND_ACTION = "FindButtonAction";

    public static final String CLEAR_ACTION = "ClearButtonAction";

    public static final String CLOSE_ACTION = "CloseButtonAction";

    /**
     * The resource bundle
     */
    protected static ResourceBundle bundle;

    /**
     * The resource manager
     */
    protected static ResourceManager resources;

    static {
        bundle = ResourceBundle.getBundle(RESOURCES, Locale.getDefault());
        resources = new ResourceManager(bundle);
    }

    /** The button factory */
    protected ButtonFactory buttonFactory;

    /** The GVT root into which text is searched. */
    protected GraphicsNode gvtRoot;

    /** The GVTTreeWalker used to scan the GVT Tree. */
    protected GVTTreeWalker walker;

    /** The current index in the TextNode's string. */
    protected int currentIndex;

    /** The TextField that owns the text to search. */
    protected JTextField search;

    /** The next button. */
    protected JButton findButton;

    /** The next button. */
    protected JButton clearButton;

    /** The cancel button. */
    protected JButton closeButton;

    /** The case sensitive button. */
    protected JCheckBox caseSensitive;

    /** The canvas. */
    protected JSVGCanvas svgCanvas;

    /** The highlight button. */
    protected JRadioButton highlightButton;

    /** The highlight and center button. */
    protected JRadioButton highlightCenterButton;

    /** The highlight center and zoom button. */
    protected JRadioButton highlightCenterZoomButton;
    /**
     * Constructs a new <tt>FindDialog</tt>.
     */
    public FindDialog(JSVGCanvas svgCanvas) {
        this(null, svgCanvas);
    }

    /**
     * Constructs a new <tt>FindDialog</tt>.
     */
    public FindDialog(Frame owner, JSVGCanvas svgCanvas) {
        super(owner, resources.getString("Dialog.title"));
        this.svgCanvas = svgCanvas;

        buttonFactory = new ButtonFactory(bundle, this);

        listeners.put(FIND_ACTION,
                      new FindButtonAction());

        listeners.put(CLEAR_ACTION,
                      new ClearButtonAction());

        listeners.put(CLOSE_ACTION,
                      new CloseButtonAction());

        JPanel p = new JPanel(new BorderLayout());
        p.setBorder(BorderFactory.createEmptyBorder(4, 4, 4, 4));
        p.add(createFindPanel(), BorderLayout.CENTER);
        p.add(createShowResultPanel(), BorderLayout.SOUTH);

        getContentPane().add(p, BorderLayout.CENTER);
        getContentPane().add(createButtonsPanel(), BorderLayout.SOUTH);
    }

    /**
     * Creates the Find panel.
     */
    protected JPanel createFindPanel() {
        JPanel panel = new JPanel(new GridBagLayout());

        panel.setBorder(BorderFactory.createTitledBorder
                        (BorderFactory.createEtchedBorder(),
                         resources.getString("Panel.title")));

        ExtendedGridBagConstraints gbc = new ExtendedGridBagConstraints();
        gbc.insets = new Insets(2, 2, 2, 2);

        gbc.anchor = ExtendedGridBagConstraints.EAST;
        gbc.fill = ExtendedGridBagConstraints.NONE;
        gbc.setWeight(0, 0);
        gbc.setGridBounds(0, 0, 1, 1);
        panel.add(new JLabel(resources.getString("FindLabel.text")), gbc);

        gbc.fill = ExtendedGridBagConstraints.HORIZONTAL;
        gbc.setWeight(1.0, 0);
        gbc.setGridBounds(1, 0, 2, 1);
        panel.add(search = new JTextField(20), gbc);

        gbc.fill = ExtendedGridBagConstraints.NONE;
        gbc.anchor = ExtendedGridBagConstraints.WEST;
        gbc.setWeight(0, 0);
        gbc.setGridBounds(1, 1, 1, 1);
        caseSensitive = buttonFactory.createJCheckBox("CaseSensitiveCheckBox");
        panel.add(caseSensitive, gbc);

        return panel;
    }

    protected JPanel createShowResultPanel() {
        JPanel panel = new JPanel(new GridBagLayout());

        panel.setBorder(BorderFactory.createTitledBorder
                        (BorderFactory.createEtchedBorder(),
                         resources.getString("ShowResultPanel.title")));

        ExtendedGridBagConstraints gbc = new ExtendedGridBagConstraints();
        gbc.insets = new Insets(2, 2, 2, 2);

        gbc.anchor = ExtendedGridBagConstraints.WEST;
        gbc.fill = ExtendedGridBagConstraints.NONE;
        gbc.setWeight(0, 0);

        ButtonGroup grp = new ButtonGroup();

        highlightButton = buttonFactory.createJRadioButton("Highlight");
        highlightButton.setSelected(true);
        grp.add(highlightButton);
        gbc.setGridBounds(0, 0, 1, 1);
        panel.add(highlightButton, gbc);

        highlightCenterButton =
            buttonFactory.createJRadioButton("HighlightAndCenter");
        grp.add(highlightCenterButton);
        gbc.setGridBounds(0, 1, 1, 1);
        panel.add(highlightCenterButton, gbc);

        highlightCenterZoomButton =
            buttonFactory.createJRadioButton("HighlightCenterAndZoom");
        grp.add(highlightCenterZoomButton);
        gbc.setGridBounds(0, 2, 1, 1);
        panel.add(highlightCenterZoomButton, gbc);

        return panel;
    }

    /**
     * Creates the buttons panel
     */
    protected JPanel createButtonsPanel() {
        JPanel panel = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        panel.add(findButton = buttonFactory.createJButton("FindButton"));
        panel.add(clearButton = buttonFactory.createJButton("ClearButton"));
        panel.add(closeButton = buttonFactory.createJButton("CloseButton"));
        return panel;
    }


    /**
     * Sets the graphics node into which text is searched.
     * @param gvtRoot the GVT root node
     */
    public void setGraphicsNode(GraphicsNode gvtRoot) {
        this.gvtRoot = gvtRoot;
        if (gvtRoot != null) {
            this.walker = new GVTTreeWalker(gvtRoot);
        } else {
            this.walker = null;
        }
    }

    /**
     * Returns the next GraphicsNode that matches the specified string or null
     * if any.
     *
     * @param text the text to match
     */
    protected GraphicsNode getNext(String text) {
        if (walker == null && gvtRoot != null) {
            walker = new GVTTreeWalker(gvtRoot);
        }
        GraphicsNode gn = walker.getCurrentGraphicsNode();
        int index = match(gn, text, currentIndex+text.length());
        if (index >= 0) {
            currentIndex = index;
        } else {
            currentIndex = 0;
            gn = walker.nextGraphicsNode();
            while (gn != null &&
                   ((currentIndex = match(gn, text, currentIndex)) < 0)) {
                currentIndex = 0;
                gn = walker.nextGraphicsNode();
            }
        }
        return gn;
    }

    /**
     * Returns the index inside the specified TextNode of the
     * specified text, or -1 if not found.
     *
     * @param node the graphics node to check
     * @param text the text use to match
     * @param index the index from which to start */
    protected int match(GraphicsNode node, String text, int index) {
        if (!(node instanceof TextNode)
            || !node.isVisible()
            || text == null || text.length() == 0) {
            return -1;
        }
        String s = ((TextNode)node).getText();
        if (!caseSensitive.isSelected()) {
            s = s.toLowerCase();
            text = text.toLowerCase();
        }
        return s.indexOf(text, index);
    }

    /**
     * Shows the current selected <tt>TextNode</tt>.
     */
    protected void showSelectedGraphicsNode() {
        GraphicsNode gn = walker.getCurrentGraphicsNode();
        if (!(gn instanceof TextNode)) {
            return;
        }
        TextNode textNode = (TextNode)gn;
        // mark the selection of the substring found
        String text    = textNode.getText();
        String pattern = search.getText();
        if (!caseSensitive.isSelected()) {
            text    = text.toLowerCase();
            pattern = pattern.toLowerCase();
        }
        int end = text.indexOf(pattern, currentIndex);

        AttributedCharacterIterator aci =
            textNode.getAttributedCharacterIterator();
        aci.first();
        for (int i=0; i < end; ++i) {
            aci.next();
        }
        Mark startMark = textNode.getMarkerForChar(aci.getIndex(), true);

        for (int i = 0; i < pattern.length()-1; ++i) {
            aci.next();
        }
        Mark endMark = textNode.getMarkerForChar(aci.getIndex(), false);
        svgCanvas.select(startMark, endMark);

        // zoom on the TextNode if needed
        if (highlightButton.isSelected()) {
            return;
        }

        // get the highlight shape in GVT root (global) coordinate sytem
        Shape s = textNode.getHighlightShape();
        AffineTransform at;
        if (highlightCenterZoomButton.isSelected()) {
            at = svgCanvas.getInitialTransform();
        } else {
            at = svgCanvas.getRenderingTransform();
        }
        // get the bounds of the highlight shape in the canvas coordinate system
        Rectangle2D gnb = at.createTransformedShape(s).getBounds();

        Dimension canvasSize = svgCanvas.getSize();
        // translate the highlight region to (0, 0) in the canvas coordinate
        // system
        AffineTransform Tx = AffineTransform.getTranslateInstance
            (-gnb.getX()-gnb.getWidth()/2,
             -gnb.getY()-gnb.getHeight()/2);

        if (highlightCenterZoomButton.isSelected()) {
            // zoom on the highlight shape such as the shape takes x% of the
            // canvas size
            double sx = canvasSize.width/gnb.getWidth();
            double sy = canvasSize.height/gnb.getHeight();
            double scale = Math.min(sx, sy) / 8;
            if (scale > 1) {
                Tx.preConcatenate
                    (AffineTransform.getScaleInstance(scale, scale));
            }
        }
        Tx.preConcatenate(AffineTransform.getTranslateInstance
                          (canvasSize.width/2, canvasSize.height/2));
        // take into account the initial transform
        AffineTransform newRT = new AffineTransform(at);
        newRT.preConcatenate(Tx);
        // change the rendering transform
        svgCanvas.setRenderingTransform(newRT);
    }

    // ActionMap implementation

    /**
     * The map that contains the listeners
     */
    protected Map listeners = new HashMap(10);

    /**
     * Returns the action associated with the given string
     * or null on error
     * @param key the key mapped with the action to get
     * @throws MissingListenerException if the action is not found
     */
    public Action getAction(String key) throws MissingListenerException {
        return (Action)listeners.get(key);
    }

    //////////////////////////////////////////////////////////////////////////
    // Action implementation
    //////////////////////////////////////////////////////////////////////////

    /**
     * The action associated to the 'find' button.
     */
    protected class FindButtonAction extends AbstractAction {
        public void actionPerformed(ActionEvent e) {
            String text = search.getText();
            if (text == null || text.length() == 0) {
                return;
            }
            GraphicsNode gn = getNext(text);
            if (gn != null) {
                showSelectedGraphicsNode();
            } else {
                // end of document reached
                walker = null;
                JOptionPane.showMessageDialog(FindDialog.this,
                                              resources.getString("End.text"),
                                              resources.getString("End.title"),
                                              JOptionPane.INFORMATION_MESSAGE);
            }
        }
    }

    /**
     * The action associated to the 'clear' button.
     */
    protected class ClearButtonAction extends AbstractAction {
        public void actionPerformed(ActionEvent e) {
            search.setText(null);
            walker = null;
        }
    }

    /**
     * The action associated to the 'close' button.
     */
    protected class CloseButtonAction extends AbstractAction {
        public void actionPerformed(ActionEvent e) {
            dispose();
        }
    }
}


