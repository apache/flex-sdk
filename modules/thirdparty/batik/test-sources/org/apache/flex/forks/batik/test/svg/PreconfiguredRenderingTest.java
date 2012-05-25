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
package org.apache.flex.forks.batik.test.svg;

import java.io.File;

/**
 * Convenience class for creating a SVGRenderingAccuracyTest with predefined
 * rules for the various configuration parameters.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: PreconfiguredRenderingTest.java,v 1.8 2005/03/27 08:58:37 cam Exp $
 */
public abstract class PreconfiguredRenderingTest extends SVGRenderingAccuracyTest {
    /**
     * Generic constants
     */
    public static final String PNG_EXTENSION = ".png";

    public static final String SVG_EXTENSION = ".svg";
    public static final String SVGZ_EXTENSION = ".svgz";

    public static final char PATH_SEPARATOR = '/';

    /**
     * For preconfigured tests, the configuration has to be 
     * derived from the test identifier. The identifier should
     * characterize the SVG file to be tested.
     */
    public void setId(String id){
        super.setId(id);
        setFile(id);
    }

    public void setFile(String id) {
        String svgFile = id;

        String[] dirNfile = breakSVGFile(svgFile);

        setConfig(buildSVGURL(dirNfile[0], dirNfile[1], dirNfile[2]),
                  buildRefImgURL(dirNfile[0], dirNfile[1]));

        setVariationURL(buildVariationURL(dirNfile[0], dirNfile[1]));
        setSaveVariation(new File(buildSaveVariationFile(dirNfile[0], dirNfile[1])));
        setCandidateReference(new File(buildCandidateReferenceFile(dirNfile[0],dirNfile[1])));
    }

    /**
     * Make the name as simple as possible. For preconfigured SVG files, 
     * we use the test id, which is the relevant identifier for the test
     * user.
     */
    public String getName(){
        return getId();
    }

    /**
     * Gives a chance to the subclass to prepend a prefix to the 
     * svgFile name.
     * The svgURL is built as:
     * getSVGURLPrefix() + svgDir + svgFile
     */
    protected String buildSVGURL(String svgDir, String svgFile, String svgExt){
        return getSVGURLPrefix() + svgDir + svgFile + svgExt;
    }

    protected abstract String getSVGURLPrefix();

    
    /**
     * Gives a chance to the subclass to control the construction
     * of the reference PNG file from the svgFile name
     * The refImgURL is built as:
     * getRefImagePrefix() + svgDir + getRefImageSuffix() + svgFile
     */
    protected String buildRefImgURL(String svgDir, String svgFile){
        return getRefImagePrefix() + svgDir + getRefImageSuffix() + svgFile + PNG_EXTENSION;
    }

    protected abstract String getRefImagePrefix();

    protected abstract String getRefImageSuffix();

    /**
     * Gives a chance to the subclass to control the construction
     * of the variation URL, which is built as:
     * getVariationPrefix() + svgDir + getVariationSuffix() + svgFile + PNG_EXTENSION
     */
    public String buildVariationURL(String svgDir, String svgFile){
        return getVariationPrefix() + svgDir + getVariationSuffix() + svgFile + PNG_EXTENSION;
    }

    protected abstract String getVariationPrefix();

    protected abstract String getVariationSuffix();

    /**
     * Gives a chance to the subclass to control the construction
     * of the saveVariation URL, which is built as:
     * getSaveVariationPrefix() + svgDir + getSaveVariationSuffix() + svgFile + PNG_EXTENSION
     */
    public String  buildSaveVariationFile(String svgDir, String svgFile){
        return getSaveVariationPrefix() + svgDir + getSaveVariationSuffix() + svgFile + PNG_EXTENSION;
    }

    protected abstract String getSaveVariationPrefix();

    protected abstract String getSaveVariationSuffix();

    /**
     * Gives a chance to the subclass to control the construction
     * of the candidateReference URL, which is built as:
     * getCandidatereferencePrefix() + svgDir + getCandidatereferenceSuffix() + svgFile + PNG_EXTENSION
     */
    public String  buildCandidateReferenceFile(String svgDir, String svgFile){
        return getCandidateReferencePrefix() + svgDir + getCandidateReferenceSuffix() + svgFile + PNG_EXTENSION;
    }

    protected abstract String getCandidateReferencePrefix();

    protected abstract String getCandidateReferenceSuffix();


    protected String[] breakSVGFile(String svgFile){
        if(svgFile == null) {
            throw new IllegalArgumentException(svgFile);
        }

        String [] ret = new String[3];

        if (svgFile.endsWith(SVG_EXTENSION)) {
            ret[2] = SVG_EXTENSION;
        } else if (svgFile.endsWith(SVGZ_EXTENSION)) {
            ret[2] = SVGZ_EXTENSION;
        } else {
            throw new IllegalArgumentException(svgFile);
        }

        svgFile = svgFile.substring(0, svgFile.length()-ret[2].length());

        int fileNameStart = svgFile.lastIndexOf(PATH_SEPARATOR);
        String svgDir = "";
        if(fileNameStart != -1){
            if(svgFile.length() < fileNameStart + 2){
                // Nothing after PATH_SEPARATOR
                throw new IllegalArgumentException(svgFile);
            }
            svgDir = svgFile.substring(0, fileNameStart + 1);
            svgFile = svgFile.substring(fileNameStart + 1);
        }
        ret[0] = svgDir;
        ret[1] = svgFile;
        return ret;
    }

}
