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

package flex2.compiler.mxml.rep;

import flex2.compiler.SymbolTable;
import flex2.compiler.as3.AbstractSyntaxTreeUtil;
import flex2.compiler.as3.binding.Watcher;
import flex2.compiler.mxml.builder.AbstractBuilder;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.reflect.Property;
import flex2.compiler.mxml.reflect.Style;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.util.NameFormatter;
import macromedia.asc.parser.*;
import macromedia.asc.util.Context;
import macromedia.asc.util.IntegerPool;
import java.util.*;

/**
 * A BindingExpression is used to store binding expressions (surprise!) when we come
 * across them while parsing MXML.  As we go, we fill in the destination of each
 * BindingExpression, and when we're done parsing we compile the source expression
 * in order to figure out how to attach ActionScript watchers and binding objects.
 *
 * @author gdaniels
 * @author mchotin
 * @author preilly
 */
public class BindingExpression implements Comparable<BindingExpression>
{
    /** The source expression for this binding */
    private String sourceExpression;
    /** The destination Model of this binding */
    private Model destination;
    /** The destination property within the Model (numeric for Arrays) */
    private String destinationProperty;
    /** The destination style */
    private String destinationStyle;
    /** If destinationProperty is an array index, this is true.  Controlled by
     * calling setDestinationProperty(int).
     */
    private boolean arrayAccess = false;
    /**
     * The lvalue is the expression that can be used for the left side of the destination expression.
     * For destinationLiteral = false, destinationLValue == destinationProperty,
     * for destinationLiteral = true, destinationLValue is XML AS code while destinationProperty is dotted expression
     */
    private String destinationLValue;
    /**
     * The id of the binding expression, used for variable name. 
     */
    private int id;
    /** Is this an XML attribute? */
    private boolean isDestinationXMLAttribute;
    /** Is this an XML node value? */
    private boolean isDestinationXMLNode;
    /** Is this XMLnode an E4X assignment? */
    private boolean isDestinationE4X;
    /** Is the destination a Model? */
    private boolean isDestinationObjectProxy;
    /**
     * Used to signal that the destination must be parsed.
     */
    private boolean isFromBindingNode;
    /**
     * Used to signal that a 2nd binding expression with source and
     * destinations reversed needs to be generated right before the
     * two-way bindings are resolved and that isTwoWayPrimary should
     * be set on the runtime Binding object.
     */
    private boolean isTwoWayPrimary;
    /** The line number where this binding expression was set up*/
    public int xmlLineNumber;

    private MxmlDocument mxmlDocument;

    private BindingExpression twoWayCounterpart;

	// namespace-aware e4x expressions need namespaces
	private Map<Integer, String> namespaces;

    private String sourceAsProperty;

	public BindingExpression(String bindingExpression, int xmlLineNumber, MxmlDocument mxmlDocument)
    {
        this.sourceExpression = bindingExpression;
		this.xmlLineNumber = xmlLineNumber;

		assert mxmlDocument != null;
		setMxmlDocument(mxmlDocument);
    }

    public int compareTo(BindingExpression bindingExpression)
    {
        int result = 0;

        if (id < bindingExpression.id)
        {
            result = -1;
        }
        else if (id > bindingExpression.id)
        {
            result = 1;
        }

        return result;
    }

    private void ensureHighestLevelModelDeclared(Model model)
    {
        if (!((model instanceof XML) ||
              (model instanceof AnonymousObjectGraph) ||
              model.equals(mxmlDocument.getRoot())) &&
            (model.getId() != null))
        {
            // This object needs to have an id at runtime, so instruct
            // SWCBuilder to emit one.
            mxmlDocument.ensureDeclaration(model);
        }
    }

    public boolean equals(Object object)
    {
        boolean result = false;

        if (object instanceof BindingExpression)
        {
            BindingExpression bindingExpression = (BindingExpression) object;

            if (bindingExpression.id == id)
            {
                result = true;
            }
        }

        return result;
    }

	public void setMxmlDocument(MxmlDocument mxmlDocument)
	{
		this.mxmlDocument = mxmlDocument;
		mxmlDocument.addBindingExpression(this);
	}

    public boolean isDestinationXMLAttribute()
    {
        return isDestinationXMLAttribute;
    }

    public boolean isDestinationXMLNode()
    {
        return isDestinationXMLNode;
    }

    public boolean isDestinationE4X()
    {
        return isDestinationE4X;
    }

    public boolean isDestinationObjectProxy()
    {
        return isDestinationObjectProxy;
    }

    public String getSourceAsProperty()
    {
        return sourceAsProperty;
    }

    public boolean isDestinationNonPublicProperty()
    {
    	// We currently assume our destination is publicly accessible, and only 
    	// validate the simple property case.
    	boolean result = false;
    	
    	if ((destination != null) && (destinationProperty != null && destinationStyle == null) &&
            !isArrayAccess() && !((isDestinationXMLAttribute || isDestinationXMLNode)))
    	{
    		Type type = destination.getType();
    		Property property = type.getProperty(destinationProperty);
    		
    		if (property != null && !property.hasPublic())
    			result = true;
    	}
    	
    	return result;
    }
    
    public boolean isSourcePublicProperty()
    {
        String potentialProperty;
        
        if (sourceExpression.startsWith("(") && sourceExpression.endsWith(")"))
        {
            potentialProperty = sourceExpression.substring(1, sourceExpression.length() - 1);
        }
        else
        {
            potentialProperty = sourceExpression;
        }

        Type skeletonClass = mxmlDocument.getSkeletonClass();

        boolean result = false;

        if (potentialProperty.indexOf(":") == -1)
        {
            Property property = skeletonClass.getProperty(SymbolTable.publicNamespace, potentialProperty);

            // It looks like we are checking for "public" twice, but
            // the above call also returns properties in the unnamed
            // package, because they are both equivalent to an empty
            // string.
            if ((property != null) && property.hasPublic())
            {
                result = true;
                sourceAsProperty = potentialProperty;

                if (mxmlDocument.showDeprecationWarnings())
                {
                    AbstractBuilder.checkDeprecation(property, mxmlDocument.getSourcePath(), xmlLineNumber);
                }
            }
        }

        return result;
    }

    private static final String NODE_VALUE = "nodeValue".intern();

    public MemberExpressionNode generateDestinationAssignment(NodeFactory nodeFactory, String rvalue)
    {
        Node base = null;

        if (!((isDestinationXMLAttribute || isDestinationXMLNode)))
        {
            base = generateDestinationPathRoot(nodeFactory, false);
        }

        IdentifierNode identifier = null;

        if (destinationLValue != null)
        {
            identifier = nodeFactory.identifier(destinationLValue);
        }
        else if (destinationProperty != null)
        {
            identifier = nodeFactory.identifier(destinationProperty);
        }
        else if (destinationStyle != null)
        {
            identifier = nodeFactory.identifier(destinationStyle);
        }

        assert identifier != null;

        if (isDestinationXMLNode && !isDestinationE4X)
        {
            //buffer.append(".nodeValue");
            GetExpressionNode getExpression = nodeFactory.getExpression(identifier);
            base = nodeFactory.memberExpression(base, getExpression);
            identifier = nodeFactory.identifier(NODE_VALUE, false);
        }

        MemberExpressionNode memberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, rvalue, true);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, memberExpression);
        SetExpressionNode selector = nodeFactory.setExpression(identifier, argumentList, false);

        if ((destination != null) &&
            (destinationProperty != null || destinationStyle != null) &&
            !isArrayAccess() &&
            !((isDestinationXMLAttribute || isDestinationXMLNode)))
        {
            selector.setMode(Tokens.DOT_TOKEN);
        }
        else if (isArrayAccess())
        {
            selector.setMode(Tokens.LEFTBRACKET_TOKEN);
        }

        return nodeFactory.memberExpression(base, selector);
    }

    private static final String SET_STYLE = "setStyle".intern();
    private static final String _SOURCE_FUNCTION_RETURN_VALUE = "_sourceFunctionReturnValue".intern();

    public MemberExpressionNode generateDestinationSetStyle(NodeFactory nodeFactory, String rvalue)
    {
        Node base = null;

        if (!((isDestinationXMLAttribute || isDestinationXMLNode)))
        {
            base = generateDestinationPathRoot(nodeFactory, false);
        }

        IdentifierNode identifier = nodeFactory.identifier(SET_STYLE, false);
        LiteralStringNode literalString = nodeFactory.literalString(destinationStyle);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, literalString);
        MemberExpressionNode memberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, _SOURCE_FUNCTION_RETURN_VALUE, false);
        argumentList = nodeFactory.argumentList(argumentList, memberExpression);
        CallExpressionNode selector = (CallExpressionNode) nodeFactory.callExpression(identifier,
                                                                                      argumentList);
        selector.setRValue(false);

        return nodeFactory.memberExpression(base, selector);
    }

    /**
     * Sometimes the destination is not a member of the document, so
     * we have to climb the parent tree to find a parent that is.  Here is an example:
     *
     *   <mx:AreaChart>
     *    <mx:horizontalAxis>
     *      <mx:CategoryAxis dataProvider="{expenses}"/>
     *    </mx:horizontalAxis>
     *   </mx:AreaChart>
     *
     * For the above example the destination stack would be
     * ["_AreaChart1", "horizontalAxis"].
     */
    private Stack<Model> generateDestinationStack()
    {
        Stack<Model> destinationStack = new Stack<Model>();
        Model model = destination;

        while (model != null)
        {
            destinationStack.push(model);

            if ((model.getId() == null) || model.getIsAnonymous())
            {
                model = model.getParent();
            }
            else
            {
                break;
            }
        }

        return destinationStack;
    }

    public String getDestinationPath(boolean doXML)
    {
        StringBuilder buffer = new StringBuilder();

        // Always treat E4X as XML so the destinationLValue is used.
        if (isDestinationE4X)
        {
            doXML = true;            
        }
        
        if (!(doXML && (isDestinationXMLAttribute || isDestinationXMLNode)))
        {
            buffer.append( getDestinationPathRoot(false) );
        }

        if ((destination != null) &&
            (destinationProperty != null || destinationStyle != null) &&
            !isArrayAccess() &&
            !(doXML && (isDestinationXMLAttribute || isDestinationXMLNode)))
        {
            buffer.append(".");
        }

        if (isArrayAccess())
        {
            buffer.append("[");
        }

        if ((doXML || (!(isDestinationXMLAttribute || isDestinationXMLNode))) && (destinationLValue != null))
        {
            buffer.append(destinationLValue);
        }
        else if (destinationProperty != null)
        {
            buffer.append(destinationProperty);
        }
        else if (destinationStyle != null)
        {
            buffer.append(destinationStyle);
        }

        if (doXML && isDestinationXMLNode && !isDestinationE4X)
        {
            buffer.append(".nodeValue");
        }
        else if (isArrayAccess())
        {
            buffer.append("]");
        }

        return buffer.toString();
    }

    public String getDestinationPathRoot(boolean doRepeatable)
    {        
        if (destination == null)
        {
            return "";
        }

        StringBuilder destinationRoot = new StringBuilder();

        Stack<Model> destinationStack = generateDestinationStack();

        Model model = destinationStack.peek();
        ensureHighestLevelModelDeclared(model);

        boolean writeRepeaterIndices = doRepeatable;

        while (!destinationStack.isEmpty())
        {
            model = destinationStack.pop();

            if (model.equals(mxmlDocument.getRoot()))
            {
                destinationRoot.append("this");
            }
            else
            {
                String parentIndex = model.getParentIndex();

                if ((parentIndex != null) && (destinationRoot.length() > 0))
                {
                    destinationRoot.append("[");
                    destinationRoot.append(parentIndex);
                    destinationRoot.append("]");
                }
                else
                {
                    String id = model.getId();

                    if (id != null)
                    {
                        if (!model.getIsAnonymous())
                        {
                            mxmlDocument.ensureDeclaration(model);
                        }
                        destinationRoot.append(id);
                    }
                }
            }

            if (writeRepeaterIndices && isRepeatable())
            {
                for (int i = 0; i < model.getRepeaterLevel(); ++i)
                {
                    destinationRoot.append("[instanceIndices[");
                    destinationRoot.append(i);
                    destinationRoot.append("]]");
                }
                writeRepeaterIndices = false;
            }

            if (!destinationStack.isEmpty())
            {
                Model child = destinationStack.peek();
                
                if (child.getParentIndex() == null)
                {
                    destinationRoot.append(".");
                }
            }
        }
        
        return destinationRoot.toString();
    }

    public Node generateDestinationPathRoot(NodeFactory nodeFactory, boolean doRepeatable)
    {
        Node result = null;

        if (destination != null)
        {
            Stack<Model> destinationStack = generateDestinationStack();
            Model model = destinationStack.peek();
            ensureHighestLevelModelDeclared(model);

            boolean writeRepeaterIndices = doRepeatable;

            while (!destinationStack.isEmpty())
            {
                model = destinationStack.pop();

                if (model.equals(mxmlDocument.getRoot()))
                {
                    result = nodeFactory.thisExpression(-1);
                }
                else
                {
                    String parentIndex = model.getParentIndex();

                    if ((parentIndex != null) && (result != null))
                    {
                        //destinationRoot.append("[");
                        //destinationRoot.append(parentIndex);
                        //destinationRoot.append("]");
                        assert false;
                    }
                    else
                    {
                        String id = model.getId();

                        if (id != null)
                        {
                            if (!model.getIsAnonymous())
                            {
                                mxmlDocument.ensureDeclaration(model);
                            }
                            //destinationRoot.append(id);

                            if (result == null)
                            {
                                result = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, id, true);
                            }
                            else
                            {
                                assert false;
                            }
                        }
                    }
                }

                if (writeRepeaterIndices && isRepeatable())
                {
                    for (int i = 0; i < model.getRepeaterLevel(); ++i)
                    {
                        //destinationRoot.append("[instanceIndices[");
                        //destinationRoot.append(i);
                        //destinationRoot.append("]]");
                        assert false;
                    }
                    writeRepeaterIndices = false;
                }

                if (!destinationStack.isEmpty())
                {
                    Model child = destinationStack.peek();
                
                    if (child.getParentIndex() == null)
                    {
                        //destinationRoot.append(".");
                        assert false;
                    }
                }
            }
        }

        return result;
    }

    /**
     * Returns the type name of the destination.  This is used when
     * code generating the binding source and destination functions.
     * It's also used when code generating the document's imports.
     */
    public String getDestinationTypeName()
    {
        Type type = null;

        if ((destination != null) &&
            !(destination instanceof AnonymousObjectGraph) &&
            !(destination instanceof XML))
        {
            if (destinationProperty != null)
            {
                Type destinationType = destination.getType();

                if (!destinationType.getName().equals(mxmlDocument.getStandardDefs().CLASS_OBJECTPROXY))
                {
                    Property property = destinationType.getProperty(destinationProperty);

                    if (property != null)
                    {
                        type = property.getType();
                    }
                }
            }
            else if (destinationStyle != null)
            {
                Type destinationType = destination.getType();
                Style style = destinationType.getStyle(destinationStyle);

                if (style != null)
                {
                    type = style.getType();
                }
            }
            else
            {
                type = destination.getType();
            }
        }

        String result = SymbolTable.NOTYPE;

        if (type != null)
        {
            result = NameFormatter.toDot(type.getName());
        }

        return result;
    }

    public int getId()
    {
        return id;
    }

    public String getRepeatableSourceExpression()
    {
        String repeatableSourceExpression = sourceExpression;
        List repeaterParents = destination.getRepeaterParents();
        Iterator iterator = repeaterParents.iterator();

        while ( iterator.hasNext() )
        {
            Model repeater = (Model) iterator.next();
            int repeaterLevel = repeater.getRepeaterLevel();
            StringBuilder buffer = new StringBuilder();
            int i;

            for (i = 0; i < repeaterLevel; i++)
            {
                buffer.append("[instanceIndices[");
                buffer.append(i);
                buffer.append("]]");
            }

            buffer.append(".mx_internal::getItemAt(repeaterIndices[");
            buffer.append(i);
            buffer.append("])");

            repeatableSourceExpression = repeatableSourceExpression.replaceAll(repeater.getId() + "\\.currentItem",
                                                                               repeater.getId() + buffer.toString());

            repeatableSourceExpression = repeatableSourceExpression.replaceAll(repeater.getId() + "\\.currentIndex",
                                                                               "repeaterIndices[" + i + "]");
        }

        return repeatableSourceExpression;
    }

    public String getSourceExpression()
    {
        return sourceExpression;
    }

    public void setDestinationProperty(String destinationProperty)
    {
        this.destinationProperty = destinationProperty;
    }

    public void setDestinationProperty(int destinationProperty)
    {
        this.destinationProperty = Integer.toString(destinationProperty);
        arrayAccess = true;
    }

    public void setDestinationStyle(String destinationStyle)
    {
        this.destinationStyle = destinationStyle;
    }

    public String getDestinationStyle()
    {
        return destinationStyle;
    }

    public boolean isSimpleChain()
    {
        return (!isFromBindingNode() &&
                !isStyle() &&
                !isDestinationObjectProxy() &&
                getNamespaceDeclarations().equals("") &&
                (twoWayCounterpart == null) &&
                (getDestinationPath(false).indexOf("[") == -1));
    }

    public boolean isStyle()
    {
        return destinationStyle != null;
    }

    public void setId(int id)
    {
        this.id = id;
    }

    public void setDestinationXMLAttribute(boolean isDestinationXMLAttribute)
    {
        this.isDestinationXMLAttribute = isDestinationXMLAttribute;
    }

    public void setDestinationXMLNode(boolean isDestinationXMLNode)
    {
        this.isDestinationXMLNode = isDestinationXMLNode;
    }

    public void setDestinationE4X(boolean isDestinationE4X)
    {
        this.isDestinationE4X = isDestinationE4X;
    }

    public void setDestinationObjectProxy(boolean isDestinationObjectProxy)
    {
        this.isDestinationObjectProxy = isDestinationObjectProxy;
    }

    public String getDestinationProperty()
    {
        return destinationProperty;
    }

    public boolean isArrayAccess()
    {
        return arrayAccess;
    }

    public String getDestinationLValue()
    {
        return destinationLValue;
    }

    public void setDestinationLValue(String lvalue)
    {
        destinationLValue = lvalue;
    }

    public Model getDestination()
    {
        return destination;
    }

    public void setDestination(Model destination)
    {
        this.destination = destination;
        if (this.xmlLineNumber == 0)
        {
	        // C: The destination xml line number may not be as accurate as the binding expression's original number...
	        this.xmlLineNumber = destination.getXmlLineNumber();
        }
    }

    public boolean isRepeatable()
    {
        return ((destination != null) && (destination.getRepeaterLevel() > 0));
    }

    public int getRepeaterLevel(String var)
    {
        if (var.indexOf("[repeaterIndices") > -1)
        {
            var = var.substring(0, var.indexOf("["));
        }
        
        int repeaterLevel = -1;

        if (destination != null)
        {
            List repeaters = destination.getRepeaterParents();

            repeaterLevel = repeaters.size() - 1;

            for (; repeaterLevel >= 0; --repeaterLevel)
            {
                Model r = (Model) repeaters.get(repeaterLevel);
                if (var.equals(r.getId()))
                {
                    break;
                }
            }
        }

        return repeaterLevel;
    }

    public String getRepeaterId(int level)
    {
        Model repeater = (Model) destination.getRepeaterParents().get(level);
        return repeater.getId();
    }

    public BindingExpression getTwoWayCounterpart()
    {
        return twoWayCounterpart;
    }

    public void setTwoWayCounterpart(BindingExpression twoWayCounterpart)
    {
        this.twoWayCounterpart = twoWayCounterpart;
    }

	/**
	 *
	 */
	public int getXmlLineNumber()
	{
		return xmlLineNumber;
	}

	public void addNamespace(String nsUri, int i)
	{
		if (namespaces == null)
		{
			namespaces = new HashMap<Integer, String>();
		}
		namespaces.put(IntegerPool.getNumber(i), nsUri);
	}
	
	public Map<Integer, String> getNamespaces()
	{
	    return namespaces;
	}

    /**
     * Combine the namespaces from all of the binding expressions.  Use the 	 
     * Integer for the key, since it is unique across all the binding expressions. 	 
     * @param bindingExpressions 	 
     * @return 	 
     */ 	 
    public static String getAllBindingNamespaceDeclarations(List<BindingExpression> bindingExpressions) 	 
    { 	 
        Map<Integer, String> allNs = new HashMap<Integer, String>(); 	 
	  	 
        // Combine all the namespaces using the Integer as the unique key. 	 
        for (BindingExpression be : bindingExpressions) 	 
        { 	 
            allNs.putAll(be.getNamespaces()); 	 
        } 	 
	  	 
        return getNamespaceDeclarations(allNs); 	 
    }

	/**
	 * Build the AS var Namespace declarations for the namespaces in the map.
	 * @param namespaceMap
	 * @return
	 */
    public static String getNamespaceDeclarations(Map<Integer, String> namespaceMap)
    {
        if (namespaceMap != null)
        {
            StringBuilder b = new StringBuilder();
            for (Integer key : namespaceMap.keySet())
            {
                int k = key.intValue();
                String uri = namespaceMap.get(key);
                b.append("var ns").append(k).append(":Namespace = new Namespace(\"").append(uri).append("\");\n");
            }
            return b.toString();
        }
        
        return "";
    }
	
	public String getNamespaceDeclarations()
	{
	    return getNamespaceDeclarations(namespaces);
	}

    // intern all identifier constants
    private static final String NAMESPACE = "Namespace".intern();

    public StatementListNode generateNamespaceDeclarations(Context context, StatementListNode statementList)
    {
        return generateNamespaceDeclarations(namespaces, context, statementList);
    }

    public static StatementListNode generateNamespaceDeclarations(
            Map<Integer, String> map, Context context,
            StatementListNode statementList)
    {
        StatementListNode result = statementList;

        if (map != null)
        {
            NodeFactory nodeFactory = context.getNodeFactory();

            for (Integer key : map.keySet())
            {
                String uri = map.get(key);
                IdentifierNode identifier = nodeFactory.identifier(NAMESPACE, false);
                LiteralStringNode literalString = nodeFactory.literalString(uri);
                ArgumentListNode argumentList = nodeFactory.argumentList(null, literalString);
                CallExpressionNode callExpression = (CallExpressionNode)nodeFactory.callExpression(identifier, argumentList);
                callExpression.is_new = true;
                callExpression.setRValue(false);
                MemberExpressionNode initializer = nodeFactory.memberExpression(null, callExpression);
                int k = key.intValue();
                VariableDefinitionNode variableDefinition = AbstractSyntaxTreeUtil.generateVariable(nodeFactory, ("ns" + k).intern(), NAMESPACE, false, initializer);
                result = nodeFactory.statementList(result, variableDefinition);
            }
        }

        return result;
    }

    public boolean isFromBindingNode()
    {
        return isFromBindingNode;
    }

    public void setFromBindingNode(boolean isFromBindingNode)
    {
        this.isFromBindingNode = isFromBindingNode;
    }

    public boolean isTwoWayPrimary()
    {
        return isTwoWayPrimary;
    }

    public void setTwoWayPrimary(boolean isTwoWayPrimary)
    {
        this.isTwoWayPrimary = isTwoWayPrimary;
    }
}
