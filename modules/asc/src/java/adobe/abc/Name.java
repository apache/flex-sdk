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

import java.util.ArrayList;

public class Name implements Comparable<Name>
{
	public static final Namespace PUBLIC = new Namespace("");
	public static final Namespace PKG_PUBLIC = new Namespace(CONSTANT_PackageNamespace, "");
	public static final Namespace AS3 = new Namespace("http://adobe.com/AS3/2006/builtin");
	
	final int kind;
	final Nsset nsset;
	final String name;
	final String type_param;	// null if none

	Name(int kind)
	{
		this(kind, GlobalOptimizer.uniqueNs(), GlobalOptimizer.unique());
	}

	Name(Namespace ns, String name)
	{
		this(CONSTANT_Qname, ns, name);
	}
	
	public Name(int kind, Namespace ns, String name)
	{
		this(kind, name, new Nsset(new Namespace[] { ns }), null);
	}
	
	Name(int kind, String name, Nsset nsset)
	{
		this(kind, name, nsset, null);
	}
	
	Name(int kind, String name, Nsset nsset, String type_param_name)
	{
		assert(nsset != null);
		this.kind = kind;
		this.nsset = nsset;
		this.name = name;
		this.type_param = type_param_name;
	}
	
	public Name(String name)
	{
		this(CONSTANT_Qname, PUBLIC, name);
	}
	
	public Namespace nsset(int i)
	{
		return nsset.nsset[i];
	}
	
	public String toString()
	{
		return name;
	}
	
	public String format()
	{
		if (nsset.length == 1)
			return nsset(0) + "::" + name;
		else
		{
			ArrayList<Namespace> list = new ArrayList<Namespace>();
			for (Namespace n : nsset)
				list.add(n);
			return list + "::" + name;
		}
	}
	
	public Name append(String s)
	{
		return new Name(kind, name+s, nsset);
	}

	public Name prepend(String s)
	{
		return new Name(kind, s+name, nsset);
	}
	
	private int hc(Object o)
	{
		return o != null ? o.hashCode() : 0;
	}
	
	public int hashCode()
	{
		return kind ^ hc(nsset) ^ hc(name);
	}
	
	/**
	 * exact equality.  Both names must have the same kind, name,
	 * and equal namespace sets.
	 */
	public boolean equals(Object other)
	{
		if (!(other instanceof Name))
			return false;
		Name o = (Name) other;
		return kind == o.kind && name.equals(o.name) && nsset.equals(o.nsset);
	}
	
	public int compareTo(Name other)
	{
		int d = kind - other.kind;
		if (d != 0) return d;
		d = name.compareTo(other.name);
		if (d != 0) return d;
		return nsset.compareTo(other.nsset);
	}
	
	public int attr()
	{
		return kind == CONSTANT_MultinameA || kind == CONSTANT_QnameA ||
			kind == CONSTANT_RTQnameA || kind == CONSTANT_RTQnameLA || kind == CONSTANT_MultinameLA ? 1 : 0;
	}
	
	public boolean isQname()
	{
		return kind == CONSTANT_Qname || kind == CONSTANT_QnameA ||
			kind == CONSTANT_RTQname || kind == CONSTANT_RTQnameA ||
			kind == CONSTANT_RTQnameL || kind == CONSTANT_RTQnameLA;
	}
	
	/**
	 * compare two names.  this implements the multiname->name matching rules.
	 * 
	 * @param other
	 * @return
	 */
	public int match(Name b)
	{
		if (this == b) return 0;
		
		// @names can't ever match regular names
		int d;
		if ((d = this.attr() - b.attr()) != 0) return d;
		if ((d = this.name.compareTo(b.name)) != 0) return d;
		
		if (this.isQname() && b.isQname())
			return this.nsset(0).compareTo(b.nsset(0));
		
		else if (this.isQname() && !b.isQname())
		{
			for (Namespace ns: b.nsset)
				if (ns.equals(this.nsset(0)))
					return 0;
		}
		else if (b.isQname() && !this.isQname())
		{
			for (Namespace ns: this.nsset)
				if (ns.equals(b.nsset(0)))
					return 0;
		}

		return this.nsset.compareTo(b.nsset);
	}
	
}
