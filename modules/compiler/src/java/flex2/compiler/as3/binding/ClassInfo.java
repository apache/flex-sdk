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

package flex2.compiler.as3.binding;

import flex2.compiler.util.MultiName;
import flex2.compiler.util.QName;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * This class holds AS3 class information, which can be obtained after
 * the parse phase.  This includes the imports, inheritance,
 * functions, getters, setters, and variables.  None of this
 * information has been validated.  It's only intended to guide
 * downstream code generation.
 *
 * @author Paul Reilly
 * @see flex2.compiler.as3.binding.TypeAnalyzer
 */
public class ClassInfo extends Info
{
    private String className;
    private List<QName> variables;
    private ClassInfo baseClassInfo;
    private String baseClassName;
    private MultiName baseClassMultiName;
    private Map<String, Boolean> skinParts;
    
    public ClassInfo(String className)
    {
        this.className = className;

        int lastIndex = className.lastIndexOf(":");

        if (lastIndex > 0)
        {
            addImport(className.substring(0, lastIndex));
        }
    }

    public void addVariable(QName variableName)
    {
        if (variables == null)
        {
            variables = new ArrayList<QName>();
        }

        variables.add(variableName);
    }
    
    /**
     * Adds Currently only used for SkinParts. When metadata with the id SkinPart is
     * found it gets added to the ClassInfo instance. 
     * 
     * @param fieldName The name of the SkinPart.
     * @param required If true there will be a runtime check for the skin part. 
     * If it does not exist an error will be thrown.
     */
	public void addSkinPart(String fieldName, Boolean required) 
    {
        if (skinParts == null)
        {
            skinParts = new HashMap<String, Boolean>();
        }
        
        skinParts.put(fieldName, required);
    }
    
    public boolean definesFunction(String functionName, boolean inherited)
    {
        boolean result = definesFunction(functionName);

        if (!result && inherited && (baseClassInfo != null))
        {
            result = baseClassInfo.definesFunction(functionName, inherited);
        }

        return result;
    }

    public boolean definesGetter(String getterName, boolean inherited)
    {
        boolean result = super.definesGetter(getterName);

        if (!result && inherited && (baseClassInfo != null))
        {
            result = baseClassInfo.definesGetter(getterName, inherited);
        }

        return result;        
    }

    public boolean definesSetter(String setterName, boolean inherited)
    {
        boolean result = super.definesSetter(setterName);

        if (!result && inherited && (baseClassInfo != null))
        {
            result = baseClassInfo.definesSetter(setterName, inherited);
        }

        return result;
    }

    public String getClassName()
    {
        return className;
    }

    public ClassInfo getBaseClassInfo()
    {
        return baseClassInfo;
    }

    public String getBaseClassName()
    {
        return baseClassName;
    }

    /**
     * Returns the SkinParts for the class. When specified all inherited parts
     * will be returned.
     * 
     * @param inherited If true all skin parts including those from base classes
     * will be returned.
     * @return Map a Map that includes the SkinParts for the class.
     */
    public Map<String, Boolean> getSkinParts(Boolean inherited)
    {
        if (inherited == true)
        {
            Map<String, Boolean> baseParts = null;
            //Get all base class skin parts
            
            if (baseClassInfo != null)
            {
                baseParts = baseClassInfo.getSkinParts(inherited);
            }
            
            Map<String, Boolean> inheritedMap = new HashMap<String, Boolean>();
            
            //add local skin parts
            if (skinParts != null)
            {
                inheritedMap.putAll(skinParts);
            }
            
            if (baseParts != null)
            {
                //add base skin parts if they exist
                inheritedMap.putAll(baseParts);
            }

            //return a new map so we do not modify our local one
            return inheritedMap;
        }
        else
        {
            return skinParts;
        }
    }
    
    public MultiName getBaseClassMultiName()
    {
        if (baseClassMultiName == null)
        {
            baseClassMultiName = getMultiName(baseClassName);
        }

        return baseClassMultiName;
    }

    public boolean definesVariable(String variableName)
    {
        boolean result = false;

        if (variables != null)
        {
            Iterator<QName> iterator = variables.iterator();

            while ( iterator.hasNext() )
            {
                QName qName = iterator.next();
                if ( variableName.equals( qName.getLocalPart() ) )
                {
                    result = true;
                }
            }
        }

        if (!result && (baseClassInfo != null))
        {
            result = baseClassInfo.definesVariable(variableName);
        }

        return result;
    }

    public boolean extendsClass(String className)
    {
        boolean result = this.className.equals(className);

        if (!result && baseClassInfo != null)
        {
            result = baseClassInfo.extendsClass(className);
        }

        return result;
    }

    public boolean implementsInterface(String namespace, String interfaceName)
    {
        boolean result = super.implementsInterface(namespace, interfaceName);

        if (!result && (baseClassInfo != null))
        {
            result = baseClassInfo.implementsInterface(namespace, interfaceName);
        }

        return result;
    }

    public void setBaseClassInfo(ClassInfo baseClassInfo)
    {
        assert baseClassInfo != null;
        
        // ASC will report an error downstream, but we need to guard
        // against a class, which extends itself, here to avoid
        // StackOverflowErrors.  See SDK-24833.
        if (baseClassInfo != this)
        {
            this.baseClassInfo = baseClassInfo;
        }
    }

    public void setBaseClassName(String baseClassName)
    {
        this.baseClassName = baseClassName;
    }
}
