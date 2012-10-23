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
package org.apache.flex.forks.batik.gvt.text;

import java.text.AttributedCharacterIterator;
import java.text.CharacterIterator;
import java.util.Map;
import java.util.Set;

/**
 * AttributedCharacterSpanIterator
 *
 * Used to provide ACI functionality to a "substring" of an AttributedString.
 * In this way a TextLayout can be created which only uses a substring of
 * AttributedString.
 *
 * @author <a href="mailto:bill.haneman@ireland.sun.com">Bill Haneman</a>
 * @version $Id: AttributedCharacterSpanIterator.java 475477 2006-11-15 22:44:28Z cam $
 */

public class AttributedCharacterSpanIterator implements
                                   AttributedCharacterIterator {

    private AttributedCharacterIterator aci;
    private int begin;
    private int end;

    /**
     * Construct a AttributedCharacterSpanIterator from a subinterval of
     * an existing AttributedCharacterIterator.
     * @param aci The source AttributedCharacterIterator
     * @param start the first index of the subinterval
     * @param stop the index of the first character after the subinterval
     */
    public AttributedCharacterSpanIterator(AttributedCharacterIterator aci, 
                                           int start, int stop) {
        this.aci = aci;
        end = Math.min(aci.getEndIndex(), stop);
        begin = Math.max(aci.getBeginIndex(), start);
        this.aci.setIndex(begin);
    }

    //From java.text.AttributedCharacterIterator

    /**
     * Get the keys of all attributes defined on the iterator's text range.
     */
    public Set getAllAttributeKeys() {
        return aci.getAllAttributeKeys();
        // FIXME: not if there are atts outside the substring!
    }

    /**
     * Get the value of the named attribute for the current
     *     character.
     */
    public Object getAttribute(AttributedCharacterIterator.Attribute attribute) {
        return aci.getAttribute(attribute);
    }

    /**
     * Returns a map with the attributes defined on the current
     * character.
     */
    public Map getAttributes() {
        return aci.getAttributes();
    }

    /**
     * Get the index of the first character following the
     *     run with respect to all attributes containing the current
     *     character.
     */
    public int getRunLimit() {
        return Math.min(aci.getRunLimit(), end);
    }

    /**
     * Get the index of the first character following the
     *      run with respect to the given attribute containing the current
     *      character.
     */
    public int getRunLimit(AttributedCharacterIterator.Attribute attribute) {
        return Math.min(aci.getRunLimit(attribute), end);
    }

    /**
     * Get the index of the first character following the
     *     run with respect to the given attributes containing the current
     *     character.
     */
    public int getRunLimit(Set attributes) {
        return Math.min(aci.getRunLimit(attributes), end);
    }

    /**
     * Get the index of the first character of the run with
     *    respect to all attributes containing the current character.
     */
    public int getRunStart() {
        return Math.max(aci.getRunStart(), begin);
    }

    /**
     * Get the index of the first character of the run with
     *      respect to the given attribute containing the current character.
     * @param attribute The attribute for whose appearance the first offset
     *      is requested.
     */
    public int getRunStart(AttributedCharacterIterator.Attribute attribute) {
        return Math.max(aci.getRunStart(attribute), begin);
    }

    /**
     * Get the index of the first character of the run with respect to
     * the given attributes containing the current character.
     * @param attributes the Set of attributes which begins at the
     * returned index.  
     */
    public int getRunStart(Set attributes) {
        return Math.max(aci.getRunStart(attributes), begin);
    }

    //From CharacterIterator

    /**
     * Create a copy of this iterator
     */
    public Object clone() {
        return new AttributedCharacterSpanIterator(
                      (AttributedCharacterIterator) aci.clone(), begin, end);
    }

    /**
     * Get the character at the current position (as returned
     *      by getIndex()).
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    public char current() {
        return aci.current();
    }

    /**
     * Sets the position to getBeginIndex().
     * @return the character at the start index of the text.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    public char first() {
        return aci.setIndex(begin);
    }

    /**
     * Get the start index of the text.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    public int getBeginIndex() {
        return begin;
    }

    /**
     * Get the end index of the text.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    public int getEndIndex() {
        return end;
    }

    /**
     * Get the current index.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    public int getIndex() {
        return aci.getIndex();
    }

    /**
     * Sets the position to getEndIndex()-1 (getEndIndex() if
     * the text is empty) and returns the character at that position.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    public char last() {
        return setIndex(end-1);
    }

    /**
     * Increments the iterator's index by one, returning the next character.
     * @return the character at the new index.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    public char next() {
        if (getIndex() < end-1 ) {
            return aci.next();
        } else {
            return setIndex(end);
        }
    }

    /**
     * Decrements the iterator's index by one and returns
     * the character at the new index.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    public char previous() {
        if (getIndex() > begin) {
            return aci.previous();
        } else {
            return CharacterIterator.DONE;
        }
    }

    /**
     * Sets the position to the specified position in the text.
     * @param position The new (current) index into the text.
     * @return the character at new index <em>position</em>.
     * <br><b>Specified by:</b> java.text.CharacterIterator.
     */
    public char setIndex(int position) {
        int ndx = Math.max(position, begin);
        ndx = Math.min(ndx, end);
        char c = aci.setIndex(ndx);
        if (ndx == end) {
            c = CharacterIterator.DONE;
        }
        return c;
    }
}






