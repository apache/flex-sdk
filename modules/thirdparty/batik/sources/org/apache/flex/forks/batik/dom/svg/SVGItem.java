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

 */package org.apache.flex.forks.batik.dom.svg;

/**
 * This interface represents an item in an SVGXXXList.
 *
 * The item is required to hold a reference to its parent 
 * list so that an item can be moved from one list to another.
 *
 * A string representation of the item is also required in order
 * to update the value of the attribute the list containing 
 * the item represents.
 *
 * If the value of the item is changed, it is required 
 * to notify the list it belongs to in order to synchronized
 * the list and the attribute the list represents.
 *
 * @see AbstractSVGList#itemChanged()
 *
 * @author <a href="mailto:nicolas.socheleau@bitflash.com">Nicolas Socheleau</a>
 * @version $Id: SVGItem.java,v 1.3 2004/08/18 07:13:14 vhardy Exp $
 */
public interface SVGItem {

    /**
     * Associates an item to an SVGXXXList
     *
     * @param list list the item belongs to.
     */
    void setParent(AbstractSVGList list);

    /**
     * Return the list the item belongs to.
     *
     * @return list the item belongs to. This
     *   could be if the item belongs to no list.
     */
    AbstractSVGList getParent();

    /**
     * Return the String representation of the item.
     *
     * @return textual representation of the item
     *  to be inserted in the attribute value 
     *  representing the list.
     */
    String getValueAsString();
}
