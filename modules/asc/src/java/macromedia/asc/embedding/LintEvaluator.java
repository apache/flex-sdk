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

package macromedia.asc.embedding;

import static macromedia.asc.embedding.avmplus.RuntimeConstants.TYPE_bool;
import static macromedia.asc.embedding.avmplus.RuntimeConstants.TYPE_boolean;
import static macromedia.asc.embedding.avmplus.RuntimeConstants.TYPE_double;
import static macromedia.asc.embedding.avmplus.RuntimeConstants.TYPE_decimal;
import static macromedia.asc.embedding.avmplus.RuntimeConstants.TYPE_int;
import static macromedia.asc.embedding.avmplus.RuntimeConstants.TYPE_uint;
import macromedia.asc.embedding.avmplus.*;
import macromedia.asc.util.*;
import macromedia.asc.parser.*;
import macromedia.asc.semantics.*;
import static macromedia.asc.parser.Tokens.*;
import static macromedia.asc.embedding.WarningConstants.*;
import static macromedia.asc.semantics.Slot.*;

import java.util.*;
import java.io.*;

/**
 * This is the Evaluator for the -coach compiler option.  It gives warnings for
 * problems that may be valid AS3 code but will likely not work as the author intended.
 */
public final class LintEvaluator extends Emitter implements Evaluator, ErrorConstants
{
	static boolean debug = false;

	private static final String newline = System.getProperty("line.separator");
	
	private static class CodeLocation
	{
		int pos;				// position within <input> where error occurred
		InputBuffer input;		// buffer for the file where this error comes from.
	}

	// Structure used to record an occurance of a warning in the source code.  These are queued up as they are recorded
	//  and then dumped out at the end of the evaluation, grouped by category.
	private static class WarningRecord 
	{
		CodeLocation loc;
		int lineNum;
		int colNum;
		int code;
		String errStringArg1;
		String errStringArg2;
        String errStringArg3;
		WarningRecord(CodeLocation location, int l, int c, int co,String s1, String s2, String s3)
		{
			loc = location;
			lineNum = l;
			colNum = c;
			code = co;
			errStringArg1 = s1;
			errStringArg2 = s2;
            errStringArg3 = s3;
		};
	};


	public boolean checkFeature(Context cx, Node node)
	{
		return true;
	}

	public Value evaluate( Context cx, Node node )
	{
		return null;
	}

	public Value evaluate( Context cx, IdentifierNode node )
	{
		if( node.ref != null )
		{
			return node.ref.getType(cx).getTypeValue(); //  getDerivedType(cx);
		}
		return cx.noType();
	}
	

	// logs a warning if the slot is marked with [Deprecated] metadata
	private void checkDeprecatedSlot(Context cx, Node node, ReferenceValue ref, Slot s)
	{
		if( s != null && s.getMetadata() != null )
		{
			ArrayList<MetaData> md = s.getMetadata();
			for( int i =0, size = md.size(); i < size; ++i )
			{
				MetaData md_node = md.get(i);
				if( "Deprecated".equals(md_node.id) )
				{
                    String since       = null;
                    String message     = null;
                    String replacement = null;
                    
                    for( int r = 0, val_size = md_node.count(); r < val_size; ++r )
                    {
                        final Value val = md_node.values[r];
                        if( val instanceof MetaDataEvaluator.KeyValuePair )
                        {
                            final MetaDataEvaluator.KeyValuePair temp = (MetaDataEvaluator.KeyValuePair)val;
                            if( "message".equals(temp.key) )
                                message = temp.obj;
                            else if ( "replacement".equals(temp.key) )
                                replacement = temp.obj;
                            else if ( "since".equals(temp.key) )
                                since = temp.obj;
                        }
                        else if( val instanceof MetaDataEvaluator.KeylessValue )
                        {
                            // [Deprecated("foo")]
                            final MetaDataEvaluator.KeylessValue temp = (MetaDataEvaluator.KeylessValue)val;
                            message = temp.obj;
                        }
                    }
                    
                    logDeprecationWarning(node, cx, ref.name, since, message, replacement);
				}
			}
		}
	}

	/**
	 * Logs the appropriate Deprecation warning based on available information in the metadata;
	 * will not log anything if since, message, and replacement are null. 
	 */
    //*** IF YOU MODIFY THIS, update flex2.compiler.mxml.builder::checkLogDeprecationWarning()
    private void logDeprecationWarning(Node node, Context cx, String name,
                                       String since, String message, String replacement)
    {
        final int pos = node.getPosition();
        final InputBuffer input = cx.input;
        
        assert ((name != null) &&
                (name.length() > 0));
        
        final boolean hasSince       = (since       != null) && (since.length()       > 0);
        final boolean hasMessage     = (message     != null) && (message.length()     > 0);
        final boolean hasReplacement = (replacement != null) && (replacement.length() > 0);
        
        if (hasMessage)
        {
            // [Deprecated("foo")]
            // [Deprecated(message="foo")]
            warning(pos, input, kWarning_DeprecatedMessage, message);
        }
        else if (hasReplacement)
        {
            if (hasSince)
            {
                // [Deprecated(since="1983", replacement="foo")]
                warning(pos, input, kWarning_DeprecatedSince, name, since, replacement);
            }
            else
            {
                // [Deprecated(replacement="foo")]
                warning(pos, input, kWarning_DeprecatedUseReplacement, name, replacement);                   
            }
        }
        else if (hasSince)
        {
            // [Deprecated(since="1983")]
            warning(pos, input, kWarning_DeprecatedSinceNoReplacement, name, since);
        }
        else
        {
            // this case differs from MXMLC's implementation:
            //   [Deprecated]
            //   [Deprecated(since="")]
            //   [Deprecated(message="")]
            //   [Deprecated(replacement="")]
            warning(pos, input, kWarning_Deprecated, name);
        }
    }
    
	private Value evaluateGenericCallExpression( Context cx, CallExpressionNode node )
	{
		if (first_pass)
		{
			if( node.args != null )
			{
				TypeValue baseType = baseType_context.last();
				baseType_context.removeLast();
				baseRef_context.add(null);
				node.args.evaluate(cx,this);				
				baseType_context.add(baseType);
				baseRef_context.removeLast();
			}
			node.expr.evaluate(cx,this);
			return cx.noType(); // doesn't matter what we return during first_pass.
		}

        Slot s = (node.ref == null ? null : node.ref.getSlot( cx, (node.is_new ? NEW_TOKEN : EMPTY_TOKEN)));
		if (node.ref != null && s == null)
		{
            TypeValue searchType = baseType_context.last(); // todo: why is this more reliable than node->ref->base

            // if this is an attempt to access a static member of a class, switch searchType to the class's type
            //   This is necessary to allow lookup in the unsupportedMethodsMap table.
   			if (searchType != null && "Class".equals(searchType.name.toString()))
            {
                ReferenceValue br = baseRef_context.back();
                s = (br != null ? br.getSlot(cx,GET_TOKEN) : null);
                // c++ variant accesses union member typValue directly, java stores value in objValue
                TypeValue t = (s != null && s.getObjectValue() instanceof TypeValue) ? (TypeValue)(s.getObjectValue()) : null;
                searchType = (t != null) ? t : searchType;
            }

            // cn:  note we can check xml/xmlList for unknown methods, but not unknown properties.  Dynamically defined props due to xml children will
            //      trump any instance props at runtime.  Not true for methods, however.  A method not known at compile time will never be defined
            //      at runtime by the xml data itself.  It would have to be defined by the author as a dynamic property of the instance (i.e. just like Date, RegExp and Error: unlikely).
            if (searchType == types[kDateType] || searchType == cx.regExpType() || searchType == cx.xmlType() || searchType == cx.xmlListType() ||
                (types[kErrorType] != null && types[kErrorType].includes(cx,searchType)))  // these types are dynamic for backwards compatability, so ! doesn't catch this.  Its unlikely anyone is adding dynamic props to them
            {
                warning(node.pos(), cx.input, kWarning_BadES3TypeMethod, node.ref.name, searchType.name.name);
            }
            else
            {
                Map<TypeValue,Integer> search = unsupportedMethodsMap.get(node.ref.name);
				if (search != null && ! search.isEmpty())
                {
                    for(TypeValue type : search.keySet())
                    {
                        if (type != null && type.includes(cx,searchType))
                        {
                            warning(node.getPosition(), cx.input, kWarning_DepricatedFunctionError, node.ref.name,
                                warningConstantsMap.get(search.get(type)));
                        }
                    }
                }
            }
	    }

		if (node.ref != null && node.is_new)
		{
			Slot callSlot = node.ref.getSlot(cx,EMPTY_TOKEN);
			if ( callSlot != null && callSlot.getType().getTypeValue() != cx.typeType() ) // don't warn for non-functions or functions actually declared to return a Class.
			{
				// in ES3.0,  function A() { var local = new Object(); local.c = 20; return c; };  var dd = new A();
				//  dd is assigned the new object returned by A, rather than a new instance of A.  In AS2.0, dd is
				//  assigned a new instance of A.  While not something people would do on purpose, its not an unlikely
				//  accident that a function intended for new instance creation might have a return in it.  Warn if it does
				Slot getSlot = node.ref.getSlot(cx,GET_TOKEN);
				ObjectValue base = node.ref.getBase(); // new obj.func() always worked as expected in AS2, however.  Don't warn if there's a base
				if (base == null && getSlot != null && slot_GetHasReturnValue(s))
				{
					warning(node.getPosition(), cx.input, kWarning_ConstructorReturnsValue, node.ref.name, node.ref.name);
				}
			}
		}

		if( s != null )
			checkDeprecatedSlot(cx, node, node.ref, s);
		
		if( node.args != null )
		{
			TypeValue baseType = baseType_context.last();
			baseType_context.removeLast();
			baseRef_context.add(null);
			node.args.evaluate(cx,this);
			baseRef_context.removeLast();
			baseType_context.add(baseType);
		}

		node.expr.evaluate(cx,this);

		if (node.ref == null)
			return cx.noType();

		// fix returnType if this is a "new" expression and function doesn't return a type
		if (node.is_new)
		{
			if ("Boolean".equals(node.ref.name) && !(node.args != null && node.args.size() != 0))
			{
				warning(node.getPosition(), cx.input, kWarning_BooleanConstructorWithNoArgs);
			}
			
            /* Reactivated, but more specific (only for blank strings)... Old comment follows:
             *    This warning is kind of obscure and not likely to affect a lot of
             *    people compared to the volume of warnings it will generate. */
			// cn:  not sure where this came from (bug assigned to Jono?), but this is so special
			//      cased as to not be useful.   We should remove this warning.
			else if ("Number".equals(node.ref.name) && node.args != null && node.args.items.size() == 1)
			{
				Node arg = node.args.items.get(0);
				Value argTypeVal = arg.evaluate(cx, this);
				if (argTypeVal == cx.stringType()
					&& (arg instanceof LiteralStringNode)
					&& "".equals(((LiteralStringNode)arg).value.trim())) 
				{
					warning(node.getPosition(), cx.input, kWarning_NumberFromStringChanges);
				}
			}
			else if ("XML".equals(node.ref.name)) // AS2 XML class has been renamed to XMLDocument, AS3 XML is better and different
			{
				warning(node.getPosition(), cx.input, kWarning_XML_ClassHasChanged);
			}
        }
		else 
		{
			if ("Array".equals(node.ref.name)) // Array(x) cast is same as constructor "new Array(x)"
			{
				warning(node.getPosition(), cx.input, kWarning_BadArrayCast);
			}
			else if ("Date".equals(node.ref.name)) // Date(x) cast is same as "new Date().toString()", x is ignored, string returned
			{
				warning(node.getPosition(), cx.input, kWarning_BadDateCast);
			}
			else if ("XML".equals(node.ref.name)) // AS2 XML class has been renamed to XMLDocument, AS3 XML is better and different
			{
				warning(node.getPosition(), cx.input, kWarning_XML_ClassHasChanged);
			}
			
		}

		Value returnVal = ( (s != null && s.getType() != null) ? s.getType().getTypeValue() : cx.noType());
		return returnVal;
	}


	public Value evaluate( Context cx, CallExpressionNode node )
	{ 
		TypeValue 	baseType = baseType_context.last();  // baseType is void if this is a global function call
		boolean		evaluated = false;
		Value 		returnVal = null;

		if (first_pass)
		{
			// mark the slot of all functions which are arguements to addEventListener
			//  so we can detect the old AS2 eventListener event handlers which 
			//  were declared, but not registered via this method.  
			if( node.ref != null && node.ref.name.compareTo("addEventListener") == 0)
			{
				if ((node.args != null) && node.args.items.size() > 1)
				{
					Node arg2 = node.args.items.get(1);

					// There seems to be multiple, redundant coerce toObject nodes wrapping
					//  the member function get.  
					CoerceNode cnode = (arg2 instanceof CoerceNode) ? (CoerceNode) arg2 : null;
					if (cnode != null)
						arg2 = cnode.expr;
					cnode = (arg2 instanceof CoerceNode) ? (CoerceNode) arg2 : null;
					if (cnode != null)
						arg2 = cnode.expr;

					if (arg2.isMemberExpression())
					{
						MemberExpressionNode memb = (MemberExpressionNode)arg2;
						if (memb.ref != null && memb.selector.isGetExpression())
						{
							Slot s = memb.ref.getSlot(cx,GET_TOKEN);
							if (s != null)
								slot_markAsRegisteredForEvent(s,true);
						}
					}

				}
			}

			// no warning reporting during first pass
			return evaluateGenericCallExpression(cx,node);
		}

		// check if this is a deprecated function
		if (node.is_new || node.ref == null )
		{
			// Evaluate args, check for change in "new" behavior, get the return type
			if (! evaluated)
				returnVal = evaluateGenericCallExpression(cx,node);  // must process args *after* processing call expression name
			return returnVal;

		}
		else if (node.ref != null)
		{
			int	numArgs = (node.args == null ? 0 : node.args.items.size());

			if ("__resolve".equals(node.ref.name))
			{
				warning(node.getPosition(), cx.input, kWarning_ChangesInResolve);
			}			
			
			/* Reactivated, but more specific (only for blank strings)... Old comment follows:
			 *    This warning is kind of obscure and not likely to affect a lot of
			 *    people compared to the volume of warnings it will generate.
			 * 
			 * PS: I don't know whether this case ever gets called, but the other place
			 *     it is checked in kWarning_NumberFromStringChanges does. */ 
			// cn:  not sure where this came from (bug assigned to Jono?), but this is so special
			//      cased as to not be useful.   We should remove this warning.
			else if ((baseType == cx.nullType()
					&& ("Number".equals(node.ref.name)
					&& numArgs == 1)))
			{
				Node   arg = node.args.items.get(0);
				Value  argTypeVal = arg.evaluate(cx, this);

				evaluated = true;
				returnVal = cx.doubleType();	// RES don't bother with numberUsage issues here
				if (argTypeVal == cx.stringType()
						&& (arg instanceof LiteralStringNode)
						&& "".equals(((LiteralStringNode)arg).value.trim()))
				{
					warning(node.getPosition(), cx.input, kWarning_NumberFromStringChanges);
				}
			}
            // TODO: toString is special-cased... unsure exactly why
			else if ( ((baseType == cx.nullType()) && ("String".equals(node.ref.name)) && (numArgs == 1))
					|| ((baseType != cx.nullType()) && ("toString".equals(node.ref.name)) && (numArgs == 0)) )
			{
				TypeValue argTypeVal = null;

				if (numArgs == 1)
				{
					Node   arg = node.args.items.get(0);
					Value  argType = arg.evaluate(cx,this);

					argTypeVal = (argType instanceof TypeValue) ? (TypeValue) argType : null;
				} 
				else
				{
					argTypeVal = baseType_context.last();
				}
				evaluated = true;
				returnVal = cx.stringType();

				if (argTypeVal == cx.arrayType())
				{
					warning(node.getPosition(), cx.input, kWarning_ArrayToStringChanges);
				}

                final Slot s = node.ref.getSlot( cx, (node.is_new ? NEW_TOKEN : EMPTY_TOKEN));
                checkDeprecatedSlot(cx, node, node.ref, s);
			}
			/*
			else if ( (baseType != cx.nullType()) && ("split".equals(node.ref.name)) )
			{
			warning(node.position, cx.input, kWarning_PotentialSplitChanges, node.ref.name);
			}
			*/
		}

		// Evaluate args, check for change in "new" behavior, get the return type
		if (! evaluated)
			returnVal = evaluateGenericCallExpression(cx,node);  // must process args *after* processing call expression name
		return returnVal;
	}

	public Value evaluate( Context cx, InvokeNode node )
	{ 
		if( node.args != null )
		{
			node.args.evaluate(cx,this);
		}

		Value result=null;
		if( "[[HasMoreNames]]".equals(node.name) )
		{
			result = cx.booleanType(); 
		}
		else if( "[[NextValue]]".equals(node.name) )
		{
			result = cx.noType(); 
		}
		else if ("[[NextName]]".equals(node.name) )
		{
			result = cx.stringType();  
		}
		else if ( "[[ToXMLString]]".equals(node.name) )
		{
			result = cx.stringType();  
		}
		else
		{
            // erik: [[CheckFilterOperand]] (etc...) was added a long time ago,
            //        and probably doesn’t affect LintEvaluator at all.
            //assert(false) : node.name;
		}
		return result;
	}

	public Value evaluate( Context cx, DeleteExpressionNode node )
	{
		node.expr.evaluate(cx,this);

        Slot slot = (node.ref != null ? node.ref.getSlot(cx,GET_TOKEN) : null);

        if( slot != null && !in_with  )
        {
            warning(node.expr.pos(), cx.input, kWarning_DeleteOfFixedProperty, node.ref.name);
        }

		return (node.void_result ? cx.voidType() : cx.booleanType() );
	}

    public Value evaluate(Context cx, ApplyTypeExprNode node)
    {
        node.typeArgs.evaluate(cx, this);
        return null;
    }

    public Value evaluate( Context cx, GetExpressionNode node )
	{
		Value  result = null;

		if (first_pass)
		{
			if (node.ref == null)
				node.expr.evaluate(cx,this);

			return result; // doesn't matter what we return during first pass
		}

		if( node.getMode()==LEFTBRACKET_TOKEN )  // no compliance errors possible with bracket access.
		{
			// No reference, then must be dynamic (indexed) access.
			if( node.expr.isLiteralInteger() )
			{
				result = cx.noType();
			}
			else // todo:  add isLiteralString, see if there's a slot for that literal?  if (node.expr.isLiteralString)
			{
				node.expr.evaluate(cx,this);
				result = cx.noType();
			}
		}
		else if( node.ref != null)
		{
			// nothing to evaluate, its an identifier
			Slot slot = node.ref.getSlot(cx,GET_TOKEN);  // check for base object type?

			// special case for looking up a value of a class.  ConstantEvaluator
			//  doesn't recognize direct Class references outside of the global scope, so
			//  it fails to set the ref's base correctly.  It has to do this because when
			//  the function is called, its possible it will be called from a context where
			//  the global class definition has been superceeded by a local definition.
			//  This is pretty unlikely, however, and messes up the undeclared property reference
			//  detection.  If the base of this expression (appears) to be the global definition for
			//  a class, temporarily reset the ref's base and use that definition.
			TypeValue basetype = baseType_context.last();
			if (slot == null && basetype != null && "Class".equals(basetype.name.toString()) )
			{
				ReferenceValue baseRef = baseRef_context.last();

				if (baseRef != null)
				{
					ObjectValue realBase = (ObjectValue)(baseRef.getValue(cx));
					ObjectValue oldBase = node.ref.getBase();
					node.ref.setBase(realBase);
					slot = node.ref.getSlot(cx,GET_TOKEN);
					node.ref.setBase(oldBase);
				}
			}

			// The last ditch, for handling Inteface base types.    If there's a base type, see if its defined in its prototype.
			//  This definition is not good enough for code generation, but its good enough for a warning.  Its pretty unlikely 
			//  that the definition is superceeded at runtime.  
			if (slot == null && basetype != null && basetype.prototype != null && node.ref.name != null)
			{
				slot = getSlot(basetype.prototype, cx, node, GET_TOKEN);
			}

			if (slot != null )
				checkDeprecatedSlot(cx, node, node.ref, slot);
			
			TypeInfo ti = (slot != null) ? slot.getType() : null;
			TypeValue 	type = (ti != null) ? ti.getTypeValue() : null;

			result = type;
			if (result == null)
			{
				result = cx.voidType();
			}
			else if (node.ref.name.compareTo("undefined")==0)
			{
				result = undefinedLiteral;
			}

			//TODO : remove this when these identifiers are declared in playerglobal.as
			Boolean ignoreKeyword = hackIgnoreIdentifierMap.get(node.ref.name);

			int  base_index				 = node.ref.getScopeIndex(GET_TOKEN);
			int  slot_index				 = node.ref.getSlotIndex(GET_TOKEN);
			boolean is_globalref         = base_index == 0;
			boolean is_dotref            = base_index == -2;
			boolean is_unbound_lexref    = base_index == -1;
			boolean is_unbound_dotref    = is_dotref && slot_index < 0;
			boolean is_unbound_globalref = is_globalref && slot_index < 0;
			boolean is_unbound_ref       = is_unbound_dotref || is_unbound_lexref || is_unbound_globalref;

			if ( slot == null && (ignoreKeyword == null || !ignoreKeyword) && is_unbound_ref )
			{
                boolean unsupported = false;
				// special case to avoid warning on access to a Class's prototype property.  This
				//  property can't be expressed in global.as because you can't both declare a class
				//  and declare it to be an instance of the Class class.
				if (basetype != null && "Class".equals(basetype.name.toString()) && "prototype".equals(node.ref.name))
                {
					return node.expr.evaluate(cx,this);
                }
                if (basetype == types[kDateType] || basetype == cx.regExpType() ||
                    (types[kErrorType] != null && types[kErrorType].includes(cx,basetype)))  // these types are dynamic for backwards compatability, so ! doesn't catch this.  Its unlikely anyone is adding dynamic props to them
                {
                    warning(node.pos(), cx.input, kWarning_BadES3TypeProp, node.ref.name, basetype.name.name);
                    unsupported = true;
                }
                else
                {
                    Map<TypeValue,Integer> search = unsupportedPropsMap.get(node.ref.name);

                    if (search != null && !search.isEmpty() ) // && search.second.empty() == false)
                    {
                        TypeValue searchType = baseType_context.last(); // todo: why is this more reliable than node->ref->base

                        // if this is an attempt to access a static member of a class, switch searchType to the class's type
                        //   This is necessary to allow lookup in the unsupportedPropsMap table.
                        if (searchType != null && "Class".equals(searchType.name.toString()))
                        {
                            ReferenceValue br = baseRef_context.back();
                            Slot s = (br != null ? br.getSlot(cx,GET_TOKEN) : null);
                            // c++ variant accesses union member typValue directly, java stores value in objValue
                            TypeValue t = (s != null && s.getObjectValue() instanceof TypeValue) ? (TypeValue)(s.getObjectValue()) : null;
                            searchType = (t != null) ? t : searchType;
                        }

                        for(TypeValue matchType : search.keySet())
                        {
                            if (matchType != null && matchType.includes(cx,searchType))
                            {
                                unsupported = true;
                                warning(node.getPosition(), cx.input, kWarning_DepricatedPropertyError, node.ref.name,
                                            warningConstantsMap.get(search.get(matchType)));
                            }
                        }
                    }

                    if ( !unsupported && node.ref.name.startsWith("_level") && (node.base == null) )
                    {
                        unsupported = true;
                        warning(node.getPosition(), cx.input, kWarning_LevelNotSupported);
                    }

                    // return * for the value type if we are accessing a prop of a dynamic class instance
                    ObjectValue base = node.ref.getBase();
                    return (base != null && base.isDynamic() ? cx.noType() : cx.voidType());
                }
			}
			if (type == cx.functionType())
			{
				slot = node.ref.getSlot(cx,EMPTY_TOKEN);
				if (slot != null && basetype != cx.xmlType() && basetype != cx.xmlListType())
				{
					warning( node.getPosition(), cx.input, kWarning_ScopingChangeInThis, node.ref.name, (node.base != null) ? node.base.name : "" );
				}
			}
		}
		else
		{
			// If there is no reference, then node.expr is a general
			// expression that needs to be evaluated here.            
			result = node.expr.evaluate(cx,this);
		}

		return result;
	}

	private Slot getSlot(ObjectValue proto, Context cx, SelectorNode node, int type)
	{
		Slot slot = null;
		Namespaces ns = proto.hasNames(cx, type, node.ref.name, node.ref.getImmutableNamespaces());
		if (ns != null)
		{
			// we just grab the first namespace value, which I assume is what would happen at runtime
			ObjectValue last = ns.first();
			int slotIndex = proto.getSlotIndex(cx, type, node.ref.name, last);
			slot = proto.getSlot(cx, slotIndex);
		}
		return slot;
	}

	public Value evaluate( Context cx, SetExpressionNode node )
	{
		if (first_pass)
		{
			return node.args.evaluate(cx,this);
		}

        Slot slot = null;
		if( node.ref != null )
		{
			slot = node.ref.getSlot(cx,GET_TOKEN);

			// special case for looking up a value of a class.  ConstantEvaluator
			//  doesn't recognize direct Class references outside of the global scope, so
			//  it fails to set the ref's base correctly.  It has to do this because when
			//  the function is called, its possible it will be called from a context where
			//  the global class definition has been superceeded by a local definition.
			//  This is pretty unlikely, however, and messes up the undeclared property reference
			//  detection.  If the base of this expression (appears) to be the global definition for
			//  a class, temporarily reset the ref's base and use that definition.
			TypeValue baseType = baseType_context.last();
			if (baseType != null && "Class".equals(baseType.name.toString()))
			{
				ReferenceValue baseRef = baseRef_context.last();

				if (baseRef != null)
				{
					ObjectValue realBase = (ObjectValue)(baseRef.getValue(cx));
					ObjectValue oldBase = node.ref.getBase();
					node.ref.setBase(realBase);
					slot = node.ref.getSlot(cx,GET_TOKEN);
					node.ref.setBase(oldBase);
				}
			}

			// The last ditch, for handling Inteface base types.    If there's a base type, see if its defined in its prototype.
			//  This definition is not good enough for code generation, but its good enough for a warning.  Its pretty unlikely
			//  that the definition is superceeded at runtime.
			if (slot == null && baseType != null && baseType.prototype != null && node.ref.name != null)
			{
				slot = getSlot(baseType.prototype, cx, node, SET_TOKEN);
			}
			//TypeValue* dt = node->ref->getType(cx); //  this uses use-definition trees, rather than the slot's def.  Assume slot's def for warnings
			int  base_index           = node.ref.getScopeIndex(SET_TOKEN);
			int  slot_index           = node.ref.getSlotIndex(SET_TOKEN);
			boolean is_globalref         = base_index == 0;
			boolean is_dotref            = base_index == -2;
			boolean is_unbound_lexref    = base_index == -1;
			boolean is_unbound_dotref    = is_dotref && slot_index < 0;
			boolean is_unbound_globalref = is_globalref && slot_index < 0;
			boolean is_unbound_ref       = is_unbound_dotref || is_unbound_lexref || is_unbound_globalref;


			if (slot != null )
				checkDeprecatedSlot(cx, node.expr, node.ref, slot);
			
			// special case to avoid warning on access to a Class's prototype property.  This
			//  property can't be expressed in global.as because you can't both declare a class
			//  and declare it to be an instance of the Class class.
			if (baseType != null && "Class".equals(baseType.name.toString()) && "prototype".equals(node.ref.name))
			{
			}
            else if (slot != null && slot.getType().getTypeValue() == cx.uintType() &&
                     node.args != null && node.args.items.size() == 1 && node.args.items.get(0) instanceof LiteralNumberNode)
            {
                LiteralNumberNode ln = (LiteralNumberNode)(node.args.items.get(0));
                if (ln.numericValue.doubleValue() < 0)
                    warning(node.getPosition(), cx.input, kWarning_NegativeUintLiteral);
            }
					
			else if ( slot == null && is_unbound_ref)
			{
                int pos = (node.expr != null ? node.expr.getPosition() : node.getPosition());
                boolean unsupported = false;
                if (baseType == types[kDateType] || baseType == cx.regExpType() ||
                    (types[kErrorType] != null && types[kErrorType].includes(cx,baseType)))  // these types are dynamic for backwards compatability, so ! doesn't catch this.  Its unlikely anyone is adding dynamic props to them
                {
                    warning(node.pos(), cx.input, kWarning_BadES3TypeProp, node.ref.name, baseType.name.name);
                    unsupported = true;
                }
                else
                {
                    Map<TypeValue,Integer> search = unsupportedPropsMap.get(node.ref.name);

                    if (search != null && !search.isEmpty())
                    {
                        TypeValue searchType = baseType_context.last(); // todo: why is this more reliable than node->ref->base

                        // if this is an attempt to access a static member of a class, switch searchType to the class's type
                        //   This is necessary to allow lookup in the unsupportedMethodsMap table.
                        if (searchType != null && "Class".equals(searchType.name.toString()))
                        {
                            ReferenceValue br = baseRef_context.back();
                            Slot s = (br != null ? br.getSlot(cx,GET_TOKEN) : null);
                            // c++ variant accesses union member typValue directly, java stores value in objValue
                            TypeValue t = (s != null && s.getObjectValue() instanceof TypeValue) ? (TypeValue)(s.getObjectValue()) : null;
                            searchType = (t != null) ? t : searchType;
                        }

                        for(TypeValue type : search.keySet())
                        {
                            if (type != null && type.includes(cx,searchType))
                            {
                                unsupported = true;
                                warning(pos, cx.input, kWarning_DepricatedPropertyError, node.ref.name,
                                        warningConstantsMap.get(search.get(type)));
                            }
                        }
                    }
                }

                if (unsupported == false && baseType != null ) // check for unsupported event handlers (StyleSheet.onLoad = new function() ... )
                {
                    Map<TypeValue,Integer> search = unsupportedEventsMap.get(node.ref.name);
                    if (search != null && ! search.isEmpty()) // it matches a former auto-registered event handler name
                    {
                        ObjectValue  scope = cx.scope();

                        if (baseType != null) // !!@todo: check that this dynamic var wasn't seen in an addEventListener call during first_pass
                        {
                            TypeValue searchType = baseType_context.last(); // todo: why is this more reliable than node->ref->base

                            // if this is an attempt to access a static member of a class, switch searchType to the class's type
                            //   This is necessary to allow lookup in the unsupportedMethodsMap table.
                            if (searchType != null && "Class".equals(searchType.name.toString()))
                            {
                                ReferenceValue br = baseRef_context.back();
                                Slot s = (br != null ? br.getSlot(cx,GET_TOKEN) : null);
                                // c++ variant accesses union member typValue directly, java stores value in objValue
                                TypeValue t = (s != null && s.getObjectValue() instanceof TypeValue) ? (TypeValue)(s.getObjectValue()) : null;
                                searchType = (t != null) ? t : searchType;
                            }

                            for(TypeValue type : search.keySet())
                            {
                                if (type != null && type.includes(cx,searchType))  // it's defining Type matches one of the warning cases
                                {
                                    warning(pos, cx.input, kWarning_DepricatedEventHandlerError, warningConstantsMap.get(search.get(type)));
                                    unsupported = true;
                                }
                            }
                        }
                    }
                }

				ObjectValue base = node.ref.getBase();
				if ((baseType != null && baseType != cx.voidType() && baseType != cx.nullType())
					&& ((base != null && base.isFinal() && !base.isDynamic())
								|| cx.doubleType().includes(cx, baseType)
								|| cx.numberType() == baseType
								|| (cx.statics.es4_numerics && cx.decimalType() == baseType)
								|| cx.stringType() == baseType
								|| cx.booleanType() == baseType
								|| types[kMathType] == baseType))

				{
					warning(node.getPosition(), cx.input, kWarning_ClassIsSealed, getSimpleTypeName(baseType));
				}

			}
			else if (baseType == types[kTextFieldType] && "text".equals(node.ref.name))
			{
				// look for " member.text += "some text" type syntax.  The compiler will have already converted this to
				//  "member.text = member.text + "some text" by now
				Node arg1 = node.args.items.get(0);
				if (arg1 instanceof BinaryExpressionNode)
				{
					MemberExpressionNode membArg = (((BinaryExpressionNode)arg1).lhs instanceof MemberExpressionNode) ?
													(MemberExpressionNode)(((BinaryExpressionNode)arg1).lhs) :
													null;
					if (membArg != null)
					{
						MemberExpressionNode membArgBase = (membArg.base instanceof MemberExpressionNode) ? (MemberExpressionNode)(membArg.base) : null;
						ReferenceValue br = baseRef_context.back();
						if (membArgBase != null && membArgBase.ref != null && br != null && br.slot == membArgBase.ref.slot)
							warning(node.getPosition(), cx.input, kWarning_SlowTextFieldAddition);
					}
				}
			}
		}
		else
		{
			node.expr.evaluate(cx,this);
		}

		Value result = node.args.evaluate(cx,this);
		if (result == cx.nullType() && slot != null)
		{
			TypeValue t = slot.getType().getTypeValue();
			TypeValue rt = (TypeValue)result;
			if ((t != null) && (t.isNumeric(cx) || t == cx.booleanType()))
				warning(node.args.getPosition(), cx.input, kWarning_BadNullAssignment, t.name.toString());
		}
		else if (slot != null && slot.getType().getTypeValue() == cx.booleanType() && result instanceof TypeValue &&
			     result != cx.booleanType() && result != cx.noType() && result != cx.objectType())
		{
			TypeValue rt = (TypeValue)result;
			warning(node.args.getPosition(), cx.input, kWarning_BadBoolAssignment, rt.name.toString());
		}

		return result;
	}

	public Value evaluate( Context cx, ThisExpressionNode node )
	{
		// What 'this' is, depends on where it is:
		// o instance method or accessor - this is the second from end of scope chain
		// o class method or accessor - no this
		// o function - is passed in by the caller, its ct type is object

		//return cx.noType().prototype;

		int this_context = this_contexts.last();

		ObjectValue  this_value = null;

		switch( this_context )
		{
			case global_this:
				this_value = cx.scope(0);
				break;
			case instance_this:
				{
					int scope_depth = cx.getScopes().size()-1;
					this_value = cx.scope(scope_depth-1); // If this is an instance method, scope is second from top
				}
				break;
			case error_this:
			default:
				this_value = null;
				break;
		}

		return (this_value != null) ? this_value.getType(cx).getTypeValue() : null;
	}

	public Value evaluate( Context cx, LiteralBooleanNode node )
	{
		return cx.booleanType();
	}

	public Value evaluate( Context cx, LiteralNumberNode node )
	{
		return node.type;
	}

	public Value evaluate( Context cx, LiteralStringNode node )
	{
		return cx.stringType();
	}

	public Value evaluate( Context cx, LiteralNullNode node )
	{
		return cx.nullType();
	}

	public Value evaluate( Context cx, LiteralRegExpNode node )
	{
		return cx.regExpType();
	}

	public Value evaluate( Context cx, LiteralXMLNode node )
	{
		if( node.list != null )
		{
			node.list.evaluate(cx,this);
		}
		return cx.xmlType();
	}

	public Value evaluate( Context cx, ParenExpressionNode node )
	{
		assert(false); //  "shouldn't be here: evaluate( Context cx, ParenExpressionNode node )" ;
		return cx.voidType();
	}

	public Value evaluate( Context cx, ParenListExpressionNode node )
	{
		assert(false); //  "shouldn't be here: evaluate( Context cx, ParenListExpressionNode node )" ;
		return cx.voidType();
	}

	public Value evaluate( Context cx, LiteralObjectNode node )
	{

		if( node.fieldlist != null)
		{
			node.fieldlist.evaluate(cx,this);
		}

		return cx.noType();
	}

	public Value evaluate( Context cx, LiteralFieldNode node )
	{
		node.name.evaluate(cx,this);
		node.value.evaluate(cx,this);

		return (node.ref != null) ? node.ref.getType(cx).getTypeValue() : null; // getDerivedType(cx) : 0 );
	}

	public Value evaluate( Context cx, LiteralArrayNode node )
	{
		if( node.elementlist != null)
			node.elementlist.evaluate(cx,this);

		return cx.arrayType();
	}
	
	public Value evaluate( Context cx, LiteralVectorNode node )
	{
		node.type.evaluate(cx, this);

		if( node.elementlist != null)
			node.elementlist.evaluate(cx,this);

		return cx.vectorType();
	}

	public Value evaluate( Context cx, MemberExpressionNode node )
	{
		if( node.base != null)
		{
			Value		result   = node.base.evaluate(cx,this);
			TypeValue   baseType = (result instanceof TypeValue) ? (TypeValue)result : null;

			if (baseType == null || baseType == cx.voidType())  // if base is undefined, we've warned about it.  Don't warn that
			//  we don't know any of the properties of the unknown thing.
			{
				return cx.voidType();
			}
			baseType_context.add(baseType);  // remember our base's type, sometimes needed for Get/SetExpression handling

			// remember the ref to our base, sometimes needed for Get/SetExpression handling
			MemberExpressionNode simpleBaseRef = (node.base instanceof MemberExpressionNode) ? (MemberExpressionNode)(node.base) : null;
			
			baseRef_context.add( simpleBaseRef != null ? simpleBaseRef.ref : null);
		}
		else
		{
			baseType_context.add(cx.nullType());
            //baseType_context.add(cx.voidType());
			baseRef_context.push_back(null);
		}

		Value  result = node.selector.evaluate(cx,this);
		TypeValue baseType = baseType_context.removeLast();
		baseRef_context.removeLast();

        // don't trust the type of an xml property.  Properties like .name have slots for the name funciton, but could
        //  evaluate to an xml defined property named "name" at runtime.
		return (baseType == cx.xmlType() || baseType == cx.xmlListType()) ? cx.noType() : result;
	}

	public Value evaluate( Context cx, UnaryExpressionNode node )
	{
		Value result = node.expr.evaluate(cx,this);

        // no need to check expected type.  No unary expression expects a Function value
        if (result == cx.functionType())
        {
            if (node.expr instanceof MemberExpressionNode)
            {
                MemberExpressionNode memb = (MemberExpressionNode)(node.expr);
                String funcName = memb.ref.name;
                warning(memb.pos(), cx.input, kWarning_UnlikelyFunctionValue, cx.objectType().toString(),
                        funcName);
            }
        }

		if (node.op == TYPEOF_TOKEN) // typeof can return String or undefined, use object
			return cx.noType();
		return (node.slot != null) ? node.slot.getType().getTypeValue() : cx.voidType();
	}

	public Value evaluate( Context cx, IncrementNode node )
	{
		node.expr.evaluate(cx,this);
		if (node.slot != null)
			return node.slot.getType().getTypeValue();
		else {
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
	        return currentNumberType;
		}
	}

	public Value evaluate( Context cx, BinaryExpressionNode node )
	{
		Value  lhsType = null;
		Value  rhsType = null;

		if (first_pass)
		{
			if (node.lhs != null)
				node.lhs.evaluate(cx,this);
			if (node.rhs != null)
				node.rhs.evaluate(cx,this);
			return (node.slot != null) ? node.slot.getType().getTypeValue() : cx.voidType();
		}

		if( node.lhs != null)
			lhsType = node.lhs.evaluate(cx,this); // do lhs first, then potentially modify operand, then rhs.  Output buffer can't back up

		switch( node.op )
		{
            case LESSTHAN_TOKEN:
            case GREATERTHAN_TOKEN:
            case LESSTHANOREQUALS_TOKEN:
            case GREATERTHANOREQUALS_TOKEN:
			case STRICTEQUALS_TOKEN:
			case STRICTNOTEQUALS_TOKEN:
			case EQUALS_TOKEN:
			case NOTEQUALS_TOKEN:
				if( node.rhs != null)
					rhsType = node.rhs.evaluate(cx,this);

  				// if lhsType or rhsType is void, it means its the result of an undefined prop access or function call
  				//  Don't warn twice about it.
  				if ( (lhsType != rhsType) && (lhsType != cx.voidType()) && (rhsType != cx.voidType()) )
  				{
  					if ( (lhsType == undefinedLiteral && rhsType != cx.noType()) ||
  							  (lhsType != cx.noType() && rhsType == undefinedLiteral) )
  					{
  						String typeName = (lhsType == undefinedLiteral ? getSimpleTypeName((TypeValue )rhsType)
  							: getSimpleTypeName((TypeValue )lhsType));
  						warning(node.getPosition(), cx.input,  kWarning_BadUndefinedComparision, typeName, typeName);
  					}
  					else if ( (lhsType == cx.nullType()) || (rhsType == cx.nullType()) )
 					{
  						TypeValue nonVoidType = (lhsType == cx.nullType() ? (TypeValue)rhsType : (TypeValue)lhsType);

  						switch( nonVoidType.getTypeId() )
  						{
  							case TYPE_boolean:
  							case TYPE_int:
  							case TYPE_uint:
  							case TYPE_double:
  							case TYPE_decimal:
  								warning(node.getPosition(), cx.input, kWarning_BadNullComparision, getSimpleTypeName(nonVoidType));
  								break;
  						}
  					}
  				}
                if (lhsType == cx.doubleType() || (cx.statics.es4_numerics && (lhsType == cx.decimalType())))
 				{
 					MemberExpressionNode mem = (node.lhs instanceof MemberExpressionNode) ? (MemberExpressionNode)(node.lhs) : null;
 					if (mem != null)
 					{
 						GetExpressionNode getter = (mem.selector instanceof GetExpressionNode) ? (GetExpressionNode)(mem.selector) : null;
 						if (getter != null && "NaN".equals(getter.ref.name))
 							warning(node.getPosition(), cx.input, kWarning_BadNaNComparision);
 					}
 				}
 				if (rhsType == cx.doubleType() || (cx.statics.es4_numerics && (lhsType == cx.decimalType())))
 				{
					MemberExpressionNode mem = (node.rhs instanceof MemberExpressionNode) ? (MemberExpressionNode)(node.rhs) : null;
					if (mem != null)
					{
						GetExpressionNode getter = (mem.selector instanceof GetExpressionNode) ? (GetExpressionNode)(mem.selector) : null;
						if (getter != null && "NaN".equals(getter.ref.name))
							warning(node.getPosition(), cx.input, kWarning_BadNaNComparision);
					}
				}

				break;

			case INSTANCEOF_TOKEN:
			    // yes, I do mean position-11; we don't know the position of the word instanceof
			    // so we start from rhs and go back 11 spaces
			    warning(node.rhs.getPosition() - 11, cx.input, kWarning_InstanceOfChanges);
                if( node.rhs != null )
					node.rhs.evaluate(cx,this);
				break;

			case MULT_TOKEN:
			case DIV_TOKEN:
			case MODULUS_TOKEN:
			case MINUS_TOKEN:

			case LEFTSHIFT_TOKEN:
			case RIGHTSHIFT_TOKEN:
			case UNSIGNEDRIGHTSHIFT_TOKEN:

			case BITWISEAND_TOKEN:
			case BITWISEXOR_TOKEN:
			case BITWISEOR_TOKEN:
			case LOGICALAND_TOKEN:
			case LOGICALOR_TOKEN:
                if( node.rhs != null )
                      rhsType = node.rhs.evaluate(cx,this);

                if (lhsType == cx.functionType())
                {
                    if (node.lhs instanceof MemberExpressionNode)
                    {
                        MemberExpressionNode memb = (MemberExpressionNode)(node.lhs);
                        String funcName = memb.ref.name;
                        warning(node.lhs.pos(), cx.input, kWarning_UnlikelyFunctionValue, cx.objectType().toString(),
                                funcName);
                    }
                }
                 if (rhsType == cx.functionType())
                {
                    if (node.rhs instanceof MemberExpressionNode)
                    {
                        MemberExpressionNode memb = (MemberExpressionNode)(node.rhs);
                        String funcName = memb.ref.name;
                        warning(node.rhs.pos(), cx.input, kWarning_UnlikelyFunctionValue, cx.objectType().toString(),
                                funcName);
                    }
                }
                break;

			case PLUS_TOKEN:
            case IN_TOKEN:
            default:
                if( node.rhs != null )
                    rhsType = node.rhs.evaluate(cx,this);
                break;
        }

		// Return the result type of the slot
		return (node.slot!= null) ? node.slot.getType().getTypeValue() : cx.voidType();

	}

	public Value evaluate( Context cx, ConditionalExpressionNode node )
	{ 
		Value result = null;
		Value result2 = null;

		if( node.condition != null )
			node.condition.evaluate(cx,this);

		if( node.thenexpr != null )
			result = node.thenexpr.evaluate(cx,this);

		if( node.elseexpr != null)
			result2 = node.elseexpr.evaluate(cx,this);

		if (result == result2)
			return result;
		else
		{
			TypeValue type1 = (result instanceof TypeValue) ? (TypeValue) result : null;
			TypeValue type2 = (result2 instanceof TypeValue) ? (TypeValue) result2 : null;

			if (type1 == null || type2 == null)
				return null;
			else if (type1.includes(cx,type2))
				return type1;
			else if (type2.includes(cx,type1))
				return type2;
			else
				return cx.noType(); // incompatable types
		}
	}


	public Value evaluate( Context cx, ArgumentListNode node )
	{
		Value  result = null;

  		// wrong # of args will have been handled as an error during ConstantEvalation time.
        int numDeclaredParams = size(node.decl_styles);
  		if ( numDeclaredParams != 0 && node.expected_types.at(0).getTypeValue() != cx.voidType()) // void is used for class based method which declares no arguments
   		{
  			int param_count = 0;
  			TypeValue expectedType = null;

		   for (int i = 0, size = node.items.size(); i < size; i++)
  			{
				  Node item = node.items.get(i);
				  result = item.evaluate(cx, this);
  
  				if (param_count < numDeclaredParams && node.decl_styles.at(param_count) != PARAM_Rest && result != null && result instanceof TypeValue)
  				{
  					expectedType = node.expected_types.at(param_count).getTypeValue();

  					if (result != expectedType && result == cx.functionType() && expectedType != cx.objectType() && expectedType != cx.noType())
					{
						if (item instanceof MemberExpressionNode)
						{
							MemberExpressionNode memb = (MemberExpressionNode)item;
							String funcName = memb.ref.name;
							warning(item.pos(), cx.input, kWarning_UnlikelyFunctionValue, expectedType.name.toString(),
								    funcName);
						}
					}
                    else if (expectedType == cx.uintType() && item instanceof LiteralNumberNode && ((LiteralNumberNode)item).numericValue.doubleValue() < 0)
                    {
                        warning(item.pos(),cx.input, kWarning_NegativeUintLiteral);
                    }
                    else if (  ((expectedType != null) && (expectedType.isNumeric(cx) || expectedType == cx.booleanType())) 
                                && item instanceof LiteralNullNode  )
                    {
                        warning(item.getPosition(), cx.input, kWarning_BadNullAssignment, expectedType.name.toString());
                    }
					else if ( expectedType == cx.booleanType() && result instanceof TypeValue && 
						      result != cx.booleanType() && result != cx.noType() && result != cx.objectType())
					{
						TypeValue rt = (TypeValue)result;
						warning(item.getPosition(), cx.input, kWarning_BadBoolAssignment, rt.name.toString());
					}

  					if (node.decl_styles.at(param_count) != PARAM_Rest)
  						++param_count;
  				}
  			}
  		}
  		else
  		{
			  for (int i = 0, size = node.items.size(); i < size; i++)
			  {
				  Node item = node.items.get(i);
				  result = item.evaluate(cx, this);
			  }
		  }

		return result;
	}

	public Value evaluate( Context cx, ListNode node )
	{
		Value  result = null;

		for (int i = 0, size = node.items.size(); i < size; i++)
		{
			Node item = node.items.get(i);
			result = item.evaluate(cx, this);
		}

		return result;
	}

	// Statements

	public Value evaluate( Context cx, StatementListNode node )
	{
		Value result = null;

		for (int i = 0, size = node.items.size(); i < size; i++)
		{
			Node item = node.items.get(i);
			if (!doing_method)
			{
				doing_method = true;
			}

			if (item != null)  // cn: probably not necessary, but mimic'ing other evaluators to make sure
			{
				result = item.evaluate(cx, this);


                //  look for special case error of calling "func;" where you meant "func();".  Note, this does not
                //   catch a missing () in a list expression ala (var x = 1;  trace; trace(x); }, which would
                //   require examining every item in the (possibly nested) ListNode.   Also note that just checking
                //   the result type for functionType isn't enough because FunctionDefintionNodes,
                //   SetExpressionNodes which set the value to a function closure, and returnStatments which return a Function
                //   willl all return type Function.   Unfortuneately, it means we have to do this nasty explicit parsetree
                //   format dependant check here.  Its not safe to move this to ListNode processing because the expression
                //   part of a returnStatement is a ListNode, as would be the argument in a call like
                //   "funcCall( (var x = function() { return true; }, x) )"
                //  This only catches a statement like "foo;" where "foo();" was expected, but I think that's likely to be 99+%
                //    of the cases we are likely to see.
                if (result == cx.functionType() && (item instanceof ExpressionStatementNode))
                {
                    ExpressionStatementNode exp = (ExpressionStatementNode)(item);
                    if (exp.expr instanceof ListNode)
                    {
                        ListNode alist = (ListNode)exp.expr;
                        if (alist.items.size() == 1)
                        {
                            Node anItem = alist.items.get(0);
                            if ( anItem instanceof MemberExpressionNode && ((MemberExpressionNode)(anItem)).selector instanceof GetExpressionNode)
                            {
                               warning(item.pos(), cx.input, kWarning_UnlikelyFunctionValue, cx.voidType().name.toString(),
						               "the function");
                            }
                        }
                    }
                }


			}
		}

		return result;
	}

	public Value evaluate( Context cx, EmptyStatementNode node )
	{
		Value result = null;

		return result;
	}


	public Value evaluate( Context cx, ExpressionStatementNode node )
	{
		Value result = null;
		if (node.expr != null)
		{
			result = node.expr.evaluate(cx,this);
		}

		return result;
	}

	public Value evaluate( Context cx, LabeledStatementNode node )
	{
		if( node.statement != null )
			node.statement.evaluate(cx,this);

		return null;
	}

	public Value evaluate( Context cx, IfStatementNode node )
	{
		if ( node.condition != null )
		{
  			if (!first_pass)
  			{
  				ListNode condList = (node.condition instanceof ListNode) ? (ListNode)(node.condition) : null;
  				if ( condList != null && condList.items.size() == 1 )
  				{
					Node item = condList.items.get(0);
  					CoerceNode cn = (item instanceof CoerceNode) ? (CoerceNode)(item) : null;
  					if (cn != null)
  					{
 						MemberExpressionNode mem = (cn.expr instanceof MemberExpressionNode) ? (MemberExpressionNode)(cn.expr) : null;
 						if (mem != null && (mem.selector instanceof SetExpressionNode))
						{
 							warning(node.getPosition(), cx.input, kWarning_AssignmentWithinConditional);
 						}
 					}
 				}
 			}

			node.condition.evaluate(cx,this);
		}

		if( node.thenactions != null)
		{
			if (!first_pass)
  			{
				StatementListNode thenList = (node.thenactions instanceof StatementListNode) ? (StatementListNode)(node.thenactions) : null;
  				if ( thenList != null && thenList.items.size() == 1 )
  				{
  					Node item = thenList.items.get(0);
  					if (item instanceof EmptyStatementNode)
  					{
  						warning(node.getPosition(), cx.input, kWarning_UnexpectedEmptyStatement);
  					}
  				}
  			}
			
			node.thenactions.evaluate(cx,this);
		}

		if( node.elseactions != null)
			node.elseactions.evaluate(cx,this);

		return null;
	}

	public Value evaluate( Context cx, SwitchStatementNode node )
	{

		if( node.expr != null)
			node.expr.evaluate(cx,this);

		if( node.statements != null)
			node.statements.evaluate(cx,this);

		return null;
	}

	public Value evaluate( Context cx, CaseLabelNode node )
	{

		if( node.label != null)
			node.label.evaluate(cx,this);

		return null;
	}

	public Value evaluate( Context cx, DoStatementNode node )
	{
		if( node.expr != null)
			node.expr.evaluate(cx,this);

		if( node.statements != null)
			node.statements.evaluate(cx,this);

		return null;
	}

	public Value evaluate( Context cx, WhileStatementNode node )
	{
		if( node.statement != null)
		{
			if (!first_pass)
  			{
				StatementListNode thenList = (node.statement instanceof StatementListNode) ? (StatementListNode)(node.statement) : null;
  				if ( thenList != null && thenList.items.size() == 1 )
  				{
  					Node item = thenList.items.get(0);
  					if (item instanceof EmptyStatementNode)
  					{
  						warning(node.getPosition(), cx.input, kWarning_UnexpectedEmptyStatement);
  					}
  				}
  			}
			
			node.statement.evaluate(cx,this);
		}
		if( node.expr != null)
			node.expr.evaluate(cx,this);

		return null;
	}

	public Value evaluate( Context cx, ForStatementNode node )
	{
		if (node.is_forin && !first_pass)
		{
			warning(node.getPosition(), cx.input,  kWarning_ForVarInChanges);
		}

		if( node.initialize != null )
		{
			node.initialize.evaluate(cx,this);
			node.initialize.voidResult();
		}
		if( node.increment != null )
		{
			node.increment.evaluate(cx,this);
			node.increment.voidResult();
		}
		if( node.test != null )
		{
			node.test.evaluate(cx,this);
		}
		if( node.statement != null )
		{
			if (!first_pass)
  			{
				StatementListNode thenList = (node.statement instanceof StatementListNode) ? (StatementListNode)(node.statement) : null;
  				if ( thenList != null && thenList.items.size() == 1 )
  				{
  					Node item = thenList.items.get(0);
  					if (item instanceof EmptyStatementNode)
  					{
  						warning(node.getPosition(), cx.input, kWarning_UnexpectedEmptyStatement);
  					}
  				}
  			}
			
			node.statement.evaluate(cx,this);
		}
		return null;
	}

	public Value evaluate( Context cx, WithStatementNode node )
	{
		if( node.expr != null)
			node.expr.evaluate(cx,this);

		if( node.statement != null)
        {
            cx.pushScope(node.activation);

            boolean saved_in_with = in_with;
            in_with = true;

            int saveWithDepth = cx.statics.withDepth;
            cx.statics.withDepth = cx.getScopes().size()-1;

			node.statement.evaluate(cx,this);

            cx.statics.withDepth = saveWithDepth;

            in_with = saved_in_with;

            cx.popScope();
        }

		return null;
	}

	public Value evaluate( Context cx, ContinueStatementNode node )
	{
		if( node.id != null)
			node.id.evaluate(cx,this);

		return null;
	}

	public Value evaluate( Context cx, BreakStatementNode node )
	{
		return null;
	}

    private void checkReturnStatementType(Context cx, Node item, Value returnType)
    {
        // look for case where a Function is being returned where something else is expected.
        //   (i.e. "return func;" where "return func();" was intended).  This isn't always a -!
        //   type error, since all types transparently coerce to Boolean and Object.
        if (returnType == cx.functionType())
        {
            if (item instanceof MemberExpressionNode)
            {
                MemberExpressionNode memb = (MemberExpressionNode)item;
                String funcName = memb.ref.name;
                warning(memb.pos(), cx.input, kWarning_UnlikelyFunctionValue, expected_returnType.name.toString(),
                        funcName);
            }
        }
        else if (expected_returnType == cx.uintType())
        {
            if (item instanceof LiteralNumberNode && ((LiteralNumberNode)item).numericValue.doubleValue() < 0)
            {
                warning(item.pos(),cx.input, kWarning_NegativeUintLiteral);
            }
        }
        else if ( expected_returnType == cx.booleanType() && returnType instanceof TypeValue &&
                  returnType != cx.noType() && returnType != cx.objectType())
        {
            TypeValue rt = (TypeValue)returnType;
            warning(item.getPosition(), cx.input, kWarning_BadBoolAssignment, rt.name.toString());
        }
        else if ((expected_returnType != null) && (expected_returnType.isNumeric(cx) || expected_returnType == cx.booleanType()))
        {
            if (item instanceof LiteralNullNode)
            {
                warning(item.getPosition(), cx.input, kWarning_BadNullAssignment, expected_returnType.name.toString() );
            }
        }
    }

	public Value evaluate( Context cx, ReturnStatementNode node )
	{
		if( node.expr != null)
		{
			Value returnType = node.expr.evaluate(cx,this);
			if (returnType != cx.voidType())
				body_has_return = true;

			if (!first_pass && expected_returnType != returnType)
            {
                Node item = node.expr;
                // need to handle "return expr" (in which case item is a listNode with one element, expr)
                //                "return(expr)" (in which case item is a listNode with a one ListNode element.  The inner ListNode's one element is expr
                //    "return(a=0, a+= b, a)"  (same as above, but the inner listNode contains three elements, a=0, a+=b, and a)
                //    "return (a ? b : c)"     (same as above, but the inner listNode contains a ConditionalNode as its one element)
                //    "return (a=0, a+=b, (b=0, b+=c, -1))"  you get the idea
                while (item instanceof ListNode)
                {
                    ListNode list = (ListNode)item;
                    item = list.items.get(list.items.size()-1);
                }

                if (item instanceof ConditionalExpressionNode)
                {
                    ConditionalExpressionNode cen = (ConditionalExpressionNode)item;
                    if (cen.thenexpr instanceof CoerceNode) // it always will be, but just to make sure
                    {
                        CoerceNode cn = (CoerceNode)cen.thenexpr;
                        checkReturnStatementType(cx, cn.expr, returnType);
                    }
                    else
                        checkReturnStatementType(cx, cen.thenexpr, returnType);

                    if (cen.elseexpr instanceof CoerceNode) // it always will be, but just to make sure
                    {
                        CoerceNode cn = (CoerceNode)cen.elseexpr;
                        checkReturnStatementType(cx, cn.expr, returnType);
                    }
                    else
                        checkReturnStatementType(cx, cen.elseexpr, returnType);
                }
                else
                {
                    checkReturnStatementType(cx, item, returnType);
                }
            }

		}
		return null;
	}


	// Definitions

	public Value evaluate( Context cx, VariableDefinitionNode node )
	{
		// C: skip the variable definition. don't lint this branch.
		if (node.skip()) return cx.noType();

		Context nodeContext = node.getContext();
		Context useCx = (nodeContext != null) ? nodeContext : cx;
		return node.list.evaluate(useCx,this);
	}

	public Value evaluate( Context cx, VariableBindingNode node )
	{
		//TypeValue  dt = node.ref.getType(cx); //  getDerivedType(cx);

		if (!first_pass)
		{
			Slot s = (node.ref != null) ? node.ref.getSlot(cx,GET_TOKEN) : null;
			if (s != null)
			{
				

				// warn for duplicate definitions.  This is legal due to variable hoisting, but is often not what people expect, especially those
				//  used to block scoping in c++ or java.   It can lean to unexpected code such as this:
				//  var x = 20;
				//  if (someCondition())
				//  {
				//      for (var x= 0; x < 10; x++)
				//          doSometing(x);
				//  }
				//  print(x); // 10, not 20.
				//  Look up the slot for the ref.  If its the first time we've seen it, mark the slot as "declared".  If the slot is already
				//   marked as declared, this is a duplicate definition.
				if (slot_isAlreadyDeclared(s))
				{

					String origDef = "";
                    //String origDef = "on line " + cx.input.getLnNum(slot_getOriginalDeclarationPosition(s));
                    // commented out since the line number is correct for the .as file, but is not correct if we are dealing
                    // with a .as file generated by flex from an mxml file.  Since there is no easy way to map this correctly
                    // at this point just remove the line number info.  We can work on getting the mapping correct in a later release.
					warning(node.getPosition(), cx.input, kWarning_DuplicateVariableDef, origDef);
				}
				else
				{
					slot_markAsDeclared(s, node.getPosition());
				}
			}

            if (node.initializer == null)
            {

                if (s != null && s.isConst())
                    warning(node.getPosition(), cx.input, kWarning_ConstNotInitialized);
            }
            else if (!doing_method)
            {
            	if( cx.statics.es4_nullability && cx.scope().builder instanceof InstanceBuilder )
            	{
            		cx.scope().setInitOnly(true);
            	}
            	
                node.initializer.evaluate(cx,this);

            	if( cx.statics.es4_nullability && cx.scope().builder instanceof InstanceBuilder )
            	{
            		cx.scope().setInitOnly(false);
            	}
            }

			if (node.typeref == null && node.ref != null && node.variable.no_anno)
				warning(node.getPosition(),cx.input, kWarning_NoTypeDecl, "variable", node.ref.name);
			
			Slot type_slot = null;
			if( node.typeref != null && (type_slot = node.typeref.getSlot(cx)) != null )
			{
				checkDeprecatedSlot(cx, node.variable.type, node.typeref, type_slot);
			}

            if( node.ref != null )
            {
                Namespaces open_namespaces = this.open_namespaces.last();
                for( int i = 0; i < open_namespaces.size(); ++i )
                {
                    ObjectValue namespace = open_namespaces.at(i);
                    if( namespace.isPackage() && node.ref.name.equals(namespace.name) )
                        warning(node.getPosition(), cx.input, kWarning_DefinitionShadowedByPackageName);
                }
            }
			// check for access specifier
			int scopes = cx.getScopes().size();


			if (scopes == 1 || (cx.scope(scopes-1).builder instanceof ActivationBuilder))
				return null; // global scope or local variable, no access modifiers allowed


            /*
            if (!(cx.scope(scopes-1).builder instanceof ClassBuilder || (cx.scope(scopes-1).builder instanceof InstanceBuilder)))
                    return null;
            */
			if (node.attrs != null)
			{
				AttributeListNode attrs = node.attrs;
				if (attrs.hasUserNamespace() || attrs.hasPrivate || attrs.hasPublic ||
					attrs.hasProtected || attrs.hasInternal)
				{
					return null;
				}
			}

			// Warn about missing access modifier.  Get the name of the parent namespace
			String ns = cx.scope(scopes-2).getPrintableName() + ":";
			warning(node.getPosition(), cx.input, kWarning_MissingNamespaceDecl, "var '" + node.ref.name + "'", ns);
		}

		return null;
	}

    public Value evaluate( Context cx, BinaryFunctionDefinitionNode node )
    {
        return cx.voidType();
    }

	public Value evaluate( Context unused_cx, FunctionDefinitionNode node )
	{
		Context cx = node.cx; // switch context to the one used to parse this node, for error reporting

		// C: skip the entire branch. don't lint this definition.
		if (node.skip()) return cx.functionType();

		ObjectValue scope = cx.scope();
		boolean is_interface = (scope.type != null && scope.type.isInterface());

		if( !first_pass && node.ref != null && !is_interface)
		{
			// check for access qualifiers
			int scopes = cx.getScopes().size();

			if (scopes == 1 || (cx.scope(scopes-1).builder instanceof ActivationBuilder)) // no access qualifiers allowed in global scope
				return cx.functionType();

			if (node.attrs != null)
			{
				AttributeListNode attrs = node.attrs;
				if (attrs.hasUserNamespace() || attrs.hasPrivate || attrs.hasPublic ||
					attrs.hasProtected || attrs.hasInternal)
				{
					return cx.functionType();
				}
			}
            // constructors can only be public.  If no access specifier is supplied, it defaults to public.  Do not warn about it.
            boolean is_constructor = "$construct".equals(node.ref.name);
            if (is_constructor)
                return cx.functionType();

			// Warn about missing qualifier.  Get the name of the parent namespace (if any)
			String ns = cx.scope(scopes-2).getPrintableName() + ":";
			warning(node.getPosition(), cx.input, kWarning_MissingNamespaceDecl, "function '" + node.ref.name + "'", ns);
		}

		return cx.functionType();
	}

	public Value evaluate( Context unused_cx, FunctionCommonNode node )
	{
		Context cx = node.cx;  // switch to original context

		if( doing_method )
		{
			return cx.functionType();
		}

        open_namespaces.push_back(node.used_namespaces);
		if (!first_pass && node.ref != null)
		{
			Map<TypeValue,Integer> search = unsupportedEventsMap.get(node.ref.name);
			if (search != null && ! search.isEmpty()) // it matches a former auto-registered event handler name
			{
				Slot s = node.ref.getSlot(cx,GET_TOKEN);
				ObjectValue  scope = cx.scope();
				TypeValue  baseType = (scope != null) ? scope.type.getTypeValue() : null;

				if (baseType != null && s != null && !slot_GetRegisteredForEvent(s)) // it wasn't seen in an addEventListener call during first_pass
				{
					for(TypeValue type : search.keySet())
					{
						if (type != null && type.includes(cx,baseType))  // it's defining Type matches one of the warning cases
						{
							int pos = (node.identifier != null) ? node.identifier.getPosition() : node.getPosition();
							warning(pos, cx.input, kWarning_DepricatedEventHandlerError, warningConstantsMap.get(search.get(type)));
						}
					}
				}
				else if (s != null)
				{
					s = null;
				}
			}


		}
		ObjectValue  fun = node.fun;
		cx.pushScope(fun.activation);
		if( node.isFunctionDefinition() == false )  // if it not a defn then 'this' can be used and is dynamic (i.e. don't warn about undeclared props/methods)
		{
			this_contexts.add(global_this);
		}

		for (int i = 0, size = node.fexprs.size(); i < size; i++)
		{
			FunctionCommonNode item = node.fexprs.get(i);
			item.evaluate(cx,this);
		}

		currentFunctionRef.add(node.ref);

		// set local expected_returnType so that we can check it against what's actually returned in ReturnStatementNode
		boolean is_constructor = "$construct".equals(node.ref.name);
		if (is_constructor)
		{
			this.expected_returnType = cx.voidType();
		}
		else
		{
			this.expected_returnType = node.signature.type!=null?node.signature.type.getTypeValue():cx.noType();
		}

		body_has_return = false;
        if( node.body != null )
		{
			node.body.evaluate(cx,this);
			doing_method = false;
		}
		this.expected_returnType = cx.noType(); // restore to default

		node.signature.evaluate(cx,this);
		currentFunctionRef.removeLast();

		cx.popScope(); // pop activation.  must do this before looking up slot for node.ref, else we can
                       //  bind to the wrong definition in the activation record instead.
        Slot s = node.ref.getSlot(cx,GET_TOKEN);

        if (first_pass && s != null)
        {
            if (body_has_return)
                slot_setHasReturnValue(s,true);
		}
        else if (!first_pass)
        {
            if (node.signature != null && node.signature.parameter != null)
            {
                HashMap<String,Boolean> paramNames = new HashMap<String,Boolean>(node.signature.parameter.items.size());
				for(ParameterNode item : node.signature.parameter.items)
                {
                    Boolean exists = paramNames.get(item.ref.name);
                    if (exists != null)
                    {
                        warning(item.pos(),cx.input,kWarning_DuplicateArgumentNames,item.ref.name);
                    }
                    else
                    {
                        paramNames.put(item.ref.name,true);
                    }
                }
            }
        }


        open_namespaces.pop_back();
		if( node.isFunctionDefinition() == false )
		{
			this_contexts.removeLast();
		}

		return cx.functionType();
	}

	public Value evaluate( Context cx, FunctionNameNode node )
	{
		assert(false);
		return null; // assert(false); //  "Should never get here!";
	}

	public Value evaluate( Context cx, FunctionSignatureNode node )
	{
		ReferenceValue ref = currentFunctionRef.last();
        Slot s = null;

        if (ref != null)
        {   // must look up the functionRef in the old scope, not the activationObject scope.  Don't want to bind
            //  to like-named arguments!
            ObjectValue oldScope = cx.scope();
            cx.popScope();
            s = ref.getSlot(cx,GET_TOKEN);
            cx.pushScope(oldScope);
        }

		if( node.parameter != null)
		{
			node.parameter.evaluate(cx,this);
		}

		if( node.result != null)
		{
			node.result.evaluate(cx,this);
		}
		else
		{
			if (!first_pass && ref != null && ref.name.compareTo("$construct") != 0 && node.no_anno)
			{
				warning(node.getPosition()-2, cx.input, kWarning_NoTypeDecl, "return value for function", ref.name);
			}
		}


		return null;
	}

	public Value evaluate( Context cx, ParameterNode node )
	{
		if (!first_pass && node.ref != null)
		{
			if (node.type == null && node.no_anno)
				warning(node.getPosition(),cx.input, kWarning_NoTypeDecl, "parameter", node.ref.name);

		}

		return null;
	}

	public Value evaluate( Context cx, RestParameterNode node )
	{
		//return evaluate(cx,(ParameterNode*)node);
		return null;
	}
	public Value evaluate(Context cx, RestExpressionNode node)
	{
		return null;
	}


	public Value evaluate( Context cx, ParameterListNode node )
	{
		for(ParameterNode item : node.items)
		{
			item.evaluate(cx,this);
		}

		return null;
	}

	public Value evaluate( Context cx, BinaryProgramNode node )
	{
		return cx.voidType();
	}

	public Value evaluate(Context cx, BinaryClassDefNode node)
	{
		return cx.voidType();
	}

    public Value evaluate(Context cx, BinaryInterfaceDefinitionNode node)
    {
        return cx.voidType();
    }

	public Value evaluate( Context unused_cx, ProgramNode node )
	{
		Context cx = node.cx;  // switch contexts so that the original one is used

        if ((cx.input == null) || ignorableFile(cx.input))
		{
			return null;
		}

        if(initialized == false)
            initialize(cx); // initialize tables and maps

		// Unlike the other evaluators, we evaluate the ProgramNode twice
		//  In the first walk (first_pass = true), we store lintData in the slot's opaque
		//   embeddedData for identifiers we need to remember information for
		//   (was a handler registered for an event, does it have a return value,
		//    what is a top level function's argument signature)
		//  During the second traversal we look for problems to warn against.
		for( int numPass = 0; numPass < 2; numPass++)
		{
			first_pass = numPass == 0;
			this_contexts.add(global_this);

			doing_class   = false;
			doing_method  = false;

            open_namespaces.push_back(node.used_def_namespaces);
			if (node.pkgdefs != null)
			{
				for (PackageDefinitionNode def : node.pkgdefs)
				{
					def.evaluate(cx, this);
				}
			}

			if (node.clsdefs != null)
			{
				for (ClassDefinitionNode def : node.clsdefs)
				{
					def.evaluate(cx, this);
				}
			}

			if (node.fexprs != null)
			{
				for (FunctionCommonNode def : node.fexprs)
				{
					def.evaluate(cx, this);
				}
			}

			if( node.statements != null)
			{
				node.statements.evaluate(cx,this);
			}
			doing_method  = false;
			doing_class   = false;

			this_contexts.removeLast();
            open_namespaces.pop_back();
		}

		return null;
	}

	public Value evaluate( Context unused_cx, PackageDefinitionNode node )
	{
        if( !node.in_this_pkg )
        {
            node.in_this_pkg = true;
            open_namespaces.push_back(node.used_namespaces);
        }
        else
        {
            node.in_this_pkg = false;
            open_namespaces.pop_back();
        }
        /*
		if( doing_package )
		{
		return null;
		}

		Context cx = node.cx;  // switch to original context

		if( node.statements != null )
		{
		node.statements.evaluate(cx,this);
		}
		doing_method = false;
		*/

		return null;
	}

	public Value evaluate( Context cx, ErrorNode node )
	{
		return null;
	}

	public Value evaluate( Context cx, ToObjectNode node )
	{ 
		node.expr.evaluate(cx,this);
		return cx.noType();
	}

	public Value evaluate( Context cx, BoxNode node )
	{ 
		Value  result = node.expr.evaluate(cx,this);

		if( node.void_result )
		{
			result = cx.voidType();
		}
		else
		{
			int type_id = node.actual.getTypeId();
			switch( type_id )
			{
				case TYPE_bool:
				case TYPE_int:
					result = (node.actual);
			}
		}

		return result;
	}

	public Value evaluate( Context cx, CoerceNode node )
	{ 
		// CoerceNodes are introduced by finalantEvaluator, using the type rather than the dtype.  
		//  Because finalantEvaluator uses ObjectType for everything not explicitly typed (and even then sometimes)
		//  we ignore any cast to ObjectType
		Value result = node.expr.evaluate(cx,this);
		if (node.expected.getTypeValue() == cx.noType() || result == undefinedLiteral)
			return result;	// likewise, actual is type not dtype
		if (result == cx.functionType() && node.expected.getTypeValue() != cx.functionType())
		{

			if (node.expr instanceof MemberExpressionNode)
			{
				MemberExpressionNode memb = (MemberExpressionNode)(node.expr);
				String funcName = memb.ref.name;
				warning(memb.pos(), cx.input, kWarning_UnlikelyFunctionValue, node.expected.getName(cx).toString(), funcName);
			}
		}
	    return result;
	}
	public Value evaluate( Context cx, LoadRegisterNode node )
	{
		return (node.type == null ? cx.noType() : node.type);
	}

	public Value evaluate( Context cx, StoreRegisterNode node )
	{
		node.expr.evaluate(cx,this);
		return (node.type == null ? cx.noType() : node.type);
	}

	public Value evaluate( Context cx, RegisterNode node )
	{
		return (node.type == null ? cx.noType() : node.type);
	}

	public Value evaluate( Context cx, HasNextNode node )
	{
		return cx.noType();
	}
	
	public Value evaluate( Context cx, ThrowStatementNode node )
	{
		if( node.expr != null )
		{
			return node.expr.evaluate(cx,this);
		}
		return null;
	}

	public Value evaluate( Context cx, TryStatementNode node )
	{
		if (node.tryblock != null)
		{
			node.tryblock.evaluate(cx, this);
		}
		if (node.catchlist != null)
		{
			node.catchlist.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate( Context cx, CatchClauseNode node )
	{
		if (node.parameter != null)
		{
			node.parameter.evaluate(cx,this);
		}

		if (node.statements != null)
		{
			node.statements.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate( Context cx, FinallyClauseNode node )
	{
		return null; // its not implemented in the compiler yet
	}

	public Value evaluate( Context unused_cx, ClassDefinitionNode node )
	{
		Context cx = node.cx;  // switch to original context

		// C: if node.skip() is true, skip the entire branch. don't lint this definition.
		if( doing_method || doing_class || node.skip())
		{
			return node.cframe;
		}
        open_namespaces.push_back(node.used_namespaces);
		doing_class = true;

		if( node.attrs != null)
		{
			node.attrs.evaluate(cx,this);
		}

		if( node.name != null)
		{
			node.name.evaluate(cx,this);
		}
		if( node.baseclass != null)
		{
			node.baseclass.evaluate(cx,this);
		}
		if( node.interfaces != null)
		{
			node.interfaces.evaluate(cx,this);
		}

		cx.pushStaticClassScopes(node);
		this_contexts.add(error_this);

		if (node.staticfexprs != null)
		{
			for(FunctionCommonNode item : node.staticfexprs)
			{
				doing_method = false;
				item.evaluate(cx,this);
			}
		}

		if (node.clsdefs != null)
		{
			for (Node clsdef : node.clsdefs)
			{
				clsdef.evaluate(cx, this);
			}
		}

		if( node.statements != null)
		{
			node.statements.evaluate(cx,this);
		}
		doing_method = false;

		this_contexts.removeLast();
		this_contexts.add(instance_this);
		cx.pushScope(node.iframe);

		// Generate code for the instance property definitions
        boolean has_instance_vars = false;


		if (node.instanceinits != null)
		{
			doing_method = true;
            for(Node item : node.instanceinits)
			{
            	if( cx.statics.es4_nullability && !item.isDefinition() )
            		node.iframe.setInitOnly(true);
            	
				item.evaluate(cx,this);
                if (item instanceof VariableDefinitionNode ) /* cn: only warn if there are instance vars.  That's the most likely time there could ever be
                                                                    a difference in behavior when a class is renamed and its constructor function isn't.
                                                                || item instanceof FunctionDefinitionNode)  */
                {
                    has_instance_vars = true;
                }
                
                if( cx.statics.es4_nullability && !item.isDefinition() )
                	node.iframe.setInitOnly(false);
			}
                
            doing_method = false;
		}



		if (node.fexprs != null)
		{
			boolean found_constructor = false;
            boolean has_instance_methods = false;
			for(FunctionCommonNode fn : node.fexprs)
			{
				if (fn.ref.name.equals("$construct"))
				{
					if (!fn.isSynthetic())
                    {
                        found_constructor = true;
					    body_has_super= false;
                    }
				}
                else
                {
                    has_instance_methods = true;
                }

				fn.evaluate(cx,this);
				if (fn.ref.name.equals("$construct") && !node.isInterface() && !fn.isSynthetic() && !body_has_super)
				{
					warning(fn.pos(), cx.input, kWarning_NoExplicitSuperCallInConstructor, node.ref.name);
					body_has_super = false;
				}
			}
            // if we haven't found a constructor AND there is either more than one (i.e. the default constructor) function defined,
            //  or there are instanceinits (for instance vars),  then log warning.  We don't want to log a warning for the case where
            //  a class exists soley to provide static properties/methods.
            // todo: Future:  perhaps we should only trigger this warning if there are instance variables which do not have a iinit default value.
			if ( !found_constructor &&
                 has_instance_vars  &&
                 !node.isInterface())
				warning(node.pos(), cx.input, kWarning_NoConstructor, node.ref.name);
		}


		doing_method = false;
		doing_class = false;

		this_contexts.removeLast();
		cx.popScope();
		cx.popStaticClassScopes(node);
        open_namespaces.pop_back();

		if( !first_pass && node.ref != null  && node.pkgdef != null )
		{
			// check for access qualifier
			int scopes = cx.getScopes().size();

			if (node.attrs != null)
			{
				AttributeListNode attrs = node.attrs;
				if (attrs.hasUserNamespace() || attrs.hasPrivate || attrs.hasPublic ||
					attrs.hasProtected || attrs.hasInternal)
				{
					return node.cframe;
				}
			}
			// Warn about missing qualifier.  Get the name of the parent namespace (if any)
			String ns = node.cframe.name.ns.name;
			warning(node.getPosition(), cx.input, kWarning_MissingNamespaceDecl, "class '" + node.ref.name + "'", ns);
		}

		return node.cframe;
	}

	public Value evaluate( Context cx, InterfaceDefinitionNode node )
	{
		if( doing_method || doing_class )
			return null;

		ObjectValue implobj = cx.scope();
		if( !(implobj.builder instanceof InstanceBuilder) )
		{
			return this.evaluate(cx, (ClassDefinitionNode)node);
		}

		return null;
	}

	public Value evaluate( Context cx, ClassNameNode node )
	{
		if( node.pkgname != null )
		{
			node.pkgname.evaluate(cx,this);
		}
		if( node.ident != null )
		{
			node.ident.evaluate(cx,this);
		}
		return ObjectValue.undefinedValue;
	}

	public Value evaluate( Context cx, InheritanceNode node )
	{
		if( node.baseclass != null)
		{
			node.baseclass.evaluate(cx,this);
		}
		if( node.interfaces != null )
		{
			node.interfaces.evaluate(cx,this);
		}
		return ObjectValue.undefinedValue;
	}

	public Value evaluate( Context cx, AttributeListNode node )
	{
		for(Node item : node.items)
		{
			item.evaluate(cx,this);
		}

		return ObjectValue.undefinedValue;
	}

	public Value evaluate( Context cx, IncludeDirectiveNode node )
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

    private ObjectList< Namespaces > open_namespaces = new ObjectList< Namespaces >();
	public Value evaluate( Context cx, ImportDirectiveNode node )
	{
		return null;
		//  node.name.id.toIdentifierString()
	}

	public Value evaluate( Context cx, SuperExpressionNode node )
	{
		TypeValue  super_type = cx.noType();
		TypeValue  this_value = null;

		// All error cases handled by flow analyzer
		if( node.expr != null )
		{
			Value result = node.expr.evaluate(cx,this);
			this_value = (result instanceof TypeValue) ? (TypeValue) result : null;
		}
		else
		{
			int scope_depth = cx.getScopes().size()-1;
			Value result = cx.scope(scope_depth-1);
			this_value = (result instanceof TypeValue) ? (TypeValue) result : null; // If this is an instance method, scope is second from top
		}

		if( this_value != null && this_value.baseclass != null )
		{
			super_type = this_value.baseclass;
		}

		return super_type;
	}

	public Value evaluate( Context cx, SuperStatementNode node )
	{
		body_has_super = true; // remember that constructor called super.  Previous compiler error checking gaurantees we must be in a constructor

		if( node.call.args != null)
		{
			node.call.args.evaluate(cx,this);
		}
		return null;
	}
	public Value evaluate( Context cx, ConfigNamespaceDefinitionNode node )
	{
		return null;
	}
	public Value evaluate( Context cx, NamespaceDefinitionNode node )
	{
		if( !first_pass && node.ref != null  )
		{
			// check for access qualifier
			int scopes = cx.getScopes().size();
            /*
			if (scopes == 1 || (cx.scope(scopes-1).builder instanceof ActivationBuilder)) // global scope, no access modifiers allowed
				return null;
            */
            if (scopes != 1 || cx.scope(scopes-1).builder instanceof PackageBuilder )
                    return null;

			if (node.attrs != null)
			{
				AttributeListNode attrs = node.attrs;
				if (attrs.hasUserNamespace() || attrs.hasPrivate || attrs.hasPublic ||
					attrs.hasProtected || attrs.hasInternal)
				{
					return null;
				}
			}
			// Warn about missing qualifier.  Get the name of the parent namespace (if any)
			String ns = cx.scope(scopes-2).getPrintableName() + ":";
			warning(node.getPosition(), cx.input, kWarning_MissingNamespaceDecl, "namespace '" + node.ref.name + "'", ns);
		}

		return null;
	}
	public Value evaluate( Context cx, UseDirectiveNode node )
	{
		return null;
	}
	public Value evaluate( Context cx, MetaDataNode node )
	{
		return null;
	}
	public Value evaluate( Context cx, EmptyElementNode node )
	{
		// do nothing
		return null;
	}



	// Supporting tables and maps for identifying unsupported AS2 Flash player apis
	// -------------------------------------------------------------------
	TypeValue[]			    types = new TypeValue[kNumDefaultTypes];			// table of TypeValues for common types we need to compare against

	private class DefaultTypeDesc
	{
		int code; // TypeCode code;
		String nameSpace;
		String name;
		DefaultTypeDesc(int c, String ns, String n) { code = c; nameSpace = ns; name = n; }
	};

	private DefaultTypeDesc[]   typeDescriptors = {
		new DefaultTypeDesc(kVoidType,				"",						"null"),
		new DefaultTypeDesc(kObjectType,			"",						"Object"),
		new DefaultTypeDesc(kFunctionType,			"",						"Function"),
		new DefaultTypeDesc(kStringType,			"",						"String"),
		new DefaultTypeDesc(kNumberType,			"",						"Number"),
		new DefaultTypeDesc(kBooleanType,			"",						"Boolean"),
		new DefaultTypeDesc(kArrayType,				"",						"Array"),
		new DefaultTypeDesc(kDateType,				"",						"Date"),
		new DefaultTypeDesc(kMathType,				"",						"Math"),
		new DefaultTypeDesc(kErrorType,				"",						"Error"),
		new DefaultTypeDesc(kRegExpType,			"",						"RegExp"),
		new DefaultTypeDesc(kDisplayObjectType,		"flash.display",		"DisplayObject"),
		new DefaultTypeDesc(kMovieClipType,			"flash.display",		"MovieClip"),
		new DefaultTypeDesc(kTextFieldType,			"flash.text",		    "TextField"),
		new DefaultTypeDesc(kTextFormatType,		"flash.text",			"TextFormat"),
		new DefaultTypeDesc(kMicrophoneType,		"flash.media",			"Microphone"),
		new DefaultTypeDesc(kSimpleButtonType,		"flash.display",		"SimpleButton"),
		new DefaultTypeDesc(kVideoType,				"flash.media",			"Video"),
		new DefaultTypeDesc(kStyleSheetType,		"flash.text",			"StyleSheet"),
		new DefaultTypeDesc(kSelectionType,			"flash.obsolete",		"SelectionType"), // not found
		new DefaultTypeDesc(kColorType,				"flash.obsolete",		"Color"), // not found
		new DefaultTypeDesc(kStageType,				"flash.display",		"Stage"),
		new DefaultTypeDesc(kMouseType,				"flash.ui",				"Mouse"),
		new DefaultTypeDesc(kKeyboardType,			"flash.ui",				"Keyboard"),
		new DefaultTypeDesc(kSoundType,				"flash.media",			"Sound"),
		new DefaultTypeDesc(kSystemType,			"flash.system",			"System"),
		new DefaultTypeDesc(kXMLType,				"",						"XML"),
		new DefaultTypeDesc(kXMLSocketType,			"flash.net",			"XMLSocket"),
		new DefaultTypeDesc(kXMLListType,			"",						"XMLList"),
		new DefaultTypeDesc(kQNameType,				"",						"QName"),
		new DefaultTypeDesc(kLoadVarsType,			"flash.net",			"LoadVars"),
		new DefaultTypeDesc(kCameraType,			"flash.media",			"Camera"),
		new DefaultTypeDesc(kContextMenuType,		"flash.ui",				"ContextMenu"),
		new DefaultTypeDesc(kContextMenuItemType,	"flash.ui",				"ContextMenuItem"),
		new DefaultTypeDesc(kMovieClipLoaderType,	"flash.obsolete",		"MovieClipLoader"), // not found
		new DefaultTypeDesc(kNetStreamType,			"flash.net",			"NetStream"),
		new DefaultTypeDesc(kAccessibilityType,		"flash.accessibility",	"Accessibility"),
		new DefaultTypeDesc(kActivityEventType,		"flash.events",			"ActivityEvent"),
		new DefaultTypeDesc(kByteArrayType,			"flash.util",			"ByteArray"),
		new DefaultTypeDesc(kColorTransformType,	"flash.geom",			"ColorTransform"),
		new DefaultTypeDesc(kDisplayObjectContainerType, "flash.display",	"DisplayObjectContainer"),
		new DefaultTypeDesc(kCustomActionsType,		"macromedia.util",		"CustomActions"),
		new DefaultTypeDesc(kDataEventType,			"flash.events",			"DataEvent"),
		new DefaultTypeDesc(kExternalInterfaceType, "flash.external",		"ExternalInterface"),
		new DefaultTypeDesc(kErrorEventType,		"flash.events",			"ErrorEvent"),
		new DefaultTypeDesc(kEventType,				"flash.events",			"Event"),
		new DefaultTypeDesc(kFocusEventType,		"flash.events",			"FocusEvent"),
		new DefaultTypeDesc(kGraphicsType,			"flash.display",		"Graphics"),
		new DefaultTypeDesc(kBitmapFilterType,		"flash.filters",		"BitmapFilter"),
		new DefaultTypeDesc(kInteractiveObjectType,	"flash.display",		"InteractiveObject"),
		new DefaultTypeDesc(kKeyboardEventType,		"flash.events",			"KeyboardEvent"),
		new DefaultTypeDesc(kLoaderType,			"flash.display",		"Loader"),
		new DefaultTypeDesc(kLoaderInfoType,		"flash.display",		"LoaderInfo"),
		new DefaultTypeDesc(kLocalConnectionType,	"flash.net",			"LocalConnection"),
		new DefaultTypeDesc(kContextMenuEventType,	"flash.events",			"ContextMenuEvent"),
		new DefaultTypeDesc(kProductManagerType,	"macromedia.util",		"ProductManager"),
		new DefaultTypeDesc(kPointType,				"flash.geom",			"Point"),
		new DefaultTypeDesc(kProxyType,				"flash.util",			"Proxy"),
		new DefaultTypeDesc(kProfilerType,			"flash.profiler",		""),
		new DefaultTypeDesc(kProgressEventType,		"flash.events",			"ProgressEvent"),
		new DefaultTypeDesc(kRectangleType,			"flash.geom",			"Rectangle"),
		new DefaultTypeDesc(kSoundTransformType,	"flash.media",			"SoundTransform"),
		new DefaultTypeDesc(kSocketType,			"flash.net",			"Socket"),
		new DefaultTypeDesc(kSharedObjectType,		"flash.net",			"SharedObject"),
		new DefaultTypeDesc(kSpriteType,			"flash.display",		"Sprite"),
		new DefaultTypeDesc(kIMEType,				"flash.system",			"IME"),
		new DefaultTypeDesc(kSWFLoaderInfoType,		"flash.display",		"SWFLoaderInfo"),
		new DefaultTypeDesc(kTextSnapshotType,		"flash.text",			"TextSnapshot"),
		new DefaultTypeDesc(kURLLoaderType,			"flash.net",			"URLLoader"),
		new DefaultTypeDesc(kURLStreamType,			"flash.net",			"URLStream"),
		new DefaultTypeDesc(kURLRequestType,		"flash.net",			"URLRequest"),
		new DefaultTypeDesc(kXMLDocumentType,		"flash.xml",			"XMLDocument"),
		new DefaultTypeDesc(kXMLNodeType,			"flash.xml",			"XMLNode"),
		new DefaultTypeDesc(kNetConnectionType,		"flash.net",			"NetConnection"),
		new DefaultTypeDesc(kSyncEventType,			"flash.events",			"SyncEvent"),
		new DefaultTypeDesc(kBitmapDataType,		"flash.display",		"BitmapData"),
		new DefaultTypeDesc(kXMLUIType,				"macromedia.util",		"XMLUI"),
		new DefaultTypeDesc(kFileReferenceListType,	"flash.net",			"FileReferenceList"),
		new DefaultTypeDesc(kFileReferenceType,		"flash.net",			"FileReference")
};

	// simple versions of the the names for the above types (not including namespace decoration)
	static final String[]   simpleTypeNames =
			{
				"null",
				"Object",
				"Function",
				"String",
				"Number",
				"Boolean",
				"Array",
				"Date",
				"Math",
				"Error",
				"RegExp",
				"DisplayObject",
				"MovieClip",
				"TextField",
				"TextFormat",
				"Microphone",
				"SimpleButton",
				"Video",
				"StyleSheet",
				"Selection",
				"Color",
				"Stage",
				"Mouse",
				"Keyboard",
				"Sound",
				"System",
				"XML",
				"XMLSocket",
				"XMLList",
				"QName",
				"LoadVars",
				"Camera",
				"ContextMenu",
				"ContextMenuItem",
				"MovieClipLoader",
				"NetStream",
				"Accessibility",
				"ActivityEvent",
				"ByteArray",
				"ColorTransform",
				"DisplayObjectContainer",
				"CustomActions",
				"DataEvent",
				"ExternalInterface",
				"ErrorEvent",
				"Event",
				"FocusEvent",
				"Graphics",
				"BitmapFilter",
				"InteractiveObject",
				"KeyboardEvent",
				"Loader",
				"LoaderInfo",
				"LocalConnection",
				"ContextMenuEvent",
				"ProductManager",
				"Point",
				"Proxy",
				"Profiler",
				"ProgressEvent",
				"Rectangle",
				"SoundTransform",
				"Socket",
				"SharedObject",
				"Sprite",
				"IME",
				"SWFLoaderInfo",
				"TextSnapshot",
				"URLLoader",
				"URLStream",
				"URLRequest",
				"XMLDocument",
				"XMLNode"
			};

	private Map<Integer, String> warningConstantsMap = new HashMap<Integer, String>(kNumWarningConstants);   // maps WarningCode enum to its warning string
	// maps a property name and base type pair to a WarningCode for unsupported properties
	private Map<String, Map<TypeValue, Integer>> unsupportedPropsMap = new HashMap<String, Map<TypeValue, Integer>>(kNumPropertyWarnings);
	// maps a property name and base type pair to a WarningCode for unsupported methods
	private Map<String, Map<TypeValue, Integer>> unsupportedMethodsMap = new HashMap<String, Map<TypeValue, Integer>>(kNumMethodWarnings);
	// maps a property name and base type pair to a WarningCode for an event handler which is no longer called automatically by the player
	private Map<String, Map<TypeValue, Integer>> unsupportedEventsMap = new HashMap<String, Map<TypeValue, Integer>>(kNumEventWarnings);

	/* Hack to ignore warnings for things which should be in playerglobal.as
	but aren't yet (usually because there are some problems with its current definition) (like 'Stage') */
	private static final Map<String, Boolean> hackIgnoreIdentifierMap = new HashMap<String, Boolean>();
	// TODO remove this once playerGlobal.as defines these
	private static final String toIgnore[] = {
		"_global",
		"rest",
		"NaN",
		"arguments",
		"undefined"
	};

	private Map<Integer, Boolean> enabledMap; // indicates if a warning(Code) is enabled

	private String warningEnabledMapFile; // custom location for EnabledWarning.xml

	// supporting tables for logging warning instances
	// ----------------------------------------------

	// Table of warningRecord vectors indexable via WarningCode
	private TreeMap<Integer, ObjectList<WarningRecord>> pWarnings = new TreeMap<Integer, ObjectList<WarningRecord>>();
	// Table of warningRecord vectors indexed by source file and line
	private TreeMap<String, TreeMap<Integer, Set<WarningRecord>>> warningsByLoc = new TreeMap<String, TreeMap<Integer, Set<WarningRecord>>>();

	//  This is where WarningRecords are logged when encountered,
	//  and how we dump them out by category at the end of the evaluation


	// General data members
	// ----------------------
	private boolean				initialized;	  //  marks that we have initialized the above.
	private String			    scriptName;       //  name of the source file.
	private ObjectValue		    undefinedLiteral; //  we need to be able to identify the literal 'undefined'
	private boolean				body_has_return;  //  need to know if a function 'f' has a return value in order to spot "new f()" as a problem.
	private boolean				body_has_super;	  //  need to know if a constructor function calls super() to initialize its super class
	
	private boolean output_to_file; // defaults to true, whether to create _warnings.txt file
	
	// state trackers, used to avoid evaluating methods/classes twice.
	private boolean doing_method;
	private boolean doing_class;

	private boolean first_pass;

	private TypeValue expected_returnType;

	// keeps track of the type of the currently evaluating member expressions base
	public ObjectList<TypeValue>					baseType_context = new ObjectList<TypeValue>();
	// keeps track of the referenceValue for the currently evaluating member expression's base
	//  (if it is a simple MemberExpression/GetExpression of an identifier, its ref is pushed,
	//   else, NULL is pushed).
	public ObjectList<ReferenceValue>				baseRef_context = new ObjectList<ReferenceValue>();

	// keeps track of what 'this' means in the currently evaluating expression
	private IntList                                 this_contexts = new IntList();
	//std::vector<int>								super_context;		 //
	// Keeps track of the function we are currently evaluating
	public ObjectList<ReferenceValue>				currentFunctionRef = new ObjectList<ReferenceValue>();

    private boolean in_with;

	public LintEvaluator( Context cx, String name, String enabledFile )
	{
		scriptName = name;
		// ctx = cx;
		initialized = false;
		body_has_return = false;
		body_has_super = false;
		warningEnabledMapFile = enabledFile;
		doing_class   = false;
		doing_method  = false;
		output_to_file = true;
		expected_returnType = cx.noType();
        in_with = false;
	}
	
	/* This constructor takes in a pre-filled-in warnings map -- you can get it using the
	 * static method parseEnabledWarningsFile(file). This avoids the overhead of reading
	 * in the same file hundreds of times in mxmlc. */
	public LintEvaluator( Context cx, String name, HashMap<Integer, Boolean> enabledWarningsMap)
	{
		scriptName = name;
		initialized = false;
		body_has_return = false;
		body_has_super = false;
		enabledMap = enabledWarningsMap;
		doing_class   = false;
		doing_method  = false;
		output_to_file = true;
		expected_returnType = cx.noType();
	}

	public void clear()
	{
		initialized = false;
		unsupportedPropsMap.clear();
		unsupportedMethodsMap.clear();
		unsupportedEventsMap.clear();
		pWarnings.clear();
		warningsByLoc.clear();
		undefinedLiteral = null;
		for (Slot s : slotsToClean)
		{
			clear_lintData(s);
		}
	}

	/**
	 * Log warnings with little formatting to the warning or error stream
	 * FLEX hooks into this method, nothing in ASC uses it.
	 */
	public int simpleLogWarnings(Context cx, boolean logAsErrors)
	{
		CompilerHandler handler = cx.getHandler();
		if(handler == null) {
			handler = cx.statics.handler;
		}

		int count = 0;
		for (TreeMap<Integer, Set<WarningRecord>> locMap : warningsByLoc.values())
		{
			for(Set<WarningRecord> records : locMap.values())
			{
                for (WarningRecord record : records)
                {
                    StringBuilder sb = new StringBuilder();
                    InputBuffer input = record.loc.input;
				
                    createErrorMessage(record, sb, record.code);
                    String source = input.getLineText(record.loc.pos);
				
                    if (logAsErrors)
                    {
                        handler.error(input.origin, record.lineNum, record.colNum, sb.toString(), source, record.code);
                    }
                    else
                    {
                        // This is the path the Flex compiler usually takes
                        handler.warning(input.origin, record.lineNum, record.colNum, sb.toString(), source, record.code);
                    }
                    count++;
                }
			}
		}
		return count;
	}

	/**
	 * Log formatted warnings to scriptname_warnings.txt and warning stream
	 */
	public void logWarnings(Context cx)
	{
		if(ContextStatics.useSanityStyleErrors || ContextStatics.useSimpleLogWarnings)
		{
			simpleLogWarnings(cx, false);
		}
		else
		{
			StringBuilder        out = new StringBuilder();
			out.append(newline).append("Warning Report:").append(newline);
			out.append("---------------").append(newline).append(newline);
	
			for (Integer code : pWarnings.keySet())
			{
				ObjectList<WarningRecord> warnings = pWarnings.get(code);
	
				out.append("[Coach] Warning #").append(code).append(": ").append(warningConstantsMap.get(code)).append(newline);
				out.append("-------------------------------------------------------------------------").append(newline);
				for( WarningRecord pRec : warnings)	{
					createWarning(pRec, out, code);
					out.append(newline);
				}
				out.append("-------------------------------------------------------------------------").append(newline).append(newline);
			}
			
			if (pWarnings.keySet().size() > 0)
			{
				// print the message
				if(cx.getHandler() != null) {
					cx.getHandler().warning("",-1,-1,out.toString(),"");
				} else {			
					System.err.println(out.toString());
				}
				
				// Output to a log file
				if(output_to_file) {
					BufferedOutputStream warningOut = null;
					try	{
						int dotPos = scriptName.indexOf('.');
						if (dotPos == -1) dotPos = scriptName.length();
						String outName = scriptName.substring(0,dotPos) + "_warnings.txt";
						warningOut = new BufferedOutputStream(new FileOutputStream(new File(outName)));
						warningOut.write(out.toString().getBytes());
						warningOut.flush();
					}
					catch (IOException ex) { ex.printStackTrace(); }
					finally	{
						if (warningOut != null)	{
							try	{ warningOut.close(); }
							catch (IOException ex) {}
						}
					}
				}
			}
		}
	}

	private void createWarning(WarningRecord pRec, StringBuilder out, Integer code)
	{
		InputBuffer input = pRec.loc.input;

		out.append("  ").append(input.origin).append("(").append(pRec.lineNum).append("): ");

		createErrorMessage(pRec, out, code);

		out.append(newline);
		out.append("    ").append(input.getLineText(pRec.loc.pos)).append(newline);
		out.append("    ").append(InputBuffer.getLinePointer(pRec.colNum)).append(newline);
	}
	
	private void createErrorMessage(WarningRecord pRec, StringBuilder out, Integer code)
	{
		// Just the arguments for sanities, no message (since they chang often)
		if(ContextStatics.useSanityStyleErrors) {
			out.append("code=" + code + "; arg1=" + pRec.errStringArg1 + "; arg2=" + pRec.errStringArg2 + "; arg3=" + pRec.errStringArg3);
		}
		// else: standard message
		else
		{
			String templateStr = warningConstantsMap.get(code+1);
			
			// Replace all %s with args
			int nextLoc = Context.replaceStringArg(out,templateStr,0,pRec.errStringArg1);
			nextLoc = Context.replaceStringArg(out,templateStr,nextLoc,pRec.errStringArg2);
            nextLoc = Context.replaceStringArg(out,templateStr,nextLoc,pRec.errStringArg3);
			
			// get trailing remainder, if any
			if (nextLoc != -1)
			{
				out.append(templateStr.substring(nextLoc,templateStr.length()));
			}
		}
	}

	// similiar to error, but doesn't block compilation
	void warning(int pos, InputBuffer input, int code)                      { warning(pos,input,code,"","",""); }
	void warning(int pos, InputBuffer input, int code, String errorArg1)    { warning(pos,input,code,errorArg1,"",""); }
    void warning(int pos, InputBuffer input, int code, String errorArg1, String errorArg2) { warning(pos,input,code,errorArg1,errorArg2,""); }
	void warning(int pos, InputBuffer input, int code, String errorArg1, String errorArg2, String errorArg3)
	{
		// special case ignore
		//	  things in the pEnabledMap.  Some common objects like NaN and undefined are not in playerglobal.as yet
		//	  anything from playerglobal.as.  It still needs to be cleaned up
		//    anything from pos==0.  This is synthesized code created by the compiler.
		if (first_pass ||
            (enabledMap.containsKey(code) && !enabledMap.get(code)) ||
            ignorableFile(input) ||
            (pos == 0)) return;

		CodeLocation loc = new CodeLocation();
		loc.pos = pos;
		loc.input = input;

		if (input != null)
		{
			//TODO Review this for removal/revising later
			// remove this when there is no longer problems with sometimes having a
			// large and wrong loc.pos
			int colPos = input.getColPos(loc.pos);
			if (colPos > 300)
			{
				colPos = 1;
			}

			WarningRecord rec = new WarningRecord( loc,
					input.getLnNum(loc.pos), colPos, code,
					errorArg1, errorArg2, errorArg3);

			// add to pWarnings
			ObjectList<WarningRecord> warnList = pWarnings.get(code);
			if (warnList == null)
				warnList = new ObjectList<WarningRecord>();
			
			// Check for duplicates
			for(WarningRecord test : warnList) {
				if(test.colNum  == rec.colNum &&
				   test.lineNum == rec.lineNum &&
				   test.errStringArg1.equals(rec.errStringArg1) &&
				   test.errStringArg2.equals(rec.errStringArg2) &&
                   test.errStringArg3.equals(rec.errStringArg3) &&
				   test.loc.input.equals(rec.loc.input)) return;
			}
			
			warnList.add(rec);
			pWarnings.put(code,warnList);

			// add to warningsByLoc
			String origin = loc.input.origin;
			TreeMap<Integer, Set<WarningRecord>> locMap = warningsByLoc.get(origin);
            
			if (locMap == null)
			{
				locMap = new TreeMap<Integer, Set<WarningRecord>>();
				warningsByLoc.put(origin, locMap);
			}

            Set<WarningRecord> records = locMap.get(rec.lineNum);

            if (records == null)
            {
                records = new HashSet<WarningRecord>(1);
                locMap.put(rec.lineNum, records);
            }

            records.add(rec);
		}
		else
			assert(false); //  "invalid inputId inAS2LintEvaluator::warning";
	}

	//TODO Review this for removal/revising later
	private boolean ignorableFile(InputBuffer input)
	{
		return (input.origin.endsWith(File.separator + "playerglobal.as")) ||
				(input.origin.endsWith(File.separator + "Global.as"));
	}


	// utility to get a version of a type's name without the namespace attached
	String getSimpleTypeName(TypeValue type)
	{
		return type.name.name;
	}

	private void initialize(Context cx)
	{
		if (initialized)
			return;

		if(warningConstantsEN[0] == null) initWarningConstants();
		initialized = true;

		ReferenceValue typeRef;
		Slot s;
		int x;

		// create a unique value to identify a literal 'undefined' with.  We sometimes
		//  need to know when something is being compared against (or assigned) undefined.
		undefinedLiteral = new ObjectValue("", cx.voidType() );

		// lookup TypeValues for built in types we expect
		for(x=0; x < kNumDefaultTypes; x++)
		{
			typeRef = new ReferenceValue(cx, null, typeDescriptors[x].name ,cx.getNamespace(typeDescriptors[x].nameSpace));
			// this getSlot is allowed to bind
			s = typeRef.getSlot(cx,GET_TOKEN);
			// c++ variant accesses union member typValue directly, java stores value in objValue
			TypeValue t = (s != null && s.getObjectValue() instanceof TypeValue) ? (TypeValue)(s.getObjectValue()) : null;
			types[ typeDescriptors[x].code ] = t;
			typeRef = null;
		}

		types[kVoidType] = cx.nullType();

		int lang = cx.statics.languageID;
		AscWarning[] warningConsts = allWarningConstants[lang];

		for(x = 0; x < kNumWarningConstants; x++)
		{
			warningConstantsMap.put(warningConsts[x].code, warningConsts[x].pWarning);
		}

		for(x = 0; x < kNumPropertyWarnings; x++)
		{
			/* Check to see if there is an old mapping, if so grab it and add to it.
			 * C++ does this succinctly with operator overloading, Java needs some guidance.
			 * 
			 * In C++, ((unsupportedPropsMap[key])[subkey]) = value;
			 * 	    If it does not exist, it simply adds the mapping: key->(subkey->value)
			 * 		else, it gets the old TypeValue and overloading makes it look like:
			 * 			(unsupportedProperties.get(key))[subkey] = value;
			 */
			Map<TypeValue,Integer> subMap = unsupportedPropsMap.get(unsupportedProperties[x].name);
			if (subMap == null) { subMap = new HashMap<TypeValue,Integer>(2); }
			
			subMap.put(types[unsupportedProperties[x].baseType], unsupportedProperties[x].code);
			unsupportedPropsMap.put(unsupportedProperties[x].name, subMap);
		}
		
		for(x = 0; x < kNumMethodWarnings; x++)
		{
			Map<TypeValue,Integer> subMap = unsupportedMethodsMap.get(unsupportedMethods[x].name);
			if (subMap == null) { subMap = new HashMap<TypeValue,Integer>(2); }
			
			subMap.put(types[unsupportedMethods[x].baseType], unsupportedMethods[x].code);
			unsupportedMethodsMap.put(unsupportedMethods[x].name, subMap);
		}
		
		for(x = 0; x < kNumEventWarnings; x++)
		{
			Map<TypeValue,Integer> subMap = unsupportedEventsMap.get(unsupportedEvents[x].name);
			if (subMap == null) { subMap = new HashMap<TypeValue,Integer>(2); }
			
			subMap.put(types[unsupportedEvents[x].baseType], unsupportedEvents[x].code);
			unsupportedEventsMap.put(unsupportedEvents[x].name, subMap);
		}

		/* Hack to ignore warnings for things which should be in playerglobal.as
		but aren't yet (usually because there are some problems with its current definition) */
		if(hackIgnoreIdentifierMap.size() != toIgnore.length) {
			for(x=0; x < toIgnore.length; x++)
				hackIgnoreIdentifierMap.put(toIgnore[x], true);
		}

		baseType_context.add(cx.nullType());
		baseRef_context.add(null);

		// CN:  it would be more elegant to read the xml file using the org.xml.sax.XMLReader,
		//   but this is quicker (to implement) and matches the c++ implementation.  We don't
		//   really need to read all the data in the xml file, just a boolean code per warning id
  		if (enabledMap == null)
		{
			final String filename = (warningEnabledMapFile != null)
							  	  	 ? warningEnabledMapFile
							  	     : "EnabledWarnings.xml";
			try {
				enabledMap = parseEnabledWarningsFile(filename);
			}
			catch (IOException ex)
			{
				enabledMap = new HashMap<Integer, Boolean>();
			}
		}
	}

    public static HashMap<Integer, Boolean> getWarningDefaults()
    {
        if(warningConstantsEN[0] == null) initWarningConstants();
        AscWarning[] warningConsts = allWarningConstants[ContextStatics.LANG_EN];    // language doesn't really matter here

        HashMap<Integer, Boolean> enabledMap = new HashMap<Integer, Boolean>();
        for(int x = 0; x < kNumWarningConstants; x++)
        {
            enabledMap.put(warningConsts[x].code,true);
        }

        return enabledMap;
    }

	public static HashMap<Integer, Boolean> parseEnabledWarningsFile(String filename) throws IOException {
        HashMap<Integer, Boolean> enabledMap = getWarningDefaults();

		// only init the warning constants once -- this can be called statically, or internally
		File warningsFile = new File(filename);
		if (warningsFile.exists() && debug)
		{
			System.err.println("[coach] Using '" + warningsFile.getName() + "'...");
		}
		
		BufferedInputStream warningInput = new BufferedInputStream(new FileInputStream(warningsFile));
		BufferedReader reader = new BufferedReader(new InputStreamReader(warningInput, "UTF8"));
		String textAsString;

		textAsString = reader.readLine();
		int textLength = textAsString.length();

		int endpos = textAsString.indexOf("</warnings>");
		if (endpos == -1)
			endpos = textLength;

		int	pos = 0;
		int code;
		
		boolean atLeastOneWarningDisabled = false;

		while (endpos == textLength)
		{
			pos = textAsString.indexOf("<warning id=", pos);
			if (pos == -1)
				pos = textLength;

			if (pos != endpos)
			{
				code = Integer.parseInt(textAsString.substring(pos+13, pos+17));  // assumes id is 4 digits long
				pos = textAsString.indexOf("enabled=",pos);
				if (pos == -1) {
					pos = textLength;
				}

				if (pos != endpos && "false".equals(textAsString.substring(pos+9, pos+14))) {
					enabledMap.put(code,false);
					atLeastOneWarningDisabled = true;
				}
				
				pos = textAsString.indexOf("</warning>", pos);
				if (pos == -1) {
					pos = textLength;
				}
				else {
					pos += 11;
				}
			}

			if (pos >= endpos)
			{
				textAsString = reader.readLine();
				textLength = textAsString.length();
				endpos = textAsString.indexOf("</warnings>");
				if (endpos == -1)
					endpos = textLength;
				pos = 0;
			}
		}
		reader.close();
		
		if(debug && atLeastOneWarningDisabled) System.err.println("[coach] Some coach-mode warnings are disabled");
		
		return enabledMap;
	}

	public Value evaluate(Context cx, DefaultXMLNamespaceNode node)
	{
		if( node.expr != null )
		{
			node.expr.evaluate(cx,this);
		}
		return cx.voidType();
	}

	public Value evaluate(Context cx, PragmaNode node)
	{
		return cx.voidType();
	}

	public Value evaluate(Context cx, UsePrecisionNode node)
	{
		return cx.voidType();
	}

	public Value evaluate(Context cx, UseNumericNode node)
	{
		return cx.voidType();
	}

	public Value evaluate(Context cx, UseRoundingNode node)
	{
		return cx.voidType();
	}

	public Value evaluate(Context cx, PragmaExpressionNode node)
	{
		return cx.voidType();
	}

	public Value evaluate(Context cx, PackageNameNode node)
	{
		return cx.voidType();
	}

	public Value evaluate(Context cx, PackageIdentifiersNode node)
	{
		return cx.voidType();
	}

	public Value evaluate(Context cx, TypedIdentifierNode node)
	{
		return cx.voidType();
	}

	public Value evaluate(Context cx, UntypedVariableBindingNode node)
	{
		return cx.voidType();
	}

	public Value evaluate(Context cx, DocCommentNode node)
	{
		return cx.voidType();
	}

	public Value evaluate(Context cx, ImportNode node)
	{
		return cx.voidType();
	}

	public Value evaluate(Context cx, QualifiedIdentifierNode node)
	{
		if (node.qualifier != null)
		{
			node.qualifier.evaluate(cx, this);
		}
		return cx.voidType();
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
		return cx.voidType();
	}

	// We sometimes need to store AS2Lint specific data on the slot for an identifier.  These
	//  methods allow us to read and write our custom data to/from a slot without impacting the rest
	//  of the compiler.  Slot supported an opaque data pointer named embeddedData which we
	//  store our  custom LintDataRecord on.  The methods which follow simplify accessing
	//  these custom data fields.
	private static class LintDataRecord 
	{
		public boolean has_return_value;
		public boolean is_registered_for_event;
		public boolean has_been_declared;
        int  declaration_pos;
		public LintDataRecord()
		{
			has_return_value = false;
			has_been_declared = false;
			is_registered_for_event = false;
            declaration_pos = 0;
		}
	};

	private ObjectList<Slot>  slotsToClean = new ObjectList<Slot>();  // store what we allocate so we can clean it up

	private LintDataRecord slot_GetComplianceRecord(Slot s)
	{
		if (s.getEmbeddedData() == null)
		{
			s.setEmbeddedData(new LintDataRecord());
			slotsToClean.add( s );
		}
		return (LintDataRecord)(s.getEmbeddedData());
	}

	private void slot_markAsDeclared(Slot s, int pos)
	{
		slot_GetComplianceRecord(s).has_been_declared = true;
        slot_GetComplianceRecord(s).declaration_pos = pos;
	}

	private void slot_setHasReturnValue(Slot s, boolean hasReturn)
	{
		slot_GetComplianceRecord(s).has_return_value = hasReturn;
	}

	private void slot_markAsRegisteredForEvent(Slot s, boolean isRegistered)
	{
		slot_GetComplianceRecord(s).is_registered_for_event = isRegistered;
	}

	private boolean slot_isAlreadyDeclared(Slot s)
	{
		if (s != null && s.getEmbeddedData() != null)
			return slot_GetComplianceRecord(s).has_been_declared;
		return false;
	}

//    private int slot_getOriginalDeclarationPosition(Slot s)
//    {
//		if (s != null && s.getEmbeddedData() != null)
//			return slot_GetComplianceRecord(s).declaration_pos;
//		return -1;
//	}



	private boolean slot_GetHasReturnValue(Slot s)
	{
		if (s != null && s.getEmbeddedData() != null)
		{
			LintDataRecord r = slot_GetComplianceRecord(s);
			return r.has_return_value;
		}
		return false;
	}

	private boolean slot_GetRegisteredForEvent(Slot s)
	{
		if (s != null && s.getEmbeddedData() != null)
			return slot_GetComplianceRecord(s).is_registered_for_event;
		return false;
	}

	static void clear_lintData(Slot s)
	{
		s.setEmbeddedData(null);
	}

	public void testErrorStrings(Context cx)
	{
		// todo: add all warning string here
	}

	public void setOutputToFile(boolean otf) {
		output_to_file = otf;
	}

    public Value evaluate(Context cx, TypeExpressionNode node)
    {
        return node.expr.evaluate(cx, this);
    }
}
