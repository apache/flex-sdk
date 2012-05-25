/*

   Copyright 2001,2004  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.bridge;

import java.util.Iterator;

import org.w3c.dom.Element;

/**
 * This is a Service interface for classes that want to extend the
 * functionality of the Bridge, to support new tags in the rendering tree.
 */
public interface BridgeExtension {

    /**
     * Return the priority of this Extension.  Extensions are
     * registered from lowest to highest priority.  So if for some
     * reason you need to come before/after another existing extension
     * make sure your priority is lower/higher than theirs.  
     */
    public float getPriority();

    /**
     * This should return the list of extensions implemented
     * by this BridgeExtension, these are added to the list of
     * requiredExtensions that the User Agent supports for purposes
     * of the 'switch' element in SVG.
     * @return An iterator containing strings one for each implemented
     *         extension.
     */
     public Iterator getImplementedExtensions();

    /**
     * This should return the individual or company name responsible
     * for the this implementation of the extension.
     */
    public String getAuthor();

    /**
     * This should return a contact address (usually an e-mail address).
     */
    public String getContactAddress();

    /**
     * This should return a URL where information can be obtained on
     * this extension.
     */
    public String getURL();

    /**
     * Human readable description of the extension.
     * Perhaps that should be a resource for internationalization?
     * (although I suppose it could be done internally)
     */
    public String getDescription();

    /**
     * This method should update the BridgeContext with support
     * for the tags in this extension.  In some rare cases it may
     * be necessary to replace existing tag handlers, although this
     * is discouraged.
     *
     * @param ctx The BridgeContext instance to be updated
     */
    public void registerTags(BridgeContext ctx);

    /**
     * Whether the presence of the specified element should cause
     * the document to be dynamic.  If this element isn't handled
     * by this BridgeExtension, just return false.
     *
     * @param e The element to check.
     */
    public boolean isDynamicElement(Element e);
}
