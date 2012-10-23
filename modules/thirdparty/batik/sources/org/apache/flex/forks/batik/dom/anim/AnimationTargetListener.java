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
package org.apache.flex.forks.batik.dom.anim;

/**
 * A listener class for animation targets.  This will be for the animation
 * engine to be notified of updates to dependencies such as font size
 * changes and viewport sizes.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimationTargetListener.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface AnimationTargetListener {

    /**
     * Invoked to indicate that base value of the specified attribute
     * or property has changed.
     */
    void baseValueChanged(AnimationTarget t, String ns, String ln,
                          boolean isCSS);
}
