/*
 * Written by Jeff Dyer
 * Copyright (c) 1998-2003 Mountain View Compiler Company
 * All rights reserved.
 */

package macromedia.asc.parser;

import static macromedia.asc.parser.Tokens.*;

/**
 * Represents token instances: literals and identifiers.
 *
 * This file implements the class Token that is used to carry
 * information from the Scanner to the Parser.
 *
 * @author Jeff Dyer
 */

public final class Token
{
	private int tokenClass;
	private String lexeme;

    public final void set(int tokenClass,String lexeme)
    {
        this.tokenClass = tokenClass;
        this.lexeme = lexeme;
    }
    
    public final void set(int tokenClass)
    {
        this.tokenClass = tokenClass;
        this.lexeme = null;
    }
    
	public Token(int tokenClass, String lexeme)
	{
	    this.tokenClass = tokenClass;
	    this.lexeme = lexeme;
	}

	public final int getTokenClass()
	{
		return tokenClass;
	}

	/*
	 * Return a copy of the token text string. Caller deletes it.
	 */

	public String getTokenText()
	{
		if (tokenClass == STRINGLITERAL_TOKEN)
		{
			return (lexeme.length() <= 1) ? "" : lexeme.substring(1, lexeme.length() - 1);
		}
		return lexeme;
	}

	public String getTokenSource()
	{
		return lexeme;
	}

	public static String getTokenClassName(int token_class)
	{
        // etierney 8/11/06 - don't move this calculation inline in the array access, JRockit doesn't like
        // it and crashes on 64 bit linux.  Doing the calculation and assigning the result to a temporary variable
        // doesn't crash though.  Go figure.  
        int temp = -1 * token_class;
		return tokenClassNames[temp];
	}

	public boolean equals(Object obj)
	{
		return tokenClass == ((Token) obj).tokenClass && lexeme.equals(((Token) obj).lexeme);
	}
}
