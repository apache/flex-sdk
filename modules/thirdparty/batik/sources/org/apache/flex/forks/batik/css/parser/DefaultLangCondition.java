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
package org.apache.flex.forks.batik.css.parser;

import org.w3c.flex.forks.css.sac.LangCondition;

/**
 * This class provides an implementation of the
 * {@link org.w3c.flex.forks.css.sac.LangCondition} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: DefaultLangCondition.java,v 1.3 2004/08/18 07:13:02 vhardy Exp $
 */
public class DefaultLangCondition implements LangCondition {

    /**
     * The language.
     */
    protected String lang;

    /**
     * Creates a new LangCondition object.
     */
    public DefaultLangCondition(String lang) {
	this.lang = lang;
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.flex.forks.css.sac.Condition#getConditionType()}.
     */    
    public short getConditionType() {
	return SAC_LANG_CONDITION;
    }

    /**
     * <b>SAC</b>: Implements {@link org.w3c.flex.forks.css.sac.LangCondition#getLang()}.
     */
    public String getLang() {
	return lang;
    }

    /**
     * Returns a text representation of this object.
     */
    public String toString() {
	return ":lang(" + lang + ")";
    }
}
