/*

   Copyright 2001  The Apache Software Foundation 

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

import org.apache.flex.forks.batik.ext.awt.image.ComponentTransferFunction;

/**
 * Defines the interface expected from a component
 * transfer operation.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: ComponentTransferRable.java,v 1.6 2004/08/18 07:13:58 vhardy Exp $
 */
public interface ComponentTransferRable extends FilterColorInterpolation {

    /**
     * Returns the source to be offset.
     */
    public Filter getSource();

    /**
     * Sets the source to be offset.
     * @param src image to offset.
     */
    public void setSource(Filter src);

    /**
     * Returns the transfer function for the alpha channel
     */
    public ComponentTransferFunction getAlphaFunction();

    /**
     * Sets the transfer function for the alpha channel
     */
    public void setAlphaFunction(ComponentTransferFunction alphaFunction);

    /**
     * Returns the transfer function for the red channel
     */
    public ComponentTransferFunction getRedFunction();

    /**
     * Sets the transfer function for the red channel
     */
    public void setRedFunction(ComponentTransferFunction redFunction);

    /**
     * Returns the transfer function for the green channel
     */
    public ComponentTransferFunction getGreenFunction();

    /**
     * Sets the transfer function for the green channel
     */
    public void setGreenFunction(ComponentTransferFunction greenFunction);

    /**
     * Returns the transfer function for the blue channel
     */
    public ComponentTransferFunction getBlueFunction();

    /**
     * Sets the transfer function for the blue channel
     */
    public void setBlueFunction(ComponentTransferFunction blueFunction);
}
