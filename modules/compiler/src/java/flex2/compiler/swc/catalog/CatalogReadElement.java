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

package flex2.compiler.swc.catalog;

/**
 * An element within catalog.xml.  This is used to provide context
 * when reading the catalog.xml (that is, we automatically know where
 * to parse next).  See CatalogReader for its usage
 */
public abstract class CatalogReadElement
{
    public abstract CatalogReadElement readElement(ReadContext context);

    public void endElement(ReadContext context)
    {
        // by default, don't do anything
    }
}
