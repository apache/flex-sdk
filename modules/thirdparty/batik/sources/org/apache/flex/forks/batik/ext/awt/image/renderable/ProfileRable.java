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
package org.apache.flex.forks.batik.ext.awt.image.renderable;

import java.awt.image.RenderedImage;
import java.awt.image.renderable.RenderContext;

import org.apache.flex.forks.batik.ext.awt.color.ICCColorSpaceExt;
import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.ext.awt.image.rendered.CachableRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.ProfileRed;

/**
 * Implements the interface expected from a color matrix
 * operation
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: ProfileRable.java,v 1.5 2004/08/18 07:13:59 vhardy Exp $
 */
public class ProfileRable extends  AbstractRable{
    
    private ICCColorSpaceExt colorSpace;

    /**
     * Instances should be built through the static
     * factory methods
     */
    public ProfileRable(Filter src, ICCColorSpaceExt colorSpace){
        super(src);
        this.colorSpace = colorSpace;
    }

    /**
     * Sets the source of the blur operation
     */
    public void setSource(Filter src){
        init(src, null);
    }

    /**
     * Returns the source of the blur operation
     */
    public Filter getSource(){
        return (Filter)getSources().get(0);
    }

    /**
     * Sets the ColorSpace of the Profile operation
     */
    public void setColorSpace(ICCColorSpaceExt colorSpace){
        touch();
        this.colorSpace = colorSpace;
    }

    /**
     * Returns the ColorSpace of the Profile operation
     */
    public ICCColorSpaceExt getColorSpace(){
        return colorSpace;
    }

    public RenderedImage createRendering(RenderContext rc) {
        //
        // Get source's rendered image
        //
        RenderedImage srcRI = getSource().createRendering(rc);

        if(srcRI == null)
            return null;

        CachableRed srcCR = GraphicsUtil.wrap(srcRI);
        return new ProfileRed(srcCR, colorSpace);
    }
}
