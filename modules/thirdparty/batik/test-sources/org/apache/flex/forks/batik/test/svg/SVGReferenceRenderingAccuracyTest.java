/*

   Copyright 2001-2003  The Apache Software Foundation 

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
import java.net.MalformedURLException;
import java.net.URL;

/**
 * Base class for tests which take an additional parameter in addition
 * to the SVG file.
 *
 * @author <a href="mailto:vincent.hardy@sun.com">Vincent Hardy</a>
 * @version $Id: SVGReferenceRenderingAccuracyTest.java,v 1.6 2004/08/18 07:17:03 vhardy Exp $
 */
public class SVGReferenceRenderingAccuracyTest
    extends ParametrizedRenderingAccuracyTest {
    protected String alias;
   
    /**
     * For this type of test, the id should be made as 
     * follows:<br />
     * <fileName>#reference-alias <br />
     * For example: <br />
     * samples/anne.svg#svgView(viewBox(0,0,100,100))-viewBox1
     */
    public void setId(String id){
        this.id = id;

        String svgFile = id;

        int n = svgFile.lastIndexOf('#');
        if(n == -1 || n+1 >= svgFile.length() ){
            throw new IllegalArgumentException(id);
        }
        
        parameter = svgFile.substring(n+1, svgFile.length());
        svgFile = svgFile.substring(0, n);
        
        n = parameter.lastIndexOf('-');
        if(n == -1 || n+1 >= parameter.length()){
            throw new IllegalArgumentException(id);
        }

        alias = parameter.substring(n+1, parameter.length());
        parameter = parameter.substring(0, n);

        String[] dirNfile = breakSVGFile(svgFile);

        setConfig(buildSVGURL(dirNfile[0], dirNfile[1]),
                  buildRefImgURL(dirNfile[0], dirNfile[1]));

        setVariationURL(buildVariationURL(dirNfile[0], dirNfile[1]));
        setSaveVariation(new File(buildSaveVariationFile(dirNfile[0], dirNfile[1])));
        setCandidateReference(new File(buildCandidateReferenceFile(dirNfile[0], dirNfile[1])));
    }

    /**
     * Resolves the input string as follows.
     *
     * + First, the string is interpreted as a file description minus
     *   any url fragment it may have (stuff after a '#').  If the
     *   file's parent directory exists, then the file name is turned
     *   into a URL and the fragment if any is appended.
     * + Otherwise, the string is supposed to be a URL. If it
     *   is an invalid URL, an IllegalArgumentException is thrown.  
     */
    protected URL resolveURL(String url){
        // We must strip the # off if there is one otherwise File thinks
        // we want to reference a file that has a '#' in it's name...
        String fragment = null;
        String file     = url;
        int n = file.lastIndexOf('#');
        if (n != -1) {
            fragment = file.substring(n); // include the #.
            file     = file.substring(0,n);
        }

        // Is url a file?
        File f = (new File(file)).getAbsoluteFile();
        if(f.getParentFile().exists()){
            try{
                if (fragment == null) {
                    return f.toURL(); // No fragment.
                } else {
                    // Construct URL that includes fragment...
                    return new URL(f.toURL(), fragment);
                }
            }catch(MalformedURLException e){
                throw new IllegalArgumentException();
            }
        }
        
        // url is not a file. It must be a regular URL...
        try{
            return new URL(url);
        }catch(MalformedURLException e){
            throw new IllegalArgumentException(url);
        }
    }

    /**
     * Gives a chance to the subclass to prepend a prefix to the 
     * svgFile name.
     * The svgURL is built as:
     * getSVGURLPrefix() + svgDir + svgFile + SVG_EXTENSION + "#" + parameter
     */
    protected String buildSVGURL(String svgDir, String svgFile){
        return getSVGURLPrefix() + svgDir +
            svgFile + SVG_EXTENSION + "#" + parameter;
    }

    /**
     * Gives a chance to the subclass to control the construction
     * of the reference PNG file from the svgFile name
     * The refImgURL is built as:
     * getRefImagePrefix() + svgDir + getRefImageSuffix() + svgFile
     */
    protected String buildRefImgURL(String svgDir, String svgFile){
        return getRefImagePrefix() + svgDir + getRefImageSuffix() + svgFile + alias + PNG_EXTENSION;
    }

    /**
     * Gives a chance to the subclass to control the construction
     * of the variation URL, which is built as:
     * getVariationPrefix() + svgDir + getVariationSuffix() + svgFile + parameter + PNG_EXTENSION
     */
    public String buildVariationURL(String svgDir, String svgFile){
        return getVariationPrefix() + svgDir + getVariationSuffix() + svgFile + alias + PNG_EXTENSION;
    }

    /**
     * Gives a chance to the subclass to control the construction
     * of the saveVariation URL, which is built as:
     * getSaveVariationPrefix() + svgDir + getSaveVariationSuffix() + svgFile + parameter + PNG_EXTENSION
     */
    public String  buildSaveVariationFile(String svgDir, String svgFile){
        return getSaveVariationPrefix() + svgDir + getSaveVariationSuffix() + svgFile + alias + PNG_EXTENSION;
    }

    /**
     * Gives a chance to the subclass to control the construction
     * of the candidateReference URL, which is built as:
     * getSaveVariationPrefix() + svgDir + getSaveVariationSuffix() + svgFile + parameter + PNG_EXTENSION
     */
    public String  buildCandidateReferenceFile(String svgDir, String svgFile){
        return getCandidateReferencePrefix() + svgDir + getCandidateReferenceSuffix() + svgFile + alias + PNG_EXTENSION;
    }

}
