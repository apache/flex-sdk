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
package org.apache.flex.forks.batik.bridge;

import java.awt.image.BufferedImage;
import java.util.EventObject;
import java.util.List;

/**
 * This class represents an event which indicate an event originated
 * from a UpdateManager instance.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: UpdateManagerEvent.java 475477 2006-11-15 22:44:28Z cam $
 */
public class UpdateManagerEvent extends EventObject {

    /**
     * The buffered image.
     */
    protected BufferedImage image;
    
    /**
     * The dirty areas, as a List of Rectangles.
     */
    protected List dirtyAreas;

    /**
     * True if before painting this update the canvas's painting
     * transform needs to be cleared.
     */
    protected boolean clearPaintingTransform;

    /**
     * Creates a new UpdateManagerEvent.
     * @param source the object that originated the event, ie. the
     *               UpdateManager.
     * @param bi the image to paint.
     * @param das List of dirty areas.
     */
    public UpdateManagerEvent(Object source, BufferedImage bi, 
                              List das) {
        super(source);
        this.image = bi;
        this.dirtyAreas = das;
        this.clearPaintingTransform = false;
    }

    /**
     * Creates a new UpdateManagerEvent.
     * @param source the object that originated the event, ie. the
     *               UpdateManager.
     * @param bi the image to paint.
     * @param das List of dirty areas.
     * @param cpt Indicates if the painting transform should be
     *            cleared as a result of this event.
     */
    public UpdateManagerEvent(Object source, BufferedImage bi, 
                              List das, boolean cpt) {
        super(source);
        this.image = bi;
        this.dirtyAreas = das;
        this.clearPaintingTransform = cpt;
    }

    /**
     * Returns the image to display, or null if the rendering failed.
     */
    public BufferedImage getImage() {
        return image;
    }

    /**
     * Returns the dirty areas (list of rectangles)
     */
    public List getDirtyAreas() {
        return dirtyAreas;
    }

    /**
     * returns true if the component should clear it's painting transform
     * before painting the associated BufferedImage.
     */
    public boolean getClearPaintingTransform() {
        return clearPaintingTransform;
    }
}
