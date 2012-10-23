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
package org.apache.flex.forks.batik.dom;

import org.w3c.dom.Node;

/**
 * This class implements the {@link org.w3c.dom.Notation} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: GenericNotation.java 475685 2006-11-16 11:16:05Z cam $
 */
public class GenericNotation extends AbstractNotation {
    /**
     * Is this node immutable?
     */
    protected boolean readonly;

    /**
     * Creates a new Notation object.
     */
    protected GenericNotation() {
    }

    /**
     * Creates a new Notation object.
     */
    public GenericNotation(String           name,
                           String           pubId,
                           String           sysId,
                           AbstractDocument owner) {
        ownerDocument = owner;
        setNodeName(name);
        setPublicId(pubId);
        setSystemId(sysId);
    }

    /**
     * Tests whether this node is readonly.
     */
    public boolean isReadonly() {
        return readonly;
    }

    /**
     * Sets this node readonly attribute.
     */
    public void setReadonly(boolean v) {
        readonly = v;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new GenericNotation();
    }
}
