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

package flex2.compiler.mxml.builder;

import flash.util.StringJoiner;
import flex2.compiler.CompilationUnit;
import flex2.compiler.util.CompilerMessage.CompilerError;
import flex2.compiler.mxml.Attribute;
import flex2.compiler.mxml.MXMLNamespaces;
import flex2.compiler.mxml.MxmlConfiguration;
import flex2.compiler.mxml.dom.*;
import flex2.compiler.mxml.gen.TextGen;
import flex2.compiler.mxml.lang.BindingHandler;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.lang.TextParser;
import flex2.compiler.mxml.lang.TypeCompatibility;
import flex2.compiler.mxml.lang.ValueNodeHandler;
import flex2.compiler.mxml.reflect.Assignable;
import flex2.compiler.mxml.reflect.Property;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.reflect.TypeTable;
import flex2.compiler.mxml.rep.*;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.util.MxmlCommentUtil;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.QName;
import flex2.compiler.util.QNameSet;

import java.util.*;

/*
 * TODO the overriding of ComponentBuilder.ComponentChildNodeHandler
 *      callouts is starting to get complicated, due to differences
 *      between processing the root and the children. Should probably
 *      bite the bullet and create a DocumentChildNodeHandler in
 *      mxml.lang
 */
/**
 * This builder handles building a Model instance from the root node
 * of an MXML document.  This isn't just an &lt;Application/&gt;.
 *
 * @author Clement Wong
 */
public class DocumentBuilder extends ComponentBuilder implements MXMLNamespaces
{
	/**
     * Note: kind of a messy overlap here. There is a set of "special" root
     * attributes (attributes that may appear on the root, that aren't
     * properties/effects/styles/events). These are skipped by the normal
     * compilation process, which uses isSpecialAttribute() to detect them.
     * These all have meaning downstream, and are collected by
     * parseRootAttributes().
     * 
     * Then there are also a handful of "ordinary" attributes that *also* have
     * downstream meaning, when they appear on the root. They are *both*
     * processed by parseRootAttributes(), and by the normal compilation
     * process. These are listed below by the rootAttr* constants.
	 */
    protected static final String rootAttrBackgroundColor = "backgroundColor";
    protected static final String rootAttrHeight = "height";
    protected static final String rootAttrStyleName = "styleName";
    protected static final String rootAttrWidth = "width";
    
    protected static final String specialAttrExclude = "excludeFrom";
    protected static final String specialAttrFrameRate = "frameRate";
    protected static final String specialAttrImplements = "implements";
    protected static final String specialAttrInclude = "includeIn";
    protected static final String specialAttrItemCPolicy = "itemCreationPolicy";
    protected static final String specialAttrItemDPolicy = "itemDestructionPolicy";
    protected static final String specialAttrLib = "lib";
    protected static final String specialAttrPageTitle = "pageTitle";
    protected static final String specialAttrPreloader = "preloader";
    protected static final String specialAttrRsl = "rsl";
    protected static final String specialAttrRuntimeDPIProvider = "runtimeDPIProvider";
    protected static final String specialAttrScriptRecursionLimit = "scriptRecursionLimit";
    protected static final String specialAttrScriptTimeLimit = "scriptTimeLimit";
    protected static final String specialAttrTheme = "theme";
    protected static final String specialAttrUsePreloader = "usePreloader";
    protected static final String specialAttrVersion = "version";
    protected static final String specialAttrSplashScreenImage = "splashScreenImage";
    protected static final String specialAttrUseGPU = "useGPU";
    protected static final String specialAttrUseDirectBlit = "useDirectBlit";

    // MXML 2006 Special Attributes
    private static final String DEFAULT_NAMESPACE = QName.DEFAULT_NAMESPACE;
    private static QNameSet specialAttributes2006 = new QNameSet(16);
    static
    {
        specialAttributes2006.add(DEFAULT_NAMESPACE, specialAttrFrameRate);
        specialAttributes2006.add(DEFAULT_NAMESPACE, specialAttrImplements);
        specialAttributes2006.add(DEFAULT_NAMESPACE, specialAttrLib);
        specialAttributes2006.add(DEFAULT_NAMESPACE, specialAttrPageTitle);
        specialAttributes2006.add(DEFAULT_NAMESPACE, specialAttrPreloader);
        specialAttributes2006.add(DEFAULT_NAMESPACE, specialAttrRsl);
        specialAttributes2006.add(DEFAULT_NAMESPACE, specialAttrScriptRecursionLimit);
        specialAttributes2006.add(DEFAULT_NAMESPACE, specialAttrScriptTimeLimit);
        specialAttributes2006.add(DEFAULT_NAMESPACE, specialAttrTheme);
        specialAttributes2006.add(DEFAULT_NAMESPACE, specialAttrUsePreloader);
    }

    // MXML 2009 Special Attributes (qualified in language namespace)
    private static QNameSet specialAttributes2009 = new QNameSet(16);
    static
    {
        specialAttributes2009.add(MXML_2009_NAMESPACE, specialAttrFrameRate);
        specialAttributes2009.add(MXML_2009_NAMESPACE, specialAttrImplements);
        specialAttributes2009.add(MXML_2009_NAMESPACE, specialAttrLib);
        specialAttributes2009.add(MXML_2009_NAMESPACE, specialAttrPageTitle);
        specialAttributes2009.add(MXML_2009_NAMESPACE, specialAttrPreloader);
        specialAttributes2009.add(MXML_2009_NAMESPACE, specialAttrRsl);
        specialAttributes2009.add(MXML_2009_NAMESPACE, specialAttrRuntimeDPIProvider);
        specialAttributes2009.add(MXML_2009_NAMESPACE, specialAttrScriptRecursionLimit);
        specialAttributes2009.add(MXML_2009_NAMESPACE, specialAttrScriptTimeLimit);
        specialAttributes2009.add(MXML_2009_NAMESPACE, specialAttrTheme);
        specialAttributes2009.add(MXML_2009_NAMESPACE, specialAttrUsePreloader);
        specialAttributes2009.add(MXML_2009_NAMESPACE, specialAttrSplashScreenImage);
        specialAttributes2009.add(MXML_2009_NAMESPACE, specialAttrUseGPU);
        specialAttributes2009.add(MXML_2009_NAMESPACE, specialAttrUseDirectBlit);
        
        // Though considered special attributes we end up disallowing the following 
        // on the root. We ensure they are in the special attributes list so that we
        // don't end up in the default attribute handling code (and end up issuing 
        // and extraneous 'unknown attribute' error).
    	specialAttributes2009.add(MXML_2009_NAMESPACE, specialAttrExclude);
        specialAttributes2009.add(MXML_2009_NAMESPACE, specialAttrInclude);
        specialAttributes2009.add(MXML_2009_NAMESPACE, specialAttrItemCPolicy);
    }
    
	public DocumentBuilder(CompilationUnit unit,
							  TypeTable typeTable,
							  MxmlConfiguration mxmlConfiguration,
							  MxmlDocument document)
	{
		super(unit, typeTable, mxmlConfiguration, document, null, null, null, false, null);

		//	NOTE: override already-initialized childNodeHandler
		this.childNodeHandler = new DocumentChildNodeHandler(typeTable);

		this.rootAttributeParser = new RootAttributeParser(typeTable);
		this.nestedDeclarationNodeHandler = new NestedDeclarationNodeHandler();
		this.componentDeclarationBindingHandler = new ComponentDeclarationBindingHandler();
		this.primitiveDeclarationBindingHandler = new PrimitiveDeclarationBindingHandler();
	}

	protected RootAttributeParser rootAttributeParser;
	protected NestedDeclarationNodeHandler nestedDeclarationNodeHandler;
	protected ComponentDeclarationBindingHandler componentDeclarationBindingHandler;
	protected PrimitiveDeclarationBindingHandler primitiveDeclarationBindingHandler;

	private boolean generateLoader = true;
	private boolean inDeclaration = false;

	public void analyze(Node node)
	{
		checkInvalidRootAttributes(node);
		
		if(mxmlConfiguration.getGenerateAbstractSyntaxTree())
		{
		    if(node.comment != null)
		    {
		        document.setComment( MxmlCommentUtil.commentToXmlComment(node.comment) );
		    }
		}
		else 
		{
		    document.setComment( node.comment );
		}
		
		Type type = nodeTypeResolver.resolveType(node, document);

		constructComponent(type, node.beginLine);

		//	TODO eliminate horrible confusion by renaming one or the other "root" below,

		//	NOTE: "document.root" means the root component, i.e. the component represented by the root node
		document.setRoot(component);

		processAttributes(node, type);
		processChildren(node, type);

		//	post-processing grab bag
		document.resolveTwoWayBindings();
		document.postProcessStates();
		postProcessDesignLayers();

		//	post-processing on *application component only* - that's what unit.isRoot() means
		if (unit.isRoot())
		{
			rootPostProcess(node);

			//	at the moment, binding destinations aren't set up until some arbitrary time after construction, so we have
			//  to do this import fixup late.
			//
			//	TODO add BindingExpression factory functions which set destination stuff up
			//  immediately, then shift this addImport() into MxmlDocument.addBindingExpression().
			//
			for (Iterator iter = document.getBindingExpressions().iterator(); iter.hasNext(); )
			{
				BindingExpression bexpr = (BindingExpression)iter.next();
				document.addImport(bexpr.getDestinationTypeName(), bexpr.getXmlLineNumber());
			}
		}
	}
	
	public void analyze(LayeredNode node)
	{
	    analyze((Node) node);
	}

	public void analyze(MetaDataNode node)
	{
		CDATANode cdata = (CDATANode)node.getChildAt(0);
		if (cdata != null && cdata.image != null)
		{
			//	metadata scripts are added to document info in InterfaceCompiler

            // If the document sets Frame metadata, then we must not overwrite it.
            // Is there a better way to do this?   This seems really hacky and brittle.
            if (node.getText().toString().indexOf( "[Frame" ) != -1)
            {
                assert unit.isRoot();
                generateLoader = false;
            }
		}
	}

	public void analyze(StyleNode node)
	{
		if (node.getStyleSheet() != null)
		{
			try
			{
				document.getStylesContainer().extractStyles(node.getStyleSheet(), true);
			}
			catch (Exception exception)
			{
				String message = exception.getLocalizedMessage();
				if (message == null)
				{
					message = exception.getClass().getName();
				}
				logError(node, message);
			}
		}
	}

	public void analyze(WebServiceNode node)
	{
		WebServiceBuilder builder = new WebServiceBuilder(unit, typeTable, mxmlConfiguration, document);
		node.analyze(builder);
	}

	public void analyze(HTTPServiceNode node)
	{
		HTTPServiceBuilder builder = new HTTPServiceBuilder(unit, typeTable, mxmlConfiguration, document);
		node.analyze(builder);
	}

	public void analyze(RemoteObjectNode node)
	{
		RemoteObjectBuilder builder = new RemoteObjectBuilder(unit, typeTable, mxmlConfiguration, document);
		node.analyze(builder);
	}

	/**
	 *
	 */
	public void analyze(BindingNode node)
	{
        boolean isTwoWayBind = false; 

        String source = (String) node.getAttributeValue("source");
		if (source == null)
		{
			log(node, new MissingAttribute("source"));
			return;
		}

		String destination = (String) node.getAttributeValue("destination");
		if (destination == null)
		{
			log(node, new MissingAttribute("destination"));
			return;
		}

		String twoWay = (String) node.getAttributeValue("twoWay");
		if (twoWay != null)
		{
            Object value = rootAttributeParser.parseBoolean(twoWay, node.beginLine, "twoWay");
	        if (value != null)
	        {
                // If twoWay, both the source and the destination have to be
                // bindable properties or property chains.  The ConstantEvaluator
                // will error if the destination isn't a reference value.
                isTwoWayBind = ((Boolean)value);
	        }
		}
		
		Object value = textParser.parseValue(source, typeTable.stringType, 0, node.beginLine, "source");
	
        //  Note: allow source="expr".
        //  Don't allow source = "@{expr}" and if two-way bind, source = "{expr}",
		BindingExpression bindingExpression;
		if (value instanceof BindingExpression)
		{
		    bindingExpression = (BindingExpression) value;

            if (bindingExpression.isTwoWayPrimary())
            {
                log(node, new TwoWayBindingNotAllowedInitializer("source", source));
            } 
            else if (isTwoWayBind)
		    {
                log(node, new BindingNotAllowedInitializer("source", source));
		    }
		}
		else
		{
		    bindingExpression = new BindingExpression((String)value, node.beginLine, document);
		}
		
        bindingExpression.setDestinationProperty(destination);
		bindingExpression.setDestinationLValue(destination);
		bindingExpression.setFromBindingNode(true);

        value = textParser.parseValue(destination, typeTable.stringType, 0, node.beginLine, "destination");

        // Don't allow destination="{expr}" or destination="@{expr}"
        if (value instanceof BindingExpression)
        {
            bindingExpression = (BindingExpression) value;
            if (bindingExpression.isTwoWayPrimary())
            {
                log(node, new TwoWayBindingNotAllowedInitializer("destination", destination));                
            }
            else
            {
                log(node, new BindingNotAllowedInitializer("destination", destination));
            }
        }

        // If a two-way binding, create another one, with the source and destination
		// reversed.  They will be hooked together when all the two-way bindings
		// are resolved.
		if (isTwoWayBind)
		{
	        BindingExpression bindingExpression2 = new BindingExpression(destination, node.beginLine, document);

	        source = TextGen.stripParens(bindingExpression.getSourceExpression());
	        bindingExpression2.setDestinationProperty(source);
	        bindingExpression2.setDestinationLValue(source);
	        bindingExpression2.setFromBindingNode(true);
		}
	}	

    /**
     * Overrides AbstractBuilder.checkTypeCompatibility() to provide
     * more document specific error messages.
     */
    protected int checkTypeCompatibility(Node node,
                                         Type lvalueType,
                                         Type lvalueArrayElementType,
                                         String lvalueDescription,
                                         boolean rvalueIsSingleton,
                                         boolean isDefaultProperty)
    {
        Type rtype = nodeTypeResolver.resolveType(node, document);

        // Determine type compatibility. We account for the possibility of 
        // incorrectly nested language or service tags.  
        String rvalueTypeName = (rtype != null) ? rtype.getName() : node.getLocalPart();
        int compat = TypeCompatibility.check(lvalueType, lvalueArrayElementType, rtype, rvalueIsSingleton, standardDefs);
        compat = coerceStatefulNodes(node, lvalueType, compat);
        	        
        switch (compat)
        {
            case TypeCompatibility.Ok:
            case TypeCompatibility.OkCoerceToArray:
            case TypeCompatibility.OkCoerceToVector:
            {
                return compat;
            }
            case TypeCompatibility.ErrRTypeNotAssignableToLType:
            {
                if (isDefaultProperty)
                {
                    log(node.beginLine, new TypeNotAssignableToDefaultProperty(lvalueDescription,
                                                                               NameFormatter.toDot(rvalueTypeName),
                                                                               NameFormatter.toDot(lvalueType.getName())));
                }
                else
                {
                    log(node.beginLine, new TypeNotAssignableToLType(lvalueDescription,
                                                                     NameFormatter.toDot(rvalueTypeName),
                                                                     NameFormatter.toDot(lvalueType.getName())));
                }
                return compat;
            }
            case TypeCompatibility.ErrLTypeNotMultiple:
            {
                if (isDefaultProperty)
                {
                    log(node.beginLine, new DefaultPropertyNotMultiple(lvalueDescription,
                                                                       NameFormatter.toDot(lvalueType.getName())));
                }
                else
                {
                    log(node.beginLine, new TypeNotMultiple(lvalueDescription,
                                                            NameFormatter.toDot(lvalueType.getName())));
                }
                return compat;
            }
            case TypeCompatibility.ErrSingleRValueNotArrayOrArrayElem:
            {
                if (isDefaultProperty)
                {
                    log(node.beginLine, new SingleRValueNestedDeclaration(node.getLocalPart(),
                                                                          NameFormatter.toDot(lvalueType.getName()),
                                                                          NameFormatter.toDot(lvalueArrayElementType.getName())));
                }
                else
                {
                    log(node.beginLine, new SingleRValueNotTargetTypeOrTargetElementType(lvalueDescription,
                                                                                         NameFormatter.toDot(rvalueTypeName),
                                                                                         NameFormatter.toDot(lvalueType.getName()),
                                                                                         NameFormatter.toDot(lvalueArrayElementType.getName())));
                }
                return compat;
            }
            case TypeCompatibility.ErrMultiRValueNotArrayElem:
            {
                if (isDefaultProperty)
                {
                    log(node.beginLine, new MultiRValueNestedDeclaration(node.getLocalPart(),
                                                                         NameFormatter.toDot(lvalueType.getName()),
                                                                         NameFormatter.toDot(lvalueArrayElementType.getName())));
                }
                else
                {
                    log(node.beginLine, new MultiRValueNotElementType(lvalueDescription,
                                                                      NameFormatter.toDot(rvalueTypeName),
                                                                      NameFormatter.toDot(lvalueType.getName()),
                                                                      NameFormatter.toDot(lvalueArrayElementType.getName())));
                }
                return compat;
            }
            default:
            {
                assert false;
                return compat;
            }
        }
    }
	
	/**
	 *
	 */
	protected boolean isLegalLanguageNode(Node node)
	{
		Class<? extends Node> nodeClass = node.getClass();
		return super.isLegalLanguageNode(node) ||
				nodeClass == MetaDataNode.class ||
				nodeClass == StyleNode.class ||
				nodeClass == BindingNode.class ||
				isServiceNode(node);
	}

	/**
	 * RemoteObject, HTTPService and WebService tags represent services
	 * that require special handling and so are considered language tags.
	 * 
	 * @param node
	 * @return true if the node represents a service
	 */
    protected boolean isServiceNode(Node node)
    {
        Class<? extends Node> nodeClass = node.getClass();
        return  nodeClass == RemoteObjectNode.class ||
            nodeClass == HTTPServiceNode.class ||
            nodeClass == WebServiceNode.class;
    }

	/**
	 * Override ComponentBuilder's isProhibitedProperty.
	 */
	protected boolean isAllowedProperty(Property property)
	{
		return true;
	}

    /**
     * Override ComponentBuilder.isSpecialAttribute(). The root node doesn't
     * allow "id", but it allows for special attributes (e.g. frameRate,
     * usePreloader, etc...).
     * @param namespace - the qualified attribute namespace
     * @param localPart - the qualified attribute local name
     * @return true if the given attribute requires special handling.
     */
    protected boolean isSpecialAttribute(String namespace, String localPart)
    {
        if (document.getVersion() < 4)
        {
            return specialAttributes2006.contains(namespace, localPart);
        }
        else
        {
            if (namespace.length() == 0)
                namespace = MXML_2009_NAMESPACE;

            return specialAttributes2009.contains(namespace, localPart);
        }
    }

    /**
     * Searches for a special (language) attribute on a given node.
     * 
     * Prior to Flex 4, attributes were never qualified and were in the default
     * (empty string) namespace.
     * 
     * From Flex 4 onwards, language attributes could be qualified if a
     * non-default prefix was used for the language namespace. For usability
     * sake, even though unprefixed attributes are in the default (empty
     * string) namespace (regardless of whether the language namespace was
     * the default namespace for the document), we continue to see them as
     * special attributes.
     * 
     * @param node The node to search for the attribute.
     * @param localPart The unqualified attribute name
     * @return attribute value as a String, or null if the attribute was not found
     */
    protected Attribute getSpecialAttribute(Node node, String localPart)
    {
        Attribute attr = null;

        if (document.getVersion() < 4)
        {
            attr = node.getAttribute(DEFAULT_NAMESPACE, localPart);
        }
        else
        {
            // We check the default namespace first as it is the most common
            // use case...
            attr = node.getAttribute(DEFAULT_NAMESPACE, localPart);
            if (attr == null)
                attr = node.getAttribute(document.getLanguageNamespace(), localPart);
        }

        return attr;
    }
    
    /**
     * Walk all 'orphan' DesignLayer instances in the document
     * (those with id's but no layer children) and ensure we process them
     * as top level declarations.
     */
    public void postProcessDesignLayers()
    {
    	List<DesignLayerNode> layers = document.getLayerDeclarationNodes();
    	
        for (Iterator<DesignLayerNode> i = layers.iterator(); i.hasNext();)
        {
        	DesignLayerNode node = i.next();
        	if (document.getLayerModel(node) == null)
        	{
        	    ComponentBuilder builder = new ComponentBuilder(unit, typeTable, mxmlConfiguration, 
        			document, component, null, null, true, null);
                node.analyze(builder);
        	}
        }
    }
    
	/**
	 * override ComponentBuilder.ComponentAttributeHandler for root-node special handling
	 */
	protected class DocumentAttributeHandler extends ComponentBuilder.ComponentAttributeHandler
	{
		/**
		 * even if our supertype is dynamic, we (an MXML document) never define a dynamic class.
		 */
		protected void dynamicProperty(String name, String state)
		{
			unknownAttributeError("", name, line);
		}
	}

	/**
	 * override ComponentBuilder.ChildNodeHandler for root-node special handling
	 */
	protected class DocumentChildNodeHandler extends ComponentBuilder.ComponentChildNodeHandler
	{
	    DocumentChildNodeHandler(TypeTable typeTable)
		{
			super(typeTable);
		}

	    /**
	     * In MXML 2009 (and later), RemoteObject, HTTPService and WebService need to
	     * be declared under the Declarations section.
	     */
        protected void languageNode()
        {
            if (document.getVersion() >= 4 && isServiceNode(child))
            {
                log(child, new NestedDeclaration(child.getLocalPart(),
                                                 NameFormatter.toDot(standardDefs.INTERFACE_IUICOMPONENT)));
            }
            else
            {
                super.languageNode();
            }
        }

        /**
		 * even if our supertype is dynamic, we (an MXML document) never define a dynamic class. If the dynamic
		 * property handler has been called, it means that no statically defined entity by this name could be found on
		 * our backing type, so here we just route it to the handler it would've gone to had our backing class been static.
		 */
		protected void dynamicProperty(String name, String state)
		{
			nestedDeclaration(false);
		}

		/**
		 * Default properties are suppressed on the root - they step on the syntactic territory used by top-level
		 * declarations. So here we're routing to the handler that would have been called had our backing class had no DP.
		 * <p>
		 * But note that we come through here on the root of an inline component as well. It would be consistent to
		 * treat them identically, but since a) nested declarations are used 0% of the time within inline components,
		 * and b) the misunderstanding would be silent, we're going to choose usability over consistency here.
		 */
		protected void defaultPropertyElement(boolean locError)
		{
			String mimeType = document.getCompilationUnit().getSource().getMimeType();

			if (DocumentBuilder.this.document.getIsInlineComponent() || 
				(mimeType.equals(MimeMappings.MXML) && (document.getVersion() >= 4)) ||
				mimeType.equals(MimeMappings.FXG))
			{
				//	In an inline component, process default property elements as usual. Note that this
				//	suppresses nested declarations inside inline components, as intended (see header comment).
				super.defaultPropertyElement(locError);
			}
			else
			{
				//	NOTE: we can *not* simply report an error here. If we did, MXML components based on classes with
				//	default properties would no longer be able to declare things FC-style at the top level.
				super.nestedDeclaration(false);
			}
		}

		protected void nestedDeclaration()
		{
			String mimeType = document.getCompilationUnit().getSource().getMimeType();

			if (mimeType.equals(MimeMappings.MXML) && document.getVersion() < 4)
			{
				super.nestedDeclaration();
			}
			else
			{
				Type childType = nodeTypeResolver.resolveType(child, document);
				assert childType != null : "nested declaration node type == null, node = " + child.image;

				if (standardDefs.isContainer(parentType) && standardDefs.isIUIComponent(childType) &&
					((mimeType.equals(MimeMappings.MXML) && (document.getVersion() < 4)) || 
					 (parentType.getDefaultProperty() == null)))
				{
					processVisualChild(child);
				}
				else if (child instanceof ReparentNode)
				{
					ComponentBuilder builder = new ComponentBuilder(unit, typeTable, mxmlConfiguration, document, component, null, null, true, null);
					child.analyze(builder);
				}
	            else if ((standardDefs.isContainer(parentType) && 
                        (childType.isAssignableTo(standardDefs.CLASS_RADIOBUTTONGROUP) || 
                                childType.isAssignableTo(standardDefs.CLASS_SPARK_RADIOBUTTONGROUP))))
	            {
	                // Special cases to allow non-visual children in visual containers.  
                    ComponentBuilder builder = new ComponentBuilder(unit, typeTable, mxmlConfiguration, document, component, null, null, true, null);
                    child.analyze(builder);	                
	            }				
				else
				{
				    if (standardDefs.isSparkGraphic(childType))
				    {
				        log(child, new SparkPrimitiveInHalo(child.getLocalPart(), parent.getLocalPart()));
				    }
				    else
				    {
						log(child, new NestedDeclaration(child.getLocalPart(),
                                                     NameFormatter.toDot(standardDefs.INTERFACE_IUICOMPONENT)));
				    }
			    }
		    }
		}

        /**
         * in our case, nested declarations are top-level declarations. However, note that here we're subclassing the
         * sub-handler that runs *after* the visual-child and repeater special cases have been checked.
         * Note that we'll only be called for "value nodes" - nodes that represent values that can be translated into AS
         * values everywhere. (See NodeTypeResolver.isValueNode() and ChildNodeHandler.invoke()) for details). Other top-level
         * tags are considered "language tags" and result in a call to langaugeNode() rather than nestedDeclaration() in the handler.
         */
        protected void processNestedDeclaration(Type childType)
        {
            nestedDeclarationNodeHandler.invoke(null, child, document);
        }
        
        /**
         * Scans for any invalid attributes on nested declarations.
         */
        protected boolean validateNestedDeclarationAttrs(Node node)
        {
            // Ensure we disallow state-specific children of the <Declarations> tag.
            String include = (String) getLanguageAttributeValue(node, specialAttrInclude);
            String exclude = (String) getLanguageAttributeValue(node, specialAttrExclude);
            String icpolicy = (String) getLanguageAttributeValue(node, specialAttrItemCPolicy);
            String idpolicy = (String) getLanguageAttributeValue(node, specialAttrItemDPolicy);
            if (include != null || exclude != null)
            {
                log(node, new StateAttrsNotAllowedOnDecls());  
                return false;
            }
            
            if (icpolicy != null || idpolicy != null)
            {
                log(node, new ItemPolicyNotAllowedOnDecls());  
                return false;
            }
            
            return true;
        }

        protected void invoke(Node parent, Type parentType, Node child)
        {
            if (child.getClass() == DeclarationsNode.class)
            {
                this.parent = parent;
                this.parentType = parentType;

                inDeclaration = true;
                for (Iterator iter = child.getChildIterator(); iter.hasNext(); )
                {
                    this.child = (Node) iter.next();
                    
                    if (validateNestedDeclarationAttrs(this.child))
                    {
                        if (isServiceNode(this.child))
                            super.languageNode();
                        else if (isLegalLanguageNode(this.child))
                            log(this.child, new LanguageNodeInDeclarationError(this.child.image));
                        else
                            super.nestedDeclaration(false);
                    }
                }
                inDeclaration = false;
            }
            else if (child.getClass() == LibraryNode.class)
            {
                // Skip Library while building Application
            }
            else if (child.getClass() == PrivateNode.class)
            {
                // Skip Private tag
            }
            else
            {
                super.invoke(parent, parentType, child);
            }
        }
    }

	/**
	 *
	 */
	protected class NestedDeclarationNodeHandler extends ValueNodeHandler
	{
	    protected void componentNode(Assignable property, Node node, MxmlDocument document)
		{
			ComponentBuilder builder = new ComponentBuilder(unit, typeTable, mxmlConfiguration, document, component, null, null, true,
					componentDeclarationBindingHandler);
			node.analyze(builder);
		}

		protected void arrayNode(Assignable property, ArrayNode node)
		{
			ArrayBuilder builder = new ArrayBuilder(unit, typeTable, mxmlConfiguration, document);
			node.analyze(builder);
		}

        protected void vectorNode(Assignable property, VectorNode node)
        {
            String typeAttributeValue = (String) node.getAttribute(StandardDefs.PROP_TYPE).getValue();
            Type elementType = typeTable.getType(NameFormatter.toColon(typeAttributeValue));
            VectorBuilder builder = new VectorBuilder(unit, typeTable, mxmlConfiguration, document, null, null, elementType, true);
            node.analyze(builder);
        }

		protected void primitiveNode(Assignable property, PrimitiveNode node)
		{
		    PrimitiveBuilder builder = new PrimitiveBuilder(unit, typeTable, mxmlConfiguration, document, component, true, null, primitiveDeclarationBindingHandler);
			node.analyze(builder);
		}

		protected void xmlNode(Assignable property, XMLNode node)
		{
			XMLBuilder builder = new XMLBuilder(unit, typeTable, mxmlConfiguration, document);
			node.analyze(builder);
			registerModel(node, builder.xml, true);
		}
        
        protected void xmlListNode(Assignable property, XMLListNode node)
        {
            XMLListBuilder builder = new XMLListBuilder(unit, typeTable, mxmlConfiguration, document);
            node.analyze(builder);
            registerModel(node, builder.xmlList, true);
        }

		protected void modelNode(Assignable property, ModelNode node)
		{
			ModelBuilder builder = new ModelBuilder(unit, typeTable, mxmlConfiguration, document, null);
			node.analyze(builder);
		}

		protected void inlineComponentNode(Assignable property, InlineComponentNode node)
		{
			InlineComponentBuilder builder = new InlineComponentBuilder(unit, typeTable, mxmlConfiguration, document, true);
			node.analyze(builder);
		}
		
		protected void reparentNode(Assignable property, ReparentNode node)
        {
            ComponentBuilder builder = new ComponentBuilder(unit, typeTable, mxmlConfiguration, document, component, null, null, true, null);
            node.analyze(builder);
        }

		protected void stateNode(Assignable property, StateNode node)
		{
			ComponentBuilder builder = new ComponentBuilder(unit, typeTable, mxmlConfiguration, document, component, null, null, true, null);
			node.analyze(builder);
		}
		
        protected void cdataNode(Assignable property, CDATANode node)
        {
            PrimitiveBuilder builder = new PrimitiveBuilder(unit, typeTable, mxmlConfiguration, document, component, true, null, primitiveDeclarationBindingHandler);
            node.analyze(builder);
        }

		protected void unknown(Assignable property, Node node)
		{
			assert false : "Unexpected node class in processNestedDeclaration: " + node.getClass();
		}
	}

	/**
	 * Primitive specific binding handler.
	 */
	protected static class PrimitiveDeclarationBindingHandler implements BindingHandler
	{
		public BindingExpression invoke(BindingExpression bindingExpression, Model dest)
		{
			bindingExpression.setDestination(dest);
			((Primitive)dest).setValue(null);
			return bindingExpression;
		}
	}

	/**
	 * Override ComponentBuilder.processSpecialAttributes()...
	 */
	protected void processSpecialAttributes(Node node)
	{
        if (unit.getSource().isRoot())
        {
		    parseRootAttributes(node);
        }
	}

    /**
     * Override ComponentBuilder.processVisualChild to avoid deferred
     * instantiation of any visual children declared inside a Declarations 
     * tag. These should be treated as "top level" definitions which are
     * initialized in the documents constructor.
     */
    protected void processVisualChild(Node node)
    {
        if (inDeclaration)
        {
            ComponentBuilder builder = new ComponentBuilder(unit, typeTable, mxmlConfiguration, document, component, null, null, true, null);
            node.analyze(builder);
        }
        else
        {
            super.processVisualChild(node);
        }
    }

    private static String buildSwfMetadata( Map<String, Object> varmap )
    {
        if ((varmap == null) || (varmap.size() == 0))
            return null;
        StringBuffer buf = new StringBuffer( 50 );
        buf.append( "[SWF( " );
        boolean more = false;
        for (Iterator<String> it = varmap.keySet().iterator(); it.hasNext(); )
        {
            String var = it.next();
            Object val = varmap.get( var );

            if (more)
                buf.append( ", " );
            else
                more = true;

            buf.append( var );
            buf.append( "='" );
            buf.append( val );
            buf.append( "'" );
        }
        buf.append( ")]" );

        return buf.toString();
    }

	// C: Most of these root attributes are linker properties. They should be
    // saved to the CompilationUnit	object or to a per-compile Context object...

	private void parseRootAttributes(Node node)
	{
        // NOTE: only put variables relevant to SWF production into the SWF
	    // metadata! MXML-specific bootstrap info should be saved into the
	    // unit's context and incorporated into the generated IFlexBootstrap
	    // derivative.

        Map<String, Object> swfvarmap = new TreeMap<String, Object>();

		Attribute frameRate = getSpecialAttribute(node, specialAttrFrameRate);
		if (frameRate != null)
		{
		    Object value = rootAttributeParser.parseUInt((String)frameRate.getValue(),
		            frameRate.getLine(),
		            specialAttrFrameRate);
			if (value != null)
			{
	            swfvarmap.put(specialAttrFrameRate, value.toString());
			}
		}

		Attribute scriptRecursionLimit = getSpecialAttribute(node, specialAttrScriptRecursionLimit);
		if (scriptRecursionLimit != null)
		{
			Object value = rootAttributeParser.parseUInt((String)scriptRecursionLimit.getValue(),
			        scriptRecursionLimit.getLine(),
			        specialAttrScriptRecursionLimit);
			if (value != null)
			{
	            swfvarmap.put(specialAttrScriptRecursionLimit, value.toString());
			}
		}

		Attribute scriptTimeLimit = getSpecialAttribute(node, specialAttrScriptTimeLimit);
		if (scriptTimeLimit != null)
		{
			Object value = rootAttributeParser.parseUInt((String)scriptTimeLimit.getValue(),
			        scriptTimeLimit.getLine(),
			        specialAttrScriptTimeLimit);
			if (value != null)
			{
	            swfvarmap.put(specialAttrScriptTimeLimit, value.toString());
			}
		}

		Attribute bgcolor = node.getAttribute(DEFAULT_NAMESPACE, rootAttrBackgroundColor);
		if (bgcolor != null)
		{
            Object value = rootAttributeParser.parseColor((String)bgcolor.getValue(),
                    bgcolor.getLine(),
                    rootAttrBackgroundColor);
            if (value != null)
            {
                swfvarmap.put(rootAttrBackgroundColor, value.toString());
            }
		}
		
		// useDirectBlit="true|false"
		Attribute useDirectBlit = node.getAttribute(DEFAULT_NAMESPACE, specialAttrUseDirectBlit);
		if(useDirectBlit != null)
		{
			Object value = rootAttributeParser.parseBoolean(
					(String) useDirectBlit.getValue(), 
					useDirectBlit.getLine(), 
					specialAttrUseDirectBlit);
			if (value != null)
			{
				swfvarmap.put(specialAttrUseDirectBlit, value.toString());
			}
		}
		
		// useGPU="true|false" 
		Attribute useGPU = node.getAttribute(DEFAULT_NAMESPACE, specialAttrUseGPU);
		if(useGPU != null)
		{
			Object value = rootAttributeParser.parseBoolean(
					(String) useGPU.getValue(), 
					useGPU.getLine(), 
					specialAttrUseGPU);
			if (value != null)
			{
				swfvarmap.put(specialAttrUseGPU, value.toString());
			}
		}
		
        Attribute styleName = node.getAttribute(DEFAULT_NAMESPACE, rootAttrStyleName);
        if (styleName != null)
        {
            document.getCompilationUnit().styleName = (String) styleName.getValue();
        }

		Attribute title = getSpecialAttribute(node, specialAttrPageTitle);
		if (title != null)
		{
			swfvarmap.put(specialAttrPageTitle, title.getValue());
		}

		// Only do the "percent" logic for Application nodes, not modules. There is no
		// html wrapper for a module and the logic keeps modules from sizing
		// to the ModuleLoader component, SDK-9527.
        Type nodeType = nodeTypeResolver.resolveType(node, document);
        boolean isApplication = StandardDefs.isApplication(nodeType);

		Attribute width = node.getAttribute(DEFAULT_NAMESPACE, rootAttrWidth);
        if (width != null && isApplication)
        {
            String widthString = width.getValue().toString();
			Object value = rootAttributeParser.parseNumberOrPercentage(widthString,
			        width.getLine(),
			        rootAttrWidth);

			if (value != null)
			{
				if (rootAttributeParser.wasPercentage())
				{
					if (widthString.endsWith("%"))
                    {
                        swfvarmap.put("widthPercent", widthString);
                    }
                    else
                    {
                        swfvarmap.put("widthPercent", widthString + '%');
                    }

					//	HACK for 174078: width="n%" at the root of an MXML app is a specification of the ratio of
					//	player to browser width, not app to player width. So we pass it through to the SWF, but strip
					//	it from the MXML DOM, preventing it from showing up in the property settings for the root UIC.
					node.removeAttribute(new QName(width.getNamespace(), rootAttrWidth));
				}
				else
				{
					if (value instanceof Double)
					{
						value = new Integer(((Double) value).intValue());
					}
					swfvarmap.put(rootAttrWidth, value);
				}
			}
        }

        Attribute height = node.getAttribute(DEFAULT_NAMESPACE, rootAttrHeight);
        if (height != null && isApplication)
        {
            String heightString = height.getValue().toString();
			Object value = rootAttributeParser.parseNumberOrPercentage(heightString,
			        height.getLine(),
			        rootAttrHeight);

			if (value != null)
			{
				if (rootAttributeParser.wasPercentage())
				{
					if (heightString.endsWith("%"))
                    {
                        swfvarmap.put("heightPercent", heightString);
                    }
                    else
                    {
                        swfvarmap.put("heightPercent", heightString + '%');
                    }

					//	HACK for 174078: as above for width
					node.removeAttribute(new QName(height.getNamespace(), rootAttrHeight));
				}
				else
				{
					if (value instanceof Double)
					{
						value = new Integer(((Double) value).intValue());
					}
					swfvarmap.put(rootAttrHeight, value);
				}
			}
        }

        Attribute usePreloader = getSpecialAttribute(node, specialAttrUsePreloader);
		if (usePreloader != null)
		{
			Object value = rootAttributeParser.parseBoolean((String)usePreloader.getValue(),
			        usePreloader.getLine(),
			        specialAttrUsePreloader);

			if (value != null)
			{
				document.setUsePreloader(((Boolean)value).booleanValue());
			}
		}

		Attribute preloader = getSpecialAttribute(node, specialAttrPreloader);
		if (preloader != null)
		{
		    String preloaderString = (String)preloader.getValue();
			String preloaderClassName = TextParser.parseClassName(preloaderString);
			if (preloaderClassName != null)
			{
				document.setPreloader(preloaderString);
			}
			else
			{
				log(node, new InvalidPreLoaderClassName(preloaderString));
			}
		}
		
		Attribute runtimeDPIProvider = getSpecialAttribute(node, specialAttrRuntimeDPIProvider);
		if (runtimeDPIProvider != null)
		{
		    String runtimeDPIProviderString = (String)runtimeDPIProvider.getValue();
			String runtimeDPIProviderClassName = TextParser.parseClassName(runtimeDPIProviderString);
			if (runtimeDPIProviderClassName == null)
			{
				log(node, new InvalidRuntimeDPIProviderClassName(runtimeDPIProviderString));
			}
		}
		
        if (swfvarmap.size() > 0)
        {
            String metadata = buildSwfMetadata( swfvarmap );
            Script script = new Script( metadata );
            document.addMetadata( script );
        }

        Attribute theme = getSpecialAttribute(node, specialAttrTheme);
		if (theme != null)
		{
            log(new ThemeAttributeError());
		}

		Attribute rsl = getSpecialAttribute(node, specialAttrRsl);
		if (rsl != null)
		{
            log(new RslAttributeError());
		}

		Attribute lib = getSpecialAttribute(node, specialAttrLib);
		if (lib != null)
		{
            log(new LibAttributeError());                        
		}
	}

	/**
	 *
	 */
	protected class RootAttributeParser extends TextValueParser
	{
		protected RootAttributeParser(TypeTable typeTable)
		{
			super(typeTable);
		}

		public Object parseUInt(String text, int line, String name)
		{
			return parseValue(text, typeTable.uintType, 0, line, name);
		}

		public Object parseColor(String text, int line, String name)
		{
			return parseValue(text, typeTable.uintType, FlagConvertColorNames, line, name);
		}

		public Object parseNumberOrPercentage(String text, int line, String name)
		{
			return parseValue(text, typeTable.numberType, FlagAllowPercentages, line, name);
		}

		public Object parseBoolean(String text, int line, String name)
		{
			return parseValue(text, typeTable.booleanType, 0, line, name);
		}

		//	TextParser impl

		public Object embed(String text, Type type)
		{
			log(line, new EmbedNotAllowed());
			return null;
		}
		
		public Object clear()
		{
			log(line, new ClearNotAllowed());
			return null;
		}

		public Object bindingExpression(String converted)
		{
			log(line, new BindingNotAllowed());
			return null;
		}
	}

	/**
	 *
	 */
	private void rootPostProcess(Node node)
	{
		if (generateLoader)
   		{
   			generateLoaderInfo(node);
   		}
		else
		{
			document.addMetadata( new Script( "[Frame(extraClass=\"FlexInit\")]\n" ) );
		}
	}

	/**
	 *
	 */
	private void generateLoaderInfo(Node node)
	{
		String baseLoaderClass = document.getSuperClass().getLoaderClass();
		if (baseLoaderClass == null)
			return;

		unit.auxGenerateInfo = new HashMap<String, Object>();

		String generateInitClass = "_" + document.getClassName() + "_FlexInit";
        generateInitClass = generateInitClass.replaceAll( "[^A-Za-z0-9]", "_" );

		document.addMetadata( new Script( "[Frame(extraClass=\"" + generateInitClass + "\")]\n" ) );

		// fixme - the lingo of the classes specified are in package:name syntax
		// in order to be able to find them in unit.topLevelDefs.
		baseLoaderClass = baseLoaderClass.replace( ':', '.' );

		String generateLoaderClass = "_" + document.getClassName() + "_" + baseLoaderClass;
		generateLoaderClass = generateLoaderClass.replaceAll( "[^A-Za-z0-9]", "_" );

		document.addMetadata( new Script( "[Frame(factoryClass=\"" + generateLoaderClass + "\")]\n" ) );

		Map<String, Object> rootAttributeMap = new HashMap<String, Object>();
		Map<String, Object> rootAttributeEmbedVarsMap = new HashMap<String, Object>();
		Map<String, Object> rootAttributeEmbedNamesMap = new HashMap<String, Object>();
		//	Type type = typeTable.getType(node.getNamespace(), node.getLocalPart());

		for (Iterator it = node.getAttributeNames(); it != null && it.hasNext();)
		{
			QName qname = (QName) it.next();
			//	String namespace = qname.getNamespace();
			String localPart = qname.getLocalPart();

			/*
			if ((type.getProperty( localPart ) != null)
				|| (type.hasEffect( localPart ))
				|| (type.getStyle( localPart ) != null)
				|| (type.getEvent( localPart ) != null))
				continue;
			*/

			String value = (String) node.getAttributeValue( qname );
			value = value.replaceAll( "\"", "\\\"" );
			if (!TextParser.isScopedName(localPart))
			{
				rootAttributeMap.put( localPart, value );
				
				// The splashScreenImage attribute is used by the SplashScreen preloader and
				// it could be @Embed or a class. We need to handle the @Embed here, but don't
				// want to do it for all of the attributes since it will change some error messages
				// for example for the legacy backgroundImage style on mx:Application. Sorry.
				if (localPart.equals("splashScreenImage"))
				{
					// Do we have "@Embed" function? If so, we need to process it here
					// and generate code pieces that will be used during the generation of the loader Class. 
					String atFunctionName = TextParser.getAtFunctionName(value);
					if (atFunctionName != null && "Embed".equals(atFunctionName))
					{
						AtEmbed atEmbed = AtEmbed.create(this.typeTable.getPerCompileData(),
														 this.unit.getSource(),
														 value,
														 node.getLineNumber(qname));

						if (atEmbed != null)
						{
							String embedVar = atEmbed.codegenEmbedVar();
							String embedName = atEmbed.getPropName();

							rootAttributeEmbedVarsMap.put(localPart, embedVar);
							rootAttributeEmbedNamesMap.put(localPart, embedName);
						}
					}
					else // Must be Class
					{
						String className = TextParser.parseClassName(value);
						if (className == null)
							log(node, new InvalidSplashScreenImageClassName(value));
					}
				}
			}
		}

        String windowClass = document.getClassName();
        if ((document.getPackageName() != null) && (document.getPackageName().length() != 0))
        {
            windowClass = document.getPackageName() + "." + document.getClassName();
        }

        unit.auxGenerateInfo.put( "baseLoaderClass", baseLoaderClass );
		unit.auxGenerateInfo.put( "generateLoaderClass", generateLoaderClass );
		unit.auxGenerateInfo.put( "windowClass", windowClass );
		unit.auxGenerateInfo.put( "preloaderClass", document.getPreloader() );
		unit.auxGenerateInfo.put( specialAttrUsePreloader, new Boolean( document.getUsePreloader() ) );
		unit.auxGenerateInfo.put( "rootAttributes", rootAttributeMap );
		unit.auxGenerateInfo.put( "rootAttributeEmbedVars", rootAttributeEmbedVarsMap );
		unit.auxGenerateInfo.put( "rootAttributeEmbedNames", rootAttributeEmbedNamesMap );
	}
	
	/**
	 *
	 */
	private void checkInvalidRootAttributes(Node node)
	{
	    Attribute idAttr = getLanguageAttribute(node, StandardDefs.PROP_ID);
		if (idAttr != null)
		{
			log(node, idAttr.getLine(), new IdNotAllowedOnRoot());
		}

		if (getLanguageAttribute(node, specialAttrInclude) != null ||
		    getLanguageAttribute(node, specialAttrExclude) != null)
		{
			log(new StateAttrsNotAllowedOnRoot());  
		}
		
		if (getLanguageAttribute(node, specialAttrItemCPolicy) != null ||
			getLanguageAttribute(node, specialAttrItemDPolicy) != null )
		{
		    log(new ItemPolicyNotAllowedOnRoot());  
		}
	}

    public static class DefaultPropertyError extends CompilerError
    {

        private static final long serialVersionUID = 4064574335519417302L;
    }

    public static class IdNotAllowedOnRoot extends CompilerError
    {

        private static final long serialVersionUID = -2319051120793286922L;
    }
    
    public static class StateAttrsNotAllowedOnRoot extends CompilerError
    {

	    private static final long serialVersionUID = -5448289747847880603L;
    }
    
    public static class StateAttrsNotAllowedOnDecls extends CompilerError
    {

	    private static final long serialVersionUID = -5448289747843880603L;
    }
    
    public static class ItemPolicyNotAllowedOnRoot extends CompilerError
    {

	    private static final long serialVersionUID = -5448389747847880603L;
    }
    
    public static class ItemPolicyNotAllowedOnDecls extends CompilerError
    {

	    private static final long serialVersionUID = -5448889747843880603L;
    }

    public static class MissingAttribute extends CompilerError
    {
        private static final long serialVersionUID = -3356986862852847108L;
        public String attribute;

        public MissingAttribute(String attribute)
        {
            this.attribute = attribute;
        }
    }

    public static class LanguageNodeInDeclarationError extends CompilerError
    {
        private static final long serialVersionUID = 2738031782626560481L;
        public String image;

        public LanguageNodeInDeclarationError(String image)
        {
            this.image = image;
        }
    }

    public static class NestedDeclaration extends CompilerError
    {
        private static final long serialVersionUID = -2341988816922122620L;
        public String declaration;
        public String targetType;

        public NestedDeclaration(String declaration, String targetType)
        {
            this.declaration = declaration;
            this.targetType = targetType;
        }
    }

    public static class SingleRValueNestedDeclaration extends NestedDeclaration
    {
        private static final long serialVersionUID = -2341988816922122621L;
        public String targetElementType;

        public SingleRValueNestedDeclaration(String declaration, String targetType,
                                             String targetElementType)
        {
            super(declaration, targetType);
            this.targetElementType = targetElementType;
        }
    }

    public static class MultiRValueNestedDeclaration extends NestedDeclaration
    {
        private static final long serialVersionUID = -2341988816922122622L;
        public String targetType;
        public String targetElementType;

        public MultiRValueNestedDeclaration(String declaration, String targetType,
                                            String targetElementType)
        {
            super(declaration, targetType);
            this.targetElementType = targetElementType;
        }
    }

    public static class ThemeAttributeError extends CompilerError
    {

        private static final long serialVersionUID = 3082224489629723459L;
    }

    public static class RslAttributeError extends CompilerError
    {

        private static final long serialVersionUID = 606263107981414356L;
    }

    public static class LibAttributeError extends CompilerError
    {

        private static final long serialVersionUID = 6302777794984339496L;
    }

    public static class EmbedNotAllowed extends CompilerError
    {

        private static final long serialVersionUID = -6247692654987565435L;
    }

    public static class ClearNotAllowed extends CompilerError
    {
    	private static final long serialVersionUID = -307322186643423229L;
    }
    
    public static class InvalidPreLoaderClassName extends CompilerError
	{
		private static final long serialVersionUID = -1419336460920873288L;
        public String className;
		public InvalidPreLoaderClassName(String className) { this.className = className; }
	}
    
    public static class InvalidSplashScreenImageClassName extends CompilerError
	{
		private static final long serialVersionUID = -4647232290960588369L;
		public String className;
		public InvalidSplashScreenImageClassName(String className) { this.className = className; }
	}
    
    public static class InvalidRuntimeDPIProviderClassName extends CompilerError
	{
		private static final long serialVersionUID = -2342232946832901971L;
		public String className;
		public InvalidRuntimeDPIProviderClassName(String className) { this.className = className; }
	}
}
