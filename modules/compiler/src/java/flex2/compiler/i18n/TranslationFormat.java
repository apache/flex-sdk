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

package flex2.compiler.i18n;

import flex2.compiler.common.CompilerConfiguration;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.Source;
import flex2.compiler.SymbolTable;

/**
 * Defines the API to be used by classes, which participate in I18N
 * translation.
 *
 * @author Brian Deitte
 */
public interface TranslationFormat
{
    /**
     * Let the compiler know whether the given mimeType is supported by this class
     */
    public boolean isSupported(String mimeType);

    /**
     * Returns the mimeTypes supported by this class.  The mimeType has to be known to the compiler.
     * Known types include MimeMappings.AS, MimeMappings.PROPERTIES, MimeMappings.MXML
     */
    public String[] getSupportedMimeTypes();

    /**
     * Process the given file and return a Set of Map.Entry values with String keys and values.
     */
    public TranslationInfo getTranslationSet(CompilerConfiguration configuration,
            SymbolTable symbolTable, Source source, String locale, StandardDefs standardDefs)
    	throws TranslationException;
}
