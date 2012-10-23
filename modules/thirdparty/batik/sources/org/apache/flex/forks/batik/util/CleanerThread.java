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
package org.apache.flex.forks.batik.util;

import java.lang.ref.Reference;
import java.lang.ref.ReferenceQueue;
import java.lang.ref.SoftReference;
import java.lang.ref.WeakReference;
import java.lang.ref.PhantomReference;

/**
 * One line Class Desc
 *
 * Complete Class Desc
 *
 * @author <a href="mailto:deweese@apache.org">l449433</a>
 * @version $Id: CleanerThread.java 591551 2007-11-03 04:52:47Z cam $
 */
public class CleanerThread extends Thread {

    static volatile ReferenceQueue queue = null;
    static CleanerThread  thread = null;

    public static ReferenceQueue getReferenceQueue() {

        if ( queue == null ) {
            synchronized (CleanerThread.class) {
                queue = new ReferenceQueue();
                thread = new CleanerThread();
            }
        }
        return queue;
    }

    /**
     * If objects registered with the reference queue associated with
     * this class implement this interface then the 'cleared' method
     * will be called when the reference is queued.
     */
    public static interface ReferenceCleared {
        /* Called when the reference is cleared */
        void cleared();
    }

    /**
     * A SoftReference subclass that automatically registers with
     * the cleaner ReferenceQueue.
     */
    public abstract static class SoftReferenceCleared extends SoftReference
      implements ReferenceCleared {
        public SoftReferenceCleared(Object o) {
            super (o, CleanerThread.getReferenceQueue());
        }
    }

    /**
     * A WeakReference subclass that automatically registers with
     * the cleaner ReferenceQueue.
     */
    public abstract static class WeakReferenceCleared extends WeakReference
      implements ReferenceCleared {
        public WeakReferenceCleared(Object o) {
            super (o, CleanerThread.getReferenceQueue());
        }
    }

    /**
     * A PhantomReference subclass that automatically registers with
     * the cleaner ReferenceQueue.
     */
    public abstract static class PhantomReferenceCleared
        extends PhantomReference
        implements ReferenceCleared {
        public PhantomReferenceCleared(Object o) {
            super (o, CleanerThread.getReferenceQueue());
        }
    }

    protected CleanerThread() {
        super("Batik CleanerThread");
        setDaemon(true);
        start();
    }

    public void run() {
        while(true) {
            try {
                Reference ref;
                try {
                    ref = queue.remove();
                    // System.err.println("Cleaned: " + ref);
                } catch (InterruptedException ie) {
                    continue;
                }

                if (ref instanceof ReferenceCleared) {
                    ReferenceCleared rc = (ReferenceCleared)ref;
                    rc.cleared();
                }
            } catch (ThreadDeath td) {
                throw td;
            } catch (Throwable t) {
                t.printStackTrace();
            }
        }
    }
}
