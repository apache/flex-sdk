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

package flex2.compiler.fxg;

import java.util.ArrayList;
import java.util.List;

import flash.swf.tags.DefineTag;

/**
 * Used to map a SWF symbol generated for a particular FXG node to
 * an ActionScript class. This association links a tag primitive to more
 * complex assets, such as the ActionScript implementation of a TextGraphic
 * node (which does not have a tag primitive equivalent).
 *
 * @author Pete Farland
 */
public class FXGSymbolClass
{
    private static final String DEFAULT_PACKAGE = "";
    private static final char PACKAGE_SEPARATOR = '.';

    private String packageName;
    private String className;
    private String generatedSource;
    private DefineTag symbol;

    private List<FXGSymbolClass> additionalSymbolClasses;

    /**
     * An FXG node may have child nodes that also require a symbol class
     * mapping that will be included along with the parent symbol for the
     * compilation unit.
     * 
     * @param spriteClass - an additional symbol class
     */
    public void addAdditionalSymbolClass(FXGSymbolClass symbolClass)
    {
        if (additionalSymbolClasses == null)
            additionalSymbolClasses = new ArrayList<FXGSymbolClass>();

        additionalSymbolClasses.add(symbolClass);
    }

    /**
     * @return the list of additional symbol classes to be included with this
     * symbol class
     */
    public List<FXGSymbolClass> getAdditionalSymbolClasses()
    {
        return additionalSymbolClasses;
    }

    /**
     * @return the qualified class name of the generated ActionScript class
     */
    public String getQualifiedClassName()
    {
        if (packageName != null && packageName != DEFAULT_PACKAGE)
            return packageName + PACKAGE_SEPARATOR + className;

        return className;
    }

    /**
     * @return the package name of the generated ActionScript class
     */
    public String getPackageName()
    {
        if (packageName == null)
            return DEFAULT_PACKAGE;

        return packageName;
    }

    /**
     * @param packageName - the package name of the generated ActionScript class
     */
    public void setPackageName(String value)
    {
        packageName = value;
    }

    /**
     * @return the class name of the generated ActionScript class
     */
    public String getClassName()
    {
        return className;
    }

    /**
     * @param value - the class name of the generated ActionScript class
     */
    public void setClassName(String value)
    {
        className = value;
    }

    /**
     * @return - the source code of the generated ActionScript class
     */
    public String getGeneratedSource()
    {
        return generatedSource;
    }

    /**
     * @param value - the source code of the generated ActionScript class
     */
    public void setGeneratedSource(String value)
    {
        this.generatedSource = value;
    }

    /**
     * @return the SWF symbol
     */
    public DefineTag getSymbol()
    {
        return symbol;
    }

    /**
     * @param value - the SWF symbol
     */
    public void setSymbol(DefineTag value)
    {
        this.symbol = value;
    }

}
