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
package org.apache.flex.forks.batik.util.gui;

import java.awt.GridBagConstraints;

/**
 * This class extends the java.awt.GridBagConstraints in order to
 * provide some utility methods.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ExtendedGridBagConstraints.java 475477 2006-11-15 22:44:28Z cam $
 */
public class ExtendedGridBagConstraints extends GridBagConstraints {

    /**
     * Modifies gridx, gridy, gridwidth, gridheight.
     *
     * @param x The value for gridx.
     * @param y The value for gridy.
     * @param width The value for gridwidth.
     * @param height The value for gridheight.
     */
    public void setGridBounds(int x, int y, int width, int height) {
        gridx = x;
        gridy = y;
        gridwidth = width;
        gridheight = height;
    }

    /**
     * Modifies the weightx and weighty.
     *
     * @param weightx The value for weightx
     * @param weighty The value for weighty
     */
    public void setWeight(double weightx, double weighty) {
        this.weightx = weightx;
        this.weighty = weighty;
    }
}
