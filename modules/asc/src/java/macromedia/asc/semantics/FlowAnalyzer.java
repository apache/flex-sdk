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

import macromedia.asc.embedding.avmplus.*;
import macromedia.asc.embedding.ErrorConstants;
import macromedia.asc.parser.*;
import macromedia.asc.util.*;
import macromedia.asc.util.graph.*;

import java.util.*;

import static macromedia.asc.parser.Tokens.*;
import static macromedia.asc.semantics.Slot.*;
import static macromedia.asc.embedding.avmplus.RuntimeConstants.*;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.*;


/**
 * FlowAnalyzer
 *
 * @author Jeff Dyer
 */
public final class FlowAnalyzer extends Emitter implements Evaluator, ErrorConstants
{
    private static final String INTRINSIC = "intrinsic".intern();
    private static final String INTERNAL = "internal".intern();
    private static final String PUBLIC = "public".intern();
    private static final String PRIVATE = "private".intern();
    private static final String PROTECTED = "protected".intern();
    private static final String PROTOTYPE = "prototype".intern();
    private static final String STATIC = "static".intern();

    private Names interfaceMethods = null;
    private boolean define_cv;
    private boolean errorNodeSeen = false;
    private boolean endpoint_dominator_is_set;
    private boolean found_circular_or_duplicate_class_definition;
    private Node endpoint_dominator;

    class CaseList extends ObjectList<Node>
    {
        boolean hasDefault;
    }

    private ObjectList<CaseList> case_exprs = new ObjectList<CaseList>();
    private ObjectList<ObjectList<FunctionCommonNode>> fexprs_sets = new ObjectList<ObjectList<FunctionCommonNode>>();
    private ObjectList<ObjectList<ClassDefinitionNode>> clsdefs_sets = new ObjectList<ObjectList<ClassDefinitionNode>>();
    private ObjectList<ObjectList<Node>> instanceinits_sets = new ObjectList<ObjectList<Node>>();
    private ObjectList<ObjectList<FunctionCommonNode>> staticfexprs_sets = new ObjectList<ObjectList<FunctionCommonNode>>();

    private ObjectList<Namespaces> usednamespaces_sets = new ObjectList<Namespaces>();
    private ObjectList<Namespaces> used_def_namespaces_sets = new ObjectList<Namespaces>();
    private ObjectList<Multinames> importednames_sets = new ObjectList<Multinames>();
    private ObjectList<ObjectValue> private_namespaces = new ObjectList<ObjectValue>();
    private ObjectList<ObjectValue> default_namespaces = new ObjectList<ObjectValue>();
    private ObjectList<ObjectValue> public_namespaces = new ObjectList<ObjectValue>();
    private ObjectList<ObjectValue> protected_namespaces = new ObjectList<ObjectValue>();
    private ObjectList<ObjectValue> static_protected_namespaces = new ObjectList<ObjectValue>();

    private IntList max_params_stack = new IntList();
    private IntList max_locals_stack = new IntList();
    private IntList max_temps_stack = new IntList();
    private ObjectList<String> fun_name_stack = new ObjectList<String>();
    private IntList with_used_stack = new IntList();
    private IntList exceptions_used_stack = new IntList();
    private ObjectList<NumberUsage> number_usage_stack = new ObjectList<NumberUsage>();

    private ObjectList<String> region_name_stack = new ObjectList<String>();
    private String package_name = "";
    private ObjectList<Boolean>        import_context = new ObjectList<Boolean>();
    private ObjectList<Boolean>        strict_context = new ObjectList<Boolean>();

    private IntList this_contexts = new IntList();
    private IntList super_context = new IntList();

    private boolean resolveInheritance;

    // unresolved defintion imports
    private ObjectList<Set<ReferenceValue>> import_def_unresolved_sets = new ObjectList<Set<ReferenceValue>>();
    // unresolved package imports
    private ObjectList<Set<ReferenceValue>> package_unresolved_sets = new ObjectList<Set<ReferenceValue>>();
    // unresolved namespaces
    private ObjectList<Set<ReferenceValue>> ns_unresolved_sets = new ObjectList<Set<ReferenceValue>>();
    // unresolved "extends" and "implements"
    private ObjectList<Set<ReferenceValue>> fa_unresolved_sets = new ObjectList<Set<ReferenceValue>>();
    // unresolved variable/function/parameter types
    private ObjectList<Set<ReferenceValue>> ce_unresolved_sets = new ObjectList<Set<ReferenceValue>>();
    private ObjectList<Set<ReferenceValue>> body_unresolved_sets = new ObjectList<Set<ReferenceValue>>();
    // unresolved member expressions
    private ObjectList<Set<ReferenceValue>> rt_unresolved_sets = new ObjectList<Set<ReferenceValue>>();
    // temporary container for accumulating unresolved ReferenceValues...
    private Set<ReferenceValue> unresolved = new HashSet<ReferenceValue>();
    // this is for the ProgramNode's allocateTemp() value because FA processes ProgramNode twice.
    private int programNode_temp;

    ObjectValue local_file_namespace;

    private FlowGraphEmitter getEmitter()
    {
        return (FlowGraphEmitter) impl;
    }

    private int loop_index;

    /***** ALL THE FOLLOWING ARE NEVER USED *******
    private boolean traverse_list_right_to_left = false;
    private boolean c_call_sequence = false;

    private int allocateFixedTemp()
    {
        // ISSUE why not return the allocTemp value?
        allocateTemp();
        return cur_fixed_temp_count++;
    }

    private void freeFixedTemp(int t)
    {
        //printf("\nfreeTemp() cur_temp_count = %d", cur_temp_count);
        --cur_fixed_temp_count;
        freeTemp(t);
    }

    public void push_args_first()
    {
        push_args_first(false);
    }

    public void push_args_first(boolean b)
    {
        c_call_sequence = b;
    }

    public void push_args_right_to_left()
    {
        push_args_right_to_left(false);
    }

    public void push_args_right_to_left(boolean b)
    {
        traverse_list_right_to_left = b;
    }
    **********************************************/


    // 3rd Edition features


    static boolean debug = false;

    public FlowAnalyzer(Emitter emitter)
    {
        super(emitter);
        loop_index = 0;
        define_cv = false;
        endpoint_dominator_is_set = false;
        found_circular_or_duplicate_class_definition = false;
        package_name = "";
        resolveInheritance = true;
        import_context.push_back(false);
    }

    public boolean checkFeature(Context cx, Node node)
    {
        // If the node->block is null and we are actually processing
        // code inside the normal flow of the method, then get and
        // save the current block. This is necessary because we pre-
        // process definition initializers before we start doing
        // proper flow analysis.

        if (node.block == null && doingMethod())
        {
            node.block = getEmitter().getBlock();
        }
        return true;
    }

    // Expression evaluators

    public Value evaluate(Context cx, IdentifierNode node)
    {
        // IDENTIFIER_EVAL_PROLOG

        if( node.ref == null)
        {
            Namespaces namespaces;

            // Add the namespaces associated with
            namespaces = usednamespaces_sets.back();

            // And then add the namespaces associated with node.name, if any
            Multinames importednames = importednames_sets.back();
            Namespaces nss           = importednames.get(node.name);
            if( nss != null )
            {
                // make and modify a copy so we don't affect the set of open namespaces
                namespaces = new Namespaces(namespaces);
                namespaces.addAll(nss);
            }

            node.ref = new ReferenceValue(cx, null,node.name,namespaces);
            node.ref.setIsAttributeIdentifier(node.isAttr());

            // If there is a set of names
            node.ref.setPosition(node.pos());
        }

        // IDENTIFIER_EVAL_EPILOG
        return node.ref;
    }

    public Value evaluate( Context cx, QualifiedIdentifierNode node )
    {
        // IDENTIFIER_EVAL_PROLOG

        if( node.ref == null)
        {
            ObjectValue ns = null;
            Namespaces nss = null;  // for protected

            if( node.qualifier != null)
            {
                AttributeListNode attrs = ((node.qualifier instanceof AttributeListNode) ? (AttributeListNode)node.qualifier : null);
                if( attrs != null)
                {
                    if( attrs.namespaces.size() > 0 )
                    {
                        ns = attrs.namespaces.get(0); // pick any one
                    }
                    else
                    {
                        cx.internalError(node.pos(), "internal error: invalid qualifier in QualifiedIdentifierNode");
                        ns = cx.publicNamespace(); // to fail gracefully
                    }
                }
                else
                {
                    Value ref = null;

                    MemberExpressionNode memb = ((node.qualifier instanceof MemberExpressionNode) ? (MemberExpressionNode)node.qualifier : null);

                    if( memb != null )
                    {
                        if( memb.isAny() )
                        {
                            ref = cx.anyNamespace();
                        }
                        else
                        {
                            IdentifierNode id = memb.selector.getIdentifier();
                            if( id != null && (id.name == INTERNAL) )
                            {
                                ns = default_namespaces.back();
                            }
                            else
                            if( id != null && (id.name == PRIVATE) )
                            {
                                if( private_namespaces.size() == 0 )
                                {
                                    cx.error(node.qualifier.pos(), kError_InvalidPrivate);
                                }
                                else
                                {
                                    ns = private_namespaces.back();
                                }
                            }
                            else
                            if( id != null && (id.name == PROTECTED) )
                            {
                                if( static_protected_namespaces.size() == 0 )
                                {
                                    cx.error(node.qualifier.pos(), kError_InvalidProtected);
                                }
                                else
                                {
                                    nss = new Namespaces();
                                    nss.push_back(static_protected_namespaces.back());

                                    if( protected_namespaces.size() != 0 )
                                    {
                                        for( ObjectValue n : usednamespaces_sets.back() )
                                        {
                                            if( n.getNamespaceKind() == Context.NS_PROTECTED )
                                            {
                                                nss.push_back(n);   // kind of a hack, but can't think of a better way to get the set of open protected namespaces
                                            }
                                        }
                                    }
                                }
                            }
                            else
                            if( id != null && (id.name == PUBLIC) )
                            {
                                ns = public_namespaces.back();
                            }
                            else
                            {
                                rt_unresolved_sets.last().addAll(unresolved);
                                unresolved.clear();

                                memb.evaluate(cx,this);
                                ref = memb.ref;

                                ns_unresolved_sets.last().addAll(unresolved);
                                unresolved.clear();
                            }

                        }
                    }
                    if (node.qualifier instanceof LiteralStringNode)     // this case for package qualified references only?
                    {
                        LiteralStringNode lsn = (LiteralStringNode)node.qualifier;
                        ns = cx.getNamespace(lsn.value);
                    }
                    else if( ref != null )
                    {
                        Value value = ref.getValue(cx);
                        ns = ((value instanceof ObjectValue) ? (ObjectValue) value : null);
                        if( ns == null )
                        {
                            return null;
                            // cx.error(node.qualifier.pos(), kError_UndefinedNamespace );
                        }
                    }
                    else
                    if( ns == null && nss == null )
                    {
                        cx.error(node.qualifier.pos(), kError_UndefinedNamespace);
                    }
                }
            }
            else
            {   // if there is no qualifier, then it an internal definition (e.g. no attributes)
                ns = default_namespaces.back();
            }

            if( !node.name.equals("") )   // otherwise it is a QualifiedExpression with no name and no corresponding reference value
            {
                if( nss != null /* protected = multiname */ )
                {
                    node.ref = new ReferenceValue(cx,null,node.name,nss);
                }
                else
                {
                    node.ref = new ReferenceValue(cx,null,node.name,ns);
                }
                node.ref.setIsAttributeIdentifier(node.isAttr());
                node.ref.setPosition(node.pos());
            }
            else
            if( node instanceof QualifiedExpressionNode )
            {
                // Save the reserved namespace as a namespace set to be used later
                // to create a constant multiname
                QualifiedExpressionNode qen = (QualifiedExpressionNode)node;
                if( ns != null )
                {
                    qen.nss = new Namespaces();
                    qen.nss.push_back(ns);
                }
                else
                {
                    qen.nss = nss;
                }
            }
        }

        // IDENTIFIER_EVAL_EPILOG
        return node.ref;
    }

    public Value evaluate( Context cx, QualifiedExpressionNode node )
    {
        // IDENTIFIER_EVAL_PROLOG

        if( node.ref == null)
        {
            evaluate(cx,(QualifiedIdentifierNode)node);
            node.expr.evaluate(cx,this);
        }

        // IDENTIFIER_EVAL_EPILOG
        return node.ref;
    }

    public Value evaluate(Context cx, ThisExpressionNode node)
    {
        if (debug)
        {
            System.out.print("\n// +ThisExpressionNode");
        }

        getEmitter().AddStmtToBlock(node.toString());

        // ERROR: 'this' is only allowed in global and instance functions
        // (including methods and accessors). It is not allowed in class
        // static and package methods.

        switch( this_contexts.last() )
        {
        case error_this:
        case cinit_this:
        case package_this:
            cx.error(node.pos(), kError_ThisUsedInStaticFunction);
            break;
        case init_this:
        	cx.error(node.pos(), kError_ThisUsedInInitializer);
        	break;
        default:
            // valid use of this
            break;
        }

        if( debug ) System.out.print("\n// -ThisExpressionNode");
        return null;
    }

    public Value evaluate(Context cx, LiteralBooleanNode node)
    {
        if (debug)
        {
            System.out.print("\n// +LiteralBoolean");
        }

        getEmitter().AddStmtToBlock(node.toString());

        ObjectValue val = node.value?cx.booleanTrue():cx.booleanFalse();

        if (debug)
        {
            System.out.print("\n// -LiteralBoolean");
        }
        return val;
    }

    public Value evaluate(Context cx, LiteralNullNode node)
    {
        if (debug)
        {
            System.out.print("\n// +LiteralNull");
        }

        getEmitter().AddStmtToBlock(node.toString());

        if (debug)
        {
            System.out.print("\n// -LiteralNull");
        }
        return null;
    }

    public Value evaluate(Context cx, LiteralNumberNode node)
    {
        if (debug)
        {
            System.out.print("\n// +LiteralNumber");
        }

    	node.numberUsage = number_usage_stack.last();
        getEmitter().AddStmtToBlock(node.toString());

        if (debug)
        {
            System.out.print("\n// -LiteralNumber");
        }
        return null;
    }

    public Value evaluate(Context cx, LiteralStringNode node)
    {
        if (debug)
        {
            System.out.print("\n// +LiteralString");
        }

        getEmitter().AddStmtToBlock(node.toString());

        if (debug)
        {
            System.out.print("\n// -LiteralString");
        }
        return null;
    }

    public Value evaluate(Context cx, LiteralRegExpNode node)
    {
        if (debug)
        {
            System.out.print("\n// +LiteralRegExp");
        }

        getEmitter().AddStmtToBlock(node.toString());

        if (debug)
        {
            System.out.print("\n// -LiteralRegExp");
        }
        return null;
    }

    public Value evaluate(Context cx, LiteralObjectNode node)
    {
        if (debug)
        {
            System.out.print("\n// +LiteralObject");
        }

        getEmitter().AddStmtToBlock(node.toString());

        if (node.fieldlist != null)
        {
            node.fieldlist.evaluate(cx, this);
        }

        if (debug)
        {
            System.out.print("\n// -LiteralObject");
        }
        return null;
    }

    public Value evaluate(Context cx, LiteralFieldNode node)
    {
        if (debug)
        {
            System.out.print("\n// +LiteralField");
        }

        int t = allocateTemp();

        getEmitter().AddStmtToBlock(node.toString());

        if (node.name != null)
        {
            // For LiteralFieldNode's with a name of type
            // IdentifierNode, ReferenceValue.findUnqualified() always
            // returns false, so speed up the process by creating a
            // ReferenceValue with no namespaces.
            if (node.name instanceof IdentifierNode)
            {
                IdentifierNode identifier = (IdentifierNode) node.name;
                Namespaces namespaces = new Namespaces();
                ReferenceValue referenceValue = new ReferenceValue(cx, null, identifier.name, namespaces);
                referenceValue.setIsAttributeIdentifier(false);
                referenceValue.setPosition(node.pos());
                node.ref = referenceValue;
            }
            else
            {
                Value value = node.name.evaluate(cx,this);
                node.ref = ((value instanceof ReferenceValue) ? (ReferenceValue)value : null);
            }
        }
        node.value.evaluate(cx, this);

        freeTemp(t);
        if (debug)
        {
            System.out.print("\n// -LiteralField");
        }
        return node.ref;

    }

    public Value evaluate(Context cx, LiteralArrayNode node)
    {
        if (debug)
        {
            System.out.print("\n// +LiteralArray");
        }

        getEmitter().AddStmtToBlock(node.toString());

        if (node.elementlist != null)
        {
            node.elementlist.evaluate(cx, this);
        }

        if (debug)
        {
            System.out.print("\n// -LiteralArray");
        }
        return null;
    }
    
    public Value evaluate(Context cx, LiteralVectorNode node)
    {
        if (debug)
        {
            System.out.print("\n// +LiteralVector");
        }

        getEmitter().AddStmtToBlock(node.toString());

        node.type.evaluate(cx, this);
        if (node.elementlist != null)
        {
            node.elementlist.evaluate(cx, this);
        }

        if (debug)
        {
            System.out.print("\n// -LiteralVector");
        }
        return null;
    }

    public Value evaluate(Context cx, MemberExpressionNode node)
    {
        if (debug)
        {
            System.out.print("\n// +MemberExpression");
        }

        /* If the member expression has a base, evaluate it and try to
         * bind it to its slot. If it binds, then get the slot
         * type and then the prototype of that type. The prototype will
         * be the compile-time stand-in for the instance.
         */

        ObjectValue base = null;




        // Simple reference
        if (node.base == null)
        {
            Value value = node.selector.evaluate(cx,this);
            node.ref = ((value instanceof ReferenceValue) ? (ReferenceValue)value : null);

            // This is an alias to node.<selector>.ref, so the
            // evaluator for node.<selector> has access to the
            // same info

            // Simple references always have a node.ref, unless they
            // are a function literal.

            if( node.ref != null )
            {
                Slot slot = node.ref.getSlot(cx,(node.ref.getKind()==SET_TOKEN?SET_TOKEN:GET_TOKEN));
                node.ref.slot = null; // Don't bind to this slot, since it could be hidden by another slot later
                if (slot == null)
                {
                    // System.err.println("Unresolved symbol '" + node.ref.toMultiName() + "' on line " + (cx.getInputLine(node.selector.pos()) + 1) + " in " + cx.getErrorOrigin());
                    unresolved.add(node.ref);
                }

            }
        }

        Value val = null;
        // check again, in case the base got added above
        if( node.base != null )
        {
            val = node.base.evaluate(cx, this);
            val = val != null ? val.getValue(cx) : null;
            base = ((val instanceof ObjectValue) ? (ObjectValue)val : null);

            // It's a literal reference
            node.selector.base = (base != null) ? base : ObjectValue.undefinedValue;
            val = node.selector.evaluate(cx, this);
            node.ref = ((val instanceof ReferenceValue) ? (ReferenceValue)val : null);

            if (node.ref != null)
            {
                if (base != null && base == cx.globalScope())
                {
                    // Issue: for this to work, we need to be able to evaluate 'this' amoung
                    // other values.
                    node.ref.setScopeIndex(0);
                    node.base = null;
                    // Don't need to set the base of ref since we know its the global
                }
            }
            else // It's a dynamic reference (bracket only)
            {
                // Nothing to do right now
            }
        }

        // special case: if selector is not a get expr, then the result is not an lvalue
        if( node.selector instanceof GetExpressionNode || node.selector instanceof ApplyTypeExprNode)
        {
            val = node.ref;
        }
        else
        {
            val = null;
        }

        if (node.base instanceof SuperExpressionNode)
        {
            adjustProtectedNamespace(cx, node.ref);
        }

        if (debug)
        {
            System.out.print("\n// -MemberExpression");
        }

        return val;
    }

    public Value evaluate(Context cx, ApplyTypeExprNode node)
    {
        if( node.ref != null )
        {
            // Already evaluated this node
            return node.ref;
        }

        if (debug)
        {
            System.out.print("\n// +ApplyTypeExpression");
        }
        getEmitter().AddStmtToBlock(node.toString());

        if (node.typeArgs != null)
        {
            node.typeArgs.evaluate(cx, this);
        }

        Value value = node.expr.evaluate(cx,this);

        if( node.expr instanceof IdentifierNode )
        {
            node.ref = ((value instanceof ReferenceValue) ? (ReferenceValue)value : null);
            if( node.typeArgs != null && node.typeArgs.values != null )
            {
                ObjectList<ReferenceValue> typerefs = new ObjectList<ReferenceValue>();
                for ( Value v : node.typeArgs.values )
                {
                    if( v instanceof ReferenceValue )
                        typerefs.add((ReferenceValue)v);
                }
                if( typerefs.size() != node.typeArgs.values.size() )
                    node.ref = null;  //Something didn't resolve to a reference
                if( node.ref != null )
                    node.ref.addTypeParam(typerefs.at(0));
            }
        }
        else
        {
            node.ref = null;
        }

        if (debug)
        {
            System.out.print("\n// -ApplyTypeExpression");
        }
        return node.ref;
    }

    public Value evaluate(Context cx, CallExpressionNode node)
    {
        if( node.ref != null )
        {
            // Already evaluated this node
            return node.ref;
        }

        if (debug)
        {
            System.out.print("\n// +CallExpression");
        }

        int t = allocateTemp();

        getEmitter().AddStmtToBlock(node.toString());

        if (node.args != null)
        {
            node.args.evaluate(cx, this);
        }

        Value value = node.expr.evaluate(cx,this);

        if( node.expr instanceof IdentifierNode )
        {
            node.ref = ((value instanceof ReferenceValue) ? (ReferenceValue)value : null);
        }
        else
        {
            node.ref = null;
        }

        if( node.ref != null && "Vector$object".equals(node.ref.name) && node.ref.namespaces.contains(cx.publicNamespace()))
        {
            if(node.expr instanceof TypeIdentifierNode)
            {
                TypeIdentifierNode tin = (TypeIdentifierNode)node.expr;
                int args_size = node.args != null ? node.args.size():0;
                ObjectList<Node> new_args = new ObjectList<Node>(args_size+1);
                new_args.push_back(tin.typeArgs.items.at(0));
                if( node.args != null )
                {
                    new_args.addAll(node.args.items);
                }
                node.args = cx.getNodeFactory().argumentList(null, null);
                node.args.items = new_args;
            }
        }

        if( node.isAttributeIdentifier() )
        {
            cx.error(node.pos()-2, kError_AttributesAreNotCallable);
        }
        if (node.ref != null )
        {
            node.ref.setBase(node.base);  // inherited attribute
        }

        freeTemp(t);

        return node.ref;
    }

    public Value evaluate(Context cx, InvokeNode node)
    {

        if (debug)
        {
            System.out.print("\n// +Invoke");
        }

        getEmitter().AddStmtToBlock(node.toString());

        node.ref = new ReferenceValue(cx, null, node.name, cx.publicNamespace()/*used_namespaces*/);
        node.ref.setKind(EMPTY_TOKEN);
        node.ref.setBase(node.base);  // inherited attribute
        node.ref.setPosition(node.pos());

        if (node.args != null)
        {
            node.args.evaluate(cx, this);
        }

        if (debug)
        {
            System.out.print("\n// -Invoke");
        }

        return null;
    }

    public Value evaluate(Context cx, SetExpressionNode node)
    {
        getEmitter().AddStmtToBlock(node.toString());
        int t = allocateTemp();

        Value value = node.expr.evaluate(cx,this);
        node.ref = ((value instanceof ReferenceValue) ? (ReferenceValue)value : null);

        if (node.ref != null)
        {
            if( node.base != null )
            {
                node.ref.setBase(node.base);  // inherited from member expression
            }

            // if in a with block, we can't trust the resolution of the slot
            if (cx.statics.withDepth == -1) 
            {
                node.ref.getSlot(cx, SET_TOKEN);
                node.gen_bits = getEmitter().NewDef(node);
            }
        }

        if (node.ref == null)
        {
            node.args.evaluate(cx, this);
        }
        else
        {
            node.args.evaluate(cx, this);

            if (cx.statics.withDepth == -1)
            {
                Slot slot = null;
                node.ref.setBase(node.base);  // inherited attribute
                slot = node.ref.getSlot(cx, GET_TOKEN);
                node.ref.setKind(SET_TOKEN);
                if (slot != null)
                {
                    slot.addDefBits(node.gen_bits);
                }
            }
        }

        freeTemp(t);
        return node.ref;
    }

    public Value evaluate(Context cx, DeleteExpressionNode node)
    {
        if (debug)
        {
            System.out.print("\n// +DeleteExpression");
        }

        getEmitter().AddStmtToBlock(node.toString());

        Value val = node.expr.evaluate(cx,this);
        node.ref = ((val instanceof ReferenceValue) ? (ReferenceValue)val : null);

        if (node.ref != null)
        {
            node.ref.setBase(node.base);  // inherited attribute
            node.ref.setKind(GET_TOKEN);
        }

        return node.ref;
    }

    public Value evaluate(Context cx, GetExpressionNode node)
    {
        if (debug)
        {
            System.out.print("\n// +GetExpression");
        }

        getEmitter().AddStmtToBlock(node.toString());

        Value val = node.expr.evaluate(cx,this);
        node.ref = ((val instanceof ReferenceValue) ? (ReferenceValue)val : null);

        if (node.ref != null && node.base != null )
        {
            node.ref.setBase(node.base);  // inherited attribute
            node.ref.setKind(GET_TOKEN);
        }

        if (debug)
        {
            System.out.print("\n// -GetExpression");
        }
        return node.ref;
    }

    public Value evaluate(Context cx, IncrementNode node)
    {
        if (debug)
        {
            System.out.print("\n// +IncrementNode");
        }

        int t1 = allocateTemp();  // approximation of actual temp usage.
        int t2 = allocateTemp();
        int t3 = allocateTemp();
        
        node.numberUsage = number_usage_stack.last();

        getEmitter().AddStmtToBlock(node.toString());

        Value val = node.expr.evaluate(cx,this);
        node.ref = ((val instanceof ReferenceValue) ? (ReferenceValue)val : null);

        if (node.ref != null)
        {
            node.ref.setBase(node.base);  // inherited attribute
            node.ref.getSlot(cx, GET_TOKEN);
        }

        freeTemp(t3);
        freeTemp(t2);
        freeTemp(t1);

        if (debug)
        {
            System.out.print("\n// -IncrementNode");
        }
        return node.ref;
    }

    /*
     * There are two kinds of unary operators: those that operate on references;
     * and those that operate on values. The reference operators (Get,Put,Delete,Call,
     * Construct are implemented as methods in the ObjectValue. The value operators
     * are implemented as methods of the global object.
     */

    public Value evaluate(Context cx, UnaryExpressionNode node)
    {

        if (debug)
        {
            System.out.print("\n// +UnaryExpressionNode");
        }

        getEmitter().AddStmtToBlock(node.toString());

        node.expr.evaluate(cx, this);
        node.numberUsage = number_usage_stack.last();

        if (debug)
        {
            System.out.print("\n// -UnaryExpressionNode");
        }

        return null;
    }

    public Value evaluate(Context cx, BinaryExpressionNode node)
    {

        if (debug)
        {
            System.out.print("\n// +BinaryExpressionNode");
        }

        getEmitter().AddStmtToBlock(node.toString());

        node.lhs.evaluate(cx, this);
        node.rhs.evaluate(cx, this);
        node.numberUsage = number_usage_stack.last();

        if (debug)
        {
            System.out.print("\n// -BinaryExpressionNode");
        }

        return null;
    }

    public Value evaluate(Context cx, ConditionalExpressionNode node)
    {
        if (debug)
        {
            System.out.print("\n// +ConditionalExpressionNode");
        }

        node.condition.evaluate(cx, this);        // leaves value of governing expr on stack
        If(IF_false);  // if false, jump past then actions
        node.thenexpr.evaluate(cx, this);
        Else(); // jump past else actions
        PatchIf(getIP());  // patch target of if jump
        node.elseexpr.evaluate(cx, this);
        PatchElse(getIP()); // patch target of else jumps

        if (debug)
        {
            System.out.print("\n// -ConditionalExpressionNode");
        }
        return null;
    }

    public Value evaluate(Context cx, ArgumentListNode node)
    {

        if (debug)
        {
            System.out.print("\n// +ArgumentList");
        }

        // ISSUE: guarantee that each instance is visited only once.

	    for (int i = 0, size = node.items.size(); i < size; i++)
        {
	        Node n = node.items.get(i);
            if (n != null)
            {
                n.evaluate(cx, this);
            }
        }

        if (debug)
        {
            System.out.print("\n// -ArgumentList");
        }
        return null;
    }

    public Value evaluate(Context cx, ListNode node)
    {

        if (debug)
        {
            System.out.print("\n// +List");
        }

        Value val = null;

	    for (int i = 0, size = node.items.size(); i < size; i++)
        {
	        Node n = node.items.get(i);
            val = n.evaluate(cx,this);
            node.values.push_back(val);
        }

        if (debug)
        {
            System.out.print("\n// -List");
        }
        return val;
    }

    /*
     * Statements
     */

    public Value evaluate(Context cx, StatementListNode node)
    {
        if (debug)
        {
            System.out.print("\n// +StatementListNode");
        }

        NodeFactory nodeFactory = cx.getNodeFactory();

        if (node.has_pragma) {
        	NumberUsage blockUsage = new NumberUsage(number_usage_stack.back());
        	number_usage_stack.push_back(blockUsage);
        }
        ObjectValue obj = cx.scope();
        boolean inside_class = false;
        if (obj.builder instanceof InstanceBuilder ||
            obj.builder instanceof ClassBuilder)
        {
            inside_class = true;
        }

        boolean inside_cinit = ( this_contexts.last() == cinit_this );

        ObjectList<DefinitionNode> hoisted_defs = new ObjectList<DefinitionNode>();
        ObjectList<Node> instance_inits = instanceinits_sets.back();

        {
            // iterate through the statements backwards to find the end point dominator

            for (int i = node.items.size() - 1; i >= 0; i--)
            {
                Node n = node.items.get(i);
                if (n != null)
                {
                    // While we are iterating backwards set aside any definitions we find,
                    // to be processed before the other statements. Handle the initializers
                    // according to their type (e.g. functions get moved to the start of
                    // statements, var initializers stay put

                    // cn: a definition might live in a labelled node
                    LabeledStatementNode label = null;
                    if (n instanceof LabeledStatementNode)
                    {
                        label = (LabeledStatementNode)n;
                        n = label.statement;
                    }
                    if (n.isDefinition())
                    {
                        DefinitionNode def = ((n instanceof DefinitionNode) ? (DefinitionNode)n : null);

                        // Eval the definition. At this point we are iterating backward
                        // (to find the end point dominator) so definitions are ordered
                        // last to first. This is weird, but should not be a problem
                        // since their initializers are evaluated in the right order.

                        if(def instanceof IncludeDirectiveNode || def instanceof ImportDirectiveNode)
                        {
                            // TODO: Remove eventually
                            /* SPECIAL CASE (for bug 124494)
                             * So all statements in an included file have IncludeDirectives
                             * wrapped around them (e.g. evaluated with the correct [sub-]context):
                             *
                             * Hoist a copy of the ID node, leave the original ID node where it is.
                             * Both hoisted definitions and left behind (non-def) statements
                             * are correctly bracketed.
                             *
                             * This is assuming that, semantically, we want non-defs in an
                             * included file (the include statement being within a classdef)
                             * to work, and not throw an error. */

                            hoisted_defs.push_back(def);
                            // node.items.set(i, nodeFactory.emptyStatement(node.pos())); // don't do this
                        }
                        else if( n.isConst() || inside_class )
                        {
                            // If definition is const, then put it and its initializer
                            // at the beginning of the block and replace current item
                            // with an empty statement.

                            hoisted_defs.push_back(def);  // C B A
//                            hoisted_defs.insert(hoisted_defs.begin(),def);
                            if (label == null)
                                node.items.set(i, nodeFactory.emptyStatement());
                            else
                                label.statement = nodeFactory.emptyStatement();
                        }
                        else
                        {
                            // Otherwise, leave the initializer at the location of the
                            // original definition and initalize the variable to its default
                            // value at the beginning of the block.

                            hoisted_defs.push_back(def);
                            if( def.attrs != null && def.attrs.hasAttribute(INTRINSIC) )
                            {
                                if (label == null)
                                    node.items.set(i, nodeFactory.emptyStatement());
                                else
                                    label.statement = nodeFactory.emptyStatement();
                            }
                            else
                            {
                                Node init = n.initializerStatement(cx);
                                if (init != null)
                                {
                                    // Put initializer(if there is one) at position
                                    // of original definition.
                                    if (label == null)
                                        node.items.set(i, init);
                                    else
                                        label.statement = init;
                                }
                                else
                                {
                                    if (label == null)
                                        node.items.set(i, nodeFactory.emptyStatement());
                                    else
                                        label.statement = nodeFactory.emptyStatement();
                                }
                            }
                        }
                    }
                    else if (!endpoint_dominator_is_set &&
                        loop_index == 0 && n.isExpressionStatement() &&
                        cx.getScopes().size() == 1 )
                    {
                        // The end point dominator is the statement that leaves
                        // the continuation value on the stack. All other results,
                        // don't need to be pushed onto the stack.

                        endpoint_dominator = n;
                        endpoint_dominator_is_set = true;
                    }
                }
            }
        }

        ObjectList<Node> inits = new ObjectList<Node>();

        {
            // Insert initializers for constants and functions at the
            // beginning of the block.

            for (int i = hoisted_defs.size() - 1; i >=0; i--) // A B C
            {
                DefinitionNode def = hoisted_defs.get(i);
                {
                    // pre-process namespace definitions and attributes

                    boolean is_static = false;
                    boolean is_intrinsic = false;

                    boolean is_include   = def instanceof IncludeDirectiveNode;
                    boolean is_namespace = def instanceof NamespaceDefinitionNode;
                    boolean is_use       = def instanceof UseDirectiveNode || def instanceof ImportDirectiveNode;
                    boolean is_const     = false;  // tbd

                    if ( is_namespace || is_const || is_use || is_include )
                    {
                        if (def.attrs != null)
                        {
                            def.attrs.evaluate(cx, this);
                            is_static = def.attrs.hasStatic;
                            is_intrinsic = def.attrs.hasIntrinsic;
                        }
                        def.evaluate(cx,this);
                    }
                    else
                    if( def.attrs != null)
                    {
                        def.attrs.evaluate(cx,this);
                        is_static = def.attrs.hasStatic;
                        is_intrinsic = def.attrs.hasIntrinsic;
                    }

                    boolean needs_init = (!is_use && !is_namespace && !is_intrinsic && def.isConst()) || inside_class;

                    if( inside_cinit && !is_static )
                    {
                        instance_inits.push_back(def);
                        if( needs_init )
                        {
                            instance_inits.push_back(def.initializerStatement(cx));
                        }
                    }
                    else
                    {
                        if( !is_use && !(def instanceof ClassDefinitionNode && needs_init)  ) // ISSUE: remove this special case check
                        {
                            inits.push_back(def);
                        }

                        if( needs_init )
                        {
                            inits.push_back(def.initializerStatement(cx));   // A B C
                        }   // otherwise, there is already a initializer at the orginal point of definition
                    }
                }
            }
        }

        {   // add the non-static inits to the beginning of the statements list

            for (int i = inits.size() - 1; i>= 0;i--)  // C B A
            {
                node.items.add(0, inits.get(i));  // A B C
            }
        }

        {
            // Now rip through the statements

            for (Node n : node.items)
            {
                if (n == endpoint_dominator)
                {
                    // This statement is the end point dominator, therefore
                    // set the define_cv flag so the evaluator will know that
                    // this is an implicit assignment to _cv and will create
                    // a new definition for it.

                    define_cv = true;
                }
                else if (!endpoint_dominator_is_set)
                {
                    // This happens when there is no statement that leaves a
                    // continuation value on the stack. In this case, an
                    // empty value is pushed onto the stack at start of the
                    // program.

                    define_cv = true;
                    endpoint_dominator_is_set = true;
                }
                else
                {
                    // This statement is not the end point dominator, and
                    // The end point dominator has been set, then do nothing
                }

                if (n != null)
                {
                    if (!doingMethod() && !n.isDefinition())
                    {
                        // We are done with definitions, which means we are doing
                        // program statements.
                        StartMethod(fun_name_stack.last(), max_params_stack.last(),
                        max_locals_stack.last(), max_temps_stack.last(),
                        false, 0);
                    }

                    n.evaluate(cx, this);
                }
            }

            if (!doingMethod() )  // If still not doing method, then start doing it now.
                                 // This happens when you have a block with only definitions
            {
                StartMethod(fun_name_stack.last(), max_params_stack.last(),
                    max_locals_stack.last(), max_temps_stack.last(), false, 0);
                // Now we are doing a method
            }

        }
/*
        if( node.is_block )
        {
            usednamespaces_sets.back().pop_back();
            default_namespaces.pop_back();
        }
*/
        if (node.has_pragma) {
        	node.numberUsage = number_usage_stack.back();
        	number_usage_stack.pop_back();
        }
        if (debug)
        {
            System.out.print("\n// -StatementListNode");
        }
        return null;
    }

    public Value evaluate(Context cx, EmptyStatementNode node)
    {
        if (debug)
        {
            System.out.print("\n// +EmptyStatementNode");
        }

        if (debug)
        {
            System.out.print("\n// -EmptyStatementNode");
        }
        return null;
    }

    public Value evaluate(Context cx, ExpressionStatementNode node)
    {
        if (debug)
        {
            System.out.print("\n// +ExpressionStatementNode");
        }

        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }

        if (define_cv && !node.isVarStatement()) // Var statements have empty cv's
        {
            node.gen_bits = getEmitter().NewDef(node);
            cx.globalScope().getSlot(cx, SLOT_Global__cv).addDefBits(node.gen_bits);
        }
        else
        if( node.expr != null )
        {
            node.voidResult();
            node.expected_type = cx.voidType();
        }

        if (debug)
        {
            System.out.print("\n// -ExpressionStatementNode");
        }
        return null;
    }

    public Value evaluate(Context cx, LabeledStatementNode node)
    {
        if (debug)
        {
            System.out.print("\n// +LabeledStatementNode");
        }


        node.label.evaluate(cx, this);
        MemberExpressionNode mnode = (MemberExpressionNode) ((ListNode) node.label).items.last();
        // grabbing the ref as opposed to evaluating memberexpressionnode to get it (workaround)
        ReferenceValue ref = mnode.ref;
        ObjectValue obj = cx.getScopes().last();

        // Define the label name in the current scope. Use the lableNamespace to avoid collisions
        // with other names. loop_index is incremented upon entry to a loop or switch statement,
        // and decremented upon exit.

        String labelName = null;

        if (ref == null)
        {
            cx.error(node.pos(), kError_InvalidLabel);
        }
        else
        {
            labelName = ref.name;
        }

        if (labelName != null)
        {
            if (obj.defineName(cx, GET_TOKEN, labelName, ObjectValue.labelNamespace, loop_index) == 0)
            {
                cx.error(node.pos(), kError_DuplicateLabel);
            }
            // and if it is a loop label, add a name for the loop label namespace too
            if (node.is_loop_label && obj.defineName(cx, GET_TOKEN, labelName, ObjectValue.loopLabelNamespace, loop_index) == 0)
            {
                cx.error(node.pos(), kError_DuplicateLabel);
            }
        }

        // Evaluate the nested statements. Any references to the label name from a break
        // or continue will be replace with that label's loop index.
        if (node.statement != null)
        {
            node.loop_index = loop_index;
            // If it's a loop label then share a loop index with the loop statement
            // Otherwise give this label a distinct index so that breaks inside of blocks
            // end up at the correct target (ie the end of the block)
            if( !node.is_loop_label )
            {
                loop_index++;
                LabelStatementBegin();
            }
            node.statement.evaluate(cx, this);

            // If the label is a loop label, then let the loop handle the patchbreak/continue.  Since the label and
            // the loop share the same loop index this will work out fine (and actually creates problems if we try
            // and do it in both places).
            if( !node.is_loop_label )
            {
                LabelStatementEnd(node.loop_index); // patch breaks within labelled statement
                loop_index--;
            }
        }

        // Remove the label name now that we are done with it.

        if (labelName != null)
        {
            obj.removeName(cx, GET_TOKEN, labelName, ObjectValue.labelNamespace);
        }

        if (debug)
        {
            System.out.print("\n// -LabeledStatementNode");
        }
        return null;
    }

    public Value evaluate(Context cx, IfStatementNode node)
    {
        if (debug)
        {
            System.out.print("\n// +IfStatementNode");
        }

        Value val = node.condition.evaluate(cx, this);
        val = val!=null?val.getValue(cx):null;

        if( val != null && val.getType(cx).getTypeValue() == cx.booleanType() )  // If there is a boolean value, use it to compile out code
        {
            node.is_true  = val.booleanValue()?true:false;
            node.is_false = val.booleanValue()?false:true;

            if( node.is_true )
            {
                if( node.thenactions != null )
                {
                    node.thenactions.evaluate(cx,this);
                }
            }
            else
            if( node.is_false )  // always the case, in this case
            {
                if( node.elseactions != null)
                {
                    node.elseactions.evaluate(cx,this);
                }
            }
        }
        else
        {

            If(IF_false);  // if false, jump past then actions
            if (node.thenactions != null)
            {
                node.thenactions.evaluate(cx, this);
            }
            Else(); // jump past else actions
            PatchIf(getIP());  // patch target of if jump
            if (node.elseactions != null)
            {
                node.elseactions.evaluate(cx, this);
            }
            PatchElse(getIP()); // patch target of else jump
        }

        if (debug)
        {
            System.out.print("\n// -IfStatementNode");
        }
        return null;
    }

    int inside_switch = 0;

    public Value evaluate(Context cx, SwitchStatementNode node)
    {
        if (debug)
        {
            System.out.print("\n// +SwitchStatementNode");
        }

        int t = allocateTemp();  // approximation of actual temp usage.

        case_exprs.add(new CaseList());
        SwitchBegin();                    // jump past statements
        if (node.statements != null)
        {
            ++inside_switch;
            node.loop_index = loop_index++;
            node.statements.evaluate(cx, this);
            --loop_index;
            --inside_switch;
        }

        // See if there is a default case. If not, then add one.

        {
            CaseList case_expr = case_exprs.last();
            if (!case_expr.hasDefault)
            {
                // no default label, lets add one.
                case_expr.add(null);
                CaseLabel(true);  // default, just in case there wasn't one yet.
                Break(node.loop_index);  // default loop_index
            }
        }

        Break(node.loop_index);              // Last chance break, in case there isn't one
        PatchSwitchBegin(getIP());            // patches initial jump past statements
        node.expr.evaluate(cx, this);        // leaves value of governing expr on stack

        {
            int case_index = 0;
            int default_index = 0;
            ObjectList<Node> case_expr = case_exprs.removeLast();
            int case_expr_size = case_expr.size();
            if (case_expr_size != 0)
            {
                for (case_index = 0; case_index < case_expr_size; ++case_index)
                {
                    Node expr = case_expr.get(case_index);
                    if (expr != null)
                    {  // skip default ( expr == 0 )
                        /* do operands */
                        expr.evaluate(cx, this);
                    }
                    else
                    {
                        default_index = case_index;
                    }

                    If(IF_false);  // if false, jump past then actions
                    PushCaseIndex(case_index);
                    Else(); // jump past else actions
                    PatchIf(getIP());  // patch target of if jump
                }
            }
            PushCaseIndex(default_index);
            while (case_index-- != 0)
            {
                PatchElse(getIP()); // patch target of else jumps
                /* this is like nested ifs:
                 *     if(...) 0;
                 *       else if(...) 1;
                 *     else if(...) 2;
                 *     else if(...) 3;
                 *     else 4; // default;
                 * you keep trying conditions until you find one
                 * that is true and then evaluate the statement
                 * and jump to the end.
                 */
            }
        }
        SwitchTable();                        // jumps to addr for case index
        PatchContinue(node.loop_index);
        PatchBreak(node.loop_index); // patches jump past switch table
        // Even though there are no continues in switch statements,
        // do this to pop the empty continue_addrs vector.

        freeTemp(t);

        if (debug)
        {
            System.out.print("\n// -SwitchStatementNode");
        }
        return null;
    }

    public Value evaluate(Context cx, CaseLabelNode node)
    {
        if (debug)
        {
            System.out.print("\n// +CaseLabelNode");
        }

        CaseList caseList = case_exprs.last();
        caseList.add(node.label);
        if (node.label == null)
        {
            // this is a default label
            if (caseList.hasDefault)
            {
                cx.error(node.pos(), kError_MultipleSwitchDefaults);
            }
            else
            {
                caseList.hasDefault = true;
            }
        }
        CaseLabel(node.label == null); // indicate if is default
        // reset the block of this node so that it is in the same
        //  block as the statements which it corresponds to.  The
        //  previous block might be unreachable and we don't want
        //  to have this label node culled during dead code removal.
        node.block = null;
        checkFeature(cx, node);

        if (debug)
        {
            System.out.print("\n// -CaseLabelNode");
        }
        return null;
    }

    int inside_loop = 0;

    public Value evaluate(Context cx, DoStatementNode node)
    {
        if (debug)
        {
            System.out.print("\n// +DoStatementNode");
        }

        LoopBegin();
        PatchLoopBegin(getIP());
        if (node.statements != null)
        {
            ++inside_loop;
            node.loop_index = loop_index++;
            node.statements.evaluate(cx, this);
            --loop_index;
            --inside_loop;  // because loop_index inlcudes labeled statements
        }
        PatchContinue(node.loop_index);
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        else
        {
        }
        LoopEnd(IF_true);
        PatchBreak(node.loop_index);

        if (debug)
        {
            System.out.print("\n// -DoStatementNode");
        }
        return null;
    }


    public Value evaluate(Context cx, WhileStatementNode node)
    {
        if (debug)
        {
            System.out.print("\n// +WhileStatementNode");
        }

        LoopBegin();
        if (node.statement != null)
        {
            ++inside_loop;
            node.loop_index = loop_index++;
            node.statement.evaluate(cx, this);
            --loop_index;
            --inside_loop;
        }
        PatchLoopBegin(getIP());
        PatchContinue(node.loop_index);

        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);

        }
        else
        {
        }
        LoopEnd(IF_true);
        PatchBreak(node.loop_index);

        if (debug)
        {
            System.out.print("\n// -WhileStatementNode");
        }
        return null;
    }

    public Value evaluate(Context cx, ForStatementNode node)
    {
        if (debug)
        {
            System.out.print("\n// +ForStatementNode");
        }

        if (node.initialize != null)
        {
            if (node.initialize.isDefinition())
            {
                ExpressionStatementNode es = (ExpressionStatementNode) node.initialize.initializerStatement(cx);
                node.initialize = es.expr;
            }
            node.initialize.evaluate(cx, this);
        }
        LoopBegin();
        if (node.statement != null)
        {
            ++inside_loop;
            node.loop_index = loop_index++;
            node.statement.evaluate(cx, this);
            --loop_index;
            --inside_loop;
        }
        PatchContinue(node.loop_index);

        if (node.increment != null)
        {
            node.increment.evaluate(cx, this);
        }
        PatchLoopBegin(getIP());

        if (node.test != null)
        {
            node.test.evaluate(cx, this);
        }
        else
        {
        }

        LoopEnd(IF_true);
        PatchBreak(node.loop_index);

        if (debug)
        {
            System.out.print("\n// -ForStatementNode");
        }
        return null;
    }

    public Value evaluate(Context cx, WithStatementNode node)
    {
        if (debug)
        {
            System.out.print("\n// +WithStatementNode");
        }
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }

        PushScope();

        node.activation = new ObjectValue(cx, new WithBuilder(), null);

        cx.pushScope(node.activation);

        if (!with_used_stack.isEmpty())
        {
            with_used_stack.removeLast();
            with_used_stack.add(1);
        }

        int saveWithDepth = cx.statics.withDepth;
        cx.statics.withDepth = cx.getScopes().size()-1;

        if (node.statement != null)
        {
            node.statement.evaluate(cx, this);
        }

        cx.statics.withDepth = saveWithDepth;

        PopScope();

        cx.popScope();

        if (debug)
        {
            System.out.print("\n// -WithStatementNode");
        }
        return null;
    }

    public Value evaluate(Context cx, ContinueStatementNode node)
    {
        if (debug)
        {
            System.out.print("\n// +ContinueStatementNode");
        }

        if (node.id != null)
        {
            Value val = node.id.evaluate(cx, this);
            ReferenceValue ref = ((val instanceof ReferenceValue) ? (ReferenceValue)val : null);
            if(ref != null)
            {
                ref.setQualifier(cx, ObjectValue.loopLabelNamespace);
                ref.setBase(cx.getScopes().last());
                ref.setKind(GET_TOKEN);
                ref.getSlot(cx, GET_TOKEN); // does the lookup
                node.loop_index = ref.getSlotIndex(GET_TOKEN);
            }

            if( inside_loop < 0 )
            {
                // it is an error
                node.loop_index = -1;
            }
        }
        else
        {
            if( inside_loop > 0 )
            {
                // target is outside of current loop
                node.loop_index = loop_index - 1;
            }
            else
            {
                // otherwise, it is an error
                node.loop_index = -1;
            }
        }

        if( node.loop_index < 0 )
        {
            cx.error(node.pos(), kError_ContinueHasNoTarget);
        }

        Continue(node.loop_index);

        if (debug)
        {
            System.out.print("\n// -ContinueStatementNode");
        }
        return null;
    }

    public Value evaluate(Context cx, BreakStatementNode node)
    {
        if (debug)
        {
            System.out.print("\n// +BreakStatementNode");
        }

        if (node.id != null)
        {
            Value val = node.id.evaluate(cx, this);
            ReferenceValue ref = ((val instanceof ReferenceValue) ? (ReferenceValue)val : null);
            if(ref != null) {
                ref.setQualifier(cx, ObjectValue.labelNamespace);
                ref.setBase(cx.getScopes().last());
                ref.setKind(GET_TOKEN);
                ref.getSlot(cx, GET_TOKEN); // does the lookup
                node.loop_index = ref.getSlotIndex(GET_TOKEN);
            }
        }
        else
        {
            if( inside_loop > 0 || inside_switch > 0 )
            {
                node.loop_index = loop_index - 1;
                // subtract 1 since we are now inside the loop.
            }
            else
            {
                node.loop_index = -1;  // break without expression must have loop target
            }
        }

        //TODO improve this error to suggest {} blocks
        if( node.loop_index < 0 )
        {
            cx.error(node.pos(), kError_BreakHasNoTarget);
        }

        Break(node.loop_index);

        if (debug)
        {
            System.out.print("\n// -BreakStatementNode");
        }
        return null;
    }

    public Value evaluate(Context cx, ReturnStatementNode node)
    {
        if (debug)
        {
            System.out.print("\n// +ReturnStatementNode");
        }

        if (this_contexts.last() == cinit_this)
        {
            cx.error(node.pos(), kError_CannotReturnFromStaticInit);
        }
        else if (this_contexts.last() == package_this)
        {
            cx.error(node.pos(), kError_CannotReturnFromPackageInit);
        }
        else if (this_contexts.last() == global_this && cx.scope().builder instanceof GlobalBuilder)
        {
            cx.error(node.pos(), kError_CannotReturnFromGlobalInit);
        }

        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        else
        {
        }
        Return(TYPE_none);

        if( super_context.last() == super_statement )
        {
            super_context.set(super_context.size()-1, super_error2);
        }

        if (debug)
        {
            System.out.print("\n// -ReturnStatementNode");
        }
        return null;
    }


    public Value evaluate(Context cx, ThrowStatementNode node)
    {
        if (debug)
        {
            System.out.print("\n// +ThrowStatementNode");
        }

        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        // cn:  A synthetic "throw x" is inserted into catch blocks
        //       by NodeFactory in order to make finally blocks work.  Don't call
        //       FlowGraphEmitter's Throw() in that case because we aren't really
        //       exiting the block.  Basically a bandaid over a hack
        if (node.isSynthetic() == false)
            Throw();

        if( super_context.last() == super_statement )
        {
            super_context.set(super_context.size()-1, super_error2);
        }

        if (debug)
        {
            System.out.print("\n// -ThrowStatementNode");
        }

        return null;
    }

    public Value evaluate(Context cx, TryStatementNode node)
    {
        if (debug)
        {
            System.out.print("\n// +TryStatementNode");
        }

        // Evaluate the try {} block
        Try(node.finallyblock != null);
        if( node.tryblock != null )
        {
            node.tryblock.evaluate(cx, this);
        }

        // Generate the catch blocks
        CatchClausesBegin();
        if( node.catchlist != null )
        {
            node.catchlist.evaluate(cx, this);
        }
        CatchClausesEnd();
        if( node.finallyblock != null )
        {
            node.finallyblock.evaluate(cx,this);
        }
        FinallyClauseEnd();

        if (debug)
        {
            System.out.print("\n// -TryStatementNode");
        }

        return null;
    }

    public Value evaluate(Context cx, CatchClauseNode node)
    {
        if (debug)
        {
            System.out.print("\n// +CatchClauseNode");
        }

        CatchBuilder catchBuilder = new CatchBuilder();
        node.activation = new ObjectValue(cx, catchBuilder,cx.noType());
        cx.pushScope(node.activation);

        if (node.parameter != null)
        {
            catchBuilder.hasParameter = true;

            node.parameter.evaluate(cx, this);

            ParameterNode parameter = (ParameterNode)node.parameter;

            if (parameter.typeref != null) // parameter->type was evaluated when we called parameter->evaluate()
            {
                node.typeref = parameter.typeref;
            }

            if (parameter.type != null)
            {
                rt_unresolved_sets.last().addAll(unresolved);
                unresolved.clear();

                Value val = parameter.type.evaluate(cx,this);
                node.typeref = ((val instanceof ReferenceValue) ? (ReferenceValue)val : null);

                if( node.typeref != null )
                {
                    node.typeref.setTypeAnnotation(true);
                }

                ObjectValue obj = cx.scope();
                if (obj.builder instanceof ActivationBuilder)
                {
                    body_unresolved_sets.last().addAll(unresolved);
                }
                else
                {
                    ce_unresolved_sets.last().addAll(unresolved);
                }
                unresolved.clear();
            }
        }

        Catch(null, null);

        // Reset the block of the Catch node
        node.block = null;
        checkFeature(cx, node);

        if (node.statements != null)
        {
            node.statements.evaluate(cx, this);
            exceptions_used_stack.removeLast();
            exceptions_used_stack.add(1);
        }

        cx.popScope();

        if (debug)
        {
            System.out.print("\n// -CatchClauseNode");
        }

        return null;
    }

    public Value evaluate(Context cx, FinallyClauseNode node)
    {
        if (debug)
        {
            System.out.print("\n// +FinallyClauseNode");
        }

        node.default_catch.evaluate(cx,this);
        if( node.statements != null )
        {
            node.statements.evaluate(cx,this);
        }

        if (debug)
        {
            System.out.print("\n// -FinallyClauseNode");
        }

        return null;
    }

    public Value evaluate(Context unused_cx, FunctionCommonNode node)
    {
        if (debug)
        {
            System.out.print("\n// +FunctionCommonNode");
        }

        Context cx = node.cx;  // switch to original context

        PackageDefinitionNode pkgdef = node.def != null ? node.def.pkgdef : null;
        if( pkgdef != null && cx.getScopes().size() == 1 )
        {
            public_namespaces.push_back(pkgdef.publicNamespace);
            default_namespaces.push_back(pkgdef.internalNamespace);
            usednamespaces_sets.push_back(pkgdef.used_namespaces);
            used_def_namespaces_sets.push_back(pkgdef.used_def_namespaces);
            importednames_sets.push_back(pkgdef.imported_names);
        }

        int savedWithDepth = cx.statics.withDepth;
        if( node.with_depth != -1)
        {
            // FCN was hoisted by an earlier pass
            cx.statics.withDepth = node.with_depth;
        }

        ObjectList<ObjectValue>saved_scopes = null;
        if( node.scope_chain != null )
        {
            saved_scopes = cx.swapScopeChain(node.scope_chain);
        }

        // First time through, initialize the compile-time constant function value.

        if (node.fun == null)
        {
        	if(node.used_namespaces == null) node.used_namespaces = new Namespaces(usednamespaces_sets.back().size());
            node.used_namespaces.addAll(usednamespaces_sets.back());  // makes a copy
        	if(node.imported_names == null) node.imported_names = new Multinames();
            node.imported_names.putAll(importednames_sets.back());  // makes a copy
            node.private_namespace = (private_namespaces.size() != 0) ? private_namespaces.back() : null;
            node.default_namespace = default_namespaces.back();
            node.public_namespace  = cx.publicNamespace(); //public_namespaces.back();

            node.fun = new ObjectValue(cx,new FunctionBuilder(),cx.functionType());
            
            boolean is_named_anon = false; 
            if( !node.isFunctionDefinition() && node.identifier != null && !"anonymous".equals(node.identifier.name) && node.isUserDefinedBody() )
            {
            	is_named_anon = true;
                node.setNamedInnerFunc(true);

            	// Create a slot in the FunctionBuilder to represent this function so that it can recursively
            	// call itself.
            	Namespaces temp_ns = new Namespaces(cx.publicNamespace());
                int method_id = node.fun.builder.Method(cx,node.fun,node.identifier.name,temp_ns,false);
                node.fun.builder.ExplicitCall(cx,node.fun,node.identifier.name,temp_ns,cx.noType(),false,false,-1,method_id,-1);
                
                cx.pushScope(node.fun);
            }

            // Save the with depth, if there is one, since the FunctionCommonNode is going to get hoisted
            // and there won't be a WithStatementNode above it anymore after hoisting.
            if( cx.statics.withDepth != -1 )
                node.with_depth = cx.statics.withDepth;

            ObjectList<ObjectValue> scope_chain = cx.getScopes();
            for(int s = scope_chain.size(); s > 0; --s  )
            {
                ObjectValue scope = scope_chain.get(s-1);
                if( scope.builder instanceof CatchBuilder ||
                    scope.builder instanceof WithBuilder ||
                    scope.builder instanceof ActivationBuilder)
                {
                    node.scope_chain = new ObjectList<ObjectValue>(scope_chain); // copy the scope chain, since the func will be hoisted
                    break;
                }
            }
            
            if( is_named_anon )
            {
            	// We can pop the scope now since it's been saved by the function.  
            	cx.popScope();
            }
            
            // fexpr_sets is a stack of sets of function expressions.
            // Each set contains the functions at a particular scope level.

            ObjectValue scope = cx.scope();
            Builder b = scope.builder;
            if (b instanceof ClassBuilder)
            {
                int size = staticfexprs_sets.last().size();
                int i;

                // Look for the current node in the set for the current scope.

                for (i = 0; i < size && staticfexprs_sets.last().get(i) != node; ++i);

                // If it is not in the set, then add it.

                if (i >= size)
                {
                    staticfexprs_sets.last().add(node);
                }
            }
            else
            {
                int size = fexprs_sets.last().size();
                int i;

                // Look for the current node in the set for the current scope.

                for (i = 0; i < size && fexprs_sets.last().get(i) != node; ++i);

                // If it is not in the set, then add it.

                if (i >= size)
                {
                    fexprs_sets.last().add(node);
                }

            }
        }
        else
        if( doingMethod() )
        {
        }
        else
        if (node.ref == null)
        {
        	if(node.used_namespaces != null)
        		usednamespaces_sets.push_back(node.used_namespaces);
        	if(node.imported_names != null)
        		importednames_sets.push_back(node.imported_names);

            // Start processing a new function. Add an empty function set to the
            // function sets.

            fexprs_sets.add(new ObjectList<FunctionCommonNode>());
            staticfexprs_sets.push_back(new ObjectList<FunctionCommonNode>());
            instanceinits_sets.push_back(new ObjectList<Node>());

            // Create a reference to the name.

            Value val = node.identifier.evaluate(cx, this);
            node.ref = ((val instanceof ReferenceValue) ? (ReferenceValue)val : null);
            node.fun.name = node.internal_name;   // ISSUE: don't know if this is necessary.

            region_name_stack.push_back(cx.debugName(region_name_stack.back(),node.ref.name,node.namespace_ids,node.kind));

            // The activation object is the compile-time model of the
            // function activation. It is different than the function
            // object, which represents the function constructor.

            node.fun.activation = new ObjectValue(cx, new ActivationBuilder(),cx.noType());

            {
                ObjectValue obj = cx.scope(cx.getScopes().size()-1);
                node.fun.activation.builder.classname = obj.builder.classname;
                node.fun.activation.name = node.internal_name;
            }

            ObjectValue fun = node.fun;
            cx.pushScope(fun.activation);

            // The following stacks are not actually used. They are
            // left here for their side effects.

            // ISSUE: remove references to these stacks.

            fun_name_stack.add(node.internal_name);
            max_params_stack.add(node.signature.size());
            max_locals_stack.add(node.body != null ? node.var_count : 0);
            max_temps_stack.add(node.body != null ? node.temp_count : 0);
            with_used_stack.add(0);
            exceptions_used_stack.add(0);

            if( node.use_stmts != null )
            {
                node.use_stmts.evaluate(cx,this);
            }

            rt_unresolved_sets.last().addAll(unresolved);
            unresolved.clear();

            node.signature.evaluate(cx, this);

            ce_unresolved_sets.last().addAll(unresolved);
            unresolved.clear();

            int scope_index = cx.getScopes().size()-1;
            ObjectValue obj = cx.scope(scope_index);
            if( (node.needsArguments&METHOD_Arguments) != 0 )
            {
            	ObjectValue namespace = node.default_namespace;
                if( !obj.hasName(cx,GET_TOKEN,"arguments",namespace) )
                {
                    Builder bui = obj.builder;
                    int var_id = bui.Variable(cx,obj);
                    bui.ExplicitVar(cx,obj,"arguments",namespace,cx.arrayType(),-1,-1,var_id);
                }
                else
                {
                    node.needsArguments ^= METHOD_Arguments; // don't actually need 'arguments' since there is a parameter or var with the same name
                }
            }

            boolean is_constructor = "$construct".equals(node.ref.name);

            if (is_constructor)
            {
                if (node.signature.result != null)
                {
                    cx.error(node.pos(), kError_CtorWithReturnType);
                }
            }

            if (node.body != null)
            {
                if( !node.isFunctionDefinition() )
                {
                    this_contexts.add(global_this);
                }

                int state = super_error;
                if (is_constructor)
                {
                    state = super_statement;
                }
                super_context.add(state);
                
                if (node.signature.inits != null)
                {
                    int scope_depth = cx.getScopeDepth();
                    ObjectValue iframe = cx.scope(scope_depth-2);
                    
                    // Make get & method slots invisible, only set slots will be visible.
                    if( iframe.builder instanceof InstanceBuilder )
                    	iframe.setInitOnly(true);	

                    this_contexts.push_back(init_this);
                	node.signature.inits.evaluate(cx, this);
                	this_contexts.pop_back();

                    if( iframe.builder instanceof InstanceBuilder )
                    	iframe.setInitOnly(false);	
                }

                if (is_constructor && cx.dialect(11))
                {
                	super_context.set(super_context.size()-1, super_error_es4);
                }
                
                node.body.evaluate(cx, this);

                node.temp_count = getTempCount();
                node.var_count = fun.activation.var_count-node.signature.size();

                super_context.pop_back();
                if( !node.isFunctionDefinition() )
                {
                    this_contexts.pop_back();
                }
            }
            else
            {
                StartMethod(fun_name_stack.last(), max_params_stack.last(), 0 /* no locals */);
            }

            TypeInfo type = null;
            ObjectList<TypeInfo> types = null;
            FinishMethod(cx,fun_name_stack.back(),type,types,node.fun.activation,node.needsArguments,cx.getScopes().size(),node.debug_name,node.isNative(),false, null);

            if (with_used_stack.last() != 0)
            {
                    node.setWithUsed(true);
            }
            with_used_stack.removeLast();

            if (exceptions_used_stack.last() != 0)
            {
                    node.setExceptionsUsed(true);
            }
            exceptions_used_stack.removeLast();

            fun_name_stack.removeLast();

            // Store the accumulated fexprs in this node for CodeGeneration
            node.fexprs = fexprs_sets.back();

            // Now evaluate each function expression
            this_contexts.add(global_this);
            for (Node fexpr : node.fexprs)
            {
                fexpr.evaluate(cx, this);
            }
            this_contexts.pop_back();

            instanceinits_sets.pop_back();
            staticfexprs_sets.pop_back();
            fexprs_sets.pop_back();
            cx.popScope(); // activation

            region_name_stack.pop_back();
            usednamespaces_sets.pop_back();
            importednames_sets.pop_back();
        }

        // Restore the scope chain if it was changed
        if( saved_scopes != null )
        {
            cx.swapScopeChain(saved_scopes);
        }
        // Reset the withDepth to whatever it was
        cx.statics.withDepth = savedWithDepth;

        if( pkgdef != null && cx.getScopes().size() == 1 )
        {
            public_namespaces.pop_back();
            default_namespaces.pop_back();
            usednamespaces_sets.pop_back();
            used_def_namespaces_sets.pop_back();
            importednames_sets.pop_back();
        }

        if (debug)
        {
            System.out.print("\n// -FunctionCommonNode");
        }
        return node.fun;

    }

    public Value evaluate(Context unused_cx, BinaryProgramNode node)
    {
        if( node.frame != null )
        {
            // We are an import from an .abc file.  Need to fill in any missing type info
            Iterator<ClassDefinitionNode> it = node.clsdefs.iterator();
            // Need to do this so that the slots from this import get put into the real
            // import frame.

            node.cx.scope().builder.addNames(node.frame.builder.getNames());

            inheritSlots(node.frame, node.cx.scope(), node.cx.scope().builder, node.cx);

            node.frame.builder.clearNames();

            while( it.hasNext() )
            {
                // Add the classdef's from the abc file to the clsdefs list.
                // these will be sorted, and then evaluated in the correct order later.
                ClassDefinitionNode cdn = it.next();

                clsdefs_sets.last().add(cdn);
            }
        }

        // TODO: better dependency analysis for ABC files.
        // this is filled in during AbcParse, and then added here - we could be doing this dependency analysis earlier
        ce_unresolved_sets.last().addAll(node.ce_unresolved);
        return null;
    }

    private void processImports(Context cx, ProgramNode node, ObjectList<ImportNode> imports)
    {
        ObjectValue frame = cx.scope();

        Builder globalBuilder = new GlobalBuilder();
        node.importFrame = new ObjectValue(cx,globalBuilder,null);

        NodeFactory nf = cx.getNodeFactory();
        ImportNode imported_program_nodes = null;
        for (ImportNode it : imports)
        {
            if( imported_program_nodes == null )
            {
                imported_program_nodes = nf.Import(cx,nf.literalString("",0),it.program);
            }
            else
            {
                imported_program_nodes.program.statements.items.addAll(it.program.statements.items);
                imported_program_nodes.program.pkgdefs.addAll(it.program.pkgdefs);
            }
        }

        if( imported_program_nodes != null )
        {
            cx.popScope();
            cx.pushScope(node.importFrame);
            // 1. ProgramNode.state == Inheritance
            import_context.push_back(true);
            imported_program_nodes.program.evaluate(cx,this);
            // 2. ProgramNode.state == else
            imported_program_nodes.program.evaluate(cx,this);
            import_context.pop_back();
            cx.popScope();
            cx.pushScope(frame);
            imported_program_nodes.evaluate(cx,this);
        }
    }

    public Value evaluate(Context unused_cx, ProgramNode node)
    {
        if (debug)
        {
            System.out.print("\n// +ProgramNode");
        }

if (node.state == ProgramNode.Inheritance)
{
        if( node.frame != null )
        {
            // already done
            return null;
        }

        Context cx = node.cx;
        programNode_temp = allocateTemp();

        strict_context.push_back(false);

        node.frame = cx.scope();

        processImports(cx, node, node.imports);

        // reset endpoint_dominator/define_cv flags which were set during import processing.
        define_cv = false;
        endpoint_dominator_is_set = false;

        StartProgram("");

        this_contexts.add(global_this);
        super_context.add(super_error);
        
        number_usage_stack.add(new NumberUsage());	// place to hang numeric usage info

        // Function expressions that occur in the current block will be
        // compiled as though they had occured at the end of the block.
        // The variable that references them is initialized at the beginning
        // of the block.

        fexprs_sets.add(new ObjectList<FunctionCommonNode>());
        clsdefs_sets.add(new ObjectList<ClassDefinitionNode>());
        staticfexprs_sets.add(new ObjectList<FunctionCommonNode>());
        instanceinits_sets.add(new ObjectList<Node>());

        package_unresolved_sets.push_back(node.package_unresolved);
        import_def_unresolved_sets.push_back(node.import_def_unresolved);
        ns_unresolved_sets.push_back(node.ns_unresolved);
        fa_unresolved_sets.push_back(node.fa_unresolved);
        ce_unresolved_sets.push_back(node.ce_unresolved);
        body_unresolved_sets.push_back(node.body_unresolved);
        rt_unresolved_sets.push_back(node.rt_unresolved);

        // Copy the set of nested functions into the node for use
        // by later phases.

        node.fexprs = fexprs_sets.last();
        node.clsdefs = clsdefs_sets.last();

        fun_name_stack.add("$init");
        max_params_stack.add(0);
        max_locals_stack.add(node.var_count);  // Should always be zero.
        max_temps_stack.add(node.temp_count);

        node.var_count = 0;  // no explicit locals in global scope

        node.public_namespace  = cx.publicNamespace();
        this.local_file_namespace = node.default_namespace = cx.getNamespace(cx.getFileInternalNamespaceName(),Context.NS_PRIVATE);

        public_namespaces.push_back(node.public_namespace);
        default_namespaces.push_back(node.default_namespace);

        usednamespaces_sets.push_back(node.used_def_namespaces);
        used_def_namespaces_sets.push_back(new Namespaces());
        importednames_sets.push_back(new Multinames());
        usednamespaces_sets.back().push_back(node.public_namespace);
        usednamespaces_sets.back().push_back(node.default_namespace);
        used_def_namespaces_sets.back().push_back(node.public_namespace);
        used_def_namespaces_sets.back().push_back(node.default_namespace);
        region_name_stack.push_back("");

        if (node.statements != null)
        {
            for(PackageDefinitionNode it : node.pkgdefs)
            {
                it.evaluate(cx,this);
            }

            node.statements.evaluate(cx, this);
            define_cv = false; // this turns off further processing of cv
        }

        node.temp_count = getTempCount(); // Remember the temp count

		Return(TYPE_none);
		FinishMethod(cx,"$init",null,null,null,0,1,"",false,false, null);

        // By now, the in and out sets have been computed.
        // Get the use definitions for the end of the program,
        // and mark them as value needed.

        ObjectList<Node> defs = getEmitter().GetDefs(getEmitter().getBlock().out_bits);

        {
            for (Node n : defs)
            {
                n.expectedType(cx.noType());
            }
        }

        // Now evaluate each function expression

        {
            for (FunctionCommonNode n : node.fexprs)
            {
                n.evaluate(cx, this);
            }
        }

        // Remove the top set of nested functions from the stack of sets

        fexprs_sets.removeLast();

        // ASSERT(fexprs_sets.size() == 0);

        // Now evaluate each class expression

        {
            // set resolveInheritance to true so that when processing ClassDefinitionNode, FA only tries to
            // resolve node.baseclass...
            resolveInheritance = true;

            for (ClassDefinitionNode n : node.clsdefs)
            {
                n.evaluate(cx,this);
            }

            resolveInheritance = false;
        }

        rt_unresolved_sets.last().addAll(unresolved);
        unresolved.clear();

        node.state = ProgramNode.Else;
}
else
{
        Context cx = node.cx;

        {
            // node.clsdefs have the baseclass.cframe resolved, i.e. we've got fully-qualified class names.
            // sort the class names based on "extends" and "implements"...
            if (found_circular_or_duplicate_class_definition == false)
            {
                node.clsdefs = sortClassDefinitions(node.cx, node.clsdefs);
            }
            // now that node.clsdefs are in topological order, check for overrides and other steps that
            // require resolved supertypes should be more accurate...
            if (found_circular_or_duplicate_class_definition == false)
            {
                for (ClassDefinitionNode n : node.clsdefs)
                {
                    n.evaluate(cx,this);
                }
            }
        }

        // Remove the top set of nested classes from the stack of sets

        rt_unresolved_sets.last().addAll(unresolved);
        unresolved.clear();

        package_unresolved_sets.pop_back();
        import_def_unresolved_sets.pop_back();
        ns_unresolved_sets.pop_back();
        fa_unresolved_sets.pop_back();
        ce_unresolved_sets.pop_back();
        body_unresolved_sets.pop_back();
        rt_unresolved_sets.pop_back();

        clsdefs_sets.removeLast();
        instanceinits_sets.removeLast();
        staticfexprs_sets.removeLast();
        region_name_stack.removeLast();


        super_context.removeLast();
        this_contexts.removeLast();
        strict_context.removeLast();

        importednames_sets.pop_back();
        usednamespaces_sets.removeLast();
        used_def_namespaces_sets.removeLast();
        default_namespaces.removeLast();
        public_namespaces.removeLast();

        // ASSERT(fexprs_sets.size() == 0);

        FinishProgram(cx,"",0);
        freeTemp(programNode_temp);

        node.state = ProgramNode.Done;
} // if

        if (debug)
        {
            System.out.print("\n// -ProgramNode");
        }
        return null;
    }

    // 1. setup a dependency graph based on "extends" and "implements".
    // 2. run topological sort to determine the export order.
    // 3. output error if part of the dependency graph forms cycles.
    private ObjectList<ClassDefinitionNode> sortClassDefinitions(Context cx, final ObjectList<ClassDefinitionNode> clsdefs)
    {
        // skip sorting if there are less than 2 classes...actually, don't skip the case
        // of one class definition in case it is self referential
        if (clsdefs == null || clsdefs.size() == 0)
        {
            return clsdefs;
        }

        // create a dependency graph, the weight is ClassDefinitionNode...
        final DependencyGraph<ClassDefinitionNode> g = new DependencyGraph<ClassDefinitionNode>();

        for (ClassDefinitionNode clsdef : clsdefs)
        {
            // The dependency graph doubles as a hashtable
            String className = clsdef.cframe.builder.classname.toString();
            g.put(className, clsdef);

            // if the class is not already in the graph as a node, add it.
            if (!g.containsVertex(className))
            {
                g.addVertex(new Vertex<String>(className));
            }

            // add dependency... add two vertices and an edge.
            if (clsdef.cframe.baseclass != null && !"Class".equals(clsdef.cframe.baseclass.name.toString()))
            {
                g.addDependency(className, clsdef.cframe.baseclass.name.toString());
            }

            // do the same things to interfaces...
            int size = (clsdef.interfaces == null) ? 0 : clsdef.interfaces.values.size();
            for (int i = 0; i < size; i++)
            {
                Value val = clsdef.interfaces.values.get(i);
                if( val instanceof ReferenceValue )
                {
                    ReferenceValue ref = (ReferenceValue) val;

                    if (ref != null)
                    {
                        Value v2 = ref.getValue(cx);
                        TypeValue t = ((v2 instanceof TypeValue) ? (TypeValue)v2 : null);
                        if (t != null)
                        {
                            g.addDependency(className, t.builder.classname.toString());
                        }
                    }
                }
            }
        }

        final ObjectList<ClassDefinitionNode> tsort = new ObjectList<ClassDefinitionNode>();

        // sort the classes
        Algorithms.topologicalSort(g, new Visitor<String>()
        {
            public void visit(Vertex<String> v)
            {
                String name = v.getWeight();
                // make sure that the name corresponds to a local ClassDefinitionNode...
                if (g.containsKey(name))
                {
                    tsort.add(g.get(name));
                }
            }
        });

        // if the sort returns fewer classes, that means some nodes form cycle(s)...
        if (clsdefs.size() > tsort.size())
        {
            for (ClassDefinitionNode clsdef : clsdefs)
            {
                // output errors against the nodes in dependency cycles...
                if (!tsort.contains(clsdef))
                {
                    cx.error(clsdef.pos(), kError_CircularReference, clsdef.cframe.builder.classname.name);
                    found_circular_or_duplicate_class_definition = true;
                }
            }
            return clsdefs;
        }
        else
        {
            return tsort;
        }
    }

    /*

    Every package definition is its own global scope. Packages can't see the script
    global scope, since packages come before any global code and non-package
    definitions. Implementations are free to use the scope chain or prototype
    chain to inherit the built-in properties

    */
    public Value evaluate(Context unused_cx, PackageDefinitionNode node)
    {
        if (debug)
        {
            System.out.print("\n// +PackageDefinitionNode");
        }

        Context cx = node.cx;  // switch to original context

        if( node.publicNamespace == null )
        {
            if( doingPackage() && import_context.back() != true )
            {
                cx.error(node.pos(), kError_NestedPackage);
                return null;
            }

            if( node.ref == null )
            {
                node.ref = (ReferenceValue)(node.name.evaluate(cx,this));
            }

            node.publicNamespace   = cx.getNamespace(node.ref.name);
            node.publicNamespace.setPackage(true);

            node.internalNamespace = cx.getNamespace(node.ref.name, Context.NS_INTERNAL);

            node.used_namespaces.push_back(local_file_namespace);
            node.used_def_namespaces.push_back(local_file_namespace);

            node.used_namespaces.push_back(cx.publicNamespace());
            node.used_def_namespaces.push_back(cx.publicNamespace());

            if( cx.publicNamespace() != node.publicNamespace )
            {
                node.used_namespaces.push_back(node.publicNamespace);
                node.used_def_namespaces.push_back(node.publicNamespace);
            }
            node.used_namespaces.push_back(node.internalNamespace);
            node.used_def_namespaces.push_back(node.internalNamespace);
        }
        else
        if( !node.in_this_pkg )
        {
            node.in_this_pkg = true;

            this_contexts.add(package_this);
            super_context.add(super_error);
            strict_context.push_back(true);

            public_namespaces.push_back(node.publicNamespace);
            default_namespaces.push_back(node.internalNamespace);

            usednamespaces_sets.push_back(node.used_namespaces);
            used_def_namespaces_sets.push_back(node.used_def_namespaces);
            importednames_sets.push_back(node.imported_names);
        }
        else
        {
            node.in_this_pkg = false;

            this_contexts.pop_back();
            super_context.pop_back();
            strict_context.pop_back();

            usednamespaces_sets.pop_back();
            used_def_namespaces_sets.pop_back();
            importednames_sets.pop_back();
            default_namespaces.pop_back();
            public_namespaces.pop_back();
        }

        if (debug)
        {
            System.out.print("\n// -PackageDefinitionNode");
        }
        return null;
    }

    public Value evaluate(Context cx, PackageNameNode node)
    {
        return node.id.evaluate(cx, this);
    }

    public Value evaluate(Context cx, PackageIdentifiersNode node)
    {
        ReferenceValue ref = new ReferenceValue(cx, null, "", cx.publicNamespace()); // caller deletes

        // qualifier gets set by caller
        ref.setPosition(node.pos());
        ref.name = node.pkg_part.intern();
        return ref;
    }

    public Value evaluate(Context cx, Node node)
    {
        cx.internalError( node.pos(), "Feature not supported: " + node.toString());
        return null;
    }

    public Value evaluate(Context cx, VariableDefinitionNode node)
    {
        if(node.cx != null) {
            cx = node.cx;
        }

        Value val = null;

        // Set up access namespaces

        if( node.pkgdef != null && cx.getScopes().size() == 1 )
        {
            public_namespaces.push_back(node.pkgdef.publicNamespace);
            default_namespaces.push_back(node.pkgdef.internalNamespace);

            usednamespaces_sets.push_back(node.pkgdef.used_namespaces);
            used_def_namespaces_sets.push_back(node.pkgdef.used_def_namespaces);
            importednames_sets.push_back(node.pkgdef.imported_names);
        }

        //

        boolean is_static = false;
        boolean is_final = false;
        boolean is_dynamic = false;
        boolean is_override = false;

        if (node.attrs != null)
        {
            is_static    = node.attrs.hasStatic;
            is_final     = node.attrs.hasFinal;
            is_dynamic   = node.attrs.hasDynamic;
            is_override  = node.attrs.hasOverride;
        }

        ClassBuilder classBuilder = classBuilderOnScopeChain(cx);
        if (classBuilder != null && classBuilder.is_interface)
        {
            cx.error(node.pos(), kError_VarInInterface);
        }

        if (is_dynamic)
        {
            cx.error(node.pos(), kError_InvalidDynamic);
        }

        if (is_final)
        {
            cx.error(node.pos(), kError_InvalidFinalUsage);
        }

        if (is_override)
        {
            cx.error(node.pos(), kError_InvalidOverrideUsage);
        }

        if( is_static )
        {
            if (classBuilder != null)
            {
                val = node.list.evaluate(cx,this);
            }
            else
            {
                cx.error(node.attrs.pos(), kError_InvalidStatic);
            }
        }
        else
        {
            val = node.list.evaluate(cx, this);
        }

        if( node.pkgdef != null && cx.getScopes().size() == 1 )
        {
            public_namespaces.pop_back();
            default_namespaces.pop_back();
            usednamespaces_sets.pop_back();
            used_def_namespaces_sets.pop_back();
            importednames_sets.pop_back();
        }
        return val;
    }

    // This should be called after AttributeListNode* attrs has already been evaluated

    public void computeNamespaces( Context cx, AttributeListNode attrs, Namespaces namespaces, ObjectList<String> namespace_ids )
    {
        if( attrs != null )
        {
            if( attrs.hasPrivate )
            {
                if( private_namespaces.size() == 0 )
                {
                    cx.error(attrs.pos(), kError_InvalidPrivate);
                    attrs.namespaces.push_back(cx.publicNamespace()); // for graceful failure
                    attrs.namespace_ids.push_back(PRIVATE);
                }
                else
                {
                    attrs.namespaces.push_back(private_namespaces.back());
                    attrs.namespace_ids.push_back(PRIVATE);
                }
            }
            else
            if( attrs.hasProtected )
            {
                if (cx.scope().builder instanceof InstanceBuilder)
                {
                    if( protected_namespaces.size() == 0 )
                    {
                        cx.error(attrs.pos(), kError_InvalidProtected);
                        attrs.namespaces.push_back(cx.publicNamespace());
                        attrs.namespace_ids.push_back(PROTECTED);
                    }
                    else
                    {
                        attrs.namespaces.push_back(protected_namespaces.back());
                        attrs.namespace_ids.push_back(PROTECTED);
                    }
                }
                else
                {
                    if( static_protected_namespaces.size() == 0 )
                    {
                        cx.error(attrs.pos(), kError_InvalidProtected);
                        attrs.namespaces.push_back(cx.publicNamespace());
                        attrs.namespace_ids.push_back(PROTECTED);
                    }
                    else
                    {
                        attrs.namespaces.push_back(static_protected_namespaces.back());
                        attrs.namespace_ids.push_back(PROTECTED);
                    }
                }
            }
            else
            if( attrs.hasPublic )
            {
                if( public_namespaces.size() == 0 )
                {

                    attrs.namespaces.push_back(cx.publicNamespace());
                    attrs.namespace_ids.push_back(cx.publicNamespace().name);
                }
                else
                {
                    attrs.namespaces.push_back(public_namespaces.back());
                    attrs.namespace_ids.push_back(public_namespaces.back().name);
                }
            }
            else
            if( attrs.hasInternal )
            {
                if( public_namespaces.size() == 0 ) // use public namespaces to determine if we are in a valid context for internal
                {
                    attrs.namespaces.push_back(cx.publicNamespace());
                    attrs.namespace_ids.push_back(cx.publicNamespace().name);
                }
                else
                {
                    attrs.namespaces.push_back(default_namespaces.back());
                    attrs.namespace_ids.push_back(default_namespaces.back().name);
                }
            }
            else
            if( attrs.namespaces.size() == 0 )
            {
                attrs.namespaces.push_back(default_namespaces.back());
                attrs.namespace_ids.push_back(default_namespaces.back().name);
                        // We do this here, because ALN is not always evaluated
                        // in a context where the access control namespaces are
                        // known. If ALN has not been evaluated, then attrs->namespaces
                        // will be wrongly empty
            }

            namespaces.addAll(attrs.namespaces);
            namespace_ids.addAll(attrs.namespace_ids);
        }
        else
        {
            namespace_ids.push_back(default_namespaces.back().name);
            namespaces.push_back(default_namespaces.back());
        }
    }

    public Value evaluate(Context cx, VariableBindingNode node)
    {

        boolean is_intrinsic = false;
        boolean is_const     = node.kind == CONST_TOKEN;

        Namespaces namespaces = new Namespaces();

        ObjectList<String> namespace_ids = new ObjectList<String>();

        if( node.attrs != null) // already been evaluated by VariableDefinitionNode
        {
            if( node.attrs.hasVirtual && node.attrs.hasFinal )
            {
                cx.error(node.pos(), kError_VarIsFinalAndVirtual);
            }
            if( node.attrs.hasNative )
            {
                cx.error(node.pos(), kError_NativeVars);
            }
            if( node.attrs.hasVirtual )
            {
                cx.error(node.pos(), kError_VirtualVars);
            }

            is_intrinsic = node.attrs.hasIntrinsic;
        }

        if( node.attrs == null && node.variable.type == null )
        {
            ObjectValue ns = default_namespaces.back();
            namespaces.push_back(ns);
            namespace_ids.push_back(ns.name);
            NodeFactory nf = cx.getNodeFactory();
            boolean isPublic = ns == cx.publicNamespace();
            AttributeListNode aln = nf.attributeList(nf.identifier(isPublic?PUBLIC:INTERNAL,false,node.variable.pos()),null);
            if (isPublic)
            {
                aln.hasPublic = true;
            }
            else
            {
                aln.hasInternal = true;
            }
            aln.namespaces.push_back(ns);
            if( node.variable.identifier instanceof QualifiedIdentifierNode )
            {
                ((QualifiedIdentifierNode)node.variable.identifier).qualifier = aln;
            }
            else
            {
                node.variable.identifier = nf.qualifiedIdentifier(aln, node.variable.identifier.name, node.variable.identifier.pos());
            }
            Value val = node.variable.identifier.evaluate(cx,this);
            node.ref = (val instanceof ReferenceValue) ? (ReferenceValue) val : null;
        }
        else
        {
            computeNamespaces( cx, node.attrs, namespaces, namespace_ids );
            Value val = node.variable.identifier.evaluate(cx,this);
            node.ref = (val instanceof ReferenceValue) ? (ReferenceValue) val : null;

            if (node.inPackage() == false && cx.getScopes().size() == 1 && node.attrs != null)
            {
                if( node.attrs.hasAttribute(PUBLIC) )
                    cx.error(node.attrs.pos(), kError_InvalidPublic);
            }
        }

        Value val = node.variable.identifier.evaluate(cx,this);
        node.ref = ((val instanceof ReferenceValue) ? (ReferenceValue)val : null);

        if (node.initializer != null)
        {
        	if( cx.statics.es4_nullability && cx.scope().builder instanceof InstanceBuilder )
        	{
        		// Initializers for instance variables should not have access to this.
        		cx.scope().setInitOnly(true);
            	this_contexts.push_back(init_this);
        	}
        	
            node.initializer.evaluate(cx,this);

        	if( cx.statics.es4_nullability && cx.scope().builder instanceof InstanceBuilder )
        	{
        		cx.scope().setInitOnly(false);
            	this_contexts.pop_back();
        	}
         }

        ObjectValue obj = getVariableDefinitionScope(cx);

        Builder bui = obj.builder;

        int slot_id = -1;

        if( bui instanceof InstanceBuilder && node.ref.name.equals(fun_name_stack.back()))
        {
            cx.error(node.pos(), kError_ConstructorsMustBeInstanceMethods);
        }

        Namespaces open_definition_namespaces ;
        if( node.attrs != null && node.attrs.hasUserNamespace() )
        {
            open_definition_namespaces = namespaces;
        }
        else
        {
            open_definition_namespaces = used_def_namespaces_sets.back();
        }

        if (node.variable.type != null)
        {
            rt_unresolved_sets.last().addAll(unresolved);
            unresolved.clear();

            /* We used to get node.typeref from the result of node.variable.type.eval
             * Having changed MemberExprNodes so that they return cx.object().prototype,
             * rather than node.ref, this is a workaround to setting the correct typeref: */
            val = node.variable.type.evaluate(cx,this);

            obj = getVariableDefinitionScope(cx);
            if (obj.builder instanceof ActivationBuilder)
            {
                body_unresolved_sets.last().addAll(unresolved);
            }
            else
            {
                ce_unresolved_sets.last().addAll(unresolved);
            }
            unresolved.clear();

            node.typeref = ((val instanceof ReferenceValue) ? (ReferenceValue)val : null);
            if( node.typeref != null )
            {
                node.typeref.setTypeAnnotation(true);
            }
            else
            {
                // If the type didn't resolve to a reference value then it's clearly going to be unknown
                cx.error(node.variable.type.pos(), kError_UnknownType, "");
            }
        }

        int kind = GET_TOKEN;
        Namespaces matchingNamespaces = obj.hasNames(cx,GET_TOKEN,node.ref.name,open_definition_namespaces);
        if( matchingNamespaces == null )
        {
            matchingNamespaces = obj.hasNames(cx, SET_TOKEN, node.ref.name, open_definition_namespaces);
            kind = SET_TOKEN;
        }
        if( matchingNamespaces == null )
        {
            // Allocate space for the variable and create the property
            // slots. A property is represented at compile-time as a
            // name and a pair of accessors (getter and setter).

            TypeValue type = cx.noType();
                    // ISSUE: the actual slot type is computed at constanteval time.
                    // make sure that is never too late

            if( bui.is_intrinsic || is_intrinsic )
            {
                slot_id = bui.ExplicitVar(cx,obj,node.ref.name,namespaces,type,-1);
            }
            else
            {
                int var_id;
                var_id  = bui.Variable(cx,obj);
                slot_id = bui.ExplicitVar(cx,obj,node.ref.name,namespaces,type,-1,-1,var_id);
                Slot slot = obj.getSlot(cx,slot_id);
                slot.setConst(is_const);
                slot.setTypeRef(node.typeref);

                if( (node.block != null) ||  // node.block is null for defintions at the top level of the method 
                	(node.initializer == null) )
                {
                	// Need to init the local at the beginning of the method
                	// so that the types at the backwards branch will match at 
                	// verify time.
                	slot.setNeedsInit(true);
                }
            }
        }
        else
        {
            String nsstr = "";
            for (ObjectValue ns : matchingNamespaces)
            {
                if (nsstr.length() != 0)
                    nsstr += " ";

                if (ns.name.length() == 0)
                {
                    nsstr += PUBLIC;
                }
                else
                {
                    switch( ns.getNamespaceKind() )
                    {
                        case Context.NS_PRIVATE:
                            nsstr += PRIVATE;
                            break;
                        case Context.NS_INTERNAL:
                            nsstr += INTERNAL;
                            break;
                        case Context.NS_PROTECTED:
                            nsstr += PROTECTED;
                            break;
                        default:
                            nsstr += ns.name;
                            break;
                    }
                }
            }

            int slot_index = obj.getSlotIndex(cx, kind,node.ref.name, matchingNamespaces.back());
            Slot orig = obj.getSlot(cx, slot_index);

            boolean isGlobalDefinition = bui instanceof GlobalBuilder && !node.inPackage();
            boolean isLocalDefinition  = bui instanceof ActivationBuilder;
            boolean isGlobalOrLocalDefinition = isGlobalDefinition || isLocalDefinition;

            if( isGlobalOrLocalDefinition && node.attrs == null && node.variable.type == null )
            {
                if( orig.getType().getTypeValue() == cx.typeType() || orig.isConst() )
                {
                    // attempting to declare a var with the same name as a class, don't allow that
                    cx.error(node.variable.identifier.pos(), kError_ConflictingNameInNamespace, node.ref.name, "internal");
                }
                else
                {
                    // ed.3 decl, so let it go
                    // need to modify the qualified identifers attribute list, so that the
                    // qualified identifier node that was auto generated for the init statement will refer to the correct namespace
                    NodeFactory nf = cx.getNodeFactory();
                    AttributeListNode aln = nf.attributeList(nf.identifier(matchingNamespaces.back().name,node.variable.pos()),null);
                    aln.items.clear();
                    aln.namespaces.addAll(matchingNamespaces);
                    if( node.variable.identifier instanceof QualifiedIdentifierNode )
                    {
                        ((QualifiedIdentifierNode)node.variable.identifier).qualifier = aln;
                    }
                    else
                    {
                        node.variable.identifier = nf.qualifiedIdentifier(aln, node.variable.identifier.name, node.variable.identifier.pos());
                    }
                    node.variable.identifier.ref = null; // force this to be regenerated since the namespace has probably changed
                    Value val2 = node.variable.identifier.evaluate(cx,this);
                    node.ref = (val instanceof ReferenceValue) ? (ReferenceValue) val2 : null;
                }
            }
            else
            if( orig.declaredBy != obj )
            {
                String fullname = getFullNameForInheritedSlot(cx, orig.declaredBy, node.ref.name);
                cx.error(node.variable.identifier.pos(), kError_ConflictingInheritedNameInNamespace, fullname, nsstr);
            }
            else
            {
                if( isGlobalOrLocalDefinition && !orig.isConst() && (orig.getTypeRef()==null || node.typeref==null || orig.getTypeRef().name.equals(node.typeref.name)) )
                {
                    // compatible definitions so allow
                }
                else
                {
                    cx.error(node.variable.identifier.pos(), kError_ConflictingNameInNamespace, node.ref.name, "internal");
                }
            }
            if( (node.block != null) ||  // node.block is null for defintions at the top level of the method 
                	(node.initializer == null) )
            {
            	// Need to init the local at the beginning of the method
            	// so that the types at the backwards branch will match at 
            	// verify time.
            	orig.setNeedsInit(true);
            }
            
        }

        node.debug_name = cx.debugName(region_name_stack.back(),node.ref.name,namespace_ids,VAR_TOKEN);
        return null;
    }

    /*

    Function definitions can occur in the global scope, other function bodies, class definitions,
    and package definitions. Inside class definitions they can be one of:

        global method on a class object (static)
        global method on an instance object (final or ctor method)
        local method on an instance object (non-static method)
        local getter on an instance object (non-static getter)
        local setter on an instnace object (non-static setter)
        function closure on the global object (toplevel function)
        function closure on a function object (nested function)

    A function closure is a method bound to a lexical environement
    A method closure is a method bound to a receiver object. One is created when a method is
        extracted from its instance.

    The FunctionDefinitionNode evaluator is responsible for creating the
    appropriate binding and compile-time value. It does this by determining
    the correct Builder action to take.

    E.g. A static method on a class will dispatch the class object builder
    with the sequence: Method, ExplicitMethod.

    E.g. A non-static getter will result in the instance builder getting the
    commands: Method, ExplicitGet

    polymorphic, monomorphic
    native, normal
    global, local

    */

    public Value evaluate(Context unused_cx, FunctionDefinitionNode node)
    {
        Context cx = node.cx; // switch context to the one used to parse this node, for error reporting

        // If this is a toplevel definition (pkgdef!=null), then set up access namespaces

        if( node.pkgdef != null && cx.getScopes().size() == 1 )
        {
            public_namespaces.push_back(node.pkgdef.publicNamespace);
            default_namespaces.push_back(node.pkgdef.internalNamespace);
            usednamespaces_sets.push_back(node.pkgdef.used_namespaces);
            used_def_namespaces_sets.push_back(node.pkgdef.used_def_namespaces);
            importednames_sets.push_back(node.pkgdef.imported_names);
            Builder temp_bui = cx.scope().builder;
            GlobalBuilder bui = ((temp_bui instanceof GlobalBuilder) ? (GlobalBuilder)temp_bui : null);
            if( bui != null )
            {
                bui.is_in_package = true;
            }   // otherwise, internal error
        }

        // Attributes

        boolean is_static    = false;
        boolean is_intrinsic = false;
        boolean is_native    = false;
        boolean is_ctor      = false;
        boolean is_final     = false;
        boolean is_override  = false;
        boolean is_prototype = node.is_prototype;
        boolean is_dynamic   = false;
        Namespaces namespaces = new Namespaces();
        ObjectList<String> namespace_ids = new ObjectList<String>(1);


        if( node.attrs != null)
        {
            if( node.attrs.hasVirtual && node.attrs.hasFinal )
            {
                cx.error(node.attrs.pos(), kError_FuncIsVirtualAndFinal);
            }
            if( node.attrs.hasStatic && node.attrs.hasVirtual )
            {
                cx.error(node.attrs.pos(), kError_FuncIsStaticAndVirtual);
            }
            if( node.attrs.hasStatic && node.attrs.hasOverride )
            {
                cx.error(node.attrs.pos(), kError_FuncIsStaticAndOverride);
            }
            if( node.attrs.hasStatic && node.attrs.hasDynamic )
            {
                cx.error(node.attrs.pos(), kError_InvalidDynamic);
            }

            is_static = node.attrs.hasStatic;
            is_intrinsic = node.attrs.hasIntrinsic;
            is_native = node.attrs.hasNative;
            is_dynamic = node.attrs.hasDynamic;

            if( is_static )
            {
                is_final = true;  // statics are always final
            }
            else
            {
                is_final = node.attrs.hasFinal;
            }
            is_override = node.attrs.hasOverride;
        }

        computeNamespaces(cx,node.attrs,namespaces,namespace_ids);
        if (node.pkgdef == null && cx.getScopes().size() == 1 && node.attrs != null )
        {
            if( node.attrs.hasAttribute(PUBLIC) )
                cx.error(node.attrs.pos(), kError_InvalidPublic);
        }

        NodeFactory nodeFactory = cx.getNodeFactory();
        QualifiedIdentifierNode qualifiedIdentifier = nodeFactory.qualifiedIdentifier(node.attrs, node.name.identifier.name, node.name.identifier.pos());
        node.init = nodeFactory.expressionStatement(nodeFactory.assignmentExpression(qualifiedIdentifier, CONST_TOKEN, node.fexpr));
        node.init.isVarStatement(true); // var statements always have a empty result

        // Compute reference

        boolean is_first_time = node.ref == null;
        Value val = node.name.identifier.evaluate(cx,this);
        node.ref = ((val instanceof ReferenceValue) ? (ReferenceValue)val : null);

        node.fexpr.namespace_ids = namespace_ids;

        // Get the current object and its builder

        ObjectValue obj = getVariableDefinitionScope(cx);
        Builder     bui = obj.builder;

        region_name_stack.push_back(cx.debugName(region_name_stack.back(),node.ref.name,namespace_ids,node.name.kind));

        // Constructor? Tweak the name

        String cname = fun_name_stack.back();
        if( cname.equals(node.ref.name))
        {
            if( bui instanceof InstanceBuilder)
            {
                is_ctor = true;
                node.ref.name = "$construct";
                is_final = true; // not strictly speaking, but can't be hidden, can't be overriden
                namespaces.push_back(cx.publicNamespace());

            }
            else
            {
                cx.error(node.pos(), kError_ConstructorsMustBeInstanceMethods);
            }
            if( node.name.kind == SET_TOKEN || node.name.kind == GET_TOKEN)
            {
                cx.error(node.pos(), kError_ConstructorCannnotBeGetterSetter);
            }
            if( node.attrs != null )
            {
                for ( ObjectValue ns : node.attrs.namespaces )
                {
                    if( ns != cx.publicNamespace() )
                    {
                        cx.error(node.pos(), kError_ConstructorMustBePublic);
                        break;
                    }
                }
            }
        }

        if (bui instanceof ActivationBuilder)
        {
            if (node.name.kind == SET_TOKEN || node.name.kind == GET_TOKEN)
            {
                cx.error(node.pos(), kError_InvalidNestedAccessor);
            }
        }

        boolean is_interface_method = false;
        boolean is_instance_method = false;
        if( bui instanceof InstanceBuilder )
        {
            is_instance_method = true;
            is_interface_method = (obj.type != null && obj.type.isInterface());
        }
        else if( bui instanceof ClassBuilder)
        {
            if( ((ClassBuilder)bui).is_interface )
            {
                is_interface_method = true;
            }
        }
        if( is_interface_method || is_native )
        {
            if (is_interface_method && is_native)
            {
                cx.error(node.pos(), kError_InvalidInterfaceNative);
            }
            if( node.fexpr.isUserDefinedBody() )
            {
                cx.error(node.pos(), is_interface_method ? kError_InterfaceMethodWithBody : kError_NativeMethodWithBody);
            }
        }
        else
        {
            if( !node.fexpr.isUserDefinedBody() && !is_ctor && !is_native && !is_dynamic ) //ctors and native and dynamic methods don't need bodies
            {
                cx.error(node.pos(), kError_FunctionWithoutBody);
            }
        }

        if( node.attrs != null )
        {
            if( node.attrs.hasFinal && (!is_instance_method || is_interface_method) )
            {
                cx.error(node.pos(), kError_InvalidFinalUsage);
            }
            if( is_interface_method && (node.attrs.hasPrivate || node.attrs.hasProtected || node.attrs.hasInternal || node.attrs.hasPublic) && (!node.ref.name.equals("$construct") ))
            {
                // todo fix error msg
                cx.error(node.pos(), kError_BadAccessInterfaceMember);
            }
        }

        if( is_static )
        {
            if (is_interface_method)
            {
                cx.error(node.pos(), kError_InvalidStatic);
            }
        }

        if (is_interface_method)
        {
            // Namespace attributes are not allowed on interface methods
            if (node.attrs != null && node.attrs.getUserNamespace() != null)
            {
                cx.error(node.pos(), kError_InterfaceNamespaceAttribute);
            }
        }

        // If the method is public and matches an interface method name, add
        // the interface namespaces.
        else if (interfaceMethods != null &&
        		 interfaceMethods.size() > 0 &&
                 namespaces.contains(cx.publicNamespace()))
        {
            Qualifiers q;
        	if(Builder.removeBuilderNames) // TODO: {pmd} both ways on this if look very similar, review this
        	{
        		q = interfaceMethods.get(node.ref.name, node.name.kind == SET_TOKEN ? Names.SET_NAMES : Names.GET_NAMES );
        	}
        	else
        	{
        		q = interfaceMethods.get(node.ref.name, Names.getTypeFromKind(node.name.kind));
        	}

        	if(q != null)
        	{
	            for (ObjectValue ns : q.keySet())
	            {
	                namespaces.push_back(ns);
	                namespace_ids.push_back(ns.name);
	            }
        	}
        }

        /*

        Define a Call slot on the current frame. There are three possible
        interpretations for this node:

        1/ it overrides an inherited method - reuse the inherited explicit binding
           give it a new implicit binding

        2/ it overrides an non-inherited method - if it is in a strict context, then
           report an error, otherwise give it a new implicit binding

        3/ it introduces a new method - give it a new explicit binding

        */

        int slot_id = -1;

        int kind = node.name.kind == SET_TOKEN?SET_TOKEN:GET_TOKEN;
        Namespaces open_definition_namespaces ;
        if( node.attrs != null && node.attrs.hasUserNamespace())
        {
            open_definition_namespaces = namespaces;
        }
        else
        {
            open_definition_namespaces = used_def_namespaces_sets.back();
        }

        Namespaces hasNamespaces = obj.hasNames(cx,kind ,node.ref.name,open_definition_namespaces);

        if( hasNamespaces != null )
        {
            // Can only override instance methods

            if( bui instanceof InstanceBuilder )
            {
                slot_id = obj.getSlotIndex(cx,kind,node.ref.name,hasNamespaces.back());

                    // ISSUE: need to check that all names are to the same slot

                // Get the implicit method slot to get the default method_id

                int implied_id = obj.getImplicitIndex(cx,slot_id,EMPTY_TOKEN);

                // If slot id is less than zero, then this is a getter or setter. Getter
                // and setter method ids are encoded in their explicit slot, so nothing
                // do do here

                if( implied_id >= 0 ) // else, do nothing
                {
                    // check that the override is at least as accessible as the overriden
                    if (!is_ctor && !namespacesContains(cx, namespaces, hasNamespaces))
                    {
                    	if( !( namespaces.size() == 1 && hasNamespaces.size() == 1 && namespaces.at(0).isProtected() && hasNamespaces.at(0).isProtected() ) )
                    	{
                    		cx.error(node.pos(), kError_IncompatibleOverride);
                    	}
                    }

                    int overridden_kind = (slot_id == implied_id) ? kind : EMPTY_TOKEN;
                    if (overridden_kind != node.name.kind && !is_ctor)
                    {
                        cx.error(node.pos(), kError_IncompatibleOverride);
                    }

                    if( true /* check signature and final */ )
                    {
                        Slot slot = obj.getSlot(cx,implied_id);
                        is_dynamic = slot.isIntrinsic();
                        int method_id = slot.getMethodID();
                        if( slot.isFinal() && !is_ctor )
                        {
                            if( node.name.kind == SET_TOKEN || node.name.kind == GET_TOKEN)
                                cx.error(node.pos(), kError_OverrideFinalAccessor);
                            else
                                cx.error(node.pos(), kError_FinalMethodRedefinition);
                        }

                        if( slot.declaredBy == obj )
                        {
                            // This was already defined at this level, it was not inherited from a base class
                            cx.error(node.pos(), kError_DuplicateFunction);
                        }
                        else if( is_prototype || is_dynamic )
                        {
                            is_override = true;
                        }
                        else if( !is_override && !is_ctor )
                        {
                            cx.error(node.pos(), kError_OverrideOfFuncNotMarkedForOverride);
                        }

                        if( node.name.kind == GET_TOKEN )
                        {
                            slot_id = bui.ExplicitGet(cx,obj,node.ref.name,namespaces,cx.noType(),is_final,is_override,-1,method_id,-1);
                        }
                        else
                        if( node.name.kind == SET_TOKEN )
                        {
                            slot_id = bui.ExplicitSet(cx,obj,node.ref.name,namespaces,cx.noType(),is_final,is_override,-1,method_id,-1);
                        }
                        else
                        {
                            slot_id = bui.ExplicitCall(cx,obj,node.ref.name,namespaces,cx.noType(),is_final,is_override,-1,method_id,-1);
                        }

                        if( !is_ctor )
                        {
                        	// Constructors don't actually override the base class constructor
                        	// Can have different signatures, so don't mark it as having an overriden slot
                        	// so we won't do signature matching later.
	                        Slot overriddenSlot = slot;
	                        Slot overrideSlot = obj.getSlot(cx,obj.getImplicitIndex(cx,slot_id,EMPTY_TOKEN));
	                        overrideSlot.setOverriddenSlot(overriddenSlot);
                        }
                    }
                    else
                    {
                        cx.error(node.pos(), kError_IncompatibleOverride);
                    }
                }
                else // cn: I think accessors now always end up in the block above, making this else block obsolete.
                {
                    Slot slot = obj.getSlot(cx,slot_id);
                    if( slot.getMethodID() <= 0 )
                    {
                        cx.error(node.pos(), kError_OverrideFinalAccessor);
                    }

                    // ISSUE: implement accessor overriding
                }
            }
            else
            if( bui instanceof ClassBuilder )
            {
                cx.error(node.pos(), kError_DuplicateFunction);
            }
            else
            if (bui instanceof GlobalBuilder && (node.pkgdef != null || namespaces.at(0) != hasNamespaces.at(0)) && is_first_time )
            {
                cx.error(node.pos(), kError_DuplicateFunction);
            }
            else
            if( cx.useStaticSemantics() && is_first_time ) // ISSUE: remove use of this flag by not evaluating this code twice
            {
                cx.error(node.pos(), kError_DuplicateFunction);
            }
            else
            {
                slot_id = obj.getSlotIndex(cx,GET_TOKEN,node.ref.name,hasNamespaces.at(0));
            }
        }
        else
        {
            if( is_override && !is_ctor)
            {
                if (is_interface_method)
                {
                    cx.error(node.pos(), kError_InvalidOverrideUsage);
                }
                else
                {
                    ObjectValue n = namespaces.at(0);
                    UnresolvedNamespace un = n instanceof UnresolvedNamespace ? (UnresolvedNamespace) n : null;
                    if( un == null || un.resolved )
                    {
                        cx.error(node.pos(), kError_OverrideNotFound);
                    }
                    else
                    {
                        cx.error(un.node.pos(), kError_Unknown_Namespace);
                    }
                }
            }

            if( node.name.kind == GET_TOKEN )
            {
                int method_id = bui.Method(cx,obj,(node.ref.name+"$get").intern(),namespaces,is_intrinsic); // Add getter to local dispatch table
                slot_id = bui.ExplicitGet(cx,obj,node.ref.name,namespaces,cx.noType(),is_final,is_override,-1,method_id,-1);
            }
            else
            if( node.name.kind == SET_TOKEN )
            {
                int method_id = bui.Method(cx,obj,(node.ref.name+"$set").intern(),namespaces,is_intrinsic);
                slot_id = bui.ExplicitSet(cx,obj,node.ref.name,namespaces,cx.noType(),is_final,is_override,-1,method_id,-1);
            }
            else
            {
                int method_id = bui.Method(cx,obj,node.ref.name,namespaces,is_intrinsic);
                slot_id = bui.ExplicitCall(cx,obj,node.ref.name,namespaces,cx.noType(),is_final,is_override,-1,method_id,-1);
            }
        }

        /*

        At this point we have either reported a redefinition error, or have
        the explicit slot for the function being defined, and an implicit
        slot for the implementation (i.e. method name, call seq)

        Now we specify the implementation

        */

        if( is_intrinsic )
        {
        }
        else
        if( node.fexpr != null && slot_id >= 0 )
        {
            node.fexpr.setNative(is_native);
            node.fexpr.kind = node.name.kind;  // inherited attribute

            Slot slot     = obj.getSlot(cx,slot_id);

            // FunctionCommonNode gets evaluated twice. The first time is for initializing
            // the function object and adding it to the list of nodes to be evaluated later.
            // The second time (this time) is for evaluating the function body.

            val     = node.fexpr.evaluate(cx,this);
            val = val != null ? val.getValue(cx) : null;
            slot.setObjectValue((val instanceof ObjectValue ? (ObjectValue)val : null));
            // slot.objValue = dynamic_cast<ObjectValue>(val!=null?val.getValue(cx) : null);


            if( slot.getObjectValue() != null)
            {
                // Resolve this function to its local dispatch id, if it is virtual, or a global
                // method id (method info) if it is not. Local method ids share the same local
                // name (the name of the original method). If B overrides m in A, then the local
                // method id for B.m will be something like A$m. If B.n is new, then its local
                // name will be something like B$n. A name consists of the classname,simplename,and
                // namespace.

                // B inherits the names of A. B declares an override of A.m. The new method slot for
                // m in B has the internal name that is the same as m in A, and therefore the same
                // dispatch id ( = local method name id).

                // The key is comparing names so that the rules for overriding are correctly implemented.

                if( is_ctor )
                {
                    InstanceBuilder ib = ((bui instanceof InstanceBuilder) ? (InstanceBuilder)bui : null);
                    if( ib != null)
                    {
                        ib.has_ctor = true;
                        ib.ctor_name = node.fexpr.internal_name;
                    }
                    else
                    {
                        cx.error(node.pos(), kError_ConstructorsMustBeInstanceMethods);
                    }
                }
                else
                if( bui instanceof ClassBuilder || bui instanceof InstanceBuilder || bui instanceof PackageBuilder )
                {
                }
                else
                {
                }

                /*

                Copy the implementation details into the implicit call slot

                */

                slot_id = obj.getImplicitIndex(cx,slot_id,EMPTY_TOKEN);
                obj.getSlot(cx,slot_id).setMethodName(node.fexpr.internal_name);
                obj.getSlot(cx,slot_id).setIntrinsic(is_dynamic);
                slot.getObjectValue().name = node.fexpr.internal_name;

            }

            node.fexpr.debug_name = region_name_stack.back();
        }
        region_name_stack.pop_back();

        if( node.pkgdef != null && cx.getScopes().size() == 1 )
        {
            usednamespaces_sets.pop_back();
            used_def_namespaces_sets.pop_back();
            importednames_sets.pop_back();
            public_namespaces.pop_back();
            default_namespaces.pop_back();
            Builder temp_bui = cx.scope().builder;
            GlobalBuilder gbui = ((temp_bui instanceof GlobalBuilder) ? (GlobalBuilder)temp_bui : null);
            if( gbui != null )
            {
            gbui.is_in_package = false;
            }   // otherwise, internal error
        }

        if( node.needs_init )
        {
            if( node.pkgdef != null && cx.getScopes().size() == 1 )
            {
                usednamespaces_sets.push_back(node.pkgdef.used_namespaces);
                used_def_namespaces_sets.push_back(node.pkgdef.used_def_namespaces);
                importednames_sets.push_back(node.pkgdef.imported_names);
                public_namespaces.push_back(node.pkgdef.publicNamespace);
                default_namespaces.push_back(node.pkgdef.internalNamespace);
                Builder temp_bui = cx.scope().builder;
                GlobalBuilder gbui = ((temp_bui instanceof GlobalBuilder) ? (GlobalBuilder)temp_bui : null);
                if( gbui != null )
                {
                    gbui.is_in_package = true;
                }   // otherwise, internal error
            }

            node.init.evaluate(cx,this);

            if( node.pkgdef != null && cx.getScopes().size() == 1 )
            {
                public_namespaces.pop_back();
                default_namespaces.pop_back();
                usednamespaces_sets.pop_back();
                used_def_namespaces_sets.pop_back();
                importednames_sets.pop_back();
                Builder temp_bui = cx.scope().builder;
                GlobalBuilder gbui = ((temp_bui instanceof GlobalBuilder) ? (GlobalBuilder)temp_bui : null);
                if( gbui != null )
                {
                    gbui.is_in_package = false;
                }   // otherwise, internal error
            }
            return null;
        }


        return null;
    }

    public Value evaluate(Context unused_cx, BinaryFunctionDefinitionNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, FunctionNameNode node)
    {
        Value val = node.identifier.evaluate(cx, this);
        ReferenceValue ref = ((val instanceof ReferenceValue) ? (ReferenceValue)val : null);
        return ref;
    }

    public Value evaluate(Context cx, FunctionSignatureNode node)
    {
        if (node.parameter != null)
        {
            node.parameter.evaluate(cx, this);
        }
        if (node.result != null)
        {
            Value val = node.result.evaluate(cx,this);
            node.typeref = ((val instanceof ReferenceValue) ? (ReferenceValue)val : null);
            if( node.typeref == null )
            {
                cx.error(node.result.pos(), kError_UnknownType);
            }
            else
            {
            	node.typeref.setTypeAnnotation(true);
            }
        }
        return null;
    }


    public Value evaluate( Context cx, RestParameterNode node )
    {
        ObjectValue obj = cx.scope();
        Builder     bui = obj.builder;

        Value v = node.identifier.evaluate(cx,this);
        node.ref = ((v instanceof ReferenceValue) ? (ReferenceValue)v : null);
        if( node.type != null)
        {
            v = node.type.evaluate(cx,this);
            node.typeref = ((v instanceof ReferenceValue) ? (ReferenceValue)v : null);

            if( node.typeref != null )
            {
                node.typeref.setTypeAnnotation(true);
            }
        }

        Namespaces namespaces = new Namespaces();

        namespaces.push_back(cx.publicNamespace());

        {
            // Allocate space for the variable and create the property
            // slots. A property is represented at compile-time as a
            // name and a pair of accessors (getter and setter).

            int var_id;
            var_id  = bui.Variable(cx,obj);
            bui.ExplicitVar(cx,obj,node.ref.name,namespaces,cx.arrayType(),-1,-1,var_id);
        }

        return node.ref;
    }

    public Value evaluate( Context cx, ParameterNode node )
    {

        ObjectValue obj = cx.scope();
        Builder     bui = obj.builder;

        Value v = node.identifier.evaluate(cx,this);
        node.ref = ((v instanceof ReferenceValue) ? (ReferenceValue)v : null);

        if (node.init != null)
        {
            node.init.evaluate(cx, this);
        }

        if( node.type != null)
        {
            v = node.type.evaluate(cx,this);
            node.typeref = ((v instanceof ReferenceValue) ? (ReferenceValue)v : null);
            if( node.typeref != null )
            {
                node.typeref.setTypeAnnotation(true);
            }
            else
            {
                cx.error(node.type.pos(), kError_UnknownType);
            }
        }


        Namespaces namespaces = new Namespaces();

        ObjectValue default_ns = default_namespaces.last();
        if (default_ns.isInterface())
        {
            // parameters of interface methods should be public
            default_ns = cx.publicNamespace();
        }

        namespaces.push_back(default_ns);

        {
            // Allocate space for the variable and create the property
            // slots. A property is represented at compile-time as a
            // name and a pair of accessors (getter and setter).

            int var_id;
            var_id  = bui.Variable(cx,obj);
            int slot_id = bui.ExplicitVar(cx,obj,node.ref.name,namespaces,cx.noType(),-1,-1,var_id);
            Slot slot = obj.getSlot(cx,slot_id);
            slot.setTypeRef(node.typeref);
        }

        return node.ref;
    }

    public Value evaluate( Context cx, ParameterListNode node )
    {
        if( debug )
        {
            System.out.println("\n// +ParameterList");
        }

        for (ParameterNode it : node.items)
        {
            it.evaluate(cx,this);
        }

        if( debug )
        {
            System.out.println("\n// -ParameterList");
        }

        return null;
    }

    public Value evaluate(Context cx, ToObjectNode node)
    {
        node.expr.evaluate(cx, this);
        return null;
    }

    public Value evaluate(Context cx, LoadRegisterNode node)
    {
        if( node.reg != null )
        {
            node.reg.evaluate(cx,this);
        }
        return null;
    }

    public Value evaluate(Context cx, StoreRegisterNode node)
    {
        if( node.reg != null )
        {
            node.reg.evaluate(cx,this);
        }
        node.expr.evaluate(cx, this);
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

    public Value evaluate(Context cx, BoxNode node)
    {
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

    /*
     * Processing class definitions involves separating the static definitions
     * from the non-statics. The statics go into an outer function, and the
     * non-statics go into an inner function.
     *
     * The trick is to complete the static definitions before the non-statics.
     * This is neccessary because the statics are in scope for the non-statics.
     */


    public Value evaluate(Context unused_cx, ClassDefinitionNode node)
    {
        // If we are doing a class, then defer this class definition until we
        // are done. Put it in the current set of the clsdefs_sets for now.

        Context cx = node.cx;  // switch contexts so that the original one is used

        /* #if 0 // debugging
        switch( node.state )
        {
        case node.INIT:
        printf("\ndoing init");
        break;
        case node.INHERIT:
        printf("\ndoing inheritance");
        break;
        case node.MAIN:
        printf("\ndoing body");
        break;
        default:
        cx.internalError("invalid CDN state");
        break;
        }
        #endif */

        if( node.pkgdef != null && cx.getScopes().size() == 1 )
        {
            public_namespaces.push_back(node.pkgdef.publicNamespace);
            default_namespaces.push_back(node.pkgdef.internalNamespace);
            usednamespaces_sets.push_back(node.pkgdef.used_namespaces);
            used_def_namespaces_sets.push_back(node.pkgdef.used_def_namespaces);
            importednames_sets.push_back(node.pkgdef.imported_names);
        }

        // First, initialize the node

        if( node.cframe == null /*doingClass()*/ )
        {
            // If this is a toplevel definition (pkgdef!=null), then set up access namespaces

            node.used_namespaces.addAll(usednamespaces_sets.back());  // makes a copy

            node.imported_names.putAll(importednames_sets.back());  // makes a copy
            node.public_namespace  = cx.publicNamespace();  // public_namespaces.back();
            node.default_namespace = default_namespaces.back();

            // clsdefs_sets is a stack of sets of class definitions.
            // Each set contains the classes at a particular scope level.

            if( clsdefs_sets.size() == 1 ) // otherwise, we've already captured the clsdefs for nested classes
            {
                int size = clsdefs_sets.last().size();
                int i;

                // Look for the current node in the set for the current scope.

                for (i = 0; i < size && clsdefs_sets.last().get(i) != node; ++i);

                // If it is not in the set, then add it.

                if (i >= size)
                {
                    if (package_name.length() != 0)
                    {
                        node.package_name = package_name;
                    }
                    clsdefs_sets.last().add(node);
                }
                else
                {
                    //cx.internalError("Internal error: the same class definition should never get processed twice.");
                    // This actually does happen, but the code from this point on is only executed once.
                }
            }

           // boolean is_static = false;
            boolean is_intrinsic = false;

            if (node.attrs != null)
            {
                // is_static = node.attrs.hasStatic;
                is_intrinsic = node.attrs.hasIntrinsic;
                if( node.attrs.hasNative )
                {
                    cx.error(node.pos(), kError_InvalidNative);
                }
				// Note: node.attrs.hasOverride will have already been checked
				// by the hoisted_defs test in StatementListNode
                /*if( node.attrs.hasOverride )
                {
                    cx.error(node.pos(), kError_InvalidOverride);
                }*/
            }

            if( cx.getScopes().size() > 1 )
            {
                if (node.isInterface())
                    cx.error(node.pos(), kError_InvalidInterfaceNesting);
                else
                    cx.error(node.pos(), kError_InvalidClassNesting);
            }

            // Only do the following once

            if (node.ref == null)
            {
                ObjectValue ownerobj = cx.scope();
                Builder ownerbui = ownerobj.builder;

                String region_name = region_name_stack.back();
                region_name += region_name.length() > 0 ? "/" : "";

                ObjectList<String> namespace_ids = new ObjectList<String>();

                computeNamespaces(cx,node.attrs,node.namespaces,namespace_ids);
                if (node.pkgdef == null && cx.getScopes().size() == 1 && node.attrs != null)
                {
                    if( node.attrs.hasAttribute(PUBLIC) )
                        cx.error(node.attrs.pos(), kError_InvalidPublic);
                }

                Value val = node.name.evaluate(cx,this);
                node.ref = ((val instanceof ReferenceValue) ? (ReferenceValue)val : null);

                //String fullname = cx.debugName(region_name,node.ref.name,namespace_ids,EMPTY_TOKEN);
                QName fullname = cx.computeQualifiedName(region_name, node.ref.name, node.ref.getImmutableNamespaces().back(), EMPTY_TOKEN);
                node.private_namespace = cx.getNamespace(fullname.toString(), Context.NS_PRIVATE);
                node.protected_namespace = cx.getNamespace(fullname.toString(), Context.NS_PROTECTED);
                node.static_protected_namespace = cx.getNamespace(fullname.toString(), Context.NS_STATIC_PROTECTED);

                if( cx.isBuiltin(fullname.toString()) )
                {
                    node.cframe = cx.builtin(fullname.toString());
                    node.iframe = node.cframe.prototype;
                }
                else
                {
                    node.cframe = TypeValue.defineTypeValue(cx,new ClassBuilder(fullname,node.protected_namespace,node.static_protected_namespace),fullname,TYPE_object); // ISSUE: what should the type tag be?
                    if( !node.is_default_nullable )
                    {
                        node.cframe.is_nullable = false;
                    }
                    node.cframe.type = cx.typeType().getDefaultTypeInfo();
                    if( node.cframe.prototype != null )
                    {
                    	node.cframe.prototype.clearInstance(cx,new InstanceBuilder(fullname),node.cframe, ObjectValue.EMPTY_STRING, true);
                    	node.iframe = node.cframe.prototype;
                    }
                    else
                    {
                        node.iframe = new ObjectValue(cx,new InstanceBuilder(fullname),node.cframe); 
                        node.cframe.prototype = node.iframe;  // ISSUE: this is not really the prototype, but works for now
                        node.owns_cframe = true;  // so it deletes it
                    }
                }

                if (node instanceof InterfaceDefinitionNode)
                {
                    node.default_namespace = node.cframe;  // class object and namespace all in one
                }

                if( node.attrs != null)
                {
                    node.cframe.builder.is_dynamic = node.iframe.builder.is_dynamic = node.attrs.hasDynamic;
                    node.cframe.builder.is_final = node.iframe.builder.is_final = node.attrs.hasFinal;
                    node.cframe.builder.is_intrinsic = node.iframe.builder.is_intrinsic = is_intrinsic;
                }

                Namespaces open_definition_namespaces ;
                if( node.attrs != null && node.attrs.hasUserNamespace() )
                {
                    open_definition_namespaces = node.namespaces;
                }
                else
                {
                    open_definition_namespaces = used_def_namespaces_sets.back();
                }
                Namespaces hasNamespaces = ownerobj.hasNames(cx,GET_TOKEN,node.ref.name,open_definition_namespaces);
                if( hasNamespaces == null )
                {
                    // If this class is intrinsic, then don't implement it

                    int var_id = -1;
                    if( node.attrs==null || !node.attrs.hasIntrinsic )
                    {
                        var_id  = ownerbui.Variable(cx,ownerobj);
                    }

                    int slot_id = ownerbui.ExplicitVar(cx,ownerobj,node.ref.name,node.namespaces,cx.typeType(),-1,-1,var_id);
                    ownerobj.getSlot(cx,slot_id).setValue(node.cframe);
                    ownerobj.getSlot(cx,slot_id).setConst(true); // class defs are const.
                   // Implicit method to represent call & construct

                    ownerbui.ImplicitCall(cx,ownerobj,slot_id,node.cframe,CALL_Method,-1,-1);
                    ownerbui.ImplicitConstruct(cx,ownerobj,slot_id,node.cframe,CALL_Method,-1,-1);

                }
                else
                {
                    if( node.isInterface() )
                    {
                        cx.error( node.name.pos(), kError_DuplicateInterfaceDefinition, node.ref.name);
                    }
                    else
                    {
                        cx.error( node.name.pos(), kError_DuplicateClassDefinition, node.ref.name);
                        found_circular_or_duplicate_class_definition = true;
                    }
                }

                // delete hasNamespaces;
            }

            node.used_namespaces.push_back(node.private_namespace);
            node.used_namespaces.push_back(node.protected_namespace);
            node.used_namespaces.push_back(node.static_protected_namespace);

            node.used_def_namespaces.push_back(node.private_namespace);
            node.used_def_namespaces.push_back(node.public_namespace);
            node.used_def_namespaces.push_back(node.default_namespace);
            node.used_def_namespaces.push_back(node.protected_namespace);
            node.used_def_namespaces.push_back(node.static_protected_namespace);

            node.state = ClassDefinitionNode.INHERIT;

            NodeFactory nodeFactory = cx.getNodeFactory();
            QualifiedIdentifierNode qualifiedIdentifier = nodeFactory.qualifiedIdentifier(node.attrs, node.name.name, node.name.pos());
            node.init = nodeFactory.expressionStatement(nodeFactory.assignmentExpression(qualifiedIdentifier, CONST_TOKEN, node));
            node.init.isVarStatement(true);

            clsdefs_sets.push_back(new ObjectList<ClassDefinitionNode>()); // make dummy
            cx.pushStaticClassScopes(node);
            ObjectList<String> namespace_ids = new ObjectList<String>();
            if( node.namespaces.size() != 0 )
            {
                namespace_ids.push_back(node.namespaces.back().name);
            }
            else
            {
                namespace_ids.push_back("error");
            }

            region_name_stack.push_back(cx.debugName(region_name_stack.back(),node.ref.name,namespace_ids,EMPTY_TOKEN));

            usednamespaces_sets.push_back(node.used_namespaces);
            used_def_namespaces_sets.push_back(node.used_def_namespaces);

            for (ClassDefinitionNode n : node.clsdefs)
            {
                // Haven't done the outer class' statement list yet, so the attrs
                // haven't been done yet
                if( n.attrs != null )
                {
                    n.attrs.evaluate(cx,this);
                }
                n.evaluate(cx,this);
            }
            cx.popStaticClassScopes(node);
            region_name_stack.removeLast();
            usednamespaces_sets.removeLast();
            used_def_namespaces_sets.removeLast();
            clsdefs_sets.removeLast();

        }
        else if( doingClass() || doingMethod() )
        {
            // Wait
        }
        else if (resolveInheritance)
        {
            if (node.baseclass == null && node.cframe != cx.objectType())
            {
                NodeFactory nf = cx.getNodeFactory();
                node.baseclass = nf.memberExpression(null, nf.getExpression(nf.identifier("Object")));
            }

            if (node.baseref == null)
            {
                if (node.baseclass != null)
                {
                    rt_unresolved_sets.last().addAll(unresolved);
                    unresolved.clear();

                    Value val2 = node.baseclass.evaluate(cx,this);

                    fa_unresolved_sets.last().addAll(unresolved);
                    unresolved.clear();

                    node.baseref = ((val2 instanceof ReferenceValue) ? (ReferenceValue)val2 : null);
                    if( node.baseref == null )
                    {
                        // uh oh, didn't resolve to anything, but we have a baseclass expression
                        cx.error(node.baseclass.pos(), kError_InvalidBaseTypeExpression);
                    }
                }
            }

            if (node.baseref != null)
            {
                Value val = node.baseref.getValue(cx);
                TypeValue type = ((val instanceof TypeValue) ? (TypeValue)val : null);

                if (type == null)
                {
                    // stay silent. we'll report this in the else part...
                    // cx.error(node.baseclass.pos(), kError_UnknownBaseClass);
                }
                else
                if( type.builder.is_final )
                {
                    // stay silent. we'll report this in the else part...
                    // cx.error(node.baseclass.pos(), kError_BaseClassIsFinal);
                }
                else
                if ( type.builder instanceof ClassBuilder && ((ClassBuilder)type.builder).is_interface )
                {
                    // stay silent. we'll report this in the else part...
                    // cx.error(node.baseclass.pos(), node.isInterface() ? kError_CannotExtendClass : kError_CannotExtendInterface);
                }
                else
                {
                    inheritClassSlots(node.cframe, node.iframe, type, cx);
                }
            }

            if( node.interfaces != null )
            {
                rt_unresolved_sets.last().addAll(unresolved);
                unresolved.clear();

                node.interfaces.evaluate(cx,this);

                fa_unresolved_sets.last().addAll(unresolved);
                unresolved.clear();
            }

            /*
            if (node.interfaces != null && node.interfaces.values != null)
            {
                for (Value v : node.interfaces.values)
                {
                    if (v instanceof ReferenceValue)
                    {
                        ReferenceValue ref = (ReferenceValue) v;
                        Value v2 = v.getValue(cx);
                        TypeValue t = dynamic_cast(TypeValue.class, v2);

                        if (t == null)
                        {
                            // stay silent. we'll report this in the else part...
                            // cx.error(node.baseclass.pos(), kError_UnknownBaseClass);
                        }
                        else
                        {
                            //inheritClassSlots(node.cframe, node.iframe, t, cx);
                        }
                    }
                }
            }
            */

            node.state = ClassDefinitionNode.MAIN;
            for (ClassDefinitionNode n : node.clsdefs)
            {
                n.evaluate(cx,this);
            }
        }
        else
        if( node.needs_init )
        {
            node.needs_init = false;
            node.init.evaluate(cx,this);
            node.needs_init = true;
        }
        else
        {
            // Start compiling the class. Statics get put in cframe, everything else
            // gets put in iframe.

            this_contexts.add(error_this);
            strict_context.push_back(true);

            usednamespaces_sets.push_back(node.used_namespaces);
            used_def_namespaces_sets.push_back(node.used_def_namespaces);
            importednames_sets.push_back(node.imported_names);

            // Put super instance properties in the instance prototype before compiling
            // the current class body.

            if (node.baseref != null)
            {
                Value val = node.baseref.getValue(cx);
                TypeValue type = ((val instanceof TypeValue) ? (TypeValue)val : null);

                if (type == null)
                {
                    cx.error(node.baseclass.pos(), kError_UnknownBaseClass, node.baseref.name);
                }
                else
                if( type.builder.is_final )
                {
                    cx.error(node.baseclass.pos(), kError_BaseClassIsFinal);
                }
                else
                if ( type.builder instanceof ClassBuilder && ((ClassBuilder)type.builder).is_interface )
                {
                    cx.error(node.baseclass.pos(), kError_CannotExtendInterface);
                }
                else
                {
                    inheritClassSlots(node.cframe, node.iframe, type, cx);

                    // No matter what, if the base slot was from an import, we can't early bind.
                    Slot base_slot = node.baseref.getSlot(node.cx, node.baseref.getKind());
                    if( base_slot.isImported() && type != cx.noType() ) //Ok if it's object, doesn't have any methods...
                    {
                        ((InstanceBuilder)node.iframe.builder).canEarlyBind = false;
                    }

                    // inherit protected namespaces
                    ClassBuilder classBuilder;
                    while( type != null && type != node.cframe && type.resolved)
                    {
                        classBuilder = (ClassBuilder) type.builder;
                        if( classBuilder.static_protected_namespace != null )
                        {
                            node.used_namespaces.push_back(classBuilder.static_protected_namespace);
                            node.used_def_namespaces.push_back(classBuilder.static_protected_namespace);
                        }

                        type = type.baseclass;
                    }
                }
            }

            if (node.interfaces != null && node.interfaces.values != null)
            {
                ObjectList<ReferenceValue> interface_refs = ((InstanceBuilder)node.iframe.builder).interface_refs;

                HashSet<TypeValue> seen_interfs = new HashSet<TypeValue>();
                for (int i = 0; i < node.interfaces.values.size(); ++i )
                {
                    Value v = node.interfaces.values.get(i);
                    if (v instanceof ReferenceValue)
                    {
                        ReferenceValue ref = (ReferenceValue) v;
                        Value v2 = v.getValue(cx);
                        TypeValue t = ((v2 instanceof TypeValue) ? (TypeValue)v2 : null);

                        if (t == null )
                        {
                            cx.error(node.interfaces.items.get(i).pos(), kError_UnknownInterface, ref.name);
                        }
                        else
                        {
                            if (t.builder instanceof ClassBuilder)
                            {
                                if (!(((ClassBuilder)t.builder).is_interface))
                                {
                                    cx.error(node.interfaces.items.get(i).pos(), kError_CannotExtendClass, ref.name);
                                }
                                else
                                {
                                    if( seen_interfs.contains(t) )
                                    {
                                        cx.error(node.interfaces.items.get(i).pos(), kError_DuplicateImplements, node.ref.name, ref.name);
                                    }
                                    else
                                    {
                                        seen_interfs.add(t);
                                    }
                                    interface_refs.push_back(ref);

                                    if (node instanceof InterfaceDefinitionNode)
                                    {
                                        // If this is an interface, inherit the super-interface slots.
                                        inheritClassSlots(node.cframe, node.iframe, t, cx);
                                    }
                                }
                            }
                            else
                            {
                                cx.error(node.interfaces.items.get(i).pos(), kError_UnknownInterface, ref.name);
                            }
                        }
                    }
                    else
                    {
                        // uh oh, didn't resolve to anything, but we have a baseclass expression
                        cx.error(node.interfaces.items.get(i).pos(), kError_InvalidInterfaceTypeExpression);
                    }
                }
            }

            Names lastInterfaceMethods = interfaceMethods;
            interfaceMethods = null;

            scanInterfaceMethods(cx, node);
            processInterfacePublicMethods(cx, node.iframe);

            StartClass(node.ref.name);

            ObjectList<String> namespace_ids = new ObjectList<String>();
            if( node.namespaces.size() != 0 )
            {
                namespace_ids.push_back(node.namespaces.back().name);
            }
            else
            {
                namespace_ids.push_back("error");
            }

            region_name_stack.push_back(cx.debugName(region_name_stack.back(),node.ref.name,namespace_ids,EMPTY_TOKEN));

            /*
                node->used_namespaces = *used_namespaces_sets.back()  // save alias of outer namespaces
                ...
                node->used_namespaces.push_back(node->private_namespace);  // add implicitly used namespaces
                ...
                usednamespaces_sets.back(&node->used_namespaces)          // add current namespaces to nss sets
                ...
                used_namespaces get deleted
            */

            private_namespaces.push_back(node.private_namespace);
            default_namespaces.push_back(node.default_namespace);
            public_namespaces.push_back(node.public_namespace);
            protected_namespaces.push_back(node.protected_namespace);
            static_protected_namespaces.push_back(node.static_protected_namespace);

            cx.pushStaticClassScopes(node);

            this_contexts.removeLast();
            this_contexts.add(cinit_this);

            // Function expressions that occur in the current block will be
            // compiled as though they had occured at the end of the block.
            // The variable that references them is initialized at the beginning
            // of the block.

            fexprs_sets.add(new ObjectList<FunctionCommonNode>());
            staticfexprs_sets.add(new ObjectList<FunctionCommonNode>());
            instanceinits_sets.add(new ObjectList<Node>());

            // Copy the set of nested functions into the node for use
            // by later phases.

            node.fexprs = fexprs_sets.last();
            node.instanceinits = instanceinits_sets.last();    // Holds the static initializers for this class
            node.staticfexprs = staticfexprs_sets.last();    // Holds the static initializers for this class

            fun_name_stack.add(node.ref.name);    // During flow analysis we use the class name
            max_params_stack.add(0);
            max_locals_stack.add(node.var_count);
            max_temps_stack.add(node.temp_count);

            StartMethod(fun_name_stack.last(), max_params_stack.last(), max_locals_stack.last());

            if (node.statements != null)
            {
                // Evaluate the statements. When we are done, the static names
                // are in the class object builder. The static initializers are
                // in the inner staticdefs_sets sets. The instance names are in
                // the instance object builder, and the instance initializers
                // are in the

                node.statements.evaluate(cx, this);
                node.temp_count = getTempCount();
                node.var_count = node.cframe.var_count;
            }
            else
            {
                StartMethod(fun_name_stack.last(), max_params_stack.last(), max_locals_stack.last());
            }

            node.temp_count = getTempCount(); // Remember the temp count

			//            Return(TYPE_none);
			Return(TYPE_void);
			FinishMethod(cx, fun_name_stack.back(), null,null,null,0, cx.getScopes().size(), "",false,false, null);

            cx.pushScope(node.iframe);

            this_contexts.removeLast();
            this_contexts.add(instance_this);

            // Evaluate the instance initializers
            // (This must be done before we add the default
            //  constructor if needed, because this is where
            //  has_ctor gets set)
            {
                for (Node n : node.instanceinits)
                {
                	if( cx.statics.es4_nullability  && !n.isDefinition())
                		node.iframe.setInitOnly(true);

                	n.evaluate(cx, this);

                	if( cx.statics.es4_nullability  && !n.isDefinition())
                		node.iframe.setInitOnly(false);

                }
            }

            ObjectValue     obj = node.iframe;
            InstanceBuilder bui = ((obj.builder instanceof InstanceBuilder) ? (InstanceBuilder)obj.builder : null);

            if( !bui.is_intrinsic && !bui.has_ctor )
            {
                NodeFactory nf = cx.getNodeFactory();

                FunctionNameNode fname = nf.functionName(EMPTY_TOKEN, nf.identifier(node.ref.name,0));

                nf.has_rest = false;
                nf.has_arguments = false;

                FunctionCommonNode fexpr = nf.functionCommon(cx, fname.identifier, nf.functionSignature(null, null, 0), null, 0);
                AttributeListNode attrs = nf.attributeList(nf.identifier(PUBLIC,false,0),null);
                attrs.evaluate(cx,this);
                FunctionDefinitionNode fdef = nf.functionDefinition(cx, attrs, fname, fexpr);
                fdef.pkgdef = node.pkgdef;
                fdef.evaluate(cx,this);
                Node init = fdef.initializerStatement(cx);
                init.evaluate(cx,this);
                if( null == node.statements )
                {
                    node.statements = nf.statementList(null,init);
                }
                else
                {
                    node.statements.items.add(0,init);
                }
            }

            // Now turn the static names into definitions


            // Generate code for the static property definitions

            {
                this_contexts.add(error_this);
                cx.popScope(); // temporarily
                for (Node n : node.staticfexprs)
                {
                    n.evaluate(cx, this);
                }
                cx.pushScope(node.iframe);
                this_contexts.removeLast();
            }


            fun_name_stack.removeLast();
            max_params_stack.removeLast();
            max_locals_stack.removeLast();
            max_temps_stack.removeLast();

            // Now evaluate each function expression
            {
                for (FunctionCommonNode n : node.fexprs)
                {
                    n.evaluate(cx, this);
                }
            }

            // Remove the top set of nested functions from the stack of sets

            fexprs_sets.removeLast();

            //ASSERT(fexprs_sets.size() == 0);

            private_namespaces.pop_back();
            default_namespaces.pop_back();
            public_namespaces.pop_back();
            protected_namespaces.pop_back();
            static_protected_namespaces.pop_back();
            usednamespaces_sets.pop_back();
            used_def_namespaces_sets.pop_back();
            importednames_sets.pop_back();

            FinishClass(cx,node.cframe.builder.classname,null,false, false, false, node.cframe.is_nullable);

            this_contexts.removeLast();

            // pop the iframe now so we process class defs in static scope
            cx.popScope(); // iframe

            // Now evaluate each class definition

            {

                // node.clsdefs have the baseclass.cframe resolved, i.e. we've got fully-qualified class names.
                // sort the class names based on "extends" and "implements"...
                node.clsdefs = sortClassDefinitions(node.cx, node.clsdefs);

                if (found_circular_or_duplicate_class_definition == false)
                {
                    for (ClassDefinitionNode clsdef : node.clsdefs)
                    {
                        clsdef.evaluate(cx,this);
                    }
                }
            }

            // Remove the top set of nested classes from the stack of sets

            instanceinits_sets.removeLast();
            staticfexprs_sets.removeLast();

            cx.popStaticClassScopes(node);

            node.debug_name = region_name_stack.back();
            // store debug name on the slot as well.  asDoc needs fully qualified debug_names for all
            //  type references.
            Slot s = node.ref.getSlot(cx,GET_TOKEN);
            if (s != null)
            {
                s.setDebugName(node.debug_name);
                s.setConst(true); // class slots are const
            }

            region_name_stack.removeLast();
            strict_context.pop_back();

            //ASSERT(fexprs_sets.size() == 0);

            interfaceMethods = lastInterfaceMethods;
        }

        if( node.pkgdef != null && cx.getScopes().size() == 1 )
        {
            default_namespaces.pop_back();
            public_namespaces.pop_back();
            usednamespaces_sets.pop_back();
            used_def_namespaces_sets.pop_back();
            importednames_sets.pop_back();
        }

        node.needs_init = true;

        if (debug)
        {
            System.out.print("\n// -ClassDefinitionNode");
        }

        return node.ref;
    }

    public Value evaluate(Context cx, BinaryClassDefNode node)
    {
        if( resolveInheritance )
        {
            if (node.baseref != null)
            {
                Value val = node.baseref.getValue(cx);
                if (val == null)
                {
                	fa_unresolved_sets.last().add(node.baseref);
                }
                else
                {
                	TypeValue type = ((val instanceof TypeValue) ? (TypeValue)val : null);

		            if (type == null)
		            {
		                // stay silent. we'll report this in the else part...
		                // cx.error(node.baseclass.pos(), kError_UnknownBaseClass);
		            }
		            else
		            if( type.builder.is_final )
		            {
		                // stay silent. we'll report this in the else part...
		                // cx.error(node.baseclass.pos(), kError_BaseClassIsFinal);
		            }
	                else
	                if ( type.builder instanceof ClassBuilder && ((ClassBuilder)type.builder).is_interface )
	                {
	                    // stay silent. we'll report this in the else part...
	                    // cx.error(node.baseclass.pos(), node.isInterface() ? kError_CannotExtendClass : kError_CannotExtendInterface);
	                }
	                else
	                {
	                    inheritClassSlots(node.cframe, node.iframe, type, cx);
	                }
                }
            }
        }
        else
        {
            if( node.baseref != null )
            {
                TypeValue baseType = (TypeValue)(node.baseref.getValue(node.cx));
                if( baseType != null)
                {
                    // Copy the methods/vars/properties from the base class into the derived class
                    inheritClassSlots(node.cframe, node.cframe.prototype, baseType, node.cx);
                }
            }
            if( node.interfaces != null )
            {
                ObjectList<ReferenceValue> interface_refs = ((InstanceBuilder)node.iframe.builder).interface_refs;
                for(int i = 0; i < node.interfaces.size();  ++i)
                {
                    Value v = node.interfaces.values.get(i);
                    if (v instanceof ReferenceValue)
                    {
						ReferenceValue ref = (ReferenceValue)v;
						if (ref.slot == null)
						{
							// if the slot is null, it's probably because we can't find 
							// the library with the parent class (e.g., playerglobal.swc)
							// ... it's a fatal error, because we'd just throw a NullPointerException
							// in the scanInterfaceMethods call below. (srj)
							cx.error(node.pos(), kError_UnknownType, ref.toMultiName());
							continue;
						}
                        interface_refs.push_back(ref);
                        Value v2 = v.getValue(node.cx);
                        TypeValue t = ((v2 instanceof TypeValue) ? (TypeValue)v2 : null);
                        if (t != null && t.isInterface())
                        {
                            if (node instanceof BinaryInterfaceDefinitionNode)
                            {
                                // If this is an interface, inherit the super-interface slots.
                                inheritClassSlots(node.cframe, node.iframe, t, node.cx);
                            }
                        }
                    }
                }
            }
            Slot s = node.ref.getSlot(node.cx,GET_TOKEN);
            if (s != null)
            {
                s.setDebugName(node.debug_name);
                s.setConst(true); // class slots are const
            }

            Names lastInterfaceMethods = interfaceMethods;
            interfaceMethods = null;

            scanInterfaceMethods(node.cx, node);
            processInterfacePublicMethods(node.cx, node.iframe);

            interfaceMethods = lastInterfaceMethods;

            node.cframe.type = node.cx.typeType().getDefaultTypeInfo();
        }
        return null;
    }

    public Value evaluate(Context cx, BinaryInterfaceDefinitionNode node)
    {
        return this.evaluate(cx, (BinaryClassDefNode)node);
    }



    private void inheritClassSlots(TypeValue cframe, ObjectValue iframe, TypeValue baseType, Context ctx)
    {
        inheritClassSlotsStatic(cframe, iframe, baseType, ctx);
    }
    static void inheritClassSlotsStatic(TypeValue cframe, ObjectValue iframe, TypeValue baseType, Context ctx)
    {
        TypeValue superType = baseType;
        cframe.baseclass = superType;

        ObjectValue baseobj = baseType.prototype;

        InstanceBuilder basebui = ((superType.prototype.builder instanceof InstanceBuilder) ? (InstanceBuilder)superType.prototype.builder : null);
        InstanceBuilder bui = (InstanceBuilder)(iframe.builder);
        
        bui.canEarlyBind = basebui.canEarlyBind;
        bui.basebui        = basebui;
        bui.var_offset     = basebui.var_offset + baseobj.var_count;
                // ISSUE: this should be zero when the base class is outside the current abc file
        bui.method_offset  = basebui.method_offset + basebui.method_count;

        TypeValue baseclass = cframe.baseclass;
        ClassBuilder classbui = ((cframe.builder instanceof ClassBuilder) ? (ClassBuilder)cframe.builder : null);
        classbui.basebui = (baseclass != null ? (baseclass.builder instanceof ClassBuilder ? (ClassBuilder)baseclass.builder : null) : null);
        if( classbui.basebui != null && classbui.basebui.basebui != null)
        {
            classbui.basebui.is_intrinsic = classbui.basebui.basebui.is_intrinsic;
        }
        
        iframe.addBaseObj(baseobj);

        if( !cframe.isInterface() && !baseType.isInterface() )
        	iframe.setProtectedNamespaces(((ClassBuilder)cframe.builder).protected_namespace, ((ClassBuilder)baseType.builder).protected_namespace);  

/*
        Names names = basebui.getNames();

        if (names != null)
        {
            for (int i = 0; (i = names.hasNext(i)) != -1; i++)
            {
                    String name = names.getName(i);
                    ObjectValue baseNamespace = names.getNamespace(i);
                    ObjectValue ns = baseNamespace;

                if (baseNamespace.isPrivate() && baseNamespace != this.local_file_namespace)
                {
                    // no point in inheriting private members from the base class
                    continue;
                }

                    if (baseNamespace.isProtected())
                    {
                        // Inherit into the protected namespace of this class instead
                        ns = classbui.protected_namespace;
                    }

                switch (names.getType(i))
                {
                    case Names.METHOD_NAMES:
                    {
                    	assert !Builder.removeBuilderNames;
                        // For each method:
                        // Allocate a new method id (matching the base method id)
                        // Create a binding to it
                        if (name.equals("$construct"))
                        {
                            break;  // don't inherit constructors
                        }

                        int base_slot_id = baseobj.getSlotIndex(ctx,GET_TOKEN,name,baseNamespace);
                        int implied_id = baseobj.getImplicitIndex(ctx,base_slot_id,EMPTY_TOKEN);
                        Slot explicitSlot = baseobj.getSlot(ctx,base_slot_id);
                        Slot slot = baseobj.getSlot(ctx,implied_id);

                        bui.InheritCall(ctx, iframe, names.getName(i), ns, explicitSlot, slot);
                        break;
                    }

                    case Names.GET_NAMES:
                    {
                        int slot_id = baseobj.getSlotIndex(ctx,GET_TOKEN,name,baseNamespace);

                        int implicit_id = baseobj.getImplicitIndex(ctx,slot_id,EMPTY_TOKEN);
                        if( implicit_id != slot_id)
                        {
                        	if(!Builder.removeBuilderNames)
                        		break;
                        	// its a getter for a method inherit the call
                        	if (name.equals("$construct"))
                            {
                                break;  // don't inherit constructors
                            }
                        	Slot explicitSlot = baseobj.getSlot(ctx,slot_id);
                        	Slot slot = baseobj.getSlot(ctx,implicit_id);
                            bui.InheritCall(ctx, iframe, name, ns, explicitSlot, slot);
                        }
                        else
                        {
		                    Slot slot = baseobj.getSlot(ctx,slot_id);
		                    if(slot instanceof VariableSlot) {
		                    	bui.InheritVar(ctx, iframe, name, ns, slot);
		                    } else {
		                    	bui.InheritGet(ctx, iframe, name, ns, slot);
		                    }
                        }
                        break;
                    }

                    case Names.SET_NAMES:
                    {
                        int slot_id = baseobj.getSlotIndex(ctx,SET_TOKEN,name,baseNamespace);
                        Slot slot = baseobj.getSlot(ctx,slot_id);
                        bui.InheritSet(ctx, iframe, name, ns, slot);
                        break;
                    }

                    case Names.VAR_NAMES:
                    {
                    	assert !Builder.removeBuilderNames;
                        int slot_id = baseobj.getSlotIndex(ctx,GET_TOKEN,name,baseNamespace);
                        Slot inheritedSlot = baseobj.getSlot(ctx,slot_id);
                        bui.InheritVar(ctx, iframe, name, ns, inheritedSlot);
                        break;
                    }
                }
            }
        }
*/
    }

    public Value evaluate(Context cx, InterfaceDefinitionNode node)
    {
        Value val = this.evaluate(cx, (ClassDefinitionNode) node);
        ReferenceValue ref = ((val instanceof ReferenceValue) ? (ReferenceValue)val : null);
        Slot slot = ref!=null?ref.getSlot(cx):null;
        if( slot == null )
        {
            cx.internalError(node.pos(), "internal error in FA::InterfaceDefinitionNode has no slot");
            return null;
        }
        slot.setImplNode(node);  // use this to validate class definitions during CE
        ((ClassBuilder)node.cframe.builder).is_interface = true;

        // check state == Inheritance before checking.  Don't want to log errors twice
        if (node.attrs != null && node.state == ProgramNode.Inheritance)
        {
            if (node.attrs.hasFinal)
            {
                cx.error(node.pos(),kError_InvalidInterfaceAttribute, "final");
            }
            if (node.attrs.hasDynamic)
            {
                cx.error(node.pos(),kError_InvalidInterfaceAttribute, "dynamic");
            }
            if (node.attrs.hasNative)
            {
                cx.error(node.pos(),kError_InvalidInterfaceAttribute, "native");
            }
            if (node.attrs.hasPrivate)
            {
                cx.error(node.pos(),kError_InvalidInterfaceAttribute, PRIVATE);
            }
            if (node.attrs.hasProtected)
            {
                cx.error(node.pos(),kError_InvalidInterfaceAttribute, PROTECTED);
            }
        }

        return null;
    }

    public Value evaluate(Context cx, ClassNameNode node)
    {
        Value val = null;
        if (node.pkgname != null)
        {
            node.pkgname.evaluate(cx, this);
        }
        if (node.ident != null)
        {
            val = node.ident.evaluate(cx, this);
        }
        return val;
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

    public Value evaluate(Context cx, AttributeListNode node)
    {
        if( node.namespace_ids.size() != 0 || node.namespaces.size() != 0 )
        {
            return null;
        }

        ObjectValue obj = null;
        ReferenceValue ref = null;

        // Use these for keeping track of if we have already seen a given attribute.
        // This is used for error checking (attributes should not appear more than once)
        boolean setPrivate = false;
        boolean setProtected = false;
        boolean setPublic = false;
        boolean setInternal = false;
        boolean setDynamic = false;
        boolean setVirtual = false;
        boolean setFinal = false;
        boolean setOverride = false;
        boolean setStatic = false;
        boolean setNative = false;
        boolean setPrototype = false;

        for (int i = 0, size = node.items.size(); i < size; i++)
        {
            Node n = node.items.get(i);
            if( n != null )
            {
                if( n.hasAttribute(PRIVATE) )
                {
                    if( setPrivate )
                    {
                        cx.error(n.pos(), kError_DuplicateAttribute, PRIVATE);
                    }
                    setPrivate = node.hasPrivate = true;
                }
                else
                if( n.hasAttribute(PROTECTED) )
                {
                    if( setProtected )
                    {
                        cx.error(n.pos(), kError_DuplicateAttribute, PROTECTED);
                    }
                    setProtected = node.hasProtected = true;
                }
                else
                if( n.hasAttribute(PUBLIC) )
                {
                    if( setPublic )
                    {
                        cx.error(n.pos(), kError_DuplicateAttribute, PUBLIC);
                    }
                    setPublic = node.hasPublic = true;
                }
                else
                if( n.hasAttribute(INTERNAL) )
                {
                    if( setInternal )
                    {
                        cx.error(n.pos(), kError_DuplicateAttribute, INTERNAL);
                    }
                    setInternal = node.hasInternal = true;
                }
                else
                {
                    if( n.hasAttribute(PROTOTYPE) )
                    {
                        if( setPrototype )
                        {
                            cx.error(n.pos(), kError_DuplicateAttribute, PROTOTYPE);
                        }
                        setPrototype = node.hasPrototype = true;
                    }

                    rt_unresolved_sets.last().addAll(unresolved);
                    unresolved.clear();

                    Value val1 = n.evaluate(cx,this);

                    ns_unresolved_sets.last().addAll(unresolved);
                    unresolved.clear();

                    ref = ((val1 instanceof ReferenceValue) ? (ReferenceValue)val1 : null);
                    if( ref != null )
                    {
                        Value val2 = ref.getValue(cx);
                        obj = ((val2 instanceof ObjectValue) ? (ObjectValue)val2 : null);
                        if( obj!=null )
                        {
                            if( obj == ObjectValue.intrinsicAttribute ) {
                                node.hasIntrinsic = true;
                                cx.error(n.pos(), kError_Unsupported_Intrinsic);
                            }
                            else
                            if( obj == ObjectValue.staticAttribute ) {
                                if( setStatic )
                                {
                                    cx.error(n.pos(), kError_DuplicateAttribute, STATIC);
                                }
                                setStatic = node.hasStatic = true;
                                if( !(cx.scope().builder instanceof InstanceBuilder) && !(cx.scope().builder instanceof ClassBuilder))
                                {
                                    cx.error(n.pos(), kError_InvalidStatic);
                                }
                            }
                            else
                            if( obj == ObjectValue.dynamicAttribute ) {
                                if( setDynamic )
                                {
                                    cx.error(n.pos(), kError_DuplicateAttribute, "dynamic");
                                }
                                setDynamic = node.hasDynamic = true;
                            }
                            else
                            if( obj == ObjectValue.virtualAttribute ) {
                                if( setVirtual )
                                {
                                    cx.error(n.pos(), kError_DuplicateAttribute, "virtual");
                                }
                                setVirtual = node.hasVirtual = true;   // error if has final too
                                if( !(cx.scope().builder instanceof InstanceBuilder) && !(cx.scope().builder instanceof ClassBuilder) )
                                {
                                    cx.error(n.pos(), kError_InvalidVirtual);
                                }
                            }
                            else
                            if( obj == ObjectValue.finalAttribute ) {
                                if( setFinal )
                                {
                                    cx.error(n.pos(), kError_DuplicateAttribute, "final");
                                }
                                setFinal = node.hasFinal = true;    // error if has virtual too
                            }
                            else
                            if( obj == ObjectValue.overrideAttribute ) {
                                if( setOverride )
                                {
                                    cx.error(n.pos(), kError_DuplicateAttribute, "override");
                                }
                                setOverride = node.hasOverride = true;
                                if( !(cx.scope().builder instanceof InstanceBuilder) && !(cx.scope().builder instanceof ClassBuilder) )
                                {
                                    cx.error(n.pos(), kError_InvalidOverride);
                                }
                            }
                            else
                            if( obj == ObjectValue.nativeAttribute ) {
                                if( setNative )
                                {
                                    cx.error(n.pos(), kError_DuplicateAttribute, "native");
                                }
                                setNative = node.hasNative = true;
                            }
                            else
                            {
                                if( obj != null )
                                {
                                    if( "false".equals(obj.name) )
                                    {
                                        node.hasFalse = true;
                                    }
                                    if( !(cx.scope().builder instanceof ClassBuilder || cx.scope().builder instanceof InstanceBuilder) )
                                    {
                                        cx.error(node.pos(), kError_InvalidNamespace);
                                    }
                                    else
                                    {
                                        node.namespaces.push_back(obj);
                                        node.namespace_ids.push_back(ref.name);
                                    }
                                }
                            }
                        }
                        else
                        {   
                            if( !(cx.scope().builder instanceof ClassBuilder || cx.scope().builder instanceof InstanceBuilder) )
                            {
                                cx.error(node.pos(), kError_InvalidNamespace);
                            }
                            else
                            {
                                node.namespaces.push_back(cx.getUnresolvedNamespace(cx, node, ref));
                                node.namespace_ids.push_back(ref.name);
                            }
                        }
                    }
                    else
                    {
                        cx.error(node.pos(), kError_InvalidAttribute);
                    }
                }
            }
        }

        if (node.namespaces.size() != 0)
        {
            boolean foundUserNamespace = false;
            for (ObjectValue ns : node.namespaces)
            {
                if (!(ns instanceof NamespaceValue))
                {
                    // Error: Not a namespace attribute
                    cx.error(node.pos(), kError_InvalidAttribute);
                }
                else if (!foundUserNamespace)
                {
                    foundUserNamespace = true;
                    node.setUserNamespace(ns);
                }
                else
                {
                    cx.error(node.pos(), kError_MultipleNamespaceAttributes);
                    break;
                }
            }
        }

        // Only one of public, private, protected, internal may be used.
        if (((node.hasPrivate?1:0) + (node.hasPublic?1:0) + (node.hasProtected?1:0) + (node.hasInternal?1:0)) > 1)
        {
            cx.error(node.pos(), kError_ConflictingAccessSpecifiers);
        }

        if (node.hasUserNamespace() && (node.hasPrivate || node.hasPublic || node.hasProtected || node.hasInternal))
        {
               cx.error(node.pos(), kError_NamespaceAccessSpecifiers);
        }

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

    public Value evaluate(Context cx, ImportNode node)
    {
        ObjectValue   baseobj = node.program.frame;

        ObjectValue obj = cx.scope();
        String id = node.filespec.value;
        QName qname = new QName(cx.publicNamespace(), id);
        ImportBuilder bui = new ImportBuilder(qname);

        inheritSlots(baseobj, obj, bui, cx);
        return null;
    }

    public static void inheritSlots(ObjectValue baseobj, ObjectValue obj, Builder bui, Context cx)
    {
        inheritSlots(baseobj, obj, bui, cx, false);
    }

    public static void inheritContextSlots(ObjectValue baseobj, ObjectValue obj, Builder bui, Context cx)
    {
        inheritSlots(baseobj, obj, bui, cx, true);
    }

    public static void inheritSlots(ObjectValue baseobj, ObjectValue obj, Builder bui, Context cx, boolean limitToContext)
    {
        Builder basebui = (baseobj.builder);

        Names names = basebui.getNames();
        if (names != null)
        {
            for (int i = 0; (i = names.hasNext(i)) != -1; i++)
            {
            	String name = names.getName(i);
                ObjectValue namespace = names.getNamespace(i);
                switch (names.getType(i))
                {
                    case Names.METHOD_NAMES:
                    {
                    	assert !Builder.removeBuilderNames;
						int inherited_get_id  = baseobj.getSlotIndex(cx,GET_TOKEN,name,namespace);
                        int inherited_call_id = baseobj.getImplicitIndex(cx,inherited_get_id,EMPTY_TOKEN);
                        Slot inheritedSlot = baseobj.getSlot(cx,inherited_get_id);
                        Slot inheritedCallSlot = baseobj.getSlot(cx,inherited_call_id);

                        bui.InheritCall(cx,obj,name,namespace,inheritedSlot,inheritedCallSlot);
                        break;
                    }

                    case Names.GET_NAMES:
                    {
                        int slot_id = baseobj.getSlotIndex(cx,GET_TOKEN,name,namespace);
                        Slot slot = baseobj.getSlot(cx,slot_id);

                        if(slot == null || (limitToContext && slot.declaredBy != null && slot.declaredBy.builder.contextId != basebui.contextId))
                        	break;

                        int implicit_id = baseobj.getImplicitIndex(cx,slot_id,EMPTY_TOKEN);
                        if(Builder.removeBuilderNames && slot_id != implicit_id && slot instanceof MethodSlot)
                        {
                        	Slot inheritedCallSlot = baseobj.getSlot(cx,implicit_id);
                        	bui.InheritCall(cx,obj,name,namespace,slot,inheritedCallSlot);
                        	break;
                        }

                        if(Builder.removeBuilderNames && slot instanceof VariableSlot)
                        {
                        	// hack propagated from VAR_NAMES case
	                        // Hack
                        	slot.setVarIndex(-1);

	                        int index = slot.implies(cx,EMPTY_TOKEN);
	                        Slot inheritedCallSlot = baseobj.getSlot(cx,index);

	                        index = slot.implies(cx,NEW_TOKEN);
	                        Slot inheritedConstructorSlot = baseobj.getSlot(cx,index);

	                        bui.InheritVar(cx, obj, name, namespace, slot);

	                        if (inheritedCallSlot != null)
	                        {
	                            obj.addSlot(inheritedCallSlot);
	                        }

	                        if (inheritedConstructorSlot != null)
	                        {
	                            obj.addSlot(inheritedConstructorSlot);
	                        }
                        }

                        // skip non-public names, this isn't applied to methods so its down here
                    	if(namespace != cx.publicNamespace())
                        {
                            break;
                        }

                        bui.InheritGet(cx,obj,name,namespace,slot);
                        break;
                    }

                    case Names.SET_NAMES:
                    {
                        // skip non-public names
                    	if(namespace != cx.publicNamespace())
                        {
                            break;
                        }

                        int slot_id = baseobj.getSlotIndex(cx,SET_TOKEN,name,namespace);
                        Slot slot = baseobj.getSlot(cx,slot_id);

                        bui.InheritSet(cx,obj,name,namespace,slot);
                        break;
                    }

                    case Names.VAR_NAMES:
                    {
                    	assert !Builder.removeBuilderNames;
                        int slot_id = baseobj.getSlotIndex(cx,VAR_TOKEN,name,namespace);
                        Slot inheritedSlot = baseobj.getSlot(cx,slot_id);

                        // Hack
                        inheritedSlot.setVarIndex(-1);

                        int index = inheritedSlot.implies(cx,EMPTY_TOKEN);
                        Slot inheritedCallSlot = baseobj.getSlot(cx,index);

                        index = inheritedSlot.implies(cx,NEW_TOKEN);
                        Slot inheritedConstructorSlot = baseobj.getSlot(cx,index);

                        bui.InheritVar(cx, obj, name, namespace, inheritedSlot);

                        if (inheritedCallSlot != null)
                        {
                            obj.addSlot(inheritedCallSlot);
                        }

                        if (inheritedConstructorSlot != null)
                        {
                            obj.addSlot(inheritedConstructorSlot);
                        }
                    }
                }
            }
            /*
			if (obj.baseMethodNames == null)
            {
                obj.baseMethodNames = new Names();
            }
            obj.baseMethodNames.putAll(names, Names.METHOD_NAMES);
            */ 
        }
    }

    public Value evaluate( Context unused_cx, ImportDirectiveNode node )
    {
        Context cx = node.cx;
        if( node.name != null )
        {
            Value val = node.name.evaluate(cx,this);
            ReferenceValue ref = ((val instanceof ReferenceValue) ? (ReferenceValue)val : null);

            if( ref != null)
            {
                if( !( cx.isNamespace(ref.name) && cx.getNamespace(ref.name).isPackage() ) )
                {
                    package_unresolved_sets.last().add(ref);
                }

                String pkg_name = ref.name;
                String def_name = node.name.id.def_part;
                if( def_name.length() > 0 )
                {
                    Multinames importednames;
                    if( node.pkgdef != null && cx.getScopes().size() == 1 )
                    {
                        importednames = node.pkgdef.imported_names;
                    }
                    else
                    {
                        importednames = importednames_sets.back();
                    }

                    Namespaces nss = importednames.get(def_name);

                                    // If there is one, then get the qualifier map for that name.
                                    // Otherwise, create a qualifier map and a new property.

                    if( nss == null )
                    {
                        importednames.put(def_name,new Namespaces());
                    }

                                    // Add the qualifier to the qualifiers map, and set its value to index.

                    Namespaces prop = importednames.get(def_name);
                    if( !prop.contains(cx.getNamespace(pkg_name)) )
                    {
                        prop.push_back(cx.getNamespace(pkg_name));
                        import_def_unresolved_sets.last().add(new ReferenceValue(cx, null, def_name, cx.getNamespace(pkg_name)));
                    }
                }
                else
                {
                    if( node.pkgdef != null && cx.getScopes().size() == 1 )
                    {
                        node.pkgdef.used_namespaces.push_back(cx.getNamespace(pkg_name));
                    }
                    else
                    {
                        usednamespaces_sets.back().push_back(cx.getNamespace(pkg_name));
                    }
                }
            }
            else
            {
                cx.error(node.name.pos(), kError_Unknown_Namespace);
            }
        }
        return null;
    }


    public Value evaluate(Context cx, SuperExpressionNode node)
    {
        switch( this_contexts.last() )
        {
            case global_this:
            case error_this:
                cx.error(node.pos(),kError_InvalidSuperExpression);
                break;
            default:
                // valid use of this
                break;
        }
        if( node.expr != null )
        {
            node.expr.evaluate(cx,this);
        }

        if( super_context.last() == super_statement )
        {
            super_context.set(super_context.size()-1, super_error2);
        }
        return null;
    }

    public Value evaluate(Context cx, SuperStatementNode node)
    {
        switch( super_context.last() )
        {
            case super_statement:
                    int index = cx.getScopes().size()-2;
                    ObjectValue obj = cx.scope(index);
                    InstanceBuilder bui = ((obj.builder instanceof InstanceBuilder) ? (InstanceBuilder)obj.builder : null);
                    if( bui == null) cx.internalError("internal error: super statement outside of instance constructor");
                    else bui.calls_super_ctor = true;

                    if( node.call.args != null )
                    {
                        node.call.args.evaluate(cx,this);
                    }
                    TypeValue type = obj.type.getTypeValue();
                    TypeValue basecls = type.baseclass;
                    if( basecls != null )
                    {
                        node.baseobj = basecls.prototype;
                    }
                    else
                    {
                        node.baseobj = cx.noType().prototype;
                    }
                    super_context.set(super_context.size()-1, super_error2);
                    break;
            case super_error2:
                cx.error(node.pos(),kError_IllegalSuperStatement);
                break;
            case super_error_es4:
            	cx.error(node.pos(), kError_InvalidES4SuperStatement);
            	break;
            case super_error:
            default:
                cx.error(node.pos(),kError_InvalidSuperStatement);
                break;
        }

        return null;
    }

    public Value evaluate( Context cx, ConfigNamespaceDefinitionNode node )
    {
    	// TODO: something to ensure that other definitions don't shadow the 
    	// TODO: config namespace.
    	return null;
    }
    public Value evaluate( Context cx, NamespaceDefinitionNode node )
    {

        // first time we are evaluated, we create a var for the namespace var and possibly mark it as const.
        //  If so, we mark needs_init = true.
        if (node.needs_init /* && doing_method() */)
        {
            // second time we are evaluated from statementList's evaluator in order to add this def to
            //  the block's def_bits.
            getEmitter().AddStmtToBlock(node.toString());
            node.gen_bits = getEmitter().NewDef(node);
            Slot slot = node.ref.getSlot(cx);
            if (slot != null)
                slot.addDefBits(node.gen_bits);

            node.needs_init = false;
            return null;
        }

        if (node.ref != null) { return null; }

        // If this is a toplevel definition (pkgdef!=null), then set up access namespaces

        if( node.attrs != null && node.attrs.hasAttribute(STATIC) )
        {
            cx.error(node.attrs.pos(), kError_StaticModifiedNamespace);
        }

        if( node.pkgdef != null && cx.getScopes().size() == 1 )
        {
            public_namespaces.push_back(node.pkgdef.publicNamespace);
            default_namespaces.push_back(node.pkgdef.internalNamespace);
            usednamespaces_sets.push_back(node.pkgdef.used_namespaces);
            importednames_sets.push_back(node.pkgdef.imported_names);
        }

        ClassBuilder classBuilder = classBuilderOnScopeChain(cx);
        if (classBuilder != null && classBuilder.is_interface)
        {
            cx.error(node.pos(), kError_NamespaceInInterface);
        }
        Namespaces namespaces = new Namespaces();
        ObjectList<String> namespace_ids = new ObjectList<String>();
        computeNamespaces(cx,node.attrs,namespaces,namespace_ids);

        Value v = node.name.evaluate(cx,this);
        node.ref = ((v instanceof ReferenceValue) ? (ReferenceValue)v : null);

        // Get the current object and its builder

        ObjectValue obj = cx.scope();
        Builder     bui = obj.builder;

        boolean is_intrinsic = false;

        int slot_id = -1;

        Namespaces hasNamespaces = obj.hasNames(cx,GET_TOKEN,node.ref.name,namespaces);
        if( hasNamespaces != null )
        {
            cx.error(node.pos(), kError_DuplicateNamespaceDefinition);
        }
        else
        {
            if( bui.is_intrinsic || is_intrinsic )
            {
                slot_id = bui.ExplicitVar(cx,obj,node.ref.name,namespaces,cx.noType(),-1);
            }
            else
            {
                int var_id;
                var_id  = bui.Variable(cx,obj);
                slot_id = bui.ExplicitVar(cx,obj,node.ref.name,namespaces,cx.noType(),-1,-1,var_id);
            }
        }


        node.debug_name = region_name_stack.back();
        // store debug name on the slot as well.  asDoc needs fully qualified debug_names for all
        //  type references.
        Slot s = obj.getSlot(cx,slot_id);
        if (s != null)
        {
            s.setDebugName(node.debug_name);
        }

        node.qualifiedname = cx.computeQualifiedName(node.debug_name, node.ref.name, namespaces.back(), EMPTY_TOKEN);

        if( !is_intrinsic && slot_id >= 0 )
        {
            Slot slot = obj.getSlot(cx,slot_id);
            if( node.value != null )
            {
                if( node.value instanceof LiteralStringNode )
                {
		    // NOTE we distinguish between package public (NS_PUBLIC) and explicit namespaces (NS_EXPLICIT)
		    // so that we know which builtin namespaces to mark with a version marker
		    slot.setObjectValue(cx.getNamespace(((LiteralStringNode)node.value).value, Context.NS_EXPLICIT));
                }
                else
                {
                    Value val= node.value.evaluate(cx, this);
                    if( val instanceof ReferenceValue )
                    {
                        Slot ns_slot = ((ReferenceValue)val).getSlot(cx);
                        if( ns_slot != null && cx.isNamespace(ns_slot.getObjectValue()) )
                        {
                            slot.setObjectValue(ns_slot.getObjectValue() );
                        }
                    }
                }
            }
            else
            {
                String name = cx.debugName(region_name_stack.back(),node.ref.name,namespace_ids,EMPTY_TOKEN);
                ObjectValue ns = cx.getNamespace(name.intern(),Context.NS_INTERNAL);
                slot.setObjectValue(ns);
            }
            // must set slot to const before we can get its ObjectValue.  VariableSlots only return ObjectValues
            //  when they are const.
            slot.setConst(true);
            if( slot.getObjectValue() == null )
            {
                cx.error(node.value.pos(), kError_InvalidNamespaceInitializer);
            }

            node.needs_init = true; // need to re-evaluate to get this definition into the def_bits for the block
        }

        if( node.pkgdef != null && cx.getScopes().size() == 1 )
        {
            public_namespaces.pop_back();
            default_namespaces.pop_back();
            usednamespaces_sets.pop_back();
            importednames_sets.pop_back();
        }

        return null;
    }

    public Value evaluate( Context  cx, UseDirectiveNode node )
    {
        if (node.ref != null) { return null; }

        if( node.pkgdef != null && cx.getScopes().size() == 1 )
        {
            public_namespaces.push_back(node.pkgdef.publicNamespace);
            default_namespaces.push_back(node.pkgdef.internalNamespace);
            usednamespaces_sets.push_back(node.pkgdef.used_namespaces);
            importednames_sets.push_back(node.pkgdef.imported_names);
        }

        ObjectValue obj = null;

        if( node.expr != null )
        {
            rt_unresolved_sets.last().addAll(unresolved);
            unresolved.clear();

            node.ref = (ReferenceValue)node.expr.evaluate(cx,this);
            Value value = node.ref.getValue(cx);
            obj = ((value instanceof ObjectValue) ? (ObjectValue) value : null);

            ns_unresolved_sets.last().addAll(unresolved);
            unresolved.clear();
        }

        if( obj != null )
        {
            if( node.pkgdef != null && cx.getScopes().size() == 1 )
            {
                node.pkgdef.used_namespaces.push_back(obj);
            }
            else
            {
                usednamespaces_sets.back().push_back(obj);
            }
        }
        else
        {
            ObjectValue surrogate = cx.getUnresolvedNamespace(cx, node, node.ref);
            if( node.pkgdef != null && cx.getScopes().size() == 1 )
            {
                node.pkgdef.used_namespaces.push_back(surrogate);
            }
            else
            {
                usednamespaces_sets.back().push_back(surrogate);
            }
        }

        if( node.pkgdef != null && cx.getScopes().size() == 1 )
        {
            public_namespaces.pop_back();
            default_namespaces.pop_back();
            usednamespaces_sets.pop_back();
            importednames_sets.pop_back();
        }

        return null;
    }

    public Value evaluate(Context cx, RestExpressionNode node)
    {
        cx.internalError(node.pos(), "RestExpressionNode not yet implemented");
        return null;
    }

    public Value evaluate(Context cx, ErrorNode node)
    {
    	if (!errorNodeSeen)
    	{
    		errorNodeSeen = true;
    		cx.error(node.pos(), node.errorCode, node.errorArg);
    	}
        return null;
    }

    public Value evaluate(Context cx, PragmaNode node)
    {
        if (debug)
        {
            System.out.print("\n// +PragmaNode");
        }
        if (node.list != null)
        	node.list.evaluate(cx, this);

        if (debug)
        {
            System.out.print("\n// -PragmaNode");
        }
        return null;
     }

    public Value evaluate(Context cx, UsePrecisionNode node)
    {
        if (debug)
        {
            System.out.print("\n// +UsePrecisionNode");
        }
        NumberUsage currentParams = number_usage_stack.last();
        if ((1 <= node.precision) && (node.precision <= 34)) {
        		currentParams.set_precision(node.precision);
        }
        else {
        	cx.error(node.pos(), kError_InvalidPrecision);
        }
        if (debug)
        {
            System.out.print("\n// -UsePrecisionNode");
        }
        return null;
    }

    public Value evaluate(Context cx, UseNumericNode node)
    {
        if (debug)
        {
            System.out.print("\n// +UseNumericNode");
        }
        NumberUsage currentParams = number_usage_stack.last();
        currentParams.set_usage(node.numeric_mode);
        if (debug)
        {
            System.out.print("\n// -UseNumericNode");
        }
        return null;
    }

    public Value evaluate(Context cx, UseRoundingNode node)
    {
        if (debug)
        {
            System.out.print("\n// +UseRoundingNode");
        }
        NumberUsage currentParams = number_usage_stack.last();
        currentParams.set_rounding(node.mode);
        
        if (debug)
        {
            System.out.print("\n// -UseRoundingNode");
        }
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

    public Value evaluate(Context cx, ParenListExpressionNode node)
    {
        cx.internalError(node.pos(), "ParenListExpressionNode not yet implemented");
        return null;
    }

    public Value evaluate(Context cx, ParenExpressionNode node)
    {
        cx.internalError(node.pos(), "ParenExpressionNode not yet implemented");
        return null;
    }

    public Value evaluate(Context cx, LiteralXMLNode node)
    {
        if (debug)
        {
            System.out.print("\n// +LiteralXML");
        }

        if (node.list != null)
        {
            node.list.evaluate(cx, this);
        }
        getEmitter().AddStmtToBlock(node.toString());

        if (debug)
        {
            System.out.print("\n// -LiteralXML");
        }
        return null;
    }

    public Value evaluate(Context cx, MetaDataNode node)
    {
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
            node.expr.evaluate(cx,this);
        }
        return null;
    }

    public Value evaluate(Context cx, DocCommentNode node)
    {
        // do nothing
        return null;
    }

    private ClassBuilder classBuilderOnScopeChain(Context cx)
    {
        for (int i = cx.getScopes().size(); --i >= 0; )
        {
            Builder bui = cx.scope(i).builder;
            if (bui instanceof ClassBuilder)
            {
                return (ClassBuilder)bui;
            }
        }
        return null;
    }

    /* This method works its way up the scope chain and determines if any of the
     * scope builders going up to the global scope are instances of ClassBuilder
     * Useful when determining if we are currently, or at any previous point,
     * within a class definition, due to nesting.
     */
    private <T extends Builder>
        boolean currentScopeChainContainsBuilder
                    (Class<T> builder, Context cx, int startingScopeDepth)
    {
        if(startingScopeDepth < 0) return false;

        return (builder.isInstance(cx.scope(startingScopeDepth).builder)
                || currentScopeChainContainsBuilder(builder, cx,startingScopeDepth-1));
    }

    private void processInterfacePublicMethods(Context cx, ObjectValue iframe)
    {
        // The interface method names map says which interface public methods are out there.
        // For each interface public method:
        // - Do we have a public method by that name in this class?
        // - If so, take the list of interfaces that have that method name
        // - Scan the class, removing interfaces that actually were implemented
        // - Now add slots pointing to the public method for the remaining namespaces
        InstanceBuilder ibui = (InstanceBuilder)iframe.builder;

        if (interfaceMethods == null)
        {
            return;
        }

        for (int i = 0; (i = interfaceMethods.hasNext(i)) != -1; i++)
        {
            String name = interfaceMethods.getName(i);
            int type = interfaceMethods.getType(i);
            ObjectValue interfaceNamespace = interfaceMethods.getNamespace(i);

            int kind = EMPTY_TOKEN;
            if (type == Names.GET_NAMES)
            {
                kind = GET_TOKEN;
            }
            else if (type == Names.SET_NAMES)
            {
                kind = SET_TOKEN;
            }

            int slot_id = iframe.getSlotIndex(cx, (kind == EMPTY_TOKEN) ? GET_TOKEN : kind, name, cx.publicNamespace());

            if (slot_id <= 0)
            {
                continue;
            }

            int implied_id = iframe.getImplicitIndex(cx,slot_id,EMPTY_TOKEN);

            //Names names = ibui.getNames();
            if (ibui.objectValue.hasName(cx, kind, name, interfaceNamespace))
            {
                continue;
            }

            switch (interfaceMethods.getType(i))
            {
            case Names.GET_NAMES:
                iframe.defineName(cx, GET_TOKEN, name, interfaceNamespace, slot_id);
                ibui.Name(cx, GET_TOKEN, name, interfaceNamespace);
                break;

            case Names.SET_NAMES:
                iframe.defineName(cx, SET_TOKEN, name, interfaceNamespace, slot_id);
                ibui.Name(cx, SET_TOKEN, name, interfaceNamespace);
                break;

            case Names.METHOD_NAMES:
            	assert !Builder.removeBuilderNames;
                iframe.defineName(cx, GET_TOKEN, name, interfaceNamespace, slot_id);
                ibui.Name(cx, GET_TOKEN, name, interfaceNamespace);

                iframe.defineName(cx, EMPTY_TOKEN, name, interfaceNamespace, implied_id);
                ibui.Name(cx, EMPTY_TOKEN, name, interfaceNamespace);
                break;
            }
        }
    }

    private void scanInterfaceMethods(Context cx, ClassDefinitionNode node)
    {
        ObjectValue iframe = node.iframe;

        InterfaceWalker interfaceWalker = new InterfaceWalker(iframe);

        if (interfaceWalker.hasNext())
        {
            interfaceMethods = new Names();
        }

        while (interfaceWalker.hasNext())
        {
            ObjectValue interfaceIFrame = interfaceWalker.next();
            TypeValue interfaceCFrame = interfaceIFrame.type.getTypeValue();

            // Add interface to used definition namespaces for this class.
            // (Otherwise, hasNamespaces will not find interface qualifiers.)
            node.used_def_namespaces.push_back(interfaceCFrame);

            InstanceBuilder interfaceBuilder = (InstanceBuilder)interfaceIFrame.builder;

            // Copy any public names into iframe's interfaceMethodNames table
            Names names = interfaceBuilder.getNames();
            if (names != null)
            {
                for (int i = 0; (i = names.hasNext(i)) != -1; i++)
                {
                    if (names.getNamespace(i).compareTo(interfaceCFrame) != 0)
                    {
                        // public auto-magic only happens on methods in the interface
                        // namespace
                        continue;
                    }

                    String name = names.getName(i);

                    if(Builder.removeBuilderNames)
                    {
                    	assert names.getType(i) != Names.METHOD_NAMES;
                        interfaceMethods.put(name, interfaceCFrame, names.getType(i), 0);
                    }
                    else
                    {	                  
	                    switch (names.getType(i))
	                    {
	                    case Names.METHOD_NAMES:
	                        if (!name.equals("$construct"))
	                        {
	                            interfaceMethods.put(name, interfaceCFrame, Names.METHOD_NAMES, 0);
	                        }
	                        break;
	                    case Names.GET_NAMES:
	                        if (!names.containsKey(name, Names.METHOD_NAMES))
	                        {
	                            interfaceMethods.put(name, interfaceCFrame, Names.GET_NAMES, 0);
	                        }
	                        break;
	                    case Names.SET_NAMES:
	                        interfaceMethods.put(name, interfaceCFrame, Names.SET_NAMES, 0);
	                        break;
	                    }
                    }
                }
            }
        }
    }

    // While brute force slow, this method is only used when reporting an error for a conflicting definition
    String getFullNameForInheritedSlot(Context cx, ObjectValue declaredBy, String name)
    {
        String fullname = name;

        fullname = declaredBy.type.getTypeValue().name.toString();
        fullname += ".";
        fullname += name;
        /*
        // find slot for original definition
        while(inheritedSlot.inheritedSlot != null)
            inheritedSlot = inheritedSlot.inheritedSlot;

        // walk up scope chain looking for class cframes
        for(int x=cx.getScopes.size()-1; x > -1; --x)
        {
            TypeValue classType = (cx.scope(x) instanceof TypeValue) ? (TypeValue)(cx.scope(x)) : null;
            if (classType != null)
            {
                // now that we've found a class type in the scope, walk it's prototype's slots
                //  looking for the original definition
                ObjectValue decl_obj = classType.prototype;
                Slots slots = decl_obj.slots;
                Iterator<Slot> it = slots.iterator();

                for (int y = slots.size()-1; y > -1 && it.hasNext(); --y)
                {
                    Slot slot = it.next();
                    if (slot == inheritedSlot)
                    {
                        fullname = decl_obj.type.name.toString();
                        fullname += ".";
                        fullname += name;
                        y = 0;
                        x = 0;
                    }
                }
            }
        }
        */
        return fullname;
    }


    private boolean namespacesContains(Context cx, Namespaces outer, Namespaces inner)
    {
        HashSet<ObjectValue> set = new HashSet<ObjectValue>();
        for (ObjectValue ns : outer)
        {
            set.add(ns);
        }
        for (ObjectValue ns : inner)
        {
            if (!set.contains(ns))
            {
                   return false;
            }
        }

        return true;
    }

    private void adjustProtectedNamespace(Context cx, ReferenceValue ref)
    {
        if (ref != null)
        {
            ClassBuilder classBuilder = classBuilderOnScopeChain(cx);
            if (classBuilder != null && classBuilder.basebui != null)
            {
                Namespaces namespaces = ref.getImmutableNamespaces();
                if (namespaces.contains(classBuilder.protected_namespace))
                {
                    namespaces = new Namespaces(namespaces);
                    namespaces.remove(classBuilder.protected_namespace);
                    namespaces.add(classBuilder.basebui.protected_namespace);
                    ref.setImmutableNamespaces(cx.statics.internNamespaces.intern(namespaces));
                }
            }
        }
    }

    private ObjectValue getVariableDefinitionScope(Context cx)
    {
        for (int i=cx.getScopes().size(); --i >= 0; )
        {
            ObjectValue scope = cx.scope(i);
            if (scope.builder.hasRegisterOffset())
            {
                return scope;
            }
        }
        return null;
    }

    public Value evaluate(Context cx, TypeExpressionNode node)
    {
        Value v = node.expr.evaluate(cx, this);
        if( v instanceof ReferenceValue )
        {
            ((ReferenceValue)v).setNullableAnnotation(node.nullable_annotation, node.is_nullable);
        }
        return v;
    }
}
