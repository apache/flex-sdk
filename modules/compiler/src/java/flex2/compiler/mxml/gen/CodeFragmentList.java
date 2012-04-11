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

package flex2.compiler.mxml.gen;

import flex2.compiler.mxml.rep.Script;

import java.util.ArrayList;

/**
 * This class acts as a mechanism for associating a line number from
 * the original MXML document with a line of generated code.  This is
 * used during Velocity template merging to map the line number of the
 * generated code with the associated line number in the MXML
 * document.  Later on, this mapping is used when reporting errors and
 * warnings.
 *
 * @author Basil Hosmer
 */
public class CodeFragmentList extends ArrayList<Script>
{
	private static final long serialVersionUID = -3188578729226329388L;

    public CodeFragmentList()
	{
	}

	public CodeFragmentList(String fragment, int line)
	{
		add(fragment, line);
	}

	public final boolean add(String fragment, int line)
	{
		return super.add(new Script(fragment, line));
	}

	// add these new add() methods in order to set exact-size StringBuilder

	public final boolean add(String s1, String s2, int line)
	{
		StringBuilder fragment = new StringBuilder(s1.length() + s2.length());
		fragment.append(s1);
		fragment.append(s2);
		return add(fragment.toString(), line);
	}

	public final boolean add(String s1, String s2, String s3, int line)
	{
		StringBuilder fragment = new StringBuilder(s1.length() + s2.length() + s3.length());
		fragment.append(s1);
		fragment.append(s2);
		fragment.append(s3);
		return add(fragment.toString(), line);
	}

	public final boolean add(String s1, String s2, String s3, String s4, int line)
	{
		StringBuilder fragment = new StringBuilder(s1.length() + s2.length() + s3.length() + s4.length());
		fragment.append(s1);
		fragment.append(s2);
		fragment.append(s3);
		fragment.append(s4);
		return add(fragment.toString(), line);
	}

	public final boolean add(String s1, String s2, String s3, String s4, String s5, int line)
	{
		StringBuilder fragment = new StringBuilder(s1.length() + s2.length() + s3.length() + s4.length() + s5.length());
		fragment.append(s1);
		fragment.append(s2);
		fragment.append(s3);
		fragment.append(s4);
		fragment.append(s5);
		return add(fragment.toString(), line);
	}

	public void add(int index, String fragment, int line)
	{
		super.add(index, new Script(fragment, line));
	}

	/**
	 * prohibit unmapped lines - override super.add(Object)
	 */
	public boolean add(Script obj)
	{
		assert false : "CodeFragmentList.add(...) without line ref";
		return false;
	}

	/**
	 * prohibit unmapped lines - override super.add(index, Object)
	 */
	public void add(int index, Script obj)
	{
		assert false : "CodeFragmentList.add(index, ...) without line ref";
	}
}
