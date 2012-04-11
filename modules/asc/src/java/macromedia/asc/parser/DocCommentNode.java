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

package macromedia.asc.parser;

import macromedia.asc.util.Context;
import macromedia.asc.semantics.*;
import static macromedia.asc.parser.Tokens.*;

/**
 * @author Jeff Dyer
 */
public class DocCommentNode extends MetaDataNode
{
    MetaDataNode metaData; // some comments are associated with other metadata (in addition to a definition)
    boolean is_default;

     DocCommentNode(LiteralArrayNode data)
	{
		super(data);
        metaData = null;
        is_default = false;
    }
     
	public Value evaluate( Context cx, Evaluator evaluator )
	{
		if( evaluator.checkFeature(cx,this) )
			return evaluator.evaluate( cx, this );
		else
			return null;
	    }

    private StringBuilder emitMetaDataComment(StringBuilder buf, String debugName, MetaDataNode meta, boolean isAttributeOfDefinition)
	{
		buf.append("\n<metadata>\n");
		String tagname = meta.getId();
		buf.append("\n\t<").append(tagname).append(" ");
		buf.append("owner='").append(debugName).append("' ");

		// write out the first keyless value, if any, as the name attribute. Output all keyValuePairs
		//  as usual.
  	    boolean has_name = false;
        if( meta.getValues() != null )
        {
            if( "SkinStates".equals(meta.getId()) )
            {
                boolean first = true;
                for( Value v : meta.getValues())
                {
                    if( v instanceof MetaDataEvaluator.KeylessValue )
                    {
                        MetaDataEvaluator.KeylessValue ov = (MetaDataEvaluator.KeylessValue)v;
                        if( first )
                        {
                            first = false;
                            buf.append("states='");
                        }
                        else
                        {
                            buf.append(", ");
                        }
                        buf.append(ov.obj);
                    }
                }
                if( !first )
                    buf.append("'");
            }
            else
            {
                for( Value v : meta.getValues())
                {
                    if (v instanceof MetaDataEvaluator.KeylessValue && has_name == false)
                    {
                        MetaDataEvaluator.KeylessValue ov = (MetaDataEvaluator.KeylessValue)v;
                        buf.append("name='").append(ov.obj).append("' ");
                        has_name = true;
                        continue;
                    }
                    if (v instanceof MetaDataEvaluator.KeyValuePair)
                    {
                        MetaDataEvaluator.KeyValuePair kv = (MetaDataEvaluator.KeyValuePair)v;
                        buf.append(kv.key).append("='").append(kv.obj).append("' ");
                        continue;
                    }
                }
            }
        }
        else if( meta.getId() != null )
        {
            // metadata with an id, but no values
            buf.append("name='").append(meta.getId()).append("' ");
        }

		buf.append(">\n");

		// [Event], [Style], and [Effect] are documented as seperate entities, rather than
		//   as elements of other entities.  In that case, we need to write out the asDoc
		//   comment here 
		if ( isAttributeOfDefinition == false)
		{

			if (getValues() != null)
			{
				for( Value v : getValues())
				{
					if (v instanceof MetaDataEvaluator.KeylessValue)
					{
						MetaDataEvaluator.KeylessValue ov = (MetaDataEvaluator.KeylessValue)v;
						buf.append(ov.obj);
						continue;
					}

					if (v instanceof MetaDataEvaluator.KeyValuePair)
					{
						MetaDataEvaluator.KeyValuePair kv = (MetaDataEvaluator.KeyValuePair)v;
						buf.append("\n\t<").append(kv.key).append(">").append(kv.obj).append("</").append(kv.key).append(">");
						continue;
					}
				}
			}
            else if( getId() != null )
            {
                // Id, but no values
                buf.append(getId());
            }
		}

		buf.append("\n\t</").append(tagname).append(">\n");
		buf.append("</metadata>\n");
		return buf;
	}

	public StringBuilder emit(Context cx,StringBuilder buf)
	{
		String tagname = "";
		StatementListNode metaData = null;
		String debug_name = "";

		if( this.def instanceof FunctionDefinitionNode )
		{
			FunctionDefinitionNode fd = (FunctionDefinitionNode)this.def;
				
			debug_name = fd.fexpr.debug_name;
			metaData = fd.metaData;
			tagname = "method";

			buf.append("\n<method name='");
			buf.append(fd.name.identifier.name);
			buf.append("' fullname='");
			buf.append(fd.fexpr.debug_name);
			buf.append("' ");
 
			AttributeListNode attrs = fd.attrs;
			if (attrs != null)
			{
				buf.append("isStatic='");
				buf.append(attrs.hasStatic ? "true" : "false");
				buf.append("' ");

				buf.append("isFinal='");
				buf.append(attrs.hasFinal ? "true" : "false");
				buf.append("' ");

				buf.append("isOverride='");
				buf.append(attrs.hasOverride ? "true" : "false");
				buf.append("' ");
				//buf.append("const='" + (attrs->hasConst ? "true" : "false") + "' ";
				//buf.append("dynamic='" + (attrs->hasDynamic ? "true" : "false") + "' ";
			}
			else
			{
				buf.append("isStatic='false' ");
				buf.append("isFinal='false' ");
				buf.append("isOverride='false' ");
			}
           
			fd.fexpr.signature.toCanonicalString(cx, buf);
			buf.append(">");
		}
	        
		if( this.def instanceof VariableDefinitionNode )
		{
			VariableDefinitionNode vd = (VariableDefinitionNode)this.def;
			VariableBindingNode    vb = (VariableBindingNode)(vd.list.items.get(0));

			debug_name = vb.debug_name;
			metaData = vd.metaData;

			tagname = "field";
			buf.append("\n<");
			buf.append(tagname);
			buf.append(" name='");
			buf.append(vb.variable.identifier.name);
			buf.append("' fullname='");
			buf.append(vb.debug_name);
			buf.append("' type='");
			if (vb.typeref != null)
			{
                buf.append(getRefName(cx, vb.typeref));
            }
			buf.append("' ");

			AttributeListNode attrs = vd.attrs;
			if (attrs != null)
			{
				buf.append("isStatic='");  // bug in E4X prevents us from using reserved keywords like 'static' as attribute keys
				buf.append(attrs.hasStatic ? "true" : "false");
				buf.append("' ");
			}
			else
			{
				buf.append("isStatic='false' ");
			}
			
			Slot s = vb.ref.getSlot(cx);
			if (s != null)
			{
				buf.append("isConst='");
				buf.append(s.isConst() ? "true" : "false");
				buf.append("' ");
			}

            if( vb.initializer != null )
            {
                buf.append("defaultValue='");
                if (vb.initializer instanceof LiteralNumberNode)
                {
                    buf.append( ((LiteralNumberNode)(vb.initializer)).value);
                }
                else if (vb.initializer instanceof LiteralStringNode)
                {
                    buf.append( escapeXml( ((LiteralStringNode)(vb.initializer)).value ));
                }
                else if (vb.initializer instanceof LiteralNullNode)
                {
                    buf.append("null");
                }
                else if (vb.initializer instanceof LiteralBooleanNode)
                {
                    buf.append( (((LiteralBooleanNode)(vb.initializer)).value) ? "true" : "false");
                }
                else if (vb.initializer instanceof MemberExpressionNode)
                {
                    MemberExpressionNode mb = (MemberExpressionNode)(vb.initializer);
                    Slot vs = (mb.ref != null ? mb.ref.getSlot(cx,GET_TOKEN) : null);
                    Value v = (vs != null ? vs.getValue() : null);
                    ObjectValue ov = ((v instanceof ObjectValue) ? (ObjectValue)(v) : null);
                    // if constant evaluator has determined this has a value, use it.
                    buf.append( (ov != null) ? ov.getValue() : "unknown");
                }
                else
                {
                    Slot vs = vb.ref.getSlot(cx,GET_TOKEN);
                    Value v = (vs != null ? vs.getValue() : null);
                    ObjectValue ov = ((v instanceof ObjectValue) ? (ObjectValue)(v) : null);
                    // if constant evaluator has determined this has a value, use it.
                    buf.append( (ov != null) ? ov.getValue() : "unknown");
                }
                buf.append("' ");
            }
			buf.append(">");
		}
	        
  		if (this.def instanceof PackageDefinitionNode)	
		{
			PackageDefinitionNode pd = (PackageDefinitionNode)(this.def);
			tagname = "packageRec";
			debug_name = "";
			metaData = null;

			buf.append("\n<");
			buf.append(tagname);
			buf.append(" name='");
		  	buf.append((pd.name.id != null ? pd.name.id.pkg_part : ""));
		 	buf.append(".");
		 	buf.append((pd.name.id != null ? pd.name.id.def_part : ""));    
			buf.append("' fullname='");
		 	buf.append((pd.name.id != null ? pd.name.id.pkg_part : ""));
			buf.append(".");
			buf.append((pd.name.id != null ? pd.name.id.def_part : ""));    
			buf.append("'>\n");
		}
		
		
		if( this.def instanceof ClassDefinitionNode )
		{
			ClassDefinitionNode cd = (ClassDefinitionNode)this.def;

            // Special case for comments preceeding an [Event] / [Style ] / or [Effect] metadata element.
			//  Doccomments associated with these metadata elements are output as a seperate metaData doc entry,
			//  rather than as the doc entry for their associated definition.

            /* no longer needed.  The above test prevents this from beign hit.  We now detect and emit this during the general
               metadata handling for the class
			if (this.metaData != null &&
				("Event".equals(this.metaData.id) ||
				 "Style".equals(this.metaData.id) ||
				 "Effect".equals(this.metaData.id) ) )
			{
				emitMetaDataComment(buf,cd.debug_name, this.metaData, false);
				return buf; // classRecord which follows is a copy of the real thing.  Don't export twice
			}
            */


			debug_name = cd.debug_name;
			metaData = cd.metaData;

			InterfaceDefinitionNode id = null;
			if( this.def instanceof InterfaceDefinitionNode )
			{
				tagname = "interfaceRec";
				id = (InterfaceDefinitionNode)(this.def);
			}
			else
			{
				tagname = "classRec";
			}

            buf.append("\n<");
            buf.append(tagname);
            buf.append(" name='");
            buf.append(cd.name.name);
            buf.append("' fullname='");
            buf.append(cd.debug_name);
			if (cd.cx.input != null && cd.cx.input.origin.length() != 0)
			{
				buf.append("' sourcefile='");
				buf.append(cd.cx.input.origin);
			}
            buf.append("' namespace='");
            buf.append(cd.cframe.builder.classname.ns.name);
            buf.append("' access='");
            buf.append(getAccessKindFromNS(cd.cframe.builder.classname.ns));
			if (id != null)
			{
				buf.append("' baseClasses='");
				if( id.interfaces != null )
				{
					Value firstV = id.interfaces.values.get(0);
					for (Value v : id.interfaces.values)
					{
						//    InterfaceDefinitionNode* idn = dynamic_cast<InterfaceDefinitionNode*>(*it);
						ReferenceValue rv = (ReferenceValue)v;
						if( v != firstV )
						{
							buf.append(";");
						}
						Slot s = rv.getSlot(cx, GET_TOKEN);
						buf.append((s == null || s.getDebugName().length() == 0) ? rv.name : s.getDebugName());
					}
				}
				else
				{
					buf.append("Object");
				}
				buf.append("' ");
			}
			else
			{
				buf.append("' baseclass='");
				if (cd.baseref != null)
				{
					Slot s = cd.baseref.getSlot(cx, GET_TOKEN);
					buf.append( (s == null || s.getDebugName().length() == 0) ? "Object" : s.getDebugName() );
				}
				else
				{
					buf.append("Object");
				}
				buf.append("' ");

				if( cd.interfaces != null )
				{
					buf.append("interfaces='");

					Value firstV = cd.interfaces.values.get(0);
					for (Value v : cd.interfaces.values)
					{
						//    InterfaceDefinitionNode* idn = dynamic_cast<InterfaceDefinitionNode*>(*it);
						ReferenceValue rv = (ReferenceValue)v;
						if( v != firstV )
						{
							buf.append(";");
						}
						Slot s = rv.getSlot(cx, GET_TOKEN);
						buf.append((s == null || s.getDebugName().length() == 0) ? rv.name : s.getDebugName());
					}

					buf.append("' ");
				}
			}


			AttributeListNode attrs = cd.attrs;
			if (attrs != null)
			{
				buf.append("isFinal='");
				buf.append(attrs.hasFinal ? "true" : "false");
				buf.append("' ");

				buf.append("isDynamic='");
				buf.append(attrs.hasDynamic ? "true" : "false");
				buf.append("' ");
			}
			else
			{
				buf.append("isFinal='false' ");
				buf.append("isDynamic='false' ");
			}
			buf.append(">");
		}

        if( getValues() != null )
        {
            for( Value v : getValues())
            {
                if (v instanceof MetaDataEvaluator.KeylessValue)
                {
                    MetaDataEvaluator.KeylessValue ov = (MetaDataEvaluator.KeylessValue)v;
                    buf.append(ov.obj);
                    continue;
                }

                if (v instanceof MetaDataEvaluator.KeyValuePair)
                {
                    MetaDataEvaluator.KeyValuePair kv = (MetaDataEvaluator.KeyValuePair)v;
                    buf.append("\n<").append(kv.key).append(">").append(kv.obj).append("</").append(kv.key).append(">");
                    continue;
                }
            }
        }
        else if( getId() != null )
        {
            // id, but no values
            buf.append(getId());
        }

		// Look for metaData we care about.  Also look for comments which are associated with metaData rather than the def.
		if (this.def != null && this.def.metaData != null)
		{
            int numItems = this.def.metaData.items.size();
			for( int x=0; x < numItems; x++ )
			{
                Node md = this.def.metaData.items.at(x);
                MetaDataNode mdi = (md instanceof MetaDataNode) ? (MetaDataNode)(md) : null;

                // cn: why not just dump all the metaData ???
				if (mdi != null && mdi.getId() != null)
                {
                    // these metaData types can have their own DocComment associated with them, though they might also have no comment.
                    if (mdi.getId().equals("Style") || mdi.getId().equals("Event") || mdi.getId().equals("Effect") )
                    {
                        if (x+1 < numItems)  // if it has a comment, it will be the sequentially next DocCommentNode
                        {
                            Node next = this.def.metaData.items.at(x+1);
                            DocCommentNode metaDataComment = (next instanceof DocCommentNode) ? (DocCommentNode)next : null;
                            // make sure the comment belongs to this piece of metaData.  It always should, but just in case....
                            if ((metaDataComment != null) && (metaDataComment.metaData != mdi))
                                metaDataComment = null;

                            if (metaDataComment != null)
                            {
                                metaDataComment.emitMetaDataComment(buf, debug_name, mdi, false);
                                x++;
                            }
                            else  // emit it even if it doesn't have a comment.
                            {
                                emitMetaDataComment(buf, debug_name, mdi, true);
                            }
                        }
                        else
                        {
                            emitMetaDataComment(buf, debug_name, mdi, true);
                        }
                    }
                    else if (mdi.getId().equals("Bindable") || mdi.getId().equals("Deprecated") || mdi.getId().equals("Exclude")
                            || mdi.getId().equals("DefaultProperty") || mdi.getId().equals("SkinStates") )
                    {
                        emitMetaDataComment(buf, debug_name, mdi, true);
                    }
                }
			}
		}

		if (!"".equals(tagname))
		{
			buf.append("\n</");
		    buf.append(tagname);
		    buf.append(">");
		}
		else
		{
			if (this.def instanceof NamespaceDefinitionNode)
            {
                NamespaceDefinitionNode nd = (NamespaceDefinitionNode)(this.def);
			    if (nd != null)
				    buf.append("<!-- Namespace comments not supported yet: ").append(nd.debug_name).append("-->");
			    //else
				//    buf.append("<!-- bad asDoc entry -->");
				//    buf.append("\n</");
            }
        }



		return buf;
	}

    private String getAccessKindFromNS(ObjectValue ns)
    {
        String access_specifier;
        switch( ns.getNamespaceKind() )
        {
            case Context.NS_PUBLIC:
                access_specifier = "public";
                break;
            case Context.NS_INTERNAL:
                access_specifier = "internal";
                break;
            case Context.NS_PROTECTED:
                access_specifier = "protected";
                break;
            case Context.NS_PRIVATE:
                access_specifier = "private";
                break;
            default:
                // should never happen
                access_specifier = "public";
                break;
        }
        return access_specifier;
    }

    // Helper method to print types in a way asdoc wants.
    // This is mostly for Vectors, which need to print as Vector$basetype.
    public static String getRefName(Context cx, ReferenceValue ref)
    {
        Slot s = ref.getSlot(cx, GET_TOKEN);
        if( s == null || s.getDebugName().length() == 0 )
        {
            String name = ref.name;
            if( ref.type_params != null && s != null && s.getValue() instanceof TypeValue)
            {
                // Vector
                TypeValue t = (TypeValue)s.getValue();
                name += getIndexedTypeName(cx, t.indexed_type);
            }
            return name;
        }
        else
        {
            return s.getDebugName();
        }
    }
    private static String getIndexedTypeName(Context cx, TypeValue t)
    {
        ParameterizedName pn = t.name instanceof ParameterizedName ? (ParameterizedName)t.name : null;
        String name = "$";
        if( pn != null )
        {
            name += t.name.name;
            if( t.indexed_type != null )
            {
                name += getIndexedTypeName(cx, t.indexed_type);
            }
        }
        else
        {
            name += t;
        }
        return name;
    }

    public static String escapeXml(String s)
    {
        StringBuilder out = new StringBuilder(s.length() + 16);
        int length = s.length();
        for(int i = 0; i < length; i++)
        {
            char c = s.charAt(i);
            switch (c)
            {
                case '<':
                    out.append("&lt;");
                    break;
                case '>':
                    out.append("&gt;");
                    break;
                case '&':
                    out.append("&amp;");
                    break;
                case '"':
                    out.append("&quot;");
                    break;
                case '\'':
                    out.append("&apos;");
                    break;
                default:
                    out.append(c);
                    break;
            } // end switch
        } // end for

        return out.toString();
    }

	public int count()
	{
	 	return getValues().length;
	}

	public final String toString()
	{
		return "DocComment";
	}
}
