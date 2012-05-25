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

import java.util.Vector;

/**
 * This abstract <code>Test</code> implementation instruments performance
 * testing.
 *
 * Derived classes need only implement the <code>runOp</code> and, 
 * optionally, the <code>runRef</code> methods.
 *
 * The <code>setReferenceScore</code> method is used to specify 
 * the last recorded score for the performance test and the 
 * <code>setAllowedScoreDeviation</code> method is used to specify
 * the allowed deviation from the reference score.
 *
 * @author <a href="mailto:vincent.hardy@sun.com">Vincent Hardy</a>
 * @version $Id: PerformanceTest.java,v 1.5 2004/08/18 07:16:57 vhardy Exp $
 */
public abstract class PerformanceTest extends AbstractTest {
    /**
     * Reference score. -1 means there is no reference score
     */
    protected double referenceScore = -1;

    /**
     * Allowed deviation from the reference score. 10% by default
     */
    protected double allowedScoreDeviation = 0.1;

    /**
     * Score during last run
     */
    protected double lastScore = -1;

    public double getLastScore() {
        return lastScore;
    }

    public double getReferenceScore() {
        return referenceScore;
    }

    public void setReferenceScore(double referenceScore) {
        this.referenceScore = referenceScore;
    }

    public double getAllowedScoreDeviation() {
        return allowedScoreDeviation;
    }

    public void setAllowedScoreDeviation(double allowedScoreDeviation) {
        this.allowedScoreDeviation = allowedScoreDeviation;
    }

    /**
     * Force implementations to only implement <code>runOp</code>
     * and other performance specific methods.
     */
    public final TestReport run() {
        return super.run();
    }

    /**
     * Force implementations to only implement <code>runOp</code>
     * and other performance specific methods.
     */
    public final boolean runImplBasic() throws Exception {
        // Should never be called for a PerformanceTest
        return false;
    }

    /**
     * This implementation of runImpl runs the reference 
     * operation (with <code>runRef</code>), then runs
     * the operation (with <code>runOp</code>) and checks whether
     * or not the score is within the allowed deviation of the 
     * reference score.
     *
     * @see #runRef
     * @see #runOp
     */
    public final TestReport runImpl() throws Exception {
        int iter = 50;

        double refUnit = 0;
        long refStart = 0;
        long refEnd = 0;
        long opEnd = 0;
        long opStart = 0;
        double opLength = 0;

        // Run once to remove class load time from timing.
        runRef();
        runOp();
        // System.gc();

        double[] scores = new double[iter];

        for (int i=0; i<iter; i++) {
            if ( i%2 == 0) {
                refStart = System.currentTimeMillis();
                runRef();
                refEnd = System.currentTimeMillis();
                runOp();
                opEnd = System.currentTimeMillis();
                refUnit = refEnd - refStart;
                opLength = opEnd - refEnd;
            } else {
                opStart = System.currentTimeMillis();
                runOp();
                opEnd = System.currentTimeMillis();
                runRef();
                refEnd = System.currentTimeMillis();
                refUnit = refEnd - opEnd;
                opLength = opEnd - opStart;
            }

            scores[i] = opLength / refUnit;
            System.err.println(".");
            // System.err.println(">>>>>>>> scores[" + i + "] = " + scores[i] + " (" + refUnit + " / " + opLength + ")");
            System.gc();
        }

        System.err.println();

        // Now, sort the scores
        sort(scores);

        // Compute the mean score based on the scores, not accounting
        // for the lowest and highest scores
        double score = 0;
        int trim = 5;
        for (int i=trim; i<scores.length-trim; i++) {
            score += scores[i];
        }

        score /= (iter - 2*trim);

        // Compute the score
        this.lastScore = score;

        // Compare to the reference score
        if (referenceScore == -1) {
            TestReport report = reportError("no.reference.score.set");
            report.addDescriptionEntry("computed.score", "" + score);
            return report;
        } else {
            double scoreMin = referenceScore*(1-allowedScoreDeviation);
            double scoreMax = referenceScore*(1+allowedScoreDeviation);
            if (score > scoreMax) {
                TestReport report = reportError("performance.regression");
                report.addDescriptionEntry("reference.score", "" + referenceScore);
                report.addDescriptionEntry("computed.score", "" + score);
                report.addDescriptionEntry("score.deviation", "" + 100*((score-referenceScore)/referenceScore));
                return report;
            } else if (score < scoreMin) {
                TestReport report = reportError("unexpected.performance.improvement");
                report.addDescriptionEntry("reference.score", "" + referenceScore);
                report.addDescriptionEntry("computed.score", "" + score);
                report.addDescriptionEntry("score.deviation", "" + 100*((score-referenceScore)/referenceScore));
                return report;
            } else {
                return reportSuccess();
            }
        }
    }

    protected void sort(double a[]) throws Exception {
        for (int i = a.length - 1; i>=0; i--) {
            boolean swapped = false;
            for (int j = 0; j<i; j++) {
                if (a[j] > a[j+1]) {
                    double d = a[j];
                    a[j] = a[j+1];
                    a[j+1] = d;
                    swapped = true;
                }
            }
            if (!swapped)
                return;
        }
    }

    /**
     * Runs the reference operation.
     * By default, this runs the same BufferedImage drawing 
     * operation 10000 times
     */
    protected void runRef() {
        Vector v = new Vector();
        for (int i=0; i<10000; i++) {
            v.addElement("" + i);
        }
        
        for (int i=0; i<10000; i++) {
            if (v.contains("" + i)) {
                v.remove("" + i);
            }
        }
    }

    /**
     * Runs the tested operation
     */
    protected abstract void runOp() throws Exception;
}
