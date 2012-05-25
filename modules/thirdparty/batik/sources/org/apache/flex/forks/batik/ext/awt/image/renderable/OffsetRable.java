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

/**
 * Adjusts the input images coordinate system by dx, dy.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: OffsetRable.java,v 1.4 2004/08/18 07:13:59 vhardy Exp $
 */
public interface OffsetRable extends Filter {
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
       * Set the x offset.
       * @param dx the amount to offset in the x direction
       */
    public void setXoffset(double dx);

      /**
       * Get the x offset.
       * @return the amount to offset in the x direction
       */
    public double getXoffset();

      /**
       * Set the y offset.
       * @param dy the amount to offset in the y direction
       */
    public void setYoffset(double dy);

      /**
       * Get the y offset.
       * @return the amount to offset in the y direction
       */
    public double getYoffset();
}
