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

/**
 * This class holds AS3 interface information, which can be obtained
 * after the parse phase.  This includes the imports, inheritance,
 * functions, getters, and setters.  None of this information has been
 * validated.  It's only intended to guide downstream code generation.
 *
 * @author Paul Reilly
 * @see flex2.compiler.as3.binding.TypeAnalyzer
 */
public class InterfaceInfo extends Info
{
    private String interfaceName;
    private InterfaceInfo baseInterfaceInfo;
    private String baseInterfaceName;
    private MultiName baseInterfaceMultiName;

    public InterfaceInfo(String interfaceName)
    {
        this.interfaceName = interfaceName;

        int lastIndex = interfaceName.lastIndexOf(":");

        if (lastIndex > 0)
        {
            addImport(interfaceName.substring(0, lastIndex));
        }
    }

    public boolean definesFunction(String functionName, boolean inherited)
    {
        boolean result = super.definesFunction(functionName);

        if (!result && inherited && (baseInterfaceInfo != null))
        {
            result = baseInterfaceInfo.definesFunction(functionName, inherited);
        }

        return result;
    }

    public boolean definesGetter(String getterName)
    {
        boolean result = super.definesGetter(getterName);

        if (!result && (baseInterfaceInfo != null))
        {
            result = baseInterfaceInfo.definesGetter(getterName);
        }

        return result;        
    }

    public boolean definesSetter(String setterName, boolean inherited)
    {
        boolean result = super.definesSetter(setterName);

        if (!result && inherited && (baseInterfaceInfo != null))
        {
            result = baseInterfaceInfo.definesSetter(setterName, inherited);
        }

        return result;
    }

    public String getInterfaceName()
    {
        return interfaceName;
    }

    public String getBaseInterfaceName()
    {
        return baseInterfaceName;
    }

    public MultiName getBaseInterfaceMultiName()
    {
        if (baseInterfaceMultiName == null)
        {
            baseInterfaceMultiName = getMultiName(baseInterfaceName);
        }

        return baseInterfaceMultiName;
    }

    public boolean extendsInterface(String namespace, String interfaceName)
    {
        boolean result = false;

        if (baseInterfaceInfo != null)
        {
            result = baseInterfaceInfo.getInterfaceName().equals(namespace + ":" + interfaceName);

            if (!result)
            {
                result = baseInterfaceInfo.extendsInterface(namespace, interfaceName);
            }
        }

        return result;
    }

    public boolean implementsInterface(String namespace, String interfaceName)
    {
        boolean result = super.implementsInterface(namespace, interfaceName);

        if (!result && (baseInterfaceInfo != null))
        {
            result = baseInterfaceInfo.implementsInterface(namespace, interfaceName);
        }

        return result;
    }

    public void setBaseInterfaceInfo(InterfaceInfo baseInterfaceInfo)
    {
        assert baseInterfaceInfo != null;
        this.baseInterfaceInfo = baseInterfaceInfo;
    }

    public void setBaseInterfaceName(String baseInterfaceName)
    {
        this.baseInterfaceName = baseInterfaceName;
    }

    public String toString()
    {
        return ("InterfaceInfo: " + interfaceName);
    }
}
