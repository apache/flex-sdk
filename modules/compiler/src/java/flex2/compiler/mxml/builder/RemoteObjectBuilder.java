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
import flex2.compiler.mxml.analyzer.RemoteObjectAnalyzer;
import flex2.compiler.mxml.dom.ArgumentsNode;
import flex2.compiler.mxml.dom.MethodNode;
import flex2.compiler.mxml.dom.RemoteObjectNode;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.reflect.TypeTable;
import flex2.compiler.mxml.rep.Array;
import flex2.compiler.mxml.rep.Model;
import flex2.compiler.mxml.rep.MxmlDocument;
import flex2.compiler.util.ThreadLocalToolkit;

import java.util.Iterator;

/**
 * This builder handles building a Model instance from a
 * RemoteObjectNode and it's children.
 */
class RemoteObjectBuilder extends ComponentBuilder
{
	private static final String OPERATIONS = "operations";
	private static final String NAME = "name";
	private static final String ARGUMENTS = "arguments";
	private static final String ARGUMENT_NAMES = "argumentNames";

	private Model ops;

	RemoteObjectBuilder(CompilationUnit unit, TypeTable typeTable, MxmlConfiguration mxmlConfiguration, MxmlDocument document)
	{
		super(unit, typeTable, mxmlConfiguration, document, null, null, null, true, null);
		this.childNodeHandler = new RemoteObjectChildNodeHandler(typeTable);
	}

    public void analyze(RemoteObjectNode node)
    {
		new RemoteObjectAnalyzer(unit, mxmlConfiguration, document).analyze(node);
		if (ThreadLocalToolkit.errorCount() > 0)
		{
			return;
		}

        Type type = typeTable.getType(node.getNamespace(), node.getLocalPart());

		component = new Model(document, type, node.beginLine);
        registerModel(node, component, true);

		processAttributes(node, type);

        //	create <Object/> VO for RemoteObject.operations
        ops = new Model(document, typeTable.objectType, component, component.getXmlLineNumber());
        ops.setParentIndex(OPERATIONS);
        component.setProperty(OPERATIONS, ops);

		processChildren(node, type);
	}

	/**
	 *
	 */
	protected class RemoteObjectChildNodeHandler extends ComponentChildNodeHandler
	{
		public RemoteObjectChildNodeHandler(TypeTable typeTable)
		{
			super(typeTable);
		}

		//	<method/> children become MethodNode instances, which come through languageNode()
		protected void languageNode()
		{
			if (child instanceof MethodNode)
			{
				addOperation(ops, (MethodNode)child);
			}
			else
			{
				super.languageNode();
			}
		}
	}

	/**
	 * create Operation VO as child of <PRE><operations/></PRE> parent arg
	 */
	public void addOperation(Model ops, MethodNode node)
    {
		Type type = typeTable.getType(node.getNamespace(), standardDefs.getConvertedTagName(node));

		//	push parent tag VO, child tag handler
		Model ro = component;
		ComponentChildNodeHandler roChildNodeHandler = childNodeHandler;

		//	install our own
		component = new Model(document, type, ops, node.beginLine);
		childNodeHandler = new MethodChildNodeHandler(typeTable);

		//	process child tag: first, add new VO as a property on the parent RemoteObject
		String name = (String)node.getAttributeValue(NAME);
		ops.setProperty(name, component);
        component.setParentIndex(name);

		//	process attributes. note that this will use parent's attribute handler, but route to our VO in 'component'
		processAttributes(node, type);

		//	this will use our child tag handler and our VO
		processChildren(node, type);

		//	restore RemoteObject's VO and child tag handler
		childNodeHandler = roChildNodeHandler;
		component = ro;
	}

	/**
	 *
	 */
	protected class MethodChildNodeHandler extends ComponentChildNodeHandler
	{
		int argumentsCount = 0;

		public MethodChildNodeHandler(TypeTable typeTable)
		{
			super(typeTable);
		}

		//	<arguments/> child will be a special ArgumentsNode, which comes through languageNode()
		protected void languageNode()
		{
			if (child instanceof ArgumentsNode && argumentsCount == 0)
			{
				argumentsCount = 1;
				addArguments(component, (ArgumentsNode)child);
			}
			else
			{
				super.languageNode();
			}
		}
	}

	/**
	 *
	 */
	public void addArguments(Model op, ArgumentsNode node)
    {
        ServiceRequestBuilder builder = new ServiceRequestBuilder(unit, typeTable, mxmlConfiguration, document, ARGUMENTS);
        node.analyze(builder);

		Model arguments = builder.graph;
        op.setProperty(ARGUMENTS, arguments);
        arguments.setParentIndex(ARGUMENTS);
        arguments.setParent(op);

        Array argNames = new Array(document, op, node.beginLine, typeTable.objectType);
        op.setProperty(ARGUMENT_NAMES, argNames);
        argNames.setParentIndex(ARGUMENT_NAMES);

        for (Iterator propNames = arguments.getProperties().keySet().iterator(); propNames.hasNext();)
        {
            String s = (String)propNames.next();
            argNames.addEntry(s, op.getXmlLineNumber());
        }
    }
}

