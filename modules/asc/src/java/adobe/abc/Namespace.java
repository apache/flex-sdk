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

package adobe.abc;

import static macromedia.asc.embedding.avmplus.ActionBlockConstants.*;


class Namespace implements Comparable<Namespace>
{
	final int kind;
	final String uri;
	private final String comparableUri;
	
	Namespace(String uri)
	{
		this(CONSTANT_Namespace, uri);
	}
	
	Namespace(int kind, String uri)
	{
		this.kind = kind;
		this.uri = uri;
		this.comparableUri = isPrivate() ? GlobalOptimizer.unique() : uri;
	}
	
	boolean isPublic()
	{
		return (kind == CONSTANT_Namespace || kind == CONSTANT_PackageNamespace) && "".equals(uri);
	}
	
	boolean isInternal()
	{
		return kind == CONSTANT_PackageInternalNs;
	}
	
	boolean isPrivate()
	{
		return kind == CONSTANT_PrivateNamespace;
	}
	
	boolean isPrivateOrInternal()
	{
		return isPrivate() || isInternal();
	}

	boolean isProtected()
	{
		return kind == CONSTANT_ProtectedNamespace ||
			   kind == CONSTANT_StaticProtectedNs;
	}
	
	public String toString()
	{
		return uri.length() > 0 ? uri : "public";
	}
	
	public int hashCode()
	{
		return kind ^ uri.hashCode();
	}
	
	public boolean equals(Object o)
	{
		if (!(o instanceof Namespace))
			return false;
		Namespace other = (Namespace) o;
		return kind == other.kind && comparableUri.equals(other.comparableUri);
	}

	public int compareTo(Namespace other)
	{
		if (other == null) return 1; // nonnull > null
		int i;
		if ((i = kind-other.kind) != 0) return i;
		return comparableUri.compareTo(other.comparableUri);
	}
}
