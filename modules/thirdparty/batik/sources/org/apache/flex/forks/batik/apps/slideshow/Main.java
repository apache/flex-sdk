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
package org.apache.flex.forks.batik.apps.slideshow;

import java.awt.Color;
import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.Toolkit;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;
import java.util.ArrayList;

import javax.swing.JComponent;
import javax.swing.JWindow;

import org.apache.flex.forks.batik.bridge.BridgeContext;
import org.apache.flex.forks.batik.bridge.DocumentLoader;
import org.apache.flex.forks.batik.bridge.GVTBuilder;
import org.apache.flex.forks.batik.bridge.UserAgent;
import org.apache.flex.forks.batik.bridge.UserAgentAdapter;
import org.apache.flex.forks.batik.bridge.ViewBox;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.renderer.StaticRenderer;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.svg.SVGDocument;

/**
 *
 * @version $Id: Main.java 504822 2007-02-08 08:40:18Z dvholten $
 */
public class Main extends JComponent {

    StaticRenderer renderer;
    UserAgent      userAgent;
    DocumentLoader loader;
    BridgeContext  ctx;

    BufferedImage image;
    BufferedImage display;
    File [] files;

    static int duration = 3000;
    static int frameDelay = duration+7000;

    volatile boolean done = false;

    public Main(File []files, Dimension size) {
        setBackground(Color.black);
        this.files = files;
        UserAgentAdapter ua = new UserAgentAdapter();
        renderer  = new StaticRenderer();
        userAgent = ua;
        loader    = new DocumentLoader(userAgent);
        ctx       = new BridgeContext(userAgent, loader);
        ua.setBridgeContext(ctx);

        if (size == null) {
            size = Toolkit.getDefaultToolkit().getScreenSize();
        }

        setPreferredSize(size);
        setDoubleBuffered(false);
        addMouseListener(new MouseAdapter() {
                public void mouseClicked(MouseEvent me) {
                    if (done)
                        System.exit(0);
                    else
                        togglePause();
                }
            });

        size.width += 2;
        size.height += 2;
        display = new BufferedImage(size.width, size.height,
                                    BufferedImage.TYPE_INT_BGR);

        Thread t = new RenderThread();
        t.start();

        JWindow w = new JWindow();
        w.setBackground(Color.black);
        w.getContentPane().setBackground(Color.black);
        w.getContentPane().add(this);
        w.pack();
        w.setLocation(new Point(-1, -1));
        w.setVisible(true);
    }

    class RenderThread extends Thread {
        RenderThread(){
            super("RenderThread");
            setDaemon( true );
        }

        public void run() {
            renderer.setDoubleBuffered(true);
            for (int i=0; i<files.length; i++) {
                GraphicsNode   gvtRoot = null;
                GVTBuilder builder = new GVTBuilder();

                try {
                    String fileName = files[ i ].toURL().toString();
                    System.out.println("Reading: " + fileName );
                    Document svgDoc = loader.loadDocument( fileName );
                    System.out.println("Building: " + fileName );
                    gvtRoot = builder.build(ctx, svgDoc);
                    System.out.println("Rendering: " + fileName );
                    renderer.setTree(gvtRoot);

                    Element elt = ((SVGDocument)svgDoc).getRootElement();
                    renderer.setTransform
                        (ViewBox.getViewTransform
                         (null, elt, display.getWidth(), display.getHeight(),
                          ctx));

                    renderer.updateOffScreen(display.getWidth(),
                                             display.getHeight());

                    Rectangle r = new Rectangle(0, 0,
                                                display.getWidth(),
                                                display.getHeight());
                    renderer.repaint(r);
                    System.out.println("Painting: " + fileName );
                    image = renderer.getOffScreen();
                    setTransition(image);

                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
            if (transitionThread != null) {
                try {
                    transitionThread.join();
                } catch (InterruptedException ie) { }
                done = true;
                setCursor(new Cursor(Cursor.WAIT_CURSOR));
            }

        }
    }

    volatile Thread transitionThread = null;

    public void setTransition(BufferedImage newImg) {
        synchronized (this) {
            while (transitionThread != null) {
                try {
                    wait();
                } catch (InterruptedException ie) { }
            }
            transitionThread = new TransitionThread(newImg);
            transitionThread.start();
        }
    }


    long   startLastTransition=0;

    volatile boolean paused = false;

    public void togglePause() {
        synchronized(this) {
            paused = !paused;
            Cursor c;
            if (paused) {
                c = new Cursor(Cursor.WAIT_CURSOR);
            } else {
                c = new Cursor(Cursor.DEFAULT_CURSOR);
                if (transitionThread != null) {
                    synchronized (transitionThread) {
                        transitionThread.notifyAll();
                    }
                }
            }
            setCursor(c);
        }
    }

    class TransitionThread extends Thread {
        BufferedImage src;
        int blockw = 75;
        int blockh = 75;

        public TransitionThread(BufferedImage bi) {
            super( "TransitionThread");
            setDaemon( true );
            src = bi;
        }

        public void run() {
            int xblocks = (display.getWidth()+blockw-1)/blockw;
            int yblocks = (display.getHeight()+blockh-1)/blockh;
            int nblocks = xblocks*yblocks;

            int tblock = duration/nblocks;

            Point [] rects = new Point[nblocks];
            for (int y=0; y<yblocks; y++)
                for (int x=0; x<xblocks; x++)
                    rects[y*xblocks+x] = new Point(x, y);

            Graphics2D g2d = display.createGraphics();
            g2d.setColor( Color.black );

            long currTrans = System.currentTimeMillis();
            while ((currTrans-startLastTransition) < frameDelay) {
                try {
                    long stime = frameDelay-(currTrans-startLastTransition);
                    if (stime > 500) {
                        System.gc();
                        currTrans = System.currentTimeMillis();
                        stime = frameDelay-(currTrans-startLastTransition);
                    }
                    if (stime > 0) sleep(stime);
                } catch (InterruptedException ie) { }
                currTrans = System.currentTimeMillis();
            }

            synchronized(this) {
                while (paused) {
                    try {
                        wait();
                    } catch (InterruptedException ie) { }
                }
            }

            long last = startLastTransition = System.currentTimeMillis();

            for (int i=0; i<rects.length; i++) {
                int idx = (int)(Math.random()*(rects.length-i));
                Point pt = rects[idx];
                System.arraycopy( rects, idx + 1, rects, idx + 1 - 1, rects.length - i - idx -1 );  // +1??
                int x=pt.x*blockw, y=pt.y*blockh;
                int w=blockw, h = blockh;
                if (x+w > src.getWidth())  w = src.getWidth()-x;
                if (y+h > src.getHeight()) h = src.getHeight()-y;

                synchronized (display) {
                    g2d.fillRect(x, y, w, h);
                    BufferedImage sub;

                    sub = src.getSubimage(x, y, w, h);
                    g2d.drawImage(sub, null, x, y);
                }

                repaint(x, y, w, h);
                long current = System.currentTimeMillis();
                try {
                    long dt = current-last;
                    if (dt < tblock)
                        sleep(tblock-dt);
                } catch (InterruptedException ie) { }
                last = current;
            }

            synchronized (Main.this) {
                transitionThread = null;
                Main.this.notifyAll();
            }
        }

    }

    public void paint(Graphics g) {
        Graphics2D g2d = (Graphics2D)g;
        if (display == null) return;
        // System.out.println("Drawing Image: " + display);
        g2d.drawImage(display, null, 0, 0);
    }

    public static void readFileList(String file, List fileVec) {
        BufferedReader br;
        try {
            br = new BufferedReader(new FileReader(file));
        } catch(FileNotFoundException fnfe) {
            System.err.println("Unable to open file-list: " + file);
            return;
        }
        try {
            URL flURL = new File(file).toURL();
            String line;
            while ((line = br.readLine()) != null) {
                String str = line;
                int idx = str.indexOf('#');
                if (idx != -1)
                    str = str.substring(0, idx);
                str = str.trim();
                if (str.length() == 0)
                    continue;
                try {
                    URL imgURL = new URL(flURL, str);
                    fileVec.add(imgURL.getFile());
                } catch (MalformedURLException mue) {
                    System.err.println("Can't make sense of line:\n  " + line);
                }
            }
        } catch (IOException ioe) {
            System.err.println("Error while reading file-list: " + file);
        } finally {
            try { br.close(); } catch (IOException ioe) { }
        }
    }

    public static void main(String []args) {

        List fileVec = new ArrayList();

        Dimension d = null;

        if (args.length == 0) {
            showUsage();
            return;
        }

        for (int i=0; i<args.length; i++) {
            if ((args[i].equals("-h")) ||
                (args[i].equals("-help")) ||
                (args[i].equals("--help"))){
                showUsage();
                return;
            } else if (args[i].equals("--")) {
                i++;
                while(i < args.length) {
                    fileVec.add(args[i++]);
                }
                break;
            } else if ((args[i].equals("-fl"))||
                     (args[i].equals("--file-list"))) {
                if (i+1 == args.length) {
                    System.err.println
                        ("Must provide name of file list file after " +
                         args[i]);
                    break;
                }
                readFileList(args[i+1], fileVec);
                i++;
            } else if ((args[i].equals("-ft"))||
                       (args[i].equals("--frame-time"))) {
                if (i+1 == args.length) {
                    System.err.println
                        ("Must provide time in millis after " + args[i]);
                    break;
                }
                try {
                    frameDelay = Integer.decode(args[i+1]).intValue();
                    i++;
                } catch (NumberFormatException nfe) {
                    System.err.println
                        ("Can't parse frame time: " + args[i+1]);
                }
            } else if ((args[i].equals("-tt"))||
                       (args[i].equals("--transition-time"))) {
                if (i+1 == args.length) {
                    System.err.println
                        ("Must provide time in millis after " + args[i]);
                    break;
                }
                try {
                    duration = Integer.decode(args[i+1]).intValue();
                    i++;
                } catch (NumberFormatException nfe) {
                    System.err.println
                        ("Can't parse transition time: " + args[i+1]);
                }
            } else if ((args[i].equals("-ws"))||
                       (args[i].equals("--window-size"))) {

                if (i+1 == args.length) {
                    System.err.println
                        ("Must provide window size [w,h] after " + args[i]);
                    break;
                }
                try {
                    int idx = args[i+1].indexOf(',');
                    int w, h;
                    if (idx == -1)
                        w = h = Integer.decode(args[i+1]).intValue();
                    else {
                        String wStr = args[i+1].substring(0,idx);
                        String hStr = args[i+1].substring(idx+1);
                        w = Integer.decode(wStr).intValue();
                        h = Integer.decode(hStr).intValue();
                    }
                    d = new Dimension(w, h);
                    i++;
                } catch (NumberFormatException nfe) {
                    System.err.println
                        ("Can't parse window size: " + args[i+1]);
                }
            } else
                fileVec.add(args[i]);
        }

        File [] files = new File[fileVec.size()];


        for (int i=0; i<fileVec.size(); i++) {
            try {
                files[i] = new File((String)fileVec.get(i));
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }

        new Main(files, d);
    }

    public static void showUsage() {
        System.out.println
("Options:\n" +
 "                                 -- : Remaining args are file names\n" +
 "                         -fl <file>\n" +
 "                 --file-list <file> : file contains list of images to\n" +
 "                                      show one per line\n" +
 "             -ws <width>[,<height>]\n" +
 "    -window-size <width>[,<height>] : Set the size of slideshow window\n" +
 "                                      defaults to full screen\n" +
 "                          -ft <int>\n" +
 "                 --frame-time <int> : Amount of time in millisecs to\n" +
 "                                      show each frame.\n" +
 "                                      Includes transition time.\n" +
 "                          -tt <int>\n" +
 "            --transition-time <int> : Amount of time in millisecs to\n" +
 "                                      transition between frames.\n" +
 "                             <file> : SVG file to display");
    }

}
