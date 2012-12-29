/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.util;

/**
 * Define XBL constants, such as tag names, attribute names and
 * namespace URI.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: XBLConstants.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface XBLConstants {

    /**
     * Namespace URI for XBL elements and events.
     */
    String XBL_NAMESPACE_URI = "http://www.w3.org/2004/xbl";

    // -- Event types --------------------------------------------------------

    String XBL_PREBIND_EVENT_TYPE = "prebind";
    String XBL_BOUND_EVENT_TYPE = "bound";
    String XBL_UNBINDING_EVENT_TYPE = "unbinding";

    // -- Event handler attributes -------------------------------------------

    String XBL_ONPREBIND_ATTRIBUTE = "onprebind";
    String XBL_ONBOUND_ATTRIBUTE = "onprebind";
    String XBL_ONUNBINDING_ATTRIBUTE = "onprebind";

    // -- XBL tags -----------------------------------------------------------

    String XBL_XBL_TAG = "xbl";
    String XBL_DEFINITION_TAG = "definition";
    String XBL_TEMPLATE_TAG = "template";
    String XBL_CONTENT_TAG = "content";
    String XBL_HANDLER_GROUP_TAG = "handlerGroup";
    String XBL_IMPORT_TAG = "import";
    String XBL_SHADOW_TREE_TAG = "shadowTree";

    // -- XBL attributes -----------------------------------------------------

    String XBL_BINDINGS_ATTRIBUTE = "bindings";
    String XBL_ELEMENT_ATTRIBUTE = "element";
    String XBL_INCLUDES_ATTRIBUTE = "includes";
    String XBL_REF_ATTRIBUTE = "ref";
}
