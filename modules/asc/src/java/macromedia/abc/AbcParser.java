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

package macromedia.abc;
import static macromedia.asc.parser.Tokens.EMPTY_TOKEN;
import static macromedia.asc.semantics.Slot.*;

import macromedia.asc.embedding.avmplus.*;
import macromedia.asc.util.*;
import macromedia.asc.parser.*;
import macromedia.asc.semantics.*;
import macromedia.asc.semantics.QName;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;

/**
 * @author Erik Tierney
 */
@SuppressWarnings("nls") // TODO: Remove
public final class AbcParser
{
    private Context ctx;
    private AbcData abcData;
    private static final boolean debug = false;

    public AbcParser(Context cx, String name) throws IOException
    {
        this.ctx = cx;
        this.abcData = new AbcData("");
        this.abcData.readAbc(new BytecodeBuffer(name));
    }

    public AbcParser(Context cx, byte[] bytes)
    {
        this.ctx = cx;
        this.abcData = new AbcData("");
        this.abcData.readAbc(new BytecodeBuffer(bytes));
    }

    private final Map<String, Integer> fun_names = new HashMap<String, Integer>();

    private final ObjectList<ObjectList<ClassDefinitionNode>> clsdefs_sets = new ObjectList<ObjectList<ClassDefinitionNode>>();
    private final ObjectList<String> region_name_stack = new ObjectList<String>();

    // TODO: better dependency analysis - this is used to populate FA's ce_unresolved_sets which
    // TODO: mxml uses to find dependencies - could be done earlier for abcs
    private ObjectList<Set<ReferenceValue>> ce_unresolved_sets = new ObjectList<Set<ReferenceValue>>();

    public ProgramNode parseAbc()
    {
        return parseAbc(false, false);
    }

    // first parameter causes BinaryProgramNode's toplevelDefinitions instance variable to be populated
    // second parameter turns on/off building full ast's - if you suspect an mxmlc problem caused by a lack of
    // ast from ABCs, turn this on to see if it fixes it.
    // if this is false, only BinaryProgramNode, and toplevel definition nodes are created (mostly BinaryClassDefNode).
    // hopefully we can get rid of those someday too.
    // both these parameters are set to true by Flash Authoring and left false by by mxmlc
    public ProgramNode parseAbc(boolean collectTopLevel, boolean buildASTForClasses)
    {
        try
        {
            // Create a program node that will represent the data in the abc file.
            // It won't actually be a parse tree, but it will contain the correct builder
            // objects which are usually built up by the FlowAnalyzer
            
            BinaryProgramNode program = ctx.getNodeFactory().binaryProgram(ctx, ctx.getNodeFactory().statementList(null, (StatementListNode)null));
            GlobalBuilder b = new GlobalBuilder();
            b.is_in_package = true; // cn: necessary for proper slot creation for top level functions
            program.frame = new ObjectValue(ctx, b, ctx.noType());
			ctx.pushScope(program.frame);
            clsdefs_sets.add(new ObjectList<ClassDefinitionNode>());
            ce_unresolved_sets.push_back(program.ce_unresolved);
            region_name_stack.push_back("");
            
            for( int i = 0; i < this.abcData.getScriptInfoSize(); ++i )
            {
                parseScript(i, program, collectTopLevel, buildASTForClasses);
            }

            program.clsdefs = clsdefs_sets.last();
    		clsdefs_sets.removeLast();
            ce_unresolved_sets.removeLast();
            region_name_stack.pop_back();
            ctx.popScope(); // global
            
			// For proper const and type enforcement of top level functions and vars, we need to 
			//  process those def nodes during CE.  These definitions need to be evaluated in the
			//  scope of the BinaryProgramNode's frame.
            // Conversely, class definition nodes are maintained in the clsdefs list rather than ever
            // being added to the binary program node's statement list. This is so that they get processed outside the 
            // BinaryProgramNode's frame...
            
            // {pmd} following builds <ProgramNode <StatementList <BinaryProgramNode ...>>>
            // {pmd} I wondered why? --probably to match some undefined visitor pattern behavior...
            
            ProgramNode prog = ctx.getNodeFactory().program(ctx, ctx.getNodeFactory().statementList(null, program));

            // Uncomment next line to get some debugging info to print to stdout.
            // {pmd} ??? for this to be useful it really should iterate the clsdefs list...(and print the objectvalue hierarchy too.)
            // dumpProgram(program);

            return prog;
        }
        catch(Exception t)
        {
        	if(debug) t.printStackTrace();
            // Clean up any scope we may have pushed and didn't pop when the exception was thrown
            ObjectValue scope = ctx.scope();
            ObjectValue global = ctx.globalScope();
            while( scope != global )
            {
                ctx.popScope();
                scope = ctx.scope();
            }
            return null;
        }
    }

    static private class DefAndSlot
    {
        public DefinitionNode def;
        public Slot slot;
    }

    /**
     * Returns a TypeValue for the qname specified by typeID.  If that type does not exist yet
     * a new placeholder TypeValue is created and returned.  The placeholder will be filled in later when
     * we actually see that type.  This allows us to avoid any forward reference problems when parsing an ABC
     * @param typeID the index of the QName we want the TypeValue for
     * @return the TypeValue representing the type specifed by typeID.
     */
    private TypeValue getTypeFromQName(int typeID)
    {
        if( typeID == 0 )
            return ctx.noType();

        QName typename = getFullName(getBinaryMNFromCPool(typeID));

        if( ctx.isBuiltin(typename.toString()) )
            return ctx.builtin( typename.toString() );

        TypeValue type = TypeValue.getTypeValue(ctx, typename);
        if( !type.resolved )
            ce_unresolved_sets.last().add(new ReferenceValue(ctx, null, typename.name, typename.ns));

        return TypeValue.getTypeValue(ctx, typename);

    }

    private DefAndSlot slotTrait(String name, ObjectValue ns, int slotID, int typeID, int valueID, int value_kind, boolean is_const, boolean build_ast)
    {
        ObjectValue obj = ctx.scope();
        DefAndSlot ret = new DefAndSlot();
        Namespaces nss = new Namespaces();
        nss.push_back(ns);
                
        TypeValue type = getTypeFromQName(typeID);
        
        int var_id = obj.builder.Variable(ctx, obj);
        int slot_id = obj.builder.ExplicitVar(ctx,obj,name,nss,type,-1,-1,var_id);

        Slot slot = obj.getSlot(ctx,slot_id);
		slot.setConst(is_const);
		slot.setImported(true);

        ret.slot = slot;

        IdentifierNode id=null;
        AttributeListNode attr=null;

        if( build_ast )
        {
            id = identifierNode(name, ns);
            attr = attributeList(false, false, false, ns, obj.builder);
        }
        if( value_kind == ActionBlockConstants.CONSTANT_Namespace )
        {
            ObjectValue nsValue = getNamespace(valueID);
            slot.setObjectValue(nsValue);
			slot.setConst(true);

            if( build_ast )
                ret.def = ctx.getNodeFactory().namespaceDefinition(attr, id, ctx.getNodeFactory().literalString(nsValue.name));

            return ret;
        }
        if( valueID != 0)
            slot.setObjectValue(getInitValue(valueID, value_kind));
        
        if( build_ast )
        {
	        MemberExpressionNode typeExpr = null;
	        if( typeID != 0 )
	        {
	            AbcData.BinaryMN t = getBinaryMNFromCPool(typeID);
	            typeExpr = memberExprFromMN(t);
	        }

	        Node init = getInitValueNode(valueID,value_kind);     // (0,0) means undefined
	        TypedIdentifierNode ty = ctx.getNodeFactory().typedIdentifier(id, typeExpr);
	        int tok = is_const ? Tokens.CONST_TOKEN : Tokens.VAR_TOKEN;
	        VariableBindingNode bind = ctx.getNodeFactory().variableBinding(attr, tok, ty, init);

	        bind.ref = id.ref;
	        if( typeExpr != null )
	        {
	            bind.typeref = typeExpr.ref;
	        }

	        ret.def = (DefinitionNode) ctx.getNodeFactory().variableDefinition(attr, tok, ctx.getNodeFactory().list(null, bind));
        }
        return ret;
    }

    private MemberExpressionNode memberExprFromMN(AbcData.BinaryMN mn)
    {
        MemberExpressionNode typeExpr = null;
        QName typeName = getFullName(mn);
        NodeFactory nf = ctx.getNodeFactory();
        
        if( typeName instanceof ParameterizedName )
        {
            ParameterizedName pn = (ParameterizedName)typeName;
            IdentifierNode baseIdNode = identifierNode(pn.name, pn.ns);
            MemberExpressionNode param_node = memberExprFromMN(getBinaryMNFromCPool(mn.params[0]));
            ListNode list = nf.list(null, param_node);
            Node apply = nf.applyTypeExpr(baseIdNode, list, -1);
            typeExpr = nf.memberExpression(null, (SelectorNode)apply);
            typeExpr.ref = baseIdNode.ref;
            typeExpr.ref.addTypeParam(param_node.ref);
        }
        else
        {
            IdentifierNode typeIdNode = identifierNode(typeName.name, typeName.ns);
            GetExpressionNode getNode = nf.getExpression(typeIdNode);
            typeExpr = nf.memberExpression(null, getNode);
            typeExpr.ref = typeIdNode.ref;
        }
        return typeExpr;
    }
    
    /**
     *  Creates an identifier node, and fills in the ref with the correct reference value
     * @param simpleName
     * @param ns
     * @return IdentifierNode
     */
    private IdentifierNode identifierNode(String simpleName, ObjectValue ns)
    {
        IdentifierNode id = ctx.getNodeFactory().identifier(simpleName);
        //IdentifierNode will clean this up
        id.ref = new ReferenceValue(ctx, null, id.name, ns);
        return id;
    }

    private DefAndSlot methodTrait(String methodName, ObjectValue ns, int dispID, int methInfo, int attrs, int kind, boolean build_ast)
    {
        ObjectValue obj = ctx.scope();
        DefAndSlot ret = new DefAndSlot();
        boolean isFinal = (attrs & ActionBlockConstants.TRAIT_FLAG_final) != 0;
        boolean isOverride = (attrs & ActionBlockConstants.TRAIT_FLAG_override) != 0;
        Namespaces names = new Namespaces(ns);
        int method_id = obj.builder.Method(ctx,obj,methodName,names,false);
        int method_slot;
        NodeFactory nf = ctx.getNodeFactory();

        // Create the right type of method based on what kind it is.  Either a setter, getter, or regular method
        switch(kind)
        {
        case ActionBlockConstants.TRAIT_Setter: //Set property
            method_slot = obj.builder.ExplicitSet(ctx,obj,methodName,names,ctx.noType(),isFinal,isOverride,-1,method_id,-1);
            break;
            
        case ActionBlockConstants.TRAIT_Getter: //get property
            method_slot = obj.builder.ExplicitGet(ctx,obj,methodName,names,ctx.noType(),isFinal,isOverride,-1,method_id,-1);
            break;
            
        default: // regular method
            method_slot = obj.builder.ExplicitCall(ctx,obj,methodName,names,ctx.noType(),isFinal,isOverride,-1,method_id,-1);
            break;
        }

        ObjectValue funcObj = getFunctionObject();
        Slot slot = obj.getSlot(ctx, method_slot);
        slot.setValue(funcObj);
		slot.setImported(true);

        // Calculate the internal name - this matter because with get/set properties you can end up with
        // multiple methods with the same name, but they must each have different internal names.
        StringBuilder internal_name = new StringBuilder(methodName.length() + 5);
        if( !fun_names.containsKey(methodName) )
        {
            fun_names.put(methodName,0);
        }
        internal_name.append(methodName).append('$');
        int num = fun_names.get(methodName);
        internal_name.append(num);
        num++;
        fun_names.put(methodName, num);

        int slot_id = obj.getImplicitIndex(ctx,method_slot,Tokens.EMPTY_TOKEN);
        Slot implied_slot = obj.getSlot(ctx, slot_id);
		implied_slot.setImported(true);

	    String n = internal_name.toString();
        implied_slot.setMethodName(n);//node->fexpr->internal_name;
        ret.slot = implied_slot;

        // Make sure the FunctionBuilder gets cleaned up
        int functionKind;
        switch( kind )
        {
            case ActionBlockConstants.TRAIT_Getter:
                functionKind = Tokens.GET_TOKEN;
                break;
            case ActionBlockConstants.TRAIT_Setter:
                functionKind = Tokens.SET_TOKEN;
                break;
            default:
                functionKind = Tokens.EMPTY_TOKEN;
                break;
        }

        // Come up with the function signature
        AbcData.Method m_info = this.abcData.getMethod(methInfo);

        int returnTypeID = m_info.getReturnType();
        int paramTypeIDs[] = m_info.getParamTypes();
        int paramCount = paramTypeIDs.length;
        ObjectList<Node> optional_nodes = null;
        int optional_count = 0;
        if( m_info.getHasOptional()  )
        {
            if( build_ast )
            {
                optional_nodes = parseOptionalParams(m_info);
            }
            optional_count = m_info.getOptionalParamTypes().length;
        }
        String[] param_names = m_info.getParamNames();

        // Set return type
        implied_slot.setType(getTypeFromQName(returnTypeID).getDefaultTypeInfo());

        ParameterListNode paramList = null;

        ObjectList<TypeInfo> param_types = new ObjectList<TypeInfo>(paramCount);
        ByteList decl_styles = new ByteList(1);

        for( int i = 0, cur_optional = 0; i < paramCount; ++i )
        {
            ParameterNode param = null;
            if( build_ast )
            {
                AbcData.BinaryMN typeMN = null;
                if( paramTypeIDs[i] != 0 )
                {
                    typeMN = getBinaryMNFromCPool(paramTypeIDs[i]);
                    // getFullName(typeMN); // for effect
                }

                String simple_param_name = i < param_names.length && param_names[i] != null ? param_names[i] : ("param" + (i+1)).intern();
                param = parameterNode(simple_param_name, typeMN);

                paramList = nf.parameterList(paramList, param);
            }

            param_types.push_back(getTypeFromQName(paramTypeIDs[i]).getDefaultTypeInfo());

            if( i >= paramCount - optional_count )
            {
                if( build_ast )
                    param.init = optional_nodes.get(cur_optional++);
                decl_styles.push_back((byte) Slot.PARAM_Optional);
            }
            else
            {
                decl_styles.push_back((byte) Slot.PARAM_Required);
            }
        }
 
        if( m_info.getNeedsRest() )
        {
            if( build_ast )
            {
                ParameterNode param = parameterNode("rest", ctx.arrayType().name);
                RestParameterNode restNode = ctx.getNodeFactory().restParameter(param , -1);
                restNode.ref = param.ref;
                restNode.typeref = param.typeref;
                paramList = nf.parameterList(paramList, restNode);

                // rsun 11.22.05 porting over a fix made to the 8ball_AS3 branch a long time
                // ago, but only to the C++ compiler. has_rest needs to be reset here since
                // MovieClipMaker is a special entry point that creates function nodes itself.
                // otherwise, has_rest is unnecessarily true for all functions processed after
                // this.
                ctx.getNodeFactory().has_rest = false;
            }

            param_types.push_back(ctx.arrayType().getDefaultTypeInfo());
            decl_styles.push_back((byte) Slot.PARAM_Rest);
        }

        if( param_types.size() > 0 )
        {
            implied_slot.setTypes(param_types);
            implied_slot.setDeclStyles(decl_styles);
        }
        else
        {
            param_types.push_back(ctx.voidType().getDefaultTypeInfo());
            implied_slot.setTypes(param_types);
            implied_slot.addDeclStyle(Slot.PARAM_Void);
        }

        if( build_ast )
        {
            MemberExpressionNode retTypeNode = null;
            if( returnTypeID != 0 )
            {
                AbcData.BinaryMN retMN = getBinaryMNFromCPool(returnTypeID);
                retTypeNode = memberExprFromMN(retMN);
            }
            FunctionSignatureNode fsn = nf.functionSignature(paramList,retTypeNode);
            if( retTypeNode != null )
            {
                fsn.typeref = retTypeNode.ref;
            }

            IdentifierNode id = identifierNode(methodName,ns);
            FunctionCommonNode fcn = nf.functionCommon(ctx, id, fsn, null);
            fcn.kind = functionKind;
            fcn.ref = id.ref;

            FunctionNameNode fn = nf.functionName(functionKind, id);
            AttributeListNode attr = attributeList(isFinal, isOverride, false, ns, obj.builder);
            FunctionDefinitionNode fdn = nf.binaryFunctionDefinition(ctx, attr, fn, fcn, -1);

            ret.def = fdn;
        }
        return ret;
    }

    private static ObjectValue dummyFunc = null;

    /**
     * Helper so we only allocate 1 ObjectValue to represent a method, instead
     * of 1 for each method.  This is safe because the OV is only used as the value
     * of a MethodSlot, and we only ever check for the existance of the value, never anything else
     * @return an ObjectValue that can be used for a function object
     */
    private ObjectValue getFunctionObject()
    {
        if( dummyFunc == null )
            dummyFunc = new ObjectValue(ctx,new FunctionBuilder(),ctx.functionType());

        return dummyFunc;
    }

    private Node getInitValueNode(int valueID,int kind)
    {
        Node t;
        NodeFactory nf = ctx.getNodeFactory();
        
        switch (kind)
        {
            case ActionBlockConstants.CONSTANT_Void:
                t = nf.unaryExpression(Tokens.VOID_TOKEN,nf.literalNumber("0",-1),-1);
                break;
                
            case ActionBlockConstants.CONSTANT_Integer:
            case ActionBlockConstants.CONSTANT_UInteger:
            case ActionBlockConstants.CONSTANT_Double:
                double val = getNumberFromCPool(valueID, kind);
                t = nf.literalNumber(String.valueOf(val));
                break;
                
            case ActionBlockConstants.CONSTANT_Decimal:
            	Decimal128 dval = getDecimalFromCPool(valueID);
            	String sval = dval.toString();
            	if (ctx.statics.es4_numerics)
            		sval += "m";
            	t = nf.literalNumber(sval);
            	break;
            
            case ActionBlockConstants.CONSTANT_True:
                t = nf.literalBoolean(true);
                break;
                
            case ActionBlockConstants.CONSTANT_False:
                t = nf.literalBoolean(false);
                break;
                
            case ActionBlockConstants.CONSTANT_Utf8:
                t = nf.literalString(getStringFromCPool(valueID));
                break;
                
            case ActionBlockConstants.CONSTANT_Null:
                t = nf.literalNull();
                break;
                
            case ActionBlockConstants.CONSTANT_Namespace:
                ObjectValue ns = getNamespace(valueID);
                t = nf.literalString(ns.name);
                break;
                
            default:
                t = nf.literalString("");
                break;
        }
        return t;
    }

    private ObjectValue getInitValue(int valueID,int kind)
    {
        ObjectValue ov;
        switch (kind)
        {
            case ActionBlockConstants.CONSTANT_Void:
                ov = ctx.voidType().prototype;
                break;

            case ActionBlockConstants.CONSTANT_Integer:
                double intval = getNumberFromCPool(valueID, kind);
                ov = new ObjectValue(String.valueOf(intval), ctx.intType());
                break;
            case ActionBlockConstants.CONSTANT_UInteger:
                double uintval = getNumberFromCPool(valueID, kind);
                ov = new ObjectValue(String.valueOf(uintval), ctx.uintType());
                break;
            case ActionBlockConstants.CONSTANT_Double:
                double val = getNumberFromCPool(valueID, kind);
                ov = new ObjectValue(String.valueOf(val), ctx.doubleType());
                break;

            case ActionBlockConstants.CONSTANT_Decimal:
            	Decimal128 dval = getDecimalFromCPool(valueID);
            	String sval = dval.toString();
            	if (ctx.statics.es4_numerics)
            		sval += "m";
            	ov = new ObjectValue(sval, ctx.decimalType());
            	break;

            case ActionBlockConstants.CONSTANT_True:
                ov = ctx.booleanTrue();
                break;

            case ActionBlockConstants.CONSTANT_False:
                ov = ctx.booleanFalse();
                break;

            case ActionBlockConstants.CONSTANT_Utf8:
                ov = new ObjectValue(getStringFromCPool(valueID), ctx.stringType());
                break;

            case ActionBlockConstants.CONSTANT_Null:
                ov = ctx.nullType().prototype;
                break;

            case ActionBlockConstants.CONSTANT_Namespace:
                ObjectValue ns = getNamespace(valueID);
                ov = ns;
                break;

            default:
                ov = null;
                break;
        }
        return ov;
    }

    private ObjectList<Node> parseOptionalParams(AbcData.Method method_info)
    {
        int[] optional_values = method_info.getOptionalParamTypes();
        int[] optional_kinds = method_info.getOptionalParamKinds();
        
        ObjectList<Node> optionals = new ObjectList<Node>(optional_values.length);
        for( int i = 0; i < optional_values.length; ++i)
        {
            int value_index = optional_values[i];
            int value_kind =  optional_kinds[i];
            Node current_node = getInitValueNode(value_index,value_kind);
            optionals.push_back(current_node);
        }
        return optionals;
    }


    private ParameterNode parameterNode(String simpleParamName, QName typeName)
    {
        IdentifierNode id = identifierNode(simpleParamName, ctx.publicNamespace());
        IdentifierNode ty = null;
        MemberExpressionNode paramType = null;
        
        if( typeName != null )
        {
            ty = identifierNode(typeName.name, typeName.ns);
            GetExpressionNode getNode = ctx.getNodeFactory().getExpression(ty);
            paramType = ctx.getNodeFactory().memberExpression(null, getNode);
        }
        ParameterNode param = ctx.getNodeFactory().parameter(Tokens.VAR_TOKEN, id, paramType);
        if( ty != null )
        {
            param.typeref = ty.ref;
        }
        param.ref = id.ref;

        return param;
    }

    private ParameterNode parameterNode(String simpleParamName, AbcData.BinaryMN typeMN)
    {
        IdentifierNode id = identifierNode(simpleParamName, ctx.publicNamespace());

        MemberExpressionNode paramType = null;
        if( typeMN != null )
        {
            paramType = memberExprFromMN(typeMN);
        }
        ParameterNode param = ctx.getNodeFactory().parameter(Tokens.VAR_TOKEN, id, paramType);
        if( paramType != null )
        {
            param.typeref = paramType.ref;
        }        
        param.ref = id.ref;

        return param;
    }

    private AttributeListNode attributeList(boolean isFinal, boolean isOverride, boolean isDynamic, ObjectValue ns, Builder builder)
    {
        AttributeListNode attr = ctx.getNodeFactory().attributeList(ctx.getNodeFactory().literalString(""), null);

        attr.hasFinal = isFinal;
        attr.hasOverride = isOverride;
        attr.hasDynamic = isDynamic;

        if( builder instanceof ClassBuilder ) //Statics are built by classbuilder, non statics by instancebuilder
        {
            attr.hasStatic = true;
        }
        if ( ns == null )
        	return attr;
        
        if( ns == ctx.publicNamespace() || (ns.getNamespaceKind() == Context.NS_PUBLIC && ns.isPackage()) )
        {
            // Only package public namespaces will have been qualified with the 'public' access specifier
            // user defined namespaces may also be public namespaces in the cpool, but they will not be package namespaces
            attr.hasPublic = true;
        }
        else if( ns.isInternal() )
            attr.hasInternal = true;
        else if( ns.isProtected() )
            attr.hasProtected = true;
        else if( ns.isPrivate() )
            attr.hasPrivate = true;
        else
        {
            if( builder.classname != null && ns == builder.classname.ns)
                attr.hasPublic = true;
            else
                attr.namespaces.add(ns);
        }
        return attr;
    }
    
    // Utility to get the full name based on a qname (ns + "/" + name)
    private QName getFullName(AbcData.BinaryMN mn)
    {
        if( mn.kind == ActionBlockConstants.CONSTANT_TypeName )
        {
            AbcData.BinaryMN base = getBinaryMNFromCPool(mn.baseMN);
            QName base_qn = getFullName(base);
            ObjectList<QName> params = new ObjectList<QName>(mn.params.length);
            
            for( int i = 0; i < mn.params.length; ++i) {
                params.add(getFullName(getBinaryMNFromCPool(mn.params[i])));
            }
            ParameterizedName pn = new ParameterizedName(params, base_qn.ns, base_qn.name);
            return pn;
        }
        else
        {
            assert (mn.nsIsSet != true):"expected a single namespace";

            String fullName = getStringFromCPool(mn.nameID);
            ObjectValue ns = getNamespace(mn.nsID);
            return ctx.computeQualifiedName("", fullName, ns, EMPTY_TOKEN);
        }
    }

    private DefAndSlot classTrait(String className, ObjectValue ns, int slotID, int classID, boolean build_ast)
    {
        if( classID >= this.abcData.getClassInfoSize() || classID < 0 )
            return null;

        DefAndSlot ret = new DefAndSlot();
        ObjectValue current_scope = ctx.scope();
        
        String region_name = region_name_stack.back();
        if( region_name.length() > 0 )
        {
            region_name += "/";
            ns = ctx.getNamespace(region_name + ns.name);
        }
 
        NodeFactory nf = ctx.getNodeFactory();

        // Instance info
        AbcData.InstanceInfo iinfo = this.abcData.getInstanceInfo(classID);

        AbcData.BinaryMN instanceMN = getBinaryMNFromCPool(iinfo.getInstanceNameID());
        QName fullName = getFullName(instanceMN);
        String fullNameString = fullName.toString();

        int superID = iinfo.getSuperID();
        boolean hasSuper = superID != 0;
        QName superName = null;
        String simpleSuperName ="";
        ObjectValue superNamespace = null;
        if( hasSuper )
        {
            AbcData.BinaryMN superMN = getBinaryMNFromCPool(superID);
            
            assert (superMN.nsIsSet != true):"expected a single namespace";
            
            superNamespace = getNamespace(superMN.nsID);
            superName = getFullName(superMN);
            simpleSuperName = getStringFromCPool(superMN.nameID);
        }

        int flags = iinfo.getFlags();

        int[] interfaces = iinfo.getInterfaces();
        ListNode interface_nodes = null;
		if(debug&&interfaces.length>0) System.out.println("parsing " + interfaces);
        for( int i = 0; i < interfaces.length; ++i )
        {
            int int_index = interfaces[i];
            AbcData.BinaryMN intMN = getBinaryMNFromCPool(int_index);
			String simpleIntName = getStringFromCPool(intMN.nameID);
			Namespaces intNamespaces;
			if(intMN.nsIsSet)
				intNamespaces = getNamespaces(intMN.nsID);
			else {
				intNamespaces = new Namespaces(1); 
				intNamespaces.add(getNamespace(intMN.nsID));
			}
		
            IdentifierNode ident = nf.identifier(simpleIntName);

            ident.ref = new ReferenceValue(ctx, null, simpleIntName, intNamespaces);
            GetExpressionNode getNode = nf.getExpression(ident);
            MemberExpressionNode interface_node = nf.memberExpression(null, getNode);
            interface_node.ref = ident.ref;
            interface_nodes = nf.list(interface_nodes, interface_node);
            interface_nodes.values.push_back(ident.ref);
        }

        boolean isFinal = (flags & ActionBlockConstants.CLASS_FLAG_final) != 0;
        boolean isDynamic = ( flags & ActionBlockConstants.CLASS_FLAG_sealed ) == 0;
        boolean isInterface = (flags & ActionBlockConstants.CLASS_FLAG_interface) != 0;
 
        ClassDefinitionNode cdn = null;
        IdentifierNode idNode = nf.identifier(className);
        idNode.ref = new ReferenceValue(ctx, null, idNode.name, ns);
        
        AttributeListNode attr = attributeList(isFinal, false, isDynamic, ns, current_scope.builder);
        StatementListNode stmtList = nf.statementList(null, (StatementListNode)null);
        
        if (isInterface)
        {
        	cdn = nf.binaryInterfaceDefinition(ctx, attr, idNode, null, stmtList);
        }
        else
        {
        	cdn = nf.binaryClassDefinition(ctx, attr, idNode, null, stmtList);
        }
        cdn.ref = idNode.ref;
        cdn.interfaces = interface_nodes;
        cdn.public_namespace = ctx.publicNamespace();
        cdn.protected_namespace = ctx.getNamespace(fullNameString, Context.NS_PROTECTED);
        cdn.static_protected_namespace = ctx.getNamespace(fullNameString, Context.NS_STATIC_PROTECTED);
        cdn.private_namespace = ctx.getNamespace(fullNameString, Context.NS_PRIVATE);
        cdn.default_namespace = ctx.getNamespace(fullName.ns.name, Context.NS_INTERNAL);

        boolean is_builtin = ctx.isBuiltin(fullNameString);
        TypeValue cframe;
        ObjectValue iframe;
        if( is_builtin )
        {
            cframe = ctx.builtin(fullNameString);
            iframe = cframe.prototype;
        }
        else
        {
        	ClassBuilder cb = new ClassBuilder(fullName,cdn.protected_namespace,cdn.static_protected_namespace);
            cframe = TypeValue.defineTypeValue(ctx,cb,fullName,RuntimeConstants.TYPE_object);
            
            InstanceBuilder ib = new InstanceBuilder(fullName);
            ib.canEarlyBind = false;
            iframe = new ObjectValue(ctx,ib,cframe);
            cframe.prototype = iframe;
           
            cdn.debug_name = fullNameString;
            // Make sure the ClassBuilder and InstanceBuilders get cleaned up
            cdn.owns_cframe = true;
        }
        cdn.cframe = cframe;
        cdn.iframe = iframe;

        if( isInterface )
        {
            ((ClassBuilder)cframe.builder).is_interface = true;
        }
        cframe.builder.is_dynamic = iframe.builder.is_dynamic = isDynamic;
        cframe.builder.is_final = iframe.builder.is_final = isFinal;

        clsdefs_sets.last().add(cdn);

        if( hasSuper )
        {
            TypeValue superType;
            cdn.baseclass = nf.literalString(superName.toString(), -1);
            if( ctx.isBuiltin(superName.toString()) )
            {
                // Set the super type, this important for int/uint which derive from Number
                superType = ctx.builtin(superName.toString());
                cframe.baseclass = superType;
                cdn.baseref = new ReferenceValue(ctx, null, superName.toString(), ctx.publicNamespace());
            }
            else
            {
                //cdn.baseclass = nf.literalString(superName.toString(), -1);
                cdn.baseref = new ReferenceValue(ctx, null, simpleSuperName, superNamespace);
                cdn.baseref.getSlot(ctx);

                cframe.baseclass = getTypeFromQName((int)superID) ;
            }
        }
        else if (cdn.cframe != ctx.objectType())
		{
				cdn.baseclass = nf.memberExpression(null, nf.getExpression(nf.identifier("Object")));
				cframe.baseclass = ctx.objectType();
		}
        else
        {
            cdn.baseclass = null;
            cframe.baseclass = null;
		}

        int var_id  = current_scope.builder.Variable(ctx,current_scope);
        int slot_id  = current_scope.builder.ExplicitVar(ctx,current_scope,className,ns,ctx.typeType(),-1,-1,var_id);
        Slot slot = current_scope.getSlot(ctx,slot_id);
        slot.setObjectValue(cframe);
		slot.setImported(true);
		slot.setConst(true);		// all class definitions are const.

        ret.slot = slot;

        current_scope.builder.ImplicitCall(ctx,current_scope,slot_id,cframe,CALL_Method,-1,-1);
		current_scope.builder.ImplicitConstruct(ctx,current_scope,slot_id,cframe,CALL_Method,-1,-1);

        if( isInterface )
        {
            ((ClassBuilder)cframe.builder).is_interface = true;
            slot.setImplNode(cdn);
        }

        clsdefs_sets.add(new ObjectList<ClassDefinitionNode>());

        region_name_stack.push_back(fullNameString);
        
        ctx.pushStaticClassScopes(cdn); // class
        {
        	ctx.pushScope(iframe); // instance
        	{
        		StatementListNode instance_stmts = nf.statementList(null, (StatementListNode)null);
        		parseTraits(iinfo.getITraits(), instance_stmts, build_ast, null, build_ast); // Traits for the instance
        		cdn.instanceinits = new ObjectList<Node>(instance_stmts.items.size());
        		if( instance_stmts.items.size() > 0)
        		{
        			cdn.instanceinits.addAll(instance_stmts.items);
        		}
        		// Add nodes for the constructor, which doesn't have a traits entry.
        		DefAndSlot d = methodTrait("$construct", ctx.publicNamespace(),0,iinfo.getInitIndex(),0,0, build_ast);
        		DefinitionNode iinit_node = d.def;
                if( build_ast )
        		    cdn.instanceinits.add(iinit_node);

                int implied_idx = current_scope.getImplicitIndex(ctx, slot_id, Tokens.NEW_TOKEN);
                Slot class_slot = current_scope.getSlot(ctx, implied_idx);
                if( class_slot != null)
                {
                    //class_slot.setType(d.slot.getType());
                    class_slot.setTypes(d.slot.getTypes());
                    class_slot.setDeclStyles(d.slot.getDeclStyles());
                }
        	}
        	ctx.popScope(); // instance

        	AbcData.ClassInfo cinfo = this.abcData.getClassInfo(classID);
        	parseTraits(cinfo.getCTraits(), cdn.statements, build_ast, null, build_ast); // Traits for the class (statics)
        }
        ctx.popStaticClassScopes(cdn); //class

        clsdefs_sets.removeLast();
        region_name_stack.pop_back();

        ret.def = cdn;
        return ret;
    }

    // parsetraits - if prog is non-null we will populate prog.toplevelDefinitions
    private void parseTraits(AbcData.Trait[] traits, StatementListNode statements, boolean build_ast, BinaryProgramNode prog, boolean buildASTForClasses)
    {
        for (AbcData.Trait t: traits)
        {   
			AbcData.BinaryMN mn = getBinaryMNFromCPool(t.getNameIndex());
			String name = getStringFromCPool(mn.nameID);
            ObjectValue ns;
            ns = getNamespaceFromMultiname(mn);

            DefAndSlot d = null;
            switch (t.getTag()) 
            {
            case ActionBlockConstants.TRAIT_Var:
            case ActionBlockConstants.TRAIT_Const:
			    d = slotTrait(name, ns, t.getSlotId(), t.getTypeName(), t.getValueIndex(), t.getValueKind(), t.isConstTrait(), build_ast);
                if( build_ast )
                    statements.items.add(d.def);

                if( prog != null )
                    prog.toplevelDefinitions.add(new QName(ns, name));

                break;
                
            case ActionBlockConstants.TRAIT_Method:
            case ActionBlockConstants.TRAIT_Getter:
            case ActionBlockConstants.TRAIT_Setter:
				d = methodTrait(name, ns, t.getDispId(), t.getMethodId(), t.getAttrs(), t.getTag(), build_ast);
				if( build_ast )
					statements.items.add(d.def);

                if( prog != null )
                    prog.toplevelDefinitions.add(new QName(ns, name));

                break;
                
            case ActionBlockConstants.TRAIT_Class:
				d = classTrait(name, ns, t.getSlotId(), t.getClassId(), buildASTForClasses);

                if( prog != null )
                    prog.toplevelDefinitions.add(new QName(ns, name));

                break;
                
            case ActionBlockConstants.TRAIT_Function: // currently unused
                break;
                
            default:
                break;
                //throw new DecoderException("Invalid trait kind: " + kind);
            }
            
            if( t.hasMetadata() && d!= null )
            {
                int[] metadata = t.getMetadata();
                for( int metaIndex: metadata )
                {   
                    MetaDataNode metaNode = parseMetadataInfo(metaIndex);
                    	
                	if ( d.def != null ){
                		metaNode.def = d.def;
                		d.def.addMetaDataNode(metaNode);
						if( build_ast )
                			statements.items.add(metaNode); //{pmd} now hasn't this just been hung off the def node? yup, but fails if not here too.
                	}
       
                	if( d.slot != null )
                	{
                		String md_id = metaNode.getId();
                		if( (MetaDataEvaluator.GO_TO_CTOR_DEFINITION_HELP != md_id) &&
                			(MetaDataEvaluator.GO_TO_DEFINITION_HELP != md_id)  ) // Should be ok since the cpool entries are interned
                		{
                			// Don't add the go_to_def metadata - its never needed by the compiler (its just a hint for tools)
                			// and it takes up a ton of memory if we add it.
                			//??? Used to only add 'deprecated' metadata...???ask Erik whats up here?
                			d.slot.addMetadata(metaNode);
                		}
                	}
                }
            }
        }
    }

    /**
     * Extract a namespace from a multiname.
     * @param mn - the multiname. It should only have one namespace if it's a set.
     * @return the multiname's namespace.
     */ 
    private ObjectValue getNamespaceFromMultiname(AbcData.BinaryMN mn)
    {
        ObjectValue ns;
        if( mn.nsIsSet )
        {
            Namespaces ns_set = getNamespaces(mn.nsID);
			if (ns_set.size() > 1) {       // they should all have the same URI modulo version maker
				ns = null;
				for (ObjectValue t : ns_set) {
					if (ns == null || t.name.length() < ns.name.length()) {
						ns = t; // the unmarked uri is always the shortest, so return it
					}
				}
			}
			else {
				ns = ns_set.at(0);
			}
        }
        else
        {
            ns = getNamespace(mn.nsID);
        }
        return ns;
    }

    private void parseScript(int scriptIndex, BinaryProgramNode program, boolean collectTopLevel, boolean buildASTForClasses)
    {
        if( scriptIndex < 0 || scriptIndex >= this.abcData.getScriptInfoSize() )
        {
            return;
        }
        
        AbcData.ScriptInfo s = this.abcData.getScriptInfo(scriptIndex);
		// at top level always want to set build_ast param to true
        parseTraits(s.getScriptTraits(), program.statements, true, collectTopLevel ? program : null, buildASTForClasses);
    }
    
    
    private MetaDataNode parseMetadataInfo( int index )
    { 
        //  TODO: Cache this data more aggressively.
        MetaDataNode metaNode = ctx.getNodeFactory().metaData(null, -1);
        metaNode.setMetadata(this.abcData.getMetadata(index, metaNode));
        return metaNode;
    }

        
    
    private String getStringFromCPool(int id)
    {
    	return this.abcData.getString(id);
    }

    private Decimal128 getDecimalFromCPool(int id) 
    {
    	return this.abcData.getDecimal(id);
    }
    
    private double getNumberFromCPool(int id, int kind)
    {
        double ret = 0.0;
        switch(kind)
        {
            case ActionBlockConstants.CONSTANT_Integer:
            	ret = this.abcData.getInt(id);
            	return ret;

            case ActionBlockConstants.CONSTANT_UInteger:
            	ret = this.abcData.getUint(id) & 0xFFFFFFFFL;
            	return ret;

            case ActionBlockConstants.CONSTANT_Double:
                ret = this.abcData.getDouble(id);
                return ret;
        }
        // {pmd} silent fail here...is this really a good idea?
        return ret;
    }


    private AbcData.BinaryMN getBinaryMNFromCPool(int index)
    {
        return this.abcData.getName(index);
    }

    Namespaces getNamespaces(int namespaceSetID)
    {
        int[] ns_ids = this.abcData.getNamespaceSet(namespaceSetID).getNamespaceIds();
        Namespaces val = new Namespaces(ns_ids.length);
        for(int i = 0; i < ns_ids.length; ++i)
        {
            val.add(getNamespace(ns_ids[i]));
        }
        return val;
    }

    ObjectValue getNamespace(int namespaceID)
    {
        ObjectValue ns = null;
        if( namespaceID == 0 )
        {
            ns = ctx.anyNamespace();
        }
        else
        {
            int kind = this.abcData.getNamespace(namespaceID).nsKind;
            String uri = this.abcData.getNamespace(namespaceID).getName();
            int ver = -1;
            byte ns_kind;
            
            switch(kind)
            {
            case ActionBlockConstants.CONSTANT_Namespace:
                //vers.add(getVersion(uri));
                ns_kind = Context.NS_PUBLIC;
                ns = ctx.getNamespace(uri);
                break;
            case ActionBlockConstants.CONSTANT_PackageNamespace:
                //vers.add(getVersion(uri));
                ns_kind = Context.NS_PUBLIC;
                ns = ctx.getNamespace(uri);
                ns.setPackage(true);
                break;
            case ActionBlockConstants.CONSTANT_ProtectedNamespace:
                ns_kind = Context.NS_PROTECTED;
                ns = ctx.getNamespace(uri, ns_kind);
                break;
            case ActionBlockConstants.CONSTANT_PackageInternalNs:
                ns_kind = Context.NS_INTERNAL;
                ns = ctx.getNamespace(uri, ns_kind);
                break;
            case ActionBlockConstants.CONSTANT_PrivateNamespace:
                ns_kind = Context.NS_PRIVATE;
                ns = ctx.getNamespace(uri, ns_kind);
                break;
            case ActionBlockConstants.CONSTANT_ExplicitNamespace:
                ns_kind = Context.NS_EXPLICIT;
                ns = ctx.getNamespace(uri, ns_kind);
                break;
            case ActionBlockConstants.CONSTANT_StaticProtectedNs:
                ns_kind = Context.NS_STATIC_PROTECTED;
                ns = ctx.getNamespace(uri, ns_kind);
                break;
            default:
                throw new IllegalStateException("Invalid kind:" + Integer.toString(kind));
            }
        }
        return ns;
    }


/*
    // These dump functions below are just some debugging aids.
    private void dumpProgram(BinaryProgramNode program)
    {

        if( program.statements != null)
        {
            dumpStatementList(program.statements);
        }
    }

    private void dumpClass(BinaryClassDefNode bincls)
    {
        if( bincls.attrs != null)
            System.out.print(attrsToString(bincls.attrs));
        System.out.print("class " + bincls.cframe.name);
        if( bincls.baseref != null)
        {
            System.out.print(" extends " + typeRefToString(bincls.baseref));
        }
        if( bincls.interfaces != null )
        {
            System.out.print(" implements " );
            for( int i = 0; i < bincls.interfaces.size(); ++ i)
            {
                Node n = bincls.interfaces.items.get(i);
                if( n instanceof MemberExpressionNode )
                {
                    System.out.print( typeRefToString(((MemberExpressionNode)n).ref));
                }
            }
        }
        System.out.println("");
        System.out.println("{");
        if( bincls.statements != null)
        {
            dumpStatementList(bincls.statements);
        }

        if( bincls.instanceinits != null)
        {
            dumpNodeList(bincls.instanceinits);
        }

        System.out.println("} //"+bincls.cframe.name);
    }

    private void dumpStatementList(StatementListNode stmts)
    {
        dumpNodeList(stmts.items);
    }
    private void dumpNodeList(ObjectList<Node> stmts)
    {
        for( Node n : stmts)
        {
            if( n instanceof FunctionDefinitionNode )
                dumpFunction((FunctionDefinitionNode)n);
            else if( n instanceof VariableDefinitionNode )
                dumpVar((VariableDefinitionNode)n);
            else if( n instanceof BinaryClassDefNode)
                dumpClass((BinaryClassDefNode)n);
            else if( n instanceof NamespaceDefinitionNode)
                dumpNamespace((NamespaceDefinitionNode)n);
        }
    }
    private void dumpFunction(FunctionDefinitionNode funcDef)
    {

        if( funcDef.attrs != null)
            System.out.print(attrsToString(funcDef.attrs));
        System.out.print("function ");
        if( funcDef.fexpr.kind == Tokens.GET_TOKEN)
            System.out.print("get ");
        else if (funcDef.fexpr.kind == Tokens.SET_TOKEN)
            System.out.print("set ");
        System.out.print( typeRefToString(funcDef.fexpr.identifier.ref) );
        System.out.print("(");
        if(funcDef.fexpr.signature.parameter != null)
        {
            ParameterListNode params = funcDef.fexpr.signature.parameter;
            for(int i = 0; i < params.size(); ++ i)
            {
                ParameterNode param = params.items.get(i);
                if(param != null && param.typeref != null)
                {
                    System.out.print(typeRefToString(param.typeref) );
                }
                System.out.print(", ");
            }
        }
        System.out.print(")");
        if( funcDef.fexpr.signature.result != null)
        {
            System.out.println( " : " + typeRefToString( ((MemberExpressionNode)funcDef.fexpr.signature.result).ref) );
        }
    }

    private void dumpVar(VariableDefinitionNode varDef)
    {
        if(varDef.attrs != null)
            System.out.print(attrsToString(varDef.attrs));
        Node first = varDef.list.items.at(0);
        System.out.print(" " + typeRefToString( ((VariableBindingNode)first).ref));
        System.out.println(" : " + typeRefToString( ((VariableBindingNode)first).typeref) );
//        /System.out.println("  Name: " + varDef.);
    }

    private void dumpNamespace(NamespaceDefinitionNode nsDef)
    {
        System.out.print( attrsToString(nsDef.attrs) );
        System.out.println( " namespace " + nsDef.name.name + " = \"" + ((LiteralStringNode)nsDef.value).value + "\"");

    }
    private String attrsToString(AttributeListNode attr)
    {
        String ret = "";
        if( attr.hasStatic )
            ret += "static ";
        if( attr.hasPublic)
            ret += "public ";
        else if( attr.hasPrivate)
            ret += "private ";
        if(attr.hasOverride)
            ret += " override ";
        if(attr.hasFinal)
            ret += " final ";
        if(attr.namespaces.size() > 0)
            ret += attr.namespaces.at(0).name + " ";

        return ret;
    }
    private String typeRefToString(ReferenceValue typeref)
    {
        String value = "";
        if( typeref.getImmutableNamespaces().size() == 1)
        {
            ObjectValue ns = typeref.getImmutableNamespaces().first();
            if( ns != null && !ns.name.equals("") )
            {
                value = ns.name + ":";
            }
            value += typeref.name;
        }
        else
        {
            value += "{";
            for( int i = 0; i < typeref.getImmutableNamespaces().size(); ++i )
            {
                ObjectValue ns = typeref.getImmutableNamespaces().get(i);
                value += ns.name + ", ";
            }
            value += "}:" + typeref.name;
        }
        return value;
    }
*/
    
    public static void main(String[] args) throws Throwable
     {
         File abcFile = new File(args[0]);
         byte[] bytes = getBytesFromFile(abcFile); 

         TypeValue.init();
         ObjectValue.init();
         Context ctx = new Context(new ContextStatics());
         AbcParser abcParser = new AbcParser(ctx, bytes);
         @SuppressWarnings("unused")
		ProgramNode programNode = abcParser.parseAbc();

         //System.out.println(programNode.toString());
     }

     private static byte[] getBytesFromFile(File file) throws IOException
     {
         FileInputStream is = new FileInputStream(file);
     
         // Get the size of the file
         long length = file.length();
     
         // Create the byte array to hold the data
         byte[] bytes = new byte[(int)length];
     
         // Read in the bytes
         int offset = 0;
         int numRead = 0;
         while (offset < bytes.length
                && (numRead=is.read(bytes, offset, bytes.length-offset)) >= 0) 
         {
             offset += numRead;
         }
     
         // Ensure all the bytes have been read in
         if (offset < bytes.length)
         {
             throw new IOException("Could not completely read file "+file.getName());
         }
     
         // Close the input stream and return bytes
         is.close();
         return bytes;
     }
     
}

