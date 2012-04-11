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

import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.dom.Node;
import flex2.compiler.util.QName;

/**
 * Attribute-specific wrapper around DeclarationHandler.
 */
public abstract class AttributeHandler extends DeclarationHandler
{
	protected Type type;
	protected String text;
	protected int line;

	/**
	 *
	 */
	public void invoke(Node node, Type type, QName qname)
	{
        //  String msg = "AttributeHandler[" + node.image + "/" + node.beginLine + ":" + type.getName() + "].invoke('" + qname + "'): ";
        this.type = type;
        this.text = (String)node.getAttributeValue(qname);
        this.line = node.getLineNumber(qname);

        String namespace = qname.getNamespace();
        String localPart = qname.getLocalPart();

        if (processScopedNames() && TextParser.isScopedName(localPart))
        {
            String[] statefulName = TextParser.analyzeScopedName(localPart);
            localPart = statefulName[0];
        }
        
        if (isSpecial(namespace, localPart))
        {
            //  System.out.println(msg + "special()");
            special(type, namespace, localPart);
        }
        else if (namespace.length() != 0)
        {
            //  System.out.println(msg + "qualifiedAttribute()");
            qualifiedAttribute(node, type, namespace, localPart);
        }
        else
        {
            //  System.out.println(msg + "super.invoke()");
            invoke(type, namespace, localPart);
        }
	}

    /**
     *
     */
    protected boolean processScopedNames()
    {
        return false;
    }
    
	/**
     * From Flex 4, tools may annotate elements with qualified attributes
     * in their other namespaces and should be considered private and
     * thus ignored.
     * 
     * @param namespace The namespace of the attribute.
     * @param localPart The name of the attribute.
     */
	protected abstract void qualifiedAttribute(Node node, Type type, String namespace, String localPart);

	/**
	 *
	 */
	protected abstract boolean isSpecial(String namespace, String localPart);

	/**
	 *
	 */
	protected abstract void special(Type type, String namespace, String localPart);

    /**
     * attribute fails to resolve due to unknown namespace 
     */
    protected abstract void unknownNamespace(String namespace, String localPart);
}
