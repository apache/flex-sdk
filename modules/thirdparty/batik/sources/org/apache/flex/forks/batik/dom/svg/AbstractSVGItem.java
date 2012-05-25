/*

   Copyright 2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.dom.svg;

/**
 * Adapter for the SVGItem interface.
 *
 * @author <a href="mailto:nicolas.socheleau@bitflash.com">Nicolas Socheleau</a>
 * @version $Id: AbstractSVGItem.java,v 1.3 2004/08/18 07:13:13 vhardy Exp $
 */
public abstract class AbstractSVGItem 
    implements SVGItem {

    /**
     * List the item belongs to.
     */
    protected AbstractSVGList parent;

    /**
     * String representation of the item.
     *
     * This is a cached representation of the
     * item while it is not changed.
     */
    protected String itemStringValue;

    /**
     * Return the string representation of the item.
     */
    protected abstract String getStringValue();

    /// Default Constructor.
    protected AbstractSVGItem(){
    }

    /**
     * Assign a parent list to this item.
     *
     * @param list : list the item belongs.
     */
    public void setParent(AbstractSVGList list){
        parent = list;
    }

    /**
     * Return the parent list of the item.
     *
     * @return list the item belongs.
     */
    public AbstractSVGList getParent(){
        return parent;
    }

    /**
     * Notifies the parent list that
     * the item has changed.
     *
     * Discard the cached representation
     * of the item.
     */
    protected void resetAttribute(){
        if ( parent != null ){
            itemStringValue = null;
            parent.itemChanged();
        }
    }

    /**
     * Return the cached representation
     * of the item if valid otherwise
     * re-computes the String representation
     * of the item.
     */
    public String getValueAsString(){
        if ( itemStringValue == null ){
            itemStringValue = getStringValue();
        }
        return itemStringValue;
    }
}
