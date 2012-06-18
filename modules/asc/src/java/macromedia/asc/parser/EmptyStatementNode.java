/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package macromedia.asc.parser;

import macromedia.asc.util.*;
import macromedia.asc.semantics.*;

/**
 * Node
 *
 * @author Jeff Dyer
 */
public class EmptyStatementNode extends Node
{	
	private final static EmptyStatementNode singleton = new EmptyStatementNode(1);
	
	private EmptyStatementNode() { super(); }
	private EmptyStatementNode(int position) { super(1); }
	
	public static EmptyStatementNode getInstance()
	{
		return singleton;
	}
	
	public Value evaluate(Context cx, Evaluator evaluator)
	{
		return null;
	}
	
	// don't let anyone get a different position (since it's a singleton)
	public void setPositionNonterminal(Node expr) {}
	public void setPositionNonterminal(Node expr, int pos) {}
	public void setPositionTerminal(int curr_pos) {}
	public void setPositionTerminal(int curr_pos, int pos) {}
	public int pos() { return 0; }
	
	public String toString()
	{
		return "EmptyStatement";
	}
}
