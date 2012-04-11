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

package flex2.compiler.mxml.dom;

import java.util.List;

import flex2.compiler.mxml.Element;
import flex2.compiler.mxml.Token;

/**
 * Represents a generic tag not necessarily in the MXML language
 * namespace.
 *
 * @author Clement Wong
 */
public class Node extends Element
{
	public Node(String uri, String localName)
	{
		this(uri, localName, 0);
	}

	public Node(String uri, String localName, int size)
	{
		super(uri, localName, size);
		index = 0;
	}

	private int index;

	public void setIndex(int index)
	{
		this.index = index;
	}

	public int getIndex()
	{
		return index;
	}

	public void analyze(Analyzer analyzer)
	{
		analyzer.prepare(this);
		analyzer.analyze(this);
	}

	public String toString()
	{
		return image + " " + beginLine;
	}

	@Override
    public void addChild(Token child)
    {
	    if (processChildrenIndividually && !preserveWhitespace)
	    {
	        if (child instanceof CDATANode)
	        {
	            CDATANode cdata = (CDATANode)child;
	            if (cdata.isWhitespace())
	                return;
	        }
	    }

	    super.addChild(child);
    }

    @Override
    public void addChildren(List<Token> children)
    {
        if (processChildrenIndividually && children != null)
        {
            for (Token child : children)
            {
                addChild(child);
            }
            return;
        }

        super.addChildren(children);
    }

    public String comment;

    /**
     * As part of a workaround for SDK-22601 this flag controls whether a
     * collection of child nodes should be processed individually to allow
     * custom processing on each node. 
     */
    boolean processChildrenIndividually;

	/**
	 * As part of a workaround for SDK-22601 this flag controls whether
	 * pure-whitespace CDATA should be preserved.
	 */
    boolean preserveWhitespace;
}
