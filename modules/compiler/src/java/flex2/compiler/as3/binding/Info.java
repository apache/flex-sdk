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
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * This class provides a base class for holding information common to
 * classes and interfaces.
 *
 * @author Paul Reilly
 * @see flex2.compiler.as3.binding.TypeAnalyzer
 */
abstract class Info
{
    private Set<String> imports;
    private Map<String, String> qualifiedImports;
    private List<String> interfaceNames;
    private List<MultiName> interfaceMultiNames;
    private List<InterfaceInfo> interfaceInfoList;
    private List<QName> functions;
    private List<QName> getters;
    private List<QName> setters;

    public Info()
    {
    }

    public void addFunction(QName functionName)
    {
        assert functionName != null;

        if (functions == null)
        {
            functions = new ArrayList<QName>();
        }

        functions.add(functionName);
    }

    public void addGetter(QName getterName)
    {
        assert getterName != null;

        if (getters == null)
        {
            getters = new ArrayList<QName>();
        }

        getters.add(getterName);
    }

    void addImport(String importName)
    {
        assert importName != null;

        if (imports == null)
        {
            imports = new TreeSet<String>();
        }

        imports.add(importName);
    }

    public void addInterfaceMultiName(String[] namespaces, String interfaceName)
    {
        assert namespaces != null && interfaceName != null;

        if (interfaceMultiNames == null)
        {
            interfaceMultiNames = new ArrayList<MultiName>();
        }

        interfaceMultiNames.add( new MultiName(namespaces, interfaceName) );
    }

    public void addInterfaceMultiName(String namespace, String interfaceName)
    {
        assert namespace != null && interfaceName != null;

        if (interfaceMultiNames == null)
        {
            interfaceMultiNames = new ArrayList<MultiName>();
        }

        interfaceMultiNames.add( new MultiName(namespace, interfaceName) );
    }

    void addInterfaceName(String interfaceName)
    {
        assert interfaceName != null;

        if (interfaceNames == null)
        {
            interfaceNames = new ArrayList<String>();
        }

        interfaceNames.add(interfaceName);
    }

    public void addInterfaceInfo(InterfaceInfo interfaceInfo)
    {
        assert interfaceInfo != null;

        if (interfaceInfoList == null)
        {
            interfaceInfoList = new ArrayList<InterfaceInfo>();
        }

        interfaceInfoList.add(interfaceInfo);
    }

    void addQualifiedImport(String localPart, String namespace)
    {
        assert (localPart != null) && (localPart.length() > 0) && (namespace != null);

        if (qualifiedImports == null)
        {
            qualifiedImports = new TreeMap<String, String>();
        }

        qualifiedImports.put(localPart, namespace);
    }

    public void addSetter(QName setterName)
    {
        if (setters == null)
        {
            setters = new ArrayList<QName>();
        }

        setters.add(setterName);
    }

    boolean definesFunction(String functionName)
    {
        boolean result = false;

        if (functions != null)
        {
            Iterator<QName> iterator = functions.iterator();

            while ( iterator.hasNext() )
            {
                QName qName = iterator.next();
                if ( functionName.equals( qName.getLocalPart() ) )
                {
                    result = true;
                }
            }
        }

        return result;
    }

    boolean definesGetter(String getterName)
    {
        boolean result = false;

        if (getters != null)
        {
            Iterator<QName> iterator = getters.iterator();

            while ( iterator.hasNext() )
            {
                QName qName = iterator.next();
                if ( getterName.equals( qName.getLocalPart() ) )
                {
                    result = true;
                }
            }
        }

        return result;
    }

    boolean definesSetter(String setterName)
    {
        boolean result = false;

        if (setters != null)
        {
            Iterator<QName> iterator = setters.iterator();

            while ( iterator.hasNext() )
            {
                QName qName = iterator.next();
                if ( setterName.equals( qName.getLocalPart() ) )
                {
                    result = true;
                }
            }
        }

        return result;
    }

    public List<QName> getFunctionNames()
    {
        return functions;
    }

    public Set<String> getImports()
    {
        return imports;
    }

    List<MultiName> getInterfaceMultiNames()
    {
        if (interfaceMultiNames == null)
        {
            interfaceMultiNames = new ArrayList<MultiName>();

            if (interfaceNames != null)
            {
                Iterator<String> iterator = interfaceNames.iterator();

                while ( iterator.hasNext() )
                {
                    String interfaceName = iterator.next();

                    MultiName interfaceMultiName = getMultiName(interfaceName);

                    interfaceMultiNames.add(interfaceMultiName);
                }
            }
        }

        return interfaceMultiNames;
    }

    public MultiName getMultiName(String name)
    {
		assert name != null : "Info.getMultiName called on null";

		MultiName result;

        int lastIndex = name.lastIndexOf(":");

        if (lastIndex < 0)
        {
            lastIndex = name.lastIndexOf(".");
        }

        if (lastIndex > 0)
        {
            result = new MultiName(new String[] {name.substring(0, lastIndex)},
                                   name.substring(lastIndex + 1));
        }
        else if ((qualifiedImports != null) && qualifiedImports.containsKey(name))
        {
            result = new MultiName(new String[] {qualifiedImports.get(name)}, name);
        }
        else if (imports != null)
        {
            String[] namespaces = new String[imports.size() + 1];
            imports.toArray(namespaces);
            namespaces[imports.size()] = "";
            result = new MultiName(namespaces, name);
        }
        else
        {
            result = new MultiName(name);
        }

        return result;
    }

    boolean implementsInterface(String namespace, String interfaceName)
    {
        boolean result = false;

        assert (((interfaceMultiNames == null) && (interfaceInfoList == null)) ||
                ((interfaceMultiNames != null) && (interfaceInfoList != null) &&
                 (interfaceInfoList.size() == interfaceMultiNames.size()))) :
                "Info.implementsInterface: interfaceInfoList = " + interfaceInfoList +
                ", interfaceMultiNames = " + interfaceMultiNames;

        if (interfaceInfoList != null)
        {
            Iterator<InterfaceInfo> iterator = interfaceInfoList.iterator();

            while ( iterator.hasNext() )
            {
                InterfaceInfo interfaceInfo = iterator.next();

                if (interfaceInfo.getInterfaceName().equals(namespace + ":" + interfaceName))
                {
                    result = true;
                }
                else if (interfaceInfo.extendsInterface(namespace, interfaceName))
                {
                    result = true;
                }
                else if (interfaceInfo.implementsInterface(namespace, interfaceName))
                {
                    result = true;
                }
            }
        }

        return result;
    }
}
