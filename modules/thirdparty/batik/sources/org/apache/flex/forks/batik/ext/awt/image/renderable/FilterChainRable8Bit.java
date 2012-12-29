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
package org.apache.flex.forks.batik.ext.awt.image.renderable;

import java.awt.Composite;
import java.awt.Graphics2D;
import java.awt.geom.Rectangle2D;
import java.awt.image.RenderedImage;
import java.awt.image.renderable.RenderContext;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.ext.awt.image.PadMode;
import org.apache.flex.forks.batik.ext.awt.image.SVGComposite;

/**
 * Implements a filter chain. A filter chain is defined by its
 * filter region (i.e., the bounding box of its input/output), its
 * filter resolution and its source. Its source cannot be null,
 * but its resolution can. <br />
 * The filter chain decomposes as follows: 
 * <ul>
 *  <li>A pad operation that makes the input image a big as the
 *      filter region.</li>
 *  <li>If there is a filterResolution specified along at least
 *      one of the axis, a <tt>AffineRable</tt>
 * </ul>
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: FilterChainRable8Bit.java 594379 2007-11-13 01:08:28Z cam $
 */
public class FilterChainRable8Bit extends AbstractRable
    implements FilterChainRable, PaintRable {
    /**
     * Resolution along the X axis
     */
    private int filterResolutionX;

    /**
     * Resolution along the Y axis
     */
    private int filterResolutionY;

    /**
     * The chain's source
     */
    private Filter chainSource;

    /**
     * Scale operation. May be null
     */
    private FilterResRable filterRes;

    /**
     * Crop operation.
     */
    private PadRable crop;

    /**
     * Filter region
     */
    private Rectangle2D filterRegion;

    /**
     * Default constructor.
     */
    public FilterChainRable8Bit(Filter source, Rectangle2D filterRegion){
        if(source == null){
            throw new IllegalArgumentException();
        }
        if(filterRegion == null){
            throw new IllegalArgumentException();
        }

        // Build crop with chain source and dummy region (will be lazily evaluated
        // later on).
        Rectangle2D padRect = (Rectangle2D)filterRegion.clone();
        crop = new PadRable8Bit(source, padRect, 
                                    PadMode.ZERO_PAD);

        // Keep a reference to the chain source and filter
        // regions.
        this.chainSource = source;
        this.filterRegion = filterRegion;

        // crop is the real shource for this filter
        // The filter chain is a simple passthrough to its
        // crop node.
        init(crop); 
  
    }

    /**
     * Returns the resolution along the X axis.
     */
    public int getFilterResolutionX(){
        return filterResolutionX;
    }

    /**
     * Sets the resolution along the X axis, i.e., the maximum
     * size for intermediate images along that axis.
     * If filterResolutionX is less than zero, no filter resolution
     * is forced on the filter chain. If filterResolutionX is zero,
     * then the filter returns null. If filterResolutionX is positive,
     * then the filter resolution is applied.
     */
    public void setFilterResolutionX(int filterResolutionX){
        touch();
        this.filterResolutionX = filterResolutionX;

        setupFilterRes();
    }

    /**
     * Returns the resolution along the Y axis.
     */
    public int getFilterResolutionY(){
        return filterResolutionY;
    }

    /**
     * Sets the resolution along the Y axis, i.e., the maximum
     * size for intermediate images along that axis.
     * If filterResolutionY is zero or less, the value of
     * filterResolutionX is used.
     */
    public void setFilterResolutionY(int filterResolutionY){
        touch();
        this.filterResolutionY = filterResolutionY;
        setupFilterRes();
    }
    
    /**
     * Implementation. Checks the current value of the 
     * filterResolutionX and filterResolutionY attribute and 
     * setup the filterRes operation accordingly.
     */
    private void setupFilterRes(){
        if(filterResolutionX >=0){
            if(filterRes == null){
                filterRes = new FilterResRable8Bit();
                filterRes.setSource(chainSource);
            }
            
            filterRes.setFilterResolutionX(filterResolutionX);
            filterRes.setFilterResolutionY(filterResolutionY);
        }
        else{
            // X is negative, this disables the resolution filter.
            filterRes = null;
        }

        // Now, update the crop source to reflect the filterRes
        // settings.
        if(filterRes != null){
            crop.setSource(filterRes);
        }
        else{
            crop.setSource(chainSource);
        }
    }
    
    /**
     * Sets the filter output area, in user space. 
     * A null value is illegal.
     */
    public void setFilterRegion(Rectangle2D filterRegion){
        if(filterRegion == null){
            throw new IllegalArgumentException();
        }
        touch();
        this.filterRegion = filterRegion;
     }

    /**
     * Returns the filter output area, in user space
     */
    public Rectangle2D getFilterRegion(){
        return filterRegion;
    }

    /**
     * Returns the source of the chain. Note that a crop and
     * affine operation may be inserted before the source, 
     * depending on the filterRegion and filterResolution 
     * parameters.
     */
    public Filter getSource() {
        return crop;
    }
    
    /**
     * Sets the source to be src.
     * @param chainSource image to the chain.
     */
    public void setSource(Filter chainSource) {
        if(chainSource == null){
            throw new IllegalArgumentException("Null Source for Filter Chain");
        }
        touch();
        this.chainSource = chainSource;
        
        if(filterRes == null){
            crop.setSource(chainSource);
        }
        else{
            filterRes.setSource(chainSource);
        }
    }

    /**
     * Returns this filter's bounds
     */
    public Rectangle2D getBounds2D(){
        return (Rectangle2D)filterRegion.clone();
    }

    /**
     * Should perform the equivilent action as 
     * createRendering followed by drawing the RenderedImage to 
     * Graphics2D, or return false.
     *
     * @param g2d The Graphics2D to draw to.
     * @return true if the paint call succeeded, false if
     *         for some reason the paint failed (in which 
     *         case a createRendering should be used).
     */
    public boolean paintRable(Graphics2D g2d) {
        // This optimization only apply if we are using
        // SrcOver.  Otherwise things break...
        Composite c = g2d.getComposite();
        if (!SVGComposite.OVER.equals(c))
            return false;
        
        GraphicsUtil.drawImage(g2d, getSource());

        return true;
    }

    public RenderedImage createRendering(RenderContext context){
        return crop.createRendering(context);
    }
}
