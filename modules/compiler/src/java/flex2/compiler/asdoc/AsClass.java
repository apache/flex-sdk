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
import java.util.HashMap;

import org.w3c.dom.Element;

/**
 * Class to store all info for a class - this info will be used to assemble classes later in asdoc generation
 */
public class AsClass
{
    private boolean innerClass;
    private boolean interfaceFlag;
    private String interfaceStr;

    private String name;
    private String fullName;
    private String baseName;
    private ArrayList<String> excludedProperties;

    private QualifiedNameInfo decompName;

    private Element node;
    private Element methods;
    private Element constructors;
    private Element fields;

    private int methodCount;
    private int constructorCount;
    private int fieldCount;

    private int innerClassCount;
    private ArrayList<AsClass> innerClasses;

    private String href;

    private HashMap<String, String> eventCommentTable;
    private HashMap<String, Integer> fieldGetSet;
    private HashMap<String, Integer> privateGetSet;
    private HashMap<String, String> methodOverrideTable;

    private String sourceFile;
    
    private boolean pendingCopyDoc;
    
    /**
     * Constructor
     */
    public AsClass()
    {
        interfaceStr = "";
        name = "";
        fullName = "";
        baseName = "";
        href = "";
        excludedProperties = new ArrayList<String>();

        innerClasses = new ArrayList<AsClass>();

        eventCommentTable = new HashMap<String, String>();
        fieldGetSet = new HashMap<String, Integer>();
        privateGetSet = new HashMap<String, Integer>();
        methodOverrideTable = new HashMap<String, String>();
    }

    public boolean isInnerClass()
    {
        return innerClass;
    }

    public void setInnerClass(boolean innerClass)
    {
        this.innerClass = innerClass;
    }

    public boolean isInterfaceFlag()
    {
        return interfaceFlag;
    }

    public void setInterfaceFlag(boolean interfaceFlag)
    {
        this.interfaceFlag = interfaceFlag;
    }

    public String getInterfaceStr()
    {
        return interfaceStr;
    }

    public void setInterfaceStr(String interfaceStr)
    {
        this.interfaceStr = interfaceStr;
    }

    public String getName()
    {
        return name;
    }

    public void setName(String name)
    {
        this.name = name;
    }

    public String getFullName()
    {
        return fullName;
    }

    public void setFullName(String fullName)
    {
        this.fullName = fullName;
    }

    public String getBaseName()
    {
        return baseName;
    }

    public void setBaseName(String baseName)
    {
        this.baseName = baseName;
    }

    public ArrayList<String> getExcludedProperties()
    {
        return excludedProperties;
    }

    public void setExcludedProperties(ArrayList<String> excludedProperties)
    {
        this.excludedProperties = excludedProperties;
    }

    public QualifiedNameInfo getDecompName()
    {
        return decompName;
    }

    public void setDecompName(QualifiedNameInfo decompName)
    {
        this.decompName = decompName;
    }

    public int getMethodCount()
    {
        return methodCount;
    }

    public void setMethodCount(int methodCount)
    {
        this.methodCount = methodCount;
    }

    public int getConstructorCount()
    {
        return constructorCount;
    }

    public void setConstructorCount(int constructorCount)
    {
        this.constructorCount = constructorCount;
    }

    public int getFieldCount()
    {
        return fieldCount;
    }

    public void setFieldCount(int fieldCount)
    {
        this.fieldCount = fieldCount;
    }

    public int getInnerClassCount()
    {
        return innerClassCount;
    }

    public void setInnerClassCount(int innerClassCount)
    {
        this.innerClassCount = innerClassCount;
    }

    public ArrayList<AsClass> getInnerClasses()
    {
        return innerClasses;
    }

    public void setInnerClasses(ArrayList<AsClass> innerClasses)
    {
        this.innerClasses = innerClasses;
    }

    public String getHref()
    {
        return href;
    }

    public void setHref(String href)
    {
        this.href = href;
    }

    public HashMap<String, String> getEventCommentTable()
    {
        return eventCommentTable;
    }

    public void setEventCommentTable(HashMap<String, String> eventCommentTable)
    {
        this.eventCommentTable = eventCommentTable;
    }

    public HashMap<String, Integer> getFieldGetSet()
    {
        return fieldGetSet;
    }

    public void setFieldGetSet(HashMap<String, Integer> fieldGetSet)
    {
        this.fieldGetSet = fieldGetSet;
    }

    public HashMap<String, Integer> getPrivateGetSet()
    {
        return privateGetSet;
    }

    public void setPrivateGetSet(HashMap<String, Integer> privateGetSet)
    {
        this.privateGetSet = privateGetSet;
    }

    public HashMap<String, String> getMethodOverrideTable()
    {
        return methodOverrideTable;
    }

    public void setMethodOverrideTable(
            HashMap<String, String> methodOverrideTable)
    {
        this.methodOverrideTable = methodOverrideTable;
    }

    public Element getNode()
    {
        return node;
    }

    public void setNode(Element node)
    {
        this.node = node;
    }

    public Element getMethods()
    {
        return methods;
    }

    public void setMethods(Element methods)
    {
        this.methods = methods;
    }

    public Element getConstructors()
    {
        return constructors;
    }

    public void setConstructors(Element constructors)
    {
        this.constructors = constructors;
    }

    public Element getFields()
    {
        return fields;
    }

    public void setFields(Element fields)
    {
        this.fields = fields;
    }

    public String getSourceFile()
    {
        return sourceFile;
    }

    public void setSourceFile(String sourceFile)
    {
        this.sourceFile = sourceFile;
    }

    public boolean isPendingCopyDoc()
    {
        return pendingCopyDoc;
    }

    public void setPendingCopyDoc(boolean pendingCopyDoc)
    {
        if(!this.pendingCopyDoc)
        {
            this.pendingCopyDoc = pendingCopyDoc;
        }
    }
}
