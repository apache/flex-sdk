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

import macromedia.asc.semantics.Value;
import macromedia.asc.semantics.ReferenceValue;
import macromedia.asc.semantics.Slot;
import macromedia.asc.util.Context;
import macromedia.asc.util.ObjectList;
import macromedia.asc.embedding.ErrorConstants;
import macromedia.asc.embedding.avmplus.InstanceBuilder;

public class MetaDataEvaluator implements Evaluator, ErrorConstants
{
    public static final String GO_TO_CTOR_DEFINITION_HELP = "__go_to_ctor_definition_help";
    public static final String GO_TO_DEFINITION_HELP = "__go_to_definition_help";

    public boolean doing_class;
    private boolean addGoToDefinitionHelpPosition;
    private boolean addGoToDefinitionHelpFile;

    public MetaDataEvaluator()
	{
	}

    public MetaDataEvaluator(boolean debug)
    {
        this(debug, debug);
    }

    public MetaDataEvaluator(boolean addGoToDefinitionHelpPosition, boolean addGoToDefinitionHelpFile)
    {
        this.addGoToDefinitionHelpPosition = addGoToDefinitionHelpPosition;
        this.addGoToDefinitionHelpFile = addGoToDefinitionHelpFile;
    }

	public boolean checkFeature(Context cx, Node node)
	{
		return true; // return true;
	}

	static public class KeylessValue extends Value
	{
		public String obj;

		public KeylessValue(String v)
		{
			v=v.intern();//assert v == v.intern();
			obj = v;
		}
	}

	static public class KeyValuePair extends Value
	{
		public String key;
		public String obj;

		public KeyValuePair(String key, String value)
		{
			//assert key == key.intern() : key;
			//assert value == value.intern() : value;
			this.key = key.intern();
			this.obj = value.intern();
		}
	}

	private MetaDataNode current;

	// Base node

	public Value evaluate(Context cx, Node node)
	{
		cx.internalError("error: undefined meta data method");
		return null;
	}

	// Expression evaluators

	public Value evaluate(Context cx, IdentifierNode node)
	{
		return new KeylessValue(node.name);
	}

	public Value evaluate(Context cx, MetaDataNode node)
	{
		current = node;

		if (node.data == null ||
			node.data.elementlist == null)
		{
		}
		else if (node.data.elementlist.size() > 1)
		{
			cx.error(node.pos(), kError_MetaDataAttributesHasMoreThanOneElement);
		}
		else if( node.data.elementlist.items.get(0) instanceof MemberExpressionNode )
		{
			MemberExpressionNode men = ((MemberExpressionNode) node.data.elementlist.items.get(0));
			SelectorNode selector = (men!=null) ? men.selector : null;

			if (selector != null)
			{
				if (selector instanceof CallExpressionNode)
				{
					CallExpressionNode call = (CallExpressionNode) selector;

					if (call.expr != null)
					{
						KeylessValue val = (KeylessValue) call.expr.evaluate(cx, this);
						//node.values.add(val);
						current.setId(val.obj);
					}

					if (call.args != null)
					{
						int length = call.args.size();
						node.setValues(new Value[length]);
						for (int i = 0; i < length; i++)
						{
							Node n = call.args.items.get(i);
							Value value = n.evaluate(cx, this);
							if (value == null)
							{
								cx.error(n.pos(), kError_InvalidMetaData);
							}
							node.getValues()[i] = value;
						}
					}
				}

				if (selector instanceof GetExpressionNode)
				{
                    // This is a metadatadata node for something like [Foo], with no arguments, so don't fill in
                    // the values, otherwise this case is indistinquishable from [Foo("Foo")] which will be handled
                    // by the CallExpressionNode block above.
					GetExpressionNode getexpr = (GetExpressionNode) selector;

					if (getexpr != null && getexpr.expr != null)
					{
						KeylessValue value = (KeylessValue) getexpr.expr.evaluate(cx, this);
						current.setId(value.obj);
					}
				}
			}
            node.data = null;
        }
        else
        {
            if( node.data.elementlist.items.get(0) != null )
            {
                cx.error(node.data.elementlist.items.get(0).pos(), kError_InvalidMetaData);
            }
            else
            {
                cx.error(node.pos(), kError_InvalidMetaData);
            }
        }


		return null;
	}

	public ObjectList<DocCommentNode> doccomments = new ObjectList<DocCommentNode>();

    public Value evaluate(Context cx, DocCommentNode node)
	{
		this.evaluate(cx, (MetaDataNode)node);

        boolean add_node = true;
        int size = doccomments.size();
        if( size > 0 )
        {
            DocCommentNode dcn = doccomments.at(size-1);
            if( dcn.def == node.def )
            {
                if( node.is_default && ( dcn.metaData == null || !("Event".equals(dcn.metaData.getId())
                                            || "Style".equals(dcn.metaData.getId())
                                            || "Effect".equals(dcn.metaData.getId())
                                            || "SkinState".equals(dcn.metaData.getId())
                                            || "Alternative".equals(dcn.metaData.getId())
                                            || "DiscouragedForProfile".equals(dcn.metaData.getId())) ) )
                    add_node = false;
                else
                    doccomments.remove(size-1);
            }
            
        }
        if( add_node )
            doccomments.push_back(node);

        return null;
	}

	public Value evaluate(Context cx, LiteralArrayNode node)
	{
		return null;
	}
	
	public Value evaluate(Context cx, LiteralVectorNode node)
	{
		return null;
	}

	public Value evaluate(Context cx, MemberExpressionNode node)
	{
		Value val = null;
		if (node.base != null)
		{
			node.base.evaluate(cx, this);
		}
		if (node.selector != null)
		{
			val = node.selector.evaluate(cx, this);
		}

		return val;
	}


    public Value evaluate(Context cx, ApplyTypeExprNode node)
    {
        return null;
    }

	public Value evaluate(Context cx, GetExpressionNode node)
	{
		if (node.expr != null)
		{
			return node.expr.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, SetExpressionNode node)
	{
		String name = null;
		String value = null;

		if (node.expr != null)
		{
			KeylessValue val = (KeylessValue) node.expr.evaluate(cx, this);
			name = (val != null) ? (String) val.obj : name;
		}
		if (node.args != null)
		{
			KeylessValue val = (KeylessValue) node.args.evaluate(cx, this);
			value = (val != null) ? val.obj : value;
		}

		if (name != null && value != null)
		{
			return new KeyValuePair(name, value);
		}

		return null;
	}

	public Value evaluate(Context cx, CallExpressionNode node)
	{
		return null;
	}

	public Value evaluate(Context cx, ArgumentListNode node)
	{
		Value val = null;
		for (Node n : node.items)
		{
			if (n != null)
			{
				val = n.evaluate(cx, this);
			}
		}
		return val;
	}

	public Value evaluate(Context cx, LiteralBooleanNode node)
	{
		KeylessValue val;
		if (node.value)
		{
			val = new KeylessValue("true");
		}
		else
		{
			val = new KeylessValue("false");
		}
		return val;
	}

	public Value evaluate(Context cx, LiteralNumberNode node)
	{
		return new KeylessValue(node.value);
	}

	public Value evaluate(Context cx, LiteralStringNode node)
	{
		return new KeylessValue(node.value);
	}

	public Value evaluate(Context cx, LiteralNullNode node)
	{
		return new KeylessValue("null");
	}

	public Value evaluate(Context cx, LiteralRegExpNode node)
	{
		return new KeylessValue(node.value);
	}

	// Expression evaluators

	public Value evaluate(Context cx, IncrementNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, DeleteExpressionNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, InvokeNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, ThisExpressionNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, QualifiedIdentifierNode node)
	{
		return new KeylessValue(node.name);  // just return the simple name
	};

    public Value evaluate(Context cx, QualifiedExpressionNode node)
    {
        return null;
    };

	public Value evaluate(Context cx, LiteralXMLNode node)
	{
		//cx.error(node.pos(), kError_MetaDataContainsXmlLiteral);
		Value v = null;
		if( node.list != null)
		{
			v = node.list.evaluate(cx,this);
		}
		return v;
	};

	public Value evaluate(Context cx, FunctionCommonNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, ParenExpressionNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, ParenListExpressionNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, LiteralObjectNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, LiteralFieldNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, SuperExpressionNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, SuperStatementNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, UnaryExpressionNode node)
	{
		if (node.expr != null)
			node.expr.evaluate(cx,this);
		return null;
	};

	public Value evaluate(Context cx, BinaryExpressionNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, ConditionalExpressionNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, ListNode node)
	{
		Value v = null;
		for (Node n : node.items)
		{
			if (n != null)
			{
				v = n.evaluate(cx, this);
			}
		}
		return v;
	};

	// Statements

	public Value evaluate(Context cx, StatementListNode node)
	{
		for (Node n : node.items)
		{
			if (n != null)
			{
				n.evaluate(cx, this);
			}
		}
		return null;
	};

	public Value evaluate(Context cx, EmptyElementNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, EmptyStatementNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, ExpressionStatementNode node)
	{
		if (node.expr != null)
			node.expr.evaluate(cx,this);
		return null;
	};

	public Value evaluate(Context cx, LabeledStatementNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, IfStatementNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, SwitchStatementNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, CaseLabelNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, DoStatementNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, WhileStatementNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, ForStatementNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, WithStatementNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, ContinueStatementNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, BreakStatementNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, ReturnStatementNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, ThrowStatementNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, TryStatementNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, CatchClauseNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, FinallyClauseNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, UseDirectiveNode node)
	{
		return null;
	};

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
	};

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

	// Definitions

	public Value evaluate(Context cx, ImportDirectiveNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, AttributeListNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, VariableDefinitionNode node)
	{
		if (node.attrs != null)
			node.attrs.evaluate(cx, this);
		if (node.list != null)
			node.list.evaluate(cx,this);

        VariableDefinitionNode vdn = node;

        if (addGoToDefinitionHelpPosition)
            addPositionMetadata(cx, vdn);

        if( node.metaData != null )
        {
            for(Node it : vdn.list.items)
            {
                VariableBindingNode binding = it instanceof VariableBindingNode ? (VariableBindingNode)it : null;
                if (binding != null)
                {
                    ReferenceValue ref = binding.ref;
                    Slot slot = null;
                    if ( ref != null )
                        slot = ref.getSlot(cx);
                    if ( slot != null && slot.getMetadata() == null )
                    {
                        for( Node meta_node : vdn.metaData.items)
                        {
                            if( meta_node instanceof MetaDataNode)
                                addMetadataToSlot(cx, slot, (MetaDataNode)meta_node);
                        }
                    }
                }
            }
        }

		return null;
	};

	public Value evaluate(Context cx, VariableBindingNode node)
	{
		if (node.variable != null)
			node.variable.evaluate(cx,this);

    	if( cx.statics.es4_nullability && cx.scope().builder instanceof InstanceBuilder )
    	{
    		cx.scope().setInitOnly(true);
    	}

    	if (node.initializer != null)
			node.initializer.evaluate(cx,this);

    	if( cx.statics.es4_nullability && cx.scope().builder instanceof InstanceBuilder )
    	{
    		cx.scope().setInitOnly(false);
    	}

		return null;
	};

	public Value evaluate(Context cx, UntypedVariableBindingNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, TypedIdentifierNode node)
	{
		if (node.identifier != null)
			node.identifier.evaluate(cx,this);
		if (node.type != null)
			node.type.evaluate(cx,this);
		return null;
	};

    public Value evaluate(Context cx, BinaryFunctionDefinitionNode node)
    {
        return null;
    };

	public Value evaluate(Context cx, FunctionDefinitionNode node)
	{
         FunctionDefinitionNode fdn = node;
        int kind = fdn.fexpr.kind;
        ReferenceValue ref = fdn.fexpr.ref;
        Slot func_slot = null;
        if( ref != null )
            func_slot = ref.getSlot(cx, kind);

        if (addGoToDefinitionHelpPosition)
            addPositionMetadata(cx, fdn);

        if( func_slot != null && func_slot.getMetadata() == null && fdn.metaData != null)
        {
            for( Node meta_node : fdn.metaData.items)
            {
                if( meta_node instanceof MetaDataNode)
                {
                    addMetadataToSlot(cx, func_slot, (MetaDataNode)meta_node);
                    int i = isVersionMetadata(cx, (MetaDataNode)meta_node);
                    if( i > -1)
                        fdn.version = i;
                }
            }
        }
		return null;
	};

    private void addMetadataToSlot(Context cx, Slot slot, MetaDataNode metadata)
    {
        if( metadata != null )
        {
            if( !(metadata instanceof DocCommentNode ) )
            {
                if( metadata.getMetadata() == null )
                    metadata.evaluate(cx, this);                        
                // Don't add comments as metadata
                slot.addMetadata(metadata);
                int i = isVersionMetadata(cx, metadata);
                if( i != -1 )
                    slot.setVersion((byte)i);
            }
        }
    }

    private int isVersionMetadata(Context cx, MetaDataNode metadata)
    {
        if( cx.checkVersion() )
        {
            if( "Version".equals(metadata.getId()) && metadata.getValues() != null && metadata.getValues().length ==1)
            {
                KeylessValue k = metadata.getValues()[0] instanceof KeylessValue ? (KeylessValue) metadata.getValues()[0] : null;
                if( k != null )
                {
                    int i = -1;
                    try
                    {
                        i = Integer.valueOf(k.obj);
                    }
                    catch(NumberFormatException nfe)
                    {
                        // not an integer
                    }
                    return i;
                }
            }
        }
        return -1;
    }

    public Value evaluate(Context cx, FunctionNameNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, FunctionSignatureNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, ParameterNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, ParameterListNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, RestExpressionNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, RestParameterNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, InterfaceDefinitionNode node)
	{
        return evaluate(cx, (ClassDefinitionNode)node);
	};

	public Value evaluate(Context cx, ClassDefinitionNode node)
	{
		if (doing_class)
			return null;
		doing_class = true; // inner classes are included multiple times in node->staticinits.  Don't double evaluate them.

        cx.pushStaticClassScopes(node);

		if (node.statements != null)
			node.statements.evaluate(cx,this);

        // now do the nested classes
        doing_class = false;
        {
            for(ClassDefinitionNode it : node.clsdefs )
            {
                it.evaluate(cx,this);
            }
        }

        cx.pushScope(node.iframe);

		{
            for (Node init : node.instanceinits)
			{
            	if( cx.statics.es4_nullability && !init.isDefinition() )
            		node.iframe.setInitOnly(true);

            	init.evaluate(cx, this);
            	
            	if (addGoToDefinitionHelpPosition && init instanceof FunctionDefinitionNode)
            	{
            		FunctionDefinitionNode fdn = (FunctionDefinitionNode)init;
            		if (fdn.fexpr.ref != null && "$construct".equals(fdn.fexpr.ref.name) )
            		{
            			addCtorPositionMetadata(cx, node, fdn);
            		}
            	}

				if( cx.statics.es4_nullability && !init.isDefinition() )
            		node.iframe.setInitOnly(false);
			}
		}

        cx.popScope(); //iframe
        cx.popStaticClassScopes(node);


        ClassDefinitionNode cdn = node;
        ReferenceValue ref = cdn.ref;
        Slot classSlot = null;
        if( ref != null )
            classSlot = ref.getSlot(cx);
        if (addGoToDefinitionHelpPosition)
        {
            addPositionMetadata(cx, cdn);
        }
        if( classSlot != null && classSlot.getMetadata() == null && cdn.metaData != null )
        {
            for( Node meta_node : cdn.metaData.items)
            {
                if( meta_node instanceof MetaDataNode)
                {
                    addMetadataToSlot(cx, classSlot, (MetaDataNode)meta_node);
                    int i = isVersionMetadata(cx, (MetaDataNode)meta_node);
                    if( i > -1)
                        cdn.version = i;
                }
            }
        }

		return null;
	}

	private MetaDataNode makePositionMetadata(Context cx, DefinitionNode def, boolean is_ctor)
	{
        MetaDataNode mn = cx.getNodeFactory().metaData(null, -1);
        mn.setId(is_ctor? GO_TO_CTOR_DEFINITION_HELP : GO_TO_DEFINITION_HELP);

        if (addGoToDefinitionHelpFile)
        {
            mn.setValues(new Value[2]);
            mn.getValues()[0] = new KeyValuePair("file", cx.getErrorOrigin());
            mn.getValues()[1] = new KeyValuePair("pos", String.valueOf(def.pos()) );
        }
        else
        {
            mn.setValues(new Value[1]);
            mn.getValues()[0] = new KeyValuePair("pos", String.valueOf(def.pos()) );
        }
        
        return mn;
	}

	// Add the ctors position info as metadata on the class - this is neccessary because
	// ctors don't get an entry in the Classes Traits, and all metadata hangs off of the Traits
	private void addCtorPositionMetadata(Context cx, ClassDefinitionNode cdn, FunctionDefinitionNode ctor)
	{
        cdn.addMetaDataNode(makePositionMetadata(cx, ctor, true));
	}
	
	// Add position metadata to a definition - Builder uses this to jump to definition.
    private void addPositionMetadata(Context cx, DefinitionNode def) {
        def.addMetaDataNode(makePositionMetadata(cx, def, false));
    }

	public Value evaluate(Context cx, ClassNameNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, InheritanceNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, NamespaceDefinitionNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, ConfigNamespaceDefinitionNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, PackageDefinitionNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, PackageIdentifiersNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, PackageNameNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, ProgramNode node)
	{
		for (Node n : node.pkgdefs)
		{
			if (n != null)
			{
				n.evaluate(cx, this);
			}
		}
		if (node.statements != null)
			node.statements.evaluate(cx,this);

		return null;
	};

	public Value evaluate(Context cx, ErrorNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, ToObjectNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, LoadRegisterNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, StoreRegisterNode node)
	{
		return null;
	};

	public Value evaluate( Context cx, HasNextNode node )
	{
		return null;
	}

	public Value evaluate(Context cx, BoxNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, CoerceNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, PragmaNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, UsePrecisionNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, UseNumericNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, UseRoundingNode node)
	{
		return null;
	};

	public Value evaluate(Context cx, PragmaExpressionNode node)
	{
		return null;
	};

    public Value evaluate(Context cx, DefaultXMLNamespaceNode node)
    {
        return null;
    };

    public Value evaluate(Context cx, RegisterNode node)
    {
        return null;
    };

    public Value evaluate(Context cx, TypeExpressionNode node)
    {
        return node.expr.evaluate(cx, this);
    }
}
