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
package org.apache.flex.forks.batik.bridge;

/**
 * This class represents the exception thrown by the bridge when the
 * current thread was interrupted.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: InterruptedBridgeException.java,v 1.4 2004/08/18 07:12:32 vhardy Exp $
 */
public class InterruptedBridgeException extends RuntimeException {

    /**
     * Constructs a new InterruptedBridgeException.
     */
    public InterruptedBridgeException() { }
}
