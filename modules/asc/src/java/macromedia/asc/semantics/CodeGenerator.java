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

import macromedia.asc.embedding.avmplus.ActivationBuilder;
import macromedia.asc.embedding.avmplus.CatchBuilder;
import macromedia.asc.embedding.avmplus.ClassBuilder;
import macromedia.asc.embedding.avmplus.Features;
import macromedia.asc.embedding.avmplus.FunctionBuilder;
import macromedia.asc.embedding.avmplus.InstanceBuilder;
import macromedia.asc.embedding.avmplus.WithBuilder;
import macromedia.asc.embedding.ErrorConstants;
import macromedia.asc.parser.*;
import macromedia.asc.util.Context;
import macromedia.asc.util.Namespaces;
import macromedia.asc.util.ObjectList;
import macromedia.asc.util.NumberConstant;
import macromedia.asc.util.IntNumberConstant;
import macromedia.asc.util.UintNumberConstant;
import macromedia.asc.util.DoubleNumberConstant;
import macromedia.asc.util.DecimalNumberConstant;
import macromedia.asc.util.Decimal128;


import java.util.ListIterator;
import java.io.File;

import static macromedia.asc.embedding.avmplus.RuntimeConstants.*;
import static macromedia.asc.semantics.Slot.*;
import static macromedia.asc.parser.Tokens.*;

public final class CodeGenerator extends Emitter implements Evaluator, ErrorConstants
{
    private boolean traverse_argslist_right_to_left;
    private boolean traverse_binop_right_to_left;
    private boolean c_call_sequence;
    private ObjectList<ObjectList<Node>> case_exprs = new ObjectList<ObjectList<Node>>();

    class StackFrame
    {
        int     catchIndex          = 0;
        int     firstInnerScope     = -1;
        int     registerScopeIndex  = -1;
        boolean withThis            = false;
        boolean activationIsExposed = false;
        int     maxTemps            = 0;
        int     maxParams           = 0;
        int     maxLocals           = 0;
        String  functionName        = null;
        int     needsArguments      = 0;
    }
    private StackFrame frame = null;
    private ObjectList<StackFrame> frames = new ObjectList<StackFrame>();

    class ExceptionState
    {
        boolean finallyPresent = false;         // Whether this try block has a finally clause
        boolean anyFinallyPresent = false;      // Whether any encompassing try block has a finally clause
        boolean insideFinally = false;
        boolean ignoreThrows = false;
    }

    private ExceptionState exceptionState = null;

    private ClassDefinitionNode currentClass;

    private ObjectList<Namespaces> used_namespaces_sets = new ObjectList<Namespaces>();

    private int temp_cv_reg = -1;
    private boolean in_with = false;
    private boolean in_anonymous_function = false;
    private boolean is_ctor = false;
    private boolean in_typeof = false;    // must use non-strict findProperty mode in MemberExpressionNode
    public boolean emitScriptNames = false;

    public void pushStackFrame()
    {
        if (frame != null) frames.push_back(frame);
        frame = new StackFrame();
    }

    void popStackFrame()
    {
        frame = frames.back();
        frames.pop_back();
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
        traverse_argslist_right_to_left = b;
    }

    public CodeGenerator(Emitter emitter)
    {
        super(emitter);
        traverse_argslist_right_to_left = false;
        traverse_binop_right_to_left = false;
        c_call_sequence = false;
        currentClass = null;
    }


    static final boolean debug = false;

    // Expression evaluators

    public Value evaluate(Context cx, QualifiedIdentifierNode node)
    {
        if (debug)
        {
            System.out.print("\n// +QualifiedIdentifierNode");
        }

        if( node.qualifier != null )
        {
            node.qualifier.evaluate(cx,this);
            CheckType(new QName(cx.publicNamespace(), "Namespace"));
        }

        if (debug)
        {
            System.out.print("\n// -QualifiedIdentifierNode");
        }
        return null;
    }

    public Value evaluate(Context cx, QualifiedExpressionNode node)
    {
        if (debug)
        {
            System.out.print("\n// +QualifiedExpressionNode");
        }

        if( node.qualifier != null && node.nss == null )    // node.nss == null means static namespace qualifier
        {
            node.qualifier.evaluate(cx,this);
            CheckType(new QName(cx.publicNamespace(), "Namespace"));
        }

        if (debug)
        {
            System.out.print("\n// -QualifiedExpressionNode");
        }
        return null;
    }

    public Value evaluate(Context cx, ThisExpressionNode node)
    {
        if (debug)
        {
            System.out.print("\n// +ThisExpressionNode");
        }

        if (cx.getScopes().size() == 1)
        {
            GetGlobalScope();
        }
        else
        {
            LoadThis();   // reg 1 always holds 'this'
        }

        if (debug)
        {
            System.out.print("\n// -ThisExpressionNode");
        }
        return null;
    }

    public Value evaluate(Context cx, LiteralBooleanNode node)
    {
        if (debug)
        {
            System.out.print("\n// +LiteralBoolean");
        }

        if (!node.void_result)
        {
            PushBoolean(node.value);
        }

        if (debug)
        {
            System.out.print("\n// -LiteralBoolean");
        }
        return null;
    }

    public Value evaluate(Context cx, LiteralNullNode node)
    {
        if (debug)
        {
            System.out.print("\n// +LiteralNull");
        }

        if (!node.void_result)
        {
            PushNull();
        }

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

        if (!node.void_result)
        {
            PushNumber(node.numericValue, node.type.getTypeId());
        }

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

        if (!node.void_result)
        {
            PushString(node.value);
        }

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

        if( !node.void_result )
        {
            Namespaces namespaces = new Namespaces();
            namespaces.add(cx.publicNamespace());

            FindProperty("RegExp",namespaces,true/*is_strict*/,true/*is_qualified*/,false/*is_attr*/);
            GetProperty("RegExp",namespaces,true/*is_qualified*/,false/*is_super*/,false/*is_attr*/);
            int endIndex = node.value.lastIndexOf("/");
            int length = node.value.length();
            if (endIndex > 0 && endIndex < length-1) // if there were options after the terminator
            {
                // parser has already validated that the flag(s) are valid (i.e. are made up of
                //  at most one occurance of the characters g i m
                PushString( node.value.substring(1,endIndex) ); // skip over '/' sentinals
                PushString( node.value.substring(endIndex+1,length));
                InvokeClosure(true,2);
            }
            else
            {
                PushString( node.value.substring(1,length-1)); // skip over '/' sentinals
                InvokeClosure(true,1);
            }
        }

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

        if (node.fieldlist != null)
        {
            node.fieldlist.evaluate(cx, this);
        }

        NewObject(node.fieldlist != null ? node.fieldlist.size() : 0);

        if (node.void_result)
        {
            Pop();
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

        if (node.ref != null)
        {
            PushString(node.ref.name);
        }
        else
        {
            node.name.evaluate(cx, this);
            ToString();
        }

        node.value.evaluate(cx, this);

        if (debug)
        {
            System.out.print("\n// -LiteralField");
        }
        return null;

    }

    public Value evaluate(Context cx, LiteralArrayNode node)
    {
        if (debug)
        {
            System.out.print("\n// +LiteralArray");
        }

        int size = node.elementlist != null ? node.elementlist.size() : 0;
        if (c_call_sequence)
        {
            if (node.elementlist != null)
            {
                node.elementlist.evaluate(cx, this);
            }
            PushNull();
        }
        else
        {
            if (node.elementlist != null)
            {
                node.elementlist.evaluate(cx, this);
            }
        }
        NewArray(size);

        if (node.void_result)
        {
            Pop();
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
        
        FindProperty("Vector", new Namespaces(cx.getNamespace("__AS3__.vec")), true/*is_strict*/, false /*is_qualified*/, false /*is_attribute*/);
        node.type.evaluate(cx, this);

        int n_elements = (null == node.elementlist)? 0:node.elementlist.size();
        
        PushNumber(new IntNumberConstant(n_elements), cx.intType().getTypeId());
        InvokeClosure(true /* construct */,1);
        
        if (node.elementlist != null)
        {
        	Namespaces elements_nss  = new Namespaces();
        	elements_nss.add(cx.publicNamespace());
        	
        	for (int i = 0, size = node.elementlist.items.size(); i < size; i++)
            {
    	        Node item = node.elementlist.items.get(i);
    	        //  Keep the new Vector on the stack
    	        Dup();
    	        
    	        //  Push the index
    	        PushNumber(new IntNumberConstant(i), cx.intType().getTypeId());
    	        
    	        //  Push the value
                item.evaluate(cx, this);
                
                //  setproperty with null operand => use indexed access
                SetProperty(false, false, false, elements_nss, false);
            }
        }

        if (node.void_result)
        {
            Pop();
        }

        if (debug)
        {
            System.out.print("\n// -LiteralVector");
        }
        return null;
    }

    public Value evaluate(Context cx, EmptyElementNode node)
    {
        if (debug)
        {
            System.out.print("\n// +EmptyElement");
        }
        PushUndefined();
        if (debug)
        {
            System.out.print("\n// +EmptyElement");
        }
        return null;
    }

    private boolean isLocalScope(Context cx, int index)
    {
        return index >= 0 && index >= frame.firstInnerScope && cx.scope(index).builder instanceof ActivationBuilder;
    }

    public Value evaluate(Context cx, MemberExpressionNode node)
    {
        if (debug)
        {
            System.out.print("\n// +MemberExpression");
        }

        // Generate code to load the base object onto the stack.

        int base_index = node.ref != null ? node.ref.getScopeIndex(node.ref.getKind()) : -1;

        // This is an alias to node.<selector>.ref, so the
        // evaluator for node.<selector> has access to the
        // same info
        Slot slot = node.ref != null ? node.ref.getSlot(cx, node.selector instanceof SetExpressionNode ? SET_TOKEN : GET_TOKEN) : null;

        int scope_depth = cx.getScopes().size() - 1;

        if (node.base != null)
        {
            boolean old_in_typeof = this.in_typeof;
            this.in_typeof = false;  // typeof requires a non-strict FindProperty mode for the leaf property, but not for any  base properties

            // If there is a base expression: evaluate it,
            // get its value, and convert it to an object.
            node.base.evaluate(cx, this);
            node.selector.setSuper((node.base instanceof SuperExpressionNode));
            node.selector.setThis((node.base instanceof ThisExpressionNode));
            if (node.ref != null)       
            {
                node.ref.setScopeIndex(-2);  // -2 means there is a base reference
            }
            this.in_typeof = old_in_typeof;
        }
        else
        if (slot != null && isClassInitializerReference(cx, slot.getValue()))
        {
            // Special case for $cinit functions that reference the class
            // being initialized.  See bug #113887.
        }
        else if( base_index == 0 && (node.selector.isCallExpression() || node.selector.isApplyTypeExpression()))
        {
            // Find globals in case they are imported
            boolean is_qualified = node.selector.isQualified();
            boolean is_attribute = node.selector.isAttributeIdentifier();
            boolean is_strict = !node.selector.isSetExpression() && !node.selector.isDeleteExpression() && !this.in_typeof;
            FindProperty(node.ref.name,node.ref.getImmutableNamespaces(),is_strict,node.ref.isQualified(),is_attribute);
        }
        else if (base_index == 0 || isLocalScope(cx, base_index))
        {
            // Do nothing. This is a global or local variable
            // and does not need a base object on the stack.
        }
        else
        {
            // Otherwise, the base index is less than zero and
            // we need to generate code to get the base object.
            // Implementations that do not
            // support nested scopes can implement LookupBaseObject by
            // assuming that the only scope with dynamic definitions is the
            // global scope, hence always pushing the global object.

            // lexical get throws error when symbol not found, set does not.
            boolean is_strict = !node.selector.isSetExpression() &&
                                !node.selector.isDeleteExpression() &&
                                !this.in_typeof;
            if( node.ref != null )
            {
                boolean is_attribute = node.selector.isAttributeIdentifier();
                if( cx.abcVersion(Features.TARGET_AVM2) && doingClass()
                		&&  base_index == scope_depth-1
                		&& cx.scope(base_index).builder instanceof InstanceBuilder 
                		&& slot != null && slot.declaredBy == cx.scope(base_index) )
                	// Use LoadThis if we know that we're accessing a property declared in the
                	// class we're compiling.  This is smaller than using FindProperty.
                	LoadThis();
                else
                	FindProperty(node.ref.name, node.ref.getImmutableNamespaces(), is_strict, node.ref.isQualified(), is_attribute);
            }
            else
            if( node.selector.getIdentifier() != null ) // must be a qualified identifier
            {
                node.selector.expr.evaluate(cx,this);  // if it is qualified, then eval the qualifier

                IdentifierNode ident = node.selector.getIdentifier();
                QualifiedExpressionNode qen = ( ident instanceof QualifiedExpressionNode) ? (QualifiedExpressionNode) ident : null;
                boolean is_attribute = node.selector.isAttributeIdentifier();
                if( qen != null )
                {
                    qen.expr.evaluate(cx,this);
                    if( qen.nss != null )
                    {
                        FindProperty(false,is_attribute,false,qen.nss);
                    }
                    else
                    if( qen.qualifier != null )
                    {
                        ToString();
                        FindProperty(true/*is_strict*/, is_attribute, true /*is_qualified*/, null/*namespaces*/);
                    }
                }
                else
                {
                    if (node.selector.isQualified())
                    {
                        // Runtime-qualified name
                        FindProperty(ident.name,true/*is_strict*/,is_attribute);
                    }
                    else
                    {
                        // Qualify with our currently open namespaces
                        FindProperty(ident.name,used_namespaces_sets.back(),true/*is_strict*/,false/*is_qualified*/,is_attribute);
                    }
                }



            }
            // Otherwise, do the search when we do the selector
        }

        // Generate code to select and invoke the slot.
        node.selector.evaluate(cx, this);

        if (debug)
        {
            System.out.print("\n// -MemberExpression");
        }
        return null;
    }

    // The flag activation_is_exposed is used to indicate when a scope object
    // is accessible from outside the body of the function that activates it.
    // This happens when one of the following occurs: a nested function is called
    // directly; a nested function is passed (by assignment or as an argument)
    // outside the body of the function; or a nested function is returned from
    // the body of the function. When this is flag is true, the activation
    // object must reflect the current state of the local variables, at the point
    // that control leave the body of the function. Only update closure when
    // there are nested functions defined.

    /*
     * The general mechanism for calling a function is to get the function object,
     * then get the this object, push the arguments, and finally call the
     * InvokeClosure emitter.
     *
     * If the function object is known at compile-time, then the function can be
     * called by getting the function's environment (scope chain), the this object,
     * pusing the arguments, and calling InvokeMethod with the function's call or
     * construct method id.
     *
     * If it is a method being called, then we can push the sequence of values
     * described by the call sequence and call InvokeMethod with the method id.
     */

    /*

     Call ops:

     InvokeClosure           OP_call = 0x41,
     InvokeMethod            OP_callmethod = 0x43,
     InvokeMethod static     OP_callstatic = 0x44,
     CallProperty            OP_callproperty = 0x46,
     CallProperty lexical    OP_callproplex = 0x4C

     Call sequences:

     what gets pushed on the stack during callexpr evaluation

     { args, thisargs, envthisargs }

     Dispatch kinds:

     how the method gets called

     { callprop, callproplex, constructprop, callfinal, callclosure, constructclosure }

     proplex can be optimized to prop when the call is monomorphic

     This kinds:

     where this comes from, if we need it

     { global, scope, stack, reg }



     Call scenarios:

     non-property (rvalue)
     (function() {})()
     GetScope 0
     InvokeMethod static
     call_seq  = CALL_ThisArgs
     disp_kind = DISP_Final
     this_kind = THIS_Global

     non-property (monomorphic local)
     f()  // bound to local const var, const parameter or function
     LoadRegister n
     GetScope 0
     InvokeMethod static
     call_seq  = CALL_ThisArgs
     disp_kind = DISP_Final
     this_kind = THIS_Global

     non-property (polymorphic local)
     f()  // bound to local var, parameter or function
     LoadRegister n
     GetScope 0
     InvokeClosure
     call_seq  = CALL_EnvThisArgs
     disp_kind = DISP_Closure
     this_kind = THIS_Global

     bound lexical ref (monomorphic)
     f()
     GetScope n  (function closure n = 0)
     InvokeMethod static
     call_seq  = CALL_ThisArgs
     disp_kind = DISP_Final
     this_kind = THIS_Global

     bound lexical ref (polymorphic method || function closure, base obj = this obj || base obj != this obj)
     f()
     FindProperty
     CallProperty lexical
     call_seq  = CALL_Args
     disp_kind = DISP_PropLex
     this_kind = unused

     bound lexical ref (monomorphic global local)
     f()
     GetScope 0
     InvokeMethod static
     call_seq  = CALL_ThisArgs
     disp_kind = DISP_Final
     this_kind = THIS_Global

     bound lexical ref (imported, base obj = this obj)
     f()
     FindProperty
     CallProperty
     call_seq  = CALL_Args
     disp_kind = DISP_PropLex
     this_kind = n/a

     bound dot ref (monomorphic file internal)
     A.f()
     o.f()   // o is known, f is final
     get o
     InvokeMethod static
     call_seq  = CALL_ThisArgs
     disp_kind = DISP_Prop
     this_kind = THIS_Base

     bound dot ref (polymorphic file external)
     o.f()   // super type of o is known, f is not final
     get o
     CallProperty
     call_seq  = CALL_ThisArgs
     disp_kind = DISP_Prop
     this_kind = THIS_Base

     unbound lexical ref (base obj == this obj or base obj != this obj)
     f()
     FindProperty (find global prop)
     CallProperty lexical
     call_seq  = CALL_Args
     disp_kind = DISP_PropLex
     this_kind = n/a

     unbound bracket ref
     o["f"]()
     get o
     get f
     get o
     InvokeClosure
     call_seq  = CALL_EnvThisArgs
     disp_kind = DISP_PropLex
     this_kind = THIS_Base

     unbound dot ref
     o.f()
     get o
     CallProperty
     call_seq  = CALL_Args
     disp_kind = DISP_Prop
     this_kind = n/a

     */

    public Value evaluate( Context cx, CallExpressionNode node )
    {
        if( debug ) System.out.print("\n// +CallExpression");

        int slot_kind = node.is_new?NEW_TOKEN:EMPTY_TOKEN;
        int disp_kind = DISP_undefined;
        int call_seq  = CALL_Closure; // default
        int this_kind = THIS_undefined;

        String method_name = "";

        boolean is_super = node.isSuper();
        boolean is_qualified = node.isQualified();
        boolean is_attribute = node.isAttributeIdentifier();

        Slot slot;
        TypeInfo expr_type=null;
        int  base_index=-1;
        int  scope_depth = cx.getScopes().size()-1;

        Builder basebui;

        boolean is_localref = false;


        if( node.ref == null )
        {
            if (node.is_new)
            {
                call_seq  = CALL_EnvThisArgs;
                disp_kind = DISP_ConstructClosure;
                this_kind = THIS_None;
            }
            else
            if( node.isRvalue() )
            {
                call_seq  = CALL_EnvThisArgs;
                disp_kind = DISP_CallClosure;
                this_kind = THIS_Global;
            }
            else
            {
                call_seq  = CALL_EnvThisArgs;
                disp_kind = DISP_CallClosure;
                this_kind = THIS_Base;
            }
        }
        else
        {
            slot                 = node.ref.getSlot(cx,GET_TOKEN);
            expr_type            = node.ref.getType(cx);
            base_index           = node.ref.getScopeIndex(GET_TOKEN);

            basebui              = base_index >= 0 ? cx.scope(base_index).builder : null;

            boolean is_outerfunc;

            boolean is_globalref;
            boolean is_dotref;
            boolean is_cinit_ref;

            is_localref          = isLocalScope(cx, base_index);
            is_outerfunc         = base_index != 0 && base_index <  frame.firstInnerScope && basebui instanceof ActivationBuilder;
            is_globalref         = base_index == 0;
            is_dotref            = base_index == -2;
            boolean is_lexref    = !(is_localref || is_dotref);
            is_cinit_ref         = slot != null && isClassInitializerReference(cx, slot.getValue());

            if (is_cinit_ref)
            {
                 // Special case for $cinit functions that reference the class
                // being initialized.  See bug #113887.
                LoadThis();

                call_seq = CALL_Args;
                disp_kind = node.is_new ? DISP_ConstructClosure : DISP_CallClosure;
                this_kind = node.is_new ? THIS_None : THIS_Scope;
            }
            else
            if( is_localref )
            {
                call_seq  = CALL_EnvThisArgs;
                disp_kind = DISP_CallClosure;
                this_kind = THIS_Global;
            }
            else
            if( is_globalref )  // some of these can be turned into CallFinal
            {
            //#if 1 // when OP_constructproperty is supported
                call_seq  = CALL_Args;
                disp_kind = node.is_new?DISP_ConstructProperty:DISP_CallProperty;
                this_kind = node.is_new?THIS_None:THIS_Base;
            //#else
            //                    call_seq  = CALL_EnvThisArgs;
            //                    disp_kind = DISP_CallClosure;
            //                    this_kind = THIS_Base;
            //#endif
            }
            else
            if( is_dotref )
            {
                call_seq  = CALL_Args;
                disp_kind = node.is_new?DISP_ConstructProperty:DISP_CallProperty;
                this_kind = node.is_new?THIS_None:THIS_Base;
            }
            else
            if( is_lexref )  // some of these can be turned into CallFinal
            {
                if( is_outerfunc )
                {
            //#if 1 // when OP_callproplex is supported
                    call_seq  = CALL_Args;
                    disp_kind = node.is_new?DISP_ConstructProperty:DISP_CallPropLex;
                    this_kind = node.is_new?THIS_None:THIS_Base;
            //#else
            //                    call_seq  = CALL_EnvThisArgs;
            //                    disp_kind = DISP_CallClosure;
            //                    this_kind = THIS_Global;
            //#endif
                }
                else
                {
            //#if 1 // when OP_constructproperty is supported
                    call_seq  = CALL_Args;
                    disp_kind = node.is_new?DISP_ConstructProperty:DISP_CallProperty;
                    this_kind = node.is_new?THIS_None:THIS_Base;
            //#else
            //                    call_seq  = CALL_EnvThisArgs;
            //                    disp_kind = DISP_CallClosure;
            //                    this_kind = node.is_new?THIS_None:THIS_Base;
            //#endif
                }
            }
            else
            {
                cx.internalError("missing call case");
            }

            // if it is monomorphic and lexical and in an inner scope, then call final

            Slot method_slot = node.ref.getSlot(cx,slot_kind);
            if( base_index > 0 && method_slot != null )
            {
                // Has an implied method (call or construct), so use it. For now,
                // we just do this for functions, we could do it for inherited
                // methods where the implementing class is defined in the current
                // script.

                if( is_outerfunc && !in_with && method_slot.getMethodID() >= 0 )
                {
                    call_seq  = method_slot.getCallSequence();
                    method_name = method_slot.getMethodName();
                    disp_kind = DISP_CallFinal; //method_slot.dispatch_kind;
                    this_kind = THIS_Global; // is_dotref?THIS_Base:is_outerfunc?THIS_Global:THIS_Base;
                }
            }

            this_kind = node.is_new?THIS_None:this_kind;  // if its a new expression, then clear this_kind
        }

        int temp_this_reg = -1;
        ObjectValue obj = cx.scope(scope_depth);
        Builder bui = obj.builder;
        int reg_offset = getRegisterOffset(cx);
        int var_offset = bui.var_offset;

        // Save this, which was on the stack when we entered this function

        {
            switch( this_kind )
            {
                case THIS_Global:
                // do nothing
                break;
                case THIS_Scope:
                // do nothing
                break;
                case THIS_Base:
                if( (call_seq & PUSH_env) != 0)
                {   // need to save base in temp
                    this_kind = THIS_Temp;
                    temp_this_reg = allocateTemp();
                    Dup();
                    StoreRegister(reg_offset+temp_this_reg,TYPE_none);
                }
                break;
                case THIS_None:
                // do nothing
                break;
                default:
                cx.internalError("invalid this_kind");
                break;
            }
        }

        int size = node.args!=null?node.args.size():0;

        // Get the function object

        if( (call_seq & PUSH_env) != 0 )
        {
            if( node.ref == null )
            {
                if( node.isRvalue() )
                {
                    // Literal function expression
                    // x = function () { return 10 } ()

                    node.expr.evaluate(cx,this);
                }
                else   // runtime qualified identifier  // o.ns::[expr]
                if( node.getIdentifier() != null )
                {
                    node.expr.evaluate(cx,this);  // if it is qualified, then eval the qualifier

                    QualifiedExpressionNode qen = node.getIdentifier() instanceof QualifiedExpressionNode? (QualifiedExpressionNode)node.getIdentifier() : null;
                    if( qen != null )
                    {
                        qen.expr.evaluate(cx,this);

                        if( qen.nss != null )
                        {
                            GetProperty(false/*is_qualified*/, is_super,is_attribute, qen.nss);
                        }
                        else
                        if( qen.qualifier != null )
                        {
                            ToString();
                            GetProperty(true/*is_qualified*/, is_super,is_attribute, used_namespaces_sets.back());
                        }
                        else
                        {
                            GetProperty(false/*is_qualified*/, is_super,is_attribute, used_namespaces_sets.back());
                        }
                    }
                    else
                    {
                        GetProperty(node.getIdentifier().name, is_super, is_attribute);
                    }
                }
                else
                {
                    // Indexed member expression
                    // x = o['foo']()

                    node.expr.evaluate(cx,this);
                    GetProperty(is_qualified,is_super,is_attribute,used_namespaces_sets.back());
                }
            }
            else
            if( is_localref )
            {
                // Fixed local
                if (frame.registerScopeIndex != base_index)
                {
                    GetActivationObject(base_index);
                    LoadVar(var_offset+node.ref.getSlot(cx,GET_TOKEN).getVarIndex());
                }
                else
                {   // cn: don't use expr_type here.  Its the type of what the function returns.  Use the get slot's type instead.
                    LoadRegister(reg_offset+node.ref.getSlot(cx,GET_TOKEN).getVarIndex(),node.ref.getSlot(cx,GET_TOKEN).getType().getTypeId());
                }
            }
            else
            {
                GetProperty(node.ref.name,node.ref.getImmutableNamespaces(),node.ref.isQualified(),is_super,is_attribute);
            }
        }

    // Push the args

    {
        if( (call_seq & PUSH_env)!=0 )
        {
            GetScopeChain();
        }

        switch( this_kind )
        {
            case THIS_Global:
            GetGlobalScope();
            break;
            case THIS_Scope:
            GetBaseObject(base_index); // never used
            break;
            case THIS_Base:
            // do nothing, already on the stack
            break;
            case THIS_Temp:
            LoadRegister(reg_offset+temp_this_reg,TYPE_none);
            break;
            case THIS_None:
            // do nothing
            break;
            default:
            cx.internalError("invalid this_kind");
            break;
        }

        if( (call_seq&PUSH_args)!=0 )
        {
            if( node.args!=null )
            {
                node.args.evaluate(cx,this);
            }
        }
    }

    // Call the function

    switch( disp_kind )
    {
        case DISP_CallProperty:
        CallProperty(node.ref.name,node.ref.getImmutableNamespaces(),size,node.ref.isQualified(),is_super,is_attribute,false);
        break;
        case DISP_CallPropLex:
        CallProperty(node.ref.name,node.ref.getImmutableNamespaces(),size,node.ref.isQualified(),is_super,is_attribute,true);
        break;
        case DISP_ConstructProperty:
        ConstructProperty(node.ref.name,node.ref.getImmutableNamespaces(),size,node.ref.isQualified(),is_super,is_attribute);
        break;
        case DISP_CallClosure:
        case DISP_ConstructClosure:
        InvokeClosure(node.is_new,size);
        break;
        case DISP_CallFinal:
        {
            int method_info = cx.getEmitter().GetMethodInfo(method_name);
            InvokeMethod(false /*DISPATCH_final*/,method_info,size);
            break;
        }
        default:
        cx.internalError("invalid disp_kind");
        break;
    }

        if( node.void_result )
        {
            Pop();
        }

        if (temp_this_reg != -1)
        {
            freeTemp(temp_this_reg); // temp_this_reg
        }

        if( debug ) System.out.print("\n// -CallExpression");

        return null;
    }

    public Value evaluate(Context cx, InvokeNode node)
    {

        if (debug)
        {
            System.out.print("\n// +Invoke");
        }

        if (node.ref == null || node.ref.getScopeIndex(EMPTY_TOKEN) == 0)
        {
            // Found. It's a global ( base must have been 'this' )
            GetGlobalScope();
        }

        // Push the args

        int size = node.args != null ? node.args.size() : 0;
        {
            if (node.args != null)
            {
                node.args.evaluate(cx, this);
            }
        }

        // Call the operator
        InvokeUnary(node.index, size - 1, -1, used_namespaces_sets.back(), null);
        if (debug)
        {
            System.out.print("\n// -Invoke");
        }

        return null;
    }

    public Value evaluate(Context cx, SetExpressionNode node)
    {
        if (debug)
        {
            System.out.print("\n// +SetExpression");
        }

        int temp_val_reg = 0;

        boolean is_qualified = node.isQualified();
        boolean is_attribute = node.isAttributeIdentifier();
        boolean is_super = node.isSuper();

        if( node.getMode() == DOUBLEDOT_TOKEN )
        {
            // work in progress
            cx.internalError("Descendant assigment not yet supported");
        }
        else
        if( node.ref == null )
        {
            int reg_offset = -1;
            // Compute the name
            node.expr.evaluate(cx,this);

            boolean is_constinit = is_ctor&&node.isThis();

            if ( node.getIdentifier() == null && (node.getMode() == EMPTY_TOKEN /*synthetic*/ || node.getMode() == LEFTBRACKET_TOKEN) )
            {

                // Push the value on the stack

                node.args.evaluate(cx, this);
                reg_offset = getRegisterOffset(cx);
                if (!node.void_result)
                {
                    temp_val_reg = allocateTemp();
                    Dup();
                    StoreRegister(reg_offset+temp_val_reg,cx.noType().getTypeId());
                }
                SetProperty(is_qualified, is_super, is_attribute, used_namespaces_sets.back(),is_constinit);
            }
            else
            if( node.getIdentifier() != null )
            {
                QualifiedExpressionNode qen = node.getIdentifier() instanceof QualifiedExpressionNode ? (QualifiedExpressionNode) node.getIdentifier() : null;
                if( qen != null )
                {

                    qen.expr.evaluate(cx,this);
                    if( qen.qualifier != null )
                    {
                        ToString();  // must be string
                    }

                    node.args.evaluate(cx,this);
                    reg_offset = getRegisterOffset(cx);
                    if( !node.void_result )
                    {
                        temp_val_reg = allocateTemp();
                        Dup();
                        StoreRegister(reg_offset+temp_val_reg,cx.noType().getTypeId());
                    }

                    if( qen.nss != null )
                    {
                        SetProperty(false/*is_qualified*/, is_super, is_attribute, qen.nss,is_constinit);
                    }
                    else
                    if( qen.qualifier != null )
                    {
                        SetProperty(true/*is_qualified*/, is_super, is_attribute, used_namespaces_sets.back(),is_constinit);
                    }
                    else
                    {
                        SetProperty(false/*is_qualified*/, is_super, is_attribute, used_namespaces_sets.back(),is_constinit);
                    }
                }
                else
                {
                    node.args.evaluate(cx,this);
                    reg_offset = getRegisterOffset(cx);
                    if( !node.void_result )
                    {
                        temp_val_reg = allocateTemp();
                        Dup();
                        StoreRegister(reg_offset+temp_val_reg,cx.noType().getTypeId());
                    }

                    SetProperty(node.getIdentifier().name, is_super, is_attribute);
                }
            }
            else
            {
                cx.internalError(node.pos(),"internal error: lhs is not a reference");
            }

            if (!node.void_result)
            {
                LoadRegister(reg_offset+temp_val_reg,cx.noType().getTypeId());
                freeTemp(temp_val_reg); // temp_val_reg
            }
        }
        else
        {
            Slot slot                = node.ref.getSlot(cx,SET_TOKEN);
            TypeInfo expr_type       = node.ref.getType(cx);
            int  base_index          = node.ref.getScopeIndex(SET_TOKEN);
            int  slot_index          = node.ref.getSlotIndex(SET_TOKEN);
            int  scope_depth         = cx.getScopes().size()-1;
            
            int reg_offset = getRegisterOffset(cx);
            int var_offset = cx.scope(scope_depth).builder.var_offset;

            Builder bui                  = base_index>0?cx.scope(base_index).builder:null; // get the builder from lexical scope, null if object reference

            boolean is_constinit         = node.is_constinit?true:(is_ctor&&node.isThis())?true:(bui instanceof InstanceBuilder)?true:false;
            boolean is_const             = slot!=null?slot.isConst():false;

            boolean is_localref          = isLocalScope(cx, base_index);
            boolean is_globalref         = base_index == 0;
            boolean is_dotref            = base_index == -2;
            boolean is_unbound_lexref    = base_index == -1;
            boolean is_unbound_dotref    = is_dotref && slot_index < 0;
            boolean is_unbound_globalref = is_globalref && slot_index < 0;
            boolean is_unbound_ref       = is_unbound_dotref || is_unbound_lexref || is_unbound_globalref;

            if( is_unbound_ref )
            {
                // If it is a global ref, then the base object is not yet on the
                // stack. Push it now

                if( is_globalref )
                {
                    GetGlobalScope();
                }

                // Push the value on the stack

                node.args.evaluate(cx,this);

                // See if we can tell if the reference is dynamic or not.
                // This is only possible when it is a dot reference, but
                // we don't worry about that here, to simplify

/*  runtime error
                ObjectValue bobj = node.ref.getBase();
                TypeValue btyp = bobj != null ? bobj.getType(cx) : cx.noType();

                if (btyp.isFinal() && !btyp.isDynamic())
                {
                    cx.error(node.pos(), kError_UnknownPropertyInNonDynamicInstance, node.ref.name);
                }
*/
                {
                    if (!node.void_result)
                    {
                        Dup();
                        temp_val_reg = allocateTemp();
                        StoreRegister(reg_offset+temp_val_reg, expr_type.getTypeId());
                    }
                    SetProperty(node.ref.name, node.ref.getImmutableNamespaces(), node.ref.isQualified(), is_super, is_attribute, is_constinit);
                }

                if (!node.void_result)
                {
                    LoadRegister(reg_offset+temp_val_reg, expr_type.getTypeId());
                    freeTemp(temp_val_reg);  // temp_val_reg
                }
            }
            else if (is_globalref)
            {
                // Found, global variable
                int varIndex = slot.getVarIndex();
                if (slot.declaredBy != cx.scope(0))
                {
                    varIndex = -1;
                }

                if (slot.getMethodID() >= 0 || varIndex < 0) // Need to put global on stack
                {
                    FindProperty(node.ref.name,node.ref.getImmutableNamespaces(),node.ref.isQualified(),is_super,is_attribute);
                }
                else
                if( is_const )
                {
                    GetBaseObject(0);
                }

                // Push the value

                node.args.evaluate(cx,this);

                if( !node.void_result )
                {
                    Dup();
                    temp_val_reg = allocateTemp();
                    StoreRegister(reg_offset+temp_val_reg,expr_type.getTypeId());
                }
   
                if( slot.getMethodID() >= 0  && cx.globalScope() == slot.declaredBy) // If it is a setter, invoke it.
                {
                    InvokeMethod(false/*is_virtual*/,GetMethodInfo(slot.getMethodName()), 1);
                    
                    //  callstatic's semantics leave a value on the stack; a void setter 
                    //  doesn't return anything, so pop this pseudo return value to keep
                    //  the stack balanced.
                    if ( node.void_result )
                    	Pop();
                }
                else // If it is a variable and we know the index, then store it
                if( varIndex >= 0 && !is_const)
                {
                    StoreGlobal(varIndex,expr_type.getTypeId());
                }
                else // Otherwise, just do a generic store global by name
                {
                    SetProperty(node.ref.name, node.ref.getImmutableNamespaces(), node.ref.isQualified(), is_super, is_attribute, is_constinit);
                }

                if( !node.void_result )
                {
                    LoadRegister(reg_offset+temp_val_reg,expr_type.getTypeId());
                    freeTemp(temp_val_reg);  // temp_val_reg
                }
            }
            else if (is_localref)
            {
                // Found, local variable

                {
                    if( is_const && !is_constinit )
                    {
                        PushString("Illegal write to local const " + node.ref.name);
                        Throw();
                    }

                    if( slot.getMethodID() >= 0 || frame.registerScopeIndex != base_index)
                    {
                        GetActivationObject(base_index);
                    }
                    node.args.evaluate(cx,this);
                    if (!node.void_result)
                    {
                        Dup();
                        temp_val_reg = allocateTemp();
                        StoreRegister(reg_offset+temp_val_reg, expr_type.getTypeId());
                    }

                    if( slot.getMethodID() >= 0 )
                    {
                        InvokeMethod(true,slot.getMethodID(),1);
                    }
                    else
                    {
                        // issue this CheckType is too conservative
                        // explicit coerce before setting a local, in case VM doesn't know
                        // the type that we know here. (e.g. calling through an interface)
                        CheckType(slot.getType().getName(cx));
                        if (frame.registerScopeIndex != base_index)
                        {
                                StoreVar(var_offset+slot.getVarIndex());
                        }
                        else
                        {
                            //CheckType(slot.getType().name);
                            StoreRegister(reg_offset+slot.getVarIndex(),expr_type.getTypeId(),node.ref.name);
                        }
                    }

                    if (!node.void_result)
                    {
                        LoadRegister(reg_offset+temp_val_reg, expr_type.getTypeId());
                        freeTemp(temp_val_reg);  // temp_val_reg
                    }
                }
            }
            else // is dot ref or lexical ref (not global or local)
            {
                // Found. Push the slot index.

                ObjectValue base = node.ref.getBase();
                base = base != null ? base : cx.scope(node.ref.getScopeIndex());

                node.args.evaluate(cx, this);
                if (!node.void_result)
                {
                    Dup();
                    temp_val_reg = allocateTemp();
                    StoreRegister(reg_offset+temp_val_reg, expr_type.getTypeId());
                }

                SetProperty(node.ref.name, node.ref.getImmutableNamespaces(),node.ref.isQualified(),is_super,is_attribute, is_constinit);

                if (!node.void_result)
                {
                    LoadRegister(reg_offset+temp_val_reg, expr_type.getTypeId());
                    freeTemp(temp_val_reg);  // temp_val_reg
                }
            }
        }

        if (debug)
        {
            System.out.print("\n// -SetExpression");
        }
        return null;
    }

    public Value evaluate(Context cx, DeleteExpressionNode node)
    {
        if (debug)
        {
            System.out.print("\n// +DeleteExpression");
        }

        boolean is_qualified = node.isQualified();
        boolean is_attribute = node.isAttributeIdentifier();
        boolean is_super = node.isSuper();

        if( node.getMode() == DOUBLEDOT_TOKEN )
        {
            // o..id
            // o..ns::id

            if( is_super )
            {
                cx.error(node.pos(), kError_CannotDeleteSuperDecendants);
            }

            if( node.base != null )
            {
                // need to pop the base object that was pushed on the stack.
                Pop();
            }

            if( !node.void_result )
            {
                PushBoolean(true);
            }
        }

        else if (node.ref == null)
        {
            // Dynamic deletion ["blah"]
            if( node.getMode() == LEFTBRACKET_TOKEN )
            {
                node.expr.evaluate(cx, this);
                DeleteProperty(is_qualified, is_super,is_attribute, used_namespaces_sets.back());
                if( node.void_result )
                {
                    Pop();
                }
            }
            // if we have a literal ala 'delete imAvariable'
            else if(node.getIdentifier() != null)
            {
                node.expr.evaluate(cx, this);
                QualifiedExpressionNode qen = node.getIdentifier() instanceof QualifiedExpressionNode? (QualifiedExpressionNode)node.getIdentifier() : null;
                if( qen != null )
                {
                    qen.expr.evaluate(cx,this);
                    if( qen.nss != null )
                    {
                        DeleteProperty(false/*is_qualified*/, is_super,is_attribute,qen.nss);
                    }
                    else
                    if( qen.qualifier != null )
                    {
                        ToString();
                        DeleteProperty(true/*is_qualified*/, is_super ,is_attribute,used_namespaces_sets.back());
                    }
                    else
                    {
                        DeleteProperty(false/*is_qualified*/, is_super,is_attribute,used_namespaces_sets.back());
                    }
                }
                else
                {
                    if( node.base == null )
                    {
                        FindProperty(node.getIdentifier().name,true,is_attribute);
                        //node.expr.evaluate(cx,this);
                    }
                    DeleteProperty(node.getIdentifier().name,is_super,is_attribute);
                }
                if( node.void_result )
                {
                    Pop();
                }
            }
            // we don't know what we're getting, e.g. 'delete arrayVar.pop()'
            // cn:  delete removes properties, not values, so 'delete arrayVar.pop()'
            //      doesn't do anything other than return true.   Our implementation of functions can't return a
            //      referenceValue (spec says the ability to do so is implementation dependant), so just evaluate and bail
            // cn:  A possible exception to this logic would be when expr is a list ala "delete(m=2,m)"
            //      The evaluation of a list returns the evaluation of the last element of that list,
            //      which is value, not a ReferenceValue, so I don't think delete should have an effect on list valued
            //      arguments.  Its a common mistake to write "delete(m)" instead of "delete m", however, so
            //      we do actually delete a property reference if its the last element of a list.   I notice that
            //      Spidermonkey does delete the prop m for an expression like "delete(m)" but does *not*
            //      delete the prop m for an expression like "delete(m=2,m)".   We delete the property in both
            //      cases  (for both cases, we follow the node.ref != null control flow to the code below because
            //      node.ref was set up to the ReferenceValue returned from the evaluation of the .expr ListNode during FA).
            else
            {
                if( node.base == null )
                {
                    // No base object was pushed
                    GetGlobalScope();
                }
                node.expr.evaluate(cx, this);
                DeleteProperty(is_qualified, is_super, is_attribute, used_namespaces_sets.back());
                if( node.void_result )
                {
                    Pop();
                }
            }
        }
        else
        {
            int base_index = node.ref.getScopeIndex(GET_TOKEN);

            if (base_index >= frame.firstInnerScope)
            {
                if (base_index != 0
                    && !(cx.scope(base_index).builder instanceof ActivationBuilder))
                {
                    Pop();  // this
                }
                // else this is a local or global declared var and no 'this' was pushed.

                if (!node.void_result)  //  but we want a result
                {
                    PushBoolean(false);  // parameters and declared vars are DontDelete
                }
            }
            else
            {
                if (base_index == 0)
                {
                    // In this case, no base object was put on the stack by the
                    // outer MemberExpressionNode.
                    GetGlobalScope();
                }
                DeleteProperty(node.ref.name,node.ref.getImmutableNamespaces(),node.ref.isQualified(),is_super,is_attribute);
                if (node.void_result)
                {
                    Pop();
                }
            }
        }
        if (debug)
        {
            System.out.print("\n// -DeleteExpression");
        }
        return null;
    }

    public Value evaluate(Context cx, ApplyTypeExprNode node)
    {
        if (debug)
        {
            System.out.print("\n// +ApplyTypeExpression");
        }

        boolean is_super = node.isSuper();
        boolean is_qualified = node.isQualified();
        boolean is_attribute = node.isAttributeIdentifier();

        if( node.ref != null )
        {
            GetProperty(node.getIdentifier().name, node.ref.getImmutableNamespaces(), is_qualified, is_super, is_attribute);
        }
        else
        {
            if( node.getIdentifier() != null )
            {
                node.expr.evaluate(cx,this);  // if it is qualified, then eval the qualifier

                QualifiedExpressionNode qen = node.getIdentifier() instanceof QualifiedExpressionNode? (QualifiedExpressionNode)node.getIdentifier() : null;
                if( qen != null )
                {
                    qen.expr.evaluate(cx,this);

                    if( qen.nss != null )
                    {
                        GetProperty(false/*is_qualified*/, is_super,is_attribute, qen.nss);
                    }
                    else
                    if( qen.qualifier != null )
                    {
                        ToString();
                        GetProperty(true/*is_qualified*/, is_super,is_attribute, used_namespaces_sets.back());
                    }
                    else
                    {
                        GetProperty(false/*is_qualified*/, is_super,is_attribute, used_namespaces_sets.back());
                    }
                }
                else
                {
                    GetProperty(node.getIdentifier().name, is_super, is_attribute);
                }
            }
            else
            {
                node.expr.evaluate(cx, this);
            }
        }
        if( node.typeArgs!=null )
        {
            for (int i = 0, size = node.typeArgs.items.size(); i < size; i++)
            {
                Node item = node.typeArgs.items.get(i);
                Value val = node.typeArgs.values.get(i);
                ReferenceValue ref = val instanceof ReferenceValue ? (ReferenceValue)val : null;
                if( ref != null && "*".equals(ref.name))
                {
                    // Use null for '*'
                    PushNull();
                }
                else
                {
                    item.evaluate(cx, this);
                }
            }
        }

        ApplyType(node.typeArgs.size());

        if (debug)
        {
            System.out.print("\n// -ApplyTypeExpression");
        }
        return null;
    }

    public Value evaluate(Context cx, GetExpressionNode node)
    {
        if (debug)
        {
            System.out.print("\n// +GetExpression");
        }

        // GetExpressions occur in a dot or bracket operation. They are always
        // embedded in a MemberExpressionNode and therefore code to load the base
        // object onto the stack has already been generated. The job of this
        // method is to generate the code to select the slot and invoke it.

        // ISSUE: If the base value is 'this' and we are in a instance method,
        // then we know the type of this and can bind directly to the slot. (not implemented)

        boolean is_qualified = node.isQualified();
        boolean is_attribute = node.isAttributeIdentifier();
        boolean is_super = node.isSuper();

        if( node.getMode() == DOUBLEDOT_TOKEN )
        {
            if( node.ref != null )
            {
                GetDescendants(node.ref.name,node.ref.getImmutableNamespaces(),node.ref.isQualified(),false,is_attribute);
            }
            else
            {
                node.expr.evaluate(cx,this);  // if it is qualified, then eval the qualifier

                QualifiedExpressionNode qen = node.getIdentifier() instanceof QualifiedExpressionNode ? (QualifiedExpressionNode) node.getIdentifier() : null;
                if( qen != null )
                {
                    qen.expr.evaluate(cx,this);
                    if( qen.qualifier != null )
                    {
                        ToString();
                        GetDescendants(true/*is_qualified*/, is_attribute, used_namespaces_sets.back());
                    }
                    else
                    {
                        GetDescendants(false/*is_qualified*/, is_attribute, used_namespaces_sets.back());
                    }
                }
                else
                {
                    GetDescendants(node.getIdentifier().name, is_super, is_attribute);
                }
            }

            if( node.isVoidResult() )
            {
                Pop();
            }
        }
        else
        if( node.ref == null )
        {
            if( node.getMode()==LEFTBRACKET_TOKEN ) // o[expr]
            {
                node.expr.evaluate(cx,this);
                GetProperty(is_qualified, is_super, is_attribute,used_namespaces_sets.back());
            }
            else   // runtime qualified identifier  // o.ns::[expr]
            {
                node.expr.evaluate(cx,this);  // if it is qualified, then eval the qualifier

                QualifiedExpressionNode qen = node.getIdentifier() instanceof QualifiedExpressionNode? (QualifiedExpressionNode)node.getIdentifier() : null;
                if( qen != null )
                {
                    qen.expr.evaluate(cx,this);
                    if( qen.nss != null )
                    {
                        GetProperty(false,is_super,is_attribute,qen.nss);   //  ns::[expr]
                    }
                    else
                    if( qen.qualifier != null )
                    {
                        ToString();
                        GetProperty(true/*is_qualified*/, is_super ,is_attribute,used_namespaces_sets.back());
                    }
                    else
                    {
                        GetProperty(false/*is_qualified*/, is_super,is_attribute,used_namespaces_sets.back());
                    }
                }
                else
                {
                    GetProperty(node.getIdentifier().name, is_super, is_attribute);
                }
            }

            if (node.isVoidResult())
            {
                Pop();
            }
        }
        else
        {
            Slot slot                = node.ref.getSlot(cx,GET_TOKEN);
            TypeInfo expr_type      = node.ref.getType(cx);
            int  base_index           = node.ref.getScopeIndex(GET_TOKEN);
            int  slot_index           = node.ref.getSlotIndex(GET_TOKEN);
            int  scope_depth          = cx.getScopes().size()-1;

            Builder basebui = base_index >= 0 ? cx.scope(base_index).builder : null;
            boolean is_localref          = isLocalScope(cx, base_index);
            boolean is_globalref         = base_index == 0;
            boolean is_dotref            = base_index == -2;
            boolean is_unbound_lexref    = base_index == -1;
            boolean is_unbound_dotref    = is_dotref && slot_index < 0;
            boolean is_unbound_globalref = is_globalref && slot_index < 0;
            boolean is_unbound_ref       = is_unbound_dotref || is_unbound_lexref || is_unbound_globalref;

            if( is_unbound_ref )
            {
                // The slot was not found.

                if( node.ref.getSlot(cx,SET_TOKEN) != null )
                {
                    cx.error(node.pos(), kError_PropertyIsWriteOnly);
                }

                // If the base_index is 0 then push the base object
                if( is_globalref )
                {
                    GetGlobalScope();
                }

                /* should be runtime error
                ObjectValue bobj = node.ref.getBase();

                if( btyp.isFinal() && !btyp.isDynamic())
                {
                    cx.error(node.pos() - 1, kError_UnknownPropertyInNonDynamicInstance, node.ref.name);
                }
*/
                {
                    // Otherwise, we don't know the base or the slot, so just do a general
                    // property ref.
                    GetProperty(node.ref.name,node.ref.getImmutableNamespaces(),node.ref.isQualified(),is_super,is_attribute);
                }
                if (node.isVoidResult())
                {
                    Pop();
                }
            }
            else if (is_globalref)
            {
                // Found. It's a global. To bind to var indexes at compile-time
                // the var index has to be owned by the base object, not one of
                // its prototypes.

                // Fixed global
                slot = node.ref.getSlot(cx, GET_TOKEN);
                if (slot.getMethodID() >= 0 && cx.globalScope() == slot.declaredBy) // If it is a method, invoke it.
                {
                    // The property has a global getter and is defined in the same source file, just
                    // invoke the method directly.
                    GetGlobalScope();
                    InvokeMethod(false, GetMethodInfo(slot.getMethodName()), 0);
                    if (node.isVoidResult())
                    {
                        Pop();
                    }
                }
                else if (slot.getValue() == cx.scope(scope_depth))
                {
                    // Special case for $cinit functions that reference the class
                    // being initialized.  See bug #113887.
                    LoadThis();
                }
                else // If it is a variable, then load it.
                {
                    if (!node.isVoidResult())
                    {
                        int varIndex = slot.getVarIndex();
                        if (slot.declaredBy != cx.scope(0))
                        {
                            varIndex = -1;
                        }
                        if (varIndex >= 0)
                        {
                            LoadGlobal(varIndex, expr_type.getTypeId());
                        }
                        else
                        {
                            // imported slot
                            FindProperty(node.ref.name,node.ref.getImmutableNamespaces(), true/*is_strict*/, node.ref.isQualified(), is_attribute);
                            GetProperty(node.ref.name,node.ref.getImmutableNamespaces(),node.ref.isQualified(), is_super, is_attribute);
                            //cx.internalError("Internal error: don't know how to get global property",node->pos()-1);
                        }
                    }
                }
            }
            else if (is_localref)
            {
                int reg_offset = getRegisterOffset(cx);
                int  var_offset = cx.scope(scope_depth).builder.var_offset;

                // Found. It's a local
                if( slot.getMethodID() >= 0 )
                {
                    GetActivationObject(base_index);
                    GetProperty(node.ref.name,node.ref.getImmutableNamespaces(),node.ref.isQualified(),is_super,is_attribute);
                    if( node.isVoidResult() )
                    {
                        Pop();
                    }
                }
                else
                if (!node.isVoidResult())
                {
                    if (frame.registerScopeIndex != base_index)
                    {
                        GetActivationObject(base_index);
                        LoadVar(var_offset+slot.getVarIndex());
                    }
                    else
                    {
                        LoadRegister(reg_offset+slot.getVarIndex(), expr_type.getTypeId());
                    }
                }
            }
            else
            {
                // Found. It's a property or closure access via slot index.
                // Slot indexes are good for access through the derived object
                // since they are unique for all slots in the prototype chain.
                // Control should not get here if the reference is to a var that
                // might be hidden at runtime. In that case the slot index should
                // be -1, and a dynamic lookup should be generated as in the
                // if block above.

                GetProperty(node.ref.name,node.ref.getImmutableNamespaces(),node.ref.isQualified(),is_super,is_attribute);
                if( node.isVoidResult() )
                {
                    Pop();
                }
            }
        }

        if (debug)
        {
            System.out.print("\n// -GetExpression");
        }
        return null;
    }

    class LazyTemp
    {
        public int get()
        {
            if (index == -1)
            {
                index = allocateTemp();
            }
            return index;
        }

        public void free()
        {
            if (index != -1)
            {
                freeTemp(index);
                index = -1;
            }
        }

        private int index = -1;
    }

    public Value evaluate(Context cx, IncrementNode node)
    {
        if (debug)
        {
            System.out.print("\n// +IncrementNode");
        }

        boolean is_qualified = node.isQualified();
        boolean is_attribute = node.isAttributeIdentifier();
        boolean is_super = node.isSuper();

        LazyTemp temp_base_reg = new LazyTemp();
        LazyTemp temp_name_reg = new LazyTemp();
        LazyTemp temp_val_reg  = new LazyTemp();
        int reg = -1;

        TypeInfo type = cx.noType().getDefaultTypeInfo();

        int scope_depth = cx.getScopes().size()-1;
        int reg_offset = getRegisterOffset(cx);
        int var_offset = cx.scope(scope_depth).builder.var_offset;

        if (node.ref == null)
        {
            // Indexed member expression
            Dup();
            StoreRegister(reg_offset+temp_base_reg.get(), TYPE_none);
            node.expr.evaluate(cx, this);
            Dup();
            StoreRegister(reg_offset+temp_name_reg.get(), TYPE_none);

            InvokeUnary(UNARY_Get,0,-1,used_namespaces_sets.back(), node.numberUsage);

            if (node.isPostfix && !node.void_result)
            {
                // Postfix result
                ToDouble(TYPE_double); // ES3 11.3.2 step 6
                Dup();
            }
        }
        else
        {
            // Member expression
            Slot slot = node.ref.getSlot(cx);
            type = node.ref.getType(cx);

            // If we are calling the int version of increment/decrement then there is no point in calling
            // ToNumber on the operand, since we know that we are incrementing an int.  The ToNumber is unneccesary, and we'll
            // undo it anyways in increment_i/decrement_i which will cast down to an int.
            int method_id = node.slot.getMethodID();
            boolean already_int = method_id == UNARY_IncrementOp_I ||
                                  method_id == UNARY_IncrementLocalOp_I ||
                                  method_id == UNARY_DecrementOp_I ||
                                  method_id == UNARY_IncrementLocalOp_I;

            int base_index = node.ref.getScopeIndex(GET_TOKEN);
            int slot_index = node.ref.getSlotIndex(GET_TOKEN);
            if (slot_index < 0 || base_index < 0)
            {
                // Dynamic reference
                if (base_index == 0)
                {
                    GetGlobalScope();
                }
                Dup();
                StoreRegister(reg_offset+temp_base_reg.get(), TYPE_none);
                GetProperty(node.ref.name,node.ref.getImmutableNamespaces(), node.ref.isQualified(), is_super, is_attribute);
                if (node.isPostfix && !node.void_result)
                {
                    // Postfix result
                    if( !already_int )
                        ToDouble(TYPE_double); // ES3 11.3.2 step 6
                    Dup();
                }
            }
            else if (base_index == 0)
            { // found slot, invoke it
                // Fixed global
                LoadGlobal(slot.getVarIndex(), type.getTypeId());
                if (node.isPostfix && !node.void_result)
                {
                    // Postfix result
                    if( !already_int )
                        ToDouble(TYPE_double); // ES3 11.3.2 step 6
                    Dup();
                }
            }
            else if (isLocalScope(cx, base_index))
            {
                reg = node.ref.getSlot(cx, GET_TOKEN).getVarIndex();
                // Postfix result
                if (frame.registerScopeIndex != base_index)
                {
                    GetActivationObject(base_index);
                    LoadVar(var_offset+node.ref.getSlot(cx, GET_TOKEN).getVarIndex());
                }
                else
                {
                    LoadRegister(reg_offset+node.ref.getSlot(cx, GET_TOKEN).getVarIndex(), type.getTypeId());
                }
                if (node.isPostfix && !node.void_result)
                {
                    // Postfix result
                    if( !already_int )
                        ToDouble(TYPE_double); // ES3 11.3.2 step 6
                    Dup();
                }
            }
            else
            {
                // Fixed property
                Dup();
                StoreRegister(reg_offset+temp_base_reg.get(), TYPE_none);
                Value val = node.ref.getBase();
                ObjectValue base = (val instanceof ObjectValue) ? (ObjectValue) val : null;
                base = base != null ? base : cx.scope(node.ref.getScopeIndex());
                GetProperty(node.ref.name,node.ref.getImmutableNamespaces(), node.ref.isQualified(), is_super, is_attribute);
                if (node.isPostfix && !node.void_result)
                {
                    // Postfix result
                    if( !already_int )
                        ToDouble(TYPE_double); // ES3 11.3.2 step 6
                    Dup();
                }

            }
        }

        // Increment the value

        InvokeUnary(node.slot.getMethodID(), 0, reg_offset+reg, used_namespaces_sets.back(), node.numberUsage);

        // Put the new value back

        if (node.ref == null)
        {
            if (!node.isPostfix && !node.void_result)
            {
                // Prefix result
                Dup();
            }

            // Save incremented value it in a temp
            StoreRegister(reg_offset+temp_val_reg.get(), type.getTypeId());

            // Indexed member expression
            LoadRegister(reg_offset+temp_base_reg.get(), TYPE_none);    // Base object
            LoadRegister(reg_offset+temp_name_reg.get(), TYPE_none);
            LoadRegister(reg_offset+temp_val_reg.get(), TYPE_none);        // Value
            InvokeUnary(UNARY_Put, 1, -1, used_namespaces_sets.back(), node.numberUsage);
        }
        else
        {
            // Member expression
            Slot slot = node.ref.getSlot(cx);
            int base_index = node.ref.getScopeIndex(SET_TOKEN);
            int slot_index = node.ref.getSlotIndex(SET_TOKEN);
            if (slot_index < 0 || base_index < 0)
            {
                if (!node.isPostfix && !node.void_result)
                {
                    // Prefix result
                    Dup();
                }

                // Save incremented value it in a temp
                StoreRegister(reg_offset+temp_val_reg.get(), type.getTypeId());

                // Dynamic reference
                LoadRegister(reg_offset+temp_base_reg.get(), TYPE_none);
                LoadRegister(reg_offset+temp_val_reg.get(), TYPE_none);
                SetProperty(node.ref.name,node.ref.getImmutableNamespaces(),node.ref.isQualified(), is_super, is_attribute, false);
            }
            else if (base_index == 0)
            {
                if (!node.isPostfix && !node.void_result)
                {
                    // Prefix result
                    Dup();
                }

                // Save incremented value it in a temp
                StoreRegister(reg_offset+temp_val_reg.get(), type.getTypeId());

                // Fixed global
                PreStoreGlobal(slot.getVarIndex(), type.getTypeId());  // swf only
                LoadRegister(reg_offset+temp_val_reg.get(), type.getTypeId());
//                CheckType(slot.type.name);
                StoreGlobal(slot.getVarIndex(), type.getTypeId());
            }
            else if (isLocalScope(cx, base_index))
            {
                if (!node.isPostfix && !node.void_result)
                {
                    // Prefix result
                    Dup();
                }
                CheckType(node.ref.getSlot(cx,GET_TOKEN).getType().getName(cx));
                if (frame.registerScopeIndex != base_index)
                {
                    GetActivationObject(base_index);
                    Swap();
                    StoreVar(var_offset+node.ref.getSlot(cx, GET_TOKEN).getVarIndex());
                }
                else
                {
                    StoreRegister(reg_offset+node.ref.getSlot(cx, GET_TOKEN).getVarIndex(), type.getTypeId());
                }
            }
            else
            {
                if (!node.isPostfix && !node.void_result)
                {
                    // Prefix result
                    Dup();
                }

                // Fixed property
                StoreRegister(reg_offset+temp_val_reg.get(), type.getTypeId());
                LoadRegister(reg_offset+temp_base_reg.get(), TYPE_none);
                LoadRegister(reg_offset+temp_val_reg.get(), TYPE_none);
                SetProperty(node.ref.name,node.ref.getImmutableNamespaces(),node.ref.isQualified(), is_super, is_attribute, false);
            }
        }

        temp_val_reg.free();
        temp_base_reg.free();
        temp_name_reg.free();

        if (debug)
        {
            System.out.print("\n// -IncrementNode");
        }
        return null;
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

        switch (node.op)
        {
            case VOID_TOKEN:
                if (!node.expr.isLiteralNumber())
                {
                    node.expr.voidResult();
                    node.expr.evaluate(cx, this);
                }
                if (!node.void_result)
                {
                    PushUndefined();
                }
                break;

            default:
                if ((node.slot.getCallSequence() & PUSH_this) != 0)
                {
                    GetGlobalScope();
                }
                if ((node.slot.getCallSequence() & PUSH_opd1) != 0)
                {
                    if (node.op == TYPEOF_TOKEN)
                    {
                        boolean old_in_typeof = this.in_typeof; // its possible to use an expression which contains typeof as the argument to another typeof
                        this.in_typeof = true;      // typeof undeclaredVar should not through RTE, use flag to force non-strict property lookup in MemberExpressionNode
                        node.expr.evaluate(cx, this);
                        this.in_typeof = old_in_typeof;
                    }
                    else
                    {
                        node.expr.evaluate(cx,this);
                    }
                }
                InvokeUnary(node.slot.getMethodID(), 0, -1, used_namespaces_sets.back(), node.numberUsage);
                if (node.void_result)
                {
                    Pop();
                }
                break;
        }

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

        if( node.op == EMPTY_TOKEN )
        {
            node.lhs.evaluate(cx,this);
        }
        else
        switch (node.slot.getMethodID())
        {
            case BINARY_LogicalAndOp_II:
            case BINARY_LogicalAndOp_BB:
                node.lhs.evaluate(cx, this);
                Dup();
                If(IF_false);  // if false, jump past then actions
                Pop();
                node.rhs.evaluate(cx, this);
                PatchIf(getIP());  // patch target of if jump
                break;
            case BINARY_LogicalAndOp:
                node.lhs.evaluate(cx, this);
                Dup();
                ToBoolean(node.lhstype != null ? node.lhstype.getTypeId() : TYPE_none);
                ToNativeBool();
                If(IF_false);  // if false, jump past then actions
                Pop();
                node.rhs.evaluate(cx, this);
                PatchIf(getIP());  // patch target of if jump
                break;
            case BINARY_LogicalOrOp_II:
            case BINARY_LogicalOrOp_BB:
                node.lhs.evaluate(cx, this);
                Dup();
                If(IF_true);  // if true, jump past then actions
                Pop();
                node.rhs.evaluate(cx, this);
                PatchIf(getIP()); // patch target of if jumps
                break;
            case BINARY_LogicalOrOp:
                node.lhs.evaluate(cx, this);
                Dup();
                ToBoolean(node.lhstype != null ? node.lhstype.getTypeId() : TYPE_none);
                ToNativeBool();
                If(IF_true);  // if false, jump past then actions
                Pop();
                node.rhs.evaluate(cx, this);
                PatchIf(getIP()); // patch target of if jumps
                break;
            case BINARY_IsOp:
            case BINARY_AsOp:   // static version, not yet implemented
                node.lhs.evaluate(cx, this);
                break;
            default:
                if (!traverse_binop_right_to_left)
                {
                    node.lhs.evaluate(cx, this);
                    node.rhs.evaluate(cx, this);
                }
                else
                {
                    node.rhs.evaluate(cx, this);
                    node.lhs.evaluate(cx, this);
                }

                InvokeBinary(node.slot.getMethodID(), node.numberUsage);
                break;
        }

        if (node.void_result)
        {
            Pop();
        }

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

        If(cx,node.condition);  // if false, jump past then actions
        node.thenexpr.evaluate(cx, this);
        if (node.thenexpr.inTerminalBlock() == false)
            Else(); // jump past else actions
        //else
        //    System.out.print("\n// +ConditionalExpressionNode, skiping Else jump");

        PatchIf(getIP());  // patch target of if jump
        node.elseexpr.evaluate(cx, this);

        if (node.thenexpr.inTerminalBlock() == false)
            PatchElse(getIP()); // patch target of else jumps

        if (debug)
        {
            System.out.print("\n// -ConditionalExpressionNode");
        }
        return null;
    }

    /*
     * Generate the code for a list (e.g. argument list). The owner of this node
     * has already allocated a fixed size array. This function stuffs the list
     * values into that array.

     * ISSUE:
     * There are two kinds of list: argument lists, which push all item values onto
     * the stack, and expression lists, which leave only the last value on the stack.
     * This function only implements the former behavior. Distinguish between node in
     * these two kinds of lists.
     */

    public Value evaluate(Context cx, ArgumentListNode node)
    {

        if (debug)
        {
            System.out.print("\n// +ArgumentList");
        }

        if (!traverse_argslist_right_to_left)
        {
	        for (int i = 0, size = node.items.size(); i < size; i++)
            {
	            Node item = node.items.get(i);
                item.evaluate(cx, this);
            }
        }
        else
        {
            for (int i = node.items.size() - 1; i >= 0; i--)
            {
                Node item = node.items.get(i);
                item.evaluate(cx, this);
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

	    for (int i = 0, size = node.items.size(); i < size; i++)
        {
	        Node item = node.items.get(i);
            item.evaluate(cx, this);
        }

        if (debug)
        {
            System.out.print("\n// -List");
        }
        return null;
    }

    /* Statements
     */

    public Value evaluate(Context cx, StatementListNode node)
    {
        if (debug)
        {
            System.out.print("\n// +StatementListNode");
        }

        int temp_count = getTempCount();

        for (Node item : node.items)
        {
            if (!doingMethod())
            {
                // We are done with definitions, which means we are doing
                // program statements.
                StartMethod(frame.functionName, frame.maxParams, frame.maxLocals, frame.maxTemps,
                            frame.activationIsExposed, frame.needsArguments);
                // Now we are doing a method
            }
            if (item != null) // ISSUE: not sure why item == 0, but it is
            {
                item.evaluate(cx, this);
            }
        }

        // ISSUE: This is a hack to free temps allocated dynamically in the
        // constituent nodes. Design a cleaner way to free this nodes

        for( int i = getTempCount(); i > temp_count; --i )
        {
            freeTemp(i-2);
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

        // Leave the previous completion value on the stack

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
            if (node.expected_type != cx.voidType())
            {
            }
            node.expr.evaluate(cx, this);
            if( node.expected_type != cx.voidType() )
            {
                if( cx.getScopes().size() == 1 && temp_cv_reg != -1)
                {
                    // coerce the continuation value to Object now so all sets are compatible types
                    int scope_depth = cx.getScopes().size()-1;
                    int reg_offset  = cx.scope(scope_depth).builder.reg_offset;
                    CheckType(cx.noType().name);
                    StoreRegister(reg_offset+temp_cv_reg,cx.noType().getTypeId());
                }
                else
                {
                    Pop();   // should never get here, but this will fix the problem if we do
                    //cx.internalError("internal error");  // and we do
                }
            }
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

        if (node.statement != null)
        {
            // If the label is a loop label, then let the loop handle the patchbreak/continue.  Since the label and
            // the loop share the same loop index this will work out fine (and actually creates problems if we try
            // and do it in both places).
            if( !node.is_loop_label )
                LabelStatementBegin();
            node.statement.evaluate(cx, this);
            if( !node.is_loop_label )
                LabelStatementEnd(node.loop_index);
        }

        if (debug)
        {
            System.out.print("\n// -LabeledStatementNode");
        }
        return null;
    }

    void If( Context cx, Node expr )
    {
        // check if the condition matches one of the supported if comparisions
        ListNode ln;
        CoerceNode cn;
        BinaryExpressionNode ben = null;

        ln = expr instanceof ListNode ? (ListNode)expr : null;
        if( ln != null )
        {
            Node temp = ln.items.last();
            cn = temp instanceof CoerceNode ? (CoerceNode)temp : null;
            if( cn != null )
            {
                ben = cn.expr instanceof BinaryExpressionNode ? (BinaryExpressionNode)cn.expr : null;
            }
            else
            {
                ben = temp instanceof BinaryExpressionNode ? (BinaryExpressionNode)temp : null;
            }
        }

        int kind = IF_false;
        if( ben != null )
        {
            switch( ben.slot.getMethodID() )
            {
                case BINARY_LessThanOp:
                if( HAS_IF_nlt )
                {
                    kind = IF_nlt;
                }
                break;
                case BINARY_GreaterThanOp:
                if( HAS_IF_ngt )
                {
                    kind = IF_ngt;
                }
                break;
                case BINARY_LessThanOrEqualOp:
                if( HAS_IF_nle )
                {
                    kind = IF_nle;
                }
                break;
                case BINARY_GreaterThanOrEqualOp:
                if( HAS_IF_nge )
                {
                    kind = IF_nge;
                }
                break;
                case BINARY_EqualsOp_II:
                case BINARY_EqualsOp:
                if( HAS_IF_ne )
                {
                    kind = IF_ne;
                }
                break;
                case BINARY_NotEqualsOp_II:
                case BINARY_NotEqualsOp:
                if( HAS_IF_eq )
                {
                    kind = IF_eq;
                }
                break;
                case BINARY_StrictEqualsOp_II:
                case BINARY_StrictEqualsOp:
                if( HAS_IF_strictne )
                {
                    kind = IF_strictne;
                }
                break;
                case BINARY_StrictNotEqualsOp_II:
                case BINARY_StrictNotEqualsOp:
                if( HAS_IF_stricteq )
                {
                    kind = IF_stricteq;
                }
                break;
                default:
                //assert(HAS_IF_false);
                kind = IF_false;
            }
        }

        switch( kind )
        {
            case IF_lt:
            case IF_ge:
            case IF_le:
            case IF_gt:
            case IF_eq:
            case IF_ne:
            case IF_stricteq:
            case IF_strictne:
            case IF_nlt:
            case IF_nge:
            case IF_nle:
            case IF_ngt:
                ben.lhs.evaluate(cx,this);
                ben.rhs.evaluate(cx,this);
                If(kind);
                break;
            default:
                expr.evaluate(cx,this);
                If(kind);  // if false, jump past then actions
                break;
        }
    }

    public Value evaluate(Context cx, IfStatementNode node)
    {
        if (debug)
        {
            System.out.print("\n// +IfStatementNode");
        }

        if( node.is_true )
        {
            if( node.thenactions != null )
            {
                node.thenactions.evaluate(cx,this);
            }
        }
        else
        if( node.is_false )
        {
            if( node.elseactions != null )
            {
                node.elseactions.evaluate(cx,this);
            }
        }
        else
        {
            If(cx,node.condition);
            if (node.thenactions != null)
            {
                // If this block defines _cv, and there is no else that does, then
                // pop the current value off the stack to keep it balanced

                node.thenactions.evaluate(cx, this);
            }
            if (node.elseactions != null)
            {
                if (node.thenactions == null || node.thenactions.inTerminalBlock() == false)
                    Else(); // jump past else actions
                //else
                //    System.out.print("\n// +IfStatementNode, skiping Else jump");

                PatchIf(getIP());  // patch target of if jump
                node.elseactions.evaluate(cx, this);

                if (node.thenactions == null || node.thenactions.inTerminalBlock() == false)
                    PatchElse(getIP()); // patch target of else jump
            }
            else
            {
                PatchIf(getIP());  // patch target of if jump
            }
        }

        if (debug)
        {
            System.out.print("\n// -IfStatementNode");
        }
        return null;
    }

    public Value evaluate(Context cx, SwitchStatementNode node)
    {
        if (debug)
        {
            System.out.print("\n// +SwitchStatementNode");
        }

        int reg_offset = getRegisterOffset(cx);

        case_exprs.add(new ObjectList<Node>());
        SwitchBegin();                    // jump past statements
        if (node.statements != null)
        {
            node.statements.evaluate(cx, this);
        }

        // See if there is a default case. If not, then add one.

        {
            ObjectList<Node> case_expr = case_exprs.last();
            int i = 0, size = case_expr.size();
            for (; i < size && case_expr.get(i) != null; i++)
            {
                ;
            }
            if (i == size)
            {
                case_expr.add(null);
                CaseLabel(true);  // default, just in case there wasn't one yet.
            }
        }

        // ISSUE: use a flag to determine if the last case has a break statement.

        Break(node.loop_index);              // Last chance break, in case there isn't one
        PatchSwitchBegin(getIP());            // patches initial jump past statements
        node.expr.evaluate(cx, this);        // leaves value of governing expr on stack

        {
            int temp_reg = allocateTemp();
            StoreRegister(reg_offset+temp_reg, TYPE_none);
            int case_index = 0;
            int default_index = 0;
            ObjectList<Boolean> patch_else = new ObjectList<Boolean>();

            if (case_exprs.last().size() != 0)
            {
                int case_exprs_size = case_exprs.last().size();
                for (case_index = 0; case_index < case_exprs_size; ++case_index)
                {
                    Node expr = case_exprs.last().get(case_index);
                    if (expr != null)
                    {  // skip default ( expr == 0 )
                        /* do operands */
                        expr.evaluate(cx, this);
                        LoadRegister(reg_offset+temp_reg, TYPE_none);
                        If(IF_strictne);
                    }
                    else
                    {
                        PushBoolean(false);
                        If(IF_false);
                        default_index = case_index;
                    }
                    PushCaseIndex(case_index);
                    if (expr == null || expr.inTerminalBlock() == false)
                    {
                        Else(); // jump past else actions
                        patch_else.push_back(true);
                    }
                    else
                    {
                        patch_else.push_back(false);

                       //System.out.print("\n// +switch case, skiping Else jump");

                    }

                    PatchIf(getIP());  // patch target of if jump
                }
            }
            PushCaseIndex(default_index);
            while (case_index-- != 0)
            {
                if (patch_else.back() == true)
                    PatchElse(getIP()); // patch target of else jumps
                patch_else.pop_back();

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
            case_exprs.removeLast();
            freeTemp(temp_reg); // temp_reg
        }
        SwitchTable();                        // jumps to addr for case index
        PatchBreak(node.loop_index); // patches jump past switch table
        // Even though there are no continues in switch statements,
        // do this to pop the empty continue_addrs vector.

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

        case_exprs.last().add(node.label);
        CaseLabel(node.label == null); // indicate if is default

        if (debug)
        {
            System.out.print("\n// -CaseLabelNode");
        }
        return null;
    }

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
            node.statements.evaluate(cx, this);
        }
        PatchContinue(node.loop_index);
        LoopEnd(cx,node.expr);
        PatchBreak(node.loop_index);

        if (debug)
        {
            System.out.print("\n// -DoStatementNode");
        }
        return null;
    }

    void LoopEnd( Context cx, Node expr )
    {
        if( expr == null )
        {
            PushBoolean(true);
            LoopEnd(IF_true);
        }
        else
        {
            int kind = IF_true;

            // check if the condition matches one of the supported if comparisions
            ListNode ln;
            CoerceNode cn;
            BinaryExpressionNode ben = null;

            ln = expr instanceof ListNode ? (ListNode)expr : null;
            if( ln != null )
            {
                Node temp = ln.items.last();
                cn = temp instanceof CoerceNode ? (CoerceNode)temp : null;
                if( cn != null )
                {
                    ben = cn.expr instanceof BinaryExpressionNode ? (BinaryExpressionNode)cn.expr : null;
                }
                else
                {
                    ben = temp instanceof BinaryExpressionNode ? (BinaryExpressionNode)temp : null;
                }
            }

            if( ben != null )
            {
                switch( ben.slot.getMethodID() )
                {
                    case BINARY_LessThanOp:
                        if( HAS_IF_lt )
                        {
                            kind = IF_lt;
                        }
                        break;
                    case BINARY_GreaterThanOp:
                        if( HAS_IF_gt )
                        {
                            kind = IF_gt;
                        }
                        break;
                    case BINARY_LessThanOrEqualOp:
                        if( HAS_IF_le )
                        {
                            kind = IF_le;
                        }
                        break;
                    case BINARY_GreaterThanOrEqualOp:
                        if( HAS_IF_ge )
                        {
                            kind = IF_ge;
                        }
                        break;
                    case BINARY_EqualsOp_II:
                    case BINARY_EqualsOp:
                        if( HAS_IF_eq )
                        {
                            kind = IF_eq;
                        }
                        break;
                    case BINARY_NotEqualsOp_II:
                    case BINARY_NotEqualsOp:
                        if( HAS_IF_ne )
                        {
                            kind = IF_ne;
                        }
                        break;
                    case BINARY_StrictEqualsOp_II:
                    case BINARY_StrictEqualsOp:
                        if( HAS_IF_stricteq )
                        {
                            kind = IF_stricteq;
                        }
                        break;
                    case BINARY_StrictNotEqualsOp_II:
                    case BINARY_StrictNotEqualsOp:
                        if( HAS_IF_strictne )
                        {
                            kind = IF_strictne;
                        }
                        break;
                    default:
                        //assert(HAS_IF_false);
                        kind = IF_true;
                }
            }
            switch( kind )
            {
                case IF_lt:
                case IF_ge:
                case IF_le:
                case IF_gt:
                case IF_eq:
                case IF_ne:
                case IF_stricteq:
                case IF_strictne:
                case IF_nlt:
                case IF_nge:
                case IF_nle:
                case IF_ngt:
                    ben.lhs.evaluate(cx,this);
                    ben.rhs.evaluate(cx,this);
                    LoopEnd(kind);
                    break;
                default:
                    expr.evaluate(cx,this);
                    LoopEnd(IF_true);
                    break;
            }
        }
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
            node.statement.evaluate(cx, this);
        }
        PatchLoopBegin(getIP());
        PatchContinue(node.loop_index);
        LoopEnd(cx,node.expr);
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

        int temp_count = getTempCount();

        if (node.initialize != null)
        {
            node.initialize.evaluate(cx, this);
        }
        LoopBegin();
        if (node.statement != null)
        {
            node.statement.evaluate(cx, this);
        }
        PatchContinue(node.loop_index);
        if (node.increment != null)
        {
            node.increment.evaluate(cx, this);
        }
        PatchLoopBegin(getIP());
        LoopEnd(cx,node.test);
        PatchBreak(node.loop_index);

        // ISSUE: This is a hack to free temps allocated dynamically in the
        // constituent nodes. Design a cleaner way to free this nodes

        for( int i = getTempCount(); i > temp_count; --i )
        {
            freeTemp(i-2);
        }

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

        int reg_offset = getRegisterOffset(cx);
        int with_object_reg = allocateTemp();

        // Save the with object in case we need to restore the scope
        // in an exception handler
        Dup();
        StoreRegister(reg_offset+with_object_reg, TYPE_none);

        WithBuilder withBuilder = (WithBuilder)node.activation.builder;
        withBuilder.temp_reg = with_object_reg;

        cx.pushScope(node.activation);

        PushWith();

        if (node.statement != null)
        {
            boolean saved_in_with = in_with;
            in_with = true;

            int saveWithDepth = cx.statics.withDepth;
            cx.statics.withDepth = cx.getScopes().size()-1;

            node.statement.evaluate(cx, this);

            in_with = saved_in_with;

            cx.statics.withDepth = saveWithDepth;
        }

        PopWith();

        cx.popScope();

        freeTemp(with_object_reg);

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

        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }

        if (isAnyFinallyPresent())
        {
            // Pop catch scope if needed
            if (cx.scope().builder instanceof CatchBuilder)
            {
                CatchBuilder catchBuilder = (CatchBuilder) cx.scope().builder;
                PopScope();
                Kill(catchBuilder.temp_reg);
            }

            int reg_offset = -1;
            int temp_index_reg = -1;
            if( node.expr != null )
            {
	            // Save the object to be returned, can't leave it on the stack because then stack depths
	            // wouldn't match when jumping to the finally block at the normal end of the try block
	            reg_offset = getRegisterOffset(cx);
	            temp_index_reg = allocateTemp();
	            CheckType(cx.noType().name);
	            StoreRegister(reg_offset + temp_index_reg, TYPE_none);
            }
            // Invoke finally handler
            CallFinally(-1);

            if( node.expr != null )
            {
	            // Restore the return value
	            LoadRegister(reg_offset+temp_index_reg, TYPE_none);
	            // Nuke the temp
	            freeTemp(temp_index_reg);
            }
        }
        if( node.expr != null )
        {
            // return value is on stack
            Return(TYPE_none);
        } 
        else
        {
            // no return value expr
            Return(TYPE_void);
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

        if (isFinallyPresent() && !exceptionState.ignoreThrows)
        {
            // Pop catch scope if needed
            if (cx.scope().builder instanceof CatchBuilder)
            {
                CatchBuilder catchBuilder = (CatchBuilder) cx.scope().builder;
                PopScope();
                Kill(catchBuilder.temp_reg);
            }

            // Save the object to be thrown, can't leave it on the stack because then stack depths
            // wouldn't match when jumping to the finally block at the normal end of the try block
            int reg_offset = getRegisterOffset(cx);
            int temp_index_reg = allocateTemp();
            CheckType(cx.noType().name);
            StoreRegister(reg_offset + temp_index_reg, TYPE_none);

            // Invoke finally handler
            CallFinally(1);

            // Restore the exception object
            LoadRegister(reg_offset+temp_index_reg, TYPE_none);
            // Nuke the temp
            freeTemp(temp_index_reg);

        }

        Throw();

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

        boolean inside_finally = isInsideFinally();
        ExceptionState saveExceptionState = exceptionState;
        exceptionState = new ExceptionState();

        // propagate any outer try/finally's since returns/breaks may have to call them as well as this finally
        if( saveExceptionState != null )
            exceptionState.anyFinallyPresent = saveExceptionState.anyFinallyPresent;

        if (node.finallyblock != null)
        {
            exceptionState.anyFinallyPresent = true;
            Try(true);
        }

        Try(false);

        int reg_offset = getRegisterOffset(cx);
        int temp_index_reg = -2;

        exceptionState.ignoreThrows = true;
        if (node.tryblock != null)
        {
            if( inside_finally )
            {
                // We're nested inside a finally, which will have a return index pushed on the stack
                // store it in a register so we don't get an unbalanced stack when jumping past the catch blocks
                temp_index_reg = allocateTemp();
                CheckType(cx.noType().name);
                StoreRegister(reg_offset + temp_index_reg, TYPE_int);
            }

            node.tryblock.evaluate(cx, this);

        }

        CatchClausesBegin();

        if (node.catchlist != null)
        {
            node.catchlist.evaluate(cx, this);
        }

        // This is where the ends of try and catch blocks jump to.
        CatchClausesEnd();

        exceptionState.ignoreThrows = false;

        // Finish up with the inner try block
        FinallyClauseBegin();
        FinallyClauseEnd();

        // Prep for finally block if present
        if (node.finallyblock != null)
        {
            // Jump index
            PushNumber(new IntNumberConstant(-1), TYPE_int);

            CatchClausesBegin();

            exceptionState.finallyPresent = true;
            node.finallyblock.default_catch.evaluate(cx, this);

            CatchClausesEnd();

            FinallyClauseBegin();

            exceptionState.finallyPresent = false;
            exceptionState.insideFinally = true;
            node.finallyblock.evaluate(cx, this);

            FinallyClauseEnd();
        }

        if( temp_index_reg > -2 )
        {
            // Put the return index back on the stack
            LoadRegister(reg_offset+temp_index_reg, TYPE_int);
            CheckType(cx.intType().name);
            // Nuke the temp
            freeTemp(temp_index_reg);
        }

        // Pop exception state
        exceptionState = saveExceptionState;

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

        int reg_offset = getRegisterOffset(cx);

        // get scope relative offsets
        ObjectValue obj = node.activation;
        Builder bui = obj.builder;
        int var_offset = bui.var_offset;

        Slot slot = null;
        TypeInfo type = null;
        QName qname = null;

        cx.pushScope(node.activation);

        if (node.parameter instanceof ParameterNode)
        {
            // get param info
            ParameterNode parameter = (ParameterNode) node.parameter;
            slot = parameter.ref.getSlot(cx, GET_TOKEN);
            type = slot.getType();

            qname = new QName(cx.publicNamespace(), parameter.ref.name);
        } else
        {
            type = cx.noType().getDefaultTypeInfo();
        }

        Catch(type.getTypeValue(), qname);

        // Restore "this" if in a method that uses this
        if (frame.withThis)
        {
            LoadThis();
            PushScope();
        }

        // Restore scopes
        for (int i = frame.firstInnerScope, n = cx.getScopes().size(); i < n; i++)
        {
            Builder builder = cx.scope(i).builder;
            int temp_reg = builder.temp_reg;
            if (temp_reg != -1)
            {
                LoadRegister(temp_reg + reg_offset, TYPE_none);
                if (builder instanceof WithBuilder)
                {
                    PushWith();
                } else
                {
                    PushScope();
                }
            }
        }

        int temp_activation_reg = -1;

        // Generate code to push the exception scope's activation object
        NewCatch(frame.catchIndex);
        Dup();

        // Store the catch activation object
        temp_activation_reg = allocateTemp();
        node.activation.builder.temp_reg = temp_activation_reg;
        StoreRegister(reg_offset + temp_activation_reg, TYPE_none);

        if (qname != null)
        {
            Dup();
        }

        PushScope();

        if (qname != null)
        {
            // Store the exception variable
            Swap();
            StoreVar(slot.getVarIndex() + var_offset);
        }

        frame.catchIndex++;

        if (node.statements != null)
        {
            node.statements.evaluate(cx, this);
        }


        if (isFinallyPresent())
        {
            PushNumber(new IntNumberConstant(-1), TYPE_int);
        }


        PopScope();
        freeTemp(temp_activation_reg);

        cx.popScope();

        if (debug)
        {
            System.out.print("\n// -CatchClauseNode");
        }

        return null; // throw;
    }

    public Value evaluate(Context cx, FinallyClauseNode node)
    {
        if (debug)
        {
            System.out.print("\n// +FinallyClauseNode");
        }

        node.statements.evaluate(cx, this);

        if (debug)
        {
            System.out.print("\n// -FinallyClauseNode");
        }
        return null;
    }

    public Value evaluate(Context cx, VariableDefinitionNode node)
    {
        if (debug)
        {
            System.out.print("\n// +VariableDefinitionNode");
        }

        if( node.pkgdef != null && cx.getScopes().size() == 1 )
        {
            used_namespaces_sets.push_back(node.pkgdef.used_namespaces);
        }

        for(Node it : node.list.items)
        {
            VariableBindingNode binding = it instanceof VariableBindingNode ? (VariableBindingNode)it : null;
            if (binding != null)
            {
                ReferenceValue ref;
                Slot slot;
                if ( (ref = binding.ref) == null)
                    ; // no good
                else if ( (slot = ref.getSlot(cx)) == null )
                    ; // no good
                else if (slot.getVarIndex() < 0)
                    ; // no good
                else
                {
                    boolean onActivationObject   = frame.activationIsExposed;
                    TypeInfo expr_type      = binding.ref.getType(cx);
                    int  base_index           = binding.ref.getScopeIndex(GET_TOKEN);

                    Builder basebui          = base_index >= 0 ? cx.scope(base_index).builder : null;
                    boolean is_globalref         = base_index == 0;

                    boolean isInheritedSlot = (slot.declaredBy != cx.scope(base_index));

                    // If we're doing the constructor, don't call DefineSlotVariable for the instance inits because they
                    // are slots on the instance, and they could end up overwriting arguments/locals in the constructor body
                    boolean isInstanceInit = basebui instanceof InstanceBuilder && cx.scope().builder instanceof ActivationBuilder;

                    if (!is_globalref && !isInheritedSlot && !onActivationObject && !isInstanceInit)
                    {
                        if (basebui != null)
                        {
                            //int reg_offset = basebui.reg_offset;
                            //setOrigin(cx.input.source());
                            if (cx.input != null)
                            {
                                setPosition(cx.input.getLnNum(binding.pos()),
                                            cx.input.getColPos(binding.pos()), binding.pos());
                            }
                            DefineSlotVariable(cx, binding.ref.name, binding.debug_name, binding.pos(),
                                                expr_type, (slot.getVarIndex()));
                        }
                    }
                }
            }
        }

        if( node.pkgdef != null && cx.getScopes().size() == 1 )
        {
            used_namespaces_sets.pop_back();
        }

        if (debug)
        {
            System.out.print("\n// -VariableDefinitionNode");
        }
        return null; // Do nothing
    }

    public Value evaluate(Context cx, BinaryFunctionDefinitionNode node)
    {
        return null; // Do nothing
    }

    public Value evaluate(Context cx, FunctionDefinitionNode node)
    {
        if (debug)
        {
            System.out.print("\n// +FunctionDefinitionNode");
        }

        if( node.pkgdef != null && cx.getScopes().size() == 1 )
        {
            used_namespaces_sets.push_back(node.pkgdef.used_namespaces);
        }

        Builder builder = cx.scope().builder;
        boolean class_method = (builder instanceof ClassBuilder ||
                                builder instanceof InstanceBuilder);

        if( !class_method && node.needs_init )
        {
            node.init.evaluate(cx,this);
            node.needs_init = false;
        }

        if( node.pkgdef != null && cx.getScopes().size() == 1 )
        {
            used_namespaces_sets.pop_back();
        }

        if (debug)
        {
            System.out.print("\n// -FunctionDefinitionNode");
        }
        return null; // Do nothing
    }

    public Value evaluate(Context unused_cx, FunctionCommonNode node)
    {
        if (debug)
        {
            System.out.print("\n// +FunctionCommonNode");
        }

        Context cx = node.cx; // switch to original context

	// getQualifiedErrorOrigin defaults to getErrorOrigin if
	// the qualified_origin isn't set - this is used to prevent
	// naming conflicts in the debug info for authoring (i.e.,
	// multiple scripts with the name "frame1"
        setOrigin(cx.getQualifiedErrorOrigin());

        if (cx.input != null)
        {
            setPosition(cx.input.getLnNum(node.pos()),cx.input.getColPos(node.pos()),node.pos());
        }

        if (doingMethod())
        {
            boolean anon_with_identifier = node.isNamedInnerFunc(); 
            if( anon_with_identifier )
            {
                NewObject(0);
                PushWith();
            }
            NewFunctionObject(node.internal_name);
            
            if( anon_with_identifier )
            {
                if ( !node.isVoidResult() ) {
                    Dup();
                }
                GetBaseObject(cx.getScopeDepth()-frame.firstInnerScope);
                Swap();
                SetProperty(node.identifier.name, new Namespaces(cx.publicNamespace()), true, false, false, false);
                PopScope();
            }
            else
            if ( node.isVoidResult() ) {
                Pop();
            }

            return null;  // defer until the current method is done.
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

        Slot getSlot = node.ref.getSlot(cx, GET_TOKEN);
        Slot setSlot = node.ref.getSlot(cx, SET_TOKEN);
        boolean with_this = getSlot instanceof MethodSlot || setSlot instanceof MethodSlot;

        ObjectValue fun = node.fun;
        cx.pushScope(fun.activation);

        // Do nested functions
        boolean needs_activation = false;

        if( node.fexprs.size() > 0 )
        {
            needs_activation = true;
        }
        if (node.isWithUsed())
        {
                needs_activation = true;
        }
        if (node.isExceptionsUsed())
        {
                needs_activation = true;
        }

/*
        for (int i = (node.fexprs == null) ? -1 : node.fexprs.size() - 1; i >= 0; i--)
        {
            Node fexpr = node.fexprs.get(i);
            fexpr.evaluate(cx, this);
        }
*/

        used_namespaces_sets.push_back(node.used_namespaces);

        for (FunctionCommonNode def : node.fexprs)
        {
            def.evaluate(cx, this);
        }

        // reset debug position.  nested Function evaulation above will have updated it, we need to reset to top of this function.
        if (cx.input != null)
        {
            setPosition(cx.input.getLnNum(node.pos()),cx.input.getColPos(node.pos()),node.pos());
        }

        pushStackFrame();

        frame.functionName = node.internal_name;
        frame.maxParams = node.signature.size();
        frame.maxLocals = node.body != null ? node.var_count : 0;
        frame.maxTemps = node.body != null ? node.temp_count : 0;
        frame.needsArguments = node.needsArguments;

        frame.withThis = with_this;

        frame.firstInnerScope = cx.getScopes().size()-1;
        if (with_this)
        {
            frame.firstInnerScope--;
        }

        // If there are nested functions, this will be true
        frame.activationIsExposed = needs_activation;
        frame.registerScopeIndex = needs_activation ? -1 : (cx.getScopes().size()-1);

        StartMethod(frame.functionName,frame.maxParams,frame.maxLocals,0,needs_activation,node.needsArguments);

        // If this is a constructor, then insert a call to the base constructor,
        // and the instance initializer

        if( "$construct".equals(node.ref.name) && cx.statics.es4_nullability  )
        {
        	// Must run property initializers before this, or activation scope is pushed.  Setting properties
        	// will be handled with getlocal0, setproperty and arguments will use getlocal since there can be no intervening
        	// scopes at this point (even if the method later needs an activation object)
            doCtorSetup(node, cx, needs_activation);
        }
        if (with_this)
        {
            LoadThis();
            PushScope();
        }

        // initialize local variables that are in registers.

        ObjectValue activation = node.fun.activation;
        int firstlocal = node.signature.size();
        if (node.needsArguments != 0)
        {
            firstlocal++;
        }
        int reg_offset = activation.builder.reg_offset;
        int var_offset = activation.builder.var_offset;

        if (needs_activation)
        {
            NewActivation();
            int temp_activation_reg = allocateTemp();
            activation.builder.temp_reg = temp_activation_reg;
            Dup();
            StoreRegister(reg_offset+temp_activation_reg,TYPE_none);
            PushScope();

			// create a 'local' name for the activation object for the debugger to use
			DefineSlotVariable(cx, node.internal_name, node.debug_name, node.pos(), ObjectValue.objectPrototype.type, temp_activation_reg);
        }

        if (activation.slots != null)
        {
            int base_offset = needs_activation ? var_offset : reg_offset;

            for (Slot s: activation.slots)
            {
                int index = base_offset + s.getVarIndex();
                if ( s.needsInit() &&  s.getVarIndex() >= firstlocal)
                {
                    StoreDefaultValue(cx, index, s, needs_activation);
                }
            }
        }

        if (needs_activation)
        {
            // Copy the arguments into the activation object
            int n=frame.maxParams;
            if (node.needsArguments != 0) n++;
            for (int i=0; i<n; i++)
            {
                GetActivationObject(cx.getScopes().size()-1);
                LoadRegister(i+1,TYPE_object);
                StoreVar(i);
            }
        }

        // for debug purposes dump out the list of args
        ParameterListNode parms = node.signature.parameter;
        String[] arg_names = null;
		if (parms != null)
		{
            arg_names = new String[parms.items.size()];
			for(int i = 0; i < parms.items.size(); ++i )
            {
                ParameterNode parm = parms.items.at(i);
				ReferenceValue ref;
				Slot slot;
				if (parm == null)
					; // no good
				else if ((ref = parm.ref) == null)
					; // no good
				else if ((slot = ref.getSlot(cx)) == null)
					; // no good
				else
				{
					TypeInfo expr_type = ref.getType(cx);
					DefineSlotVariable(cx, ref.name, ref.name, pos, expr_type, slot.getVarIndex());
                    arg_names[i] = ref.name;
				}
			}
		}

        if( "$construct".equals(node.ref.name) && !cx.statics.es4_nullability  )
        {
            doCtorSetup(node, cx, needs_activation);
        }

        if( node.body != null)
        {
            if( node.default_dxns != null )
            {
                node.default_dxns.evaluate(cx,this);
            }
            boolean old_in_anonymous_function = this.in_anonymous_function;
            this.in_anonymous_function = (node.isFunctionDefinition() == false); // set flag if we are processing an anonymous function
            node.body.evaluate(cx,this);
            this.in_anonymous_function = old_in_anonymous_function;
        }

        if (cx.input != null)
        {
            setPosition(cx.input.getLnNum(node.signature.pos()),cx.input.getColPos(node.signature.pos()),node.signature.pos());
        }

        // If there is a nested function, then pass the activation object so traits can be emitted
        if (!needs_activation)
            activation = null;
            // ISSUE: this logic can be more subtle. We also might need the activation
            // if there is an embedded eval or with. And we might not need the activation
            // object for all functions with nested functions

		int scope_depth = activation != null ? cx.getScopes().size() : cx.getScopes().size()-1;
		TypeInfo type = node.signature.type;
		ObjectList<TypeInfo> types = node.signature.parameter!=null?node.signature.parameter.types:null;
		node.fun.method_info = FinishMethod(cx,
				frame.functionName,
				type,
				types,
				activation,
				node.needsArguments,
				scope_depth,
				node.debug_name,
				node.isNative(),
				(currentClass instanceof InterfaceDefinitionNode),
                arg_names);

        cx.popScope();
        this.is_ctor = false;
        // We don't need this or the activation builder anymore
        node.fun.activation = null;
        // don't need the FunctionBuilder anymore either
        node.fun.builder = null;
        
        popStackFrame();

        if( saved_scopes != null )
        {
            cx.swapScopeChain(saved_scopes);
        }
        cx.statics.withDepth = savedWithDepth;

        // Call code is compiled as though register 0 is the scope
        // stack, register 1 is the current object, register 2 is the
        // args array, and registers 2 through 2+n-1 (where n is the
        // count of formal parameters) are the formal parameters.

        used_namespaces_sets.pop_back();

        if (debug)
        {
            System.out.print("\n// -FunctionCommonNode");
        }
        return null;
    }

	private void doCtorSetup(FunctionCommonNode node, Context cx, boolean needs_activation) {
		// Call super constructor
		this.is_ctor = true;
		int scope_depth = cx.getScopes().size();
		ObjectValue iframe = cx.scope(scope_depth-2);
		InstanceBuilder ib = iframe.builder instanceof InstanceBuilder ? (InstanceBuilder) iframe.builder : null;

		/* // Invoke iinit

		int method_info = GetMethodInfo(iframe.builder.classname+"$iinit");

		LoadThis();
		InvokeMethod(false,method_info,0);
		Pop();
		*/

		// inline iinit

		if( cx.statics.es4_nullability )
		{
		    if( needs_activation )
		    {
		    	// have to turn off needs activation for now, so that arguments can be accessed as local registers
		        frame.activationIsExposed = false;
		        frame.registerScopeIndex = (cx.getScopes().size()-1);
		    }
		}

		// Generate code for the class and instance initializers.
		{
		    for (Node def : currentClass.instanceinits)
		    {
		        // don't emit code for initializers that have constant values
		        // FIXME: is there a more general way for this that will get
		        // static/function/script initializers too?
		        removeConstantInitializers(cx, def);
		        
		        if( cx.statics.es4_nullability && !def.isDefinition() )
		        	iframe.setInitOnly(true);
		        
		        def.evaluate(cx, this);

		        if( cx.statics.es4_nullability && !def.isDefinition() )
		        	iframe.setInitOnly(false);
		        
		        clearPositionInfo();
		    }
		}

		// This should fix the cases when there is stale line number.
		clearPositionInfo();
		
		// reset the position to the beginning of the function, since the position may be left at the last instanceInit,
		// which may not have generated any code (e.g., FunctionDefinitionNode)
        if (cx.input != null)
        {
            setPosition(cx.input.getLnNum(node.signature.pos()),cx.input.getColPos(node.signature.pos()),node.signature.pos());
        }

		if( node.signature.inits != null )
		{
			iframe.setInitOnly(true);
			node.signature.inits.evaluate(cx, this);
			iframe.setInitOnly(false);
		}

		if( cx.statics.es4_nullability  )
		{
		    if( needs_activation )
		    {
		    	// Turn it back on so that the rest of the method codegens correctly
		        frame.activationIsExposed = true;
		        frame.registerScopeIndex = -1;
		    }
		}
		
		if (ib.basebui != null && !ib.calls_super_ctor)
		{
		    LoadThis();
		    InvokeSuper(true, 0);
		}
	}

    public Value evaluate(Context cx, ProgramNode node)
    {
        if (debug)
        {
            System.out.print("\n// +ProgramNode");
        }

        used_namespaces_sets.push_back(node.used_def_namespaces);

        setOrigin(cx.getErrorOrigin());

        StartProgram(getProgramName(cx));

        for (int i = (node.fexprs == null) ? -1 : node.fexprs.size() - 1; i >= 0; i--)
        {
            Node fexpr = node.fexprs.get(i);
            fexpr.evaluate(cx, this);
        }

        for (ClassDefinitionNode def : node.clsdefs)
        {
            def.evaluate(cx, this);
            cx.scope().getDeferredClassMap().put(def.cframe, def);
        }

        /* The body of this script is put in a function called run, which
         * takes two parameters: scope, and thisobj.
         */

        pushStackFrame();

        frame.functionName = "$init";
        frame.maxParams = 0;
        frame.maxLocals = node.var_count;  // Should always be zero.
        frame.maxTemps = node.temp_count;

        // Global scope is special
        frame.activationIsExposed = false;
        frame.withThis = true;
        frame.firstInnerScope = cx.getScopes().size()-1;
        frame.registerScopeIndex = -1;

        StartMethod(frame.functionName, frame.maxParams, frame.maxLocals);
        clearPositionInfo();
        if (node.statements.definesCV() && node.statements.was_empty != true)
        {
            temp_cv_reg = allocateTemp();
        }
        else
        {
            temp_cv_reg = -1;
        }

        LoadThis();
        PushScope();

        boolean startedMethod = false;

        if (node.statements != null)
        {
            for (PackageDefinitionNode def : node.pkgdefs)
            {
                def.evaluate(cx, this);
            }

            node.statements.evaluate(cx, this);
        }
        else
        {
            StartMethod(frame.functionName, frame.maxParams, frame.maxLocals);
            startedMethod = true;
        }

        int reg_offset = getRegisterOffset(cx);
        if (temp_cv_reg != -1)
        {
            LoadRegister(reg_offset+temp_cv_reg,cx.noType().getTypeId());
            Return(TYPE_none);
            freeTemp(temp_cv_reg); // temp_cv_reg
        }
        else
        {
            Return(TYPE_void);
        }

        if (startedMethod)
        {
            clearPositionInfo();
        }

		setPosition(0, 0, 0);
		int init_info = FinishMethod(cx,"$init",null,null,null,0,cx.getScopes().size(),"",false,false, null);

        FinishProgram(cx,getProgramName(cx),init_info);

        used_namespaces_sets.pop_back();

        popStackFrame();

        if (debug)
        {
            System.out.print("\n// -ProgramNode");
        }
        return null;
    }

    public Value evaluate(Context unused_cx, PackageDefinitionNode node)
    {
        if (debug)
        {
            System.out.print("\n// +PackageDefinitionNode");
        }

        if (debug)
        {
            System.out.print("\n// -PackageDefinitionNode");
        }
        return null;
    }

    // Un-used nodes

    public Value evaluate(Context cx, Node node)
    {
        assert(false);
        return null; // throw "Should never get here!";
    }

    public Value evaluate(Context cx, IdentifierNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, VariableBindingNode node)
    {
        //throw "Should never get here!";
        return null;
    }

    public Value evaluate(Context cx, FunctionNameNode node)
    {
        assert(false);
        return null; // throw "Should never get here!";
    }

    public Value evaluate(Context cx, FunctionSignatureNode node)
    {
        assert(false);
        return null; // throw "Should never get here!";
    }

    public Value evaluate(Context cx, ParameterNode node)
    {
        assert(false);
        return null; // throw "Should never get here!";
    }

    public Value evaluate(Context cx, ParameterListNode node)
    {
        assert(false);
        return null; // throw "Should never get here!";
    }

    public Value evaluate(Context cx, ToObjectNode node)
    {
        node.expr.evaluate(cx, this);
        ToObject();
        return null;
    }

    public Value evaluate(Context cx, LoadRegisterNode node)
    {
        node.reg.evaluate(cx,this);
        int reg_offset = getRegisterOffset(cx);
        if (!node.void_result)
        {
            LoadRegister(reg_offset+node.reg.index,node.type.getTypeId());
        }
        return null;
    }

    public Value evaluate(Context cx, StoreRegisterNode node)
    {
        node.reg.evaluate(cx,this);
        int reg_offset = getRegisterOffset(cx);
        node.expr.evaluate(cx, this);
        if (!node.void_result)
        {
            Dup();
        }
        StoreRegister(reg_offset+node.reg.index,node.type.getTypeId());
        return null;
    }

    public Value evaluate(Context cx, RegisterNode node)
    {
        if ( node.index < 0 )
        {
            node.index = allocateTemp();
        }
        return null;
    }

    public Value evaluate(Context cx, HasNextNode node)
    {
        node.objectRegister.evaluate(cx,this);
        node.indexRegister.evaluate(cx,this);
        int reg_offset = getRegisterOffset(cx);
        HasNext(reg_offset+node.objectRegister.index,
        		reg_offset+node.indexRegister.index);
        return null;
    }
    
    public Value evaluate(Context cx, BoxNode node)
    {
        node.expr.evaluate(cx, this);

        if (!node.void_result)
        {
            int type_id = node.actual.getTypeId();
            switch (type_id)
            {
                case TYPE_bool:
                    ToBoolean(node.actual.getTypeId());
                    break;
                case TYPE_int:
                    ToDouble(node.actual.getTypeId()); // RES what about decimal here
                    break;
            }
        }
        return null;
    }

    public Value evaluate(Context cx, CoerceNode node)
    {
        node.expr.evaluate(cx, this);

        if (!node.void_result)
        {
            if( node.is_explicit)
            {

                int type_id = node.expected.getTypeId();
                switch (type_id)
                {
                     case TYPE_uint:
                        if (node.actual == null || node.actual.getTypeValue() != cx.uintType())
                        {
                            ToUint();
                        }
                        break;
                    /* cn: TYPE_uint == TYPE_int for internal handling.  Must explicitly compare against cx.uintType() */
                    case TYPE_int:
                    	/*
                        if (node.expected.getTypeValue() == cx.uintType())
                        {
                            if (node.actual == null || node.actual.getTypeValue() != cx.uintType())
                            {
                                ToUint();
                            }
                        }
                        else // RES I made TYPE_uint not equal to TYPE_int to make use <numbertype> work
                        */
                        if(node.actual == null || node.actual.getTypeValue() != cx.intType() )
                        {
                            ToInt();
                        }
                        break;

                    case TYPE_double:
                    case TYPE_number:
                        if (node.actual == null || 
                        		(!((node.actual.getTypeValue() == cx.doubleType()) || 
                        				(node.actual.getTypeValue() == cx.numberType()))))
                        {
                            ToDouble(node.actual != null ? node.actual.getTypeId() : TYPE_none);
                        }
                        break;
                    case TYPE_decimal:
                        if (cx.statics.es4_numerics && (node.actual == null || node.actual.getTypeValue() != cx.decimalType()))
                        {
                            ToDecimal(node.actual != null ? node.actual.getTypeId() : TYPE_none);
                        }
                        break;
                    case TYPE_boolean:
                        if (node.actual == null || node.actual.getTypeValue() != cx.booleanType())
                        {
                            ToBoolean(node.actual != null ? node.actual.getTypeId() : TYPE_none);
                        }
                        break;
                    default:
                        {
                            CheckType(node.expected.getName(cx));
                        }
                        break;

                }
             }
             else
             {
                 CheckType(node.expected.getName(cx));
             }
        }

        return null;
    }

    private String getProgramName(Context cx)
    {
        return emitScriptNames && (cx.input != null) ? new File(cx.input.origin).getName() : "";
    }

    private int pushStaticScopesHelper(Context cx, TypeValue cframe)
    {
        if (cframe == null)
        {
            return 0;
        }

        int count = 0;
        if (cframe.baseclass != null)
        {
            count = pushStaticScopesHelper(cx, cframe.baseclass);
        }

        Namespaces namespaces = new Namespaces();
        namespaces.push_back(cframe.name.ns);

        String name = cframe.name.name;
        FindProperty(name, namespaces, true/*is_strict*/, true/*is_qualified*/, false/*is_attr*/);
        GetProperty(name,namespaces, true/*is_qualified*/, false/*is_super*/, false/*is_attr*/);
        PushScope();

        return count+1;
    }

    public Value evaluate(Context unused_cx, ClassDefinitionNode node)
    {
        if (node.attrs != null && node.attrs.hasIntrinsic)
        {
            return null;
        }

        Context cx = node.cx; // switch to original context

        setOrigin(cx.getErrorOrigin());

        if (doingMethod() || doingClass())
        {
            if( node.needs_init )
            {
                ClassDefinitionNode baseClassNode = cx.scope().getDeferredClassMap().get(node.cframe.baseclass);
                if (baseClassNode != null && baseClassNode.needs_init)
                {
                    if (node.name.name.equals("Object") &&
                        baseClassNode.name.name.equals("Class"))
                    {
                        // special case.  do not defer in this case.
                    }
                    else
                    {
                        if (baseClassNode.deferred_subclasses == null)
                        {
                            baseClassNode.deferred_subclasses = new ObjectList<ClassDefinitionNode>();
                        }
                        cx.error(node.baseclass.pos(), kError_ForwardReferenceToBaseClass,baseClassNode.name.name);
                        baseClassNode.deferred_subclasses.add(node);
                        return null;
                    }
                }

                node.needs_init = false;
                node.init.evaluate(cx,this);

                // Initiailize any subclasses that were deferred
                if (node.deferred_subclasses != null)
                {
                    for (Node n : node.deferred_subclasses)
                    {
                        n.evaluate(cx, this);
                    }
                    node.deferred_subclasses = null;
                }

                return null;
            }

            int popCount = 0;

            if( node.baseclass != null)
            {
                // Must push scopes for base classes
                TypeValue cframe = node.cframe;
                popCount = pushStaticScopesHelper(cx, cframe.baseclass);

                node.baseclass.evaluate(cx,this);
            }
            else
            {
                PushNull();
            }
            NewClassObject(node.cframe.builder.classname);

            for (int i=0; i<popCount; i++)
            {
                PopScope();
            }

            return null;
        }

        if( node.pkgdef != null && cx.getScopes().size() == 1 )
        {
            used_namespaces_sets.push_back(node.pkgdef.used_namespaces);
        }

        used_namespaces_sets.push_back(node.used_namespaces);

        /*
         * Interface initializer
         *
         * The class initializer gets the static properties of the class definition.
         */

        cx.pushStaticClassScopes(node);

        {
            // generate nested classes before the outer class
            for (ClassDefinitionNode clsdef : node.clsdefs)
            {
                clsdef.evaluate(cx, this);
                cx.scope().getDeferredClassMap().put(clsdef.cframe,clsdef);
            }
        }

        currentClass = node;

        StartClass(node.ref.name);

        {
            pushStackFrame();

            frame.functionName = node.cframe.builder.classname+"$cinit";
            frame.maxParams = 0;
            frame.maxLocals = 0/*node->var_count*/; // ISSUE: always 0?
            frame.maxTemps = node.temp_count;
            frame.activationIsExposed = false;
            frame.withThis = true;
            frame.firstInnerScope = cx.getScopes().size()-1;
            frame.registerScopeIndex = -1;

            // Generate code for the class and instance initializers.

            StartMethod(frame.functionName, frame.maxParams, frame.maxLocals);

            LoadThis();
            PushScope();

            ClassBuilder bui = (node.cframe.builder instanceof ClassBuilder) ? (ClassBuilder) node.cframe.builder : null;
            if( bui == null )
            {
                cx.internalError("internal error: invalid class builder");
            }

            NewNamespace(node.private_namespace);

            if (node.statements != null)
            {
                node.statements.evaluate(cx, this);
            }

            clearPositionInfo();
            setPosition(0, 0, 0);
            Return(TYPE_void);

			TypeInfo type = null;
			ObjectList<TypeInfo> types = null;
			FinishMethod(cx,frame.functionName,type,types,null/*node->cframe*/,0,cx.getScopes().size(),"",false,false, null);

            {
                for (FunctionCommonNode expr : node.staticfexprs)
                {
                    expr.evaluate(cx, this);
                }
            }

            popStackFrame();
        }

        /*
         * Prototype initializer
         *
         * The prototype initializer sets up the prototype object with the
         * getter and setters for its children.
         */

        cx.pushScope(node.iframe);

        /*{
            fun_name_stack.add(node.iframe.builder.classname + "$iinit");
            max_params_stack.add(0);
            max_locals_stack.add(node.var_count + 1);// ? why +1
            max_temps_stack.add(node.temp_count);

            activation_is_exposed_stack.add(0); // registers not used

            StartMethod(fun_name_stack.last(), max_params_stack.last(), max_locals_stack.last());

            // Generate code for the class and instance initializers.

            // ISSUE: use istmts to capture the instance initializers

            if (node.statements != null)
            {
                node.statements.evaluate(cx, this);
            }

            int scope_depth = cx.getScopes().size() - 1;

            GetBaseObject(scope_depth);
            Return(TYPE_none);
            setPosition(0, 0, 0);

            {
                // $iinit is nested in the constructor and uses the same scope chain as the
                // constructor, so the net scope_depth is zero.
                int scope_depth2 = cx.getScopes().size();
                TypeValue type = node.iframe.type;//make the initializer return type be the object type
                ObjectList<TypeValue> types = null;
                FinishMethod(cx,fun_name_stack.back(),type,types,null,0,scope_depth2,"",false);
            }

            fun_name_stack.removeLast();
            max_params_stack.removeLast();
            max_locals_stack.removeLast();
            max_temps_stack.removeLast();
            activation_is_exposed_stack.removeLast();
        }*/

        /*
         * User defined methods
         */

        for (ListIterator<FunctionCommonNode> it = node.fexprs.listIterator(); it.hasNext(); )
        {
            it.next().evaluate(cx,this);
        }

        boolean is_dynamic = node.attrs != null ? node.attrs.hasDynamic : false;
        boolean is_final = node.attrs != null ? node.attrs.hasFinal : false;

        QName basename = null;
        if( node.cframe.baseclass != null)
        {
            basename = node.cframe.baseclass.builder.classname;
            if ( basename.name.equals("Class") )
                basename = null;
        }
        FinishClass(cx,node.cframe.builder.classname/*node->ref->name*/,basename,is_dynamic, is_final, false, node.cframe.is_nullable);
        cx.popScope();  // iframe
        cx.popStaticClassScopes(node);

        used_namespaces_sets.pop_back();

        if( node.pkgdef != null && cx.getScopes().size() == 1 )
        {
            used_namespaces_sets.pop_back();
        }

        if (debug)
        {
            System.out.print("\n// -ClassDefinitionNode");
        }
        return null;
    }

    public Value evaluate(Context cx, InterfaceDefinitionNode node)
    {
        if (debug)
        {
            System.out.print("\n// +InterfaceDefinitionNode");
        }

        if( doingMethod() || doingClass() )
        {
            if( node.needs_init )
            {
                node.needs_init = false;
                node.init.evaluate(cx,this);
                return null;
            }

            PushNull();  // dummy for interface object
            NewClassObject(node.cframe.builder.classname);
            return null;
        }

        currentClass = node;
        StartClass(node.ref.name);

        cx.pushStaticClassScopes(node);

        pushStackFrame();

        {
            frame.functionName = node.cframe.builder.classname+"$cinit";
            frame.maxParams = 0;
            frame.maxLocals = 0; // ISSUE: always 0?
            frame.registerScopeIndex = -1;
            frame.maxTemps = node.temp_count;
            frame.activationIsExposed = false;
            StartMethod(frame.functionName,frame.maxParams,frame.maxLocals);
            Return(TYPE_void);
            TypeInfo type = null;
            ObjectList<TypeInfo> types = new ObjectList<TypeInfo>();
            FinishMethod(cx,frame.functionName,type,types,null,0,cx.getScopes().size(),"",false,false, null);
        }

        cx.pushScope(node.iframe);

        /*
         * implicit initializers are emitted in $construct
         {

            fun_name_stack.push_back(node.cframe.builder.classname+"$iinit");
            max_params_stack.add(0);
            max_locals_stack.add(node.var_count+1);
            max_temps_stack.add(node.temp_count);

            StartMethod(fun_name_stack.back(),max_params_stack.back(),max_locals_stack.back());

            int scope_depth = cx.getScopes().size()-1;

            GetBaseObject(scope_depth);
            Return(TYPE_none);

            {
                // $iinit is nested in the constructor so add one scope, but
                // this new function doesn't need an activation object, so subtract one scope.
                int scope_depth2 = cx.getScopes().size();
                TypeValue type = node.iframe.type;//make the initializer return type be the object type
                ObjectList<TypeValue> types = new ObjectList<TypeValue>();
                FinishMethod(cx,fun_name_stack.back(),type,types,null,0,scope_depth2,"",false);
            }

            fun_name_stack.pop_back();
            max_params_stack.pop_back();
            max_locals_stack.pop_back();
            max_temps_stack.pop_back();
            activation_is_exposed_stack.pop_back();
        }*/

        popStackFrame();

        /*
         * User defined methods
         */
        for (ListIterator<FunctionCommonNode> it = node.fexprs.listIterator(); it.hasNext(); )
        {
            it.next().evaluate(cx,this);
        }

        FinishClass(cx,node.cframe.builder.classname,null,false, false, true, node.cframe.is_nullable);
        cx.popScope();
        cx.popStaticClassScopes(node);

        if (debug)
        {
            System.out.print("\n// -InterfaceDefinitionNode");
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

    public Value evaluate(Context cx, AttributeListNode node)
    {
        for (Node item : node.items)
        {
            item.evaluate(cx, this);
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

        setOrigin(cx.getQualifiedErrorOrigin());

        return null;
    }

    public Value evaluate(Context cx, ImportDirectiveNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, SuperExpressionNode node)
    {
        if( node.expr != null )
        {
            node.expr.evaluate(cx,this);
        }
        else
        {
            LoadThis();
        }
        return null;
    }

    public Value evaluate(Context cx, SuperStatementNode node)
    {
        int scope_depth = cx.getScopes().size();
        ObjectValue iframe = cx.scope(scope_depth-2);
        InstanceBuilder ib = iframe.builder instanceof InstanceBuilder ? (InstanceBuilder) iframe.builder : null;
        Namespaces namespaces = new Namespaces();
        namespaces.add(cx.publicNamespace());

        if( ib.basebui != null )
        {
            LoadThis();
            int size = node.call.args != null ? node.call.args.size() : 0;
            if( size != 0)
            {
                node.call.args.evaluate(cx,this);
            }
            InvokeSuper(true,size);
        }

        return null;
    }

    public Value evaluate( Context cx, NamespaceDefinitionNode node )
    {
        // cn:  no longer needed. NewNamespace(node.value.value); // doesn't actually push ns value right now
        return null;
    }

    public Value evaluate( Context cx, ConfigNamespaceDefinitionNode node )
    {
        return null;
    }

    public Value evaluate( Context cx, UseDirectiveNode node )
    {
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
        // nothing to do in this pass
        return null;
    }

    public Value evaluate(Context cx, UseNumericNode node)
    {
        // nothing to do in this pass
        return null;
    }

    public Value evaluate(Context cx, UseRoundingNode node)
    {
        // nothing to do in this pass
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

    public Value evaluate(Context cx, LiteralXMLNode node)
    {
        if (debug)
        {
            System.out.print("\n// +LiteralXML");
        }

        if (!node.void_result)
        {
            Namespaces namespaces = new Namespaces();
            namespaces.push_back(cx.publicNamespace());

            String name;

            if( node.is_xmllist )
            {
                name = "XMLList";
            }
            else
            {
                name = "XML";
            }

            FindProperty(name, namespaces,true/*is_strict*/,true/*is_qualified*/,false/*is_attr*/);
            GetProperty(name,namespaces,true/*is_qualified*/,false/*is_super*/,false/*is_attr*/);
            node.list.evaluate(cx, this);
            InvokeClosure(true, 1);
        }

        if (debug)
        {
            System.out.print("\n// -LiteralXML");
        }
        return null;
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

    public Value evaluate(Context cx, ErrorNode node)
    {
        cx.internalError(node.pos(), "ErrorNode not yet implemented");
        return null;
    }

    public Value evaluate(Context cx, RestExpressionNode node)
    {
        cx.internalError(node.pos(), "RestExpressionNode not yet implemented");
        return null;
    }

    public Value evaluate(Context cx, RestParameterNode node)
    {
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
        return null;
    }

    public Value evaluate(Context cx, BinaryClassDefNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, BinaryInterfaceDefinitionNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, DefaultXMLNamespaceNode node)
    {
        if( node.ref == null )
        {
            node.expr.evaluate(cx,this);
            DefaultXMLNamespace();
        }
        else
        {
            Value val = node.ref.getValue(cx);
            ObjectValue obj = val instanceof ObjectValue ? (ObjectValue) val : null;
            if( obj == null )
            {
                node.expr.evaluate(cx,this);
                DefaultXMLNamespace();
            }
            else
            {
                DefaultXMLNamespace(obj.name);
            }
        }
        return null;
    }

    public void GetActivationObject(int base_index)
    {
           GetBaseObject(base_index - frame.firstInnerScope);
    }

    public int getRegisterOffset(Context cx)
    {
        // Return the register offset for the code being currently generated.
        // We want the innermost scope but ignoring any catch scopes, which
        // do not specify a register offset.
        for (int i = cx.getScopes().size(); --i >= 0; )
        {
            Builder builder = cx.scope(i).builder;
            if (builder.hasRegisterOffset())
            {
                return builder.reg_offset;
            }
        }
        return -1;
    }

    public boolean checkFeature(Context cx, Node node)
    {
        if (cx.input != null)
        {
            int pos = node.pos();
            int line = cx.input.getLnNum(pos);
            int col = cx.input.getColPos(pos);
            setPosition(line,col,pos);
        }

        return true; //Evaluator::checkFeature(cx,node);
    }

    private static final NumberConstant ZeroInt = new IntNumberConstant(0);
    private static final NumberConstant ZeroUint = new UintNumberConstant(0);
    private static final NumberConstant NaNDouble = new DoubleNumberConstant(Double.NaN);
    private static final NumberConstant NaNDecimal = new DecimalNumberConstant(Decimal128.NaN);
    public void StoreDefaultValue(Context cx, int index, Slot s, boolean needs_activation)
    {
        if (needs_activation)
        {
            GetActivationObject(cx.getScopes().size()-1);
        }
        TypeInfo type = s.getType();
        if (type.getTypeValue() == cx.intType())
        {
            PushNumber(ZeroInt, TYPE_int);
        }
        else if (type.getTypeValue() == cx.uintType())
        {
            PushNumber(ZeroUint, TYPE_uint_external); // cn: TYPE_uint == TYPE_int for internal purposes.
            CheckType(type.getName(cx));
        }
        else if (type.getTypeValue() == cx.booleanType())
        {
            PushBoolean(false);
        }
        else if (type.getTypeValue() == cx.numberType())
        {
            PushNumber(NaNDouble, TYPE_double);
        }
        else if (type.getTypeValue() == cx.doubleType())
        {
            PushNumber(NaNDouble, TYPE_double);
        }
        else if (cx.statics.es4_numerics && (type.getTypeValue() == cx.decimalType()))
        {
            PushNumber(NaNDecimal, TYPE_decimal);
        }
        else if (type.getTypeValue() == cx.noType())
        {
            ObjectValue objValue = s.getObjectValue();
            if( cx.isNamespace(objValue) )
            {
                PushNamespace(objValue);
            }
            else
            {
                PushUndefined();
                CheckType(type.getName(cx));// coerce undefined to Object to avoid verify-iteration
            }
        }
        else if (type.getTypeValue() == cx.voidType())
        {
            PushUndefined();
        }
        else
        {
            if( type.isNullable() )
                PushNull() ;
            else
                PushUninitialized();

            CheckType(type.getName(cx)); // coerce null to target type to avoid verify-iteration
        }
        if (needs_activation)
        {
            StoreVar(index);
        }
        else
        {
            StoreRegister(index, type != null ? type.getTypeId() : TYPE_object);
        }
    }

    public boolean isClassInitializerReference(Context cx, Value value)
    {
        if (value != null && value instanceof TypeValue && ((TypeValue)value).builder instanceof ClassBuilder
            && this.in_anonymous_function == false) // cn: don't return true when inside body of anonymous function
                                                    //     created within the class cinit.  See bug #137176 for details
        {
            int scope_depth = cx.getScopes().size();
            for (int i=scope_depth; --i >= 0; )
            {
                ObjectValue scope = cx.scope(i);
                if (scope.builder instanceof InstanceBuilder)
                {
                    return false;
                }
                if (scope == value)
                {
                    return true;
                }
                else if( scope.builder instanceof ClassBuilder )
                {
                    // We hit a TypeValue, but it is not the same as the one we are looking for
                    // stop looking because we have now found the Class we are Initializing, and
                    // it is not the Class we are looking for.  See bug #137604
                    return false;
                }
            }
        }

        return false;
    }

    private void removeConstantInitializers(Context cx, Node def)
    {
        // this could be more general but gets the important cases
        if(def instanceof ExpressionStatementNode)
        {
           Node list = ((ExpressionStatementNode)def).expr;
           if(list.isList())
           {
               ListNode list_node = (ListNode)list;
               for( int i = 0; i < list_node.items.size(); ++i )
               {
                   Node men = list_node.items.get(i);
                   if(men instanceof MemberExpressionNode)
                   {
                       ReferenceValue v = ((MemberExpressionNode)men).ref;
                       if(v != null)
                       {
                           Slot s = v.getSlot(cx);
                           if(s != null && s.getInitializerValue() != null && s.getInitializerValue().hasValue())
                           {
                               // If this is a constant initializer, then remove it from the list
                               // because the value will be provided in the traits
                               list_node.items.set(i, cx.getNodeFactory().emptyStatement());
                           }
                       }
                   }
               }
           }
        }
    }

    public boolean isFinallyPresent()
    {
        return exceptionState != null && exceptionState.finallyPresent;
    }

    public boolean isAnyFinallyPresent()
    {
        return exceptionState != null && exceptionState.anyFinallyPresent;
    }

    public boolean isInsideFinally()
    {
        return exceptionState != null && exceptionState.insideFinally;
    }

    public Value evaluate(Context cx, TypeExpressionNode node)
    {
        return node.expr.evaluate(cx, this);
    }
}
