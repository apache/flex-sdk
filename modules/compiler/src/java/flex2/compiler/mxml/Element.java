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

package flex2.compiler.mxml;

import flex2.compiler.mxml.rep.AtResource;
import flex2.compiler.util.LinkedQNameMap;
import flex2.compiler.util.QName;

import java.util.*;
import java.io.StringWriter;

/**
 * This is the common base class for all DOM nodes.  It is not used directly.
 *
 * @author Clement Wong
 */
public abstract class Element extends Token
{
	protected Element(String uri, String localPart, int size)
	{
		this.uri = uri;
		this.localPart = localPart;

		if (size > 0)
		{
			attributes = new LinkedQNameMap<Object>(size);
		}

		prefixMappings = null;
	}

	private String uri;
	private String localPart;

	private LinkedQNameMap<Object> attributes;
	private Map<String, String> prefixMappings;

	private List<Token> children;

	public void addPrefixMapping(String uri, String prefix)
	{
		if (prefixMappings == null)
		{
			prefixMappings = new HashMap<String, String>(8);
		}
		prefixMappings.put(uri, prefix);
	}

	public void addAttribute(String uri, String localPart, Object value, int line)
	{
		if (attributes == null)
		{
			attributes = new LinkedQNameMap<Object>();
		}
		attributes.put(uri, localPart, new Attribute(uri, localPart, value, line));
	}

	public Attribute getAttribute(String localName)
	{
	    return getAttribute("", localName);
	}

	public Attribute getAttribute(String uri, String localName)
	{
	    if (attributes == null)
	    {
	        return null;
	    }
	    else
	    {
	        return (Attribute)attributes.get(uri, localName);
	    }
	}

	public Object getAttributeValue(String localName)
	{
		return getAttributeValue("", localName);
	}

	public Object getAttributeValue(String uri, String localName)
	{
		Attribute v = getAttribute(uri, localName);
		if (v != null)
		{
			return v.getValue();
		}
		else
		{
			return null;
		}
	}

	public Object getAttributeValue(QName qname)
	{
		if (attributes == null)
		{
			return null;
		}
		else
		{
			Attribute v = (Attribute) attributes.get(qname);
			if (v != null)
			{
				return v.getValue();
			}
			else
			{
				return null;
			}
		}
	}

	public int getLineNumber(String localName)
	{
		return getLineNumber("", localName);
	}

	public int getLineNumber(String uri, String localName)
	{
		if (attributes == null)
		{
			return beginLine;
		}
		else
		{
			Attribute v = (Attribute) attributes.get(uri, localName);
			if (v != null)
			{
				return v.getLine();
			}
			else
			{
				return beginLine;
			}
		}
	}

	public int getLineNumber(QName qname)
	{
		if (attributes == null)
		{
			return beginLine;
		}
		else
		{
			Attribute v = (Attribute) attributes.get(qname);
			if (v != null)
			{
				return v.getLine();
			}
			else
			{
				return beginLine;
			}
		}
	}

	public Iterator<QName> getAttributeNames()
	{
		return (attributes == null) ? Collections.<QName>emptySet().iterator() : attributes.keySet().iterator();
	}

	public int getAttributeCount()
	{
		return (attributes == null) ? 0 : attributes.size();
	}

	public String getNamespace()
	{
		return uri;
	}

	public String getLocalPart()
	{
		return localPart;
	}

	public String getPrefix()
	{
		return (prefixMappings == null) ? null : prefixMappings.get(uri);
	}

	public void addChildren(List<Token> children)
	{
		if (this.children == null)
		{
			this.children = children;
		}
		else
		{
			this.children.addAll(children);
		}
	}

	public void addChild(Token child)
	{
		if (child != null)
		{
			if (children == null)
			{
				children = new ArrayList<Token>();
			}
			children.add(child);
		}
	}

    public void copy(Element element)
    {
        element.uri = uri;
        element.localPart = localPart;
        element.attributes = attributes;
        element.children = children;
        element.prefixMappings = prefixMappings;
    }

	public Token getChildAt(int index)
	{
		return (children == null ? null : children.get(index));
	}

	public int getChildCount()
	{
		return (children == null) ? 0 : children.size();
	}

	public List<Token> getChildren()
	{
		return children == null ? Collections.<Token>emptyList() : Collections.<Token>unmodifiableList(children);
	}

	public final Iterator getChildIterator()
	{
		return getChildren().iterator();
	}

	public void replaceNode(int index, List<Token> children)
	{
		this.children.remove(index);
		this.children.addAll(index, children);
	}

    public void removeAttribute(QName qname)
    {
		attributes.remove(qname);
    }

	public String getPrefix(String uri)
	{
		return (prefixMappings == null) ? null : prefixMappings.get(uri);
	}

	public void toStartElement(StringWriter w)
	{
		String p = null;
		w.write('<');
		if ((p = getPrefix(uri)) != null && p.length() > 0)
		{
			w.write(p);
			w.write(':');
		}
		w.write(localPart);

		for (Iterator i = getAttributeNames(); i.hasNext();)
		{
			QName qName = (QName) i.next();
			w.write(' ');
			if ((p = getPrefix(qName.getNamespace())) != null && p.length() > 0)
			{
				w.write(p);
				w.write(':');
			}
			w.write(qName.getLocalPart());
            
            final Object attr = getAttributeValue(qName);
            // handle @Resource specially
            if(attr instanceof AtResource)
            {
                // e4x expression, so braces instead of double-quotes
                w.write("={");
                w.write(((AtResource)attr).getValueExpression());
                w.write("}");
            }
            else
            {
                // string expression
                w.write("=\"");
                w.write(getAttributeValue(qName).toString());
                w.write("\"");
            }
		}

		for (Iterator k = prefixMappings == null ? null : prefixMappings.keySet().iterator(); k != null && k.hasNext();)
		{
			String ns = (String) k.next();
			String px = getPrefix(ns);
			if (px != null)
			{
				w.write(" xmlns");
				if (px.length() > 0)
				{
					w.write(':');
					w.write(px);
				}
				w.write("=\"");
				w.write(ns);
				w.write("\"");
			}
		}

		w.write('>');
	}

	public void toEndElement(StringWriter w)
	{
		String p = null;
		w.write("</");
		if ((p = getPrefix(uri)) != null && p.length() > 0)
		{
			w.write(p);
			w.write(':');
		}
		w.write(localPart);
		w.write('>');
	}
}
