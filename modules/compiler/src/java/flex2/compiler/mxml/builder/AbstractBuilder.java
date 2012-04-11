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
import flex2.compiler.SymbolTable;
import flex2.compiler.util.CompilerMessage.CompilerError;
import flex2.compiler.util.CompilerMessage.CompilerWarning;
import flex2.compiler.mxml.MXMLNamespaces;
import flex2.compiler.mxml.MxmlConfiguration;
import flex2.compiler.mxml.dom.*;
import flex2.compiler.mxml.lang.*;
import flex2.compiler.mxml.reflect.*;
import flex2.compiler.mxml.rep.*;
import flex2.compiler.util.MxmlCommentUtil;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.QName;
import flex2.compiler.util.ThreadLocalToolkit;

import java.util.Collection;
import java.util.Iterator;

/**
 * This base class contains code common to all the builders.
 *
 * @author Clement Wong
 */
public abstract class AbstractBuilder extends AnalyzerAdapter
{
    protected TypeTable typeTable;
    protected MxmlDocument document;

    protected NodeTypeResolver nodeTypeResolver;
    protected TextValueParser textParser;
    protected RValueNodeHandler rvalueNodeHandler;

	AbstractBuilder(CompilationUnit unit, TypeTable typeTable, MxmlConfiguration mxmlConfiguration, MxmlDocument document)
	{
		super(unit, mxmlConfiguration);

        this.typeTable = typeTable;
        this.document = document;

        this.nodeTypeResolver = new NodeTypeResolver(typeTable);
        this.textParser = new TextValueParser(typeTable);
        this.rvalueNodeHandler = new RValueNodeHandler();
    }

    /**
     * AbstractBuilder-generic text value parser. Uses AbstractBuilder members for e.g. document access, error reporting.
     * <p/>Also, importantly, implements some universal side-effects for certain parsed values, including:
     * <li/>- parsed binding expressions are turned into BindingExpression objects, and added to the builder's MxmlDocument
     * <li/>- parsed @Embed expressions are turned into AtEmbed objects, and added to the builder's document
     * <li/>- parsed values for Class-typed properties (i.e., class names) are added as imports to the builder's document
     * <p/>Subclasses may provide custom entry points and handlers.
     */
    protected class TextValueParser extends TextParser
    {
        protected String lvalueName;
        protected int line;
        protected String desc;
        protected boolean wasPercentage;

        TextValueParser(TypeTable typeTable)
        {
            super(typeTable, mxmlConfiguration.getCompatibilityVersion());
        }

        /**
         *
         */
        public Object parseValue(String text, Type type, int flags, int line, String desc)
        {
            return parseValue(text, type, typeTable.objectType, flags, line, desc);
        }

        /**
         *
         */
        public Object parseValue(String text, Type type, Type elementType, int flags, int line, String desc)
        {
            this.line = line;
            this.desc = desc;
            this.wasPercentage = false;

            // We ignore binding syntax in FXG values
            if (document != null && MXMLNamespaces.FXG_2008_NAMESPACE.equals(document.getLanguageNamespace()))
            {
                flags = flags | TextParser.FlagIgnoreBinding;
                flags = flags | TextParser.FlagIgnoreArraySyntax;
                flags = flags | TextParser.FlagIgnoreAtFunctionEscape;
            }

            return super.parse(text, type, elementType, flags);
        }

        /**
         * prevent subclasses from inadvertantly calling super utility routine
         */
        protected Object parse(String text, Type type, Type elementType, int flags)
        {
            assert false : "internal parse() called";
            return null;
        }
        
        /*
         * (non-Javadoc)
         * @see flex2.compiler.mxml.lang.TextParser#parseBindingExpression(String, int)
         */
        protected BindingExpression parseBindingExpression(String text, int line)
        {
            this.line = line;
            this.desc = null;
            return super.parseBindingExpression(text);
        }
        
        /**
         *
         */
        public boolean wasPercentage()
        {
            return wasPercentage;
        }
        
        //  TextParser impl

		/**
		 *
		 */
		public String contextRoot(String text)
		{
			String contextRoot = mxmlConfiguration.getContextRoot();
			if (contextRoot == null)
			{
				error(ErrUndefinedContextRoot, text, null, null);
				return null;
			}
			else
			{
				return text.replaceAll("@ContextRoot\\(\\)", contextRoot);
			}
		}

        /**
         * Handles an @Clear() directive.
         */
        public Object clear()
        {
            AtClear atClear = new AtClear(unit.getSource(), line);
            return atClear;
        }
        
        /**
         *
         */
        public Object embed(String text, Type type)
        {
            boolean strType = type.isAssignableTo(typeTable.stringType);
            AtEmbed atEmbed = AtEmbed.create(typeTable.getPerCompileData(), unit.getSource(), line, text, strType);
            if (atEmbed != null)
            {
                document.addAtEmbed(atEmbed);

                if (standardDefs.isIFactory(type))
                {
                    return factoryFromClass(atEmbed.getPropName(), line);
                }
                else if (standardDefs.isIDeferredInstance(type))
                {
                    return instanceFromClass(atEmbed.getPropName(), line, false);
                }

                return atEmbed;
            }
            else
            {
                return null;
            }
        }

        /**
         * Handles an @Resource() directive.
         * @param text The @Resource() directive that was parsed as the attribute value,
         * such as "@Resource(bundle='MyResources', key='OPEN')"
         * @param type Specifies the type (e.g., a String or an int) for the MXML attribute
         */
        public Object resource(String text, Type type)
        {
            AtResource atResource = AtResource.create(typeTable, unit.getSource(), line, text, type);
            if (atResource != null)
            {
                document.addAtResource(atResource);
                return atResource;
            }
            else
            {
                return null;
            }
        }

        /**
         *
         */
        public Object bindingExpression(String converted)
        {
            return bindingExpression(converted, false);
        }

        /**
        *
        */
       public Object bindingExpression(String converted, boolean isTwoWay)
       {
           BindingExpression be = new BindingExpression(converted, line, document);
           be.setTwoWayPrimary(isTwoWay);

           return be;
       }

       /**
         * set was-percentage flag and return percentage as Integer. Subclasses might do prop-name swapping, etc.
         */
        public Object percentage(String pct)
        {
            this.wasPercentage = true;
            return Double.valueOf(pct.substring(0, pct.indexOf('%')));
        }

        /**
         *
         */
        public Object array(Collection entries, Type elementType)
        {
            Array array = new Array(document, line, elementType);
            array.addEntries(entries, line);
            return array;
        }

        /**
         *
         */
        public Object functionText(String text)
        {
            return text;
        }

        /**
         *
         */
        public Object className(String name, Type lvalueType)
        {
            document.addImport(name, line);
            if (standardDefs.isIFactory(lvalueType))
            {
                return factoryFromClass(name, line);
            }
            else if (standardDefs.isIDeferredInstance(lvalueType))
            {
                return instanceFromClass(name, line, true);
            }
            else
            {
                assert lvalueType.equals(typeTable.classType);
                return name;
            }
        }

        /**
         *
         */
        public void error(int err, String text, Type type, Type elementType)
        {
            switch(err)
            {
                case ErrTypeNotContextRootable:
                    log(line, new TypeNotContextRootable(desc, NameFormatter.toDot(type.getName())));
                    break;

                case ErrUndefinedContextRoot:
                    log(line, new UndefinedContextRoot());
                    break;

                case ErrTypeNotEmbeddable:
                    log(line, new TypeNotEmbeddable(desc, NameFormatter.toDot(type.getName())));
                    break;

                case ErrInvalidTextForType:
                    log(line, new InvalidTextForType(desc,
                                                     NameFormatter.toDot(type.getName()),
                                                     (type.equals(typeTable.arrayType) ? "[" + NameFormatter.toDot(elementType.getName()) + "]" : ""),
                                                     text));
                    break;

                case ErrInvalidPercentage:
                    log(line, new InvalidPercentage(desc, text));
                    break;

                case ErrTypeNotSerializable:
                    log(line, new TypeNotSerializable(desc, NameFormatter.toDot(type.getName())));
                    break;

                case ErrPercentagesNotAllowed:
                    log(line, new PercentagesNotAllowed(desc));
                    break;

                case ErrUnrecognizedAtFunction:
                    log(line, new UnrecognizedAtFunction(desc));
                    break;

                case ErrInvalidTwoWayBind:
                    if (desc != null)
                    {
                        log(line, new InvalidTwoWayBindingInitializer(desc, text));
                    }
                    else
                    {
                        log(line, new InvalidTwoWayBinding(text));                       
                    }
                    
                default:
                    assert false : "unhandled text parse error, code = " + err;
            }
        }
    }

    /**
     * distinguish between different kinds of MXML text - affects parse flags
     */
    public static class TextOrigin
    {
        public static int FROM_ATTRIBUTE = 0;
        public static int FROM_CHILD_TEXT = 1;
        public static int FROM_CHILD_CDATA = 2;

        public static int fromChild(boolean cdata) { return cdata ? FROM_CHILD_CDATA : FROM_CHILD_TEXT; }
    }

    /**
     *
     */
    protected boolean processPropertyText(Property property, String text, int origin, int line, Model model)
    {
        String name = property.getName();

        ensureSingleInitializer(model, name, line, property.getStateName());

        if (!checkPropertyUsage(property, text, line))
        {
            return false;
        }

        int flags =
                ((origin == TextOrigin.FROM_CHILD_CDATA) ? TextParser.FlagInCDATA : 0) |
                (getIsColor(property) ? TextParser.FlagConvertColorNames : 0) |
                ((origin != TextOrigin.FROM_ATTRIBUTE && property.collapseWhiteSpace()) ? TextParser.FlagCollapseWhiteSpace : 0) |
                (getPercentProxy(model.getType(), property, line) != null ? TextParser.FlagAllowPercentages : 0) |
                (property.richTextContent() ? TextParser.FlagRichTextContent : 0);

        Object value = textParser.parseValue(text, property.getType(), property.getElementType(), flags, line, name);

        if (value != null)
        {
            postProcessBindingExpression(value, model, name);

            if (textParser.wasPercentage())
            {
                property = getPercentProxy(model.getType(), property, line);
            } 
            else if ((value instanceof AtClear) && !property.isStateSpecific())
            {
            	log(line, new ClearNotAllowed());
            	return false;
            }

            model.setProperty(property, value, line);
            return true;
        }
        else
        {
            return false;
        }
    }

   /**
    *
    */
    protected void processPropertySyntheticArray(Property property, int line, Model model)
    {
        String name = property.getName();
        ensureSingleInitializer(model, name, line, property.getStateName());
        ArrayBuilder builder = new ArrayBuilder(unit, typeTable, mxmlConfiguration, document);
        builder.createSyntheticArrayModel(line);
        model.setProperty(property, builder.array, line);
    }
    
    /**
     *
     */
    protected boolean processDynamicPropertyText(String name, String text, int origin, int line, Model model, String state)
    {
        ensureSingleInitializer(model, name, line, state);

        int flags = (origin == TextOrigin.FROM_CHILD_CDATA) ? TextParser.FlagInCDATA : 0;

        Object value = textParser.parseValue(text, typeTable.objectType, typeTable.objectType, flags, line, name);

        if (value != null)
        {
            postProcessBindingExpression(value, model, name);

            model.setDynamicProperty(typeTable.objectType, name, value, state, line);

            return true;
        }
        else
        {
            return false;
        }
    }

    /*
     * includeIn and excludeFrom helper. Used to detect state-specific
     * document nodes.
     */
    protected boolean processStateAttributes(Node node, Model model)
    {
        String includedStates = (String)getLanguageAttributeValue(node, StandardDefs.PROP_INCLUDE_STATES);
        String excludedStates = (String)getLanguageAttributeValue(node, StandardDefs.PROP_EXCLUDE_STATES);
        String itemCreationPolicy = (String)getLanguageAttributeValue(node, StandardDefs.PROP_ITEM_CREATION_POLICY);
        String itemDestructionPolicy = (String)getLanguageAttributeValue(node, StandardDefs.PROP_ITEM_DESTRUCTION_POLICY);

        // Check that there isn't a binding expression in the string.
        if (includedStates != null && TextParser.isBindingExpression(includedStates))
        {
            log(node, new BindingNotAllowedInitializer(StandardDefs.PROP_INCLUDE_STATES, includedStates));                
        }

        if (excludedStates != null && TextParser.isBindingExpression(excludedStates))
        {
            log(node, new BindingNotAllowedInitializer(StandardDefs.PROP_EXCLUDE_STATES, excludedStates));                
        }
        
        if (includedStates != null || excludedStates != null)
        {
            Collection<String> includes = TextParser.parseStringList(includedStates);
            Collection<String> excludes = TextParser.parseStringList(excludedStates);

            // Register our state specific node with the document's stateful model.
            document.registerStateSpecificNode(model, node, includes, excludes);
            
            // Register optional creation policy.
            if (itemCreationPolicy != null)
            {
            	if (itemCreationPolicy.equals("immediate"))
            	{
            		document.registerEarlyInitNode(model);
            	}
            	else if (!itemCreationPolicy.equals("deferred"))
            	{
            		log(model.getXmlLineNumber(), new InvalidItemCreationPolicy());
            	}
            }
            
            // Register optional destruction policy.
            if (itemDestructionPolicy != null)
            {
            	if (itemDestructionPolicy.equals("auto"))
            	{
            		model.setIsTransient(true);
            	}
            	else if (!itemDestructionPolicy.equals("never"))
            	{
            		log(model.getXmlLineNumber(), new InvalidItemDestructionPolicy());
            	}
            }
            
            return true;
        }
        
        if (itemCreationPolicy != null)
        {
        	log(model.getXmlLineNumber(), new InvalidItemCreationPolicyUsage());
        }
        
        if (itemDestructionPolicy != null)
        {
        	log(model.getXmlLineNumber(), new InvalidItemDestructionPolicyUsage());
        }
        
        return false;
    }
    
    /*
     * TODO move this to TypeTable.PropertyHelper?
     */
    protected boolean getIsColor(Property property)
    {
        Inspectable inspectable = property.getInspectable();
        if (inspectable != null)
        {
            String type = inspectable.getFormat();
            if (type != null)
            {
                return type.equals(StandardDefs.MDPARAM_INSPECTABLE_FORMAT_COLOR);
            }
        }
        return false;
    }

    /*
     * TODO move this to TypeTable.PropertyHelper?
     */
    protected Property getPercentProxy(Type type, Property property, int line)
    {
        String percentProxyName = property.getPercentProxy();
        if (percentProxyName != null)
        {
            Property percentProxy = type.getProperty(percentProxyName);
            if (percentProxy != null)
            {
            	percentProxy.setStateName(property.getStateName());
                return percentProxy;
            }
            else
            {
                log(line, new PercentProxyWarning(percentProxyName,
                                                  property.getName(),
                                                  NameFormatter.toDot(type.getName())));
                return null;
            }
        }
        else
        {
            return null;
        }
    }

    /**
     *
     */
    private void postProcessBindingExpression(Object value, Model model, String name)
    {
        if (value instanceof BindingExpression)
        {
            BindingExpression bindingExpression = (BindingExpression)value;
            bindingExpression.setDestination(model);
            bindingExpression.setDestinationLValue(name);
            bindingExpression.setDestinationProperty(name);
        }
    }

    /**
     *
     */
    private void ensureSingleInitializer(Model model, String name, int line, String state)
    {
        // Ensure single initialization for non state-specific properties only.
        // State-specific properties validated elsewhere.
        if (model.hasProperty(name) && (state == null))
        {
            //  presence of default property can make error nonobvious, so put out some extra text in that case
            Type type = model.getType();
            Property dp = type.getDefaultProperty();
            if (dp != null && dp.getName().equals(name))
            {
                log(line, new MultiplePropertyInitializerWithDefaultError(name, NameFormatter.toDot(type.getName())));
            }
            else
            {
                log(line, new MultiplePropertyInitializerError(name));
            }
        }
    }

    /**
     *
     */
    protected void processEventText(Event event, String text, int line, Model model)
    {
        //  TODO check for multiple initializers of event.

        if (text.length() > 0)
        {
            //  register Event type as import
            Type eventType = event.getType();
            if (eventType == null)
            {
                log(line, new EventTypeUnavailable(event.getTypeName()));
                return;
            }
            document.addImport(NameFormatter.toDot(eventType.getName()), line);

            // Ensure user only utilizes the @Clear directive for state-specific
            // event properties.
            if (text.equals("@Clear()") && !event.isStateSpecific())
            {
            	log(line, new ClearNotAllowed());
            	return;
            }
            
            // preilly: Don't check for binding expressions,
            // because they are not supported inside event
            // values.  Using curly braces are allowed,
            // because event values are just ActionScript
            // snippets and curly braces are part of the language.
            model.setEvent(event, text, line);
        }
        else
        {
            log(line, new EventHandlerEmpty());
        }
    }

    /**
     *
     */
    public boolean processStyleText(Style style, String text, int origin, int line, Model model)
    {
        String name = style.getName();
        Type type = style.getType();

        if (!style.isStateSpecific() && model.hasStyle(name))
        {
            log(line, new MultipleStyleInitializerError(name));
        }
        
        if (!checkStyleUsage(style, text, line))
        {
            return false;
        }

        int flags =
                ((origin == TextOrigin.FROM_CHILD_CDATA) ? TextParser.FlagInCDATA : 0) |
                (getIsColor(style) ? TextParser.FlagConvertColorNames : 0);

        Object value = textParser.parseValue(text, type, flags, line, name);
        if (value != null)
        {
            if (value instanceof BindingExpression)
            {
                BindingExpression bindingExpression = (BindingExpression)value;
                // two-way data binding expression not allowed here
                if (bindingExpression.isTwoWayPrimary())
                {
                    log(line, new TwoWayBindingNotAllowedInitializer(name, text));
                    return false;
                }                
                bindingExpression.setDestination(model);
                bindingExpression.setDestinationLValue(name);
                bindingExpression.setDestinationStyle(name);
            }
            else if (value instanceof AtClear)
            {
            	if (!style.isStateSpecific())
            	{
            		log(line, new AtClearNotAllowed());
            		return false;
            	}
            }

            model.setStyle(style, value, line);
            return true;
        }
        else
        {
            return false;
        }
    }

    /*
     * TODO move this to TypeTable.StyleHelper?
     */
    protected boolean getIsColor(Style style)
    {
        String format = style.getFormat();
        return format != null && format.equals(StandardDefs.MDPARAM_STYLE_FORMAT_COLOR);
    }

    /**
     *
     */
    protected boolean processEffectText(Effect effect, String text, int origin, int line, Model model)
    {
        String name = effect.getName();

        if (!effect.isStateSpecific() && model.hasEffect(name))
        {
            log(line, new MultipleEffectInitializerError(name));
        }

        int flags = (origin == TextOrigin.FROM_CHILD_CDATA) ? TextParser.FlagInCDATA : 0;
        Object value = textParser.parseValue(text, typeTable.stringType, flags, line, name);

        if (value != null)
        {
            if (value instanceof BindingExpression)
            {
                BindingExpression bindingExpression = (BindingExpression)value;
                // two-way data binding expression not allowed here
                if (bindingExpression.isTwoWayPrimary())
                {
                    log(line, new TwoWayBindingNotAllowedInitializer(name, text));
                    return false;
                }
                bindingExpression.setDestination(model);
                bindingExpression.setDestinationStyle(name);
                bindingExpression.setDestinationLValue(name);
            }
            else
            {
                if (FrameworkDefs.isBuiltinEffectName(text))
                {
                    // for 1.5 compatibility
                    document.addTypeRef(standardDefs.getEffectsPackage() + "." + text, line);
                }
            }

            model.setEffect(effect, value, typeTable.stringType, line);
            return true;
        }
        else
        {
            return false;
        }
    }

    /**
     *
     */
    protected boolean processPropertyNodes(Node parent, Property property, Model model)
    {
        return processPropertyNodes(parent.getChildren(), property, model, parent.beginLine);
    }


    /**
     * Note: nodes must not be empty
     */
    protected boolean processPropertyNodes(Collection nodes, Property property, Model model, int line)
    {
        CDATANode cdata = getTextContent(nodes, true);
        if (cdata != null)
        {
            return processPropertyText(property, cdata.image, TextOrigin.fromChild(cdata.inCDATA), cdata.beginLine, model);
        }
        else
        {
            String name = property.getName();

            //  check for multiple inits to this property
            ensureSingleInitializer(model, name, line, property.getStateName());

            //  check other usage constraints
            //  TODO replace ""-passing approach with something that results in a better errmsg for enum violation
            if (!checkPropertyUsage(property, "", ((Node)nodes.iterator().next()).beginLine))
            {
                return false;
            }

            //  process
            Object rvalue = processRValueNodes(property, nodes, model);
            if (rvalue != null)
            {
                model.setProperty(property, rvalue, line);
                return true;
            }
            else
            {
                return false;
            }
        }
    }

    /**
     * Note: nodes must not be empty
     */
    protected boolean processDynamicPropertyNodes(Node parent, DynamicProperty property, Model model)
    {
        Collection nodes = parent.getChildren();
        String name = property.getName();
        String state = property.getStateName();

        CDATANode cdata = getTextContent(nodes, true);
        if (cdata != null)
        {
            return processDynamicPropertyText(name, cdata.image, TextOrigin.fromChild(cdata.inCDATA), cdata.beginLine, model, state);
        }
        else
        {
            if ((state == null) && model.hasProperty(name))
            {
                log(parent, new MultiplePropertyInitializerError(name));
            }

            Object rvalue = processRValueNodes(property, nodes, model);
            if (rvalue != null)
            {
                model.setDynamicProperty(typeTable.objectType, name, rvalue, state, parent.beginLine);
                return true;
            }
            else
            {
                return false;
            }
        }
    }

    /**
     * Note: nodes must not be empty
     */
    protected boolean processStyleNodes(Node parent, Style style, Model model)
    {
        Collection nodes = parent.getChildren();

        CDATANode cdata = getTextContent(nodes, true);
        if (cdata != null)
        {
            return processStyleText(style, cdata.image, TextOrigin.fromChild(cdata.inCDATA), cdata.beginLine, model);
        }
        else
        {
            String name = style.getName();
            if (!style.isStateSpecific() && model.hasStyle(name))
            {
                log(parent, new MultipleStyleInitializerError(name));
            }

            //  TODO replace ""-passing approach with something that results in a better errmsg for enum violation
            if (!checkStyleUsage(style, "", ((Node)nodes.iterator().next()).beginLine))
            {
                return false;
            }

            //  lvalue type - initializers to IDeferredInstance-typed styles are values to be returned by the generated factory.
            Type lvalueType = style.getType();
            if (standardDefs.isIDeferredInstance(lvalueType))
            {
                lvalueType = typeTable.objectType;
            }

            Object rvalue = processRValueNodes(style, nodes, model);
            if (rvalue != null)
            {
                model.setStyle(style, rvalue, parent.beginLine);
                return true;
            }
            else
            {
                return false;
            }
        }
    }

    /**
     * Note: nodes must not be empty
     */
    protected boolean processEffectNodes(Node parent, Effect effect, Model model)
    {
        Collection nodes = parent.getChildren();

        CDATANode cdata = getTextContent(nodes, true);
        if (cdata != null)
        {
            return processEffectText(effect, cdata.image, TextOrigin.fromChild(cdata.inCDATA), cdata.beginLine, model);
        }
        else
        {
            String name = effect.getName();

            if (!effect.isStateSpecific() && model.hasEffect(name))
            {
                log(parent, new MultipleEffectInitializerError(name));
            }

            Object rvalue = processRValueNodes(effect, nodes, model);
            if (rvalue != null)
            {
                model.setEffect(effect, rvalue, effect.getType(), parent.beginLine);
                return true;
            }
            else
            {
                return false;
            }
        }
    }

    /**
     * Note: if type is Array, then elementStoreType is the type of element actually stored to the array, and
     * elementParseType is the type which elements specified in MXML need to be compatible with. They are equal
     * unless elementStoreType is (assignable to) a factory interface, in which case elementParseType is the
     * instance type which the factory is required to produce (Object unless specified by [InstanceType]).
     *
     * The two-type scheme is a bit clumsy, but both types are needed here currently because the 'storage' element type
     * must be passed into ArrayBuilder, while the 'result' element type is used to verify type compatibility.
     */
    /*
     * TODO refactor backwards from codegen in such a way that the storage type is directly available from reflection
     * objects at codegen time. This is impossible currently because ArrayBuilder and the Array VO obscure higher-level
     * reflection info (Property, Style, etc.)
     */
    protected Object processRValueNodes(Assignable assignable, Collection nodes, Model model)
    {
        Type type = assignable.getLValueType();
        String name = assignable.getName();
        Type elementStoreType = assignable.getElementType();
        Type elementParseType = elementStoreType;

        if (assignable instanceof Property)
        {
            Property property = (Property)assignable;

            // element parse type - initializers to
            // Array<IDeferredInstance>-typed properties are values to
            // be returned by the generated factory.
            if (standardDefs.isIDeferredInstance(elementStoreType))
                elementParseType = property.getInstanceType();
        }

        boolean isDefaultProperty = false;
        Property defaultProperty = model.getType().getDefaultProperty();

        if (defaultProperty != null)
        {
            isDefaultProperty = defaultProperty.getName().equals(name);
        }

        switch (checkTypeCompatibility(nodes, type, elementParseType, name, isDefaultProperty))
        {
            case TypeCompatibility.Ok:
                //  nodes represents an rvalue that is directly assignable to (lvalue) type
                return rvalueNodeHandler.process(assignable, (Node)nodes.iterator().next(), model);

			case TypeCompatibility.OkCoerceToArray:
				//	nodes is a sequence of rvalues that can be coerced to an array that's assignable to (lvalue) type.
			    ArrayBuilder arrayBuilder = new ArrayBuilder(unit, typeTable,
			                mxmlConfiguration, document, model, assignable, false);
				arrayBuilder.createSyntheticArrayModel(((Node)nodes.iterator().next()).beginLine);
				arrayBuilder.processChildren(nodes);
				return arrayBuilder.array;

			case TypeCompatibility.OkCoerceToVector:
				//	nodes is a sequence of rvalues that can be coerced to a vector that's assignable to (lvalue) type.
               VectorBuilder vectorBuilder = new VectorBuilder(unit, typeTable,
                       mxmlConfiguration, document, model, assignable, false);
				vectorBuilder.createSyntheticVectorModel(((Node)nodes.iterator().next()).beginLine);
				vectorBuilder.processChildren(nodes);
				return vectorBuilder.vector;

            default:
                return null;
        }
    }

    /**
     *
     */
    protected class RValueNodeHandler extends ValueNodeHandler
    {
        protected Model model;
        protected Object result;

        protected Object process(Assignable property, Node node, Model model)
        {
            this.model = model;
            invoke(property, node, document);
            return result;
        }

        protected void componentNode(Assignable property, Node node, MxmlDocument document)
		{
            ComponentBuilder builder = new ComponentBuilder(unit, typeTable, mxmlConfiguration, document, model, getName(property), getStateName(property), false, null);
			node.analyze(builder);
			result = builder.component;
		}

        protected void arrayNode(Assignable property, ArrayNode node)
		{
            ArrayBuilder builder = new ArrayBuilder(unit, typeTable, mxmlConfiguration, document, model, property, false);
			node.analyze(builder);
			result = builder.array;
		}

        protected void vectorNode(Assignable property, VectorNode node)
        {
            String typeAttributeValue = (String) node.getAttribute(StandardDefs.PROP_TYPE).getValue();
            Type elementType = typeTable.getType(NameFormatter.toColon(typeAttributeValue));
            VectorBuilder builder = new VectorBuilder(unit, typeTable, mxmlConfiguration, document,
                    model, property, elementType, false);
            node.analyze(builder);
            result = builder.vector;
        }

        protected void primitiveNode(Assignable property, PrimitiveNode node)
		{
            PrimitiveBuilder builder = new PrimitiveBuilder(unit, typeTable, mxmlConfiguration, document, model, false, property, null);
			node.analyze(builder);
			result = builder.value;
		}

        protected void xmlNode(Assignable property, XMLNode node)
		{
			XMLBuilder builder = new XMLBuilder(unit, typeTable, mxmlConfiguration, document, model);
			node.analyze(builder);
			XML xml = builder.xml;
			xml.setParentIndex(getName(property), getStateName(property));
            result = xml;

	        // Fix for SDK-28286. Ensure <XML> models with ids are registered
            // with the MXML document.
	        if (xml.getId() != null)
	        {
	            document.ensureDeclaration(xml);
	        }
		}

        protected void xmlListNode(Assignable property, XMLListNode node)
        {
            XMLListBuilder builder = new XMLListBuilder(unit, typeTable, mxmlConfiguration, document, model);
            node.analyze(builder);
            builder.xmlList.setParentIndex(getName(property), getStateName(property));
            result = builder.xmlList;
        }

        protected void modelNode(Assignable property, ModelNode node)
		{
			ModelBuilder builder = new ModelBuilder(unit, typeTable, mxmlConfiguration, document, model);
			node.analyze(builder);
			result = builder.graph;
		}

        protected void inlineComponentNode(Assignable property, InlineComponentNode node)
        {
            InlineComponentBuilder builder = new InlineComponentBuilder(unit, typeTable, mxmlConfiguration, document, false);
            node.analyze(builder);
            result = builder.getRValue();
        }
        
        protected void reparentNode(Assignable property, ReparentNode node)
        {
            ComponentBuilder builder = new ComponentBuilder(unit, typeTable, mxmlConfiguration, document, model, getName(property), getStateName(property), false, null);
            node.analyze(builder);
            result = builder.component;
        }

        protected void cdataNode(Assignable property, CDATANode node)
        {
            PrimitiveBuilder builder = new PrimitiveBuilder(unit, typeTable, mxmlConfiguration, document, model, false, property, null);
            node.analyze(builder);
            result = builder.value;
        }
        
        protected void stateNode(Assignable property, StateNode node)
        {
            ComponentBuilder builder = new ComponentBuilder(unit, typeTable, mxmlConfiguration, document, model, getName(property), getStateName(property), false, null);
            node.analyze(builder);
            result = builder.component;
        }
   
        protected void unknown(Assignable property, Node node)
        {
            assert false : "Unexpected node class in processRValueNode: " + node.getClass();
            result = null;
        }
        
        private String getName(Assignable property)
        {
            return property != null ? property.getName() : null;
        }

        private String getStateName(Assignable property)
        {
            return property != null ? property.getStateName() : null;
        }
    }

    /**
     * Note: callers can opt out of class checking, due to use-cases involving late-gen classes e.g. @Embed
     */
    protected final Model instanceFromClass(String className, int line, boolean checkClass)
    {
        if (checkClass)
        {
            Type classType = typeTable.getType(NameFormatter.toColon(className));
            if (classType == null)
            {
                log(line, new ClassNotAvailable(className));
            }
        }
        return new Primitive(document, typeTable.classType, className, line);
    }

    /**
     * Note: expects dot (not colon) delimited className. See note in NameFormaterr for notes on
     * string-formatted classname migration.
     */
    protected final Model factoryFromClass(String className, int line)
    {
        Type classFactoryType = typeTable.getType(standardDefs.CLASS_CLASSFACTORY);
        if (classFactoryType == null)
        {
            log(line, new TypeNotAvailable(standardDefs.CLASS_CLASSFACTORY));
            return new Model(document, typeTable.objectType, line); //  fail semi-gracefully
        }

        Model model = new Model(document, classFactoryType, line);

        //  generator
        model.setProperty(StandardDefs.PROP_CLASSFACTORY_GENERATOR,
                new Primitive(document, typeTable.classType, className, line));

        //  introspect the classdef for property sites that match things we can auto-set
        //  NOTE: if className is unqualified, this code will not reach it.
        //  TODO either add support to introspect unqualified classNames via imports, or document its absence
        Type classType = typeTable.getType(NameFormatter.toColon(className));
        if (classType != null)
        {
            //  prop object will carry one or more properties to set on the newInstance()
            Model propObject = null;

            //  outerDocument
            Property outerDocumentProperty = classType.getProperty(DocumentInfo.OUTER_DOCUMENT_PROP);
            if (outerDocumentProperty != null)
            {
                //  check type agreement between outerDocument and our document type
                String qualName = document.getQName().toString();
                Type selfType = typeTable.getType(qualName);
                assert selfType != null : "skeleton type for class '" + NameFormatter.toDot(qualName) + "' not available";

                if (selfType.isAssignableTo(outerDocumentProperty.getType()))
                {
                    propObject = new Model(document, typeTable.objectType, line);

                    //  HACK: using classType here simply to bypass codegen formatting machinery.
                    //  TODO: add Reference rvalue type - will need for <PropertyRef/> etc.
                    propObject.setProperty(outerDocumentProperty, new Primitive(document, typeTable.classType, "this", line), line);
                }
            }

            //  if we picked anything up, attach properties initializer
            if (propObject != null)
            {
                model.setProperty(StandardDefs.PROP_CLASSFACTORY_PROPERTIES, propObject);
            }
        }

        return model;
    }

    /**
     *
     */
    private int checkTypeCompatibility(Collection<Node> nodes, Type lvalueType, Type lvalueArrayElemType,
                                       String lvalueDesc, boolean isDefaultProperty)
    {
        switch (nodes.size())
        {
            case 0:
                assert false;   //  empty collection is illegal argument
                return TypeCompatibility.ErrRTypeNotAssignableToLType;

            case 1:
                return checkTypeCompatibility(nodes.iterator().next(), lvalueType, lvalueArrayElemType,
                                              lvalueDesc, true, isDefaultProperty);

            default:
                int compat = TypeCompatibility.Ok;
                for (Node node : nodes)
                {
                    int elementCompat = checkTypeCompatibility(node, lvalueType, lvalueArrayElemType,
                                                               lvalueDesc, false, isDefaultProperty);

                    // Overwrite the last result if it wasn't an error.
                    if (compat == TypeCompatibility.Ok ||
                        compat == TypeCompatibility.OkCoerceToArray ||
                        compat == TypeCompatibility.OkCoerceToVector)
                    {
                        compat = elementCompat;
                    }
                }
                return compat;
        }
    }

    /**
     *
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
                log(node.beginLine, new SingleRValueNotTargetTypeOrTargetElementType(lvalueDescription,
                                                                                     NameFormatter.toDot(rvalueTypeName),
                                                                                     NameFormatter.toDot(lvalueType.getName()),
                                                                                     NameFormatter.toDot(lvalueArrayElementType.getName())));
                return compat;
            }
            case TypeCompatibility.ErrMultiRValueNotArrayElem:
            {
                log(node.beginLine, new MultiRValueNotElementType(lvalueDescription,
                                                                  NameFormatter.toDot(rvalueTypeName),
                                                                  NameFormatter.toDot(lvalueType.getName()),
                                                                  NameFormatter.toDot(lvalueArrayElementType.getName())));
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
     * In some circumstances stateful nodes need to be coerced to an Array.
     */
    protected int coerceStatefulNodes(Node node, Type lvalueType, int compat)
    {
    	// Special case of reparent node.
        if (node instanceof ReparentNode) return TypeCompatibility.OkCoerceToArray;
        
        // In the special case of lvalueType being Object or * we need to coerce to 
    	// array if the rvalue is state-specific.
    	if (compat == TypeCompatibility.Ok && (lvalueType.getName().equals(SymbolTable.NOTYPE) || 
    		lvalueType.getName().equals(SymbolTable.OBJECT)))
    	{
    		if (getLanguageAttribute(node, StandardDefs.PROP_INCLUDE_STATES) != null || 
    			getLanguageAttribute(node, StandardDefs.PROP_EXCLUDE_STATES) != null)
    		{
    			return TypeCompatibility.OkCoerceToArray;
    		}
    	}
    	return compat;
    }
    
    /**
     *
     */
    protected boolean checkPropertyUsage(Property property, String text, int line)
    {
        if (!isAllowedProperty(property))
        {
            log(line, new InitializerNotAllowed(property.getName()));
            return false;
        }

        if (mxmlConfiguration.showDeprecationWarnings())
        {
            checkDeprecation(property, document.getSourcePath(), line);
        }

        Inspectable inspectable = property.getInspectable();
        if (inspectable != null)
        {
            checkImageType(inspectable.getFormat(), text, line);

            if (!TextParser.isBindingExpression(text))
            {
                if (!checkEnumeration(inspectable.getEnumeration(), text, line))
                {
                    return false;
                }
            }
        }

        if (property.readOnly())
        {
            log(line, new PropertyReadOnly(property.getName()));
            return false;
        }

        //  TODO make sure this never happens
        if (property.getType() == null)
        {
            log(line, new PropertyUnreachable(property.getName()));
            return false;
        }

        return true;
    }

    /**
     * Subclasses implement this to prohibit properties for special reasons. This only gets called if the property is
     * valid - i.e., if it exists and is visible on the type of the backing class. But this usage check is called before
     * others, so e.g. deprecation, enumeration warnings, etc. will be short-circuited if this returns false.
     */
    protected boolean isAllowedProperty(Property property)
    {
        return true;
    }

    /**
     *
     */
    protected boolean checkStyleUsage(Style style, String text, int line)
    {
        checkImageType(style.getFormat(), text, line);

        if (!TextParser.isBindingExpression(text) && TextParser.getAtFunctionName(text) == null)
        {
            if (!checkEnumeration(style.getEnumeration(), text, line))
            {
                return false;
            }
        }

        //  TODO make sure this never happens
        if (style.getType() == null)
        {
            log(line, new StyleUnreachable(style.getName()));
            return false;
        }

        return true;
    }

    /**
     * Return true if the check is okay.
     * Note: must happen on parsed value, e.g. to avoid failing {bindings}, which passed in 1.5
     */
    protected boolean checkEnumeration(String[] enums, String value, int line)
    {
        if (enums != null)
        {
            for (int j = 0, count = enums.length; j < count; j++)
            {
                if (enums[j].equals(value))
                {
                    return true;
                }
            }
			StringBuilder buffer = new StringBuilder();
            for (int j = 0, count = enums.length; j < count; j++)
            {
                buffer.append(enums[j]);
                if (j < count - 1)
                {
                    buffer.append(", ");
                }
            }

            log(line, new InvalidEnumerationValue(value, buffer.toString()));

            return false;
        }
        else
        {
            return true;
        }
    }

    /**
     * Return true if the check is okay.
     * Note: must happen on parsed value. collapseWhiteSpace, etc. will affect the test
     */
    protected boolean checkImageType(String format, String value, int line)
    {
        if ("File".equals(format))
        {
            if ( value.endsWith(".svg") )
            {
                log(line, new RuntimeSVGNotSupported());
                return false;
            }
        }

        return true;
    }
    
    /**
     * Logs the appropriate Deprecation warning based on available information in the metadata;
     * will not log anything if since, message, and replacement are null. 
     * 
     * Returns true if a warning was logged.
     */
    //*** IF YOU MODIFY THIS, update macromedia.asc.embedding.LintEvaluator::logDeprecationWarning() ***
    private static boolean checkLogDeprecationWarning(String path, int line,
                                                      String name,
                                                      String since,
                                                      String message,
                                                      String replacement)
    {
        assert ((name != null) && (name.length() > 0));
        
        final boolean hasSince       = (since       != null) && (since.length()       > 0);
        final boolean hasMessage     = (message     != null) && (message.length()     > 0);
        final boolean hasReplacement = (replacement != null) && (replacement.length() > 0);
        
        if (hasMessage)
        {
            // [Deprecated("foo")]
            // [Deprecated(message="foo")]
            ThreadLocalToolkit.log(new DeprecatedMessage(message), path, line);
        }
        else if (hasReplacement)
        {
            if (hasSince)
            {
                // [Deprecated(since="1983", replacement="foo")]
                ThreadLocalToolkit.log(new DeprecatedSince(name, since, replacement), path, line);
            }
            else
            {
                // [Deprecated(replacement="foo")]
                ThreadLocalToolkit.log(new DeprecatedUseReplacement(name, replacement), path, line);
            }
        }
        else if (hasSince)
        {
            // [Deprecated(since="1983")]
            ThreadLocalToolkit.log(new DeprecatedSinceNoReplacement(name, since), path, line);
        }
        else if ((message != null) || (replacement != null) || (since != null))
        {
            // deprecation was intended by providing at least one non-null string,
            // though no message was provided, e.g.:
            // [Deprecated(replacement="")] or [Style(deprecatedReplacement="")]
            ThreadLocalToolkit.log(new Deprecated(name), path, line);
        }
        else
        {
            // probably not [Deprecated]
            return false;
        }
        
        return true;
    }

	/**
	 * Return true if the check is okay.  It is assumed that
	 * deprecation warnings should be shown if this method is called.
	 */
	public static boolean checkDeprecation(Property property, String path, int line)
	{
		flex2.compiler.mxml.reflect.Deprecated deprecated = property.getDeprecated();

		if ((deprecated != null))
		{
            // since there was definitely a [Deprecated], try logging a deprecation warning;
            // if no arguments were given and nothing is logged (call returns false),
            // log the default deprecation warning.
            if (!checkLogDeprecationWarning(path, line,
                                            property.getName(),
                                            deprecated.getSince(),
                                            deprecated.getMessage(),
                                            deprecated.getReplacement()))
            {
                ThreadLocalToolkit.log(new Deprecated(property.getName()), path, line);
            }
            return false;
        }
        return true;
    }

	/**
	 * 
	 */
	protected void checkEventDeprecation(Event event, String path, int line)
	{
		if (mxmlConfiguration.showDeprecationWarnings())
        {
            checkLogDeprecationWarning(path, line,
                                  event.getName(),
                                  event.getDeprecatedSince(),
                                  event.getDeprecatedMessage(),
                                  event.getDeprecatedReplacement());
        }
    }
    
    /**
     * 
     */
    protected void checkEffectDeprecation(Effect effect, String path, int line)
    {
        if (mxmlConfiguration.showDeprecationWarnings())
        {
            checkLogDeprecationWarning(path, line,
                                  effect.getName(),
                                  effect.getDeprecatedSince(),
                                  effect.getDeprecatedMessage(),
                                  effect.getDeprecatedReplacement());
        }
    }
    
    /**
     * 
     */
    protected void checkStyleDeprecation(Style style, String path, int line)
    {
        if (mxmlConfiguration.showDeprecationWarnings())
        {
            checkLogDeprecationWarning(path, line,
                                  style.getName(),
                                  style.getDeprecatedSince(),
                                  style.getDeprecatedMessage(),
                                  style.getDeprecatedReplacement());
        }
    }

    /**
     *
     */
    protected boolean checkNonEmpty(Node node, Type type)
    {
        if (node.getChildren().isEmpty())
        {
            if (!allowEmptyDefault(type))
            {
                log(node.beginLine, new EmptyChildInitializer(NameFormatter.toDot(type.getName())));
            }

            return false;
        }
        else
        {
            return true;
        }
    }

    /**
     *
     */
    protected boolean allowEmptyDefault(Type type)
    {
        return typeTable.stringType.isAssignableTo(type) || 
               typeTable.arrayType.isAssignableTo(type);
    }

    /**
     *
     */
    protected boolean hasAttributeInitializers(Node node)
    {
        for (Iterator iter = node.getAttributeNames(); iter.hasNext(); )
        {
            QName qname = (QName)iter.next();
            if (!isSpecialAttribute(qname.getNamespace(), qname.getLocalPart()))
            {
                return true;
            }
        }
        return false;
    }

    /**
     * Subclasses should override this method to define what they consider special attributes.
     */
    protected boolean isSpecialAttribute(String namespaceURI, String localPart)
    {
        return false;
    }

    /**
     * Register an rvalue (currently aka Model) to our MxmlDocument, as a
     * declaration.
     */
    protected void registerModel(Node node, Model model, boolean topLevel)
    {
        String id = (String)getLanguageAttributeValue(node, StandardDefs.PROP_ID);
        // get the comment from the node and store in the model
        if(node.comment != null) 
        {
            // if generate ast if false, lets not scan the tokens here because they will be scanned later in asc scanner. 
            // we will go the velocity template route
            if(!mxmlConfiguration.getGenerateAbstractSyntaxTree())
            {
                model.comment = node.comment;
            }
            else
            {
                model.comment = MxmlCommentUtil.commentToXmlComment(node.comment);   
            }
        }
        
        registerModel(id, model, topLevel);
    }

    /**
     * register an rvalue (currently aka Model) to our MxmlDocument, as a declaration.
     */
    protected void registerModel(String id, Model model, boolean topLevel)
    {
        if (id != null)
        {
            model.setId(id, false);
            document.addDeclaration(model, topLevel);
        }
        else if (topLevel)
        {
            document.addDeclaration(model, true);
        }
        else if (model.isDeclarationEnsured() && model.getIdIsAutogenerated())
        {
        	document.addDeclaration(model.getId(), model.getType().getName(),
					model.getXmlLineNumber(), true, true, true, model.getBindabilityEnsured());
        }
    }

    protected int getDocumentVersion()
    {
        return document.getVersion();
    }

    protected String getLanguageNamespace()
    {
        return document.getLanguageNamespace();
    }

    /*
     * errors, warnings from here to EOF
     */

    public static class AtClearNotAllowed extends CompilerError
    {
        private static final long serialVersionUID = 2999387312121186024L;
    }
    
    public static class BindingNotAllowed extends CompilerError
    {
        private static final long serialVersionUID = 8873043175834895629L;
    }

    // valid binding syntax but not allowed here
    public static class BindingNotAllowedInitializer extends CompilerError
    {
        private static final long serialVersionUID = -6988629472344628260L;
        public String desc;
        public String text;
        
        public BindingNotAllowedInitializer(String desc, String text)
        {
            this.desc = desc;
            this.text = text;
        }
    }
      
    public static class TypeNotContextRootable extends CompilerError
    {
        private static final long serialVersionUID = 2999387313501186024L;
        public String desc;
        public String type;

        public TypeNotContextRootable(String desc, String type)
        {
            this.desc = desc;
            this.type = type;
        }
    }

    public static class UndefinedContextRoot extends CompilerError
    {
        private static final long serialVersionUID = 1315340897509577928L;

        public UndefinedContextRoot()
        {
        }
    }

    public static class TypeNotEmbeddable extends CompilerError
    {
        private static final long serialVersionUID = 1329678763686966135L;
        public String desc;
        public String type;

        public TypeNotEmbeddable(String desc, String type)
        {
            this.desc = desc;
            this.type = type;
        }
    }

    public static class InvalidTextForType extends CompilerError
    {
        private static final long serialVersionUID = 4515750602580054804L;
        public String desc;
        public String type;
        public String array;
        public String text;

        public InvalidTextForType(String desc, String type, String array, String text)
        {
            this.desc = desc;
            this.type = type;
            this.array = array;
            this.text = text;
        }
    }

    public static class InvalidPercentage extends CompilerError
    {
        private static final long serialVersionUID = -2623489942233054966L;
        public String desc;
        public String text;

        public InvalidPercentage(String desc, String text)
        {
            this.desc = desc;
            this.text = text;
        }
    }

    public static class TypeNotSerializable extends CompilerError
    {
        private static final long serialVersionUID = 352552929285101031L;
        public String desc;
        public String type;

        public TypeNotSerializable(String desc, String type)
        {
            this.desc = desc;
            this.type = type;
        }
    }

    public static class PercentagesNotAllowed extends CompilerError
    {
        private static final long serialVersionUID = 106765063868387999L;
        public String desc;

        public PercentagesNotAllowed(String desc)
        {
            this.desc = desc;
        }
    }

    // valid two-way binding syntax but not allowed here
    public static class TwoWayBindingNotAllowedInitializer extends CompilerError
    {
        private static final long serialVersionUID = -4509943614908495917L;
        
        public String desc;
        public String text;
        
        public TwoWayBindingNotAllowedInitializer(String desc, String text)
        {
            this.desc = desc;
            this.text = text;
        }
    }
    
    // valid two-way binding syntax but not allowed here
    public static class TwoWayBindingNotAllowed extends CompilerError
    {
        private static final long serialVersionUID = -3894038340408090247L;
    }      

    // invalid two-way binding syntax
    public static class InvalidTwoWayBindingInitializer extends CompilerError
    {
        private static final long serialVersionUID = -6225540773527205704L;
        public String desc;
        public String text;
        
        public InvalidTwoWayBindingInitializer(String desc, String text)
        {
            this.desc = desc;
            this.text = text;
        }
    }
    
    // invalid two-way binding syntax
    public static class InvalidTwoWayBinding extends CompilerError
    {
       private static final long serialVersionUID = 4795539821885732534L;
        public String text;

        public InvalidTwoWayBinding(String text)
        {
            this.text = text;
        }
    }

    public static class UnrecognizedAtFunction extends CompilerError
    {
        private static final long serialVersionUID = -7976108326433297022L;
        public String desc;

        public UnrecognizedAtFunction(String desc)
        {
            this.desc = desc;
        }
    }

    public static class PercentProxyWarning extends CompilerWarning
    {
        private static final long serialVersionUID = -5227221682435159906L;
        public String proxyName;
        public String property;
        public String type;

        public PercentProxyWarning(String proxyName, String property, String type)
        {
            this.proxyName = proxyName;
            this.property = property;
            this.type = type;
        }
    }

    public static class MultiplePropertyInitializerError extends CompilerError
    {
        private static final long serialVersionUID = -3093330194050759789L;
        public String name;

        public MultiplePropertyInitializerError(String name)
        {
            this.name = name;
        }
    }

    public static class MultiplePropertyInitializerWithDefaultError extends CompilerError
    {
        private static final long serialVersionUID = -2193960741080733281L;
        public String name;
        public String type;

        public MultiplePropertyInitializerWithDefaultError(String name, String type)
        {
            this.name = name;
            this.type = type;
        }
    }

    public static class EventTypeUnavailable extends CompilerError
    {
        private static final long serialVersionUID = 1538004770687497485L;
        public String type;

        public EventTypeUnavailable(String type)
        {
            this.type = type;
        }
    }

    public static class EventHandlerEmpty extends CompilerWarning
    {

        private static final long serialVersionUID = 7631512992578158817L;
    }

    public static class MultipleStyleInitializerError extends CompilerError
    {
        private static final long serialVersionUID = -5623999245296398120L;
        public String name;

        public MultipleStyleInitializerError(String name)
        {
            this.name = name;
        }
    }

    public static class MultipleEffectInitializerError extends CompilerError
    {
        private static final long serialVersionUID = -1441380732951033404L;
        public String name;

        public MultipleEffectInitializerError(String name)
        {
            this.name = name;
        }
    }

    public static class ClassNotAvailable extends CompilerError
    {
        private static final long serialVersionUID = 2595556373093280868L;
        public String className;

        public ClassNotAvailable(String className)
        {
            this.className = className;
        }
    }

    public static class TypeNotAvailable extends CompilerError
    {
        private static final long serialVersionUID = 6652076396694350439L;
        public String type;

        public TypeNotAvailable(String type)
        {
            this.type = type;
        }
    }

    public static class TypeNotAssignableToDefaultProperty extends CompilerError
    {
        private static final long serialVersionUID = 3170516169562771495L;
        public String defaultProperty;
        public String type;
        public String targetType;

        public TypeNotAssignableToDefaultProperty(String defaultProperty, String type, String targetType)
        {
            this.defaultProperty = defaultProperty;
            this.type = type;
            this.targetType = targetType;
        }
    }

    public static class TypeNotAssignableToLType extends CompilerError
    {
        private static final long serialVersionUID = 3170516169562771496L;
        public String lvalue;
        public String type;
        public String targetType;

        public TypeNotAssignableToLType(String lvalue, String type, String targetType)
        {
            this.lvalue = lvalue;
            this.type = type;
            this.targetType = targetType;
        }
    }

    public static class DefaultPropertyNotMultiple extends CompilerError
    {
        private static final long serialVersionUID = -226195643462502027L;
        public String defaultProperty;
        public String targetType;

        public DefaultPropertyNotMultiple(String defaultProperty, String targetType)
        {
            this.defaultProperty = defaultProperty;
            this.targetType = targetType;
        }
    }

    public static class TypeNotMultiple extends CompilerError
    {
        private static final long serialVersionUID = -226195643462502028L;
        public String lvalue;
        public String targetType;

        public TypeNotMultiple(String lvalue, String targetType)
        {
            this.lvalue = lvalue;
            this.targetType = targetType;
        }
    }

    public static class SingleRValueNotTargetTypeOrTargetElementType extends CompilerError
    {
        private static final long serialVersionUID = 2707598764290534991L;
        public String lvalue;
        public String type;
        public String targetType;
        public String targetElementType;

        public SingleRValueNotTargetTypeOrTargetElementType(String lvalue, String type, String targetType, String targetElementType)
        {
            this.lvalue = lvalue;
            this.type = type;
            this.targetType = targetType;
            this.targetElementType = targetElementType;
        }
    }

    public static class MultiRValueNotElementType extends CompilerError
    {
        private static final long serialVersionUID = 3496264868863398700L;
        public String lvalue;
        public String type;
        public String targetType;
        public String targetElementType;

        public MultiRValueNotElementType(String lvalue, String type, String targetType, String targetElementType)
        {
            this.lvalue = lvalue;
            this.type = type;
            this.targetType = targetType;
            this.targetElementType = targetElementType;
        }
    }

    public static class InitializerNotAllowed extends CompilerError
    {
        private static final long serialVersionUID = -5647720336849700770L;
        public String name;

        public InitializerNotAllowed(String name)
        {
            this.name = name;
        }
    }

    public static class PropertyReadOnly extends CompilerError
    {
        private static final long serialVersionUID = -7534712819383293242L;
        public String name;

        public PropertyReadOnly(String name)
        {
            this.name = name;
        }
    }

    public static class PropertyUnreachable extends CompilerError
    {
        private static final long serialVersionUID = -8232851717762250700L;
        public String name;

        public PropertyUnreachable(String name)
        {
            this.name = name;
        }
    }

    public static class StyleUnreachable extends CompilerError
    {
        private static final long serialVersionUID = -907081582545856406L;
        public String name;

        public StyleUnreachable(String name)
        {
            this.name = name;
        }
    }

    public static class InvalidEnumerationValue extends CompilerError
    {
        private static final long serialVersionUID = 6028640604926009874L;
        public String value;
        public String values;

        public InvalidEnumerationValue(String value, String values)
        {
            this.value = value;
            this.values = values;
        }
    }

    public static class RuntimeSVGNotSupported extends CompilerWarning
    {

        private static final long serialVersionUID = -2904837796107529728L;
    }

    public static class Deprecated extends CompilerWarning
    {
        private static final long serialVersionUID = -7717466044221114090L;
        public String name;

        public Deprecated(String name)
        {
            this.name = name;
        }
    }
    
    public static class DeprecatedMessage extends CompilerWarning
    {
        private static final long serialVersionUID = -4559508730948651240L;
        public String deprecationMessage;

        public DeprecatedMessage(String deprecationMessage)
        {
            this.deprecationMessage = deprecationMessage;
        }
    }

    public static class DeprecatedUseReplacement extends CompilerWarning
    {
        private static final long serialVersionUID = 6268273891441452672L;
        public String name;
        public String replacement;

        public DeprecatedUseReplacement(String name, String replacement)
        {
            this.name = name;
            this.replacement = replacement;
        }
    }

    public static class DeprecatedSince extends CompilerWarning
    {
        private static final long serialVersionUID = 8941405158832020624L;
        public String name;
        public String replacement;
        public String since;

        public DeprecatedSince(String name, String since, String replacement)
        {
            this.name = name;
            this.since = since;
            this.replacement = replacement;
        }
    }
    
    public static class DeprecatedSinceNoReplacement extends CompilerWarning
    {
        private static final long serialVersionUID = -2892937735469385339L;
        public String name;
        public String since;

        public DeprecatedSinceNoReplacement(String name, String since)
        {
            this.name = name;
            this.since = since;
        }
    }
    
    public static class EmptyChildInitializer extends CompilerError
    {
        private static final long serialVersionUID = -6310661960438135244L;
        public String type;

        public EmptyChildInitializer(String type)
        {
            this.type = type;
        }
    }
    
    public static class ClearNotAllowed extends CompilerError
    {
        private static final long serialVersionUID = -8851319647736024265L;
    }
    
    public static class InvalidItemCreationPolicyUsage extends CompilerError
    {
        private static final long serialVersionUID = -8851319647736024265L;
    }
    
    public static class InvalidItemCreationPolicy extends CompilerError
    {
        private static final long serialVersionUID = -8851319647736091965L;
    }
    
    public static class InvalidItemDestructionPolicyUsage extends CompilerError
    {
        private static final long serialVersionUID = -8851319646636024265L;
    }
    
    public static class InvalidItemDestructionPolicy extends CompilerError
    {
        private static final long serialVersionUID = -8851319646636091965L;
    }

}
