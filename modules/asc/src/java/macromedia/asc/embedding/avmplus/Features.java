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

package macromedia.asc.embedding.avmplus;

/**
 * All special features turned off. All of the features
 * described below are non-standard, and so are turned
 * off by default.
 *
 * @author Jeff Dyer
 */
public class Features
{
	static boolean ES4 = System.getProperty("ES4") != null;
	static boolean E4X = System.getProperty("E4X") != null;
	static boolean AS3 = System.getProperty("AS3") != null;
	static boolean ES3 = System.getProperty("ES3") != null;

	/**
	 * This flag tells the compiler to use LookupBaseObject
	 * even when it knows where to find a variable on the
	 * scope chain.
	 */
	public static boolean LOOKUP_LEXICAL_REFERENCES = false;

	/**
	 * Use special syntax evaluators in the node factory
	 * to post process the parse tree for syntax errors.
	 */
	public static boolean SPECIAL_FUNCTION_SYNTAX = false;

	/**
	 * This flag allows the use of compound names, which are
	 * treated as a single name. A compound name must have the
	 * syntax of a member expression (base.name) and be
	 * registered with the instance of Context used to compile
	 * the program that contains them. This feature is used to
     * implement package names.
	 */
	public static boolean TRANSLATE_COMPOUND_NAMES = true;

	/**
	 * This flag allows the embedding to define one keyword
	 * that is used in the if condition to compile out code
	 * in the if block. In this case, the code in the else
	 * block is inserted as if it where a simple block statement.
	 */
	public static boolean COMPILE_TIME_IF = false;
	public static String COMPILE_TIME_IF_KEYWORD = "UNUSED";

	/**
	 * Some runtimes want to access properties differently
	 * than simple references. This flag skips an optimization
	 * that turn references to the global object through this
	 * into direct references, rather than property acesses.
	 */
	public static boolean KEEP_GLOBAL_THIS_EXPLICIT = false;

	/**
	 * This flag allows the embedding to control whether
	 * nested functions are allowed. If turned on, an error
	 * is reported during constant evaluation.
	 */
	public static boolean NO_NESTED_FUNCTIONS = false;

	/**
	 * If turned on, this flag causes a error to be reported
	 * for duplicate function definitions at the global level.
	 */
	public static boolean DUPLICATE_FUNCTION_NAME_ERROR = false;

	/**
	 * Special code used to process identifiers during constant
	 * evaluation.
	 */
	public static boolean IDENTIFIER_EVAL_PROLOG = true;
	public static boolean IDENTIFIER_EVAL_EPILOG = true;

	/**
	 * Pass simple escapes in strings to the backend
	 */
	public static boolean PASS_ESCAPES_TO_BACKEND = false;

	/**
	 * Use the user defined identifier as the internal name of
	 * a function. Otherwise generate a mangled name to avoid
	 * name collisions.
	 */
	public static boolean USE_DEFINED_NAME_AS_INTERNAL_NAME = false;

    /**
     * Don't treat function expressions a regular variable
     * definitions with a function literal initializer.
     */

    public static boolean DONT_SET_FUNCTIONS_EXPRESSIONS = false;


    /**
     * Compute and use the static types of expressions to
     * enforce type correctness at compile-time, Report
     * type errors at compile-time.
     */

    public static boolean USE_STATIC_SEMANTICS = false;

	/**
	 * When this feature is turned on, next-generation ABC code is emitted
	 */
	public static boolean FUTURE_ABC = false;
	
    /**
	 * Define dialect specific language features
	 */

	public static boolean HAS_NONIDENTFIELDNAMES = false;
	public static boolean HAS_QUALIFIEDIDENTIFIERS = false;
	public static boolean HAS_DESCENDOPERATORS = false;
	public static boolean HAS_FILTEROPERATORS = false;
	public static boolean HAS_ATTRIBUTEIDENTIFIERS = false;
	public static boolean HAS_WILDCARDSELECTOR = false;
	public static boolean HAS_XMLLITERALS = false;
	public static boolean HAS_EXPRESSIONQUALIFIEDIDS = false;
	public static boolean HAS_REGULAREXPRESSIONS = false;
	public static boolean HAS_ACCESSSPECIFIERS = false;
	public static boolean HAS_SUPEREXPRESSIONS = false;
	public static boolean HAS_RESTPARAMETERS = false;
	public static boolean HAS_ISOPERATOR = false;
	public static boolean HAS_ASOPERATOR = false;
	public static boolean HAS_STRICTNOTEQUALS = false;
	public static boolean HAS_LOGICALASSIGNMENT = false;
	public static boolean HAS_SUPERSTATEMENTS = false;
	public static boolean HAS_ATTRIBUTES = false;
	public static boolean HAS_SQUAREBRACKETATTRS = false;
	public static boolean HAS_LABELEDSTATEMENTS = false;
	public static boolean HAS_INCLUDEDIRECTIVES = false;
	public static boolean HAS_IMPORTDIRECTIVES = false;
	public static boolean HAS_USEDIRECTIVES = false;
	public static boolean HAS_HASHPRAGMAS = false;
	public static boolean HAS_CONSTVARIABLES = false;
	public static boolean HAS_CONSTPARAMETERS = false;
	public static boolean HAS_CLASSDEFINITIONS = false;
	public static boolean HAS_COMPOUNDCLASSNAMES = false;
	public static boolean HAS_INTERFACEDEFINITIONS = false;
	public static boolean HAS_NAMESPACEDEFINITIONS = false;
	public static boolean HAS_TYPEDIDENTIFIERS = false;
	public static boolean HAS_ACCESSORDEFINITIONS = false;
	public static boolean HAS_PACKAGEDEFINITIONS = false;
	public static boolean HAS_RUNTIMECOMPILES = false;

    /**
     * constants for checking which version of the language we're compiling.  
     */
    public static final int DIALECT_ES3 = 9;
    public static final int DIALECT_AS3 = 10;

    /**
     * constants to decide which version of the VM we're targeting
     */
    public static final int TARGET_AVM1 = 0;  //Flash9 VM
    public static final int TARGET_AVM2 = 1;  //Flash10 VM

    /**
	 * Define which dialect feature set(s) to use
	 * More than one feature set can be selected
	 * at once (e.g. ES3 & E4X), but may lead to
	 * semantic ambiguities (e.g. ES4 & AS3)
	 */

	static
	{
		if (!ES4 && !AS3)
		{
			AS3 = true;
			E4X = true;
		}
		
		if( AS3 )
		{
            ES4 = true;
            E4X = true;
		}

		if (ES3)  // FOR DOCUMENTATION ONLY, DON'T USE
		{
			HAS_NONIDENTFIELDNAMES = false;
			HAS_NONIDENTFIELDNAMES = true;
			// HAS_QUALIFIEDIDENTIFIERS   = true;
			// HAS_DESCENDOPERATORS       = true;
			// HAS_FILTEROPERATORS        = true;
			// HAS_ATTRIBUTEIDENTIFIERS   = true;
			// HAS_WILDCARDSELECTOR       = true;
			// HAS_XMLLITERALS            = true;
			// HAS_EXPRESSIONQUALIFIEDIDS = true;
			HAS_REGULAREXPRESSIONS = false;
			HAS_REGULAREXPRESSIONS = true;
			// HAS_ACCESSSPECIFIERS       = true;
			// HAS_SUPEREXPRESSIONS       = true;
			// HAS_RESTPARAMETERS         = true;
			// HAS_ISOPERATOR             = true;
			// HAS_ASOPERATOR             = true;
			// HAS_STRICTNOTEQUALS        = true;
			// HAS_LOGICALASSIGNMENT      = true;
			// HAS_SUPERSTATEMENTS        = true;
			// HAS_ATTRIBUTES             = true;
			// HAS_SQUAREBRACKETATTRS     = true;
			HAS_LABELEDSTATEMENTS = false;
			HAS_LABELEDSTATEMENTS = true;
			// HAS_INCLUDEDIRECTIVES      = true;
			// HAS_IMPORTDIRECTIVES       = true;
			// HAS_USEDIRECTIVES          = true;
			// HAS_HASHPRAGMAS            = true;
			// HAS_CONSTVARIABLES         = true;
			// HAS_CONSTPARAMETERS        = true;
			// HAS_CLASSDEFINITIONS       = true;
			// HAS_COMPOUNDCLASSNAMES     = true;
			// HAS_INTERFACEDEFINITIONS   = true;
			// HAS_NAMESPACEDEFINITIONS   = true;
			// HAS_TYPEDIDENTIFIERS       = true;
			// HAS_ACCESSORDEFINITIONS    = true;
			// HAS_PACKAGEDEFINITIONS     = true;
			HAS_RUNTIMECOMPILES = false;
			HAS_RUNTIMECOMPILES = true;
		}

		if (ES4)
		{
			HAS_NONIDENTFIELDNAMES = false;
			HAS_NONIDENTFIELDNAMES = true;
			HAS_QUALIFIEDIDENTIFIERS = false;
			HAS_QUALIFIEDIDENTIFIERS = true;
			// HAS_DESCENDOPERATORS       = true;
			// HAS_FILTEROPERATORS        = true;
			// HAS_ATTRIBUTEIDENTIFIERS   = true;
			// HAS_WILDCARDSELECTOR       = true;
			// HAS_XMLLITERALS            = true;
			HAS_EXPRESSIONQUALIFIEDIDS = false;
			HAS_EXPRESSIONQUALIFIEDIDS = true;
			HAS_REGULAREXPRESSIONS = false;
			HAS_REGULAREXPRESSIONS = true;
			HAS_ACCESSSPECIFIERS = false;
			HAS_ACCESSSPECIFIERS = true;
			HAS_SUPEREXPRESSIONS = false;
			HAS_SUPEREXPRESSIONS = true;
			HAS_RESTPARAMETERS = false;
			HAS_RESTPARAMETERS = true;
			HAS_ISOPERATOR = false;
			HAS_ISOPERATOR = true;
			HAS_ASOPERATOR = false;
			HAS_ASOPERATOR = true;
			HAS_STRICTNOTEQUALS = false;
			HAS_STRICTNOTEQUALS = true;
			HAS_LOGICALASSIGNMENT = false;
			HAS_LOGICALASSIGNMENT = true;
			HAS_SUPERSTATEMENTS = false;
			HAS_SUPERSTATEMENTS = true;
			HAS_ATTRIBUTES = false;
			HAS_ATTRIBUTES = true;
			// HAS_SQUAREBRACKETATTRS     = true;
			HAS_LABELEDSTATEMENTS = false;
			HAS_LABELEDSTATEMENTS = true;
			HAS_INCLUDEDIRECTIVES = false;
			HAS_INCLUDEDIRECTIVES = true;
			HAS_IMPORTDIRECTIVES = false;
			HAS_IMPORTDIRECTIVES = true;
			HAS_USEDIRECTIVES = false;
			HAS_USEDIRECTIVES = true;
			//HAS_HASHPRAGMAS            = true;
			HAS_CONSTVARIABLES = false;
			HAS_CONSTVARIABLES = true;
			HAS_CONSTPARAMETERS = false;
			// HAS_CONSTPARAMETERS = true;
			HAS_CLASSDEFINITIONS = false;
			HAS_CLASSDEFINITIONS = true;
			// HAS_COMPOUNDCLASSNAMES     = true;
			// HAS_INTERFACEDEFINITIONS   = true;
			HAS_NAMESPACEDEFINITIONS = false;
			HAS_NAMESPACEDEFINITIONS = true;
			HAS_TYPEDIDENTIFIERS = false;
			HAS_TYPEDIDENTIFIERS = true;
			HAS_ACCESSORDEFINITIONS = false;
			HAS_ACCESSORDEFINITIONS = true;
			HAS_PACKAGEDEFINITIONS = false;
			HAS_PACKAGEDEFINITIONS = true;
			HAS_RUNTIMECOMPILES = false;
			HAS_RUNTIMECOMPILES = true;

            //HAS_NULLABILITY = true;
		}

		if (AS3)
		{
			HAS_NONIDENTFIELDNAMES = false;
			HAS_NONIDENTFIELDNAMES = true;
			HAS_QUALIFIEDIDENTIFIERS = false;
			HAS_QUALIFIEDIDENTIFIERS = true;
			// HAS_DESCENDOPERATORS       = true;
			// HAS_FILTEROPERATORS        = true;
			// HAS_ATTRIBUTEIDENTIFIERS   = true;
			HAS_WILDCARDSELECTOR = false;
			HAS_WILDCARDSELECTOR = true;
			// HAS_XMLLITERALS            = true;
			// HAS_EXPRESSIONQUALIFIEDIDS = true;
			HAS_REGULAREXPRESSIONS = false;
			HAS_REGULAREXPRESSIONS = true;  // For better error handling
			HAS_ACCESSSPECIFIERS = false;
			HAS_ACCESSSPECIFIERS = true;
			HAS_SUPEREXPRESSIONS = false;
			HAS_SUPEREXPRESSIONS = true;
			// HAS_RESTPARAMETERS         = true;
			HAS_ISOPERATOR             = true;
			HAS_ASOPERATOR             = true;
			HAS_STRICTNOTEQUALS = false;
			HAS_STRICTNOTEQUALS = true;
			// HAS_LOGICALASSIGNMENT      = true;
			// HAS_SUPERSTATEMENTS        = true;
			HAS_ATTRIBUTES = false;
			HAS_ATTRIBUTES = true;
			HAS_SQUAREBRACKETATTRS = false;
			HAS_SQUAREBRACKETATTRS = true;
			HAS_LABELEDSTATEMENTS = false;
			HAS_LABELEDSTATEMENTS = true;
			HAS_INCLUDEDIRECTIVES = false;
			HAS_INCLUDEDIRECTIVES = true;
			HAS_IMPORTDIRECTIVES = false;
			HAS_IMPORTDIRECTIVES = true;
			// HAS_USEDIRECTIVES          = true;
			HAS_HASHPRAGMAS = false;
			//HAS_HASHPRAGMAS            = true;
			// HAS_CONSTVARIABLES         = true;
			// HAS_CONSTPARAMETERS        = true;
			HAS_CLASSDEFINITIONS = false;
			HAS_CLASSDEFINITIONS = true;
			HAS_COMPOUNDCLASSNAMES = false;
			HAS_COMPOUNDCLASSNAMES = true;
			HAS_INTERFACEDEFINITIONS = false;
			HAS_INTERFACEDEFINITIONS = true;
			// HAS_NAMESPACEDEFINITIONS   = true;
			HAS_TYPEDIDENTIFIERS = false;
			HAS_TYPEDIDENTIFIERS = true;
			HAS_ACCESSORDEFINITIONS = false;
			HAS_ACCESSORDEFINITIONS = true;
			HAS_PACKAGEDEFINITIONS = false;
			HAS_PACKAGEDEFINITIONS = true;
			// HAS_RUNTIMECOMPILES        = true;

            //HAS_NULLABILITY = true;
		}

		if (E4X)
		{
			// HAS_NONIDENTFIELDNAMES    = true;
			HAS_QUALIFIEDIDENTIFIERS = false;
			HAS_QUALIFIEDIDENTIFIERS = true;
			HAS_DESCENDOPERATORS = false;
			HAS_DESCENDOPERATORS = true;
			HAS_FILTEROPERATORS = false;
			HAS_FILTEROPERATORS = true;
			HAS_ATTRIBUTEIDENTIFIERS = false;
			HAS_ATTRIBUTEIDENTIFIERS = true;
			HAS_WILDCARDSELECTOR = false;
			HAS_WILDCARDSELECTOR = true;
			HAS_XMLLITERALS = false;
			HAS_XMLLITERALS = true;
			// HAS_EXPRESSIONQUALIFIEDIDS = true;
			// HAS_REGULAREXPRESSIONS     = true;
			// HAS_ACCESSSPECIFIERS       = true;
			// HAS_SUPEREXPRESSIONS       = true;
			// HAS_RESTPARAMETERS         = true;
			// HAS_ISOPERATOR             = true;
			// HAS_ASOPERATOR             = true;
			// HAS_LOGICALASSIGNMENT      = true;
			// HAS_SUPERSTATEMENTS        = true;
			// HAS_ATTRIBUTES             = true;
			// HAS_LABELEDSTATEMENTS      = true;
			// HAS_INCLUDEDIRECTIVES      = true;
			// HAS_IMPORTDIRECTIVES       = true;
			HAS_USEDIRECTIVES = false;
			HAS_USEDIRECTIVES = true;
			// HAS_HASHPRAGMAS            = true;
			// HAS_CONSTVARIABLES         = true;
			// HAS_CONSTPARAMETERS        = true;
			// HAS_CLASSDEFINITIONS       = true;
			// HAS_COMPOUNDCLASSNAMES     = true;
			// HAS_INTERFACEDEFINITIONS   = true;
			HAS_NAMESPACEDEFINITIONS = false;
			HAS_NAMESPACEDEFINITIONS = true;
			// HAS_TYPEDIDENTIFIERS       = true;
			// HAS_ACCESSORDEFINITIONS    = true;
			// HAS_PACKAGEDEFINITIONS     = true;
			// HAS_RUNTIMECOMPILES        = true;
		}
	}
}
