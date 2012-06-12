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

package flex2.compiler.fxg;

import java.io.File;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import com.adobe.fxg.dom.FXGNode;
import com.adobe.fxg.swf.FXG2SWFTranscoder;
import com.adobe.internal.fxg.dom.CDATANode;
import com.adobe.internal.fxg.dom.GraphicContentNode;
import com.adobe.internal.fxg.dom.GroupNode;
import com.adobe.internal.fxg.dom.MaskableNode;
import com.adobe.internal.fxg.dom.MaskingNode;
import com.adobe.internal.fxg.dom.RichTextNode;
import com.adobe.internal.fxg.dom.TextGraphicNode;
import com.adobe.internal.fxg.dom.TextNode;
import com.adobe.internal.fxg.dom.richtext.BRNode;
import com.adobe.internal.fxg.dom.richtext.DivNode;
import com.adobe.internal.fxg.dom.richtext.ImgNode;
import com.adobe.internal.fxg.dom.richtext.LinkNode;
import com.adobe.internal.fxg.dom.richtext.TextLayoutFormatNode;
import com.adobe.internal.fxg.dom.richtext.ParagraphNode;
import com.adobe.internal.fxg.dom.richtext.SpanNode;
import com.adobe.internal.fxg.dom.richtext.TCYNode;
import com.adobe.internal.fxg.dom.richtext.TabNode;
import com.adobe.internal.fxg.dom.types.BlendMode;
import com.adobe.internal.fxg.dom.types.MaskType;

import flash.swf.tags.DefineSprite;
import flash.swf.tags.DefineTag;
import flash.swf.tags.PlaceObject;
import flash.util.StringUtils;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.reflect.Property;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.reflect.TypeTable;

/**
 * This implementation generates ActionScript classes for features not supported
 * in SWF tags. For example, ActionScript classes must be generated to draw
 * FXG 1.0 TextGraphic nodes programmatically (using instances of the
 * spark.components.RichText ActionScript class). To maintain a link between
 * the DefineSprite display list and a generated RichText wrapper class, a
 * SWF SymbolClass is used and associated with the DefineSprite.
 * 
 * Other features not supported in SWF that require ActionScript classes to be
 * generated include alpha masks, luminosity masks, and pixel-bender based
 * blend modes, namely: colordodge, colorburn, exclusion, softlight, hue,
 * saturation, color, and luminosity.
 * 
 * @author Peter Farland
 * @author Kaushal Kantawala
 */
public class FlexFXG2SWFTranscoder extends FXG2SWFTranscoder
{
    private FXGSymbolClass graphicClass;
    private String packageName;

    private TypeTable typeTable;
    private Type divType;
    private Type imgType;
    private Type linkType;
    private Type richTextType; // Note: TextGraphic and RichText use same type
    private Type paragraphType;
    private Type spanType;
    private Type tabType;
    private Type tcyType;
    private Type textLayoutFormatType;

    /**
     * Construct a Flex specific FXG to SWF tag transcoder.
     * 
     * @param typeTable A TypeTable is used to look up type information while
     * generating ActionScript source for a TextGraphic section of an FXG
     * document. 
     */
    public FlexFXG2SWFTranscoder(TypeTable typeTable)
    {
        super();
        this.typeTable = typeTable;
        if (typeTable != null)
        {
            divType = typeTable.getType(StandardDefs.CLASS_TEXT_DIV);
            linkType = typeTable.getType(StandardDefs.CLASS_TEXT_LINK);
            imgType = typeTable.getType(StandardDefs.CLASS_TEXT_IMG);
            richTextType = typeTable.getType(StandardDefs.CLASS_TEXT_RICHTEXT);
            paragraphType = typeTable.getType(StandardDefs.CLASS_TEXT_PARAGRAPH);
            spanType = typeTable.getType(StandardDefs.CLASS_TEXT_SPAN);
            tabType = typeTable.getType(StandardDefs.CLASS_TEXT_TAB);
            tcyType = typeTable.getType(StandardDefs.CLASS_TEXT_TCY);
            textLayoutFormatType = typeTable.getType(StandardDefs.CLASS_TEXT_LAYOUT_FORMAT);
        }
    }

    /**
     * Traverses an FXG DOM to generate a SWF graphics primitives, with the
     * root DefineSprite associated with a generated ActionScript symbol class.
     * 
     * @param node The root node of an FXG DOM.
     * @param className The class name of the generated symbol class.
     * @return an FXGSymbolClass context that includes generated sources and
     * associated DefineSprites.
     */
    public FXGSymbolClass transcode(FXGNode node, String packageName, String className)
    {
        this.packageName = packageName;

        if (node instanceof FlexGraphicNode)
        {
            FlexGraphicNode graphicNode = (FlexGraphicNode)node;

            graphicClass = new FXGSymbolClass();
            graphicClass.setPackageName(packageName);
            graphicClass.setClassName(className);

            DefineSprite sprite = (DefineSprite)transcode(graphicNode);
            graphicClass.setSymbol(sprite);
            
            // use specified className if specified
            if (graphicNode.className != null)
            	sprite.name = graphicNode.className;

            // Create a new sprite class to map to this Graphic's DefineSprite
            StringBuilder buf = new StringBuilder(512);
            buf.append("package ").append(packageName).append("\n");
            buf.append("{\n\n");
            if (graphicNode.baseClassName != null)
            {
            	buf.append("import ");
            	buf.append(graphicNode.baseClassName);
            	buf.append(";\n\n");
            	buf.append("public class ").append(className).append(" extends ");
            	buf.append(graphicNode.baseClassName);
            	buf.append("\n");
            }
            else
            {
            	buf.append("import spark.core.SpriteVisualElement;\n\n");
            	buf.append("public class ").append(className).append(" extends SpriteVisualElement\n");
            }
            buf.append("{\n");
            buf.append("    public function ").append(className).append("()\n");
            buf.append("    {\n");
            buf.append("        super();\n");

            if (!Double.isNaN(graphicNode.viewWidth))
                buf.append("        viewWidth = ").append(graphicNode.viewWidth).append(";\n");

            if (!Double.isNaN(graphicNode.viewHeight))
                buf.append("        viewHeight = ").append(graphicNode.viewHeight).append(";\n");

            if (graphicNode.getMaskType() == MaskType.ALPHA && graphicNode.mask != null)
            {
                int maskIndex = graphicNode.mask.getMaskIndex();
                buf.append("        this.cacheAsBitmap = true;\n");
                buf.append("        this.mask = this.getChildAt(").append(maskIndex).append(");\n");
            }

            buf.append("    }\n"); // End constructor
			buf.append("}\n"); // End class
	        buf.append("}\n"); // End package

            graphicClass.setGeneratedSource(buf.toString());

            return graphicClass;
        }

        return null;
    }

    @Override
    /**
     * This override simply ensures that a FlexFXG2SWFTranscoder is created
     * instead of an instance of the base class FXG2SWFTranscoder.
     * 
     * @return a new transcoder with an isolated context to process a Library
     * Definition.
     */
    public FXG2SWFTranscoder newInstance()
    {
        FlexFXG2SWFTranscoder graphics = new FlexFXG2SWFTranscoder(typeTable);
        graphics.packageName = packageName;
        graphics.graphicClass = graphicClass;
        graphics.definitions = definitions;
        return graphics;
    }

    //--------------------------------------------------------------------------
    //
    //  Advanced Graphics Code Generation
    //
    //--------------------------------------------------------------------------

    @Override
    /**
     * This override handles advanced mask features not supported by SWF. This
     * includes alpha and luminosity masks.
     * 
     * @param node - the node being masked (which has a reference to the mask
     * node)
     * @param parentSprite - the SWF DefineSprite that will be the parent of
     * this node when added to the display list
     */
    protected PlaceObject mask(MaskableNode node, DefineSprite parentSprite)
    {
        MaskingNode mask = node.getMask();
        PlaceObject po3 = super.mask(node, parentSprite); 

        if (mask != null)
        {
            MaskType maskType = node.getMaskType(); 

            if (maskType != MaskType.CLIP)
            {
                // Record the display list position that the mask was placed.
                // The ActionScript display list is 0 based, but SWF the depth
                // counter starts at 1, so we subtract 1.
                int maskIndex = parentSprite.depthCounter - 1;
                mask.setMaskIndex(maskIndex);
            }

            if (maskType == MaskType.LUMINOSITY)
            {
                // Create a new SymbolClass to map to this mask's
                // DefineSprite (see below)  
                String className = createUniqueName(graphicClass.getClassName() + "_Mask");
                FXGSymbolClass symbolClass = new FXGSymbolClass();
                symbolClass.setPackageName(packageName);
                symbolClass.setClassName(className);

                // Then record this SymbolClass with the top-level graphic
                // SymbolClass so that it will be associated with the FXG asset.
                graphicClass.addAdditionalSymbolClass(symbolClass);

                // Calculate luminosity mode
                int mode = 0;

                if (node.getLuminosityClip())
                    mode += 2;

                if (node.getLuminosityInvert())
                    mode += 1;

                StringBuilder buf = new StringBuilder(768);
                buf.append("package ").append(packageName).append("\n");
                buf.append("{\n\n");
                buf.append("import flash.display.Sprite;\n");
                buf.append("import spark.filters.ShaderFilter;\n");
                buf.append("import mx.graphics.shaderClasses.LuminosityMaskShader;\n\n");
                buf.append("public class ").append(className).append(" extends Sprite\n");
                buf.append("{\n");
                buf.append("    public function ").append(className).append("()\n");
                buf.append("    {\n");
                buf.append("        super();\n");
                buf.append("        this.cacheAsBitmap = true;\n");
                buf.append("        var shader:LuminosityMaskShader = new LuminosityMaskShader();\n");
                buf.append("        shader.mode = ").append(mode).append(";\n");
                buf.append("        var filter:ShaderFilter = new ShaderFilter(shader);\n");
                buf.append("        this.filters = [filter.clone()];\n");
                buf.append("    }\n");
                buf.append("}\n"); // End class
                buf.append("}\n"); // End package

                symbolClass.setGeneratedSource(buf.toString());
                symbolClass.setSymbol(po3.ref);
            }
        }

        return po3;
    }

    @Override
    /**
     * This override handles graphic content nodes that make use of advanced
     * graphics features not supported by SWF. A Group is translated into a 
     * SWF DefineSprite tag. Shapes are translated into SWF DefineShape tags.
     * 
     * @param node - the graphic content node
     * @return the PlaceObjcet definition that would place the graphic on stage
     */
    protected PlaceObject graphicContentNode(GraphicContentNode node)
    {
        // Keep track of whether a node had a mask and filters as this
        // scenario needs to be special cased to match the rendering order 
        // of the ActionScript drawing API.
        boolean hasMaskAndFilters = node.mask != null && node.filters != null;

        PlaceObject po3 = super.graphicContentNode(node);

        // We skip text nodes because they already generate a symbol class
        // and will handle advanced graphics there
        if (po3 != null && !(node instanceof TextNode) && hasAdvancedGraphics(node))
        {
            SymbolClassType symbolClassType = SymbolClassType.SHAPE;
            if (hasMaskAndFilters || (node instanceof GroupNode))
                symbolClassType = SymbolClassType.SPRITE;

            advancedGraphics(node, po3.ref, symbolClassType);
        }

        return po3;
    }

    @Override
    /**
     * This override handles Group nodes that make use of advanced
     * graphics features not supported by SWF. Groups are translated into
     * SWF DefineSprites and can be linked to a SymbolClass that will use
     * ActionScript to draw the advanced graphic features.
     * 
     * @param node - the Group node
     * @return the PlaceObject definition that would place the Group on stage
     */
    protected PlaceObject group(GroupNode node)
    {
        PlaceObject po3 = super.group(node);

        if (po3 != null && hasAdvancedGraphics(node))
            advancedGraphics(node, po3.ref, SymbolClassType.SPRITE);

        return po3;
    }

    /**
     * Determines whether a node uses advanced graphics features which are not
     * supported by the SWF format. If so, we will need to generate
     * ActionScript code to instruct the player to draw the advanced features.
     * 
     * @param node - the graphics node that may make use of advanced graphics
     * features
     * @return true if advanced graphics features are in use
     */
    private boolean hasAdvancedGraphics(MaskableNode node)
    {
        if (node.getMask() != null &&
            (node.getMaskType() == MaskType.ALPHA ||
             node.getMaskType() == MaskType.LUMINOSITY))
        {
            return true;
        }
        else if (node instanceof GraphicContentNode)
        {
            GraphicContentNode graphicNode = (GraphicContentNode)node;
            if (graphicNode.blendMode.needsPixelBenderSupport())
                return true;
        }

        return false;
    }

    /**
     * Some advanced graphics features are not supported by SWF. This helper
     * method generates ActionScript instructions to handle advanced features
     * such as alpha masks, luminosity masks, or pixel-bender based blend modes
     * (e.g. colordodge, colorburn, exclusion, softlight, hue, saturation, 
     * color, and luminosity).
     * 
     * @param node - an FXG node that uses advanced graphics features
     * @param symbol - the SWF symbol for this node
     * @param symbolClassType - determines the base type for the SymbolClass
     */
    private void advancedGraphics(GraphicContentNode node, DefineTag symbol,
            SymbolClassType symbolClassType)
    {
        MaskingNode maskNode = node.getMask();

        // Create a new SymbolClass to map to this mask's
        // DefineSprite (see below)
        String className = graphicClass.getClassName();
        if (maskNode != null)
            className += "_Maskee";

        className = createUniqueName(className);

        FXGSymbolClass symbolClass = new FXGSymbolClass();
        symbolClass.setPackageName(packageName);
        symbolClass.setClassName(className);

        // Then record this SymbolClass with the top-level graphic
        // SymbolClass so that it will be associated with the FXG asset.
        graphicClass.addAdditionalSymbolClass(symbolClass);

        StringBuilder buf = new StringBuilder(512);
        buf.append("package ").append(packageName).append("\n");
        buf.append("{\n\n");

        // Determine Base Class
        String baseClassName = null;
        if (symbolClassType == SymbolClassType.SPRITE)
        {
            buf.append("import flash.display.Sprite;\n");
            baseClassName = "Sprite";
        }
        else
        {
            buf.append("import flash.display.Shape;\n");
            baseClassName = "Shape";
        }

        // Advanced BlendModes
        String blendModeImport = generateBlendModeImport(node.blendMode);
        if (blendModeImport != null)
            buf.append(blendModeImport);
        String blendModeShader = generateBlendMode(node.blendMode);

        // Class Definition and Constructor
        buf.append("public class ").append(className).append(" extends ").append(baseClassName).append("\n");
        buf.append("{\n");
        buf.append("    public function ").append(className).append("()\n");
        buf.append("    {\n");
        buf.append("        super();\n");
        buf.append("        this.cacheAsBitmap = true;\n");

        // Alpha and Luminosity Masks
        if (maskNode != null)
        {
            int maskIndex = maskNode.getMaskIndex();
            if (symbolClassType == SymbolClassType.SPRITE)
                buf.append("        this.mask = this.getChildAt(").append(maskIndex).append(");\n");
            else
                buf.append("        this.mask = this.parent.getChildAt(").append(maskIndex).append(");\n");
        }

        // BlendMode Shader
        if (blendModeShader != null)
            buf.append(blendModeShader);

        buf.append("    }\n"); // End constructor
        buf.append("}\n"); // End class
        buf.append("}\n"); // End package

        symbolClass.setGeneratedSource(buf.toString());
        symbolClass.setSymbol(symbol);
    }

    /**
     * Generates a snippet of ActionScript source code that imports the correct
     * class for the corresponding blend mode.
     * 
     * @param blendMode - the type of blend mode
     * @return a String snippet of ActionScript to import a blend mode class
     */
    private String generateBlendModeImport(BlendMode blendMode)
    {
        if (blendMode == BlendMode.COLOR)
            return "import mx.graphics.shaderClasses.ColorShader;\n\n";
        else if (blendMode == BlendMode.COLORBURN)
            return "import mx.graphics.shaderClasses.ColorBurnShader;\n\n";
        else if (blendMode == BlendMode.COLORDODGE)
            return "import mx.graphics.shaderClasses.ColorDodgeShader;\n\n";
        else if (blendMode == BlendMode.EXCLUSION)
            return "import mx.graphics.shaderClasses.ExclusionShader;\n\n";
        else if (blendMode == BlendMode.HUE)
            return "import mx.graphics.shaderClasses.HueShader;\n\n";
        else if (blendMode == BlendMode.LUMINOSITY)
            return "import mx.graphics.shaderClasses.LuminosityShader;\n\n";
        else if (blendMode == BlendMode.SATURATION)
            return "import mx.graphics.shaderClasses.SaturationShader;\n\n";
        else if (blendMode == BlendMode.SOFTLIGHT)
            return"import mx.graphics.shaderClasses.SoftLightShader;\n\n";
        else
            return null;
    }

    /**
     * Generates a snippet of ActionScript source code that instantiates a new
     * blend mode.
     * 
     * @param blendMode - the type of blend mode
     * @return a String snippet of ActionScript to create a new blend mode
     */
    private String generateBlendMode(BlendMode blendMode)
    {
        if (blendMode == BlendMode.COLOR)
            return "        this.blendShader = new ColorShader();\n";
        else if (blendMode == BlendMode.COLORBURN)
            return "        this.blendShader = new ColorBurnShader();\n"; 
        else if (blendMode == BlendMode.COLORDODGE)
            return "        this.blendShader = new ColorDodgeShader();\n"; 
        else if (blendMode == BlendMode.EXCLUSION)
            return "        this.blendShader = new ExclusionShader();\n"; 
        else if (blendMode == BlendMode.HUE)
            return "        this.blendShader = new HueShader();\n"; 
        else if (blendMode == BlendMode.LUMINOSITY)
            return "        this.blendShader = new LuminosityShader();\n"; 
        else if (blendMode == BlendMode.SATURATION)
            return "        this.blendShader = new SaturationShader();\n"; 
        else if (blendMode == BlendMode.SOFTLIGHT)
            return "        this.blendShader = new SoftLightShader();\n";
        else
            return null;
    }

    //--------------------------------------------------------------------------
    //
    //  TextGraphic and RichText Code Generation
    //
    //--------------------------------------------------------------------------
    
    @Override
    /**
     * RichText is not supported by SWF. This override uses a Sprite-based
     * ActionScript SymbolClass to create a spark.components.RichText instance
     * to draw the text.
     * 
     * @param node - an FXG 2.0 RichText node
     * @return the PlaceObject definition that would place the associated
     * DefineSprite on the stage
     */
    protected PlaceObject richtext(RichTextNode node)
    {
        return flexText(node);
    }

    @Override
    /**
     * TextGraphic is not supported by SWF. This override uses a Sprite-bsaed
     * ActionScript SymbolClass to create a spark.components.RichText instance
     * to draw the text.
     * 
     * @param node - an FXG 1.0 TextGraphic node
     * @return the PlaceObject definition that would place the associated
     * DefineSprite on the stage
     */
    protected PlaceObject text(TextGraphicNode node)
    {
        return flexText(node);
    }

    /**
     * Generates Flex specific ActionScript for FXG 1.0 &lt;TextGraphic&gt; or
     * FXG 2.0 &lt;RichText&gt; nodes.
     * 
     * @param node - either a TextGraphicNode or RichTextNode.
     * @return the PlaceObject definition that would place the associated
     * DefineSprite on the stage
     */
    private PlaceObject flexText(GraphicContentNode node)
    {
        if (node instanceof TextNode)
        {
            TextNode textNode = ((TextNode)node);

            // Create a new SymbolClass to map to this TextGraphic's
            // DefineSprite (see below)  
            String className = createUniqueName(graphicClass.getClassName() + "_Text");

            FXGSymbolClass spriteSymbolClass = new FXGSymbolClass();
            spriteSymbolClass.setPackageName(packageName);
            spriteSymbolClass.setClassName(className);

            // Then record this SymbolClass with the top-level graphic
            // SymbolClass so that it will be associated with the FXG asset.
            graphicClass.addAdditionalSymbolClass(spriteSymbolClass);

            // Create a DefineSprite to hold this TextGraphic
            DefineSprite textSprite = createDefineSprite(className);
            PlaceObject po3 = placeObject(textSprite, node.createGraphicContext());
            spriteStack.push(textSprite);

            StringBuilder buf = new StringBuilder(4096);
            buf.append("package ").append(packageName).append("\n");
            buf.append("{\n\n");
            buf.append("import flash.events.Event;\n");
            buf.append("import flashx.textLayout.elements.*;\n");
            buf.append("import flashx.textLayout.formats.TextLayoutFormat;\n");
            buf.append("import mx.core.IFlexModuleFactory;\n");
            buf.append("import mx.core.mx_internal;\n");
            buf.append("import spark.components.RichText;\n");
            buf.append("import spark.core.SpriteVisualElement;\n\n");
            buf.append("use namespace mx_internal;\n\n");

            // Advanced BlendModes
            String blendModeImport = generateBlendModeImport(node.blendMode);
            if (blendModeImport != null)
                buf.append(blendModeImport);
            String blendModeShader = generateBlendMode(node.blendMode);

            buf.append("public class ").append(className).append(" extends SpriteVisualElement\n");
            buf.append("{\n");
            buf.append("    public function ").append(className).append("()\n");
            buf.append("    {\n");
            buf.append("        super();\n");
            buf.append("        this.nestedSpriteVisualElement = true;\n");

            if (hasAdvancedGraphics(node))
                buf.append("        this.cacheAsBitmap = true;\n");

            // Alpha Masks
            MaskingNode maskNode = node.getMask();
            if (maskNode != null &&
                    (node.getMaskType() == MaskType.ALPHA ||
                     node.getMaskType() == MaskType.LUMINOSITY))
            {
                int maskIndex = maskNode.getMaskIndex();
                buf.append("        this.mask = this.parent.getChildAt(").append(maskIndex).append(");\n");
            }

            // BlendMode Shader
            if (blendModeShader != null)
                buf.append(blendModeShader);

            // Generate Text
            buf.append("        createText();\n");
            buf.append("    }\n");
            buf.append("\n");
            
            buf.append("    private var _richTextComponent:RichText;\n\n");

            buf.append("    private function createText():void\n");
            buf.append("    {\n");

            SourceContext textSource = generateRichText(textNode);
            if (textSource.functionBuffer != null)
                buf.append(textSource.functionBuffer.toString());

            buf.append("    }\n");

            if (textSource.classBuffer != null)
                buf.append(textSource.classBuffer.toString());

            buf.append(generateModuleFactoryOverride("_richTextComponent"));
            
            buf.append("}\n"); // End class
            buf.append("}\n"); // End package

            spriteSymbolClass.setGeneratedSource(buf.toString());
            spriteSymbolClass.setSymbol(textSprite);

            spriteStack.pop();
            return po3;
        }

        return null;
    }

    /**
     * Generates a unique name by appending a random number to the given base
     * name.
     * 
     * @param baseName the base of the generated name 
     * @return the unique name
     */
    private String createUniqueName(String baseName)
    {
        int r = random.nextInt();
        String suffix = Integer.toString(r);
        if (suffix.charAt(0) == '-')
        {
            suffix = suffix.replace('-', '_');
        }
        return baseName + suffix;
    }

    //--------------------------------------------------------------------------
    //
    // Methods for ActionScript Generation  
    //
    //--------------------------------------------------------------------------

    /**
     * Generates ActionScript code to initialize a new instance of
     * RichText for a given FXG TextGraphic node, its attributes, and any
     * child nodes.
     * 
     * @param node The TextGraphic node to process.
     * 
     * @return Returns the code generation buffers (for the function and
     * potentially class scopes).
     */
    private SourceContext generateRichText(TextNode textNode)
    {
        // Generate ActionScript equivalent of tag markup. We use 1024
        // characters of generated code is sufficient for the initial size of
        // the function scope buffer. We use 0 characters for the class scope
        // buffer until we encounter the special case of:
        //     <img source="@Embed('...')">
        // which involves generating class member variables to embed images.
        SourceContext srcContext = new SourceContext(1024, 0);
        StringBuilder buf = srcContext.functionBuffer;

        Variables varContext = new Variables();
        varContext.setVar(richTextType, NodeType.RICHTEXT);
        String elementVar = varContext.elementVar;

        generateTextVariable(textNode, srcContext, varContext);

        buf.append("        _richTextComponent = ").append(elementVar).append(";\r\n");
        buf.append("        addChild(").append(elementVar).append(");\r\n");
		
        buf.append("        var addHandler:Function = function(event:Event):void\r\n");
        buf.append("        {\r\n");
        buf.append("            removeEventListener(Event.ADDED_TO_STAGE, addHandler);\r\n\r\n");

        buf.append("            // If we don't have a module factory by now then use the root\r\n");
        buf.append("            if (moduleFactory == null && root is IFlexModuleFactory)\r\n");
        buf.append("                moduleFactory = IFlexModuleFactory(root);\r\n");

        buf.append("        };\r\n");
        buf.append("        addEventListener(Event.ADDED_TO_STAGE, addHandler);\r\n");


        return srcContext;
    }
    
    /**
     * Create a module factory override so we do not try to use a RichText's styles until we 
     * have a module factory. The module factory will tell us which style manager to use.
     * 
     * @param elementVar
     * @return
     */
    private String generateModuleFactoryOverride(String elementVar)
    {
        StringBuilder buf = new StringBuilder(1024);

        buf.append("\r\n    /**\r\n");
        buf.append("     *  @private\r\n");
        buf.append("     *  Create a module factory override so we do not try to use a RichText's\r\n");
        buf.append("     *  styles until we have a module factory. The module factory will tell us\r\n");
        buf.append("     *  which style manager to use.\r\n");
        buf.append("     */\r\n");
        buf.append("    override public function set moduleFactory(factory:IFlexModuleFactory):void\r\n");
        buf.append("    {\r\n");
        buf.append("        super.moduleFactory = factory;\r\n");
        buf.append("        ").append(elementVar).append(".regenerateStyleCache(true);\r\n");
        buf.append("        ").append(elementVar).append(".styleChanged(null);\r\n");        
        buf.append("        ").append(elementVar).append(".stylesInitialized();\r\n");
        buf.append("        ").append(elementVar).append(".validateProperties();\r\n");
        buf.append("        ").append(elementVar).append(".validateSize();\r\n");
        buf.append("        ").append(elementVar).append(".setLayoutBoundsSize(NaN, NaN);\r\n");
        buf.append("        ").append(elementVar).append(".validateDisplayList();\r\n");
        buf.append("        invalidateSize();\r\n");
        buf.append("    }\r\n");
        
        return buf.toString();
    }

    /**
     * Generates ActionScript to initialize a variable for a given text node,
     * populates any specified attributes as properties or styles, and
     * recursively processes any text child nodes.
     * @param textNode - the current text node
     * @param srcContext - the current code generation buffers
     * @param varContext - the current generated ActionScript variable context 
     */
    private void generateTextVariable(TextNode textNode,
            SourceContext srcContext, Variables varContext)
    {
        StringBuilder buf = srcContext.functionBuffer;
        Map<String, String> attributes = textNode.getTextAttributes();
        List<TextNode> children = textNode.getTextChildren();

        String currentVar = varContext.elementVar;
        String contentVar = varContext.contentVar;
        String parentClass = varContext.elementClass;
        String parentChildrenVar = varContext.elementChildrenVar;
        Type type = varContext.type;

        if (!varContext.varDeclared)
        {
            // var someElement:SomeElement = new SomeElement();
            buf.append("        var ").append(currentVar).append(":").append(parentClass).append(" = new ").append(parentClass).append("();\r\n");

            // var someContent:Array = [];
            if (contentVar != null)
                buf.append("        var ").append(contentVar).append(":Array = [];\r\n");
        }
        else
        {
            // someElement = new SomeElement();
            buf.append("        ").append(currentVar).append(" = new ").append(parentClass).append("();\r\n");

            // someContent = [];
            if (contentVar != null)
                buf.append("        ").append(contentVar).append(" = [];\r\n");
        }

        // Attributes
        generateAttributes(textNode, type, attributes, srcContext, currentVar);

        // Properties
        // Note: We process RichTextNode properties after content has been assigned.
        if (!(textNode instanceof RichTextNode))
            generateProperties(srcContext, textNode, currentVar, varContext);

        // Child Nodes
        if (children != null && children.size() > 0)
        {
            Iterator<TextNode> iter = children.iterator();
            while (iter.hasNext())
            {
                String elementVar = null;
                TextNode child = iter.next();

                // FXG 2.0
                if (child instanceof RichTextNode)
                {
                    varContext.setVar(richTextType, NodeType.RICHTEXT);
                    elementVar = varContext.elementVar;
                    generateTextVariable(child, srcContext, varContext);
                    buf.append("        ").append(contentVar).append(".push(").append(elementVar).append(");\r\n");
                }
                else if (child instanceof ParagraphNode)
                {
                    varContext.setVar(paragraphType, NodeType.PARAGRAPH);
                    elementVar = varContext.elementVar;
                    generateTextVariable(child, srcContext, varContext);
                    buf.append("        ").append(contentVar).append(".push(").append(elementVar).append(");\r\n");
                }
                else if (child instanceof SpanNode)
                {
                    varContext.setVar(spanType, NodeType.SPAN);
                    elementVar = varContext.elementVar;
                    generateTextVariable(child, srcContext, varContext);
                    buf.append("        ").append(contentVar).append(".push(").append(elementVar).append(");\r\n");
                }
                else if (child instanceof DivNode)
                {
                    varContext.setVar(divType, NodeType.DIV);
                    elementVar = varContext.elementVar;
                    generateTextVariable(child, srcContext, varContext);
                    buf.append("        ").append(contentVar).append(".push(").append(elementVar).append(");\r\n");
                }
                else if (child instanceof CDATANode)
                {
                    // someContent.push("some text");
                    String text = formatString(((CDATANode)child).content);
                    buf.append("        ").append(contentVar).append(".push(").append(text).append(");\r\n");
                }
                else if (child instanceof BRNode)
                {
                    // someContent.push(new BreakElement());
                    buf.append("        ").append(contentVar).append(".push(new BreakElement());\r\n");
                }
                else if (child instanceof ImgNode)
                {
                    varContext.setVar(imgType, NodeType.IMG);
                    elementVar = varContext.elementVar;
                    generateTextVariable(child, srcContext, varContext);
                    buf.append("        ").append(contentVar).append(".push(").append(elementVar).append(");\r\n");
                }
                else if (child instanceof LinkNode)
                {
                    varContext.setVar(linkType, NodeType.LINK);
                    elementVar = varContext.elementVar;
                    generateTextVariable(child, srcContext, varContext);
                    buf.append("        ").append(contentVar).append(".push(").append(elementVar).append(");\r\n");
                }
                else if (child instanceof TabNode)
                {
                    varContext.setVar(tabType, NodeType.TAB);
                    elementVar = varContext.elementVar;
                    generateTextVariable(child, srcContext, varContext);
                    buf.append("        ").append(contentVar).append(".push(").append(elementVar).append(");\r\n");
                }
                else if (child instanceof TCYNode)
                {
                    varContext.setVar(tcyType, NodeType.TCY);
                    elementVar = varContext.elementVar;
                    generateTextVariable(child, srcContext, varContext);
                    buf.append("        ").append(contentVar).append(".push(").append(elementVar).append(");\r\n");
                }
                // FXG 1.0
                else if (child instanceof TextGraphicNode)
                {
                    varContext.setVar(richTextType, NodeType.RICHTEXT);
                    elementVar = varContext.elementVar;
                    generateTextVariable(child, srcContext, varContext);
                    buf.append("        ").append(contentVar).append(".push(").append(elementVar).append(");\r\n");
                }
                else if (child instanceof com.adobe.internal.fxg.dom.text.ParagraphNode)
                {
                    varContext.setVar(paragraphType, NodeType.PARAGRAPH);
                    elementVar = varContext.elementVar;
                    generateTextVariable(child, srcContext, varContext);
                    buf.append("        ").append(contentVar).append(".push(").append(elementVar).append(");\r\n");
                }
                else if (child instanceof com.adobe.internal.fxg.dom.text.SpanNode)
                {
                    varContext.setVar(spanType, NodeType.SPAN);
                    elementVar = varContext.elementVar;
                    generateTextVariable(child, srcContext, varContext);
                    buf.append("        ").append(contentVar).append(".push(").append(elementVar).append(");\r\n");
                }
                else if (child instanceof com.adobe.internal.fxg.dom.text.BRNode)
                {
                    // e.g. someContent.push(new BreakElement());
                    buf.append("        ").append(contentVar).append(".push(new BreakElement());\r\n");
                }
                else
                {
                    // TODO: Error: Unknown Text Tag
                }
            }
        }

        // e.g. someElement.mxmlChildren = someContent;
        if (parentChildrenVar != null && contentVar != null)
            buf.append("        ").append(currentVar).append(".").append(parentChildrenVar).append(" = ").append(contentVar).append(";\r\n");

        // RichText is a special case whose properties must be set after content
        // is assigned and the textFlow has been populated.
        if (textNode instanceof RichTextNode)
            generateProperties(srcContext, textNode, currentVar, varContext);
    }

    /**
     * Generates ActionScript code for child property nodes that represent
     * complex property values. It also generates the property assignment 
     * statement.
     * 
     * @param srcContext - the ActionScript source code generation buffers.
     * @param parentNode - the parent TextNode to process for properties  
     * @param parentVar - the parent variable that declares the properties
     * @param varContext - the current context for generating variables in
     * ActionScript code 
     */
    private void generateProperties(SourceContext srcContext, TextNode parentNode,
            String parentVar, Variables varContext)
    {
        Map<String, TextNode> properties = parentNode.getTextProperties(); 
        if (properties != null)
        {
            StringBuilder buf = srcContext.functionBuffer;

            for (Map.Entry<String, TextNode> entry : properties.entrySet())
            {
                String propertyName = entry.getKey();
                TextNode node = entry.getValue();

                if (node instanceof TextLayoutFormatNode)
                {
                    // RichText does not support setting text layout formatting
                    // at the top level so we must update its textFlow instead.
                    if (parentNode instanceof RichTextNode)
                    {
                        varContext.setVar(textLayoutFormatType, NodeType.TEXT_LAYOUT_FORMAT);
                        generateTextVariable(node, srcContext, varContext);
                        buf.append("        ").append(parentVar).append(".textFlow.").append(propertyName).append(" = ").append(varContext.elementVar).append(";\r\n");
                    }
                    else
                    {
                        varContext.setVar(textLayoutFormatType, NodeType.TEXT_LAYOUT_FORMAT);
                        generateTextVariable(node, srcContext, varContext);
                        buf.append("        ").append(parentVar).append(".").append(propertyName).append(" = ").append(varContext.elementVar).append(";\r\n");
                    }
                }
            }
        }
    }

    /**
     * Converts the attributes specified on an FXG node into ActionScript
     * property initializers.
     * 
     * @param type The ActionScript type for this node.
     * @param attributes The Map of attributes specified on this node.
     * @param srcContext The source code generation buffers.
     * @param variableName The ActionScript variable name representing the
     * instance of this node.
     */
    private void generateAttributes(TextNode node, Type type, Map<String, String> attributes,
            SourceContext srcContext, String variableName)
    {
        if (attributes != null)
        {
            StringBuilder buf = srcContext.functionBuffer;

            // HACK: Handle <img source="@Embed('xyz.jpg')" /> as a special case
            if (node instanceof ImgNode)
            {
                String imgSource = attributes.get("source");
                imgSource = parseSource(imgSource);
                if (imgSource != null)
                {
                    // Resolve relative file path
                    File f = new File(imgSource);
                    if (!f.isAbsolute() && resourceResolver != null)
                    {
                        String resolvedPath = resourceResolver.resolve(imgSource);
                        if (resolvedPath != null)
                            imgSource = resolvedPath;
                    }
                    imgSource = imgSource.replace('\\', '/');

                    // Generate [Embed] for the image.
                    if (srcContext.classBuffer == null)
                        srcContext.classBuffer = new StringBuilder(128);
                    StringBuilder classBuf = srcContext.classBuffer;
                    String imgVar = createUniqueName("img");
                    classBuf.append("\n");
                    classBuf.append("    [Embed(source=\"").append(imgSource).append("\")]\n");
                    classBuf.append("    private static var ").append(imgVar).append(":Class;\n");

                    // Generate source attribute assignment
                    buf.append("        ").append(variableName).append(".source = ").append(imgVar).append(";\n");

                    attributes.remove("source");
                }
            }

            for (Map.Entry<String, String> entry : attributes.entrySet())
            {
                String attribName = entry.getKey();
                String attribValue = entry.getValue();
                String thisAttrib = null;

                Property property = type.getProperty(attribName);
                if (property != null)
                {
                    Type propertyType = property.getType();
                    if (propertyType.isAssignableTo(typeTable.stringType)
                        || propertyType == typeTable.objectType
                        || propertyType == typeTable.noType) 
                    {
                        thisAttrib = attribName + " = \"" + attribValue + "\"";
                    }
                    else
                    {
                         thisAttrib = attribName + " = " + attribValue;
                    }
                }
                else if (type.getStyle(attribName) != null)
                {
                    thisAttrib = "setStyle(\"" + attribName + "\", \"" + attribValue + "\")";
                }

                if (thisAttrib != null)
                    buf.append("        " + variableName + '.' + thisAttrib + ";\r\n");
            }
        }
    }

    /**
     * Quotes a String and escapes any special characters so that it can be
     * used as a literal ActionScript value.
     * 
     * @param content the raw String
     * @return a Quoted String suitable for use as an ActionScript value. 
     */
    private String formatString(String content)
    {
        if (content != null)
            return StringUtils.formatString(content);

        return content;
    }

    //--------------------------------------------------------------------------
    //
    // Helper Classes for ActionScript Source Code Generation
    //
    //--------------------------------------------------------------------------

    /**
     * An enumeration that specifies the base type of a SymbolClass.
     */
    private static enum SymbolClassType
    {
        SPRITE,
        SHAPE
    }
    
    /**
     * Text node type enumeration.
     */
    private static enum NodeType
    {
        DIV,
        FORMAT,
        IMG,
        LINK,
        PARAGRAPH,
        RICHTEXT,
        SPAN,
        TAB,
        TCY,
        TEXT_LAYOUT_FORMAT
    }

    /**
     * Provides a context to the current ActionScript generation buffers.
     * Multiple buffers allow code to be generated in different parts of an
     * ActionScript file, such as generating a class scope member while 
     * generating a function scope.
     */
    private static class SourceContext
    {
        /**
         * Constructor.
         * @param functionSize - Initial function buffer size.
         * @param classSize - Initial class buffer size.
         */
        private SourceContext(int functionSize, int classSize)
        {
            if (functionSize > 0)
                functionBuffer = new StringBuilder(functionSize);

            if (classSize > 0)
                classBuffer = new StringBuilder(classSize);
        }

        private StringBuilder functionBuffer;
        private StringBuilder classBuffer;
    }
    
    /**
     * Provides a context of variables in use for ActionScript source
     * generation of a text node and its children.
     */
    private static class Variables
    {
        private Variable divVar;
        private Variable formatVar;
        private Variable imgVar;
        private Variable linkVar;
        private Variable paragraphVar;
        private Variable richTextVar;
        private Variable spanVar;
        private Variable tabVar;
        private Variable tcyVar;
        private Variable textLayoutFormatVar;

        private Variables()
        {
        }

        private void setVar(Type type, NodeType nodeType)
        {
            this.type = type;
            Variable var = getVar(nodeType);
            if (var != null)
            {
                var.count++;
                if (!var.reusableVar)
                {
                    varDeclared = false;
                    elementVar = var.elementVar + var.count;
                    contentVar = var.contentVar + var.count;
                }
                else
                {
                    varDeclared = var.count > 1;
                    elementVar = var.elementVar;
                    contentVar = var.contentVar;
                }
                elementClass = var.elementClass;
                elementChildrenVar = var.elementChildrenVar;
            }
        }

        private Variable getVar(NodeType nodeType)
        {
            switch (nodeType)
            {
                case DIV:
                {
                    if (divVar == null)
                        divVar = new Variable("DivElement", "divElement", "divContent", "mxmlChildren", false);
                    return divVar; 
                }
                case FORMAT:
                {
                    if (formatVar == null)
                        formatVar = new Variable("TextLayoutFormat", "formatElement", null, null, false);
                    return formatVar;
                }
                case IMG:
                {
                    if (imgVar == null)
                        imgVar = new Variable("InlineGraphicElement", "imgElement", null, null, true);
                    return imgVar;
                }
                case LINK:
                {
                    if (linkVar == null)
                        linkVar = new Variable("LinkElement", "linkElement", "linkContent", "mxmlChildren", true);
                    return linkVar;
                }
                case PARAGRAPH:
                {
                    if (paragraphVar == null)
                        paragraphVar = new Variable("ParagraphElement", "paragraphElement", "paragraphContent", "mxmlChildren", true);
                    return paragraphVar;
                }
                case RICHTEXT:
                {
                    if (richTextVar == null)
                        richTextVar = new Variable("RichText", "textElement", "textContent", "content", true);
                    return richTextVar;
                }
                case SPAN:
                {
                    if (spanVar == null)
                        spanVar = new Variable("SpanElement", "spanElement", "spanContent", "mxmlChildren", true);
                    return spanVar;
                }
                case TAB:
                {
                    if (tabVar == null)
                        tabVar = new Variable("TabElement", "tabElement", null, null, true);
                    return tabVar;
                }
                case TCY:
                {
                    if (tcyVar == null)
                        tcyVar = new Variable("TCYElement", "tcyElement", "tcyContent", "mxmlChildren", true);
                    return tcyVar;
                }
                case TEXT_LAYOUT_FORMAT:
                {
                    if (textLayoutFormatVar == null)
                        textLayoutFormatVar = new Variable("TextLayoutFormat", "tlfElement", null, null, true);
                    return textLayoutFormatVar;
                }
            }

            return null;
        }

        private Type type;
        private boolean varDeclared;
        private String elementClass;
        private String elementVar;
        private String contentVar;
        private String elementChildrenVar;
    }

    /**
     * The context for an individual variable.
     */
    private static class Variable
    {
        private Variable(String elementClass, String elementVar, String contentVar, String elementChildrenVar, boolean reusableVar)
        {
            this.elementClass = elementClass;
            this.elementVar = elementVar;
            this.contentVar = contentVar;
            this.elementChildrenVar = elementChildrenVar;
            this.reusableVar = reusableVar;
        }

        private int count;
        private boolean reusableVar;
        private String elementClass;
        private String elementVar;
        private String contentVar;
        private String elementChildrenVar;
    }
}
