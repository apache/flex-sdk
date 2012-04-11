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
public class IdentifierErrorNode extends IdentifierNode // ErrorNode
{
	public String value;

	public IdentifierErrorNode()
	{
		super("", 0);
		value = "Expecting an identifier";

		// C: should make IdentifierNode and ErrorNode interface
		//    no multiple inheritance in Java
		// ErrorNode("Expecting an identifier")
	}

	public boolean isIdentifier()
	{
		return true;
	}

	public String toString()
	{
		return "IdentifierError";
	}
}
