/*
 * Written by Jeff Dyer
 * Copyright (c) 1998-2003 Mountain View Compiler Company
 * All rights reserved.
 */

package macromedia.asc.parser;

/**
 * CommentNode
 *
 * @author Chris Nuuja
 */
public class CommentNode extends Node
{
	int type;		// either slashslashcomment_token or blockcomment_token 
	String comment;	// contents of comment string including delimiters 

	public CommentNode(String val, int ctype)
	{
		type = ctype;
		comment = val;
	}

	public String toString()
	{
		return comment;
	}
	
	public int getType(){
		return type;
	}
}
