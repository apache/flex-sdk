package org.apache.flex.forks.batik.dom.util;

/**
 * JRE specific helper functions for {@link DOMUtilities}.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id$
 */
public abstract class DOMUtilitiesSupport {

    /**
     * Gets a DOM 3 modifiers string from the given lock and
     * shift bitmasks.
     */
    protected static String getModifiersList(int lockState, int modifiers) {
        if ((modifiers & 0x20) != 0) {
            modifiers = 0x10 | (modifiers & 0x0f);
        } else {
            modifiers = modifiers & 0x0f;
        }
        String s = DOMUtilities.LOCK_STRINGS[lockState & 0x0f];
        if (s.length() != 0) {
            return s + ' ' + DOMUtilities.MODIFIER_STRINGS[modifiers];
        }
        return DOMUtilities.MODIFIER_STRINGS[modifiers];
    }
}
