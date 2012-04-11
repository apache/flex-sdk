/*
 * Written by Jeff Dyer
 * Copyright (c) 1998-2003 Mountain View Compiler Company
 * All rights reserved.
 */

package macromedia.asc.parser;

/**
 * Node
 *
 * @author Jeff Dyer
 */
public class ListErrorNode extends ListNode // ErrorNode
{
	public String value;

	public ListErrorNode(String str)
	{
		super(null, null, 0);
		value = str;

		// C: should make IdentifierNode and ErrorNode interface
		//    no multiple inheritance in Java
		// ErrorNode(str)
	}

	public String toString()
	{
		return "ListError";
	}
}
