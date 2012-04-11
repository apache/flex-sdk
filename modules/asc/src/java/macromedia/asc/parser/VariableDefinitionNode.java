/*
 * Written by Jeff Dyer
 * Copyright (c) 1998-2003 Mountain View Compiler Company
 * All rights reserved.
 */

package macromedia.asc.parser;

import macromedia.asc.semantics.*;
import macromedia.asc.util.*;

import static macromedia.asc.parser.Tokens.*;

/**
 * Node
 *
 * @author Jeff Dyer
 */
public class VariableDefinitionNode extends DefinitionNode
{
	public int kind;
	public ListNode list;
	public Context cx;

	public VariableDefinitionNode(PackageDefinitionNode pkgdef, AttributeListNode attrs, int kind, ListNode list, int pos)
	{
		super(pkgdef,attrs,pos);
		this.kind = kind;
		this.list = list;
		this.cx = null;
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

	public boolean hasAttribute(String name)
	{
		if (attrs != null && attrs.hasAttribute(name))
		{
			return true;
		}
		return false;
	}

	public Node initializerStatement(Context cx)
	{
		NodeFactory nodeFactory = cx.getNodeFactory();
		ListNode list = this.list;
		ListNode init_list = null;

		// if there are attributes, then create a special qualified identifier
		// by using the attributes as the potential qualifier. We don't yet
		// know if any of the attributes are actually namespaces, so the qulaified
		// identifier will have to check when it is evaluated, and return an unqualified
		// reference if not.

        if( !this.isConst() )
		for (Node n : list.items)
		{
//			if( n instanceof VariableBindingNode )
			{
				VariableBindingNode binding = (VariableBindingNode) n;
	
	            // If its a simple var declaration, then hoist to the regional namespace ("public")
	
	            if( binding.attrs == null && binding.variable.type == null )
	            {
	                NodeFactory nf = cx.getNodeFactory();
	                AttributeListNode aln = null; // This will get filled in correctly when FA evaluates the VariableBindingNode
	                binding.variable.identifier = nf.qualifiedIdentifier(aln,binding.variable.identifier.name, binding.variable.identifier.pos());
	            }
	
	
	            if (binding.initializer != null)
				{
	            	Node assign_node = nodeFactory.assignmentExpression(binding.variable.identifier,binding.kind==CONST_TOKEN?CONST_TOKEN:ASSIGN_TOKEN,binding.initializer);
	            	if( assign_node instanceof MemberExpressionNode && ((MemberExpressionNode)assign_node).selector instanceof SetExpressionNode)
	            	{
	            		((SetExpressionNode)((MemberExpressionNode)assign_node).selector).is_initializer = true;
	            	}
					init_list = nodeFactory.list(init_list,assign_node);
				}
	            else
	            {
	            }
			}
		}

		if (init_list != null)
		{
			ExpressionStatementNode init = nodeFactory.expressionStatement(init_list);
			init.isVarStatement(true); // var statements always have a empty result
			return init;
		}
		else
		{
			return nodeFactory.emptyStatement();
		}
	}

	public int countVars()
	{
		return list.size();
	}

	public void setContext(Context cx) {
	   	this.cx = cx;
	}

	public Context getContext() {
	    	return this.cx;
	}

	public String toString()
	{
		if(Node.useDebugToStrings)
         return "VarDefinition@" + pos();
      else
         return "VarDefinition";
	}
}
