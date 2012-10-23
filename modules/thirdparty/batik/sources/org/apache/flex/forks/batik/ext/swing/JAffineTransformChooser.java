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
package org.apache.flex.forks.batik.ext.swing;

import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.Container;
import java.awt.FlowLayout;
import java.awt.Window;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.geom.AffineTransform;
import java.io.Serializable;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.border.Border;
import javax.swing.text.Document;

/**
 * The <tt>JAffineTransformChooser</tt> is a pane that contains
 * controls to let a user select the various components that
 * make up an <tt>AffineTransform</tt>
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: JAffineTransformChooser.java 501495 2007-01-30 18:00:36Z dvholten $
 */
public class JAffineTransformChooser extends JGridBagPanel{
    public static final String LABEL_ANGLE
        = "JAffineTransformChooser.label.angle";

    public static final String LABEL_DEGREE
        = "JAffineTransformChooser.label.degree";

    public static final String LABEL_PERCENT
        = "JAffineTransformChooser.label.percent";

    public static final String LABEL_ROTATE
        = "JAffineTransformChooser.label.rotate";

    public static final String LABEL_SCALE
        = "JAffineTransformChooser.label.scale";

    public static final String LABEL_RX
        = "JAffineTransformChooser.label.rx";

    public static final String LABEL_RY
        = "JAffineTransformChooser.label.ry";

    public static final String LABEL_SX
        = "JAffineTransformChooser.label.sx";

    public static final String LABEL_SY
        = "JAffineTransformChooser.label.sy";

    public static final String LABEL_TRANSLATE
        = "JAffineTransformChooser.label.translate";

    public static final String LABEL_TX
        = "JAffineTransformChooser.label.tx";

    public static final String LABEL_TY
        = "JAffineTransformChooser.label.ty";

    public static final String CONFIG_TEXT_FIELD_WIDTH
        = "JAffineTransformChooser.config.text.field.width";

    public static final String CONFIG_TOP_PAD
        = "JAffineTransformChooser.config.top.pad";

    public static final String CONFIG_LEFT_PAD
        = "JAffineTransformChooser.config.left.pad";

    public static final String CONFIG_BOTTOM_PAD
        = "JAffineTransformChooser.config.bottom.pad";

    public static final String CONFIG_RIGHT_PAD
        = "JAffineTransformChooser.config.right.pad";

    /**
     * The <tt>AffineTransform</tt> value represented by the
     * chooser
     */
    protected AffineTransform txf;

    /**
     * The Model for the x-axis translate component
     */
    protected DoubleDocument txModel = new DoubleDocument();

    /**
     * The Model for the y-axis translate component
     */
    protected DoubleDocument tyModel = new DoubleDocument();

    /**
     * The Model for the x-axis scale component
     */
    protected DoubleDocument sxModel = new DoubleDocument();

    /**
     * The Model for the y-axis scale component
     */
    protected DoubleDocument syModel = new DoubleDocument();

    /**
     * The Model for the x-axis rotation center
     */
    protected DoubleDocument rxModel = new DoubleDocument();

    /**
     * The Model for the y-axis rotation center
     */
    protected DoubleDocument ryModel = new DoubleDocument();

    /**
     * The Model for the rotation
     */
    protected DoubleDocument rotateModel = new DoubleDocument();

    protected static final double RAD_TO_DEG = 180./Math.PI;
    protected static final double DEG_TO_RAD = Math.PI/180.;

    /**
     * Default constructor
     */
    public JAffineTransformChooser(){
        build();
        setAffineTransform(new AffineTransform());
    }

    /**
     * Adds the control components into this panel.
     */
    protected void build(){
        Component txyCmp = buildPanel(Resources.getString(LABEL_TRANSLATE),
                                      Resources.getString(LABEL_TX),
                                      txModel,
                                      Resources.getString(LABEL_TY),
                                      tyModel,
                                      "",
                                      "",
                                      true);

        Component sxyCmp = buildPanel(Resources.getString(LABEL_SCALE),
                                      Resources.getString(LABEL_SX),
                                      sxModel,
                                      Resources.getString(LABEL_SY),
                                      syModel,
                                      Resources.getString(LABEL_PERCENT),
                                      Resources.getString(LABEL_PERCENT),
                                      true);

        Component rCmp = buildRotatePanel();

        add(txyCmp,  0, 0, 1, 1, CENTER, BOTH, 1, 1);
        add(sxyCmp,  1, 0, 1, 1, CENTER, BOTH, 1, 1);
        add(rCmp,    0, 1, 2, 1, CENTER, BOTH, 1, 1);
    }

    protected Component buildRotatePanel(){
        JGridBagPanel panel = new JGridBagPanel();

        Component anglePanel = buildPanel(Resources.getString(LABEL_ROTATE),
                                          Resources.getString(LABEL_ANGLE),
                                          rotateModel,
                                          null,
                                          null,
                                          Resources.getString(LABEL_DEGREE),
                                          null,
                                          false);

        Component centerPanel = buildPanel("",
                                           Resources.getString(LABEL_RX),
                                           rxModel,
                                           Resources.getString(LABEL_RY),
                                           ryModel,
                                           null,
                                           null,
                                           false);

        panel.add(anglePanel,   0, 0, 1, 1, CENTER, BOTH, 1, 1);
        panel.add(centerPanel,  1, 0, 1, 1, CENTER, BOTH, 1, 1);

        setPanelBorder(panel, Resources.getString(LABEL_ROTATE));

        return panel;
    }

    protected Component buildPanel(String panelName,
                                   String tfALabel,
                                   Document tfAModel,
                                   String tfBLabel,
                                   Document tfBModel,
                                   String tfASuffix,
                                   String tfBSuffix,
                                   boolean setBorder){
        JGridBagPanel panel = new JGridBagPanel();

        addToPanelAtRow(tfALabel, tfAModel, tfASuffix, panel, 0);
        if(tfBLabel != null){
            addToPanelAtRow(tfBLabel, tfBModel, tfBSuffix, panel, 1);
        }

        // Create a border
        if(setBorder){
            setPanelBorder(panel, panelName);
        }

        return panel;

    }

    public void setPanelBorder(JComponent panel, String panelName){
        Border border
            = BorderFactory.createTitledBorder
            (BorderFactory.createEtchedBorder(), panelName);

        int topPad = Resources.getInteger(CONFIG_TOP_PAD);
        int leftPad = Resources.getInteger(CONFIG_LEFT_PAD);
        int bottomPad = Resources.getInteger(CONFIG_BOTTOM_PAD);
        int rightPad = Resources.getInteger(CONFIG_RIGHT_PAD);

        border
            = BorderFactory.createCompoundBorder
            (border,
             BorderFactory.createEmptyBorder(topPad, leftPad,
                                             bottomPad, rightPad));

        panel.setBorder(border);
    }

    protected void addToPanelAtRow(String label,
                                   Document model,
                                   String suffix,
                                   JGridBagPanel p,
                                   int row){
        JTextField tf = new JTextField(Resources.getInteger(CONFIG_TEXT_FIELD_WIDTH));
        tf.setDocument(model);
        p.add(new JLabel(label),    0, row, 1, 1, WEST, HORIZONTAL, 0, 0);
        p.add(tf,                   1, row, 1, 1, CENTER, HORIZONTAL, 1, 0);
        p.add(new JLabel(suffix),   2, row, 1, 1, WEST, HORIZONTAL, 0, 0);
    }

    public AffineTransform getAffineTransform(){
        double sx = sxModel.getValue()/100.;
        double sy = syModel.getValue()/100.;
        double theta = rotateModel.getValue()*DEG_TO_RAD;
        double rx = rxModel.getValue();
        double ry = ryModel.getValue();
        double tx = txModel.getValue();
        double ty = tyModel.getValue();

        double[] m = new double[6];

        final double SIN_THETA = Math.sin( theta );
        final double COS_THETA = Math.cos( theta );

        m[0] =  sx * COS_THETA;
        m[1] =  sx * SIN_THETA;
        m[2] = -sy * SIN_THETA;
        m[3] =  sy * COS_THETA;
        m[4] =  tx + rx - rx * COS_THETA + ry * SIN_THETA;
        m[5] =  ty + ry - rx * SIN_THETA - ry * COS_THETA;

        txf = new AffineTransform(m);

        return txf;
    }

    public void setAffineTransform(AffineTransform txf){
        if(txf == null){
            txf = new AffineTransform();
        }

        this.txf = txf;

        /**
         * Now, update model
         */
        double[] m = new double[6];
        txf.getMatrix(m);

        // Translation
        txModel.setValue(m[4]);
        tyModel.setValue(m[5]);

        // Scale, in percentages
        double sx = Math.sqrt(m[0]*m[0] + m[1]*m[1]);
        double sy = Math.sqrt(m[2]*m[2] + m[3]*m[3]);
        sxModel.setValue(100*sx);
        syModel.setValue(100*sy);

        // Rotation
        double theta = 0;
        if(m[0] > 0){
            theta = Math.atan2(m[1], m[0]);
        }

        // Rotate
        rotateModel.setValue(RAD_TO_DEG*theta);
        rxModel.setValue(0);
        ryModel.setValue(0);
    }

    /**
     * Displays the panel in a modal dialog box.
     * @param cmp the dialog's parent component
     * @param title the dialog's title
     *
     * @return null if the dialog was cancelled. Otherwise, the value entered
     *         by the user.
     */
    public static AffineTransform showDialog(Component cmp,
                                             String title){
        final JAffineTransformChooser pane
            = new JAffineTransformChooser();

        AffineTransformTracker tracker = new AffineTransformTracker(pane);
        JDialog dialog = new Dialog(cmp, title, true, pane, tracker, null);
        dialog.addWindowListener(new Closer());
        dialog.addComponentListener(new DisposeOnClose());

        dialog.setVisible(true); // blocks until user brings dialog down...

        return tracker.getAffineTransform();
    }

    /**
     * Creates a new modal dialog box that can be used to
     * configure an <tt>AffineTransform</tt>
     *
     * @param cmp the dialog's parent component
     * @param title the dialog's title
     *
     */
    public static Dialog createDialog(Component cmp,
                                      String title){
        final JAffineTransformChooser pane
            = new JAffineTransformChooser();

        AffineTransformTracker tracker = new AffineTransformTracker(pane);
        Dialog dialog = new Dialog(cmp, title, true, pane, tracker, null);
        dialog.addWindowListener(new Closer());
        dialog.addComponentListener(new DisposeOnClose());

        return dialog;
    }


    public static void main(String[] args){
        AffineTransform t = showDialog(null, "Hello");
        // AffineTransform.getScaleInstance(.25, .25));
        // new AffineTransform());
        // AffineTransform.getShearInstance(1, 1));
        if(t == null){
            System.out.println("Cancelled");
        }
        else{
            System.out.println("t = " + t);
        }
    }

    /*
     * Class which builds a AffineTransform chooser dialog consisting of
     * a JAffineTransformChooser with "Ok", "Cancel", and "Reset" buttons.
     *
     * Note: This needs to be fixed to deal with localization!
     */
    public static class Dialog extends JDialog {
        private JAffineTransformChooser chooserPane;
        private AffineTransformTracker tracker;

        public static final String LABEL_OK
            = "JAffineTransformChooser.label.ok";

        public static final String LABEL_CANCEL
            = "JAffineTransformChooser.label.cancel";

        public static final String LABEL_RESET
            = "JAffineTransformChooser.label.reset";

        public static final String ACTION_COMMAND_OK
            = "OK";

        public static final String ACTION_COMMAND_CANCEL
            = "cancel";


        public Dialog(Component c, String title, boolean modal,
                      JAffineTransformChooser chooserPane,
                      AffineTransformTracker okListener, ActionListener cancelListener) {
            super(JOptionPane.getFrameForComponent(c), title, modal);

            this.chooserPane = chooserPane;
            this.tracker = okListener;

            String okString = Resources.getString(LABEL_OK);
            String cancelString = Resources.getString(LABEL_CANCEL);
            String resetString = Resources.getString(LABEL_RESET);

            Container contentPane = getContentPane();
            contentPane.setLayout(new BorderLayout());
            contentPane.add(chooserPane, BorderLayout.CENTER);

            /*
             * Create Lower button panel
             */
            JPanel buttonPane = new JPanel();
            buttonPane.setLayout(new FlowLayout(FlowLayout.CENTER));
            JButton okButton = new JButton(okString);
            getRootPane().setDefaultButton(okButton);
            okButton.setActionCommand(ACTION_COMMAND_OK);
            if (okListener != null) {
                okButton.addActionListener(okListener);
            }
            okButton.addActionListener(new ActionListener() {
                    public void actionPerformed(ActionEvent e) {
                        setVisible(false);
                    }
                });
            buttonPane.add(okButton);

            JButton cancelButton = new JButton(cancelString);

            addKeyListener(new KeyAdapter(){
                    public void keyPressed(KeyEvent evt){
                        if(evt.getKeyCode() == KeyEvent.VK_ESCAPE){
                            setVisible(false);
                        }
                    }
                });

            cancelButton.addActionListener(new ActionListener() {
                    public void actionPerformed(ActionEvent e) {
                        setVisible(false);
                    }
                });

            buttonPane.add(cancelButton);

            JButton resetButton = new JButton(resetString);
            resetButton.addActionListener(new ActionListener() {
                    public void actionPerformed(ActionEvent e) {
                        reset();
                    }
                });
            buttonPane.add(resetButton);
            contentPane.add(buttonPane, BorderLayout.SOUTH);

            pack();
            setLocationRelativeTo(c);
        }

        public void setVisible(boolean b) {
            if (b) tracker.reset();
            super.setVisible(b);
        }

        public AffineTransform showDialog(){
            this.setVisible(true);
            return tracker.getAffineTransform();
        }

        public void reset() {
            chooserPane.setAffineTransform(new AffineTransform());
        }

        public void setTransform(AffineTransform at){
            if(at == null){
                at = new AffineTransform();
            }

            chooserPane.setAffineTransform(at);
        }



    }

    static class Closer extends WindowAdapter implements Serializable{
        public void windowClosing(WindowEvent e) {
            Window w = e.getWindow();
            w.setVisible(false);
        }
    }

    static class DisposeOnClose extends ComponentAdapter implements Serializable{
        public void componentHidden(ComponentEvent e) {
            Window w = (Window)e.getComponent();
            w.dispose();
        }
    }

}


class AffineTransformTracker implements ActionListener, Serializable {
    JAffineTransformChooser chooser;
    AffineTransform txf;

    public AffineTransformTracker(JAffineTransformChooser c) {
        chooser = c;
    }

    public void actionPerformed(ActionEvent e) {
        txf = chooser.getAffineTransform();
    }

    public AffineTransform getAffineTransform() {
        return txf;
    }

    public void reset(){
        txf = null;
    }
}

