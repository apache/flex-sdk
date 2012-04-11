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
 * Defines the reflection API of a property or variable, which can be
 * assigned a value.
 */
public interface Assignable extends Stateful
{
    /**
     * @return The name of the assignable field.
     */
    String getName();

    /**
     * @return The declared type of the assignable field.
     */
    Type getType();

    /**
     * @return The expected type of the assignable field. While typically
     * the same as getType(), this may be customized with metadata.
     */
    Type getLValueType();

    /**
     * [ArrayElementType] or Vector data type.
     *
     * @return null if the assignable field is of type Array and the array
     * element type metadata is not available or if the array element type is
     * not specified.
     */
    Type getElementType();
}
