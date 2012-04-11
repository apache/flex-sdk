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

package flex2.compiler.util;

import flex2.compiler.SymbolTable;

/**
 * This class represents a namespace URI and local part.
 *
 * @author Clement Wong
 */
public final class QName extends Name
{
	public static final String DEFAULT_NAMESPACE = SymbolTable.publicNamespace;

	QName()
	{
		this(DEFAULT_NAMESPACE, "");
	}

	public QName(String qname)
	{
		int index = qname.indexOf(":");
		if (index == -1)
		{
			namespaceURI = DEFAULT_NAMESPACE;
			localPart = qname;
		}
		else
		{
			namespaceURI = qname.substring(0, index);
			localPart = qname.substring(index + 1);
		}
		fullName = qname;
	}

	public QName(final String namespaceURI, final String localPart)
	{
		assert namespaceURI != null : "Null namespace";
		this.namespaceURI = namespaceURI;
		this.localPart = localPart;
	}

    public QName(final String namespaceURI, final String localPart, final String preferredPrefix)
	{
        this(namespaceURI, localPart);
        this.preferredPrefix = preferredPrefix; 
	}

	public QName(QName qName)
	{
		assert qName.namespaceURI != null : "Null namespace";
		namespaceURI = qName.namespaceURI;
		localPart = qName.localPart;
		fullName = qName.fullName;
		preferredPrefix = qName.preferredPrefix;
	}

	private String namespaceURI;
	private String fullName;
	private String preferredPrefix;

	public String getNamespace()
	{
		return namespaceURI;
	}

	public void setNamespace(String namespaceURI)
	{
		assert namespaceURI != null : "Null namespace";
		this.namespaceURI = namespaceURI;
	}

    public String getPreferredPrefix()
	{
	    return preferredPrefix;
	}

	public boolean equals(String namespaceURI, String localPart)
	{
		assert namespaceURI != null : "Null namespace";

		boolean result = this.namespaceURI.equals(namespaceURI) && this.localPart.equals(localPart);

		return result;
	}

	public boolean equals(Object obj)
	{
		if (obj instanceof QName)
		{
			QName qName = (QName) obj;
			return equals(qName.namespaceURI, qName.localPart);
		}
		/*
		else if (obj instanceof MultiName)
		{
			MultiName mName = (MultiName) obj;
			String[] ns = mName.getNamespace();
			return (ns.length == 1 && ns[0].equals(namespaceURI) && mName.getLocalPart().equals(localPart));
		}
		*/
		else
		{
			return false;
		}
	}

	public int hashCode()
	{
		int result;

		if (namespaceURI.length() != 0)
		{
			result = namespaceURI.hashCode() ^ super.hashCode();
		}
		else
		{
			result = super.hashCode();
		}

		return result;
	}

	public String toString()
	{
		if (namespaceURI.length() == 0)
		{
			return localPart;
		}
		else if (fullName != null)
		{
			return fullName;
		}
		else
		{
			StringBuilder b = new StringBuilder(namespaceURI.length() + localPart.length() + 1);
			b.append(namespaceURI).append(':').append(localPart);
			fullName = b.toString();
			return fullName;
		}
	}
}
