/*
 * Written by Jeff Dyer
 * Copyright (c) 1998-2003 Mountain View Compiler Company
 * All rights reserved.
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
