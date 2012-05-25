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

import java.awt.Graphics2D;
import java.awt.geom.AffineTransform;
import javax.swing.ImageIcon;

/**
 * This test validates drawImage conversions.
 *
 * @author <a href="mailto:vhardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: Bug4389.java,v 1.4 2004/08/18 07:16:44 vhardy Exp $
 */
public class Bug4389 implements Painter {
    public void paint(Graphics2D g){
        ImageIcon image = new ImageIcon(ClassLoader.getSystemResource("org/apache/batik/svggen/resources/vangogh.png"));
        g.translate(40,40);
        g.drawImage(image.getImage(), new AffineTransform(), null);
    }
}
