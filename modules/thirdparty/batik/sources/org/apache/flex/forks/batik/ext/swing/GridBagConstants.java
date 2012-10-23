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

import java.awt.GridBagConstraints;

/**
 * <tt>GridBagConstraints</tt> constants.
 *
 * @author <a href="mailto:vhardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: GridBagConstants.java 479559 2006-11-27 09:46:16Z dvholten $
 */
public interface GridBagConstants {
    /**
     * Specify that this component is the
     * last component in its column or row.
     * @since   JDK1.0
     */
    int REMAINDER = GridBagConstraints.REMAINDER;

    /**
     * Do not resize the component.
     * @since   JDK1.0
     */
    int NONE = GridBagConstraints.NONE;

    /**
     * Resize the component both horizontally and vertically.
     * @since   JDK1.0
     */
    int BOTH = GridBagConstraints.BOTH;

    /**
     * Resize the component horizontally but not vertically.
     * @since   JDK1.0
     */
    int HORIZONTAL = GridBagConstraints.HORIZONTAL;

    /**
     * Resize the component vertically but not horizontally.
     * @since   JDK1.0
     */
    int VERTICAL = GridBagConstraints.VERTICAL;

    /**
     * Put the component in the center of its display area.
     * @since    JDK1.0
     */
    int CENTER = GridBagConstraints.CENTER;

    /**
     * Put the component at the top of its display area,
     * centered horizontally.
     * @since   JDK1.0
     */
    int NORTH = GridBagConstraints.NORTH;

    /**
     * Put the component at the top-right corner of its display area.
     * @since   JDK1.0
     */
    int NORTHEAST = GridBagConstraints.NORTHEAST;

    /**
     * Put the component on the left side of its display area,
     * centered vertically.
     * @since    JDK1.0
     */
    int EAST = GridBagConstraints.EAST;

    /**
     * Put the component at the bottom-right corner of its display area.
     * @since   JDK1.0
     */
    int SOUTHEAST = GridBagConstraints.SOUTHEAST;

    /**
     * Put the component at the bottom of its display area, centered
     * horizontally.
     * @since   JDK1.0
     */
    int SOUTH = GridBagConstraints.SOUTH;

    /**
     * Put the component at the bottom-left corner of its display area.
     * @since   JDK1.0
     */
    int SOUTHWEST = GridBagConstraints.SOUTHWEST;

    /**
     * Put the component on the left side of its display area,
     * centered vertically.
     * @since    JDK1.0
     */
    int WEST = GridBagConstraints.WEST;

    /**
     * Put the component at the top-left corner of its display area.
     * @since   JDK1.0
     */
    int NORTHWEST = GridBagConstraints.NORTHWEST;

}
