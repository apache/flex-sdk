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

package flex2.compiler;

import flex2.compiler.abc.AbcClass;
import flex2.compiler.abc.MetaData;
import flex2.compiler.css.Styles;
import flex2.compiler.css.StylesContainer;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.util.*;
import macromedia.asc.parser.MetaDataNode;
import macromedia.asc.semantics.ObjectValue;
import macromedia.asc.util.ByteList;

import java.util.*;

/**
 * This class hold all the information related to compiling a single
 * <code>Source</code> object.
 *
 * @author Clement Wong
 * @see flex2.compiler.Source
 */
public final class CompilationUnit
{
    // Jono: When adding a getter/setter to CU, be sure to update Source.copy()
    
	public static final int Empty = 0;
	public static final int SyntaxTree = 1;
	public static final int abc = 2;
	public static final int Done = 4;

	static final String COMPILATION_UNIT = CompilationUnit.class.getName();

	// C: not a public constructor
	CompilationUnit(Source source, Object syntaxTree, CompilerContext context)
	{
		this.source = source;
		this.syntaxTree = syntaxTree;
		this.context = context;
		reset();
	}

	/**
	 * CompilationUnit()
	 */
	private Source source;

	/**
	 * SubCompiler.parse()
	 */
	private Object syntaxTree;

	/**
	 * CompilationUnit()
	 */
	private CompilerContext context;

	/**
	 * SubCompiler.parse()
	 */
	private Assets assets;

	/**
	 * SubCompiler.parse(), analyze1234(), generate()
	 */
	private int state;
	private int workflow;

    /**
     * The version of StandardDefs used to build this CompilationUnit  
     */
    private StandardDefs standardDefs;

	/**
	 * SubCompiler.generate()
	 */
	public ByteList bytes;

	/**
	 * SubCompiler.parse(), AS3 metadata only
	 */
	public Set<MetaDataNode> metadata; // MetaDataNodes may reference huge DefinitionNode

	/**
	 * SubCompiler.parse(), AS3 metadata only, doesn't pull in dependencies
	 */
	public MetaData swfMetaData;

	/**
	 * The value from [IconFile] metadata.
	 */
    public String icon;

	/**
     * Represents the resolved <code>icon</code>.
     */
	public VirtualFile iconFile;

	/**
	 * SubCompiler.parse(), AS3 metadata only, not this unit's dependency, processed by getExtraSources()
	 */
	public String loaderClass;

	/**
	 * SubCompiler.analyze4(), AS3 metadata only, module factory base class, not this unit's dependency
	 */
	public String loaderClassBase;

	/**
	 * SubCompiler.parse(), PreLink (styles), AS3 metadata, not this unit's dependencies, processed by getExtraSources()
	 */
	public Set<String> extraClasses;

	/**
	 * inline components, embeds, WatcherSetupUtil, unit.expressions, processed by addGeneratedSources()
	 */
	private Map<QName, Source> generatedSources;

	/**
	 * AbstractDocumentBuilder, should persist
	 */
	public Map<String, Object> auxGenerateInfo; // context gets cleared, need something to survive

	/**
	 * SubCompiler.parse(), AS3 metadata only, FlexInit class's dependencies, not this unit's dependencies, CompcPreLink, PreLink, in this unit's swc
	 */
	private Set<String> accessibilityClasses;

	/**
	 * SubCompiler.parse(), AS3 metadata only, processed by getExtraSources(), not this unit's dependency, in this unit's swc
	 */
    public Map<String, String> licensedClassReqs; // class-in-this-unit to licensed product id

	/**
	 * SubCompiler.parse(), AS3 metadata only, doesn't pull in dependencies, PreLink
	 */
    public Map<String, String> remoteClassAliases; // class-in-this-unit to alias

	/**
	 * SubCompiler.parse(), AS3 metadata only, doesn't pull in dependencies, FlexInit, PreLink
	 */
	public Map<String, String> effectTriggers;

	/**
	 * SubCompiler.parse(), PreLink (fontface rules), AS3 metadata, not this unit's dependencies, FlexInit only references by names
	 */
	public Set<String> mixins; // classes in this unit to call init on

	/**
	 * SubCompiler.parse(), AS3 metadata only, not this unit's dependencies, processed by getExtraSources()
	 */
	public Set<String> resourceBundles;       // classes in this unit to add as resource bundles
	public Set<String> resourceBundleHistory; // classes in this unit to add as resource bundles

	public QNameList topLevelDefinitions;
    /**
     * Set of 'inheritance' dependencies.
     */
	public Set<Name> inheritance;
    /**
     * Set of 'type' dependencies.
     */
	public Set<Name> types;
    /**
     * Set of 'expression' dependencies.
     */
	public Set<Name> expressions;
    /**
     * Set of 'namespace' dependencies
     */
	public Set<Name> namespaces;
	public Set<String> importPackageStatements;
	public QNameSet importDefinitionStatements; // QName

	public MultiNameMap inheritanceHistory;
	public MultiNameMap typeHistory;
	public MultiNameMap namespaceHistory;
	public MultiNameMap expressionHistory;


	public Styles styles;
    public String styleName;
    public HashSet<String> skinStates;

	/**
	 * only MXML components set StylesContainer
	 */
	private StylesContainer stylesContainer;

	public boolean hasTypeInfo;
	public ObjectValue typeInfo;
	public Map<String, AbcClass> classTable;
	
	public MetaDataNode hostComponentMetaData;
	public String hostComponentOwnerClass;
    
    /**
     * The CRC32 of the class signature, coming from SignatureExtension.
     * Null means a signature wasn't generated.
     * 
     * Used by SignatureExtension, PersistenceStore, API::validateCompilationUnits 
     */
    // TODO Only AS Sources can have these, should this really be here?
    // TODO it doesn't feel right to do this here, since Signatures are Extensions...
    //      where should an extension store its data?
    private Long signatureChecksum;
    
    public void setSignatureChecksum(Long signatureChecksum)
    {
        this.signatureChecksum = signatureChecksum;
    }
    
    public Long getSignatureChecksum()
    {
        return signatureChecksum;
    }
    
    public boolean hasSignatureChecksum()
    {
        return signatureChecksum != null;
    }

	/**
	 * equivalent to setting this = new CompilationUnit(this.source, this.syntaxTree, this.context)
	 */
	private void resetKeepTypeInfo()
	{
		assets = null;
        
        //TODO is this correct? should it go in reset()? if here, I assume the CU will get run
        //     through the AS3 compiler again?
        signatureChecksum = null;

		state = Empty;
		workflow = 0;

		if (bytes == null)
		{
			bytes = new ByteList();
		}
		else
		{
			bytes.clear();
		}

		if (metadata == null)
		{
			metadata = new HashSet<MetaDataNode>();
		}
		else
		{
			metadata.clear();
		}

		swfMetaData = null;
		iconFile = null;
		loaderClass = null;

		if (extraClasses == null)
		{
			extraClasses = new HashSet<String>();
		}
		else
		{
			extraClasses.clear();
		}

		generatedSources = null;
		auxGenerateInfo = null;
		accessibilityClasses = null;

		if (remoteClassAliases == null)
		{
			remoteClassAliases = new HashMap<String, String>(1);
		}
		else
		{
			remoteClassAliases.clear();
		}

        if (licensedClassReqs == null)
        {
            licensedClassReqs = new HashMap<String, String>(1);
        }
        else
        {
            licensedClassReqs.clear();
        }

        if (effectTriggers == null)
		{
			effectTriggers = new HashMap<String, String>(1);
		}
		else
		{
			effectTriggers.clear();
		}

		mixins = new HashSet<String>(2);

		if (resourceBundles == null)
		{
			resourceBundles = new HashSet<String>(1);
			resourceBundleHistory = new HashSet<String>(1);
		}
		else
		{
			resourceBundles.clear();
			resourceBundleHistory.clear();
		}

		if (topLevelDefinitions == null)
		{
			topLevelDefinitions = new QNameList(source.isSourcePathOwner() || source.isSourceListOwner() ? 1 : 8);
		}
		else
		{
			topLevelDefinitions.clear();
		}

		if (inheritance == null)
		{
			inheritance = new HashSet<Name>(2);
			types = new HashSet<Name>(8);
			expressions = new HashSet<Name>(8);
			namespaces = new HashSet<Name>(2);
			importPackageStatements = new HashSet<String>(16);
			importDefinitionStatements = new QNameSet(16);

			inheritanceHistory = new MultiNameMap(2);
			typeHistory = new MultiNameMap(8);
			expressionHistory = new MultiNameMap(8);
			namespaceHistory = new MultiNameMap(2);
		}
		else
		{
			inheritance.clear();
			types.clear();
			expressions.clear();
			namespaces.clear();
			importPackageStatements.clear();
			importDefinitionStatements.clear();

			inheritanceHistory.clear();
			typeHistory.clear();
			expressionHistory.clear();
			namespaceHistory.clear();
		}

		if (styles == null)
		{
			styles = new Styles(2);
		}
		else
		{
			styles.clear();
		}
		
		checkBits = 0;
	}

	void reset()
	{
		resetKeepTypeInfo();
		removeTypeInfo();
	}

	void removeTypeInfo()
	{
		hasTypeInfo = false;
		typeInfo = null;
		if (classTable == null)
		{
			classTable = new HashMap<String, AbcClass>((source.isSourcePathOwner() || source.isSourceListOwner()) ? 4 : 8);
		}
		else
		{
			classTable.clear();
		}
	}

	public boolean isRoot()
	{
		return source.isRoot();
	}

	// used by InterfaceAnalyzer.createInlineComponentUnit()
	public void addGeneratedSource(QName defName, Source source)
	{
		if (generatedSources == null)
		{
			generatedSources = new HashMap<QName, Source>();
		}
		generatedSources.put(defName, source);
	}

	// used by DataBindingExtension, EmbedEvaluator
	public void addGeneratedSources(Map<QName, Source> generatedSources)
	{
		if (generatedSources != null)
		{
			if (this.generatedSources == null)
			{
				this.generatedSources = new HashMap<QName, Source>();
			}
			this.generatedSources.putAll(generatedSources);
		}
	}

	public void clearGeneratedSources()
	{
		generatedSources = null;
	}

	public Map<QName, Source> getGeneratedSources()
	{
		return generatedSources;
	}

	public Source getSource()
	{
		return source;
	}

	void setState(int flag)
	{
		state |= flag;

		if (flag == abc)
		{
			syntaxTree = null;

            if (!isRoot())
            {
                // For non-root CompilationUnit's we shouldn't have to
                // do any more resolving.  Root CompilationUnit's
                // might need to do some style related resolving
                // during PreLink.
                source.setPathResolver(null);
                // We don't want to disconnect the root's logger,
                // because we use it in PreLink when we validate the
                // StylesContainer.
                source.disconnectLogger();
            }
		}
		else if (flag == Done)
		{
			hasTypeInfo = typeInfo != null;
			context.clear();
			metadata.clear();
			source.clearSourceFragments();
		}
	}

	int getState()
	{
		return state;
	}

	public boolean isBytecodeAvailable()
	{
		return (state & abc) != 0;
	}

	public boolean isDone()
	{
		return (state & Done) != 0;
	}

	void setWorkflow(int flag)
	{
		workflow |= flag;
	}

	int getWorkflow()
	{
		return workflow;
	}

	public Object getSyntaxTree()
	{
		return syntaxTree;
	}

	public void setSyntaxTree(Object syntaxTree)
	{
		this.syntaxTree = syntaxTree;
	}

	public CompilerContext getContext()
	{
		return context;
	}

	public Assets getAssets()
	{
        if (assets == null)
        {
            assets = new Assets();
        }

		return assets;
	}

    public boolean hasAssets()
    {
        return (assets != null) && (assets.count() > 0);
    }

	public void addAccessibilityClasses(CompilationUnit u)
	{
		if (u.accessibilityClasses != null)
		{
			if (accessibilityClasses == null)
			{
				accessibilityClasses = new HashSet<String>();
			}
			accessibilityClasses.addAll(u.accessibilityClasses);
		}
	}

	public void addAccessibilityClass(MetaData metadata)
	{
		if (accessibilityClasses == null)
		{
			accessibilityClasses = new HashSet<String>();
		}

		String accessibilityClass = metadata.getValue("implementation");
		if (!accessibilityClasses.contains(accessibilityClass))
		{
			accessibilityClasses.add(accessibilityClass);
		}
	}

	public Set<String> getAccessibilityClasses()
	{
		return accessibilityClasses;
	}

	public byte[] getByteCodes()
	{
		return bytes.toByteArray(false);
	}

	public StylesContainer getStylesContainer()
	{
		return stylesContainer;
	}

	public void setStylesContainer(StylesContainer stylesContainer)
	{
		this.stylesContainer = stylesContainer;
	}

	public StandardDefs getStandardDefs()
	{
	    return standardDefs;
	}

	public void setStandardDefs(StandardDefs defs)
	{
	    standardDefs = defs;
	}

	public boolean equals(Object obj)
	{
		if (obj instanceof CompilationUnit)
		{
			return ((CompilationUnit) obj).getSource() == getSource();
		}
		else
		{
			return false;
		}
	}

	// C: There is no need to persist this value. Ideally it should be in Context, but using Integer
	//    is going to be a bit slower than using int.
	public int checkBits = 0;

	public String toString()
	{
		return source.getName();
	}
}
