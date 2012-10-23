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

import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;

import org.apache.flex.forks.batik.dom.anim.AnimationTarget;
import org.apache.flex.forks.batik.dom.anim.AnimationTargetListener;
import org.apache.flex.forks.batik.dom.svg.SVGAnimationTargetContext;

import org.w3c.dom.Element;

/**
 * Abstract bridge class for those elements that can be animated.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimatableSVGBridge.java 490655 2006-12-28 05:19:44Z cam $
 */
public abstract class AnimatableSVGBridge
        extends AbstractSVGBridge
        implements SVGAnimationTargetContext {

    /**
     * The element that has been handled by this bridge.
     */
    protected Element e;

    /**
     * The bridge context to use for dynamic updates.
     */
    protected BridgeContext ctx;

    /**
     * Map of CSS property names to {@link LinkedList}s of
     * {@link AnimationTargetListener}s.
     */
    protected HashMap targetListeners;

    // SVGAnimationTargetContext /////////////////////////////////////////////

    /**
     * Adds a listener for changes to the given attribute value.
     */
    public void addTargetListener(String pn, AnimationTargetListener l) {
        if (targetListeners == null) {
            targetListeners = new HashMap();
        }
        LinkedList ll = (LinkedList) targetListeners.get(pn);
        if (ll == null) {
            ll = new LinkedList();
            targetListeners.put(pn, ll);
        }
        ll.add(l);
    }

    /**
     * Removes a listener for changes to the given attribute value.
     */
    public void removeTargetListener(String pn, AnimationTargetListener l) {
        LinkedList ll = (LinkedList) targetListeners.get(pn);
        ll.remove(l);
    }

    /**
     * Fires the listeners registered for changes to the base value of the
     * given CSS property.
     */
    protected void fireBaseAttributeListeners(String pn) {
        if (targetListeners != null) {
            LinkedList ll = (LinkedList) targetListeners.get(pn);
            if (ll != null) {
                Iterator it = ll.iterator();
                while (it.hasNext()) {
                    AnimationTargetListener l =
                        (AnimationTargetListener) it.next();
                    l.baseValueChanged((AnimationTarget) e, null, pn, true);
                }
            }
        }
    }
}
