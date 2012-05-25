/*

   Copyright 2001-2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.ext.awt;

import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.lang.ref.Reference;

/**
 * This class is here to workaround a javadoc problem. It is only used by
 * <code>GraphicsNode</code>.
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @version $Id: BufferedImageHintKey.java,v 1.6 2004/08/18 07:13:41 vhardy Exp $
 */
final class BufferedImageHintKey extends RenderingHints.Key {
    BufferedImageHintKey(int number) { super(number); }

    public boolean isCompatibleValue(Object val) {
        if (val == null)
            return true;

        if (!(val instanceof Reference))
            return false;
        Reference ref = (Reference)val;
        val = ref.get();
        if (val == null)
            return true;
        if (val instanceof BufferedImage)
            return true;

        return false;
    }
}

