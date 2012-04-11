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

package flex2.compiler.asdoc;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import macromedia.asc.parser.AttributeListNode;
import macromedia.asc.parser.ClassDefinitionNode;
import macromedia.asc.parser.DocCommentNode;
import macromedia.asc.parser.FunctionDefinitionNode;
import macromedia.asc.parser.InterfaceDefinitionNode;
import macromedia.asc.parser.LiteralBooleanNode;
import macromedia.asc.parser.LiteralNullNode;
import macromedia.asc.parser.LiteralNumberNode;
import macromedia.asc.parser.LiteralStringNode;
import macromedia.asc.parser.MemberExpressionNode;
import macromedia.asc.parser.MetaDataEvaluator;
import macromedia.asc.parser.MetaDataNode;
import macromedia.asc.parser.Node;
import macromedia.asc.parser.PackageDefinitionNode;
import macromedia.asc.parser.ParameterListNode;
import macromedia.asc.parser.ParameterNode;
import macromedia.asc.parser.RestParameterNode;
import macromedia.asc.parser.Tokens;
import macromedia.asc.parser.TypeExpressionNode;
import macromedia.asc.parser.VariableBindingNode;
import macromedia.asc.parser.VariableDefinitionNode;
import macromedia.asc.semantics.ObjectValue;
import macromedia.asc.semantics.ParameterizedName;
import macromedia.asc.semantics.ReferenceValue;
import macromedia.asc.semantics.Slot;
import macromedia.asc.semantics.TypeValue;
import macromedia.asc.semantics.Value;
import macromedia.asc.util.Context;
import flash.util.Trace;

import flex2.compiler.abc.AbcClass;
import flex2.compiler.abc.MetaData;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.QName;
import flex2.compiler.util.ThreadLocalToolkit;

/**
 * ClassTable stores the CommentsTables containing CommentEntrys
 * in a LinkedHashMap. The key to each CommentsTable is the package 
 * name and class name in dot format. (Ex. the class Foo in the 
 * package Bar would be Bar.Foo and the class Cheese in the default
 * (empty) package would be Cheese). It also keeps a separate Map
 * containing each unique package name linked to a CommentEntry for
 * that package (if it exists). A HashSet is used to quickly check
 * for known tag names.
 * 
 * @author klin
 *
 */
public class ClassTable implements DocCommentTable {
    
    private LinkedHashMap<String, CommentsTable> classTable;
    private LinkedHashMap<String, DocComment> packageTable;
    private HashSet<String> tagNames;
    private boolean restoreBuiltinClasses = false;
    
    public ClassTable(boolean restoreBuiltinClasses)
    {
        classTable = new LinkedHashMap<String, CommentsTable>();
        packageTable = new LinkedHashMap<String, DocComment>();
        tagNames = new HashSet<String>();
        tagNames.add("author");
        tagNames.add("copy");
        tagNames.add("default");
        tagNames.add("event");
        tagNames.add("eventType");
        tagNames.add("example");
        tagNames.add("helpid");
        tagNames.add("includeExample");
        tagNames.add("inheritDoc");
        tagNames.add("internal");
        tagNames.add("langversion");
        tagNames.add("param");
        tagNames.add("playerversion");
        tagNames.add("private");
        tagNames.add("productversion");
        tagNames.add("return");
        tagNames.add("review");
        tagNames.add("see");
        tagNames.add("throws");
        tagNames.add("tiptext");
        tagNames.add("toolversion");
        tagNames.add("description");
        tagNames.add("since");
        this.restoreBuiltinClasses = restoreBuiltinClasses;
    }
    
    
    /**
     * Adds comments to the table. Sorts them by package. Also, makes sure all
     * packages are present in the packageTable.
     * 
     * @param name
     * @param comments
     * @param inheritance
     * @param exclude
     * @param cx
     */
    public void addComments(QName name, List comments, 
            Set<QName> inheritance, boolean exclude, Context cx, AbcClass abcClass)
    {
        String packageName = name.getNamespace().intern();
        String className = name.getLocalPart().intern();
        //CommentNodes belonging to the public class (or function)
        List<DocCommentNode> mainClass = new ArrayList<DocCommentNode>();
        //CommentNodes belonging to private classes and their inheritance
        LinkedHashMap<String, List<DocCommentNode>> otherClasses = new LinkedHashMap<String, List<DocCommentNode>>();
        Map<String, Set<QName>> otherInheritance = new LinkedHashMap<String, Set<QName>>();
        //Whether there is a public class declaration
        boolean mainDef = false;
        //asc generated package
        String otherPackage = null;
        
        //sorting all the comments and pulling out other classes that are out of the package
        for (int i = 0; i < comments.size(); i++)
        {
            DocCommentNode current = (DocCommentNode)comments.get(i);
            String pkg = "";  //package name
            String cls = "";  //class name
            String debug;
            if (current.def instanceof PackageDefinitionNode)
            {
                mainClass.add(current);
                continue;
            }
            else if (current.def instanceof ClassDefinitionNode)
            {
                ClassDefinitionNode cd = (ClassDefinitionNode)current.def;
                
                debug = cd.debug_name;
                int colon = debug.indexOf(':');
                if (colon < 0) //empty package
                {
                    pkg = "";
                    cls = debug.intern();
                }
                else
                {
                    pkg = debug.substring(0, colon).intern();
                    cls = debug.substring(colon + 1).intern();
                }
                if (cls.equals(className) && pkg.equals(packageName))
                    mainDef = true;
                else
                {
                    if (otherPackage == null)
                        otherPackage = pkg;
                    
                    //if not the public class, we need to create our own inheritance set
                    Set<QName> inherit = new HashSet<QName>(); 
                    otherInheritance.put(cls, inherit);
                    List inherited = cd.used_def_namespaces;
                    for (int j = 0; j < inherited.size(); j++)
                    {
                        String s = inherited.get(j).toString().intern();
                        //Make sure that the inheritance list doesn't contain itself or a package.
                        if (!s.equals(debug) && !s.equals(otherPackage))
                        {
                            QName q = new QName(s);
                            if (!q.getLocalPart().equals(""))
                            {
                                assert !((q.getLocalPart().equals(cls)) && (q.getNamespace().equals(pkg))) : "same class";
                                inherit.add(q);
                            }
                        }
                    }
                }
            }
            else if (current.def instanceof FunctionDefinitionNode)
            {
                FunctionDefinitionNode fd = (FunctionDefinitionNode)current.def;
                debug = fd.fexpr.debug_name;
                int colon = debug.indexOf(':');
                int slash = debug.indexOf('/');
                if (colon < 0)
                {
                    pkg = "";
                    if (slash < 0) //when there's only a name (Ex. debug == Foobar)
                        cls = "";
                    else  //when there happens to be a slash (Ex. debug == Class/Function)
                        cls = debug.substring(0, slash).intern();
                }
                else
                {
                    pkg = debug.substring(0, colon).intern();
                    if (slash < 0)   //when you have debug == packageName:Function
                        cls = "";
                    else if (slash < colon)  //when debug == className/private:something (mxml case)
                    {
                        pkg = "";
                        cls = debug.substring(0, slash).intern();
                    }
                    else  //when debug == packageName:className/Function
                        cls = debug.substring(colon + 1, slash).intern();
                }
            }
            else if (current.def instanceof VariableDefinitionNode)
            {
                VariableBindingNode vb = (VariableBindingNode)(((VariableDefinitionNode)current.def).list.items.get(0));
                debug = vb.debug_name;
                int colon = debug.indexOf(':');
                int slash = debug.indexOf('/');
                if (colon < 0)
                {
                    pkg = "";
                    if (slash < 0)
                        cls = "";
                    else
                        cls = debug.substring(0, slash).intern();
                }
                else
                {
                    pkg = debug.substring(0, colon).intern();
                    if (slash < 0)
                        cls = "";
                    else if (slash < colon)
                    {
                        pkg = "";
                        cls = debug.substring(0, slash).intern();
                    }
                    else
                        cls = debug.substring(colon + 1, slash).intern();
                }
            }
            //Add to list for other classes (they will be in a separate package)
            if (!pkg.equals(packageName))
            {
                if (cls.equals(""))
                    cls = "null";
                List<DocCommentNode> l = otherClasses.get(cls);
                if (l == null)
                    l = new ArrayList<DocCommentNode>();
                l.add(current);
                otherClasses.put(cls, l);
            }
            else  //Add to list for public class
                mainClass.add(current);
        }
        
        if (mainDef)  //there exists a public class definition
            this.put(name, mainClass, inheritance, exclude, cx, abcClass);
        else    //null classname for package level functions
            this.put(new QName(packageName, "null"), mainClass, inheritance, exclude, cx, abcClass);
        
        //for classes outside the package but in the same sourcefile (should be private, but we exclude anyway)
        if (otherPackage != null)
        {
            Iterator<String> iter = otherClasses.keySet().iterator();
            while (iter.hasNext())
            {
                //Add other classes under asc generated package name
                String cls = iter.next().intern();
                this.put(new QName(otherPackage, cls), otherClasses.get(cls), otherInheritance.get(cls), true, cx, abcClass);
            }
        }
        
        //This is to ensure that the packageTable contains all the package names (as keys).
        if (!packageTable.containsKey(packageName))
            packageTable.put(packageName, null);
        if (otherPackage != null && !packageTable.containsKey(otherPackage))
            packageTable.put(otherPackage, null);
    }
    
    private void put(QName name, List<DocCommentNode> comments, Set<QName> inheritance, boolean exclude, Context cx, AbcClass abcClass)
    {
        CommentsTable table = classTable.get(NameFormatter.toDot(name));
        if(table == null ) 
        {
            table = new CommentsTable(name.getNamespace(), name.getLocalPart(), inheritance, exclude, cx, abcClass);
        }
        
        int temp = comments.size();
        for (int i = 0; i < temp; i++)
        {
            DocCommentNode tempNode = comments.get(i);
            DocComment tempComment = table.addComment(tempNode);
            
            //keep a reference to the first packageEntry encountered for each package.
            if (packageTable.get(name.getNamespace()) == null && tempComment != null)
                if (tempComment.getType() == DocComment.PACKAGE)
                    packageTable.put(name.getNamespace(), tempComment);
        }
        classTable.put(NameFormatter.toDot(name), table);
    }
    
    /**
     * Getter method to return all comments for a class.
     */
    public List<DocComment> getAllClassComments(String className, String packageName)
    {
        try
        {
            if (packageName == null)
                packageName = "";
            if (className == null || className.equals(""))
                className = "null";
            String name = NameFormatter.toDot(new QName(packageName, className));
            CommentsTable temp = classTable.get(name);
            return new ArrayList<DocComment>(temp.values());
        } catch (NullPointerException e)
        {
            return null;   //if a given class/package do not exist
        }
    }

    public Map<String, DocComment> getClassesAndInterfaces(String packageName)
    {
        return getCsOrIs(packageName, true, true);
    }
    
    /**
     * Helper function for getting Classes/Interfaces/Both.
     * @param packageName
     * @param c
     * @param i
     * @return
     */
    private Map<String, DocComment> getCsOrIs(String packageName, boolean c, boolean i)
    {
        if (packageName == null)
            packageName = "";
        Map<String, DocComment> comments = new LinkedHashMap<String, DocComment>();
        Iterator<String> iter = classTable.keySet().iterator();
        while (iter.hasNext())
        {
            String key = iter.next();
            int dot = key.lastIndexOf(".");
            
            //Case when in empty package. ("null" package signifies top-level functions/variables)
            // we also want the "null" key - that is for top level functions.. 
            if (dot < 0 && packageName.equals("") )
            {
                CommentsTable temp1 = classTable.get(key);
                if (!temp1.isInterface() && c)
                    comments.put(key, temp1.get(new KeyPair(key, DocComment.CLASS)));
                else if (i)
                    comments.put(key, temp1.get(new KeyPair(key, DocComment.INTERFACE)));
            }
            else if (dot >= 0 && (key.substring(0, dot)).equals(packageName))  //must match packageName
            {
                CommentsTable temp1 = classTable.get(key);
                String key2 = key.substring(dot + 1);
                if (!temp1.isInterface() && c)
                    comments.put(key2, temp1.get(new KeyPair(key, DocComment.CLASS)));
                else if (i)
                    comments.put(key2, temp1.get(new KeyPair(key, DocComment.INTERFACE)));
            }
        }
        return comments;
    }
    
    public Map<String, DocComment> getPackages()
    {
        return new LinkedHashMap<String, DocComment>(packageTable);
    }
    
    /**
     * A CommentsTable stores CommentEntries in itself by extending
     * TreeMap. The key is a private utility class KeyPair that
     * stores a name and integer type. Extending TreeMap keeps the
     * CommentEntries in the order provided by KeyPair. CommentsTable
     * also assists in finding the correct CommentEntry to inherit
     * documentation from.
     * 
     * 
     * @author klin
     *
     */
    private class CommentsTable extends TreeMap<KeyPair, DocComment> {
        
        private static final long serialVersionUID = 5737364574357983642L;
        private boolean exclude;
        private Set<QName> inheritance;
        private macromedia.asc.util.Context cx;
        private boolean isInterface;
        private AbcClass abcClass;
        
        private List<CommentEntry> skinPartMetadataList;
        
        /*
         * Stores the list of function generated as a result of [Bindable] 
         * where the function also had skinpart metadata
         */
        private Set<String> functionToIgnoreSet;
        
        public CommentsTable(String packageName, String className, Set<QName> inheritance, boolean exclude, Context cx, AbcClass abcClass)
        {
            super();
            this.exclude = exclude;
            this.inheritance = inheritance;
            this.cx = cx;
            this.abcClass = abcClass;
        }
        
        /** 
         * Adds a comment to the table.
         * 
         * @param comment
         * @param exclude
         */
        public DocComment addComment(DocCommentNode comment)
        {
            CommentEntry entry = new CommentEntry(comment, exclude);
            if (entry.key.type == DocComment.INTERFACE)
                isInterface = true;
            
            if(entry.getSkinPartMetadata() != null)
            {
                if (skinPartMetadataList == null)
                {
                    skinPartMetadataList = new ArrayList<CommentEntry>();
                }
                
                skinPartMetadataList.add(entry.getSkinPartMetadata());                
            }
            
            // if the functionToIgnore is not empty then add it to the set
            if(entry.functionToIgnore != null)
            {
                if (functionToIgnoreSet == null)
                {
                    functionToIgnoreSet = new HashSet<String>();
                }
                
                functionToIgnoreSet.add(entry.functionToIgnore);
            }
            
            
            //make sure there are no duplicates (happens with metadata present)
            if (!this.containsKey(entry.key) || 
                    (comment.getId() != null && ((entry.key.type == DocComment.FIELD) || (entry.key.type == DocComment.FUNCTION)
                    || (entry.key.type == DocComment.FUNCTION_GET) || (entry.key.type == DocComment.FUNCTION_SET) ) && !entry.hasUserNamespace ) )
            {
                if(entry.key.type == DocComment.CLASS && skinPartMetadataList != null )
                {
                    if(entry.getMetadata() == null)
                    {
                        entry.setMetadata(skinPartMetadataList);
                    }
                    else 
                    {
                        entry.getMetadata().addAll(skinPartMetadataList);
                    }
                }
                
                // if the entry is for a getter/setter function and the name is present in ignore set then ignore this entry.
                if(functionToIgnoreSet != null && 
                		(entry.key.type == DocComment.FUNCTION_GET || entry.key.type == DocComment.FUNCTION_SET ))
                {
                    if (functionToIgnoreSet.contains(entry.key.name))
                    {
                        return null;
                    }
                }
                
                this.put(entry.key, entry);
                return entry;
            }
            return null;
        }
        
        public boolean isInterface()
        {
            return isInterface;
        }
        
        /**
         * Finds inherited documentation to comment.
         *
         * @return Returns inherited documentation
         */
        private Object[] findInheritDoc(KeyPair key)
        {
            //placeholder until null case is figured out.
            Object[] inheritDoc = null;
            
            //Search through all parent classes and implemented interfaces
            Iterator iter = inheritance.iterator();
            
            CommentsTable baseClassObj = null;
            QName baseClass = null;
            while (iter.hasNext()){
                QName nextClass = (QName)iter.next();
                CommentsTable t = classTable.get(NameFormatter.toDot(nextClass));
                
                if(restoreBuiltinClasses && t == null && nextClass.getNamespace().equals(QName.DEFAULT_NAMESPACE) && !"Object_ASDoc".equals(abcClass.getName()))
                {
                    nextClass = new QName(QName.DEFAULT_NAMESPACE, nextClass.getLocalPart() + "_ASDoc");
                    t = classTable.get(NameFormatter.toDot(nextClass));
                }
                
                if (t != null)
                {
                    if(!t.isInterface()) 
                    {
                        baseClassObj = t;
                        baseClass = nextClass;
                        continue;
                    }
                    
                    //retrieve inherited Documentation.
                    //Special case for class definition comments
                    if (key.type == DocComment.CLASS)
                        inheritDoc = t.getCommentForInherit(new KeyPair(nextClass.getLocalPart(), DocComment.CLASS));
                    else  
                        inheritDoc = t.getCommentForInherit(key);
                }
                if (inheritDoc != null)
                    break;
            }
            
            if(inheritDoc == null && baseClass != null)
            {
                //retrieve inherited Documentation.
                //Special case for class definition comments
                if (key.type == DocComment.CLASS)
                    inheritDoc = baseClassObj.getCommentForInherit(new KeyPair(baseClass.getLocalPart(), DocComment.CLASS));
                else  
                    inheritDoc = baseClassObj.getCommentForInherit(key);
            }
            
            return inheritDoc;
        }
        
        /**
         * Returns an array of the description, paramTags and returnTag
         * of the comment to be inherited.
         */
        public Object[] getCommentForInherit(KeyPair key)
        {
            CommentEntry temp = (CommentEntry)this.get(key);
            if(temp == null || temp.getDescription() == null || temp.hasPrivateTag())
            {
                // if processing @inheritDoc for a setter function and the comment was with a null description or if it had an @private.. 
                // then try to inherit from the getter.
                if(key.type == DocComment.FUNCTION_SET )
                {
                    CommentEntry temp2 = (CommentEntry)this.get(new KeyPair(key.name, DocComment.FUNCTION_GET));
                    if(temp2 != null )
                    {
                        temp = temp2;    
                    }
                } 
                else if (key.type == DocComment.FUNCTION_GET ) // if processing @inheritDoc for a getter function and the comment was with a null description or if it had an @private.. then try to inherit from the setter.
                {
                    CommentEntry temp2 = (CommentEntry)this.get(new KeyPair(key.name, DocComment.FUNCTION_SET));
                    if(temp2 != null )
                    {
                        temp = temp2;    
                    }
                }                
            }
            
            if (temp != null && !temp.hasPrivateTag())
                return temp.getInheritedDoc();
            else
                return findInheritDoc(key);
        }
        
        /**
         * Each CommentEntry represents one comment associated with a
         * certain definition. When first instantiated, a CommentEntry
         * will take an asc DocCommentNode and retrieve all the information
         * necessary including tags. It also processes any inheritDoc tags
         * by searching through parent classes and interfaces. Each
         * CommentEntry within a certain class has a unique KeyPair
         * that allows for easy retrieval from a CommentsTable. Metadata
         * and their comments are held in a definition's CommentEntry
         * through the List, metadata.
         * 
         * @author klin
         *
         */
        private class CommentEntry implements DocComment{
            
            private boolean exclude;
            
            public KeyPair key;
            private String fullname;
            
            //Shared
            private String description;
            private boolean isFinal;
            private boolean isStatic;
            private boolean isOverride;
            
            //Classes and Interfaces
            private String sourcefile;
            private String namespace;
            private String access;
            private boolean isDynamic;
            
            //Classes
            private String baseClass;
            private String[] interfaces;
            
            //Interfaces
            private String[] baseClasses;

            //Methods
            private String[] paramNames;
            private String[] paramTypes;
            private String[] paramDefaults;
            private String resultType;
            
            //Fields
            private String vartype;
            private boolean isConst;
            private String defaultValue;
            
            //Metadata
            private List<CommentEntry> metadata;
            private String metadataType;
            private String owner;
            private String type_meta;
            private String event_meta;
            private String kind_meta;
            private String arrayType_meta;
            private String format_meta;
            private String inherit_meta;
            private String enumeration_meta;
            private String theme_meta;
            
            private String message_meta; // store message for Deprecation
            private String replacement_meta; // stores replacement for Deprecation 
            private String since_meta; // stores since for Deprecation
            
            private String variableType_meta; // stores the SkinPart variable type
            private String required_meta; // stores required for SkinPart
            
            //Tags
            private List<String> authorTags;
            private String copyTag;
            private String defaultTag;
            private List<String> eventTags;
            private String eventTypeTag;
            private List<String> exampleTags;
            private String helpidTag;
            private List<String> includeExampleTags;
            private boolean hasInheritTag;
            private String inheritDocTagLocation;
            private String internalTag;
            private String langversionTag;
            private List<String> paramTags;
            private List<String> playerversionTags;
            private boolean hasPrivateTag;
            private List<String> productversionTags;
            private String sinceTag;
            private String returnTag;
            private boolean hasReviewTag;
            private List<String> seeTags;
            private List<String> throwsTags;
            private String tiptextTag;
            private String toolversionTag;
            private Map<String, String> customTags;
            
            private boolean hasDefaultProperty = false;
            
            public boolean hasUserNamespace = false;
            
            private CommentEntry skinPartMetadata = null;
            /*
             * store the name of getter/setter to be ignored.
             */
            private String functionToIgnore = null;
            
            /**
             * Main Constructor.
             * 
             * @param comment
             * @param exclude
             */
            public CommentEntry(DocCommentNode comment, boolean exclude)
            {
                this.exclude = exclude;
                processComment(comment);
            }
            
            /**
             * Constructor for creating a metadata CommentEntry.
             * 
             * @param debugName
             * @param meta
             * @param isAttributeOfDefinition
             * @param current
             */
            public CommentEntry(String debugName, MetaDataNode meta, boolean isAttributeOfDefinition, MetaDataNode current, String variableType, String variableName)
            {
                createMetadataEntry(debugName, meta, isAttributeOfDefinition, current, variableType, variableName);
            }
            
            /**
             * Constructor used when inheriting meta data comment for [DefaultProperty].
             * 
             * @param debugName
             * @param meta
             */
            public CommentEntry(String debugName, MetaData meta)
            {
                inheritMetadataEntry(debugName, meta);
            }            
            
            private void createMetadataEntry(String debugName, MetaDataNode meta, boolean isAttributeOfDefinition, MetaDataNode current, String variableType, String variableName)
            {
                this.key = new KeyPair("IGNORE", METADATA);
                this.metadataType = meta.getId();
                this.owner = debugName;

                // write out the first keyless value, if any, as the name attribute. Output all keyValuePairs
                //  as usual.
                boolean has_name = false;
                if (meta.getValues() != null)
                {
                    int l = meta.getValues().length;
                    
                    for (int i = 0; i < l; i++)
                    {
                        Value v = meta.getValues()[i];
                        if (v != null)
                        {
                            if (v instanceof MetaDataEvaluator.KeylessValue && has_name == false)
                            {
                                MetaDataEvaluator.KeylessValue ov = (MetaDataEvaluator.KeylessValue)v;
                                this.key.name = ov.obj;
                                has_name = true;
                                continue;
                            }
                            if (v instanceof MetaDataEvaluator.KeyValuePair)
                            {
                                MetaDataEvaluator.KeyValuePair kv = (MetaDataEvaluator.KeyValuePair)v;
                                String s = kv.key.intern();
                                if (s.equals("name"))
                                    this.key.name = kv.obj;
                                else if (s.equals("type"))
                                    this.type_meta = kv.obj;
                                else if (s.equals("event"))
                                    this.event_meta = kv.obj;
                                else if (s.equals("kind"))
                                    this.kind_meta = kv.obj;
                                else if (s.equals("arrayType"))
                                    this.arrayType_meta = kv.obj;
                                else if (s.equals("format"))
                                    this.format_meta = kv.obj;
                                else if (s.equals("inherit"))
                                    this.inherit_meta = kv.obj;
                                else if (s.equals("enumeration"))
                                    this.enumeration_meta = kv.obj;
                                else if (s.equals("message") || s.equals("deprecatedMessage"))
                                    this.message_meta = kv.obj;
                                else if (s.equals("replacement") || s.equals("deprecatedReplacement"))
                                    this.replacement_meta = kv.obj;
                                else if (s.equals("since")  || s.equals("deprecatedSince"))
                                    this.since_meta = kv.obj;
                                else if (s.equals("required"))
                                    this.required_meta = kv.obj;
                                else if (s.equals("theme"))
                                    this.theme_meta = kv.obj;
                                else if (s.equals("profile"))
                                    this.key.name = kv.obj;
                                
                                continue;
                            }
                        }
                    }
                }
                else if(meta.getId() != null)
                {
                    // metadata with an id, but no values
                    this.key.name = meta.getId();
                }
                
                if(variableType != null)
                {
                    variableType_meta = variableType;
                }
                
                if(variableName != null)
                {
                    this.key.name = variableName;
                }

                // [Event], [Style], and [Effect] are documented as seperate entities, rather than
                //   as elements of other entities.  In that case, we need to write out the asDoc
                //   comment here 
                if (isAttributeOfDefinition == false)
                {
                    if (current.getId() != null)
                    {
                        // Id, but no values
                        this.processTags(current.getId());
                    }
                }
            }
            
            private void inheritMetaDataComment(String debugName, MetaData meta)
            {
                if (metadata == null)
                    metadata = new ArrayList<CommentEntry>();
                CommentEntry newMetadata = new CommentEntry(debugName, meta);
                metadata.add(newMetadata);
            }
            
            /**
             * This method is used to inherit the [DefaultProperty] meta data from parent classes.
             * 
             * @param debugName
             * @param meta
             */
            private void inheritMetadataEntry(String debugName, MetaData meta)
            {
                this.key = new KeyPair("IGNORE", METADATA);
                this.metadataType = meta.getID();
                this.owner = debugName;
                 
                if (meta.count() != 0)
                {
                    if(StandardDefs.MD_DEFAULTPROPERTY.equals(meta.getID()))
                    {
                        this.key.name = meta.getValue(0);
                    }    
                } 
            }            
            
            private String getAccessKindFromNS(ObjectValue ns)
            {
                String access_specifier;
                switch (ns.getNamespaceKind())
                {
                    case macromedia.asc.util.Context.NS_PUBLIC:
                        access_specifier = "public";
                        break;
                    case macromedia.asc.util.Context.NS_INTERNAL:
                        access_specifier = "internal";
                        break;
                    case macromedia.asc.util.Context.NS_PROTECTED:
                        access_specifier = "protected";
                        break;
                    case macromedia.asc.util.Context.NS_PRIVATE:
                        access_specifier = "private";
                        break;
                    default:
                        // should never happen
                        access_specifier = "public";
                        break;
                }
                return access_specifier;
            }
            
            private void processPackage(PackageDefinitionNode pd)
            {
                this.key.type = PACKAGE;
                this.key.name = pd.name.id != null ? pd.name.id.pkg_part : "";
                fullname = pd.name.id != null ? pd.name.id.pkg_part + "." + pd.name.id.def_part : "";
            }
            
            private void processClassAndInterface(ClassDefinitionNode cd)
            {
                this.key.name = cd.name.name;
                fullname = cd.debug_name;
                InterfaceDefinitionNode idn = null;
                if (cd instanceof InterfaceDefinitionNode)
                {
                    this.key.type = INTERFACE;
                    idn = (InterfaceDefinitionNode)cd;
                }
                else
                {
                    this.key.type = CLASS;
                }
                
                if (cd.cx.input != null && cd.cx.input.origin.length() != 0)
                {
                    sourcefile = cd.cx.input.origin;
                }
                namespace = cd.cframe.builder.classname.ns.name;
                access = getAccessKindFromNS(cd.cframe.builder.classname.ns);
                
                if (idn != null)
                {
                    if (idn.interfaces != null)
                    {
                        List values = idn.interfaces.values;
                        baseClasses = new String[values.size()];
                        for (int i = 0; i < values.size(); i++)
                        {
                            ReferenceValue rv = (ReferenceValue)values.get(i);
                            Slot s = rv.getSlot(cx, Tokens.GET_TOKEN);
                            baseClasses[i] = (s == null || s.getDebugName().length() == 0) ? rv.name : s.getDebugName();
                        }
                    }
                    else
                    {
                        baseClasses = new String[] {"Object"};
                    }
                }
                else
                {
                    if (cd.baseref != null)
                    {
                        Slot s = cd.baseref.getSlot(cx, Tokens.GET_TOKEN);
                        baseClass = (s == null || s.getDebugName().length() == 0) ? "Object" : s.getDebugName();
                    }
                    else
                    {
                        baseClass = "Object";
                    }

                    if (cd.interfaces != null)
                    {
                        List values = cd.interfaces.values;
                        interfaces = new String[values.size()];
                        for (int i = 0; i < values.size(); i++)
                        {
                            ReferenceValue rv = (ReferenceValue)values.get(i);
                            Slot s = rv.getSlot(cx, Tokens.GET_TOKEN);
                            interfaces[i] = (s == null || s.getDebugName().length() == 0) ? rv.name : s.getDebugName();
                        }
                    }
                }

                AttributeListNode attrs = cd.attrs;
                if (attrs != null)
                {
                    isFinal = attrs.hasFinal ? true : false;
                    isDynamic = attrs.hasDynamic ? true : false;
                }
            }

            
            private void processFunction(FunctionDefinitionNode fd)
            {
                key.type = FUNCTION;
                int check1 = fd.fexpr.debug_name.indexOf("/get");
                int check2 = fd.fexpr.debug_name.indexOf("/set");
                if (check1 == fd.fexpr.debug_name.length()-4)
                    key.type = FUNCTION_GET;
                else if (check2 == fd.fexpr.debug_name.length()-4)
                    key.type = FUNCTION_SET;
                
                key.name = fd.name.identifier.name;
                
                fullname = fd.fexpr.debug_name;
     
                AttributeListNode attrs = fd.attrs;
                if(attrs != null)
                {
                    isStatic = attrs.hasStatic;
                    isFinal = attrs.hasFinal;
                    isOverride = attrs.hasOverride;
                    hasUserNamespace  = attrs.hasUserNamespace();
                }
                
                ParameterListNode pln = fd.fexpr.signature.parameter;
                if (pln != null)
                {
                    int size = pln.items.size();
                    paramNames = new String[size];
                    paramTypes = new String[size];
                    paramDefaults = new String[size];
                    //param_names
                    ParameterNode pn;
                    for (int i = 0; i < size; i++)
                    {
                        pn = pln.items.get(i);
                        //parameter names
                        paramNames[i] = pn.ref != null ? pn.ref.name : "";
                        
                        //parameter types
                        if (pn instanceof RestParameterNode)
                            paramTypes[i] = "restParam";
                        else if (pn.typeref != null)
                        {
                            paramTypes[i] = getRefName(cx, pn.typeref);
                        }
                        else
                        {
                        	paramTypes[i] = "*";
                        }
                        
                        //parameter defaults
                        if (pn.init == null)
                            paramDefaults[i] = "undefined";
                        else
                        {
                            if (pn.init instanceof LiteralNumberNode)
                            {
                                paramDefaults[i] = ((LiteralNumberNode)(pn.init)).value;
                            }
                            else if (pn.init instanceof LiteralStringNode)
                            {
                                paramDefaults[i] = DocCommentNode.escapeXml(((LiteralStringNode)(pn.init)).value);
                            }
                            else if (pn.init instanceof LiteralNullNode)
                            {
                                paramDefaults[i] = "null";
                            }
                            else if (pn.init instanceof LiteralBooleanNode)
                            {
                                paramDefaults[i] = (((LiteralBooleanNode)(pn.init)).value) ? "true" : "false";
                            }
                            else
                            {
                                paramDefaults[i] = "unknown";
                            }
                        }
                    }
                }
                
                if (fd.fexpr.signature.result != null)
                {
                    TypeExpressionNode result = (TypeExpressionNode)fd.fexpr.signature.result;
                    if(result.expr != null)
                    {
                        MemberExpressionNode expr = (MemberExpressionNode)result.expr;
                        resultType = getRefName(cx, expr.ref);
                    }
                }
                else if( fd.fexpr.signature.void_anno )
                    resultType = "void";
                else
                    resultType = cx.noType().name.toString();
            }
            
            private void processField(VariableDefinitionNode vd)
            {
                VariableBindingNode vb = (VariableBindingNode)(vd.list.items.get(0));
                key.type = FIELD;
                key.name = vb.variable.identifier.name;
                fullname = vb.debug_name;

                if (vb.typeref != null)
                {
                    vartype = getRefName(cx, vb.typeref);
                }

                AttributeListNode attrs = vd.attrs;
                if (attrs != null)
                {
                    isStatic = attrs.hasStatic;
                    hasUserNamespace  = attrs.hasUserNamespace();
                }
                
                Slot s = vb.ref.getSlot(cx);
                if (s != null)
                {
                    isConst = s.isConst();               
                }

                if (vb.initializer != null)
                {
                    if (vb.initializer instanceof LiteralNumberNode)
                    {
                        defaultValue = ((LiteralNumberNode)(vb.initializer)).value;
                    }
                    else if (vb.initializer instanceof LiteralStringNode)
                    {
                        defaultValue = DocCommentNode.escapeXml(((LiteralStringNode)(vb.initializer)).value);
                    }
                    else if (vb.initializer instanceof LiteralNullNode)
                    {
                        defaultValue = "null";
                    }
                    else if (vb.initializer instanceof LiteralBooleanNode)
                    {
                        defaultValue = (((LiteralBooleanNode)(vb.initializer)).value) ? "true" : "false";
                    }
                    else if (vb.initializer instanceof MemberExpressionNode)
                    {
                        MemberExpressionNode mb = (MemberExpressionNode)(vb.initializer);
                        Slot vs = null;
						if (mb.ref != null && mb.selector.isGetExpression())
						{
							vs = (mb.ref != null ? mb.ref.getSlot(cx, Tokens.GET_TOKEN) : null);
						}
						else
						{
							vs = vb.ref.getSlot(cx, Tokens.GET_TOKEN);
						}
                        
                        Value v = (vs != null ? vs.getValue() : null);
                        ObjectValue ov = ((v instanceof ObjectValue) ? (ObjectValue)(v) : null);
                        // if constant evaluator has determined this has a value, use it.
                        defaultValue = (ov != null) ? ov.getValue() : "unknown";
                    }
                    else
                    {
                        Slot vs = vb.ref.getSlot(cx, Tokens.GET_TOKEN);
                        Value v = (vs != null ? vs.getValue() : null);
                        ObjectValue ov = ((v instanceof ObjectValue) ? (ObjectValue)(v) : null);
                        // if constant evaluator has determined this has a value, use it.
                        defaultValue = (ov != null) ? ov.getValue() : "unknown";
                    }
                }
            }
            
            // Helper method to print types in a way asdoc wants.
            // This is mostly for Vectors, which need to print as Vector$basetype.
            public String getRefName(Context cx, ReferenceValue ref)
            {
                Slot s = ref.getSlot(cx, Tokens.GET_TOKEN);
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
            
            private String getIndexedTypeName(Context cx, TypeValue t)
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
            
            private void createMetaDataComment(String debugName, MetaDataNode meta, boolean isAttributeOfDefinition, MetaDataNode current)
            {
                if (metadata == null)
                    metadata = new ArrayList<CommentEntry>();
                CommentEntry newMetadata = new CommentEntry(debugName, meta, isAttributeOfDefinition, current, null, null);
                metadata.add(newMetadata);
            }
            
            private void processMetadata(DocCommentNode comment)
            {
                if (comment.def != null && comment.def.metaData != null)
                {
                    int numItems = comment.def.metaData.items.size();
                    for (int x = 0; x < numItems; x++)
                    {
                        Node md = comment.def.metaData.items.at(x);
                        MetaDataNode mdi = (md instanceof MetaDataNode) ? (MetaDataNode)(md) : null;
                        
                        // cn: why not just dump all the metaData ???
                        if (mdi != null && mdi.getId() != null)
                        {
                            // these metaData types can have their own DocComment associated with them, though they might also have no comment.
                            if (mdi.getId().equals(StandardDefs.MD_STYLE) || mdi.getId().equals(StandardDefs.MD_EVENT) || mdi.getId().equals(StandardDefs.MD_EFFECT)
                                    || mdi.getId().equals(StandardDefs.MD_SKINSTATE) || mdi.getId().equals(StandardDefs.MD_ALTERNATIVE)
                                    || mdi.getId().equals(StandardDefs.MD_DISCOURAGEDFORPROFILE))
                            {
                                if (x+1 < numItems)  // if it has a comment, it will be the sequentially next DocCommentNode
                                {
                                    Node next = comment.def.metaData.items.at(x+1);
                                    DocCommentNode metaDataComment = (next instanceof DocCommentNode) ? (DocCommentNode)next : null;

                                    if (metaDataComment != null)
                                    {
                                        createMetaDataComment(fullname, mdi, false, metaDataComment);
                                        x++;
                                    }
                                    else  // emit it even if it doesn't have a comment.
                                    {
                                        createMetaDataComment(fullname, mdi, true, null);
                                    }
                                }
                                else
                                {
                                    createMetaDataComment(fullname, mdi, true, null);
                                }
                            }
                            else if (mdi.getId().equals(StandardDefs.MD_BINDABLE) || mdi.getId().equals(StandardDefs.MD_DEPRECATED) || mdi.getId().equals(StandardDefs.MD_EXCLUDE))
                            {
                                createMetaDataComment(fullname, mdi, true, null);
                            }
                            else if (mdi.getId().equals(StandardDefs.MD_DEFAULTPROPERTY))
                            {
                                hasDefaultProperty = true;
                                createMetaDataComment(fullname, mdi, true, null);
                            } 
                            else if (mdi.getId().equals(StandardDefs.MD_SKINPART))
                            {
                                String className = fullname.substring(0, fullname.indexOf("/"));
                                if(comment.getId() != null)
                                {
                                    createSkinPartMetaDataComment(className, mdi, false, comment);
                                }
                                else 
                                {
                                    createSkinPartMetaDataComment(className, mdi, true, null);
                                }
                                
                                // if the entry is for a getter/setter then store the name so setter/getter can be ignored. 
                                if(this.key.type == FUNCTION_GET || this.key.type == FUNCTION_SET)
                                {
                                    functionToIgnore = this.key.name;
                                }
                                
                                this.key.name = "IGNORE";
                                this.key.type = -1;
                            }
                        }
                    }
                }
            }
            
            private void createSkinPartMetaDataComment(String debugName, MetaDataNode meta, boolean isAttributeOfDefinition, MetaDataNode current)
            {
                String tempVarType = vartype;
                
                if (this.key.type == FUNCTION_GET)
                {
                    tempVarType = resultType;
                }
                
                skinPartMetadata = new CommentEntry(debugName, meta, isAttributeOfDefinition, current, tempVarType, key.name);
            }
            
            /**
             * Tries to match tagname to known tag names.
             */
            private boolean matchesAnyTag(String tagName)
            {
                return tagNames.contains(tagName);
            }
            
            /**
             * Parses out all the descriptions and tags. It leaves anything 
             * that's not found as null. processTags() also checks for certain
             * errors and reports them through the logger.
             * 
             * @param id
             */
            private void processTags(String id)
            {
                //Extracting description
                int is = id.indexOf("<description><![CDATA[");
                int ie = id.indexOf("]]></description>");
                description = id.substring(is + "<description><![CDATA[".length(), ie);
                
                //extracting @return
                int index = id.indexOf("]]></return>");
                int endCDATABefore;
                int begin;
                if (index >= 0)
                {
                    endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                    begin = id.indexOf("<return><![CDATA[", endCDATABefore) + "<return><![CDATA[".length();
                    returnTag = id.substring(begin, index);
                }
                index = id.indexOf("]]></return>", index+12);
                if (index > 0)
                    ThreadLocalToolkit.getLogger().logError("More than one @return found in " + this.fullname + ".");
                
                //extracting @param (multiple)
                index = id.indexOf("]]></param>");
                if (index >= 0)
                    paramTags = new ArrayList<String>();
                while (index >= 0)
                {
                    endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                    begin = id.indexOf("<param><![CDATA[", endCDATABefore);
                    paramTags.add(id.substring(begin + "<param><![CDATA[".length(), index));
                    index = id.indexOf("]]></param>", index + "]]></param>".length());
                }
                //check for @inheritDoc
                index = id.indexOf("]]></inheritDoc>");
                hasInheritTag = index > 0 ? true : false;
                if (index > 0)
                {
                    endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                    begin = id.indexOf("<inheritDoc><![CDATA[", endCDATABefore) + "<inheritDoc><![CDATA[".length();
                    inheritDocTagLocation = id.substring(begin, index).trim();
                }
                
                index = id.indexOf("]]></inheritDoc>", index+16);
                if (index > 0)
                    ThreadLocalToolkit.getLogger().logError("More than one @inheritDoc found in " + this.fullname + ".");
                
                //extracting @author tags
                index = id.indexOf("]]></author>");
                if (index >= 0)
                    authorTags = new ArrayList<String>();
                while (index >= 0)
                {
                    endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                    begin = id.indexOf("<author><![CDATA[", endCDATABefore);
                    authorTags.add(id.substring(begin + "<author><![CDATA[".length(), index));
                    index = id.indexOf("]]></author>", index + "]]></author>".length());
                }
                
                //extracting @copy
                index = id.indexOf("]]></copy>");
                if (index > 0)
                {
                    endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                    begin = id.indexOf("<copy><![CDATA[", endCDATABefore) + "<copy><![CDATA[".length();
                    copyTag = id.substring(begin, index);
                }
                //extracting @default
                index = id.indexOf("]]></default>");
                if (index > 0)
                {
                    endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                    begin = id.indexOf("<default><![CDATA[", endCDATABefore) + "<default><![CDATA[".length();
                    defaultTag = id.substring(begin, index);
                }
                //extracting @event (multiple)
                index = id.indexOf("]]></event>");
                if (index >= 0)
                    eventTags = new ArrayList<String>();                
                while (index > 0)
                {
                    endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                    begin = id.indexOf("<event><![CDATA[", endCDATABefore);
                    eventTags.add(id.substring(begin + "<event><![CDATA[".length(), index));
                    index = id.indexOf("]]></event>", index + "]]></event>".length());                    
                }
                
                //extracting @eventType
                index = id.indexOf("]]></eventType>");
                if (index > 0)
                {
                    endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                    begin = id.indexOf("<eventType><![CDATA[", endCDATABefore) + "<eventType><![CDATA[".length();
                    eventTypeTag = id.substring(begin, index);
                }
                //extracting @example (multiple)
                index = id.indexOf("]]></example>");
                if (index >= 0)
                    exampleTags = new ArrayList<String>();
                while (index >= 0)
                {
                    endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                    begin = id.indexOf("<example><![CDATA[", endCDATABefore);
                    exampleTags.add(id.substring(begin + "<example><![CDATA[".length(), index));
                    index = id.indexOf("]]></example>", index + "]]></example>".length());
                }

                //extracting @helpid
                index = id.indexOf("]]></helpid>");
                if (index > 0)
                {
                    endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                    begin = id.indexOf("<helpid><![CDATA[", endCDATABefore) + "<helpid><![CDATA[".length();
                    helpidTag = id.substring(begin, index);
                }

                //extracting @includeExample (multiple)
                index = id.indexOf("]]></includeExample>");
                if (index >= 0)
                    includeExampleTags = new ArrayList<String>();
                while (index >= 0)
                {
                    endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                    begin = id.indexOf("<includeExample><![CDATA[", endCDATABefore);
                    includeExampleTags.add(id.substring(begin + "<includeExample><![CDATA[".length(), index));
                    index = id.indexOf("]]></includeExample>", index + "]]></includeExample>".length());
                }
                //extracting @internal
                index = id.indexOf("]]></internal>");
                if (index > 0)
                {
                    endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                    begin = id.indexOf("<internal><![CDATA[", endCDATABefore) + "<internal><![CDATA[".length();
                    internalTag = id.substring(begin, index);
                }

                //extracting @langversion
                index = id.indexOf("]]></langversion>");
                if (index > 0)
                {
                    endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                    begin = id.indexOf("<langversion><![CDATA[", endCDATABefore) + "<langversion><![CDATA[".length();
                    langversionTag = id.substring(begin, index);
                }

                //extracting @playerversion (multiple)
                index = id.indexOf("]]></playerversion>");
                if (index >= 0)
                    playerversionTags = new ArrayList<String>();
                while (index >= 0)
                {
                    endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                    begin = id.indexOf("<playerversion><![CDATA[", endCDATABefore);
                    playerversionTags.add(id.substring(begin + "<playerversion><![CDATA[".length(), index));
                    index = id.indexOf("]]></playerversion>", index + "]]></playerversion>".length());
                }
                
                //check for @private
                hasPrivateTag = id.indexOf("]]></private>") > 0 ? true : false;
                
                //extracting @productversion (multiple)
                index = id.indexOf("]]></productversion>");
                if (index >= 0)
                    productversionTags = new ArrayList<String>();
                while (index >= 0)
                {
                    endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                    begin = id.indexOf("<productversion><![CDATA[", endCDATABefore);
                    productversionTags.add(id.substring(begin + "<productversion><![CDATA[".length(), index));
                    index = id.indexOf("]]></productversion>", index + "]]></productversion>".length());
                }
                
                //extracting @since
                index = id.indexOf("]]></since>");
                if (index > 0)
                {
                    endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                    begin = id.indexOf("<since><![CDATA[", endCDATABefore) + "<since><![CDATA[".length();
                    sinceTag = id.substring(begin, index);
                }
                
                //check for @review
                hasReviewTag = id.indexOf("]]></review>") > 0 ? true : false;
                //extracting @see (multiple)
                index = id.indexOf("]]></see>");
                if (index >= 0)
                    seeTags = new ArrayList<String>();
                while (index >= 0)
                {
                    endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                    begin = id.indexOf("<see><![CDATA[", endCDATABefore);
                    String see = id.substring(begin + "<see><![CDATA[".length(), index);
                    if (see.indexOf('<') >= 0)
                        ThreadLocalToolkit.getLogger().logError("Do not use html in @see. Offending text: " + see + " Located at " + this.fullname + ".");
                    seeTags.add(see);
                    index = id.indexOf("]]></see>", index + "]]></see>".length());
                }
                //extracting @throws (multiple)
                index = id.indexOf("]]></throws>");
                if (index >= 0)
                    throwsTags = new ArrayList<String>();
                while (index >= 0)
                {
                    endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                    begin = id.indexOf("<throws><![CDATA[", endCDATABefore);
                    throwsTags.add(id.substring(begin + "<throws><![CDATA[".length(), index));
                    index = id.indexOf("]]></throws>", index + "]]></throws>".length());
                }
                //extracting @tiptext
                index = id.indexOf("]]></tiptext>");
                if (index > 0)
                {
                    endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                    begin = id.indexOf("<tiptext><![CDATA[", endCDATABefore) + "<tiptext><![CDATA[".length();
                    tiptextTag = id.substring(begin, index);
                }
                //extracting @toolversion
                index = id.indexOf("]]></toolversion>");
                if (index > 0)
                {
                    endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                    begin = id.indexOf("<toolversion><![CDATA[", endCDATABefore) + "<toolversion><![CDATA[".length();
                    toolversionTag = id.substring(begin, index);
                }
                //extracting @<unknown>
                index = id.indexOf("]]></");
                while (index >= 0)
                {
                    int beginTag = index + "]]></".length();
                    int endTag = id.indexOf(">", beginTag);
                    String tagName = (id.substring(beginTag, endTag)).intern();
                    if (!matchesAnyTag(tagName))
                    {
                        if(tagName.indexOf("!") != -1)
                        {
                            ThreadLocalToolkit.getLogger().logError("Unexpected symbol ! (" + tagName 
                                    + ") found in " + this.fullname + "."); 
                        }

                        if(tagName.indexOf(":") != -1)
                        {
                            ThreadLocalToolkit.getLogger().logError("Unexpected symbol : (" + tagName 
                                    + ") found in " + this.fullname + "."); 
                        }
                    	
                        if (customTags == null)
                            customTags = new LinkedHashMap<String, String>();
                        endCDATABefore = id.substring(0, index).lastIndexOf("]]>");
                        String tag = "<" + tagName + "><![CDATA[";
                        begin = id.indexOf(tag, endCDATABefore) + tag.length();
                        customTags.put(tagName, id.substring(begin, index));
                    }
                    index = id.indexOf("]]></", endTag + 1);
                }
            }
            
            /**
             * processComment() extracts the necessary information from the
             * DocCommentNode using its helper methods. The helper methods use
             * the logic derived from the asc parser. It also processes any 
             * inheritDoc tags.
             */
            private void processComment(DocCommentNode comment)
            {
                this.key = new KeyPair("IGNORE", -1);
                
                hasDefaultProperty = false;
                
                //Extracts information (name and def type) for identifying a comment
                if (comment.def instanceof PackageDefinitionNode)
                {
                    processPackage((PackageDefinitionNode)comment.def);
                }
                else if (comment.def instanceof ClassDefinitionNode)
                {
                    ClassDefinitionNode cd = (ClassDefinitionNode)comment.def;
                    
                    processClassAndInterface(cd);
                }
                else if (comment.def instanceof FunctionDefinitionNode)
                {
                    processFunction((FunctionDefinitionNode)comment.def);
                }
                else if (comment.def instanceof VariableDefinitionNode)
                {
                    processField((VariableDefinitionNode)comment.def);
                }
                else
                {
                    //unsupported definition
                    this.key.name = "Unsupported";
                }
                
                if (this.key.type == -1)
                    return;
                
                this.key.isStatic = isStatic;
                
                //extracts @ tags.
                if (comment.getId() != null)
                    processTags(comment.getId());
                
                //only process inheritDoc when needed
                if (!exclude && hasInheritTag)
                {
                    processInheritDoc();
                }
                
                processMetadata(comment);

                // adding null check - for flash classes it can be null here
                if (comment.def instanceof ClassDefinitionNode && abcClass != null)
                {
                    // if this is a class definition and it doesn't have [DefaultProperty], may be its defined on its parent classes.
                    if(!hasDefaultProperty)
                    {
                        ClassDefinitionNode cd = (ClassDefinitionNode)comment.def;
                        
                        List<MetaData> metadataList = abcClass.getMetaData(StandardDefs.MD_DEFAULTPROPERTY, true);
                       
                        // if [DefaultProperty] found on the parent, lets inherit that.
                        if(metadataList.size() != 0)
                        {
                            inheritMetaDataComment(cd.debug_name, metadataList.get(0));
                        }
                    }
                }
            }

            /**
             * adds description and parameters/return tags if they exist to the current comment
             */
            private void addToComment(Object[] inheritDoc)
            {
                String desc = (String)inheritDoc[0];
                
                // unavoidable since we're casting against an array
                @SuppressWarnings("unchecked")
                List<String> para = (List<String>)inheritDoc[1];
                
                String retu = (String)inheritDoc[2];
                
                //add description
                if (desc != null)
                {
                		if(inheritDocTagLocation != null && inheritDocTagLocation.equals("before-description"))
                		{
                			this.description = desc + this.description;
                		}
                		else
                		{
                			this.description += desc;
                		}
                }
                    
                //add parameters
                if (para != null)
                {
                    if (this.paramTags != null)
                    {
                        int diff = para.size() - this.paramTags.size();
                        if (diff > 0)
                        {
                            int size = this.paramTags.size();
                            for (int i = size; i < size + diff; i++)
                                this.paramTags.add(para.get(i));
                        }
                    }
                    else
                        this.paramTags = para;
                }
                //add return
                if (this.returnTag == null && retu != null)
                    this.returnTag = retu;
            }
            
            /**
             * @return Returns an Object array of a {String, List, String}
             * that represent the description, paramter tags, return tag.
             */
            public Object[] getInheritedDoc()
            {
                //only search for inherited documentation if
                //we did not search for it earlier.
                Object[] inheritDoc;
                if (hasInheritTag && exclude)
                {
                    inheritDoc = findInheritDoc(this.key);
                    if (inheritDoc != null)
                        addToComment(inheritDoc);
                }
                
                inheritDoc = new Object[3];
                inheritDoc[0] = this.getDescription();
                inheritDoc[1] = this.getParamTags();
                inheritDoc[2] = this.getReturnTag();
                return inheritDoc;
            }
            
            /**
             * Processes inheritDoc tag.
             */
            private void processInheritDoc()
            {
                //Retrieve inherited documentation
                Object[] inheritDoc = findInheritDoc(this.key);
                
                //Add it to this CommentEntry
                if (inheritDoc != null)
                {
                    addToComment(inheritDoc);
                    hasInheritTag = false;
                }
                else
                    if (Trace.asdoc) System.out.println("Cannot find inherited documentation for: " + this.key.name);
            }
            
            /**
             * Method that returns a map of all the information 
             * derived from parsing the tags. The keys are the
             * tag names.
             */
            public Map<String, Object> getAllTags()
            {
                Map<String, Object> tags = new LinkedHashMap<String, Object>();
                tags.put("author", getAuthorTags());
                tags.put("copy", getCopyTag());
                tags.put("default", getDefaultTag());
                tags.put("event", getEventTags());
                tags.put("eventType", getEventTypeTag());
                tags.put("example", getExampleTags());
                tags.put("helpid", getHelpidTag());
                tags.put("includeExample", getIncludeExampleTags());
                tags.put("internal", getInternalTag());
                tags.put("langversion", getLangversionTag());
                tags.put("param", getParamTags());
                tags.put("playerversion", getPlayerversionTags());
                tags.put("productversion", getProductversionTags());
                tags.put("since", getSinceTag());
                tags.put("return", getReturnTag());
                tags.put("see", getSeeTags());
                tags.put("throws", getThrowsTags());
                tags.put("tiptext", getTiptextTag());
                tags.put("toolversion", getToolversionTag());
                tags.put("inheritDoc", Boolean.valueOf(hasInheritTag()));
                tags.put("private", Boolean.valueOf(hasPrivateTag()));
                tags.put("review", Boolean.valueOf(hasReviewTag()));
                tags.put("custom", getCustomTags());
                return tags;
            }
            
            public int getType()
            {
                return this.key.type;
            }
            
            public String getDescription()
            {
                return this.description;
            }
            
            public List<String> getParamTags()
            {
                return this.paramTags;
            }
            
            public String getReturnTag()
            {
                return this.returnTag;
            }

            public String getAccess()
            {
                return this.access;
            }

            public String getArrayType_meta()
            {
                return this.arrayType_meta;
            }

            public List<String> getAuthorTags()
            {
                return this.authorTags;
            }
            
            public String getBaseClass()
            {
                return this.baseClass;
            }
            
            public String[] getBaseclasses()
            {
                return this.baseClasses;
            }

            public String getCopyTag()
            {
                return this.copyTag;
            }

            public Map<String, String> getCustomTags()
            {
                return this.customTags;
            }

            public String getDefaultTag()
            {
                return this.defaultTag;
            }

            public String getDefaultValue()
            {
                return this.defaultValue;
            }

            public String getEnumeration_meta()
            {
                return this.enumeration_meta;
            }
            
            public String getTheme_meta()
            {
            		return this.theme_meta;
            }
            
            public String getEvent_meta()
            {
                return this.event_meta;
            }
            
            public String getMessage_meta()
            {
                return this.message_meta;
            }
            
            public String getReplacement_meta()
            {
                return this.replacement_meta;
            }
            
            public String getSince_meta()
            {
                return this.since_meta;
            }

            public List<String> getEventTags()
            {
                return this.eventTags;
            }

            public String getEventTypeTag()
            {
                return this.eventTypeTag;
            }

            public List<String> getExampleTags()
            {
                return this.exampleTags;
            }

            public String getFormat_meta()
            {
                return this.format_meta;
            }

            public String getInherit_meta()
            {
                return this.inherit_meta;
            }

            public String getHelpidTag()
            {
                return this.helpidTag;
            }

            public List<String> getIncludeExampleTags()
            {
                return this.includeExampleTags;
            }
            
            public String[] getInterfaces()
            {
                return this.interfaces;
            }

            public String getInternalTag()
            {
                return this.internalTag;
            }

            public String getKind_meta()
            {
                return this.kind_meta;
            }

            public String getLangversionTag()
            {
                return this.langversionTag;
            }

            public List<CommentEntry> getMetadata()
            {
                return this.metadata;
            }

            public String getMetadataType()
            {
                return this.metadataType;
            }

            public String getName()
            {
                return this.key.name;
            }
            
            public String getFullname()
            {
                return this.fullname;
            }

            public String getNamespace()
            {
                return this.namespace;
            }

            public String getOwner()
            {
                return this.owner;
            }

            public String[] getParamDefaults()
            {
                return this.paramDefaults;
            }

            public String[] getParamNames() 
            {
                return this.paramNames;
            }

            public String[] getParamTypes()
            {
                return this.paramTypes;
            }

            public List<String> getPlayerversionTags()
            {
                return this.playerversionTags;
            }

            public List<String> getProductversionTags() 
            {
                return this.productversionTags;
            }
            
            public String getSinceTag() 
            {
                return this.sinceTag;
            }            

            public String getResultType()
            {
                return this.resultType;
            }

            public List<String> getSeeTags() 
            {
                return this.seeTags;
            }

            public String getSourceFile()
            {
                return this.sourcefile;
            }

            public List<String> getThrowsTags()
            {
                return this.throwsTags;
            }

            public String getTiptextTag()
            {
                return this.tiptextTag;
            }

            public String getToolversionTag()
            {
                return this.toolversionTag;
            }

            public String getType_meta()
            {
                return this.type_meta;
            }

            public String getVartype()
            {
                return this.vartype;
            }

            public boolean hasInheritTag()
            {
                return this.hasInheritTag;
            }

            public boolean hasPrivateTag()
            {
                return this.hasPrivateTag;
            }

            public boolean hasReviewTag()
            {
                return this.hasReviewTag;
            }

            public boolean isConst()
            {
                return this.isConst;
            }

            public boolean isDynamic()
            {
                return this.isDynamic;
            }

            public boolean isExcluded()
            {
                return this.exclude;
            }

            public boolean isFinal()
            {
                return this.isFinal;
            }

            public boolean isOverride()
            {
                return this.isOverride;
            }

            public boolean isStatic()
            {
                return this.isStatic;
            }

            public CommentEntry getSkinPartMetadata()
            {
                return skinPartMetadata;
            }

            public void setMetadata(List<CommentEntry> metadata)
            {
                this.metadata = metadata;
            }

            public String getVariableType_meta()
            {
                return variableType_meta;
            }

            public String getRequired_meta()
            {
                return required_meta;
            }
        }
    }
    
    /**
     * Key to retrieve individual CommentEntry's. Composed of the
     * name of the definition associated with the comment
     * and the type of definition. Implements Comparable
     * only for equality (high and low are arbitrary). Suppose we
     * have a field called foo and a class called bar. Comparisons
     * are done with strings in this manner: the field foo would 
     * be "6foo" and the class bar would be "1bar".
     * 
     */
    private class KeyPair implements Comparable{
        
        public String name;
        public int type;
        public boolean isStatic;
        
        public KeyPair(String name, int type)
        {
            this.name = name;
            this.type = type;
        }
        
        public int compareTo(Object key)
        {
            return(((new Integer(type)).toString() + name + isStatic).compareTo((new Integer(((KeyPair)key).type)).toString() + ((KeyPair)key).name + ((KeyPair)key).isStatic));
        }
    }
}
