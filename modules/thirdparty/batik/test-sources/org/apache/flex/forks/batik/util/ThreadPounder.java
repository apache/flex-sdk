/*
 * Copyright 1999-2003,2005 The Apache Software Foundation.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.flex.forks.batik.util;

import java.util.ArrayList;
import java.util.List;
import java.util.Iterator;
import java.util.Collections;
import java.util.Random;

/**
 * The purpose of this class is to invoke a series of runnables as
 * closely to synchronously as possible.  It does this by starting 
 * a thread for each one, getting the threads into there run method,
 * then quickly running through (in random order) and notifying each
 * thread.
 */
public class ThreadPounder {
    List runnables;
    Object [] threads;
    Object lock = new Object();

    public ThreadPounder(List runnables)  
        throws InterruptedException {
        this(runnables, new Random(1234));
    }

    public ThreadPounder(List runnables, Random rand) 
        throws InterruptedException {
        this.runnables = new ArrayList(runnables);
        Collections.shuffle(this.runnables, rand);
        threads = new Object[this.runnables.size()];
        int i=0;
        Iterator iter= this.runnables.iterator();
        synchronized (lock) {
            while (iter.hasNext()) {
                Thread t = new SyncThread((Runnable)iter.next());
                t.start();
                lock.wait();
                threads[i] = t;
                i++;
            }
        }
    }

    public void start() {
        synchronized(this) {
            this.notifyAll();
        }

    }

    class SyncThread extends Thread {
        Runnable toRun;
        public long runTime;
        public SyncThread(Runnable toRun) {
            this.toRun = toRun;
        }

        public void run() {
            try {
                synchronized (ThreadPounder.this) {
                    synchronized (lock) {
                        // Let pounder know I'm ready to go
                        lock.notify();
                    }
                    // Wait for pounder to wake me up.
                    ThreadPounder.this.wait();
                }
                toRun.run();
            } catch (InterruptedException ie) {
            }
        }
    }

    public static void main(String [] str) { 
        List l = new ArrayList(20);
        for (int i=0; i<20; i++) {
            final int x = i;
            l.add(new Runnable() {
                    public void run() {
                        System.out.println("Thread " + x);
                    }
                });
        }

        try { 
            ThreadPounder tp = new ThreadPounder(l);
            System.out.println("Starting:" );
            tp.start();
            System.out.println("All Started:" );
        } catch (InterruptedException ie) {
            ie.printStackTrace();
        }
    }
}
