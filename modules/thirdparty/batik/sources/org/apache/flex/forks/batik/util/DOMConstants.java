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
 * String constants used by the DOM classes.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: DOMConstants.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface DOMConstants {

    // DOMConfiguration parameter strings
    String DOM_CANONICAL_FORM_PARAM = "canonical-form";
    String DOM_CDATA_SECTIONS_PARAM = "cdata-sections";
    String DOM_CHECK_CHARACTER_NORMALIZATION_PARAM = "check-character-normalization";
    String DOM_COMMENTS_PARAM = "comments";
    String DOM_DATATYPE_NORMALIZATION_PARAM = "datatype-normalization";
    String DOM_ELEMENT_CONTENT_WHITESPACE_PARAM = "element-content-whitespace";
    String DOM_ENTITIES_PARAM = "entities";
    String DOM_ERROR_HANDLER_PARAM = "error-handler";
    String DOM_INFOSET_PARAM = "infoset";
    String DOM_NAMESPACES_PARAM = "namespaces";
    String DOM_NAMESPACE_DECLARATIONS_PARAM = "namespace-declarations";
    String DOM_NORMALIZE_CHARACTERS_PARAM = "normalize-characters";
    String DOM_SPLIT_CDATA_SECTIONS_PARAM = "split-cdata-sections";
    String DOM_VALIDATE_PARAM = "validate";
    String DOM_VALIDATE_IF_SCHEMA_PARAM = "validate-if-schema";
    String DOM_WELL_FORMED_PARAM = "well-formed";

    // Document.normalizeDocument error codes
    String DOM_CDATA_SECTIONS_SPLITTED_ERROR = "cdata-sections-splitted";
    String DOM_INVALID_CHARACTER_ERROR = "wf-invalid-character";
    String DOM_INVALID_CHARACTER_IN_NODE_NAME_ERROR = "wf-invalid-character-in-node-name";
}
