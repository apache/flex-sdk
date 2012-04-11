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

package flex2.compiler.as3.reflect;

import flex2.compiler.SymbolTable;
import flex2.compiler.CompilationUnit;
import flex2.compiler.util.QName;
import flex2.compiler.util.LineNumberMap;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.compiler.util.CompilerMessage;
import macromedia.asc.parser.*;
import macromedia.asc.parser.MetaDataEvaluator.KeyValuePair;
import macromedia.asc.parser.MetaDataEvaluator.KeylessValue;
import macromedia.asc.semantics.ObjectValue;
import macromedia.asc.semantics.Value;
import macromedia.asc.util.Context;
import macromedia.asc.util.Multinames;
import macromedia.asc.util.Namespaces;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.LinkedList;
import java.util.TreeSet;
import java.util.Map.Entry;
import java.util.Set;
import java.util.StringTokenizer;

/**
 * An early attempt to gradually move unencapsulated ASC node
 * knowledge into one spot.  This effort was dropped as ASC
 * integration became widespread with features like direct AST
 * generation.
 *
 * NOTE Where possible, these methods delegate to static methods in
 * the reflection classes, but because databinding needs to work on
 * nodes that have gone through nothing but a parse, whereas the
 * reflection classes expect more (complete?) processing, these
 * methods sometimes get nodes in an earlier state than the reflection
 * methods expect.  Again, these differences in node state should
 * ideally be made systematic in an ASC API.
 *
 * @author Basil Hosmer
 * @author Clement Wong
 * @author Paul Reilly
 */
public class NodeMagic
{
    public static final String CONST        = "const";
    public static final String DYNAMIC      = "dynamic";
    public static final String FINAL        = "final";
    public static final String INTERNAL     = "internal";
    public static final String INTRINSIC    = "intrinsic";
    public static final String NATIVE       = "native";
    public static final String OVERRIDE     = "override";
    public static final String PRIVATE      = "private";
    public static final String PROTECTED    = "protected";
    public static final String PROTOTYPE    = "prototype";
    public static final String PUBLIC       = "public";
    public static final String STATIC       = "static";
    public static final String VIRTUAL      = "virtual";

    /**
     * This only returns the _first_ variable if there happens to be a variable definition list.
     */
    public static String getVariableName(VariableDefinitionNode node)
    {
        return getVariableBinding(node).variable.identifier.name;
    }

    /**
     * This only returns the _first_ variable if there happens to be a variable definition list.
     */
    public static VariableBindingNode getVariableBinding(VariableDefinitionNode node)
    {
        return (VariableBindingNode) node.list.items.get(0);
    }

    /**
     *
     */
    public static void setVariableBindingName(VariableBindingNode node, String name)
    {
        node.variable.identifier.name = name.intern();
    }

    /**
     * This only returns the typename of the _first_ variable if there happens to be a variable definition list.
     */
    public static String getVariableTypeName(VariableDefinitionNode node)
    {
        // C: flex2.compiler.as3.reflect.Variable has a different way to obtain the type name. I'm not suggesting
        //    that that one is more correct. I believe this should be centralized...
        //Jono: That one is good only if ReferenceValues have been filled in already; this one
        //      is good when you only have the syntax tree
        return getVariableTypeName(getVariableBinding(node));
    }
    
    public static String getVariableTypeName(VariableBindingNode node)
    {
        // C: flex2.compiler.as3.reflect.Variable has a different way to obtain the type name. I'm not suggesting
        //    that that one is more correct. I believe this should be centralized...
        //Jono: That one is good only if ReferenceValues have been filled in already; this one
        //      is good when you only have the syntax tree
    	MemberExpressionNode memberExpression;
    	if (node.variable.type instanceof TypeExpressionNode)
    	{
    		TypeExpressionNode typeExpression = (TypeExpressionNode) node.variable.type;
    		memberExpression = (MemberExpressionNode) typeExpression.expr;
    	}
    	else // if (node.variable.type instanceof MemberExpressionNode)
    	{
            memberExpression = (MemberExpressionNode) node.variable.type;
    	}
        return getTypeName(memberExpression);
    }

    /**
     *
     */
    private static String typeNameFromSelector(GetExpressionNode getExpression)
    {
        return typeNameFromIdentifier((IdentifierNode) getExpression.expr);
    }

    /**
     *
     */
    private static String typeNameFromIdentifier(IdentifierNode identifier)
    {
        String result = identifier.name;

        if (identifier instanceof QualifiedIdentifierNode)
        {
            QualifiedIdentifierNode qualifiedIdentifier = (QualifiedIdentifierNode) identifier;
            if ((qualifiedIdentifier.qualifier != null) &&
                (qualifiedIdentifier.qualifier instanceof LiteralStringNode))
            {
                LiteralStringNode literalString = (LiteralStringNode) qualifiedIdentifier.qualifier;

                if ((literalString.value != null) && (literalString.value.length() > 0))
                {
                    result = literalString.value + "." + qualifiedIdentifier.name;
                }
                else
                {
                    assert false : "Empty LiteralStringNode";
                }
            }
            else
            {
                assert false : "Empty QualifiedIdentifierNode";
            }
        }

        return result;
    }

    private static void addIdentifier(List<String> list, IdentifierNode identifier)
    {
        if (identifier.name.equals(OVERRIDE))
        {
            // we want to put this one first as a matter of coding conventions
            list.add(0, OVERRIDE);
        }
        else
        {
            // we want to put this one first as a matter of coding conventions
            list.add(identifier.name);
        }
    }

    /**
     *
     */
    public static void addImport(Context context, ClassDefinitionNode node, String packageName)
    {
        NodeFactory nodeFactory = new NodeFactory(context);

        PackageIdentifiersNode packageIdentifiers = null;

        StringTokenizer stringTokenizer = new StringTokenizer(packageName, ".");

        while ( stringTokenizer.hasMoreTokens() )
        {
            String token = stringTokenizer.nextToken();

            IdentifierNode identifier = nodeFactory.identifier(token);

            packageIdentifiers = nodeFactory.packageIdentifiers(packageIdentifiers, identifier, true);
        }

        PackageNameNode packageNameNode = nodeFactory.packageName(packageIdentifiers);

        ImportDirectiveNode importDirective = nodeFactory.importDirective(null, packageNameNode, null, context);

        importDirective.pkgdef = node.pkgdef;

        if (node.statements == null)
        {
            node.statements = new StatementListNode(null);
        }

        node.statements.items.add(0, importDirective);
    }

    private static void checkForIdentifier(List<String> list, Object attrsNode)
    {
        if (attrsNode instanceof MemberExpressionNode)
        {
            MemberExpressionNode memberExpression = (MemberExpressionNode) attrsNode;

            if (memberExpression.selector instanceof GetExpressionNode)
            {
                GetExpressionNode getExpression = (GetExpressionNode) memberExpression.selector;

                if (getExpression.expr instanceof IdentifierNode)
                {
                    addIdentifier(list, (IdentifierNode) getExpression.expr);
                }
            }
        }
        else if (attrsNode instanceof LiteralStringNode)
        {
            LiteralStringNode literalString = (LiteralStringNode) attrsNode;
            list.add(literalString.value);
        }
        else if (attrsNode instanceof IdentifierNode)
        {
            addIdentifier(list, (IdentifierNode) attrsNode);
        }
        else
        {
            assert false : "Unexpected attribute node: " + attrsNode.getClass().getName();
        }
    }

    /**
     * TODO: many of these methods seem to take pains to leave the world of
     * nodes... this is returning a list of MetaDataNodes.  Need confirmation
     * that this is ok.  Delete comment if so.  :-)  Thanks!  -rg
     */
    public static List<Node> getMetaData(DefinitionNode definition)
    {
        LinkedList<Node> list = new LinkedList<Node>();
        if ((definition.metaData != null) && (definition.metaData.items != null))
            list.addAll( definition.metaData.items );

        return list;
    }
    
    /**
     * Returns a sorted (canonical) MetaData parameter list.
     * 
     * Don't change this method without considering its use in SignatureEvaluator.java
     */
    public static String getSortedMetaDataParamString(MetaDataNode node)
    {
        final Set<Value> params = new TreeSet<Value>(metaDataValueComparator);
        final StringBuilder parameters = new StringBuilder(32);
        
        if(node.getValues() != null)
        {
            for (int i = 0, length = node.getValues().length; i < length; i++)
            {
                params.add(node.getValues()[i]);
            }
            
            final Iterator<Value> iter = params.iterator();
            parameters.append('(');
            while (iter.hasNext())
            {
                final Object v = iter.next();

                if (v instanceof KeyValuePair)
                {
                    final KeyValuePair pair = (KeyValuePair)v;
                    parameters.append(pair.key)
                              .append("=\"")
                              .append(pair.obj)
                              .append('"');
                }
                else
                {
                    assert (v instanceof KeylessValue);
                    parameters.append('"')
                          .append(((KeylessValue)v).obj)
                          .append('"');
                }
                
                if(iter.hasNext())
                {
                    parameters.append(",");
                }
            }
            parameters.append(')');
        }
                
        return parameters.toString();
    }
    
    /**
     * helper class for getSortedMetaDataParamString()
     */
    private static class MetaDataValueComparator implements Comparator<Value>
    {
        private static String getKey(Value v)
        {
            return ((v instanceof KeyValuePair)
                        ? ((KeyValuePair)v).key
                        : ((KeylessValue)v).obj);
        }
        
        public int compare(Value o1, Value o2)
        {
            return getKey(o1).compareTo(getKey(o2));
        }
    }
    private static MetaDataValueComparator metaDataValueComparator = new MetaDataValueComparator();

    /**
     *
     */
    public static List<String> getAttributes(DefinitionNode definition)
    {
        return getAttributes(definition.attrs);
    }
    
    /**
    *
    */
   // TODO This is REALLY inefficient, why not at least returned a sorted or hashed list
   public static List<String> getAttributes(AttributeListNode node)
   {
       ArrayList<String> result = new ArrayList<String>();
       if (node != null)
       {
           Iterator attrsIterator = node.items.iterator();

           while ( attrsIterator.hasNext() )
           {
               Object attrsNode = attrsIterator.next();

               if (attrsNode instanceof ListNode)
               {
                   Iterator listIterator = ((ListNode) attrsNode).items.iterator();

                   while ( listIterator.hasNext() )
                   {
                       Object listNode = listIterator.next();
                       checkForIdentifier(result, listNode);
                   }
               }
               else
               {
                   checkForIdentifier(result, attrsNode);
               }
           }
       }

       return result;
   }
   
    /**
     * Returns a sorted (canonical) attribute/namespace list.
     * 
     * Warning: This does return CONST/VAR -- those are typically found in *Node.kind
     * if the attribute is possible. 
     *          
     * Don't change this method without considering its use in SignatureEvaluator.java
     */
    public static String getSortedAttributeString(AttributeListNode node, String delimiter)
    {
        return setToString(getSortedAttributes(node), delimiter);
    }
    
    /**
     * returns TreeSet<String>
     */
    public static TreeSet<String> getSortedAttributes(AttributeListNode node)
    {
        final TreeSet<String> attrs = new TreeSet<String>();
        
        final Iterator<String> iter = getAttributes(node).iterator();
        while (iter.hasNext())
            attrs.add(iter.next().toString());

        return attrs;
    }
    
    public static String setToString(Set<String> set, String delimiter)
    {
        final StringBuilder attributes = new StringBuilder(32);
        
        final Iterator<String> iter = set.iterator();
        while (iter.hasNext())
        {
            attributes.append(iter.next());
            if(iter.hasNext())
                attributes.append(delimiter);
        }
        
        return attributes.toString();
    }


    public static Set<String> getImports(Multinames multiNames)
    {
        Set<String> result = new HashSet<String>();
        Iterator iterator = multiNames.entrySet().iterator();

        while ( iterator.hasNext() )
        {
            Entry entry = (Entry) iterator.next();
            String className = (String) entry.getKey();
            Namespaces namespaces = (Namespaces) entry.getValue();

            if (namespaces.isEmpty())
            {
                result.add(className);
            }
            else
            {
                Iterator namespaceIterator = namespaces.iterator();

                while ( namespaceIterator.hasNext() )
                {
                    ObjectValue objectValue = (ObjectValue) namespaceIterator.next();
                    String packageName = objectValue.toString();
                    if (packageName.length() > 0)
                    {
                        result.add(packageName + "." + className);
                    }
                    else
                    {
                        result.add(className);
                    }
                }
            }
        }

        return result;
    }
    
    
    /**
     * Returns the import name as it appeared in source code:
     * E.g.: "Foo.Bar.*" if the source code was "import Foo.Bar.*"
     * 
     * Don't change this method without considering its use in SignatureEvaluator.java
     */
    public static String getDottedImportName(ImportDirectiveNode node)
    {
        final StringBuilder buf = new StringBuilder();
        if (node.name != null && node.name.id.list != null)
        {
            for(final Iterator iter = node.name.id.list.iterator(); iter.hasNext(); )
            {
                buf.append(((IdentifierNode)iter.next()).toIdentifierString());
                if (iter.hasNext())
                    buf.append('.');
            }
        }
        return buf.toString();
    }


    public static QName getQName(QualifiedIdentifierNode qualifiedIdentifier)
    {
        String namespaceURI = null;

        if (qualifiedIdentifier.qualifier instanceof MemberExpressionNode)
        {
            MemberExpressionNode memberExpression = (MemberExpressionNode) qualifiedIdentifier.qualifier;

            if (memberExpression.selector instanceof GetExpressionNode)
            {
                GetExpressionNode getExpression = (GetExpressionNode) memberExpression.selector;

                if (getExpression.expr instanceof IdentifierNode)
                {
                    namespaceURI = ((IdentifierNode) getExpression.expr).name;
                }
            }
        }

        return new QName(namespaceURI, qualifiedIdentifier.name);
    }

    /**
     *
     */
    public static String getUserNamespace(DefinitionNode definition)
    {
        String result = QName.DEFAULT_NAMESPACE;
        final Iterator<String> iterator = getAttributes(definition.attrs).iterator();

        while ( iterator.hasNext() )
        {
            String attribute = iterator.next();

            if (!(attribute.equals(CONST) ||
                  attribute.equals(DYNAMIC) ||
                  attribute.equals(FINAL) ||
                  attribute.equals(INTERNAL) ||
                  attribute.equals(INTRINSIC) ||
                  attribute.equals(NATIVE) ||
                  attribute.equals(OVERRIDE) ||
                  attribute.equals(PRIVATE) ||
                  attribute.equals(PROTECTED) ||
                  attribute.equals(PROTOTYPE) ||
                  attribute.equals(PUBLIC) ||
                  attribute.equals(STATIC) ||
                  attribute.equals(VIRTUAL)))
            {
                result = attribute;
                break;
            }
        }

        return result;
    }

    /**
     *
     */
    public static boolean functionIsGetter(FunctionDefinitionNode node)
    {
        return node.name.kind == Tokens.GET_TOKEN;
    }

    /**
     *
     */
    public static boolean functionIsSetter(FunctionDefinitionNode node)
    {
        return node.name.kind == Tokens.SET_TOKEN;
    }

    /**
     *
     */
    public static String getFunctionTypeName(FunctionDefinitionNode node)
    {
    	MemberExpressionNode memberExpr;
    	if (node.fexpr.signature.result instanceof TypeExpressionNode)
    	{
    		memberExpr = (MemberExpressionNode) ((TypeExpressionNode) node.fexpr.signature.result).expr;
    	}
    	else
    	{
    		memberExpr = (MemberExpressionNode) node.fexpr.signature.result;
    	}
        return getTypeName( memberExpr );
    }

    /**
     *
     */
    public static int getFunctionParamCount(FunctionDefinitionNode function)
    {
        ParameterListNode params = function.fexpr.signature.parameter;
        return params != null ? params.items.size() : 0;
    }

    /**
     * @param pnum 0-based index of desired param
     * @return param type name in dotted form. Note: returns SymbolTable.NOTYPE when pnum > arg count; test against
     * getFunctionParamCount() to differentiate from actual *-typed params.
     */
    public static String getFunctionParamTypeName(FunctionDefinitionNode function, int pnum)
    {
        ParameterListNode params = function.fexpr.signature.parameter;

        if (params == null || pnum >= params.size())
        {
            //	out of range - see javadoc
            return SymbolTable.NOTYPE;
        }
        else
        {
            ParameterNode param = params.items.get(pnum);
            assert param != null : "functionDefinitionNode.params contains null entry at " + pnum;
            MemberExpressionNode memberExpr;
            if (param.type instanceof TypeExpressionNode)
            {
            	memberExpr = (MemberExpressionNode) ((TypeExpressionNode) param.type).expr;
            }
            else
            {
            	memberExpr = (MemberExpressionNode) param.type;
            }
            return getTypeName( memberExpr );
        }
    }
    
    /**
     * TODO can we cut over to Method.functionName (uses fexpr)? is there ever a difference?
     */
    public static String getFunctionName(FunctionDefinitionNode functionDefinition)
    {
        String result = null;

        if ((functionDefinition.name != null) &&
            (functionDefinition.name.identifier != null) &&
            (functionDefinition.name.identifier.name != null))
        {
            result = functionDefinition.name.identifier.name;
        }

        return result;
    }

    /**
     * TODO need to set both? appears so.
     * TODO when if ever will intermediates be null?
     */
    public static void prefixFunctionName(FunctionDefinitionNode node, String prefix)
    {
        if ((node.name != null) &&
            (node.name.identifier != null) &&
            (node.name.identifier.name != null))
        {
            node.name.identifier.name = (prefix + node.name.identifier.name).intern();
        }

        if ((node.fexpr != null) &&
            (node.fexpr.internal_name != null))
        {
            node.fexpr.internal_name = prefix + node.fexpr.internal_name;
        }
    }

    /**
     *
     */
    public static String getPackageName(ClassDefinitionNode node)
    {
        return getPackageName(node.pkgdef);
    }
    
    public static String getPackageName(PackageDefinitionNode node)
    {
        //TODO when is node.name.url not null???
        // assert (node == null || node.name == null || node.name.url == null);
        
        if ((node != null) && (node.name != null) && (node.name.id != null))
        {
            return node.name.id.toIdentifierString();
        }
        else
        {
            return "";
        }
    }

    public static String getUnqualifiedFunctionName(FunctionDefinitionNode functionDefinitionNode)
    {
        if (functionDefinitionNode.name != null)
        {
            assert functionDefinitionNode.name.identifier != null;
            return functionDefinitionNode.name.identifier.name;
        }
        
        return null;
    }
    
    /**
     *
     */
    public static String getUnqualifiedClassName(ClassDefinitionNode classDefinitionNode)
    {
        return classDefinitionNode.name.name;
    }

    /**
     * returns qualified class name in p.q:c format
     */
    public static String getClassName(ClassDefinitionNode classDefinition)
    {
        if (classDefinition.cframe != null)
        {
            return classDefinition.cframe.name.toString();
        }
        else
        {
            StringBuilder stringBuffer = new StringBuilder(getPackageName(classDefinition));
            if (stringBuffer.length() > 0)
            {
                stringBuffer.append(":");
            }

            stringBuffer.append(getUnqualifiedClassName(classDefinition));

            return stringBuffer.toString();
        }
    }

    public static boolean isClassDefinition(MetaDataNode n)
    {
        return n.def instanceof ClassDefinitionNode;
    }

    public static String retrieveClassName(MetaDataNode n)
    {
        String className = null;

        if (isClassDefinition(n))
        {
            ClassDefinitionNode node = (ClassDefinitionNode) n.def;

            if (node.cframe != null)
            {
                className = node.cframe.name.toString().replace( ':', '.' );
            }
            else
            {
                StringBuilder fullyQualifiedClassName = new StringBuilder();

                fullyQualifiedClassName.append(NodeMagic.getPackageName(node));
                if (fullyQualifiedClassName.length() > 0)
                {
                    fullyQualifiedClassName.append('.');
                }
                fullyQualifiedClassName.append(node.name.name);

                className = fullyQualifiedClassName.toString();
            }
        }

        return className;
    }

    public static String normalizeClassName( String className )
    {
        // Make sure we have the colon version...

        if (className == null)
            return null;

        if (className.indexOf( ':' ) == -1)
        {
            int dot = className.lastIndexOf( '.' );
            if (dot != -1)
            {
                className = className.substring( 0, dot ) + ':' + className.substring( dot + 1 );
            }
        }
        return className;
    }

    /**
     * only allow MetaDataNode in the specified ranges.
     *
     * @param unit
     * @param map
     * @param beginLines
     * @param endLines
     */
    public static void metaDataOnly(CompilationUnit unit, LineNumberMap map, int[] beginLines, int[] endLines)
    {
        ProgramNode node = (ProgramNode) unit.getSyntaxTree();
        Context cx = node.cx;
        StatementListNode stmts = node.statements;
        for (int i = 0, length = stmts.items == null ? 0 : stmts.items.size(); i < length; i++)
        {
            Node n = stmts.items.get(i);
            if (n instanceof DocCommentNode || !(n instanceof MetaDataNode))
            {
                int line = map.get(cx.input.getLnNum(n.pos()));
                for (int j = 0, count = line == 0 ? 0 : beginLines.length; j < count; j++)
                {
                    if (line >= beginLines[j] && line <= endLines[j])
                    {
                    	CompilerMessage m = new OnlyMetadataIsAllowed();
                    	m.setPath(cx.input.origin);
                    	m.setLine(cx.input.getLnNum(n.pos()));
                        ThreadLocalToolkit.log(m);
                        break;
                    }
                }
            }
        }
    }

	public static IdentifierNode getIdentifier(MemberExpressionNode memberExpression)
	{
		IdentifierNode result = null;

		if (memberExpression.selector instanceof GetExpressionNode)
		{
			GetExpressionNode getExpression = (GetExpressionNode) memberExpression.selector;

			if (getExpression.expr instanceof IdentifierNode)
			{
				result = (IdentifierNode)getExpression.expr;
			}
		}

		return result;
	}

    /**
     * This method returns the type name for the MemberExpression in the case where the
     * selector is an instance of GetExpressionNode.  ASC can potentially parse selector's
     * of other types, so we return *, aka NOTYPE, in that case.  ASC will report
     * non-GetExpressionNode selector's as an error downstream.  Here is an example of a
     * non-GetExpressionNode selector:
     *
     *   var foo:Object();
     *
     */
    private static String getTypeName(MemberExpressionNode memberExpression)
    {
        String result = SymbolTable.NOTYPE;

        if (memberExpression != null)
        {
            if (memberExpression.selector instanceof GetExpressionNode)
            {
                result = typeNameFromSelector((GetExpressionNode) memberExpression.selector);
            }
            else if (memberExpression.selector instanceof ApplyTypeExprNode)
            {
                ApplyTypeExprNode applyType = (ApplyTypeExprNode) memberExpression.selector;
                
                if (applyType.expr instanceof IdentifierNode)
                {
                    result = typeNameFromIdentifier((IdentifierNode) applyType.expr);

                    if (applyType.typeArgs != null)
                    {
                        result += ".<";

                        Iterator<Node> iterator = applyType.typeArgs.items.iterator();

                        while (iterator.hasNext())
                        {
                            Node node = iterator.next();

                            if (node instanceof TypeExpressionNode)
                            {
                                TypeExpressionNode typeExpression = (TypeExpressionNode) node;
                                result += getTypeName((MemberExpressionNode) typeExpression.expr);
                            }

                            if (iterator.hasNext())
                            {
                                result += ", ";
                            }
                        }

                        result += ">";
                    }
                }
                else
                {
                    assert false : "Unexpedted ApplyTypeExprNode expr type: " + applyType.expr.getClass().getName();
                }
            }
            else
            {
                assert false : "Unexpedted MemberExpressionNode selector type: " + memberExpression.selector.getClass().getName();
            }
        }

        return result;
    }

	// fixme: this does nearly the same thing as getVariableTypeName.  Consolidate.  One difference is that this
	// always returns a short name.  getVariableTypeName returns the exact name. 
	public static String lookupType(VariableBindingNode variableBinding)
	{
		MemberExpressionNode memberExpression = null;
		
	    if ((variableBinding.variable != null) && (variableBinding.variable.type != null))
	    {
	        if (variableBinding.variable.type instanceof TypeExpressionNode)
	    	{
	        	memberExpression = (MemberExpressionNode) ((TypeExpressionNode) variableBinding.variable.type).expr;
	    	}
	        else if (variableBinding.variable.type instanceof MemberExpressionNode)
	        {
	        	memberExpression = (MemberExpressionNode) variableBinding.variable.type;	        	
	        }
	    }

		String result = null;

		if (memberExpression != null)
	    {
	        if ((memberExpression.selector != null) &&
	            (memberExpression.selector instanceof GetExpressionNode))
	        {
	            GetExpressionNode getExpression = (GetExpressionNode) memberExpression.selector;

	            if (getExpression.getIdentifier() != null)
	            {
	                result = getExpression.getIdentifier().name;
	            }
	        }
	    }

	    return result;
	}

    public static void removeMetaData(DefinitionNode definitionNode, String id)
    {
        StatementListNode metaData = definitionNode.metaData;

        if ((metaData != null) && (metaData.items != null))
        {
            Iterator iterator = metaData.items.iterator();

            while ( iterator.hasNext() )
            {
                MetaDataNode metaDataNode = (MetaDataNode) iterator.next();
                if ((metaDataNode.getId() != null) && metaDataNode.getId().equals(id))
                {
                    iterator.remove();
                }
            }
        }
    }

	// error messages

    public static class OnlyMetadataIsAllowed extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 6872237372429205625L;

        public OnlyMetadataIsAllowed()
        {
            super();
        }
    }
}
