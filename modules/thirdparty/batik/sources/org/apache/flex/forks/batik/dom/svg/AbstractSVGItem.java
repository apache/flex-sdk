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
package org.apache.flex.forks.batik.dom.svg;

/**
 * Adapter for the SVGItem interface.
 *
 * @author <a href="mailto:nicolas.socheleau@bitflash.com">Nicolas Socheleau</a>
 * @version $Id: AbstractSVGItem.java 475477 2006-11-15 22:44:28Z cam $
 */
public abstract class AbstractSVGItem implements SVGItem {

    /**
     * List the item belongs to.
     */
    protected AbstractSVGList parent;

    /**
     * String representation of the item.
     * This is a cached representation of the item while it is not changed.
     */
    protected String itemStringValue;

    /**
     * Return the string representation of the item.
     */
    protected abstract String getStringValue();

    /**
     * Creates a new AbstractSVGList.
     */
    protected AbstractSVGItem() {
    }

    /**
     * Assigns a parent list to this item.
     * @param list The list the item belongs.
     */
    public void setParent(AbstractSVGList list) {
        parent = list;
    }

    /**
     * Returns the parent list of this item.
     */
    public AbstractSVGList getParent() {
        return parent;
    }

    /**
     * Notifies the parent list that the item has changed.
     * This discards the cached representation of the item.
     */
    protected void resetAttribute() {
        if (parent != null) {
            itemStringValue = null;
            parent.itemChanged();
        }
    }

    /**
     * Returns the cached representation of the item if valid, otherwise
     * recomputes the String representation of the item.
     */
    public String getValueAsString() {
        if (itemStringValue == null) {
            itemStringValue = getStringValue();
        }
        return itemStringValue;
    }
}
