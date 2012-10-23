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

import java.awt.BasicStroke;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Frame;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Shape;
import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.awt.event.MouseEvent;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.geom.AffineTransform;
import java.awt.geom.Dimension2D;
import java.awt.geom.NoninvertibleTransformException;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.util.List;
import java.util.Locale;
import java.util.ResourceBundle;

import javax.swing.JDialog;
import javax.swing.event.MouseInputAdapter;

import org.apache.flex.forks.batik.bridge.ViewBox;
import org.apache.flex.forks.batik.gvt.CanvasGraphicsNode;
import org.apache.flex.forks.batik.gvt.CompositeGraphicsNode;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.swing.JSVGCanvas;
import org.apache.flex.forks.batik.swing.gvt.GVTTreeRendererAdapter;
import org.apache.flex.forks.batik.swing.gvt.GVTTreeRendererEvent;
import org.apache.flex.forks.batik.swing.gvt.JGVTComponent;
import org.apache.flex.forks.batik.swing.gvt.Overlay;
import org.apache.flex.forks.batik.swing.svg.SVGDocumentLoaderAdapter;
import org.apache.flex.forks.batik.swing.svg.SVGDocumentLoaderEvent;
import org.apache.flex.forks.batik.util.resources.ResourceManager;
import org.apache.flex.forks.batik.util.SVGConstants;

import org.w3c.dom.svg.SVGDocument;
import org.w3c.dom.svg.SVGSVGElement;

/**
 * This class represents a Dialog that displays a Thumbnail of the current SVG
 * document.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: ThumbnailDialog.java 592619 2007-11-07 05:47:24Z cam $
 */
public class ThumbnailDialog extends JDialog {

    /**
     * The resource file name
     */
    protected static final String RESOURCES =
        "org.apache.flex.forks.batik.apps.svgbrowser.resources.ThumbnailDialog";

    /**
     * The resource bundle
     */
    protected static ResourceBundle bundle;

    /**
     * The resource manager
     */
    protected static ResourceManager resources;

    static {
        bundle = ResourceBundle.getBundle(RESOURCES, Locale.getDefault());
        resources = new ResourceManager(bundle);
    }

    /** The canvas that owns the SVG document to display. */
    protected JSVGCanvas svgCanvas;

    /** The canvas that displays the thumbnail. */
    protected JGVTComponent svgThumbnailCanvas;

    /** A flag bit that indicates a document has been loaded. */
    protected boolean documentChanged;

    /** The overlay used to display the area of interest. */
    protected AreaOfInterestOverlay overlay;

    /** The overlay used to display the area of interest. */
    protected AreaOfInterestListener aoiListener;

    protected boolean interactionEnabled = true;

    /**
     * Constructs a new <tt>ThumbnailDialog</tt> for the specified canvas.
     *
     * @param owner the owner frame
     * @param svgCanvas the canvas that owns the SVG document to display
     */
    public ThumbnailDialog(Frame owner, JSVGCanvas svgCanvas) {
        super(owner, resources.getString("Dialog.title"));

        addWindowListener(new ThumbnailListener());

        // register listeners to maintain consistency
        this.svgCanvas = svgCanvas;
        svgCanvas.addGVTTreeRendererListener(new ThumbnailGVTListener());
        svgCanvas.addSVGDocumentLoaderListener(new ThumbnailDocumentListener());
        svgCanvas.addComponentListener(new ThumbnailCanvasComponentListener());

        // create the thumbnail
        svgThumbnailCanvas = new JGVTComponent();
        overlay = new AreaOfInterestOverlay();
        svgThumbnailCanvas.getOverlays().add(overlay);
        svgThumbnailCanvas.setPreferredSize(new Dimension(150, 150));
        svgThumbnailCanvas.addComponentListener(new ThumbnailComponentListener());
        aoiListener = new AreaOfInterestListener();
        svgThumbnailCanvas.addMouseListener(aoiListener);
        svgThumbnailCanvas.addMouseMotionListener(aoiListener);
        getContentPane().add(svgThumbnailCanvas, BorderLayout.CENTER);
    }

    public void setInteractionEnabled(boolean b) {
        if (b == interactionEnabled) return;
        interactionEnabled = b;
        if (b) {
            svgThumbnailCanvas.addMouseListener      (aoiListener);
            svgThumbnailCanvas.addMouseMotionListener(aoiListener);
        } else {
            svgThumbnailCanvas.removeMouseListener      (aoiListener);
            svgThumbnailCanvas.removeMouseMotionListener(aoiListener);
        }
    }

    public boolean getInteractionEnabled() {
        return interactionEnabled;
    }

    /**
     * Updates the thumbnail component.
     */
    protected void updateThumbnailGraphicsNode() {
        svgThumbnailCanvas.setGraphicsNode(svgCanvas.getGraphicsNode());
        updateThumbnailRenderingTransform();
    }

    protected CanvasGraphicsNode getCanvasGraphicsNode(GraphicsNode gn) {
        if (!(gn instanceof CompositeGraphicsNode))
            return null;
        CompositeGraphicsNode cgn = (CompositeGraphicsNode)gn;
        List children = cgn.getChildren();
        if (children.size() == 0)
            return null;
        gn = (GraphicsNode)cgn.getChildren().get(0);
        if (!(gn instanceof CanvasGraphicsNode))
            return null;
        return (CanvasGraphicsNode)gn;
    }

    /**
     * Updates the thumbnail component rendering transform.
     */
    protected void updateThumbnailRenderingTransform() {
        SVGDocument svgDocument = svgCanvas.getSVGDocument();
        if (svgDocument != null) {
            SVGSVGElement elt = svgDocument.getRootElement();
            Dimension dim = svgThumbnailCanvas.getSize();

            // XXX Update this to use the animated values of 'viewBox'
            //     and 'preserveAspectRatio'.
            String viewBox = elt.getAttributeNS
                (null, SVGConstants.SVG_VIEW_BOX_ATTRIBUTE);

            AffineTransform Tx;
            if (viewBox.length() != 0) {
                String aspectRatio = elt.getAttributeNS
                    (null, SVGConstants.SVG_PRESERVE_ASPECT_RATIO_ATTRIBUTE);
                Tx = ViewBox.getPreserveAspectRatioTransform
                    (elt, viewBox, aspectRatio, dim.width, dim.height, null);
            } else {
                // no viewBox has been specified, create a scale transform
                Dimension2D docSize = svgCanvas.getSVGDocumentSize();
                double sx = dim.width / docSize.getWidth();
                double sy = dim.height / docSize.getHeight();
                double s = Math.min(sx, sy);
                Tx = AffineTransform.getScaleInstance(s, s);
            }

            GraphicsNode gn = svgCanvas.getGraphicsNode();
            CanvasGraphicsNode cgn = getCanvasGraphicsNode(gn);
            if (cgn != null) {
                AffineTransform vTx = cgn.getViewingTransform();
                if ((vTx != null) && !vTx.isIdentity()) {
                    try {
                        AffineTransform invVTx = vTx.createInverse();
                        Tx.concatenate(invVTx);
                    } catch (NoninvertibleTransformException nite) {
                        /* nothing */
                    }
                }
            }

            svgThumbnailCanvas.setRenderingTransform(Tx);
            overlay.synchronizeAreaOfInterest();
        }
    }

    /**
     * Used to determine whether or not the GVT tree of the thumbnail has to be
     * updated.
     */
    protected class ThumbnailDocumentListener extends SVGDocumentLoaderAdapter {

        public void documentLoadingStarted(SVGDocumentLoaderEvent e) {
            documentChanged = true;
        }
    }

    /**
     * Used to perform a translation using the area of interest.
     */
    protected class AreaOfInterestListener extends MouseInputAdapter {

        protected int sx, sy;
        protected boolean in;

        public void mousePressed(MouseEvent evt) {
            sx = evt.getX();
            sy = evt.getY();
            in = overlay.contains(sx, sy);
            overlay.setPaintingTransform(new AffineTransform());
        }

        public void mouseDragged(MouseEvent evt) {
            if (in) {
                int dx = evt.getX() - sx;
                int dy = evt.getY() - sy;
                overlay.setPaintingTransform
                    (AffineTransform.getTranslateInstance(dx, dy));
                svgThumbnailCanvas.repaint();
            }
        }

        public void mouseReleased(MouseEvent evt) {
            if (in) {
                in = false;

                int dx = evt.getX() - sx;
                int dy = evt.getY() - sy;
                AffineTransform at = overlay.getOverlayTransform();
                Point2D pt0 = new Point2D.Float(0, 0);
                Point2D pt = new Point2D.Float(dx, dy);

                try {
                    at.inverseTransform(pt0, pt0);
                    at.inverseTransform(pt, pt);
                    double tx = pt0.getX() - pt.getX();
                    double ty = pt0.getY() - pt.getY();
                    at = svgCanvas.getRenderingTransform();
                    at.preConcatenate
                        (AffineTransform.getTranslateInstance(tx, ty));
                    svgCanvas.setRenderingTransform(at);
                } catch (NoninvertibleTransformException ex) { }
            }
        }
    }

    /**
     * Used to update the overlay and/or the GVT tree of the thumbnail.
     */
    protected class ThumbnailGVTListener extends GVTTreeRendererAdapter {

        public void gvtRenderingCompleted(GVTTreeRendererEvent e) {
            if (documentChanged) {
                updateThumbnailGraphicsNode();
                documentChanged = false;
            } else {
                overlay.synchronizeAreaOfInterest();
                svgThumbnailCanvas.repaint();
            }
        }

        public void gvtRenderingCancelled(GVTTreeRendererEvent e) {
            if (documentChanged) {
                svgThumbnailCanvas.setGraphicsNode(null);
                svgThumbnailCanvas.setRenderingTransform(new AffineTransform());
            }
        }

        public void gvtRenderingFailed(GVTTreeRendererEvent e) {
            if (documentChanged) {
                svgThumbnailCanvas.setGraphicsNode(null);
                svgThumbnailCanvas.setRenderingTransform(new AffineTransform());
            }
        }
    }

    /**
     * Used the first time the thumbnail dialog is shown to make visible the
     * current GVT tree being displayed by the original SVG component.
     */
    protected class ThumbnailListener extends WindowAdapter {

        public void windowOpened(WindowEvent evt) {
            updateThumbnailGraphicsNode();
        }
    }

    /**
     * Used to allow the SVG document being displayed by the thumbnail to be
     * resized properly.
     */
    protected class ThumbnailComponentListener extends ComponentAdapter {

        public void componentResized(ComponentEvent e) {
            updateThumbnailRenderingTransform();
        }
    }

    /**
     * Used to allow the SVG document being displayed by the thumbnail to be
     * resized properly when parent resizes.
     */
    protected class ThumbnailCanvasComponentListener extends ComponentAdapter {

        public void componentResized(ComponentEvent e) {
            updateThumbnailRenderingTransform();
        }
    }

    /**
     * An overlay that represents the current area of interest.
     */
    protected class AreaOfInterestOverlay implements Overlay {

        protected Shape s;
        protected AffineTransform at;
        protected AffineTransform paintingTransform = new AffineTransform();

        public boolean contains(int x, int y) {
            return (s != null) ? s.contains(x, y) : false;
        }

        public AffineTransform getOverlayTransform() {
            return at;
        }

        public void setPaintingTransform(AffineTransform rt) {
            this.paintingTransform = rt;
        }

        public AffineTransform getPaintingTransform() {
            return paintingTransform;
        }

        public void synchronizeAreaOfInterest() {
            paintingTransform = new AffineTransform();
            Dimension dim = svgCanvas.getSize();
            s = new Rectangle2D.Float(0, 0, dim.width, dim.height);
            try {
                at = svgCanvas.getRenderingTransform().createInverse();
                at.preConcatenate(svgThumbnailCanvas.getRenderingTransform());
                s = at.createTransformedShape(s);
            } catch (NoninvertibleTransformException ex) {
                dim = svgThumbnailCanvas.getSize();
                s = new Rectangle2D.Float(0, 0, dim.width, dim.height);
            }
        }

        public void paint(Graphics g) {
            if (s != null) {
                Graphics2D g2d = (Graphics2D)g;
                g2d.transform(paintingTransform);
                g2d.setColor(new Color(255, 255, 255, 128));
                g2d.fill(s);
                g2d.setColor(Color.black);
                g2d.setStroke(new BasicStroke());
                g2d.draw(s);
            }
        }
    }
}
