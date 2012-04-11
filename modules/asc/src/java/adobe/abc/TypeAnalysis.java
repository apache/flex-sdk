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

package adobe.abc;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

import adobe.abc.Algorithms.EdgeMap;

import static adobe.abc.Algorithms.*;
import static adobe.abc.OptimizerConstants.BOTTOM;
import static adobe.abc.OptimizerConstants.NAN;
import static adobe.abc.OptimizerConstants.OP_arg;
import static adobe.abc.OptimizerConstants.OP_hasnext2_i;
import static adobe.abc.OptimizerConstants.OP_hasnext2_o;
import static adobe.abc.OptimizerConstants.OP_phi;
import static adobe.abc.OptimizerConstants.OP_xarg;
import static adobe.abc.OptimizerConstants.UNDEFINED;
import static adobe.abc.OptimizerConstants.opNames;
import static adobe.abc.TypeAnalysis.isPointer;
import static adobe.abc.TypeAnalysis.type;
import static java.lang.Boolean.FALSE;
import static java.lang.Boolean.TRUE;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.*;


public abstract class TypeAnalysis 
{

	public static Map<Expr,Typeref> getExprTypes(Method m)
	{
		Map<Expr,Typeref> types = new HashMap<Expr,Typeref>();
		Map<Expr,Object>  values = new HashMap<Expr,Object>();
		
		analyzeTypes(m, types, values);
		return types;
	}
	public static void analyzeTypes(Method m, Map<Expr,Typeref> types, Map<Expr,Object> values)
	{
		// first build the SSA Edges.
		Deque<Block> code = dfs(m.entry.to);
		EdgeMap<Expr> uses = findUses(code);

		Set<Edge> reached = new TreeSet<Edge>();
		
		analyzeTypes(m, uses, values, types, reached);
	}
	
	public static void analyzeTypes(Method m, EdgeMap<Expr> uses, Map<Expr, Object> values, Map<Expr, Typeref> types, Set<Edge> reached)
	{
		Set<Edge> flowWork = new TreeSet<Edge>();
		Set<Expr> ssaWork = new TreeSet<Expr>();
		Set<Expr> ready = new TreeSet<Expr>();

		flowWork.add(m.entry);
		do
		{
			while (!flowWork.isEmpty())
			{
				Edge edge = getEdge(flowWork);
				if (!reached.contains(edge))
				{
					reached.add(edge);
					Block b = edge.to;
					ready.addAll(b.exprs);
					ssaWork.addAll(b.exprs);
					for (Edge x: b.xsucc)
						flowWork.add(x);
				}
			}
			while (!ssaWork.isEmpty())
			{
				Expr e = getExpr(ssaWork);
				if (ready.contains(e))
				{
					evaluateExpr(m, e, values, types, flowWork, ssaWork, uses);
				}
			}
		}
		while (!flowWork.isEmpty());
	}
	
	/**
	 * visit a single expression.  compute it's type and constant value.  If
	 * either change, add any dependents to the appropriate work list.
	 * 
	 * @param m
	 * @param e
	 * @param values
	 * @param types
	 * @param flowWork
	 * @param ssaWork
	 * @param uses
	 */
	private static void evaluateExpr(Method m, Expr e, 
			Map<Expr,Object> values, 
			Map<Expr,Typeref> types,
			Set<Edge>flowWork, Set<Expr>ssaWork, 
			EdgeMap<Expr> uses)
	{
		Object v = null;
		Typeref tref = null;
		
		if (e.op == OP_phi)
		{
			for (Expr a: e.args)
			{
				// compute the phi() meet operation.  ignore any inputs we
				// haven't evaluated yet.  If all inputs have the same value,
				// phi() has that value.  Otherwise return BOTTOM.
				Object av = values.get(a);
				if (av == null) continue; // ignore TOP inputs
				
				if (v == null)
					v = av;
				else if (!av.equals(v))
					v = BOTTOM;
				
				// same idea for types, but if they aren't all the same
				// then compute the most derived base class (mdb) of the types.
				Typeref aref = types.get(a);
				if (tref == null)
					tref = aref;
				else if (!tref.equals(aref))
					tref = mdb(tref,aref);
			}
		}
		else
		{
			// if any arg is TOP result is TOP (unchanged)
			for (Expr a : e.args) if (!values.containsKey(a))	return;
			for (Expr a : e.scopes) if (!values.containsKey(a))	return;
			for (Expr a : e.locals) if (!values.containsKey(a))	return;
			
			v = BOTTOM;
			tref = TypeCache.instance().ANY.ref;
			
			switch (e.op)
			{
			default:
				System.err.println("unhandled op:" + e.op + ":"+ opNames[e.op]);
				assert(false);
			
			case OP_hasnext2_o:
			case OP_nextname:
			case OP_nextvalue:
			case OP_call:
			case OP_callsuper:
			case OP_getsuper:
			case OP_getdescendants:
				break;
				
			case OP_convert_o:
			{
				tref = types.get(e.args[0]).nonnull();
				v = values.get(e.args[0]);
				break;
			}	
			case OP_esc_xattr:
			case OP_esc_xelem:
				tref = TypeCache.instance().STRING.ref.nonnull();
				break;
				
			case OP_newcatch:
				tref = m.handlers[e.imm[0]].activation;
				break;
				
			case OP_newobject:
				tref = TypeCache.instance().OBJECT.ref.nonnull();
				break;
			
			case OP_newarray:
				tref = TypeCache.instance().ARRAY.ref.nonnull();
				break;
				
			case OP_newactivation:
				tref = m.activation;
				break;
				
			case OP_getglobalscope:
				if (m.cx.scopes.length > 0)
				{
					tref = m.cx.scopes[0];
				}
				else
				{
					// same as getscopeobject<0>
					v = values.get(e.scopes[0].args[0]);
					tref = types.get(e.scopes[0].args[0]);
				}
				break;
				
			case OP_getscopeobject:
				v = values.get(e.scopes[0].args[0]);
				tref = types.get(e.scopes[0].args[0]);
				if ( tref == null )
				{
					//  FIXME: Should be more thorough.
					tref = TypeCache.instance().ANY.ref;
				}
				break;
				
			case OP_newclass:
				tref = e.c.ref.nonnull();
				break;
				
			case OP_newfunction:
				tref = TypeCache.instance().FUNCTION.ref.nonnull();
				break;
				
			case OP_finddef:
				if (TypeCache.instance().globals.contains(e.ref))
					tref = TypeCache.instance().globals.get(e.ref);
				break;
				
			case OP_findpropstrict:
			case OP_findproperty:
			{
				int i = findInner(e.ref, e.scopes, types);
				if (i >= 0)
				{
					v = values.get(e.scopes[i]);
					tref = types.get(e.scopes[i]);
				}
				else if ((i = findOuter(e.ref, m.cx.scopes)) >= 0)
				{
					tref = m.cx.scopes[i];
				}
				else if (TypeCache.instance().globals.contains(e.ref))
				{
					tref = TypeCache.instance().globals.get(e.ref);
				}
				else
				{
					// not found.  use global.
					if (m.cx.scopes.length > 0)
					{
						tref = m.cx.scopes[0];
					}
					else
					{
						v = values.get(e.scopes[0]);
						tref = types.get(e.scopes[0]);
					}
				}
				break;
			}
			
			case OP_getlex:
			{
				// findproperty + getproperty
				int i = findInner(e.ref, e.scopes, types);
				Typeref stref = i >= 0 ? types.get(e.scopes[i]) : 
					(i=findOuter(e.ref, m.cx.scopes)) >= 0 ? m.cx.scopes[i] :
						TypeCache.instance().globals.contains(e.ref) ? TypeCache.instance().globals.get(e.ref) :
							m.cx.scopes.length > 0 ? m.cx.scopes[0] :
								types.get(e.scopes[0]);
	
				Binding b = stref.t.findGet(e.ref);
				// code below is a copy of OP_getproperty
				if (b != null)
				{
				
					if ( b.isSlot())
					{
						// TODO we only compute const value here if primitive type.
						// it would be more correct if we knew whether the initializer
						// changed the const value.  (consts can be computed in init).
						tref = b.type;
						if (b.isConst() && b.defaultValueChanged())
							v = b.value;
					}
					else if (b.isMethod())
					{
						// TODO if base type is or might be XML, return ANY
						// TODO use MethodClosure, more specific than Function
						tref = TypeCache.instance().FUNCTION.ref.nonnull();
					}
					else if (b.isGetter())
					{
						tref = b.method.returns;
					}
				}
				break;
			}
			
			case OP_construct:
			{
				tref = TypeCache.instance().OBJECT.ref.nonnull();
				break;
			}
			
			case OP_constructprop:
			{
				Type ot = type(types,e.args[0]); // type of base object
				Binding b = ot.findGet(e.ref);
				if (b != null && b.type != null && b.type.t.itype != null)
				{
					tref = b.type.t.itype.ref.nonnull();
					break;
				}
				break;
			}
			
			case OP_callproperty:
			case OP_callproplex:
			{
				Type ot = type(types, e.args[0]);
				Binding b = ot.findGet(e.ref);
				if ( b != null )
				{
					if (b.isMethod())
					{
						tref = b.method.returns;
					}
					else if (b.isSlot() && b.type != null)
					{
						// each of these has same logic as convert_i, convert_s, etc
						if (b.type.t.itype == TypeCache.instance().INT) 
						{
							tref = TypeCache.instance().INT.ref;
							if ( e.args.length > 1)
								v = eval_convert_i(values.get(e.args[1]));
						}
						else if (b.type.t.itype == TypeCache.instance().UINT) 
						{
							tref = TypeCache.instance().UINT.ref;
							if ( e.args.length > 1)
								v = eval_convert_u(values.get(e.args[1]));
						}
						else if (b.type.t.itype == TypeCache.instance().STRING)
						{
							tref = TypeCache.instance().STRING.ref.nonnull();
							if ( e.args.length > 1)
								v = eval_convert_s(values.get(e.args[1]));
						}
						else if (b.type.t.itype == TypeCache.instance().BOOLEAN)
						{
							tref = TypeCache.instance().BOOLEAN.ref;
							if ( e.args.length > 1)
								v = eval_convert_b(values.get(e.args[1]));
						}
						else if (b.type.t.itype == TypeCache.instance().NUMBER)
						{
							tref = TypeCache.instance().NUMBER.ref;
							if ( e.args.length > 1)
								v = eval_convert_d(values.get(e.args[1]));
						}
					}
				}
				break;
			}
							
			case OP_applytype:
				tref = types.get(e.args[0]).nonnull();
				break;
			
			case OP_callstatic:
				tref = e.m.returns;
				break;
			
			case OP_arg:
				if (e.imm[0] < m.getParams().length)
					tref = m.getParams()[e.imm[0]];
				else if (m.needsArguments()||m.needsRest() && e.imm[0] == m.getParams().length)
					tref = TypeCache.instance().ARRAY.ref.nonnull();
				else
					tref = TypeCache.instance().VOID.ref;
				break;
				
			case OP_xarg:
				tref = m.handlers[e.imm[0]].type;
				break;
				
			case OP_getslot:
			{
				Type t0 = type(types, e.args[0]);
				Binding b = t0.findSlot(e.imm[0]);
				if (b != null)
					tref = b.type;
				break;
			}
			
			case OP_getproperty:
			{
				Type t0 = type(types, e.args[0]);
				Binding b = t0.findGet(e.ref);
				if ( b != null )
				{
					if (b.isSlot())
					{
						// TODO we only compute const value here if primitive type.
						// it would be more correct if we knew whether the initializer
						// changed the const value.  (consts can be computed in init).
						tref = b.type;
						if (b.isConst() && b.defaultValueChanged())
							v = b.value;
					}
					else if (b.isMethod())
					{
						// TODO if base type is or might be XML, return ANY
						// TODO use MethodClosure, more specific than Function
						tref = TypeCache.instance().FUNCTION.ref.nonnull();
					}
					else if (b.isGetter())
					{
						tref = b.method.returns;
					}
				}
				break;
			}
			
			case OP_pushundefined:
				v = e.value;
				tref = TypeCache.instance().VOID.ref;
				break;
				
			case OP_pushnull:
				v = e.value;
				tref = TypeCache.instance().NULL.ref;
				break;
				
			case OP_pushtrue:
			case OP_pushfalse:
				v = e.value;
				tref = TypeCache.instance().BOOLEAN.ref;
				break;
				
			case OP_pushbyte:
			case OP_pushshort:
			case OP_pushint:
				v = e.value;
				tref = TypeCache.instance().INT.ref;
				break;
				
			case OP_pushuint:
				v = e.value;
				tref = TypeCache.instance().UINT.ref;
				break;
				
			case OP_pushstring:
				v = e.value;
				tref = TypeCache.instance().STRING.ref.nonnull();
				break;
				
			case OP_pushnan:
			case OP_pushdouble:
				v = e.value;
				tref = TypeCache.instance().NUMBER.ref;
				break;
				
			case OP_pushnamespace:
				v = e.value;
				tref = TypeCache.instance().NAMESPACE.ref.nonnull();
				break;
				
			case OP_jump:
				flowWork.add(e.succ[0]);
				return;
	
			case OP_lookupswitch:
			{
				Object v1 = values.get(e.args[0]);
				if (v1 == BOTTOM)
					for (Edge s: e.succ)
						flowWork.add(s);
				else
				{
					// input is const
					int i = intValue(v1);
					if (i < 0 || i >= e.succ.length-1) 
						i = e.succ.length-1;
					flowWork.add(e.succ[i]);
				}
				return;
			}
			
			case OP_iffalse:
			case OP_iftrue:
			{
				Object v1 = values.get(e.args[0]);
				if (v1 == BOTTOM)
				{
					flowWork.add(e.succ[0]);
					flowWork.add(e.succ[1]);
				}
				else if (e.op == OP_iffalse)
					flowWork.add(e.succ[booleanValue(v1) ? 0 : 1]);
				else if (e.op == OP_iftrue)
					flowWork.add(e.succ[booleanValue(v1) ? 1 : 0]);
				return;
			}
			
			case OP_pushscope:
			case OP_pushwith:
				// treat this as a copy.
				v = values.get(e.args[0]);
				tref = types.get(e.args[0]).nonnull();
				break;
				
			case OP_convert_b:
				tref = TypeCache.instance().BOOLEAN.ref;
				v = eval_convert_b(values.get(e.args[0]));
				break;
				
			case OP_not:
			{
				tref = TypeCache.instance().BOOLEAN.ref;
				Object v0 = values.get(e.args[0]);
				if (v0 != BOTTOM)
					v = booleanValue(v0) ? FALSE : TRUE;
				break;
			}
				
			case OP_deleteproperty:
				// TODO result is const false for any declared property
			case OP_deldescendants:
			case OP_hasnext:
			case OP_hasnext2:
			case OP_equals:
			case OP_strictequals:
			case OP_in:
			case OP_istype:
			case OP_istypelate:
			case OP_instanceof:
				tref = TypeCache.instance().BOOLEAN.ref;
				break;
				
			case OP_lessthan:
			case OP_lessequals:
			case OP_greaterthan:
			case OP_greaterequals:
			{
				tref = TypeCache.instance().BOOLEAN.ref;
				Object v0 = values.get(e.args[0]);
				Object v1 = values.get(e.args[1]);
				if (v0.equals(NAN) || v0 == UNDEFINED || v1.equals(NAN) || v1 == UNDEFINED)
					v = FALSE;
				else if (v0 != BOTTOM && v1 != BOTTOM)
					v = e.op == OP_lessthan ?     lessthan(v0,v1) :
						e.op == OP_lessequals ?  !lessthan(v1,v0) :
					    e.op == OP_greaterthan ?  lessthan(v1,v0) :
					    	                     !lessthan(v0,v1);
				break;
			}
			
			case OP_convert_s:
				tref = TypeCache.instance().STRING.ref.nonnull();
				v = eval_convert_s(values.get(e.args[0]));
				break;
			
			case OP_coerce_s:
			{
				tref = eval_coerce_s(types.get(e.args[0]));
				v = eval_coerce_s(values.get(e.args[0]));
				break;
			}

			case OP_coerce_o:
			{
				Typeref t0 = types.get(e.args[0]);
				tref = eval_coerce_o(t0);
				v = eval_coerce_o(values.get(e.args[0]), t0.t);
				break;
			}

			case OP_coerce_a:
			{
				//  This cast has meaning if it's casting from void.
				//  Otherwise, it's an upcast and can be removed;
				//  casts will be re-inserted as appropriate.
				if ( ! (types.get(e.args[0]).equals(TypeCache.instance().VOID.ref) ) )
				{
					v = values.get(e.args[0]);
					tref = types.get(e.args[0]);
				}
				else
				{
					tref = TypeCache.instance().ANY.ref;
				}
				break;
			}
			
			case OP_coerce:
			{
				Typeref t0 = types.get(e.args[0]);
				Object v0 = values.get(e.args[0]);
				Type t = TypeCache.instance().namedTypes.get(e.ref);
				assert ( t != null );
				
				if (t == TypeCache.instance().STRING)
				{
					tref = eval_coerce_s(t0);
					v = eval_coerce_s(v0);
				}
				else if (t == TypeCache.instance().OBJECT)
				{
					tref = eval_coerce_o(t0);
					v = eval_coerce_o(v0,t0.t);
				}
				else if (t == TypeCache.instance().INT)
				{
					tref = t.ref;
					v = eval_convert_i(v0);
				}
				else if (t == TypeCache.instance().UINT) 
				{
					tref = t.ref;
					v = eval_convert_u(v0);
				}
				else if (t == TypeCache.instance().NUMBER) 
				{
					tref = t.ref;
					v = eval_convert_d(v0);
				}
				else if (t == TypeCache.instance().BOOLEAN) 
				{
					tref = t.ref;
					v = eval_convert_b(v0);
				}
				else
				{
					// pointer style cast
					if (t0.t.extendsOrIsBase(t))
					{
						// ignore upcasts
						tref = t0;
						v = v0;
					}
					else if (t0.t == TypeCache.instance().NULL || t0.t == TypeCache.instance().VOID)
					{
						tref = TypeCache.instance().NULL.ref;
					}
					else
					{
						tref = t.ref;
					}
				}
				break;
			}
			
			case OP_astype:
				// TODO constant folding
				tref = TypeCache.instance().namedTypes.get(e.ref).ref;
				break;
			
			case OP_astypelate:
			{
				Typeref t1 = types.get(e.args[1]);
				if (t1.t.itype != null)
				{
					if (t1.t.itype.atom || t1.t.itype.numeric)
						tref = TypeCache.instance().OBJECT.ref;
					else
						tref = t1.t.itype.ref;
				}
				else
				{
					tref = TypeCache.instance().ANY.ref;
				}
				break;
			}
			
			case OP_typeof:
			{
				Type t0 = type(types,e.args[0]);
				if (t0 == TypeCache.instance().INT || t0 == TypeCache.instance().UINT || t0 == TypeCache.instance().NUMBER)
					v = "number";
				else if (t0 == TypeCache.instance().STRING)
					v = "string";
				else if (t0.extendsOrIsBase(TypeCache.instance().XML) || t0.extendsOrIsBase(TypeCache.instance().XMLLIST))
					v = "xml";
				else if (t0 == TypeCache.instance().VOID)
					v = "undefined";
				else if (t0 == TypeCache.instance().BOOLEAN)
					v = "boolean";
				else if (t0.extendsOrIsBase(TypeCache.instance().FUNCTION))
					v = "function";
				else if (t0 != TypeCache.instance().OBJECT && t0.extendsOrIsBase(TypeCache.instance().OBJECT))
					v = "object";
				tref = TypeCache.instance().STRING.ref.nonnull();
				break;
			}
			
			case OP_add:
			{
				Expr a0 = e.args[0];
				Expr a1 = e.args[1];
				Typeref t0 = types.get(a0);
				Typeref t1 = types.get(a1);
				Object v0 = values.get(a0);
				Object v1 = values.get(a1);
				if (t0.t == TypeCache.instance().STRING && !t0.nullable || t1.t == TypeCache.instance().STRING && !t1.nullable)
				{
					tref = TypeCache.instance().STRING.ref.nonnull();
					if (v0 != BOTTOM && v1 != BOTTOM)
						v = stringValue(v0) + stringValue(v1);
				}
				else if (t0.t.numeric && t1.t.numeric)
				{
					tref = TypeCache.instance().NUMBER.ref;
					if (v0 instanceof Number && v1 instanceof Number)
						v = doubleValue(v0) + doubleValue(v1);
				}
				else
				{
					// TODO make all primitives extend a type so we can use that type here.
					tref = TypeCache.instance().OBJECT.ref.nonnull(); // will be a String or a Number
				}
				break;
			}
			
			case OP_divide:
			{
				tref = TypeCache.instance().NUMBER.ref;
				Object v0 = values.get(e.args[0]);
				Object v1 = values.get(e.args[1]);
				if (v0 instanceof Number && v1 instanceof Number)
					v = doubleValue(v0) / doubleValue(v1);
				break;
			}
			
			case OP_subtract:
			case OP_multiply:
			case OP_modulo:
			case OP_negate:
			case OP_increment:
			case OP_decrement:
				tref = TypeCache.instance().NUMBER.ref;
				break;

			case OP_convert_d:
				tref = TypeCache.instance().NUMBER.ref;
				v = eval_convert_d(values.get(e.args[0]));
				break;
				
			case OP_convert_i:
				tref = TypeCache.instance().INT.ref;
				v = eval_convert_i(values.get(e.args[0]));
				break;

			case OP_convert_u:
				tref = TypeCache.instance().UINT.ref;
				v = eval_convert_u(values.get(e.args[0]));
				break;
	
			case OP_bitor:
			{
				tref = TypeCache.instance().INT.ref;
				Object v0 = values.get(e.args[0]);
				Object v1 = values.get(e.args[1]);
				if (v0 instanceof Number && v1 instanceof Number)
					v = intValue(v0) | intValue(v1);
				break;
			}
			
			case OP_bitand:
			{
				tref = TypeCache.instance().INT.ref;
				Object v0 = values.get(e.args[0]);
				Object v1 = values.get(e.args[1]);
				if (v0 instanceof Number && v1 instanceof Number)
				{
					v = intValue(v0) & intValue(v1);
				}
				break;
			}
				
			case OP_bitnot:
			case OP_add_i:
			case OP_subtract_i:
			case OP_multiply_i:
			case OP_negate_i:
			case OP_bitxor:
			case OP_lshift:
			case OP_rshift:
			case OP_hasnext2_i:
			case OP_increment_i:
			case OP_decrement_i:
				// TODO constant folding
				tref = TypeCache.instance().INT.ref;
				break;
				
			case OP_urshift:
				// TODO constant folding
				tref = TypeCache.instance().UINT.ref;
				break;
				
			// these ops do not produce any value
			case OP_setslot:
			case OP_setproperty:
			case OP_setsuper:
			//case OP_setglobalslot: // deprecated
			case OP_initproperty:
			case OP_callpropvoid:
			case OP_constructsuper:
			case OP_callsupervoid:
			case OP_returnvoid:
			case OP_returnvalue:
			case OP_throw:
			case OP_popscope:
			case OP_debug:
			case OP_debugline:
			case OP_debugfile:
			case OP_bkpt:
			case OP_bkptline:
			case OP_checkfilter:
				return;
			}
		}
		
		assert(tref != null && tref.t != null);
		
		// singleton types have a specific value.
		if (tref.t == TypeCache.instance().VOID)
			v = UNDEFINED;
		else if (tref.t == TypeCache.instance().NULL)
			v = TypeCache.instance().NULL;
		
		if (v != null && !v.equals(values.get(e)))
		{
			values.put(e, v);
			ssaWork.addAll(uses.get(e));
		}
		
		if (!tref.equals(types.get(e)))
		{
			types.put(e, tref);
			ssaWork.addAll(uses.get(e));
		}
	}
	
	public static boolean isPointer(Type t)
	{
		return !t.isAtom() && !t.numeric;
	}
	
	public static Object eval_convert_i(Object v0)
	{
		return v0 instanceof Number ? intValue(v0) :
			   v0 == TRUE ? 1 :
			   v0 == FALSE ? 0 :
			   BOTTOM;
	}

	public static Object eval_convert_u(Object v0)
	{
		return v0 instanceof Number ? uintValue(v0) :
			   v0 == TRUE ? 1 :
			   v0 == FALSE ? 0 :
			   BOTTOM;
	}

	public static Object eval_convert_d(Object v0)
	{
		return v0 instanceof Number ? doubleValue(v0) :
			   v0 == TRUE ? 1 :
			   v0 == FALSE ? 0 :
			   BOTTOM;
	}

	public static Object eval_convert_b(Object v0)
	{
		return v0 == BOTTOM ? BOTTOM :
			   booleanValue(v0) ? TRUE : FALSE;
	}
	
	public static Object eval_convert_s(Object v0)
	{
		return v0 != BOTTOM ? stringValue(v0) : BOTTOM;
	}
	
	public static Typeref eval_coerce_s(Typeref t0)
	{
		if (t0.nullable)
			return t0.t == TypeCache.instance().VOID || t0.t == TypeCache.instance().NULL ? TypeCache.instance().NULL.ref : TypeCache.instance().STRING.ref;
		else
			return TypeCache.instance().STRING.ref.nonnull();
	}
	
	public static Object eval_coerce_s(Object v0)
	{
		return v0 == UNDEFINED || v0 == TypeCache.instance().NULL ? TypeCache.instance().NULL :
			   v0 != BOTTOM ? stringValue(v0) :
			   BOTTOM;
	}
	
	public static Typeref eval_coerce_o(Typeref t0)
	{
		if (t0.nullable)
			return t0.t.extendsOrIsBase(TypeCache.instance().OBJECT) ? t0 :
			   t0.t == TypeCache.instance().VOID || t0.t == TypeCache.instance().NULL ? TypeCache.instance().NULL.ref :
			   TypeCache.instance().OBJECT.ref;
		else
			return t0.t.extendsOrIsBase(TypeCache.instance().OBJECT) ? t0 : TypeCache.instance().OBJECT.ref.nonnull();
	}
	
	public static Object eval_coerce_o(Object v0, Type t0)
	{
		return t0.extendsOrIsBase(TypeCache.instance().OBJECT) ? v0 :
			   t0 == TypeCache.instance().VOID || t0 == TypeCache.instance().NULL ? TypeCache.instance().NULL :
			   BOTTOM;
	}
	
	public static boolean lessthan(Object v0, Object v1)
	{
		if (v0 instanceof String && v1 instanceof String)
		{
			return ((String)v0).compareTo((String)v1) < 0;
		}
		else
		{
			return doubleValue(v0) < doubleValue(v1);
		}
	}
	
	public static Type type(Map<Expr,Typeref>types, Expr e)
	{
		assert(types.containsKey(e));
		return types.get(e).t;
	}
	

	public static int intValue(Object o)
	{
		return ((Number)o).intValue();
	}
	
	public static long uintValue(Object o)
	{
		return ((Number)o).longValue() & 0xFFFFFFFFL;
	}
	
	public static double doubleValue(Object o)
	{
		return o instanceof Number ? ((Number)o).doubleValue() : Double.NaN;
	}
	
	public static boolean booleanValue(Object o)
	{
		if (o instanceof Boolean)
			return o == TRUE;
		if (o instanceof String || o instanceof Namespace)
			return true;
		if (o == TypeCache.instance().NULL || o == UNDEFINED)
			return false;
		return doubleValue(o) != 0;
	}
	
	public static String stringValue(Object v0)
	{
		// TODO ES3 compatible double format
		return String.valueOf(v0);
	}
	
	public static /**
	 * most derived base
	 * @param a - first type
	 * @param b - second type
	 * @return Typeref to the "nearest" common base type.
	 */
	Typeref mdb(Typeref a, Typeref b)
	{
		// TODO support interfaces
		assert(a != b && a != null && b != null);
		
		// null is compatible with pointer types
		if (a.t == TypeCache.instance().NULL && isPointer(b.t)) return b;
		if (b.t == TypeCache.instance().NULL && isPointer(a.t)) return a;
		
		Set<Type> bases = new HashSet<Type>();
		for (Type t = a.t; t != null; t = t.base)
			bases.add(t);
		
		for (Type t = b.t; t != null; t = t.base)
			if (bases.contains(t))
				return new Typeref(t, a.nullable | b.nullable);
		
		return new Typeref(TypeCache.instance().ANY, a.nullable | b.nullable);
	}
	
	/**
	 * find inner scope.  returns index of object or -1 if not found.
	 * @param ref
	 * @param scopes
	 * @param types
	 * @return
	 */
	public static int findInner(Name ref, Expr[] scopes, Map<Expr,Typeref> types)
	{
		for (int i=scopes.length-1; i >= 0; i--)
		{
			Type st = type(types,scopes[i]);
			Binding b = st.find(ref);
			if (b != null)
				return i;
		}
		return -1;
	}
	
	/**
	 * find outer scope.  returns index, or -1 if not found, in which
	 * case caller can look in globals.
	 * 
	 * @param ref
	 * @param scopes
	 * @return
	 */
	public static int findOuter(Name ref, Typeref[] scopes)
	{
		for (int i=scopes.length-1; i >= 1; i--)
		{
			Type st = scopes[i].t;
			Binding b = st.find(ref);
			if (b != null)
				return i;
		}
		Typeref st = TypeCache.instance().globals.get(ref);
		if (st != null)
			return -1; // how to identify which global?
		if (scopes.length > 0 && scopes[0].t.find(ref) != null)
			return 0;
		return -1; // can't find it (caller can search globals, will return null).
	}

}
