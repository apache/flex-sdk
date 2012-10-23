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
package org.apache.flex.forks.batik.bridge;

/**
 * This interface represents a listener to the UpdateManagerEvent events.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: UpdateManagerListener.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface UpdateManagerListener {

    /**
     * Called when the manager was started.
     */
    void managerStarted(UpdateManagerEvent e);

    /**
     * Called when the manager was suspended.
     */
    void managerSuspended(UpdateManagerEvent e);

    /**
     * Called when the manager was resumed.
     */
    void managerResumed(UpdateManagerEvent e);

    /**
     * Called when the manager was stopped.
     */
    void managerStopped(UpdateManagerEvent e);

    /**
     * Called when an update started.
     */
    void updateStarted(UpdateManagerEvent e);

    /**
     * Called when an update was completed.
     */
    void updateCompleted(UpdateManagerEvent e);

    /**
     * Called when an update failed.
     */
    void updateFailed(UpdateManagerEvent e);

}
