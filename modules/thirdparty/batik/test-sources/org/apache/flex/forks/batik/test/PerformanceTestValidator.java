/*

   Copyright 2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.test;

import java.awt.AlphaComposite;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;

/**
 * Validates the operation of the <code>PerformanceTest</code> class.
 *
 * @author <a href="mailto:vincent.hardy@sun.com">Vincent Hardy</a>
 * @version $Id: PerformanceTestValidator.java,v 1.5 2004/08/18 07:16:57 vhardy Exp $
 */
public class PerformanceTestValidator extends AbstractTest {
    public TestReport runImpl() throws Exception {
        // First, work with SimplePerformanceTest to check the life
        // cycle of using a performance test.
        // ===========================================================
        SimplePerformanceTest p = new SimplePerformanceTest();
        TestReport r = p.run();
        assertTrue(!r.hasPassed());
        assertTrue(r.getErrorCode().equals("no.reference.score.set"));
        p.setReferenceScore(p.getLastScore());
        p.run();
        p.setReferenceScore(p.getLastScore());
        p.run();

        double score = p.getLastScore();        
        p.setReferenceScore(score);
        r = p.run();

        if (!r.hasPassed()) {
            TestReport result = reportError("unexpected.performance.test.failure");
            result.addDescriptionEntry("error.code", r.getErrorCode());
            result.addDescriptionEntry("expected.score", "" + score);
            result.addDescriptionEntry("actual.score", "" + p.getLastScore());
            result.addDescriptionEntry("regression.percentage", "" + 100*(score - p.getLastScore())/p.getLastScore());
            return result;
        }

        // Now, check that performance changes are detected
        // ===========================================================
        p.setReferenceScore(score*0.5);
        r = p.run();
        assertTrue(!r.hasPassed());
        if (!r.getErrorCode().equals("performance.regression")) {
            TestReport result = reportError("unexpected.performance.test.error.code");
            result.addDescriptionEntry("expected.code", "performance.regression");
            result.addDescriptionEntry("actual.code", r.getErrorCode());
            result.addDescriptionEntry("expected.score", "" + score);
            result.addDescriptionEntry("actual.score", "" + p.getLastScore());
            result.addDescriptionEntry("regression.percentage", "" + 100*(score - p.getLastScore())/p.getLastScore());
            return result;
        }

        p.setReferenceScore(score*2);
        r = p.run();
        assertTrue(!r.hasPassed());
        if (!r.getErrorCode().equals("unexpected.performance.improvement")) {
            TestReport result = reportError("unexpected.performance.test.error.code");
            result.addDescriptionEntry("expected.code", "unexpected.performance.improvement");
            result.addDescriptionEntry("actual.code", r.getErrorCode());
            result.addDescriptionEntry("expected.score", "" + score);
            result.addDescriptionEntry("actual.score", "" + p.getLastScore());
            result.addDescriptionEntry("regression.percentage", "" + 100*(score - p.getLastScore())/p.getLastScore());
            return result;
        }

        return reportSuccess();
    }

    static class SimplePerformanceTest extends PerformanceTest {
        public void runOp() {
            // runRef();
            BufferedImage buf = new BufferedImage(200, 200, BufferedImage.TYPE_INT_ARGB);
            Graphics2D g = buf.createGraphics();
            AffineTransform txf = new AffineTransform();
            g.setComposite(AlphaComposite.getInstance(AlphaComposite.SRC_OVER, 0.5f));
            g.setPaint(new Color(30, 100, 200));
            
            for (int j=0; j<20; j++) {
                txf.setToIdentity();
                txf.translate(-100, -100);
                txf.rotate(j*Math.PI/100);
                txf.translate(100, 100);
                g.setTransform(txf);
                g.drawRect(30, 30, 140, 140);
            }
            /*
            Vector v = new Vector();
            for (int i=0; i<5000; i++) {
                v.addElement("" + i);
            }
            
            for (int i=0; i<5000; i++) {
                if (v.contains("" + i)) {
                    v.remove("" + i);
                }
                }*/
        }
    }
}
