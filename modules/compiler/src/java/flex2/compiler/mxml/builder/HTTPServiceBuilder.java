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

package flex2.compiler.mxml.builder;

import flex2.compiler.CompilationUnit;
import flex2.compiler.mxml.MxmlConfiguration;
import flex2.compiler.mxml.analyzer.HTTPServiceAnalyzer;
import flex2.compiler.mxml.dom.HTTPServiceNode;
import flex2.compiler.mxml.dom.RequestNode;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.reflect.TypeTable;
import flex2.compiler.mxml.rep.Model;
import flex2.compiler.mxml.rep.MxmlDocument;
import flex2.compiler.util.ThreadLocalToolkit;

/**
 * This builder handles building a Model instance from a
 * HTTPServiceNode and it's children.
 */
class HTTPServiceBuilder extends ComponentBuilder
{
	private static final String REQUEST = "request";

	private Type type;

	HTTPServiceBuilder(CompilationUnit unit, TypeTable typeTable, MxmlConfiguration mxmlConfiguration, MxmlDocument document)
	{
		super(unit, typeTable, mxmlConfiguration, document, null, null, null, true, null);
		this.childNodeHandler = new HTTPServiceChildNodeHandler(typeTable);
	}

	public void analyze(HTTPServiceNode node)
	{
		new HTTPServiceAnalyzer(unit, mxmlConfiguration, document).analyze(node);
		if (ThreadLocalToolkit.errorCount() > 0)
		{
			return;
		}

        type = typeTable.getType(node.getNamespace(), node.getLocalPart());

		component = new Model(document, type, node.beginLine);
        registerModel(node, component, true);

		processAttributes(node, type);
		processChildren(node, type);
	}

	/**
	 *
	 */
	protected class HTTPServiceChildNodeHandler extends ComponentChildNodeHandler
	{
		int requestCount = 0;

		public HTTPServiceChildNodeHandler(TypeTable typeTable)
		{
			super(typeTable);
		}

		// <request/> children become RequestNode instances, which come through languageNode()
		// Note: multiple <request/>s result 'not allowed here' error on the second one, which is good enough.	
		protected void languageNode()
		{
			if (child instanceof RequestNode && requestCount == 0)
			{
				requestCount = 1;
				addRequest((RequestNode)child);
			}
			else
			{
				super.languageNode();
			}
		}
	}

	private void addRequest(RequestNode child)
	{
		ServiceRequestBuilder builder = new ServiceRequestBuilder(unit, typeTable, mxmlConfiguration, document, REQUEST);
		child.analyze(builder);
		Model request = builder.graph;
		component.setProperty(REQUEST, request);
		request.setParentIndex(REQUEST);
		request.setParent(component);
	}
}
