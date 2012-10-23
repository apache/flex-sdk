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
package org.apache.flex.forks.batik.swing.gvt;

import java.awt.image.BufferedImage;
import java.util.EventObject;

/**
 * This class represents an event which indicate an event originated
 * from a GVTTreeRenderer instance.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: GVTTreeRendererEvent.java 475477 2006-11-15 22:44:28Z cam $
 */
public class GVTTreeRendererEvent extends EventObject {

    /**
     * The buffered image.
     */
    protected BufferedImage image;
    
    /**
     * Creates a new GVTTreeRendererEvent.
     * @param source the object that originated the event, ie. the
     *               GVTTreeRenderer.
     * @param bi the image to paint.
     */
    public GVTTreeRendererEvent(Object source, BufferedImage bi) {
        super(source);
        image = bi;
    }

    /**
     * Returns the image to display, or null if the rendering failed.
     */
    public BufferedImage getImage() {
        return image;
    }
}
