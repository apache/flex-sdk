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

package macromedia.asc.semantics;

import macromedia.asc.embedding.ErrorConstants;
import macromedia.asc.embedding.avmplus.InstanceBuilder;
import macromedia.asc.embedding.avmplus.ClassBuilder;
import macromedia.asc.embedding.avmplus.GlobalBuilder;

import macromedia.asc.parser.*;

import macromedia.asc.util.*;

import static macromedia.asc.parser.Tokens.*;
import static macromedia.asc.embedding.avmplus.RuntimeConstants.*;
import static macromedia.asc.semantics.Slot.*;
import static macromedia.asc.util.BitSet.*;

/**
 * [Apr-15-2004, jdyer]
 * The constant evaluator's overarching purpose is to compute
 * the value of compile-time constants. Any expression may
 * result in constant value, at compile-time, and there are
 * some important context where they must (e.g. TypeExpression)
 *
 * Knowing the value of an expression allows the compiler
 * to optimize access to that value and, if necessary, it's
 * properties. Even when the value of an expression is not
 * known, it is possible for the compiler to know the type
 * of an expression. In this case, the constant evaluator
 * uses the prototype of that type as a stand-in for the
 * actual runtime value.
 *
 * @author Jeff Dyer
 */
public final class ConstantEvaluator extends Emitter implements Evaluator, ErrorConstants
{
    private BitSet rch_bits = null;
    private Block block;

    private boolean doing_method;
    private boolean doing_class;
    private boolean in_anonymous_function;

    TypeInfo return_type;  // function common is unrolled so this should be okay

    boolean in_with;

    private IntList this_contexts = new IntList();
    private IntList super_context = new IntList();

    // This is set by PreprocessTypeInfo(cx, ProgramNode).  Mxmlc needs to call PreprocessTypeInfo on
    //  all source files prior to the normal CE evaluation of each source file.  This flag
    //  prevents us from performing PreprocessTypeInfo step twice in that case.
    private boolean typeInfoPreprocessing_complete;  
    
    private Decimal128Context currentDecimalContext;


    public ConstantEvaluator(Context cx)
    {
        doing_method = false;
        doing_class  = false;
        in_anonymous_function = false;
        block = null;
        return_type = cx.noType().getDefaultTypeInfo();
        typeInfoPreprocessing_complete = false;
        in_with = false;
    }

    // This method is called before evaluating every node.
    // If the current nodes block is different than the
    // current block, then we are at a leader and we need
    // to set rch_bits to the new block's in_bits. Then,
    // compute the reaching definition using a straight
    // cascade of statements.

    public boolean checkFeature(Context cx, Node node)
    {
        if (node.block != null && node.block != block && !(node instanceof EmptyStatementNode))
        {
            rch_bits = node.block.in_bits;
            block = node.block;
        }
        return true;
    }

    public void PreprocessDefinitionTypeInfo(Context cx, ProgramNode pn)
    {
        // Mxmlc needs to call PreprocessTypeInfo on all source files prior to the 
        //  normal CE evaluation of each source file.  This flag prevents us from performing 
        //  this step twice in that case.
        if (typeInfoPreprocessing_complete == false)
        {
            PreprocessDefinitionTypeInfo(cx, pn.statements.items, false);
            cx.processUnresolvedNamespaces();
        }
        typeInfoPreprocessing_complete = true;
    }

    public void PreprocessDefinitionTypeInfo(Context cx, BinaryProgramNode node)
    {
        for (ClassDefinitionNode cls_def : node.clsdefs)
        {
            PreprocessDefinitionTypeInfo(cx, cls_def);
        }

		PreprocessDefinitionTypeInfo(cx, node.statements.items);
    }

    void PreprocessDefinitionTypeInfo(Context cx, ObjectList<Node> defList)
    {
        PreprocessDefinitionTypeInfo(cx, defList, false);
    }

    void PreprocessDefinitionTypeInfo(Context cx, ObjectList<Node> defList, boolean static_context)
    {
	    for (int i = 0, size = defList.size(); i < size; i++)
        {
	        Node it = defList.get(i);
			if (it instanceof LabeledStatementNode)
			{
				it = ((LabeledStatementNode)it).statement;
			}
			DefinitionNode dn = it instanceof DefinitionNode ? (DefinitionNode)it : null;

            if (dn != null && ((dn.attrs != null && dn.attrs.hasStatic == static_context) ||
                               (static_context == false && (dn.attrs == null || dn.attrs.hasStatic == false))))
            {
                if (dn instanceof ClassDefinitionNode)
                    PreprocessDefinitionTypeInfo(cx,(ClassDefinitionNode)dn);
                else if (dn instanceof FunctionDefinitionNode)
                    PreprocessDefinitionTypeInfo(cx,(FunctionDefinitionNode)dn);
                else if (dn instanceof VariableDefinitionNode)
                    PreprocessDefinitionTypeInfo(cx,(VariableDefinitionNode)dn);
                // else we don't care
            }
            else if (it instanceof MemberExpressionNode)
            {
                MemberExpressionNode me = (MemberExpressionNode)it;
                if (me.selector instanceof SetExpressionNode)
                {
                    SetExpressionNode se = (SetExpressionNode)(me.selector);
                    Node firstArg = (se.args != null && se.args.items != null) ? se.args.items.get(0) : null;
                    if (firstArg instanceof FunctionDefinitionNode)
                    {
                        PreprocessDefinitionTypeInfo(cx,(FunctionDefinitionNode)firstArg);
                    }
                    else if(firstArg instanceof FunctionCommonNode)
                    {
                        PreprocessDefinitionTypeInfo(cx,(FunctionCommonNode)firstArg);
                    }
                }
                else
                if (me.selector instanceof CallExpressionNode)
                {
                    CallExpressionNode se = (CallExpressionNode)(me.selector);
                    if( se.args != null )
                    for(Node arg : se.args.items)
                    {
                        if (arg instanceof FunctionDefinitionNode)
                        {
                            PreprocessDefinitionTypeInfo(cx,(FunctionDefinitionNode)arg);
                        }
                        else if(arg instanceof FunctionCommonNode)
                        {
                            PreprocessDefinitionTypeInfo(cx,(FunctionCommonNode)arg);
                        }
                    }
                }
            }
            else if (it instanceof ExpressionStatementNode)
            {
                ExpressionStatementNode expr_node = (ExpressionStatementNode)it;
                if( expr_node.expr instanceof ListNode)
                {
                    PreprocessDefinitionTypeInfo(cx, ((ListNode)expr_node.expr).items);
                }
            }
            else if( it instanceof BinaryProgramNode )
            {
                PreprocessDefinitionTypeInfo(cx, ((BinaryProgramNode)it));
            }
            else if( it instanceof StatementListNode )
            {
                PreprocessDefinitionTypeInfo(cx, ((StatementListNode)it).items, static_context);
            }
            else if (static_context == false)
            {   // deal with blocks created for for, with, try, catch, and finally clauses.
                //  Their statementLists are included as elements within the host statementlist
                //  and can contain their own definitions.
                StatementListNode    stln = it instanceof StatementListNode ? (StatementListNode)it : null;
                CatchClauseNode        ccn = it instanceof CatchClauseNode ? (CatchClauseNode)it : null;
                FinallyClauseNode    fcn = it instanceof FinallyClauseNode ? (FinallyClauseNode)it : null;
                SwitchStatementNode ssn = it instanceof SwitchStatementNode ? (SwitchStatementNode)it : null;
                TryStatementNode    tsn = it instanceof TryStatementNode ? (TryStatementNode)it : null;
                ForStatementNode    fsn = it instanceof ForStatementNode ? (ForStatementNode)it : null;
                WhileStatementNode    wsn = it instanceof WhileStatementNode ? (WhileStatementNode)it : null;
                IfStatementNode        isn = it instanceof IfStatementNode ? (IfStatementNode)it : null;
                DoStatementNode		dsn = it instanceof DoStatementNode ? (DoStatementNode)it : null;

                if (stln != null)
                {
                    PreprocessDefinitionTypeInfo(cx,stln.items,false);
                }
                else if (isn != null)
                {
                    StatementListNode sln = isn.thenactions instanceof StatementListNode ? (StatementListNode)(isn.thenactions) : null;
                    if (sln != null)
                        PreprocessDefinitionTypeInfo(cx,sln.items,false);
                    sln = isn.elseactions instanceof StatementListNode ? (StatementListNode)(isn.elseactions) : null;
                    if (sln != null)
                        PreprocessDefinitionTypeInfo(cx,sln.items,false);
                }
                else if (fsn != null)
                {
                    StatementListNode sln = fsn.statement instanceof StatementListNode ? (StatementListNode)(fsn.statement) : null;
                    if (sln != null)
                        PreprocessDefinitionTypeInfo(cx,sln.items,false);
                }
                else if (wsn != null)
                {
                    StatementListNode sln = wsn.statement instanceof StatementListNode ? (StatementListNode)(wsn.statement) : null;
                    if (sln != null)
                        PreprocessDefinitionTypeInfo(cx,sln.items,false);
                }
                else if ( dsn != null )
                {
                    StatementListNode sln = dsn.statements instanceof StatementListNode ? (StatementListNode)(dsn.statements) : null;
                    if (sln != null)
                        PreprocessDefinitionTypeInfo(cx,sln.items,false);
                }
                else if (ccn != null && ccn.statements != null)
                {
                    cx.pushScope(ccn.activation);
                    PreprocessDefinitionTypeInfo(cx,ccn.statements.items,false);
                    cx.popScope();
                }
                else if (fcn != null && fcn.statements != null)
                {
                    PreprocessDefinitionTypeInfo(cx,fcn.statements.items,false);
                }
                else if (ssn != null && ssn.statements != null)
                {
                    PreprocessDefinitionTypeInfo(cx,ssn.statements.items,false);
                }
                else if (tsn != null)
                {
                    if (tsn.tryblock != null)
                        PreprocessDefinitionTypeInfo(cx,tsn.tryblock.items,false);
                    if (tsn.catchlist != null)
                        PreprocessDefinitionTypeInfo(cx,tsn.catchlist.items,false);
                    if (tsn.finallyblock != null && tsn.finallyblock.statements != null)
                        PreprocessDefinitionTypeInfo(cx,tsn.finallyblock.statements.items,false);
                }
            }
        }
    }

    void PreprocessDefinitionTypeInfo(Context cx, FunctionCommonNode fcn)
    {
        ObjectValue fun = fcn.fun;

		// FIXME this could be a function expressions that was hoisted out of a
		// block that is conditionally compiled out. If so it is dead code that
		// is not properly initialized at this point (e.g fun == null), so we
		// need to check and bail out if so. The better fix would be to not add
		// it to the definition list in the first place.
		if (fun==null) return;

		cx.pushScope(fun.activation);

        if( fcn.def != null && fcn.def.version > -1)
            cx.pushVersion(fcn.def.version);

        PreprocessDefinitionTypeInfo(cx,fcn.signature);
        // process local definitions of the function
        if(fcn.body != null)
        	PreprocessDefinitionTypeInfo(cx,fcn.body.items);
        cx.popScope();
        Slot slot = fcn.ref.getSlot(cx,fcn.kind);
        if( slot != null )
        {
            slot.setType(fcn.signature.type != null ? fcn.signature.type : cx.noType().getDefaultTypeInfo());
            if( fcn.signature.parameter != null )
            {
                slot.setTypes(fcn.signature.parameter.types);
                slot.setDeclStyles(fcn.signature.parameter.decl_styles);
            }
            else // mark as requiring no arguments for proper # of arg checking
            {
                slot.addType(cx.voidType().getDefaultTypeInfo());        // Use void to denote that no parameters are declared
                slot.addDeclStyle(PARAM_Void);
            }
        }

        if( fcn.def != null && fcn.def.version > -1)
            cx.popVersion();
    }

    // also handles BinaryFunctionDefinitionNode
    void PreprocessDefinitionTypeInfo(Context unused_cx, FunctionDefinitionNode node)
    {
        // BinaryFunctionDefinitionNodes don't need any additional processing - AbcParser
        // should have created everything.
        if( node instanceof BinaryFunctionDefinitionNode )
            return;
        
        Context cx = node.cx;  // switch to original context
        FunctionCommonNode fcn = node.fexpr;

        if( fcn.ref != null)
            PreprocessDefinitionTypeInfo(cx, fcn);
    }

    // also handles InterfaceDefinitionNode, BinaryInterfaceDefinitionNode, BinaryClassDefNode
    void PreprocessDefinitionTypeInfo(Context unused_cx, ClassDefinitionNode  node)
    {
        // BinaryClassDefNode don't need any additional processing - AbcParser
        // should have created everything.
        if( node instanceof BinaryClassDefNode )
            return;
        
        Context cx = node.cx;  // switch to original context
        cx.pushStaticClassScopes(node);
        PreprocessDefinitionTypeInfo(cx,node.statements.items, true);

        cx.pushScope(node.iframe);


        if( node.version > -1 )
            cx.pushVersion(node.version);

        if (node.instanceinits != null)
            PreprocessDefinitionTypeInfo(cx,node.instanceinits, false);

        ObjectList<TypeInfo> ctor_types = null;
        ByteList ctor_decls = null;
        // need to look for the constructor and record it's signature.  It needs to be recorded in the class slot, not the function slot
        Slot class_slot = (node.ref != null ?  node.ref.getSlot(cx, NEW_TOKEN) : null);
        if (class_slot != null)
        {
            for (Node init : node.instanceinits)
            {
                if (init instanceof FunctionDefinitionNode)
                {
                    FunctionDefinitionNode func_def = (FunctionDefinitionNode)init;
                    if( func_def.fexpr.ref.name.equals("$construct") )
                    {
                        // Copy the type info from the constructor slot into the global slot that is the reference
                        // to the class - this is so that type checking on constructor calls can happen correctly
                        Slot ctor_slot = func_def.fexpr.ref.getSlot(cx, func_def.fexpr.kind);
                        if (ctor_slot != null)
                        {
                            ctor_types = ctor_slot.getTypes();
                            ctor_decls = ctor_slot.getDeclStyles();
                            class_slot.setTypes(ctor_slot.getTypes());
                            class_slot.setDeclStyles(ctor_slot.getDeclStyles());
                        }
                    }
                }
            }
        }

        cx.popScope();
        cx.popStaticClassScopes(node);

        if( node.version > -1 )
            cx.popVersion();

    }


    void PreprocessDefinitionTypeInfo(Context cx, VariableDefinitionNode  node)
    {
        for(Node it : node.list.items)
        {
            if (it instanceof VariableBindingNode)
            {
                PreprocessDefinitionTypeInfo(cx, (VariableBindingNode)it);
            }
        }
    }

    void PreprocessDefinitionTypeInfo(Context cx, VariableBindingNode  node)
    {
        if( node.typeref != null )
        {
            Slot typeslot = node.typeref.getSlot(cx);
            TypeValue type_val = null;
            TypeInfo type = null;

            if ( typeslot != null && typeslot.getValue() instanceof TypeValue )
            {
                type_val = (TypeValue)(typeslot.getValue());
                type = node.typeref.has_nullable_anno ? type_val.getTypeInfo(node.typeref.is_nullable) : type_val.getDefaultTypeInfo();
            }
            if ( type != null )
            {
                Slot slot = node.ref.getSlot(cx);
                if( slot != null )
                {
                    slot.setType(type);
                    slot.getTypes().clear();
                    slot.getTypes().push_back(type); // cn: issue, this isn't used by SetExpressionNode, just type.  For imported .abc definitions it already contains Object anyway
                }
            }
        }

        if ((node.initializer) instanceof FunctionCommonNode)
        {
            PreprocessDefinitionTypeInfo(cx,(FunctionCommonNode)(node.initializer));
        }
    }

    // Base node

    public Value evaluate(Context cx, Node node)
    {
        return cx.noType().prototype;
    }

    /*
     * Unqualified identifier
     *
     * STATUS
     *
     * NOTES
     * An unqualified name can bind to a local variable, instance
     * property, or global property. A local will result in a
     * aload_n instruction. A instance property will result in a
     * get_property method call. A global property will result in a
     * get_property method call on the global object.
     */

    public Value evaluate(Context cx, IdentifierNode node)
    {
        if (node.ref != null)
        {
            node.ref.calcUseDefinitions(cx, rch_bits);
        }

        return node.ref;
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
        if (node.qualifier != null)
        {
            node.qualifier.evaluate(cx, this);
        }
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        return null;
    }

    public Value evaluate(Context cx, ApplyTypeExprNode node)
    {
        TypeInfo type = cx.noType().getDefaultTypeInfo();
        Slot slot;
        int kind = EMPTY_TOKEN;
        if( node.ref != null )
        {
            Value val = node.expr.evaluate(cx, this);
            node.ref.calcUseDefinitions(cx, rch_bits);

            slot = node.ref.getSlot(cx, kind);
            type = node.ref.getType(cx, kind);

            if( cx.useStaticSemantics() )
            {
                TypeValue t = val instanceof TypeValue ? (TypeValue)val : null;
                if( t != cx.noType() && t != null && !t.is_parameterized )
                    cx.internalError("Illegal use of parameterized type");
            }
        }
        return node.ref;
    }


    /*
     * CallExpression
     */
    public Value evaluate(Context cx, CallExpressionNode node)
    {

        Slot slot = null;
        TypeInfo type = cx.noType().getDefaultTypeInfo();
        int kind = node.is_new ? NEW_TOKEN : EMPTY_TOKEN;
        
        if (node.ref != null)
        {
            /*if (node.ref.getBase() == null)
                            System.out.println("call "+node.ident.name);
                        else
                            System.out.println("call "+node.ref.getBase().type.name+"."+node.ident.name);*/
            node.ref.calcUseDefinitions(cx, rch_bits);

            slot = node.ref.getSlot(cx, kind);
            type = node.ref.getType(cx, kind);
            if( cx.useStaticSemantics() )
            {
                if( slot == null )
                {
                    slot = node.ref.getSlot(cx, GET_TOKEN);
                    // check for function/Class valued properties and getter functions which return functions/Classes
                    if (slot != null)
                    {
                        TypeValue t = slot.getType() != null ? slot.getType().getTypeValue() : null;
                        // note: you can call a Class valued var, it acts like an explicit cast
                        if ( t != cx.typeType() && t != cx.functionType() && t != cx.objectType() && t != cx.noType())
                        {
                            slot = null;
                            // don't permanently bind to the get slot.
                            node.ref.slot = null;
                        }
                    }

                    if (slot == null)
                    {
                        ObjectValue base = node.ref.getBase();
                        if( base == null )
                        {
                            if( cx.statics.withDepth == -1 ) cx.error(node.pos(), kError_Strict_PlainUndefinedMethod,node.ref.name);
                        }
                        //  Note: Function is dynamic, but methods of a class are MethodClosures, a non-dynamic subclass of Function.
                        //  The compiler doesn't have an internal representation of MethodClosure, though the only reason it would
                        //  need one is for this check.  Rather than modify a lot of existing compiler code to check type.memberOf(cx.functionType())
                        //  instead of type == cx.functionType() (and likely some other less obviuos dependances), we're just going to check
                        //  the builder here to distinguish between a global function and a non-global function.
                        else if (!base.isDynamic() || (base.getType(cx).getTypeValue() == cx.functionType() && !(base.builder instanceof GlobalBuilder)) )
                        {
							if ( (base instanceof TypeValue) || (base.type != null && base.type.getTypeValue() != cx.noType()) )
							{
								String className = (base instanceof TypeValue) ? "Class" : base.getType(cx).getName(cx).toString();

								if (base.hasNameUnqualified(cx, node.ref.name, GET_TOKEN))
									cx.error(node.pos(), kError_InaccessibleMethodReference, node.ref.name, className);
								else
									cx.error(node.pos(), kError_Strict_UndefinedMethod, node.ref.name, className);
							}
                        }
                    }
                    if (slot != null)
                    {
                        // don't permanently bind to the get slot.
                        node.ref.slot = null;
                        slot = null;
                    }
                }
            }
            if( slot == null && node.is_new)
            {
                Slot callSlot = node.ref.getSlot(cx,EMPTY_TOKEN);
                Slot getSlot  = node.ref.getSlot(cx,GET_TOKEN);
                if ( callSlot != null && getSlot != null && getSlot.declaredBy != null &&
                     ((getSlot.declaredBy.builder instanceof ClassBuilder) || (getSlot.declaredBy.builder instanceof InstanceBuilder)) )
                {
                    cx.error(node.pos(), kError_MethodIsNotAConstructor);
                }
            }
            type = type != null ? type : cx.noType().getDefaultTypeInfo();
            if (node.is_new && slot != null && slot.getType() != null)
            {
                    Builder bui = slot.getType().getBuilder();
                    if (bui instanceof ClassBuilder && ((ClassBuilder)bui).is_interface)
                    {
                        cx.error(node.pos(), kError_CannotInstantiateInterface);
                    }
            }
        }
        else
        {
            node.expr.evaluate(cx, this);
        }

        boolean callOfClass = false;
        if ( !node.is_new && node.ref != null )
        {
            Slot newSlot = node.ref.getSlot(cx, NEW_TOKEN);
            if (newSlot != null && newSlot.getType() != null && newSlot.getType().getTypeValue() != cx.noType()) // cn: in !, global Functions have new slots.  Only classes have non-object types for their new slot
                callOfClass = true;
        }

        if (callOfClass)
        {
            // Special treatment of calling a class closure as a function
            if (node.args != null)
            {
                if (cx.useStaticSemantics() && node.args.expected_types == null)
                {
                    node.args.addType(cx.noType().getDefaultTypeInfo());
                    node.args.addDeclStyle(PARAM_Required);
                }
                node.args.evaluate(cx, this);
            }
            else if (cx.useStaticSemantics())
            {
                // explicit cast without an argument, log error if this isn't that ES3 legacy problem "Date()"
                // Watch out for Date() which returns (new Date().toString().  It shouldn't be an error to call Date()
                //  with no arguments.
                if ( !("Date".equals(node.ref.name)))
                    cx.error(node.pos(), kError_WrongNumberOfArguments, "1");
            }
        }
        else
        {
            if (node.args != null)
            {
                if (slot != null)
                {
                    node.args.expected_types = slot.getTypes();
                    node.args.decl_styles = slot.getDeclStyles();
                }
                if (cx.useStaticSemantics() && node.is_new && 
					node.ref != null && node.ref.getSlot(cx,NEW_TOKEN) != null && 
					node.args.decl_styles == null) // calling default constructor of class with no constructor declared, no arguments should be supplied.
                {
                    cx.error(node.pos(), kError_WrongNumberOfArguments, "0");
                }
                node.args.evaluate(cx, this);
            }
             // check if function expects arguments
              else if (slot != null && size(slot.getDeclStyles()) != 0 && slot.getDeclStyles().get(0) == PARAM_Required &&
                       cx.useStaticSemantics())
              {
                 int expected_num_args = slot.getDeclStyles().size();
                 for(; expected_num_args > 0; expected_num_args--)
                 {
                     if (slot.getDeclStyles().at(expected_num_args-1) == PARAM_Required)
                         break;
                 }
                StringBuilder err_arg_buf = new StringBuilder();
                err_arg_buf.append(expected_num_args);
                cx.error(node.pos(), kError_WrongNumberOfArguments, err_arg_buf.toString());
            }

        }

        // a new expression will never result in null, so it's "non-nullable"
        if( node.is_new )
            type = type.getTypeValue().getTypeInfo(false);

        return type.getPrototype();
    }

    public Value evaluate(Context cx, InvokeNode node)
    {
        Slot slot = null;
        TypeValue type;

        if ("[[HasMoreNames]]".equals(node.name))
        {
            node.index = UNARY_HasMoreNames;
            node.args.addType(cx.intType().getDefaultTypeInfo());
            type = cx.intType();
        }
        else if ("[[NextValue]]".equals(node.name))
        {
            node.index = UNARY_NextValue;
            node.args.addType(cx.intType().getDefaultTypeInfo());
            type = cx.noType();
        }
        else if ("[[NextName]]".equals(node.name))
        {
            node.index = UNARY_NextName;
            node.args.addType(cx.intType().getDefaultTypeInfo());
            type = cx.stringType();
        }
        else if ("[[ToXMLString]]".equals(node.name))
        {
            node.index = UNARY_ToXMLString;
            node.args.addType(cx.noType().getDefaultTypeInfo());
            type = cx.stringType();
        }
        else if ("[[ToXMLAttrString]]".equals(node.name))
        {
            node.index = UNARY_ToXMLAttrString;
            node.args.addType(cx.noType().getDefaultTypeInfo());
            type = cx.stringType();
        }
        else if ("[[CheckFilterOperand]]".equals(node.name))
        {
            node.index = UNARY_CheckFilterOp;
            node.args.addType(cx.noType().getDefaultTypeInfo());
            type = cx.noType();
        }
        else
        {
            assert(false); // throw "should not get here";
            type = cx.noType();
        }

        if (node.args != null)
        {
            if (slot != null)
            {
                node.args.expected_types = slot.getTypes();
            }
            node.args.evaluate(cx, this);
        }

        return type.prototype;
    }

    public Value evaluate(Context cx, DeleteExpressionNode node)
    {
        if (node.ref != null)
        {
            node.ref.calcUseDefinitions(cx, rch_bits);
            if( cx.useStaticSemantics() ) // bang
            {
                Slot slot = node.ref.getSlot(cx,GET_TOKEN);
                if( slot == null )
                {
                    ObjectValue base = node.ref.getBase();
                    //  Note: only global Functions are dynamic, but methods of a class are MethodClosures, a non-dynamic subclass of Function.
                    if( base != null && (!base.isDynamic() || (base.getType(cx).getTypeValue() == cx.functionType() && !(base.builder instanceof GlobalBuilder)) ) )
                    {
                        if (base.hasNameUnqualified(cx, node.ref.name, GET_TOKEN))
                            cx.error(node.expr.pos(), kError_InaccessiblePropertyReference, node.ref.name, base.getType(cx).getName(cx).toString());
                        else
                            cx.error(node.expr.pos(), kError_UndefinedProperty,node.ref.name,base.getType(cx).getName(cx).toString());
                    }
                }

                ObjectValue base = node.ref.getBase();
                boolean isDynamic = base != null && base.isDynamic();

                if( slot != null && !in_with && !isDynamic )
                {
                    cx.error(node.expr.pos(), kError_Strict_AttemptToDeleteFixedProperty, node.ref.name);
                }

            }
        }
        else
        {
            // If its not a reference, then evaluate it.
            node.expr.evaluate(cx, this);
        }

        Slot slot;

        {
            ObjectValue global;
            global = cx.builtinScope();
            slot = global.getSlot(cx, SLOT_Global_DeleteOp);

            // Now we know the type expected by the unary operator. Coerce it.
            //node.expr = cx.coerce(node.expr,type,slot.types.size()?slot.types[0]:cx.noType());

            // Save the slot index in the node for later use
            // by the code generator.
            node.slot = slot;
        }

        return slot.getType().getPrototype();
    }

    public Value evaluate(Context cx, GetExpressionNode node)
    {
        Value val;
        if (node.ref != null)
        {
            node.ref.calcUseDefinitions(cx, rch_bits);


            if (node.ref.usedBeforeInitialized())
            {
                Slot s = node.ref.getSlot(cx,GET_TOKEN);
                if (s != null)
                    s.setNeedsInit(true);
            }


            val = node.ref;
            node.ref.getType(cx,GET_TOKEN);
            if( cx.useStaticSemantics() ) // bang
            {
                Slot slot = node.ref.getSlot(cx,GET_TOKEN);
                if( slot == null )
                {
                    ObjectValue base = node.ref.getBase();
                    //  Note: only global Functions are dynamic, but methods of a class are MethodClosures, a non-dynamic subclass of Function.
                    if( base != null && (!base.isDynamic() || (base.getType(cx).getTypeValue() == cx.functionType() && !(base.builder instanceof GlobalBuilder)) ) )
                    {
                        if (base.hasNameUnqualified(cx, node.ref.name, GET_TOKEN))
                            cx.error(node.pos(), kError_InaccessiblePropertyReference, node.ref.name, base.getType(cx).getName(cx).toString());
                        else
                            cx.error(node.pos(), kError_UndefinedProperty,node.ref.name,base.getType(cx).getName(cx).toString());
                    }
                }
            }
        }
        else if( node.base != null && node.getMode()==LEFTBRACKET_TOKEN )
        {
            node.expr.evaluate(cx, this);
            val = cx.noType().prototype;
            if( node.base.type != null )
            {
                TypeValue tv = node.base.type.getTypeValue();
                val = tv.indexed_type != null ? tv.indexed_type.prototype : cx.noType().prototype;
            }
        }
        else
        {
            // If there is no reference, then node.expr is a general
            // expression that needs to be evaluated here.
            node.expr.evaluate(cx,this);
            val = cx.noType().prototype;
        }

        return val;
    }

    public Value evaluate(Context cx, SetExpressionNode node)
    {
        // Without a type annotation, the expected type of the definition
        // is the union of types of all uses of this definition, except if
        // this is an indexed put, then it is Object because we can't be
        // sure we have seen all assignments.

        if (node.base == null && !node.expr.isLValue())
        {
            cx.error(node.pos(),kError_AssignmentToNonRefVar);
        }
        else
        {
            if (node.ref != null)
            {
                if(node.is_initializer)
            	{
	                node.ref.calcUseDefinitions(cx, rch_bits);
	                if (!node.ref.usedBeforeInitialized())
	                {
	                	// If the slot is set before it is declared/initialized we need to init
	                	// it at the top of the method to get the types to agree at branch targets
	                	// This happens with code like:
	                	//
	                	//   if( something() )
	                	//     x = "blah";
	                	//   var x : String = "hi";
	                	//
	                	// We need to init this at the top of the method, otherwise the types for
	                	// x at the end of the if block would be * and String, which wouldn't match
	                	// and would cause a verify error.
	                    Slot s = node.ref.getSlot(cx,GET_TOKEN);
	                    if (s != null)
	                        s.setNeedsInit(true);
	                }
            	}
            	
                Slot slot = node.ref.getSlot(cx,SET_TOKEN);

                node.ref.getType(cx,SET_TOKEN);

                if( slot != null )
                {
                    // need to check var_index to see if this is a setter.  In the case of slots inherited during abc import,
                    //  this will only be accurate for the original slot
                    Slot origSlot = slot;

                    if( origSlot.getVarIndex() < 0 && size(slot.getTypes()) == 1 )
                    {
                        node.args.addType(slot.getTypes().get(0)); // setter, expected type is param type
                    }
                    else
                    {
                        node.args.addType(slot.getType());
                    }
                }
                else
                {
                    node.args.addType(cx.noType().getDefaultTypeInfo());
                }

               
            }
            else if( node.base != null && node.getMode()==LEFTBRACKET_TOKEN )
            {
                node.expr.evaluate(cx, this);
                TypeInfo t = cx.noType().getDefaultTypeInfo();
                if( node.base.type != null )
                {
                    TypeValue tv = node.base.type.getTypeValue();
                    t = tv.indexed_type != null ? tv.indexed_type.getDefaultTypeInfo() : cx.noType().getDefaultTypeInfo();
                }
                node.args.addType(t);
            }
            else
            {
                node.expr.evaluate(cx, this); // Only do this if there is no ref.
                node.args.addType(cx.noType().getDefaultTypeInfo());
            }
        }

//        rch_bits = rch_bits & ~ node.gen_bits;   // temporarily turn off the current gen bits

        Value val = node.args.evaluate(cx, this);
        TypeInfo type = val != null ? val.getType(cx) : cx.noType().getDefaultTypeInfo();

        if ( cx.useStaticSemantics() && node.ref != null )
        {
            Slot slot = node.ref.getSlot(cx,SET_TOKEN);

            int rchkill_bits_count = BitSet.and_count(rch_bits, node.getKillBits());  // number of kill bits that reach this definition, should be zero
            int scope_index = node.ref.getScopeIndex(GET_TOKEN);
            int base_index = cx.getScopes().size()-1;

            if (slot != null && slot.isConst() && slot.getType().getTypeValue() == cx.typeType())
            {
                Node firstArg = node.args.items.get(0);
                // check if its the synthetic assignment invented for a CDN.  Authors can't assing a var directly to a CDN
                if (!(firstArg instanceof ClassDefinitionNode))
                {
                    if (slot.getObjectValue() != null) // slot will only have a value if this is a class slot
                    {
                        cx.error(node.pos(), kError_AssignmentToDefinedClass, node.ref.name);
                    }
                }
            }
            else if (slot != null && slot.isConst() && slot.getType().getTypeValue() == cx.functionType())
            {
                Node firstArg = node.args.items.get(0);

                // check if its the synthetic assignment invented for a FDN.
                if (!(firstArg instanceof FunctionCommonNode && ((FunctionCommonNode)firstArg).def != null) )
                {
                    // if the base type is XML or XMLList, ignore.  The prop may actually evaluate to a non-function at runtime (for instance, .name)
                    boolean isXMLProp = false;
                    ObjectValue base = node.ref.getBase();
                    if (base != null &&
                       (base.getType(cx).getTypeValue() == cx.xmlType() ||
                        base.getType(cx).getTypeValue() == cx.xmlListType()))
                    {
                            isXMLProp = true;
                    }
                    if (!isXMLProp && slot.getObjectValue() != null)
                    {
                        cx.error(node.pos(), kError_AssignmentToDefinedFunction, node.ref.name);
                    }
                }
            }
            else if( slot != null && slot.isConst() && (slot.isImported() || scope_index != base_index || val.hasValue() || rchkill_bits_count > 0) )
            {
                cx.error(node.pos(), kError_AssignmentToConstVar);
            }
            else if( cx.useStaticSemantics() && slot == null )
            {
                // If there is no set but there is a get, then the property is read only. Post an error.
                slot = node.ref.getSlot(cx,GET_TOKEN);
                if ( slot != null )
                {
                    // slot will only have a value if this is a slot for a non-anonymous function
                    if( slot.getType() != null && slot.getType().getTypeValue() == cx.functionType() && slot.getObjectValue() != null )
                    {
                        Node firstArg = node.args.items.get(0);
                        CoerceNode cn = (firstArg instanceof CoerceNode) ? (CoerceNode)firstArg : null;
                        if ( !firstArg.isSynthetic() || (cn != null && !(cn.expr instanceof FunctionCommonNode) ) ) // its not the synthetic assignment invented for a FDN.  Authors can't assing a var directly to a FCN
                        {
                            boolean isXMLProp = false;
                            ObjectValue base = node.ref.getBase();
                            if (base != null &&
                               (base.getType(cx).getTypeValue() == cx.xmlType() ||
                                base.getType(cx).getTypeValue() == cx.xmlListType()))
                            {
                                isXMLProp = true;
                            }
                            if (!isXMLProp)
                            {
                                int pos = node.pos() == 0 ? node.expr.pos() : node.pos();
                                cx.error(pos, kError_AssignmentToDefinedFunction, node.ref.name);
                            }
                        }
                    }
                    else
                    {
                        cx.error(node.pos(), kError_PropertyIsReadOnly);
                    }
                }
                else
                {
                    ObjectValue base = node.ref.getBase();
                    //  Note: only global Functions are dynamic, but methods of a class are MethodClosures, a non-dynamic subclass of Function.
                    if( base != null && (!base.isDynamic() || (base.getType(cx).getTypeValue() == cx.functionType() && !(base.builder instanceof GlobalBuilder)) ) )
                    {
                        if (base.hasNameUnqualified(cx, node.ref.name, GET_TOKEN))
                            cx.error(node.expr.pos(), kError_InaccessiblePropertyReference, node.ref.name, base.getType(cx).getName(cx).toString());
                        else
                            cx.error(node.expr.pos(), kError_UndefinedProperty,node.ref.name,base.getType(cx).getName(cx).toString());
                    }
                }
            }
        }

        cx.setDefType(node.gen_bits, type);

        rch_bits = reset_set(rch_bits, node.getKillBits(), node.getGenBits());

        if (node.ref != null)
        {
            node.ref.calcUseDefinitions(cx, rch_bits);
        }

        node.value_type = type;   // for use at code gen time.

        return val;
    }

    public Value evaluate(Context cx, ThisExpressionNode node)
    {
        // What 'this' is, depends on where it is:
        // + instance method or accessor - this is the second from end of scope chain
        // + global code - this is the global object
        // + function - is passed in by the caller, its ct type is object
        // All error cases should have been caught by flow analyzer

        ObjectValue this_value = null;
        int scope_depth = cx.getScopes().size()-1;

        switch (this_contexts.last())
        {
            case instance_this:
                this_value = cx.scope(scope_depth - 1); // If this is an instance method, scope is second from top
                break;
            case global_this:
                this_value = cx.scope(0);
                break;
            default:
                this_value = ObjectValue.objectPrototype;
                break;
        }

        return this_value;
    }

    public Value evaluate(Context cx, LiteralBooleanNode node)
    {
        return node.value ? cx.booleanTrue() : cx.booleanFalse();
    }

    public Value evaluate(Context cx, LiteralNumberNode node)
    {
        // getValueOfNumberLiteral sets node.type as side effect.  In order to determine the type,
        //  the emitter has to first convert the string into a number to see if it fits
        //  into its int representation.
        TypeValue[] type = new TypeValue[1];
        node.numericValue = cx.getEmitter().getValueOfNumberLiteral( node.value, type, node.numberUsage);
        node.type = type[0];
        ObjectValue ret = new ObjectValue(node.value, node.type);
        ret.setNumberUsage(node.numberUsage);
        return ret;
    }

    public Value evaluate(Context cx, LiteralStringNode node)
    {
        return new ObjectValue(node.value, cx.stringType().getTypeInfo(false));  // literal strings can't result in null
    }

    public Value evaluate(Context cx, LiteralNullNode node)
    {
        return cx.nullType().prototype;
    }

    public Value evaluate(Context cx, LiteralRegExpNode node)
    {
        return cx.regExpType().prototype;
    }

    public Value evaluate(Context cx, ParenExpressionNode node)
    {
        assert(false); // throw;
        return null;
    }

    public Value evaluate(Context cx, ParenListExpressionNode node)
    {
        assert(false); // throw;
        return null;
    }

    public Value evaluate(Context cx, LiteralObjectNode node)
    {

        if (node.fieldlist != null)
        {
            node.fieldlist.evaluate(cx, this);
        }

        return cx.objectType().prototype;
    }

    public Value evaluate(Context cx, LiteralFieldNode node)
    {

        {
            Value val;
            TypeInfo[] type;

            val = node.name.evaluate(cx, this);
            type = new TypeInfo[]{val != null ? val.getType(cx) : null};
            node.name = cx.coerce(node.name,type,cx.noType().getDefaultTypeInfo()); // ISSUE: the real type is string + number
        }

        {
            Value val;
            TypeInfo[] type;

            val = node.value.evaluate(cx, this);
            type = new TypeInfo[]{val != null ? val.getType(cx) : null};
            // Give object fields a standard ecma type.
            node.value = cx.coerce(node.value, type, cx.noType().getDefaultTypeInfo());
        }

        return cx.noType().prototype;
    }

    public Value evaluate(Context cx, LiteralArrayNode node)
    {
        if (node.elementlist != null)
        {
            node.value = node.elementlist.evaluate(cx, this);
        }
        return cx.arrayType().prototype;
    }
    
    public Value evaluate(Context cx, LiteralVectorNode node)
    {
    	Value initializer_typeref = node.type.evaluate(cx, this);
    	Value intializer_typevalue = initializer_typeref.getValue(cx);
    	
    	if ( cx.useStaticSemantics() )
    	{
	        if ( intializer_typevalue == null)
	        {
	        	if ( initializer_typeref.isReference() )
	        	{
	        		cx.error(node.type.pos(), kError_UnknownType, ((ReferenceValue)initializer_typeref).getDiagnosticTypeName());
	        	}
	        	else
	        	{
	        		cx.error(node.type.pos(), kError_UnknownType);
	        	}
	        }
    	}
 
        if (node.elementlist != null)
        {
    		if ( intializer_typevalue instanceof TypeValue )
    		{
        		TypeInfo vector_element_type = ((TypeValue)intializer_typevalue).indexed_type.getDefaultTypeInfo();
        		
    			for ( int i = size(node.elementlist.expected_types); i < node.elementlist.size(); i++ )
    			{
    				node.elementlist.addType(vector_element_type);
    				node.elementlist.addDeclStyle(PARAM_Required);
    			}
    			
    			if ( cx.useStaticSemantics() )
    			{
    				checkLiteralConversion(cx, vector_element_type.getTypeValue(), node.elementlist);
    			}
    		}

            node.value = node.elementlist.evaluate(cx, this);
        }
        return initializer_typeref;
    }


    public Value evaluate(Context cx, MemberExpressionNode node)
    {
        Value val;

        if (node.base != null)
        {
            Value base = node.base.evaluate(cx, this);
            // cn: if base is a conditional or otherwise untypeable, force coerce to Object.
            //  i.e. (a > b ? "1" : 22.22).toString()
            TypeInfo type = null;
            if (base == null)
            {
                TypeInfo[] actual = new TypeInfo[]{null};
                node.base = cx.coerce(node.base,actual,cx.noType().getDefaultTypeInfo(),false,true);
                type = cx.noType().getDefaultTypeInfo();
                if ( node.ref != null )
                    node.ref.setBase(type.getPrototype());
            }
            else
                type = base.getType(cx);

            if (base != null )
            {
                if(node.ref != null )
                {
                    if (type.getTypeValue() == cx.typeType())
                    {
                        val = base.getValue(cx);
                        ObjectValue obj = (val instanceof ObjectValue) ? (ObjectValue) val : null;
                        node.ref.setBase(obj);
                    }
                    else
                    {
                        node.ref.setBase(type.getPrototype());
                    }

                    if (type.isInterface())
                    {
                        if (!node.ref.isQualified())
                        {
                            // If the base of the reference is an interface type,
                            // add all the interface namespaces to the reference,
                            // if the reference is unqualified.
                            InterfaceWalker interfaceWalker = new InterfaceWalker(type.getTypeValue());
                            Namespaces namespaces = new Namespaces();
                            while (interfaceWalker.hasNext())
                            {
                                namespaces.add(interfaceWalker.next().type.getTypeValue());
                            }
                            node.ref.setImmutableNamespaces(cx.statics.internNamespaces.intern(namespaces));
                        }
                    }
                }
                else if( node.selector.getMode() == LEFTBRACKET_TOKEN )
                {
                    node.selector.setBase(type.getPrototype());
                }
            }
            // C: NullPointerException here?? It's weird that we call node.base.evaluate() again!
            //    and we don't do null pointer check here like we do above...
//            TypeValue[] actual = new TypeValue[]{node.base.evaluate(cx, this).getType(cx)};
//            node.base = cx.coerce(node.base, actual, cx.noType());
        }
        else
        if( node.ref != null )
        {
            if (cx.useStaticSemantics())
            {
                ObjectValue base = node.ref.getBase();
                boolean isDynamic = false;

                if (base != null)
                {
                    //  Note: only global Functions are dynamic, but methods of a class are MethodClosures, a non-dynamic subclass of Function.
                    isDynamic = base.isDynamic() && !(base.getType(cx).getTypeValue() == cx.functionType() && (base.builder instanceof GlobalBuilder));
                }


                int refType = !(node.selector instanceof SetExpressionNode) ? GET_TOKEN : SET_TOKEN;
                Slot slot = node.ref.getSlot(cx,refType);
                if( slot == null )
                {
                    //  cn: Function is declared dynamic in Function.as, but its not dynamic in !
                    if( !in_with && !isDynamic )
                    {
                        ObjectList<ObjectValue> scopes = cx.getScopes();
                        int x;
                        for(x=0;x<scopes.size();x++)
                        {
                            ObjectValue scope = scopes.get(x);
                            if ( (scope.builder) instanceof InstanceBuilder &&
                                 !(node.selector.expr instanceof QualifiedIdentifierNode) &&  // If it was qualified then fall through to the normal unfound property error
                                 scope.hasNameUnqualified(cx, node.ref.name, GET_TOKEN)  )
                            {
                                cx.error(node.selector.expr.pos(), kError_InaccessiblePropertyReference,node.ref.name, scope.type.getName(cx).toString());
                                break;
                            }
                        }
                        // bad function calls have already been reported in CallExpressionNode
                        if (x == scopes.size() && !(node.selector instanceof CallExpressionNode))
                        {
                            String qualified_pkg_name = null;
                            if( node.selector.expr instanceof QualifiedIdentifierNode )
                            {
                                ObjectValue namespace = node.ref.namespaces.at(0);
                                if( namespace.isPackage() )
                                {
                                    qualified_pkg_name = namespace.name;
                                }
                            }
                            if( node.selector instanceof SetExpressionNode )
                            {
                                slot = node.ref.getSlot(cx, GET_TOKEN);
                                if( !( slot != null && slot.getType()!= null && slot.getType().getTypeValue() == cx.functionType() && slot.getObjectValue() != null) )
                                {
                                    if( qualified_pkg_name != null )
                                        cx.error(node.selector.expr.pos(), kError_UnfoundPackageProperty, node.ref.name, qualified_pkg_name);
                                    else
                                        // Attempting to set a function will be caught by the SetExpressionNode
                                        cx.error(node.selector.expr.pos(), kError_UnfoundProperty,node.ref.name);
                                }
                            }
                            else
                            {
                                if( qualified_pkg_name != null )
                                    cx.error(node.selector.expr.pos(), kError_UnfoundPackageProperty, node.ref.getDiagnosticTypeName(), qualified_pkg_name);
                                else
                                    cx.error(node.selector.expr.pos(), kError_UnfoundProperty,node.ref.getDiagnosticTypeName());
                            }
                        }
                    }
                }
            }
            if( node.selector.is_package && node.ref.getSlotIndex(GET_TOKEN) < 0 )
            {
                cx.error(node.selector.expr.pos(),kError_IllegalPackageReference,node.ref.name);
            }
        }

        val = node.selector.evaluate(cx, this);

       // If the base is an XML or XMLIST, return type * to avoid possibly bogus -strict type coercion errors.
        if (node.base != null && node.base instanceof MemberExpressionNode)
        {
            MemberExpressionNode m = (MemberExpressionNode)(node.base);
            Slot s = (m.ref != null) ? m.ref.getSlot(cx,GET_TOKEN) : null;
            TypeInfo ti = s != null ? s.getType() : null;
            TypeValue slot_type = ti != null ? ti.getTypeValue() : null;
            if (slot_type == cx.xmlType() || slot_type == cx.xmlListType())
            {
                return cx.noType().prototype; //  a property like .name may resolve to a method slot, but might actually be refering to a dynamically defined xml attribute or child
            }
        }

        return val;
    }

    public Value evaluate(Context cx, UnaryExpressionNode node)
    {
        int slot_index = 0;
        Value val = node.expr.evaluate(cx, this);
        TypeInfo[] type = new TypeInfo[1];
        
        type[0] = (val != null) ? val.getType(cx) : null;
        
        TypeValue currentNumberType = cx.doubleType();
        if (node.numberUsage != null)
        	switch (node.numberUsage.get_usage()) {
         	case NumberUsage.use_int:
        		currentNumberType = cx.intType();
        		break;
        	case NumberUsage.use_uint:
        		currentNumberType = cx.uintType();
        		break;
        	case NumberUsage.use_decimal:
        		currentNumberType = cx.decimalType();
        		break;
        	case NumberUsage.use_double:
        	case NumberUsage.use_Number:
        	default:
        		currentNumberType = cx.doubleType();
        	}

        switch (node.op)
        {
            case VOID_TOKEN:
                slot_index = SLOT_Global_VoidOp;
                break;
            case TYPEOF_TOKEN:
                slot_index = SLOT_Global_TypeofOp;
                break;
            case PLUS_TOKEN:
                slot_index = SLOT_Global_UnaryPlusOp;
                cx.coerce(node.expr,type,currentNumberType.getDefaultTypeInfo());
                break;
            case MINUS_TOKEN:
                slot_index = SLOT_Global_UnaryMinusOp;
                cx.coerce(node.expr,type,currentNumberType.getDefaultTypeInfo());
                break;
            case BITWISENOT_TOKEN:
                slot_index = SLOT_Global_BitwiseNotOp;
                cx.coerce(node.expr,type,currentNumberType.getDefaultTypeInfo());
                break;
            case NOT_TOKEN:
                slot_index = SLOT_Global_LogicalNotOp;
                cx.coerce(node.expr,type,cx.booleanType().getDefaultTypeInfo());
                break;
            default:
                cx.internalError("unrecognized unary operator");
                break;
        }

        if( node.op == VOID_TOKEN )
        {
            val = cx.voidType().prototype;
        }
        else
        {
            if (val != null)
            {
            	//  tharwood 7/28/2008: if the value can be further evaluated, 
            	//  that value usually has the same or a more specific type. 
            	//  However, the secondary value may be undefined, 
            	//  in which case avm uses the type of the original value.  
            	//  Mimic that logic here. 
            	Value constVal = val.getValue(cx);
	                
                if ( constVal != null )
                {
                	TypeInfo constValType = constVal.getType(cx);
                	
                	if ( !constValType.getTypeValue().equals(cx.voidType()))
                	{
                		type[0] = constValType;
                	}
                }   
            }
            else
            {
            	type[0] = null;
            }

            Slot slot;

            {
                ObjectValue global = cx.builtinScope();
                if (type[0] != null && type[0].getTypeValue() != cx.uintType()) // overloading not working correctly for uints
                    slot_index  = global.getOverloadIndex(cx,slot_index,type[0].getTypeValue());
                
                slot = global.getSlot(cx, slot_index);

                // Now we know the type expected by the unary operator. Coerce it.
                //  cn: (but not if node.op == typeof.  typeof should return 'undefined' for an
                //  undefined variable,  don't try to coerce the potentially undefined expr to Object).
                if (node.op != TYPEOF_TOKEN)
                    node.expr = cx.coerce(node.expr, type, size(slot.getTypes()) != 0 ? slot.getTypes().get(0) : null);

                // Save the slot index in the node for later use
                // by the code generator.
                node.slot = slot;
            }

            val = slot.getType().getPrototype();
        }
        return val;
    }

    public Value evaluate(Context cx, IncrementNode node)
    {
        Value val = node.expr.evaluate(cx, this);
        int mode = node.getMode();
        if( !(mode == DOT_TOKEN || mode == EMPTY_TOKEN) )
        {
            val = null;
        }

        TypeInfo type = val != null ? val.getType(cx) : null;

        if (node.ref != null)
        {
            node.ref.calcUseDefinitions(cx, rch_bits);
            Slot slot = node.ref.getSlot(cx,GET_TOKEN);
            if( cx.useStaticSemantics() ) // bang
            {
                if( slot == null )
                {
                    ObjectValue base = node.ref.getBase();
                    //  cn: Function is declared dynamic in Function.as, but its not dynamic in !

                    if( base != null && (!base.isDynamic() || (base.getType(cx).getTypeValue() == cx.functionType() && !(base.builder instanceof GlobalBuilder))) )
                    {
                        if (base.hasNameUnqualified(cx, node.ref.name, GET_TOKEN))
                            cx.error(node.pos(), kError_InaccessiblePropertyReference, node.ref.name, base.getType(cx).getName(cx).toString());
                        else
                            cx.error(node.pos(), kError_UndefinedProperty,node.ref.name,base.getType(cx).getName(cx).toString());
                    }
                }
            }

            if (slot != null &&
            	!(slot instanceof VariableSlot) && // FIXME: tpr added this since var's don't get a set slot,   
            	node.ref.getSlot(cx,SET_TOKEN) == null)
            {
                cx.error(node.pos(), node.op == PLUSPLUS_TOKEN ? kError_InvalidIncrementOperand : kError_InvalidDecrementOperand);
            }
        }
        else
        {
            QualifiedExpressionNode qen = node.getIdentifier() instanceof QualifiedExpressionNode? (QualifiedExpressionNode)node.getIdentifier() : null;
            if (qen != null && qen.nss != null )
            {
                cx.error(node.pos(), node.op == PLUSPLUS_TOKEN ? kError_InvalidIncrementOperand : kError_InvalidDecrementOperand);
                     // this is a case we just don't handle. might need a more descriptive message
            }

        }
        ObjectValue global = cx.builtinScope();
        int slot_index = 0;
        switch (node.op)
        {
            case PLUSPLUS_TOKEN:
                // [ed] issue re-enable incrementlocal only when no coersion is needed
                //slot_index = (base_index != 0 && base_index == scope_depth) ? SLOT_Global_IncrementLocalOp : SLOT_Global_IncrementOp;
                slot_index = SLOT_Global_IncrementOp;
                break;
            case MINUSMINUS_TOKEN:
                //slot_index = (base_index != 0 && base_index == scope_depth) ? SLOT_Global_DecrementLocalOp : SLOT_Global_DecrementOp;
                slot_index = SLOT_Global_DecrementOp;
                break;
            default:
                assert(false); // throw "invalid unary operator";
        }

        if (type != null && type.getTypeValue() != cx.uintType()) // overloading not working correctly for uints
            slot_index  = global.getOverloadIndex(cx,slot_index,type.getTypeValue());
        node.slot = global.getSlot(cx, slot_index);

        Slot s = val instanceof ReferenceValue ? ((ReferenceValue)val).getSlot(cx): null;
        TypeInfo atype[] = new TypeInfo[1];
        atype[0] = s != null ? s.getType() : val!=null ? val.getType(cx) : cx.noType().getDefaultTypeInfo();      // get the static type from the reference value, or literal

        
        TypeValue currentNumberType = cx.doubleType();
        if (node.numberUsage != null)
        	switch (node.numberUsage.get_usage()) {
         	case NumberUsage.use_int:
        		currentNumberType = cx.intType();
        		break;
        	case NumberUsage.use_uint:
        		currentNumberType = cx.uintType();
        		break;
        	case NumberUsage.use_decimal:
        		currentNumberType = cx.decimalType();
        		break;
        	case NumberUsage.use_double:
        	case NumberUsage.use_Number:
        	default:
        		currentNumberType = cx.doubleType();
        	}
        cx.coerce(node.expr,atype,currentNumberType.getDefaultTypeInfo());

        return type != null ? type.getPrototype() : null;
    }

    public Value evaluate(Context cx, BinaryExpressionNode node)
    {
        Value val = null;
        Value lhsval = null;
        Value rhsval = null;
        TypeInfo resultType = null;

        TypeInfo[] lhstype = new TypeInfo[]{ null };
        TypeInfo[] rhstype = new TypeInfo[]{ null };
        if (node.lhs != null)
        {
            lhsval = node.lhs.evaluate(cx,this);
            if (lhsval != null)
            {
                Value constVal = lhsval.getValue(cx);
                Slot s = lhsval instanceof ReferenceValue ? ((ReferenceValue)lhsval).getSlot(cx): null;
                lhstype[0] = s != null ? s.getType():lhsval.getType(cx);      // get the static type from the reference value, or literal
                lhsval = constVal!=null&&constVal.hasValue()?constVal:null;
            }
        }
        if (node.rhs != null)
        {
            rhsval = node.rhs.evaluate(cx,this);
            if (rhsval != null)
            {
                Value constVal = rhsval.getValue(cx);
                Slot s = rhsval instanceof ReferenceValue ? ((ReferenceValue)rhsval).getSlot(cx): null;
                rhstype[0] = s != null ? s.getType():rhsval.getType(cx);      // get the static type from the reference value, or literal
                rhsval = constVal!=null&&constVal.hasValue()?constVal:null;

                if (node.op == AS_TOKEN)     // save rhsval as result of "as"
                {
                    TypeValue typeval = (constVal instanceof TypeValue) ? (TypeValue)constVal : cx.objectType();
                    resultType = typeval.getDefaultTypeInfo();
                }
            }
        }

        int slot_index = 0;


        if (cx.useStaticSemantics() && lhstype[0] != null && rhstype[0] != null ) // null types are o.k., they mean don't do type checking or op-code overriding.
        {
            switch(node.op)
            {
                // check for comparisions between incompatable types
                case EQUALS_TOKEN:
                case NOTEQUALS_TOKEN:
                case LESSTHAN_TOKEN:
                case GREATERTHAN_TOKEN:
                case LESSTHANOREQUALS_TOKEN:
                case GREATERTHANOREQUALS_TOKEN:
                case STRICTNOTEQUALS_TOKEN:
                case STRICTEQUALS_TOKEN:

                    if ( lhstype[0].getTypeValue() == cx.noType() || rhstype[0].getTypeValue() == cx.noType() ||
                         lhstype[0].getTypeValue() == cx.booleanType() || rhstype[0].getTypeValue() == cx.booleanType() ||
                         lhstype[0].isInterface()      || rhstype[0].isInterface() ||
                         lhstype[0].includes(cx,rhstype[0]) || rhstype[0].includes(cx,lhstype[0]) )
                    {
                        // no problem
                        // why boolean?  since everyting implicitly converts to boolean,
                        //  var s:string = "",
                        //  if (s) {} // should be equivalent to
                        //  if (s == true) { }
                    }
                    // check comparision between null and un-nullable type
                    else if (lhstype[0].getTypeValue() == cx.nullType() || rhstype[0].getTypeValue() == cx.nullType())
                    {
                        if (lhstype[0].getTypeValue() == cx.nullType() &&
                            (rhstype[0].getTypeValue().isNumeric(cx)   || rhstype[0].getTypeValue() == cx.booleanType() ))
                        {
                            cx.error(node.pos(), kError_IncompatableValueComparison, lhstype[0].getName(cx).toString(), rhstype[0].getName(cx).toString());
                        }
                            // yes, this could be combined with the above, but it would be hard to read
                        else if (rhstype[0].getTypeValue() == cx.nullType() &&
                                 (lhstype[0].getTypeValue().isNumeric(cx)   || lhstype[0].getTypeValue() == cx.booleanType() ))
                        {
                            cx.error(node.pos(), kError_IncompatableValueComparison, lhstype[0].getName(cx).toString(), rhstype[0].getName(cx).toString());
                        }
                        // else no problem
                    }
                    // E4X allows  XML to be compared directly with Strings
                    else if ( (lhstype[0].getTypeValue() == cx.xmlType() && rhstype[0].getTypeValue() == cx.stringType()) ||
                         (rhstype[0].getTypeValue() == cx.stringType() && lhstype[0].getTypeValue() == cx.xmlType()) )
                    {
                        // no problem, <a>test</a> == "test"; // is true
                    }
                    // Check for comparision between unrelated types (unless its between number types)
                    else if ( !((lhstype[0].getTypeValue().isNumeric(cx)) && (rhstype[0].getTypeValue().isNumeric(cx))) )
                    {
                        cx.error(node.pos(), kError_IncompatableValueComparison, lhstype[0].getName(cx).toString(), rhstype[0].getName(cx).toString());
                    }

                    break;
            }
        }

        TypeValue lhstypeval = lhstype[0] != null ? lhstype[0].getTypeValue() : null;
        TypeValue rhstypeval = rhstype[0] != null ? rhstype[0].getTypeValue() : null;
        
        TypeValue currentNumberType = cx.doubleType();
        if (node.numberUsage != null)
        	switch (node.numberUsage.get_usage()) {
         	case NumberUsage.use_int:
        		currentNumberType = cx.intType();
        		break;
        	case NumberUsage.use_uint:
        		currentNumberType = cx.uintType();
        		break;
        	case NumberUsage.use_decimal:
        		currentNumberType = cx.decimalType();
        		break;
        	case NumberUsage.use_double:
        	case NumberUsage.use_Number:
        	default:
        		currentNumberType = cx.doubleType();
        	}


        // now process op as normal
        switch (node.op)
        {
            case MULT_TOKEN:
                slot_index = SLOT_Global_MultiplyOp;
                // RES this is probably wrong with uint as a full citizen
                if ((lhstypeval == cx.intType() || lhstypeval == cx.uintType()) && (rhstypeval == cx.intType() || rhstypeval == cx.uintType()))
                {
                    resultType = cx.intType().getDefaultTypeInfo();
                }
                cx.coerce(node.lhs,lhstype,currentNumberType);
                cx.coerce(node.rhs,rhstype,currentNumberType);
                break;
            case DIV_TOKEN:
                slot_index = SLOT_Global_DivideOp;
                cx.coerce(node.lhs,lhstype,currentNumberType);
                cx.coerce(node.rhs,rhstype,currentNumberType);
                break;
            case MODULUS_TOKEN:
                slot_index = SLOT_Global_ModulusOp;
                cx.coerce(node.lhs,lhstype,currentNumberType);
                cx.coerce(node.rhs,rhstype,currentNumberType);
                break;
            case PLUS_TOKEN:
                if( lhsval != null && rhsval != null && lhsval.hasValue() && rhsval.hasValue() )
                {
                    // cn: see bug 124260.  A literal number might not always print as its compile time string rep
                    /* cn actually, this is causing errors even when lhs and rhs are strings
                    if( (lhstype[0] == cx.stringType() && rhstype[0] != cx.numberType()) ||
                        (rhstype[0] == cx.stringType() && lhstype[0] != cx.numberType()))
                    {
                        node.lhs = cx.getNodeFactory().literalString(lhsval.toString()+rhsval.toString(),0);
                        node.op = EMPTY_TOKEN;
                        val = node.lhs.evaluate(cx,this);  // get the folded value
                    }
                    */
                }
                slot_index = SLOT_Global_BinaryPlusOp;
                if ( (lhstypeval == cx.xmlListType() || lhstypeval == cx.xmlType()) &&
                     (rhstypeval == cx.xmlListType() || rhstypeval == cx.xmlType()))
                {
                    resultType = cx.xmlListType().getDefaultTypeInfo();
                }
                else if ( (lhstypeval != null) && (lhstypeval.isNumeric(cx)) &&
                          (rhstypeval != null) && (rhstypeval.isNumeric(cx)) )
                {
                    resultType = currentNumberType.getDefaultTypeInfo();
                }
                else if ( lhstypeval == cx.stringType() || rhstypeval == cx.stringType() ) // anything + a string is a string.
                {
                    resultType = cx.stringType().getDefaultTypeInfo();
                }
                else
                {
                    resultType = cx.noType().getDefaultTypeInfo(); // can't tell.  Could be number, string or xmllist
                }

                break;
            case MINUS_TOKEN:
                slot_index = SLOT_Global_BinaryMinusOp;
                cx.coerce(node.lhs,lhstype,currentNumberType);
                cx.coerce(node.rhs,rhstype,currentNumberType);
                if ((lhstypeval == cx.intType() || lhstypeval == cx.uintType()) && (rhstypeval == cx.intType() || rhstypeval == cx.uintType()))
                    resultType = cx.intType().getDefaultTypeInfo();
                break;
            case LEFTSHIFT_TOKEN:
                slot_index = SLOT_Global_LeftShiftOp;
                cx.coerce(node.lhs,lhstype,currentNumberType);
                cx.coerce(node.rhs,rhstype,currentNumberType);
                break;
            case RIGHTSHIFT_TOKEN:
                slot_index = SLOT_Global_RightShiftOp;
                cx.coerce(node.lhs,lhstype,currentNumberType);
                cx.coerce(node.rhs,rhstype,currentNumberType);
                break;
            case UNSIGNEDRIGHTSHIFT_TOKEN:
                slot_index = SLOT_Global_UnsignedRightShiftOp;
                cx.coerce(node.lhs,lhstype,currentNumberType);
                cx.coerce(node.rhs,rhstype,currentNumberType);
                break;
            case LESSTHAN_TOKEN:
                slot_index = SLOT_Global_LessThanOp;
                break;
            case GREATERTHAN_TOKEN:
                slot_index = SLOT_Global_GreaterThanOp;
                break;
            case LESSTHANOREQUALS_TOKEN:
                slot_index = SLOT_Global_LessThanOrEqualOp;
                break;
            case GREATERTHANOREQUALS_TOKEN:
                slot_index = SLOT_Global_GreaterThanOrEqualOp;
                break;
            case INSTANCEOF_TOKEN:
                slot_index = SLOT_Global_InstanceofOp;
                break;
            case IN_TOKEN:
                slot_index = SLOT_Global_InOp;
                break;
            case IS_TOKEN:
                slot_index = SLOT_Global_IsLateOp;
                cx.coerce(node.rhs,rhstype,cx.typeType());
                break;
            case AS_TOKEN:
                slot_index = SLOT_Global_AsLateOp;
                cx.coerce(node.rhs,rhstype,cx.typeType());
                break;
            case EQUALS_TOKEN:
                slot_index = SLOT_Global_EqualsOp;
                break;
            case NOTEQUALS_TOKEN:
                slot_index = SLOT_Global_NotEqualsOp;
                break;
            case STRICTEQUALS_TOKEN:
                slot_index = SLOT_Global_StrictEqualsOp;
                break;
            case STRICTNOTEQUALS_TOKEN:
                slot_index = SLOT_Global_StrictNotEqualsOp;
                break;
            case BITWISEAND_TOKEN:
                slot_index = SLOT_Global_BitwiseAndOp;
                cx.coerce(node.lhs,lhstype,currentNumberType);
                cx.coerce(node.rhs,rhstype,currentNumberType);
                break;
            case BITWISEXOR_TOKEN:
                slot_index = SLOT_Global_BitwiseXorOp;
                cx.coerce(node.lhs,lhstype,currentNumberType);
                cx.coerce(node.rhs,rhstype,currentNumberType);
                break;
            case BITWISEOR_TOKEN:
                slot_index = SLOT_Global_BitwiseOrOp;
                cx.coerce(node.lhs,lhstype,currentNumberType);
                cx.coerce(node.rhs,rhstype,currentNumberType);
                break;
            case LOGICALAND_TOKEN:
                slot_index = SLOT_Global_LogicalAndOp;

                if (lhstype[0] == rhstype[0])
                    resultType = lhstype[0];
                /*
                else if (lhstype[0] != null && lhstype[0] != cx.noType() && rhstype[0] != null && rhstype[0] != cx.noType())
                    resultType = cx.objectType(); // if its not null or *, then we at least know it can't be undefined.
                */
                break;

            case LOGICALOR_TOKEN:
                slot_index = SLOT_Global_LogicalOrOp;
                if (lhstype[0] == rhstype[0])
                    resultType = lhstype[0];
                /*
                else if (lhstype[0] != null && lhstype[0] != cx.noType() && rhstype[0] != null && rhstype[0] != cx.noType())
                    resultType = cx.objectType(); // if its not null or *, then we at least know it can't be undefined.
                */
                break;

            case EMPTY_TOKEN:
                // do nothing, already been folded
                break;
            default:
                cx.internalError("unrecognized binary operator");
                break;
        }

        Slot slot;

        if( node.op != EMPTY_TOKEN )
        {
            // ObjectValue global = null;

            ObjectValue global = cx.builtinScope();
            if (lhstypeval != cx.uintType() && rhstypeval != cx.uintType() ) // overloading not working correctly for uints
            {
                slot_index  = global.getOverloadIndex(cx, slot_index, lhstypeval, rhstypeval);
            }
            slot = global.getSlot(cx, slot_index);

            // Now we know the types expected by the overloaded operator.
            // Coerce the operands.
            node.lhs = cx.coerce(node.lhs, lhstype, size(slot.getTypes()) > 0 ? slot.getTypes().get(0) : null);
            node.rhs = cx.coerce(node.rhs, rhstype, size(slot.getTypes()) > 0 ? slot.getTypes().get(1) : null);

            node.lhstype = lhstype[0];
            node.rhstype = rhstype[0];

            // Save the slot index in the node for later use
            // by the code generator.
            node.slot = slot;

            if( lhsval instanceof ObjectValue && rhsval instanceof ObjectValue )
            {
                val = computeBinaryExpr(cx,node.op,(ObjectValue)lhsval,(ObjectValue)rhsval, node.numberUsage);
            }
            else if (resultType != null)
            {
                val = resultType.getPrototype();
            }
            else
            {
                val = slot.getType().getPrototype();
            }
        }

        return val;
    }


    public Value computeBinaryExpr(Context cx, int op, ObjectValue lv, ObjectValue rv, NumberUsage numberUsage)
    {
        ObjectValue val = null;
        TypeInfo lt = lv.getType(cx);
        TypeInfo rt = rv.getType(cx);

        TypeValue ltval = lt.getTypeValue();
        TypeValue rtval = rt.getTypeValue();

        switch ( op )
        {
            case MINUS_TOKEN:
            case MULT_TOKEN:
            case DIV_TOKEN:
            case PLUS_TOKEN:
            case MODULUS_TOKEN:
            {
                if( (ltval != null) && ltval.isNumeric(cx) && rtval.isNumeric(cx) )
                {
                    TypeValue[] ltype = new TypeValue[1];
                    TypeValue[] rtype = new TypeValue[1];
                    NumberConstant lval = cx.getEmitter().getValueOfNumberLiteral( lv.getValue(), ltype, numberUsage);
                    NumberConstant rval = cx.getEmitter().getValueOfNumberLiteral( rv.getValue(), rtype, numberUsage);
                    
                    boolean forceType = true;
                    int usage = numberUsage.get_usage();
                    if (usage == NumberUsage.use_Number ) {
                       	/* in this case, the types of the operands determine the type of the result */
                    	forceType = false;
                    	if (cx.statics.es4_numerics && ((ltype[0] == cx.decimalType()) || (rtype[0] == cx.decimalType()))) {
                    		usage = NumberUsage.use_decimal;
                    	}
                    	//else usage = Context.NU_DOUBLE; // we could overflow
                    	
                    	else if ((ltype[0] == cx.doubleType()) || (rtype[0] == cx.doubleType()) ||
                    			(ltype[0] == cx.numberType()) || (rtype[0] == cx.numberType())) {
                    		usage = NumberUsage.use_double;
                    	}
                    	else if ((ltype[0] == cx.intType()) || (rtype[0] == cx.uintType())) {
                    		if (lval.intValue() >= 0)
                    			usage = NumberUsage.use_uint;
                    		else
                    			usage = NumberUsage.use_double;
                    	}
                    	else if ((ltype[0] == cx.uintType()) || (rtype[0] == cx.intType())) {
                    		if (rval.intValue() >= 0)
                    			usage = NumberUsage.use_uint;
                    		else
                    			usage = NumberUsage.use_double;
                    	}
                    	else
                    		usage = NumberUsage.use_int;

                        if( !cx.statics.es4_numerics )
                            usage = NumberUsage.use_double;
                    }
                    switch (usage) {
                    case NumberUsage.use_decimal: {
                    	Decimal128 d = Decimal128.NaN;
                    	Decimal128 ld = lval.decimalValue();
                    	Decimal128 rd = rval.decimalValue();
                    	currentDecimalContext.setPrecision(numberUsage.get_precision());
                    	currentDecimalContext.setRoundingMode(numberUsage.get_java_roundingMode());
                    	switch ( op ) {
                    	case MINUS_TOKEN:
                    		d = ld.subtract(rd, currentDecimalContext);
                    		break;
                    	case PLUS_TOKEN:
                    		d = ld.add(rd, currentDecimalContext);
                    		break;
                    	case MULT_TOKEN:
                    		d = ld.multiply(rd, currentDecimalContext);
                    		break;
                    	case DIV_TOKEN:
                    		d = ld.divide(rd, currentDecimalContext);
                    		break;
                    	case MODULUS_TOKEN:
                    		d = ld.remainder(rd, currentDecimalContext);
                    		break;
                    	default: // shouldn't be possible
                    	}
                    	// we won't be here unless cx.statics.es4_numerics is true
                    	val = new ObjectValue(d.toString() + "m", cx.decimalType());
                    	break;
                    } // case NU_DECIMAL
                    case NumberUsage.use_double: {
                    	double d = Double.NaN;
                    	double ld = lval.doubleValue();
                    	double rd = rval.doubleValue();
                    	switch ( op ) {
                    	case MINUS_TOKEN:
                    		d = ld - rd;
                    		break;
                    	case PLUS_TOKEN:
                    		d = ld + rd;
                    		break;
                    	case MULT_TOKEN:
                    		d = ld * rd;
                    		break;
                    	case DIV_TOKEN:
                    		d = ld / rd;
                    		break;
                    	case MODULUS_TOKEN:
                    		d = ld % rd;
                    		break;
                    	default: // shouldn't be possible
                    	}
                    	val = new ObjectValue(Double.toString(d), cx.doubleType());
                    	break;
                    } // case NU_DOUBLE
                    case NumberUsage.use_int: {
                    	int i = 0;
                    	int li = lval.intValue();
                    	int ri = rval.intValue();
                    	double d = 0;
                    	double ld = lval.doubleValue();
                    	double rd = rval.doubleValue();
                    	switch ( op ) {
                    	case MINUS_TOKEN:
                    		i = li - ri;
                    		d = ld - rd;
                    		break;
                    	case PLUS_TOKEN:
                    		i = li + ri;
                    		d = ld + rd;
                    		break;
                    	case MULT_TOKEN:
                    		i = li * ri;
                    		d = ld * rd;
                    		break;
                    	case DIV_TOKEN:
                    		i = li / ri;
                    		d = ld / rd;
                    		break;
                    	case MODULUS_TOKEN:
                    		if (ri == 0) {
                    			return new ObjectValue("NaN", cx.doubleType());
                    		}
                    		i = li % ri;
                    		d = ld % rd;
                    		break;
                    	default: // shouldn't be possible
                    	}
                    	if (forceType || (((int)d) == i))
                    		val = new ObjectValue(Integer.toString(i), cx.intType());
                    	else
                        	val = new ObjectValue(Double.toString(d), cx.doubleType());
                    	break;
                    } // case NU_INT
                    case NumberUsage.use_uint: {
                     	long d = 0;
                    	long ld = lval.uintValue();
                    	long rd = rval.uintValue();
                    	switch ( op ) {
                    	case MINUS_TOKEN:
                    		d = ld - rd;
                    		break;
                    	case PLUS_TOKEN:
                    		d = ld + rd;
                    		break;
                    	case MULT_TOKEN:
                    		d = ld * rd;
                    		break;
                    	case DIV_TOKEN:
                    		if (rd == 0) {
                    			// divide by 0
                    			String sval;
                    			if (ld == 0)
                    				sval = "NaN";
                    			else if (ld < 0)
                    				sval = "-Infinity";
                    			else 
                    				sval = "Infinity";
                    			return new ObjectValue(sval, cx.doubleType());
                    		}
                    		d = ld / rd;
                    		break;
                    	case MODULUS_TOKEN:
                    		if (rd == 0) {
                    			return new ObjectValue("NaN", cx.doubleType());
                    		}
                    		d = ld % rd;
                    		break;
                    	default: // shouldn't be possible
                    	}
                    	if (forceType || ((d >= 0) && (d <= 0xFFFFFFFFL))) {
                    		d &= 0xFFFFFFFFL; // truncate to 32 bits in the forceType case
                    		val = new ObjectValue(Long.toString(d), cx.uintType());
                    	}
                    	else {
                    		double dval;
                    		if ((op == MULT_TOKEN) && (d > 0xFFFFFFFFL || (d < 0))) {
                    			// could be from overflow in multiply.  Redo in double
                    			dval = lval.doubleValue() * rval.doubleValue();
                    		}
                    		else
                    			dval = d;
                    		val = new ObjectValue(Double.toString(dval), cx.doubleType());
                    	}
                    	break;
                    } // case NU_UINT
                    default: 

                    } // switch cx.numeric_usage
                    
                } // both types numeric
                else {
                	if (op == PLUS_TOKEN) {
                		val = cx.noType().prototype;
                	}
                }
                break;
            }
            default:
                val = cx.noType().prototype;
                break;
        }

        return val;
    }

    public Value evaluate(Context cx, ConditionalExpressionNode node)
    {

        if (node.condition != null)
        {
            Value val = node.condition.evaluate(cx, this);
            TypeInfo[] type = new TypeInfo[]{val != null ? val.getType(cx) : cx.noType().getDefaultTypeInfo()};
            node.condition = cx.coerce(node.condition, type, cx.booleanType(), true/*is_explicit*/);
        }

        // ISSUE: what should be the rules for type compatibility between
        // the first and second results.
        // [ed] need to coerce to expected type before the join node. using Context.coerce()
        //      to push coersions into each branch.

        if (node.thenexpr != null)
        {
            node.thenvalue = node.thenexpr.evaluate(cx, this);
        }

        if (node.elseexpr != null)
        {
            node.elsevalue = node.elseexpr.evaluate(cx, this);
        }

        return null;
    }


    public Value evaluate(Context cx, ArgumentListNode node)
    {
        Value       result = null;
        TypeInfo[] actual = new TypeInfo[1];

        int i = 0, items_size = node.items.size(), types_size = size(node.expected_types);

        if( size(node.decl_styles) != 0 ) // if parameter types were declared for this func, match against the args supplied
        {
            int param_count = 0;
            int val_index=0, type_index=0;

            if (node.expected_types.at(0)!= null && node.expected_types.at(0).getTypeValue() != cx.voidType()) // void is used for class based method which declares no arguments
            {
                for( ; val_index < items_size && type_index < types_size; val_index++, type_index++)
                {
                    Node item = node.items.get(val_index);
                    TypeInfo type = node.expected_types.get(type_index);

                    Value val = item.evaluate(cx, this);
                    actual[0] = null;//cx.noType();
                    if (val != null)
                    {
                        actual[0] = val.getType(cx);
                    }

                    if (node.decl_styles.at(param_count) != PARAM_Rest)
                    {
                        node.items.set(val_index, cx.coerce(item, actual, type));
                        result = type.getPrototype();
                        ++param_count;
                    }
                    else
                    {
                        node.items.set(val_index, cx.coerce(item, actual, cx.noType()));
                        result = (actual[0] != null ? actual[0].getPrototype() : null);
                        type_index--;
                    }
                }
            }
            if (cx.useStaticSemantics())
            {
                boolean tooManyArgs = (val_index < items_size);
                boolean tooFewArgs  = ((type_index < types_size) && node.decl_styles.at(param_count) == PARAM_Required);

                if ( tooManyArgs || tooFewArgs)
                {
                    StringBuilder err_arg_buf = new StringBuilder();
                    int expected_num_args = node.decl_styles.at(0) == PARAM_Void?0:types_size;
                    if (tooFewArgs)
                    {
                        for(; expected_num_args > 0; expected_num_args--)
                        {
                            if (node.decl_styles.at(expected_num_args-1) == PARAM_Required)
                                break;
                        }
                    }
                    else if (expected_num_args == 1 && node.decl_styles.at(0) == PARAM_Void)
                        expected_num_args = 0;

                    err_arg_buf.append(expected_num_args);
                    cx.error(node.pos(), (tooFewArgs ? kError_WrongNumberOfArguments : kError_TooManyArguments), err_arg_buf.toString());
                }
            }
            for( ; val_index < items_size; val_index++)
            {
                // Too few args, but make sure we evaluate the remaining args since they didn't get evaluated above.
                Node item = node.items.get(val_index);
                item.evaluate(cx, this);
            }
        }
        else
        {
            for (; i < items_size; ++i)
            {
                Node item = node.items.get(i);

                Value val = item.evaluate(cx, this);
                actual[0] = val != null ? val.getType(cx) : null;//cx.noType();

                TypeInfo expected;
                if (i >= types_size)
                {
                    expected = null;//cx.noType();
                }
                else
                {
                    expected = node.expected_types.get(i);
                }

                node.items.set(i, cx.coerce(item, actual, expected));
                result = expected != null ? expected.getPrototype() : (actual[0] != null ? actual[0].getPrototype() : null);
            }
        }

        return result;
    }

    public Value evaluate(Context cx, ListNode node)
    {
        Value val = null;

        int i = 0, size = node.items.size();
        for (; i < size; i++)
        {
            Node item = node.items.get(i);
            val = item.evaluate(cx, this);
            if (i + 1 != size)
            {
                item.voidResult();
            }
        }

        return val;
    }

    // Statements

    public Value evaluate(Context cx, StatementListNode node)
    {

        for ( int n = 0; n < node.items.size() ; ++n )
        {
            Node item = node.items.at(n);
            if (!doing_method)
            {
                doing_method = true;
            }

            if (item != null)
            {
                // Note that nodes from imported .abc files do not have blocks, though they are synthetic (i.e. not directly created from source)

                if (item.block != null && item.block.is_terminal) // if its unreachable, remove it
                {
                    // cn: don't remove variabledefintionNodes.  Looks like variable declarations within a switch
                    //  statement are hoisted up to the top of the switch's statementlist, even though no code execution
                    //  path will ever enter the block they are in.   The switch jumps over all statements to the end where the
                    //  switch block of if/else if jumps start for each case statement, none of which ever enter the
                    //  block where the variable def is declared.  We still need to evaluate that var def during
                    //  compilation time, however (for slot typing and compile-time constant setting), so leave it here
                    //  even if its unreachable.
                    if (!(item instanceof VariableDefinitionNode))
                    {
                        node.items.set(n, cx.getNodeFactory().emptyStatement());
                        /* cn: if you suspect that dead code removal is causing a problem, comment
                         * out the above line and uncomment this instead.  If the problem goes away, the
                         * error is likely in FlowGraphEmitter/FlowAnalyzer.  Check the block # of removed
                         * nodes and then set breakpoints in FlowGraphEmitter's EnterBlock() and AddEdge()
                        if (!(item instanceof ReturnStatementNode && ((ReturnStatementNode)item).isSynthetic()))
                            item.evaluate(cx, this);
                        */

                    }
                    /* for debugging dead code removal
                    if (item instanceof ReturnStatementNode)
                    {
                        ReturnStatementNode rn = (ReturnStatementNode)(item);
                        if (rn.pos() != 0 && !(rn.expr instanceof UnaryExpressionNode))
                        {

                            System.out.println("\tRemoving: return " + ((ReturnStatementNode)item).expr.toString());
                            System.out.println("\t\tfrom: " + cx.getErrorOrigin());
                            System.out.println("\t\t : " + cx.getInputLine(node.pos()));
                        }
                        //
                        if (rn.expr instanceof UnaryExpressionNode)
                            node.items.set(n, cx.getNodeFactory().emptyStatement());
                        else
                            item.evaluate(cx, this);
                    }
                    else if (!(item instanceof VariableDefinitionNode))
                    {
                        System.out.println("\tRemoving: " + item.toString());
                        System.out.println("\t\tfrom: " + cx.getErrorOrigin());
                        System.out.println("\t\t : " + cx.getInputLine(node.pos()));

                        item.evaluate(cx, this);
                    }
                    */
                }
                else
                {
                    item.evaluate(cx, this);
                }
            }
        }

       return ObjectValue.undefinedValue;
    }

    public Value evaluate(Context cx, EmptyStatementNode node)
    {
        return cx.noType().prototype;
    }

    public Value evaluate(Context cx, ExpressionStatementNode node)
    {
        Value result = null;
        if (node.expr != null)
        {

            TypeInfo[] type = new TypeInfo[1];
            result = node.expr.evaluate(cx, this);
            type[0] = result != null ? result.getType(cx) : cx.noType().getDefaultTypeInfo();
            node.expr = cx.coerce(node.expr, type, node.expected_type);
        }

        // Expression statements define the completion value (cv).
        // Update the reaching definitions.

        rch_bits = reset_set(rch_bits, node.getKillBits(), node.getGenBits());

        return result;
    }

    public Value evaluate(Context cx, LabeledStatementNode node)
    {
        if (node.statement != null)
        {
            node.statement.evaluate(cx, this);

        }
        return cx.noType().prototype;
    }

    public Value evaluate(Context cx, IfStatementNode node)
    {
        Value val = null;

        if( node.is_true )
        {
            if (node.thenactions != null)
            {
                node.thenactions.evaluate(cx, this);
            }
        }
        else
        if( node.is_false )
        {
            if (node.elseactions != null)
            {
                node.elseactions.evaluate(cx, this);
            }
        }
        else
        {
            if (node.condition != null)
            {
                val = node.condition.evaluate(cx, this);
                TypeInfo[] type = new TypeInfo[]{val != null ? val.getType(cx) : cx.noType().getDefaultTypeInfo()};
                node.condition = cx.coerce(node.condition, type, cx.booleanType(), true/*is_explicit*/);
            }
            if (node.thenactions != null)
            {
                node.thenactions.evaluate(cx, this);
            }
            if (node.elseactions != null)
            {
                node.elseactions.evaluate(cx, this);
            }
        }
        return cx.noType().prototype;
    }

    public Value evaluate(Context cx, SwitchStatementNode node)
    {

        if (node.expr != null)
        {
            Value val = node.expr.evaluate(cx, this);
            TypeInfo[] type = new TypeInfo[]{val != null ? val.getType(cx) : cx.noType().getDefaultTypeInfo()};
            node.expr = cx.coerce(node.expr, type, cx.noType());
        }
        if (node.statements != null)
        {
            node.statements.evaluate(cx, this);
        }

        return cx.noType().prototype;
    }

    public Value evaluate(Context cx, CaseLabelNode node)
    {

        if (node.label != null)
        {
            /*Value val =*/ node.label.evaluate(cx, this);
            //TypeValue[] type = new TypeValue[]{val != null ? val.getType(cx) : cx.noType()};
            //node.label = cx.coerce(node.label, type, cx.noType());
        }
        return cx.noType().prototype;
    }

    public Value evaluate(Context cx, DoStatementNode node)
    {
        if (node.expr != null)
        {
            Value val = node.expr.evaluate(cx, this);
            TypeInfo[] type = new TypeInfo[]{val != null ? val.getType(cx) : cx.noType().getDefaultTypeInfo()};
            node.expr = cx.coerce(node.expr, type, cx.booleanType(), true/*is_explicit*/);
        }
        if (node.statements != null)
        {
            node.statements.evaluate(cx, this);
        }
        return cx.noType().prototype;
    }

    public Value evaluate(Context cx, WhileStatementNode node)
    {
        if (node.statement != null)
        {
            node.statement.evaluate(cx, this);
        }

        if (node.expr != null)
        {
            // Coerce the condition expression to native bool.

            Value val = node.expr.evaluate(cx, this);
            TypeInfo[] type = new TypeInfo[]{val != null ? val.getType(cx) : cx.noType().getDefaultTypeInfo()};
            node.expr = cx.coerce(node.expr, type, cx.booleanType(), true/*is_explicit*/);
        }
        return cx.noType().prototype;
    }

    public Value evaluate(Context cx, ForStatementNode node)
    {
        if (node.initialize != null)
        {
            if (node.initialize.isDefinition())
            {
                ExpressionStatementNode es = (ExpressionStatementNode) node.initialize.initializerStatement(cx);
                node.initialize = es.expr;
            }
            node.initialize.evaluate(cx, this);
            node.initialize.voidResult();
        }
        if (node.statement != null)
        {
            node.statement.evaluate(cx, this);
        }
        if (node.increment != null)
        {
            node.increment.evaluate(cx, this);
            node.increment.voidResult();
        }
        if (node.test != null)
        {
            // Coerce the condition expression to native bool.

            Value val = node.test.evaluate(cx, this);
            TypeInfo[] type = new TypeInfo[]{val != null ? val.getType(cx) : cx.noType().getDefaultTypeInfo()};
            node.test = cx.coerce(node.test, type, cx.booleanType(), true/*is_explicit*/);
        }
        return cx.noType().prototype;
    }

    public Value evaluate(Context cx, WithStatementNode node)
    {
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }

        if (node.statement != null)
        {
            cx.pushScope(node.activation);

            boolean saved_in_with = in_with;
            in_with = true;

            int saveWithDepth = cx.statics.withDepth;
            cx.statics.withDepth = cx.getScopes().size()-1;

            node.statement.evaluate(cx, this);

            in_with = saved_in_with;

            cx.statics.withDepth = saveWithDepth;

            cx.popScope();
        }

        return cx.noType().prototype;
    }

    public Value evaluate(Context cx, ContinueStatementNode node)
    {
        return cx.noType().prototype;
    }

    public Value evaluate(Context cx, BreakStatementNode node)
    {
        return cx.noType().prototype;
    }

    public Value evaluate(Context cx, ReturnStatementNode node)
    {
        if( node.expr != null )
        {
            Value     val  = node.expr.evaluate(cx,this);
            TypeInfo[] type = new TypeInfo[1];
            type[0] = val!=null?val.getType(cx):null;
            if( return_type.getTypeValue() == cx.voidType() )
            {
                if( type[0]==null || type[0].getTypeValue() != cx.voidType() )
                {
                    cx.error(node.pos(), kError_ReturnTypeMustBeUndefined);
                }
                else
                {
                    //node.expr = null; // null the return expression
                    // etierney 7/7/05 - don't null the expression, it may evaluate to undefined, but it may
                    // have side effects and so should still be evaluated.  See bug #108487.
                }
                return cx.voidType().prototype;
            }
            else
            {
                if (type[0]!= null && type[0].getTypeValue() == cx.voidType() && return_type.getTypeValue() != cx.noType() && node.isSynthetic() && cx.useStaticSemantics())
                {
                    cx.error(node.pos(), kError_MustReturnValue); // error on missing return, not the type mismatch error coerce would cause below
                }
                else
                {
                    node.expr = cx.coerce(node.expr,type,return_type);
                }
            }
        }
        else
        {
            // If a return type is required, signal an error.
            if (cx.useStaticSemantics() && return_type != null && return_type.getTypeValue() != cx.voidType() && return_type.getTypeValue() != cx.noType())
            {
                cx.error(node.pos(), kError_MustReturnValue);
            }
        }
        return return_type.getPrototype();
    }


    // Definitions

    public Value evaluate(Context cx, VariableDefinitionNode node)
    {
		if(node.cx != null) {
			cx = node.cx;
		}

		return node.list.evaluate(cx, this);
    }

    public Value evaluate(Context cx, VariableBindingNode node)
    {
        TypeInfo type = null;
        Slot slot = node.ref.getSlot(cx);

        if( node.typeref != null )
        {
            Slot typeSlot = node.typeref.getSlot(cx);
            if (typeSlot == null  || typeSlot.getValue() == null)
            {
                cx.error(node.variable.type.pos(), kError_UnknownType, node.typeref.getDiagnosticTypeName());
                slot.setType(type = cx.noType().getDefaultTypeInfo());
            }
            else
            {
                Value v = typeSlot.getValue();
                if( v instanceof TypeValue )
                {
                    TypeValue tv = (TypeValue)v;
                    type = node.typeref.has_nullable_anno ? tv.getTypeInfo(node.typeref.is_nullable) : tv.getDefaultTypeInfo();
                }
                else if( v == null )
                {
                    type = cx.noType().getDefaultTypeInfo();
                }
                else
                {
                    // The value of the slot is not a type, so it's an unknown type
                    cx.error(node.variable.type.pos(), kError_UnknownType, node.typeref.getDiagnosticTypeName());
                    slot.setType(type = cx.noType().getDefaultTypeInfo());
                }
            }
        }
        else
        {
            type = cx.noType().getDefaultTypeInfo();
        }

        if( node.initializer != null && slot != null && (node.kind == CONST_TOKEN || // only class member's
                slot.declaredBy.builder instanceof InstanceBuilder ||
                slot.declaredBy.builder instanceof ClassBuilder ) )
        {
        	if( cx.statics.es4_nullability && cx.scope().builder instanceof InstanceBuilder )
        	{
        		// Initializers for instance variables should not have access to this.
        		cx.scope().setInitOnly(true);
        	}
            Value val = node.initializer.evaluate(cx,this);
        	if( cx.statics.es4_nullability && cx.scope().builder instanceof InstanceBuilder )
        	{
        		cx.scope().setInitOnly(false);
        	}
            val = val != null ? val.getValue(cx) : null;
            if( val instanceof ObjectValue && ((ObjectValue)val).hasValue())
            {
                ObjectValue ov = (ObjectValue)val;
                ObjectValue checked = checkDefaultValue(cx, type, ov);
                if( checked == null )
                {
                    cx.error(node.initializer.pos(), kError_IncompatibleDefaultValue,ov.type.getName(cx).toString(),type.getName(cx).toString());
                }
                slot.setObjectValue(checked);
            }
        }

        return type.getPrototype();
    }

    public Value evaluate(Context cx, BinaryFunctionDefinitionNode node)
    {
        // Nothing to do - all type info should have been set up by AbcParser
        return null;
    }

    public Value evaluate(Context unused_cx, FunctionDefinitionNode node)
    {
        Context cx = node.cx; // switch context to the one used to parse this node, for error reporting

        if (node.attrs != null && !doing_class )
        {
            node.attrs.evaluate(cx, this);
        }
        if (node.name != null)
        {
//            node.name.evaluate(cx,this);
        }
        if (node.fexpr != null)
        {
            if( node.version > -1)
                cx.pushVersion(node.version);

            int state = super_error;
            if( "$construct".equals(node.ref.name) )
            {
                state = super_statement;
            }
            super_context.add(state);
            node.fexpr.evaluate(cx,this);
            super_context.pop_back();

            // check for get/set type compatibility

            // Turn off version checking to avoid erroneous errors when getter/setters
            // weren't introduced in the same version.
            boolean old_check_ver = cx.checkVersion() ;
            cx.statics.check_version = false;

            if( node.name.kind == GET_TOKEN ||
                node.name.kind == SET_TOKEN )
            {
                node.ref.getType(cx,GET_TOKEN); // lazily inherit type info
                node.ref.getType(cx,SET_TOKEN); //  yeah.
                Slot s1 = node.ref.getSlot(cx,GET_TOKEN);
                Slot s2 = node.ref.getSlot(cx,SET_TOKEN);
                if( s1 != null && s2 != null )
                {
                    TypeInfo t1 = s1.getType();
                    TypeInfo t2 = size(s2.getTypes()) > 0 ? s2.getTypes().get(0) : cx.noType().getDefaultTypeInfo();
                    if( !compareTypeInfos(t1, t2) && (t1.getTypeValue() != cx.noType() && t2.getTypeValue() != cx.noType()) )
                    {
                        int pos = node.name.kind == GET_TOKEN ?
                                (node.fexpr.signature.result != null ? node.fexpr.signature.result.pos() : node.fexpr.signature.pos()) :
                                (node.fexpr.signature.parameter != null ? node.fexpr.signature.parameter.items.get(0).type.pos(): node.fexpr.signature.pos());

                        //String kind_str = node.name.kind == GET_TOKEN ? "Getter" : "Setter";
                        //String otherkind_str = node.name.kind == GET_TOKEN ? "setter" : "getter";
                        node.ref.getSlot(cx,SET_TOKEN);
                        cx.error(pos, kError_AccessorTypesMustMatch);
                    }
                }
            }
            if( node.name.kind == SET_TOKEN )
            {
                Slot s2 = node.ref.getSlot(cx,SET_TOKEN);
                if( s2 != null )
                {
                    TypeInfo rt2 = s2.getType();
                    if( node.fexpr.signature.result != null && rt2.getTypeValue() != cx.voidType() )
                    {
                        int pos = node.fexpr.signature.result.pos();
                        cx.error(pos, kError_BadSetterReturnType);
                    }
                }
                ParameterListNode parameter = node.fexpr.signature.parameter;
                if (parameter == null || parameter.items.size() != 1)
                {
                    int pos = (parameter != null) ? parameter.pos() : node.fexpr.signature.pos();
                    cx.error(pos, kError_SetterMustHaveOneParameter);
                }
                else if (parameter.items.at(0).init != null)
                {
                    int pos = node.fexpr.signature.parameter.pos();
                    cx.error(pos, kError_SetterCannotHaveOptional);
                }
            }
            else if( node.name.kind == GET_TOKEN )
            {
                if (node.fexpr.signature.void_anno)
                {
                    int pos = node.fexpr.signature.pos();
                    cx.error(pos, kError_BadGetterReturnType);
                }
                ParameterListNode parameter = node.fexpr.signature.parameter;
                if (parameter != null && parameter.items.size() != 0)
                {
                    int pos = node.fexpr.signature.parameter.pos();
                    cx.error(pos, kError_GetterCannotHaveParameters);
                }
            }

            cx.statics.check_version = old_check_ver;

            if( node.version > -1)
                cx.popVersion();
        }

        if( node.needs_init )
        {
            node.init.evaluate(cx,this);
        }

        return cx.noType().prototype;
    }


    public Value evaluate(Context unused_cx, FunctionCommonNode node)
    {
        Context cx = node.cx; // switch to original context

        if (doing_method)
        {
            if( node.ref != null )
            {
                Slot slot = node.ref.getSlot(cx,node.kind);
                if( slot != null )
                {
                    if (slot.getOverriddenSlot() != null)
                    {
                        if (!matchSignatures(slot, slot.getOverriddenSlot()))
                        {
                            cx.error(node.pos(), kError_IncompatibleOverride);
                        }
                    }
                }

                ObjectValue fun = node.fun;
                cx.pushScope(fun.activation);

                if( node.def != null && node.def.version > -1)
                    cx.pushVersion(node.def.version);

                node.signature.evaluate(cx,this);

                if( node.def != null && node.def.version > -1)
                    cx.popVersion();
                cx.popScope();


            }

            return node.fun;

        }

        int savedWithDepth = cx.statics.withDepth;
        if( node.with_depth != -1)
        {
            cx.statics.withDepth = node.with_depth;
        }

        ObjectList<ObjectValue>saved_scopes = null;
        if( node.scope_chain != null )
        {
            saved_scopes = cx.swapScopeChain(node.scope_chain);
        }

        if( node.def != null && node.def.version > -1 )
            cx.pushVersion(node.def.version);

        ObjectValue fun = node.fun;
        cx.pushScope(fun.activation);

        boolean is_constructor = "$construct".equals(node.ref.name);
        if (is_constructor || node.isNative())
        {
            this.return_type = cx.voidType().getDefaultTypeInfo();
        }
        else
        {
            this.return_type = node.signature.type!=null?node.signature.type:cx.noType().getDefaultTypeInfo();
        }

        if( is_constructor && cx.useStaticSemantics() )
        {
            // check for default 0 arg ctor in baseclass if the user doesn't explicitly call super() from the ctor
            int scope_depth = cx.getScopeDepth();
            ObjectValue iframe = cx.scope(scope_depth-2);
            InstanceBuilder ib = iframe.builder instanceof InstanceBuilder ? (InstanceBuilder) iframe.builder : null;
            if( ib != null && !ib.calls_super_ctor )
            {
                // Doesn't call the base class constructor, check for a default no-args constructor

                if( ib.basebui != null )
                {
                    ObjectValue baseobj = ib.basebui.objectValue;

                    ReferenceValue ref = new ReferenceValue(cx, baseobj,"$construct",cx.publicNamespace());
                    Slot slot = ref.getSlot(cx,EMPTY_TOKEN);
                    ref.getType(cx,EMPTY_TOKEN);

                    if (slot != null && size(slot.getDeclStyles()) != 0 && slot.getDeclStyles().at(0) == PARAM_Required)
                    {
                        // found a slot, and it has required params
                        cx.error(node.pos(), kError_NoDefaultBaseclassCtor, ib.basebui.classname.toString());
                    }
                }
            }
        }
        boolean old_in_anonymous_function = this.in_anonymous_function;
        this.in_anonymous_function = (node.isFunctionDefinition() == false); // set flag if we are processing an anonymous function
        if (this.in_anonymous_function)
            this_contexts.push_back(global_this);

        if( node.signature.inits != null )
        {
            ObjectValue iframe = null;
            int scope_depth = cx.getScopeDepth();
            iframe = cx.scope(scope_depth-2);
            
            // Make get & method slots invisible, only set slots will be visible.
            iframe.setInitOnly(true);

            // Evaluate the constructor initializer list if present
        	node.signature.inits.evaluate(cx, this);

        	// Make everything visible again
        	iframe.setInitOnly(false);
        }
        
        if (node.body != null)
        {
            // Don't evaluate the bodies of interface methods.  It will generate a bogus missing
            //  return statement error in -strict / !
            int scope_depth = cx.getScopes().size()-3;  // -1 is func activation, -2 could be the class iframe, -3 could be the class cframe
            if (scope_depth > 0)                        //   If the scope is at least that big.
            {
                ObjectValue scope = cx.scope(scope_depth); // and the builder is a ClassBuilder
                boolean is_interface_method = (scope.builder instanceof ClassBuilder) && ((ClassBuilder)(scope.builder)).is_interface == true;
                if (!is_interface_method) // don't evaulate default "return void 0" body of interface defs here, it will just generate bogus return type errors in !
                    node.body.evaluate(cx,this);
            }
            else
                node.body.evaluate(cx,this);
        }
        if (this.in_anonymous_function)
            this_contexts.pop_back();
        this.in_anonymous_function = old_in_anonymous_function;

        doing_method = false;
        this.return_type = cx.noType().getDefaultTypeInfo(); // restore to default

        for (FunctionCommonNode fexpr : node.fexprs)
        {
            fexpr.evaluate(cx, this);
        }

        cx.popScope(); // activation
        if( node.def != null && node.def.version > -1)
            cx.popVersion();

        if( saved_scopes != null )
        {
            cx.swapScopeChain(saved_scopes);
        }
        cx.statics.withDepth = savedWithDepth;

        return node.fun;
    }

    public boolean matchSignatures(Slot implementingSlot, Slot interfaceSlot)
    {
        if (implementingSlot.getType() != interfaceSlot.getType())
        {
            return false;
        }
        int count = size(implementingSlot.getTypes());
        if (count != size(interfaceSlot.getTypes()))
        {
            return false;
        }
        for (int i=0; i<count; i++)
        {
            if (implementingSlot.getTypes().at(i) != interfaceSlot.getTypes().at(i))
            {
                return false;
            }
            if ((implementingSlot.getDeclStyles().at(i)) != (interfaceSlot.getDeclStyles().at(i)))
            {
                return false;
            }
        }
        return true;
    }

    public Value evaluate(Context cx, FunctionNameNode node)
    {
        assert(false); // throw "Should never get here.";
        return null;
    }

    public Value evaluate(Context cx, FunctionSignatureNode node)
    {
        if (node.parameter != null)
        {
            node.parameter.evaluate(cx, this);
        }

        Value result = cx.noType().prototype;

        if( node.typeref != null )
        {
            Slot typeslot = node.typeref.getSlot(cx);
            if( typeslot != null )
            {
                TypeValue typeval = typeslot.getValue() instanceof TypeValue ? (TypeValue) typeslot.getValue() : null;
                node.type = typeval != null ? node.typeref.has_nullable_anno ? typeval.getTypeInfo(node.typeref.is_nullable) : typeval.getDefaultTypeInfo() : null;
            }

            if( node.type != null )
            {
                result = node.type.getPrototype();
            }
            else
            {
                cx.error(node.result.pos(), kError_UnknownType, node.typeref.getDiagnosticTypeName());
            }
        }
        else
        if( node.void_anno )
        {
            node.type = cx.voidType().getDefaultTypeInfo();
            result = cx.voidType().prototype;
        }
        else
        {
            node.type = cx.noType().getDefaultTypeInfo();
        }

        return result;
    }

    public Value PreprocessDefinitionTypeInfo(Context cx, FunctionSignatureNode node)
    {
        if (node.parameter != null)
        {
            PreprocessDefinitionTypeInfo(cx,node.parameter);
        }

        Value result = cx.noType().prototype;

        if( node.typeref != null )
        {
            Slot typeslot = node.typeref.getSlot(cx);
            if( typeslot != null )
            {
                TypeValue typeval = typeslot.getValue() instanceof TypeValue ? (TypeValue) typeslot.getValue() : null;
                node.type = typeval != null ? node.typeref.has_nullable_anno ? typeval.getTypeInfo(node.typeref.is_nullable) : typeval.getDefaultTypeInfo() : null;
            }

            if( node.type != null )
            {
                result = node.type.getPrototype();
            }
            else
            {
                cx.error(node.result.pos(), kError_UnknownType, node.typeref.getDiagnosticTypeName());
            }
        }
        else
        if( node.void_anno )
        {
            node.type = cx.voidType().getDefaultTypeInfo();
            result = cx.voidType().prototype;
        }
        else
        {
            node.type = cx.noType().getDefaultTypeInfo();
        }

        return result;
    }

    ObjectValue checkDefaultValue(Context cx, TypeInfo type, ObjectValue from)
    {
        switch(type.getTypeId())
        {
        case TYPE_object:
        case TYPE_none:
            return from;     // any value is okay, vm converts undefined to null for Object
        case TYPE_array:
        case TYPE_xml:
            switch(from.type.getTypeId())
            {
            case TYPE_void:
            case TYPE_null:
                return from;
            default:
                break;
            }
            break;
        case TYPE_string:
            switch(from.type.getTypeId())
            {
            case TYPE_void:
            case TYPE_null:
            case TYPE_string:
                return from;
            default:
                break;
            }
            break;
        case TYPE_function:
            switch(from.type.getTypeId())
            {
            case TYPE_void:
            case TYPE_null:
            case TYPE_function:
                return from;
            default:
                break;
            }
            break;
        case TYPE_type:
            switch(from.type.getTypeId())
            {
            case TYPE_void:
            case TYPE_null:
            case TYPE_type:
                return from;
            default:
                break;
            }
            break;
        case TYPE_boolean:
            switch(from.type.getTypeId())
            {
            case TYPE_void:
            case TYPE_boolean:
                return from;
            default:
                break;  // error
            }
            break;
        case TYPE_double:
            switch(from.type.getTypeId())
            {
            case TYPE_void:
            case TYPE_double:
            case TYPE_int:
            case TYPE_uint:
            case TYPE_decimal:		
                return from;
            default:
                break;
            }
            break;
        case TYPE_decimal:
            switch(from.type.getTypeId())
            {
            case TYPE_void:
            case TYPE_double:
            case TYPE_decimal:		
            case TYPE_int:
                return from;
            default:
                break;
            }
            break;
        case TYPE_uint:
        {
        	switch(from.type.getTypeId())
        	{
        	case TYPE_void:
                return from;
            case TYPE_uint:
            	return from;
            case TYPE_int:
            case TYPE_decimal:
            case TYPE_double:
                String nstr = from.toString();
                TypeValue[] ntype = new TypeValue[1];
                // RES - for this check, I don't think I need the active number usage
                double dval = cx.getEmitter().getValueOfNumberLiteral(nstr,ntype, new NumberUsage()).doubleValue();
                long uval = macromedia.asc.util.NumericConversions.toUint32(dval);

                if( dval == uval )
                    return from;
                else
                    //  Return the converted value.
                    return new ObjectValue(Long.toString(uval), cx.uintType());
        	}
            break;
        }
        case TYPE_int:
            switch(from.type.getTypeId())
            {
            case TYPE_void:
                return from;
            case TYPE_int:
                     return from;
            case TYPE_uint:
            case TYPE_decimal:	// launder this through double to see if integral
            case TYPE_double:
                {
                String nstr = from.toString();
                TypeValue[] ntype = new TypeValue[1];
                double dval = cx.getEmitter().getValueOfNumberLiteral(nstr,ntype, new NumberUsage()).doubleValue();
                int ival = macromedia.asc.util.NumericConversions.toInt32(dval);
                
                if ( dval == ival )
                    return from;
                else
                    //  Return the converted value.
                    return new ObjectValue(Long.toString(ival), cx.intType());
                }
            default:
                break; // error
            }
            break;
        }
        return null;
    }

    public Value evaluate(Context cx, ParameterNode node)
    {
        TypeInfo type = null;
        Slot slot = node.ref.getSlot(cx);

        if( node.typeref != null)
        {
            Slot typeslot = node.typeref.getSlot(cx);
            if( typeslot != null)
            {
                TypeValue typeval = (typeslot.getValue() instanceof TypeValue) ? (TypeValue) typeslot.getValue() : null;
                type = typeval != null ? node.typeref.has_nullable_anno ? typeval.getTypeInfo(node.typeref.is_nullable) : typeval.getDefaultTypeInfo() : null;
            }
            if( type!=null )
            {
                slot.setType(type);
            }
            else
            {
                cx.error(node.type.pos(), kError_UnknownType, node.typeref.getDiagnosticTypeName());
                slot.setType(type = cx.noType().getDefaultTypeInfo());
            }
        }
        else
        {
            type = cx.noType().getDefaultTypeInfo();
        }

        if( node.init != null )
        {
            Value v = node.init.evaluate(cx, this);

            if (v instanceof ReferenceValue)
                v = ((ReferenceValue)(v)).getValue(cx);

            ObjectValue ov = v instanceof ObjectValue ? (ObjectValue)v : null;

            if (ov != null && ov.hasValue())
            {
                ObjectValue checked = checkDefaultValue(cx,type,ov);
                if( checked == null )
                {
                    cx.error(node.init.pos(), kError_IncompatibleDefaultValue,ov.type.getName(cx).toString(),type.getName(cx).toString());
                }
                slot.setValue(checked);
            }
            else
            {
                cx.error(node.init.pos(), kError_NonConstantParamInitializer);
            }
        }
        return type.getPrototype();
    }

    public Value PreprocessDefinitionTypeInfo(Context cx, RestParameterNode node)
    {
        ParameterNode pnode = node;
        Value result = PreprocessDefinitionTypeInfo(cx,pnode);
        Slot  s = node.ref.getSlot(cx);
        // Only error if there was an explicit typeref other than Array
        if (pnode.typeref != null && s.getType() != null && s.getType().getTypeValue() != cx.arrayType())
            cx.error(node.pos(), kError_InvalidRestDecl);

        return result;
    }

    public Value PreprocessDefinitionTypeInfo(Context cx, ParameterNode node)
    {
        TypeInfo type = null;
        Slot slot = node.ref.getSlot(cx);

        if( node.typeref != null)
        {
            Slot typeslot = node.typeref.getSlot(cx);
            if( typeslot != null)
            {
                TypeValue typeval = (typeslot.getValue() instanceof TypeValue) ? (TypeValue) typeslot.getValue() : null;
                type = typeval != null ? node.typeref.has_nullable_anno ? typeval.getTypeInfo(node.typeref.is_nullable) :typeval.getDefaultTypeInfo() : null;
            }
            if( type!=null )
            {
                slot.setType(type);
            }
            else
            {
                cx.error(node.type.pos(), kError_UnknownType, node.typeref.getDiagnosticTypeName());
                slot.setType(type = cx.noType().getDefaultTypeInfo());
            }
        }
        else
        {
            type = cx.noType().getDefaultTypeInfo();
        }

        return type.getPrototype();
    }

    public Value evaluate( Context cx, ParameterListNode node )
    {
        Value val;
        ObjectValue obj;
        TypeValue type;

        for (ParameterNode item : node.items)
        {
            val  = item.evaluate(cx,this);
            obj  = (val.getValue(cx) instanceof ObjectValue) ? (ObjectValue) val.getValue(cx) : null;
        }

        return null;
    }

    public Value PreprocessDefinitionTypeInfo( Context cx, ParameterListNode node )
    {
        Value val;
        ObjectValue obj;
        TypeInfo type;

        if( size(node.types) == 0 ) // do only once
        {
            int decl_style;
            int last_decl_style =PARAM_Required;


            for (ParameterNode item : node.items)
            {

                if ((item instanceof RestParameterNode) == false)
                {
                    val  = PreprocessDefinitionTypeInfo(cx,item);
                    obj  = (val.getValue(cx) instanceof ObjectValue) ? (ObjectValue) val.getValue(cx) : null;

                    type = obj.type!=null?obj.type:cx.noType().getDefaultTypeInfo();
                    node.types.push_back(type);
                    decl_style = (item.init == null) ? PARAM_Required : PARAM_Optional;
                }
                else
                {
                    val  = PreprocessDefinitionTypeInfo(cx,(RestParameterNode)item);
                    obj  = (val.getValue(cx) instanceof ObjectValue) ? (ObjectValue) val.getValue(cx) : null;

                    node.types.push_back(cx.arrayType().getDefaultTypeInfo()); // This is only used for arg coercion.  Perhaps noType() instead ?
                    decl_style = PARAM_Rest;
                }

                node.decl_styles.push_back((byte)decl_style);

                if (decl_style == PARAM_Required && last_decl_style != decl_style)
                    cx.error(item.pos(),kError_BadRequiredParameter);
                // parser enforces that no argument decl can follow a "..." rest param,
                //  so no need to check again here.
                last_decl_style = decl_style;
            }
        }


        return null;
    }

    public Value evaluate(Context cx, ProgramNode node)
    {
        super_context.add(super_error);

        {
            if ( node.imports.size() >= 1 )
            {
                // This is ok because the FA will have consolidated all of the various imports into
                // one program node that lives in the first ImportNode.
                node.imports.first().program.evaluate(cx, this);
            }
        }
        
        currentDecimalContext = new Decimal128Context(); // for use in constant folding

        // preprocess all definitions to set their slot.type, types, and decl_styles correctly.
        if (typeInfoPreprocessing_complete == false)  // only true when Flex calls us, false for normal asc usage.
        {
            node.cx.processUnresolvedNamespaces();
            PreprocessDefinitionTypeInfo(cx,node.statements.items);
        }

        // Evaluate each function expression to do semantic checking

        doing_method = false;
        doing_class  = false;

        {
            for (FunctionCommonNode n : node.fexprs)
            {
                n.evaluate(cx, this);
            }
        }

        {
            for (ClassDefinitionNode n : node.clsdefs)
            {
                n.evaluate(cx, this);
            }
        }


        this_contexts.add(global_this);

        // Now evaluate each package definition

        StartProgram("");

        // Function expressions that occur in the current block will be
        // compiled as though they had occured at the end of the block.
        // The variable that references them is initialized at the beginning
        // of the block.

        if (node.statements != null)
        {
            node.statements.evaluate(cx, this);
        }
        doing_method = false;

        FinishProgram(cx,"",0);

        super_context.pop_back();
        this_contexts.pop_back();

        return null;
    }

    public Value evaluate(Context unused_cx, PackageDefinitionNode node)
    {
        if( !node.in_this_pkg )
        {
            node.in_this_pkg = true;
        }

        return null;
    }

    public Value evaluate(Context cx, ErrorNode node)
    {
        cx.error(node.pos(), node.errorCode, node.errorArg);
        return cx.noType().prototype;
    }

    public Value evaluate(Context cx, ToObjectNode node)
    {
        TypeInfo[] actual = new TypeInfo[]{node.expr.evaluate(cx, this).getType(cx)};
        node.expr = cx.coerce(node.expr, actual, cx.noType());
        return actual[0].getPrototype();
    }

    public Value evaluate(Context cx, LoadRegisterNode node)
    {
        return node.type.prototype;
    }

    public Value evaluate(Context cx, StoreRegisterNode node)
    {
        Value val = node.expr.evaluate(cx, this);
        TypeInfo[] type = new TypeInfo[]{val != null ? val.getType(cx) : null};
        node.expr = cx.coerce(node.expr, type, node.type);
        return node.type.prototype;
    }

    public Value evaluate(Context cx, RegisterNode node)
    {
        return cx.voidType().prototype;
    }

    public Value evaluate(Context cx, HasNextNode node)
    {
        return cx.booleanType().prototype;
    }
    
    public Value evaluate(Context cx, ThrowStatementNode node)
    {
        if( node.expr != null )
        {
            node.expr.evaluate(cx,this);
        }
        return cx.noType().prototype;
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
        return cx.noType().prototype;
    }

    public Value evaluate(Context cx, CatchClauseNode node)
    {
        cx.pushScope(node.activation);

        if (node.parameter != null)
        {
            node.parameter.evaluate(cx,this);
        }
        if (node.statements != null)
        {
            // eval the statements
            node.statements.evaluate(cx, this);
        }

        cx.popScope();

        return cx.noType().prototype;
    }

    public Value evaluate(Context cx, FinallyClauseNode node)
    {
        node.default_catch.evaluate(cx,this);
        if( node.statements != null )
        {
            node.statements.evaluate(cx,this);
        }

        return cx.noType().prototype;
    }

    public Value evaluate(Context cx, BoxNode node)
    {
        node.expr.evaluate(cx, this);
        return cx.noType().prototype;
    }

    public Value evaluate(Context cx, CoerceNode node)
    {
        node.expr.evaluate(cx, this);
        return node.expected.getPrototype();
    }

    public Value evaluate(Context unused_cx, ClassDefinitionNode node)
    {
        Context cx = node.cx;  // switch to original context

        if (doing_method)
        {
            return node.cframe;
        }

        if( node.needs_init )
        {
            node.needs_init = false;
            doing_method = true;
            node.init.evaluate(cx,this);
            doing_method = false;
        }
        Slot class_slot = null;
        if( node.ref != null )
        {
            class_slot = node.ref.getSlot(cx, NEW_TOKEN);
        }

        if( node.version > -1 )
        {
            cx.pushVersion(node.version);
        }

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

        if (doing_class)
          {
              return node.cframe;
          }

        cx.pushStaticClassScopes(node);
        this_contexts.add(error_this);

        // Generate code for the static property definitions
        doing_class = true;

        {
            for (FunctionCommonNode staticfexpr : node.staticfexprs)
            {
                staticfexpr.evaluate(cx, this);
            }
        }

        {
            doing_class = false;
            for (Node clsdef : node.clsdefs)
            {
                clsdef.evaluate(cx, this);
            }
            doing_class = true;
        }

        if (node.statements != null)
        {
            node.statements.evaluate(cx, this);
        }

        doing_method = false;   // This flag determines if the function is compiled
                                // now or later. The outer code block is finished
                                // so we can do a another one.

        cx.pushScope(node.iframe);

        this_contexts.removeLast();
        this_contexts.add(instance_this);

        // Determine which interfaces are implemented by the class
        if (node.interfaces != null)
        {
            node.interfaces.evaluate(cx, this);
        }

        // Generate code for the instance initializers
        {
            for (Node init : node.instanceinits)
            {
                doing_method = true;
                // not clear on whether this is required for instance inits
                if (init instanceof FunctionDefinitionNode) // FunctionCommonNode initial evaluation requires this flag, normally set within StatementListNode evaluation
                {                                                  //  static functions (incl getter/setters) are evaluated here, however, rather than from within a StatementListNode.
                    FunctionDefinitionNode func_def = (FunctionDefinitionNode)init;
                    func_def.evaluate(cx, this);

                    if( func_def.fexpr.ref.name.equals("$construct") )
                    {
                        // Copy the type info from the constructor slot into the global slot that is the reference
                        // to the class - this is so that type checking on constructor calls can happen correctly
                        Slot ctor_slot = func_def.fexpr.ref.getSlot(cx, func_def.fexpr.kind);
                        if( class_slot != null && ctor_slot != null )
                        {
                            class_slot.setTypes(ctor_slot.getTypes());
                            class_slot.setDeclStyles(ctor_slot.getDeclStyles());
                        }
                    }
                }
                else
                {
    		        if( cx.statics.es4_nullability && !init.isDefinition() )
    		        	node.iframe.setInitOnly(true);
                	
                    init.evaluate(cx, this);

    		        if( cx.statics.es4_nullability && !init.isDefinition() )
    		        	node.iframe.setInitOnly(false);
                }
            }
            doing_method = false; // all done with the instance initializers, can now do the actual methods in fexpr
        }

        // Evaluate each function expression to do semantic checking

        for (FunctionCommonNode fexpr : node.fexprs)
        {
            fexpr.evaluate(cx, this);
        }

        doing_class = false;

        // Verify that the class correctly implements all interface methods
        checkInterfaceMethods(cx, node);

        this_contexts.removeLast();

        cx.popScope(); // iframe
        cx.popStaticClassScopes(node);

        if( node.version > -1)
            cx.popVersion();

        node.needs_init = true;

        return node.cframe;
    }

    public Value evaluate(Context cx, BinaryInterfaceDefinitionNode node)
    {
        return evaluate(cx, (BinaryClassDefNode)node);
    }

    public Value evaluate(Context cx, InterfaceDefinitionNode node)
    {
        return evaluate(cx, (ClassDefinitionNode)node);
    }

    private void checkInterfaceMethods(Context cx,
                                       ClassDefinitionNode classNode)
    {
        InterfaceWalker interfaceWalker = new InterfaceWalker(classNode.iframe, false);

        while (interfaceWalker.hasNext())
        {
            ObjectValue interfaceIFrame = interfaceWalker.next();
            TypeValue interfaceCFrame = interfaceIFrame.type.getTypeValue();

            if (classNode.isInterface())
            {
                checkInterfaceInterfaceMethods(cx, (InterfaceDefinitionNode)classNode, interfaceCFrame);
            }
            else
            {
                checkClassInterfaceMethods(cx, classNode, interfaceCFrame);
            }
        }
    }

    private void checkClassInterfaceMethods(Context cx,
                                            ClassDefinitionNode classNode,
                                            TypeValue interfaceCFrame)
    {
        ObjectValue interfaceIFrame = interfaceCFrame.prototype;
        checkClassInterfaceMethods(cx, classNode, interfaceIFrame);
    }
    
    private void checkClassInterfaceMethods(Context cx,
                                            ClassDefinitionNode classNode,
                                            ObjectValue interfaceIFrame)
    {
        InstanceBuilder builder = (InstanceBuilder)interfaceIFrame.builder;
        Names names = builder.getNames();

        if (names != null)
        {
            for (int i = 0; (i = names.hasNext(i)) != -1; i++)
            {
                String name = names.getName(i);
                ObjectValue namespace = names.getNamespace(i);

                if(!Builder.removeBuilderNames) {
                    if (names.getType(i) == Names.LOCAL_METHOD_NAMES)
                        continue;

                    if (names.getType(i) == Names.GET_NAMES)
                    {
                        // Method names exist as entries in the methodNames and getNames tables, so if we are doing a getter
                        // don't error if the name is also a method name, because that means its really a method and will be checked
                        // when the method names are checked.
                        if (names.containsKey(name, Names.METHOD_NAMES))
                            continue;
                    }
                }

                if (name.equals("$construct"))
                    continue;

                int lookupKind = (names.getType(i) == Names.SET_NAMES ? SET_TOKEN : GET_TOKEN);

                int errorID = 0;

                int slot_id = interfaceIFrame.getSlotIndex(cx,lookupKind,name,namespace);
                int implied_id = interfaceIFrame.getImplicitIndex(cx, slot_id, EMPTY_TOKEN);
                boolean orig_getter = (slot_id == implied_id);


                if (!classNode.iframe.hasName(cx, lookupKind, name, namespace))
                {
                    errorID = kError_UnknownInterfaceMethod;
                }
                else
                {
                    Slot orig = interfaceIFrame.getSlot(cx, implied_id);

                    slot_id = classNode.iframe.getSlotIndex(cx,lookupKind,name,namespace);
                    implied_id = classNode.iframe.getImplicitIndex(cx, slot_id, EMPTY_TOKEN);
                    boolean slot_getter = (slot_id == implied_id);
                    Slot slot = classNode.iframe.getSlot(cx, implied_id);

                    if (!matchSignatures(slot, orig) || orig_getter != slot_getter)
                    {
                        errorID = kError_IncompatibleInterfaceMethod;
                    }
                }

                if (errorID != 0)
                {
                    String namespaceString = (namespace == cx.publicNamespace()) ? "public" : namespace.name;
                    String propType = "";
                    if (names.getType(i) == Names.SET_NAMES)
                        propType = "set ";
                    else if (orig_getter)
                        propType = "get ";
                    cx.error(classNode.pos(), errorID, propType + name, namespaceString, classNode.iframe.type.getTypeValue().name.toString());
                }
            }
        }
        for( int i = 0, size = interfaceIFrame.base_objs != null ? interfaceIFrame.base_objs.size() : 0 ; 
                i < size; 
                ++i)
        {
            checkClassInterfaceMethods(cx, classNode, interfaceIFrame.base_objs.at(i));
        }
    }

    private void checkInterfaceInterfaceMethods(Context cx,
                                                InterfaceDefinitionNode classNode,
                                                TypeValue interfaceCFrame)
    {
        ObjectValue interfaceIFrame = interfaceCFrame.prototype;
        checkInterfaceInterfaceMethods(cx, classNode, interfaceIFrame);
    }
    private void checkInterfaceInterfaceMethods(Context cx,
            InterfaceDefinitionNode classNode,
            ObjectValue interfaceIFrame)
    {
        InstanceBuilder builder = (InstanceBuilder)interfaceIFrame.builder;
        Names names = builder.getNames();

        if (names != null)
        {
            for (int i = 0; (i = names.hasNext(i)) != -1; i++)
            {
                String name = names.getName(i);
                ObjectValue namespace = names.getNamespace(i);

                if(!Builder.removeBuilderNames) {
                    if (names.getType(i) == Names.LOCAL_METHOD_NAMES)
                        continue;

                    if (names.getType(i) == Names.GET_NAMES)
                    {
                        // Method names exist as entries in the methodNames and getNames tables, so if we are doing a getter
                        // don't error if the name is also a method name, because that means its really a method and will be checked
                        // when the method names are checked.
                        if (names.containsKey(name, Names.METHOD_NAMES))
                            continue;
                    }
                }

                if (name.equals("$construct"))
                    continue;

                int lookupKind = (names.getType(i) == Names.SET_NAMES ? SET_TOKEN : GET_TOKEN);

                if (classNode.iframe.hasName(cx, lookupKind, name, namespace))
                {
                    String propType = "";
                    if (names.getType(i) == Names.SET_NAMES)
                        propType = "set ";
                    else if(names.getType(i) == Names.GET_NAMES)
                        propType = "get ";

                    cx.error(classNode.pos(), kError_ConflictingInheritedNameInInterface, propType + name,
                        interfaceIFrame.type.getTypeValue().name.toString());
                }
            }
        }
        for( int i = 0, size = interfaceIFrame.base_objs != null ? interfaceIFrame.base_objs.size() : 0 ; 
                i < size; 
                ++i)
        {
            checkInterfaceInterfaceMethods(cx, classNode, interfaceIFrame.base_objs.at(i));
        }
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
        return ObjectValue.undefinedValue;
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
        return ObjectValue.undefinedValue;
    }

    public Value evaluate(Context cx, AttributeListNode node)
    {
        for (Node n : node.items)
        {
            if (n != null)
            {
                n.evaluate(cx, this);
            }
        }

        return ObjectValue.undefinedValue;
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

    public Value evaluate(Context unused_cx, ImportDirectiveNode node)
    {
	   Context cx = node.cx;

        if (cx.useStaticSemantics())
        {
            String packageName = node.name.id.pkg_part;
            String definitionName = node.name.id.def_part;

	        if (definitionName != null && definitionName.length() > 0)
	        {
                StringBuilder b = new StringBuilder(packageName == null ? 0 : packageName.length() +
                                                  definitionName.length() + 1);
                if (packageName != null && packageName.length() > 0)
                {
                    b.append(packageName);
                    b.append(':');
                }
                b.append(definitionName);

                String import_name = b.toString();
                if (!cx.isValidImport(import_name))
                {
                    Namespaces namespaces = new Namespaces();
                    namespaces.add( cx.getNamespace(packageName.intern()) );
                    ReferenceValue ref = new ReferenceValue(cx, null, definitionName, namespaces);
                    Slot slot = ref.getSlot(cx,GET_TOKEN);
                    if (slot == null)
                    {
                        cx.error(node.name.pos(), kError_DefinitionNotFound, import_name);
                    }
                    else
                    {
                        cx.addValidImport(import_name);
                    }
                }
	        }
	        else
	        {
		        // Does the namespace exist?
		        ObjectValue ns = cx.getNamespace(packageName.intern());
		        if (!ns.isPackage())
		        {
		            cx.error(node.name.pos(), kError_DefinitionNotFound, packageName);
		        }
	        }
        }

        return ObjectValue.undefinedValue;
    }

    public Value evaluate(Context cx, SuperExpressionNode node)
    {
        Value super_value = ObjectValue.objectPrototype;
        TypeValue this_value = null;

        // All error cases handled by flow analyzer

        if( node.expr != null )
        {
            Value val = node.expr.evaluate(cx,this);
            this_value = val instanceof TypeValue ? (TypeValue) val : null;
        }
        else
        {
            int scope_depth = cx.getScopes().size()-1;
            Value val = cx.scope(scope_depth-2);
            this_value = val instanceof TypeValue ? (TypeValue) val : null;
        }

        if( this_value != null && this_value.baseclass != null)
        {
            super_value = this_value.baseclass.prototype;
        }

        return super_value;

    }

    public Value evaluate(Context cx, SuperStatementNode node)
    {
        Slot slot = null;

        if( node.baseobj != null )
        {
            ReferenceValue ref = new ReferenceValue(cx, node.baseobj,"$construct",cx.publicNamespace());
            slot = ref.getSlot(cx,EMPTY_TOKEN);
            ref.getType(cx,EMPTY_TOKEN);

            // cn: if the user did not define an explicit constructor for the baseclass, decl_styles is
            //  never initialized.  Initialize now to correctly detect wrong # of arguments supplied.
            if (slot != null && size(slot.getTypes()) == 0 && size(slot.getDeclStyles()) == 0)
            {
                slot.addDeclStyle(PARAM_Void);
                slot.addType(cx.voidType().getDefaultTypeInfo());
            }
        }

        if( node.call.args != null )
        {
            if( slot != null )
            {
                node.call.args.expected_types = slot.getTypes();
                node.call.args.decl_styles = slot.getDeclStyles();
            }

            node.call.args.evaluate(cx,this);
        }
        else if (cx.useStaticSemantics() && slot != null && size(slot.getDeclStyles()) != 0 && slot.getDeclStyles().at(0) == PARAM_Required)
        {
            StringBuilder err_arg_buf = new StringBuilder();
            int expected_num_args = slot.getDeclStyles().size();
            for(; expected_num_args > 0; expected_num_args--)
            {
                if (slot.getDeclStyles().at(expected_num_args-1) == PARAM_Required)
                    break;
            }
            err_arg_buf.append(expected_num_args);
            cx.error(node.pos(), kError_WrongNumberOfArguments, err_arg_buf.toString());
        }
        return ObjectValue.undefinedValue;
    }

    public Value evaluate(Context cx, RestExpressionNode node)
    {
        cx.internalError(node.pos(), "RestExpressionNode not yet implemented");
        return null;
    }

    public Value evaluate(Context cx, RestParameterNode node)
    {
        ParameterNode pnode = node;
        Value result = evaluate(cx,pnode);
        // Error checking done in PreprocessDefinitionTypeInfo(RestParameterNode)
        return result;

    }

    public Value evaluate(Context cx, ConfigNamespaceDefinitionNode node)
    {
    	return null;
    }
    public Value evaluate(Context cx, NamespaceDefinitionNode node)
    {
        rch_bits = reset_set(rch_bits, node.getKillBits(), node.getGenBits());

        if( node.ref != null)
        {
            node.ref.calcUseDefinitions(cx,rch_bits);
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

    public Value evaluate(Context cx, UsePrecisionNode node)
    {
        // nothing to do in this pass.  
    	// FlowAnalyzer already set params in BinaryExpression and UnaryExpression nodes
        return null;
    }

    public Value evaluate(Context cx, UseNumericNode node)
    {
        // nothing to do in this pass.  
    	// FlowAnalyzer already set params in StatementList nodes
        return null;
    }

    public Value evaluate(Context cx, UseRoundingNode node)
    {
        // nothing to do in this pass.  
    	// FlowAnalyzer already set params in BinaryExpression and UnaryExpression nodes
        return null;
    }

    public Value evaluate(Context cx, PragmaExpressionNode node)
    {
        cx.internalError(node.pos(), "PragmaExpressionNode not yet implemented");
        return null;
    }

    public Value evaluate(Context cx, TypedIdentifierNode node)
    {
        cx.internalError(node.pos(), "TypedIdentifierNode not yet implemented");
        return null;
    }

    public Value evaluate(Context cx, UntypedVariableBindingNode node)
    {
        cx.internalError(node.pos(), "UntypedVariableBindingNode not yet implemented");
        return null;
    }

    public Value evaluate(Context cx, UseDirectiveNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, LiteralXMLNode node)
    {
        if (node.list != null)
        {
            node.list.evaluate(cx, this);
        }
        return (node.is_xmllist ? cx.xmlListType().prototype : cx.xmlType().prototype);
    }

    public Value evaluate(Context cx, PackageNameNode node)
    {
        cx.internalError(node.pos(), "PackageNameNode not yet implemented");
        return null;
    }

    public Value evaluate(Context cx, PackageIdentifiersNode node)
    {
        cx.internalError(node.pos(), "PackageIdentifiersNode not yet implemented");
        return null;
    }

    public Value evaluate(Context cx, MetaDataNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, DocCommentNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, ImportNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, BinaryProgramNode node)
    {
		cx.pushScope(node.frame);
		node.statements.evaluate(cx, this);
		cx.popScope();

        return null;
    }

    public Value evaluate(Context cx, BinaryClassDefNode node)
    {
        // Nothing to do - all type info should have been set up by AbcParser
        return null;
    }

    public Value evaluate(Context cx, EmptyElementNode node)
    {
        return null;
    }
    public Value evaluate(Context cx, DefaultXMLNamespaceNode node)
    {
        if( node.expr != null )
        {
            Value val = node.expr.evaluate(cx,this);
            node.ref = val instanceof ReferenceValue ? (ReferenceValue) val : null;
        }
        return null;
    }

    private boolean compareTypeInfos(TypeInfo t1, TypeInfo t2)
    {
        if( t1 == t2 )
            return true;
        if( t1 != null && t2 != null)
        {
            return t1.isNullable() == t2.isNullable() && t1.getTypeValue() == t2.getTypeValue();
        }
        return false;
    }

    public Value evaluate(Context cx, TypeExpressionNode node)
    {
        return node.expr.evaluate(cx, this);
    }
    
    /**
     * Check for data loss in type conversion.
     * @param cx - the compile context.
     * @param dest_type - the type to convert to.
     * @param element_list - the list of potential literals to be checked. 
     */
    private void checkLiteralConversion(Context cx, TypeValue dest_type, ArgumentListNode element_list)
    {
    	//  The only types where this is relevant are int and uint.
    	boolean conversion_to_int = dest_type == cx.intType();
    	boolean conversion_to_uint = dest_type == cx.uintType();
    	
    	if ( !conversion_to_int && !conversion_to_uint )
    		//  No data loss (after type conversion, checked elsewhere).
    		return;
    	
    	for ( int i = 0; i < element_list.size(); i++ )
		{
			Node item = element_list.items.get(i);
			
			if ( item.isLiteralNumber() )
			{
				LiteralNumberNode literal = (LiteralNumberNode)item;
				double d_value = literal.numericValue.doubleValue();
				
				if ( conversion_to_int )
				{
					if ( d_value != literal.numericValue.intValue() )
					{
						cx.error(item.getPosition(), kError_LossyConversion, dest_type.getPrintableName());
					}
				}
				else if ( conversion_to_uint)
				{
					//  Note: can't call uintValue() b/c the parser parsed the numeric constant wrong"
					if ( d_value < 0 || d_value != (long)d_value)
					{
						cx.error(item.getPosition(), kError_LossyConversion, dest_type.getPrintableName());
					}
				}
				else
					//  Can't happen unless guard at the top of the routine has malfunctioned.
					assert(false);
			}
		}
    }
}
