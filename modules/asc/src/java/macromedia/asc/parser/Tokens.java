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

/**
 * Defines token classes and their print names.
 * <p/>
 * This header defines values for each token class that occurs in
 * ECMAScript 4. All but numberliteral, stringliteral, regexpliteral,
 * xmlliteral, negminlongliteral, and identifier are singletons and
 * therefore a fully described by their token class. The non-singleton
 * token classes can have an infinite number of instances, each with a
 * unique token id and associated instance data. We use positive
 * identifiers to identify instances of these token classes so that
 * the instance data can be stored in an array, or set of arrays with
 * the token value specifying its index.
 *
 * @author Jeff Dyer
 */
public interface Tokens
{

// when adding a new token, please update both the tokenClassNames and tokenToString
// arrays to keep them in sync.  While no code within asc.jar accesses the tokenToString
// array, it is still used by other code and must be kept up to date.

/*
 * Token class values are negative, and token instances are positive so
 * that their values can point to their instance data in an array.
 */
	public static final int FIRST_TOKEN = -1;
	public static final int EOS_TOKEN = FIRST_TOKEN - 0;
	public static final int MINUS_TOKEN = FIRST_TOKEN - 1;
	public static final int MINUSMINUS_TOKEN = MINUS_TOKEN - 1;
	public static final int NOT_TOKEN = MINUSMINUS_TOKEN - 1;
	public static final int NOTEQUALS_TOKEN = NOT_TOKEN - 1;
	public static final int STRICTNOTEQUALS_TOKEN = NOTEQUALS_TOKEN - 1;
	public static final int MODULUS_TOKEN = STRICTNOTEQUALS_TOKEN - 1;
	public static final int MODULUSASSIGN_TOKEN = MODULUS_TOKEN - 1;
	public static final int BITWISEAND_TOKEN = MODULUSASSIGN_TOKEN - 1;
	public static final int LOGICALAND_TOKEN = BITWISEAND_TOKEN - 1;
	public static final int LOGICALANDASSIGN_TOKEN = LOGICALAND_TOKEN - 1;
	public static final int BITWISEANDASSIGN_TOKEN = LOGICALANDASSIGN_TOKEN - 1;
	public static final int LEFTPAREN_TOKEN = BITWISEANDASSIGN_TOKEN - 1;
	public static final int RIGHTPAREN_TOKEN = LEFTPAREN_TOKEN - 1;
	public static final int MULT_TOKEN = RIGHTPAREN_TOKEN - 1;
	public static final int MULTASSIGN_TOKEN = MULT_TOKEN - 1;
	public static final int COMMA_TOKEN = MULTASSIGN_TOKEN - 1;
	public static final int DOT_TOKEN = COMMA_TOKEN - 1;
	public static final int DOUBLEDOT_TOKEN = DOT_TOKEN - 1;
	public static final int TRIPLEDOT_TOKEN = DOUBLEDOT_TOKEN - 1;
    public static final int DOTLESSTHAN_TOKEN = TRIPLEDOT_TOKEN -1;
    public static final int DIV_TOKEN = DOTLESSTHAN_TOKEN - 1;
	public static final int DIVASSIGN_TOKEN = DIV_TOKEN - 1;
	public static final int COLON_TOKEN = DIVASSIGN_TOKEN - 1;
	public static final int DOUBLECOLON_TOKEN = COLON_TOKEN - 1;
	public static final int SEMICOLON_TOKEN = DOUBLECOLON_TOKEN - 1;
	public static final int QUESTIONMARK_TOKEN = SEMICOLON_TOKEN - 1;
	public static final int ATSIGN_TOKEN = QUESTIONMARK_TOKEN - 1;
	public static final int LEFTBRACKET_TOKEN = ATSIGN_TOKEN - 1;
	public static final int RIGHTBRACKET_TOKEN = LEFTBRACKET_TOKEN - 1;
	public static final int BITWISEXOR_TOKEN = RIGHTBRACKET_TOKEN - 1;
	public static final int LOGICALXOR_TOKEN = BITWISEXOR_TOKEN - 1;
	public static final int LOGICALXORASSIGN_TOKEN = LOGICALXOR_TOKEN - 1;
	public static final int BITWISEXORASSIGN_TOKEN = LOGICALXORASSIGN_TOKEN - 1;
	public static final int LEFTBRACE_TOKEN = BITWISEXORASSIGN_TOKEN - 1;
	public static final int BITWISEOR_TOKEN = LEFTBRACE_TOKEN - 1;
	public static final int LOGICALOR_TOKEN = BITWISEOR_TOKEN - 1;
	public static final int LOGICALORASSIGN_TOKEN = LOGICALOR_TOKEN - 1;
	public static final int BITWISEORASSIGN_TOKEN = LOGICALORASSIGN_TOKEN - 1;
	public static final int RIGHTBRACE_TOKEN = BITWISEORASSIGN_TOKEN - 1;
	public static final int BITWISENOT_TOKEN = RIGHTBRACE_TOKEN - 1;
	public static final int PLUS_TOKEN = BITWISENOT_TOKEN - 1;
	public static final int PLUSPLUS_TOKEN = PLUS_TOKEN - 1;
	public static final int PLUSASSIGN_TOKEN = PLUSPLUS_TOKEN - 1;
	public static final int LESSTHAN_TOKEN = PLUSASSIGN_TOKEN - 1;
	public static final int LEFTSHIFT_TOKEN = LESSTHAN_TOKEN - 1;
	public static final int LEFTSHIFTASSIGN_TOKEN = LEFTSHIFT_TOKEN - 1;
	public static final int LESSTHANOREQUALS_TOKEN = LEFTSHIFTASSIGN_TOKEN - 1;
	public static final int ASSIGN_TOKEN = LESSTHANOREQUALS_TOKEN - 1;
	public static final int MINUSASSIGN_TOKEN = ASSIGN_TOKEN - 1;
	public static final int EQUALS_TOKEN = MINUSASSIGN_TOKEN - 1;
	public static final int STRICTEQUALS_TOKEN = EQUALS_TOKEN - 1;
	public static final int GREATERTHAN_TOKEN = STRICTEQUALS_TOKEN - 1;
	public static final int GREATERTHANOREQUALS_TOKEN = GREATERTHAN_TOKEN - 1;
	public static final int RIGHTSHIFT_TOKEN = GREATERTHANOREQUALS_TOKEN - 1;
	public static final int RIGHTSHIFTASSIGN_TOKEN = RIGHTSHIFT_TOKEN - 1;
	public static final int UNSIGNEDRIGHTSHIFT_TOKEN = RIGHTSHIFTASSIGN_TOKEN - 1;
	public static final int UNSIGNEDRIGHTSHIFTASSIGN_TOKEN = UNSIGNEDRIGHTSHIFT_TOKEN - 1;
	public static final int ABSTRACT_TOKEN = UNSIGNEDRIGHTSHIFTASSIGN_TOKEN - 1;
	public static final int AS_TOKEN = ABSTRACT_TOKEN - 1;
	public static final int BREAK_TOKEN = AS_TOKEN - 1;
	public static final int CASE_TOKEN = BREAK_TOKEN - 1;
	public static final int CATCH_TOKEN = CASE_TOKEN - 1;
	public static final int CLASS_TOKEN = CATCH_TOKEN - 1;
	public static final int CONST_TOKEN = CLASS_TOKEN - 1;
	public static final int CONTINUE_TOKEN = CONST_TOKEN - 1;
	public static final int DEBUGGER_TOKEN = CONTINUE_TOKEN - 1;
	public static final int DEFAULT_TOKEN = DEBUGGER_TOKEN - 1;
	public static final int DELETE_TOKEN = DEFAULT_TOKEN - 1;
	public static final int DO_TOKEN = DELETE_TOKEN - 1;
	public static final int ELSE_TOKEN = DO_TOKEN - 1;
	public static final int ENUM_TOKEN = ELSE_TOKEN - 1;
	public static final int EXTENDS_TOKEN = ENUM_TOKEN - 1;	
	public static final int FALSE_TOKEN = EXTENDS_TOKEN - 1;
	public static final int FINAL_TOKEN = FALSE_TOKEN - 1;
	public static final int FINALLY_TOKEN = FINAL_TOKEN - 1;
	public static final int FOR_TOKEN = FINALLY_TOKEN - 1;
	public static final int FUNCTION_TOKEN = FOR_TOKEN - 1;
	public static final int GET_TOKEN = FUNCTION_TOKEN - 1;
	public static final int GOTO_TOKEN = GET_TOKEN - 1;
	public static final int IF_TOKEN = GOTO_TOKEN - 1;
	public static final int IMPLEMENTS_TOKEN = IF_TOKEN - 1;
	public static final int IMPORT_TOKEN = IMPLEMENTS_TOKEN - 1;
	public static final int IN_TOKEN = IMPORT_TOKEN - 1;
	public static final int INCLUDE_TOKEN = IN_TOKEN - 1;
	public static final int INSTANCEOF_TOKEN = INCLUDE_TOKEN - 1;
	public static final int INTERFACE_TOKEN = INSTANCEOF_TOKEN - 1;
	public static final int IS_TOKEN = INTERFACE_TOKEN - 1;
	public static final int NAMESPACE_TOKEN = IS_TOKEN - 1;
    public static final int CONFIG_TOKEN = NAMESPACE_TOKEN -1;
	public static final int NATIVE_TOKEN = CONFIG_TOKEN - 1;
	public static final int NEW_TOKEN = NATIVE_TOKEN - 1;
	public static final int NULL_TOKEN = NEW_TOKEN - 1;
	public static final int PACKAGE_TOKEN = NULL_TOKEN - 1;
	public static final int PRIVATE_TOKEN = PACKAGE_TOKEN - 1;
	public static final int PROTECTED_TOKEN = PRIVATE_TOKEN - 1;
	public static final int PUBLIC_TOKEN = PROTECTED_TOKEN - 1;
	public static final int RETURN_TOKEN = PUBLIC_TOKEN - 1;
	public static final int SET_TOKEN = RETURN_TOKEN - 1;
	public static final int STATIC_TOKEN = SET_TOKEN - 1;
	public static final int SUPER_TOKEN = STATIC_TOKEN - 1;
	public static final int SWITCH_TOKEN = SUPER_TOKEN - 1;
	public static final int SYNCHRONIZED_TOKEN = SWITCH_TOKEN - 1;
	public static final int THIS_TOKEN = SYNCHRONIZED_TOKEN - 1;
	public static final int THROW_TOKEN = THIS_TOKEN - 1;
	public static final int THROWS_TOKEN = THROW_TOKEN - 1;
	public static final int TRANSIENT_TOKEN = THROWS_TOKEN - 1;
	public static final int TRUE_TOKEN = TRANSIENT_TOKEN - 1;
	public static final int TRY_TOKEN = TRUE_TOKEN - 1;
	public static final int TYPEOF_TOKEN = TRY_TOKEN - 1;
	public static final int USE_TOKEN = TYPEOF_TOKEN - 1;
	public static final int VAR_TOKEN = USE_TOKEN - 1;
	public static final int VOID_TOKEN = VAR_TOKEN - 1;
	public static final int VOLATILE_TOKEN = VOID_TOKEN - 1;
	public static final int WHILE_TOKEN = VOLATILE_TOKEN - 1;
	public static final int WITH_TOKEN = WHILE_TOKEN - 1;
	public static final int IDENTIFIER_TOKEN = WITH_TOKEN - 1;
	public static final int NUMBERLITERAL_TOKEN = IDENTIFIER_TOKEN - 1;
	public static final int REGEXPLITERAL_TOKEN = NUMBERLITERAL_TOKEN - 1;
	public static final int STRINGLITERAL_TOKEN = REGEXPLITERAL_TOKEN - 1;
	public static final int NEGMINLONGLITERAL_TOKEN = STRINGLITERAL_TOKEN - 1;
	public static final int XMLLITERAL_TOKEN = NEGMINLONGLITERAL_TOKEN - 1;
	public static final int XMLPART_TOKEN = XMLLITERAL_TOKEN - 1;
	public static final int XMLMARKUP_TOKEN = XMLPART_TOKEN - 1;
	public static final int XMLTEXT_TOKEN = XMLMARKUP_TOKEN - 1;
	public static final int XMLTAGENDEND_TOKEN = XMLTEXT_TOKEN - 1;
	public static final int XMLTAGSTARTEND_TOKEN = XMLTAGENDEND_TOKEN - 1;
	public static final int ATTRIBUTEIDENTIFIER_TOKEN = XMLTAGSTARTEND_TOKEN - 1;
    public static final int DOCCOMMENT_TOKEN                    = ATTRIBUTEIDENTIFIER_TOKEN - 1;
	public static final int BLOCKCOMMENT_TOKEN					= DOCCOMMENT_TOKEN - 1;
	public static final int SLASHSLASHCOMMENT_TOKEN				= BLOCKCOMMENT_TOKEN - 1;

    public static final int EOL_TOKEN                           = SLASHSLASHCOMMENT_TOKEN - 1;

	public static final int EMPTY_TOKEN = EOL_TOKEN - 1;
	public static final int ERROR_TOKEN = EMPTY_TOKEN - 1;
	public static final int LAST_TOKEN = EMPTY_TOKEN - 1;


	// when adding a new token, please update both the tokenClassNames and tokenToString
	// arrays to keep them in sync.  While no code within asc.jar accesses the tokenToString
	// array, it is still used by other code and must be kept up to date.
	public static final String[] tokenClassNames =
		{
			"<unused index>",
			"end of program",
			"minus",
			"minusminus",
			"not",
			"notequals",
			"strictnotequals",
			"modulus",
			"modulusassign",
			"bitwiseand",
			"logicaland",
			"logicalandassign",
			"bitwiseandassign",
			"leftparen",
			"rightparen",
			"mult",
			"multassign",
			"comma",
			"dot",
			"doubledot",
			"tripledot",
            "dotlessthan",
			"div",
			"divassign",
			"colon",
			"doublecolon",
			"semicolon",
			"questionmark",
			"atsign",
			"leftbracket",
			"rightbracket",
			"bitwisexor",
			"logicalxor",
			"logicalxorassign",
			"bitwisexorassign",
			"leftbrace",
			"bitwiseor",
			"logicalor",
			"logicalorassign",
			"bitwiseorassign",
			"rightbrace",
			"bitwisenot",
			"plus",
			"plusplus",
			"plusassign",
			"lessthan",
			"leftshift",
			"leftshiftassign",
			"lessthanorequals",
			"assign",
			"minusassign",
			"equals",
			"strictequals",
			"greaterthan",
			"greaterthanorequals",
			"rightshift",
			"rightshiftassign",
			"unsignedrightshift",
			"unsignedrightshiftassign",
			"abstract",
			"as",
			"break",
			"case",
			"catch",
			"class",
			"const",
			"continue",
			"debugger",
			"default",
			"delete",
			"do",
			"else",
			"enum",
			"extends",
			"false",
			"final",
			"finally",
			"for",
			"function",
			"get",
			"goto",
			"if",
			"implements",
			"import",
			"in",
			"include",
			"instanceof",
			"interface",
			"is",
			"namespace",
            "config",
			"native",
			"new",
			"null",
			"package",
			"private",
			"protected",
			"public",
			"return",
			"set",
			"static",
			"super",
			"switch",
			"synchronized",
			"this",
			"throw",
			"throws",
			"transient",
			"true",
			"try",
			"typeof",
			"use",
			"var",
			"void",
			"volatile",
			"while",
			"with",
			"identifier",
			"numberliteral",
			"regexpliteral",
			"stringliteral",
			"negminlongliteral",
			"xmlliteral",
			"xmlpart",
			"xmlmarkup",
			"xmltext",
			"xmltagendend",
			"xmltagstartend",
			"attributeidentifier",
            "docComment",
            "blockComment",
            "slashslashcomment",

			"end of line",
			"<empty>",
			"<error>",
            "abbrev_mode",
            "full_mode"
		};
	
	// when adding a new token, please update both the tokenClassNames and tokenToString
	// arrays to keep them in sync.  While no code within asc.jar accesses the tokenToString
	// array, it is still used by other code and must be kept up to date.
	public static final String[] tokenToString =
	{
			"",//"<unused index>"
			"",//"end of program"
			"-",//"minus"
			"--",//"minusminus"
			"!",//"not"
			"!=",//"notequals"
			"!==",//"strictnotequals"
			"%",//"modulus"
			"%=",//"modulusassign"
			"&",//"bitwiseand"
			"&&",//"logicaland"
			"&&=",//"logicalandassign"
			"&=",//"bitwiseandassign"
			"(",//"leftparen"
			")",//"rightparen"
			"*",//"mult"
			"*=",//"multassign"
			",",//"comma"
			".",//"dot"
			"..",//"doubledot"
			"...",//"tripledot"
			".<",//"dotlessthan"
			"/",//"div"
			"/=",//"divassign"
			":",//"colon"
			"::",//"doublecolon"
			";",//"semicolon"
			"?",//"questionmark"
			"@",//"atsign"
			"[",//"leftbracket"
			"]",//"rightbracket"
			"^",//"bitwisexor"
			"^^",//"logicalxor"
			"^^=",//"logicalxorassign"
			"^=",//"bitwisexorassign"
			"{",//"leftbrace"
			"|",//"bitwiseor"
			"||",//"logicalor"
			"||=",//"logicalorassign"
			"|=",//"bitwiseorassign"
			"}",//"rightbrace"
			"~",//"bitwisenot"
			"+",//"plus"
			"++",//"plusplus"
			"+=",//"plusassign"
			"<",//"lessthan"
			"<<",//"leftshift"
			"<<=",//"leftshiftassign"
			"<=",//"lessthanorequals"
			"=",//"assign"
			"-=",//"minusassign"
			"==",//"equals"
			"===",//"strictequals"
			">",//"greaterthan"
			">=",//"greaterthanorequals"
			">>",//"rightshift"
			">>=",//"rightshiftassign"
			">>>",//"unsignedrightshift"
			">>>=",//"unsignedrightshiftassign"
			"abstract",//"abstract"
			" as ",//"as"
			"break",//"break"
			"case",//"case"
			"catch",//"catch"
			"class",//"class"
			"const",//"const"
			"continue",//"continue"
			"debugger",//"debugger"
			"default",//"default"
			"delete",//"delete"
			"do",//"do"
			"else",//"else"
			"enum",//"enum"
			"extends",//"extends"
			"false",//"false"
			"final",//"final"
			"finally",//"finally"
			"for",//"for"
			"function",//"function"
			"get",//"get"
			"goto",//"goto"
			"if",//"if"
			"implements",//"implements"
			"import",//"import"
			"in",//"in"
			"include",//"include"
			"instanceof",//"instanceof"
			"interface",//"interface"
			" is ",//"is"
			"namespace",//"namespace"
			"config",//"config"
			"native",//"native"
			"new",//"new"
			"null",//"null"
			"package",//"package"
			"private",//"private"
			"protected",//"protected"
			"public ",//"public"
			"return",//"return"
			"set",//"set"
			"static",//"static"
			"super",//"super"
			"switch",//"switch"
			"synchronized",//"synchronized"
			"this",//"this"
			"throw",//"throw"
			"throws",//"throws"
			"transient",//"transient"
			"true",//"true"
			"try",//"try"
			"typeof",//"typeof"
			"use namespace ",//"use"
			"var",//"var"
			"void",//"void",
			"volatile",//"volatile",
			"while",//"while",
			"with",//"with",
			"",//"identifier",
			"",//"numberliteral",
			"",//"regexpliteral",
			"",//"stringliteral",
			"",//"negminlongliteral",
			"",//"xmlliteral",
			"{",//"xmlpart",
			"",//"xmlmarkup",
			"",//"xmltext",
			"/>",//"xmltagendend",
			"</",//"xmltagstartend",
			"",//"attributeidentifier",
			"",//"docComment",
            "/*",//"blockComment",
            "//",//"slashslashcomment",

            "",//"end of line",
			"",//"<empty>",
			"",//"<error>",
			"",//"abbrev_mode",
            ""//"full_mode"
		};
		
}
