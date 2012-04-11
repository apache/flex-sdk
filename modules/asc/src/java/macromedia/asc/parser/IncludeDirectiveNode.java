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
public class IncludeDirectiveNode extends DefinitionNode
{
	public LiteralStringNode filespec;
	public ProgramNode program;
    public Context cx;
    public boolean in_this_include;
    public Context prev_cx;

	public IncludeDirectiveNode(Context cx, LiteralStringNode filespec, ProgramNode program)
	{
        super(null, null, -1);
		this.filespec = filespec;
		this.program = program;
        this.cx = cx;
        in_this_include = false;
        prev_cx = null;        
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

	public String toString()
	{
		return "IncludeDirective";
	}
}
