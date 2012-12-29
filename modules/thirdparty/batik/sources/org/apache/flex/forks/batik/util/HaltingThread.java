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

/**
 * This is a subclass of java.lang.Thread that includes a non-intrusive
 * 'halt' method.  The Halt method simply sets a boolean that can be
 * checked periodically during expensive processing.
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: HaltingThread.java 478169 2006-11-22 14:23:24Z dvholten $
 */
public class HaltingThread extends Thread {
    /**
     * Boolean indicating if this thread has ever been 'halted'.
     */
    protected boolean beenHalted = false;

    public HaltingThread() { }

    public HaltingThread(Runnable r) { super(r); }

    public HaltingThread(String name) { super(name); }

    public HaltingThread(Runnable r, String name) { super(r, name); }

    /**
     * returns true if someone has halted the thread.
     */
    public boolean isHalted() {
        synchronized (this) { return beenHalted; }
    }

    /**
     * Set's beenHalted to true.
     */
    public void halt() {
        synchronized (this) { beenHalted = true; }
    }

    /**
     * Set's beenHalted to false.
     */
    public void clearHalted() {
        synchronized (this) { beenHalted = false; }
    }

    /**
     * Calls 'halt' on <tt>Thread.currentThread()</tt> if it is an
     * instance of HaltingThread otherwise it does nothing.
     */
    public static void haltThread() {
        haltThread(Thread.currentThread());
    }

    /**
     * Calls 'halt' on <tt>t</tt> if it is an instance of
     * HaltingThread otherwise it does nothing.
     */
    public static void haltThread(Thread t) {
        if (t instanceof HaltingThread)
            ((HaltingThread)t).halt();
    }

    /**
     * Returns the result of calling hasBeenHalted on
     * <tt>Thread.currentThread()</tt>, if it is an instance of
     * HaltingThread otherwise it returns false.
     */
    public static boolean hasBeenHalted() {
        return hasBeenHalted(Thread.currentThread());
    }

    /**
     * Returns the result of calling hasBeenHalted on <tt>t</tt>,
     * if it is an instance of HaltingThread otherwise it returns false.
     */
    public static boolean hasBeenHalted(Thread t) {
        if (t instanceof HaltingThread)
            return ((HaltingThread)t).isHalted();
        return false;
    }


}
