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
package org.apache.flex.forks.batik.swing.svg;

/**
 * This interface represents a listener to the GVTTreeBuilderEvent events.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: GVTTreeBuilderListener.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface GVTTreeBuilderListener {

    /**
     * Called when a build started.
     */
    void gvtBuildStarted(GVTTreeBuilderEvent e);

    /**
     * Called when a build was completed.
     */
    void gvtBuildCompleted(GVTTreeBuilderEvent e);

    /**
     * Called when a build was cancelled.
     */
    void gvtBuildCancelled(GVTTreeBuilderEvent e);

    /**
     * Called when a build failed.
     */
    void gvtBuildFailed(GVTTreeBuilderEvent e);

}
