/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flash.swf;

import java.util.Iterator;
import java.util.NoSuchElementException;

/**
 * Base class for all SWF tags.
 *
 * @author Clement Wong
 */
public abstract class Tag
        implements TagValues
{
	final public int code;

    public Tag(int code)
    {
        this.code = code;
    }

    /**
	 * Subclasses implement this method to callback one of the methods in TagHandler...
	 * @param h
	 */
	public abstract void visit(TagHandler h);

	/**
	 * many tags have zero or one reference, in which case they only need
	 * to override this method.  Tags that have two or more references
	 * should override getReferences() and provide an Iterator.
	 * @return
	 */
	protected Tag getSimpleReference()
    {
        return null;
    }

    /**
     * Find the immediate dependencies.  unlike visitDefs, it doesn't explore the entire tree.
     * The user must do a recursive walk if they care to go beyond the first order dependencies.
     * The default implementation provides an iterator over a single simple reference, defined
     * by the derived class via the getSimpleReference() call.
     * @return An iterator over the first order Tag dependencies.
     */

    public Iterator<Tag> getReferences()
    {
        return new Iterator<Tag>()
        {
            private boolean done = false;

            public boolean hasNext()
            {
                return (!((getSimpleReference() == null) || done));
            }
            public Tag next()
            {
                if ( hasNext() )
                {
                    done = true;
                    return getSimpleReference();
                }
                throw new NoSuchElementException();
            }
            public void remove()
            {
                throw new UnsupportedOperationException();
            }
        };
    }

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof Tag)
        {
            Tag tag = (Tag) object;

            if (tag.code == this.code)
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

    public int hashCode()
    {
        return code;
    }

    public static boolean equals(Object o1, Object o2)
    {
        return o1 == o2 || o1 != null && o1.equals(o2);
    }
}
