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

import flex2.compiler.mxml.Token;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.util.QName;

import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Represents a primitive tag in the MXML language namespace.
 *
 * @author Clement Wong
 */
public abstract class PrimitiveNode extends Node
{
	public static final Set<QName> attributes;

	static
	{
		attributes = new HashSet<QName>();
		attributes.add(new QName("", StandardDefs.PROP_ID));
		attributes.add(new QName("", StandardDefs.PROP_SOURCE));
		attributes.add(new QName("", StandardDefs.PROP_INCLUDE_STATES));
		attributes.add(new QName("", StandardDefs.PROP_EXCLUDE_STATES));
		attributes.add(new QName("", StandardDefs.PROP_ITEM_CREATION_POLICY));
		attributes.add(new QName("", StandardDefs.PROP_ITEM_DESTRUCTION_POLICY));
	}

	PrimitiveNode(String uri, String localName, int size)
	{
		super(uri, localName, size);
	}

	private CDATANode sourceFile;

	public void setSourceFile(CDATANode cdata)
	{
		sourceFile = cdata;
	}

	public CDATANode getSourceFile()
	{
		return sourceFile;
	}

	public int getChildCount()
	{
		return sourceFile != null ? 1 : super.getChildCount();
	}

	public Token getChildAt(int index)
	{
		return sourceFile != null && index == 0 ? sourceFile : super.getChildAt(index);
	}

	public List<Token> getChildren()
	{
		return sourceFile != null ? Collections.<Token>singletonList(sourceFile) : super.getChildren();
	}
}
