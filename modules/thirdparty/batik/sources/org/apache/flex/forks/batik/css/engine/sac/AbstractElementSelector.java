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

import org.w3c.css.sac.ElementSelector;

/**
 * This class provides an abstract implementation of the ElementSelector
 * interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractElementSelector.java 475685 2006-11-16 11:16:05Z cam $
 */
public abstract class AbstractElementSelector
    implements ElementSelector,
               ExtendedSelector {

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
     * Indicates whether some other object is "equal to" this one.
     * @param obj the reference object with which to compare.
     */
    public boolean equals(Object obj) {
        if (obj == null || (obj.getClass() != getClass())) {
            return false;
        }
        AbstractElementSelector s = (AbstractElementSelector)obj;
        return (s.namespaceURI.equals(namespaceURI) &&
                s.localName.equals(localName));
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.ElementSelector#getNamespaceURI()}.
     */
    public String getNamespaceURI() {
        return namespaceURI;
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.ElementSelector#getLocalName()}.
     */
    public String getLocalName() {
        return localName;
    }

    /**
     * Fills the given set with the attribute names found in this selector.
     */
    public void fillAttributeSet(Set attrSet) {
    }
}
