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

import java.awt.Component;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.LayoutManager;

import javax.swing.JPanel;

/**
 * An implementation of JPanel that uses the GridBagLayout.
 *
 * @author  <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: JGridBagPanel.java 479559 2006-11-27 09:46:16Z dvholten $
 */
public class JGridBagPanel extends JPanel implements GridBagConstants{
    /**
     * Provides insets desired for a given grid cell
     */
    public static interface InsetsManager{
        /**
         * Returns the insets for cell (gridx, gridy);
         */
        Insets getInsets(int gridx, int gridy);
    }

    /**
     * Always use 0 insets
     */
    private static class ZeroInsetsManager implements InsetsManager{
        private Insets insets = new Insets(0, 0, 0, 0);

        public Insets getInsets(int gridx, int gridy){
            return insets;
        }
    }

    /**
     * Default implemenation
     */
    private static class DefaultInsetsManager implements InsetsManager{
        /**
         * leftInset is the space used by default as a padding to the
         * left of each grid cell.
         */
        int leftInset=5;

        /**
         * topInset is the space used by default as a padding to the
         * top of each grid cell.
         */
        int topInset=5;

        public Insets positiveInsets = new Insets(topInset, leftInset, 0, 0);
        public Insets leftInsets = new Insets(topInset, 0, 0, 0);
        public Insets topInsets = new Insets(0, leftInset, 0, 0);
        public Insets topLeftInsets = new Insets(0, 0, 0, 0);

        public Insets getInsets(int gridx, int gridy){
            if(gridx > 0){
                if(gridy > 0)
                    return positiveInsets;
                else
                    return topInsets;
            }
            else{
                if(gridy > 0)
                    return leftInsets;
                else
                    return topLeftInsets;
            }
        }
    }

    /**
     * An InsetsManager that uses zero insets
     */
    public static final InsetsManager ZERO_INSETS = new ZeroInsetsManager();

    /**
     * An InsetsManager that uses padding for inside cells
     */
    public static final InsetsManager DEFAULT_INSETS = new DefaultInsetsManager();


    /**
     * Used to get insets at any given cell location
     */
    public InsetsManager insetsManager;

    /**
     * Sets the layout manager to GridBagLayout
     */
    public JGridBagPanel(){
        this(new DefaultInsetsManager());
    }

    /**
     * Initializes panel with a given insets manager
     */
    public JGridBagPanel(InsetsManager insetsManager){
        super(new GridBagLayout());

        if(insetsManager != null)
            this.insetsManager = insetsManager;
        else
            this.insetsManager = new DefaultInsetsManager();
    }

    /**
     * This method only takes effect if the LayoutManager is a GridBagLayout
     */
    public void setLayout(LayoutManager layout){
        if(layout instanceof GridBagLayout)
            super.setLayout(layout);
    }

    /**
     * This version uses default insets and assumes that components are added in
     * positive cell coordinates. Top inset for components added to the top
     * is 0. Left inset for components added to the left is 0. For compoents at
     * index gridx more than zero and index gridy more than zero, the insets
     * are set to a default value.
     *
     * @param cmp Component to add to the panel
     * @param gridx x position of the cell into which component should be added
     * @param gridy y position of the cell into which component should be added
     * @param gridwidth width, in cells, of the space occupied by the component in the grid
     * @param gridheight height, in cells, of the space occupied by the component in the grid
     * @param anchor placement of the component in its allocated space: WEST, NORTH, SOUTH, NORTHWEST, ...
     * @param fill out should the component be resized within its space? NONE, BOTH, HORIZONTAL, VERTICAL.
     * @param weightx what amount of extra horizontal space, if any, should be given to this component?
     * @param weighty what amount of extra vertical space, if any, should be given to this component?
     */
    public void add(Component cmp, int gridx, int gridy,
                    int gridwidth, int gridheight, int anchor, int fill,
                    double weightx, double weighty){
        Insets insets = insetsManager.getInsets(gridx, gridy);
        GridBagConstraints constraints = new GridBagConstraints();
        constraints.gridx = gridx;
        constraints.gridy = gridy;
        constraints.gridwidth = gridwidth;
        constraints.gridheight = gridheight;
        constraints.anchor = anchor;
        constraints.fill = fill;
        constraints.weightx = weightx;
        constraints.weighty = weighty;
        constraints.insets = insets;
        add(cmp, constraints);
    }

}
