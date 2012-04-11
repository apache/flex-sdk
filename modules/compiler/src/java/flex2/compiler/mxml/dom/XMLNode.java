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

import java.util.*;

/**
 * Represents a &lt;XML&gt; tag in the MXML language namespace.
 *
 * @author Clement Wong
 */
public class XMLNode extends Node
{
	public static final Set<QName> attributes;

	static
	{
		attributes = new HashSet<QName>();
		attributes.add(new QName("", StandardDefs.PROP_ID));
		attributes.add(new QName("", StandardDefs.PROP_SOURCE));
        attributes.add(new QName("", StandardDefs.PROP_FORMAT)); //for WebService Operation
	}

	XMLNode(String uri, String localName, int size)
	{
		super(uri, localName, size);
	}

	private Node[] sourceFile;
	
	public void analyze(Analyzer analyzer)
	{
		analyzer.prepare(this);
		analyzer.analyze(this);
	}

	public void setSourceFile(Node[] nodes)
	{
		sourceFile = nodes;
	}

	public Node[] getSourceFile()
	{
		return sourceFile;
	}

	public int getChildCount()
	{
		return sourceFile != null ? sourceFile.length : super.getChildCount();
	}

	public Token getChildAt(int index)
	{
		return sourceFile != null ? sourceFile[index] : super.getChildAt(index);
	}

	public List<Token> getChildren()
	{
		return sourceFile != null ? Collections.<Token>unmodifiableList(Arrays.asList(sourceFile)) : super.getChildren();
	}

	/**
	 *
	 */
	public boolean isE4X()
	{
		String formatAttr = (String)getAttributeValue("format");
		return formatAttr == null || "E4X".equalsIgnoreCase(formatAttr);
	}
}
