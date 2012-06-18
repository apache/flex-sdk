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

package macromedia.asc.util;

import static macromedia.asc.parser.Tokens.*;
import static macromedia.asc.util.BitSet.*;
import macromedia.asc.parser.ClassDefinitionNode;
import macromedia.asc.parser.InputBuffer;
import macromedia.asc.parser.Node;
import macromedia.asc.parser.NodeFactory;
import macromedia.asc.parser.Parser;
import macromedia.asc.parser.ConditionalExpressionNode;
import macromedia.asc.parser.ListNode;
import macromedia.asc.parser.BinaryExpressionNode;

import macromedia.asc.semantics.*;
import macromedia.asc.embedding.CompilerHandler;
import macromedia.asc.embedding.ConfigVar;

import macromedia.asc.embedding.avmplus.ClassBuilder;
import macromedia.asc.embedding.ErrorConstants;

import macromedia.asc.embedding.avmplus.GlobalBuilder;
import macromedia.asc.embedding.avmplus.InstanceBuilder;
import macromedia.asc.embedding.avmplus.ByteCodeFactory;

import java.io.PrintWriter;
import java.io.Writer;
import java.io.File;
import java.util.*;

import static macromedia.asc.embedding.avmplus.RuntimeConstants.*;

/**
 * Execution context.
 *
 * @author Jeff Dyer
 */
public final class Context implements ErrorConstants
{
	
    private String parser_scanner_input_origin;
    private String qualified_origin;
    public Parser parser;
    public PrintWriter err;
    public InputBuffer input;

    public ContextStatics statics;
    public CompilerHandler handler;

    public ObjectList<ConfigVar> config_vars = new ObjectList<ConfigVar>();
    
    //Constants for internal & private namespace names
    public static final byte NS_PUBLIC = 0x00;
    public static final byte NS_INTERNAL = 0x01;
    public static final byte NS_PRIVATE = 0x02;
    public static final byte NS_PROTECTED = 0x03;
    public static final byte NS_EXPLICIT = 0x04;
    public static final byte NS_STATIC_PROTECTED = 0x05;

    public static final String NS_INTERNAL_SUFFIX  = "$internal";
    public static final String NS_PRIVATE_SUFFIX   = "$private";
    public static final String NS_PROTECTED_SUFFIX = "$protected";
    public static final String NS_STATIC_PROTECTED_SUFFIX = "$staticprotected";
    
    
    public Decimal128Context decimal_ctx;
    public int decimalParams;

    private static int contextIds=0;
    private int contextId;

    private TreeMap<UnresolvedNamespace, ObjectList<ObjectValue>> unresolved_namespaces;
	public ObjectList<Node>    comments = new ObjectList<Node>();
	public boolean scriptAssistParsing = false;	// allows use of the Asc parser by flex-debugger
	public boolean spaceOperators = false;
	
    public Context(ContextStatics statics)
    {
        this.statics = statics;
        this.handler = null;
        this.qualified_origin = "";
        err = null;
        contextId = contextIds++;
        if (statics != null)
        {
            if (statics.nodeFactory == null)
            {
                statics.nodeFactory = new NodeFactory(this);
            }
            if (statics.builtins == null)
            {
                statics.builtins = new HashMap<String, TypeValue>();
                statics.userDefined = new HashMap<String, TypeValue>();
                statics.namespaces   = new HashMap<String,ObjectValue>();
                statics.internal_namespaces = new HashMap<String,ObjectValue>();
                statics.protected_namespaces = new HashMap<String,ObjectValue>();
                statics.static_protected_namespaces = new HashMap<String,ObjectValue>();
                statics.private_namespaces = new HashMap<String,ObjectValue>();

                statics.validImports = new HashSet<String>();
            }
        }
    }

    private Context(Context origCtx)
    {
        this.statics = origCtx.statics;
        this.handler = origCtx.handler;
        this.err = origCtx.err;
        this.contextId = origCtx.contextId;
        this.def_types = origCtx.def_types;
        this.input = origCtx.input;
        this.parser = origCtx.parser;
        this.parser_scanner_input_origin = origCtx.parser_scanner_input_origin;
        this.qualified_origin = origCtx.qualified_origin;
        this.decimal_ctx = origCtx.decimal_ctx;
        this.decimalParams = origCtx.decimalParams;
    }

    // A context holds the parser_scanner_input_origin of the input file where the current code comes from.
    //   When an IncludeDirectiveNode is handled by an evaluator, the contents of the current context are
    //   swapped with those of an included file's context via switchToContext().
    //   This allows error reporting to use the correct file source context for errors in code from that included file.
    //   Some potential errors, such as unresolvedNamespaces, are collected togeather and processed
    //   later on, however, long after the include'd file they might have come from has been switchToContext()'d out again.
    //   This method allows us to preserve the context in effect at the time an unresolved namespace is queued for later
    //   processing so that if we can report unresolved namespace errors in the correct file context.
    public Context makeCopyOf()
    {
        return new Context(this);
    }

    public int getId()
    {
        return contextId;
    }

   // the current context becomes a new context (shallow copy)
    public void switchToContext(Context cx) {
        this.parser_scanner_input_origin = cx.parser_scanner_input_origin;
	this.qualified_origin = cx.qualified_origin;
        this.parser = cx.parser;
        this.err = cx.err;
        this.input = cx.input;
        this.statics = cx.statics;
        this.handler = cx.handler;
        //this.unresolved_namespaces = cx.unresolved_namespaces;
        // cn: don't loose new unresolved namespaces added while evaluating an include file's contents
        if (cx.unresolved_namespaces != null)
        {
            if (this.unresolved_namespaces == null)
            {
                this.unresolved_namespaces = cx.unresolved_namespaces;
            }
            else
            {
                List<UnresolvedNamespace> nsList = new ArrayList<UnresolvedNamespace>(cx.unresolved_namespaces.keySet());
                for (int i = 0, size = nsList.size(); i < size; i++)
                {
                    UnresolvedNamespace ns = nsList.get(i);
                    ObjectList<ObjectValue> scopes = cx.unresolved_namespaces.get(ns);
                    if (this.unresolved_namespaces.get(ns) == null)
                        this.unresolved_namespaces.put(ns,scopes);
                }
            }
        }

        this.def_types = cx.def_types;
    }

    public void setCompoundNames(ObjectList<String> compound_names)
    {
        statics.nodeFactory.init(compound_names);
    }

    public String getUniqueNamespaceName( String base, Context cx )
    {
        String name = base + "$" + cx.statics.ticket_count++;
        return name.intern();
    }

    public String getFileInternalNamespaceName()
    {
        String base = this.getErrorOrigin();
        int idx = base.lastIndexOf(File.separatorChar);
        if( idx != -1 )
            base = base.substring( idx+1 );
        return getUniqueNamespaceName(base, this);
    }

    public String errorString(int error)
    {
        if (statics.errorCodeMap.get(error) == null)
        {
            AscError[] errorConsts = allErrorConstants[statics.languageID];
            for(int x = 0; x < kNumErrorConstants; x++)
            {
                statics.errorCodeMap.put(errorConsts[x].code,errorConsts[x].errorMsg);
            }
        }

        return statics.errorCodeMap.get(error);
    }

    // This method implements sprintf-like functionality for %s string argument insertions.  Using sprintf would
    //  be easier, but java doesn't have an equivalent.  c++ matches java implementation to make it easier to keep both in sync.
    public static int replaceStringArg(StringBuilder out, String templateStr, int startLoc, String arg)
    {
        if (startLoc == -1) // there are no more %'s to replace in templateStr
            return -1;

        int nextLoc = -1;
        int templateLen = templateStr.length();
        int substLoc = templateStr.indexOf('%',startLoc);

        if (substLoc != -1)
        {
            if (substLoc > startLoc)
                out.append(templateStr.substring(startLoc, substLoc));
            out.append(arg);
            nextLoc = substLoc+2;
        }
        else
        {
            out.append(templateStr.substring(startLoc, templateLen));
        }

        return nextLoc;
    }

//    this is what gets printed to the shell if an error occurs
    public String shellErrorString(int errCode)
    {
        return (ContextStatics.useVerboseErrors ? "[Compiler] Error #" + errCode + ": " : "") + errorString(errCode);
    }

    public void error(int pos, int error)                           { error(pos, error, "", "", "");     }
    public void error(int pos, int error, String arg1)              { error(pos, error, arg1, "", "");   }
    public void error(int pos, int error, String arg1, String arg2) { error(pos, error, arg1, arg2, ""); }
    public void error(int pos, int error, String arg1, String arg2, String arg3)
    {
        StringBuilder out = new StringBuilder();

        // Just the arguments for sanities, no message (since they change often)
        if(ContextStatics.useSanityStyleErrors)
        {
            out.append("code=" + error + "; arg1=" + arg1 + "; arg2=" + arg2 + "; arg3=" + arg3);
        }
        else
        {
            String templateStr = shellErrorString(error);
            int nextLoc = replaceStringArg(out,templateStr,0,arg1);
            nextLoc = replaceStringArg(out,templateStr,nextLoc,arg2);
            nextLoc = replaceStringArg(out,templateStr,nextLoc,arg3);
            if (nextLoc != -1)  // get trailing remainder, if any
                out.append( templateStr.substring(nextLoc,templateStr.length()) );
        }

        localizedError(getErrorOrigin(), pos, out.toString(), error);
    }

    /**
     * This method assumes that the error message is already localized. The AS3 compiler core should use error codes.
     *
     * This method is mainly for toolchains to report error messages via the same error reporting mechanism.
     *
     * @param pos character offset
     * @param msg error message
     */
    public void localizedError(int pos, String msg)
    {
        localizedError(pos, msg, -1);   // -1 means logged from elsewhere
    }

    public void localizedError(int pos, String msg, int code)
    {
        if( pos < 0 )
        {
            pos = 0;   // ISSUE: remove this hack
        }

        int ln = getInputLine(pos);
        int col = getInputCol(pos);

        localizedError(getErrorOrigin(), ln, col, msg, getErrorLineText(pos), code);
    }

    public void localizedWarning(int pos, String msg)
    {
        localizedWarning(pos, msg, -1);
    }

    public void localizedWarning(int pos, String msg, int code)
    {
        if( pos < 0 )
        {
            pos = 0;   // ISSUE: remove this hack
        }

        int ln = getInputLine(pos);
        int col = getInputCol(pos);

        localizedWarning(getErrorOrigin(), ln, col, msg, getErrorLineText(pos), code);
    }

    public void localizedError(String filename, int pos, String msg)
    {
        localizedError(filename,pos,msg,-1);
    }

    public void localizedError(String filename, int pos, String msg, int code)
    {
        if( pos < 0 )
        {
            pos = 0;   // ISSUE: remove this hack
        }

        int ln = getInputLine(pos);
        int col = getInputCol(pos);

        localizedError(filename,ln,col,msg,getErrorLineText(pos), code);
    }

    public void localizedWarning(String filename, int pos, String msg, int code)
    {
        if( pos < 0 )
        {
            pos = 0;   // ISSUE: remove this hack
        }

        int ln = getInputLine(pos);
        int col = getInputCol(pos);

        localizedWarning(filename,ln,col,msg,getErrorLineText(pos), code);
    }


	/**
	 * C: The localizedError2() and localizedWarning2() allow toolchains to implement message-object-based
	 *    system for i18n/l10n. Some toolchains may want to use error-code-based system. In that case,
	 *    they should continue to use localizedError() and localizedWarning().
	 */

	public void localizedError2(int pos, Object msg)
	{
		localizedError2(getErrorOrigin(), pos, msg);
	}

	public void localizedError2(String filename, int pos, Object msg)
	{
		if( pos < 0 )
		{
		    pos = 0;   // ISSUE: remove this hack
		}

		int ln = getInputLine(pos);
		int col = getInputCol(pos);

	    localizedError2(filename,ln,col,msg,getErrorLineText(pos));
	}

	public void localizedError2(String filename, int ln, int col, Object msg, String source)
	{
	    if( handler != null)
	    {
	        handler.error2(filename,ln,col,msg,source);
	    }
	    else if( statics.handler != null )
	    {
	        // Flex enters through here for regular compiler errors
	        statics.handler.error2(filename,ln,col,msg,source);
	    }
	    else
	    {
		    missingHandler(filename, ln, col, msg, source);
	    }
	    ++statics.errCount;
	}

	public void localizedWarning2(int pos, Object msg)
	{
		localizedWarning2(getErrorOrigin(), pos, msg);
	}

	public void localizedWarning2(String filename, int pos, Object msg)
	{
		if( pos < 0 )
		{
		    pos = 0;   // ISSUE: remove this hack
		}

		int ln = getInputLine(pos);
		int col = getInputCol(pos);

	    localizedWarning2(filename,ln,col,msg,getErrorLineText(pos));
	}

	public void localizedWarning2(String filename, int ln, int col, Object msg, String source)
	{
	    if( handler != null)
	    {
	        handler.warning2(filename,ln,col,msg,source);
	    }
	    else if( statics.handler != null )
	    {
	        // Flex enters through here for regular compiler errors
	        statics.handler.warning2(filename,ln,col,msg,source);
	    }
	    else
	    {
		    missingHandler(filename, ln, col, msg, source);
	    }
	}

	private void missingHandler(String filename, int ln, int col, Object msg, String source)
	{
		System.err.println(msg);
		System.err.println("   " + filename + ", Ln " + ln + ", Col " + col + ": ");

		if (source.length() > 0)
		{
		    System.err.println("   " + source);
		    System.err.println("   " + InputBuffer.getLinePointer(col));
		}
		System.err.println();
	}

    public int getInputLine(int pos)
    {
        int ret = -1;
        if( this.input != null )
        {
            ret = this.input.getLnNum(pos);
        }
        return ret;
    }

    int getInputCol(int pos)
    {
        int ret = -1;
        if( this.input != null )
        {
            ret = this.input.getColPos(pos);
        }
        return ret;
    }

    String getErrorLineText(int pos)
    {
        String ret = "";
        if( this.input != null )
        {
            ret = this.input.getLineText(pos);
        }
        return ret;
    }

    public String getErrorOrigin()
    {
        return parser_scanner_input_origin != null ? parser_scanner_input_origin : "";
    }

    public String getQualifiedErrorOrigin()
    {
	    if(qualified_origin != null && qualified_origin.length() > 0) {
		    return qualified_origin;
	    }

	    return getErrorOrigin();
    }

    public void localizedError(String filename, int ln, int col, String msg, String source)
    {
        localizedError(filename, ln, col, msg, source, -1);
    }
    // Code should call the error() methods using ErrorCode id's to log errors in a language independant
    //  manner.  They call this method with the correct string for the language in use.
    public void localizedError(String filename, int ln, int col, String msg, String source, int code)
    {
        if( handler != null)
        {
            handler.error(filename,ln,col,msg,source, code);
        }
        else if( statics.handler != null )
        {
            // Flex enters through here for regular compiler errors
            statics.handler.error(filename,ln,col,msg,source, code);
        }
        else
        {
	        missingHandler(filename, ln, col, msg, source);
        }
        ++statics.errCount;
    }

    private void localizedWarning(String filename, int ln, int col, String msg, String source, int code)
    {
        if( handler != null)
        {
            handler.warning(filename,ln,col,msg,source, code);
        }
        else if( statics.handler != null )
        {
            // Flex enters through here for regular compiler errors
            statics.handler.warning(filename,ln,col,msg,source, code);
        }
        else
        {
	        missingHandler(filename, ln, col, msg, source);
        }
    }

    public void internalError(int pos, String msg)
    // for now do same thing as error(), but not localized
    // Perhaps this should be a noop for release builds?
    {
        localizedError(getErrorOrigin(), pos, msg, kError_InternalError);
    }

    public void internalError(String msg)
    // for now do same thing as error(), but not localized
    // Perhaps this should be a noop for release builds?
    {
        internalError(-1,msg);
    }

    public void importFile(String filename) {
            if(handler != null) {
                handler.importFile(filename);
        }
    }

    public void exit(int exitCode)
    {
    }

    public void setDefType(BitSet def, TypeInfo type)
    {
        if (isEmpty(def))
        {
            // No bits set, do nothing.
            return;
        }

        // get first set bit
        int i = nextSetBit(def,0);

        if(i - def_types.size() >= 0)
        {
            def_types.resize(i + 1); // resize the type vector, if needed
            def_types.set(i, type); // set the type
        }
        else
        {
            // ISSUE: If the def_type is set but it is not the same,
            // the we are hosed.
            if (def_types.get(i) == null) // hasn't been set yet
            {
                def_types.set(i, type);
            }
            // C: def_types.get(i) != type, compare content or reference?
            else if (!type.equals(def_types.get(i)))
            {
//                TypeValue* temp = def_types[i];
//                throw "Internal type redefinition error";
                def_types.set(i, type);
            }
        }

        //printf("\nSetting def %ul to %s",def.to_ulong(),type->toString());
    }

    /*
     * Get the combined type of all reaching definitions.
     * If there are two incompatible types, then the caller
     * must coerce one to the other.
     */

    public TypeInfo getDefType(BitSet def)
    {
        TypeInfo type = voidType().getDefaultTypeInfo();

        if (isEmpty(def))
        {
            return noType().getDefaultTypeInfo();
        }

        // Check type defined types until there are no more.
        final BitSet bits = def;

        // Iterate only over set bits
        for(int i=nextSetBit(bits,0); i>=0; i=nextSetBit(bits,i+1))
        {
            int diff = 0;
            if ((diff = i - def_types.size()) >= 0)
            {
                if (true)
                {
                    return noType().getDefaultTypeInfo();
                }
                else
                {
                    // ISSUE: If you get here, there is a definition, but
                    // it has not been assigned a type. Set the def_type
                    // to a guess and check it later.

                    for (int j = 0; j < diff; j++)
                    {
                        def_types.add(null); // resize the type vector, if needed
                    }
                    def_types.set(i, type); // set the type
                }
            }
            else if (type != null && type.getTypeValue() == voidType())
            {
                type = def_types.get(i);
            }
            else if (def_types.get(i) == null) // Two incompatible types
            {
                // else, keep using current type
            }
            else if (type != null && (type.getTypeId() & def_types.get(i).getTypeId()) == 0)
            {
                // ISSUE: Why don't some definitions have their type set?
                // See: moz\tests\ecma_2\Statements\dowhile-006

                type = noType().getDefaultTypeInfo();
            }
            // else, keep using current type
        }

        return type;
    }


    public Node coerce(Node expr, TypeInfo[] actual, TypeValue expected)
    {
        return coerce(expr,actual,expected != null ? expected.getDefaultTypeInfo() : null,false,false);
    }
    public Node coerce(Node expr, TypeInfo[] actual, TypeValue expected, boolean isExplicit)
    {
        return coerce(expr,actual,expected != null ? expected.getDefaultTypeInfo() : null,isExplicit,false);
    }

    // FIXME: the usage of a TypeValue[] seems to be unnecessary and could cause unnecessary GC pressure
    public Node coerce(Node expr, TypeInfo[] actual, TypeInfo expected)
    {
        return coerce(expr,actual,expected,false,false);
    }
    public Node coerce(Node expr, TypeInfo[] actual, TypeInfo expected, boolean isExplicit)
    {
        return coerce(expr,actual,expected,isExplicit,false);
    }


    public Node coerce(Node expr, TypeInfo[] actual, TypeInfo expected, boolean isExplicit, boolean force)
    {
        if (expr instanceof ListNode)
        {
            // compound expression.  Only coerce the final expr in the list.
            ListNode list = (ListNode) expr;
            Node lastExpr = list.items.back();
            lastExpr = coerce(lastExpr, actual, expected, isExplicit, force);
            list.items.pop_back();
            list.items.push_back(lastExpr);
            return expr;
        }
        else if (expr instanceof ConditionalExpressionNode)
        {
            // the two branches of a conditional node might produce different results.
            // so, instead of coercing the result, add a coerce to each branch so they
            // will produce compatible results.

            // we set force to true because our actual&expected types may not match
            // what's at runtime, and the VM cannot compensate at join nodes.

            ConditionalExpressionNode cond = (ConditionalExpressionNode) expr;

            actual[0] = cond.thenvalue != null ? cond.thenvalue.getType(this) : null;
            cond.thenexpr = coerce(cond.thenexpr, actual, expected, isExplicit, true);

            actual[0] = cond.elsevalue != null ? cond.elsevalue.getType(this) : null;
            cond.elseexpr = coerce(cond.elseexpr, actual, expected, isExplicit, true);

            return expr;
        }
        else if (expr instanceof BinaryExpressionNode)
        {
            BinaryExpressionNode binary = (BinaryExpressionNode) expr;
            if ((binary.op == LOGICALAND_TOKEN || binary.op == LOGICALOR_TOKEN) && ( (expected != null && expected.getTypeValue() != voidType() ) || (binary.lhstype != binary.rhstype)))
            {
                // short-circuit logical operator.  push coersion down so types match at join nodes.
                // we set force to true because our actual&expected types may not match
                // what's at runtime, and the VM cannot compensate at join nodes.

                // If the expected type is void but the lhstype and rhstype don't match,
                // then don't coerce to void as this will result in nothing being left
                // on the stack for the lhs or rhs expressions, and the binary op will stack underflow.  But we have
                // to coerce to something so that the types match at the join nodes, so coerce to *
                TypeInfo expected2 = expected != null ? expected.getTypeValue() == voidType() ? noType().getDefaultTypeInfo() : expected : null;

                actual[0] = binary.lhstype;
                binary.lhs = coerce(binary.lhs, actual, expected2, isExplicit, true);
                binary.lhstype = actual[0];

                actual[0] = binary.rhstype;
                binary.rhs = coerce(binary.rhs, actual, expected2, isExplicit, true);
                binary.rhstype = actual[0];

                return expr;
            }
        }

        // if expected is not defined, it's a type-sniffing operator and we
        // want to preserve the actual type.
        if (expected == null)
        {
            // but if this feeds into a join node, we must make the type
            // be something, so choose *.  this causes too many coersions but is safe.
            if (force)
            {
                actual[0] = noType().getDefaultTypeInfo();
                return statics.nodeFactory.coerce(expr,null,noType().getDefaultTypeInfo(),isExplicit);
            }
            return expr;
        }


        // First check for the common native types

        if (expected.getTypeValue() == voidType())
        {
            actual[0] = expected;
            expr.voidResult();
            return expr;
        }
        // if actual is unknown, go ahead and coerce to expected
        else if (actual[0] == null)
        {
            actual[0] = expected;
            return statics.nodeFactory.coerce(expr,null,expected,isExplicit);
        }
        // If expected is undefined or compatible...
        else if (expected == actual[0] || expected.includes(this, actual[0]))
        {

            return force ? statics.nodeFactory.coerce(expr,null,expected,isExplicit)
                         : expr;

        }
        else if (useStaticSemantics()) // do ! type compatability checking
        {
            if (actual[0].getTypeValue() != nullType() && expected.getTypeValue() != booleanType())  // null is always valid, everything coerces to boolean
            {
                // a widening cast
                if ( actual[0].getTypeValue().getTypeInfo(true).includes(this,expected) )
                {
                    if ( actual[0].getTypeValue() == vectorObjType() && expected.getTypeValue().baseclass == vectorObjType() )
                    {
                        // allow coercion from Vector.<*> to Vector.<T>
                    }
                    else if ( !isExplicit && actual[0].getTypeValue() != noType()) // always allow coercion from Object.  Just too common a problem without this
                    {
                        error(expr.pos(), kError_ImplicitCoercionToSubtype, actual[0].getName(this).toString(), expected.getName(this).toString());
                    }
                }
                else if ( expected.getTypeValue() == stringType() && (actual[0].getTypeValue() == xmlType() || actual[0].getTypeValue() == xmlListType()) )
                {
                    // do nothing, e4x values are string values transparently (i.e. without having to call toString()/toXMLString()).
                }
                    // unrelated cast (unless its between number types)
                else if ( !(expected.isNumeric(this) && actual[0].isNumeric(this))) // always allow coercion between number types
                {
                    error(expr.pos(), kError_ImplicitCoercisionOfUnrelatedType, actual[0].getName(this).toString(), expected.getName(this).toString());
                }
            }
        }

        return (force || isExplicit) ? statics.nodeFactory.coerce(expr,actual[0],expected,isExplicit)
                                     : expr;
    }


    public int errorCount()
    {
        return statics.errCount;
    }

    private void pushStaticClassScopesHelper(TypeValue cframe)
    {
        if (cframe.baseclass != null)
        {
            pushStaticClassScopesHelper(cframe.baseclass);
        }
        pushScope(cframe);
    }

    public void pushStaticClassScopes(ClassDefinitionNode node)
    {
        pushStaticClassScopesHelper(node.cframe);
    }

    public void popStaticClassScopes(ClassDefinitionNode node)
    {
        TypeValue cframe = node.cframe;
        while (cframe != null)
        {
            popScope();
            cframe = cframe.baseclass;
        }
    }

    public void pushScope(ObjectValue scope)
    {
        if (statics.scopes.isEmpty())
        {
            statics.global = scope;
        }
        statics.scopes.add(scope);
    }

    public void popScope()
    {
        statics.scopes.removeLast();
        if (statics.scopes.isEmpty())
        {
            statics.global = null;
        }
    }

    public ObjectList<ObjectValue> getScopes()
    {
        return statics.scopes;
    }

    public ObjectList<ObjectValue> swapScopeChain(ObjectList<ObjectValue> new_scopes )
    {
        ObjectList<ObjectValue> old_scopes = statics.scopes;
        statics.scopes = new_scopes;
        return old_scopes;
    }

    public ObjectValue scope()
    {
        if( statics.scopes.size() > 0 )
        {
            return statics.scopes.back();
        }
        else
        {
            return statics.global;   // this is an error case. return global for graceful failure
        }
    }

    public int getScopeDepth()
    {
        return statics.scopes.size();
    }

    public ObjectValue scope(int n)
    {
        if( n >= 0 && n < statics.scopes.size() )
        {
            return statics.scopes.get(n);
        }
        else
        {
            return statics.global; // for graceful error handling
        }
    }

    public ObjectValue globalScope()
    {
        return statics.global;
    }

    public ObjectValue builtinScope()
    {
        if(GlobalBuilder.useStaticBuiltins)
            return statics.globalPrototype;
        else
            return globalScope();
    }

    public void setEmitter(Emitter emitter)
    {
        statics.emitter = emitter;
    }

    public Emitter getEmitter()
    {
        return statics.emitter;
    }

    public void setPath(String pathspec)
    {
        statics.pathspec = pathspec;
    }

    public String path()
    {
        return statics.pathspec;
    }

    public void setScriptName(String scriptname)
    {
        statics.scriptname = scriptname;
    }

    public String scriptName()
    {
        return statics.scriptname;
    }

    public NodeFactory getNodeFactory()
    {
        if (statics.nodeFactory == null)
        {
            statics.nodeFactory = new NodeFactory(this);
        }
        else
        {
            statics.nodeFactory.setContext(this);
        }

        return statics.nodeFactory;
    }

    public ByteCodeFactory getByteCodeFactory()
    {
        if (statics.bytecodeFactory == null)
        {
            statics.bytecodeFactory = new ByteCodeFactory();
        }

        return statics.bytecodeFactory;
    }

    public void setHandler(CompilerHandler handler)
    {
        this.handler = handler;

        if (statics.handler == null)
        {
            statics.handler = handler;
        }
    }

    public void setLanguage(String language)
    {
        statics.languageID = getLanguageID(language);
    }

    public static int getLanguageID(String language)
    {
        int langID = ContextStatics.LANG_EN;
        if (language.equals("EN")) langID = ContextStatics.LANG_EN;
        else if (language.equals("CN")) langID = ContextStatics.LANG_CN;
        else if (language.equals("CS")) langID = ContextStatics.LANG_CS;
        else if (language.equals("DK")) langID = ContextStatics.LANG_DA;
        else if (language.equals("DE")) langID = ContextStatics.LANG_DE;
        else if (language.equals("ES")) langID = ContextStatics.LANG_ES;
        else if (language.equals("FI")) langID = ContextStatics.LANG_FI;
        else if (language.equals("FR")) langID = ContextStatics.LANG_FR;
        else if (language.equals("IT")) langID = ContextStatics.LANG_IT;
        else if (language.equals("JP")) langID = ContextStatics.LANG_JP;
        else if (language.equals("KR")) langID = ContextStatics.LANG_KR;
        else if (language.equals("NO")) langID = ContextStatics.LANG_NB;
        else if (language.equals("NL")) langID = ContextStatics.LANG_NL;
        else if (language.equals("PL")) langID = ContextStatics.LANG_PL;
        else if (language.equals("BR")) langID = ContextStatics.LANG_PT;
        else if (language.equals("RU")) langID = ContextStatics.LANG_RU;
        else if (language.equals("SE")) langID = ContextStatics.LANG_SV;
        else if (language.equals("TR")) langID = ContextStatics.LANG_TR;
        else if (language.equals("TW")) langID = ContextStatics.LANG_TW;

        return langID;
    }

    public CompilerHandler getHandler()
    {
        return this.handler;
    }

    public Writer getErrOut()
    {
        return this.err;
    }

    public ObjectList<TypeInfo> def_types = new ObjectList<TypeInfo>();

    public Block newBlock()
    {
        return new Block();
    }

    public ObjectValue publicNamespace()
    {
        if (statics._publicNamespace == null)
        {
            statics._publicNamespace = getNamespace("");
        }
        return statics._publicNamespace;
    }

    public ObjectValue AS3Namespace()
    {
        if (statics._AS3Namespace == null)
        {
            statics._AS3Namespace = getNamespace("");
        }
        return statics._AS3Namespace;
    }
    
    public ObjectValue anyNamespace()
    {
        if (statics._anyNamespace == null)
        {
            statics._anyNamespace = getNamespace("*");
        }
        return statics._anyNamespace;
    }

    public TypeValue noType()
    {
        if (statics._noType == null)
        {
            String name = "*";
            QName qname = new QName(publicNamespace(), name);
            ObjectValue protected_namespace = getNamespace(qname.toString(), NS_PROTECTED);
            ObjectValue static_protected_namespace = getNamespace(qname.toString(), NS_STATIC_PROTECTED);
            statics._noType = new TypeValue(this, new ClassBuilder(qname,protected_namespace,static_protected_namespace), qname, TYPE_none);
            statics._noType.prototype = new ObjectValue(this, new InstanceBuilder(qname), statics._noType);
            statics.builtins.put(name, statics._noType);
            statics._noType.prototype.builder.is_dynamic = true;  // do this here since there is no class definition
        }
        return statics._noType;
    }

    public TypeValue objectType()
    {
        if (statics._objectType == null)
        {
            String name = "Object";
            QName qname = new QName(publicNamespace(), name);
            ObjectValue protected_namespace = getNamespace(qname.toString(), NS_PROTECTED);
            ObjectValue static_protected_namespace = getNamespace(qname.toString(), NS_STATIC_PROTECTED);
            statics._objectType = new TypeValue(this, new ClassBuilder(qname,protected_namespace,static_protected_namespace), qname, TYPE_object);
            statics._objectType.prototype = new ObjectValue(this, new InstanceBuilder(qname), statics._objectType);
            statics.builtins.put(name, statics._objectType);
        }
        return statics._objectType;
    }

    public TypeValue arrayType()
    {
        if (statics._arrayType == null)
        {
            String name = "Array";
            QName qname = new QName(publicNamespace(), name);
            ObjectValue protected_namespace = getNamespace(qname.toString(), NS_PROTECTED);
            ObjectValue static_protected_namespace = getNamespace(qname.toString(), NS_STATIC_PROTECTED);
            statics._arrayType = new TypeValue(this, new ClassBuilder(qname,protected_namespace,static_protected_namespace), qname, TYPE_array);
            statics._arrayType.prototype = new ObjectValue(this, new InstanceBuilder(qname), statics._arrayType);
            statics.builtins.put(name, statics._arrayType);
        }
        return statics._arrayType;
    }

    public TypeValue voidType()
    {
        if (statics._voidType == null)
        {
            String name = "void";
            QName qname = new QName(publicNamespace(), name);
            ObjectValue protected_namespace = getNamespace(qname.toString(), NS_PROTECTED);
            ObjectValue static_protected_namespace = getNamespace(qname.toString(), NS_STATIC_PROTECTED);
            statics._voidType = new TypeValue(this, new ClassBuilder(qname,protected_namespace,static_protected_namespace), qname, TYPE_void);
            statics._voidType.prototype = new ObjectValue(this, new InstanceBuilder(qname), statics._voidType);
            statics._voidType.prototype.setValue("undefined");
            statics.builtins.put(name, statics._voidType);
        }
        return statics._voidType;
    }

    public TypeValue nullType()
    {
        if (statics._nullType == null)
        {
            String name = "Null";
            QName qname = new QName(publicNamespace(), name);
            ObjectValue protected_namespace = getNamespace(qname.toString(), NS_PROTECTED);
            ObjectValue static_protected_namespace = getNamespace(qname.toString(), NS_STATIC_PROTECTED);
            statics._nullType = new TypeValue(this, new ClassBuilder(qname,protected_namespace,static_protected_namespace), qname, TYPE_null);
            statics._nullType.prototype = new ObjectValue(this, new InstanceBuilder(qname), statics._nullType);
            statics._nullType.prototype.setValue("null");
            statics.builtins.put(name, statics._nullType);
        }
        return statics._nullType;
    }

    public TypeValue booleanType()
    {
        if (statics._booleanType == null)
        {
            String name = "Boolean";
            QName qname = new QName(publicNamespace(), name);
            ObjectValue protected_namespace = getNamespace(qname.toString(), NS_PROTECTED);
            ObjectValue static_protected_namespace = getNamespace(qname.toString(), NS_STATIC_PROTECTED);
            statics._booleanType = new TypeValue(this, new ClassBuilder(qname,protected_namespace,static_protected_namespace), qname, TYPE_boolean);
            statics._booleanType.prototype = new ObjectValue(this, new InstanceBuilder(qname), statics._booleanType);
            statics.builtins.put(name, statics._booleanType);
        }
        return statics._booleanType;
    }

    public TypeValue stringType()
    {
        if (statics._stringType == null)
        {
            String name = "String";
            QName qname = new QName(publicNamespace(), name);
            ObjectValue protected_namespace = getNamespace(qname.toString(), NS_PROTECTED);
            ObjectValue static_protected_namespace = getNamespace(qname.toString(), NS_STATIC_PROTECTED);
            statics._stringType = new TypeValue(this, new ClassBuilder(qname,protected_namespace,static_protected_namespace), qname, TYPE_string);
            statics._stringType.prototype = new ObjectValue(this, new InstanceBuilder(qname), statics._stringType);
            statics.builtins.put(name, statics._stringType);
        }
        return statics._stringType;
    }

    public TypeValue typeType()
    {
        if (statics._typeType == null)
        {
            String name = "Class";
            QName qname = new QName(publicNamespace(), name);
            ObjectValue protected_namespace = getNamespace(qname.toString(), NS_PROTECTED);
            ObjectValue static_protected_namespace = getNamespace(qname.toString(), NS_STATIC_PROTECTED);
            statics._typeType = new TypeValue(this, new ClassBuilder(qname,protected_namespace,static_protected_namespace), qname, TYPE_type);
            statics._typeType.prototype = new ObjectValue(this, new InstanceBuilder(qname), statics._typeType);
            statics.builtins.put(name, statics._typeType);
        }
        return statics._typeType;
    }

    public TypeValue functionType()
    {
        if (statics._functionType == null)
        {
            String name = "Function";
            QName qname = new QName(publicNamespace(), name);
            ObjectValue protected_namespace = getNamespace(qname.toString(), NS_PROTECTED);
            ObjectValue static_protected_namespace = getNamespace(qname.toString(), NS_STATIC_PROTECTED);
            statics._functionType = new TypeValue(this, new ClassBuilder(qname,protected_namespace,static_protected_namespace), qname, TYPE_function);
            statics._functionType.prototype = new ObjectValue(this, new InstanceBuilder(qname), statics._functionType);
            statics.builtins.put(name, statics._functionType);
        }
        return statics._functionType;
    }

    public TypeValue intType()
    {
        if (statics._intType == null)
        {
            String name = "int";
            QName qname = new QName(publicNamespace(), name);
            ObjectValue protected_namespace = getNamespace(qname.toString(), NS_PROTECTED);
            ObjectValue static_protected_namespace = getNamespace(qname.toString(), NS_STATIC_PROTECTED);
            statics._intType = new TypeValue(this, new ClassBuilder(qname,protected_namespace,static_protected_namespace), qname, TYPE_int);
            statics._intType.prototype = new ObjectValue(this, new InstanceBuilder(qname), statics._intType);
            statics.builtins.put(name, statics._intType);
        }
        return statics._intType;
    }

    public TypeValue uintType()
    {
        if (statics._uintType == null)
        {
            String name = "uint";
            QName qname = new QName(publicNamespace(), name);
            ObjectValue protected_namespace = getNamespace(qname.toString(), NS_PROTECTED);
            ObjectValue static_protected_namespace = getNamespace(qname.toString(), NS_STATIC_PROTECTED);
            statics._uintType = new TypeValue(this, new ClassBuilder(qname,protected_namespace,static_protected_namespace), qname, TYPE_uint);
            statics._uintType.prototype = new ObjectValue(this, new InstanceBuilder(qname), statics._uintType);
            statics.builtins.put(name, statics._uintType);
        }
        return statics._uintType;
    }

    public TypeValue numberType()
    {
    	// treated the same as double
        if (statics._numberType == null)
        {
            String name = "Number";
            QName qname = new QName(publicNamespace(), name);
            ObjectValue protected_namespace = getNamespace(qname.toString(), NS_PROTECTED);
            ObjectValue static_protected_namespace = getNamespace(qname.toString(), NS_STATIC_PROTECTED);
            statics._numberType = new TypeValue(this, new ClassBuilder(qname,protected_namespace,static_protected_namespace), qname, TYPE_double);
            statics._numberType.prototype = new ObjectValue(this, new InstanceBuilder(qname), statics._numberType);
            statics.builtins.put(name, statics._numberType);
        }
        return statics._numberType;
    }

    public TypeValue doubleType()
    {
    	if (!statics.es4_numerics)	// to deal with old Global.abc files without double defined.
    		return numberType();
        if (statics._doubleType == null)
        {
            String name = "double";
            QName qname = new QName(publicNamespace(), name);
            ObjectValue protected_namespace = getNamespace(qname.toString(), NS_PROTECTED);
            ObjectValue static_protected_namespace = getNamespace(qname.toString(), NS_STATIC_PROTECTED);
            statics._doubleType = new TypeValue(this, new ClassBuilder(qname,protected_namespace,static_protected_namespace), qname, TYPE_double);
            statics._doubleType.baseclass = objectType(); // since this is not in older Global.abc
            statics._doubleType.prototype = new ObjectValue(this, new InstanceBuilder(qname), statics._doubleType);
            statics.builtins.put(name, statics._doubleType);
        }
        return statics._doubleType;
    }

    public TypeValue decimalType()
    {
    	// leave null unless es4_numerics
        if (statics._decimalType == null && statics.es4_numerics)
        {
            String name = "decimal";
            QName qname = new QName(publicNamespace(), name);
            ObjectValue protected_namespace = getNamespace(qname.toString(), NS_PROTECTED);
            ObjectValue static_protected_namespace = getNamespace(qname.toString(), NS_STATIC_PROTECTED);
            statics._decimalType = new TypeValue(this, new ClassBuilder(qname,protected_namespace,static_protected_namespace), qname, TYPE_decimal);
            statics._decimalType.prototype = new ObjectValue(this, new InstanceBuilder(qname), statics._decimalType);
            statics.builtins.put(name, statics._decimalType);
        }
        return statics._decimalType;
    }
    
    public TypeValue xmlType()
    {
        if (statics._xmlType == null)
        {
            String name = "XML";
            QName qname = new QName(publicNamespace(), name);
            ObjectValue protected_namespace = getNamespace(qname.toString(), NS_PROTECTED);
            ObjectValue static_protected_namespace = getNamespace(qname.toString(), NS_STATIC_PROTECTED);
            statics._xmlType = new TypeValue(this, new ClassBuilder(qname,protected_namespace,static_protected_namespace), qname, TYPE_xml);
            statics._xmlType.prototype = new ObjectValue(this, new InstanceBuilder(qname), statics._xmlType);
            statics.builtins.put(name, statics._xmlType);
        }
        return statics._xmlType;
    }

    public TypeValue regExpType()
    {
        if (statics._regExpType == null)
        {
            String name = "RegExp";
            QName qname = new QName(publicNamespace(), name);
            ObjectValue protected_namespace = getNamespace(qname.toString(), NS_PROTECTED);
            ObjectValue static_protected_namespace = getNamespace(qname.toString(), NS_STATIC_PROTECTED);
            statics._regExpType = new TypeValue(this, new ClassBuilder(qname,protected_namespace,static_protected_namespace), qname, TYPE_object);
            statics._regExpType.prototype = new ObjectValue(this, new InstanceBuilder(qname), statics._regExpType);
            statics.builtins.put(name, statics._regExpType);
        }
        return statics._regExpType;
    }

    public TypeValue xmlListType()
    {
        if (statics._xmlListType == null)
        {
            String name = "XMLList";
            QName qname = new QName(publicNamespace(), name);
            ObjectValue protected_namespace = getNamespace(qname.toString(), NS_PROTECTED);
            ObjectValue static_protected_namespace = getNamespace(qname.toString(), NS_STATIC_PROTECTED);
            statics._xmlListType = new TypeValue(this, new ClassBuilder(qname,protected_namespace,static_protected_namespace), qname, TYPE_xml);
            statics._xmlListType.prototype = new ObjectValue(this, new InstanceBuilder(qname), statics._xmlListType);
            statics.builtins.put(name, statics._xmlListType);
        }
        return statics._xmlListType;
    }

    public TypeValue vectorType()
    {
        if (statics._vectorType == null)
        {
            String name = "Vector";
            QName qname = new QName(getNamespace("__AS3__.vec"), name);
            ObjectValue protected_namespace = getNamespace(qname.toString(), NS_PROTECTED);
            ObjectValue static_protected_namespace = getNamespace(qname.toString(), NS_STATIC_PROTECTED);
            statics._vectorType = new TypeValue(this, new ClassBuilder(qname,protected_namespace,static_protected_namespace), qname, TYPE_object);
            statics._vectorType.prototype = new ObjectValue(this, new InstanceBuilder(qname), statics._vectorType);
            statics._vectorType.is_parameterized = true;
            statics.builtins.put(qname.toString(), statics._vectorType);
        }
        return statics._vectorType;
    }

    public TypeValue vectorObjType()
    {
        if (statics._vectorObjType == null)
        {
            String name = "Vector$object";
            QName qname = new QName(getNamespace("__AS3__.vec", Context.NS_INTERNAL), name);
            ObjectValue protected_namespace = getNamespace(qname.toString(), NS_PROTECTED);
            ObjectValue static_protected_namespace = getNamespace(qname.toString(), NS_STATIC_PROTECTED);
            statics._vectorObjType = new TypeValue(this, new ClassBuilder(qname,protected_namespace,static_protected_namespace), qname, TYPE_object);
            statics._vectorObjType.prototype = new ObjectValue(this, new InstanceBuilder(qname), statics._vectorObjType);
            statics.builtins.put(qname.toString(), statics._vectorObjType);
        }
        return statics._vectorObjType;
    }


    public boolean isBuiltin(String name)
    {
        return statics.builtins.containsKey(name);
    }

    public TypeValue builtin(String name)
    {
        return statics.builtins.get(name);
    }

    public TypeValue userDefined(String name)
    {
        return statics.userDefined.get(name);
    }

    /**
     * Store a TypeValue for the given fully qualified name.  This TypeValue is
     * used when parsing ABC's to avoid forward reference problems, and during the two
     * pass mxml compilation (the second pass needs to rebuild the same TypeValue, rather
     * than creating a new TypeValue).
     * @param name  fully qualified name of the type
     * @param value the TypeValue
     */
    public void setUserDefined(String name, TypeValue value)
    {
        statics.userDefined.put(name, value);
    }

    /**
     * mxmlc uses this to remove references to types which no longer exist, so that Types
     * defined in one project do not bleed over into other projects
     * @param name the name of the type to remove
     * @return the TypeValue that was removed
     */
    public TypeValue removeUserDefined(String name)
    {
        return statics.userDefined.remove(name);
    }

    public ObjectValue booleanTrue()
    {
        if( statics._booleanTrue == null )
        {
            statics._booleanTrue = new ObjectValue("true", this.booleanType());
        }
        return statics._booleanTrue;
    }

    public ObjectValue booleanFalse()
    {
        if( statics._booleanFalse == null )
        {
            statics._booleanFalse = new ObjectValue("false", this.booleanType());
        }
        return statics._booleanFalse;
    }

	public static final int MIN_API_MARK = 0xE000;
	public static final int MAX_API_MARK = 0xF8FF;

	static int getVersion(String uri) {
		if (uri.length() == 0) return -1;
		int last = uri.codePointAt(uri.length()-1);
		if(last >= MIN_API_MARK && last <= MAX_API_MARK) {
			return last-MIN_API_MARK;
		}
		return -1;
	}

	static String stripVersion(String uri) {
		int version = getVersion(uri);
		if(version >= 0) {
			uri = uri.substring(0, uri.length()-1);
			//System.out.println("stripping "+version+" from uri='"+uri+"'");
		}
		return uri.intern();
	}

    public ObjectValue getNamespace(String name)
    {
        return getNamespace(name, NS_PUBLIC);
    }

    public ObjectValue getNamespace(String name, byte ns_kind)
    {
        return statics.getNamespace(name, ns_kind);
    }

    public ObjectValue getOpaqueNamespace(String name)
    {
        return getNamespace(name);
    }

    // C: this is only definition names, not package names
    public boolean isValidImport(String name)
    {
        return statics != null ? statics.validImports.contains(name) : false;
    }

    public void addValidImport(String name)
    {
        if (statics.validImports == null)
        {
            statics.validImports = new HashSet<String>();
        }
        statics.validImports.add(name);
    }

    public boolean useStaticSemantics()
    {
        return statics.use_static_semantics;
    }

    public boolean checkVersion()
    {
        return statics.check_version;
    }

    public void pushVersion(int v)
    {
        if( checkVersion() ) {
            //System.out.println("pushing version " + v);
            statics.versions.push_back(v);
        }
    }

    public int popVersion()
    {
        if( checkVersion() ) {
            int ret = statics.versions.pop_back();
            //System.out.println("pop version " + ret);
            return ret;
        }
        return 0;
    }

    public int version()
    {
        return statics.versions.size() > 0 ? statics.versions.back() : 0;
    }
    /**
     * Check which version of the language we're compiling for.  9 is ES3, 10 is AS3
     * @param n
     */
    public boolean dialect(int n)
    {
        return statics.dialect == n;
    }

    /**
     * check which version of the VM we're compiling for.  Returns true if the target is
     * greater or equal to the version passed in
     */
    public boolean abcVersion(int n)
    {
        return statics.abc_version >= n;
    }

    public boolean isNamespace( String ns_name )
    {
        return statics.namespaces.containsKey(ns_name);
    }

     public boolean isNamespace(ObjectValue obj)
     {
         boolean isns = false;
         if (obj != null )
         {
             if( obj.isPrivate() && statics.private_namespaces.containsKey(obj.name) )
             {
                 isns = true;
             }
             else if( obj.isProtected() && statics.protected_namespaces.containsKey(obj.name) )
             {
                 isns = true;
             }
             else if( obj.isInternal() && statics.internal_namespaces.containsKey(obj.name) )
             {
                 isns = true;
             }
             else if( statics.namespaces.containsKey(obj.name) )
             {
                 isns = true;
             }
         }
         return isns;
     }

    public ObjectValue getUnresolvedNamespace(Context cx, Node node, ReferenceValue ref)
    {
        if (unresolved_namespaces == null)
        {
            unresolved_namespaces = new TreeMap<UnresolvedNamespace, ObjectList<ObjectValue>>(new ObjectValue.ObjectValueCompare());
        }

        for (Iterator<UnresolvedNamespace> i = unresolved_namespaces.keySet().iterator(); i.hasNext();)
        {
            UnresolvedNamespace ns = i.next();
            ReferenceValue val = ns.ref;
            if (val.name.equals(ref.name) && val.getImmutableNamespaces().size() == ref.getImmutableNamespaces().size())
            {
                boolean match = true;
                for (int j = 0, size = val.getImmutableNamespaces().size(); j < size; j++)
                {
                    if (!val.getImmutableNamespaces().get(j).name.equals(ref.getImmutableNamespaces().get(j).name))
                    {
                        match = false;
                        break;
                    }
                }
                if (match)
                {
                    return ns;
                }
            }
        }

        UnresolvedNamespace ns = new UnresolvedNamespace(cx, node, ref);
        ns.name = ("__unresolved__ns__" + statics.unresolved_ns_count++).intern();
        ObjectList<ObjectValue> scopes = new ObjectList<ObjectValue>(statics.scopes);
        unresolved_namespaces.put(ns, scopes);
        return ns;
    }

    public void processUnresolvedNamespaces()
    {
        if (unresolved_namespaces != null)
        {
            List<UnresolvedNamespace> nsList = new ArrayList<UnresolvedNamespace>(unresolved_namespaces.keySet());

            for (int i = 0, size = nsList.size(); i < size; i++)
            {
                UnresolvedNamespace ns = nsList.get(i);
                ObjectList<ObjectValue> temp = statics.scopes;
                statics.scopes = unresolved_namespaces.get(ns);
                Slot slot = ns.ref.getSlot(this);
                statics.scopes = temp;

                // If we find a slot without a value, it means the namespace is defined in a variable.
                if (slot != null)
                {
                    Value val = slot.getValue();
                    ObjectValue realNamespace = (val instanceof ObjectValue) ? (ObjectValue) val : null;

                    if (realNamespace != null)
                    {
                        // Remove the ns from the TreeMap before we change it's name, and ns_kind,
                        // which would change the ordering that ObjectValue.ObjectValueCompare generates.
                        // If we don't remove the entry, then the Tree could be messed up since the ordering could
                        // be different from when the namespace was inserted.  This could cause lookup problems for
                        // other unresolved namespaces.
                        unresolved_namespaces.remove(ns);

                        ns.name = realNamespace.name;
                        ns.ns_kind = realNamespace.getNamespaceKind();
                        ns.resolved = true;
                    }
                }
                else
                {
                    // must use the context in effect when the unresolvedNamespace was created.  The node may have come from an included file.
                    ns.cx.error(ns.node.pos(), kError_Unknown_Namespace);
                }

                // null out the Context object. it's no longer used. UnresolvedNamespace instances may be referenced
                // by some Names instances and these Names instances could be in turn, referenced by some ObjectValues,
                // which mxmlc stores for incremental compilations.
                ns.cx = null;
	            ns.node = null;
                ns.ref = null;
            }

            unresolved_namespaces.clear();
            unresolved_namespaces = null;
        }
    }

    public String debugName(String region_part, String name, ObjectList<String> namespace_ids, int kind )
    {
        String kind_part = kind==GET_TOKEN?"/get":(kind==SET_TOKEN?"/set":"");
        StringBuilder namespace_part = new StringBuilder(region_part.length() + name.length() + kind_part.length() + ((namespace_ids != null ? namespace_ids.size() * 8 : 0)));
        namespace_part.append(region_part);
        int region_part_length = region_part.length();
        if (region_part_length > 0)
        {
            namespace_part.append('/');
            region_part_length++;
        }
        if(namespace_ids != null)
        {
            int last = namespace_ids.size()-1 ;
            for( int n = last; n >= 0; --n )
            {
                if( namespace_ids.at(n).length() == 0 )
                {   // skip delimiter
                }
                else
                if( n == last )
                {   // skip it
                }
                else
                {
                    namespace_part.append('|');
                }
                namespace_part.append(namespace_ids.at(n));
            }
        }
        if( namespace_part.length() - region_part_length > 0 )
        {
            namespace_part.append(':');
        }
        String debug_name = namespace_part.append(name).append(kind_part).toString();
        return debug_name;
    }

    public QName computeQualifiedName(String region_part, String name, ObjectValue qualifier, int kind )
    {
        String kind_part = kind==GET_TOKEN?"/get":(kind==SET_TOKEN?"/set":"");
        String namespace_part = qualifier.name;
        byte ns_kind = qualifier.getNamespaceKind();
        return new QName(getNamespace((region_part.length() != 0) ? (region_part+namespace_part).intern() : namespace_part, ns_kind),
                         (kind_part.length() != 0) ? name+kind_part : name);
    }

    public ObjectList<Node> getComments()
    {
        return comments;
    }

    public String toString() {
      if(Node.useDebugToStrings)
           return (input != null ? input.origin : "");
      else
         return super.toString();
    }

    public void setOrigin(String origin) {
        this.parser_scanner_input_origin = origin.intern();
    }

    public void setQualifiedOrigin(String qualifiedOrigin) {
	    this.qualified_origin = qualifiedOrigin;
    }
    
    public String getConfigVarCode() {
        String code = null;
        StringBuilder code_buffer;
        if( config_vars != null && config_vars.size() > 0)
        {
        	HashSet<String> namespaces = new HashSet<String>();
        	// guesstimate.  Should avoid resizing too many times.
            code_buffer = new StringBuilder(config_vars.size()*10);
            for( int i = 0, size = config_vars.size(); i < size; ++i )
            {
                ConfigVar cv = config_vars.at(i);
                if( !namespaces.contains(cv.ns) )
                {
                	// If we haven't seen this namespace before, add a 
                	// config namespace directive to make the namespace
                	// a configuration namespace.
                	namespaces.add(cv.ns);
                	code_buffer.append("config namespace " + cv.ns + ";\n");
                }
                code_buffer.append( cv.ns );
                code_buffer.append( " const ");
                code_buffer.append( cv.name + "=" + cv.value + ";\n");
            }
            code = code_buffer.toString();
        }
        return code;
    }

}
