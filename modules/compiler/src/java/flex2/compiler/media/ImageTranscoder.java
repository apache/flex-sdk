/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flex2.compiler.media;

import flex2.compiler.SymbolTable;
import flex2.compiler.Transcoder;
import flex2.compiler.TranscoderException;
import flex2.compiler.common.PathResolver;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.util.ThreadLocalToolkit;
import flash.swf.TagValues;
import flash.swf.builder.tags.ImageShapeBuilder;
import flash.swf.tags.*;
import flash.swf.types.*;

import java.util.ArrayList;
import java.util.Map;

/**
 * Base class for transcoding images.  For images with Slice 9 or
 * smoothing, we use a DefineSprite tags, which wraps a DefineShape
 * tag.  Otherwise, we use a DefineBits tag.
 *
 * @author Paul Reilly
 * @author Clement Wong
 */
public abstract class ImageTranscoder extends AbstractTranscoder
{
    public static final String SMOOTHING = "smoothing";

    public ImageTranscoder(String[] mimeTypes, Class defineTag, boolean cacheTags)
    {
        super( mimeTypes, defineTag, cacheTags );
    }

    public boolean isSupportedAttribute( String attr )
    {
        return (SCALE9BOTTOM.equals(attr) ||
                SCALE9LEFT.equals(attr) ||
                SCALE9RIGHT.equals(attr) ||
                SCALE9TOP.equals(attr) ||
                SMOOTHING.equals(attr));
    }

    public abstract ImageInfo getImage( VirtualFile source, Map<String, Object> args ) throws TranscoderException;

	public TranscodingResults doTranscode(PathResolver context, SymbolTable symbolTable,
                                           Map<String, Object> args, String className,
                                           boolean generateSource)
        throws TranscoderException
	{
        TranscodingResults results = new TranscodingResults( resolveSource( context, args ) );

        // We don't need to export in FP9 movies, but hey, here's a top secret loophole 'til we're positive
        String newName = (String) args.get( Transcoder.NEWNAME );

        ImageInfo info = getImage( results.assetSource, args );

        if (args.containsKey(SCALE9LEFT) || args.containsKey(SCALE9RIGHT) || args.containsKey(SCALE9TOP) || args.containsKey(SCALE9BOTTOM))
        {
            if (args.get(SCALE9LEFT)==null || args.get(SCALE9RIGHT)==null || args.get(SCALE9TOP)==null || args.get(SCALE9BOTTOM)==null)
            {
                throw new ScalingGridException();
            }
            results.defineTag = buildSlicedSprite( newName, info, args );
        }
        else if (args.containsKey(SMOOTHING) && Boolean.parseBoolean((String) args.get(SMOOTHING)))
        {
            // We wrap the Shape in a Sprite, because the framework
            // doesn't support Shape based assets yet.  It supports
            // Sprite assets, though.
            results.defineTag = buildSmoothingSprite(newName, info);
        }
        else
        {
            // We use a just a bitmap for this case, to be more lightweight.
            results.defineTag = buildBitmap( newName, info );
        }

        if (generateSource)
            generateSource(results, className, args);

        return results;
	}

    private static DefineShape generateSlicedShape( DefineBits refBitmap, Rect r, int width, int height )
    {
        int slt = r.xMin;
        int srt = r.xMax;
        int stt = r.yMin;
        int sbt = r.yMax;

        DefineShape shape = new DefineShape( TagValues.stagDefineShape4 );
        shape.bounds = new Rect( 0, width, 0, height );
        shape.edgeBounds = shape.bounds;
        shape.shapeWithStyle = new ShapeWithStyle();
        shape.shapeWithStyle.shapeRecords = new ArrayList<ShapeRecord>();
        shape.shapeWithStyle.fillstyles = new ArrayList<FillStyle>();
        shape.shapeWithStyle.linestyles = new ArrayList<LineStyle>();
        // translate into source bitmap
        Matrix tsm = new Matrix();
        // unity in twips
        tsm.setScale(20,20);

        // 9 identical fillstyles to fool things
        for (int i = 0; i < 9; ++i)
        {
            FillStyle fs = new FillStyle( FillStyle.FILL_BITS|FillStyle.FILL_BITS_NOSMOOTH, tsm, refBitmap);
            shape.shapeWithStyle.fillstyles.add( fs );
        }
        int dxa = slt;
        int dxb = srt-slt;
        int dxc = width-srt;

        int dya = stt;
        int dyb = sbt-stt;
        int dyc = height-sbt;

        StyleChangeRecord startStyle = new StyleChangeRecord();
        startStyle.setMove( 0, dya );
        shape.shapeWithStyle.shapeRecords.add( startStyle );

        // border
        addEdgesWithFill( shape, new int[][]{{0, -dya}, {dxa, 0}}, 0, 1 );
        addEdgesWithFill( shape, new int[][]{{dxb, 0}}, 0, 2 );
        addEdgesWithFill( shape, new int[][]{{dxc, 0}, {0, dya}}, 0, 3 );
        addEdgesWithFill( shape, new int[][]{{0, dyb}}, 0, 6 );
        addEdgesWithFill( shape, new int[][]{{0, dyc}, {-dxc, 0}}, 0, 9 );
        addEdgesWithFill( shape, new int[][]{{-dxb, 0}}, 0, 8 );
        addEdgesWithFill( shape, new int[][]{{-dxa, 0}, {0, -dyc}}, 0, 7 );
        addEdgesWithFill( shape, new int[][]{{0, -dyb}}, 0, 4 );

        // down 1
        StyleChangeRecord down1Style = new StyleChangeRecord();
        down1Style.setMove( dxa, 0 );
        shape.shapeWithStyle.shapeRecords.add( down1Style );
        addEdgesWithFill( shape, new int[][]{{0, dya}}, 2, 1 );
        addEdgesWithFill( shape, new int[][]{{0, dyb}}, 5, 4 );
        addEdgesWithFill( shape, new int[][]{{0, dyc}}, 8, 7 );

        // down 2
        StyleChangeRecord down2Style = new StyleChangeRecord();
        down2Style.setMove( dxa+dxb, 0 );
        shape.shapeWithStyle.shapeRecords.add( down2Style );
        addEdgesWithFill( shape, new int[][]{{0, dya}}, 3, 2 );
        addEdgesWithFill( shape, new int[][]{{0, dyb}}, 6, 5 );
        addEdgesWithFill( shape, new int[][]{{0, dyc}}, 9, 8 );

        // right 1
        StyleChangeRecord right1Style = new StyleChangeRecord();
        right1Style.setMove( 0, dya );
        shape.shapeWithStyle.shapeRecords.add( right1Style );
        addEdgesWithFill( shape, new int[][]{{dxa, 0}}, 1, 4 );
        addEdgesWithFill( shape, new int[][]{{dxb, 0}}, 2, 5 );
        addEdgesWithFill( shape, new int[][]{{dxc, 0}}, 3, 6 );

        // right 2
        StyleChangeRecord right2Style = new StyleChangeRecord();
        right2Style.setMove( 0, dya+dyb);
        shape.shapeWithStyle.shapeRecords.add( right2Style );
        addEdgesWithFill( shape, new int[][]{{dxa, 0}}, 4, 7 );
        addEdgesWithFill( shape, new int[][]{{dxb, 0}}, 5, 8 );
        addEdgesWithFill( shape, new int[][]{{dxc, 0}}, 6, 9 );
        return shape;
    }

    /**
     * Generates a Shape with with a JPEG fillstyle and smoothing.
     */
    private static DefineShape generateSmoothingShape(ImageInfo imageInfo)
    {
        DefineShape shape = new DefineShape(TagValues.stagDefineShape);
        shape.bounds = new Rect(0, imageInfo.width * 20, 0, imageInfo.height * 20);
        shape.edgeBounds = shape.bounds;
        shape.shapeWithStyle = new ShapeWithStyle();
        shape.shapeWithStyle.shapeRecords = new ArrayList<ShapeRecord>();
        shape.shapeWithStyle.fillstyles = new ArrayList<FillStyle>();
        shape.shapeWithStyle.linestyles = new ArrayList<LineStyle>();

        Matrix matrix = new Matrix();
        matrix.setScale(20,20);

        FillStyle fillStyle = new FillStyle(FillStyle.FILL_BITS | FillStyle.FILL_BITS_CLIP, matrix, imageInfo.defineBits);
        shape.shapeWithStyle.fillstyles.add(fillStyle);

        StyleChangeRecord startStyle = new StyleChangeRecord();
        // We use fillstyle1, because it matches what FlashAuthoring generates.
        startStyle.setFillStyle1(1);
        startStyle.setMove(imageInfo.width * 20, imageInfo.height * 20);
        shape.shapeWithStyle.shapeRecords.add(startStyle);

        // border
        shape.shapeWithStyle.shapeRecords.add( new StraightEdgeRecord(-1 * imageInfo.width * 20, 0));
        shape.shapeWithStyle.shapeRecords.add( new StraightEdgeRecord(0, -1 * imageInfo.height * 20));
        shape.shapeWithStyle.shapeRecords.add( new StraightEdgeRecord(imageInfo.width * 20, 0));
        shape.shapeWithStyle.shapeRecords.add( new StraightEdgeRecord(0, imageInfo.height * 20));

        return shape;
    }

    private static void addEdgesWithFill( DefineShape shape, int[][] coords, int left, int right )
    {
        StyleChangeRecord scr = new StyleChangeRecord();
        if ((left != 0) || (right != 0))
        {
            scr.setFillStyle0( left );
            scr.setFillStyle1( right );
        }
        shape.shapeWithStyle.shapeRecords.add( scr );

        for (int i = 0; i < coords.length; ++i)
        {
            shape.shapeWithStyle.shapeRecords.add( new StraightEdgeRecord(coords[i][0], coords[i][1]));
        }
    }

    public static DefineBits buildBitmap(String name, ImageInfo imageInfo)
    {
        return imageInfo.defineBits;
    }

    /**
     * This was used in the past by doTranscode() for bitmaps, but it
     * wasn't necessary, so we use buildBitmap() now.
     */
    public static DefineSprite buildSprite(String name, ImageInfo imageInfo)
	{
        DefineSprite sprite = new DefineSprite( name );
        sprite.tagList.tags.add( imageInfo.defineBits );

		DefineShape ds3 = ImageShapeBuilder.buildImage(imageInfo.defineBits, imageInfo.width, imageInfo.height);
		sprite.tagList.defineShape3(ds3);

		PlaceObject po2 = new PlaceObject(ds3, 1);
		po2.setMatrix(new Matrix());
		// po2.setName(name);

		sprite.tagList.placeObject2(po2);
        return sprite;
	}

    public static DefineSprite buildSlicedSprite(String name, ImageInfo imageInfo, Map<String, Object> args) throws TranscoderException
    {
        DefineSprite sprite = new DefineSprite( name );
        MovieTranscoder.defineScalingGrid( sprite, args );
        DefineShape shape = generateSlicedShape( imageInfo.defineBits, sprite.scalingGrid.rect, imageInfo.width*20, imageInfo.height*20);

        PlaceObject po = new PlaceObject( shape, 10 );
        Matrix tm = new Matrix();
        tm.setScale(1,1);
        po.setMatrix(tm);
        sprite.tagList.placeObject( po );
        return sprite;
    }

    /**
     * Wraps the Shape from generateSmoothingShape() in a Sprite.
     */
    public static DefineSprite buildSmoothingSprite(String name, ImageInfo imageInfo) throws TranscoderException
    {
        DefineSprite sprite = new DefineSprite(name);
        DefineShape shape = generateSmoothingShape(imageInfo);
        PlaceObject placeObject = new PlaceObject(shape, 10);
        Matrix matrix = new Matrix();
        matrix.setScale(1,1);
        placeObject.setMatrix(matrix);
        sprite.tagList.placeObject(placeObject);
        return sprite;
    }

    public String getAssociatedClass(DefineTag tag)
    {
        if (tag instanceof DefineBits)
        {
            StandardDefs standardDefs = ThreadLocalToolkit.getStandardDefs();
            return standardDefs.getCorePackage() + ".BitmapAsset";
        }

        return super.getAssociatedClass(tag);
    }

    static public class ImageInfo
    {
        public DefineBits defineBits;
        public int width;
        public int height;
    }

    public static final class ScalingGridException extends TranscoderException
    {
        private static final long serialVersionUID = -834180976279170821L;
    }
}
