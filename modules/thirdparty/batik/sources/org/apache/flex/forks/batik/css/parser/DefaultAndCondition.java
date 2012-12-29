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
package org.apache.flex.forks.batik.css.parser;

import org.w3c.css.sac.Condition;

/**
 * This class provides an implementation of the
 * {@link org.w3c.css.sac.CombinatorCondition} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: DefaultAndCondition.java 501495 2007-01-30 18:00:36Z dvholten $
 */
public class DefaultAndCondition extends AbstractCombinatorCondition {

    /**
     * Creates a new CombinatorCondition object.
     */
    public DefaultAndCondition(Condition c1, Condition c2) {
        super(c1, c2);
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.Condition#getConditionType()}.
     */
    public short getConditionType() {
        return SAC_AND_CONDITION;
    }

    /**
     * Returns a text representation of this object.
     */
    public String toString() {
        return String.valueOf( getFirstCondition() ) + getSecondCondition();
    }
}
