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

package flex2.compiler.abc;

import flex2.compiler.util.QName;
import macromedia.asc.util.Namespaces;

import java.util.Iterator;
import java.util.List;

/**
 * This interface defines the TypeTable API for a class.
 *
 * @author Clement Wong
 * @see flex2.compiler.as3.reflect.TypeTable
 */
public interface AbcClass
{
	Variable getVariable(String[] namespaces, String name, boolean inherited);
    Variable getVariable(Namespaces namespaces, String name, boolean inherited);

	Method getMethod(String[] namespaces, String name, boolean inherited);
    Method getMethod(Namespaces namespaces, String name, boolean inherited);

	Method getGetter(String[] namespaces, String name, boolean inherited);
    Method getGetter(Namespaces namespaces, String name, boolean inherited);

	Method getSetter(String[] namespaces, String name, boolean inherited);
    Method getSetter(Namespaces namespaces, String name, boolean inherited);

	String getName();

	String getSuperTypeName();

	String[] getInterfaceNames();

    /**
	 * all metadata [name] defined on this class. superclasses are scanned if (inherited)
	 */
	List<MetaData> getMetaData(String name, boolean inherited);

	/**
	 * Super classes are scanned.
	 */
    boolean implementsInterface(String interfaceName);

    boolean isSubclassOf(String baseName);

	boolean isInterface();

    boolean isDynamic();

	// C: bad design. will revisit when i get a chance...
	void setTypeTable(Object obj);
    
    Iterator<Variable> getVarIterator();
    Iterator<Method> getMethodIterator();
    Iterator<Method> getGetterIterator();
    Iterator<Method> getSetterIterator();

    void freeze();

    public boolean isPublic();
}

