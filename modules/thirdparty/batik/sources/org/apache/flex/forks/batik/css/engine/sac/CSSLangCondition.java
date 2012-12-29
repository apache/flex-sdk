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
package org.apache.flex.forks.batik.css.engine.sac;

import java.util.Set;

import org.apache.flex.forks.batik.util.XMLConstants;

import org.w3c.css.sac.LangCondition;
import org.w3c.dom.Element;

/**
 * This class provides an implementation of the
 * {@link org.w3c.css.sac.LangCondition} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: CSSLangCondition.java 574507 2007-09-11 08:37:34Z cam $
 */

public class CSSLangCondition
    implements LangCondition,
               ExtendedCondition {
    /**
     * The language.
     */
    protected String lang;

    /**
     * The language with a hyphen suffixed.
     */
    protected String langHyphen;

    /**
     * Creates a new LangCondition object.
     */
    public CSSLangCondition(String lang) {
        this.lang = lang.toLowerCase();
        this.langHyphen = lang + '-';
    }

    /**
     * Indicates whether some other object is "equal to" this one.
     * @param obj the reference object with which to compare.
     */
    public boolean equals(Object obj) {
        if (obj == null || (obj.getClass() != getClass())) {
            return false;
        }
        CSSLangCondition c = (CSSLangCondition)obj;
        return c.lang.equals(lang);
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.Condition#getConditionType()}.
     */
    public short getConditionType() {
        return SAC_LANG_CONDITION;
    }

    /**
     * <b>SAC</b>: Implements {@link org.w3c.css.sac.LangCondition#getLang()}.
     */
    public String getLang() {
        return lang;
    }

    /**
     * Returns the specificity of this condition.
     */
    public int getSpecificity() {
        return 1 << 8;
    }

    /**
     * Tests whether this condition matches the given element.
     */
    public boolean match(Element e, String pseudoE) {
        String s = e.getAttribute("lang").toLowerCase();
        if (s.equals(lang) || s.startsWith(langHyphen)) {
            return true;
        }
        s = e.getAttributeNS(XMLConstants.XML_NAMESPACE_URI,
                             XMLConstants.XML_LANG_ATTRIBUTE).toLowerCase();
        return s.equals(lang) || s.startsWith(langHyphen);
    }

    /**
     * Fills the given set with the attribute names found in this selector.
     */
    public void fillAttributeSet(Set attrSet) {
        attrSet.add("lang");
    }

    /**
     * Returns a text representation of this object.
     */
    public String toString() {
        return ":lang(" + lang + ')';
    }
}
