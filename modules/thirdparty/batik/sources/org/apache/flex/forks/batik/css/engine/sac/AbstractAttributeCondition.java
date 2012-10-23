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

import org.w3c.css.sac.AttributeCondition;

/**
 * This class provides an abstract implementation of the {@link
 * org.w3c.css.sac.AttributeCondition} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractAttributeCondition.java 501844 2007-01-31 13:54:05Z dvholten $
 */
public abstract class AbstractAttributeCondition
    implements AttributeCondition,
               ExtendedCondition {

    /**
     * The attribute value.
     */
    protected String value;

    /**
     * Creates a new AbstractAttributeCondition object.
     */
    protected AbstractAttributeCondition(String value) {
        this.value = value;
    }

    /**
     * Indicates whether some other object is "equal to" this one.
     * @param obj the reference object with which to compare.
     */
    public boolean equals(Object obj) {
        if (obj == null || (obj.getClass() != getClass())) {
            return false;
        }
        AbstractAttributeCondition c = (AbstractAttributeCondition)obj;
        return c.value.equals(value);
    }

    /**
     * equal objects should have equal hashCodes.
     * @return hashCode of this AbstractAttributeCondition
     */
    public int hashCode() {
        return value == null ? -1 : value.hashCode();
    }

    /**
     * Returns the specificity of this condition.
     */
    public int getSpecificity() {
        return 1 << 8;
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.AttributeCondition#getValue()}.
     */
    public String getValue() {
        return value;
    }
}
