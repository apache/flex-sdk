/*

   Copyright 2001,2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.svggen;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.GridLayout;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;

import javax.swing.JFrame;
import javax.swing.JPanel;

import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;

import org.apache.flex.forks.batik.dom.svg.SVGDOMImplementation;
import org.apache.flex.forks.batik.swing.JSVGCanvas;
import org.apache.flex.forks.batik.swing.svg.SVGDocumentLoaderAdapter;
import org.apache.flex.forks.batik.swing.svg.SVGDocumentLoaderEvent;
import org.apache.flex.forks.batik.util.SVGConstants;

/**
 * Simple component which displays, side by side, the drawing
 * created by a <tt>Painter</tt>, rendered in a 
 * <tt>JPainterComponent</tt> on the left, and in a 
 * <tt>JSVGCanvas</tt> on the right, where the SVG
 * displayed is the one created by the <tt>SVGGraphics2D</tt>
 *
 * @author <a href="mailto:vincent.hardy@sun.com">Vincent Hardy</a>
 * @version $Id: JPainterCompare.java,v 1.5 2004/08/18 07:16:45 vhardy Exp $
 */
public class JPainterCompare extends JPanel implements SVGConstants{
    /**
     * Canvas size for all tests
     */
    public static final Dimension CANVAS_SIZE
        = new Dimension(300, 400);

    public static String MESSAGES_USAGE 
        = "JPainterCompare.messages.usage";

    public static String MESSAGES_LOADING_CLASS
        = "JPainterCompare.messages.loading.class";

    public static String MESSAGES_LOADED_CLASS
        = "JPainterCompare.messages.loaded.class";

    public static String MESSAGES_INSTANCIATED_OBJECT
        = "JPainterCompare.messages.instanciated.object";

    public static String ERROR_COULD_NOT_LOAD_CLASS
        = "JPainterCompare.error.could.not.load.class";

    public static String ERROR_COULD_NOT_INSTANCIATE_OBJECT
        = "JPainterCompare.error.could.not.instanciate.object";

    public static String ERROR_CLASS_NOT_PAINTER
        = "JPainterCompare.error.class.not.painter";

    public static String ERROR_COULD_NOT_TRANSCODE_TO_SVG 
        = "JPainterCompare.error.could.not.transcode.to.svg";

    public static String ERROR_COULD_NOT_CONVERT_FILE_PATH_TO_URL
        = "JPainterCompare.error.could.not.convert.file.path.to.url";

    public static String ERROR_COULD_NOT_RENDER_GENERATED_SVG
        = "JPainterCompare.error.could.not.render.generated.svg";

    public static String CONFIG_TMP_FILE_PREFIX
        = "JPainterCompare.config.tmp.file.prefix";

    /**
     * Builds an <tt>SVGGraphics2D</tt> with a default
     * configuration.
     */
    protected SVGGraphics2D buildSVGGraphics2D() {
        DOMImplementation impl = SVGDOMImplementation.getDOMImplementation();
        String namespaceURI = SVGDOMImplementation.SVG_NAMESPACE_URI;
        Document domFactory = impl.createDocument(namespaceURI, SVG_SVG_TAG, null);

        // Create a default context from our Document instance
        SVGGeneratorContext ctx = SVGGeneratorContext.createDefault(domFactory);

        GenericImageHandler ihandler = new CachedImageHandlerBase64Encoder();
        ctx.setGenericImageHandler(ihandler);

        return new SVGGraphics2D(ctx, false);
    }

    static class LoaderListener extends SVGDocumentLoaderAdapter{
        public final String sem = "sem";
        public boolean success = false;
        public void documentLoadingFailed(SVGDocumentLoaderEvent e){
            synchronized(sem){
                sem.notifyAll();
            }
        }
        
        public void documentLoadingCompleted(SVGDocumentLoaderEvent e){
            success = true;
            synchronized(sem){
                sem.notifyAll();
            }
        }
    }

    /**
     * Constructor
     */
    public JPainterCompare(Painter painter){
        // First, create the AWT reference.
        JPainterComponent ref = new JPainterComponent(painter);

        // Now, generate the SVG from this Painter
        SVGGraphics2D g2d = buildSVGGraphics2D();

        g2d.setSVGCanvasSize(CANVAS_SIZE);

        //
        // Generate SVG content
        //
        File tmpFile = null;
        try{
            tmpFile = File.createTempFile(CONFIG_TMP_FILE_PREFIX,
                                          ".svg");
            
            OutputStreamWriter osw = new OutputStreamWriter(new FileOutputStream(tmpFile), "UTF-8");

            painter.paint(g2d);
            g2d.stream(osw);
            osw.flush();
        }catch(Exception e){
            e.printStackTrace();
            throw new IllegalArgumentException
                (Messages.formatMessage(ERROR_COULD_NOT_TRANSCODE_TO_SVG,
                                        new Object[]{e.getClass().getName()}));
        }
        
        //
        // Now, transcode SVG to a BufferedImage
        //
        JSVGCanvas svgCanvas = new JSVGCanvas();
        LoaderListener l = new LoaderListener();
        svgCanvas.addSVGDocumentLoaderListener(l);

        try{
            svgCanvas.setURI(tmpFile.toURL().toString());
            synchronized(l.sem){
                l.sem.wait();
            }
        }catch(Exception e){
            e.printStackTrace();
            new Error
                (Messages.formatMessage(ERROR_COULD_NOT_CONVERT_FILE_PATH_TO_URL,
                                        new Object[]{e.getMessage()}));
        }

        if(l.success){
            setLayout(new GridLayout(1,2));
            add(ref);
            add(svgCanvas);
        }

        else{
            throw new Error
                (Messages.formatMessage(ERROR_COULD_NOT_RENDER_GENERATED_SVG,null));
        }
    }

    public Dimension getPreferredSize(){
        return new Dimension(CANVAS_SIZE.width*2, CANVAS_SIZE.height);
    }

    /*
     * Debug application: shows the image creatd by a <tt>Painter</tt>
     * on the left and the image created by a <tt>JSVGComponent</tt>
     * from the SVG generated by <tt>SVGGraphics2D</tt> from the same
     * <tt>Painter</tt> on the right.
     *
     */
    public static void main(String args[]){
        if(args.length <= 0){
            System.out.println(Messages.formatMessage
                               (MESSAGES_USAGE, null));
            System.exit(0);
        }

        // Load class.
        String className = args[0];
        System.out.println
            (Messages.formatMessage(MESSAGES_LOADING_CLASS,
                                    new Object[]{className}));

        Class cl = null;

        try{
            cl = Class.forName(className);
            System.out.println
                (Messages.formatMessage(MESSAGES_LOADED_CLASS,
                                        new Object[]{className}));
        }catch(Exception e){
            System.out.println
                (Messages.formatMessage(ERROR_COULD_NOT_LOAD_CLASS,
                                        new Object[] {className,
                                                      e.getClass().getName() }));
            System.exit(0);
        }

        // Instanciate object
        Object o = null;

        try{
            o = cl.newInstance();
            System.out.println
                (Messages.formatMessage(MESSAGES_INSTANCIATED_OBJECT,
                                        null));
        }catch(Exception e){
            System.out.println
                (Messages.formatMessage(ERROR_COULD_NOT_INSTANCIATE_OBJECT,
                                        new Object[] {className,
                                                      e.getClass().getName()}));
            System.exit(0);
        }

        // Cast to Painter
        Painter p = null;

        try{
            p = (Painter)o;
        }catch(ClassCastException e){
            System.out.println
                (Messages.formatMessage(ERROR_CLASS_NOT_PAINTER,
                                        new Object[]{className}));
            System.exit(0);
        }

        // Build frame
        JFrame f = new JFrame();
        JPainterCompare c = new JPainterCompare(p);
        c.setBackground(Color.white);
        c.setPreferredSize(new Dimension(300, 400));
        f.getContentPane().add(c);
        f.getContentPane().setBackground(Color.white);
        f.pack();
        f.setVisible(true);
    }

}
