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

import flex2.compiler.CompilationUnit;
import flex2.compiler.mxml.InvalidStateSpecificValue;
import flex2.compiler.mxml.MXMLNamespaces;
import flex2.compiler.mxml.MxmlConfiguration;
import flex2.compiler.mxml.dom.*;
import flex2.compiler.mxml.lang.*;
import flex2.compiler.mxml.reflect.*;
import flex2.compiler.mxml.rep.*;
import flex2.compiler.mxml.rep.init.Initializer;
import flex2.compiler.util.CompilerMessage.CompilerError;
import flex2.compiler.util.CompilerMessage.CompilerWarning;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.QName;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.Map;

/**
 * This builder handles building a Model instance from a Node and it's
 * children.
 *
 * @author Clement Wong
 */
public class ComponentBuilder extends AbstractBuilder
{
	ComponentBuilder(CompilationUnit unit, TypeTable typeTable, MxmlConfiguration mxmlConfiguration, MxmlDocument document,
            Model parent, String name, String state, boolean topLevelChild, BindingHandler bindingHandler)
    {
		super(unit, typeTable, mxmlConfiguration, document);

        this.parent = parent;
        this.topLevelChild = topLevelChild;
        this.bindingHandler = bindingHandler;

        if (bindingHandler == null)
        {
            this.bindingHandler = new ComponentDeclarationBindingHandler();
        }

        this.name = name;
        this.state = state;

        this.attributeHandler = new ComponentAttributeHandler();
        this.childNodeHandler = new ComponentChildNodeHandler(typeTable);

    }

    protected Model parent;
    protected boolean topLevelChild;
	private String name;
	private String state;
    protected BindingHandler bindingHandler;	
    protected ComponentAttributeHandler attributeHandler;
    protected ComponentChildNodeHandler childNodeHandler;

    Model component;

    /**
     * 
     */
    public void analyze(Node node)
    {
        assert component == null : "ComponentBuilder.analyze(Node) called twice";

        Type type = nodeTypeResolver.resolveType(node, document);

        constructComponent(type, node.beginLine);
        component.setParentIndex(name, state);
        
        processAttributes(node, type);
        processChildren(node, type);

       // NOTE: must do this after processing, due to/until removal of swapout of this.component in processTextInitializer
        registerModel(node, component, topLevelChild);
    }
    
    /**
     * 
     */
    public void analyze(LayeredNode node)
    {
        analyze((Node) node);
        processLayerParent(node);
    }

    /**
     * 
     */
    public void analyze(ScriptNode node)
    {
        // scripts are added to document info in InterfaceCompiler
    }
    
    /**
     * 
     */
    public void analyze(DesignLayerNode node)
    {
    	Type type = nodeTypeResolver.resolveType(node, document);

    	component = new DesignLayer(document, type, node.beginLine);      
        processAttributes(node, type);
        processLayerParent(node);
        document.addLayerModel(node, (DesignLayer) component);
        
        // Only register if we know we actually will be using this layer
        // model at runtime.  We currently optimize away layers with no 
        // id and no attributes.
        if (node.getAttributeCount() > 0)
        {
            registerModel(node, component, true);
        }
    }
    
    
    /**
     * 
     */
    public void analyze(ReparentNode node)
    {
        Type type = nodeTypeResolver.resolveType(node, document);
        String target = (String) node.getAttributeValue("target");
        component = new Reparent(document, type, parent, target, node.beginLine);
        processAttributes(node, type);
    }

    /**
     * 
     */
    public void analyze(StateNode node)
    {
        Type type = nodeTypeResolver.resolveType(node, document);
        constructComponent(type, node.beginLine);
        processAttributes(node, type);
        registerModel(node, component, topLevelChild);
        
        if (document.getVersion() < 4)
        {
        	// Only process children for legacy stateful documents.
        	processChildren(node, type);
        }
        else 
        {
        	document.registerState(component, node);
        	
        	// Ensure user knows they cannot explicitly declare overrides
        	// with the 2009 (Flex 4) syntax.
        	if (node.getChildCount() > 0 || node.getAttributeValue("overrides") != null)
        	{
        		log(node.beginLine, new InvalidOverrideDeclaration());
        	}
        }   
    }
    
    /**
     * 
     */
    protected void constructComponent(Type type, int line)
    {
        component = standardDefs.isIUIComponent(type) ? 
                        new MovieClip(document, type, parent, line) : 
                        new Model(document, type, parent, line);

        if (type.equals(typeTable.objectType))
        {
            component.setInspectable(true);
        }
    }

    /**
     * 
     */
    protected void processAttributes(final Node node, Type type)
    {
        processSpecialAttributes(node);

        for (Iterator iter = node.getAttributeNames(); iter.hasNext();)
        {
            attributeHandler.invoke(node, type, (QName) iter.next());
        }
    }

    /**
     * 
     */
    protected void processLayerParent(final LayeredNode node)
    {
        DesignLayerNode layerParent = node.getLayerParent();
        if (layerParent != null)
        {
            while (layerParent != null)
            {
                if (layerParent.getAttributeCount() > 0)
                {
                    // We currently optimize away layers that have no id and no
                    // attributes set, OR layers that do not have an id but have
                    // the default values for both alpha and visible. We 
                	// automatically persist layers with state-specific attributes.
                    Boolean hasStatefulAttrs = hasStateSpecificAttributes(layerParent);
                    String alphaValue = (String) layerParent.getAttributeValue("alpha");
                    String visibleValue = (String) layerParent.getAttributeValue("visible");
                    String idValue = (String) layerParent.getAttributeValue("id");
                    
                    Boolean opaque = (alphaValue != null && (alphaValue.equals("1.0") || 
                        alphaValue.equals("1"))) || alphaValue == null;
                    
                    Boolean visible = (visibleValue != null && visibleValue.equals("true")) || 
                        visibleValue == null;
                    
                    if (!(idValue == null && opaque && visible) || hasStatefulAttrs)
                        break;
                }
                layerParent = layerParent.getLayerParent();
            }
            
            if (layerParent != null)
            {
                DesignLayer layerModel = document.getLayerModel(layerParent);
                if (layerModel == null)
                {
                    ComponentBuilder builder = new ComponentBuilder(unit, typeTable, mxmlConfiguration, 
                        document, component, null, null, true, null);
                    layerParent.analyze(builder);
                    layerModel = (DesignLayer) builder.component;
                }       
                component.layerParent = layerModel;
            }
        }
    }
    
    /**
     * Private helper which is used to determine if a given Node
     * contains state-specific properties.
     */
    private Boolean hasStateSpecificAttributes(Node node)
    {
    	for (Iterator<QName> attributes = node.getAttributeNames(); 
    	    attributes != null && attributes.hasNext();)
    	{
    		QName qname = attributes.next();
    		String localPart = qname.getLocalPart();
    		if (TextParser.isScopedName(localPart))
    		    return true;
    	}	
    	return false;
    }
    
    
    /**
     * Component specific attribute handler.
     */
    protected class ComponentAttributeHandler extends AttributeHandler
    {
        protected boolean isSpecial(String namespace, String localPart)
        {
            return isSpecialAttribute(namespace, localPart);
        }

        protected void special(Type type, String namespace, String localPart)
        {
            // TODO: Special attributes already handled in
            // processSpecialAttributes(), but they really should be handled
            // here.
        }

        protected void qualifiedAttribute(Node node, Type type, String namespace, String localPart)
        {
            int version = document.getVersion();

            if (version < 4)
            {
                // Prior to Flex 4, MXML does not allow namespace qualification
                // on attributes at all.
                unknownNamespace(namespace, localPart);
            }
            else if (namespace.equals(document.getLanguageNamespace()))
            {
                // Language attributes should have been discovered as special
                // attributes above, so any other attribute in this
                // namespace are considered unknown language attributes
                unknown(namespace, localPart);
            }
            else if (namespace.equals(node.getNamespace()))
            {
                // The attribute is qualified in the component node's namespace,
                // so process it normally
                invoke(type, namespace, localPart);
            }

            // else, we ignore any other namespaced attributes as private
            // annotations
        }

        protected void event(Event event)
        {
            checkEventDeprecation(event, document.getSourcePath(), line);
            processEventText(event, text, line, component);
        }

        protected void states(Property property)
        {
            property(property);
        }

        protected void property(Property property)
        {
            processPropertyText(property, text, AbstractBuilder.TextOrigin.FROM_ATTRIBUTE, line, component);
        }

        protected void effect(Effect effect)
        {
            checkEffectDeprecation(effect, document.getSourcePath(), line);
            processEffectText(effect, text, AbstractBuilder.TextOrigin.FROM_ATTRIBUTE, line, component);
        }

        protected void style(Style style)
        {
            checkStyleDeprecation(style, document.getSourcePath(), line);
            processStyleText(style, text, AbstractBuilder.TextOrigin.FROM_ATTRIBUTE, line, component);
        }

        protected void dynamicProperty(String name, String state)
        {
            processDynamicPropertyText(name, text, AbstractBuilder.TextOrigin.FROM_ATTRIBUTE, line, component, state);
        }

        protected void unknownNamespace(String namespace, String localPart)
        {
            log(line, new UnknownNamespace(namespace, text));
        }

        protected void unknown(String namespace, String localPart)
        {
            String styleThemes = type.getStyleThemes(localPart);

            if (type.isExcludedStyle(localPart))
            {
                    log(line, new ExcludedStyleProperty(localPart,
                                                        NameFormatter.toDot(component.getType().getName())));
            }
            else if (styleThemes != null)
            {
                if (mxmlConfiguration.reportInvalidStylesAsWarnings())
                {
                    log(line, new InvalidStyleThemeWarning(localPart,
                                                           NameFormatter.toDot(component.getType().getName()),
                                                           styleThemes));
                }
                else
                {
                    log(line, new InvalidStyleThemeError(localPart,
                                                         NameFormatter.toDot(component.getType().getName()),
                                                         styleThemes));
                }
            }
            else
            {
                unknownAttributeError(namespace, localPart, line);
            }
        }

        protected void invoke(Type type, String namespace, String localPart)
        {
            if (TextParser.isScopedName(localPart))
            {
            	if (document.getVersion() >= 4)
            	{
	                // Here we detect and process any state-specific attribute values.
	                // We also ensure declaration of the component so that our state
	                // overrides can find and apply state-specific properties.
	                String[] statefulName = TextParser.analyzeScopedName(localPart);
	                if ((statefulName != null) && document.validateState(statefulName[1], line))
	                {
	                	if (isSpecial(namespace, statefulName[0]))
	                	{
	                		// Language attributes may not be state-specific.
	                		log(line, new InvalidStateSpecificValue(statefulName[0]));
	                	}
	                	else
	                	{
	                		component.ensureDeclaration();
	                		component.ensureBindable();
	                		super.invoke(type, namespace, statefulName[0], statefulName[1]);
	                	}
	                } 
	                else if (statefulName == null)
	                {
	                    unknownAttributeError(namespace, localPart, line);
	                }
                }
                else
                {
                    // We only support state-scoped identifiers in MXML 2009 and later.
                    log(line, new UnsupportedStatefulPropertySyntax(localPart));
                }
            } 
            else
            {
                super.invoke(type, namespace, localPart);
            }
        }
    }

    /**
     * 
     */
    protected void unknownAttributeError(String namespace, String localPart, int line)
    {
        if (namespace != null && namespace.length() > 0)
            log(line, new UnknownQualifiedAttribute(namespace, localPart, NameFormatter.toDot(component.getType().getName())));
        else
            log(line, new UnknownAttribute(localPart, NameFormatter.toDot(component.getType().getName())));
    }

    /**
     * 
     */
    protected void processChildren(Node node, Type type)
    {
        childNodeHandler.scanChildNodes(node, type);

        if (!childNodeHandler.getDefaultPropertyNodes().isEmpty())
        {
            processPropertyNodes(childNodeHandler.getDefaultPropertyNodes(), type.getDefaultProperty(), component, node.beginLine);
        }
    }

    /**
     * 
     */
    protected class ComponentChildNodeHandler extends ChildNodeHandler
    {
        protected Collection<Node> defaultPropertyNodes;

        public ComponentChildNodeHandler(TypeTable typeTable)
        {
            super(typeTable, MXMLNamespaces.FXG_2008_NAMESPACE.equals(document.getLanguageNamespace()));
        }
    
        public Collection<Node> getDefaultPropertyNodes()
        {
            return defaultPropertyNodes != null ? defaultPropertyNodes : Collections.<Node>emptyList();
        }

    protected void addDefaultPropertyNode(Node node)
    {
        (defaultPropertyNodes != null ? defaultPropertyNodes : (defaultPropertyNodes = new ArrayList<Node>(1))).add(node);
    }

        // ChildNodeHandler impl

        protected void event(Event event)
        {
            CDATANode cdata = getTextContent(child.getChildren(), false);
            if (cdata != null)
            {
                processEventText(event, cdata.image, cdata.beginLine, component);
            }
        }

        protected void states(Property property)
        {
            property(property);
            
            if (document.getVersion() >= 4)
            {
            	// We still allow for validation to occur and attributes on each
            	// State node to be processed, however for Flex 4 and later, we suppress
            	// the states property from being declared, since our stateful
            	// document model has specialized handling for the State nodes.

            	Map<String, Initializer> properties = component.getProperties();
            	properties.remove(property.getName());
            	
                if (property.isStateSpecific())
                {
                	// Flag an error if someone is attempting to use state attributes
                	// with the 'states' attribute.
                	log(child, new InvalidStateSpecificValue(StandardDefs.PROP_UICOMPONENT_STATES));
                }
            }
        }

        protected void property(Property property)
        {
            Type type = property.getType();
            if (checkNonEmpty(child, type))
            {
                processPropertyNodes(child, property, component);
            } 
            else if (typeTable.stringType.isAssignableTo(type)) 
            {
                processPropertyText(property, "", AbstractBuilder.TextOrigin.FROM_CHILD_CDATA, child.beginLine, component);
            }
            else if (typeTable.arrayType.isAssignableTo(type)) 
            {
                processPropertySyntheticArray(property, child.beginLine, component);	
            }
        }

        protected void effect(Effect effect)
        {
            if (checkNonEmpty(child, typeTable.classType))
            {
                processEffectNodes(child, effect, component);
            }
        }

        protected void style(Style style)
        {
            Type type = style.getType();
            if (checkNonEmpty(child, type))
            {
                processStyleNodes(child, style, component);
            } 
            else if (allowEmptyDefault(type))
            {
                processStyleText(style, "", AbstractBuilder.TextOrigin.FROM_CHILD_CDATA, child.beginLine, component);
            }
        }

        protected void dynamicProperty(String name, String state)
        {
            Type type = typeTable.objectType;
            if (checkNonEmpty(child, type))
            {
                DynamicProperty dynamicProperty = typeTable.getDynamicProperty(name, state);
                processDynamicPropertyNodes(child, dynamicProperty, component);
            } 
            else if (allowEmptyDefault(type))
            {
                processDynamicPropertyText(name, "", AbstractBuilder.TextOrigin.FROM_CHILD_CDATA, child.beginLine, component, state);
            }
        }

        protected void defaultPropertyElement(boolean locError)
        {
            if (locError)
            {
                log(child, new NonContiguous(NameFormatter.retrieveClassName(parentType.getName()), 
                    parentType.getDefaultProperty().getName()));
            }

            Type childType = nodeTypeResolver.resolveType(child, document);

            if (standardDefs.isRepeater(childType) && !standardDefs.isContainer(parentType))
            {
                log(child, new RepeatersRequireHaloContainerParent());
            }
            else
            {
                addDefaultPropertyNode(child);
            }
        }

        protected void nestedDeclaration()
        {
            nestedDeclaration(true);
        }

        /**
         * Note that here is where we implement the visual-child-of-visual-container special case, as well as the 
         * (urp) RadioButtonGroup special case.
         */
        protected void nestedDeclaration(boolean checkHaloNavigatorRequirements)
        {
            Type childType = nodeTypeResolver.resolveType(child, document);
            assert childType != null : "nested declaration node type == null, node = " + child.image;
            String mimeType = document.getCompilationUnit().getSource().getMimeType();

            // Halo navigators (Accordion, TagNavigator, and
            // ViewStack) only support container based children.
            if (checkHaloNavigatorRequirements &&
                standardDefs.isHaloNavigator(parentType) &&
                !standardDefs.isNavigatorContent(childType) &&
                !(child instanceof ReparentNode))
            {
                log(child, new HaloNavigatorsRequireHaloContainerChildren());
            }
            // For containers with a visual nested declaration, handle
            // the child as a visual child for version 3- documents or
            // if the default property is null.
            else if (standardDefs.isContainer(parentType) && standardDefs.isIUIComponent(childType) && 
                     ((mimeType.equals(MimeMappings.MXML) && (document.getVersion() < 4)) || 
                      (parentType.getDefaultProperty() == null)))
            {
                processVisualChild(child);
            } 
            else if ((standardDefs.isContainer(parentType) && 
                     (childType.isAssignableTo(standardDefs.CLASS_RADIOBUTTONGROUP) || 
                      childType.isAssignableTo(standardDefs.CLASS_SPARK_RADIOBUTTONGROUP))) ||
                     (child instanceof ReparentNode))
            {
				ComponentBuilder builder = new ComponentBuilder(unit, typeTable, mxmlConfiguration, document, component, null, null, true, null);
                child.analyze(builder);
            } 
            else
            {
                processNestedDeclaration(childType);
            }
        }

        /**
         * Note: actual nested declarations are only allowed at the root level - see override in ApplicationChildNodeHandler. 
         * Note: put out a slightly more verbose error if we're within an IContainer, since they may have meant to 
         * specify a visual child.
         */
        protected void processNestedDeclaration(Type childType)
        {
            if (standardDefs.isSparkGraphic(childType))
            {
                log(child, new SparkPrimitiveInHalo(child.getLocalPart(), parent.getLocalPart()));
            }
            else if (standardDefs.isContainer(parentType))
            {
                log(child, new NestedFlexDeclaration(NameFormatter.toDot(standardDefs.INTERFACE_IUICOMPONENT)));
            } 
            else
            {
                log(child, new NestedDeclaration());
            }
        }

        protected void textContent()
        {
            if (parent.getChildCount() > 1)
            {
                log(child, new MixedContent());
            }
            else if (hasAttributeInitializers(parent))
            {
                log(child, new InitializersNotAllowed());
            }
            else
            {
                processTextInitializer((CDATANode) child);
            }
        }

        protected void languageNode()
        {
            if (isLegalLanguageNode(child))
            {
                child.analyze(ComponentBuilder.this);
            } 
            else
            {
                log(child, new IllegalLanguageNode(child.image));
            }
        }

        protected void invoke(Node parent, Type parentType, Node child)
        {
            this.parent = parent;
            this.parentType = parentType;
            this.child = child;

            if (NodeTypeResolver.isValueNode(child))
            {
                String namespace = child.getNamespace(), localPart = child.getLocalPart();

                if (child.getAttributeCount() == 0 && namespace.equals(this.parent.getNamespace()))
                {
                    // Here we detect and process any state-specific value nodes.
                    // We also ensure declaration of the component so that our state
                    // overrides can find and apply state-specific properties.
                    if (TextParser.isScopedName(localPart))
                    {
                        String[] statefulName = TextParser.analyzeScopedName(localPart);
                        
                        if ((document.getVersion() >= 4))
                        {
                            if ((statefulName != null) && document.validateState(statefulName[1], child.beginLine))
                            {
                                component.ensureDeclaration();
                                component.ensureBindable();
                                invoke(this.parentType, namespace, statefulName[0], statefulName[1]);
                            }
                        }
                        else
                        {
                            // We only support state-scoped identifiers in MXML 2009 and later.
                            log(child, new UnsupportedStatefulPropertySyntax(localPart));
                        }
                    } 
                    else
                    {
                        coreDeclarationHandler.invoke(this.parentType, namespace, localPart);
                    }
                } 
                else
                {
                    // System.out.println(msg + "unknown()");
                    // WARNING: passing null is only okay as long as name
                    // remains unused in the implementation of unknown()...
                    // if you're not sure, use this: unknown(new
                    // QName(namespace, localPart).toString());
                    unknown(null, null);
                }
            } 
            else
            {
                super.invoke(parent, parentType, child);
            }
        }
    }

    /**
     * Component specific binding handler.
     */
    protected static class ComponentDeclarationBindingHandler implements BindingHandler
    {
        public BindingExpression invoke(BindingExpression bindingExpression, Model dest)
        {
            bindingExpression.setDestination(dest);
            return bindingExpression;
        }
    }

    /**
     * TODO can we make these top-level only?
     */
    protected boolean isLegalLanguageNode(Node node)
    {
    Class<? extends Node> nodeClass = node.getClass();
        return nodeClass == ScriptNode.class 
            || nodeClass == DeclarationsNode.class 
            || nodeClass == LibraryNode.class
            || nodeClass == ReparentNode.class;
    }

    /**
     * process visual child of visual container
     */
    protected void processVisualChild(Node node)
    {
		ComponentBuilder builder = new ComponentBuilder(unit, typeTable, mxmlConfiguration, document, component, null, null, false, null);
        node.analyze(builder);
        ((MovieClip) component).addChild((MovieClip) builder.component);
    }

    /**
     * 
     */
    protected void processTextInitializer(CDATANode cdata)
    {
        if (!component.isEmpty())
        {
            log(cdata.beginLine, new MixedInitializers());
        } 
        else
        {
            String text = cdata.image;
            Type type = component.getType();
            int line = cdata.beginLine;

            int flags = cdata.inCDATA ? TextParser.FlagInCDATA : 0;
            Object value = textParser.parseValue(text, type, typeTable.objectType, flags, line, NameFormatter.toDot(type.getName()));

            if (value != null)
            {
                if (value instanceof BindingExpression)
                {
                    if (bindingHandler != null)
                    {
                        bindingHandler.invoke((BindingExpression) value, component);
                    }
                    else
                    {
                        log(line, new BindingNotAllowed());
                    }
                } 
                else
                {
                    //  Note: here we're in an atypical situation. We've encountered a text initializer for something we
                    //  thought was a (non-Primitive) component. This may happen e.g. when primitives are exposed in MXML
                    //  namespaces other than MXML_NAMESPACE. (NOTE also that all global definitions are implictly
                    //  available in the namespace "*", due to the optimistic approach used NameMappings for package-style
                    //  namespaces. We may want to suppress this at some point, but it would require changing NM's approach.)
                    //  When this happens, the parser will package (e.g.) <String>foo</String> in an ordinary Node rather
                    //  than the corresponding type-specific node, e.g. StringNode, etc. That will bring us here.
                    //  TODO finish generalizing the processing of class-backed MXML tags. This will eliminate this
                    //  special case, the various type-specific primitive node classes, and so on.
                    //  Until then, the MO here is: swap our prepped component member variable for the appropriate
                    //  replacement containing the parsed value, carrying over the already-registered id.

                    Model preppedComponent = component;

                    if (value instanceof Model)
                    {
                        // textParser has returned a Model
                        component = (Model) value;
                    } 
                    else
                    {
                        // textParser has returned a POJO
                        component = new Primitive(document, preppedComponent.getType(), value, line);
                    }

                    component.setId(preppedComponent.getId(), preppedComponent.getIdIsAutogenerated());
                }
            }
        }
    }

    /**
     * Currently, our only prohibition is on setting UIComponent.states[] on anything but a root UIComponent. 
     * (AbstractDocumentBuilder re-subclasses to allow the root case.)
     */
    protected boolean isAllowedProperty(Property property)
    {
        if (property.getName().equals(StandardDefs.PROP_UICOMPONENT_STATES) && 
                property.getType().equals(typeTable.arrayType)) //&& 
                //component.getType().isAssignableTo(standardDefs.CLASS_UICOMPONENT))
        {
            return false;
        }

        return true;
    }

    /**
     * Subclasses should override this method to define what they consider
     * special attributes.
     */
    protected boolean isSpecialAttribute(String namespace, String localPart)
    {
        boolean isSpecial = false;

        // Prior to Flex 4, special attributes were not namespace qualified and
        // were always seen as special attributes.
        if (document.getVersion() < 4)
        {
            if (namespace.length() == 0 && StandardDefs.PROP_ID.equals(localPart))
                isSpecial = true;
        }
        else
        {
            // If unqualified, special attributes always win over
            // properties. Developers can qualify properties using the
            // component node's namespace to disambiguate. Language attributes
            // can also be qualified using the language namespace too.
            if (namespace.length() == 0 ||
                namespace.equals(document.getLanguageNamespace())) 
            {
                if (StandardDefs.PROP_ID.equals(localPart) ||
                    StandardDefs.PROP_INCLUDE_STATES.equals(localPart) || 
                    StandardDefs.PROP_EXCLUDE_STATES.equals(localPart) ||
                    StandardDefs.PROP_ITEM_CREATION_POLICY.equals(localPart) ||
                    StandardDefs.PROP_ITEM_DESTRUCTION_POLICY.equals(localPart))
                {
                    isSpecial = true;
                }
            }
        }

        return isSpecial;
    }

    /**
     * process special attributes, like "id"... Subclasses, e.g. AbstractDocumentBuilder, can override 
     * processSpecialAttributes() to process "usePreloader", "preloader", etc...
     */
    protected void processSpecialAttributes(Node node)
    {
        // Here we process special attributes 'includedStates' and 'excludedStates', so that
        // we detect and process any state-specific nodes.
        processStateAttributes(node, component);
    }

    public static class ExcludedStyleProperty extends CompilerError
    {
        private static final long serialVersionUID = -655374071288180326L;

        public String stylePropertyName;
        public String typeName;

        public ExcludedStyleProperty(String stylePropertyName, String typeName)
        {
            this.stylePropertyName = stylePropertyName;
            this.typeName = typeName;
        }
    }

    public static class InvalidStyleThemeError extends CompilerError
    {
        private static final long serialVersionUID = -655374071288180327L;

        public String stylePropertyName;
        public String typeName;
        public String styleThemes;

        public InvalidStyleThemeError(String stylePropertyName,
                                      String typeName, String styleThemes)
        {
            this.stylePropertyName = stylePropertyName;
            this.typeName = typeName;
            this.styleThemes = styleThemes;
        }
    }

    public static class InvalidStyleThemeWarning extends CompilerWarning
    {
        private static final long serialVersionUID = -655374071288180328L;

        public String stylePropertyName;
        public String typeName;
        public String styleThemes;

        public InvalidStyleThemeWarning(String stylePropertyName,
                                        String typeName, String styleThemes)
        {
            this.stylePropertyName = stylePropertyName;
            this.typeName = typeName;
            this.styleThemes = styleThemes;
        }
    }

    public static class UnknownNamespace extends CompilerError
    {
        private static final long serialVersionUID = -2726612392306645841L;
        public String namespace;
        public String text;

        public UnknownNamespace(String namespace, String text)
        {
            this.namespace = namespace;
            this.text = text;
        }
    }

    public static class UnknownAttribute extends CompilerError
    {
        private static final long serialVersionUID = 9083393507315473854L;
        public String name;
        public String type;

        public UnknownAttribute(String name, String type)
        {
            this.name = name;
            this.type = type;
        }
    }

    public static class UnknownQualifiedAttribute extends CompilerError
    {
        private static final long serialVersionUID = -154678836882378518L;
        public String namespace;
        public String localPart;
        public String type;

        public UnknownQualifiedAttribute(String namespace, String localPart, String type)
        {
            this.namespace = namespace;
            this.localPart = localPart;
            this.type = type;
        }
    }

    public static class NonContiguous extends CompilerError
    {
        private static final long serialVersionUID = -1292997329913440526L;
    	public String parentTypeName;
    	public String propertyName;
        
        public NonContiguous(String parentTypeName, String propertyName)
        {
            this.parentTypeName = parentTypeName;
            this.propertyName = propertyName;
        }
    }

    public static class NestedFlexDeclaration extends CompilerError
    {
        private static final long serialVersionUID = 8825421061991216942L;
        public String interfaceName;

        public NestedFlexDeclaration(String interfaceName)
        {
            this.interfaceName = interfaceName;
        }
    }

    public static class SparkPrimitiveInHalo extends CompilerError
    {
        private static final long serialVersionUID = -4291778911086982102L;
        public String type;
        public String parentType;

        public SparkPrimitiveInHalo(String type, String parentType)
        {
            this.type = type;
            this.parentType = parentType;
        }
    }

    public static class NestedDeclaration extends CompilerError
    {

        private static final long serialVersionUID = 5826513690825239320L;
    }

    public static class MixedContent extends CompilerError
    {

        private static final long serialVersionUID = 1917736469938208273L;
    }

    public static class InitializersNotAllowed extends CompilerError
    {

        private static final long serialVersionUID = -4021816606896363410L;
    }

    public static class IllegalLanguageNode extends CompilerError
    {
        private static final long serialVersionUID = 7624702544805022417L;
        public String image;

        public IllegalLanguageNode(String image)
        {
            this.image = image;
        }
    }

    public static class MixedInitializers extends CompilerError
    {
        private static final long serialVersionUID = 2254406874080898341L;
    }
    
    public static class InvalidOverrideDeclaration extends CompilerError
    {
        private static final long serialVersionUID = 2254406474080898341L;
    }
    
    public static class HaloNavigatorsRequireHaloContainerChildren extends CompilerError
    {
    }

    public static class RepeatersRequireHaloContainerParent extends CompilerError
    {
    }
    
    public static class UnsupportedStatefulPropertySyntax extends CompilerError
    {
        private static final long serialVersionUID = 7624702513255022417L;
        public String name;

        public UnsupportedStatefulPropertySyntax(String propertyName)
        {
            this.name = propertyName;
        }
    }
}
