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
public class FunctionSignatureNode extends Node
{
	public ParameterListNode parameter;
	public Node result;
	public TypeInfo type;
	public ReferenceValue typeref;
	public ListNode inits; //initializers for ctor signatures (instead of a result type)
	//public Slot slot;
    public boolean no_anno;
    public boolean void_anno;

	public FunctionSignatureNode(ParameterListNode parameter, Node result)
	{
		type = null;
		this.parameter = parameter;
		this.result = result;
		typeref = null;
        no_anno = false;
        void_anno = false;
	}

	
	public FunctionSignatureNode(ParameterListNode parameter, ListNode initializers)
	{
		type = null;
		this.parameter = parameter;
		this.inits = initializers;
		typeref = null;
        no_anno = false;
        void_anno = false;
	}
	
	public Value evaluate(Context cx, Evaluator evaluator)
	{
		if (evaluator.checkFeature(cx, this))
		{
			return evaluator.evaluate(cx, this);
		}
		else
		{
			return null;
		}
	}

	public int size()
	{
		return parameter != null ? parameter.size() : 0;
	}

	public String toString()
	{
		return "FunctionSignature";
	}

	public StringBuilder toCanonicalString(Context cx, StringBuilder buff)
	{
		if (parameter != null)
			parameter.toCanonicalString(cx, buff);
		buff.append(" result_type='");
		if (result != null)
			result.toCanonicalString(cx, buff);
        else if( this.void_anno )
            buff.append("void");
        else
            buff.append(cx.noType().name.toString());
		buff.append("'");
		return buff;
	}
}
