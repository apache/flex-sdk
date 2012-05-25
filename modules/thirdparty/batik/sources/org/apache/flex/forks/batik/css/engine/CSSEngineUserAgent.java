/*

   Copyright 2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.css.engine;

/**
 * One line Class Desc
 *
 * Complete Class Desc
 *
 * @author <a href="mailto:deweese@apache.org">l449433</a>
 * @version $Id: CSSEngineUserAgent.java,v 1.3 2005/03/27 08:58:31 cam Exp $
 */
public interface CSSEngineUserAgent {
    
    /**
     * Displays an error resulting from the specified Exception.
     */
    void displayError(Exception ex);

    /**
     * Displays a message in the User Agent interface.
     */
    void displayMessage(String message);

};
