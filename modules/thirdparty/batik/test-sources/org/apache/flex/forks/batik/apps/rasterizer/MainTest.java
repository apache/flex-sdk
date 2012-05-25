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
package org.apache.flex.forks.batik.apps.rasterizer;


import java.awt.Color;
import java.awt.geom.Rectangle2D;
import java.io.File;
import java.util.StringTokenizer;
import java.util.Vector;

import org.apache.flex.forks.batik.test.AbstractTest;
import org.apache.flex.forks.batik.test.DefaultTestSuite;
import org.apache.flex.forks.batik.test.Test;
import org.apache.flex.forks.batik.test.TestReport;

/**
 * Validates the operation of the <tt>Main</tt> class.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: MainTest.java,v 1.14 2005/03/27 08:58:37 cam Exp $
 */
public class MainTest extends DefaultTestSuite {
    
    public MainTest(){
        Test t = new MainConfigTest("-d samples") {
                public TestReport validate(SVGConverter c){
                    File dst = c.getDst();
                    if(dst!= null && dst.equals(new File("samples"))){
                        return reportSuccess();
                    } else {
                        return reportError("-d", "samples", "" + dst);
                    }
                }
                
            };
        
        addTest(t);
        t.setId("MainConfigTest.output");
        
        t = new MainConfigTest("samples/anne.svg") {
                String ERROR_UNEXPECTED_SOURCES = "MainConfigTest.error.unexpected.sources";
                
                public TestReport validate(SVGConverter c){
                    Vector sources = c.getSources();
                    if(sources.size() == 1){
                        String src = (String)sources.elementAt(0);
                        if ("samples/anne.svg".equals(src)){
                            return reportSuccess();
                        } 
                    }
                    
                    return reportError(ERROR_UNEXPECTED_SOURCES);
                }
                
            };
    
        addTest(t);
        t.setId("MainConfigTest.source");
    
        t = new MainConfigTest("-m image/jpeg") {
                public TestReport validate(SVGConverter c){
                    DestinationType type = c.getDestinationType();
                    if(type.equals(DestinationType.JPEG)){
                        return reportSuccess();
                    } else {
                        return reportError("-m", DestinationType.JPEG.toString(), "" + type);
                    }
                }
            
            };
    
        addTest(t);
        t.setId("MainConfigTest.mimeType.jpegA");

        t = new MainConfigTest("-m image/jpg") {
                public TestReport validate(SVGConverter c){
                    DestinationType type = c.getDestinationType();
                    if(type.equals(DestinationType.JPEG)){
                        return reportSuccess();
                    } else {
                        return reportError("-m", DestinationType.JPEG.toString(), "" + type);
                    }
                }
            
            };
    
        addTest(t);
        t.setId("MainConfigTest.mimeType.jpegB");

        t = new MainConfigTest("-m image/jpe") {
                public TestReport validate(SVGConverter c){
                    DestinationType type = c.getDestinationType();
                    if(type.equals(DestinationType.JPEG)){
                        return reportSuccess();
                    } else {
                        return reportError("-m", DestinationType.JPEG.toString(), "" + type);
                    }
                }
            
            };
    
        addTest(t);
        t.setId("MainConfigTest.mimeType.jpegC");

        t = new MainConfigTest("-m image/png") {
                public TestReport validate(SVGConverter c){
                    DestinationType type = c.getDestinationType();
                    if(type.equals(DestinationType.PNG)){
                        return reportSuccess();
                    } else {
                        return reportError("-m", DestinationType.PNG.toString(), "" + type);
                    }
                }
            
            };
    
        addTest(t);
        t.setId("MainConfigTest.mimeType.png");

        t = new MainConfigTest("-m application/pdf") {
                public TestReport validate(SVGConverter c){
                    DestinationType type = c.getDestinationType();
                    if(type.equals(DestinationType.PDF)){
                        return reportSuccess();
                    } else {
                        return reportError("-m", DestinationType.PDF.toString(), "" + type);
                    }
                }
            
            };
    
        addTest(t);
        t.setId("MainConfigTest.mimeType.pdf");

        t = new MainConfigTest("-m image/tiff") {
                public TestReport validate(SVGConverter c){
                    DestinationType type = c.getDestinationType();
                    if(type.equals(DestinationType.TIFF)){
                        return reportSuccess();
                    } else {
                        return reportError("-m", DestinationType.TIFF.toString(), "" + type);
                    }
                }
            
            };
    
        addTest(t);
        t.setId("MainConfigTest.mimeType.tiff");

        t = new MainConfigTest("-w 467.69") {
                public TestReport validate(SVGConverter c){
                    float width = c.getWidth();
                    if(width == 467.69f){
                        return reportSuccess();
                    } else {
                        return reportError("-w", "" + 467.69, "" + width);
                    }
                }
            
            };
    
        addTest(t);
        t.setId("MainConfigTest.width");

        t = new MainConfigTest("-h 345.67") {
                public TestReport validate(SVGConverter c){
                    float height = c.getHeight();
                    if(height == 345.67f){
                        return reportSuccess();
                    } else {
                        return reportError("-h", "" + 345.67, "" + height);
                    }
                }
            
            };
    
        addTest(t);
        t.setId("MainConfigTest.height");

        t = new MainConfigTest("-maxw 467.69") {
                public TestReport validate(SVGConverter c){
                    float maxWidth = c.getMaxWidth();
                    if(maxWidth == 467.69f){
                        return reportSuccess();
                    } else {
                        return reportError("-maxw", "" + 467.69, "" + maxWidth);
                    }
                }
            
            };
        addTest(t);
        t.setId("MainConfigTest.maxWidth");

        t = new MainConfigTest("-maxh 345.67") {
                public TestReport validate(SVGConverter c){
                    float maxHeight = c.getMaxHeight();
                    if(maxHeight == 345.67f){
                        return reportSuccess();
                    } else {
                        return reportError("-maxh", "" + 345.67, "" + maxHeight);
                    }
                }
            };
        addTest(t);
        t.setId("MainConfigTest.maxHeight");

        t = new MainConfigTest("-a 5,10,20,30") {
                public TestReport validate(SVGConverter c){
                    Rectangle2D aoi = c.getArea();
                    Rectangle2D.Float eAoi = new Rectangle2D.Float(5,10,20,30);
                    if(eAoi.equals(aoi)){
                        return reportSuccess();
                    } else {
                        return reportError("-a", toString(eAoi), toString(aoi));
                    }
                }

                public String toString(Rectangle2D r){
                    if (r == null){
                        return "null";
                    } else {
                        return r.getX() + "," + r.getY() + "," + r.getWidth() + "," + r.getHeight();
                    }
                }
            
            };
    
        addTest(t);
        t.setId("MainConfigTest.aoi");

    
        t = new MainConfigTest("-bg 128.200.100.50") {
                public TestReport validate(SVGConverter c){
                    Color bg = c.getBackgroundColor();
                    Color eBg = new Color(200,100,50,128); // Alpha is last
                    if(eBg.equals(bg)){
                        return reportSuccess();
                    } else {
                        return reportError("-bg", toString(eBg), toString(bg));
                    }
                }

                public String toString(Color c){
                    if (c==null){
                        return "null";
                    } else {
                        return c.getAlpha() + "." + c.getRed() + "." + c.getGreen() + "." + c.getBlue();
                    }
                }
            
            };
    
        addTest(t);
        t.setId("MainConfigTest.backgroundColor");

        t = new MainConfigTest("-cssMedia projection"){
                public TestReport validate(SVGConverter c){
                    String cssMedia = c.getMediaType();
                    String eCssMedia = "projection";
                    if(eCssMedia.equals(cssMedia)){
                        return reportSuccess();
                    } else {
                        return reportError("-cssMedia", eCssMedia, cssMedia);
                    }
                }
            };

        addTest(t);
        t.setId("MainConfigTest.cssMedia");


        t = new MainConfigTest("-font-family Arial, Comic Sans MS"){
                public TestReport validate(SVGConverter c){
                    String fontFamily = c.getDefaultFontFamily();
                    String eFontFamily = "Arial, Comic Sans MS";
                    if(eFontFamily.equals(fontFamily)){
                        return reportSuccess();
                    } else {
                        return reportError("-font-family", eFontFamily, fontFamily);
                    }
                }

                String[] makeArgsArray(String args) {
                    return new String[] {"-font-family",
                                        "Arial, Comic Sans MS"};
                }
            };

        addTest(t);
        t.setId("MainConfigTest.fontFamily");




        t = new MainConfigTest("-cssAlternate myAlternateStylesheet"){
                public TestReport validate(SVGConverter c){
                    String alternate = c.getAlternateStylesheet();
                    String eAlternate = "myAlternateStylesheet";
                    if(eAlternate.equals(alternate)){
                        return reportSuccess();
                    } else {
                        return reportError("-cssAlternate", eAlternate, alternate);
                    }
                }
            };
        addTest(t);
        t.setId("MainConfigTest.cssAlternate");

        t = new MainConfigTest("-validate"){
                public TestReport validate(SVGConverter c){
                    if(c.getValidate()){
                        return reportSuccess();
                    } else {
                        return reportError("-validate", "true", "false");
                    }
                }
            };

        addTest(t);
        t.setId("MainConfigTest.validate");

        t = new MainConfigTest("-onload"){
                public TestReport validate(SVGConverter c){
                    if(c.getExecuteOnload()){
                        return reportSuccess();
                    } else {
                        return reportError("-onload", "true", "false");
                    }
                }
            };

        addTest(t);
        t.setId("MainConfigTest.onload");

        t = new MainConfigTest("-scripts text/jpython"){
                public TestReport validate(SVGConverter c){
                    if("text/jpython".equals(c.getAllowedScriptTypes())){
                        return reportSuccess();
                    } else {
                        return reportError("-scripts", "text/jpython", ">>" + c.getAllowedScriptTypes() + "<<");
                    }
                }
            };

        addTest(t);
        t.setId("MainConfigTest.scripts");

        t = new MainConfigTest("-anyScriptOrigin"){
                public TestReport validate(SVGConverter c){
                    if(!c.getConstrainScriptOrigin()){
                        return reportSuccess();
                    } else {
                        return reportError("-anyScriptOrigin", "true", "false");
                    }
                }
            };

        addTest(t);
        t.setId("MainConfigTest.anyScriptOrigin");

        t = new MainConfigTest("-scriptSecurityOff"){
                public TestReport validate(SVGConverter c){
                    if(c.getSecurityOff()){
                        return reportSuccess();
                    } else {
                        return reportError("-scriptSecurityOff", "true", "false");
                    }
                }
            };

        addTest(t);
        t.setId("MainConfigTest.scriptSecurityOff");

        t = new MainConfigTest("-lang fr"){
                public TestReport validate(SVGConverter c){
                    if("fr".equals(c.getLanguage())){
                        return reportSuccess();
                    } else {
                        return reportError("-lang", "fr", c.getLanguage());
                    }
                }
            };
        addTest(t);
        t.setId("MainConfigTest.lang");

        t = new MainConfigTest("-cssUser myStylesheet.css"){
                public TestReport validate(SVGConverter c){
                    if("myStylesheet.css".equals(c.getUserStylesheet())){
                        return reportSuccess();
                    } else {
                        return reportError("-cssUser", "myStylesheet.css", c.getUserStylesheet());
                    }
                }
            };
        addTest(t);
        t.setId("MainConfigTest.cssUser");

        t = new MainConfigTest("-dpi 5.08"){
                public TestReport validate(SVGConverter c){
                    if(c.getPixelUnitToMillimeter() == 5f){
                        return reportSuccess();
                    } else {
                        return reportError("-dpi", "5f", "" + c.getPixelUnitToMillimeter());
                    }
                }
            };
        addTest(t);
        t.setId("MainConfigTest.dpi");

        t = new MainConfigTest("-q .5"){
                public TestReport validate(SVGConverter c){
                    if(c.getQuality() == .5f){
                        return reportSuccess();
                    } else {
                        return reportError("-q", ".5f", "" + c.getQuality());
                    }
                }
            };
        addTest(t);
        t.setId("MainConfigTest.quality");

        t = new MainConfigTest("-indexed 8"){
                public TestReport validate(SVGConverter c){
                    if(c.getIndexed() == 8){
                        return reportSuccess();
                    } else {
                        return reportError("-indexed", "8", 
                                           "" + c.getIndexed());
                    }
                }
            };
        addTest(t);
        t.setId("MainConfigTest.indexed");

        t = new MainConfigErrorTest("-d", "hello.svg -d");
        addTest(t);
        t.setId("MainConfigErrorTest.output");

        t = new MainConfigErrorTest("-m", "hello.svg -m");
        addTest(t);
        t.setId("MainConfigErrorTest.mimeType");

        t = new MainConfigErrorTest("-w", "hello.svg -w");
        addTest(t);
        t.setId("MainConfigErrorTest.width");

        t = new MainConfigErrorTest("-h", "hello.svg -h");
        addTest(t);
        t.setId("MainConfigErrorTest.height");

        t = new MainConfigErrorTest("-maxw", "hello.svg -maxw");
        addTest(t);
        t.setId("MainConfigErrorTest.maxWidth");

        t = new MainConfigErrorTest("-maxh", "hello.svg -maxh");
        addTest(t);
        t.setId("MainConfigErrorTest.maxHeight");

        t = new MainConfigErrorTest("-a", "hello.svg -a");
        addTest(t);
        t.setId("MainConfigErrorTest.area");

        t = new MainConfigErrorTest("-bg", "hello.svg -bg");
        addTest(t);
        t.setId("MainConfigErrorTest.backgroundColor");

        t = new MainConfigErrorTest("-cssMedia", "hello.svg -cssMedia");
        addTest(t);
        t.setId("MainConfigErrorTest.mediaType");

        t = new MainConfigErrorTest("-font-family", "hello.svg -font-family");
        addTest(t);
        t.setId("MainConfigErrorTest.font-family");

        t = new MainConfigErrorTest("-cssAlternate", "hello.svg -cssAlternate");
        addTest(t);
        t.setId("MainConfigErrorTest.cssAlternate");

        t = new MainConfigErrorTest("-lang", "hello.svg -lang");
        addTest(t);
        t.setId("MainConfigErrorTest.lang");

        t = new MainConfigErrorTest("-cssUser", "hello.svg -cssUser");
        addTest(t);
        t.setId("MainConfigErrorTest.cssUser");

        t = new MainConfigErrorTest("-dpi", "hello.svg -dpi");
        addTest(t);
        t.setId("MainConfigErrorTest.dpi");

        t = new MainConfigErrorTest("-q", "hello.svg -q");
        addTest(t);
        t.setId("MainConfigErrorTest.quality");

        t = new MainConfigErrorTest("-scripts", "hello.svg -scripts");
        addTest(t);
        t.setId("MainConfigErrorTest.allowedScriptTypes");

        t = new MainIllegalArgTest("-m", "-m images/jpeq");
        addTest(t);
        t.setId("MainIllegalArgTest.mediaType");

        t = new MainIllegalArgTest("-w", "-w abd");
        addTest(t);
        t.setId("MainIllegalArgTest.width");

        t = new MainIllegalArgTest("-h", "-h abaa");
        addTest(t);
        t.setId("MainIllegalArgTest.height");

        t = new MainIllegalArgTest("-maxw", "-maxw abd");
        addTest(t);
        t.setId("MainIllegalArgTest.maxWidth");

        t = new MainIllegalArgTest("-maxh", "-maxh abaa");
        addTest(t);
        t.setId("MainIllegalArgTest.maxHeight");

        t = new MainIllegalArgTest("a", "-a aaaaaa");
        addTest(t);
        t.setId("MainIllegalArgTest.aoi");

        t = new MainIllegalArgTest("bg", "-bg a.b.c.d");
        addTest(t);
        t.setId("MainIllegalArgTest.bg");

        t = new MainIllegalArgTest("dpi", "-dpi invalidDPI");
        addTest(t);
        t.setId("MainIllegalArgTest.dpi");

        t = new MainIllegalArgTest("q", "-q illegalQuality");
        addTest(t);
        t.setId("MainIllegalArgTest.q");

    }

}

class MainIllegalArgTest extends AbstractTest {
    String badOption;
    String args;
    TestReport report;

    public MainIllegalArgTest(String badOption, String args){
        this.badOption = badOption;
        this.args = args;
    }

    public String getName(){
        return getId();
    }

    public static final String ERROR_NO_ERROR_REPORTED
        = "MainIllegalArgTest.error.no.error.reported";

    public static final String ERROR_UNEXPECTED_ERROR_CODE
        = "MainIllegalArgTest.error.unexpected.error.code";

    public static final String ENTRY_KEY_EXPECTED_ERROR_CODE
        = "MainIllegalArgTest.entry.key.expected.error.code";

    public static final String ENTRY_KEY_GOT_ERROR_CODE
        = "MainIllegalArgTest.entry.key.got.error.code";

    public TestReport runImpl() throws Exception {
        String[] argsArray = makeArgsArray(args);
        Main main = new Main(argsArray) {
                public void error(String errorCode, 
                                  Object[] errorArgs){
                    if (Main.ERROR_ILLEGAL_ARGUMENT.equals(errorCode)){
                        report = reportSuccess();
                    } else {
                        report = reportError(ERROR_UNEXPECTED_ERROR_CODE);
                        report.addDescriptionEntry(ENTRY_KEY_EXPECTED_ERROR_CODE,
                                                   Main.ERROR_ILLEGAL_ARGUMENT);
                        report.addDescriptionEntry(ENTRY_KEY_GOT_ERROR_CODE,
                                                   errorCode);
                    }
                }
                                  
                
            };

        main.execute();

        if (report == null){
            report = reportError(ERROR_NO_ERROR_REPORTED);
        }

        return report;
    }

    String[] makeArgsArray(String args){
        StringTokenizer st = new StringTokenizer(args, " ");
        String[] argsArray = new String[st.countTokens()];
        for (int i=0; i<argsArray.length; i++){
            argsArray[i] = st.nextToken();
        }

        return argsArray;
    }

}

class MainConfigErrorTest extends AbstractTest {
    String badOption;
    String args;
    TestReport report = null;

    public static final String ERROR_UNEXPECTED_ERROR_ARGS_0
        = "MainConfigErrorTest.error.unexpected.error.args.0";

    public static final String ERROR_UNEXPECTED_ERROR_CODE
        = "MainConfigErrorTest.error.unexpected.error.code";

    public static final String ERROR_NO_ERROR_REPORTED
        = "MainConfigErrorTest.error.no.error.reported";

    public static final String ENTRY_KEY_EXPECTED_ERROR_ARGS_0
        = "MainConfigErrorTest.entry.key.expected.error.args.0";

    public static final String ENTRY_KEY_GOT_ERROR_ARGS_0
        = "MainConfigErrorTest.entry.key.got.error.args.0";

    public static final String ENTRY_KEY_EXPECTED_ERROR_CODE
        = "MainConfigErrorTest.entry.key.expected.error.code";

    public static final String ENTRY_KEY_GOT_ERROR_CODE
        = "MainConfigErrorTest.entry.key.got.error.code";

    public MainConfigErrorTest(String badOption, String args){
        this.badOption = badOption;
        this.args = args;
    }

    public String getName(){
        return getId();
    }

    public TestReport runImpl() throws Exception {
        String[] argsArray = makeArgsArray(args);
        Main main = new Main(argsArray) {
                public void error(String errorCode, 
                                  Object[] errorArgs){
                    if (Main.ERROR_NOT_ENOUGH_OPTION_VALUES.equals(errorCode)){
                        if(errorArgs != null && errorArgs.length > 0 && badOption.equals(errorArgs[0])){
                            report = reportSuccess();
                        } else {
                            report = reportError(ERROR_UNEXPECTED_ERROR_ARGS_0);
                            report.addDescriptionEntry(ENTRY_KEY_EXPECTED_ERROR_ARGS_0,
                                                       badOption);
                            report.addDescriptionEntry(ENTRY_KEY_GOT_ERROR_ARGS_0,
                                                       errorArgs!= null && errorArgs.length>0 ? errorArgs[0] : "none");
                        }
                    } else {
                        report = reportError(ERROR_UNEXPECTED_ERROR_CODE);
                        report.addDescriptionEntry(ENTRY_KEY_EXPECTED_ERROR_CODE,
                                                   Main.ERROR_NOT_ENOUGH_OPTION_VALUES);
                        report.addDescriptionEntry(ENTRY_KEY_GOT_ERROR_CODE,
                                                   errorCode);
                    }
                }
                                  
                
            };

        main.execute();

        if (report == null){
            report = reportError(ERROR_NO_ERROR_REPORTED);
        }

        return report;
    }

    String[] makeArgsArray(String args){
        StringTokenizer st = new StringTokenizer(args, " ");
        String[] argsArray = new String[st.countTokens()];
        for (int i=0; i<argsArray.length; i++){
            argsArray[i] = st.nextToken();
        }

        return argsArray;
    }
}

abstract class MainConfigTest extends AbstractTest {
    String args;
    TestReport report;

    static final String ERROR_UNEXPECTED_OPTION_VALUE 
        = "MainConfigTest.error.unexpected.option.value";

    static final String ENTRY_KEY_OPTION
        = "MainConfigTest.entry.key.option";

    static final String ENTRY_KEY_EXPECTED_VALUE
        = "MainConfigTest.entry.key.expected.value";

    static final String ENTRY_KEY_ACTUAL_VALUE
        = "MainConfigTest.entry.key.actual.value";

    public TestReport reportError(String option,
                                  String expectedValue,
                                  String actualValue){
        TestReport report = reportError(ERROR_UNEXPECTED_OPTION_VALUE);
        report.addDescriptionEntry(ENTRY_KEY_OPTION, option);
        report.addDescriptionEntry(ENTRY_KEY_EXPECTED_VALUE, expectedValue);
        report.addDescriptionEntry(ENTRY_KEY_ACTUAL_VALUE, actualValue);
        return report;
    }

    public MainConfigTest(String args){
        this.args = args;
    }

    public String getName(){
        return getId();
    }

    public TestReport runImpl() throws Exception {
        String[] argsArray = makeArgsArray(args);
        Main main = new Main(argsArray) {
                public void validateConverterConfig(SVGConverter c){
                    report = validate(c);
                }
                
            };

        main.execute();

        return report;
    }

    public abstract TestReport validate(SVGConverter c);

    String[] makeArgsArray(String args){
        StringTokenizer st = new StringTokenizer(args, " ");
        String[] argsArray = new String[st.countTokens()];
        for (int i=0; i<argsArray.length; i++){
            argsArray[i] = st.nextToken();
        }

        return argsArray;
    }


}

