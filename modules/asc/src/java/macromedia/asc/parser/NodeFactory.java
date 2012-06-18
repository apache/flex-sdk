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

import macromedia.asc.util.*;
import macromedia.asc.semantics.*;
import macromedia.asc.embedding.ErrorConstants;

import java.util.*;

import static macromedia.asc.parser.Tokens.*;
import static macromedia.asc.embedding.avmplus.Features.*;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.*;

/**
 * NodeFactory.h
 *
 * Creates parse tree nodes. Keeps all created nodes in a vector so that
 * they can be deleted when the compiler is done with them.
 *
 * @author Jeff Dyer
 */
public final class NodeFactory implements ErrorConstants
{
	// cx is the compiler context used
	// to store instance global data.
	// This reference provides the NF
	// with access to that data.
	private Context cx;

	// roots is a vector of references
	// to all the nodes allocated since
	// the last call to clear().
    // [ed] Java is garbage collected
    
	//private ObjectList<Node> roots;

	// compound_names is the set of all
	// dot expressions that are to be
	// treated as a single name.
	public Set<String> compound_names;

	public boolean has_arguments;
    public boolean has_rest;
    public boolean has_unnamed_package;
    public boolean has_dxns;

    public PackageDefinitionNode current_package;
    public StatementListNode use_stmts;
    public DefaultXMLNamespaceNode dxns;

	private boolean create_default_doc_comments;
    
	public NodeFactory(Context cx)
	{
        this.cx = cx;
        this.compound_names = new HashSet<String>();
		has_arguments = false;
		has_rest = false;
		has_unnamed_package = false;
		has_dxns = false;
		create_default_doc_comments = false;
		current_package = null;
		use_stmts = null;
		dxns = null;
	}

	public void init(ObjectList<String> names)
	{
		// Initialize the set of compound names.
		compound_names.addAll(names);
	}

	public void createDefaultDocComments(boolean val)
	{
		create_default_doc_comments = val;
	}

	// Nodes
	public ArgumentListNode argumentList(ArgumentListNode list, Node item)
	{
		return argumentList(list, item, -1);
	}

	public ArgumentListNode argumentList(ArgumentListNode list, Node item, int pos)
	{
		if (item != null && item.isIdentifier())
		{
			item = this.memberExpression(null, this.getExpression((IdentifierNode) item), pos);
		}

		ArgumentListNode node;

		if (list != null)
		{
			list.items.add(item);
			node = list;
		}
		else
		{
			node = new ArgumentListNode(item, 0);
			node.setPositionNonterminal((list != null) ? list : item, pos);
		}
		return node;
	}

	public Node assignmentExpression(Node lhs, int op, Node rhs)
	{
		return assignmentExpression(lhs, op, rhs, -1);
	}

	public Node assignmentExpression(Node lhs, int op, Node rhs, int pos)
	{
		Node node;
        boolean is_constinit = false;
       
        if( op == CONST_TOKEN )
        {
            op = ASSIGN_TOKEN;
            is_constinit = true;
        }
        
        int prevOp = op;
        
        if (op != ASSIGN_TOKEN)
		{
            //  Strip parentheses off the lhs expression; these cause
            //  trouble in the operator-assignment variants, when an
            //  obfuscated MemberExpression gets re-used on both sides
            //  of the assignment and its lvalue-centric flags confound
            //  rvalue processing.
            while ( lhs.isList() && ((ListNode)lhs).items.size() == 1)
            {

            	lhs = ((ListNode)lhs).items.get(0);
            }
            
			op = op == MULTASSIGN_TOKEN ? op = MULT_TOKEN :
				op == DIVASSIGN_TOKEN ? op = DIV_TOKEN :
				op == MODULUSASSIGN_TOKEN ? op = MODULUS_TOKEN :
				op == PLUSASSIGN_TOKEN ? op = PLUS_TOKEN :
				op == MINUSASSIGN_TOKEN ? op = MINUS_TOKEN :
				op == LEFTSHIFTASSIGN_TOKEN ? op = LEFTSHIFT_TOKEN :
				op == RIGHTSHIFTASSIGN_TOKEN ? op = RIGHTSHIFT_TOKEN :
				op == UNSIGNEDRIGHTSHIFTASSIGN_TOKEN ? op = UNSIGNEDRIGHTSHIFT_TOKEN :
				op == BITWISEANDASSIGN_TOKEN ? op = BITWISEAND_TOKEN :
				op == BITWISEXORASSIGN_TOKEN ? op = BITWISEXOR_TOKEN :
				op == BITWISEORASSIGN_TOKEN ? op = BITWISEOR_TOKEN :
				op == LOGICALANDASSIGN_TOKEN ? op = LOGICALAND_TOKEN :
				op == LOGICALXORASSIGN_TOKEN ? op = LOGICALXOR_TOKEN :
				op == LOGICALORASSIGN_TOKEN ? op = LOGICALOR_TOKEN : ERROR_TOKEN;

			rhs = this.binaryExpression(op, lhs, rhs);
		}

		if (lhs.isMemberExpression())
		{
			// Put the assignment expression in the slot part of the member expr.
			MemberExpressionNode member = (MemberExpressionNode) lhs;
			if (member.selector.isGetExpression())
			{
				GetExpressionNode get;
				get = (GetExpressionNode) member.selector;
				if (member.isIndexedMemberExpression())
				{
					node = this.indexedMemberExpression(member.base, this.setExpression(get, this.argumentList(null, rhs),is_constinit));
				}
				else
				{
//                    if( !get.ident )
//                    {
//                        throw "internal error";
//                    }
					node = this.memberExpression(member.base, this.setExpression(get, this.argumentList(null, rhs), is_constinit, rhs.pos()));
				}
			}
			else
			{
				node = this.error(pos,kError_AssignmentTargetNotRefVal); 
			}
		}
		else
		{
			node = this.memberExpression(null, this.setExpression(lhs, this.argumentList(null, rhs),is_constinit));
		}
		// required by flash pro
		if (cx.scriptAssistParsing){
			MemberExpressionNode exprNode = (MemberExpressionNode)node;
			if (exprNode != null && (prevOp != op))
				exprNode.setOrigToken(prevOp);
		}
		node.setPositionNonterminal(lhs, pos);
		return node;
	}

	public AttributeListNode attributeList(Node item, AttributeListNode list)
	{
		return attributeList(item, list, -1);
	}

	public AttributeListNode attributeList(Node item, AttributeListNode list, int pos)
	{
		AttributeListNode node;
		if (list != null)
		{
			list.items.add(item);
			node = list;
		}
		else
		{
			node = new AttributeListNode(item, item.pos());
			node.setPositionNonterminal(item, pos);
		}
		return node;
	}

	public BinaryExpressionNode binaryExpression(int op, Node lhs, Node rhs)
	{
		return binaryExpression(op, lhs, rhs, -1);
	}

	public BinaryExpressionNode binaryExpression(int op, Node lhs, Node rhs, int pos)
	{
        BinaryExpressionNode node = new BinaryExpressionNode(op, lhs, rhs);
        node.setPositionNonterminal(lhs, pos);
        return node;
	}

	public BlockNode block(AttributeListNode attributes, StatementListNode statements)
	{
		return block(attributes, statements, -1);
	}

	public BlockNode block(AttributeListNode attributes, StatementListNode statements, int pos)
	{
		BlockNode node = new BlockNode(attributes, statements);
		node.setPositionNonterminal(attributes, pos);
		return node;
	}

	public BreakStatementNode breakStatement(IdentifierNode id)
	{
		return breakStatement(id, -1);
	}

	public BreakStatementNode breakStatement(IdentifierNode id, int pos)
	{
		BreakStatementNode node = new BreakStatementNode(id);
		node.setPositionTerminal(pos);
		return node;
	}

	public Node callExpression(Node expr, ArgumentListNode args)
	{
		return callExpression(expr, args, -1);
	}

	public Node callExpression(Node expr, ArgumentListNode args, int pos)
	{
		// if the omitTrace flag is on, don't generate trace statements
		if(ContextStatics.omitTrace && expr != null && expr instanceof MemberExpressionNode) {
			MemberExpressionNode men = (MemberExpressionNode)expr;
			if(men.base == null && men.selector != null &&
					men.selector instanceof GetExpressionNode) {
				GetExpressionNode gen = (GetExpressionNode)men.selector;
				if(gen.expr != null && gen.expr instanceof IdentifierNode) {
					IdentifierNode iden = (IdentifierNode)gen.expr;
					if(iden.name != null && iden.name == "trace") {
						return emptyStatement();
					}
				}
			}
		}

		Node node;

		// If it is a member expression, then extract the expression inside the selector
		// and place it in the new call expression.

		if (expr != null && expr.isMemberExpression())
		{
			// Put the call expression in the slot of the member expr.
			// ISSUE: generalize this code for converting one selector to another.

			CallExpressionNode call;
			MemberExpressionNode memb = (MemberExpressionNode) expr;
			GetExpressionNode get = (memb.selector instanceof GetExpressionNode) ? (GetExpressionNode) memb.selector : null;
			if (get != null)
			{
				call = new CallExpressionNode(get.expr, args);
                call.setMode(get.getMode());
                call.is_package = get.is_package;
                call.setPositionNonterminal(expr, pos);
				memb.selector = call;
				node = memb;
			}
			else
			{
				call = new CallExpressionNode(expr, args);
				call.setRValue(true);
				call.setPositionNonterminal(expr, pos);
				node = call;
			}
		}
		else
		{
			CallExpressionNode call;
			call = new CallExpressionNode(expr, args);
			call.setRValue(true);
			call.setPositionNonterminal(expr, pos);
			node = call;
		}

		if (SPECIAL_FUNCTION_SYNTAX)
		{
			// C: SPECIAL_FUNCTION_SYNTAX is false...
			/*
			Evaluator e = new SpecialFunctionSyntaxChecker();
			node.evaluate(cx, e);
			*/
		}

		return node;
	}

	public CaseLabelNode caseLabel(Node label)
	{
		return caseLabel(label, -1);
	}

	public CaseLabelNode caseLabel(Node label, int pos)
	{
		CaseLabelNode node = new CaseLabelNode(label);
		node.setPositionTerminal(pos);
		// Because default has no label
		return node;
	}

	public CatchClauseNode catchClause(Node parameter, StatementListNode block)
	{
		return catchClause(parameter, block, -1);
	}

	public CatchClauseNode catchClause(Node parameter, StatementListNode block, int pos)
	{
		CatchClauseNode node = new CatchClauseNode(parameter, block);
		node.setPositionNonterminal(parameter, pos);
		return node;
	}
	
    private ObjectList<ObjectList<ClassDefinitionNode>> clsdefs_sets = new ObjectList<ObjectList<ClassDefinitionNode>>();
    private boolean needs_prototype_ns;
    public void StartClassDefs()
	{
        clsdefs_sets.add(new ObjectList<ClassDefinitionNode>());
        needs_prototype_ns = true;
    }

    public void FinishClassDefs()
	{
        clsdefs_sets.removeLast();
    }

    public boolean classNeedsPrototypeNamespace() {
        /* for nested classes, when we support them
        boolean temp =  clsdefs_sets.last().last().needs_prototype_ns;
        clsdefs_sets.last().last().needs_prototype_ns = false;
        */
        boolean temp = needs_prototype_ns;
        needs_prototype_ns = false;
        return temp;
    }
	
    public ClassDefinitionNode classDefinition(Context cx, AttributeListNode attrs, IdentifierNode identifier, InheritanceNode inheritance, StatementListNode block)
	{
		return classDefinition(cx, attrs, identifier, inheritance, block, false);
	}

    public ClassDefinitionNode classDefinition(Context cx, AttributeListNode attrs, IdentifierNode identifier, InheritanceNode inheritance, StatementListNode block, boolean non_nullable)
	{
		return classDefinition(cx, attrs, identifier, inheritance, block, non_nullable, -1);
	}

	public ClassDefinitionNode classDefinition(Context cx, AttributeListNode attrs, IdentifierNode identifier, InheritanceNode inheritance, StatementListNode block, boolean non_nullable, int pos)
	{
        // make the identifier qualified with the attributes so it can be turned into a qualified identifier during flow analysis
        identifier = qualifiedIdentifier(attrs, identifier.name, identifier.pos());
		Node baseclass = (inheritance != null) ? inheritance.baseclass : null;
		ListNode interfaces = (inheritance != null) ? inheritance.interfaces : null;
		ClassDefinitionNode node = new ClassDefinitionNode(cx, current_package, attrs, identifier, baseclass, interfaces, block);
        
        node.is_default_nullable = !non_nullable;

		node.setPositionNonterminal(identifier, pos);
		
		node.clsdefs = clsdefs_sets.last();
		clsdefs_sets.removeLast();
		if( clsdefs_sets.size() > 0 )
		{
		    clsdefs_sets.last().add(node);
		}
		return node;
	}

    public BinaryClassDefNode binaryClassDefinition(Context cx, AttributeListNode attrs, IdentifierNode identifier, InheritanceNode inheritance, StatementListNode block)
    {
        return binaryClassDefinition(cx, attrs, identifier, inheritance, block, -1);
    }

    public BinaryClassDefNode binaryClassDefinition(Context cx, AttributeListNode attrs, IdentifierNode identifier, InheritanceNode inheritance, StatementListNode block, int pos)
    {
        // make the identifier qualified with the attributes so it can be turned into a qualified identifier during flow analysis
        identifier = qualifiedIdentifier(attrs, identifier.name, identifier.pos());
        Node baseclass = (inheritance != null) ? inheritance.baseclass : null;
        ListNode interfaces = (inheritance != null) ? inheritance.interfaces : null;
        BinaryClassDefNode node = new BinaryClassDefNode(cx, current_package, attrs, identifier, baseclass, interfaces, block);
        node.setPositionNonterminal(identifier, pos);

        return node;
    }

	public InterfaceDefinitionNode interfaceDefinition(Context cx, AttributeListNode attrs, IdentifierNode identifier, ListNode interfaces, StatementListNode block)
	{
		return interfaceDefinition(cx, attrs, identifier, interfaces, block, -1);
	}

	public InterfaceDefinitionNode interfaceDefinition(Context cx, AttributeListNode attrs, IdentifierNode identifier, ListNode interfaces, StatementListNode block, int pos)
	{
        // make the identifier qualified with the attributes so it can be turned into a qualified identifier during flow analysis
        identifier = qualifiedIdentifier(attrs, identifier.name, identifier.pos());
        InterfaceDefinitionNode node = new InterfaceDefinitionNode(cx, current_package, attrs, identifier, interfaces, block);
		node.setPositionNonterminal(identifier, pos);

        node.clsdefs = new ObjectList<ClassDefinitionNode>();
        if( clsdefs_sets.size() > 0 )
        {
            clsdefs_sets.last().add(node);
        }

		return node;
	}
	
	public BinaryInterfaceDefinitionNode binaryInterfaceDefinition(Context cx, AttributeListNode attrs, IdentifierNode identifier, ListNode interfaces, StatementListNode block)
	{
		return binaryInterfaceDefinition(cx, attrs, identifier, interfaces, block, -1);
	}

	public BinaryInterfaceDefinitionNode binaryInterfaceDefinition(Context cx, AttributeListNode attrs, IdentifierNode identifier, ListNode interfaces, StatementListNode block, int pos)
	{
        // make the identifier qualified with the attributes so it can be turned into a qualified identifier during flow analysis
        identifier = qualifiedIdentifier(attrs, identifier.name, identifier.pos());
        BinaryInterfaceDefinitionNode node = new BinaryInterfaceDefinitionNode(cx, current_package, attrs, identifier, interfaces, block);
		node.setPositionNonterminal(identifier, pos);

		return node;
	}

	public ClassNameNode className(PackageNameNode pkgname, IdentifierNode ident)
	{
		return className(pkgname, ident, -1);
	}

	public ClassNameNode className(PackageNameNode pkgname, IdentifierNode ident, int pos)
	{
		ClassNameNode node = new ClassNameNode(pkgname, ident, ident.pos());
		node.setPositionNonterminal(ident, pos);
		return node;
	}

	public ConditionalExpressionNode conditionalExpression(Node cond, Node thenexpr, Node elseexpr)
	{
		return conditionalExpression(cond, thenexpr, elseexpr, -1);
	}


	public ConditionalExpressionNode conditionalExpression(Node cond, Node thenexpr, Node elseexpr, int pos)
	{
		ConditionalExpressionNode node = new ConditionalExpressionNode(cond, thenexpr, elseexpr);
		node.setPositionNonterminal(cond, pos);
		return node;
	}

	public ContinueStatementNode continueStatement(IdentifierNode id)
	{
		return continueStatement(id, -1);
	}

	public ContinueStatementNode continueStatement(IdentifierNode id, int pos)
	{
		ContinueStatementNode node = new ContinueStatementNode(id);
		node.setPositionTerminal(pos);
		return node;
	}

	public DoStatementNode doStatement(Node stmt, Node expr)
	{
		return doStatement(stmt, expr, -1);
	}

	public DoStatementNode doStatement(Node stmt, Node expr, int pos)
	{
        if( stmt != null )
        {
            StatementListNode stmtlist = (stmt instanceof StatementListNode)?(StatementListNode) stmt : null;
            if( stmtlist == null )
            {
                stmt = stmtlist = this.statementList(null,stmt);
            }
        }
        DoStatementNode node = new DoStatementNode(stmt, expr);
		node.setPositionNonterminal(stmt, pos);
		return node;
	}

   public EmptyElementNode emptyElement()
	{
		return emptyElement(-1);
	}

	public EmptyElementNode emptyElement(int pos)
	{
		EmptyElementNode node = new EmptyElementNode();
		node.setPositionTerminal(pos);
		return node;
	}

	public EmptyStatementNode emptyStatement()
	{
		return EmptyStatementNode.getInstance();
	}

	public ExpressionStatementNode expressionStatement(Node expr)
	{
		return expressionStatement(expr, -1);
	}

	public ExpressionStatementNode expressionStatement(Node expr, int pos)
	{
		ExpressionStatementNode node = new ExpressionStatementNode(expr);
		node.setPositionNonterminal(expr, pos);
		return node;
	}

	public Node forInStatement(boolean is_each, Node expr1, Node expr2, Node stmt)
	{
		return forInStatement(is_each, expr1, expr2, stmt, -1);
	}

    public Node forInStatement( boolean is_each, Node expr1, Node expr2, Node stmt, int pos )
    {
    	if (!cx.scriptAssistParsing){
	        if( stmt != null && !stmt.isStatementList() )
	        {   
	            stmt = statementList(null,stmt);
	        }
	
	        VariableDefinitionNode vard = null;
	        if( expr1.isDefinition() )
	        {   
	            vard = (VariableDefinitionNode) expr1;
	            // extract the variable binding
	            VariableBindingNode varb = (VariableBindingNode) vard.list.items.back();
	            TypedIdentifierNode var  = varb.variable;
	            expr1 = var.identifier;
	        }
	        else
	        {
	            ListNode list = (ListNode) expr1;
	            expr1 = list.items.back();
	        }
	
	        RegisterNode ndx_reg = register(pos);
	        RegisterNode obj_reg = register(pos);
	            
	        Node init;
	        Node test;
	
	        // Coerce the object to type *, since it will be mutated by OP_hasnext
	        Node untypedExpr = coerce(expr2,null,cx.noType().getDefaultTypeInfo(),true,pos);
	        	
	        init = list(list(null,
	            storeRegister(ndx_reg,literalNumber("0",pos),cx.intType(),pos)),
	            storeRegister(obj_reg,untypedExpr,cx.noType(),pos));        
	
	        test = hasNext(obj_reg,ndx_reg,pos);
	            
	        Node incr;
	            
	        if( is_each )
	        {
	            incr = expressionStatement(assignmentExpression(
	            expr1,ASSIGN_TOKEN,memberExpression(
	            loadRegister(obj_reg,cx.noType(),pos),
	            invoke("[[NextValue]]",argumentList(null,
	            loadRegister(ndx_reg,cx.intType(),pos)),pos))));
	        }
	        else
	        {
	            incr = expressionStatement(assignmentExpression(
	            expr1,ASSIGN_TOKEN,memberExpression(
	            loadRegister(obj_reg,cx.noType(),pos),
	            invoke("[[NextName]]",argumentList(null,loadRegister(ndx_reg,cx.intType(),pos)),expr1.pos()))));
	        }
	            
	        stmt = statementList(statementList(null,incr),stmt);
	        Node node = forStatement(init,test,null,stmt,true/*is_forin*/,(pos == -1) ? expr1.pos() : pos);
	            
	        if( vard != null )
	        {
	            StatementListNode stmtlist = this.statementList(this.statementList(null,vard),node);
	            if ( stmtlist != null )
	            	stmtlist.is_loop = true;
	            node = stmtlist;
	        }
	
	        return node;
    	}
    	else {
			if (stmt != null && !stmt.isStatementList())
			{
				stmt = this.statementList(null, stmt);
			}
			VariableDefinitionNode vard = null;
			if (expr1 != null && expr1.isDefinition())
			{
				vard = (VariableDefinitionNode) expr1;
				expr1 = null;
			}
			if (expr1 != null)
				pos = expr1.pos();
			else if (expr2 != null)
				pos = expr2.pos();
			Node node = new ForStatementNode(expr1, expr2, null, stmt, true);//tbd is_each

			node.setPositionNonterminal(expr1, pos);
			
	        if( vard != null )
	        {
	            StatementListNode stmtlist = this.statementList(this.statementList(null,vard),node);
	            node = stmtlist;
	            stmtlist.is_loop = true;
	        }
	        else
	        {
	            StatementListNode stmtlist = (stmt instanceof StatementListNode)?(StatementListNode) stmt : null;
	            if( stmtlist != null )
	            {
	                stmtlist.is_loop = true;
	            }
	        }

			return node;
		}
    }

	public Node forStatement(Node expr1, Node expr2, Node expr3, Node stmt)
	{
		return forStatement(expr1, expr2, expr3, stmt, false, -1);
	}

	public Node forStatement(Node expr1, Node expr2, Node expr3, Node stmt, boolean is_forin, int pos)
	{
		if (stmt != null && !stmt.isStatementList())
		{
			stmt = this.statementList(null, stmt);
		}
		VariableDefinitionNode vard = null;
		if (expr1 != null && expr1.isDefinition())
		{
			vard = (VariableDefinitionNode) expr1;
			expr1 = null;
		}

		Node node = new ForStatementNode(expr1, expr2, expr3, stmt, is_forin);
		node.setPositionNonterminal(expr1, pos);

        if( vard != null )
        {
            StatementListNode stmtlist = this.statementList(this.statementList(null,vard),node);
            node = stmtlist;
            stmtlist.is_loop = true;
        }
        else
        {
            StatementListNode stmtlist = (stmt instanceof StatementListNode)?(StatementListNode) stmt : null;
            if( stmtlist != null )
            {
                stmtlist.is_loop = true;
            }
        }

		return node;
	}

	private Map<String, Integer> fun_names = new TreeMap<String, Integer>();
	public Map<String, PackageDefinitionNode> pkg_names = new TreeMap<String, PackageDefinitionNode>();
	public ObjectList<PackageDefinitionNode> pkg_defs = new ObjectList<PackageDefinitionNode>();

	public FunctionDefinitionNode functionDefinition(Context cx, AttributeListNode attrs, FunctionNameNode name, FunctionCommonNode fexpr)
	{
		return functionDefinition(cx, attrs, name, fexpr, -1);
	}

	public FunctionDefinitionNode functionDefinition(Context cx, AttributeListNode attrs, FunctionNameNode name, FunctionCommonNode fexpr, int pos)
	{
	    // fix up the name with the namespace attribute
		name.identifier = qualifiedIdentifier(attrs, name.identifier.name, name.identifier.pos());
		fexpr.identifier = name.identifier;
		fexpr.setFunctionDefinition(true);
		FunctionDefinitionNode node = new FunctionDefinitionNode(cx, current_package, attrs, name, fexpr);
		node.setPositionNonterminal(name, pos);
		return node;
	}

    public BinaryFunctionDefinitionNode binaryFunctionDefinition(Context cx, AttributeListNode attrs, FunctionNameNode name, FunctionCommonNode fexpr, int pos)
    {
        // fix up the name with the namespace attribute
        name.identifier = qualifiedIdentifier(attrs, name.identifier.name, name.identifier.pos());
        fexpr.identifier = name.identifier;
        fexpr.setFunctionDefinition(true);
        BinaryFunctionDefinitionNode node = new BinaryFunctionDefinitionNode(cx, current_package, attrs, name, fexpr);
        node.setPositionNonterminal(name, pos);
        return node;
    }

	public FunctionCommonNode functionCommon(Context cx, IdentifierNode identifier, FunctionSignatureNode signature, StatementListNode body)
	{
		return functionCommon(cx, identifier, signature, body, -1);
	}

	public FunctionCommonNode functionCommon(Context cx, IdentifierNode identifier, FunctionSignatureNode signature, StatementListNode body, int pos)
	{
		if (identifier == null)
		{
			if (cx.scriptAssistParsing)
				identifier = this.identifier("",pos);
			else
				identifier = this.identifier("anonymous",pos);
		}
		StringBuilder internal_name = new StringBuilder(identifier.name.length() + 6);

		if (!fun_names.containsKey(identifier.name))
		{
			fun_names.put(identifier.name, 0);
		}

		int num = fun_names.get(identifier.name);

		if (USE_DEFINED_NAME_AS_INTERNAL_NAME)
		{
			// if( fun_names[identifier.name]==0 )
			if (num == 0)
			{
				internal_name.append(identifier.name);
				num++;
				fun_names.put(identifier.name, num);
			}
			else
			{
				internal_name.append(identifier.name);
				internal_name.append('$').append(num);
				num++;
				fun_names.put(identifier.name, num);
			}
		}
		else
		{
			/*
	        internal_name  = identifier.name;
	        internal_name += "$";
			char buf[9];
			sprintf(buf,"%d",fun_names[identifier.name]++);
			internal_name += buf;
			*/
			internal_name.append(identifier.name);
			internal_name.append('$').append(num);
			num++;
			fun_names.put(identifier.name, num);
		}

		// ISSUE: refactor to make use of internal_name and identifier clearer.
	        boolean userBody = false;
		if (cx.input != null)      //  Input is null if this is from a BinaryFunctionDefinition imported from .abc

		{
			ReturnStatementNode rtn;
			if (cx.scriptAssistParsing){
				rtn = this.returnStatement(this.unaryExpression(VOID_TOKEN, this.literalNumber("0", 0), 0), 0);
				rtn.setIsSynthetic();       // So that we can identify this later and avoid creating bogus ! type errors
			} else {
				rtn = this.returnStatement(null, 0);
				rtn.setIsSynthetic();       // So that we can identify this later and avoid creating bogus ! type errors
				rtn.setPositionTerminal(cx.input.positionOfMark()); // Set the position of the default return to be the closing brace.	
			}
			
			if (body == null)
			{
				body = this.statementList(null, rtn);
		        	userBody = false;
			}
			else
			{
				body.items.push_back(rtn);
		        	userBody = true;
			}
		}

		FunctionCommonNode  fexpr = new FunctionCommonNode(cx, null/*use_stmts*/, internal_name.toString(), identifier, signature, body, userBody);

		fexpr.needsArguments = has_rest ? METHOD_Needrest : (has_arguments ? METHOD_Arguments : 0);  // order is important, rest overrides arguments

		fexpr.setPositionNonterminal(signature, pos);
		FunctionCommonNode node = fexpr;

		return node;
	}

	public FunctionNameNode functionName(int kind, IdentifierNode name)
	{
		return functionName(kind, name, -1);
	}

	public FunctionNameNode functionName(int kind, IdentifierNode name, int pos)
	{
		FunctionNameNode node = new FunctionNameNode(kind, name);
		node.setPositionNonterminal(name, pos);
		return node;
	}

	public FunctionSignatureNode functionSignature(ParameterListNode parameter, Node result)
	{
		return functionSignature(parameter, result, -1);
	}

	public FunctionSignatureNode functionSignature(ParameterListNode parameter, Node result, int pos)
	{
		FunctionSignatureNode node = new FunctionSignatureNode(parameter, result);
		node.setPositionTerminal(pos);
		return node;
	}

	public FunctionSignatureNode constructorSignature(ParameterListNode parameter, ListNode initializers, int pos)
	{
		FunctionSignatureNode node = new FunctionSignatureNode(parameter, initializers);
		node.setPositionTerminal(pos);
		return node;
	}
	
	public GetExpressionNode getExpression(Node expr)
	{
		return getExpression(expr, -1);
	}

	public GetExpressionNode getExpression(Node expr, int pos)
	{
		GetExpressionNode node = new GetExpressionNode(expr);
		node.setPositionNonterminal(expr, pos);
		return node;
	}

	public GetExpressionNode getExpression(IdentifierNode ident)
	{
		return getExpression(ident, -1);
	}

	public GetExpressionNode getExpression(IdentifierNode ident, int pos)
	{
		GetExpressionNode node = new GetExpressionNode(ident);
		node.setPositionNonterminal(ident, pos);
		return node;
	}

	public IdentifierNode identifier(String name)
	{
		return identifier(name, -1);
	}

	public IdentifierNode identifier(String name, boolean intern)
	{
		return identifier(name, intern, -1);
	}

	public IdentifierNode identifier(String name, boolean intern, int pos)
	{
		IdentifierNode node = new IdentifierNode(name, intern, pos);

		if (ARGUMENTS == node.name)
		{
			this.has_arguments = true;
		}

		return node;
	}

	private static final String ARGUMENTS = "arguments".intern();

	public IdentifierNode identifier(String name, int pos)
	{
		IdentifierNode node = new IdentifierNode(name, pos);
		node.setPositionTerminal(pos);

		if (ARGUMENTS == node.name)
		{
			this.has_arguments = true;
		}

		return node;
	}

	public IdentifierNode identifier(IdentifierNode ident, int pos)
	{
		IdentifierNode node;
		QualifiedIdentifierNode qualid = (ident instanceof QualifiedIdentifierNode) ? (QualifiedIdentifierNode) ident : null;
		if (qualid != null)
		{
			node = this.qualifiedIdentifier(qualid.qualifier, qualid.name, pos);
		}
		else
		{
			node = this.identifier(ident.name,pos);
		}
		node.setAttr(ident.isAttr());
		return node;
	}

    public Node applyTypeExpr(Node expr, ListNode typeArgs, int pos)
    {
        Node node;
        
        assert(expr != null);

        // If it is a member expression, then extract the expression inside the selector
        // and place it in the new call expression.

        if (expr.isMemberExpression())
        {
            // Put the apply expression in the slot of the member expr.
            // ISSUE: generalize this code for converting one selector to another.

            ApplyTypeExprNode apply;
            MemberExpressionNode memb = (MemberExpressionNode) expr;
            GetExpressionNode get = (memb.selector instanceof GetExpressionNode) ? (GetExpressionNode) memb.selector : null;
            if (get != null)
            {
                apply = new ApplyTypeExprNode(get.expr, typeArgs);
                apply.setMode(get.getMode());
                apply.is_package = get.is_package;
                apply.setPositionNonterminal(expr, pos);
                memb.selector = apply;
                node = memb;
            }
            else
            {
                apply = new ApplyTypeExprNode(expr, typeArgs);
                apply.setRValue(true);
                apply.setPositionNonterminal(expr, pos);
                node = apply;
            }
        }
        else if ( expr.isIdentifier() )
        {
        	//  A Vector literal.
            ApplyTypeExprNode apply;
            apply = new ApplyTypeExprNode(expr, typeArgs);
            apply.setRValue(true);
            apply.setPositionNonterminal(expr, pos);
            node = apply;
        }
        else
        {
        	node = this.error(pos, kError_Parser_keywordInsteadOfTypeExpr, expr.toString());
        }

        return node;
    }

	public Node ifStatement(ListNode test, Node tblock, Node eblock)
	{
		return ifStatement(test, tblock, eblock, -1);
	}

	public Node ifStatement(ListNode test, Node tblock, Node eblock, int pos)
	{
		Node node = null;

		if (COMPILE_TIME_IF) // special conditional compile symbol
		{
			// C: COMPILE_TIME_IF is false...
			/*
			String id;
			if (test.item.isMemberExpression())
			{
				MemberExpressionNode memb = (MemberExpressionNode) test.item;
				if (memb.selector.isGetExpression())
				{
					GetExpressionNode getx = (GetExpressionNode) memb.selector;
					id = (getx.ident != null) ? getx.ident.name : "";
					if (id == COMPILE_TIME_IF_KEYWORD)
					{
						node = tblock;
					}
				}
			}
			*/
		}

		// If node is not set then finish the if statement.

        if( tblock != null )
        {
            StatementListNode stmtlist = (tblock instanceof StatementListNode)?(StatementListNode) tblock : null;
            if( stmtlist == null )
            {
                tblock = stmtlist = this.statementList(null,tblock);
            }
        }

        if( eblock != null )
        {
            StatementListNode stmtlist = (eblock instanceof StatementListNode)?(StatementListNode) eblock : null;
            if( stmtlist == null )
            {
                eblock = stmtlist = this.statementList(null,eblock);
            }
        }

		if (node == null)
		{
			node = new IfStatementNode(test, tblock, eblock);
			node.setPositionNonterminal(test, pos);
		}
		return node;
	}

	public ImportDirectiveNode importDirective(AttributeListNode attrs, PackageNameNode name, PackageNameNode init, Context cx)
	{
		return importDirective(attrs, name, init, -1, cx);
	}

	public ImportDirectiveNode importDirective(AttributeListNode attrs, PackageNameNode name, PackageNameNode init, int pos, Context cx)
	{
		PackageDefinitionNode pkg_node = null;
		String id = name.id.toIdentifierString();

		if (pkg_names.containsKey(id))
		{
			pkg_node = pkg_names.get(id);
		} 

		ImportDirectiveNode node = new ImportDirectiveNode(current_package, attrs, name, pkg_node, cx);

		node.setPositionNonterminal(name, pos);
		return node;
	}

	public IncludeDirectiveNode includeDirective(Context cx, LiteralStringNode filespec, ProgramNode program)
	{
		return includeDirective(cx, filespec, program, -1);
	}

	public IncludeDirectiveNode includeDirective(Context cx, LiteralStringNode filespec, ProgramNode program, int pos)
	{
		IncludeDirectiveNode node = new IncludeDirectiveNode(cx, filespec, program);
		node.setPositionNonterminal(filespec, pos);
		return node;
	}

	public ImportNode Import( Context cx, LiteralStringNode filespec, ProgramNode program )
	{
		return Import(cx,filespec,program,-1);
	}
	public ImportNode Import( Context cx, LiteralStringNode filespec, ProgramNode program, int pos)
	{
		ImportNode node = new ImportNode(filespec,program);
		node.setPositionNonterminal(filespec,pos);
		return node;
	}

	public IncrementNode increment(int op, Node expr, boolean isPostfix)
	{
		return increment(op, expr, isPostfix, -1);
	}

	public IncrementNode increment(int op, Node expr, boolean isPostfix, int pos)
	{
		IncrementNode node = new IncrementNode(op, expr, isPostfix);
		node.setPositionNonterminal(expr, pos);
		return node;
	}

	public InheritanceNode inheritance(Node baseclass, ListNode interfaces)
	{
		return inheritance(baseclass, interfaces, -1);
	}

	public InheritanceNode inheritance(Node baseclass, ListNode interfaces, int pos)
	{
		InheritanceNode node = new InheritanceNode(baseclass, interfaces);
		node.setPositionNonterminal(baseclass, pos);
		return node;
	}

	public LabeledStatementNode labeledStatement(Node label, Node statement)
	{
		return labeledStatement(label, statement, -1);
	}

	public LabeledStatementNode labeledStatement(Node label, Node statement, int pos)
	{
        LabeledStatementNode node;

        boolean stmt_is_loop = statement instanceof ForStatementNode ||
                               statement instanceof WhileStatementNode ||
                               statement instanceof DoStatementNode ||
                               (statement instanceof StatementListNode && ((StatementListNode)statement).is_loop);

        if(!cx.scriptAssistParsing &&( statement instanceof StatementListNode ))
        {
            node = new LabeledStatementNode(label, stmt_is_loop, ifStatement(list(null,literalBoolean(true)),statement,null));
        }
        else
        {
            node = new LabeledStatementNode(label, stmt_is_loop, statement!=null?statement:this.emptyStatement());
        }
		node.setPositionNonterminal(label, pos);
		return node;
	}

	// List gets consed on nil, added to end otherwise.
	// Always returns list start.
	
	public ListNode list(ListNode list, Node item)
	{
		return list(list, item, -1);
	}

	public ListNode list(ListNode list, Node item, int pos)
	{
		if (item != null && item.isIdentifier())
		{
			item = this.memberExpression(null, this.getExpression((IdentifierNode) item));
		}

		ListNode node;

		if (list != null)
		{
			list.items.add(item);
			node = list;
		}
		else
		{
			node = new ListNode(null, item, 0);
			node.setPositionNonterminal((list != null) ? list : item, pos);
		}
		return node;
	}

	public LiteralArrayNode literalArray(ArgumentListNode elementlist)
	{
		return literalArray(elementlist, -1);
	}

	public LiteralArrayNode literalArray(ArgumentListNode elementlist, int pos)
	{
		LiteralArrayNode node = new LiteralArrayNode(elementlist);
		node.setPositionNonterminal(elementlist, pos);
		return node;
	}

	public LiteralBooleanNode literalBoolean(boolean value)
	{
		return literalBoolean(value, -1);
	}

	public LiteralBooleanNode literalBoolean(boolean value, int pos)
	{
		LiteralBooleanNode node = new LiteralBooleanNode(value);
		node.setPositionTerminal(pos);
		return node;
	}

	public LiteralFieldNode literalField(Node name, Node value)
	{
		return literalField(name, value, -1);
	}

	public LiteralFieldNode literalField(Node name, Node value, int pos)
	{
		LiteralFieldNode node = new LiteralFieldNode(name, value);
		node.setPositionNonterminal(name, pos);
		return node;
	}

	public LiteralNumberNode literalNumber(int i)
	{
		return literalNumber(i, -1);
	}

	public LiteralNumberNode literalNumber(int i, int pos)
	{
		return this.literalNumber("" + i, pos);
	}

	public LiteralNullNode literalNull()
	{
		return literalNull(-1);
	}

	public LiteralNullNode literalNull(int pos)
	{
		LiteralNullNode node = new LiteralNullNode();
		node.setPositionTerminal(pos);
		return node;
	}

	public LiteralNumberNode literalNumber(String value)
	{
		return literalNumber(value, -1);
	}

	public LiteralNumberNode literalNumber(String value, int pos)
	{
		LiteralNumberNode node = new LiteralNumberNode(value);
		node.setPositionTerminal(pos);
		return node;
	}

	public LiteralObjectNode literalObject(ArgumentListNode fieldlist)
	{
		return literalObject(fieldlist, -1);
	}

	public LiteralObjectNode literalObject(ArgumentListNode fieldlist, int pos)
	{
		LiteralObjectNode node = new LiteralObjectNode(fieldlist);
		node.setPositionNonterminal(fieldlist, pos);
		return node;
	}

	public LiteralRegExpNode literalRegExp(String value, int pos)
	{
		LiteralRegExpNode node = new LiteralRegExpNode(value);
		node.setPositionTerminal(pos);
		return node;
	}
	
	public LiteralVectorNode literalVector(Node vector_type, ArgumentListNode initializer_list, int pos)
	{
		LiteralVectorNode node = new LiteralVectorNode(initializer_list, vector_type);
		node.setPositionTerminal(pos);
		return node;
	}
	
    public LiteralXMLNode literalXML( ListNode list, boolean is_xmllist, int pos )
    {
        // LiteralStringNode first = list.items.at(0) instanceof LiteralStringNode ? (LiteralStringNode) list.items.at(0) : null;
        LiteralXMLNode node = new LiteralXMLNode(list,is_xmllist);
        node.setPositionTerminal(pos);
        return node;
    }

	public LiteralStringNode literalString(String value)
	{
		return literalString(value, 0);
	}

	public LiteralStringNode literalString(String value, boolean intern)
	{
		LiteralStringNode node = new LiteralStringNode(value, false, intern);
		return node;
	}

	public LiteralStringNode literalString(String value, int pos)
	{
		LiteralStringNode node = new LiteralStringNode(value);
		node.setPositionTerminal(pos);
		return node;
	}

	public LiteralStringNode literalString(String value, int pos, boolean is_single_quoted)
	{
		LiteralStringNode node = new LiteralStringNode(value, is_single_quoted);
		node.setPositionTerminal(pos);
		return node;
	}

	public MemberExpressionNode indexedMemberExpression(Node base, SelectorNode selector)
	{
		return indexedMemberExpression(base, selector, -1);
	}

	public MemberExpressionNode indexedMemberExpression(Node base, SelectorNode selector, int pos)
	{
		MemberExpressionNode node = memberExpression(base, selector, pos);
		node.selector.setMode(LEFTBRACKET_TOKEN);
		return node;
	}

    public TypeExpressionNode typeExpression(Node expr, boolean nullable, boolean explicit, int pos)
    {
        TypeExpressionNode typeexpr = new TypeExpressionNode(expr, nullable, explicit);
        typeexpr.setPositionNonterminal(expr, pos);
        return typeexpr;

    }

	public MemberExpressionNode memberExpression(Node base, SelectorNode selector)
	{
		return memberExpression(base, selector, -1);
	}

	public MemberExpressionNode memberExpression(Node base, SelectorNode selector, int pos)
	{
		if (TRANSLATE_COMPOUND_NAMES)
		{
			if (base != null && base.isMemberExpression())
			{
				MemberExpressionNode memb = (MemberExpressionNode) base;
				if (memb.selector.isGetExpression() /*&& memb.base == null*/)
				{
					GetExpressionNode getx = (GetExpressionNode) memb.selector;
					// Finish this
					if (selector.isGetExpression() )
					{
						IdentifierNode pname = ((GetExpressionNode) selector).getIdentifier();
						IdentifierNode bname = null;

                        // calculate the dotted base name, walk up the MemberExpressionNodes and add each identifier
                        // as part of a dotted string to get to something that might be a package name (like a.b.c)
                        String base_name = null;
                        while( getx != null )
                        {
                            bname = getx.getIdentifier();
                            if( bname != null )
                            {
                                if( base_name == null )
                                    base_name = bname.name;
                                else
                                    base_name = bname.name + "." + base_name;
                                if( bname instanceof QualifiedIdentifierNode && ((QualifiedIdentifierNode)bname).qualifier instanceof LiteralStringNode )
                                {
                                    base_name = ((LiteralStringNode)((QualifiedIdentifierNode)bname).qualifier).value + "." + base_name;
                                }
                            }
                            if( memb.base != null && memb.base instanceof MemberExpressionNode )
                            {
                                memb = (MemberExpressionNode)memb.base;
                                getx = memb.selector.isGetExpression() ? (GetExpressionNode)memb.selector : null;
                            }
                            else
                            {
                                getx = null;
                            }
                        }
						if( base_name != null && pname != null )
						{
							String compound_name = new StringBuilder(base_name.length() + pname.name.length() + 1).append(base_name).append(".").append(pname.name).toString();
							if( compound_names.contains(compound_name) )
							{
								selector = this.getExpression(this.identifier(compound_name,selector.pos()));
//                                selector.is_package = true;
								base = memb.base;
							}
							else if( compound_names.contains(base_name) )
							{
								LiteralStringNode nsn = literalString(bname.name,memb.pos());
								selector = this.getExpression(qualifiedIdentifier(nsn, pname.name, selector.pos()));
								base = memb.base;
							}
						}
					}
				}
			}
		}

		// If not already done, convert an identifier node that is the base into a member expression.
		// ISSUE: make this code obsolete by turning identifer nodes into member expressions earlier.

		if (base != null && base.isIdentifier())
		{
			base = this.memberExpression(null, this.getExpression((IdentifierNode) base));
		}

		if (base == null)
		{
			selector.setMode(EMPTY_TOKEN);
            IdentifierNode ident = selector.expr instanceof IdentifierNode ? (IdentifierNode) selector.expr : null;
            if( ident != null && compound_names.contains(ident.name) )
            {
                selector.is_package = true;
            }
		}

		MemberExpressionNode node = new MemberExpressionNode(base, selector, 0 /* in.positionOfMark() */);
		node.setPositionNonterminal(selector, pos);
		return node;
	}

	Map<String, Integer> namespace_names = new TreeMap<String, Integer>();

	public NamespaceDefinitionNode namespaceDefinition(AttributeListNode attributes, IdentifierNode identifier, Node value)
	{
		return namespaceDefinition(attributes, identifier, value, -1);
	}

	public NamespaceDefinitionNode namespaceDefinition(AttributeListNode attributes, IdentifierNode identifier, Node value, int pos)
	{
		if (!namespace_names.containsKey(identifier.name))
		{
			namespace_names.put(identifier.name, IntegerPool.getNumber(0));
		}

		{
		}

		// If value is null, then make one from the declared name

		// ISSUE: Every namespace is unique. Two namespaces with the same
		// value in the same .abc file will compare equals. We need to
		// separate the idea of uri and internal name, or we need to somehow
		// combine the two.
/*
		if (value == null)
		{
			String internal_name = identifier.name + "$" + namespace_names.get(identifier.name);
			namespace_names.put(identifier.name, IntegerPool.getNumber(namespace_names.get(identifier.name).intValue() + 1));
			value = this.literalString(internal_name);
		}
*/
		NamespaceDefinitionNode node = new NamespaceDefinitionNode(current_package, attributes, identifier, value);
		node.setPositionNonterminal(identifier, pos);
		return node;
	}

	public NamespaceDefinitionNode configNamespaceDefinition(AttributeListNode attributes, IdentifierNode identifier, int pos)
	{
		NamespaceDefinitionNode node = new ConfigNamespaceDefinitionNode(current_package, attributes, identifier);
		node.setPositionNonterminal(identifier, pos);
		return node;
	}
	
	public Node newExpression(Node expr)
	{
		return newExpression(expr, -1);
	}

	public Node newExpression(Node expr, int pos)
	{
		Node node;

		if (expr.isMemberExpression())
		{
			MemberExpressionNode memb = (MemberExpressionNode) expr;
			CallExpressionNode call;
			if (memb.selector.isCallExpression())
			{
				call = (CallExpressionNode) memb.selector;
				call.is_new = true;
				node = memb;
			}
			else
			{
				assert(false); // throw "internal error";

				// Put the call expression in the slot of the member expr.
				// ISSUE: generalize this code for converting one selector to another.

				GetExpressionNode get = (memb.selector instanceof GetExpressionNode) ? (GetExpressionNode) memb.selector : null;
				if (get == null)
				{
					assert(false); // throw "internal error in CallExpression factory";
				}
				call = new CallExpressionNode(get.expr, null);
//                call.is_lexical   = get.is_lexical;
//                call.is_bracketed = get.is_bracketed;
				call.setMode(get.getMode());
				call.setPositionNonterminal(expr, pos);
				memb.selector = call;
				node = memb;
			}
		}
		else if (expr.isCallExpression())
		{
			CallExpressionNode call;
			call = (CallExpressionNode) expr;
			call.is_new = true;
			node = call;
		}
		else
		{
			assert(false); // throw "internal error";
			CallExpressionNode call;
			call = new CallExpressionNode(expr, null);
			call.is_new = true;
			call.setMode(EMPTY_TOKEN);
			call.setPositionNonterminal(expr, pos);
			node = call;
		}

		return node;
	}

    public PackageDefinitionNode startPackage(Context cx,AttributeListNode attrs, PackageNameNode name)
    {
    	if (cx.scriptAssistParsing)
    		 return startPackage(cx, attrs, name, cx.input.positionOfNext());
    	else
    		return startPackage(cx, attrs, name, -1);
    }

    public PackageDefinitionNode startPackage(Context cx, AttributeListNode attrs, PackageNameNode name, int pos)
    {
        PackageDefinitionNode node;
		
        if( name == null )
        {
            name = packageName(packageIdentifiers(null,identifier("",0),false));
        }
        
        final String id = name.id.toIdentifierString();
        
        {
            node = new PackageDefinitionNode(cx,attrs, name, null);
            node.setPositionNonterminal(name, pos);
            pkg_names.put(id,node);
            pkg_defs.add(node);
        }
        
        if (current_package != null)
			cx.parser.error(kError_NestedPackage);

        current_package = node;
        return node;
    }
	
    public PackageDefinitionNode finishPackage(Context cx, StatementListNode block)
    {
        return finishPackage(cx, block, -1);
    }

    public PackageDefinitionNode finishPackage(Context cx, StatementListNode statements, int pos)
    {
        if (current_package == null) // nested package definition can cause this.  Error has already been reported
			return null;

        PackageDefinitionNode node = current_package;
        current_package = null;

        // wrap statements in matching package nodes
        
        if( statements == null )
        {
            statements = statementList(null,(StatementListNode)null);
        }
        
        statements.items.add(0,node);
        statements.items.add(node);

        node.statements = statements;
        use_stmts = null;
        return node;
    }
	
    public PackageNameNode packageName(LiteralStringNode url)
	{
		return packageName(url, -1);
	}

	public PackageNameNode packageName(LiteralStringNode url, int pos)
	{
		PackageNameNode node = new PackageNameNode(url, url.pos());
		node.setPositionNonterminal(url, pos);
		return node;
	}

	public PackageNameNode packageName(PackageIdentifiersNode id)
	{
		return packageName(id, -1);
	}

	public PackageNameNode packageName(PackageIdentifiersNode id, int pos)
	{
        id.clearIdentifierString();     // clear the string so it will regen
        String compound_name = id.toIdentifierString();
        compound_names.add(compound_name);

        PackageNameNode node = new PackageNameNode(id, id.pos());
		node.setPositionNonterminal(id, pos);
		return node;
	}

	public PackageIdentifiersNode packageIdentifiers(PackageIdentifiersNode node, IdentifierNode item, boolean isDefinition)
	{
		return packageIdentifiers(node, item, isDefinition, -1);
	}

	public PackageIdentifiersNode packageIdentifiers(PackageIdentifiersNode node, IdentifierNode item, boolean isDefinition, int pos)
	{
		if (node != null)
		{
			node.list.add(item);
            node.clearIdentifierString();     // clear the string so it will regen
            String compound_name = node.toIdentifierString();
/*            if( compound_name.indexOf(".") > 0 )
            {
                compound_names.add(compound_name);
            }
*/
		}
		else
		{
			node = new PackageIdentifiersNode(item, 0, isDefinition);
			node.setPositionNonterminal(node, pos);
		}

        return node;
	}

	public ParameterNode parameter(int kind, IdentifierNode identifier, Node type)
	{
		return parameter(kind, identifier, type, -1);
	}

	public ParameterNode parameter(int kind, IdentifierNode identifier, Node type, int pos)
	{
		return this.parameter(kind, identifier, type, null, pos);
	}

	public ParameterNode parameter(int kind, IdentifierNode identifier, Node type, Node init)
	{
		return parameter(kind, identifier, type, init, -1);
	}

	public ParameterNode parameter(int kind, IdentifierNode identifier, Node type, Node init, int pos)
	{
		ParameterNode node = new ParameterNode(kind, identifier, type, init);
		node.setPositionNonterminal(identifier, pos);
		return node;
	}

	public ParameterListNode parameterList( ParameterListNode list, ParameterNode item)
	{
		return parameterList(list, item, -1);
	}

	public ParameterListNode parameterList( ParameterListNode list, ParameterNode item, int pos)
	{
		ParameterListNode node;

		if( list != null)
		{
			list.items.push_back(item);
			node = list;
		}
		else
		{
			node = new ParameterListNode(null,item,0);
			node.setPositionNonterminal(list!=null?(Node)list:(Node)item,pos);
		}
		return node;
	}


	public ParenExpressionNode parenExpression(Node expr)
	{
		return parenExpression(expr, -1);
	}

	public ParenExpressionNode parenExpression(Node expr, int pos)
	{
		ParenExpressionNode node = new ParenExpressionNode(expr, 0 /*in.positionOfMark()*/);
		node.setPositionNonterminal(expr, pos);
		return node;
	}

	public ParenListExpressionNode parenListExpression(Node expr)
	{
		return parenListExpression(expr, -1);
	}

	public ParenListExpressionNode parenListExpression(Node expr, int pos)
	{
		ParenListExpressionNode node = new ParenListExpressionNode(expr);
		node.setPositionNonterminal(expr, pos);
		return node;
	}

	public Node postfixExpression(int op, Node expr, int pos)
	{
		Node node;
		MemberExpressionNode member = null;
		if (expr.isList())
		{
			ListNode list = (ListNode) expr;
			if (list.items.last().isMemberExpression())
			{
				member = (MemberExpressionNode) list.items.last();
			}
		}
		else if (expr.isMemberExpression())
		{
			// Put the assignment expression in the slot part of the member expr.
			member = (MemberExpressionNode) expr;
		}

		if (member != null && member.selector.isGetExpression())
		{
			GetExpressionNode get = (GetExpressionNode) member.selector;
			member.selector = new IncrementNode(op, get.expr, true /*postfix*/);
//            member.selector.is_lexical   = get.is_lexical;
//            member.selector.is_bracketed = get.is_bracketed;
			member.selector.setMode(get.getMode());
			member.selector.setPositionTerminal(pos);
			if (member.isIndexedMemberExpression())
			{
				node = this.indexedMemberExpression(member.base, member.selector);
			}
			else
			{
				node = this.memberExpression(member.base, member.selector);
			}
		}
		else
		{
			node = this.error(expr.getPosition(), kError_IncrementOperatorNotAReference);// todo: should be an cx.error, not an ErrorNode?
			node.setPosition(node.getPosition());
		}

		return node;
	}

	public PragmaExpressionNode pragmaExpression(IdentifierNode identifier, Node arg, int pos)
	{
		PragmaExpressionNode node = new PragmaExpressionNode(identifier, arg);
		node.setPositionTerminal(pos);
		return node;
	}

	public PragmaNode pragma(ListNode list, int pos)
	{
		PragmaNode node = new PragmaNode(list);
		node.setPositionTerminal(pos);
		return node;
	}

	public ProgramNode program(Context cx, StatementListNode statements)
	{
		return program(cx, statements, -1);
	}

	public ProgramNode program(Context cx, StatementListNode statements, int pos)
	{
        if (statements == null)
        {
            statements = statementList(null,null);
            statements.was_empty = true;
        }
        ProgramNode node = new ProgramNode(cx,statements);
		node.setPositionNonterminal(statements, pos);

		node.pkgdefs.addAll(pkg_defs);
		node.has_unnamed_package = has_unnamed_package;

		use_stmts = null;

		return node;
	}


    public BinaryProgramNode binaryProgram(Context cx, StatementListNode statements)
    {
        return binaryProgram(cx, statements, -1);
    }

    public BinaryProgramNode binaryProgram(Context cx, StatementListNode statements, int pos)
    {
        if ( statements == null )
        {
            statements = statementList(null,null);
            statements.was_empty = true;
        }

		BinaryProgramNode node = new BinaryProgramNode(cx,statements);
        node.setPositionNonterminal(statements, pos);

        node.pkgdefs.addAll(pkg_defs);
        node.has_unnamed_package = has_unnamed_package;

        return node;
    }

	public QualifiedIdentifierNode qualifiedIdentifier(Node qualifier, String name)
	{
		return qualifiedIdentifier(qualifier, name, -1);
	}

    public QualifiedIdentifierNode qualifiedIdentifier(Node qualifier, String name, int pos)
    {
        QualifiedIdentifierNode node = new QualifiedIdentifierNode(qualifier, name, pos);
        node.setPositionTerminal(pos);

        if (ARGUMENTS == name)
        {
            this.has_arguments = true;
        }

        return node;
    }

    public QualifiedExpressionNode qualifiedExpression(Node qualifier, Node expr, int pos)
    {
        QualifiedExpressionNode node = new QualifiedExpressionNode(qualifier, expr, expr.pos());
        node.setPositionNonterminal(expr, pos);
        return node;
    }

    public RestParameterNode restParameter(ParameterNode expr)
	{
		return restParameter(expr, -1);
	}

	public RestParameterNode restParameter(ParameterNode expr, int pos)
	{
		this.has_rest = true;

        RestParameterNode node = null;
		if( expr == null )
		{
            cx.error(pos-1, kError_RestParameterNotNamed);
		}
		else
		{
		    node = new RestParameterNode(expr);
            node.setPositionNonterminal(expr, pos);
        }
		return node;
	}

	public RestExpressionNode restExpression(Node expr)
	{
		return restExpression(expr, -1);
	}

	public RestExpressionNode restExpression(Node expr, int pos)
	{
		RestExpressionNode node = new RestExpressionNode(expr);
		node.setPositionNonterminal(expr, pos);
		return node;
	}

	public ReturnStatementNode returnStatement(Node expr)
	{
		return returnStatement(expr, -1);
	}

	public ReturnStatementNode returnStatement(Node expr, int pos)
	{
		ReturnStatementNode node = new ReturnStatementNode(expr);
		node.setPositionNonterminal(expr, pos);
		return node;
	}

	public SetExpressionNode setExpression(Node expr, ArgumentListNode args, boolean is_constinit)
	{
		return setExpression(expr, args, is_constinit, -1);
	}

	public SetExpressionNode setExpression(Node expr, ArgumentListNode args, boolean is_constinit, int pos)
	{
		SetExpressionNode node = new SetExpressionNode(expr, args);
		node.setPositionNonterminal(expr, pos);
        node.is_constinit = is_constinit;
		return node;
	}

	public SetExpressionNode setExpression(GetExpressionNode get, ArgumentListNode args, boolean is_constinit)
	{
		return setExpression(get, args, is_constinit, -1);
	}

	public SetExpressionNode setExpression(GetExpressionNode get, ArgumentListNode args, boolean is_constinit, int pos)
	{
		SetExpressionNode node;

        if( get.getIdentifier() != null )
        {
            node = setExpression(get.expr,args,is_constinit,pos);
        }
        else
        {
            if( get.expr.hasSideEffect() )
            {
                RegisterNode reg = register(-1);
                Node expr = list(list(null,
                    storeRegister(reg,get.expr,cx.noType(),-1)),
                        loadRegister(reg,cx.noType(),-1));

                get.expr = loadRegister(reg,cx.noType(),-1);
                node = setExpression(expr,args,is_constinit,pos);
            }
            else
            {
                node = setExpression(get.expr,args,is_constinit,pos);
            }
        }

        return node;
	}

	public StatementListNode statementList(StatementListNode list, Node item)
	{
		return statementList(list, item, -1);
	}

    public StatementListNode statementList(StatementListNode list, Node item, int pos)
    {
        StatementListNode node;

        if (list != null)
        {
            // some forms of metaData can have DocComments associated with them.  They are also associated with
            //  a definition
            if (item instanceof MetaDataNode && !(item instanceof DocCommentNode))
            {
                MetaDataNode meta = (MetaDataNode)item;
                for (int i = list.items.size() - 1; i >= 0; i--)
                {
                    Node n = list.items.get(i);

                    if (n instanceof DocCommentNode )
                    {
                        DocCommentNode doc = (DocCommentNode)n;
                        if (doc.metaData == null)
                            doc.metaData = meta;
                        break;
                    }
                    else if (n instanceof MetaDataNode || n instanceof DefinitionNode)
                        break;
                }
            }

            boolean has_doc = false;

            if (item instanceof DefinitionNode && !(item instanceof IncludeDirectiveNode) )
            {
                for (int i = list.items.size() - 1; i >= 0; i--)
                {
                    Node n = list.items.get(i);
                    if (n instanceof MetaDataNode)
                    {
                        MetaDataNode meta = (MetaDataNode) n;
                        if (meta.def == null)
                        {
                            meta.def = (DefinitionNode) item;
                            meta.def.addMetaDataNode(meta);
                            if (n instanceof DocCommentNode)
                            {
                                if (((DocCommentNode)n).metaData == null)    // cn: Some metadata like [Style] can have its own docCommentNode which is not associated with the definition that
                                    has_doc = true;                          //  metadata is.  Don't mark as true if we are precided by a docComment belongs to a piece of metaData
                            }
                        }
                    }
					else if (!(n instanceof IncludeDirectiveNode)) // cn: includeStatementNodes bracket included nodes.  Included file could contain metadata, skip bracket.
                    {
                        break;
                    }
                }
                if (has_doc == false && create_default_doc_comments)
                {
                    DocCommentNode dcn = docComment(literalArray(null),pos);
                    DefinitionNode def = (DefinitionNode) item;
                    dcn.def = def;
                    dcn.is_default = true;
                    // cn: ensure docComment is the first piece of metaData.  Necessary for DocCommentNode.emit to skip over duplicates when more than one
                    //  docComment is specified for a single definition.
                    if (def.metaData == null)
                        def.addMetaDataNode(dcn);
                    else
                        def.metaData.items.add(0,dcn);
                    list.items.add(dcn);
                }
            }
            
            if( !cx.scriptAssistParsing && item instanceof IncludeDirectiveNode )
            {
                IncludeDirectiveNode idn = (IncludeDirectiveNode) item;
                list.items.add(idn);
                // first element of a program statementlist may be a synthetically inserted "void 0" used as the default cv value
                // cn:  that is no longer true, add all the elements.
                list.items.addAll(idn.program.statements.items.subList(0, idn.program.statements.items.size()));
                list.items.add(idn);
            }
            else
            {
                list.items.add(item);
            }
            node = list;
        }
        else
        {
            if( item instanceof DefinitionNode && create_default_doc_comments)
            {
                DocCommentNode dcn = docComment(literalArray(null),pos);
                DefinitionNode def = (DefinitionNode)item;
                dcn.def = def;
                dcn.is_default = true;
                def.addMetaDataNode(dcn);

                node = new StatementListNode(dcn);
                node.setPositionNonterminal(list != null ? list : item, item != null ? item.pos() : -1);
                node.items.add(item);
            }
            else
            {
                node = new StatementListNode(item);
                node.setPositionNonterminal(list != null ? list : item, item != null ? item.pos() : -1);
            }

            if(!cx.scriptAssistParsing && item instanceof IncludeDirectiveNode )
            {
                IncludeDirectiveNode idn = (IncludeDirectiveNode) item;
                node.items.addAll(idn.program.statements.items);
                node.items.add(idn);
            }
        }
        return node;
    }

    public StatementListNode statementList(StatementListNode first, StatementListNode second)
    {
        if( first == null )
        {
            first = new StatementListNode(null);
            first.setPositionNonterminal(second,second!=null?second.pos():-1);
        }

        if( second != null )
        {
            first.items.addAll(second.items);
        }

        return first;
    }

    public SuperExpressionNode superExpression(Node expr, int pos)
	{
		SuperExpressionNode node = new SuperExpressionNode(expr);
		node.setPositionTerminal(pos);
		return node;
	}

	public SuperStatementNode superStatement(CallExpressionNode call)
	{
		return superStatement(call, -1);
	}

	public SuperStatementNode superStatement(CallExpressionNode call, int pos)
	{
		SuperStatementNode node = new SuperStatementNode(call);
		node.setPositionNonterminal(call, pos);
		return node;
	}

	public SwitchStatementNode switchStatement(Node expr, StatementListNode statements)
	{
		return switchStatement(expr, statements, -1);
	}

	public SwitchStatementNode switchStatement(Node expr, StatementListNode statements, int pos)
	{
        SwitchStatementNode node = new SwitchStatementNode(expr, statements);
		node.setPositionNonterminal(expr, pos);
		return node;
	}

	public ThisExpressionNode thisExpression(int pos)
	{
		ThisExpressionNode node = new ThisExpressionNode();
		node.setPositionTerminal(pos);
		return node;
	}

	public ThrowStatementNode throwStatement(Node list, int pos)
	{
		ThrowStatementNode node = new ThrowStatementNode(list);
		node.setPositionTerminal(pos);
		return node;
	}

	public TryStatementNode tryStatement(StatementListNode tryblock, StatementListNode catchlist, FinallyClauseNode finallyblock)
	{
		return tryStatement(tryblock, catchlist, finallyblock, -1);
	}

	public TryStatementNode tryStatement(StatementListNode tryblock, StatementListNode catchlist, FinallyClauseNode finallyblock, int pos)
	{
        if( tryblock == null )
        {
            tryblock = statementList(null,emptyStatement());
        }
        TryStatementNode node = new TryStatementNode(tryblock, catchlist, finallyblock);
		node.setPositionNonterminal(tryblock, pos);
		return node;
	}

	public FinallyClauseNode finallyClause(StatementListNode block)
	{
		return finallyClause(block, -1);
	}

	public FinallyClauseNode finallyClause(StatementListNode block, int pos)
	{
        if( block == null )
        {
            block = statementList(null,emptyStatement());
        }

        // default catch_clause so that finally will work.
        CatchClauseNode catch_clause = catchClause(null,statementList(null,throwStatement(null, 0 )));

        FinallyClauseNode node = new FinallyClauseNode(block, catch_clause);
		node.setPositionNonterminal(block, pos);
		return node;
	}

    public TypedIdentifierNode typedIdentifier(Node identifier, Node type)
	{
		return typedIdentifier(identifier, type, -1);
	}

	public TypedIdentifierNode typedIdentifier(Node identifier, Node type, int pos)
	{
		TypedIdentifierNode node = new TypedIdentifierNode(identifier, type, type != null ? type.pos() : identifier.pos());
		node.setPositionNonterminal(identifier, pos);
		return node;
	}

	public Node unaryExpression(int op, Node expr)
	{
		return unaryExpression(op, expr, -1);
	}

	public Node unaryExpression(int op, Node expr, int pos)
	{
		Node node;

		// If this is a delete, ++ or -- expression, then this must return a
		// MemberExpression. Otherwise, this will return a UnaryExpression.

		if (op == DELETE_TOKEN)
		{
			MemberExpressionNode member = null;

			if (expr.isMemberExpression())
			{
				// Put the assignment expression in the slot part of the member expr.
				member = (expr instanceof MemberExpressionNode) ? (MemberExpressionNode) expr : null;
			}
			else if (expr.isList())
			{
				Node item = ((ListNode) expr).items.last();
				member = (item instanceof MemberExpressionNode) ? (MemberExpressionNode) item : null;
			}
			else
			{
				// Its just a regular old expression
			}

			if (member != null && member.selector.isGetExpression())
			{
				GetExpressionNode get = (GetExpressionNode) member.selector;
				member.selector = new DeleteExpressionNode(op, get.expr);
//                member.selector.is_lexical   = get.is_lexical;
//                member.selector.is_bracketed = get.is_bracketed;
				member.selector.setMode(get.getMode());
				member.selector.setPositionNonterminal(expr, pos);
				// ISSUE: eliminate IndexedMemberExpression
				if (member.isIndexedMemberExpression())
				{
					node = this.indexedMemberExpression(member.base, member.selector);
				}
				else
				{
					node = this.memberExpression(member.base, member.selector);
				}
			}
			else
			{
				// expr does not result in a reference, evaluate the expression and return true.
				node = new DeleteExpressionNode(op, expr);
				node.setPositionNonterminal(expr, pos);
			}
		}
		else if (op == PLUSPLUS_TOKEN ||
			op == MINUSMINUS_TOKEN)
		{

			MemberExpressionNode member = null;

            while (expr.isList())
            {
                ListNode list = (ListNode)expr;
                if (list.size() != 1)
                {
                    if (op == PLUSPLUS_TOKEN)
                        return this.error(kError_InvalidIncrementOperand, pos);
                    else
                        return this.error(kError_InvalidDecrementOperand, pos);
                }

                expr = list.items.at(0);
            }
			if (expr.isMemberExpression())
			{
				// Put the assignment expression in the slot part of the member expr.
				member = (MemberExpressionNode) expr;
			}
			else
			{
				// Its just a regular old expression
			}

			if (member != null && member.selector.isGetExpression())
			{
				GetExpressionNode get = (GetExpressionNode) member.selector;
				member.selector = new IncrementNode(op, get.expr, false/*not postfix*/);
				member.selector.setPositionNonterminal(expr, pos);
				if (member.isIndexedMemberExpression())
				{
					node = this.indexedMemberExpression(member.base, member.selector);
				}
				else
				{
					node = this.memberExpression(member.base, member.selector);
				}
			}
			else
			{
				node = this.error(pos, kError_IncrementOperatorNotAReference);
				node.setPositionNonterminal(expr, pos);
			}
		}
		else if (expr.isLiteralNumber() &&
			(op == PLUS_TOKEN || op == MINUS_TOKEN))
		{
			LiteralNumberNode numb = (LiteralNumberNode) expr;
			if (op == MINUS_TOKEN)
			{
				numb.negate();
			} else {
				if (cx.scriptAssistParsing)
					numb.value = "+" + numb.value;
			}
			node = numb;
		}
		else
		{
			node = new UnaryExpressionNode(op, expr);
			node.setPositionNonterminal(expr, pos);
		}

		return node;
	}

	public UseDirectiveNode useDirective(AttributeListNode attrs, Node expr)
	{
		return useDirective(attrs, expr, -1);
	}


	public UseDirectiveNode useDirective(AttributeListNode attrs, Node expr, int pos)
	{
		UseDirectiveNode node = new UseDirectiveNode(current_package, attrs, expr);
		node.setPositionNonterminal(expr, pos);
        use_stmts = statementList(use_stmts,node);
		return node;
	}

	public UsePragmaNode usePragma(Node id, Node argument)
	{
		return usePragma(id, argument, -1);
	}


	public UsePragmaNode usePragma(Node id, Node argument, int pos)
	{
        UsePragmaNode node = null;
        if (id instanceof IdentifierNode && cx.statics.es4_numerics) {
            String idval = ((IdentifierNode)id).toIdentifierString();
            if (idval.equals("precision")) {
                node = new UsePrecisionNode(id, argument);
            }
            else if (idval.equals("rounding")) {
                node = new UseRoundingNode (id, argument);
            }
            else if (idval.equals("decimal")) {
				node = new UseNumericNode(id, argument, NumberUsage.use_decimal);
			}
			else if (idval.equals("double")) {
				node = new UseNumericNode(id, argument, NumberUsage.use_double);
			}
			else if (idval.equals("int")) {
				node = new UseNumericNode(id, argument, NumberUsage.use_int);
			}
			else if (idval.equals("uint")) {
				node = new UseNumericNode(id, argument, NumberUsage.use_uint);
			}
			else if (idval.equals("Number")) {
				node = new UseNumericNode(id, argument, NumberUsage.use_Number);
			}
        }
        if (node == null) {
            // nothing matched
            node = new UsePragmaNode(id, argument);
        }
		node.setPositionTerminal(pos);
        //use_stmts = statementList(use_stmts,node);
		return node;
	}

	public VariableBindingNode variableBinding(AttributeListNode attrs, int kind, TypedIdentifierNode identifier, Node initializer)
	{
		return variableBinding(attrs, kind, identifier, initializer, -1);
	}

	public VariableBindingNode variableBinding(AttributeListNode attrs, int kind, TypedIdentifierNode identifier, Node initializer, int pos)
	{
		identifier.identifier = qualifiedIdentifier(attrs, identifier.identifier.name, identifier.identifier.pos());
		VariableBindingNode node = new VariableBindingNode(current_package, attrs, kind, identifier, initializer);
		node.setPositionNonterminal(identifier, pos);
		return node;
	}

	public VariableDefinitionNode variableDefinition(AttributeListNode attrs, int kind, ListNode list)
	{
		return variableDefinition(attrs, kind, list, -1);
	}


	public VariableDefinitionNode variableDefinition(AttributeListNode attrs, int kind, ListNode list, int pos)
	{
		VariableDefinitionNode node = new VariableDefinitionNode(current_package, attrs, kind, list, list.pos());
		node.setPositionNonterminal(list, pos);
		return node;
	}

	public WithStatementNode withStatement(Node expr, Node stmt)
	{
		return withStatement(expr, stmt, -1);
	}

	public WithStatementNode withStatement(Node expr, Node stmt, int pos)
	{
        if( stmt != null )
        {
            StatementListNode stmtlist = (stmt instanceof StatementListNode)?(StatementListNode) stmt : null;
            if( stmtlist == null )
            {
                stmt = stmtlist = this.statementList(null,stmt);
            }
        }
        WithStatementNode node = new WithStatementNode(expr, stmt);
		node.setPositionNonterminal(expr, pos);
		return node;
	}

	public WhileStatementNode whileStatement(Node expr, Node stmt)
	{
		return whileStatement(expr, stmt, -1);
	}


	public WhileStatementNode whileStatement(Node expr, Node stmt, int pos)
	{
        if( stmt != null )
        {
            StatementListNode stmtlist = (stmt instanceof StatementListNode)?(StatementListNode) stmt : null;
            if( stmtlist == null )
            {
                stmt = stmtlist = this.statementList(null,stmt);
            }
        }
        WhileStatementNode node = new WhileStatementNode(expr, stmt);
		node.setPositionNonterminal(expr, pos);
		return node;
	}

	// Begin nodes that are created during semantic analysis.

	public InvokeNode invoke(String name, ArgumentListNode args, int pos)
	{
		InvokeNode node = new InvokeNode(name, args);
		node.setPositionTerminal(pos);
		return node;
	}

	public ErrorNode error(int errCode)
	{
		return error(-1, errCode);
	}

    public ErrorNode error(int pos, int errCode, String arg)
	{
		ErrorNode node = new ErrorNode(errCode, arg); 
		node.setPositionTerminal(pos);
		return node;
	}

	public ErrorNode error(int pos, int errCode)
	{
		ErrorNode node = new ErrorNode(errCode, "");
		node.setPositionTerminal(pos);
		return node;
	}

	public HasNextNode hasNext(RegisterNode objectRegister,
							   RegisterNode indexRegister,
							   int pos)
	{
		HasNextNode node = new HasNextNode(objectRegister, indexRegister);
		node.setPositionTerminal(pos);
		return node;
	}
	
	public LoadRegisterNode loadRegister(RegisterNode reg, TypeValue type, int pos)
	{
		LoadRegisterNode node = new LoadRegisterNode(reg, type);
		node.setPositionTerminal(pos);
		return node;
	}

	public StoreRegisterNode storeRegister(RegisterNode reg, Node expr, TypeValue type, int pos)
	{
		StoreRegisterNode node = new StoreRegisterNode(reg, expr, type);
		node.setPositionNonterminal(expr, pos);
		return node;
	}

	public ToObjectNode toObject(Node expr, int pos)
	{
		ToObjectNode node = new ToObjectNode(expr);
		node.setPositionNonterminal(expr, pos);
		return node;
	}

	public Node box(Node expr, TypeValue actual)
	{
		return box(expr, actual, -1);
	}

	public Node box(Node expr, TypeValue actual, int pos)
	{
		BoxNode node = new BoxNode(expr, actual);
		node.setPositionNonterminal(expr, pos);
		return node;
	}

	public Node coerce(Node expr, TypeInfo actual, TypeInfo expected, boolean is_explicit)
	{
		return coerce(expr, actual, expected, is_explicit, -1);
	}

	public Node coerce(Node expr, TypeInfo actual, TypeInfo expected, boolean is_explicit, int pos)
	{
        if (expr instanceof CoerceNode)
        {
            CoerceNode cn = (CoerceNode) expr;
            if (cn.actual == actual && cn.expected == expected && (cn.is_explicit || !is_explicit))
            {
                // don't wrap a coerce node with another redundant one
                return expr;
            }
        }
		CoerceNode node = new CoerceNode(expr, actual, expected, is_explicit);
		node.setPositionNonterminal(expr, pos);
		return node;
	}

    public MetaDataNode metaData(LiteralArrayNode data, int pos)
    {
        MetaDataNode node = new MetaDataNode(data);
        node.setPositionTerminal(pos);
        return node;
    }

	public DocCommentNode docComment(LiteralArrayNode data, int pos)
	{
		DocCommentNode node = new DocCommentNode(data);
		node.setPositionTerminal(pos);
		return node;
	}

	public CommentNode comment(String val, int ctype, int pos)
	{
		CommentNode node = new CommentNode(val,ctype);
		node.setPositionTerminal(pos);
		return node;
	}

    public DefaultXMLNamespaceNode defaultXMLNamespace(Node expr, int pos)
    {
        DefaultXMLNamespaceNode node = new DefaultXMLNamespaceNode(expr);
        node.setPositionTerminal(pos);
        dxns = node;
        has_dxns = true;
        return node;
    }

    RegisterNode register(int pos)
    {
        RegisterNode node = new RegisterNode();
        node.setPositionTerminal(pos);
        return node;
    }

    Node filterOperator( Node expr1, Node expr2, int pos )
    {
    	 if (cx.scriptAssistParsing){
    		Node result = memberExpression(expr1, getExpression(expr2));
    		return result;
    	 } else {
	        RegisterNode var_reg = register(pos);    // p in for each ( var p in o ) { }
	        RegisterNode tmp_reg = register(pos);    // holds the XMLList result
	        RegisterNode ndx_reg = register(pos);
	        RegisterNode obj_reg = register(pos);    // expr1
	            
	        Node init;
	        Node test;
	
	        Node checkFilter = invoke("[[CheckFilterOperand]]", argumentList(null, expr1), pos);
	        
	        // Coerce the object to type *, since it will be mutated by OP_hasnext        
	        Node untypedExpr = coerce(checkFilter,null,cx.noType().getDefaultTypeInfo(),true,pos);
	        
	        init = list(list(list(null,
	            storeRegister(ndx_reg,literalNumber("0",pos),cx.intType(),pos)),
	            storeRegister(obj_reg,untypedExpr,cx.noType(),pos)),
	            storeRegister(tmp_reg,literalXML(list(null,literalString("",pos)),true/*is_xmllist*/,pos),cx.noType(),pos));
	
	        test = hasNext(obj_reg,ndx_reg,pos);
	            
	        ExpressionStatementNode incr;
	            
	        incr = expressionStatement(storeRegister(var_reg,
	            memberExpression(loadRegister(obj_reg,cx.noType(),pos),
	            invoke("[[NextValue]]",argumentList(null,
	            loadRegister(ndx_reg,cx.intType(),pos)),pos)),cx.noType(),pos));
	        incr.isVarStatement(true); // treat as var statement, don't save result for cv
	            
	        StatementListNode stmt2;
	            
	        // tmp[ndx] = var
	        SetExpressionNode setx = setExpression(loadRegister(ndx_reg,cx.intType(),pos), argumentList(null,
	            loadRegister(var_reg,cx.noType(),pos)), /*is_constinit=*/ false);
	        setx.setMode(EMPTY_TOKEN);  // synthetic
	        
	        stmt2 = statementList(null,expressionStatement(memberExpression(loadRegister(tmp_reg,cx.noType(),pos),
	            setx,pos),pos),pos);
	            
	
	        StatementListNode stmt;
	        stmt = statementList(null,incr);
	        stmt = statementList(stmt,withStatement(loadRegister(var_reg,cx.noType(),pos),ifStatement(list(null,expr2),stmt2,null)));

	        Node node = forStatement(init,test,null,stmt,false/*is_forin*/,pos);
	        node = statementList(statementList(statementList(null,tmp_reg,pos)/*force alloc of tmp_reg*/,
	                    node),loadRegister(tmp_reg,cx.noType(),pos));
	        return node;
    	 }
    }

    public Context getContext()
    {
        return cx;
    }

    public void setContext(Context cx)
    {
        this.cx = cx;
    }

    public static void main(String[] args)
	{
		ContextStatics statics = new ContextStatics();
		Context cx = new Context(statics);
		NodeFactory nodeFactory = new NodeFactory(cx);

		nodeFactory.identifier("a");
		nodeFactory.qualifiedIdentifier(nodeFactory.identifier("public"), "b");
		nodeFactory.literalNull();
		nodeFactory.literalBoolean(true);
		nodeFactory.literalArray(nodeFactory.argumentList(null, nodeFactory.literalNumber("one")));
		nodeFactory.literalField(nodeFactory.identifier("a"), nodeFactory.literalBoolean(true));
		nodeFactory.literalNumber("3.1415");
		nodeFactory.literalObject(nodeFactory.argumentList(null, nodeFactory.literalField(nodeFactory.identifier("a"), nodeFactory.literalBoolean(true))));
	}
}
