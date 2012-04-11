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
 * Defines the reflection API for a property or variable.
 *
 * @author Clement Wong
 */
public interface Property extends Assignable
{
	/**
	 * Property name
	 */
	String getName();

	/**
	 * Type.
	 * 
	 * If this is a getter, the returned value is the getter's return type.
	 * If this is a setter, the returned value is the type of the input argument of the setter.
	 */
	Type getType();

    /**
     * [InstanceType]
     *
     * @return null if the instance type metadata is not available or if the
     * instance type is not specified.
     */
    Type getInstanceType();

	/**
	 * Is this read only?
	 */
	boolean readOnly();

    /**
	 *
	 */
	boolean hasPublic();

    // metadata

	/**
	 * [Inspectable]
	 */
	Inspectable getInspectable();

	/**
	 * [CollapseWhiteSpace]
	 */
	boolean collapseWhiteSpace();

    /**
     * [RichTextContent]
     */
    boolean richTextContent();

	/**
	 * [Deprecated]
	 */
	Deprecated getDeprecated();

	/**
	 * [ChangeEvent]
	 */
	boolean hasChangeEvent(String name);


	/**
	 * [PercentProxy]
	 */
	String getPercentProxy();
}
