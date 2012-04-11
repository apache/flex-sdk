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

import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.util.QName;

import java.util.Set;
import java.util.HashSet;

/**
 * Represents a &lt;InlineComponent&gt; tag in the MXML language
 * namespace.
 *
 * @author Paul Reilly
 */
public class InlineComponentNode extends Node
{
	public static final String CLASS_NAME_ATTR = "className";

	public static final Set<QName> attributes;
	static
	{
		attributes = new HashSet<QName>();
		attributes.add(new QName("", StandardDefs.PROP_ID));
		attributes.add(new QName("", CLASS_NAME_ATTR));
	}

	private QName classQName;

	InlineComponentNode(String uri, String localName, int size)
	{
		super(uri, localName, size);
	}

	public void analyze(Analyzer analyzer)
	{
		analyzer.prepare(this);
		analyzer.analyze(this);
	}

	public void setClassQName(QName classQName)
	{
		assert this.classQName == null;
		this.classQName = classQName;
	}

	public QName getClassQName()
	{
		assert this.classQName != null;
		return classQName;
	}
}
