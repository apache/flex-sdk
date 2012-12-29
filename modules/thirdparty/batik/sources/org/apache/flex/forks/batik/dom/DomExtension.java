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
package org.apache.flex.forks.batik.dom;

/**
 * This is a Service interface for classes that want to extend the
 * functionality of the AbstractDocument, to support new tags in the
 * DOM tree.
 *
 * @author <a href="mailto:thomas.deweese@kodak.com">Thomas DeWeese</a>
 * @version $Id: DomExtension.java 478249 2006-11-22 17:29:37Z dvholten $
 */
public interface DomExtension {

    /**
     * Return the priority of this Extension.  Extensions are
     * registered from lowest to highest priority.  So if for some
     * reason you need to come before/after another existing extension
     * make sure your priority is lower/higher than theirs.
     */
    float getPriority();

    /**
     * This should return the individual or company name responsible
     * for the this implementation of the extension.
     */
    String getAuthor();

    /**
     * This should return a contact address (usually an e-mail address).
     */
    String getContactAddress();

    /**
     * This should return a URL where information can be obtained on
     * this extension.
     */
    String getURL();

    /**
     * Human readable description of the extension.
     * Perhaps that should be a resource for internationalization?
     * (although I suppose it could be done internally)
     */
    String getDescription();

    /**
     * This method should update the DOMImplementation with support
     * for the tags in this extension.  In some rare cases it may
     * be necessary to replace existing tag handlers, although this
     * is discouraged.
     *
     * This is called before the DOMImplementation starts.
     *
     * @param di The DOMImplementation instance to be updated
     */
    void registerTags(ExtensibleDOMImplementation di);
}
