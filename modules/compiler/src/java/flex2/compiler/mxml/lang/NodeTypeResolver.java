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

import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.reflect.Assignable;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.reflect.TypeTable;
import flex2.compiler.mxml.rep.MxmlDocument;
import flex2.compiler.mxml.dom.*;
import flex2.compiler.util.NameFormatter;

/**
 * Encapsulates knowledge of how value nodes map to backing
 * classes. Used in determining lvalue/rvalue type compatibility.
 */
public class NodeTypeResolver extends ValueNodeHandler
{
	final TypeTable typeTable;
	Type type;

	public NodeTypeResolver(TypeTable typeTable)
	{
		this.typeTable = typeTable;
	}

	public Type resolveType(Node node, MxmlDocument document)
	{
		invoke(null, node, document);
		return type;
	}

    //	ValueNodeHandler impl

	protected void componentNode(Assignable property, Node node, MxmlDocument document)
	{
	    // Resolve component against any classes local to the document
	    if (document != null)
		{
		    String className = document.getLocalClass(node.getNamespace(), node.getLocalPart());
		    if (className != null)
		    {
		        Type localType = typeTable.getType(className);
		        if (localType != null)
		        {
		            type = localType;
		            return;
		        }
		    }
		}

	    type = typeTable.getType(node.getNamespace(), node.getLocalPart());
	}
	
	protected void arrayNode(Assignable property, ArrayNode node)
	{
		type = typeTable.arrayType;
	}

	protected void designLayerNode(Assignable property, DesignLayerNode node, MxmlDocument document)
	{
		componentNode(property, node, document);
	}
	
	protected void primitiveNode(Assignable property, PrimitiveNode node)
	{
		Class<? extends PrimitiveNode> nodeClass = node.getClass();
		type = nodeClass == BooleanNode.class ? typeTable.booleanType :
				nodeClass == NumberNode.class ? typeTable.numberType :
                nodeClass == IntNode.class ? typeTable.intType :
                nodeClass == UIntNode.class ? typeTable.uintType :
                nodeClass == StringNode.class ? typeTable.stringType :
				nodeClass == ClassNode.class ? typeTable.classType :
				nodeClass == FunctionNode.class ? typeTable.functionType :
				null;
		assert type != null : "unknown subclass of PrimitiveNode";
	}

	protected void vectorNode(Assignable property, VectorNode node)
	{
        String typeAttributeValue = (String) node.getAttribute(StandardDefs.PROP_TYPE).getValue();
        Type elementType = typeTable.getType(NameFormatter.toColon(typeAttributeValue));

        if (elementType != null)
        {
            type = typeTable.getVectorType(elementType);
        }
	}

	protected void xmlNode(Assignable property, XMLNode node)
	{
		if ((node).isE4X())
		{
			type = typeTable.xmlType;
		}
		else
		{
			type = typeTable.getType(StandardDefs.CLASS_XMLNODE);
			assert type != null : "MXML core type " + StandardDefs.CLASS_XMLNODE + " not loaded";
		}
	}
    
    protected void xmlListNode(Assignable property, XMLListNode node)
    {
        type = typeTable.xmlListType;
    }

	protected void modelNode(Assignable property, ModelNode node)
	{
		// Note that here we return objectType, even though this often wind up getting
		// typed to ObjectProxy.  This may well be a problem when it comes to array
		// coercion.  TODO confirm/deny that Array is assignable to ObjectProxy
		type = typeTable.objectType;
	}

	protected void inlineComponentNode(Assignable property, InlineComponentNode node)
	{
		type = typeTable.getType(typeTable.getStandardDefs().INTERFACE_IFACTORY);
		assert type != null : "MXML core type " + typeTable.getStandardDefs().INTERFACE_IFACTORY + " not loaded";
	}
	
	protected void reparentNode(Assignable property, ReparentNode node)
    {
	    type = typeTable.objectType;
    }
	
	protected void stateNode(Assignable property, StateNode node)
    {
		type = typeTable.getType(node.getNamespace(), node.getLocalPart());
    }

    protected void cdataNode(Assignable property, CDATANode node)
    {
        type = typeTable.objectType;
    }
	
	protected void unknown(Assignable property, Node node)
	{
		type = null;
	}
}
