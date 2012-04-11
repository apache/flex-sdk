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

package flex2.compiler.mxml.lang;

import flex2.compiler.mxml.dom.*;
import flex2.compiler.mxml.reflect.Assignable;
import flex2.compiler.mxml.rep.MxmlDocument;

/**
 * The idea of "value node" is that any node which can represent an AS
 * value *anywhere* - property initializers, top-level declarations,
 * whatever - is a value node. There are other node classes that map
 * to AS types but represent more than simple values, i.e. legacy
 * "special" nodes like RemoteObjectNode, etc.
 *
 * This class exists to provide a) a simple way of writing code
 * against all value node types, without repeating a specific and
 * somewhat awkward set of tests on the node's class, and b) an easy
 * way to make sure you've covered all the cases.  Of course in some
 * cases it may be more convenient to simply switch on the node class.
 *
 * For typical use-cases, see callers of isValueNode, and subclasses.
 */
public abstract class ValueNodeHandler
{
	protected abstract void componentNode(Assignable assignable, Node node, MxmlDocument document);
	protected abstract void arrayNode(Assignable assignable, ArrayNode node);
	protected abstract void primitiveNode(Assignable assignable, PrimitiveNode node);
	protected abstract void xmlNode(Assignable assignable, XMLNode node);
    protected abstract void xmlListNode(Assignable assignable, XMLListNode node);
	protected abstract void modelNode(Assignable assignable, ModelNode node);
	protected abstract void reparentNode(Assignable assignable, ReparentNode node);
	protected abstract void stateNode(Assignable assignable, StateNode node);
	protected abstract void inlineComponentNode(Assignable assignable, InlineComponentNode node);
	protected abstract void cdataNode(Assignable assignable, CDATANode node);
	protected abstract void vectorNode(Assignable assignable, VectorNode node);
	protected abstract void unknown(Assignable assignable, Node node);

	public static boolean isValueNode(Node node)
	{
		Class<? extends Node> nodeClass = node.getClass();
		return nodeClass == Node.class ||
				nodeClass == LayeredNode.class ||
				nodeClass == DocumentNode.class ||
				nodeClass == ArrayNode.class ||
				node instanceof PrimitiveNode ||
				nodeClass == XMLNode.class ||
                nodeClass == XMLListNode.class ||
				nodeClass == ModelNode.class ||
				nodeClass == ReparentNode.class ||
				nodeClass == InlineComponentNode.class ||
				nodeClass == VectorNode.class;
	}

	public void invoke(Assignable property, Node node, MxmlDocument document)
	{
		Class<? extends Node> nodeClass = node.getClass();

		if (nodeClass == Node.class ||
            nodeClass == LayeredNode.class ||
            nodeClass == DesignLayerNode.class ||
		    nodeClass == DocumentNode.class)
		{
			componentNode(property, node, document);
		}
		else if (nodeClass == ArrayNode.class)
		{
			arrayNode(property, (ArrayNode)node);
		}
		else if (node instanceof PrimitiveNode)
		{
			primitiveNode(property, (PrimitiveNode)node);
		}
		else if (nodeClass == XMLNode.class)
		{
			xmlNode(property, (XMLNode)node);
		}
        else if (nodeClass == XMLListNode.class)
        {
            xmlListNode(property, (XMLListNode)node);
        }
		else if (nodeClass == ModelNode.class)
		{
			modelNode(property, (ModelNode)node);
		}
		else if (nodeClass == InlineComponentNode.class)
		{
			inlineComponentNode(property, (InlineComponentNode)node);
		}
		else if (nodeClass == ReparentNode.class)
		{
		    reparentNode(property, (ReparentNode)node);
		}
		else if (nodeClass == StateNode.class)
		{
		    stateNode(property, (StateNode)node);
		}
		else if (nodeClass == CDATANode.class)
		{
		    cdataNode(property, (CDATANode)node);
		}
		else if (nodeClass == VectorNode.class)
		{
			vectorNode(property, (VectorNode)node);
		}
		else
		{
			assert !isValueNode(node) : "value node class not handled by invoke()";
			unknown(property, node);
		}
	}
}
