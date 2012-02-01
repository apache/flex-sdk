<?xml version="1.0" encoding="utf-8"?>

<!--

	ADOBE SYSTEMS INCORPORATED
	Copyright 2008 Adobe Systems Incorporated
	All Rights Reserved.

	NOTICE: Adobe permits you to use, modify, and distribute this file
	in accordance with the terms of the license agreement accompanying it.

-->

<s:ItemRenderer focusEnabled="false" xmlns:fx="http://ns.adobe.com/mxml/2009" xmlns:s="library://ns.adobe.com/flex/spark">
	
    <s:states>
		<s:State name="normal"/>			
		<s:State name="hovered"/>
		<s:State name="selected"/>
	</s:states>
	
	<s:Rect left="0" right="0" top="0" bottom="0">
		<s:fill>
			<s:SolidColor color="{contentBackgroundColor}" />
		</s:fill>
		<s:fill.hovered>
		    <s:SolidColor color="{rollOverColor}" />
		</s:fill.hovered>
		<s:fill.selected>
		    <s:SolidColor color="{selectionColor}" />
		</s:fill.selected>
	</s:Rect>
	<s:SimpleText id="labelElement" verticalCenter="0" left="3" right="3" top="6" bottom="4"/>

</s:ItemRenderer>
