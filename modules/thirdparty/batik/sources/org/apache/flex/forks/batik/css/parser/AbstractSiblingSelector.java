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

/**
 *  Modified by Adobe Flex to extend AbstractSelector.
 */

package org.apache.flex.forks.batik.css.parser;

import org.w3c.css.sac.Selector;
import org.w3c.css.sac.SiblingSelector;
import org.w3c.css.sac.SimpleSelector;

/**
 * This class provides an abstract implementation of the {@link
 * org.w3c.css.sac.SiblingSelector} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractSiblingSelector.java 475685 2006-11-16 11:16:05Z cam $
 */
public abstract class AbstractSiblingSelector extends AbstractSelector
    implements SiblingSelector {

    /**
     * The node type.
     */
    protected short nodeType;

    /**
     * The selector.
     */
    protected Selector selector;

    /**
     * The simple selector.
     */
    protected SimpleSelector simpleSelector;

    /**
     * Creates a new SiblingSelector object.
     */
    protected AbstractSiblingSelector(short type,
                                      Selector sel,
                                      SimpleSelector simple) {
        nodeType = type;
	selector = sel;
	simpleSelector = simple;
    }

    /**
     * Returns the node type.
     */
    public short getNodeType() {
        return nodeType;
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.SiblingSelector#getSelector()}.
     */    
    public Selector getSelector() {
	return selector;
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.SiblingSelector#getSiblingSelector()}.
     */    
    public SimpleSelector getSiblingSelector() {
	return simpleSelector;
    }
}
