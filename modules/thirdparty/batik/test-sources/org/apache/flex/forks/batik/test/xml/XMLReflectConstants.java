/*

   Copyright 2001  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.test.xml;

/**
 * Contains constants for elements and attributes used to
 * describe Java objects, constructor arguments and properties
 * in XML.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: XMLReflectConstants.java,v 1.3 2004/08/18 07:17:06 vhardy Exp $
 */
public interface XMLReflectConstants {
    /////////////////////////////////////////////////////////////////////////
    // Tags
    /////////////////////////////////////////////////////////////////////////
    String XR_ARG_TAG        = "arg";
    String XR_PROPERTY_TAG   = "property";

    /////////////////////////////////////////////////////////////////////////
    // XTS attributes
    /////////////////////////////////////////////////////////////////////////
    String XR_CLASS_ATTRIBUTE = "class";
    String XR_NAME_ATTRIBUTE  = "name";
    String XR_VALUE_ATTRIBUTE = "value";
}
