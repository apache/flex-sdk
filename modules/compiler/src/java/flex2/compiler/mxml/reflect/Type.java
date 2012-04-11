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

/**
 * The facade for the MXML compiler to AS3 type.  More API methods can
 * be added but they must be meaningful to MXML parsing, semantic
 * analysis and code generation.
 *
 * @author Clement Wong
 */
public interface Type
{
	/**
	 * Type name. AS3-compatible fully-qualified class name.
	 */
	String getName();

	/**
	 * return type table
	 */
	TypeTable getTypeTable();

    /**
     * Element type
     */
    Type getElementType();

	/**
	 * Super type
	 */
	Type getSuperType();

	/**
	 * Interfaces
	 */
	Type[] getInterfaces();

	/**
	 * Property = variable | [getter]/[setter]
	 * Searches all standard namespaces: public, protected, internal, private
	 */
	Property getProperty(String name);

	/**
	 * Property = variable | [getter]/[setter]
	 * Searches specified namespace
	 */
	Property getProperty(String namespace, String name);

	/**
	 * Property = variable | [getter]/[setter]
	 * Searches specified namespaces
	 */
	Property getProperty(String[] namespaces, String name);

	/**
	 *
	 */
	public boolean hasStaticMember(String name);

	/**
	 * [Event]
	 */
	Event getEvent(String name);

	/**
	 * [Effect]
	 */
	Effect getEffect(String name);

	/**
	 * [Style]
	 */
	Style getStyle(String name);

    /**
     * [Style(theme="...")]
     */
    String getStyleThemes(String name);

    /**
     * [Frame(loaderClass=...)]
     * Might support other Frame stuff in the future, requiring some refactoring.
     */
    public String getLoaderClass();

	/**
	 * [Obsolete]
	 */
	boolean hasObsolete(String name);

	/**
	 * [DefaultProperty]
	 * Note: returns name as given in metadata - may or may not correctly specify a public property 
	 */
	Property getDefaultProperty();

	/**
	 * [MaxChildren]
	 */
	int getMaxChildren();

	/**
	 * Dynamic type
	 */
	boolean hasDynamic();

    /**
     * Tests whether the type declares the specified metadata.
     */
    boolean hasMetadata(String name, boolean inherited);

	/**
	 * Return true if this type is assignable to 'baseType'.
	 */
	boolean isAssignableTo(Type baseType);

	/**
	 * Return true if this type is assignable to 'baseName'.
	 */
	boolean isAssignableTo(String baseName);

    /**
     * Return true if the type has excluded this styles.
     */
    boolean isExcludedStyle(String name);

	/**
	 * Return true if this type is a subclass of 'baseType'.
	 */
	boolean isSubclassOf(Type baseType);

	/**
	 * Return true if this type is a subclass of 'baseName'.
	 */
	boolean isSubclassOf(String baseName);
}
