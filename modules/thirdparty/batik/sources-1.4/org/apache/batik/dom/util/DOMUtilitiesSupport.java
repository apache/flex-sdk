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
package org.apache.flex.forks.batik.dom.util;

/**
 * JRE specific helper functions for {@link DOMUtilities}.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: DOMUtilitiesSupport.java 502541 2007-02-02 08:55:41Z dvholten $
 */
public abstract class DOMUtilitiesSupport {

    static final String[] BITS = {
        "Shift",
        "Ctrl",
        "Meta-or-Button3",
        "Alt-or-Button2",
        "Button1",
        "AltGraph",
        "ShiftDown",
        "CtrlDown",
        "MetaDown",
        "AltDown",
        "Button1Down",
        "Button2Down",
        "Button3Down",
        "AltGraphDown"
    };

    /**
     * Gets a DOM 3 modifiers string from the given lock and
     * shift bitmasks.
     */
    protected static String getModifiersList(int lockState, int modifiersEx) {
        if ((modifiersEx & (1 << 13)) != 0) {
            modifiersEx = 0x10 | ((modifiersEx >> 6) & 0x0f);
        } else {
            modifiersEx = (modifiersEx >> 6) & 0x0f;
        }
        String s = DOMUtilities.LOCK_STRINGS[lockState & 0x0f];
        if (s.length() != 0) {
            return s + ' ' + DOMUtilities.MODIFIER_STRINGS[modifiersEx];
        }
        return DOMUtilities.MODIFIER_STRINGS[modifiersEx];
    }
}
