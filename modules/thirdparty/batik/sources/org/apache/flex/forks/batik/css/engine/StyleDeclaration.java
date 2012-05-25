/*

   Copyright 2002-2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.css.engine;

import org.apache.flex.forks.batik.css.engine.value.Value;

/**
 * This class represents a collection of CSS property values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: StyleDeclaration.java,v 1.8 2005/03/29 10:48:02 deweese Exp $
 */
public class StyleDeclaration {

    protected final static int INITIAL_LENGTH = 8;
    
    /**
     * The values.
     */
    protected Value[] values = new Value[INITIAL_LENGTH];

    /**
     * The value indexes.
     */
    protected int[] indexes = new int[INITIAL_LENGTH];

    /**
     * The value priorities.
     */
    protected boolean[] priorities = new boolean[INITIAL_LENGTH];

    /**
     * The number of values in the declaration.
     */
    protected int count;

    /**
     * Returns the number of values in the declaration.
     */
    public int size() {
        return count;
    }

    /**
     * Returns the value at the given index.
     */
    public Value getValue(int idx) {
        return values[idx];
    }

    /**
     * Returns the property index of a value.
     */
    public int getIndex(int idx) {
        return indexes[idx];
    }

    /**
     * Tells whether a value is important.
     */
    public boolean getPriority(int idx) {
        return priorities[idx];
    }

    /**
     * Removes the value at the given index.
     */
    public void remove(int idx) {
        count--;
        for (int i = idx; i < count; i++) {
            values[i] = values[i + 1];
            indexes[i] = indexes[i + 1];
            priorities[i] = priorities[i + 1];
        }
    }

    /**
     * Sets a value within the declaration.
     */
    public void put(int idx, Value v, int i, boolean prio) {
        values[idx]     = v;
        indexes[idx]    = i;
        priorities[idx] = prio;
    }

    /**
     * Appends a value to the declaration.
     */
    public void append(Value v, int idx, boolean prio) {
        if (values.length == count) {
            Value[]   newval  = new Value[count * 2];
            int[]     newidx  = new int[count * 2];
            boolean[] newprio = new boolean[count * 2];
            for (int i = 0; i < count; i++) {
                newval[i]  = values[i];
                newidx[i]  = indexes[i];
                newprio[i] = priorities[i];
            }
            values     = newval;
            indexes    = newidx;
            priorities = newprio;
        }
        for (int i = 0; i < count; i++) {
            if (indexes[i] == idx) {
                // Replace existing property values, 
                // unless they are important!
                if (prio || (priorities[i] == prio)) {
                    values    [i] = v;
                    priorities[i] = prio;
                }
                return;
            }
        }
        values    [count] = v;
        indexes   [count] = idx;
        priorities[count] = prio;
        count++;
    }

    /**
     * Returns a printable representation of this style rule.
     */
    public String toString(CSSEngine eng) {
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < count; i++) {
            sb.append(eng.getPropertyName(indexes[i]));
            sb.append(": ");
            sb.append(values[i]);
            sb.append(";\n");
        }
        return sb.toString();
    }
}
