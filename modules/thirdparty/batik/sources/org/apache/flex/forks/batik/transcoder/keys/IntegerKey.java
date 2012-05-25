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
package org.apache.flex.forks.batik.transcoder.keys;

import org.apache.flex.forks.batik.transcoder.TranscodingHints;

/**
 * A transcoding Key represented as an int.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: IntegerKey.java,v 1.3 2004/08/18 07:15:44 vhardy Exp $
 */
public class IntegerKey extends TranscodingHints.Key {

    public boolean isCompatibleValue(Object v) {
        return (v instanceof Integer);
    }
}
