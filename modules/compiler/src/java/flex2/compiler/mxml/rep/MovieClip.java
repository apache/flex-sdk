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
import flex2.compiler.mxml.rep.init.Initializer;
import flex2.compiler.mxml.rep.init.VisualChildInitializer;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.util.IteratorList;

import java.util.*;

/**
 * This class represents a (Halo) visual child node in a MXML
 * document.
 *
 * @author Edwin Smith
 */
/*
 * TODO remove when you-know-what happens
 * 
 * jono: someone should really check in with you-know-who before you-know-when... or else.
 */
public class MovieClip extends Model
{
	private Collection<VisualChildInitializer> children;

	public MovieClip(MxmlDocument document, Type type, Model parent, int line)
	{
		super(document, type, parent, line);
		children = new ArrayList<VisualChildInitializer>();
	}

	public void addChild(MovieClip child)
	{
		children.add(new VisualChildInitializer(child));

		if (standardDefs.isRepeater(child.getType()))
		{
			getDocument().ensureDeclaration(this);
		}
	}
	
	public Collection<VisualChildInitializer> children()
	{
		return children;
	}

	public boolean hasChildren()
	{
		return !children.isEmpty();
	}

	/**
	 *
	 */
	public Iterator<VisualChildInitializer> getChildInitializerIterator()
	{
		return children.iterator();
	}

	/**
	 *  iterator containing definitions from our initializers
	 */
	public Iterator<CodeFragmentList> getSubDefinitionsIterator()
	{
		IteratorList iterList = new IteratorList();

		iterList.add(super.getSubDefinitionsIterator());
		
		addDefinitionIterators(iterList, getChildInitializerIterator());

		return iterList.toIterator();
	}

	/**
	 *  iterator containing our initializers
	 */
	public Iterator<Initializer> getSubInitializerIterator()
	{
		IteratorList iterList = new IteratorList();

		iterList.add(super.getSubInitializerIterator());
		iterList.add(getChildInitializerIterator());

		return iterList.toIterator();
	}

	/**
	 * override hasBindings to check children
	 */
	public boolean hasBindings()
	{
		return bindingsOnly(children().iterator()).hasNext() || super.hasBindings();
	}

}
