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

package flex2.compiler.util;

import org.apache.commons.collections.iterators.IteratorChain;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.Collections;

/**
 * Utility wrapper for IteratorChain, culls empty adds and exploits
 * singletons.
 */
public class IteratorList extends ArrayList<Iterator>
{
	private static final long serialVersionUID = -5093248926480065063L;

    public boolean add(Iterator iter)
	{
		if (iter.hasNext())
		{
			return super.add(iter);
		}
        return false;
	}

	public Iterator toIterator()
	{
		switch (size())
		{
            case 0:     return Collections.emptyList().iterator();
			case 1: 	return get(0);
			default: 	return new IteratorChain(this);
		}
	}
}
