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

import flex2.compiler.mxml.dom.DocumentNode;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.NameMappings;
import flex2.compiler.util.QName;
import flex2.compiler.util.ThreadLocalToolkit;

import java.util.*;

/**
 * Accumulates the results of interface compilation.  Note: our
 * contract includes managing relationships between stored items -
 * e.g.  import names are accumulated as class names come in through
 * various setters
 */
public class DocumentInfo
{
	public static final String OUTER_DOCUMENT_PROP = "outerDocument";

	private DocumentNode rootNode;

	private final String path;
	private String className;
	private String packageName;
	private QName qname;
	private String qualifiedSuperClassName;
	private Set<NameInfo> interfaceNames;
	private Set<NameInfo> importNames;
	private Map<String, String[]> splitImportNames;
	private Set<String> stateNames;
	private Map<String,Collection<String>> stateGroups;
	private Map<String, VarDecl> varDecls;	// key=id, value=className
	private List<Script> scripts;
	private List<Script> metadata;
	private String languageNamespace = "";
	private int version;
	private final StandardDefs standardDefs;

	public DocumentInfo(String path, StandardDefs standardDefs)
	{
		this.path = path;
		this.standardDefs = standardDefs; 
	}

    public String getPath()
    {
        return path;
    }

	/**
	 * set root document node.
	 * <br>Happens in InterfaceCompiler.createDocumentInfo(), right after initial syntax check in parse()
	 */
	public void setRootNode(DocumentNode rootNode, int line)
	{
		assert this.rootNode == null;
		this.rootNode = rootNode;

		//	declare outerDocument property, if specified by root node
		String outerDocumentClassName = rootNode.getOuterDocumentClassName();
		if (outerDocumentClassName != null)
		{
			addVarDecl(OUTER_DOCUMENT_PROP, outerDocumentClassName, line);
		}

		// Record the language version in DocumentInfo for both the interface
		// compiler as well as the implementation compiler downstream...
		version = rootNode.getVersion();
		languageNamespace = rootNode.getLanguageNamespace();

		// -1 represents the unresolved language version
        if (version < 0 || languageNamespace == null)
             ThreadLocalToolkit.log(new UnableToResolveLanguageVersion());

    }

	public StandardDefs getStandardDefs()
	{
	    return standardDefs;
	}

	/**
	 * get root document node
	 */
	public DocumentNode getRootNode()
	{
		assert rootNode != null;
		return rootNode;
	}
	
	/**
	 * set document class name.
	 * <br>Happens in InterfaceCompiler.createDocumentInfo(), right after initial syntax check in parse()
	 */
	public void setClassName(String className)
	{
		assert this.className == null;
		this.className = className;
	}

	/**
	 * get document class name
	 */
	public String getClassName()
	{
		assert className != null;
		return className;
	}

	/**
	 * set document package name.
	 * <br>Happens in InterfaceCompiler.createDocumentInfo(), right after initial syntax check in parse()
	 */
	public void setPackageName(String packageName)
	{
		assert this.packageName == null;
		this.packageName = packageName;
	}

	/**
	 * get document package name
	 */
	public String getPackageName()
	{
		assert packageName != null;
		return packageName;
	}

    public QName getQName()
    {
        return qname != null ? qname : (qname = new QName(packageName, className));
    }

	/**
	 * set document superclass name. adds name to import list.
	 * <br>Happens in InterfaceCompiler.createDocumentInfo(), right after initial syntax check in parse()
	 */
	public void setQualifiedSuperClassName(String qualifiedSuperClassName, int line)
	{
		assert this.qualifiedSuperClassName == null;
		this.qualifiedSuperClassName = qualifiedSuperClassName;
		addImportName(qualifiedSuperClassName, line);
	}

	/**
	 * get document superclass name
	 */
	public String getQualifiedSuperClassName()
	{
		assert qualifiedSuperClassName != null;
		return qualifiedSuperClassName;
	}

	/**
	 * add interface ('implements') name. adds name to import list.
	 * <br>Happens in InterfaceCompiler.createDocumentInfo(), right after initial syntax check in parse()
	 */
	public void addInterfaceName(String interfaceName, int line)
	{
		(interfaceNames != null ? interfaceNames : (interfaceNames = new TreeSet<NameInfo>())).add(new NameInfo(interfaceName, line));
		addImportName(interfaceName, line);
	}

	/**
	 * get Set of document interface ('implements') names
	 */
	public Set<NameInfo> getInterfaceNames()
	{
		return interfaceNames != null ? interfaceNames : Collections.<NameInfo>emptySet();
	}

	/**
	 * add definition name to import set.
	 * <li>- base set of MXML imports is added in InterfaceCompiler.createDocumentInfo()
	 * <li>- various names are added to imports as side effects of their respective setters here:
	 * superclass, interfaces, id-to-classname entries. These are all invoked from InterfaceCompiler.InterfaceAnalyzer,
	 * which traverses the DOM collecting public signature items.
	 * <li>- tag-backing classes, and support classes for built-in tags, are imported as the DOM is traversed
	 * in InterfaceCompiler.DependencyAnalyzer
	 */
	public void addImportName(String importName, int line)
	{
        if (importName.startsWith(StandardDefs.CLASS_VECTOR + ".<") )
        {
            addImportName(importName.substring(StandardDefs.CLASS_VECTOR.length() + 2, importName.length() - 1), line);
        }
        else if(importName.startsWith(StandardDefs.CLASS_VECTOR_SHORTNAME + ".<") )
        {
            addImportName(importName.substring(StandardDefs.CLASS_VECTOR_SHORTNAME.length() + 2, importName.length()-1), line);
        }
        else
        {
            if (!importName.equals("*") && !StandardDefs.isBuiltInTypeName(importName))
            {
                (importNames != null ? importNames : (importNames = new TreeSet<NameInfo>())).add(new NameInfo(importName, line));
            }
        }
	}

	/**
	 * add definition names to import set
	 */
	public void addImportNames(Collection<String> names, int line)
	{
		for (String name : names)
		{
			addImportName(name, line);
		}
	}

	/**
	 * get document import names
	 */
	public Set<NameInfo> getImportNames()
	{
		return importNames != null ? importNames : Collections.<NameInfo>emptySet();
	}
	
    public void removeImportName(String importName)
    {
        for (Iterator<NameInfo> iterator = importNames.iterator(); iterator.hasNext();)
        {
            NameInfo nameInfo = iterator.next();

            if (nameInfo.getName().equals(importName))
            {
                iterator.remove();
                return;
            }
        }
    }

	/**
	 * add presplit definition name to import set
	 */
	public void addSplitImportName(String importName, String[] splitImportName)
	{
        if (splitImportNames == null)
        {
            splitImportNames = new TreeMap<String, String[]>();
        }

        splitImportNames.put(importName, splitImportName);
	}

	/**
	 * add presplit definition names to import set
	 */
	public void addSplitImportNames(Map<String, String[]> names)
	{
        if (splitImportNames == null)
        {
            splitImportNames = new TreeMap<String, String[]>();
        }

        splitImportNames.putAll(names);
	}

	public Collection<String[]> getSplitImportNames()
	{
		return splitImportNames != null ? splitImportNames.values() : Collections.<String[]>emptyList();
	}

    public void removeSplitImportName(String importName)
    {
        if (splitImportNames != null)
        {
            splitImportNames.remove(importName);
        }        
    }

	/**
	 * adds state name to states list.
	 */
	public void addStateName(String stateName, int line)
	{
		if (stateGroups != null && stateGroups.containsKey(stateName))
		{
			ThreadLocalToolkit.log(new AmbiguousStateIdentifier(stateName), path, line);
		}
		
		stateNames = (stateNames != null) ? stateNames : new LinkedHashSet<String>();
		stateNames.add(stateName);
	}
	
	/**
	 * adds state group name and adds specified state to group.
	 */
	public void addStateGroup(String groupName, String stateName, int line)
	{
		if (stateNames != null && stateNames.contains(groupName))
		{
			ThreadLocalToolkit.log(new AmbiguousStateIdentifier(groupName), path, line);
		}
		
		stateGroups = (stateGroups != null) ? stateGroups : new HashMap<String, Collection<String>>();
		Collection<String> states = stateGroups.get(groupName);
        states = (states != null) ? states : new ArrayList<String>();
        states.add(stateName);
        stateGroups.put(groupName, states);
	}
	
	/**
	 * get state group map
	 */
    public Map<String, Collection<String>> getStateGroups()
	{
		return stateGroups != null ? stateGroups : Collections.<String, Collection<String>>emptyMap();
	}
	
	/**
	 * get Set of state names
	 */
	@SuppressWarnings("unchecked")
    public Set<String> getStateNames()
	{
		return stateNames != null ? stateNames : Collections.EMPTY_SET;
	}
    
	/**
	 * add name -> className mapping.
	 * <br>This set is built as InterfaceCompiler.InterfaceAnalyzer traverses the DOM, collecting items needed
	 * to generate the public signature of the class to be generated.
	 */
	public void addVarDecl(String name, String className, int line)
	{
		VarDecl ref = new VarDecl(name, className, line);
		(varDecls != null ? varDecls : (varDecls = new LinkedHashMap<String, VarDecl>())).put(name, ref);
		addImportName(className, line);
	}

    public void addVectorVarDecl(String name, int line, String elementTypeName)
    {
		VarDecl ref = new VarDecl(name, StandardDefs.CLASS_VECTOR + ".<" + elementTypeName + ">", line);
		(varDecls != null ? varDecls : (varDecls = new LinkedHashMap<String, VarDecl>())).put(name, ref);

        int dotLessThanIndex = elementTypeName.lastIndexOf(".<");

        if (dotLessThanIndex != -1)
        {
            int greaterThanIndex = elementTypeName.indexOf(">");

            if (greaterThanIndex != -1)
            {
                addImportName(StandardDefs.CLASS_VECTOR, line);
                addImportName(elementTypeName.substring(dotLessThanIndex + 2, greaterThanIndex), line);
            }
        }
        else
        {
            addImportName(elementTypeName, line);
        }
    }

	/**
	 * get id to class name map
	 */
	public Map<String, VarDecl> getVarDecls()
	{
		return varDecls != null ? varDecls : Collections.<String, VarDecl>emptyMap();
	}

	/**
	 * return true iff id is present in map
	 */
	public boolean containsVarDecl(String id)
	{
		return getVarDecls().containsKey(id);
	}

	/**
	 * add script.
	 * <br>The script list is built as InterfaceCompiler.InterfaceAnalyzer traverses the DOM, collecting items needed
	 * to generate the public signature of the class to be generated.
	 */
	public void addScript(Script script)
	{
		(scripts != null ? scripts : (scripts = new ArrayList<Script>())).add(script);
	}

	/**
	 * get script list
	 */
	public List<Script> getScripts()
	{
		return scripts != null ? scripts : Collections.<Script>emptyList();
	}

	/**
	 * add metadata script..
	 * <br>The metadata script list is built as InterfaceCompiler.InterfaceAnalyzer traverses the DOM, collecting items needed
	 * to generate the public signature of the class to be generated.
	 */
	public void addMetadata(Script metadatum)
	{
		(metadata != null ? metadata : (metadata = new ArrayList<Script>())).add(metadatum);
	}

	/**
	 * get metadata script list
	 */
	public List<Script> getMetadata()
	{
		return metadata != null ? metadata : Collections.<Script>emptyList();
	}

    /**
     * Maps a qualified tag name to a Class name for a local document.
     * 
     * @param namespace The tag namespace URI.
     * @param localPart The tag name.
     * @param className The name of the local Class.
     */
    public void addLocalClass(String namespace, String localPart, String className)
    {
        assert rootNode != null;
        rootNode.addLocalClass(namespace, localPart, className);
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
        if (rootNode == null)
            return null;

        return rootNode.getLocalClass(namespace, localPart);
    }

    /**
     * @return The collection of local class mappings for this DocumentNode.
     */
    public NameMappings getLocalClassMappings()
    {
        if (rootNode == null)
            return null;

        return rootNode.getLocalClassMappings();
    }

    /**
     * The language namespace for this document.
     *
     * @return String the URI representing the language namespace.
     */
    public String getLanguageNamespace()
    {
        return languageNamespace;
    }

    /**
     * Updates the language namespace for this document.
     *
     * @param namespace
     */
    public void setLanguageNamespace(String namespace)
    {
        languageNamespace = namespace;
    }

	/**
	 * Reports the MXML language version based on the language namespace
	 * found on the document Node. This version instructs the compiler
	 * as to which rules are in effect and is an integer to allow for relative
	 * comparison.
	 */
	public int getVersion()
	{
		return version;
	}

	/**
	 * Overrides the MXML language version.
	 */
	public void setVersion(int version)
	{
		this.version = version;
	}

    public static class AmbiguousStateIdentifier extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -7799411281259631895L;
        public String name;
        public AmbiguousStateIdentifier(String name) { this.name = name; }
    }

    public static class UnableToResolveLanguageVersion extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -8221325833364429728L;

        public UnableToResolveLanguageVersion()
        {
        }
    }
    
	/**
	 * This value object represents a name, class name, and line
	 * number triple.
	 */
	public static class VarDecl
	{
		public final String name, className;
		public final int line;

		VarDecl(String name, String className, int line)
		{
			this.name = name;
			this.className = className;
			this.line = line;
		}
	}

	/**
	 * This value object represents a name and line number pair.
	 */
	public static class NameInfo implements Comparable
	{
		NameInfo(String name, int line)
		{
			this.name = name;
			this.line = line;
		}

		public int compareTo(Object o)
		{
			return o instanceof NameInfo ? name.compareTo(((NameInfo) o).name) : 0;
		}

		public String toString()
		{
			return name;
		}

        public String getName()
        {
            return name;
        }

        public int getLine()
        {
            return line;
        }

		private final String name;
		private final int line;
	}
}
