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

import flex2.compiler.abc.*;
import flex2.compiler.as3.BytecodeEmitter;
import flex2.compiler.as3.binding.TypeAnalyzer;
import flex2.compiler.common.CompilerConfiguration;
import flex2.compiler.common.Configuration;
import flex2.compiler.css.StyleConflictException;
import flex2.compiler.css.Styles;
import flex2.compiler.util.*;
import flex2.tools.oem.ProgressMeter;
import macromedia.asc.util.Context;
import macromedia.asc.util.ContextStatics;
import macromedia.asc.util.Namespaces;
import macromedia.asc.util.ObjectList;

import java.util.*;

/**
 * This class supports looking up information for a class or a style
 * and looking up a <code>Source</code> by QName or by resource bundle
 * name.
 *
 * @author Clement Wong
 */
public final class SymbolTable
{
	// These may look funny, but they line up with the values that ASC uses.
	public static final String internalNamespace = "internal";
	public static final String privateNamespace = "private";
	public static final String protectedNamespace = "protected";
	public static final String publicNamespace = "";
	public static final String unnamedPackage = "";
	public static final String[] VISIBILITY_NAMESPACES = new String[] {SymbolTable.publicNamespace,
																	   SymbolTable.protectedNamespace,
																	   SymbolTable.internalNamespace,
																       SymbolTable.privateNamespace};

	public static final String NOTYPE = "*";
	public static final String STRING = "String";
	public static final String BOOLEAN = "Boolean";
	public static final String NUMBER = "Number";
	public static final String INT = "int";
	public static final String UINT = "uint";
	public static final String NAMESPACE = "Namespace";
	public static final String FUNCTION = "Function";
	public static final String CLASS = "Class";
	public static final String ARRAY = "Array";
	public static final String OBJECT = "Object";
	public static final String XML = "XML";
	public static final String XML_LIST = "XMLList";
	public static final String REPARENT = "Reparent";
	public static final String REGEXP = "RegExp";
	public static final String EVENT = "flash.events:Event";
    public static final String VECTOR = "__AS3__.vec:Vector";

	static class NoType implements flex2.compiler.abc.AbcClass
	{
		public Variable getVariable(String[] namespaces, String name, boolean inherited)
		{
			return null;
		}

        public Variable getVariable(Namespaces namespaces, String name, boolean inherited)
        {
            return null;
        }

		public Method getMethod(String[] namespaces, String name, boolean inherited)
		{
			return null;
		}
        public Method getMethod(Namespaces namespaces, String name, boolean inherited)
        {
            return null;
        }

		public Method getGetter(String[] namespaces, String name, boolean inherited)
		{
			return null;
		}
        public Method getGetter(Namespaces namespaces, String name, boolean inherited)
        {
            return null;
        }

		public Method getSetter(String[] namespaces, String name, boolean inherited)
		{
			return null;
		}
        public Method getSetter(Namespaces namespaces, String name, boolean inherited)
        {
            return null;
        }

        public String getName()
		{
			return NOTYPE;
		}

        public String getElementTypeName()
        {
            return null;
        }

		public String getSuperTypeName()
		{
			return null;
		}

		public String[] getInterfaceNames()
		{
			return null;
		}

        public List<MetaData> getMetaData(boolean inherited)
		{
			return null;
		}

		public List<MetaData> getMetaData(String name, boolean inherited)
		{
			return null;
		}

		public boolean implementsInterface(String interfaceName)
		{
			return false;
		}

		public boolean isSubclassOf(String baseName)
		{
			return false;
		}

		public boolean isInterface()
		{
			assert false;
			return false;
		}

        public boolean isDynamic()
        {
            return true;
        }

        public boolean isPublic()
        {
            return true;
        }

		public void setTypeTable(Object typeTable)
		{
		}

        public Iterator<Variable> getVarIterator()
        {
            return new EmptyIter<Variable>();            
        }
        public Iterator<Method> getMethodIterator()
        {
            return new EmptyIter<Method>();
        }
        public Iterator<Method> getGetterIterator()
        {
            return new EmptyIter<Method>();
        }
        public Iterator<Method> getSetterIterator()
        {
            return new EmptyIter<Method>();
        }

        class EmptyIter<T> implements Iterator<T>
        {
            public boolean hasNext()
            {
                return false;
            }
            public T next()
            {
                throw new NoSuchElementException();
            }
            public void remove()
            {
            }
        }

        public void freeze()
        {
            
        }
	}

	private static final NoType NoTypeClass = new NoType();

    /**
     * This constructor is useful when an existing ContextStatics
     * should be reused.  FlashBuilder entrypoint.
     */
	public SymbolTable(Configuration configuration, ContextStatics contextStatics)
	{
		classTable = new HashMap<String, AbcClass>(300);
		styles = new Styles();
        perCompileData = contextStatics;

        CompilerConfiguration compilerConfiguration = configuration.getCompilerConfiguration();
		perCompileData.use_static_semantics = compilerConfiguration.strict();
		perCompileData.dialect = compilerConfiguration.dialect();
		perCompileData.languageID = Context.getLanguageID(Locale.getDefault().getCountry().toUpperCase());
        perCompileData.setAbcVersion(configuration.getTargetPlayerTargetAVM());

        // Leave out trace() statements when emitting bytecode
        perCompileData.omitTrace = !compilerConfiguration.debug() && compilerConfiguration.omitTraceStatements();

        // set up use_namespaces anytime before parsing begins
        assert configuration.getTargetPlayerRequiredUseNamespaces() != null;
        perCompileData.use_namespaces.addAll(configuration.getTargetPlayerRequiredUseNamespaces());

		ContextStatics.useVerboseErrors = false;
		
		qNameTable = new QNameMap<Source>(300);
		multiNames = new HashMap<MultiName, QName>(1024);
		Context cx = new Context(perCompileData);
		emitter = new BytecodeEmitter(cx, null, false, false);
		cx.setEmitter(emitter);
		typeAnalyzer = new TypeAnalyzer(this);
		
		rbNames = new HashMap<String, QName[]>();
		rbNameTable = new HashMap<String, Source>();
	}

    /**
     * This constructor is useful when starting a fresh compile where
     * a ContextStatics isn't available or doing a one-off compile
     * where an existing ContextStatics shouldn't be poluted.
     * FlashBuilder entrypoint.
     */
	public SymbolTable(Configuration configuration)
	{
        this(configuration, new ContextStatics());
	}

	private final Map<String, AbcClass> classTable;

	// C: if possible, move styles out of SymbolTable...
	private final Styles styles;

	// C: ContextStatics stays here because it holds namespace and type info...
	public final ContextStatics perCompileData;

	private final QNameMap<Source> qNameTable;
	private final Map<MultiName, QName> multiNames;

	// C: This single instance is for ConstantEvaluator to calculate doubles only.
	public final BytecodeEmitter emitter;

	private CompilerContext context;

	// C: please see CompilerConfiguration.suppressWarningsInIncremental
	private boolean suppressWarnings;
	// See CompilerConfiguration.cfgDebug().
    private boolean debug;
	
	private final Map<String, QName[]> rbNames;
	private final Map<String, Source> rbNameTable;
	
	public int tick = 0;
	public int currentPercentage = 0;
	
	public void adjustProgress()
	{
		ProgressMeter meter = ThreadLocalToolkit.getProgressMeter();
		
		for (int i = currentPercentage + 1; meter != null && i <= 100; i++)
		{
			meter.percentDone(i);
		}
	}
	
	public void registerClass(String className, AbcClass cls)
	{
		assert className.indexOf('/') == -1;

		classTable.put(className, cls);
	}

    public AbcClass getClass(String className)
    {
        assert className == null || (className.indexOf('/') == -1) && NameFormatter.toColon(className).equals(className) : className;
        AbcClass result = null;

        if (className != null)
        {
            if (className.equals("*"))
            {
                result = NoTypeClass;
            }
            else
            {
                result = classTable.get(className);
            }
        }

        return result;
    }

    public Set<String> getClassNames()
    {
        return classTable.keySet();
    }

	// app-wide style management

	public void registerStyles(Styles newStyles) throws StyleConflictException
	{
		styles.addStyles(newStyles);
	}

	public MetaData getStyle(String styleName)
	{
		if (styleName != null)
		{
			return styles.getStyle(styleName);
		}
		else
		{
			return null;
		}
	}

	public Styles getStyles()
	{
		return styles;
	}

	/**
	 * It is possible for a Source to define multiple definitions. This method creates mappings between
	 * the definitions and the Source instance.
	 */
	void registerQNames(QNameList qNames, Source source)
	{
		for (int i = 0, size = qNames.size(); i < size; i++)
		{
			QName qN = qNames.get(i);
			qNameTable.put(qN, source);
		}
	}

	/**
	 * If CompilerAPI.resolveMultiName() is successful, the QName result should be associated with a Source object.
	 * Store the mapping here...
	 *
	 * @param qName ClassDefinitionNode.cframe.classname
	 * @param source Source
	 */
	public void registerQName(QName qName, Source source)
	{
		Source old = qNameTable.get(qName);
		if (old == null)
		{
			qNameTable.put(new QName(qName), source);
		}
		else if (!old.getName().equals(source.getName()))
		{
			assert false : qName + " defined in " + old + " and " + source.getName();
		}
	}
	
	public void registerResourceBundle(String rbName, Source source)
	{
		/*
		Source old = (Source) rbNameTable.get(rbName);
		if (old == null)
		{
			rbNameTable.put(rbName, source);
		}
		*/
		rbNameTable.put(rbName, source);
	}

	/**
	 * If CompilerAPI.resolveMultiName() is successful, the QName result should be associated with a Source object.
	 * This method allows for quick lookups given a qname.
	 */
	public Source findSourceByQName(QName qName)
	{
		return qNameTable.get(qName);
	}

	/**
	 * If CompilerAPI.resolveMultiName() is successful, the QName result should be associated with a Source object.
	 * This method allows for quick lookups given a qname.
	 */
	public Source findSourceByQName(String namespaceURI, String localPart)
	{
		return qNameTable.get(namespaceURI, localPart);
	}
	
	public Source findSourceByResourceBundleName(String rbName)
	{
		return rbNameTable.get(rbName);
	}

	/**
	 * If CompilerAPI.resolveMultiName() successfully resolves a multiname to a qname, the result will be stored here.
	 */
	void registerMultiName(MultiName multiName, QName qName)
	{
		multiNames.put(multiName, qName);
	}
	
	void registerResourceBundleName(String rbName, QName[] qNames)
	{
		rbNames.put(rbName, qNames);
	}

	/**
	 * If CompilerAPI.resolveMultiName() successfully resolves a multiname to a qname, the result will be stored here.
	 * This method allows for quick lookup.
	 */
	public QName isMultiNameResolved(MultiName multiName)
	{
		return multiNames.get(multiName);
	}
	
	public QName[] isResourceBundleResolved(String rbName)
	{
		return rbNames.get(rbName);
	}

	/**
	 * placeholder for transient data
	 */
	public CompilerContext getContext()
	{
		if (context == null)
		{
			context = new CompilerContext();
		}

		return context;
	}

	/**
	 * dereference the flex2.compiler.abc.AbcClass instances from flex2.compiler.as3.reflect.TypeTable. This is
	 * necessary for lowering the peak memory. It also makes the instances reusable in subsequent compilations.
	 */
	public void cleanClassTable()
	{
		for (Iterator<String> i = classTable.keySet().iterator(); i.hasNext();)
		{
			flex2.compiler.abc.AbcClass c = classTable.get(i.next());
			c.setTypeTable(null);
		}
	}

	// The following is for TypeAnalyzer only... please do not expand the usage to the other classes...

	private TypeAnalyzer typeAnalyzer;

	public TypeAnalyzer getTypeAnalyzer()
	{
		return typeAnalyzer;
	}
    
    public boolean getSuppressWarningsIncremental()
    {
        return suppressWarnings;
    }
    
    public void register(String rbName, QName[] qNames, Source source)
    {
		if (source != null)
		{
			registerResourceBundleName(rbName, qNames);
			registerResourceBundle(rbName, source);
			
			for (int i = 0, length = qNames == null ? 0 : qNames.length; i < length; i++)
			{
				registerQName(qNames[i], source);
			}
		}
    }
}
