<?xml version="1.0" encoding="utf-8"?>

<!--

	ADOBE SYSTEMS INCORPORATED
	Copyright 2008 Adobe Systems Incorporated
	All Rights Reserved.

	NOTICE: Adobe permits you to use, modify, and distribute this file
	in accordance with the terms of the license agreement accompanying it.

-->

<ItemRenderer xmlns="http://ns.adobe.com/mxml/2009">
	
    <states>
		<State name="normal"/>			
		<State name="hovered"/>
		<State name="selected"/>
	</states>
	
	<Rect left="0" right="0" top="0" bottom="0">
		<fill>
			<SolidColor color="{contentBackgroundColor}" />
		</fill>
		<fill.hovered>
		    <SolidColor color="{rollOverColor}" />
		</fill.hovered>
		<fill.selected>
		    <SolidColor color="{selectionColor}" />
		</fill.selected>
	</Rect>
	<TextBox id="labelField" text="{data}" verticalCenter="0" left="3" right="3" top="6" bottom="4" />

</ItemRenderer>
