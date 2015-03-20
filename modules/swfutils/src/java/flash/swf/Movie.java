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

package flash.swf;

import flash.swf.tags.EnableDebugger;
import flash.swf.tags.GenericTag;
import flash.swf.tags.ScriptLimits;
import flash.swf.tags.SetBackgroundColor;
import flash.swf.tags.FileAttributes;
import flash.swf.tags.EnableTelemetry;
import flash.swf.tags.ProductInfo;
import flash.swf.tags.Metadata;
import flash.swf.tags.DefineSceneAndFrameLabelData;
import flash.swf.types.FlashUUID;
import flash.swf.types.Rect;

import java.util.List;
import java.util.Map;

/**
 * Represents a whole flash movie.  Singleton tags are represented as
 * such, and frames are as well.
 */
public class Movie
{
	/**
	 * file format version (1..10)
	 */
	public int version;

    /**
     * product info for compiler 
     */
    public ProductInfo productInfo;

    /**
     * description of the app
     */

    public Metadata metadata;

    /**
	 * initial stage size in twips
	 */
	public Rect size;

	/**
	 * frames per second
	 */
	public int framerate;

	/**
	 * player wide execution limits
	 */
	public ScriptLimits scriptLimits;

	/**
	 * protect the movie from being loaded into the authortool
	 */
	public GenericTag protect;

	/**
	 * bgcolor for the whole movie.
	 */
	public SetBackgroundColor bgcolor;

	/**
	 * FileAttributes defines whole-SWF attributes (SWF 8 or later)
	 */
	public FileAttributes fileAttributes;
	
	/**
	 * EnableTelemetry defines if advanced telemetry is on or off
	 */
	public EnableTelemetry enableTelemetry;

	/**
	 * if present, player will attach to a debugger
	 */
	public EnableDebugger enableDebugger;

	/**
	 * if present, expect and/or generate a SWD
	 */
	public FlashUUID uuid;  // if set, generate a swd

	/**
	 * each frame contains display list tags, and actions
	 */
	public List<Frame> frames;

	/**
	 * if movie will be used as a library, certain optimizations are verboten.
	 */
	public boolean isLibrary;

	/**
	 * top-level class name
	 */
	public String topLevelClass;

	/**
	 * movie width in pixels, not twips
	 */
    public int width;

	/**
	 * movie width percentage
	 */
    public String widthPercent;

	/**
	 * is width default, or user-specified?
	 */
    public boolean userSpecifiedWidth;

	/**
	 * movie height in pixels, not twips
	 */
    public int height;

	/**
	 * movie height percentage
	 */
    public String heightPercent;

	/**
	 * is height default, or user-specified?
	 */
    public boolean userSpecifiedHeight;

	/**
	 * movie page title
	 */
    public String pageTitle;

    /**
     * maps definition names    Sou
     */
    public Map definitionMap;

    /**
     * 8.5 scene data, only one per timeline at the moment
     */
    public DefineSceneAndFrameLabelData sceneAndFrameLabelData;
}