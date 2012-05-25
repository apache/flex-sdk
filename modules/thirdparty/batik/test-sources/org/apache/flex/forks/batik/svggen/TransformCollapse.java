/*
 * Copyright 1999-2004 The Apache Software Foundation.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.flex.forks.batik.svggen;

import java.awt.Graphics2D;

/**
 * This test validates that transforms are collapsed when they
 * should.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: TransformCollapse.java,v 1.4 2005/04/01 02:28:16 deweese Exp $
 */
public class TransformCollapse implements Painter {
    public void paint(Graphics2D g){
        g.translate(10, 10);
        g.translate(20, 30);

        // Should see a translate(30, 40) in the output SVg
        g.drawString("translate collapse", 0, 0);

        g.scale(2, 2);
        g.scale(2, 4);
        
        // Should see a scale(4, 8)
        g.drawString("scale collapse", 10, 10);

        g.scale(.25, .125);
        g.rotate(Math.toRadians(90));
        g.rotate(Math.toRadians(-60));

        // Should see a rotate(30)
        g.drawString("rotate collapse", 0, 40);
        
        g.rotate(Math.toRadians(-30));
        // Should get identity
        g.drawString("identity", 0, 80);
    }
}
