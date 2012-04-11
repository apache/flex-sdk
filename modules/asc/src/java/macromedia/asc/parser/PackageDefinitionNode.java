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
public class PackageDefinitionNode extends DefinitionNode
{
	public ReferenceValue ref;
	public PackageNameNode name;
	public StatementListNode statements;

	public ObjectList<FunctionCommonNode> fexprs = new ObjectList<FunctionCommonNode>();
	public ObjectList<ClassDefinitionNode> clsdefs = new ObjectList<ClassDefinitionNode>();

	public ObjectValue defaultNamespace;
	public ObjectValue publicNamespace;
    public ObjectValue internalNamespace;
    
    public Namespaces used_namespaces = new Namespaces();
    public Namespaces used_def_namespaces = new Namespaces();
    public Multinames imported_names = new Multinames();
    
	public int var_count;
	public int temp_count;
	public Context cx;

	public boolean package_retrieved;
    public boolean in_this_pkg;

	public PackageDefinitionNode(Context cx, AttributeListNode attrs, PackageNameNode name, StatementListNode statements)
	{
        super(null,attrs,0);
		this.cx = cx;
		this.ref = null;
		this.name = name;
		this.statements = statements;
		this.var_count = 0;
		this.temp_count = 0;
		
		package_retrieved = false;
		in_this_pkg = false;

		defaultNamespace = null;
		publicNamespace = null;
        internalNamespace = null;
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

	public Node initializerStatement(Context cx)
	{
		return cx.getNodeFactory().emptyStatement();
	}

	public boolean isConst()
	{
		return true;
	}

    public boolean isDefinition()
    {
        return false;  // this is not an error. this keeps packages from getting hoisted
    }

	public String toString()
	{
		if(Node.useDebugToStrings)
         return "PackageDefinition@" + pos();
      else
         return "PackageDefinition";
	}
}
