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

package flash.swf.tools.as3;

import macromedia.asc.parser.*;
import macromedia.asc.semantics.Value;
import macromedia.asc.util.Context;
import flash.localization.LocalizationManager;

/**
 * An adapter for visiting the nodes of an ASC AST.
 *
 * @author Clement Wong
 * @author Paul Reilly
 */
public abstract class EvaluatorAdapter implements Evaluator
{
	public void setLocalizationManager(LocalizationManager l10n)
	{
		this.l10n = l10n;
	}

	protected LocalizationManager l10n;


    /*
     * FIXME: check whether we need to change the current Context in certain evaulate methods.
     * FlowAnalyzer does this- do we use Context and need to do this as well?
     */
	public boolean checkFeature(Context cx, Node node)
	{
		return true;
	}

	// Base node

	public Value evaluate(Context cx, Node node)
	{
		return null;
	}

	// Expression evaluators

	public Value evaluate(Context cx, IdentifierNode node)
	{
		return null;
	}

	// Expression evaluators

	public Value evaluate(Context cx, IncrementNode node)
	{
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, ThisExpressionNode node)
	{
		return null;
	}

	public Value evaluate(Context cx, QualifiedIdentifierNode node)
	{
		if (node.qualifier != null)
		{
			node.qualifier.evaluate(cx, this);
		}
		return null;
	}

    public Value evaluate(Context cx, QualifiedExpressionNode node)
    {
        if( node.ref == null)
        {
            evaluate(cx,(QualifiedIdentifierNode)node);
            node.expr.evaluate(cx,this);
        }
        return node.ref;
    }

	public Value evaluate(Context cx, LiteralBooleanNode node)
	{
		return null;
	}

	public Value evaluate(Context cx, LiteralNumberNode node)
	{
		return null;
	}

	public Value evaluate(Context cx, LiteralStringNode node)
	{
		return null;
	}

	public Value evaluate(Context cx, LiteralNullNode node)
	{
		return null;
	}

	public Value evaluate(Context cx, LiteralRegExpNode node)
	{
		return null;
	}

	public Value evaluate(Context cx, LiteralXMLNode node)
	{
		if (node.list != null)
		{
			node.list.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context unused_cx, FunctionCommonNode node)
	{
		Context cx = node.cx;

		if (node.signature != null)
		{
			node.signature.evaluate(cx, this);
		}
		if (node.body != null)
		{
			node.body.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, ParenExpressionNode node)
	{
		return null;
	}

	public Value evaluate(Context cx, ParenListExpressionNode node)
	{
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, LiteralObjectNode node)
	{
		if (node.fieldlist != null)
		{
			node.fieldlist.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, LiteralFieldNode node)
	{
		if (node.name != null)
		{
			node.name.evaluate(cx, this);
		}
		if (node.value != null)
		{
			node.value.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, LiteralArrayNode node)
	{
		if (node.elementlist != null)
		{
			node.elementlist.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, LiteralVectorNode node)
	{
		node.type.evaluate(cx,this);

		if (node.elementlist != null)
		{
			node.elementlist.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, SuperExpressionNode node)
	{
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, MemberExpressionNode node)
	{
		if (node.base != null)
		{
			node.base.evaluate(cx, this);
		}
		if (node.selector != null)
		{
			node.selector.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, InvokeNode node)
	{
		if (node.args != null)
		{
			node.args.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, CallExpressionNode node)
	{
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
		if (node.args != null)
		{
			node.args.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, DeleteExpressionNode node)
	{
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, GetExpressionNode node)
	{
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, SetExpressionNode node)
	{
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
		if (node.args != null)
		{
			node.args.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, UnaryExpressionNode node)
	{
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, BinaryExpressionNode node)
	{
		if (node.lhs != null)
		{
			node.lhs.evaluate(cx, this);
		}
		if (node.rhs != null)
		{
			node.rhs.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, ConditionalExpressionNode node)
	{
		if (node.condition != null)
		{
			node.condition.evaluate(cx, this);
		}
		if (node.thenexpr != null)
		{
			node.thenexpr.evaluate(cx, this);
		}
		if (node.elseexpr != null)
		{
			node.elseexpr.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, ArgumentListNode node)
	{
		// for (Node n : node.items)
		for (int i = 0, size = node.items.size(); i < size; i++)
		{
			Node n = node.items.get(i);
			n.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, ListNode node)
	{
		// for (Node n : node.items)
		for (int i = 0, size = node.items.size(); i < size; i++)
		{
			Node n = node.items.get(i);
			n.evaluate(cx, this);
		}
		return null;
	}

	// Statements

	public Value evaluate(Context cx, StatementListNode node)
	{
		// Reevaluate the size for each iteration, because Nodes can
		// be added to "items" (See the NodeMagic.addImport() call in
		// flex2.compiler.as3.SyntaxTreeEvaluator.processResourceBundle())
		// and if the last Node is an IncludeDirectiveNode, we need to
		// be sure to evaluate it, so that in_this_include is turned
		// off.

		// for (Node n : node.items)
		for (int i = 0; i < node.items.size(); i++)
		{
			Node n = node.items.get(i);
			if (n != null)
			{
				n.evaluate(cx, this);
			}
		}

		return null;
	}

    public Value evaluate(Context cx, EmptyElementNode node)
	{
		return null;
	}

	public Value evaluate(Context cx, EmptyStatementNode node)
	{
		return null;
	}

	public Value evaluate(Context cx, ExpressionStatementNode node)
	{
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, SuperStatementNode node)
	{
		if (node.call.args != null)
		{
			node.call.args.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, LabeledStatementNode node)
	{
		if (node.label != null)
		{
			node.label.evaluate(cx, this);
		}
		if (node.statement != null)
		{
			node.statement.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, IfStatementNode node)
	{
		if (node.condition != null)
		{
			node.condition.evaluate(cx, this);
		}
		if (node.thenactions != null)
		{
			node.thenactions.evaluate(cx, this);
		}
		if (node.elseactions != null)
		{
			node.elseactions.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, SwitchStatementNode node)
	{
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
		if (node.statements != null)
		{
			node.statements.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, CaseLabelNode node)
	{
		if (node.label != null)
		{
			node.label.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, DoStatementNode node)
	{
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
		if (node.statements != null)
		{
			node.statements.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, WhileStatementNode node)
	{
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
		if (node.statement != null)
		{
			node.statement.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, ForStatementNode node)
	{
		if (node.initialize != null)
		{
			node.initialize.evaluate(cx, this);
		}
		if (node.test != null)
		{
			node.test.evaluate(cx, this);
		}
		if (node.increment != null)
		{
			node.increment.evaluate(cx, this);
		}
		if (node.statement != null)
		{
			node.statement.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, WithStatementNode node)
	{
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
		if (node.statement != null)
		{
			node.statement.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, ContinueStatementNode node)
	{
		if (node.id != null)
		{
			node.id.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, BreakStatementNode node)
	{
		if (node.id != null)
		{
			node.id.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, ReturnStatementNode node)
	{
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, ThrowStatementNode node)
	{
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, TryStatementNode node)
	{
		if (node.tryblock != null)
		{
			node.tryblock.evaluate(cx, this);
		}
		if (node.catchlist != null)
		{
			node.catchlist.evaluate(cx, this);
		}
		if (node.finallyblock != null)
		{
			node.finallyblock.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, CatchClauseNode node)
	{
		if (node.parameter != null)
		{
			node.parameter.evaluate(cx, this);
		}
		if (node.statements != null)
		{
			node.statements.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, FinallyClauseNode node)
	{
		if (node.statements != null)
		{
			node.statements.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, UseDirectiveNode node)
	{
		return null;
	}

	public Value evaluate(Context cx, IncludeDirectiveNode node)
	{
		if( !node.in_this_include )
        {
            node.in_this_include = true;
			node.prev_cx = new Context(cx.statics);
			node.prev_cx.switchToContext(cx);

            // DANGER: it may not be obvious that we are setting the
            // the context of the outer statementlistnode here
            cx.switchToContext(node.cx);
        }
        else
        {
            node.in_this_include = false;
            cx.switchToContext(node.prev_cx);   // restore prevailing context
            node.prev_cx = null;
        }

		return null;
	}

	// Definitions

	public Value evaluate(Context unused_cx, ImportDirectiveNode node)
	{
		Context cx = node.cx;

		if (node.attrs != null)
		{
			node.attrs.evaluate(cx, this);
		}
		if (node.name != null)
		{
			node.name.evaluate(cx, this);
		}

		return null;
	}

	public Value evaluate(Context cx, AttributeListNode node)
	{
		// for (Node n : node.items)
		for (int i = 0, size = node.items.size(); i < size; i++)
		{
			Node n = node.items.get(i);
			n.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, VariableDefinitionNode node)
	{
		if (node.attrs != null)
		{
			node.attrs.evaluate(cx, this);
		}
		if (node.list != null)
		{
			node.list.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, VariableBindingNode node)
	{
		if (node.variable != null)
		{
			node.variable.evaluate(cx, this);
		}
		if (node.initializer != null)
		{
			node.initializer.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, UntypedVariableBindingNode node)
	{
		if (node.identifier != null)
		{
			node.identifier.evaluate(cx, this);
		}
		if (node.initializer != null)
		{
			node.initializer.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, TypedIdentifierNode node)
	{
		if (node.identifier != null)
		{
			node.identifier.evaluate(cx, this);
		}
		if (node.type != null)
		{
			node.type.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, BinaryFunctionDefinitionNode node)
	{
		return evaluate(cx, (FunctionDefinitionNode) node);
	}

	public Value evaluate(Context unused_cx, FunctionDefinitionNode node)
	{
		Context cx = node.cx;

		if (node.attrs != null)
		{
			node.attrs.evaluate(cx, this);
		}
		if (node.name != null)
		{
			node.name.evaluate(cx, this);
		}
		if (node.fexpr != null)
		{
			node.fexpr.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, FunctionNameNode node)
	{
		if (node.identifier != null)
		{
			node.identifier.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, FunctionSignatureNode node)
	{
		if (node.parameter != null)
		{
			node.parameter.evaluate(cx, this);
		}
		if (node.result != null)
		{
			node.result.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, ParameterNode node)
	{
		if (node.identifier != null)
		{
			node.identifier.evaluate(cx, this);
		}
		if (node.type != null)
		{
			node.type.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, RestExpressionNode node)
	{
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, RestParameterNode node)
	{
		if (node.parameter != null)
		{
			node.parameter.evaluate(cx, this);
		}
		return null;
	}

    public Value evaluate(Context cx, BinaryClassDefNode node)
    {
        return evaluate(cx, (ClassDefinitionNode)node);
    }

	public Value evaluate(Context cx, BinaryInterfaceDefinitionNode node)
	{
		return evaluate(cx, (BinaryClassDefNode) node);
	}

	public Value evaluate(Context unused_cx, ClassDefinitionNode node)
	{
		Context cx = node.cx;

		if (node.attrs != null)
		{
			node.attrs.evaluate(cx, this);
		}
		if (node.name != null)
		{
			node.name.evaluate(cx, this);
		}
		if (node.baseclass != null)
		{
			node.baseclass.evaluate(cx, this);
		}
		if (node.interfaces != null)
		{
			node.interfaces.evaluate(cx, this);
		}

		if (node.fexprs != null)
		{
			// for (FunctionCommonNode n : node.fexprs)
			for (int i = 0, size = node.fexprs.size(); i < size; i++)
			{
				FunctionCommonNode n = node.fexprs.get(i);
				n.evaluate(cx, this);
			}
		}

		if (node.staticfexprs != null)
		{
			// for (FunctionCommonNode n : node.staticfexprs)
			for (int i = 0, size = node.staticfexprs.size(); i < size; i++)
			{
				FunctionCommonNode n = node.staticfexprs.get(i);
				n.evaluate(cx, this);
			}
		}

		if (node.instanceinits != null)
		{
			// for (Node n : node.instanceinits)
			for (int i = 0, size = node.instanceinits.size(); i < size; i++)
			{
				Node n = node.instanceinits.get(i);
				n.evaluate(cx, this);
			}
		}

		if (node.statements != null)
		{
			node.statements.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, InterfaceDefinitionNode node)
	{
		if (node.attrs != null)
		{
			node.attrs.evaluate(cx, this);
		}
		if (node.name != null)
		{
			node.name.evaluate(cx, this);
		}
		if (node.interfaces != null)
		{
			node.interfaces.evaluate(cx, this);
		}
		if (node.statements != null)
		{
			node.statements.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, ClassNameNode node)
	{
		if (node.pkgname != null)
		{
			node.pkgname.evaluate(cx, this);
		}
		if (node.ident != null)
		{
			node.ident.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, InheritanceNode node)
	{
		if (node.baseclass != null)
		{
			node.baseclass.evaluate(cx, this);
		}
		if (node.interfaces != null)
		{
			node.interfaces.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, NamespaceDefinitionNode node)
	{
		if (node.attrs != null)
		{
			node.attrs.evaluate(cx, this);
		}
		if (node.name != null)
		{
			node.name.evaluate(cx, this);
		}
		if (node.value != null)
		{
			node.value.evaluate(cx, this);
		}
		return null;
	}
    
    public Value evaluate(Context cx, ConfigNamespaceDefinitionNode node)
    {
        return null;
    }

	public Value evaluate(Context cx, PackageDefinitionNode node)
	{
		return null;
	}

	public Value evaluate(Context cx, PackageIdentifiersNode node)
	{
		// for (IdentifierNode n : node.list)
		for (int i = 0, size = node.list.size(); i < size; i++)
		{
			IdentifierNode n = node.list.get(i);
			n.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, PackageNameNode node)
	{
		if (node.id != null)
		{
			node.id.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context unused_cx, ProgramNode node)
	{
		Context cx = node.cx;

		if (node.pkgdefs != null)
		{
			// for (PackageDefinitionNode n : node.pkgdefs)
			for (int i = 0, size = node.pkgdefs.size(); i < size; i++)
			{
				PackageDefinitionNode n = node.pkgdefs.get(i);
				n.evaluate(cx, this);
			}
		}

		if (node.statements != null)
		{
			node.statements.evaluate(cx, this);
		}

		if (node.fexprs != null)
		{
			// for (FunctionCommonNode n : node.fexprs)
			for (int i = 0, size = node.fexprs.size(); i < size; i++)
			{
				FunctionCommonNode n = node.fexprs.get(i);
				n.evaluate(cx, this);
			}
		}

		if (node.clsdefs != null)
		{
			// for (FunctionCommonNode n : node.clsdefs)
			for (int i = 0, size = node.clsdefs.size(); i < size; i++)
			{
				ClassDefinitionNode n = node.clsdefs.get(i);
				n.evaluate(cx, this);
			}
		}

		return null;
	}

	public Value evaluate(Context cx, ErrorNode node)
	{
		return null;
	}

	public Value evaluate(Context cx, ToObjectNode node)
	{
		return null;
	}

	public Value evaluate(Context cx, LoadRegisterNode node)
	{
		return null;
	}

	public Value evaluate(Context cx, StoreRegisterNode node)
	{
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, BoxNode node)
	{
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, CoerceNode node)
	{
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, PragmaNode node)
	{
		if (node.list != null)
		{
			node.list.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, PragmaExpressionNode node)
	{
		if (node.identifier != null)
		{
			node.identifier.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, ParameterListNode node)
	{
		for (int i = 0, size = node.items.size(); i < size; i++)
		{
			// ParameterNode param = node.items.get(i);
			ParameterNode param = node.items.get(i);
			if (param != null)
			{
				param.evaluate(cx, this);
			}
		}
		return null;
	}

	public Value evaluate(Context cx, MetaDataNode node)
	{
		if (node.data != null)
		{
			MetaDataEvaluator mde = new MetaDataEvaluator();
			node.evaluate(cx, mde);
		}

		return null;
	}

	public Value evaluate(Context context, DefaultXMLNamespaceNode defaultXMLNamespaceNode)
	{
		return null;
	}

    public Value evaluate(Context cx, BinaryProgramNode node)
    {
        return evaluate(cx, (ProgramNode)node);
    }

	public Value evaluate(Context cx, DocCommentNode node)
	{
		return null;
	}

	public Value evaluate(Context cx, ImportNode node)
	{
		return null;
	}

	public Value evaluate(Context cx, RegisterNode node)
	{
		return null;
	}

	public Value evaluate(Context cx, HasNextNode node)
	{
		return null;
	}
	
    public Value evaluate(Context cx, TypeExpressionNode node)
    {
        return node.expr.evaluate(cx, this);
    }
    
    public Value evaluate(Context cx, ApplyTypeExprNode node)
    {
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        
        if (node.typeArgs != null)
        {
            node.typeArgs.evaluate(cx, this);
        }
        
        return null;
    }
       
    public Value evaluate(Context cx, UseNumericNode node)
    {
    	return null;
    }

    public Value evaluate(Context cx, UsePrecisionNode node)
    {
    	return null;
    }
    
    public Value evaluate(Context cx, UseRoundingNode node)
    {
    	return null;
    }
}
