/*

   Copyright 2000-2002  The Apache Software Foundation 

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

/**
 * A tagging interface that all bridges must implement. A bridge is
 * responsible on creating and maintaining an appropriate object
 * according to an Element.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: Bridge.java,v 1.8 2004/08/18 07:12:30 vhardy Exp $
 */
public interface Bridge {

    /**
     * Returns the namespace URI of the element this <tt>Bridge</tt> is
     * dedicated to.
     */
    String getNamespaceURI();

    /**
     * Returns the local name of the element this <tt>Bridge</tt> is dedicated
     * to.
     */
    String getLocalName();

    /**
     * Returns a new instance of this bridge.
     */
    Bridge getInstance();
}
