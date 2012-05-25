/*

   Copyright 2000-2001,2003  The Apache Software Foundation 

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
 * Defines a viewport for a <tt>UserAgent</tt>.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: UserAgentViewport.java,v 1.5 2004/08/18 07:12:37 vhardy Exp $
 */
public class UserAgentViewport implements Viewport {

    private UserAgent userAgent;

    /**
     * Constructs a new viewport for the specified user agent.
     * @param userAgent the user agent that defines the viewport
     */
    public UserAgentViewport(UserAgent userAgent) {
        this.userAgent = userAgent;
    }

    /**
     * Returns the width of this viewport.
     */
    public float getWidth() {
        return (float) userAgent.getViewportSize().getWidth();
    }

    /**
     * Returns the height of this viewport.
     */
    public float getHeight() {
        return (float) userAgent.getViewportSize().getHeight();
    }
}
