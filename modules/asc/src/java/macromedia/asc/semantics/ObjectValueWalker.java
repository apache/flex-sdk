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

package macromedia.asc.semantics;

import java.util.Iterator;

/** ObjectValueWalker<P>
 * Takes a starting ObjectValue and returns an interator that walks up the prototype/interface chain.<BR> 
 * All the next() are on demand, so we don't waste too much time preloading more than we may need.
 * 
 * @author Jono Spiro */
public abstract class ObjectValueWalker implements Iterator<ObjectValue>
{
	/** Doesn't do anything (needed to implement Iterator) */
	final public void remove() {}

	final public Iterator<ObjectValue> iterator()
	{
		return this;
	}
	
	abstract void clear();
};
