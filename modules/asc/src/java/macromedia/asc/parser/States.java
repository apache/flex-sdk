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
public interface States
{
	public static final int start_state = 0;
	public static final int error_state = start_state - 1;

	public static final int dot_state = start_state + 1;
	public static final int slashequal_state = dot_state + 1;
	public static final int slash_state = slashequal_state + 1;
	public static final int A_state = slash_state + 1;
	public static final int zero_state = A_state + 1;
	public static final int decimalinteger_state = zero_state + 1;
	public static final int decimal_state = decimalinteger_state + 1;
	public static final int exponentstart_state = decimal_state + 1;
	public static final int exponent_state = exponentstart_state + 1;
	public static final int hexinteger_state = exponent_state + 1;
	public static final int slashregexp_state = hexinteger_state + 1;
	public static final int regexp_state = slashregexp_state + 1;

	public static final int blockcommentstart_state = regexp_state+1;
	public static final int blockcomment_state = blockcommentstart_state+1;
	public static final int blockcommentstar_state = blockcomment_state+1;
    
	public static final int doccomment_state = blockcommentstar_state+1;
	public static final int doccommentstar_state = doccomment_state+1;
	public static final int doccommenttag_state = doccommentstar_state+1;
	public static final int doccommentvalue_state = doccommenttag_state+1;
	
	public static final int startxml_state = doccommentvalue_state+1;
	public static final int startxmlname_state = startxml_state+1;
	public static final int xmlliteral_state = startxmlname_state+1;
	public static final int endxml_state = xmlliteral_state+1;
	public static final int endxmlname_state = endxml_state+1;
	public static final int xmlcommentorcdatastart_state = endxmlname_state+1;
    public static final int xmlcdata_state = xmlcommentorcdatastart_state+1;
	public static final int xmlcomment_state = xmlcdata_state+1;
	public static final int xmlpi_state = xmlcomment_state+1;
	public static final int xmltext_state = xmlpi_state+1;
}
