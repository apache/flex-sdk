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

import org.w3c.css.sac.ElementSelector;

/**
 * This class provides an abstract implementation of the
 * {@link ElementSelector} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractElementSelector.java 475685 2006-11-16 11:16:05Z cam $
 */
public abstract class AbstractElementSelector extends AbstractSelector
    implements ElementSelector {

    /**
     * The namespace URI.
     */
    protected String namespaceURI;

    /**
     * The local name.
     */
    protected String localName;

    /**
     * Creates a new ElementSelector object.
     */
    protected AbstractElementSelector(String uri, String name) {
	namespaceURI = uri;
	localName    = name;
    }

    /**
     * <b>SAC</b>: Implements {@link ElementSelector#getNamespaceURI()}.
     */
    public String getNamespaceURI() {
	return namespaceURI;
    }

    /**
     * <b>SAC</b>: Implements {@link ElementSelector#getLocalName()}.
     */
    public String getLocalName() {
	return localName;
    }
}
