/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flash.graphics.g2d;

import org.apache.flex.forks.batik.ext.awt.g2d.TransformStackElement;
import org.apache.flex.forks.batik.ext.awt.RenderingHintsKeyExt;

import java.awt.*;
import java.awt.font.FontRenderContext;
import java.awt.geom.AffineTransform;
import java.awt.geom.Area;
import java.awt.geom.GeneralPath;
import java.awt.geom.NoninvertibleTransformException;
import java.awt.geom.Point2D;
import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.util.Map;
import java.util.Vector;
import java.lang.ref.WeakReference;

/**
 * A modified version of Apache Batik's GraphicsContext, used to store
 * state between successive Graphics2D calls.
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @author Peter Farland
 * @version 1.0
 */
public final class GraphicContext implements Cloneable
{
	/**
	 * Call this optimized Constructor for faster instantiation, but without FontMetrics support.
	 */
	public GraphicContext()
	{
		bufferedImage = null;

		init();
	}

	/**
	 * Constructor. Used by clone() too.
	 */
	public GraphicContext(int width, int height)
	{
		this.width = width;
		this.height = height;

		bufferedImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
		bufferedImageGraphics = bufferedImage.createGraphics(); //Keep in sync with current transforms

		hints.put(RenderingHintsKeyExt.KEY_BUFFERED_IMAGE, new WeakReference<BufferedImage>(bufferedImage));

		init();
	}

	private void init()
	{
		// Noted from Apache Batik - supposedly to workaround a JDK bug
		hints.put(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_DEFAULT);

		transform = new AffineTransform(defaultTransform);
	}

	/**
	 * Returns the current paint if an instance of <code>Color</code>, otherwise the default paint
	 * is returned, which is <code>Color.black</code>.
	 */
	public Color getColor()
	{
		if (paint instanceof Color)
			return (Color)paint;
		else
			return defaultPaint;
	}

	/**
	 * Returns the current Composite of the graphic context.
	 * @return the Composite
	 */
	public Composite getComposite()
	{
		return composite;
	}

	/**
	 * Sets the <code>Composite</code> for the <code>Graphics2D</code> context.
     * The <code>Composite</code> is used in all drawing methods such as
     * <code>drawImage</code>, <code>drawString</code>, <code>draw</code>,
     * and <code>fill</code>.  It specifies how new pixels are to be combined
     * with the existing pixels on the graphics device during the rendering
     * process.
	 * @param comp
	 */
	public void setComposite(Composite comp)
	{
		this.composite = comp;

		if (bufferedImageGraphics != null)
			bufferedImageGraphics.setComposite(comp);
	}

    /**
	 * Gets the current font of this graphic context.
	 * @return
	 */
	public Font getFont()
	{
		return font;
	}

	public void setFont(Font f)
	{
		if (f == null)
			return;

		this.font = f;

		if (bufferedImageGraphics != null)
			bufferedImageGraphics.setFont(f);
	}

	public FontRenderContext getFontRenderContext()
	{
		// Find if antialiasing should be used.
		Object antialiasingHint = hints.get(RenderingHints.KEY_TEXT_ANTIALIASING);
		boolean isAntialiased = true;
		if (antialiasingHint != RenderingHints.VALUE_TEXT_ANTIALIAS_ON &&
				antialiasingHint != RenderingHints.VALUE_TEXT_ANTIALIAS_DEFAULT)
		{

			// If antialias was not turned off, then use the general rendering hint.
			if (antialiasingHint != RenderingHints.VALUE_TEXT_ANTIALIAS_OFF)
			{
				antialiasingHint = hints.get(RenderingHints.KEY_ANTIALIASING);

				// Test general hint
				if (antialiasingHint != RenderingHints.VALUE_ANTIALIAS_ON &&
						antialiasingHint != RenderingHints.VALUE_ANTIALIAS_DEFAULT)
				{
					// Antialiasing was not requested. However, if it was not turned
					// off explicitly, use it.
					if (antialiasingHint == RenderingHints.VALUE_ANTIALIAS_OFF)
						isAntialiased = false;
				}
			}
			else
				isAntialiased = false;

		}

		// Find out whether fractional metrics should be used.
		boolean useFractionalMetrics = true;
		if (hints.get(RenderingHints.KEY_FRACTIONALMETRICS)
				== RenderingHints.VALUE_FRACTIONALMETRICS_OFF)
			useFractionalMetrics = false;

		FontRenderContext frc = new FontRenderContext(null, isAntialiased, useFractionalMetrics);

		return frc;
	}

	public GraphicsConfiguration getDeviceConfiguration()
	{
		if (bufferedImageGraphics != null)
			return bufferedImageGraphics.getDeviceConfiguration();
		else
			return null;
	}

	public Paint getPaint()
	{
		return this.paint;
	}

	public void setPaint(Paint paint)
	{
		this.paint = paint;

		if (bufferedImageGraphics != null)
			bufferedImageGraphics.setPaint(paint);
	}

	public Stroke getStroke()
	{
		return this.stroke;
	}

	public void setStroke(Stroke s)
	{
		this.stroke = s;

		if (bufferedImageGraphics != null)
			bufferedImageGraphics.setStroke(s);
	}

	public Color getBackground()
	{
		return this.background;
	}

	public void setBackground(Color color)
	{
		this.background = color;

		if (bufferedImageGraphics != null)
			bufferedImageGraphics.setBackground(color);
	}

	public Point2D getPen()
	{
		return pen;
	}

	public Point2D setPen(Point2D pen)
	{
		Point2D old = this.pen;
		this.pen = pen;
		return old;
	}

	public void setRenderingHint(RenderingHints.Key hintKey, Object hintValue)
	{
		hints.put(hintKey, hintValue);

		if (bufferedImageGraphics != null)
			bufferedImageGraphics.setRenderingHint(hintKey, hintValue);
	}

	public Object getRenderingHint(RenderingHints.Key hintKey)
	{
		return hints.get(hintKey);
	}

	public RenderingHints getRenderingHints()
	{
		return hints;
	}

	public void addRenderingHints(Map hints)
	{
		this.hints.putAll(hints);

		if (bufferedImageGraphics != null)
			bufferedImageGraphics.addRenderingHints(hints);
	}

	public void setRenderingHints(Map hints)
	{
		RenderingHints h = new RenderingHints(hints);
		this.hints = h;

		if (bufferedImageGraphics != null)
			bufferedImageGraphics.setRenderingHints(h);
	}

	public void clip(Shape s)
	{
		if (s != null)
			s = transform.createTransformedShape(s);

		if (clip != null)
		{
			Area newClip = new Area(clip);
			newClip.intersect(new Area(s));
			clip = new GeneralPath(newClip);
		}
		else
		{
			clip = s;
		}
	}

    public Rectangle getClipBounds()
	{
        Shape c = getClip();
        if (c == null)
            return null;
        else
            return c.getBounds();
    }

	public void clipRect(int x, int y, int width, int height)
	{
		clip(new Rectangle(x, y, width, height));
	}

	public void setClip(int x, int y, int width, int height)
	{
		setClip(new Rectangle(x, y, width, height));
	}

	public void setClip(Shape clip)
	{
		Shape s = null;

		if (clip != null)
		{
			s = transform.createTransformedShape(clip);
			this.clip = s;
		}
		else
		{
			this.clip = null;
		}

		if (bufferedImageGraphics != null)
			bufferedImageGraphics.setClip(s);
	}

	public Shape getClip()
	{
		try
		{
			return transform.createInverse().createTransformedShape(clip);
		}
		catch (NoninvertibleTransformException e)
		{
			return null;
		}
	}

	public FontMetrics getFontMetrics(Font f)
	{
		if (bufferedImageGraphics != null)
			return bufferedImageGraphics.getFontMetrics(f);
		else
			return null;
	}

	public ColorModel getColorModel()
	{
		if (bufferedImage != null)
			return bufferedImage.getColorModel();
		else
			return null;
	}

    public void rotate(double theta)
	{
        transform.rotate(theta);
        transformStack.addElement(TransformStackElement.createRotateElement(theta));

		if (bufferedImageGraphics != null)
			bufferedImageGraphics.rotate(theta);
    }

    public void rotate(double theta, double x, double y)
	{
        transform.rotate(theta, x, y);
        transformStack.addElement(TransformStackElement.createTranslateElement(x, y));
        transformStack.addElement(TransformStackElement.createRotateElement(theta));
        transformStack.addElement(TransformStackElement.createTranslateElement(-x, -y));

		if (bufferedImageGraphics != null)
			bufferedImageGraphics.rotate(theta, x, y);
    }

    public void scale(double sx, double sy)
	{
        transform.scale(sx, sy);
        transformStack.addElement(TransformStackElement.createScaleElement(sx, sy));

		if (bufferedImageGraphics != null)
			bufferedImageGraphics.scale(sx, sy);
    }

    public void shear(double shx, double shy)
	{
        transform.shear(shx, shy);
        transformStack.addElement(TransformStackElement.createShearElement(shx, shy));

		if (bufferedImageGraphics != null)
			bufferedImageGraphics.shear(shx, shy);
    }

    public void translate(double tx, double ty)
	{
        transform.translate(tx, ty);
        transformStack.addElement(TransformStackElement.createTranslateElement(tx, ty));

		if (bufferedImageGraphics != null)
			bufferedImageGraphics.translate(tx, ty);
    }

	public void translate(int x, int y)
	{
        if(x!=0 || y!=0)
		{
            transform.translate(x, y);
            transformStack.addElement(TransformStackElement.createTranslateElement(x, y));
        }

		if (bufferedImageGraphics != null)
			bufferedImageGraphics.translate(x, y);
    }

	public void transform(AffineTransform tx)
	{
		transform.concatenate(tx);
		transformStack.addElement(TransformStackElement.createGeneralTransformElement(tx));

		if (bufferedImageGraphics != null)
			bufferedImageGraphics.transform(tx);
	}

    public AffineTransform getTransform()
	{
        return new AffineTransform(transform);
    }

    public void setTransform(AffineTransform Tx)
	{
        transform = new AffineTransform(Tx);
        invalidateTransformStack();
        if(!Tx.isIdentity())
		{
            transformStack.addElement(TransformStackElement.createGeneralTransformElement(Tx));
		}

		if (bufferedImageGraphics != null)
			bufferedImageGraphics.setTransform(Tx);
    }

	public AffineTransform getDefaultTransform()
	{
		return defaultTransform;
	}

    public void validateTransformStack()
	{
        transformStackValid = true;
    }

    public boolean isTransformStackValid()
	{
        return transformStackValid;
    }

    void invalidateTransformStack()
	{
        transformStack.removeAllElements();
        transformStackValid = false;
    }


    /**
     * Creates a deep copy of a <code>SWFGraphicContext</code> instance.
	 *
	 * @return a deep copy of this context
     */
    public Object clone()
	{
        GraphicContext copy = new GraphicContext(width, height);

        // BufferedImage (used to calculate font metrics - DON'T CLONE)
		copy.bufferedImageGraphics = this.bufferedImageGraphics;

		// Transform
        copy.setTransform(this.transform);

        // Paint (immutable by requirement)
        copy.setPaint(this.paint);

        // Stroke (immutable by requirement)
        copy.setStroke(this.stroke);

        // Composite (immutable by requirement)
        copy.setComposite(this.composite);

        // Clip
        if(clip != null)
            copy.clip = new GeneralPath(clip);
        else
            copy.clip=null;

        // RenderingHints
        copy.setRenderingHints((RenderingHints)this.hints.clone());

        // Font (immutable)
        copy.setFont(this.font);

        // Background, Foreground (immutable)
        copy.setBackground(this.background);

        return copy;
    }

	private final BufferedImage bufferedImage;

	private Graphics2D bufferedImageGraphics;

	private Font font = new Font("Dialog", Font.PLAIN, 12);

	private final static AffineTransform defaultTransform = new AffineTransform();

	private AffineTransform transform = new AffineTransform();

	private Vector<TransformStackElement> transformStack = new Vector<TransformStackElement>();

	private boolean transformStackValid = true;

	private Composite composite = AlphaComposite.SrcOver;

	private Point2D pen = new Point2D.Double(0.0, 0.0);

	private Paint paint = Color.black;

	private final static Color defaultPaint = Color.black;

	private Stroke stroke = new BasicStroke();

	private Color background = new Color(255, 255, 255, 0);

	private Shape clip = null;

	private RenderingHints hints = new RenderingHints(null);

	private int width;

	private int height;
}
