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

import java.awt.geom.AffineTransform;
import java.util.ArrayList;
import java.util.List;

/**
 * This class implements a transform history mechanism.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: TransformHistory.java 475477 2006-11-15 22:44:28Z cam $
 */
public class TransformHistory {
    
    /**
     * The transform stack.
     */
    protected List transforms = new ArrayList();

    /**
     * The current position in the stack.
     */
    protected int position = -1;

    /**
     * Goes back of one position in the history.
     * Assumes that <tt>canGoBack()</tt> is true.
     */
    public void back() {
        position -= 2;
    }

    /**
     * Whether it is possible to go back.
     */
    public boolean canGoBack() {
        return position > 0;
    }

    /**
     * Goes forward of one position in the history.
     * Assumes that <tt>canGoForward()</tt> is true.
     */
    public void forward() {
    }

    /**
     * Whether it is possible to go forward.
     */
    public boolean canGoForward() {
        return position < transforms.size() - 1;
    }

    /**
     * Returns the current transform.
     */
    public AffineTransform currentTransform() {
        return (AffineTransform)transforms.get(position + 1);
    }

    /**
     * Adds a transform to the history.
     */
    public void update(AffineTransform at) {
        if (position < -1) {
            position = -1;
        }
        if (++position < transforms.size()) {
            if (!transforms.get(position).equals(at)) {
                transforms = transforms.subList(0, position + 1);
            }
            transforms.set(position, at);
        } else {
            transforms.add(at);
        }
    }
}
