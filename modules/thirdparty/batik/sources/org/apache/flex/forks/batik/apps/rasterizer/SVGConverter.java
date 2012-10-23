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
import java.io.FileFilter;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;

import org.apache.flex.forks.batik.transcoder.Transcoder;
import org.apache.flex.forks.batik.transcoder.TranscoderInput;
import org.apache.flex.forks.batik.transcoder.TranscoderOutput;
import org.apache.flex.forks.batik.transcoder.image.ImageTranscoder;
import org.apache.flex.forks.batik.transcoder.image.JPEGTranscoder;
import org.apache.flex.forks.batik.transcoder.image.PNGTranscoder;
import org.apache.flex.forks.batik.util.ParsedURL;

/**
 * This application can be used to convert SVG images to raster images.
 * <br />
 * Possible result raster image formats are PNG, JPEG, TIFF, and PDF.
 * The Batik Transcoder API is used to execute the conversion. FOP is
 * needed to be able to transcode to the PDF format<br />
 *
 * The source has to be list of files or URL (set by the <tt>setSources</tt>
 * method). <br />
 *
 * The destination can be:<br /><ul>
 * <li><b>unspecified</b>. In that case, only file sources can be converted and
 * a file in the same directory as the source will be created.</li>
 * <li><b>a directory</b>, set by the <tt>setDst</tt> method. In that case,
 * the output files are created in that destination directory</li>
 * <li><b>a file</b>. In case there is a <i>single
 * source</i>, the destination can be a single named file
 * (set with the <tt>setDst</tt> method.</li>)<br />
 * </ul>
 *
 * <hr />
 *
 * There are a number of options which control the way the image is
 * converted to the destination format:<br /><ul>
 * <li>destinationType: controls the type of conversion which should be done.
 *     see the {@link DestinationType} documentation.</li>
 * <li>width/height: they control the desired width and height, in user space,
 *     for the output image.</li>
 * <li>maxWidth/maxHeight: control the maximum width and height,
 *     in user space, of the output image.</li>
 * <li>area: controls the specific sub-area of the image which should be
 *     rendered.</li>
 * <li>backgroundColor: controls the color which is used to fill the
 *     background before rendering the image</li>
 * <li>quality: relevant only for JPEG destinations, this controls the
 *     encoding quality.</li>
 * <li>indexed: relevant only for PNG, controls the number of bits
 *              used in writting of a palletized files.</li>
 * <li>mediaType: controls the CSS media, or list of media, for which the
 *     image should be rendered.</li>
 * <li>alternate: controls the alternate CSS stylesheet to activate,
 *     if any.</li>
 * <li>language: controls the user language with which the SVG document
 *     should be converted.</li>
 * <li>userStylesheet: defines the user stylesheet to apply to SVG documents
 *     in addition to other stylesheets referenced by or embedded in the
 *     SVG documents.</li>
 * <li>pixelUnitToMillimeter: defines the size of a pixel in millimeters
 *     to use when processing the SVG documents.</li>
 * </ul>
 *
 * @version $Id: SVGConverter.java 579992 2007-09-27 12:44:00Z cam $
 * @author <a href="mailto:Henri.Ruini@nokia.com">Henri Ruini</a>
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 */
public class SVGConverter {
    //
    // Error codes reported by the SVGConverter
    //

    //
    // Reported when no source file has been specified.
    //
    public static final String ERROR_NO_SOURCES_SPECIFIED
        = "SVGConverter.error.no.sources.specified";

    //
    // Reported when there is more than one valid input source
    // and no output directory has been set and the source is
    // not a file.
    //
    public static final String ERROR_CANNOT_COMPUTE_DESTINATION
        = "SVGConverter.error.cannot.compute.destination";

    //
    // Reported when the dst is a file and there are multiple
    // sources.
    //
    public static final String ERROR_CANNOT_USE_DST_FILE
        = "SVGConverter.error.cannot.use.dst.file";

    //
    // Reported when the <tt>Transcoder</tt> for the requested
    // <tt>destinationType</tt> cannot be found.
    //
    public static final String ERROR_CANNOT_ACCESS_TRANSCODER
        = "SVGConverter.error.cannot.access.transcoder";

    //
    // Reported when the source is found to be the same as
    // the destination. Note that it is not guaranteed that
    // this error condition will always be detected.
    //
    public static final String ERROR_SOURCE_SAME_AS_DESTINATION
        = "SVGConverter.error.source.same.as.destination";

    //
    // Reported when one of the sources cannot be read.
    //
    public static final String ERROR_CANNOT_READ_SOURCE
        = "SVGConverter.error.cannot.read.source";

    //
    // Reported when an error happens while opening a source
    // file.
    //
    public static final String ERROR_CANNOT_OPEN_SOURCE
        = "SVGConverter.error.cannot.open.source";

    //
    // Reported if the output is not writeable. This may
    // happen if the output file already exists and does not
    // have write permission.
    //
    public static final String ERROR_OUTPUT_NOT_WRITEABLE
        = "SVGConverter.error.output.not.writeable";

    //
    // Reported when an error happens while trying to open
    // the output file for writing.
    //
    public static final String ERROR_CANNOT_OPEN_OUTPUT_FILE
        = "SVGConverter.error.cannot.open.output.file";

    //
    // Reported when the converter was not able to create
    // the destination directory for the files.
    //
    public static final String ERROR_UNABLE_TO_CREATE_OUTPUT_DIR
        = "SVGConverter.error.unable.to.create.output.dir";

    //
    // Reported when an error occurs while convertion the
    // source file.
    //
    public static final String ERROR_WHILE_RASTERIZING_FILE
        = "SVGConverter.error.while.rasterizing.file";

    //
    // Class variables and constants
    //

    /** SVG file extension */
    protected static final String SVG_EXTENSION = ".svg";

    /** Default quality value.  A value of -1 means disabled. */
    protected static final float DEFAULT_QUALITY
        = -1.0f;

    /** Maximum quality value */
    protected static final float MAXIMUM_QUALITY
        = .99F;

    /** Default result type */
    protected static final DestinationType DEFAULT_RESULT_TYPE
        = DestinationType.PNG;

    /** Default width */
    protected static final float DEFAULT_WIDTH = -1;

    /** Default height */
    protected static final float DEFAULT_HEIGHT = -1;

    /** Result type */
    protected DestinationType destinationType = DEFAULT_RESULT_TYPE;

    /** Output image height. */
    protected float height = DEFAULT_HEIGHT;

    /** Output image width. */
    protected float width = DEFAULT_WIDTH;

    /** Maximum output image height. */
    protected float maxHeight = DEFAULT_HEIGHT;

    /** Maximum output image width. */
    protected float maxWidth = DEFAULT_WIDTH;

    /** Output image quality. */
    protected float quality = DEFAULT_QUALITY;

    /** Should output Image be indexed . */
    protected int indexed = -1;

    /** Output AOI area. */
    protected Rectangle2D area = null;

    /** Language */
    protected String language = null;

    /** User stylesheet */
    protected String userStylesheet = null;

    /** Millimeters Per Pixel */
    protected float pixelUnitToMillimeter = -1.0f;

    /** Validation flag */
    protected boolean validate = false;

    /** Execute the 'onload' scripts flag */
    protected boolean executeOnload = false;

    /** Document time to seek to. */
    protected float snapshotTime = Float.NaN;

    /** Set of allowed script types. */
    protected String allowedScriptTypes = null;

    /** Controls whether scripts can only have the same origin as
        the document which references them. */
    protected boolean constrainScriptOrigin = true;

    /** Controls whether scripts should be run securely or not */
    protected boolean securityOff = false;

    /** Sources files or URLs */
    protected List sources = null;

    /**
     * Destination image path. Can be a file (for single source) or
     *  a directory
     */
    protected File dst;

    /** Background color for the output images. */
    protected Color backgroundColor = null;

    /** Media type for which the SVG image should be rendered */
    protected String mediaType = null;

    /** Default value for the font-family when it is unspecified */
    protected String defaultFontFamily = null;

    /** Alternate stylesheet for which should be applied to the SVG */
    protected String alternateStylesheet = null;

    /** Contents of <tt>fileset</tt> elements. */
    protected List files = new ArrayList();

    /**
     * Controls some aspects of the converter's operation,
     *  such as whether or not it should proceed in some
     *  error situations. See {@link SVGConverterController}
     */
    protected SVGConverterController controller;

    //
    // Default constructor
    //
    public SVGConverter(){
        this(new DefaultSVGConverterController());
    }

    //
    // Constructor
    //
    public SVGConverter(SVGConverterController controller){
        if (controller == null){
            throw new IllegalArgumentException();
        }

        this.controller = controller;
    }

    //
    // Property get/set methods
    //

    /**
     * Sets the <tt>destinationType</tt> attribute value.
     * Should not be null.
     */
    public void setDestinationType(DestinationType destinationType) {
        if(destinationType == null){
            throw new IllegalArgumentException();
        }
        this.destinationType = destinationType;
    }

    public DestinationType getDestinationType(){
        return destinationType;
    }

    /**
     * In less than or equal to zero, the height is not
     * constrained on the output image. The height is in
     * user space.
     */
    public void setHeight(float height) {
        this.height = height;
    }

    public float getHeight(){
        return height;
    }

    /**
     * In less than or equal to zero, the width is not
     * constrained on the output image. The width is in
     * user space.
     */
    public void setWidth(float width) {
        this.width = width;
    }

    public float getWidth(){
        return width;
    }

    /**
     * If less than or equal to zero, the maximum height
     * does not have any effect on the output image.
     * The maximum height is in user space.
     */
    public void setMaxHeight(float height) {
        this.maxHeight = height;
    }

    public float getMaxHeight(){
        return maxHeight;
    }

    /**
     * If less than or equal to zero, the maximum width
     * does not have any effect on the output image.
     * The maximum width is in user space.
     */
    public void setMaxWidth(float width) {
        this.maxWidth = width;
    }

    public float getMaxWidth(){
        return maxWidth;
    }

    /**
     * Sets the JPEG encoding quality. The value should be strictly
     * less than 1. If the value is less than zero, then the maximum
     * encoding quality is used.
     */
    public void setQuality(float quality) throws IllegalArgumentException {
        if(quality >= 1){
            throw new IllegalArgumentException();
        }

        this.quality = quality;
    }

    public float getQuality(){
        return quality;
    }

    /**
     * Tells the PNG encoder to reduce the image to 256 colors, so the
     * PNG file is indexed.
     */
    public void setIndexed(int bits) throws IllegalArgumentException {
        this.indexed = bits;
    }

    public int getIndexed(){
        return indexed;
    }

    /**
     * Sets the user language. If the value is null, then the default (see
     * {@link org.apache.flex.forks.batik.bridge.UserAgent#getLanguages})
     * is used.
     */
    public void setLanguage(String language){
        this.language = language;
    }

    public String getLanguage(){
        return language;
    }

    /**
     * Sets the user stylesheet. May be null.
     */
    public void setUserStylesheet(String userStylesheet){
        this.userStylesheet = userStylesheet;
    }

    public String getUserStylesheet(){
        return userStylesheet;
    }

    /**
     * Sets the millimeters per pixel constant. A negative
     * value will cause the default value
     * (see {@link org.apache.flex.forks.batik.bridge.UserAgent#getPixelUnitToMillimeter})
     * to be used.
     */
    public void setPixelUnitToMillimeter(float pixelUnitToMillimeter){
        this.pixelUnitToMillimeter = pixelUnitToMillimeter;
    }

    public float getPixelUnitToMillimeter(){
        return pixelUnitToMillimeter;
    }

    /**
     * Sets the <tt>area</tt> as a Rectangle. This value can
     * be null in which case the whole image will be rendered. If the
     * area is not null, then only the portion of the image it
     * defines will be rendered.
     */
    public void setArea(Rectangle2D area){
        this.area = area;
    }

    public Rectangle2D getArea(){
        return area;
    }

    /**
     * Sets the list of individual SVG sources. The strings
     * can be either URLs or file names. Note that invalid
     * sources (e.g., read-protected files or invalid URLs)
     * will cause <tt>SVGConverterExceptions</tt> to be
     * thrown during the transcoding process (see {@link #execute});
     */
    public void setSources(String[] sources) {
        if(sources == null){
            this.sources = null;
        }
        else{
            this.sources = new ArrayList();
            for (int i=0; i<sources.length; i++){
                if (sources[i] != null){
                    this.sources.add(sources[i]);
                }
            }

            if (this.sources.size() == 0){
                this.sources = null;
            }
        }
    }

    public List getSources(){
        return sources;
    }

    /**
     * When converting a single source, dst can be a file.
     * Othewise, it should be a directory.
     */
    public void setDst(File dst) {
        this.dst = dst;
    }

    public File getDst(){
        return dst;
    }

    /**
     * Sets the <tt>backgroundColor</tt> value. This can be
     * null in which case no color will be used to fill the
     * background before rendering this SVG image.
     */
    public void setBackgroundColor(Color backgroundColor){
        this.backgroundColor = backgroundColor;
    }

    public Color getBackgroundColor(){
        return backgroundColor;
    }

    /**
     * Sets the <tt>mediaType</tt> value. This value controls
     * the CSS media for which the image should be rendered. It
     * can be null, in which case no specific media selectors will
     * apply. If it is not null, it can contain space separated values
     * of the medias for which the image should be rendered. For example,
     * "screen", "print" or "scree projection" are valid values.
     */
    public void setMediaType(String mediaType){
        this.mediaType = mediaType;
    }

    public String getMediaType(){
        return mediaType;
    }

    /**
     * Sets the <tt>defaultFontFamily</tt> value. This value controls
     * the default value for the font-family CSS property when that
     * property is unspecified.
     */
    public void setDefaultFontFamily(String defaultFontFamily) {
        this.defaultFontFamily = defaultFontFamily;
    }

    public String getDefaultFontFamily() {
        return defaultFontFamily;
    }

    /**
     * Sets the <tt>alternateStyleSheet</tt> value. This value
     * controls the CSS alternate stylesheet to select in the
     * rendered SVG file(s). It may be null, in which case no alternate
     * stylesheet will be selected.
     */
    public void setAlternateStylesheet(String alternateStylesheet){
        this.alternateStylesheet = alternateStylesheet;
    }

    public String getAlternateStylesheet(){
        return alternateStylesheet;
    }

    /**
     * Defines whether or not input sources should be validated in
     * the conversion process
     */
    public void setValidate(boolean validate){
        this.validate = validate;
    }

    public boolean getValidate(){
        return validate;
    }

    /**
     * Sets whether or not scripts attached to the DOM using 'onload'
     * event attribute must be executed before rasterizing.
     *
     * @param b true means scripts will be executed
     */
    public void setExecuteOnload(boolean b){
        this.executeOnload = b;
    }

    /**
     * Returns true if the scripts attached to the DOM using 'onload'
     * event attribute is going to be executed before rasterizing,
     * false otherwise.
     */
    public boolean getExecuteOnload(){
        return executeOnload;
    }

    /**
     * Sets the document time to seek to before rasterizing.
     *
     * @param t the document time, in seconds
     */
    public void setSnapshotTime(float t) {
        snapshotTime = t;
    }

    /**
     * Returns the document to to seek to before rasterizing.
     */
    public float getSnapshotTime() {
        return snapshotTime;
    }

    /**
     * Sets the set of allowed script types (i.e., the set of possible
     * values for the type attribute in the &lt;script&gt; element),
     * as a comma separated list of allowed values.
     */
    public void setAllowedScriptTypes(String allowedScriptTypes){
        this.allowedScriptTypes = allowedScriptTypes;
    }

    /**
     * Returns the list of allowed script types.
     *
     * @see #setAllowedScriptTypes
     */
    public String getAllowedScriptTypes(){
        return allowedScriptTypes;
    }

    /**
     * Sets whether scripts should only be loaded from the same
     * location as the documents referencing them.
     */
    public void setConstrainScriptOrigin(boolean constrainScriptOrigin){
        this.constrainScriptOrigin = constrainScriptOrigin;
    }

    /**
     * Returns whether scripts can only be loaded from the same
     * origin as the documents referencing them.
     */
    public boolean getConstrainScriptOrigin(){
        return constrainScriptOrigin;
    }

    /**
     * Sets whether or not scripts should be run securely
     */
    public void setSecurityOff(boolean securityOff){
        this.securityOff = securityOff;
    }

    /**
     * Returns whether or not scripts will be run securely
     */
    public boolean getSecurityOff(){
        return securityOff;
    }

    /**
     * Returns true if f is a File. <code>f</code> is found to be a file if
     * it exists and is a file. If it does not exist, it is declared
     * to be a file if it has the same extension as the DestinationType.
     */
    protected boolean isFile(File f){
        if (f.exists()){
            return f.isFile();
        } else {
            if (f.toString().toLowerCase().endsWith(destinationType.getExtension())){
                return true;
            }
        }

        return false;
    }

    /**
     * Starts the conversion process.
     * @throws SVGConverterException thrown if parameters are not set correctly.
     */
    public void execute() throws SVGConverterException {
        // Compute the set of SVGConverterSource from the source properties
        // (srcDir and srcFile);
        // This throws an exception if there is not at least one src file.
        List sources = computeSources();

        // Compute the destination files from dest
        List dstFiles = null;
        if(sources.size() == 1 && dst != null && isFile(dst)){
            dstFiles = new ArrayList();
            dstFiles.add(dst);
        }
        else{
            dstFiles = computeDstFiles(sources);
        }

        // Now, get the transcoder to use for the operation
        Transcoder transcoder = destinationType.getTranscoder();
        if(transcoder == null) {
            throw new SVGConverterException(ERROR_CANNOT_ACCESS_TRANSCODER,
                                             new Object[]{destinationType.toString()},
                                             true /* fatal error */);
        }

        // Now, compute the set of transcoding hints to use
        Map hints = computeTranscodingHints();
        transcoder.setTranscodingHints(hints);

        // Notify listener that task has been computed
        if(!controller.proceedWithComputedTask(transcoder,
                                               hints,
                                               sources,
                                               dstFiles)){
            return;
        }

        // Convert files one by one
        for(int i = 0 ; i < sources.size() ; i++) {
            // Get the file from the vector.
            SVGConverterSource currentFile
                = (SVGConverterSource)sources.get(i);
            File outputFile  = (File)dstFiles.get(i);

            createOutputDir(outputFile);
            transcode(currentFile, outputFile, transcoder);
        }
    }

    /**
     * Populates a vector with destination files names
     * computed from the names of the files in the sources vector
     * and the value of the dst property
     */
    protected List computeDstFiles(List sources)
    throws SVGConverterException {
        List dstFiles = new ArrayList();
        if (dst != null) {
            if (dst.exists() && dst.isFile()) {
                throw new SVGConverterException(ERROR_CANNOT_USE_DST_FILE);
            }

            //
            // Either dst exist and is a directory or dst does not
            // exist and we may fail later on in createOutputDir
            //
            int n = sources.size();
            for(int i=0; i<n; i++){
                SVGConverterSource src = (SVGConverterSource)sources.get(i);
                // Generate output filename from input filename.
                File outputName = new File(dst.getPath(),
                                           getDestinationFile(src.getName()));
                dstFiles.add(outputName);

            }
        } else {
            //
            // No destination directory has been specified.
            // Try and create files in the same directory as the
            // sources. This only work if sources are files.
            //
            int n = sources.size();
            for(int i=0; i<n; i++){
                SVGConverterSource src = (SVGConverterSource)sources.get(i);
                if (!(src instanceof SVGConverterFileSource)) {
                    throw new SVGConverterException(ERROR_CANNOT_COMPUTE_DESTINATION,
                                                     new Object[]{src});
                }

                // Generate output filename from input filename.
                SVGConverterFileSource fs = (SVGConverterFileSource)src;
                File outputName = new File(fs.getFile().getParent(),
                                           getDestinationFile(src.getName()));
                dstFiles.add(outputName);
            }

        }

        return dstFiles;
    }

    /**
     * Populates a vector with the set of SVG files from the
     * srcDir if it is not null and with the sources (files or URLs)
     * if any.
     */
    protected List computeSources() throws SVGConverterException{
        List sources = new ArrayList();

        // Check that at least one source has been specified.
        if (this.sources == null){
            throw new SVGConverterException(ERROR_NO_SOURCES_SPECIFIED);
        }

        int n = this.sources.size();
        for (int i=0; i<n; i++){
            String sourceString = (String)(this.sources.get(i));
            File file = new File(sourceString);
            if (file.exists()) {
                sources.add(new SVGConverterFileSource(file));
            } else {
                String[] fileNRef = getFileNRef(sourceString);
                file = new File(fileNRef[0]);
                if (file.exists()){
                    sources.add(new SVGConverterFileSource(file, fileNRef[1]));
                } else{
                    sources.add(new SVGConverterURLSource(sourceString));
                }
            }
        }

        return sources;
    }

    public String[] getFileNRef(String fileName){
        int n = fileName.lastIndexOf('#');
        String[] result = {fileName, ""};
        if (n > -1){
            result[0] = fileName.substring(0, n);
            if (n+1 < fileName.length()){
                result[1] = fileName.substring(n+1);
            }
        }

        return result;
    }

    // -----------------------------------------------------------------------
    //   Internal methods
    // -----------------------------------------------------------------------

    /**
     * Computes the set of transcoding hints to use for the operation
     */
    protected Map computeTranscodingHints(){
        Map map = new HashMap();

        // Set AOI. ----------------------------------------------------------
        if (area != null) {
            map.put(ImageTranscoder.KEY_AOI, area);
        }

        // Set image quality. ------------------------------------------------
        if (quality > 0) {
            map.put(JPEGTranscoder.KEY_QUALITY, new Float(this.quality));
        }

        // Set image indexed. ------------------------------------------------
        if (indexed != -1) {
            map.put(PNGTranscoder.KEY_INDEXED, new Integer(indexed));
        }

        // Set image background color -----------------------------------------
        if (backgroundColor != null){
            map.put(ImageTranscoder.KEY_BACKGROUND_COLOR, backgroundColor);
        }

        // Set image height and width. ----------------------------------------
        if (height > 0) {
            map.put(ImageTranscoder.KEY_HEIGHT, new Float(this.height));
        }
        if (width > 0){
            map.put(ImageTranscoder.KEY_WIDTH, new Float(this.width));
        }

        // Set maximum height and width ---------------------------------------
        if (maxHeight > 0) {
            map.put(ImageTranscoder.KEY_MAX_HEIGHT, new Float(this.maxHeight));
        }
        if (maxWidth > 0){
            map.put(ImageTranscoder.KEY_MAX_WIDTH, new Float(this.maxWidth));
        }

        // Set CSS Media
        if (mediaType != null){
            map.put(ImageTranscoder.KEY_MEDIA, mediaType);
        }

        // Set default font-family
        if (defaultFontFamily != null) {
            map.put(ImageTranscoder.KEY_DEFAULT_FONT_FAMILY, defaultFontFamily);
        }

        // Set alternateStylesheet
        if (alternateStylesheet != null){
            map.put(ImageTranscoder.KEY_ALTERNATE_STYLESHEET, alternateStylesheet);
        }

        // Set user stylesheet
        if (userStylesheet != null) {
            String userStylesheetURL;
            try {
                URL userDir = new File(System.getProperty("user.dir")).toURL();
                userStylesheetURL = new ParsedURL(userDir, userStylesheet).toString();
            } catch (Exception e) {
                userStylesheetURL = userStylesheet;
            }
            map.put(ImageTranscoder.KEY_USER_STYLESHEET_URI, userStylesheetURL);
        }

        // Set the user language
        if (language != null){
            map.put(ImageTranscoder.KEY_LANGUAGE, language);
        }

        // Sets the millimeters per pixel
        if (pixelUnitToMillimeter > 0){
            map.put(ImageTranscoder.KEY_PIXEL_UNIT_TO_MILLIMETER,
                    new Float(pixelUnitToMillimeter));
        }

        // Set validation
        if (validate){
            map.put(ImageTranscoder.KEY_XML_PARSER_VALIDATING, Boolean.TRUE);
        }

        // Set onload
        if (executeOnload) {
            map.put(ImageTranscoder.KEY_EXECUTE_ONLOAD, Boolean.TRUE);
        }

        // Set snapshot time
        if (!Float.isNaN(snapshotTime)) {
            map.put(ImageTranscoder.KEY_SNAPSHOT_TIME, new Float(snapshotTime));
        }

        // Set allowed scripts
        if (allowedScriptTypes != null) {
            map.put(ImageTranscoder.KEY_ALLOWED_SCRIPT_TYPES, allowedScriptTypes);
        }

        // Set constrain script origin
        if (!constrainScriptOrigin) {
            map.put(ImageTranscoder.KEY_CONSTRAIN_SCRIPT_ORIGIN, Boolean.FALSE);
        }

        return map;
    }

    /**
     * Converts the input image to the result image.
     * with the given transcoder. If a failure happens, the
     * controller is notified and decides whether to proceed
     * or not. If it decides to proceed, the converter will
     * continue processing other files. Otherwise, it will
     * throw an exception.
     */
    protected void transcode(SVGConverterSource inputFile,
                             File outputFile,
                             Transcoder transcoder)
        throws SVGConverterException {
        TranscoderInput input = null;
        TranscoderOutput output = null;
        OutputStream outputStream = null;

        if (!controller.proceedWithSourceTranscoding(inputFile,
                                                     outputFile)){
            return;
        }

        try {
            if (inputFile.isSameAs(outputFile.getPath())) {
                throw new SVGConverterException(ERROR_SOURCE_SAME_AS_DESTINATION,
                                                 true /* fatal error */);
            }

            // Compute transcoder input.
            if (!inputFile.isReadable()) {
                throw new SVGConverterException(ERROR_CANNOT_READ_SOURCE,
                                                 new Object[]{inputFile.getName()});
            }

            try {
                InputStream in = inputFile.openStream();
                in.close();
            } catch(IOException ioe) {
                throw new SVGConverterException(ERROR_CANNOT_OPEN_SOURCE,
                                                 new Object[] {inputFile.getName(),
                                                               ioe.toString()});
                                                               }

            input = new TranscoderInput(inputFile.getURI());

            // Compute transcoder output.
            if (!isWriteable(outputFile)) {
                throw new SVGConverterException(ERROR_OUTPUT_NOT_WRITEABLE,
                                                 new Object[] {outputFile.getName()});
            }
            try {
                outputStream = new FileOutputStream(outputFile);
            } catch(FileNotFoundException fnfe) {
                throw new SVGConverterException(ERROR_CANNOT_OPEN_OUTPUT_FILE,
                                                 new Object[] {outputFile.getName()});
            }

            output = new TranscoderOutput(outputStream);
        } catch(SVGConverterException e){
            boolean proceed = controller.proceedOnSourceTranscodingFailure
                (inputFile, outputFile, e.getErrorCode());
            if (proceed){
                return;
            } else {
                throw e;
            }
        }

        // Transcode now
        boolean success = false;
        try {
            transcoder.transcode(input, output);
            success = true;
        } catch(Exception te) {
            te.printStackTrace();
            try {
                outputStream.flush();
                outputStream.close();
            } catch(IOException ioe) {}

            // Report error to the controller. If controller decides
            // to stop, throw an exception
            boolean proceed = controller.proceedOnSourceTranscodingFailure
                (inputFile, outputFile, ERROR_WHILE_RASTERIZING_FILE);

            if (!proceed){
                throw new SVGConverterException(ERROR_WHILE_RASTERIZING_FILE,
                                                 new Object[] {outputFile.getName(),
                                                               te.getMessage()});
            }
        }

        // Close streams and clean up.
        try {
            outputStream.flush();
            outputStream.close();
        } catch(IOException ioe) {
            return;
        }

        if (success){
            controller.onSourceTranscodingSuccess(inputFile, outputFile);
        }
    }

    /**
     * Get the name of the result image file.
     *
     * <P>This method modifies the result filename, it changes the existing
     * suffix to correspong the result file type. It also adds the suffix
     * if the file doesn't have one.</P>
     *
     * @param file Result file name as a String object.
     *
     * @return Name of the file. The directory of the file is not returned.
     *         The returned string is empty if the parameter is not a file.
     */
    protected String getDestinationFile(String file) {
        int suffixStart;            // Location of the first char of
                                    // the suffix in a String.
        String oldName;             // Existing filename.
        String newSuffix = destinationType.getExtension();
                                    // New suffix.

        oldName = file;
        // Find the first char of the suffix.
        suffixStart = oldName.lastIndexOf( '.' );
        String dest = null;
        if (suffixStart != -1) {
            // Replace existing suffix.
            dest = oldName.substring(0, suffixStart) + newSuffix;
        } else {
            // Add new suffix.
            dest = oldName + newSuffix;
        }

        return dest;
    }

    /**
     * Creates directories for output files if needed.
     *
     * @param output Output file with path.
     *
     * @throws SVGConverterException Output directory doesn't exist and it can't be created.
     */
    protected void createOutputDir(File output)
        throws SVGConverterException {

        File outputDir;             // Output directory object.
        boolean success = true;     // false if the output directory
                                    // doesn't exist and it can't be created
                                    // true otherwise


        // Create object from output directory.
        String parentDir = output.getParent();
        if (parentDir != null){
            outputDir = new File(output.getParent());
            if ( ! outputDir.exists() ) {
                // Output directory doesn't exist, so create it.
                success = outputDir.mkdirs();
            } else {
                if ( ! outputDir.isDirectory() ) {
                    // File, which have a same name as the output directory, exists.
                    // Create output directory.
                    success = outputDir.mkdirs();
                }
            }
        }

        if (!success) {
            throw new SVGConverterException(ERROR_UNABLE_TO_CREATE_OUTPUT_DIR);
        }
    }

    /**
     * Checks if the application is allowed to write to the file.
     *
     * @param file File to be checked.
     *
     * @return <tt>true</tt> if the file is writeable and <tt>false</tt> otherwise.
     */
    protected boolean isWriteable(File file) {
        if (file.exists()) {
            // Check the existing file.
            if (!file.canWrite()) {
                return false;
            }
        } else {
            // Check the file that doesn't exist yet.
            // Create a new file. The file is writeable if
            // the creation succeeds.
            try {
                file.createNewFile();
            } catch(IOException ioe) {
                return false;
            }
        }
        return true;
    }

    // -----------------------------------------------------------------------
    //   Inner classes
    // -----------------------------------------------------------------------

    /**
     * Convenience class to filter svg files
     */
    public static class SVGFileFilter implements FileFilter {
        public static final String SVG_EXTENSION = ".svg";

        public boolean accept(File file){
            if (file != null && file.getName().toLowerCase().endsWith(SVG_EXTENSION)){
                return true;
            }

            return false;
        }
    }

}

