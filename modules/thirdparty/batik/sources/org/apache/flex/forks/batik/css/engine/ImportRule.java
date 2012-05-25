/*

   Copyright 2002  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.css.engine;

import java.net.URL;

/**
 * This class represents a @import CSS rule.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ImportRule.java,v 1.3 2004/08/18 07:12:48 vhardy Exp $
 */
public class ImportRule extends MediaRule {
    
    /**
     * The type constant.
     */
    public final static short TYPE = (short)2;

    /**
     * The URI of the imported stylesheet.
     */
    protected URL uri;

    /**
     * Creates a new ImportRule.
     * @param ss The imported style-sheet.
     */

    /**
     * Returns a constant identifying the rule type.
     */
    public short getType() {
        return TYPE;
    }

    /**
     * Sets the URI of the imported stylesheet.
     */
    public void setURI(URL u) {
        uri = u;
    }

    /**
     * Returns the URI of the imported stylesheet.
     */
    public URL getURI() {
        return uri;
    }

    /**
     * Returns a printable representation of this import rule.
     */
    public String toString(CSSEngine eng) {
        StringBuffer sb = new StringBuffer();
        sb.append("@import \"");
        sb.append(uri);
        sb.append("\"");
        if (mediaList != null) {
            for (int i = 0; i < mediaList.getLength(); i++) {
                sb.append(' ');
                sb.append(mediaList.item(i));
            }
        }
        sb.append(";\n");
        return sb.toString();
    }
}
