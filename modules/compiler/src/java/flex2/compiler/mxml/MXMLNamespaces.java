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

package flex2.compiler.mxml;

/**
 * A collection of language namespaces used in various versions of MXML.
 * <p>
 * Note that prior to Flex 4, language and component namespaces overlapped.
 * </p>
 * @author Pete Farland
 */
public interface MXMLNamespaces
{
    public static final String FXG_2008_NAMESPACE = "http://ns.adobe.com/fxg/2008";

    public static final String MXML_1_NAMESPACE = "http://www.macromedia.com/2003/mxml";
    public static final String MXML_2_NAMESPACE = "http://www.macromedia.com/2005/mxml";
    public static final String MXML_2006_NAMESPACE = "http://www.adobe.com/2006/mxml";
    public static final String MXML_2009_NAMESPACE = "http://ns.adobe.com/mxml/2009";

    public static final String SPARK_NAMESPACE = "library://ns.adobe.com/flex/spark";
    public static final String MX_NAMESPACE = "library://ns.adobe.com/flex/mx";
}
