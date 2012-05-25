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

import org.w3c.flex.forks.css.sac.SelectorList;

/**
 * This class represents a style rule.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: StyleRule.java,v 1.3 2004/08/18 07:12:48 vhardy Exp $
 */
public class StyleRule implements Rule {
    
    /**
     * The type constant.
     */
    public final static short TYPE = (short)0;

    /**
     * The selector list.
     */
    protected SelectorList selectorList;

    /**
     * The style declaration.
     */
    protected StyleDeclaration styleDeclaration;

    /**
     * Returns a constant identifying the rule type.
     */
    public short getType() {
        return TYPE;
    }

    /**
     * Sets the selector list.
     */
    public void setSelectorList(SelectorList sl) {
        selectorList = sl;
    }

    /**
     * Returns the selector list.
     */
    public SelectorList getSelectorList() {
        return selectorList;
    }

    /**
     * Sets the style map.
     */
    public void setStyleDeclaration(StyleDeclaration sd) {
        styleDeclaration = sd;
    }

    /**
     * Returns the style declaration.
     */
    public StyleDeclaration getStyleDeclaration() {
        return styleDeclaration;
    }

    /**
     * Returns a printable representation of this style rule.
     */
    public String toString(CSSEngine eng) {
        StringBuffer sb = new StringBuffer();
        if (selectorList != null) {
            sb.append(selectorList.item(0));
            for (int i = 1; i < selectorList.getLength(); i++) {
                sb.append(", ");
                sb.append(selectorList.item(i));
            }
        }
        sb.append(" {\n");
        if (styleDeclaration != null) {
            sb.append(styleDeclaration.toString(eng));
        }
        sb.append("}\n");
        return sb.toString();
    }
}
