/*

   Copyright 2002-2003  The Apache Software Foundation 

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

import org.w3c.flex.forks.css.sac.SACMediaList;

/**
 * This class represents a @media CSS rule.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: MediaRule.java,v 1.4 2004/08/18 07:12:48 vhardy Exp $
 */
public class MediaRule extends StyleSheet implements Rule {
    
    /**
     * The type constant.
     */
    public final static short TYPE = (short)1;

    /**
     * The media list.
     */
    protected SACMediaList mediaList;

    /**
     * Returns a constant identifying the rule type.
     */
    public short getType() {
        return TYPE;
    }

    /**
     * Sets the media list.
     */
    public void setMediaList(SACMediaList ml) {
        mediaList = ml;
    }

    /**
     * Returns the media list.
     */
    public SACMediaList getMediaList() {
        return mediaList;
    }

    /**
     * Returns a printable representation of this media rule.
     */
    public String toString(CSSEngine eng) {
        StringBuffer sb = new StringBuffer();
        sb.append("@media");
        if (mediaList != null) {
            for (int i = 0; i < mediaList.getLength(); i++) {
                sb.append(' ');
                sb.append(mediaList.item(i));
            }
        }
        sb.append(" {\n");
        for (int i = 0; i < size; i++) {
            sb.append(rules[i].toString(eng));
        }
        sb.append("}\n");
        return sb.toString();
    }
}
