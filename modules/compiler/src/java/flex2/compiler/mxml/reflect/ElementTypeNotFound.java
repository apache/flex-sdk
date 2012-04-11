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

import flex2.compiler.util.CompilerMessage.CompilerError;

/**
 * Error reported when an element's type can't be resolved.
 */
public class ElementTypeNotFound extends CompilerError
{
    private static final long serialVersionUID = 2373851015809929644L;
    public String metadata;
    public String elementTypeName;

    public ElementTypeNotFound(String metadata, String elementTypeName)
    {
        this.metadata = metadata;
        this.elementTypeName = elementTypeName;
    }
}