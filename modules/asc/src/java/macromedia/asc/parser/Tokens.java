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
	int FIRST_TOKEN = -1;
	int EOS_TOKEN = FIRST_TOKEN - 0;
	int MINUS_TOKEN = FIRST_TOKEN - 1;
	int MINUSMINUS_TOKEN = MINUS_TOKEN - 1;
	int NOT_TOKEN = MINUSMINUS_TOKEN - 1;
	int NOTEQUALS_TOKEN = NOT_TOKEN - 1;
	int STRICTNOTEQUALS_TOKEN = NOTEQUALS_TOKEN - 1;
	int MODULUS_TOKEN = STRICTNOTEQUALS_TOKEN - 1;
	int MODULUSASSIGN_TOKEN = MODULUS_TOKEN - 1;
	int BITWISEAND_TOKEN = MODULUSASSIGN_TOKEN - 1;
	int LOGICALAND_TOKEN = BITWISEAND_TOKEN - 1;
	int LOGICALANDASSIGN_TOKEN = LOGICALAND_TOKEN - 1;
	int BITWISEANDASSIGN_TOKEN = LOGICALANDASSIGN_TOKEN - 1;
	int LEFTPAREN_TOKEN = BITWISEANDASSIGN_TOKEN - 1;
	int RIGHTPAREN_TOKEN = LEFTPAREN_TOKEN - 1;
	int MULT_TOKEN = RIGHTPAREN_TOKEN - 1;
	int MULTASSIGN_TOKEN = MULT_TOKEN - 1;
	int COMMA_TOKEN = MULTASSIGN_TOKEN - 1;
	int DOT_TOKEN = COMMA_TOKEN - 1;
	int DOUBLEDOT_TOKEN = DOT_TOKEN - 1;
	int TRIPLEDOT_TOKEN = DOUBLEDOT_TOKEN - 1;
    int DOTLESSTHAN_TOKEN = TRIPLEDOT_TOKEN -1;
    int DIV_TOKEN = DOTLESSTHAN_TOKEN - 1;
	int DIVASSIGN_TOKEN = DIV_TOKEN - 1;
	int COLON_TOKEN = DIVASSIGN_TOKEN - 1;
	int DOUBLECOLON_TOKEN = COLON_TOKEN - 1;
	int SEMICOLON_TOKEN = DOUBLECOLON_TOKEN - 1;
	int QUESTIONMARK_TOKEN = SEMICOLON_TOKEN - 1;
	int ATSIGN_TOKEN = QUESTIONMARK_TOKEN - 1;
	int LEFTBRACKET_TOKEN = ATSIGN_TOKEN - 1;
	int RIGHTBRACKET_TOKEN = LEFTBRACKET_TOKEN - 1;
	int BITWISEXOR_TOKEN = RIGHTBRACKET_TOKEN - 1;
	int LOGICALXOR_TOKEN = BITWISEXOR_TOKEN - 1;
	int LOGICALXORASSIGN_TOKEN = LOGICALXOR_TOKEN - 1;
	int BITWISEXORASSIGN_TOKEN = LOGICALXORASSIGN_TOKEN - 1;
	int LEFTBRACE_TOKEN = BITWISEXORASSIGN_TOKEN - 1;
	int BITWISEOR_TOKEN = LEFTBRACE_TOKEN - 1;
	int LOGICALOR_TOKEN = BITWISEOR_TOKEN - 1;
	int LOGICALORASSIGN_TOKEN = LOGICALOR_TOKEN - 1;
	int BITWISEORASSIGN_TOKEN = LOGICALORASSIGN_TOKEN - 1;
	int RIGHTBRACE_TOKEN = BITWISEORASSIGN_TOKEN - 1;
	int BITWISENOT_TOKEN = RIGHTBRACE_TOKEN - 1;
	int PLUS_TOKEN = BITWISENOT_TOKEN - 1;
	int PLUSPLUS_TOKEN = PLUS_TOKEN - 1;
	int PLUSASSIGN_TOKEN = PLUSPLUS_TOKEN - 1;
	int LESSTHAN_TOKEN = PLUSASSIGN_TOKEN - 1;
	int LEFTSHIFT_TOKEN = LESSTHAN_TOKEN - 1;
	int LEFTSHIFTASSIGN_TOKEN = LEFTSHIFT_TOKEN - 1;
	int LESSTHANOREQUALS_TOKEN = LEFTSHIFTASSIGN_TOKEN - 1;
	int ASSIGN_TOKEN = LESSTHANOREQUALS_TOKEN - 1;
	int MINUSASSIGN_TOKEN = ASSIGN_TOKEN - 1;
	int EQUALS_TOKEN = MINUSASSIGN_TOKEN - 1;
	int STRICTEQUALS_TOKEN = EQUALS_TOKEN - 1;
	int GREATERTHAN_TOKEN = STRICTEQUALS_TOKEN - 1;
	int GREATERTHANOREQUALS_TOKEN = GREATERTHAN_TOKEN - 1;
	int RIGHTSHIFT_TOKEN = GREATERTHANOREQUALS_TOKEN - 1;
	int RIGHTSHIFTASSIGN_TOKEN = RIGHTSHIFT_TOKEN - 1;
	int UNSIGNEDRIGHTSHIFT_TOKEN = RIGHTSHIFTASSIGN_TOKEN - 1;
	int UNSIGNEDRIGHTSHIFTASSIGN_TOKEN = UNSIGNEDRIGHTSHIFT_TOKEN - 1;
	int ABSTRACT_TOKEN = UNSIGNEDRIGHTSHIFTASSIGN_TOKEN - 1;
	int AS_TOKEN = ABSTRACT_TOKEN - 1;
	int BREAK_TOKEN = AS_TOKEN - 1;
	int CASE_TOKEN = BREAK_TOKEN - 1;
	int CATCH_TOKEN = CASE_TOKEN - 1;
	int CLASS_TOKEN = CATCH_TOKEN - 1;
	int CONST_TOKEN = CLASS_TOKEN - 1;
	int CONTINUE_TOKEN = CONST_TOKEN - 1;
	int DEBUGGER_TOKEN = CONTINUE_TOKEN - 1;
	int DEFAULT_TOKEN = DEBUGGER_TOKEN - 1;
	int DELETE_TOKEN = DEFAULT_TOKEN - 1;
	int DO_TOKEN = DELETE_TOKEN - 1;
	int ELSE_TOKEN = DO_TOKEN - 1;
	int ENUM_TOKEN = ELSE_TOKEN - 1;
	int EXTENDS_TOKEN = ENUM_TOKEN - 1;
	int FALSE_TOKEN = EXTENDS_TOKEN - 1;
	int FINAL_TOKEN = FALSE_TOKEN - 1;
	int FINALLY_TOKEN = FINAL_TOKEN - 1;
	int FOR_TOKEN = FINALLY_TOKEN - 1;
	int FUNCTION_TOKEN = FOR_TOKEN - 1;
	int GET_TOKEN = FUNCTION_TOKEN - 1;
	int GOTO_TOKEN = GET_TOKEN - 1;
	int IF_TOKEN = GOTO_TOKEN - 1;
	int IMPLEMENTS_TOKEN = IF_TOKEN - 1;
	int IMPORT_TOKEN = IMPLEMENTS_TOKEN - 1;
	int IN_TOKEN = IMPORT_TOKEN - 1;
	int INCLUDE_TOKEN = IN_TOKEN - 1;
	int INSTANCEOF_TOKEN = INCLUDE_TOKEN - 1;
	int INTERFACE_TOKEN = INSTANCEOF_TOKEN - 1;
	int IS_TOKEN = INTERFACE_TOKEN - 1;
	int NAMESPACE_TOKEN = IS_TOKEN - 1;
    int CONFIG_TOKEN = NAMESPACE_TOKEN -1;
	int NATIVE_TOKEN = CONFIG_TOKEN - 1;
	int NEW_TOKEN = NATIVE_TOKEN - 1;
	int NULL_TOKEN = NEW_TOKEN - 1;
	int PACKAGE_TOKEN = NULL_TOKEN - 1;
	int PRIVATE_TOKEN = PACKAGE_TOKEN - 1;
	int PROTECTED_TOKEN = PRIVATE_TOKEN - 1;
	int PUBLIC_TOKEN = PROTECTED_TOKEN - 1;
	int RETURN_TOKEN = PUBLIC_TOKEN - 1;
	int SET_TOKEN = RETURN_TOKEN - 1;
	int STATIC_TOKEN = SET_TOKEN - 1;
	int SUPER_TOKEN = STATIC_TOKEN - 1;
	int SWITCH_TOKEN = SUPER_TOKEN - 1;
	int SYNCHRONIZED_TOKEN = SWITCH_TOKEN - 1;
	int THIS_TOKEN = SYNCHRONIZED_TOKEN - 1;
	int THROW_TOKEN = THIS_TOKEN - 1;
	int THROWS_TOKEN = THROW_TOKEN - 1;
	int TRANSIENT_TOKEN = THROWS_TOKEN - 1;
	int TRUE_TOKEN = TRANSIENT_TOKEN - 1;
	int TRY_TOKEN = TRUE_TOKEN - 1;
	int TYPEOF_TOKEN = TRY_TOKEN - 1;
	int USE_TOKEN = TYPEOF_TOKEN - 1;
	int VAR_TOKEN = USE_TOKEN - 1;
	int VOID_TOKEN = VAR_TOKEN - 1;
	int VOLATILE_TOKEN = VOID_TOKEN - 1;
	int WHILE_TOKEN = VOLATILE_TOKEN - 1;
	int WITH_TOKEN = WHILE_TOKEN - 1;
	int IDENTIFIER_TOKEN = WITH_TOKEN - 1;
	int NUMBERLITERAL_TOKEN = IDENTIFIER_TOKEN - 1;
	int REGEXPLITERAL_TOKEN = NUMBERLITERAL_TOKEN - 1;
	int STRINGLITERAL_TOKEN = REGEXPLITERAL_TOKEN - 1;
	int NEGMINLONGLITERAL_TOKEN = STRINGLITERAL_TOKEN - 1;
	int XMLLITERAL_TOKEN = NEGMINLONGLITERAL_TOKEN - 1;
	int XMLPART_TOKEN = XMLLITERAL_TOKEN - 1;
	int XMLMARKUP_TOKEN = XMLPART_TOKEN - 1;
	int XMLTEXT_TOKEN = XMLMARKUP_TOKEN - 1;
	int XMLTAGENDEND_TOKEN = XMLTEXT_TOKEN - 1;
	int XMLTAGSTARTEND_TOKEN = XMLTAGENDEND_TOKEN - 1;
	int ATTRIBUTEIDENTIFIER_TOKEN = XMLTAGSTARTEND_TOKEN - 1;
    int DOCCOMMENT_TOKEN                    = ATTRIBUTEIDENTIFIER_TOKEN - 1;
	int BLOCKCOMMENT_TOKEN					= DOCCOMMENT_TOKEN - 1;
	int SLASHSLASHCOMMENT_TOKEN				= BLOCKCOMMENT_TOKEN - 1;

    int EOL_TOKEN                           = SLASHSLASHCOMMENT_TOKEN - 1;

	int EMPTY_TOKEN = EOL_TOKEN - 1;
	int ERROR_TOKEN = EMPTY_TOKEN - 1;
	int LAST_TOKEN = EMPTY_TOKEN - 1;


	// when adding a new token, please update both the tokenClassNames and tokenToString
	// arrays to keep them in sync.  While no code within asc.jar accesses the tokenToString
	// array, it is still used by other code and must be kept up to date.
	String[] tokenClassNames =
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
	String[] tokenToString =
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
