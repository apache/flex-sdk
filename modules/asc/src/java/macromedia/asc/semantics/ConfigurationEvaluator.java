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

package macromedia.asc.semantics;

import static macromedia.asc.embedding.avmplus.RuntimeConstants.TYPE_boolean;
import static macromedia.asc.embedding.avmplus.RuntimeConstants.TYPE_int;
import static macromedia.asc.embedding.avmplus.RuntimeConstants.TYPE_number;
import static macromedia.asc.embedding.avmplus.RuntimeConstants.TYPE_double;
import static macromedia.asc.embedding.avmplus.RuntimeConstants.TYPE_decimal;
import static macromedia.asc.embedding.avmplus.RuntimeConstants.TYPE_string;
import static macromedia.asc.embedding.avmplus.RuntimeConstants.TYPE_uint_external;
import static macromedia.asc.parser.Tokens.*;

import java.util.HashSet;

import macromedia.asc.embedding.ErrorConstants;
import macromedia.asc.parser.*;
import macromedia.asc.util.Context;
import macromedia.asc.util.IntegerPool;
import macromedia.asc.util.Namespaces;
import macromedia.asc.util.ObjectList;
import macromedia.asc.util.NumberConstant;

public class ConfigurationEvaluator implements Evaluator, ErrorConstants {

	private boolean fold_expressions = false;

    private boolean top_level = false;
    
    private HashSet<String> config_namespaces = new HashSet<String>();
    
	private ObjectValue getBooleanObjectValue(Context cx, boolean b)
	{
		if( b )
		{
			return cx.booleanTrue();
		}
		else
		{
			return cx.booleanFalse();
		}
	}
	public boolean checkFeature(Context cx, Node node) {
		return true;
	}

	public Value evaluate(Context cx, Node node) {
		return null;
	}

	public Value evaluate(Context cx, IncrementNode node) {
		node.expr = evalAndFold(cx, node.expr);
		return null;
	}

	public Value evaluate(Context cx, DeleteExpressionNode node) {
		node.expr = evalAndFold(cx, node.expr);
		return null;
	}

	public Value evaluate(Context cx, IdentifierNode node) {
		return new ReferenceValue(cx, null, node.name, cx.publicNamespace());
	}

	public Value evaluate(Context cx, InvokeNode node) {
		node.args.evaluate(cx, this);
		node.expr = evalAndFold(cx, node.expr);
		return null;
	}

	public Value evaluate(Context cx, ThisExpressionNode node) {
		return null;
	}

	public Value evaluate(Context cx, QualifiedIdentifierNode node) {
		Value result = null;

		Value val = node.qualifier != null ? node.qualifier.evaluate(cx, this) : null;
		AttributeListNode attrs = ((node.qualifier instanceof AttributeListNode) ? (AttributeListNode)node.qualifier : null);
        if( attrs != null && attrs.items != null && attrs.items.size() == 1)
        {
        	// We are probably in a variable definition
        	val = attrs.items.at(0).evaluate(cx, this);
    		ReferenceValue ref = val instanceof ReferenceValue ? (ReferenceValue)val : null;
    		if( ref != null )
    		{
    			Slot s = ref.getSlot(cx);
    			if( s != null && s.getObjectValue() != null && s.getObjectValue().isConfigNS() )
    			{
    				ReferenceValue temp = new ReferenceValue(cx, null, node.name, s.getObjectValue());
    				temp.setPosition(node.qualifier.getPosition());
    				result = temp;
    				
    			}
    		}
        }
        else if( val instanceof ReferenceValue )
        {
        	ReferenceValue ref = (ReferenceValue)val;
        	Slot s = ref.getSlot(cx);
        	if ( s != null && s.getObjectValue() != null && s.getObjectValue().isConfigNS() )
        	{
        		ReferenceValue temp = new ReferenceValue(cx, null, node.name, s.getObjectValue());
        		temp.setPosition(node.getPosition());
        		result = temp;
        	}
        }
		return result;
	}

	public Value evaluate(Context cx, QualifiedExpressionNode node) {
		return null;  // Should this do anything?
	}

	public Value evaluate(Context cx, LiteralBooleanNode node) {
        return getBooleanObjectValue(cx, node.value);
	}

	public Value evaluate(Context cx, LiteralNumberNode node) {
        TypeValue[] type = new TypeValue[1];
        node.numericValue = cx.getEmitter().getValueOfNumberLiteral( node.value, type, node.numberUsage);
        node.type = type[0];
        return new ObjectValue(node.value, node.type);
	}

	public Value evaluate(Context cx, LiteralStringNode node) {
		return new ObjectValue(node.value, cx.stringType());
	}

	public Value evaluate(Context cx, LiteralNullNode node) {
		return null;
	}

	public Value evaluate(Context cx, LiteralRegExpNode node) {
		return null;
	}

	public Value evaluate(Context cx, LiteralXMLNode node) {
		return null;
	}

	public Value evaluate(Context cx, FunctionCommonNode node) {
		node.signature.evaluate(cx, this);
		
		ConfigurationBuilder config_bui = new ConfigurationBuilder();
		ObjectValue scope = new ObjectValue(cx, config_bui, null);
		cx.pushScope(scope);
		
		node.body.evaluate(cx, this);
		
		cx.popScope();
		
		return null;
	}

	public Value evaluate(Context cx, ParenExpressionNode node) {
		node.expr = evalAndFold(cx, node.expr);
		return null;
	}

	public Value evaluate(Context cx, ParenListExpressionNode node) {
		node.expr = evalAndFold(cx, node.expr);
		return null;
	}

	private void evalArrayOrObjectArgList(Context cx, ArgumentListNode list)
	{
		if( list != null )
		{
			for ( int i = list.size()-1; i > 0; --i)
			{
				Node n = list.items.at(i);
				ListNode l = n instanceof ListNode ? (ListNode)n : null;
				if( l != null && l.size()==2 && l.items.at(0).isConfigurationName() )
				{
					Value config_val = l.items.at(0).evaluate(cx, this);
					
					if( config_val != null && config_val.isReference() && ((ReferenceValue)config_val).isConfigRef())
					{
						ReferenceValue r = (ReferenceValue)config_val;
		            	Value v = config_val.getValue(cx);
		            	if( v == null )
		            	{
		            		cx.error(r.getPosition(), kError_UnfoundProperty, r.name);
		            	}
		            	else
		            	{
			                Boolean b = toBoolean(cx, (ObjectValue)r.getValue(cx));
			                if( b != null && b.booleanValue())
			                {
			                	list.items.set(i, l.items.at(1));
			                }
			                else
			                {
			                	list.items.remove(i);
			                }
		            	}
					}
				}
			}
		}
	}
	public Value evaluate(Context cx, LiteralObjectNode node) {
		if( node.fieldlist!= null )
		{
			evalArrayOrObjectArgList(cx, node.fieldlist);
			node.fieldlist.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, LiteralFieldNode node) {
        node.name = evalAndFold(cx, node.name);
        node.value = evalAndFold(cx, node.value);
		return null;
	}

	public Value evaluate(Context cx, LiteralArrayNode node) {
		if( node.elementlist != null )
		{
			evalArrayOrObjectArgList(cx, node.elementlist);
			node.elementlist.evaluate(cx, this);
		}
		return null;
	}
	
	public Value evaluate(Context cx, LiteralVectorNode node) {
		node.type.evaluate(cx, this);
		if( node.elementlist != null )
		{
			evalArrayOrObjectArgList(cx, node.elementlist);
			node.elementlist.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, SuperExpressionNode node) {
		node.expr = evalAndFold(cx, node.expr);
		return null;
	}

	public Value evaluate(Context cx, SuperStatementNode node) {
		node.call.evaluate(cx, this);
		return null;
	}

	public Value evaluate(Context cx, MemberExpressionNode node) {
		if( node.base != null )
		{
			node.base = evalAndFold(cx, node.base);
		}
		Value val = node.selector.evaluate(cx, this);
		return val;
	}

	public Value evaluate(Context cx, CallExpressionNode node) {
		if( node.args != null ) node.args.evaluate(cx, this);
		return null;
	}

	public Value evaluate(Context cx, GetExpressionNode node) {
        Value val = node.expr.evaluate(cx,this);
		return val;
	}

    public Value evaluate(Context cx, ApplyTypeExprNode node)
    {
        return null;
    }
    
    public Value evaluate(Context cx, SetExpressionNode node) {
		node.args.evaluate(cx, this);
		return null;
	}

	private Boolean toBoolean(Context cx, ObjectValue obj)
	{
		Boolean ret = null;
		TypeInfo ti = obj.getType(cx);
		TypeValue tv = ti != null ? ti.getTypeValue() : null;
		if ( tv != null )
		{
			if( tv == cx.booleanType() )
			{
				ret = obj.booleanValue() ? Boolean.TRUE : Boolean.FALSE;
			}
			else if( tv == cx.stringType() )
			{
				String s = obj.getValue();
				if( s == null || "".equals(s) )
					ret = Boolean.FALSE;
				else
					ret = Boolean.TRUE;
			}
			else if( isNumericType(cx, tv) )
			{
                TypeValue[] type = new TypeValue[1];
                double d = cx.getEmitter().getValueOfNumberLiteral( obj.getValue(), type, obj.getNumberUsage()).doubleValue();
                if( Double.isNaN(d) || d == 0.0 )
                	ret = Boolean.FALSE;
                else
                	ret = Boolean.TRUE;
			}
		}
		return ret;
	}

	private String toString(Context cx, ObjectValue obj)
	{
		String ret = null;
		TypeInfo ti = obj.getType(cx);
		TypeValue tv = ti != null ? ti.getTypeValue() : null;
		if ( tv != null )
		{
			if( tv == cx.booleanType() )
			{
				ret = obj.booleanValue() ? "true" : "false";
			}
			else if( tv == cx.stringType() )
			{
				ret = obj.getValue();
			}
			else if( isNumericType(cx, tv) )
			{
                TypeValue[] type = new TypeValue[1];
                NumberConstant v = cx.getEmitter().getValueOfNumberLiteral( obj.getValue(), type, obj.getNumberUsage());
                ret = v.toString();
			}
		}
		return ret;
	}

	private Double toNumber(Context cx, ObjectValue obj)
	{
		Double ret = null;
		TypeInfo ti = obj.getType(cx);
		TypeValue tv = ti != null ? ti.getTypeValue() : null;
		if ( tv != null )
		{
			if( tv == cx.booleanType() )
			{
				ret = new Double(obj.booleanValue() ? 1 : 0);
			}
			else if( tv == cx.stringType() || isNumericType(cx, tv))
			{
                TypeValue[] type = new TypeValue[1];
                try
                {
                	ret = cx.getEmitter().getValueOfNumberLiteral( obj.getValue(), type, obj.getNumberUsage()).doubleValue();
                }
                catch(NumberFormatException nfe)
                {
                	// must not be a number
                }
			}
		}
		return ret;
	}
	
	private Integer toInt(Context cx, ObjectValue obj)
	{
		Integer i = null;
		Double d = toNumber(cx, obj);
		if( d != null )
		{
			if( d.isInfinite() || d.isNaN() || d.doubleValue() == 0.0 )
				i = IntegerPool.getNumber(0);
			else
				i = IntegerPool.getNumber((int)d.doubleValue());
		}
		return i;
	}

	private Long toUInt(Context cx, ObjectValue obj)
	{
		Long l = null;
		Double d = toNumber(cx, obj);
		if( d != null )
		{
			if( d.isInfinite() || d.isNaN() || d.doubleValue() == 0.0 )
				l = new Long(0);
			else
				l = new Long((long)d.doubleValue());
		}
		return l;
	}
	
	public Value evaluate(Context cx, UnaryExpressionNode node) {
		Value val = null;
		if( fold_expressions )
		{
			Value expr_val = node.expr.evaluate(cx, this);
			
			Node new_expr = foldRefValue(cx, expr_val);
			if( new_expr != null )
			{
				node.expr = new_expr;
				expr_val = node.expr.evaluate(cx, this);
			}
			
			if( expr_val != null && expr_val.hasValue() )
			{
				ObjectValue expr_ov = (ObjectValue)expr_val;
				
				switch( node.op )
				{
				case NOT_TOKEN:
					Boolean b = toBoolean(cx, expr_ov);
					if( b != null )
						val = getBooleanObjectValue(cx, !b);
					break;
				}
			}
		}
		else
		{
			node.expr = evalAndFold(cx, node.expr);
		}
		return val;
	}

	public Value evaluate(Context cx, BinaryExpressionNode node) {
		Value val = null;
		if( fold_expressions )
		{
			Value lhs_val = node.lhs.evaluate(cx, this);
			Value rhs_val = node.rhs.evaluate(cx, this);
			
			Node new_lhs = foldRefValue(cx, lhs_val);
			Node new_rhs = foldRefValue(cx, rhs_val);
			if( new_lhs != null )
			{
				node.lhs = new_lhs;
				lhs_val = node.lhs.evaluate(cx, this);
			}
			if( new_rhs != null )
			{
				node.rhs = new_rhs;
				rhs_val = node.rhs.evaluate(cx, this);
			}
			
			if( lhs_val != null && rhs_val != null && lhs_val.hasValue() && rhs_val.hasValue() )
			{
				ObjectValue lhs_ov = (ObjectValue)lhs_val;
				ObjectValue rhs_ov = (ObjectValue)rhs_val;
				
				TypeValue lt = lhs_ov.getType(cx).getTypeValue();
				TypeValue rt = rhs_ov.getType(cx).getTypeValue();
				
				switch(node.op)
				{
				case PLUS_TOKEN:
					if( isNumericType(cx, lt) && isNumericType(cx, rt) )
					{
	                    TypeValue[] type = new TypeValue[1];
	                    double ld = cx.getEmitter().getValueOfNumberLiteral( lhs_ov.getValue(), type, node.numberUsage).doubleValue();
	                    double rd = cx.getEmitter().getValueOfNumberLiteral( rhs_ov.getValue(), type, node.numberUsage).doubleValue();
	                    double d = 0.0/0;
	                    d = ld + rd;
	                    val = new ObjectValue(Double.toString(d), cx.numberType());
					}
					else if( lt == cx.stringType() || rt == cx.stringType() )
					{
	                    String ls = toString(cx, lhs_ov);
	                    String rs = toString(cx, rhs_ov);
	                    val = new ObjectValue(ls+rs,cx.stringType());
					}
					break;
	            case MINUS_TOKEN:
	            case MULT_TOKEN:
	            case DIV_TOKEN:
	            case MODULUS_TOKEN:
	            	if( isNumericType(cx, lt) && isNumericType(cx, rt) )
	            	{
	                    TypeValue[] type = new TypeValue[1];
	                    double ld = cx.getEmitter().getValueOfNumberLiteral( lhs_ov.getValue(), type, node.numberUsage).doubleValue();
	                    double rd = cx.getEmitter().getValueOfNumberLiteral( rhs_ov.getValue(), type, node.numberUsage).doubleValue();
	                    double d = 0.0/0;
	                    switch( node.op )
	                    {
	                    case MINUS_TOKEN:
	                        d = ld-rd;
	                        break;
	                    case MULT_TOKEN:
	                        d = ld*rd;
	                        break;
	                    case DIV_TOKEN:
	                        d = ld/rd;
	                        break;
	                    case MODULUS_TOKEN:
	                        d = ld%rd;
	                        break;
	                    }
	                    val = new ObjectValue(Double.toString(d), cx.numberType());
	                    break;
	            	}
				case LOGICALOR_TOKEN:
				{
					Boolean b = toBoolean(cx, lhs_ov);
					Boolean b2 = toBoolean(cx, rhs_ov);
					if( b != null && b2 != null )
					{
						val = getBooleanObjectValue(cx, b.booleanValue() || b2.booleanValue());
					}
					break;
				}
				case LOGICALAND_TOKEN:
				{
					Boolean b = toBoolean(cx, lhs_ov);
					Boolean b2 = toBoolean(cx, rhs_ov);
					if( b != null && b2 != null )
					{
						val = getBooleanObjectValue(cx, b.booleanValue() && b2.booleanValue());
					}
					break;
				}
				case EQUALS_TOKEN:
				case NOTEQUALS_TOKEN:
				{
					Boolean b = compare(cx, lhs_ov, rhs_ov);
					if( b != null )
						if( node.op == NOTEQUALS_TOKEN)
							val = getBooleanObjectValue(cx, !b.booleanValue());
						else
							val = getBooleanObjectValue(cx, b.booleanValue());
					break;
				}
				
				case LESSTHAN_TOKEN:
				case GREATERTHANOREQUALS_TOKEN:
				{
					String less_result = lessthan(cx, lhs_ov, rhs_ov);
					Boolean b = null;
					if( node.op == LESSTHAN_TOKEN )
					{
						if( less_result == UNDEFINED || less_result == FALSE )
							b = Boolean.FALSE;
						else
							b = Boolean.TRUE ;
					}
					else
					{
						if( less_result == UNDEFINED || less_result == TRUE )
							b = Boolean.FALSE;
						else
							b = Boolean.TRUE;
					}
					if( b != null )
						val = getBooleanObjectValue(cx, b.booleanValue());
					break;
				}
				
				case LESSTHANOREQUALS_TOKEN:
				case GREATERTHAN_TOKEN:
				{
					String less_result = lessthan(cx, rhs_ov, lhs_ov);
					Boolean b = null;
					if( node.op == LESSTHANOREQUALS_TOKEN )
					{
						if( less_result == UNDEFINED || less_result == TRUE )
							b = Boolean.FALSE;
						else
							b = Boolean.TRUE ;
					}
					else
					{
						if( less_result == UNDEFINED || less_result == FALSE )
							b = Boolean.FALSE;
						else
							b = Boolean.TRUE;
					}
					if( b != null )
						val = getBooleanObjectValue(cx, b.booleanValue());
					break;
				}
				
				case LEFTSHIFT_TOKEN:
				case RIGHTSHIFT_TOKEN:
				{
					Integer li  = toInt(cx, lhs_ov);
					Integer ri = toInt(cx, rhs_ov) ;
					if( li != null && ri != null )
					{
						ri = ri & 0x1F;
						if( node.op == LEFTSHIFT_TOKEN )
							val = new ObjectValue(String.valueOf(li << ri), cx.intType());
						else
							val = new ObjectValue(String.valueOf(li >> ri), cx.intType());
					}
					break;
				}
				case UNSIGNEDRIGHTSHIFT_TOKEN:
				{
					Long ll  = toUInt(cx, lhs_ov);
					Long rl = toUInt(cx, rhs_ov);
					if( ll != null && rl != null )
					{
						rl = rl & 0x1F;
						val = new ObjectValue(String.valueOf(ll >>> rl), cx.intType());
					}
					break;
				}
				
				case BITWISEAND_TOKEN:
				case BITWISEXOR_TOKEN:
				case BITWISEOR_TOKEN:
				{
					Integer li = toInt(cx, lhs_ov);
					Integer ri = toInt(cx, rhs_ov);
					if( li != null && ri != null )
					{
						int result = 0;
						switch(node.op)
						{
						case BITWISEAND_TOKEN:
							result = li & ri;
							break;
						case BITWISEOR_TOKEN:
							result = li | ri;
							break;
						case BITWISEXOR_TOKEN:
							result = li ^ ri;
							break;
						}
						val = new ObjectValue(String.valueOf(result), cx.intType());
					}
				}
				}

			}
		}
		else
		{
			node.lhs = evalAndFold(cx, node.lhs);
			node.rhs = evalAndFold(cx, node.rhs);
		}
		return val;
	}

	static final String UNDEFINED = "undefined";
	static final String TRUE = "true";
	static final String FALSE = "false";
	
	private String lessthan(Context cx, ObjectValue lhs, ObjectValue rhs)
	{
		Double ld = toNumber(cx, lhs);
		Double rd = toNumber(cx, rhs);
		
		if( ld != null && rd != null )
		{
			if( ld.isNaN() || rd.isNaN() )
				return UNDEFINED;
			
			if( ld.doubleValue() == rd.doubleValue() )
				return FALSE;
			
			if( ld.isInfinite() )
			{
				if( ld.doubleValue() > 0)
					return FALSE;
				else
					return TRUE;
			}
			
			if( rd.isInfinite() )
			{
				if( rd.doubleValue() < 0 )
					return FALSE;
				else
					return TRUE;
			}
			
			if( ld.doubleValue() < rd.doubleValue() )
				return TRUE;
			else
				return FALSE;
		}
		return null;
	}
	
	private Boolean compare(Context cx, ObjectValue lhs, ObjectValue rhs)
	{
		if( lhs!= null && lhs.hasValue() && rhs != null && rhs.hasValue() )
		{
			if( lhs == rhs )
				return Boolean.TRUE;
			
			TypeValue rhs_type = rhs.getType(cx).getTypeValue();
			TypeValue lhs_type = lhs.getType(cx).getTypeValue();
			
			if( lhs_type == rhs_type )
			{
				if( lhs_type == cx.stringType() )
				{
					return lhs.getValue().equals(toString(cx, rhs));
				}
				else if( lhs_type == cx.booleanType() )
				{
					Boolean b1 = toBoolean(cx, lhs);
					Boolean b2 = toBoolean(cx, rhs);
					if( b1.booleanValue() == b2.booleanValue() )
						return Boolean.TRUE;
					else
						return Boolean.FALSE;
				}
				else if( isNumericType(cx, lhs_type) )
				{
					Double d1 = toNumber(cx, lhs);
					Double d2 = toNumber(cx, rhs);
					if( d1.doubleValue() == d2.doubleValue() )
						return Boolean.TRUE;
					else
						return Boolean.FALSE;
				}
			}
			else
			{
				if( (isNumericType(cx,lhs_type) && isNumericType(cx, rhs_type)) ||
					(isNumericType(cx, lhs_type) && rhs_type == cx.stringType()) ||
					(lhs_type == cx.stringType() && isNumericType(cx, rhs_type)) ||
					lhs_type == cx.booleanType() || rhs_type == cx.booleanType() )
				{
					Double d1 = toNumber(cx, lhs);
					Double d2 = toNumber(cx, rhs);
					if( d1 != null && d2 != null && d1.doubleValue() == d2.doubleValue() )
						return Boolean.TRUE;
					else
						return Boolean.FALSE;
				}
			}
		}
		return Boolean.FALSE;
	}
	
	private ObjectValue numberObjVal(Context cx, double d)
	{
		return new ObjectValue(String.valueOf(d), cx.numberType());
	}
	
	private boolean isNumericType(Context cx, TypeValue typeval)
	{
		return (typeval == cx.numberType() || typeval == cx.intType() || typeval == cx.uintType());
	}
	public Value evaluate(Context cx, ConditionalExpressionNode node) {
		node.condition = evalAndFold(cx, node.condition);
		node.thenexpr = evalAndFold(cx, node.thenexpr);
		node.elseexpr = evalAndFold(cx, node.elseexpr);
		return null;
	}

	public Value evaluate(Context cx, ArgumentListNode node) {
	    for (int i = 0, size = node.items.size(); i < size; i++)
        {
	        Node n = node.items.get(i);
            Node temp = null;
            if (n != null)
            {
                temp = evalAndFold(cx, n);
                if( temp != n )
                    node.items.set(i, temp);
            }
        }
	    return null;
	}

	public Value evaluate(Context cx, ListNode node) {
		Value val = null;
		for( int i = 0, size = node.items.size(); i < size; ++i)
		{
			Node n = node.items.at(i);
			val = n.evaluate(cx, this);
			Node temp = foldRefValue(cx, val);
			if( temp != null )
			{
				node.items.set(i, temp);
				val = temp.evaluate(cx, this);
			}
		}
		return val;
	}

	public Value evaluate(Context cx, StatementListNode node) {
        NodeFactory nodeFactory = cx.getNodeFactory();

        if( node.config_attrs != null )
        {
        	node.config_attrs.evaluate(cx, this);
    		if( node.config_attrs.compileDefinition == false)
    			node.items.clear();
    		node.config_attrs = null;
        }

        for (int i = 0, size = node.items.size(); i < size; ++i)
        {
        	Node n = node.items.at(i);
        	if( n != null && n.isDefinition() )
        	{
        		DefinitionNode def = (DefinitionNode)n;
        		if( def.attrs != null )
        		{
	        		def.attrs.evaluate(cx, this);
	        		
	        		if( !def.attrs.compileDefinition )
	        		{
	        			node.items.set(i,nodeFactory.emptyStatement());
                        removeMetaData(cx, def, node, i);
	        			continue;
	        		}
        		}
                
                boolean old_toplevel = top_level;
                if( !( def instanceof ConfigNamespaceDefinitionNode || def instanceof VariableDefinitionNode) )
                    top_level = false;
    			
                def.evaluate(cx, this);
                
                top_level = old_toplevel;
                
    			if( def instanceof VariableDefinitionNode )
    			{
    				VariableDefinitionNode vardef = (VariableDefinitionNode)def;
    				if( vardef.list.items.size() == 0 )
                    {
                        removeMetaData(cx, vardef, node, i);
    					node.items.set(i, nodeFactory.emptyStatement());
                    }
    			}
        	}
            else if ( n instanceof StatementListNode )
            {
                StatementListNode stmt = (StatementListNode)n;
                if( stmt.config_attrs != null )
                {
                    stmt.config_attrs.evaluate(cx, this);
                    if( stmt.config_attrs.compileDefinition )
                    {
                        // Look for previous Metadata/DocComments if the stmtlist starts with a definition
                        DefinitionNode def;
                        if( (def = startsWithDefinition(cx, stmt)) != null )
                        {
                            for( int m = i-1; m >= 0; --m)
                            {
                                Node temp = node.items.at(m);
                                if( temp instanceof MetaDataNode)
                                {
                                    MetaDataNode metadata = (MetaDataNode)temp;
                                    metadata.def = def;
                                    def.addMetaDataNode(metadata);
                                }
                                else if( !(temp instanceof IncludeDirectiveNode || temp instanceof EmptyStatementNode) )
                                {
                                    break;
                                }
                            }
                        }
                        if( stmt.last() instanceof MetaDataNode && ((def = findNextDefinition(cx, node, i+1))!= null))
                        {
                            for( int m = stmt.items.size()-1; m >= 0; --m)
                            {
                                Node temp = stmt.items.at(m);
                                if( temp instanceof MetaDataNode )
                                {
                                    MetaDataNode metadata = (MetaDataNode)temp;
                                    metadata.def = def;
                                    def.addMetaDataNode(metadata);
                                }
                                else if( !(temp instanceof IncludeDirectiveNode || temp instanceof EmptyStatementNode) )
                                {
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {
                        node.items.set(i, nodeFactory.emptyStatement());
                    }
                    stmt.config_attrs = null;
                }
                n = node.items.at(i);
                Node temp = evalAndFold(cx, n);
                if( temp != n )
                    node.items.set(i, temp);
            }
            else
        	{
                
                boolean old_topLevel = top_level;
                if( !(n instanceof StatementListNode) )
                {
                    
                    top_level = false;
                }
                
        		Node temp = evalAndFold(cx, n);
        		if( temp != n )
        			node.items.set(i, temp);
                
                if( !(n instanceof StatementListNode) )
                {
                    top_level = old_topLevel;
                }
        	}
        }
        
        return null;
	}

    // Helper function to clean up the metadata nodes that had pointed
    // to a removed defintion.
    private void removeMetaData(Context cx, DefinitionNode def, StatementListNode list, int def_index)
    {
        if( def.metaData != null )
        {
            NodeFactory nf = cx.getNodeFactory();
            for( int i = def_index-1; i >= 0; --i )
            {
                Node temp = list.items.at(i);
                MetaDataNode meta = temp instanceof MetaDataNode ? (MetaDataNode)temp : null;
                if( meta != null && meta.def == def )
                {
                    list.items.set(i, nf.emptyStatement());
                    meta.def = null;
                }
                else if( !(temp instanceof IncludeDirectiveNode) )
                {
                    break;
                }
                
            }
            def.metaData = null;
        }        
    }

    // Returns the next definition node in the list starting from start
    // This skips over metadata, comments, etc, to find the next definition node
    // returns null if a definition is not found.
    private DefinitionNode findNextDefinition(Context cx, StatementListNode list, int start)
    {
        DefinitionNode def = null;
        for( int i =start, l=list.items.size(); i < l; ++i)
        {
            Node n = list.items.at(i);
            if( n instanceof MetaDataNode || n instanceof IncludeDirectiveNode )
            {
                continue;
            }
            if( n instanceof DefinitionNode )
            {
                def = (DefinitionNode)n;
            }
            break;
        }
        return def;
    }

    // Returns the first definition node if the list starts with a definition
    // This skips over metadata, comments, etc, to find the first definition node
    // returns null if the list does not start with a definition.
    private DefinitionNode startsWithDefinition(Context cx, StatementListNode list)
    {
        return findNextDefinition(cx, list, 0);
    }

    private Node evalAndFold(Context cx, Node n)
    {
    	Node ret = n;
        if( n != null )
        {
	        Value val = n.evaluate(cx, this);
	        ret = foldRefValue(cx, val);
	        if( ret == null )
	        	ret = n;
        }
        return ret;
    }

    // Generates a new literal node if val is a reference to a configuration variable
    private Node foldRefValue(Context cx, Value val)
    {
        Node ret = null;
        
        ReferenceValue ref_val = val instanceof ReferenceValue ? (ReferenceValue)val : null;
        
        if( ref_val != null )
        {
            if( ref_val.isConfigRef() )
            {
            	Value v = ref_val.getValue(cx);
            	if( v == null )
            	{
            		cx.error(ref_val.getPosition(), kError_UnfoundProperty, ref_val.name);
            	}
            	else
            	{
	                ret = literalFromValue(cx, v);
            	}
                if( ret != null )
                	ret.evaluate(cx, this);
            }
        }
        
        return ret;
    }

    private Node literalFromValue(Context cx, Value val)
    {
        Node ret = null;
        
        if( val instanceof ObjectValue )
        {
            ObjectValue obj_val = val instanceof ObjectValue ? (ObjectValue)val : null;
            
            if( obj_val != null )
            {
                Node literal_node = null;
                switch(obj_val.getType(cx).getTypeId())
                {
                    case TYPE_string:
                        literal_node = cx.getNodeFactory().literalString(obj_val.getValue());
                        break;
                    case TYPE_boolean:
                        literal_node = cx.getNodeFactory().literalBoolean(obj_val.booleanValue());
                        break;
                    case TYPE_number:
                    case TYPE_int:
                    case TYPE_uint_external:
                    case TYPE_decimal:
                    case TYPE_double:
                        literal_node = cx.getNodeFactory().literalNumber(obj_val.getValue());
                        break;
                }
                ret = literal_node;
            }
        }
        return ret;
    }
    
	public Value evaluate(Context cx, EmptyElementNode node) {
		return null;
	}

	public Value evaluate(Context cx, EmptyStatementNode node) {
		return null;
	}

	public Value evaluate(Context cx, ExpressionStatementNode node) {
		Value val;
		val = node.expr.evaluate(cx, this);
		Node temp = foldRefValue(cx, val);
		if( temp != null )
		{
			node.expr = temp;
			val = temp.evaluate(cx, this);
		}
		return val;
	}

	public Value evaluate(Context cx, LabeledStatementNode node) {
		node.label = evalAndFold(cx, node.label);
		node.statement = evalAndFold(cx, node.statement);
		return null;
	}

	public Value evaluate(Context cx, IfStatementNode node) {
		node.condition = evalAndFold(cx, node.condition);
		node.thenactions = evalAndFold(cx, node.thenactions);
		node.elseactions = evalAndFold(cx, node.elseactions);
		return null;
	}

	public Value evaluate(Context cx, SwitchStatementNode node) {
		node.expr = evalAndFold(cx, node.expr);
        if( node.statements != null)
            node.statements.evaluate(cx, this);
		return null;
	}

	public Value evaluate(Context cx, CaseLabelNode node) {
		node.label = evalAndFold(cx, node.label);
		return null;
	}

	public Value evaluate(Context cx, DoStatementNode node) {
		node.expr = evalAndFold(cx, node.expr);
		node.statements = evalAndFold(cx, node.statements);
		return null;
	}

	public Value evaluate(Context cx, WhileStatementNode node) {
		node.expr = evalAndFold(cx, node.expr);
		node.statement = evalAndFold(cx, node.statement);
		return null;
	}

	public Value evaluate(Context cx, ForStatementNode node) {
		node.initialize = evalAndFold(cx, node.initialize);
		node.test = evalAndFold(cx, node.test);
		node.increment = evalAndFold(cx, node.increment);
		node.statement = evalAndFold(cx, node.statement);
		return null;
	}

	public Value evaluate(Context cx, WithStatementNode node) {
		node.expr = evalAndFold(cx, node.expr);
		node.statement = evalAndFold(cx, node.statement);
		return null;
	}

	public Value evaluate(Context cx, ContinueStatementNode node) {
		return null;
	}

	public Value evaluate(Context cx, BreakStatementNode node) {
		return null;
	}

	public Value evaluate(Context cx, ReturnStatementNode node) {
		node.expr = evalAndFold(cx, node.expr);
		return null;
	}

	public Value evaluate(Context cx, ThrowStatementNode node) {
		node.expr = evalAndFold(cx, node.expr);
		return null;
	}

	public Value evaluate(Context cx, TryStatementNode node) {
		if( node.tryblock != null )
			node.tryblock.evaluate(cx, this);
		if(node.catchlist != null)
			node.catchlist.evaluate(cx, this);
		if( node.finallyblock != null )
			node.finallyblock.evaluate(cx, this);
		return null;
	}

	public Value evaluate(Context cx, CatchClauseNode node) {
		if( node.parameter != null )
			node.parameter = evalAndFold(cx, node.parameter);
		if( node.statements != null )
			node.statements.evaluate(cx, this);
		return null;
	}

	public Value evaluate(Context cx, FinallyClauseNode node) {
		if( node.default_catch != null )
			node.default_catch.evaluate(cx, this);
		if( node.statements != null )
			node.statements.evaluate(cx, this);
		return null;
	}

	public Value evaluate(Context cx, UseDirectiveNode node) {
		// TODO use number pragmas
		return null;
	}

	public Value evaluate(Context cx, IncludeDirectiveNode node) {
		return null;
	}

	public Value evaluate(Context cx, ImportNode node) {
		return null;
	}

	public Value evaluate(Context cx, MetaDataNode node) {
        this.evaluate(cx, node.data);
        return null;
	}

	public Value evaluate(Context cx, DocCommentNode node) {
		return null;
	}

	public Value evaluate(Context cx, ImportDirectiveNode node) {
		return null;
	}

	public Value evaluate(Context cx, AttributeListNode node) {
		ObjectValue obj = null;
		for( int i = 0, size = node.items.size(); i < size; ++i )
		{
			Node n = node.items.at(i);
	        Value val1 = n.evaluate(cx,this);
	
            obj = ((val1 instanceof ObjectValue) ? (ObjectValue)val1 : null);
            if( obj!=null )
            {
                if( i == size-1 &&
                    obj.getType(cx).getTypeValue() == cx.booleanType()  )
                {
                    node.compileDefinition = obj.booleanValue();
                    node.items.removeLast();
                }
            }
		}
		return null;
	}

	public Value evaluate(Context cx, VariableDefinitionNode node) {
		node.list.evaluate(cx, this);
		for( int i = node.list.items.size()-1 ; i >= 0; --i )
		{
			Node n = node.list.items.at(i);
			if( n instanceof VariableBindingNode )
			{
				VariableBindingNode var_bind = (VariableBindingNode)n;
				if(var_bind.ref != null && var_bind.ref.isConfigRef() )
                {
					node.list.items.removeLast();
                }
			}
		}
		return null;
	}

	public Value evaluate(Context cx, VariableBindingNode node) {
        Value val = node.variable.identifier.evaluate(cx,this);
        ReferenceValue ref = ((val instanceof ReferenceValue) ? (ReferenceValue)val : null);
        
        if( ref != null && ref.isConfigRef() )
        {
            if( !isTopLevel() )
            {
                cx.error(node.pos(), kError_InvalidConfigLocation);
                return null;
            }

    		ObjectValue obj = cx.scope();
    		Builder bui = obj.builder;
    		Namespaces hasNamespaces = obj.hasNames(cx, GET_TOKEN, ref.name, ref.namespaces);
    		if( hasNamespaces == null )
    		{
                int var_id, slot_id;
                var_id  = bui.Variable(cx,obj);
                // TODO: does the type of the slot matter?
                slot_id = bui.ExplicitVar(cx,obj,ref.name,ref.namespaces,cx.noType(),-1,-1,var_id);
                Slot slot = obj.getSlot(cx,slot_id);
                if( node.kind != Tokens.CONST_TOKEN)
                {
                	cx.error(node.attrs.pos(),kError_NonConstConfigVar );
                }
                slot.setConst(true);
        		if( node.initializer == null )
        		{
                	cx.error(node.pos(), kError_NonConstantConfigInit);
        		}
        		else
        		{
        			// Turn on constant folding for expressions.  
        			boolean old_fold = fold_expressions;
        			fold_expressions = true;
	                Value init_val = node.initializer.evaluate(cx, this);
	                fold_expressions = old_fold;
	                if( init_val == null || !init_val.hasValue() )
	                {
	                	cx.error(node.initializer.pos(), kError_NonConstantConfigInit);
	                }
		        	slot.setValue(init_val);
        		}
	        	node.ref = ref;
    		}
            else
            {
                cx.error(node.variable.identifier.pos(), kError_ConflictingNameInNamespace, ref.name, ref.namespaces.at(0).name);
            }
        }
        else
        {
        	node.initializer = evalAndFold(cx, node.initializer);
        }
		return null;
	}

	public Value evaluate(Context cx, UntypedVariableBindingNode node) {
		// not used
		return null;
	}

	public Value evaluate(Context cx, TypedIdentifierNode node) {
		return node.identifier.evaluate(cx, this);
	}

	public Value evaluate(Context cx, TypeExpressionNode node) {
		return null;
	}

	public Value evaluate(Context cx, FunctionDefinitionNode node) {
		node.fexpr.evaluate(cx, this);
		return null;
	}

	public Value evaluate(Context cx, BinaryFunctionDefinitionNode node) {
		return null;
	}

	public Value evaluate(Context cx, FunctionNameNode node) {
		return null;
	}

	public Value evaluate(Context cx, FunctionSignatureNode node) {
		if( node.parameter != null ) node.parameter.evaluate(cx, this);
		if( node.result != null ) node.result.evaluate(cx, this);
		return null;
	}

	public Value evaluate(Context cx, ParameterNode node) {
		node.init = evalAndFold(cx, node.init);
		return null;
	}

	public Value evaluate(Context cx, ParameterListNode node) {
		for( int i = 0, size = node.items.size(); i < size; ++i )
		{
			ParameterNode n = node.items.at(i);
			n.evaluate(cx, this);
		}
			
		return null;
	}

	public Value evaluate(Context cx, RestExpressionNode node) {
		return null;
	}

	public Value evaluate(Context cx, RestParameterNode node) {
		return null;
	}

	public Value evaluate(Context cx, InterfaceDefinitionNode node) {
		return this.evaluate(cx, (ClassDefinitionNode)node);
	}

	public Value evaluate(Context cx, ClassDefinitionNode node) {
		ConfigurationBuilder config_bui = new ConfigurationBuilder();
		ObjectValue scope = new ObjectValue(cx, config_bui, null);
		cx.pushScope(scope);

		if( node.statements != null )node.statements.evaluate(cx, this);
		
		cx.popScope();
		
		return null;
	}

	public Value evaluate(Context cx, BinaryClassDefNode node) {
		return null;
	}

	public Value evaluate(Context cx, BinaryInterfaceDefinitionNode node) {
		return null;
	}

	public Value evaluate(Context cx, ClassNameNode node) {
		return null;
	}

	public Value evaluate(Context cx, InheritanceNode node) {
		return null;
	}

    private boolean isTopLevel()
    {
        return top_level;
    }
    
	public Value evaluate(Context cx, ConfigNamespaceDefinitionNode node) {
        
        if( !isTopLevel() )
        {
            cx.error(node.pos(), kError_InvalidConfigLocation);
            return null;
        }
        Namespaces namespaces = new Namespaces();
        ObjectList<String> namespace_ids = new ObjectList<String>();
        // can use public since the ConfigurationScopes won't exist after this evaluator.
        namespaces.push_back(cx.publicNamespace());

        // Get the current object and its builder

        ObjectValue obj = cx.scope();
        Builder     bui = obj.builder;

        int slot_id = -1;

        Namespaces hasNamespaces = obj.hasNames(cx,GET_TOKEN,node.name.name,namespaces);
        if( hasNamespaces == null )
        {
            int var_id;
            var_id  = bui.Variable(cx,obj);
            slot_id = bui.ExplicitVar(cx,obj,node.name.name,namespaces,cx.noType(),-1,-1,var_id);

            Slot s = obj.getSlot(cx,slot_id);

            String name = cx.debugName("",node.name.name,namespace_ids,EMPTY_TOKEN);
            ObjectValue ns = cx.getNamespace(name.intern(),Context.NS_INTERNAL);
            if( ns instanceof NamespaceValue )
        	{
            	((NamespaceValue)ns).config_ns = true;
        	}
            s.setObjectValue(ns);

            s.setConst(true);
            
            config_namespaces.add(node.name.name);
        }

        return null;
	}
	public Value evaluate(Context cx, NamespaceDefinitionNode node) {
        if( config_namespaces.contains(node.name.name) )
            cx.error(node.pos(), kError_ShadowedConfigNamespace, node.name.name);
        return null;
	}

	public Value evaluate(Context cx, PackageDefinitionNode node) {
		return null;
	}

	public Value evaluate(Context cx, PackageIdentifiersNode node) {
		return null;
	}

	public Value evaluate(Context cx, PackageNameNode node) {
		return null;
	}

	public Value evaluate(Context cx, ProgramNode node) {
		// Create a config builder and scope
		ConfigurationBuilder config_bui = new ConfigurationBuilder();
		ObjectValue scope = new ObjectValue(cx, config_bui, null);
		cx.pushScope(scope);
		
        top_level = true;
        
		// Only have to eval statements since this is run before hoisting
		node.statements.evaluate(cx, this);
	
        top_level = false;
        
		cx.popScope();
		return null;
	}

	public Value evaluate(Context cx, BinaryProgramNode node) {
		return null;
	}

	public Value evaluate(Context cx, ErrorNode node) {
		return null;
	}

	public Value evaluate(Context cx, ToObjectNode node) {
		node.expr = evalAndFold(cx, node.expr);
		return null;
	}

	public Value evaluate(Context cx, LoadRegisterNode node) {
		return null;
	}

	public Value evaluate(Context cx, StoreRegisterNode node) {
		return null;
	}

	public Value evaluate(Context cx, RegisterNode node) {
		return null;
	}

	public Value evaluate(Context cx, HasNextNode node) {
		return null;
	}

	public Value evaluate(Context cx, BoxNode node) {
		node.expr = evalAndFold(cx, node.expr);
		return null;
	}

	public Value evaluate(Context cx, CoerceNode node) {
		node.expr = evalAndFold(cx, node.expr);
		return null;
	}

	public Value evaluate(Context cx, PragmaNode node) {
		node.list.evaluate(cx, this);
		return null;
	}

	public Value evaluate(Context cx, PragmaExpressionNode node) {
		return null;
	}

	public Value evaluate(Context cx, DefaultXMLNamespaceNode node) {
		return null;
	}
    public Value evaluate(Context cx, UsePrecisionNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, UseNumericNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, UseRoundingNode node)
    {
        return null;
    }


}
