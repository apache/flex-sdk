/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

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
import java.util.Iterator;
import java.util.Map;
import java.util.StringTokenizer;
import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;

import org.apache.flex.forks.batik.transcoder.Transcoder;
import org.apache.flex.forks.batik.parser.ClockHandler;
import org.apache.flex.forks.batik.parser.ClockParser;
import org.apache.flex.forks.batik.parser.ParseException;
import org.apache.flex.forks.batik.util.ApplicationSecurityEnforcer;

/**
 * Handles command line parameters to configure the <tt>SVGConverter</tt>
 * and rasterizer images. <br />
 *
 * Each command line option is handled by an <tt>OptionHandler</tt> which
 * is responsible for converting the option into a configuration of the
 * <tt>SVGConverter</tt> which is used to perform the conversion.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: Main.java 504084 2007-02-06 11:24:46Z dvholten $
 */
public class Main implements SVGConverterController {
    /**
     * URL for Squiggle's security policy file
     */
    public static final String RASTERIZER_SECURITY_POLICY
        = "org/apache/batik/apps/rasterizer/resources/rasterizer.policy";

    /**
     * Interface for handling one command line option
     */
    public static interface OptionHandler {
        /**
         * The <tt>OptionHandler</tt> should configure the <tt>SVGConverter</tt>
         * according to the value of the option.
         *
         * Should throw an IllegalArgumentException if optionValue
         * is not an acceptable option.
         */
        void handleOption(String[] optionValues, SVGConverter c);

        /**
         * Returns the number of values which the option handler requires.
         * This defines the length of the optionValues array passed to
         * the handler in the handleOption method
         */
        int getOptionValuesLength();

        /**
         * Returns the description for this option
         */
        String getOptionDescription();
    }

    /**
     * This abstract implementation of the <tt>OptionHandler</tt> interface
     * throws an exception if the number of arguments passed to the
     * <tt>handleOption</tt> method does not match the number of expected
     * optionValues. If the size matches, the <tt>safeHandleOption</tt>
     * method is invoked.
     * Subclasses can implement the <tt>safeHandleOption</tt> method
     * assuming that the input array size is correct.
     */
    public abstract static class AbstractOptionHandler implements OptionHandler {

        public void handleOption(String[] optionValues, SVGConverter c){
            int nOptions = optionValues != null? optionValues.length: 0;
            if (nOptions != getOptionValuesLength()){
                throw new IllegalArgumentException();
            }

            safeHandleOption(optionValues, c);
        }

        public abstract void safeHandleOption(String[] optionValues, SVGConverter c);
    }

    /**
     * Base class for options with no option value (i.e., the presence
     * of the option means something in itself. Subclasses should implement
     * the <tt>handleOption</tt> method which takes only an <tt>SVGConverter</tt>
     * as a parameter.
     */
    public abstract static class NoValueOptionHandler extends AbstractOptionHandler {
        public void safeHandleOption(String[] optionValues, SVGConverter c){
            handleOption(c);
        }

        public int getOptionValuesLength(){
            return 0;
        }

        public abstract void handleOption(SVGConverter c);
    }

    /**
     * Base class for options with a single option value. Subclasses should
     * provide an implementation for the <tt>handleOption</tt> method which
     * takes a <tt>String</tt> and an <tt>SVGConverter</tt> as parameters.
     */
    public abstract static class SingleValueOptionHandler extends AbstractOptionHandler {
        public void safeHandleOption(String[] optionValues, SVGConverter c){
            handleOption(optionValues[0], c);
        }

        public int getOptionValuesLength(){
            return 1;
        }

        public abstract void handleOption(String optionValue, SVGConverter c);
    }

    /**
     * Base class for options which expect the single optionValue to
     * be a float. Subclasses should implement the <tt>handleOption</tt>
     * method which takes a float and an <tt>SVGConverter</tt> as
     * parameters.
     */
    public abstract static class FloatOptionHandler extends SingleValueOptionHandler {
        public void handleOption(String optionValue, SVGConverter c){
            try{
                handleOption(Float.parseFloat(optionValue), c);
            } catch(NumberFormatException e){
                throw new IllegalArgumentException();
            }
        }

        public abstract void handleOption(float optionValue, SVGConverter c);
    }

    /**
     * Base class for options which expect the single optionValue to
     * be a time value. Subclasses should implement the <tt>handleOption</tt>
     * method which takes a float and an <tt>SVGConverter</tt> as
     * parameters.
     */
    public abstract static class TimeOptionHandler extends FloatOptionHandler {
        public void handleOption(String optionValue, final SVGConverter c) {
            try {
                ClockParser p = new ClockParser(false);
                p.setClockHandler(new ClockHandler() {
                    public void clockValue(float v) {
                        handleOption(v, c);
                    }
                });
                p.parse(optionValue);
            } catch (ParseException e) {
                throw new IllegalArgumentException();
            }
        }

        public abstract void handleOption(float optionValue, SVGConverter c);
    }

    /**
     * Base class for options which expect a <tt>Rectangle</tt> optionValue.
     * Subclasses should implement the <tt>handleOption</tt> method which
     * takes a <tt>Rectangle</tt> and an <tt>SVGConverter</tt> as parameters.
     */
    public abstract static class RectangleOptionHandler extends SingleValueOptionHandler {
        public void handleOption(String optionValue, SVGConverter c){
            Rectangle2D r = parseRect(optionValue);
            if (r==null){
                throw new IllegalArgumentException();
            }
            handleOption(r, c);
        }

        public abstract void handleOption(Rectangle2D r, SVGConverter c);

        public Rectangle2D.Float parseRect(String rectValue){
            Rectangle2D.Float rect = null;
            if(rectValue != null){
                if (!rectValue.toLowerCase().endsWith("f")){
                    rectValue += "f";
                }

                StringTokenizer st = new StringTokenizer(rectValue, ",");
                if(st.countTokens() == 4){
                    String xStr = st.nextToken();
                    String yStr = st.nextToken();
                    String wStr = st.nextToken();
                    String hStr = st.nextToken();
                    float x=Float.NaN, y=Float.NaN, w=Float.NaN, h=Float.NaN;
                    try {
                        x = Float.parseFloat(xStr);
                        y = Float.parseFloat(yStr);
                        w = Float.parseFloat(wStr);
                        h = Float.parseFloat(hStr);
                    }catch(NumberFormatException e){
                        // If an error occured, the x, y, w, h
                        // values will not be valid
                    }

                    if( !Float.isNaN(x)
                        &&
                        !Float.isNaN(y)
                        &&
                        (!Float.isNaN(w) && w > 0)
                        &&
                        (!Float.isNaN(h) && h > 0) ){
                        rect = new Rectangle2D.Float(x, y, w, h);
                    }
                }
            }
            return rect;
        }
    }

    /**
     * Base class for options which expect a <tt>Color</tt> optionValue.
     * Subclasses should implement the <tt>handleOption</tt> method which
     * takes a <tt>Color</tt> and an <tt>SVGConverter</tt> as parameters.
     */
    public abstract static class ColorOptionHandler extends SingleValueOptionHandler {
        public void handleOption(String optionValue, SVGConverter c){
            Color color = parseARGB(optionValue);
            if (color==null){
                throw new IllegalArgumentException();
            }
            handleOption(color, c);
        }

        public abstract void handleOption(Color color, SVGConverter c);

        /**
         * Parse the input value, which should be in the following
         * format: a.r.g.b where a, r, g and b are integer values,
         * in decimal notation, between 0 and 255.
         * @return the parsed color if successful. null otherwise.
         */
        public Color parseARGB(String argbVal){
            Color c = null;
            if(argbVal != null){
                StringTokenizer st = new StringTokenizer(argbVal, ".");
                if(st.countTokens() == 4){
                    String aStr = st.nextToken();
                    String rStr = st.nextToken();
                    String gStr = st.nextToken();
                    String bStr = st.nextToken();
                    int a = -1, r = -1, g = -1, b = -1;
                    try {
                        a = Integer.parseInt(aStr);
                        r = Integer.parseInt(rStr);
                        g = Integer.parseInt(gStr);
                        b = Integer.parseInt(bStr);
                    }catch(NumberFormatException e){
                        // If an error occured, the a, r, g, b
                        // values will not be in the 0-255 range
                        // and the next if test will fail
                    }

                    if( a>=0 && a<=255
                        &&
                        r>=0 && r<=255
                        &&
                        g>=0 && g<=255
                        &&
                        b>=0 && b<=255 ){
                        c = new Color(r,g,b,a);
                    }
                }
            }
            return c;
        }
    }



    /**
     * Describes the command line options for the rasterizer
     */
    public static String USAGE =
        Messages.formatMessage("Main.usage", null);

    //
    // The command line options are found in the properties
    // file.
    //

    /**
     * Option to specify the output directory or file
     */
    public static String CL_OPTION_OUTPUT
        = Messages.get("Main.cl.option.output", "-d");

    public static String CL_OPTION_OUTPUT_DESCRIPTION
        = Messages.get("Main.cl.option.output.description", "No description");

    /**
     * Option to specify the output image's mime type
     */
    public static String CL_OPTION_MIME_TYPE
        = Messages.get("Main.cl.option.mime.type", "-m");

    public static String CL_OPTION_MIME_TYPE_DESCRIPTION
        = Messages.get("Main.cl.option.mime.type.description", "No description");

    /**
     * Option to specify the output image's width
     */
    public static String CL_OPTION_WIDTH
        = Messages.get("Main.cl.option.width", "-w");

    public static String CL_OPTION_WIDTH_DESCRIPTION
        = Messages.get("Main.cl.option.width.description", "No description");

    /**
     * Option to specify the output image's height
     */
    public static String CL_OPTION_HEIGHT
        = Messages.get("Main.cl.option.height", "-h");

    public static String CL_OPTION_HEIGHT_DESCRIPTION
        = Messages.get("Main.cl.option.height.description", "No description");

    /**
     * Option to specify the output image's maximum width.
     */
    public static String CL_OPTION_MAX_WIDTH
        = Messages.get("Main.cl.option.max.width", "-maxw");

    public static String CL_OPTION_MAX_WIDTH_DESCRIPTION
        = Messages.get("Main.cl.option.max.width.description", "No description");

    /**
     * Option to specify the output image's maximum height.
     */
    public static String CL_OPTION_MAX_HEIGHT
        = Messages.get("Main.cl.option.max.height", "-maxh");

    public static String CL_OPTION_MAX_HEIGHT_DESCRIPTION
        = Messages.get("Main.cl.option.max.height.description", "No description");

    /**
     * Option to specify the area of interest in the output
     * image.
     */
    public static String CL_OPTION_AOI
        = Messages.get("Main.cl.option.aoi", "-a");

    public static String CL_OPTION_AOI_DESCRIPTION
        = Messages.get("Main.cl.option.aoi.description", "No description");

    /**
     * Option to specify the output image's background color
     */
    public static String CL_OPTION_BACKGROUND_COLOR
        = Messages.get("Main.cl.option.background.color", "-bg");

    public static String CL_OPTION_BACKGROUND_COLOR_DESCRIPTION
        = Messages.get("Main.cl.option.background.color.description", "No description");

    /**
     * Option to specify the CSS media type when converting
     * the SVG image
     */
    public static String CL_OPTION_MEDIA_TYPE
        = Messages.get("Main.cl.option.media.type", "-cssMedia");

    public static String CL_OPTION_MEDIA_TYPE_DESCRIPTION
        = Messages.get("Main.cl.option.media.type.description", "No description");

    /**
     * Option to specify the default value for the font-family
     * CSS property when converting the SVG image
     */
    public static String CL_OPTION_DEFAULT_FONT_FAMILY
        = Messages.get("Main.cl.option.default.font.family", "-font-family");

    public static String CL_OPTION_DEFAULT_FONT_FAMILY_DESCRIPTION
        = Messages.get("Main.cl.option.default.font.family.description", "No description");

    /**
     * Option to specify the CSS alternate stylesheet when
     * converting the SVG images
     */
    public static String CL_OPTION_ALTERNATE_STYLESHEET
        = Messages.get("Main.cl.option.alternate.stylesheet", "-cssAlternate");

    public static String CL_OPTION_ALTERNATE_STYLESHEET_DESCRIPTION
        = Messages.get("Main.cl.option.alternate.stylesheet.description", "No description");

    /**
     * Option to specify that the converted SVG files should
     * be validated during the conversion process.
     */
    public static String CL_OPTION_VALIDATE
        = Messages.get("Main.cl.option.validate", "-validate");

    public static String CL_OPTION_VALIDATE_DESCRIPTION
        = Messages.get("Main.cl.option.validate.description", "No description");

    /**
     * Option to specify that the converted SVG files should
     * be after the dispatch of the 'onload' event.
     */
    public static String CL_OPTION_ONLOAD
        = Messages.get("Main.cl.option.onload", "-onload");

    public static String CL_OPTION_ONLOAD_DESCRIPTION
        = Messages.get("Main.cl.option.onload.description", "No description");

    /**
     * Option to specify that the document should be rasterized after
     * seeking to the specified document time.
     */
    public static String CL_OPTION_SNAPSHOT_TIME
        = Messages.get("Main.cl.option.snapshot.time", "-snapshotTime");

    public static String CL_OPTION_SNAPSHOT_TIME_DESCRIPTION
        = Messages.get("Main.cl.option.snapshot.time.description", "No description");

    /**
     * Option to specify the user language with which SVG
     * documents should be processed
     */
    public static String CL_OPTION_LANGUAGE
        = Messages.get("Main.cl.option.language", "-lang");

    public static String CL_OPTION_LANGUAGE_DESCRIPTION
        = Messages.get("Main.cl.option.language.description", "No description");

    /**
     * Option to specify an addition user stylesheet
     */
    public static String CL_OPTION_USER_STYLESHEET
        = Messages.get("Main.cl.option.user.stylesheet", "-cssUser");

    public static String CL_OPTION_USER_STYLESHEET_DESCRIPTION
        = Messages.get("Main.cl.option.user.stylesheet.description", "No description");

    /**
     * Option to specify the resolution for the output image
     */
    public static String CL_OPTION_DPI
        = Messages.get("Main.cl.option.dpi", "-dpi");

    public static String CL_OPTION_DPI_DESCRIPTION
        = Messages.get("Main.cl.option.dpi.description", "No description");

    /**
     * Option to specify the output JPEG quality
     */
    public static String CL_OPTION_QUALITY
        = Messages.get("Main.cl.option.quality", "-q");

    public static String CL_OPTION_QUALITY_DESCRIPTION
        = Messages.get("Main.cl.option.quality.description", "No description");

    /**
     * Option to specify if the PNG should be indexed.
     */
    public static String CL_OPTION_INDEXED
        = Messages.get("Main.cl.option.indexed", "-indexed");

    public static String CL_OPTION_INDEXED_DESCRIPTION
        = Messages.get("Main.cl.option.indexed.description", "No description");

    /**
     * Option to specify the set of allowed scripts
     */
    public static String CL_OPTION_ALLOWED_SCRIPTS
        = Messages.get("Main.cl.option.allowed.scripts", "-scripts");

    public static String CL_OPTION_ALLOWED_SCRIPTS_DESCRIPTION
        = Messages.get("Main.cl.option.allowed.scripts.description", "No description");

    /**
     * Option to determine whether scripts a constrained to the
     * same origin as the document referencing them.
     */
    public static String CL_OPTION_CONSTRAIN_SCRIPT_ORIGIN
        = Messages.get("Main.cl.option.constrain.script.origin", "-anyScriptOrigin");

    public static String CL_OPTION_CONSTRAIN_SCRIPT_ORIGIN_DESCRIPTION
        = Messages.get("Main.cl.option.constrain.script.origin.description", "No description");

    /**
     * Option to turn off secure execution of scripts
     */
    public static String CL_OPTION_SECURITY_OFF
        = Messages.get("Main.cl.option.security.off", "-scriptSecurityOff");

    public static String CL_OPTION_SECURITY_OFF_DESCRIPTION
        = Messages.get("Main.cl.option.security.off.description", "No description");

    /**
     * Static map containing all the option handlers able to analyze the
     * various options.
     */
    protected static Map optionMap = new HashMap();

    /**
     * Static map containing all the mime types understood by the
     * rasterizer
     */
    protected static Map mimeTypeMap = new HashMap();

    /**
     * Static initializer: adds all the option handlers to the
     * map of option handlers.
     */
    static {
        mimeTypeMap.put("image/jpg", DestinationType.JPEG);
        mimeTypeMap.put("image/jpeg", DestinationType.JPEG);
        mimeTypeMap.put("image/jpe", DestinationType.JPEG);
        mimeTypeMap.put("image/png", DestinationType.PNG);
        mimeTypeMap.put("application/pdf", DestinationType.PDF);
        mimeTypeMap.put("image/tiff", DestinationType.TIFF);

        optionMap.put(CL_OPTION_OUTPUT,
                      new SingleValueOptionHandler(){
                              public void handleOption(String optionValue,
                                                       SVGConverter c){
                                  c.setDst(new File(optionValue));
                              }
                              public String getOptionDescription(){
                                  return CL_OPTION_OUTPUT_DESCRIPTION;
                              }
                          });

        optionMap.put(CL_OPTION_MIME_TYPE,
                      new SingleValueOptionHandler(){
                              public void handleOption(String optionValue,
                                                       SVGConverter c){
                                  DestinationType dstType =
                                      (DestinationType)mimeTypeMap.get(optionValue);

                                  if (dstType == null){
                                      throw new IllegalArgumentException();
                                  }

                                  c.setDestinationType(dstType);
                              }

                              public String getOptionDescription(){
                                  return CL_OPTION_MIME_TYPE_DESCRIPTION;
                              }
                          });

        optionMap.put(CL_OPTION_WIDTH,
                      new FloatOptionHandler(){
                              public void handleOption(float optionValue,
                                                       SVGConverter c){
                                  if (optionValue <= 0){
                                      throw new IllegalArgumentException();
                                  }

                                  c.setWidth(optionValue);
                              }

                              public String getOptionDescription(){
                                  return CL_OPTION_WIDTH_DESCRIPTION;
                              }
                          });

        optionMap.put(CL_OPTION_HEIGHT,
                      new FloatOptionHandler(){
                              public void handleOption(float optionValue,
                                                       SVGConverter c){
                                  if (optionValue <= 0){
                                      throw new IllegalArgumentException();
                                  }

                                  c.setHeight(optionValue);
                              }

                              public String getOptionDescription(){
                                  return CL_OPTION_HEIGHT_DESCRIPTION;
                              }
                          });

        optionMap.put(CL_OPTION_MAX_WIDTH,
                      new FloatOptionHandler(){
                              public void handleOption(float optionValue,
                                                       SVGConverter c){
                                  if (optionValue <= 0){
                                      throw new IllegalArgumentException();
                                  }

                                  c.setMaxWidth(optionValue);
                              }

                              public String getOptionDescription(){
                                  return CL_OPTION_MAX_WIDTH_DESCRIPTION;
                              }
                          });

        optionMap.put(CL_OPTION_MAX_HEIGHT,
                      new FloatOptionHandler(){
                              public void handleOption(float optionValue,
                                                       SVGConverter c){
                                  if (optionValue <= 0){
                                      throw new IllegalArgumentException();
                                  }

                                  c.setMaxHeight(optionValue);
                              }

                              public String getOptionDescription(){
                                  return CL_OPTION_MAX_HEIGHT_DESCRIPTION;
                              }
                          });

        optionMap.put(CL_OPTION_AOI,
                      new RectangleOptionHandler(){
                              public void handleOption(Rectangle2D optionValue,
                                                       SVGConverter c){
                                  c.setArea(optionValue);
                              }

                              public String getOptionDescription(){
                                  return CL_OPTION_AOI_DESCRIPTION;
                              }
                          });

        optionMap.put(CL_OPTION_BACKGROUND_COLOR,
                      new ColorOptionHandler(){
                              public void handleOption(Color optionValue,
                                                       SVGConverter c){
                                  c.setBackgroundColor(optionValue);
                              }

                              public String getOptionDescription(){
                                  return CL_OPTION_BACKGROUND_COLOR_DESCRIPTION;
                              }
                          });

        optionMap.put(CL_OPTION_MEDIA_TYPE,
                      new SingleValueOptionHandler(){
                              public void handleOption(String optionValue,
                                                       SVGConverter c){
                                  c.setMediaType(optionValue);
                              }

                              public String getOptionDescription(){
                                  return CL_OPTION_MEDIA_TYPE_DESCRIPTION;
                              }
                          });

        optionMap.put(CL_OPTION_DEFAULT_FONT_FAMILY,
                      new SingleValueOptionHandler() {
                          public void handleOption(String optionValue,
                                                   SVGConverter c){
                              c.setDefaultFontFamily(optionValue);
                          }

                          public String getOptionDescription(){
                              return CL_OPTION_DEFAULT_FONT_FAMILY_DESCRIPTION;
                          }
                      });

        optionMap.put(CL_OPTION_ALTERNATE_STYLESHEET,
                      new SingleValueOptionHandler(){
                              public void handleOption(String optionValue,
                                                       SVGConverter c){
                                  c.setAlternateStylesheet(optionValue);
                              }

                              public String getOptionDescription(){
                                  return CL_OPTION_ALTERNATE_STYLESHEET_DESCRIPTION;
                              }
                          });

        optionMap.put(CL_OPTION_USER_STYLESHEET,
                      new SingleValueOptionHandler(){
                              public void handleOption(String optionValue,
                                                       SVGConverter c){
                                  c.setUserStylesheet(optionValue);
                              }

                              public String getOptionDescription(){
                                  return CL_OPTION_USER_STYLESHEET_DESCRIPTION;
                              }
                          });

        optionMap.put(CL_OPTION_LANGUAGE,
                      new SingleValueOptionHandler(){
                              public void handleOption(String optionValue,
                                                       SVGConverter c){
                                  c.setLanguage(optionValue);
                              }

                              public String getOptionDescription(){
                                  return CL_OPTION_LANGUAGE_DESCRIPTION;
                              }
                          });

        optionMap.put(CL_OPTION_DPI,
                      new FloatOptionHandler(){
                              public void handleOption(float optionValue,
                                                       SVGConverter c){
                                  if (optionValue <= 0){
                                      throw new IllegalArgumentException();
                                  }

                                  c.setPixelUnitToMillimeter
                                      ((2.54f/optionValue)*10);
                              }

                              public String getOptionDescription(){
                                  return CL_OPTION_DPI_DESCRIPTION;
                              }
                          });

        optionMap.put(CL_OPTION_QUALITY,
                      new FloatOptionHandler(){
                              public void handleOption(float optionValue,
                                                       SVGConverter c){
                                  if (optionValue <= 0 || optionValue >= 1){
                                      throw new IllegalArgumentException();
                                  }

                                  c.setQuality(optionValue);
                              }

                              public String getOptionDescription(){
                                  return CL_OPTION_QUALITY_DESCRIPTION;
                              }
                          });

        optionMap.put(CL_OPTION_INDEXED,
                      new FloatOptionHandler(){
                              public void handleOption(float optionValue,
                                                       SVGConverter c){
                                  if ((optionValue != 1) &&
                                      (optionValue != 2) &&
                                      (optionValue != 4) &&
                                      (optionValue != 8))
                                      throw new IllegalArgumentException();

                                  c.setIndexed((int)optionValue);
                              }

                              public String getOptionDescription(){
                                  return CL_OPTION_INDEXED_DESCRIPTION;
                              }
                          });
        optionMap.put(CL_OPTION_VALIDATE,
                      new NoValueOptionHandler(){
                              public void handleOption(SVGConverter c){
                                  c.setValidate(true);
                             }

                              public String getOptionDescription(){
                                  return CL_OPTION_VALIDATE_DESCRIPTION;
                              }
                          });
        optionMap.put(CL_OPTION_ONLOAD,
                      new NoValueOptionHandler(){
                              public void handleOption(SVGConverter c){
                                  c.setExecuteOnload(true);
                             }

                              public String getOptionDescription(){
                                  return CL_OPTION_ONLOAD_DESCRIPTION;
                              }
                          });

        optionMap.put(CL_OPTION_SNAPSHOT_TIME,
                      new TimeOptionHandler(){
                              public void handleOption(float optionValue,
                                                       SVGConverter c){
                                  c.setExecuteOnload(true);
                                  c.setSnapshotTime(optionValue);
                              }

                              public String getOptionDescription(){
                                  return CL_OPTION_SNAPSHOT_TIME_DESCRIPTION;
                              }
                          });

        optionMap.put(CL_OPTION_ALLOWED_SCRIPTS,
                      new SingleValueOptionHandler() {
                          public void handleOption(String optionValue,
                                                   SVGConverter c){
                              c.setAllowedScriptTypes(optionValue);
                          }

                          public String getOptionDescription(){
                              return CL_OPTION_ALLOWED_SCRIPTS_DESCRIPTION;
                          }
                      });

        optionMap.put(CL_OPTION_CONSTRAIN_SCRIPT_ORIGIN,
                      new NoValueOptionHandler(){
                          public void handleOption(SVGConverter c){
                              c.setConstrainScriptOrigin(false);
                          }

                          public String getOptionDescription(){
                              return CL_OPTION_CONSTRAIN_SCRIPT_ORIGIN_DESCRIPTION;
                          }
                      });

        optionMap.put(CL_OPTION_SECURITY_OFF,
                      new NoValueOptionHandler() {
                          public void handleOption(SVGConverter c){
                              c.setSecurityOff(true);
                          }

                          public String getOptionDescription(){
                              return CL_OPTION_SECURITY_OFF_DESCRIPTION;
                          }
                      });
    }

    /**
     * List of arguments describing the conversion task to be
     * performed.
     */
    protected List args;

    public Main(String[] args){
        this.args = new ArrayList();
        for (int i=0; i<args.length; i++){
            this.args.add(args[i]);
        }
    }

    protected void error(String errorCode,
                         Object[] errorArgs){
        System.err.println(Messages.formatMessage(errorCode,
                                                  errorArgs));
    }

    //
    // Error codes generated by the rasterizer
    //

    /**
     * Error when there are missing option values:
     * {0} Option
     * {1} Option description
     */
    public static final String ERROR_NOT_ENOUGH_OPTION_VALUES
        = "Main.error.not.enough.option.values";

    /**
     * Error when an illegal option value was passed to the app
     * {0} Option
     * {1} Option description
     */
    public static final String ERROR_ILLEGAL_ARGUMENT
        = "Main.error.illegal.argument";

    public static final String ERROR_WHILE_CONVERTING_FILES
        = "Main.error.while.converting.files";

    public void execute(){
        SVGConverter c = new SVGConverter(this);

        List sources = new ArrayList();

        int nArgs = args.size();
        for (int i=0; i<nArgs; i++){
            String v = (String)args.get(i);
            OptionHandler optionHandler = (OptionHandler)optionMap.get(v);
            if (optionHandler == null){
                // Assume v is a source.
                sources.add(v);
            } else {
                // v is an option. Extract the optionValues required
                // by the handler.
                int nOptionArgs = optionHandler.getOptionValuesLength();
                if (i + nOptionArgs >= nArgs){
                    error(ERROR_NOT_ENOUGH_OPTION_VALUES, new Object[]{ v, optionHandler.getOptionDescription()});
                    return;
                }

                String[] optionValues = new String[nOptionArgs];
                for (int j=0; j<nOptionArgs; j++){
                    optionValues[j] = (String)args.get(1+i+j);
                }
                i += nOptionArgs;

                try {
                    optionHandler.handleOption(optionValues, c);
                } catch(IllegalArgumentException e){
                    e.printStackTrace();
                    error(ERROR_ILLEGAL_ARGUMENT,
                          new Object[] { v,
                                         optionHandler.getOptionDescription() ,
                                         toString(optionValues)});
                    return;
                }
            }
        }

        // Apply script security option
        ApplicationSecurityEnforcer securityEnforcer =
            new ApplicationSecurityEnforcer(this.getClass(),
                                            RASTERIZER_SECURITY_POLICY);

        securityEnforcer.enforceSecurity(!c.getSecurityOff());

        String[] expandedSources = expandSources(sources);

        c.setSources(expandedSources);

        validateConverterConfig(c);

        if (expandedSources== null || expandedSources.length < 1){
            System.out.println(USAGE);
            System.out.flush();
            securityEnforcer.enforceSecurity(false);
            return;
        }

        try {
            c.execute();
        } catch(SVGConverterException e){
            error(ERROR_WHILE_CONVERTING_FILES,
                  new Object[] { e.getMessage() });
        } finally {
            System.out.flush();
            securityEnforcer.enforceSecurity(false);
        }
    }

    protected String toString( String[] v){
        StringBuffer sb = new StringBuffer();
        int n = v != null ? v.length:0;
        for (int i=0; i<n; i++){
            sb.append(v[i] );
            sb.append( ' ' );
        }

        return sb.toString();
    }

    /**
     * Template methods which subclasses may implement to do whatever is
     * needed. For example, this can be used for test purposes.
     */
    public void validateConverterConfig(SVGConverter c){
    }

    /**
     * Scans the input vector and replaces directories with the list
     * of SVG files they contain
     */
    protected String[] expandSources(List sources){
        List expandedSources = new ArrayList();
        Iterator iter = sources.iterator();
        while (iter.hasNext()){
            String v = (String)iter.next();
            File f = new File(v);
            if (f.exists() && f.isDirectory()){
                File[] fl = f.listFiles(new SVGConverter.SVGFileFilter());
                for (int i=0; i<fl.length; i++){
                    expandedSources.add(fl[i].getPath());
                }
            } else {
                expandedSources.add(v);
            }
        }

        String[] s = new String[expandedSources.size()];
        expandedSources.toArray( s );
        return s;
    }

    public static void main(String [] args) {
        (new Main(args)).execute();
        System.exit(0);
    }

    //
    // SVGConverterController implementation
    //
    public static final String MESSAGE_ABOUT_TO_TRANSCODE
        = "Main.message.about.to.transcode";

    public static final String MESSAGE_ABOUT_TO_TRANSCODE_SOURCE
        = "Main.message.about.to.transcode.source";

    public static final String MESSAGE_CONVERSION_FAILED
        = "Main.message.conversion.failed";

    public static final String MESSAGE_CONVERSION_SUCCESS
        = "Main.message.conversion.success";

    public boolean proceedWithComputedTask(Transcoder transcoder,
                                           Map hints,
                                           List sources,
                                           List dest){
        System.out.println(Messages.formatMessage(MESSAGE_ABOUT_TO_TRANSCODE,
                                                  new Object[]{"" + sources.size()}));
        return true;
    }

    public boolean proceedWithSourceTranscoding(SVGConverterSource source,
                                                File dest){
        System.out.print(Messages.formatMessage(MESSAGE_ABOUT_TO_TRANSCODE_SOURCE,
                                                new Object[]{source.toString(),
                                                             dest.toString()}));
        return true;
    }

    public boolean proceedOnSourceTranscodingFailure(SVGConverterSource source,
                                                     File dest,
                                                     String errorCode){
        System.out.println(Messages.formatMessage(MESSAGE_CONVERSION_FAILED,
                                                  new Object[]{errorCode}));

        return true;
    }

    public void onSourceTranscodingSuccess(SVGConverterSource source,
                                           File dest){
        System.out.println(Messages.formatMessage(MESSAGE_CONVERSION_SUCCESS,
                                                  null));
    }
}

