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

package macromedia.abc;

public final class MultiName
{
	public MultiName(String name, String[] namespaces)
	{
		this.localPart = name;
		this.namespaceURI = namespaces;
	}

	public String localPart;
	public String[] namespaceURI;

	public boolean equals(Object obj)
	{
		if (obj instanceof MultiName)
		{
			MultiName mName = (MultiName) obj;
			String[] nsURI = mName.namespaceURI;

			if (nsURI.length != namespaceURI.length)
			{
				return false;
			}

			boolean match = false;

			if (nsURI.length > 0)
			{
				for (int i = 0, length = namespaceURI.length; i < length; i++)
				{
					if (nsURI[i].equals(namespaceURI[i]))
					{
						match = true;
					}
					else
					{
						match = false;
						break;
					}
				}
			}
			else
			{
				match = true;
			}

			if (match && ((mName.localPart == null && localPart == null) || (mName.localPart != null && mName.localPart.equals(localPart))))
			{
				return true;
			}
		}

		return false;
	}

	public int hashCode()
	{
		if (namespaceURI.length > 0)
		{
			int hash = namespaceURI[0].hashCode();
			for (int i = 1, length = namespaceURI.length; i < length; i++)
			{
				hash ^= namespaceURI[i].hashCode();
			}

			return hash ^ localPart.hashCode();
		}
		else
		{
			return localPart.hashCode();
		}
	}

	public String toString()
	{
		// return "multiname{...}::" + localPart;
		StringBuilder b = new StringBuilder("{");
		for (int i = 0, length = (namespaceURI == null) ? 0 : namespaceURI.length; i < length; i++)
		{
			b.append(namespaceURI[i]);
			if (i < length - 1)
			{
				b.append(",");
			}
		}
		b.append("}::");
		b.append(localPart);
		return b.toString();
	}
}

