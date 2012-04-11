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

import flash.util.StringUtils;
import flex2.compiler.CompilationUnit;
import flex2.compiler.CompilerContext;
import flex2.compiler.css.Styles;
import flex2.compiler.css.StylesContainer;
import flex2.compiler.mxml.MxmlConfiguration;
import flex2.compiler.mxml.dom.DesignLayerNode;
import flex2.compiler.mxml.dom.Node;
import flex2.compiler.mxml.gen.CodeFragmentList;
import flex2.compiler.mxml.gen.DescriptorGenerator;
import flex2.compiler.mxml.gen.StatesGenerator;
import flex2.compiler.mxml.gen.TextGen;
import flex2.compiler.mxml.lang.FrameworkDefs;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.reflect.Property;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.reflect.TypeTable;
import flex2.compiler.mxml.rep.decl.InitializedPropertyDeclaration;
import flex2.compiler.mxml.rep.decl.PropertyDeclaration;
import flex2.compiler.mxml.rep.decl.UninitializedPropertyDeclaration;
import flex2.compiler.mxml.rep.init.Initializer;
import flex2.compiler.mxml.rep.init.NamedInitializer;
import flex2.compiler.mxml.rep.init.ValueInitializer;
import flex2.compiler.mxml.rep.init.EventInitializer;
import flex2.compiler.mxml.rep.StatesModel;
import flex2.compiler.util.*;

import org.apache.commons.collections.Predicate;
import org.apache.commons.collections.iterators.FilterIterator;
import org.apache.commons.collections.iterators.IteratorChain;

import java.util.*;

/**
 * This class represents an Mxml document's class information and
 * contains the object representation of the document's declarations,
 * binding expressions, @Embed's, @Resource's, and styles.  It is
 * created by the ImplemenationCompiler and filled in by
 * DocumentBuilder's analysis of the DOM.
 *
 * @see flex2.compiler.mxml.ImplementationCompiler
 * @see flex2.compiler.mxml.builder.DocumentBuilder
 */
public final class MxmlDocument
{
    private final CompilationUnit unit;
    private final TypeTable typeTable;
    private final DocumentInfo info;
    private final StandardDefs standardDefs;

    private Model root;
    private final Map<String, PropertyDeclaration> declarations;
    private final List<BindingExpression> bindingExpressions;
    private final List<PropertyDeclaration> layerDeclarations;
    private final Map<String, AtEmbed> atEmbeds;
    private final Map<String, AtResource> atResources;
    private final Set<String> typeRefs;
    private final StylesContainer stylesContainer;

    private String preloader;
    private boolean usePreloader;

    private DualModeLineNumberMap lineNumberMap;

    private Map<String, Integer> anonIdCounts;

    private boolean bindingImportsAdded;    //  HACK see ensureBindingImports()
    
    private Map sharedObjects;
    
    private StatesModel statesModel;
    private List statefulEventInitializers;
    private String comment;

    private boolean showDeprecationWarnings;
    private boolean allowDuplicateDefaultStyleDeclarations;
    
    private Map<DesignLayerNode, DesignLayer> designLayers;

	public MxmlDocument(CompilationUnit unit, TypeTable typeTable, DocumentInfo info, MxmlConfiguration mxmlConfiguration)
	{
		this.unit = unit;
		this.typeTable = typeTable;
		this.info = info;
		this.standardDefs = unit.getStandardDefs();

        root = null;
        declarations = new TreeMap<String, PropertyDeclaration>();
        layerDeclarations = new ArrayList<PropertyDeclaration>();
        bindingExpressions = new ArrayList<BindingExpression>();
        atEmbeds = new TreeMap<String, AtEmbed>();
        atResources = new TreeMap<String, AtResource>();
        typeRefs = new TreeSet<String>();
        
        designLayers = new HashMap<DesignLayerNode, DesignLayer>();

        stylesContainer = new StylesContainer(mxmlConfiguration, unit, typeTable.getPerCompileData());
        unit.setStylesContainer(stylesContainer);
        showDeprecationWarnings = mxmlConfiguration.showDeprecationWarnings();
        allowDuplicateDefaultStyleDeclarations = mxmlConfiguration.getAllowDuplicateDefaultStyleDeclarations();
        
        stylesContainer.setMxmlDocument(this);
        stylesContainer.setNameMappings(typeTable.getNameMappings());
        sharedObjects = new TreeMap();
        
        statesModel = new StatesModel(this, info, standardDefs);
        statefulEventInitializers = new ArrayList();
        
        preloader = NameFormatter.toDot(standardDefs.CLASS_DOWNLOADPROGRESSBAR);
        usePreloader = true;

        lineNumberMap = null;

        anonIdCounts = new HashMap<String, Integer>();

        bindingImportsAdded = false;

        //  transfer binding expressions out to CompilerContext
        //  TODO this should happen somewhere else
        CompilerContext context = unit.getContext();
        context.setAttribute(CompilerContext.BINDING_EXPRESSIONS, bindingExpressions);
    }

	public final DesignLayer getLayerModel(DesignLayerNode node)
	{
		return designLayers.get(node);
	}
	
	public final void addLayerModel(DesignLayerNode node, DesignLayer model)
	{
		designLayers.put(node, model);
	}
	
    public final CompilationUnit getCompilationUnit()
    {
        return unit;
    }

    public final String getSourcePath()
    {
        return unit.getSource().getName();
    }

    public final StandardDefs getStandardDefs()
    {
        return standardDefs;
    }

    public final boolean getIsMain()
    {
        return unit.isRoot();
    }

    public final TypeTable getTypeTable()
    {
        return typeTable;
    }

    public final String getClassName()
    {
        return info.getClassName();
    }

    public final String getConvertedClassName()
    {
        return "_" + StringUtils.substitute(getClassName(), ".", "_");
    }

    public final String getPackageName()
    {
        return info.getPackageName();
    }

    public final QName getQName()
    {
        return info.getQName();
    }

    public final Type getSkeletonClass()
    {
        return typeTable.getType(getQName().toString());
    }

    public final Type getSuperClass()
    {
        return getRoot().getType();
    }

    public final String getSuperClassName()
    {
        return NameFormatter.toDot(getSuperClass().getName());
    }

    public final boolean getHasInterfaces()
    {
        return info.getInterfaceNames().size() > 0;
    }

    public final boolean getIsInlineComponent()
    {
        return info.getRootNode().isInlineComponent();
    }

    public final boolean getAllowDuplicateDefaultStyleDeclarations()
    {
        return allowDuplicateDefaultStyleDeclarations;
    }

    /*
     * TODO set this and various other stuff from Info, at construction time
     */
    public void setRoot(Model root)
    {
        this.root = root;

        //  TODO what follows can move into ctor once root is set there from info

        if (getIsContainer())
        {
            addImport(NameFormatter.toDot(standardDefs.CLASS_UICOMPONENTDESCRIPTOR), root.getXmlLineNumber());
        }

        String outerDocClassName = info.getRootNode().getOuterDocumentClassName();
        if (outerDocClassName != null)
        {
            addDeclaration(DocumentInfo.OUTER_DOCUMENT_PROP, outerDocClassName, 0, false, true, false, false);
        }
    }

    /**
     *
     */
    public final Model getRoot()
    {
        assert root != null : "root component not set";
        return root;
    }

    /**
     *
     */
    public final void addDeclaration(Model model, boolean topLevel)
    {
        if (!inheritedPropertyUsageError(model.getId(), model.getType(), model.getXmlLineNumber()))
        {
        	if (model instanceof DesignLayer)
        		layerDeclarations.add(new InitializedPropertyDeclaration(model, topLevel, model.getXmlLineNumber()));

        	declarations.put(model.getId(), new InitializedPropertyDeclaration(model, topLevel, model.getXmlLineNumber()));
        }
    }

    /**
     *
     */
    public final void addDeclaration(String id, String typeName, int line, boolean inspectable, boolean topLevel, boolean idIsAutogenerated, boolean isBindable)
    {
        addDeclaration(id, typeName, line, inspectable, topLevel, idIsAutogenerated, isBindable, null);
    }
    
    public final void addDeclaration(String id, String typeName, int line, boolean inspectable, boolean topLevel, boolean idIsAutogenerated, boolean isBindable, String comment)
    {
        if (!inheritedPropertyUsageError(id, root.getType().getTypeTable().getType(NameFormatter.toColon(typeName)), line))
        {
            declarations.put(id, new UninitializedPropertyDeclaration(id, typeName, line, inspectable, topLevel, idIsAutogenerated, isBindable, comment));
        }
    }    
    
    /**
     * Return a property declaration from our declarations map.
     */
    public final PropertyDeclaration getDeclaration(String id) 
    {
        return declarations.get(id);
    }
    
    /**
     * Register state specific event initializer
     */
    public final void addStateSpecificEventInitializer(EventInitializer initializer)
    {
    	if (!initializer.getHandlerText().equals("@Clear()"))
    	{
    		statefulEventInitializers.add(initializer);
    	}
    }
    
    /**
     * If a model is not by default to be declared, declare it otherwise.
     */
    public final void ensureDeclaration(Model model)
    {
        if (!isDeclared(model))
        {
            addDeclaration(model, false);
        }
    }

    /**
     * true iff the document has a property (induced or explicit) named by the model's id
     */
    // TODO remove
    public final boolean isDeclared(Model model)
    {
        String id = model.getId();
        return id != null && isDeclared(id);
    }

    /**
     * true iff the document has a property (induced or explicit) named by the id
     */
    public final boolean isDeclared(String id)
    {
        return declarations.containsKey(id);
    }

    public boolean showDeprecationWarnings()
    {
        return showDeprecationWarnings;
    }

    /**
     * NOTE: suppress declaration of inherited properties
     */
    public final Iterator<PropertyDeclaration> getDeclarationIterator()
    {
        final Type superType = getSuperClass();

        return new FilterIterator(declarations.values().iterator(), new Predicate()
        {
            public boolean evaluate(Object object)
            {
                return superType.getProperty(((PropertyDeclaration)object).getName()) == null;
            }
        });
    }

    /**
     *
     */
    private final Iterator<PropertyDeclaration> getTopLevelDeclarationIterator()
    {
        return new FilterIterator(declarations.values().iterator(), new Predicate()
        {
            public boolean evaluate(Object object)
            {
                return ((PropertyDeclaration)object).getTopLevel();
            }
        });
    }

   /**
    *
    */
   public final Iterator<Initializer> getNonStagePropertyInitializerIterator()
   {
       return new FilterIterator(new IteratorChain(root.getPropertyInitializerIterator(false),
               getTopLevelInitializerIterator()), new Predicate()
       {
           public boolean evaluate(Object object)
           {
               if (object instanceof NamedInitializer)
                   return (!StandardDefs.isStageProperty(((NamedInitializer)object).getName())) &&
                   	      (!((NamedInitializer)object).isDesignLayer());
               return true;
           }
       });
   }
   
   /**
   *
   */
  public final Iterator<Initializer> getDesignLayerPropertyInitializerIterator()
  {
	  return new FilterIterator(layerDeclarations.iterator(), new Predicate()
      {
          public boolean evaluate(Object object)
          {
              return object instanceof InitializedPropertyDeclaration;
          }
      });
  }
  
  /**
   *
   */
  public final Iterator<Initializer> getStagePropertyInitializerIterator()
  {
      return new FilterIterator(new IteratorChain(root.getPropertyInitializerIterator(false),
              getTopLevelInitializerIterator()), new Predicate()
      {
          public boolean evaluate(Object object)
          {
              if (object instanceof NamedInitializer)
                  return StandardDefs.isStageProperty(((NamedInitializer)object).getName());
              return false;
          }
      });
  }
  
  /**
   * 
   */
  public final boolean getHasStagePropertyInitializers()
  {
      return getStagePropertyInitializerIterator().hasNext();
  }

   /**
     *
     */
	public final Iterator<Initializer> getTopLevelInitializerIterator()
    {
        return new FilterIterator(getTopLevelDeclarationIterator(), new Predicate()
        {
            public boolean evaluate(Object object)
            {
                return object instanceof InitializedPropertyDeclaration;
            }
        });
    }

    /**
     * a little trickiness here: we need to initialize both our superclass properties, and document variables that
     * have initializers
     */
	public final Iterator<Initializer> getPropertyInitializerIterator()
    {
		return new IteratorChain(root.getPropertyInitializerIterator(false),
                getTopLevelInitializerIterator());
    }

	/*
	 * State-specific event handler iterator.
	 */
	public final Iterator<Initializer> getStatefulEventIterator()
    {
        return statefulEventInitializers.iterator();
    }
	
    /**
     * return an iterator over visual children that haven't been marked described.
     */
    // TODO visual children are marked described by the descriptor
    //      generator, so there is some order-of-codegen sensitivity
    //      here. It's the only such dependency, but at some point
    //      descriptor codegen and marking-of-isDescribed should be
    //      split apart.
    public final Iterator getProceduralVisualChildInitializerIterator()
    {
        if (root instanceof MovieClip)
        {
            return new FilterIterator(((MovieClip)root).getChildInitializerIterator(), new Predicate()
            {
                public boolean evaluate(Object object)
                {
                    ValueInitializer init = (ValueInitializer)object;
                    Object value = init.getValue();
                    return !(value instanceof Model) || (!((Model)value).isDescribed() && !((Model)value).isStateSpecific());
                }
            });
        }
        else
        {
            return Collections.EMPTY_LIST.iterator();
        }
    }

    /**
     * For Flex 2.0, visual children are always described - i.e., initialized using the UICOmponentDescriptor-based
     * DI machinery, rather than by procedural code. Future variations of this approach can be tested by modifying
     * what this method returns - e.g. by querying a config variable, making a per-document decision (say, based on
     * metadata or base class), or whatever.
     *
     * (Note that DI is always used for Repeater contents, independent of this setting.)
     */
    public final boolean getDescribeVisualChildren()
    {
        return true;
    }

    /**
     * iterator over all definitions from our toplevel declarations, root initializers,
     * and our states model (state specific values).
     */
    public final Iterator<CodeFragmentList> getDefinitionIterator()
    {
        IteratorList iterList = new IteratorList();

        Model.addDefinitionIterators(iterList, getTopLevelInitializerIterator());

        Iterator iter = statefulEventInitializers.iterator();
        while (iter.hasNext())
        {
            iterList.add(((Initializer)iter.next()).getDefinitionsIterator());
        }
        
        iterList.add(root.getSubDefinitionsIterator());
        
        if (getVersion() >= 4)
        	iterList.add(statesModel.getSubDefinitionIterators());

        return iterList.toIterator();
    }

    /**
     *
     */
    public final void addBindingExpression(BindingExpression expr)
    {
        expr.setId(bindingExpressions.size());
        bindingExpressions.add(expr);
        info.addInterfaceName(standardDefs.INTERFACE_IBINDINGCLIENT_DOT, -1);
    }
    
    /**
     *
     */
   public final void removeBindingExpression(BindingExpression expr)
   {
       int index = bindingExpressions.indexOf(expr);
       if (index >= 0)
       {
           for (int i=index; i < bindingExpressions.size(); i++)
               bindingExpressions.get(i).setId(i-1);
           
           bindingExpressions.remove(index);
       }
   }
   

    public final List<BindingExpression> getBindingExpressions()
    {
        return bindingExpressions;
    }

    public final void addAtEmbed(AtEmbed atEmbed)
    {
        if (!atEmbeds.containsKey(atEmbed.getPropName()))
        {
            atEmbeds.put(atEmbed.getPropName(), atEmbed);
        }
    }

    public final Set<AtEmbed> getAtEmbeds()
    {
        Set<AtEmbed> result = new HashSet(atEmbeds.values());

        if (stylesContainer != null)
        {
            result.addAll(stylesContainer.getAtEmbeds());
        }

        return result;
    }

    public final boolean addAtResource(AtResource atResource)
    {
        // @Resource codegen (AtResource.getValueExpression()) requires mx.resources.ResourceManager
        addImport(standardDefs.CLASS_RESOURCEMANAGER_DOT,
                  atResource.getXmlLineNumber());
        atResources.put(atResource.getBundle(), atResource);
        return true;
    }

    public final Collection<AtResource> getAtResources()
    {
        return atResources.values();
    }

    /**
     *
     */
    public final void addTypeRef(String typeRef, int line)
    {
        addImport(typeRef, line);
        typeRefs.add(typeRef);
    }

    public final Collection<String> getTypeRefs()
    {
        return typeRefs;
    }

    /**
     *
     */
    public final void addImport(String name, int line)
    {
        info.addImportName(name, line);
    }

    public final Set<DocumentInfo.NameInfo> getImports()
    {
        ensureBindingImports();
        return info.getImportNames();
    }

	public final Collection<String[]> getSplitImports()
	{
		return info.getSplitImportNames();
	}

    //  HACK: because essential stuff in a BindingExpression is set up *after* addBindingExpression() is called
    //  on it, we have to wait until the last minute before adding their destination types to the import list.
    //  TODO clean up BindingExpression setup. A BE should be completely configured by the time it's added here.
    private final void ensureBindingImports()
    {
        if (!bindingImportsAdded)
        {
            for (Iterator<BindingExpression> iter = bindingExpressions.iterator(); iter.hasNext(); )
            {
                BindingExpression expr = iter.next();
                addImport(expr.getDestinationTypeName(), expr.getXmlLineNumber());
            }
            bindingImportsAdded = true;
        }
    }

    /**
     *
     */
    public final void addScript(Script script)
    {
        info.addScript(script);
    }

    public final List<Script> getScripts()
    {
        return info.getScripts();
    }

    /**
     * Looks to see whether the document has a local class mapping for a
     * qualified tag name.
     *
     * @param namespace The tag namespace URI.
     * @param localPart The tag name.
     * @return The Class name, or null if a mapping was not found.
     */
    public String getLocalClass(String namespace, String localPart)
    {
        return info.getLocalClass(namespace, localPart);
    }

    /**
     *
     */
    public final void addMetadata(Script metaDataSource)
    {
        String text = metaDataSource.getText();
        assert text != null;

        // FIXME - when people stop abusing metadata, this hack can be nuked.
        if (!text.startsWith("["))
        {
            info.getMetadata().add(0, metaDataSource);
        }
        else
        {
            info.addMetadata(metaDataSource);
        }
    }

    public final List<Script> getMetadata()
    {
        return info.getMetadata();
    }

    /**
     *
     */
    public StylesContainer getStylesContainer()
    {
        return stylesContainer;
    }

    /**
     *
     */
    public Iterator getInheritingStyleNameIterator()
    {
        final Styles styles = typeTable.getStyles();
        return new FilterIterator(styles.getStyleNames(), new Predicate()
            {
                public boolean evaluate(Object obj) { return styles.isInheritingStyle((String)obj); }
            });
    }

    /**
     * Returns true if root's type implements mx.core.IContainer or mx.core.Repeater.
     */
    public boolean getIsContainer()
    {
        return standardDefs.isContainer(root.getType());
    }

    /**
     * Returns true if root's type implements mx.core.IVisualElementContainer.
     */
    public boolean getIsVisualElementContainer()
    {
        return root.getType().isAssignableTo(standardDefs.INTERFACE_IVISUALELEMENTCONTAINER);
    }

    public boolean getIsIFlexModule()
    {
        return standardDefs.isIFlexModule(root.getType());
    }
    
    public boolean getIsIUIComponent()
    {
        return standardDefs.isIUIComponent(root.getType());
    }
    
    /**
     * Test if this document is a Flex application.
     * 
     * @return True if this is a Flex application, false if
     * this document is a non-Flex application.  
     */
    public boolean getIsFlexApplication()
    {
        return getIsMain() && 
               (getIsContainer() || 
               (getVersion() >= 4 && getIsSimpleStyleComponent()));
    }

    public boolean getIsSimpleStyleComponent()
    {
        return standardDefs.isSimpleStyleComponent(root.getType());
    }

    public final void setLineNumberMap(DualModeLineNumberMap lineNumberMap)
    {
        this.lineNumberMap = lineNumberMap;
    }

    public final DualModeLineNumberMap getLineNumberMap()
    {
        return lineNumberMap;
    }

    public final void setPreloader(String preloader)
    {
        this.preloader = preloader;
    }

    public final String getPreloader()
    {
        return preloader;
    }

    public void setUsePreloader(boolean usePreloader)
    {
        this.usePreloader = usePreloader;
    }

    public final boolean getUsePreloader()
    {
        return usePreloader;
    }

    public String getLanguageNamespace()
    {
        return info.getLanguageNamespace();
    }

    public int getVersion()
    {
        return info.getVersion();
    }

    /**
     * NOTE the phase situation here if super is MXML that is being compiled in this run. In that case, this call will
     * be examining the "public signature" type put together by InterfaceCompiler, *not* the fully built component.
     */
    public final boolean superHasPublicProperty(String name)
    {
        return getSuperClass().getProperty(name) != null;
    }

    /**
     *
     */
    void ensureId(Model model)
    {
        if (model.getId() == null)
        {
            Type type = model.getType();
            assert type != null;

            int i = getAnonIndex(model.getType());

            String id = "_" + NameFormatter.toDot(info.getClassName()).replace('.', '_') +
                        "_" + NameFormatter.retrieveClassName(type.getName().replace('<', '_').replace('>', '_')) + i;
            // String id = "_" + NameFormatter.retrieveClassName(type.getName()) + i;

            model.setId(id, true);
        }
    }

    /**
     * Note: we use the leaf name as our key, rather than the full classname (Foo rather than a.b.c.Foo).
     * This allows us to use generated function names like _Foo, rather than _a_b_c_Foo, for readability.
     */
    private int getAnonIndex(Type type)
    {
        String typeName = NameFormatter.retrieveClassName(type.getName());
        Integer cell = anonIdCounts.get(typeName);
        int i = cell == null ? 1 : cell.intValue();
        anonIdCounts.put(typeName, new Integer(i + 1));
        return i;
    }

    /**
     * Match up two-way binding expressions and setTwoWayCounterpart to indicate partner. 
     */
    public void resolveTwoWayBindings()
    {
        // If there are any two-way bindings, only partially built, now is the time
        // to finish them.
        completeTwoWayBindings();
        
        Map<String, BindingExpression> destinationMap = new HashMap<String, BindingExpression>();

        for (BindingExpression bindingExpression : bindingExpressions)
        {
            // Note that this just strips the parens on the edges of the expression.
            // It's possible the expression was an inline expression which got parsed to
            // something like '(a.text) + "." + (b.text)'.  Since this would never be part of a two-way bind
            // it probably doesn't matter that when the parens are stripped it ends up
            // as 'a.text) + "." + (b.text'.
            String sourceExpression = TextGen.stripParens(bindingExpression.getSourceExpression());
            
            String destinationPath = bindingExpression.getDestinationPath(false);
            BindingExpression match = destinationMap.get(sourceExpression);

            if ((match != null) && destinationPath.equals(TextGen.stripParens(match.getSourceExpression())))
            {
                bindingExpression.setTwoWayCounterpart(match);
            }
            else
            {
                destinationMap.put(destinationPath, bindingExpression);
            }           
        }
    }
    
    /**
     * If a binding expression has isTwoWayPrimary set, this signals that another 
     * binding needs to be created with the source and destination reversed.  
     * This binding couldn't be created until the component registered it's model 
     * which sets the id.
     */
    private void completeTwoWayBindings()
    {
        // A side-effect of creating a new BindingExpression is that it is inserted
        // into the bindingExressions list.  Since we can't add to the list while 
        // iterating thru it, use an array instead.
        Object[] bindingExpressionsArray = bindingExpressions.toArray();        
        for (int i = 0; i < bindingExpressionsArray.length; i++)
        {
            BindingExpression bindingExpression = (BindingExpression) bindingExpressionsArray[i];
            if (bindingExpression.isTwoWayPrimary())
            {
                Model destination = bindingExpression.getDestination();

                if (destination != null)
                {
                    destination.ensureBindable();
                }

                String source2 = bindingExpression.getDestinationPath(false);
                
                BindingExpression bindingExpression2 = 
                    new BindingExpression(source2, bindingExpression.getXmlLineNumber(), this);
                
                String destination2 = TextGen.stripParens(bindingExpression.getSourceExpression());
                bindingExpression2.setDestinationProperty(destination2);
                bindingExpression2.setDestinationLValue(destination2);
            }
        }        
    }

    /**
     * Combine all the binding expression namespaces using the Integer as the 
     * unique key since the namespace int generation is shared across XML and XMLList
     * objects.
     * @return
     */
    public Map<Integer, String> getAllBindingNamespaces()
    {
        Map<Integer, String> allNs = new HashMap<Integer, String>();
        
        for (BindingExpression be : bindingExpressions)
        {
            if (be.getNamespaces() != null)
            {
                allNs.putAll(be.getNamespaces());
            }
        }
        
        return allNs;
    }
    
    public boolean hasBindingTags()
    {
        boolean result = false;

        for (BindingExpression bindingExpression : getBindingExpressions()) 	 
        { 	 
            if (bindingExpression.getDestination() == null) 	 
            {
                result = true;
                break;
            }
        }

        return result;
    }

    /**
     * Called by ClassDefLib.vm to generate the var declarations for all the 	 
     * namespaces used by all the binding expressions. 	 
     */ 	 
    public String getAllBindingNamespaceDeclarations() 	 
    { 	 
        return BindingExpression.getNamespaceDeclarations(getAllBindingNamespaces()); 	 
    } 

    /**
     *
     */
    public void postProcessStates()
    {
    	statesModel.applyMetadata();
    	if (statesModel.processReparents())
    	{
    		statesModel.processStatefulModels();
    		statesModel.setInitialState();  
    	}
    }
   
    /**
     *
     */
    public String getInterfaceList()
    {
        List<String> names = new ArrayList<String>(info.getInterfaceNames().size());
        for (Iterator i = info.getInterfaceNames().iterator(); i.hasNext();)
        {
            names.add(((DocumentInfo.NameInfo) i.next()).getName());
        }
        return TextGen.toCommaList(names.iterator());
    }

    public Set<DocumentInfo.NameInfo> getInterfaceNames()
    {
        return info.getInterfaceNames();
    }

    /**
     *
     */
    public String getWatcherSetupUtilClassName()
    {
        StringBuilder stringBuffer = new StringBuilder("_");

        String packageName = getPackageName();

        if ((packageName != null) && (packageName.length() > 0))
        {
            stringBuffer.append( packageName.replace('.', '_') );
            stringBuffer.append("_");
        }

        stringBuffer.append( getClassName() );
        stringBuffer.append("WatcherSetupUtil");

        return stringBuffer.toString();
    }

    /**
     *
     */
    public CodeFragmentList getDescriptorDeclaration(String name)
    {
        CodeFragmentList fragList = new CodeFragmentList();

        DescriptorGenerator.addDescriptorInitializerFragments(fragList, getRoot(),
                                                              FrameworkDefs.requiredTopLevelDescriptorProperties, true, "");

        fragList.add(0, "private var " + name + " : " + NameFormatter.toDot(standardDefs.CLASS_UICOMPONENTDESCRIPTOR) + " = ", 0);

        return fragList;
    }
    
    /**
     * Generates all code necessary to maintain our stateful model.
     */
    public CodeFragmentList getStatesDeclaration()
    {
        StatesGenerator generator = new StatesGenerator(standardDefs);
        return (getVersion() >= 4) ? generator.getStatesInitializerFragments(statesModel) : new CodeFragmentList();
    }

    /**
     * If an inherited property by the given name exists, we check usage constraints.
     * @return true iff inherited property exists, and an assignment to it (under the given type) is an error.
     */
    private final boolean inheritedPropertyUsageError(String name, Type type, int line)
    {
        assert root != null : "root null in checkInherited";

        Property prop = root.getType().getProperty(name);

        if (prop != null)
        {
            if (!prop.hasPublic())
            {
                ThreadLocalToolkit.log(new NonPublicInheritedPropertyInit(name), getSourcePath(), line);
                return true;
            }

            if (prop.readOnly())
            {
                ThreadLocalToolkit.log(new ReadOnlyInheritedPropertyInit(name), getSourcePath(), line);
                return true;
            }

            if (!type.isAssignableTo(prop.getType()))
            {
                ThreadLocalToolkit.log(
                        new TypeIncompatibleInheritedPropertyInit(
                                name,
                                NameFormatter.toDot(prop.getType().getName()),
                                NameFormatter.toDot(type.getName())),
                        getSourcePath(), line);

                return true;
            }
        }

        return false;
    }

    /*
     * Validates a set of states against our states list to ensure previous 
     * declaration.
     */
    private final boolean unresolvedStateIdentifier(Collection states, int line)
    {
        for (Iterator iter = states.iterator(); iter.hasNext(); )
        {
            String state = (String)iter.next();
            if (!validateState(state, line))
                return true;
        }
        return false;
    }
    
    /*
     * Validates a state against our explicit states list, generate error if
     * not declared.
     */
    public boolean validateState(String state, int line)
    {
        if (!statesModel.validateState(state))
        {
            ThreadLocalToolkit.log(new StateResolutionError(state), getSourcePath(), line);
            return false;
        }
        return true;
    }
    
    /*
     * Validates either an include or exclude state list is specified, (but not
     * both).  Ensures states are valid within specified filter.
     */
    public boolean validateStateFilters(Collection include, Collection exclude, int line)
    {
        if (!include.isEmpty() && !exclude.isEmpty())
        {
            ThreadLocalToolkit.log(new AmbiguousStateFilterError(), getSourcePath(), line);
            return false;
        }
        
        if (unresolvedStateIdentifier(include, line) || unresolvedStateIdentifier(exclude, line))
        {
            return false;
        }
        
        return true;
    }
    
    /**
     * Collection of declared DesignLayer instances that wouldn't otherwise
     * be associated with any layer children. These eventually will become
     * top level declarations.
     */
    public List<DesignLayerNode> getLayerDeclarationNodes()
    {
        return info.getRootNode().layerDeclarationNodes;
    }
    
    /**
     * delegate to FrameworkDefs for names of generated management vars
     */
	public static List<VariableDeclaration> getBindingManagementVars()
    {
        return FrameworkDefs.bindingManagementVars; 
    }

    /*
     * Register a state specific node with our states model.
     */
    public void registerStateSpecificNode(Model model, Node node, Collection<String> includedStates, Collection<String> excludedStates)
    {
        // Validate and then register this stateful node with our states builder.    
        if (validateStateFilters(includedStates, excludedStates, model.getXmlLineNumber()))
        {           
            statesModel.registerStateSpecificNode(model, node, includedStates, excludedStates);
        }
    }
    
    /*
     * Register a state specific property with our states model.
     */
    public void registerStateSpecificProperty(Model model, String property, ValueInitializer value, String stateName)
    {   
        statesModel.registerStateSpecificProperty(model, property, value, stateName);
    }
    
    /*
     * Register a state specific style with our states model.
     */
    public void registerStateSpecificStyle(Model model, String property, ValueInitializer value, String stateName)
    {
        statesModel.registerStateSpecificStyle(model, property, value, stateName);
    }
    
    /*
     * Register a state specific event handler with our states model.
     */
    public void registerStateSpecificEventHandler(Model model, String event, EventInitializer value, String stateName)
    {
        statesModel.registerStateSpecificEventHandler(model, event, value, stateName);
    }
    
    /*
     * Register a realized state model so any event initializers, etc. can be accounted for.
     */
    public void registerState(Model model, Node node)
    {
        statesModel.registerState(model, node);
    }
    
    /*
     * Returns our stateful document model.
     */
    public StatesModel getStatefulModel()
    {
        return statesModel;
    }
    
    /*
     * Denote that a state-specific document node should be instantiated early.
     */
    public void registerEarlyInitNode(Model model)
    {
    	statesModel.registerEarlyInitNode(model);
    }
    
    /**
     * CompilerErrors
     */
    public static class NonPublicInheritedPropertyInit extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 9044603625972071302L;
        public String name;
        public NonPublicInheritedPropertyInit(String name) { this.name = name; }
    }

    public static class ReadOnlyInheritedPropertyInit extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -2959436790426946620L;
        public String name;
        public ReadOnlyInheritedPropertyInit(String name) { this.name = name; }
    }

    public static class TypeIncompatibleInheritedPropertyInit extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -6205552750667618804L;
        public String name, propertyType, valueType;
        public TypeIncompatibleInheritedPropertyInit(String name, String propertyType, String valueType)
        {
            this.name = name;
            this.propertyType = propertyType;
            this.valueType = valueType;
        }
    }
    
    public static class StateResolutionError extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -7520940017001772178L;
        public String name;
        public StateResolutionError(String name) { this.name = name; }
    }
     
    public static class AmbiguousStateFilterError extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 6642005101532059046L;
        public AmbiguousStateFilterError() { }
    }

    public String getComment()
    {
        return comment;
    }

    public void setComment(String comment)
    {
        this.comment = comment;
    }
}




