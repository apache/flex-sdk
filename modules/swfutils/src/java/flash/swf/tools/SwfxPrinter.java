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

package flash.swf.tools;

import macromedia.abc.AbcParser;
import macromedia.asc.embedding.CompilerHandler;
import macromedia.asc.embedding.avmplus.ActionBlockEmitter;
import macromedia.asc.parser.ProgramNode;
import macromedia.asc.semantics.ObjectValue;
import macromedia.asc.semantics.TypeValue;
import macromedia.asc.util.Context;
import macromedia.asc.util.ContextStatics;
import macromedia.asc.util.StringPrintWriter;
import flash.swf.ActionDecoder;
import flash.swf.Dictionary;
import flash.swf.Header;
import flash.swf.SwfDecoder;
import flash.swf.Tag;
import flash.swf.TagDecoder;
import flash.swf.TagEncoder;
import flash.swf.TagHandler;
import flash.swf.TagValues;
import flash.swf.tags.*;
import flash.swf.types.ActionList;
import flash.swf.types.ButtonCondAction;
import flash.swf.types.ButtonRecord;
import flash.swf.types.ClipActionRecord;
import flash.swf.types.CurvedEdgeRecord;
import flash.swf.types.EdgeRecord;
import flash.swf.types.FillStyle;
import flash.swf.types.Filter;
import flash.swf.types.GlyphEntry;
import flash.swf.types.GradRecord;
import flash.swf.types.ImportRecord;
import flash.swf.types.LineStyle;
import flash.swf.types.MorphFillStyle;
import flash.swf.types.MorphGradRecord;
import flash.swf.types.MorphLineStyle;
import flash.swf.types.Shape;
import flash.swf.types.ShapeRecord;
import flash.swf.types.ShapeWithStyle;
import flash.swf.types.SoundInfo;
import flash.swf.types.StraightEdgeRecord;
import flash.swf.types.StyleChangeRecord;
import flash.swf.types.TextRecord;
import flash.swf.types.FocalGradient;
import flash.swf.types.KerningRecord;
import flash.util.Base64;
import flash.util.FileUtils;
import flash.util.SwfImageUtils;
import flash.util.Trace;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.net.URL;
import java.net.URLConnection;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

/**
 * This class supports printing out a SWF in a human readable XML
 * format.
 *
 * @author Clement Wong
 * @author Edwin Smith
 */
public final class SwfxPrinter extends TagHandler
	{
		/**
		 * this value should get set after the header is parsed
		 */
		private Integer swfVersion = null;
		
		private boolean abc = false;
		private boolean showActions = true;
		private boolean showOffset = false;
		private boolean showByteCode = false;
		private boolean showDebugSource = false;
		private boolean glyphs = true;
		private boolean external = false;
		private String externalPrefix = null;
		private String externalDirectory = null;
		private boolean decompile;
		private boolean defunc;
		private int indent = 0;
		private boolean tabbedGlyphs = false;
		
		static
		{
			TypeValue.init();
			ObjectValue.init();
		}
		
		public SwfxPrinter(PrintWriter out)
		{
			this.out = out;
		}
		
		private void printActions(ActionList list)
		{
			if (decompile)
			{
				/*
				 AsNode node;
				 try
				 {
				 node = new Decompiler(defunc).decompile(list);
				 new PrettyPrinter(out, indent).list(node);
				 return;
				 }
				 catch (Exception e)
				 {
				 indent();
				 out.println("// error while decompiling.  falling back to disassembler");
				 }
				 */
			}
			
			Disassembler disassembler = new Disassembler(out, showOffset, indent);
			if (showDebugSource)
			{
				disassembler.setShowDebugSource(showDebugSource);
				disassembler.setComment("// ");
			}
			list.visitAll(disassembler);
		}
		
		private void setExternal(boolean b, String path)
		{
			external = b;
			
			if (external)
			{
				if (path != null)
				{
					externalPrefix = baseName(path);
					externalDirectory = dirName(path);
				}
				
				if (externalPrefix == null)
					externalPrefix = "";
				else
					externalPrefix += "-";
				if (externalDirectory == null)
					externalDirectory = "";
			}
		}
		
		private void indent()
		{
			for (int i = 0; i < indent; i++)
			{
				out.print("  ");
			}
		}
		
		public void header(Header h)
		{
			swfVersion = h.version;
			out.println("<!-- ?xml version=\"1.0\" encoding=\"UTF-8\"? -->");
			out.println("<swf xmlns='http://macromedia/2003/swfx'" +
						" version='" + h.version + "'" +
						" framerate='" + h.rate + "'" +
						" size='" + h.size + "'" +
						" compressed='" + h.compressed + "'" +
						" >");
			indent++;
			indent();
			out.println("<!-- framecount=" + h.framecount + " length=" + h.length + " -->");
		}
		
		public void productInfo(ProductInfo productInfo)
		{
			open(productInfo);
			out.print(" product='" + productInfo.getProductString() + "'");
			out.print(" edition='" + productInfo.getEditionString() + "'");
			out.print(" version='" + productInfo.getMajorVersion() + "." + productInfo.getMinorVersion() + "'");
			out.print(" build='" + productInfo.getBuild() + "'");
			out.print(" compileDate='" + DateFormat.getInstance().format(new Date(productInfo.getCompileDate())) + "'");
			close();
		}
		
		public void metadata(Metadata tag)
		{
			open(tag);
			end();
			indent();
			out.println(tag.xml);
			close(tag);
		}
		
		public void fileAttributes(FileAttributes tag)
		{
			open(tag);
			out.print(" useDirectBlit='" + tag.useDirectBlit + "'");
			out.print(" useGPU='" + tag.useGPU + "'");
			out.print(" hasMetadata='" + tag.hasMetadata + "'");
			out.print(" actionScript3='" + tag.actionScript3 + "'");
			out.print(" suppressCrossDomainCaching='" + tag.suppressCrossDomainCaching + "'");
			out.print(" swfRelativeUrls='" + tag.swfRelativeUrls + "'");
			out.print(" useNetwork='" + tag.useNetwork + "'");
			close();
		}
		
		
		private final PrintWriter out;
		
		private Dictionary dict;
		
		public void setDecoderDictionary(Dictionary dict)
		{
			this.dict = dict;
		}
		
		public void setOffsetAndSize(int offset, int size)
		{
			// Note: 'size' includes the size of the tag's header
			// so it is either length + 2 or length + 6.
			
			if (showOffset)
			{
				indent();
				out.println("<!--" +
							" offset=" + offset +
							" size=" + size +
							" -->");
			}
		}
		
		private void open(Tag tag)
		{
			indent();
			out.print("<" + TagValues.names[tag.code]);
		}
		
		private void end()
		{
			out.println(">");
			indent++;
		}
		
		private void openCDATA()
		{
			indent();
			out.println("<![CDATA[");
			indent++;
		}
		
		private void closeCDATA()
		{
			indent--;
			indent();
			out.println("]]>");
		}
		
		private void close()
		{
			out.println("/>");
		}
		
		private void close(Tag tag)
		{
			indent--;
			indent();
			out.println("</" + TagValues.names[tag.code] + ">");
		}
		
		public void error(String s)
		{
			indent();
			out.println("<!-- error: " + s + " -->");
		}
		
		public void unknown(GenericTag tag)
		{
			indent();
			out.println("<!-- unknown tag=" + tag.code + " length=" +
						(tag.data != null ? tag.data.length : 0) + " -->");
		}
		
		public void showFrame(ShowFrame tag)
		{
			open(tag);
			close();
		}
		
		public void defineShape(DefineShape tag)
		{
			printDefineShape(tag, false);
		}
		
		private void printDefineShape(DefineShape tag, boolean alpha)
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			out.print(" bounds='" + tag.bounds + "'");
			if (tag.code == Tag.stagDefineShape4)
			{
				out.print(" edgebounds='" + tag.edgeBounds + "'");
				out.print(" usesNonScalingStrokes='" + tag.usesNonScalingStrokes + "'");
				out.print(" usesScalingStrokes='" + tag.usesScalingStrokes + "'");
			}
			
			end();
			
			printShapeWithStyles(tag.shapeWithStyle, alpha);
			
			close(tag);
		}
		
		private String id(DefineTag tag)
		{
			final int id = dict.getId(tag);
			return String.valueOf(id);
		}
		
		static final char[] digits = new char[]{
        '0', '1', '2', '3', '4', '5', '6', '7',
        '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
		};
		
		/**
		 * @param rgb as an integer, 0x00RRGGBB
		 * @return string formatted as #RRGGBB
		 */
		public String printRGB(int rgb)
		{
			StringBuilder b = new StringBuilder();
			b.append('#');
			int red = (rgb >> 16) & 255;
			b.append(digits[(red >> 4) & 15]);
			b.append(digits[red & 15]);
			int green = (rgb >> 8) & 255;
			b.append(digits[(green >> 4) & 15]);
			b.append(digits[green & 15]);
			int blue = rgb & 255;
			b.append(digits[(blue >> 4) & 15]);
			b.append(digits[blue & 15]);
			return b.toString();
		}
		
		/**
		 * @param rgb as an integer, 0xAARRGGBB
		 * @return string formatted as #RRGGBBAA
		 */
		public String printRGBA(int rgb)
		{
			StringBuilder b = new StringBuilder();
			b.append('#');
			int red = (rgb >> 16) & 255;
			b.append(digits[(red >> 4) & 15]);
			b.append(digits[red & 15]);
			int green = (rgb >> 8) & 255;
			b.append(digits[(green >> 4) & 15]);
			b.append(digits[green & 15]);
			int blue = rgb & 255;
			b.append(digits[(blue >> 4) & 15]);
			b.append(digits[blue & 15]);
			int alpha = (rgb >> 24) & 255;
			b.append(digits[(alpha >> 4) & 15]);
			b.append(digits[alpha & 15]);
			return b.toString();
		}
		
		public void placeObject(PlaceObject tag)
		{
			open(tag);
			out.print(" idref='" + idRef(tag.ref) + "'");
			out.print(" depth='" + tag.depth + "'");
			out.print(" matrix='" + tag.matrix + "'");
			if (tag.colorTransform != null)
				out.print(" colorXform='" + tag.colorTransform + "'");
			close();
		}
		
		public void removeObject(RemoveObject tag)
		{
			open(tag);
			out.print(" idref='" + idRef(tag.ref) + "'");
			close();
		}
		
		public void outputBase64(byte[] data)
		{
			Base64.Encoder e = new Base64.Encoder(1024);
			
			indent();
			int remain = data.length;
			while (remain > 0)
			{
				int block = 1024;
				if (block > remain)
					block = remain;
				e.encode(data, data.length - remain, block);
				out.print(e.drain());
				remain -= block;
			}
			out.println(e.flush());
		}
		//private byte[]  jpegTable = null;
		
		public void defineBits(DefineBits tag)
		{
			if (tag.jpegTables == null)
			{
				out.println("<!-- warning: no JPEG table tag found. -->");
			}
			
			open(tag);
			out.print(" id='" + id(tag) + "'");
			
			if (external)
			{
				String path = externalDirectory
				+ externalPrefix
				+ "image"
				+ dict.getId(tag)
				+ ".jpg";
				
				out.println(" src='" + path + "' />");
				try
				{
					FileOutputStream image = new FileOutputStream(path, false);
					SwfImageUtils.JPEG jpeg = new SwfImageUtils.JPEG(tag.jpegTables.data, tag.data);
					jpeg.write(image);
					image.close();
				}
				catch (IOException e)
				{
					out.println("<!-- error: unable to write external asset file " + path + "-->");
				}
			}
			else
			{
				out.print(" encoding='base64'");
				end();
				outputBase64(tag.data);
				close(tag);
			}
		}
		
		public void defineButton(DefineButton tag)
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			end();
			if (showActions)
			{
				openCDATA();
				// todo print button records
				printActions(tag.condActions[0].actionList);
				closeCDATA();
			}
			else
			{
				out.println("<!-- " + tag.condActions[0].actionList.size() + " action(s) elided -->");
			}
			close(tag);
		}
		
		public void jpegTables(GenericTag tag)
		{
			open(tag);
			out.print(" encoding='base64'");
			end();
			outputBase64(tag.data);
			close(tag);
		}
		
		public void setBackgroundColor(SetBackgroundColor tag)
		{
			open(tag);
			out.print(" color='" + printRGB(tag.color) + "'");
			close();
		}
		
		public void defineFont(DefineFont1 tag)
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			end();
			
			if (glyphs)
			{
				for (int i = 0; i < tag.glyphShapeTable.length; i++)
				{
					indent();
					out.println("<glyph>");
					
					Shape shape = tag.glyphShapeTable[i];
					indent++;
					printShapeWithTabs(shape);
					indent--;
					
					indent();
					out.println("</glyph>");
				}
			}
			close(tag);
		}
		
		public void defineText(DefineText tag)
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			out.print(" bounds='" + tag.bounds + "'");
			out.print(" matrix='" + tag.matrix + "'");
			
			end();
			
			Iterator it = tag.records.iterator();
			
			while (it.hasNext())
			{
				TextRecord tr = (TextRecord)it.next();
				printTextRecord(tr, tag.code);
			}
			
			close(tag);
		}
		
		public void doAction(DoAction tag)
		{
			open(tag);
			end();
			
			if (showActions)
			{
				openCDATA();
				printActions(tag.actionList);
				closeCDATA();
			}
			else
			{
				out.println("<!-- " + tag.actionList.size() + " action(s) elided -->");
			}
			close(tag);
		}
		
		public void defineFontInfo(DefineFontInfo tag)
		{
			open(tag);
			out.print(" idref='" + idRef(tag.font) + "'");
			out.print(" ansi='" + tag.ansi + "'");
			out.print(" italic='" + tag.italic + "'");
			out.print(" bold='" + tag.bold + "'");
			out.print(" wideCodes='" + tag.wideCodes + "'");
			out.print(" langCold='" + tag.langCode + "'");
			out.print(" name='" + tag.name + "'");
			out.print(" shiftJIS='" + tag.shiftJIS + "'");
			end();
			indent();
			for (int i = 0; i < tag.codeTable.length; i++)
			{
				out.print((int)tag.codeTable[i]);
				if ((i + 1) % 16 == 0)
				{
					out.println();
					indent();
				}
				else
				{
					out.print(' ');
				}
			}
			if (tag.codeTable.length % 16 != 0)
			{
				out.println();
				indent();
			}
			close(tag);
		}
		
		public void defineSound(DefineSound tag)
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			out.print(" format='" + tag.format + "'");
			out.print(" rate='" + tag.rate + "'");
			out.print(" size='" + tag.size + "'");
			out.print(" type='" + tag.type + "'");
			out.print(" sampleCount='" + tag.sampleCount + "'");
			out.print(" soundDataSize='" + tag.data.length + "'");
			end();
			openCDATA();
			outputBase64(tag.data);
			closeCDATA();
			close(tag);
		}
		
		public void startSound(StartSound tag)
		{
			open(tag);
			out.print(" soundid='" + idRef(tag.sound) + "'");
			printSoundInfo(tag.soundInfo);
			close(tag);
		}
		
		private void printSoundInfo(SoundInfo info)
		{
			out.print(" syncStop='" + info.syncStop + "'");
			out.print(" syncNoMultiple='" + info.syncNoMultiple + "'");
			if (info.inPoint != SoundInfo.UNINITIALIZED)
			{
				out.print(" inPoint='" + info.inPoint + "'");
			}
			if (info.outPoint != SoundInfo.UNINITIALIZED)
			{
				out.print(" outPoint='" + info.outPoint + "'");
			}
			if (info.loopCount != SoundInfo.UNINITIALIZED)
			{
				out.print(" loopCount='" + info.loopCount + "'");
			}
			end();
			if (info.records != null && info.records.length > 0)
			{
				openCDATA();
				for (int i = 0; i < info.records.length; i++)
				{
					out.println(info.records[i]);
				}
				closeCDATA();
			}
		}
		
		public void defineButtonSound(DefineButtonSound tag)
		{
			open(tag);
			out.print(" buttonId='" + idRef(tag.button) + "'");
			close();
		}
		
		public void soundStreamHead(SoundStreamHead tag)
		{
			open(tag);
			close();
		}
		
		public void soundStreamBlock(GenericTag tag)
		{
			open(tag);
			close();
		}
		
		public void defineBinaryData(DefineBinaryData tag)
		{
			open(tag);
			out.println(" id='" + id(tag) + "' length='" + tag.data.length + "' />" );
		}
		public void defineBitsLossless(DefineBitsLossless tag)
		{
			open(tag);
			out.print(" id='" + id(tag) + "' width='" + tag.width + "' height='" + tag.height + "'");
			
			if (external)
			{
				String path = externalDirectory
				+ externalPrefix
				+ "image"
				+ dict.getId(tag)
				+ ".bitmap";
				
				out.println(" src='" + path + "' />");
				try
				{
					FileOutputStream image = new FileOutputStream(path, false);
					image.write(tag.data);
					image.close();
				}
				catch (IOException e)
				{
					out.println("<!-- error: unable to write external asset file " + path + "-->");
				}
			}
			else
			{
				out.print(" encoding='base64'");
				end();
				outputBase64(tag.data);
				close(tag);
			}
		}
		
		public void defineBitsJPEG2(DefineBits tag)
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			
			if (external)
			{
				String path = externalDirectory
				+ externalPrefix
				+ "image"
				+ dict.getId(tag)
				+ ".jpg";
				
				out.println(" src='" + path + "' />");
				try
				{
					FileOutputStream image = new FileOutputStream(path, false);
					image.write(tag.data);
					image.close();
				}
				catch (IOException e)
				{
					out.println("<!-- error: unable to write external asset file " + path + "-->");
				}
			}
			else
			{
				out.print(" encoding='base64'");
				end();
				outputBase64(tag.data);
				close(tag);
			}
		}
		
		public void defineShape2(DefineShape tag)
		{
			printDefineShape(tag, false);
		}
		
		public void defineButtonCxform(DefineButtonCxform tag)
		{
			open(tag);
			out.print(" buttonId='" + idRef(tag.button) + "'");
			close();
		}
		
		public void protect(GenericTag tag)
		{
			open(tag);
			if (tag.data != null)
				out.print(" password='" + hexify(tag.data) + "'");
			close();
		}
		
		public void placeObject2(PlaceObject tag)
		{
			placeObject23(tag);
		}
		
		public void placeObject3(PlaceObject tag)
		{
			placeObject23(tag);
		}
		
		public void placeObject23(PlaceObject tag)
		{
			if (tag.hasCharID())
			{
				if (tag.ref.name != null)
				{
					indent();
					out.println("<!-- instance of " + tag.ref.name + " -->");
				}
			}
			
			open(tag);
			if (tag.hasClassName())
				out.print(" className='" + tag.className + "'");
			if (tag.hasImage())
				out.print(" hasImage='true' ");
			if (tag.hasCharID())
				out.print(" idref='" + idRef(tag.ref) + "'");
			if (tag.hasName())
				out.print(" name='" + tag.name + "'");
			out.print(" depth='" + tag.depth + "'");
			if (tag.hasClipDepth())
				out.print(" clipDepth='" + tag.clipDepth + "'");
			if (tag.hasCacheAsBitmap())
				out.print(" cacheAsBitmap='true'");
			if (tag.hasRatio())
				out.print(" ratio='" + tag.ratio + "'");
			if (tag.hasCxform())
				out.print(" cxform='" + tag.colorTransform + "'");
			if (tag.hasMatrix())
				out.print(" matrix='" + tag.matrix + "'");
			if (tag.hasBlendMode())
				out.print(" blendmode='" + tag.blendMode + "'");
			if (tag.hasFilterList())
			{
				// todo - pretty print this once we actually care
				out.print(" filters='");
				for (Iterator it = tag.filters.iterator(); it.hasNext();)
				{
					out.print( (((Filter) it.next()).getID() ) + " ");
				}
				out.print("'");
			}
			
			if (tag.hasClipAction())
			{
				end();
				Iterator it = tag.clipActions.clipActionRecords.iterator();
				
				openCDATA();
				while (it.hasNext())
				{
					ClipActionRecord record = (ClipActionRecord)it.next();
					indent();
					out.println("onClipEvent(" + printClipEventFlags(record.eventFlags) +
								(record.hasKeyPress() ? "<" + record.keyCode + ">" : "") +
								") {");
					indent++;
					if (showActions)
					{
						printActions(record.actionList);
					}
					else
					{
						indent();
						out.println("// " + record.actionList.size() + " action(s) elided");
					}
					indent--;
					indent();
					out.println("}");
				}
				closeCDATA();
				close(tag);
			}
			else
			{
				close();
			}
		}
		
		public void removeObject2(RemoveObject tag)
		{
			open(tag);
			out.print(" depth='" + tag.depth + "'");
			close();
		}
		
		public void defineShape3(DefineShape tag)
		{
			printDefineShape(tag, true);
		}
		
		public void defineShape4(DefineShape tag)
		{
			printDefineShape(tag, true);
		}
		
		private void printShapeWithStyles(ShapeWithStyle shapes, boolean alpha)
		{
			printFillStyles(shapes.fillstyles, alpha);
			printLineStyles(shapes.linestyles, alpha);
			printShape(shapes, alpha);
		}
		
		private void printMorphLineStyles(MorphLineStyle[] lineStyles)
		{
			for (int i = 0; i < lineStyles.length; i++)
			{
				MorphLineStyle lineStyle = lineStyles[i];
				indent();
				out.print("<linestyle ");
				out.print("startColor='" + printRGBA(lineStyle.startColor) + "' ");
				out.print("endColor='" + printRGBA(lineStyle.startColor) + "' ");
				out.print("startWidth='" + lineStyle.startWidth + "' ");
				out.print("endWidth='" + lineStyle.endWidth + "' ");
				out.println("/>");
			}
		}
		
		private void printLineStyles(ArrayList linestyles, boolean alpha)
		{
			Iterator it = linestyles.iterator();
			while (it.hasNext())
			{
				LineStyle lineStyle = (LineStyle)it.next();
				indent();
				out.print("<linestyle ");
				String color = alpha ? printRGBA(lineStyle.color) : printRGB(lineStyle.color);
				out.print("color='" + color + "' ");
				out.print("width='" + lineStyle.width + "' ");
				if (lineStyle.flags != 0)
					out.print("flags='" + lineStyle.flags + "' ");
				if (lineStyle.hasMiterJoint())
				{
					out.print("miterLimit='" + lineStyle.miterLimit + "' ");
				}
				if (lineStyle.hasFillStyle())
				{
					out.println(">");
					indent();
					ArrayList<FillStyle> fillStyles = new ArrayList<FillStyle>(1);
					fillStyles.add(lineStyle.fillStyle);
					printFillStyles(fillStyles, alpha);
					indent();
					out.println("</linestyle>");
				}
				else
				{
					out.println("/>");
				}
			}
		}
		
		private void printFillStyles(ArrayList fillstyles, boolean alpha)
		{
			Iterator it = fillstyles.iterator();
			while (it.hasNext())
			{
				FillStyle fillStyle = (FillStyle)it.next();
				indent();
				out.print("<fillstyle");
				out.print(" type='" + fillStyle.getType() + "'");
				if (fillStyle.getType() == FillStyle.FILL_SOLID)
				{
					out.print(" color='" + (alpha ? printRGBA(fillStyle.color) : printRGB(fillStyle.color)) + "'");
				}
				if ((fillStyle.getType() & FillStyle.FILL_LINEAR_GRADIENT) != 0)
				{
					if (fillStyle.getType() == FillStyle.FILL_RADIAL_GRADIENT)
						out.print( " typeName='radial'");
					else if (fillStyle.getType() == FillStyle.FILL_FOCAL_RADIAL_GRADIENT)
						out.print( " typeName='focal' focalPoint='" + ((FocalGradient)fillStyle.gradient).focalPoint + "'");
					// todo print linear or radial or focal
					out.print(" gradient='" + formatGradient(fillStyle.gradient.records, alpha) + "'");
					out.print(" matrix='" + fillStyle.matrix + "'");
				}
				if ((fillStyle.getType() & FillStyle.FILL_BITS) != 0)
				{
					// todo print tiled or clipped
					out.print(" idref='" + idRef(fillStyle.bitmap) + "'");
					out.print(" matrix='" + fillStyle.matrix + "'");
				}
				out.println(" />");
			}
		}
		
		private void printMorphFillStyles(MorphFillStyle[] fillStyles)
		{
			for (int i = 0; i < fillStyles.length; i++)
			{
				MorphFillStyle fillStyle = fillStyles[i];
				indent();
				out.print("<fillstyle");
				out.print(" type='" + fillStyle.type + "'");
				if (fillStyle.type == FillStyle.FILL_SOLID)
				{
					out.print(" startColor='" + printRGBA(fillStyle.startColor) + "'");
					out.print(" endColor='" + printRGBA(fillStyle.endColor) + "'");
				}
				if ((fillStyle.type & FillStyle.FILL_LINEAR_GRADIENT) != 0)
				{
					// todo print linear or radial
					out.print(" gradient='" + formatMorphGradient(fillStyle.gradRecords) + "'");
					out.print(" startMatrix='" + fillStyle.startGradientMatrix + "'");
					out.print(" endMatrix='" + fillStyle.endGradientMatrix + "'");
				}
				if ((fillStyle.type & FillStyle.FILL_BITS) != 0)
				{
					// todo print tiled or clipped
					out.print(" idref='" + idRef(fillStyle.bitmap) + "'");
					out.print(" startMatrix='" + fillStyle.startBitmapMatrix + "'");
					out.print(" endMatrix='" + fillStyle.endBitmapMatrix + "'");
				}
				out.println(" />");
			}
		}
		
		private String formatGradient(GradRecord[] records, boolean alpha)
		{
			StringBuilder b = new StringBuilder();
			for (int i = 0; i < records.length; i++)
			{
				b.append(records[i].ratio);
				b.append(' ');
				b.append(alpha ? printRGBA(records[i].color) : printRGB(records[i].color));
				if (i + 1 < records.length)
					b.append(' ');
			}
			return b.toString();
		}
		
		private String formatMorphGradient(MorphGradRecord[] records)
		{
			StringBuilder b = new StringBuilder();
			for (int i = 0; i < records.length; i++)
			{
				b.append(records[i].startRatio);
				b.append(',');
				b.append(records[i].endRatio);
				b.append(' ');
				b.append(printRGBA(records[i].startColor));
				b.append(',');
				b.append(printRGBA(records[i].endColor));
				if (i + 1 < records.length)
					b.append(' ');
			}
			return b.toString();
		}
		
		private void printShape(Shape shapes, boolean alpha)
		{
		    if (shapes == null)
		        return;

			Iterator it = shapes.shapeRecords.iterator();
			while (it.hasNext())
			{
				indent();
				ShapeRecord shape = (ShapeRecord)it.next();
				if (shape instanceof StyleChangeRecord)
				{
					StyleChangeRecord styleChange = (StyleChangeRecord)shape;
					out.print("<styleChange ");
					if (styleChange.stateMoveTo)
					{
						out.print("dx='" + styleChange.moveDeltaX + "' dy='" + styleChange.moveDeltaY + "' ");
					}
					if (styleChange.stateFillStyle0)
					{
						out.print("fillStyle0='" + styleChange.fillstyle0 + "' ");
					}
					if (styleChange.stateFillStyle1)
					{
						out.print("fillStyle1='" + styleChange.fillstyle1 + "' ");
					}
					if (styleChange.stateLineStyle)
					{
						out.print("lineStyle='" + styleChange.linestyle + "' ");
					}
					if (styleChange.stateNewStyles)
					{
						out.println(">");
						indent++;
						printFillStyles(styleChange.fillstyles, alpha);
						printLineStyles(styleChange.linestyles, alpha);
						indent--;
						indent();
						out.println("</styleChange>");
					}
					else
					{
						out.println("/>");
					}
				}
				else
				{
					EdgeRecord edge = (EdgeRecord)shape;
					if (edge instanceof StraightEdgeRecord)
					{
						StraightEdgeRecord straightEdge = (StraightEdgeRecord)edge;
						out.println("<line dx='" + straightEdge.deltaX + "' dy='" + straightEdge.deltaY + "' />");
					}
					else
					{
						CurvedEdgeRecord curvedEdge = (CurvedEdgeRecord)edge;
						out.print("<curve ");
						out.print("cdx='" + curvedEdge.controlDeltaX + "' cdy='" + curvedEdge.controlDeltaY + "' ");
						out.print("dx='" + curvedEdge.anchorDeltaX + "' dy='" + curvedEdge.anchorDeltaY + "' ");
						out.println("/>");
					}
				}
			}
		}
		
		private void printShapeWithTabs(Shape shapes)
		{
            if (shapes == null)
	            return;

			Iterator it = shapes.shapeRecords.iterator();
			int startX = 0;
			int startY = 0;
			
			int x = 0;
			int y = 0;
			
			while (it.hasNext())
			{
				indent();
				ShapeRecord shape = (ShapeRecord)it.next();
				if (shape instanceof StyleChangeRecord)
				{
					StyleChangeRecord styleChange = (StyleChangeRecord)shape;
					out.print("SSCR" + styleChange.nMoveBits() + "\t");
					if (styleChange.stateMoveTo)
					{
						out.print(styleChange.moveDeltaX + "\t" + styleChange.moveDeltaY);
						
						if (startX == 0 && startY == 0)
						{
							startX = styleChange.moveDeltaX;
							startY = styleChange.moveDeltaY;
						}
						
						x = styleChange.moveDeltaX;
						y = styleChange.moveDeltaY;
						
						out.print("\t\t");
					}
				}
				else
				{
					EdgeRecord edge = (EdgeRecord)shape;
					if (edge instanceof StraightEdgeRecord)
					{
						StraightEdgeRecord straightEdge = (StraightEdgeRecord)edge;
						out.print("SER" + "\t");
						out.print(straightEdge.deltaX + "\t" + straightEdge.deltaY);
						x += straightEdge.deltaX;
						y += straightEdge.deltaY;
						out.print("\t\t");
					}
					else
					{
						CurvedEdgeRecord curvedEdge = (CurvedEdgeRecord)edge;
						out.print("CER" + "\t");
						out.print(curvedEdge.controlDeltaX + "\t" + curvedEdge.controlDeltaY + "\t");
						out.print(curvedEdge.anchorDeltaX + "\t" + curvedEdge.anchorDeltaY);
						x += (curvedEdge.controlDeltaX + curvedEdge.anchorDeltaX);
						y += (curvedEdge.controlDeltaY + curvedEdge.anchorDeltaY);
					}
				}
				
				out.println("\t\t" + x + "\t" + y);
			}
		}
		
		private String printClipEventFlags(int flags)
		{
			StringBuilder b = new StringBuilder();
			
			if ((flags & ClipActionRecord.unused31) != 0) b.append("res31,");
			if ((flags & ClipActionRecord.unused30) != 0) b.append("res30,");
			if ((flags & ClipActionRecord.unused29) != 0) b.append("res29,");
			if ((flags & ClipActionRecord.unused28) != 0) b.append("res28,");
			if ((flags & ClipActionRecord.unused27) != 0) b.append("res27,");
			if ((flags & ClipActionRecord.unused26) != 0) b.append("res26,");
			if ((flags & ClipActionRecord.unused25) != 0) b.append("res25,");
			if ((flags & ClipActionRecord.unused24) != 0) b.append("res24,");
			
			if ((flags & ClipActionRecord.unused23) != 0) b.append("res23,");
			if ((flags & ClipActionRecord.unused22) != 0) b.append("res22,");
			if ((flags & ClipActionRecord.unused21) != 0) b.append("res21,");
			if ((flags & ClipActionRecord.unused20) != 0) b.append("res20,");
			if ((flags & ClipActionRecord.unused19) != 0) b.append("res19,");
			if ((flags & ClipActionRecord.construct) != 0) b.append("construct,");
			if ((flags & ClipActionRecord.keyPress) != 0) b.append("keyPress,");
			if ((flags & ClipActionRecord.dragOut) != 0) b.append("dragOut,");
			
			if ((flags & ClipActionRecord.dragOver) != 0) b.append("dragOver,");
			if ((flags & ClipActionRecord.rollOut) != 0) b.append("rollOut,");
			if ((flags & ClipActionRecord.rollOver) != 0) b.append("rollOver,");
			if ((flags & ClipActionRecord.releaseOutside) != 0) b.append("releaseOutside,");
			if ((flags & ClipActionRecord.release) != 0) b.append("release,");
			if ((flags & ClipActionRecord.press) != 0) b.append("press,");
			if ((flags & ClipActionRecord.initialize) != 0) b.append("initialize,");
			if ((flags & ClipActionRecord.data) != 0) b.append("data,");
			
			if ((flags & ClipActionRecord.keyUp) != 0) b.append("keyUp,");
			if ((flags & ClipActionRecord.keyDown) != 0) b.append("keyDown,");
			if ((flags & ClipActionRecord.mouseUp) != 0) b.append("mouseUp,");
			if ((flags & ClipActionRecord.mouseDown) != 0) b.append("mouseDown,");
			if ((flags & ClipActionRecord.mouseMove) != 0) b.append("moseMove,");
			if ((flags & ClipActionRecord.unload) != 0) b.append("unload,");
			if ((flags & ClipActionRecord.enterFrame) != 0) b.append("enterFrame,");
			if ((flags & ClipActionRecord.load) != 0) b.append("load,");
			if (b.length() > 1)
			{
				b.setLength(b.length() - 1);
			}
			return b.toString();
		}
		
		public void defineText2(DefineText tag)
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			end();
			
			Iterator it = tag.records.iterator();
			
			while (it.hasNext())
			{
				TextRecord tr = (TextRecord)it.next();
				printTextRecord(tr, tag.code);
			}
			
			close(tag);
		}
		
		public void printTextRecord(TextRecord tr, int tagCode)
		{
			indent();
			out.print("<textRecord ");
			if (tr.hasFont())
				out.print(" font='" + tr.font.getFontName() + "'");
			
			if (tr.hasHeight())
				out.print(" height='" + tr.height + "'");
			
			if (tr.hasX())
				out.print(" xOffset='" + tr.xOffset + "'");
			
			if (tr.hasY())
				out.print(" yOffset='" + tr.yOffset + "'");
			
			if (tr.hasColor())
				out.print(" color='" +
						  (tagCode == TagValues.stagDefineEditText ? printRGB(tr.color) : printRGBA(tr.color)) +
						  "'");
			out.println(">");
			
			indent++;
			printGlyphEntries(tr);
			indent--;
			indent();
			out.println("</textRecord>");
			
		}
		
		private void printGlyphEntries(TextRecord tr)
		{
			indent();
			for (int i = 0; i < tr.entries.length; i++)
			{
				GlyphEntry ge = tr.entries[i];
				out.print(ge.getIndex());
				if (ge.advance >= 0)
					out.print('+');
				out.print(ge.advance);
				out.print(' ');
				if ((i + 1) % 10 == 0)
				{
					out.println();
					indent();
				}
			}
			if (tr.entries.length % 10 != 0)
				out.println();
		}
		
		
		public void defineButton2(DefineButton tag)
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			out.print(" trackAsMenu='" + tag.trackAsMenu + "'");
			end();
			
			for (int i = 0; i < tag.buttonRecords.length; i++)
			{
				ButtonRecord record = tag.buttonRecords[i];
				indent();
				out.println("<buttonRecord " +
							"idref='" + idRef(record.characterRef) + "' " +
							"depth='" + record.placeDepth + "' " +
							"matrix='" + record.placeMatrix + "' " +
							"states='" + record.getFlags() + "'/>");
				// todo print optional cxforma
			}
			
			// print conditional actions
			if (tag.condActions.length > 0 && showActions)
			{
				indent();
				out.println("<buttonCondAction>");
				openCDATA();
				for (int i = 0; i < tag.condActions.length; i++)
				{
					ButtonCondAction cond = tag.condActions[i];
					indent();
					out.println("on(" + cond + ") {");
					indent++;
					printActions(cond.actionList);
					indent--;
					indent();
					out.println("}");
				}
				closeCDATA();
				indent();
				out.println("</buttonCondAction>");
			}
			
			close(tag);
		}

        public void defineBitsJPEG3(DefineBitsJPEG3 tag)
        {
            open(tag);
            out.print(" id='" + id(tag) + "'");

            if (external)
            {
                String path = externalDirectory
                    + externalPrefix
                    + "image"
                    + dict.getId(tag)
                    + ".jpg";
		
                out.println(" src='" + path + "' />");

                try
                {
                    FileOutputStream image = new FileOutputStream(path, false);
                    SwfImageUtils.JPEG jpeg = null;

                    if (tag.jpegTables != null)
                    {
                        jpeg = new SwfImageUtils.JPEG(tag.jpegTables.data, tag.data);
                    }
                    else
                    {
                        jpeg = new SwfImageUtils.JPEG(tag.data, true);
                    }

                    jpeg.write(image);
                    image.close();
                }
                catch (IOException e)
                {
                    out.println("<!-- error: unable to write external asset file " + path + "-->");
                }
            }
            else
            {
                out.print(" encoding='base64'");
                end();
                outputBase64(tag.data);
                close(tag);
            }
        }

		public void defineBitsLossless2(DefineBitsLossless tag)
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			
			if (external)
			{
				String path = externalDirectory
				+ externalPrefix
				+ "image"
				+ dict.getId(tag)
				+ ".bitmap";
				
				out.println(" src='" + path + "' />");
				try
				{
					FileOutputStream image = new FileOutputStream(path, false);
					image.write(tag.data);
					image.close();
				}
				catch (IOException e)
				{
					out.println("<!-- error: unable to write external asset file " + path + "-->");
				}
			}
			else
			{
				out.print(" encoding='base64'");
				end();
				outputBase64(tag.data);
				close(tag);
			}
		}
		
		String escape(String s)
		{
			if (s == null)
				return null;
			
			StringBuilder b = new StringBuilder(s.length());
			for (int i = 0; i < s.length(); i++)
			{
				char c = s.charAt(i);
				switch (c)
				{
					case '<':
						b.append("&lt;");
						break;
					case '>':
						b.append("&gt;");
						break;
					case '&':
						b.append("&amp;");
						break;
				}
			}
			
			return b.toString();
		}
		
		public void defineEditText(DefineEditText tag)
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			
			if (tag.hasText)
				out.print(" text='" + escape(tag.initialText) + "'");
			
			if (tag.hasFont)
			{
				out.print(" fontId='" + id(tag.font) + "'");
				out.print(" fontName='" + tag.font.getFontName() + "'");
				out.print(" fontHeight='" + tag.height + "'");
			}
			else if (tag.hasFontClass)
			{
                out.print(" fontClass='" + tag.fontClass + "'");
                out.print(" fontHeight='" + tag.height + "'");
			}

			out.print(" bounds='" + tag.bounds + "'");
			
			if (tag.hasTextColor)
				out.print(" color='" + printRGBA(tag.color) + "'");
			
			out.print(" html='" + tag.html + "'");
			out.print(" autoSize='" + tag.autoSize + "'");
			out.print(" border='" + tag.border + "'");
			
			if (tag.hasMaxLength)
				out.print(" maxLength='" + tag.maxLength + "'");
			
			out.print(" multiline='" + tag.multiline + "'");
			out.print(" noSelect='" + tag.noSelect + "'");
			out.print(" password='" + tag.password + "'");
			out.print(" readOnly='" + tag.readOnly + "'");
			out.print(" useOutlines='" + tag.useOutlines + "'");
			out.print(" varName='" + tag.varName + "'");
			out.print(" wordWrap='" + tag.wordWrap + "'");
			
			if (tag.hasLayout)
			{
				out.print(" align='" + tag.align + "'");
				out.print(" indent='" + tag.ident + "'");
				out.print(" leading='" + tag.leading + "'");
				out.print(" leftMargin='" + tag.leftMargin + "'");
				out.print(" rightMargin='" + tag.rightMargin + "'");
			}
			close();
		}
		
		
		public void defineSprite(DefineSprite tag)
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			end();
			indent();
			out.println("<!-- sprite framecount=" + tag.framecount + " -->");
			
			tag.tagList.visitTags(this);
			
			close(tag);
		}
		
		public void finish()
		{
			--indent;
			indent();
			out.println("</swf>");
		}
		
		public void frameLabel(FrameLabel tag)
		{
			open(tag);
			out.print(" label='" + tag.label + "'");
			if (tag.anchor)
				out.print(" anchor='" + "true" + "'");
			close();
		}
		
		public void soundStreamHead2(SoundStreamHead tag)
		{
			open(tag);
			out.print(" playbackRate='" + tag.playbackRate + "'");
			out.print(" playbackSize='" + tag.playbackSize + "'");
			out.print(" playbackType='" + tag.playbackType + "'");
			out.print(" compression='" + tag.compression + "'");
			out.print(" streamRate='" + tag.streamRate + "'");
			out.print(" streamSize='" + tag.streamSize + "'");
			out.print(" streamType='" + tag.streamType + "'");
			out.print(" streamSampleCount='" + tag.streamSampleCount + "'");
			
			if (tag.compression == 2)
			{
				out.print(" latencySeek='" + tag.latencySeek + "'");
			}
			close();
		}
		
		public void defineScalingGrid(DefineScalingGrid tag)
		{
			open(tag);
			out.print(" idref='" + id(tag.scalingTarget) + "'");
			out.print( " grid='" + tag.rect + "'" );
			close();
		}
		
		public void defineMorphShape(DefineMorphShape tag)
		{
			defineMorphShape2(tag);
		}
		
		public void defineMorphShape2(DefineMorphShape tag)
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			out.print(" startBounds='" + tag.startBounds + "'");
			out.print(" endBounds='" + tag.endBounds + "'");
			if (tag.code == TagValues.stagDefineMorphShape2)
			{
				out.print(" startEdgeBounds='" + tag.startEdgeBounds + "'");
				out.print(" endEdgeBounds='" + tag.endEdgeBounds + "'");
				out.print(" usesNonScalingStrokes='" + tag.usesNonScalingStrokes + "'");
				out.print(" usesScalingStrokes='" + tag.usesScalingStrokes + "'");
			}
			end();
			printMorphLineStyles(tag.lineStyles);
			printMorphFillStyles(tag.fillStyles);
			
			indent();
			out.println("<start>");
			indent++;
			printShape(tag.startEdges, true);
			indent--;
			indent();
			out.println("</start>");
			
			indent();
			out.println("<end>");
			indent++;
			printShape(tag.endEdges, true);
			indent--;
			indent();
			out.println("</end>");
			
			close(tag);
		}
		
		public void defineFont2(DefineFont2 tag)
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			out.print(" font='" + tag.fontName + "'");
			out.print(" numGlyphs='" + tag.glyphShapeTable.length + "'");
			out.print(" italic='" + tag.italic + "'");
			out.print(" bold='" + tag.bold + "'");
			out.print(" ansi='" + tag.ansi + "'");
			out.print(" wideOffsets='" + tag.wideOffsets + "'");
			out.print(" wideCodes='" + tag.wideCodes + "'");
			out.print(" shiftJIS='" + tag.shiftJIS + "'");
			out.print(" langCode='" + tag.langCode + "'");
			out.print(" hasLayout='" + tag.hasLayout + "'");
			out.print(" ascent='" + tag.ascent + "'");
			out.print(" descent='" + tag.descent + "'");
			out.print(" leading='" + tag.leading + "'");
			out.print(" kerningCount='" + tag.kerningCount + "'");
			
			out.print(" codepointCount='" + tag.codeTable.length + "'");
			
			if (tag.hasLayout)
			{
				out.print(" advanceCount='" + tag.advanceTable.length + "'");
				out.print(" boundsCount='" + tag.boundsTable.length + "'");
			}
			end();
			
			if (glyphs)
			{
				for (int i=0; i < tag.kerningCount; i++)
				{
					KerningRecord rec = tag.kerningTable[i];
					indent();
					out.println("<kerningRecord adjustment='" + rec.adjustment + "' code1='" + rec.code1 + "' code2='" + rec.code2 + "' />");
				}
				
				for (int i = 0; i < tag.glyphShapeTable.length; i++)
				{
					indent();
					out.print("<glyph");
					out.print(" codepoint='" + ((int)tag.codeTable[i]) + (isPrintable(tag.codeTable[i]) ? ("(" + tag.codeTable[i] + ")") : "(?)") + "'");
					if (tag.hasLayout)
					{
						out.print(" advance='" + tag.advanceTable[i] + "'");
						out.print(" bounds='" + tag.boundsTable[i] + "'");
					}
					out.println(">");
					
					Shape shape = tag.glyphShapeTable[i];
					indent++;
					if (tabbedGlyphs)
						printShapeWithTabs(shape);
					else
						printShape(shape, true);
					indent--;
					indent();
					out.println("</glyph>");
				}
			}
			
			close(tag);
		}
		
		public void defineFont3(DefineFont3 tag)
		{
			defineFont2(tag);
		}
		
		public void defineFont4(DefineFont4 tag)
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			out.print(" font='" + tag.fontName + "'");
			out.print(" hasFontData='" + tag.hasFontData + "'");
			out.print(" smallText='" + tag.smallText + "'");
			out.print(" italic='" + tag.italic + "'");
			out.print(" bold='" + tag.bold + "'");
			out.print(" langCode='" + tag.langCode + "'");
			end();
			
			if (glyphs && tag.hasFontData)
			{
				outputBase64(tag.data);
			}
			
			close(tag);
		}
		
		public void defineFontAlignZones(DefineFontAlignZones tag)
		{
			open(tag);
			if (tag.name != null)
				out.print(" id='" + id(tag) + "'");
			out.print(" fontID='" + id(tag.font) + "'");
			out.print(" CSMTableHint='" + tag.csmTableHint + "'");
			out.println(">");
			indent++;
			indent();
			out.println("<ZoneTable length='" + tag.zoneTable.length + "'>");
			indent++;
			if (glyphs)
			{
				for (int i = 0; i < tag.zoneTable.length; i++)
				{
					ZoneRecord record = tag.zoneTable[i];
					indent();
					out.print("<ZoneRecord num='" + record.numZoneData + "' mask='" + record.zoneMask + "'>");
					for (int j = 0; j < record.zoneData.length; j++)
					{
						out.print(record.zoneData[j] + " ");
					}
					out.println("</ZoneRecord>");
				}
			}
			indent--;
			indent();
			out.println("</ZoneTable>");
			close(tag);
		}
		
		public void csmTextSettings(CSMTextSettings tag)
		{
			open(tag);
			if (tag.name != null)
				out.print(" id='" + id(tag) + "'");
			
			String textID = tag.textReference == null ? "0" : id(tag.textReference);
			out.print(" textID='" + textID + "'");
			out.print(" styleFlagsUseSaffron='" + tag.styleFlagsUseSaffron + "'");
			out.print(" gridFitType='" + tag.gridFitType + "'");
			out.print(" thickness='" + tag.thickness + "'");
			out.print(" sharpness='" + tag.sharpness + "'");
			close();
		}
		
		public void defineFontName(DefineFontName tag)
		{
			open(tag);
			if (tag.name != null)
				out.print(" id='" + id(tag) + "'");
			out.print(" fontID='" + id(tag.font) + "'");
			if (tag.fontName != null)
			{
				out.print(" name='" + tag.fontName + "'");
			}
			if (tag.copyright != null)
			{
				out.print(" copyright='" + tag.copyright + "'");
			}
			
			close();
		}
		
		private boolean isPrintable(char c)
		{
			int i = c & 0xFFFF;
			if (i < ' ' || i == '<' || i == '&' || i == '\'')
				return false;
			else
				return true;
		}
		
		
		public void exportAssets(ExportAssets tag)
		{
			open(tag);
			end();
			
			Iterator it = tag.exports.iterator();
			while (it.hasNext())
			{
				DefineTag ref = (DefineTag)it.next();
				indent();
				out.println("<Export idref='" + dict.getId(ref) + "' name='" + ref.name + "' />");
			}
			
			close(tag);
		}
		
		public void symbolClass(SymbolClass tag)
		{
			open(tag);
			end();
			
			Iterator it = tag.class2tag.entrySet().iterator();
			while (it.hasNext())
			{
				Map.Entry e = (Map.Entry)it.next();
				String className = (String)e.getKey();
				DefineTag ref = (DefineTag)e.getValue();
				indent();
				out.println("<Symbol idref='" + dict.getId(ref) + "' className='" + className + "' />");
			}
			
			if (tag.topLevelClass != null)
			{
				indent();
				out.println("<Symbol idref='0' className='" + tag.topLevelClass + "' />");
			}
			
			
			close(tag);
		}
		
		public void importAssets(ImportAssets tag)
		{
			open(tag);
			out.print(" url='" + tag.url + "'");
			end();
			
			Iterator it = tag.importRecords.iterator();
			while (it.hasNext())
			{
				ImportRecord record = (ImportRecord)it.next();
				indent();
				out.println("<Import name='" + record.name + "' id='" + dict.getId(record) + "' />");
			}
			
			close(tag);
		}
		
		public void importAssets2(ImportAssets tag)
		{
			// TODO: add support for tag.downloadNow and SHA1...
			importAssets(tag);
		}
		
		public void enableDebugger(EnableDebugger tag)
		{
			open(tag);
			out.print(" password='" + tag.password + "'");
			close();
		}
		
		public void doInitAction(DoInitAction tag)
		{
			if (tag.sprite != null && tag.sprite.name != null)
			{
				indent();
				out.println("<!-- init " + tag.sprite.name + " " + dict.getId(tag.sprite) + " -->");
			}
			
			open(tag);
			if (tag.sprite != null)
				out.print(" idref='" + idRef(tag.sprite) + "'");
			end();
			
			if (showActions)
			{
				openCDATA();
				printActions(tag.actionList);
				closeCDATA();
			}
			else
			{
				indent();
				out.println("<!-- " + tag.actionList.size() + " action(s) elided -->");
			}
			close(tag);
		}
		
		private String idRef(DefineTag tag)
		{
			if (tag == null)
			{
				// if tag is null then it isn't in the dict -- the SWF is invalid.
				// lets be lax and print something; Matador generates invalid SWF sometimes.
				return "-1";
			}
			else if (tag.name == null)
			{
				// just print the character id since no name was exported
				return String.valueOf(dict.getId(tag));
			}
			else
			{
				return tag.name;
			}
		}
		
		public void defineVideoStream(DefineVideoStream tag)
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			close();
		}
		
		public void videoFrame(VideoFrame tag)
		{
			open(tag);
			out.print(" streamId='" + idRef(tag.stream) + "'");
			out.print(" frame='" + tag.frameNum + "'");
			close();
		}
		
		public void defineFontInfo2(DefineFontInfo tag)
		{
			defineFontInfo(tag);
		}
		
		public void enableDebugger2(EnableDebugger tag)
		{
			open(tag);
			out.print(" password='" + tag.password + "'");
			out.print(" reserved='0x" + Integer.toHexString(tag.reserved) + "'");
			close();
		}
		
		public void debugID(DebugID tag)
		{
			open(tag);
			out.print(" uuid='" + tag.uuid + "'");
			close();
		}
		
		public void scriptLimits(ScriptLimits tag)
		{
			open(tag);
			out.print(" scriptRecursionLimit='" + tag.scriptRecursionLimit + "'" +
					  " scriptTimeLimit='" + tag.scriptTimeLimit + "'");
			close();
		}
		
		public void setTabIndex(SetTabIndex tag)
		{
			open(tag);
			out.print(" depth='" + tag.depth + "'");
			out.print(" index='" + tag.index + "'");
			close();
		}
		
		public void doABC(DoABC tag)
		{
			if (abc)
			{
				open(tag);
				end();
				AbcPrinter abcPrinter = new AbcPrinter(tag.abc, out, showOffset, indent, showByteCode);
				abcPrinter.print();
				close(tag);
			}
			else if (showActions)
			{
				open(tag);
				if (tag.code == TagValues.stagDoABC2)
					out.print( " name='" + tag.name + "'");
				end();
				
				ContextStatics contextStatics = new ContextStatics();
				contextStatics.use_static_semantics = true;
				contextStatics.dialect = 9;
				
				assert swfVersion != null : "header should have been parsed already, but wasn't";
				contextStatics.setAbcVersion(ContextStatics.getTargetAVM(swfVersion));
				contextStatics.use_namespaces.addAll(ContextStatics.getRequiredUseNamespaces(swfVersion));
				
				Context context = new Context(contextStatics);
				context.setHandler(new CompilerHandler());
				AbcParser abcParser = new AbcParser(context, tag.abc);
				context.setEmitter(new ActionBlockEmitter(context, tag.name, new StringPrintWriter(),
														  new StringPrintWriter(), false, false, false, false));
				ProgramNode programNode = abcParser.parseAbc();
				
				if (programNode == null)
				{
					out.println("<!-- Error: could not parse abc -->");
				}
				else if (decompile)
				{
					//                PrettyPrinter prettyPrinter = new PrettyPrinter(out);
					//                programNode.evaluate(context, prettyPrinter);
				}
				else
				{
					SyntaxTreeDumper syntaxTreeDumper = new SyntaxTreeDumper(out, indent);
					programNode.evaluate(context, syntaxTreeDumper);
				}
				
				close(tag);
			}
			else
			{
				open(tag);
				close();
			}
		}
		
		private String hexify(byte[] id)
		{
			StringBuilder b = new StringBuilder(id.length * 2);
			for (int i = 0; i < id.length; i++)
			{
				b.append(Character.forDigit((id[i] >> 4) & 15, 16));
				b.append(Character.forDigit(id[i] & 15, 16));
			}
			return b.toString().toUpperCase();
		}
		
		public static String baseName(String path)
		{
			int start = path.lastIndexOf(File.separatorChar);
			
			if (File.separatorChar != '/')
			{
				// some of us are grouchy about unix paths not being
				// parsed since they are totally legit at the system
				// level of win32.
				int altstart = path.lastIndexOf('/');
				if ((start == -1) || (altstart > start))
					start = altstart;
			}
			
			if (start == -1)
				start = 0;
			else
				++start;
			
			
			int end = path.lastIndexOf('.');
			
			if (end == -1)
				end = path.length();
			
			
			if (start > end)
				end = path.length();
			
			return path.substring(start, end);
			
		}
		
		public static String dirName(String path)
		{
			int end = path.lastIndexOf(File.pathSeparatorChar);
			
			
			if (File.pathSeparatorChar != '/')
			{
				// some of us are grouchy about unix paths not being
				// parsed since they are totally legit at the system
				// level of win32.
				int altend = path.lastIndexOf('/');
				if ((end == -1) || (altend < end))
					end = altend;
			}
			
			if (end == -1)
				return "";
			else
				++end;
			
			return path.substring(0, end);
		}
		
		// options
		static boolean abcOption = false;
		static boolean encodeOption = false;
		static boolean showActionsOption = true;
		static boolean showOffsetOption = false;
		static boolean showByteCodeOption = false;
		static boolean showDebugSourceOption = false;
		static boolean glyphsOption = true;
		static boolean externalOption = false;
		static boolean decompileOption = true;
		static boolean defuncOption = true;
		static boolean saveOption = false;
		static boolean tabbedGlyphsOption = true;
		
		
		/**
		 * swfdump usage:  swfdump [-encode] [-noactions] [-showoffset] files ...
		 * -encode       ?
		 * -noactions    don't output ActionScript byte code
		 * -showoffset   output an XML comment line in the output before each
		 * tag, displaying the tag's byte offset and size in the file
		 * <p/>
		 * Swfdump will dump a SWF file as XML.  Swf tags are shown as XML tags.  Swf Actions are shown
		 * commented out assembly language.  If a SWD file is found that matches this SWF file, then
		 * we will show intermixed source code and assembly language.
		 * <p/>
		 * The format of the output (swfx) is according to the SWFX doctype.  The optional -dtd flag will
		 * include the doctype declaration before the actual content.  This format can be edited in any
		 * text or xml editor, and then converted back into SWF using the Swfxc utility.
		 */
		public static void main(String[] args) throws IOException
		{
			if (args.length == 0)
			{
				System.err.println("Usage: java tools.SwfxPrinter [-encode] [-asm] [-abc] [-showbytecode] [-noactions] [-showdebugsource] [-showoffset] [-noglyphs] [-external] [-save file.swf] [-nofunctions] [-out file.swfx] file1.swf ...");
				System.exit(1);
			}
			
			int index = 0;
			PrintWriter out = null;
			String outfile = null;
			
			while ((index < args.length) && (args[index].startsWith("-")))
			{
				if (args[index].equals("-encode"))
				{
					encodeOption = true;
					++index;
				}
				else if (args[index].equals("-save"))
				{
					++index;
					saveOption = true;
					outfile = args[index++];
				}
				else if (args[index].equals("-decompile"))
				{
					decompileOption = true;
					++index;
				}
				else if (args[index].equals("-nofunctions"))
				{
					defuncOption = false;
					++index;
				}
				else if (args[index].equals("-asm"))
				{
					decompileOption = false;
					++index;
				}
				else if (args[index].equals("-abc"))
				{
					abcOption = true;
					++index;
				}
				else if (args[index].equals("-noactions"))
				{
					showActionsOption = false;
					++index;
				}
				else if (args[index].equals("-showoffset"))
				{
					showOffsetOption = true;
					++index;
				}
				else if (args[index].equals("-showbytecode"))
				{
					showByteCodeOption = true;
					++index;
				}
				else if (args[index].equals("-showdebugsource"))
				{
					showDebugSourceOption = true;
					++index;
				}
				else if (args[index].equals("-noglyphs"))
				{
					glyphsOption = false;
					++index;
				}
				else if (args[index].equals("-out"))
				{
					if (index + 1 == args.length)
					{
						System.err.println("-out requires a filename or - for stdout");
						System.exit(1);
					}
					if (!args[index + 1].equals("-"))
					{
						
						outfile = args[index + 1];
						out = new PrintWriter(new FileOutputStream(outfile, false));
					}
					index += 2;
				}
				else if (args[index].equals("-external"))
				{
					externalOption = true;
					++index;
				}
				else if (args[index].equalsIgnoreCase("-tabbedGlyphs"))
				{
					tabbedGlyphsOption = true;
					++index;
				}
				else
				{
					System.err.println("unknown argument " + args[index]);
					++index;
				}
			}
			
			if (out == null)
				out = new PrintWriter(System.out, true);
			
			File f = new File(args[index]);
			URL[] urls;
			if (!f.exists())
			{
				urls = new URL[]{new URL(args[index])};
			}
			else
			{
				if (f.isDirectory())
				{
					File[] list = FileUtils.listFiles(f);
					urls = new URL[list.length];
					for (int i = 0; i < list.length; i++)
					{
						urls[i] = FileUtils.toURL(list[i]);
					}
				}
				else
				{
					urls = new URL[]{FileUtils.toURL(f)};
				}
			}
			
			for (int i = 0; i < urls.length; i++)
			{
				try
				{
					URL url = urls[i];
					if (saveOption)
					{
						InputStream in = new BufferedInputStream(url.openStream());
						try
						{
							OutputStream fileOut = new BufferedOutputStream(new FileOutputStream(outfile));
							try
							{
								int c;
								while ((c = in.read()) != -1)
								{
									fileOut.write(c);
								}
							}
							finally
							{
								fileOut.close();
							}
						}
						finally
						{
							in.close();
						}
					}
					
					if (isSwf(url))
					{
						dumpSwf(out, url, outfile);
					}
					else if (isZip(url) && !url.toString().endsWith(".abj"))
					{
						dumpZip(out, url, outfile);
					}
					else
					{
						out.println("<!-- Parsing actions from " + url + " -->");
						// we have no way of knowing the swf version, so assume latest
						URLConnection connection = url.openConnection();
						ActionDecoder actionDecoder = new ActionDecoder(new SwfDecoder(connection.getInputStream(), 7));
						actionDecoder.setKeepOffsets(true);
						ActionList actions = actionDecoder.decode(connection.getContentLength());
						SwfxPrinter printer = new SwfxPrinter(out);
						printer.decompile = decompileOption;
						printer.defunc = defuncOption;
						printer.printActions(actions);
					}
					out.flush();
				}
				catch (Error e)
				{
					if (Trace.error)
						e.printStackTrace();
					
					System.err.println("");
					System.err.println("An unrecoverable error occurred.  The given file " + urls[i] + " may not be");
					System.err.println("a valid swf.");
				}
				catch (FileNotFoundException e)
				{
					System.err.println("Error: " + e.getMessage());
					System.exit(1);
				}
			}
		}
		
		private static void dumpZip(PrintWriter out, URL url, String outfile) throws IOException
		{
			InputStream in = new BufferedInputStream(url.openStream());
			try
			{
				ZipInputStream zipIn = new ZipInputStream(in);
				ZipEntry zipEntry = zipIn.getNextEntry();
				while ((zipEntry != null))
				{
					URL fileUrl = new URL("jar:" + url.toString() + "!/" + zipEntry.getName());
					if (isSwf(fileUrl))
						dumpSwf(out, fileUrl, outfile);
					zipEntry = zipIn.getNextEntry();
				}
			}
			finally
			{
				in.close();
			}
		}
		
		private static void dumpSwf(PrintWriter out, URL url, String outfile)
		throws IOException
		{
			out.println("<!-- Parsing swf " + url + " -->");
			InputStream in;
			SwfxPrinter debugPrinter = new SwfxPrinter(out);
			
			debugPrinter.showActions = showActionsOption;
			debugPrinter.showOffset = showOffsetOption;
			debugPrinter.showByteCode = showByteCodeOption;
			debugPrinter.showDebugSource = showDebugSourceOption;
			debugPrinter.glyphs = glyphsOption;
			debugPrinter.setExternal(externalOption, outfile);
			debugPrinter.decompile = decompileOption;
			debugPrinter.abc = abcOption;
			debugPrinter.defunc = defuncOption;
			debugPrinter.tabbedGlyphs = tabbedGlyphsOption;
			
			if (encodeOption)
			{
				// decode -> encode -> decode -> print
				TagEncoder encoder = new TagEncoder();
				in = url.openStream();
				new TagDecoder(in, url).parse(encoder);
				encoder.finish();
				in = new ByteArrayInputStream(encoder.toByteArray());
			}
			else
			{
				// decode -> print
				in = url.openStream();
			}
			TagDecoder t = new TagDecoder(in, url);
			t.setKeepOffsets(debugPrinter.showOffset);
			t.parse(debugPrinter);
		}
		
		private static boolean isSwf(URL url) throws IOException
		{
			InputStream in = new BufferedInputStream(url.openStream());
			try
			{
				return isSwf(in);
			}
			finally
			{
				in.close();
			}
		}
		
		public static boolean isSwf(InputStream in)
		{
			try
			{
				DataInputStream data = new DataInputStream(in);
				byte[] b = new byte[3];
				data.mark(b.length);
				data.readFully(b);
				if (b[0] == 'C' && b[1] == 'W' && b[2] == 'S' ||
                    b[0] == 'F' && b[1] == 'W' && b[2] == 'S')
				{
					data.reset();
					return true;
				}
				else
				{
					data.reset();
					return false;
				}
			}
			catch (IOException e)
			{
				return false;
			}
		}
		
		private static boolean isZip(URL url) throws IOException
		{
			InputStream in = new BufferedInputStream(url.openStream());
			try
			{
				return isZip(in);
			}
			finally
			{
				in.close();
			}
		}
		
		public static boolean isZip(InputStream in)
		{
			try
			{
				ZipInputStream swcZipInputStream = new ZipInputStream(in);
				swcZipInputStream.getNextEntry();
				return true;
			}
			catch (IOException e)
			{
				return false;
			}
		}
		
		// Handy dandy for dumping an action list during debugging
		public static String actionListToString(ActionList al, String[] args)
		{
			// cut and paste arg code from main() could be better but it works
			boolean showActions = true;
			boolean showOffset = false;
			boolean showDebugSource = false;
			boolean decompile = false;
			boolean defunc = true;
			boolean tabbedGlyphs = true;
			int index = 0;
			
			while (args != null && (index < args.length) && (args[index].startsWith("-")))
			{
				if (args[index].equals("-decompile"))
				{
					decompile = true;
					++index;
				}
				else if (args[index].equals("-nofunctions"))
				{
					defunc = false;
					++index;
				}
				else if (args[index].equals("-asm"))
				{
					decompile = false;
					++index;
				}
				else if (args[index].equals("-noactions"))
				{
					showActions = false;
					++index;
				}
				else if (args[index].equals("-showoffset"))
				{
					showOffset = true;
					++index;
				}
				else if (args[index].equals("-showdebugsource"))
				{
					showDebugSource = true;
					++index;
				}
				else if (args[index].equalsIgnoreCase("-tabbedGlyphs"))
				{
					tabbedGlyphs = true;
					++index;
				}
			}
			
			StringWriter sw = new StringWriter();
			PrintWriter out = new PrintWriter(sw);
			SwfxPrinter printer = new SwfxPrinter(out);
			printer.showActions = showActions;
			printer.showOffset = showOffset;
			printer.showDebugSource = showDebugSource;
			printer.decompile = decompile;
			printer.defunc = defunc;
			printer.tabbedGlyphs = tabbedGlyphs;
			
			printer.printActions(al);
			out.flush();
			return sw.toString();
		}
	}
