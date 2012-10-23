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
package org.apache.flex.forks.batik.swing;

import java.awt.Image;
import java.beans.SimpleBeanInfo;

/**
 * A <tt>BeanInfo</tt> for the <tt>JSVGCanvas</tt>.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: JSVGCanvasBeanInfo.java 475477 2006-11-15 22:44:28Z cam $
 */
public class JSVGCanvasBeanInfo extends SimpleBeanInfo {

    /** A color 16x16 icon. */
    protected Image iconColor16x16;

    /** A greyscale 16x16 icon. */
    protected Image iconMono16x16;

    /** A color 32x32 icon. */
    protected Image iconColor32x32;

    /** A greyscale 32x32 icon. */
    protected Image iconMono32x32;

    /**
     * Constructs a new <tt>BeanInfo</tt> for a <tt>JSVGCanvas</tt>.
     */
    public JSVGCanvasBeanInfo() {
        iconColor16x16 = loadImage("resources/batikColor16x16.gif");
        iconMono16x16 = loadImage("resources/batikMono16x16.gif");
        iconColor32x32 = loadImage("resources/batikColor32x32.gif");
        iconMono32x32 = loadImage("resources/batikMono32x32.gif");
    }

    /**
     * Returns an icon for the specified type.
     */
    public Image getIcon(int iconType) {
        switch(iconType) {
        case ICON_COLOR_16x16:
            return iconColor16x16;
        case ICON_MONO_16x16:
            return iconMono16x16;
        case ICON_COLOR_32x32:
            return iconColor32x32;
        case ICON_MONO_32x32:
            return iconMono32x32;
        default:
            return null;
        }
    }
}

