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
package org.apache.flex.forks.batik.apps.svgbrowser;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.util.Locale;
import java.util.ResourceBundle;

import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.border.BevelBorder;

import org.apache.flex.forks.batik.util.resources.ResourceManager;

/**
 * This class represents a viewer status bar.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: StatusBar.java 592619 2007-11-07 05:47:24Z cam $
 */
public class StatusBar extends JPanel {

    /**
     * The gui resources file name
     */
    protected static final String RESOURCES =
        "org.apache.flex.forks.batik.apps.svgbrowser.resources.StatusBarMessages";

    /**
     * The resource bundle
     */
    protected static ResourceBundle bundle;

    /**
     * The resource manager
     */
    protected static ResourceManager rManager;

    static {
        bundle = ResourceBundle.getBundle(RESOURCES, Locale.getDefault());
        rManager = new ResourceManager(bundle);
    }

    /**
     * The x position/width label.
     */
    protected JLabel xPosition;

    /**
     * The y position/height label.
     */
    protected JLabel yPosition;

    /**
     * The zoom label.
     */
    protected JLabel zoom;

    /**
     * The message label
     */
    protected JLabel message;

    /**
     * The main message
     */
    protected String mainMessage;

    /**
     * The temporary message
     */
    protected String temporaryMessage;

    /**
     * The current display thread.
     */
    protected DisplayThread displayThread;

    /**
     * Creates a new status bar.
     */
    public StatusBar() {
        super(new BorderLayout(5, 5));

        JPanel p = new JPanel(new BorderLayout(0, 0));
        add("West", p);

        xPosition = new JLabel();
        BevelBorder bb;
        bb = new BevelBorder(BevelBorder.LOWERED,
                             getBackground().brighter().brighter(),
                             getBackground(),
                             getBackground().darker().darker(),
                             getBackground());
        xPosition.setBorder(bb);
        xPosition.setPreferredSize(new Dimension(110, 16));
        p.add("West", xPosition);

        yPosition = new JLabel();
        yPosition.setBorder(bb);
        yPosition.setPreferredSize(new Dimension(110, 16));
        p.add("Center", yPosition);

        zoom = new JLabel();
        zoom.setBorder(bb);
        zoom.setPreferredSize(new Dimension(70, 16));
        p.add("East", zoom);

        p = new JPanel(new BorderLayout(0, 0));
        message = new JLabel();
        message.setBorder(bb);
        p.add(message);
        add(p);
        setMainMessage(rManager.getString("Panel.default_message"));
    }

    /**
     * Sets the x position.
     */
    public void setXPosition(float x) {
        xPosition.setText("x: " + x);
    }

    /**
     * Sets the width.
     */
    public void setWidth(float w) {
        xPosition.setText(rManager.getString("Position.width_letters") +
                          " " + w);
    }

    /**
     * Sets the y position.
     */
    public void setYPosition(float y) {
        yPosition.setText("y: " + y);
    }

    /**
     * Sets the height.
     */
    public void setHeight(float h) {
        yPosition.setText(rManager.getString("Position.height_letters") +
                          " " + h);
    }

    /**
     * Sets the zoom factor.
     */
    public void setZoom(float f) {
        f = (f > 0) ? f : -f;
        if (f == 1) {
            zoom.setText("1:1");
        } else if (f >= 1) {
            String s = Float.toString(f);
            if (s.length() > 6) {
                s = s.substring(0, 6);
            }
            zoom.setText("1:" + s);
        } else {
            String s = Float.toString(1 / f);
            if (s.length() > 6) {
                s = s.substring(0, 6);
            }
            zoom.setText(s + ":1");
        }
    }

    /**
     * Sets a temporary message
     * @param s the message
     */
    public void setMessage(String s) {
        setPreferredSize(new Dimension(0, getPreferredSize().height));
        if (displayThread != null) {
            displayThread.finish();
        }
        temporaryMessage = s;
        Thread old = displayThread;
        displayThread = new DisplayThread(old);
        displayThread.start();
    }

    /**
     * Sets the main message
     * @param s the message
     */
    public void setMainMessage(String s) {
        mainMessage = s;
        message.setText(mainMessage = s);
        if (displayThread != null) {
            displayThread.finish();
            displayThread = null;
        }
        setPreferredSize(new Dimension(0, getPreferredSize().height));
    }

    /**
     * To display the main message
     */
    protected class DisplayThread extends Thread {
        static final long DEFAULT_DURATION = 5000;
        long duration;
        Thread toJoin;
        public DisplayThread() {
            this(DEFAULT_DURATION, null);
        }
        public DisplayThread(long duration) {
            this(duration, null);
        }
        public DisplayThread(Thread toJoin) {
            this(DEFAULT_DURATION, toJoin);
        }
        public DisplayThread(long duration, Thread toJoin) {
            this.duration = duration;
            this.toJoin   = toJoin;
            setPriority(Thread.MIN_PRIORITY);
        }

        public synchronized void finish() {
            this.duration = 0;
            this.notifyAll();
        }

        public void run() {
            synchronized (this) {
                if (toJoin != null) {
                    while (toJoin.isAlive()) {
                        try { toJoin.join(); }
                        catch (InterruptedException ie) { }
                    }
                    toJoin = null;
                }

                message.setText(temporaryMessage);

                long lTime = System.currentTimeMillis();

                while (duration > 0) {
                    try {
                        wait(duration);
                    } catch(InterruptedException e) { }
                    long cTime = System.currentTimeMillis();
                    duration -= (cTime-lTime);
                    lTime = cTime;
                }
                message.setText(mainMessage);
            }
        }
    }
}
