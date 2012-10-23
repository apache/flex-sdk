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

import java.util.Iterator;
import java.util.NoSuchElementException;

/**
 * This class represents an object which queues Runnable objects for
 * invocation in a single thread.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: RunnableQueue.java 501495 2007-01-30 18:00:36Z dvholten $
 */
public class RunnableQueue implements Runnable {

    /**
     * Type-safe enumeration of queue states.
     */
    public static final class RunnableQueueState {

        private final String value;

        private RunnableQueueState(String value) {
            this.value = value; }

        public String getValue() { return value; }

        public String toString() {
            return "[RunnableQueueState: " + value + ']'; }
    }

    /**
     * The queue is in the process of running tasks.
     */
    public static final RunnableQueueState RUNNING
        = new RunnableQueueState("Running");

    /**
     * The queue may still be running tasks but as soon as possible
     * will go to SUSPENDED state.
     */
    public static final RunnableQueueState SUSPENDING
        = new RunnableQueueState("Suspending");

    /**
     * The queue is no longer running any tasks and will not
     * run any tasks until resumeExecution is called.
     */
    public static final RunnableQueueState SUSPENDED
        = new RunnableQueueState("Suspended");

    /**
     * The Suspension state of this thread.
     */
    protected volatile RunnableQueueState state;

    /**
     * Object to synchronize/wait/notify for suspension
     * issues.
     */
    protected final Object stateLock = new Object();

    /**
     * Used to indicate if the queue was resumed while
     * still running, so a 'resumed' event can be sent.
     */
    protected boolean wasResumed;

    /**
     * The Runnable objects list, also used as synchronization point
     * for pushing/poping runables.
     */
    private final DoublyLinkedList list = new DoublyLinkedList();

    /**
     * Count of preempt entries in queue, so preempt entries
     * can be kept properly ordered.
     */
    protected int preemptCount;

    /**
     * The object which handle run events.
     */
    protected RunHandler runHandler;

    /**
     * The current thread.
     */
    protected volatile HaltingThread runnableQueueThread;

    /**
     * The {@link IdleRunnable} to run if the queue is empty.
     */
    private IdleRunnable idleRunnable;

    /**
     * The time (in milliseconds) that the idle runnable should be run next.
     */
    private long idleRunnableWaitTime;

    /**
     * Creates a new RunnableQueue started in a new thread.
     * @return a RunnableQueue which is guaranteed to have entered its
     *         <tt>run()</tt> method.
     */
    public static RunnableQueue createRunnableQueue() {
        RunnableQueue result = new RunnableQueue();
        synchronized (result) {       // todo ?? sync on local object has no meaning ??
            HaltingThread ht = new HaltingThread
                (result, "RunnableQueue-" + threadCount++);
            ht.setDaemon(true);
            ht.start();
            while (result.getThread() == null) {
                try {
                    result.wait();
                } catch (InterruptedException ie) {
                }
            }
        }
        return result;
    }

    private static volatile int threadCount;

    /**
     * Runs this queue.
     */
    public void run() {
        synchronized (this) {
            runnableQueueThread = (HaltingThread)Thread.currentThread();
            // Wake the create method so it knows we are in
            // our run and ready to go.
            notify();
        }

        Link l;
        Runnable rable;
        try {
            while (!HaltingThread.hasBeenHalted()) {
                boolean callSuspended = false;
                boolean callResumed   = false;
                // Mutex for suspension work.
                synchronized (stateLock) {
                    if (state != RUNNING) {
                        state = SUSPENDED;
                        callSuspended = true;
                    }
                }
                if (callSuspended)
                    executionSuspended();

                synchronized (stateLock) {
                    while (state != RUNNING) {
                        state = SUSPENDED;

                        // notify suspendExecution in case it is
                        // waiting til we shut down.
                        stateLock.notifyAll();

                        // Wait until resumeExecution called.
                        try {
                            stateLock.wait();
                        } catch(InterruptedException ie) { }
                    }

                    if (wasResumed) {
                        wasResumed = false;
                        callResumed = true;
                    }
                }

                if (callResumed)
                    executionResumed();

                // The following seriously stress tests the class
                // for stuff happening between the two sync blocks.
                //
                // try {
                //     Thread.sleep(1);
                // } catch (InterruptedException ie) { }

                synchronized (list) {
                    if (state == SUSPENDING)
                        continue;
                    l = (Link)list.pop();
                    if (preemptCount != 0) preemptCount--;
                    if (l == null) {
                        // No item to run, see if there is an idle runnable
                        // to run instead.
                        if (idleRunnable != null &&
                                (idleRunnableWaitTime = idleRunnable.getWaitTime())
                                    < System.currentTimeMillis()) {
                            rable = idleRunnable;
                        } else {
                            // Wait for a runnable.
                            try {
                                if (idleRunnable != null && idleRunnableWaitTime
                                        != Long.MAX_VALUE) {
                                    long t = idleRunnableWaitTime
                                        - System.currentTimeMillis();
                                    if (t > 0) {
                                        list.wait(t);
                                    }
                                } else {
                                    list.wait();
                                }
                            } catch (InterruptedException ie) {
                                // just loop again.
                            }
                            continue; // start loop over again...
                        }
                    } else {
                        rable = l.runnable;
                    }
                }

                runnableStart(rable);

                try {
                    rable.run();
                } catch (ThreadDeath td) {
                    // Let it kill us...
                    throw td;
                } catch (Throwable t) {
                    // Might be nice to notify someone directly.
                    // But this is more or less what Swing does.
                    t.printStackTrace();
                }
                // Notify something waiting on the runnable just completed,
                // if we just ran one from the queue.
                if (l != null) {
                    l.unlock();
                }
                runnableInvoked(rable);
            }
        } finally {
            synchronized (this) {
                runnableQueueThread = null;
            }
        }
    }

    /**
     * Returns the thread in which the RunnableQueue is currently running.
     * @return null if the RunnableQueue has not entered his
     *         <tt>run()</tt> method.
     */
    public HaltingThread getThread() {
        return runnableQueueThread;
    }

    /**
     * Schedules the given Runnable object for a later invocation, and
     * returns.
     * An exception is thrown if the RunnableQueue was not started.
     * @throws IllegalStateException if getThread() is null.
     */
    public void invokeLater(Runnable r) {
        if (runnableQueueThread == null) {
            throw new IllegalStateException
                ("RunnableQueue not started or has exited");
        }
        synchronized (list) {
            list.push(new Link(r));
            list.notify();
        }
    }

    /**
     * Waits until the given Runnable's <tt>run()</tt> has returned.
     * <em>Note: <tt>invokeAndWait()</tt> must not be called from the
     * current thread (for example from the <tt>run()</tt> method of the
     * argument).</em>
     * @throws IllegalStateException if getThread() is null or if the
     *         thread returned by getThread() is the current one.
     */
    public void invokeAndWait(Runnable r) throws InterruptedException {
        if (runnableQueueThread == null) {
            throw new IllegalStateException
                ("RunnableQueue not started or has exited");
        }
        if (runnableQueueThread == Thread.currentThread()) {
            throw new IllegalStateException
                ("Cannot be called from the RunnableQueue thread");
        }

        LockableLink l = new LockableLink(r);
        synchronized (list) {
            list.push(l);
            list.notify();
        }
        l.lock();
    }


    /**
     * Schedules the given Runnable object for a later invocation, and
     * returns. The given runnable preempts any runnable that is not
     * currently executing (ie the next runnable started will be the
     * one given).  An exception is thrown if the RunnableQueue was
     * not started.
     * @throws IllegalStateException if getThread() is  null.
     */
    public void preemptLater(Runnable r) {
        if (runnableQueueThread == null) {
            throw new IllegalStateException
                ("RunnableQueue not started or has exited");
        }
        synchronized (list) {
            list.add(preemptCount, new Link(r));
            preemptCount++;
            list.notify();
        }
    }

    /**
     * Waits until the given Runnable's <tt>run()</tt> has returned.
     * The given runnable preempts any runnable that is not currently
     * executing (ie the next runnable started will be the one given).
     * <em>Note: <tt>preemptAndWait()</tt> must not be called from the
     * current thread (for example from the <tt>run()</tt> method of the
     * argument).
     * @throws IllegalStateException if getThread() is null or if the
     *         thread returned by getThread() is the current one.
     */
    public void preemptAndWait(Runnable r) throws InterruptedException {
        if (runnableQueueThread == null) {
            throw new IllegalStateException
                ("RunnableQueue not started or has exited");
        }
        if (runnableQueueThread == Thread.currentThread()) {
            throw new IllegalStateException
                ("Cannot be called from the RunnableQueue thread");
        }

        LockableLink l = new LockableLink(r);
        synchronized (list) {
            list.add(preemptCount, l);
            preemptCount++;
            list.notify();
        }
        l.lock();
    }

    public RunnableQueueState getQueueState() {
        synchronized (stateLock) {
            return state;
        }
    }

    /**
     * Suspends the execution of this queue after the current runnable
     * completes.
     * @param waitTillSuspended if true this method will not return
     *        until the queue has suspended (no runnable in progress
     *        or about to be in progress). If resumeExecution is
     *        called while waiting will simply return (this really
     *        indicates a race condition in your code).  This may
     *        return before an associated RunHandler is notified.
     * @throws IllegalStateException if getThread() is null.
     */
    public void suspendExecution(boolean waitTillSuspended) {
        if (runnableQueueThread == null) {
            throw new IllegalStateException
                ("RunnableQueue not started or has exited");
        }
        // System.err.println("Suspend Called");
        synchronized (stateLock) {
            wasResumed = false;

            if (state == SUSPENDED) {
                // already suspended, notify stateLock so an event is
                // generated.
                stateLock.notifyAll();
                return;
            }

            if (state == RUNNING) {
                state = SUSPENDING;
                synchronized (list) {
                    // Wake up run thread if it is waiting for jobs,
                    // so we go into the suspended case (notifying
                    // run-handler etc...)
                    list.notify();
                }
            }

            if (waitTillSuspended) {
                while (state == SUSPENDING) {
                    try {
                        stateLock.wait();
                    } catch(InterruptedException ie) { }
                }
            }
        }
    }

    /**
     * Resumes the execution of this queue.
     * @throws IllegalStateException if getThread() is null.
     */
    public void resumeExecution() {
        // System.err.println("Resume Called");
        if (runnableQueueThread == null) {
            throw new IllegalStateException
                ("RunnableQueue not started or has exited");
        }

        synchronized (stateLock) {
            wasResumed = true;

            if (state != RUNNING) {
                state = RUNNING;
                stateLock.notifyAll(); // wake it up.
            }
        }
    }

    /**
     * Returns iterator lock to use to work with the iterator
     * returned by iterator().
     */
    public Object getIteratorLock() {
        return list;
    }

    /**
     * Returns an iterator over the runnables.
     */
    public Iterator iterator() {
        return new Iterator() {
                Link head = (Link)list.getHead();
                Link link;
                public boolean hasNext() {
                    if (head == null) {
                        return false;
                    }
                    if (link == null) {
                        return true;
                    }
                    return link != head;
                }
                public Object next() {
                    if (head == null || head == link) {
                        throw new NoSuchElementException();
                    }
                    if (link == null) {
                        link = (Link)head.getNext();
                        return head.runnable;
                    }
                    Object result = link.runnable;
                    link = (Link)link.getNext();
                    return result;
                }
                public void remove() {
                    throw new UnsupportedOperationException();
                }
            };
    }

    /**
     * Sets the RunHandler for this queue.
     */
    public synchronized void setRunHandler(RunHandler rh) {
        runHandler = rh;
    }

    /**
     * Returns the RunHandler or null.
     */
    public synchronized RunHandler getRunHandler() {
        return runHandler;
    }

    /**
     * Sets a Runnable to be run whenever the queue is empty.
     */
    public void setIdleRunnable(IdleRunnable r) {
        synchronized (list) {
            idleRunnable = r;
            idleRunnableWaitTime = 0;
            list.notify();
        }
    }

    /**
     * Called when execution is being suspended.
     * Currently just notifies runHandler
     */
    protected synchronized void executionSuspended() {
        // System.err.println("Suspend Sent");
        if (runHandler != null) {
            runHandler.executionSuspended(this);
        }
    }

    /**
     * Called when execution is being resumed.
     * Currently just notifies runHandler
     */
    protected synchronized void executionResumed() {
        // System.err.println("Resumed Sent");
        if (runHandler != null) {
            runHandler.executionResumed(this);
        }
    }

    /**
     * Called just prior to executing a Runnable.
     * Currently just notifies runHandler
     * @param rable The runnable that is about to start
     */
    protected synchronized void runnableStart(Runnable rable ) {
        if (runHandler != null) {
            runHandler.runnableStart(this, rable);
        }
    }

    /**
     * Called when a Runnable completes.
     * Currently just notifies runHandler
     * @param rable The runnable that just completed.
     */
    protected synchronized void runnableInvoked(Runnable rable ) {
        if (runHandler != null) {
            runHandler.runnableInvoked(this, rable);
        }
    }

    /**
     * A {@link Runnable} that can also inform the caller how long it should
     * be until it is run again.
     */
    public interface IdleRunnable extends Runnable {

        /**
         * Returns the system time that can be safely waited until before this
         * {@link Runnable} is run again.
         *
         * @return time to wait until, <code>0</code> if no waiting can
         *         be done, or {@link Long#MAX_VALUE} if the {@link Runnable}
         *         should not be run again at this time
         */
        long getWaitTime();
    }

    /**
     * This interface must be implemented by an object which wants to
     * be notified of run events.
     */
    public interface RunHandler {

        /**
         * Called just prior to invoking the runnable
         */
        void runnableStart(RunnableQueue rq, Runnable r);

        /**
         * Called when the given Runnable has just been invoked and
         * has returned.
         */
        void runnableInvoked(RunnableQueue rq, Runnable r);

        /**
         * Called when the execution of the queue has been suspended.
         */
        void executionSuspended(RunnableQueue rq);

        /**
         * Called when the execution of the queue has been resumed.
         */
        void executionResumed(RunnableQueue rq);
    }

    /**
     * This is an adapter class that implements the RunHandler interface.
     * It simply does nothing in response to the calls.
     */
    public static class RunHandlerAdapter implements RunHandler {

        /**
         * Called just prior to invoking the runnable
         */
        public void runnableStart(RunnableQueue rq, Runnable r) { }

        /**
         * Called when the given Runnable has just been invoked and
         * has returned.
         */
        public void runnableInvoked(RunnableQueue rq, Runnable r) { }

        /**
         * Called when the execution of the queue has been suspended.
         */
        public void executionSuspended(RunnableQueue rq) { }

        /**
         * Called when the execution of the queue has been resumed.
         */
        public void executionResumed(RunnableQueue rq) { }
    }

    /**
     * To store a Runnable.
     */
    protected static class Link extends DoublyLinkedList.Node {

        /**
         * The Runnable.
         */
        private final Runnable runnable;

        /**
         * Creates a new link.
         */
        public Link(Runnable r) {
            runnable = r;
        }

        /**
         * unlock link and notify locker.
         * Basic implementation does nothing.
         */
        public void unlock() { return; }
    }

    /**
     * To store a Runnable with an object waiting for him to be executed.
     */
    protected static class LockableLink extends Link {

        /**
         * Whether this link is actually locked.
         */
        private volatile boolean locked;

        /**
         * Creates a new link.
         */
        public LockableLink(Runnable r) {
            super(r);
        }

        /**
         * Whether the link is actually locked.
         */
        public boolean isLocked() {
            return locked;
        }

        /**
         * Locks this link.
         */
        public synchronized void lock() throws InterruptedException {
            locked = true;
            notify();
            wait();
        }

        /**
         * unlocks this link.
         */
        public synchronized void unlock() {
            while (!locked) {
                try {
                    wait(); // Wait until lock is called...
                } catch (InterruptedException ie) {
                    // Loop again...
                }
            }
            locked = false;
            // Wake the locking thread...
            notify();
        }
    }
}
