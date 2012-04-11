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

package flex2.compiler.mxml.rep;

import flex2.compiler.mxml.gen.CodeFragmentList;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.rep.init.ArrayElementInitializer;
import flex2.compiler.mxml.rep.init.Initializer;
import flex2.compiler.util.IteratorList;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;

import org.apache.commons.collections.Predicate;
import org.apache.commons.collections.iterators.FilterIterator;

/*
 * TODO this shouldn't really subclass Model. Either detach it, or
 * block other Model methods like setProperty() below
 */
/**
 * This class represents an Array of MXML document nodes.
 */
public class Array extends Model
{
	protected Collection<ArrayElementInitializer> list;
	protected Type elementType;

	public Array(MxmlDocument document, int line, Type elementType)
	{
		this(document, null, line, elementType);
	}

    public Array(MxmlDocument document, Model parent, int line, Type elementType)
    {
		this(document, document.getTypeTable().arrayType, parent, line, elementType);
    }

	protected Array(MxmlDocument document, Type type, Model parent, int line, Type elementType)
	{
		super(document, type, parent, line);
		this.list = new ArrayList<ArrayElementInitializer>();
		this.elementType = elementType;
	}

	public void setProperty(String name, Object value)
	{
		assert false : "Array may not have properties";
	}
	
	public void addEntry(Model entry)
	{
		ArrayElementInitializer initializer = new ArrayElementInitializer(elementType, list.size(), entry, entry.getXmlLineNumber(), standardDefs);
		initializer.setStateSpecific(entry.isStateSpecific());
		list.add(initializer);
	}

	public void addEntry(Object entry, int line)
	{
		list.add(new ArrayElementInitializer(elementType, list.size(), entry, line, standardDefs));
	}

	public void addEntries(Collection entries, int line)
	{
		for (Iterator iter = entries.iterator(); iter.hasNext(); )
		{
			addEntry(iter.next(), line);
		}
	}

	public void setEntries(Collection<ArrayElementInitializer> entries)
	{
		this.list = entries;
	}

	public Collection<ArrayElementInitializer> getEntries()
	{
		return list;
	}

	public int size()
	{
		return list.size();
	}

	public boolean isEmpty()
	{
		return list.isEmpty();
	}

	/**
	 * Note that we do *not* filter out bindings for element initializers.
	 */
	@SuppressWarnings("unchecked")
	public final Iterator<ArrayElementInitializer> getElementInitializerIterator()
	{
	    return new FilterIterator(list.iterator(), new Predicate()
        {
            public boolean evaluate(Object object)
            {
                return (! (((ArrayElementInitializer) object).getValue() instanceof Reparent));
            }
        });
	}

	/**
	 *  iterator containing definitions from our initializers
	 */
	public Iterator<CodeFragmentList> getSubDefinitionsIterator()
	{
		IteratorList iterList = new IteratorList();

		addDefinitionIterators(iterList, getElementInitializerIterator());

		return iterList.toIterator();
	}

	/**
	 *  iterator containing our initializers
	 */
	public Iterator<Initializer> getSubInitializerIterator()
	{
		IteratorList iterList = new IteratorList();

		iterList.add(getElementInitializerIterator());

		return iterList.toIterator();
	}

	/**
	 * override hasBindings to check entries
	 */
	public boolean hasBindings()
	{
		return bindingsOnly(getEntries().iterator()).hasNext() || super.hasBindings();
	}
}
