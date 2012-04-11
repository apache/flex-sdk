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

package flex2.compiler.mxml.reflect;

import flex2.compiler.SymbolTable;
import flex2.compiler.abc.AbcClass;
import flex2.compiler.abc.MetaData;
import flex2.compiler.abc.Method;
import flex2.compiler.abc.Variable;
import flex2.compiler.css.Styles;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.NameMappings;
import flex2.compiler.util.QName;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.compiler.util.CompilerMessage.CompilerWarning;

import java.util.*;

import macromedia.asc.util.ContextStatics;

/**
 * This class provides an MXML specific reflection API, built on top
 * of the compiler's symbol table.  Type and Property wrappers may be
 * cached.
 *
 * Design Note: flex2.compiler.mxml.reflect.* interface with
 * flex2.compiler.abc.*. That way, the MXML type system is not tightly
 * coupled with the player VM type system.
 *
 * @author Clement Wong
 */
public class TypeTable
{
    private SymbolTable symbolTable;
    private final StandardDefs standardDefs;
    private NameMappings manifest;
    private Set<String> themeNames;

    public final Type noType;
    public final Type stringType;
    public final Type booleanType;
    public final Type classType;
    public final Type functionType;
    public final Type numberType;
    public final Type intType;
    public final Type uintType;
    public final Type arrayType;
    public final Type objectType;
    public final Type xmlType;
    public final Type xmlListType;
    public final Type regExpType;
    public final Type vectorType;

    private Map<String, Type> typeMap;
    private Map<String, String> nonRepeaters;

    public TypeTable(SymbolTable symbolTable, NameMappings manifest,
                     StandardDefs standardDefs, Set<String> themeNames)
    {
        this.symbolTable = symbolTable;
        this.manifest = manifest;
        this.standardDefs = standardDefs;
        this.themeNames = themeNames;

        nonRepeaters = new WeakHashMap<String, String>();
        typeMap = new HashMap<String, Type>();

        noType          = getType(SymbolTable.NOTYPE);
        objectType      = getType(SymbolTable.OBJECT);
        stringType      = getType(SymbolTable.STRING);
        booleanType     = getType(SymbolTable.BOOLEAN);
        classType       = getType(SymbolTable.CLASS);
        functionType    = getType(SymbolTable.FUNCTION);
        numberType      = getType(SymbolTable.NUMBER);
        intType         = getType(SymbolTable.INT);
        uintType        = getType(SymbolTable.UINT);
        arrayType       = getType(SymbolTable.ARRAY);
        xmlType         = getType(SymbolTable.XML);
        xmlListType     = getType(SymbolTable.XML_LIST);
        regExpType      = getType(SymbolTable.REGEXP);
        vectorType      = getType(SymbolTable.VECTOR);
    }

    /**
     * @return The Map of QNames to class names used by this TypeTable.
     */
    public NameMappings getNameMappings()
    {
        return manifest;
    }

    /**
     * Use <namespaceURI:localPart> to lookup a component implementation
     */
    public Type getType(String namespaceURI, String localPart)
    {
        // use manifest to lookup classname based on namespaceURI and localPart. classname is fully qualfied.
        String className = manifest.resolveClassName(namespaceURI, localPart);
        // C: should check the type visibility here...
        return getType(className);
    }

    public Type getType(QName qName)
    {
        return getType(qName.getNamespace(), qName.getLocalPart());
    }

    /**
     * Use the specified fully-qualified class name to lookup a component implementation.
     *
     * @param className Expected to be in colon format, ie foo:Bar.
     */
    public Type getType(String className)
    {
        assert NameFormatter.toColon(className).equals(className) : "toColon = " + NameFormatter.toColon(className) + ", className = " + className;
        Type type = typeMap.get(className);

        if (type == null)
        {
            // use symbolTable to lookup Class.
            AbcClass classInfo = symbolTable.getClass(className);

            if (classInfo != null)
            {
                type = new TypeHelper(classInfo, standardDefs);
                typeMap.put(className, type);
            }
            else
            {
                // Check if we have a Vector.
                int lessThanIndex = className.indexOf("<");
            
                if (lessThanIndex != -1)
                {
                    int greaterThanIndex = className.lastIndexOf(">");

                    if (greaterThanIndex != -1)
                    {
                        String elementTypeName = className.substring(lessThanIndex + 1, greaterThanIndex);
                        Type elementType = getType(elementTypeName);

                        if (elementType != null)
                        {
                            type = new TypeHelper(symbolTable.getClass(SymbolTable.VECTOR), elementType, standardDefs);
                            typeMap.put(className, type);
                            assert type.getName().equals(className) : "type = " + type.getName() + ", className = " + className;
                        }
                    }
                }
            }
        }

        return type;
    }

    public Type getVectorType(Type elementType)
    {
        String className = SymbolTable.VECTOR + ".<" + elementType.getName() + ">";
        Type type = typeMap.get(className);

        if (type == null)
        {
            type = new TypeHelper(symbolTable.getClass(SymbolTable.VECTOR), elementType, standardDefs);
            typeMap.put(className, type);
        }

        assert type.getName().equals(className) : "type = " + type.getName() + ", className = " + className;

        return type;
    }

    /**
     * Look up a globally-defined style property
     */
    public Style getStyle(String styleName)
    {
        MetaData md = symbolTable.getStyle(styleName);
        return md == null ? null : new StyleHelper(styleName,
                                                   md.getValue("type"),
                                                   md.getValue("enumeration"),
                                                   md.getValue("format"),
                                                   md.getValue("inherit"),
                                                   md.getValue(Deprecated.DEPRECATED_MESSAGE),
                                                   md.getValue(Deprecated.DEPRECATED_REPLACEMENT),
                                                   md.getValue(Deprecated.DEPRECATED_SINCE));
    }

    public Styles getStyles()
    {
        return symbolTable.getStyles();
    }

    /**
     * DynamicProperty gets a new, undeclared property placeholder
     */
    public DynamicProperty getDynamicProperty(String name, String state)
    {
        return new DynamicPropertyHelper(name, state);
    }

	public ContextStatics getPerCompileData()
    {
        return symbolTable.perCompileData;
    }

	public StandardDefs getStandardDefs()
	{
	    return standardDefs;
	}
	
    // Helper classes

    private final class TypeHelper implements Type
    {
        private TypeHelper(AbcClass classInfo, StandardDefs defs)
        {
            this(classInfo, null, defs);
        }

        private TypeHelper(AbcClass classInfo, Type elementType, StandardDefs defs)
        {
            assert classInfo != null;
            this.classInfo = classInfo;
            this.elementType = elementType;
            this.standardDefs = defs;
        }

        private AbcClass classInfo;
        private Type elementType;
        private EventListHelper events;
        private List<MetaData> effects;
        private List<MetaData> excludes;
        private List<MetaData> styles;
        private final StandardDefs standardDefs;

        public boolean equals(Object obj)
        {
            if (obj == this)
            {
                return true;
            }
            else if (obj instanceof Type)
            {
                return getName().equals(((Type) obj).getName());
            }
            else
            {
                return false;
            }
        }

        public TypeTable getTypeTable()
        {
            return TypeTable.this;
        }

        /**
         * Type name. AS3-compatible fully-qualified class name.
         */
        public String getName()
        {
            String result;

            if (elementType != null)
            {
                result = classInfo.getName() + ".<" + elementType.getName() + ">";
            }
            else
            {
                result = classInfo.getName();
            }

            return result;
        }

        /**
         * Super type
         */
        public Type getSuperType()
        {
            return classInfo.getSuperTypeName() != null ? getType(classInfo.getSuperTypeName()) : null;
        }

        public Type getElementType()
        {
            return elementType;
        }

        /**
         * Interfaces
         */
        public Type[] getInterfaces()
        {
            String[] ifaces = classInfo.getInterfaceNames();

            if (ifaces != null)
            {
                Type[] types = new Type[ifaces.length];
                for (int i = 0, length = types.length; i < length; i++)
                {
                    types[i] = getType(ifaces[i]);
                }
                return types;
            }
            else
            {
                return null;
            }
        }

        /**
         * Property. variables, getters, setters, etc.
         * Searches SymbolTable.VISIBILITY_NAMESPACES: public protected internal private
         */
        public Property getProperty(String name)
        {
            return getProperty(SymbolTable.VISIBILITY_NAMESPACES, name);
        }

        /**
         * Property. variables, getters, setters, etc.
         * Searches specified namespace
         */
        public Property getProperty(String namespace, String name)
        {
            return getProperty(new String[]{namespace}, name);
        }

        /**
         * Property. variables, getters, setters, etc.
         * Searches specified namespaces
         */
        public Property getProperty(String[] namespaces, String name)
        {
            AbcClass cls = classInfo, superClass = null;

            // walk the superclass chain for the specified property...
            while (cls != null)
            {
                Variable var = cls.getVariable(namespaces, name, false);
                if (var != null)
                {
                    if (!var.isStatic())
                    {
                        // found the property as a variable...
                        return new PropertyHelper(var);
                    }
                    else
                    {
                        superClass = symbolTable.getClass(cls.getSuperTypeName());
                    }
                }
                else
                {
                    Method setter = cls.getSetter(namespaces, name, false);
                    Method getter = cls.getGetter(namespaces, name, false);
                    if (setter != null && getter != null)
                    {
                        // found the property as a pair of getter and setter...
                        return new PropertyHelper(setter, getter);
                    }

                    superClass = symbolTable.getClass(cls.getSuperTypeName());

                    if (setter != null && superClass != null)
                    {
                        // search for a superclass getter before creating PropertyHelper.
                        getter = findGetter(superClass, name);
                        return new PropertyHelper(setter, getter);
                    }
                    else if (getter != null && superClass != null)
                    {
                        // search for a superclass setter before creating PropertyHelper.
                        setter = findSetter(superClass, name);
                        return new PropertyHelper(setter, getter);
                    }
                }
                cls = superClass;
            }

            return null;
        }

        /**
         *
         */
        public boolean hasStaticMember(String name)
        {
            AbcClass cls = classInfo;

            // walk the superclass chain for the specified property...
            while (cls != null)
            {
                Variable var = cls.getVariable(SymbolTable.VISIBILITY_NAMESPACES, name, false);
                if (var != null)
                {
                    if (var.isStatic())
                    {
                        return true;
                    }
                }
                else
                {
                    Method method = cls.getMethod(new String[] {SymbolTable.publicNamespace}, name, false);
                    if (method != null)
                    {
                        if (method.isStatic())
                        {
                            return true;
                        }
                    }
                }

                cls = symbolTable.getClass(cls.getSuperTypeName());
            }

            return false;
        }

        /**
         * [Event]
         * NOTE a) for now, we assume that Event's type attribute (if specified) is either fully qualified,
         *  ***in internal format***, or is in flash.core (!)
         * NOTE b) for now, we assume that Event's class can be found within current type set (!)
         * NOTE c) for now, we silently revert to flash.core.Event if (a) or (b) are false (!)
         * TODO fix (a), (b), (c) above, following ASC rearchitecture. EventExtension should a) try resolving unqualified
         * type against current imports; b) add import if implied by qualified type; c) logError if a/b fail
         */
        public Event getEvent(String name)
        {
            if (events == null)
            {
                events = new EventListHelper(classInfo.getMetaData("Event", false));
            }

            Event e = events.getEvent(name);

            if (e != null)
            {
                return e;
            }
            else
            {
                Type st = getSuperType();
                return (st != null) ? st.getEvent(name) : null;
            }
        }

        /**
         * [Effect]
         */
        public Effect getEffect(String name)
        {
            if (effects == null)
            {
                effects = classInfo.getMetaData("Effect", true);
            }

            for (int i = 0, length = effects.size(); i < length; i++)
            {
                MetaData md = effects.get(i);
                if (name.equals(md.getValue(0)))
                {
                    return new EffectHelper(name,
                                            md.getValue("event"),
                                            md.getValue(Deprecated.DEPRECATED_MESSAGE),
                                            md.getValue(Deprecated.DEPRECATED_REPLACEMENT),
                                            md.getValue(Deprecated.DEPRECATED_SINCE));
                }
            }

            return null;
        }

        /**
         * [Style]
         */
        public Style getStyle(String name)
        {
            if (styles == null)
            {
                styles = classInfo.getMetaData("Style", true);
            }

            if (!isExcludedStyle(name))
            {
                for (int i = 0, length = styles.size(); i < length; i++)
                {
                    MetaData md = styles.get(i);

                    if (name.equals(md.getValue("name")))
                    {
                        String theme = md.getValue("theme");

                        if ((theme == null) || (themeNames == null) || hasTheme(theme))
                        {
                            return new StyleHelper(name,
                                                   md.getValue("type"),
                                                   md.getValue("enumeration"),
                                                   md.getValue("format"),
                                                   md.getValue("inherit"),
                                                   md.getValue(Deprecated.DEPRECATED_MESSAGE),
                                                   md.getValue(Deprecated.DEPRECATED_REPLACEMENT),
                                                   md.getValue(Deprecated.DEPRECATED_SINCE));
                        }
                    }
                }
            }

            return null;
        }

        public boolean isExcludedStyle(String name)
        {
            boolean result = false;

            if (excludes == null)
            {
                excludes = classInfo.getMetaData("Exclude", true);
            }

            for (MetaData metaData : excludes)
            {
                if (name.equals(metaData.getValue("name")) &&
                    "style".equals(metaData.getValue("kind")))
                {
                    result = true;
                }
            }

            return result;
        }

        /**
         * [Style(theme="...")]
         */
        public String getStyleThemes(String name)
        {
            if (styles == null)
            {
                styles = classInfo.getMetaData("Style", true);
            }

            for (int i = 0, length = styles.size(); i < length; i++)
            {
                MetaData md = styles.get(i);

                if (name.equals(md.getValue("name")))
                {
                    return md.getValue("theme");
                }
            }

            return null;
        }
        
        private boolean hasTheme(String value)
        {
            boolean result = false;
            String[] themes = value.split("[, ]");
            
            for (int i = 0; i < themes.length; i++)
            {
                if (themeNames.contains(themes[i]))
                {
                    result = true;
                    break;
                }
            }

            return result;
        }

        /**
         * Determines whether this type declares the specified metadata.
         * @param name Specifies the name of the metadata to find.
         * @param inheriting Controls whether super types should be searched
         * for the specified metadata. 
         */
        public boolean hasMetadata(String name, boolean inheriting)
        {
            List<MetaData> metadata = classInfo.getMetaData(name, inheriting);
            if (metadata != null && metadata.size() > 0)
                return true;

            return false;
        }

        /**
         * [DefaultProperty]
         * Note: returns name as given in metadata - may or may not correctly specify a public property
         * TODO validate: should error when [DefaultProperty] is defined, but doesn't yield a default property
         */
        public Property getDefaultProperty()
        {
            List<MetaData> metadata = classInfo.getMetaData("DefaultProperty", true);
            if (metadata.size() > 0)
            {
                String defaultPropertyName = (metadata.get(0)).getValue(0);
                return defaultPropertyName != null ? getProperty(defaultPropertyName) : null;
            }
            else
            {
                return null;
            }
        }

        /**
         * [Obsolete]
         */
        public boolean hasObsolete(String name)
        {
            List<MetaData> metadata = classInfo.getMetaData("Obsolete", false);
            for (int i = 0, length = metadata.size(); i < length; i++)
            {
                MetaData md = metadata.get(i);
                if (name.equals(md.getValue(0)))
                {
                    return true;
                }
            }

            return false;
        }

        public int getMaxChildren()
        {
            List<MetaData> metadata = classInfo.getMetaData("MaxChildren", true);
            if (!metadata.isEmpty())
            {
                MetaData md = metadata.get(0);
                return Integer.parseInt(md.getValue(0));
            }

            return 0;
        }

        public String getLoaderClass()
        {
            List<MetaData> metadata = classInfo.getMetaData("Frame", true);
            if (!metadata.isEmpty())
            {
                MetaData md = metadata.get(0);

                return md.getValue( "factoryClass" );
            }
            return null;
        }

        /**
         * Dynamic type
         */
        public boolean hasDynamic()
        {
            return classInfo.isDynamic();
        }

        /**
         * Is this type a subclass of baseType?
         *
         * C: Note that this implementation of isAssignableTo *might* run into infinite recursion if there is a
         *    circular reference in the supertype/interface hierarchies. The type table is not expecting stuff
         *    registered in SymbolTable to have compile problems.
         *
         *    If we want to stop infinite recursion in this code, we just need to pass a HashSet down the recursion,
         *    detect when the code is processing something that already exists in the HashSet.
         */
        public boolean isSubclassOf(Type baseType)
        {
            if (baseType == this)
            {
                return true;
            }
            else if (baseType == noType)
            {
                return false;
            }
            else if (baseType != null)
            {
                return isSubclassOf(baseType.getName());
            }
            else
            {
                return false;
            }
        }

        public boolean isSubclassOf(String baseName)
        {
            if (SymbolTable.NOTYPE.equals(baseName))
            {
                return false;
            }
            else
            {
                return isAssignableTo(baseName);
            }
        }

        public boolean isAssignableTo(Type baseType)
        {
            if (baseType == this || baseType == noType)
            {
                return true;
            }
            else if (baseType != null)
            {
                return isAssignableTo(baseType.getName());
            }
            else
            {
                return false;
            }
        }

        public boolean isAssignableTo(String baseName)
        {
            String name = getName();

            // C: if this type is not assignable to Repeater, return false immediately.
            if (standardDefs.CLASS_REPEATER.equals(baseName) && TypeTable.this.nonRepeaters.containsKey(name))
            {
                return false;
            }

            if (SymbolTable.NOTYPE.equals(baseName) || name.equals(baseName))
            {
                return true;
            }

            Type superType = getSuperType();

            if (superType != null && superType.getName().equals(baseName))
            {
                return true;
            }

            Type[] interfaces = getInterfaces();

            for (int i = 0, length = (interfaces == null) ? 0 : interfaces.length; i < length; i++)
            {
                if (baseName != null && interfaces[i] != null && baseName.equals(interfaces[i].getName()))
                {
                    return true;
                }
            }

            if (superType != null && superType.isAssignableTo(baseName))
            {
                return true;
            }

            for (int i = 0, length = (interfaces == null) ? 0 : interfaces.length; i < length; i++)
            {
                if (interfaces[i] != null && interfaces[i].isAssignableTo(baseName))
                {
                    return true;
                }
            }

            // C: if this type is not assignable to Repeater, remember it.
            if (standardDefs.CLASS_REPEATER.equals(baseName))
            {
                TypeTable.this.nonRepeaters.put(name, name);
            }

            return false;
        }

        @Override
        public String toString()
        {
            return "Type " + getName();
        }

        // lookup superclass chain until it finds a matching getter...

        private Method findGetter(AbcClass cls, String name)
        {
            while (cls != null)
            {
                Method getter = cls.getGetter(new String[] {SymbolTable.publicNamespace},
                                              name, true);
                if (getter != null)
                {
                    return getter;
                }
                else
                {
                    cls = symbolTable.getClass(cls.getSuperTypeName());
                }
            }
            return null;
        }

        private Method findSetter(AbcClass cls, String name)
        {
            while (cls != null)
            {
                Method setter = cls.getSetter(new String[] {SymbolTable.publicNamespace},
                                              name, true);
                if (setter != null)
                {
                    return setter;
                }
                else
                {
                    cls = symbolTable.getClass(cls.getSuperTypeName());
                }
            }
            return null;
        }
    }

    private final class EventListHelper
    {
        private EventListHelper(List<MetaData> events)
        {
            if (events.size() == 0) return;

            eventTypes = new HashMap<String, EventHelper>(events.size());

            for (int i = 0, length = events.size(); i < length; i++)
            {
                MetaData md = events.get(i);

                String name = md.getValue("name");
                String typeName = md.getValue("type");
                
                if (name != null)
                {
                    if (typeName == null)
                    {
                        // [Event(name="...")]
                        typeName = SymbolTable.EVENT;
                    }
                    else
                    {
                        // [Event(name="...",type="...")]
                        typeName = NameFormatter.toColon(typeName);
                    }
                }
                else
                {
                    // [Event("name")]
                    name = md.getValue(0);
                    typeName = SymbolTable.EVENT;
                }

                if (typeName != null)
                {
                    eventTypes.put(name, new EventHelper(name, typeName,
                                                         md.getValue(Deprecated.DEPRECATED_MESSAGE),
                                                         md.getValue(Deprecated.DEPRECATED_REPLACEMENT),
                                                         md.getValue(Deprecated.DEPRECATED_SINCE)));
                }
            }
        }

        private Map<String, EventHelper> eventTypes;

        Event getEvent(String name)
        {
            return (eventTypes == null) ? null : eventTypes.get(name);
        }
    }

    /*
     * Serves as base for EventHelper, PropertyHelper, StyleHelper,and EffectHelper
     */
    private abstract class StatefulHelper implements Stateful
    {
        protected String state;
        
        /**
         * Is this a stateful property?
         */
        public boolean isStateSpecific()
        {
            return (state != null);
        }
        
        /**
         * Set state for which this property applies.
         */
        public void setStateName(String state)
        {
            this.state = state;
        }
        
        /**
         * Returns state for which this property applies.
         */
        public String getStateName()
        {
            return state;
        }
    }
    
    private final class PropertyHelper extends StatefulHelper implements Property
    {
        private PropertyHelper(Variable var)
        {
            this.var = var;
            if( var != null )
                this.name = var.getQName().getLocalPart();

            readOnly = var.isConst();
        }

        PropertyHelper(Method setter, Method getter)
        {
            this.setter = setter;
            this.getter = getter;

            if( setter != null )
                this.name = setter.getQName().getLocalPart();
            else if (getter != null )
                this.name = getter.getQName().getLocalPart();

            readOnly = setter == null && getter != null;
        }

        private boolean readOnly;

        private String name;
        
        private Variable var;
        private Method setter;
        private Method getter;

        private Type type;
        private Type elementType;
        private Type instanceType;
        private Type lvalueType;

        public boolean equals(Object obj)
        {
            if (obj instanceof Property)
            {
                Property p = (Property) obj;
                // FIXME
                return getName().equals(p.getName());
            }
            else
            {
                return false;
            }
        }

        /**
         * Property name
         */
        public String getName()
        {
            return name;
        }

        /**
         * Type.
         *
         * If this is a getter, the returned value is the getter's return type.
         * If this is a setter, the returned value is the type of the input
         * argument of the setter.
         */
        public Type getType()
        {
            if (type == null)
            {
                String className;
    
                if (var != null)
                {
                    className = var.getTypeName();
                }
                else if (setter != null)
                {
                    className = setter.getParameterTypeNames()[0];
                }
                else // if (getter != null)
                {
                    className = getter.getReturnTypeName();
                }

                type = TypeTable.this.getType(className);
            }

            return type;
        }

        public Type getLValueType()
        {
            if (lvalueType == null)
            {
                lvalueType = getType();

                // lvalue type - initializers to IDeferredInstance-typed properties
                // are values to be returned by the generated factory.
                if (standardDefs.isIDeferredInstance(lvalueType))
                {
                    lvalueType = getInstanceType();
                }
            }
            return lvalueType;
        }

        /**
         * [ArrayElementType] or Vector type
         */
        public Type getElementType()
        {
            elementType = getType().getElementType();

            if (elementType == null)
            {
                String elementTypeName = null;
                List<MetaData> mdList = getMetaDataList(StandardDefs.MD_ARRAYELEMENTTYPE);
    
                if (mdList != null)
                {
                    MetaData metaData = (MetaData) mdList.get(0);
    
                    if (metaData.count() > 0)
                    {
                        String value = metaData.getValue(0);

                        if (value != null)
                        {
                            elementTypeName = NameFormatter.toColon(value);
                        }
                    }
                }

                if (elementTypeName != null)
                {
                    elementType = TypeTable.this.getType(elementTypeName);

                    if (getType().equals(arrayType) && (elementType == null))
                    {
                        ElementTypeNotFound e = new ElementTypeNotFound(StandardDefs.MD_ARRAYELEMENTTYPE, elementTypeName);
                        ThreadLocalToolkit.log(e);
                    }
                }

                if (elementType == null)
                {
                    elementType = objectType;
                }
            }

            return elementType;
        }

        /**
         * [InstanceType]
         */
        public Type getInstanceType()
        {
            if (instanceType == null)
            {
                String instanceTypeName = null;
    
                List<MetaData> mdList = getMetaDataList(StandardDefs.MD_INSTANCETYPE);
                if (mdList != null)
                {
                    MetaData metaData = (MetaData) mdList.get(0);
                    if (metaData.count() > 0)
                    {
                        instanceTypeName = NameFormatter.toColon(metaData.getValue(0));
                    }
                }

                if (instanceTypeName == null)
                {
                    instanceType = objectType;
                }
                else
                {
                    instanceType = TypeTable.this.getType(instanceTypeName);

                    if (instanceType == null)
                    {
                        // TODO: this needs to be handled differently,
                        // because it doesn't get a path or a line
                        // number before being reported.  Since there
                        // is no context here, one option is to throw
                        // it and catch it upstream when the context
                        // is available.
                        ThreadLocalToolkit.log(new NullInstanceType(StandardDefs.MD_INSTANCETYPE, instanceTypeName));
                        instanceType = objectType;
                    }
                }
            }

            return instanceType;
        }

        /**
         * Is this read only?
         */
        public boolean readOnly()
        {
            return readOnly;
        }

        /**
         *
         */
        public boolean hasPublic()
        {
            return var != null ? var.isPublic() :
                    setter != null ? setter.isPublic() :
                    getter.isPublic();
        }

        /**
         *
         */
        public Inspectable getInspectable()
        {
            List<MetaData> mdList = getMetaDataList(Inspectable.INSPECTABLE);
            if (mdList != null)
            {
                MetaData md = mdList.get(0);

                return new InspectableHelper(md.getValue(Inspectable.ENUMERATION),
                                             md.getValue(Inspectable.DEFAULT_VALUE),
                                             md.getValue(Inspectable.IS_DEFAULT),
                                             md.getValue(Inspectable.CATEGORY),
                                             md.getValue(Inspectable.IS_VERBOSE),
                                             md.getValue(Inspectable.TYPE),
                                             md.getValue(Inspectable.OBJECT_TYPE),
                                             md.getValue(Inspectable.ARRAY_TYPE),
                                             md.getValue(Inspectable.ENVIRONMENT),
                                             md.getValue(Inspectable.FORMAT));
            }
            else
            {
                return null;
            }
        }

        public Deprecated getDeprecated()
        {
            List<MetaData> mdList = getMetaDataList(Deprecated.DEPRECATED);
            if (mdList != null)
            {
                MetaData md = mdList.get(0);

                String replacement = md.getValue(Deprecated.REPLACEMENT);
                String message     = md.getValue(Deprecated.MESSAGE);
                String since       = md.getValue(Deprecated.SINCE);

                // grab whatever string /was/ provided: [Deprecated("foo")]
                if ((replacement == null) &&
                        (message == null) &&
                          (since == null) && (md.count() > 0))
                {
                    message = md.getValue(0);
                }
                
                return new DeprecatedHelper(replacement, message, since);
            }
            else
            {
                return null;
            }
        }

        /**
         * [ChangeEvent]
         * TODO why just on var? should it be returned for getter/setter props?
         */
        public boolean hasChangeEvent(String name)
        {
            if (var != null)
            {
                List<MetaData> mdList = var.getMetaData(StandardDefs.MD_CHANGEEVENT);
                if (mdList != null)
                {
                    for (int i = 0, size = mdList.size(); i < size; i++)
                    {
                        MetaData md = mdList.get(i);
                        if (name.equals(md.getValue(0)))
                        {
                            return true;
                        }
                    }
                }
            }

            return false;
        }

        /**
         * [PercentProxy]
         */
        public String getPercentProxy()
        {
            List<MetaData> metaDataList = getMetaDataList(StandardDefs.MD_PERCENTPROXY);
            if (metaDataList != null && !metaDataList.isEmpty())
            {
                MetaData metaData = (MetaData) metaDataList.get(0);
                if (metaData.count() > 0)
                {
                    return metaData.getValue(0);
                }
            }

            return null;
        }

        /**
         * [RichTextContent]
         */
        public boolean richTextContent()
        {
            return getMetaDataList(StandardDefs.MD_RICHTEXTCONTENT) != null;
        }

        /**
         * [CollapseWhiteSpace]
         */
        public boolean collapseWhiteSpace()
        {
            return getMetaDataList(StandardDefs.MD_COLLAPSEWHITESPACE) != null;
        }

        /**
         * property metadata lookup: we will have either a non-null var, or <getter, setter> with one or both non-null.
         * Return value is guaranteed non-empty if non-null.
         * Note: validation should ensure that each metadata name occurs at most once on the latter pair.
         */
        private List<MetaData> getMetaDataList(String name)
        {
            List<MetaData> mdList = null;

            if (var != null)
            {
                mdList = var.getMetaData(name);
            }
            else
            {
                if (getter != null)
                {
                    mdList = getter.getMetaData(name);
                }

                if (mdList == null && setter != null)
                {
                    mdList = setter.getMetaData(name);
                }
            }

            return mdList != null && mdList.size() > 0 ? mdList : null;
        }

        @Override
        public String toString()
        {
            return "Property " + getName();
        }
    }

    private final class EventHelper extends StatefulHelper implements Event
    {
        private final String name;
        private final String typeName;
        private Type type;
        private final String message;
        private final String replacement;
        private final String since;
        
        private EventHelper(String name, String typeName, String message, String replacement, String since)
        {
            this.name = name;
            this.typeName = typeName;
            this.message = message;
            this.replacement = replacement;
            this.since = since;
        }

        public String getName()
        {
            return name;
        }

        public String getTypeName()
        {
            return typeName;
        }

        public Type getType()
        {
            return type != null ? type : (type = TypeTable.this.getType(typeName));
        }
        
        public String getDeprecatedMessage()
        {
            return message;
        }

        public String getDeprecatedReplacement()
        {
            return replacement;
        }

        public String getDeprecatedSince()
        {
            return since;
        }

        @Override
        public String toString()
        {
            return "Event " + getName();
        }
    }

    private final class StyleHelper extends StatefulHelper implements Style
    {
        /**
         * NOTE for now, we assume that specified type name (if specified) is either fully qualified,
         * TODO fix this, following ASC rearchitecture. StyleExtension should a) try resolving unqualified
         * type against current imports; b) add import if implied by qualified type; c) logError if a/b fail
         * TODO make StyleHelper and EventHelper consistent w.r.t. type member
         */
        private StyleHelper(String name, String typeName, String enumeration, String format, String inherit,
                            String message, String replacement, String since)
        {
            if (typeName == null)
            {
                typeName = (enumeration == null) ? SymbolTable.OBJECT : SymbolTable.STRING;
            }
            else
            {
                //  HACK: for now, if declared type isn't found... (no more actionscript.lang)
                //  TODO: this should no longer be necessary given metadata scanning in as3.SyntaxTreeEvaluator, but
                //  leaving it in place for now out of cowardice.
                Type t = TypeTable.this.getType(NameFormatter.toColon(typeName));
                if (t == null)
                {
                    typeName = SymbolTable.OBJECT;
                }
                //  /HACK
            }

            this.name = name;
			this.typeName = NameFormatter.toColon(typeName);
            if (enumeration != null)
            {
                StringTokenizer t = new StringTokenizer(enumeration, ",");
                this.enumeration = new String[t.countTokens()];
                for (int i = 0; t.hasMoreTokens(); i++)
                {
                    this.enumeration[i] = t.nextToken();
                }
            }
            this.format = format;
            isInherit = "yes".equalsIgnoreCase(inherit);
            
            this.message = message;
            this.replacement = replacement;
            this.since = since;
        }

        private final String name;
        private final String typeName;
        private String[] enumeration;
        private String format;
        private final boolean isInherit;
        private final String message;
        private final String replacement;
        private final String since;
        private Type type;
        private Type lvalueType;

        public String getName()
        {
            return name;
        }

        public Type getType()
        {
            if (type == null)
            {
                type = TypeTable.this.getType(typeName);
            }
            return type;
        }

        public Type getLValueType()
        {
            if (lvalueType == null)
            {
                lvalueType = getType();

                //  lvalue type - initializers to IDeferredInstance-typed styles
                // are values to be returned by the generated factory.
                if (standardDefs.isIDeferredInstance(lvalueType))
                {
                    lvalueType = TypeTable.this.objectType;
                }
            }
            return lvalueType;
        }

        public Type getElementType()
        {
            return objectType;
        }

        public String[] getEnumeration()
        {
            return enumeration;
        }

        public String getFormat()
        {
            return format;
        }

        public boolean isInherit()
        {
            return isInherit;
        }

        public String getDeprecatedMessage()
        {
            return message;
        }

        public String getDeprecatedReplacement()
        {
            return replacement;
        }

        public String getDeprecatedSince()
        {
            return since;
        }

        @Override
        public String toString()
        {
            return "Style " + getName();
        }
    }

    private final class EffectHelper extends StatefulHelper implements Effect
    {
        private final String name;
        private final String event;
        private final String message;
        private final String replacement;
        private final String since;

        private EffectHelper(String name, String event, String message, String replacement, String since)
        {
            this.name = name;
            this.event = event;
            this.message = message;
            this.replacement = replacement;
            this.since = since;
        }

        public String getName()
        {
            return name;
        }

        public Type getType()
        {
            return TypeTable.this.getType(standardDefs.CLASS_EFFECT);
        }

        public Type getLValueType()
        {
            return getType();
        }

        public Type getElementType()
        {
            return objectType;
        }

        public String getEvent()
        {
            return event;
        }

        public String getDeprecatedMessage()
        {
            return message;
        }

        public String getDeprecatedReplacement()
        {
            return replacement;
        }

        public String getDeprecatedSince()
        {
            return since;
        }

        @Override
        public String toString()
        {
            return "Effect " + getName();
        }
    }

    private final class DynamicPropertyHelper extends StatefulHelper implements DynamicProperty
    {
        private final String name;

        private DynamicPropertyHelper(String name, String state)
        {
            this.name = name;
            this.state = state;
        }

        public String getName()
        {
            return name;
        }

        public Type getType()
        {
            return objectType;
        }

        public Type getLValueType()
        {
            return getType();
        }

        public Type getElementType()
        {
            return objectType;
        }

        @Override
        public String toString()
        {
            return "DynamicProperty " + getName();
        }
    }

    private final class InspectableHelper implements Inspectable
    {
        private InspectableHelper(String enumeration,
                                  String defaultValue,
                                  String isDefault,
                                  String category,
                                  String isVerbose,
                                  String type,
                                  String objectType,
                                  String arrayType,
                                  String environment,
                                  String format)
        {
            if (enumeration != null)
            {
                StringTokenizer t = new StringTokenizer(enumeration, ",");
                this.enumeration = new String[t.countTokens()];
                for (int i = 0; t.hasMoreTokens(); i++)
                {
                    this.enumeration[i] = t.nextToken();
                }
            }

            this.defaultValue = defaultValue;
            this.isDefault = "yes".equalsIgnoreCase(isDefault);
            this.category = category;
            this.isVerbose = "yes".equalsIgnoreCase(isVerbose);
            this.type = type;
            this.objectType = objectType;
            this.arrayType = arrayType;
            this.environment = environment;
            this.format = format;
        }

        private String[] enumeration;
        private String defaultValue;
        private boolean isDefault;
        private String category;
        private boolean isVerbose;
        private String type;
        private String objectType;
        private String arrayType;
        private String environment;
        private String format;

        /**
         * enumeration
         */
        public String[] getEnumeration()
        {
            return enumeration;
        }

        /**
         * default value
         */
        public String getDefaultValue()
        {
            return defaultValue;
        }

        /**
         * default?
         */
        public boolean isDefault()
        {
            return isDefault;
        }

        /**
         * category
         */
        public String getCategory()
        {
            return category;
        }

        /**
         * verbose?
         */
        public boolean isVerbose()
        {
            return isVerbose;
        }

        /**
         * type
         */
        public String getType()
        {
            return type;
        }

        /**
         * object type
         */
        public String getObjectType()
        {
            return objectType;
        }

        /**
         * array type
         */
        public String getArrayType()
        {
            return arrayType;
        }

        /**
         * environment
         */
        public String getEnvironment()
        {
            return environment;
        }

        /**
         * format
         */
        public String getFormat()
        {
            return format;
        }
    }

    private final class DeprecatedHelper implements Deprecated
    {
        private DeprecatedHelper(String replacement, String message, String since)
        {
            this.replacement = replacement;
            this.message = message;
            this.since = since;
        }

        private String replacement;
        private String message;
        private String since;

        public String getReplacement()
        {
            return replacement;
        }

        public String getMessage()
        {
            return message;
        }
        
        public String getSince()
        {
            return since;
        }
    }

    public static class NullInstanceType extends CompilerWarning
    {
        private static final long serialVersionUID = 9108186251245008722L;
        public String instanceType;
        public String instanceTypeName;

        public NullInstanceType(String instanceType, String instanceTypeName)
        {
            this.instanceType = instanceType;
            this.instanceTypeName = instanceTypeName;
        }
    }
}
