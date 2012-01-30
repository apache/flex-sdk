////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

// This script does the following:
// 
// 1. Check for a selection in the Library. If nothing is selected, 
//    alert the user and abort the script.
//
// 2. Prepare the document for Flex, if needed. This includes:
//    a) Changing publish properties to set player version to at least
//       9, ActionScript version to at least 3, turning on Export SWC,
//       and turning on Permit Debugging.
//    b) Setting the frame rate to 24
//    c) Import FlexComponentBase SWC from the components panel into the library
//    d) Tracing the changes that occurred in the document
//
// 3. For each MovieClip selected in the Library, the following changes
//    are made:
//    a) Set Export for ActionScript to true
//    b) Set Export in First Frame to true
//    c) Set Base Class to mx.flash.UIMovieClip
//    d) Set class name to match the symbol name
//    e) Make sure class name is valid (no spaces, etc.)
//    

var doc = null;

// info parsed from publish profile XML about what we want to change
var playerVersionChanged = false;
var minPlayerVersion = 10;
var asVersionChanged = false;
var minAsVersion = 3;
var permitDebuggingChanged = false;
var exportSwcChanged = false;
var frameRateChanged = false;
var swcCopiedtoLibrary = false;

// xml read from publish profiles file exported
var xmlContent;

// String we create to read XML back into publish profile,
// plus supporting index values
// (we cannot use xml output by E4X due to limitations
// of publish properties xml parsing)
var newXMLContent;
var startIndex;
var nextIndex;

// get temp xml file name, used for importing and exporting publish profiles xml
function getTempFileURI() {
	return (fl.configURI + "temp" + Math.floor(Math.random() * 1000000000) + ".xml");
}

// helper function for changing publish profiles xml
function outputNextValue(tagName, value) {
	var searchToken = ("<" + tagName + ">");
	nextIndex = xmlContent.indexOf(searchToken, startIndex);
	if (nextIndex < 0) return;
	nextIndex += searchToken.length;
	newXMLContent += xmlContent.slice(startIndex, nextIndex);
	newXMLContent += value;
	startIndex = xmlContent.indexOf("<", nextIndex);
}

// helper function for changing publish profiles xml
function fixNextValue(tagName, minValue) {
	// grab current value from document to see if we need to change
	var mustChange = false;

	// find tag value
	var searchToken = ("<" + tagName + ">");
	nextIndex = xmlContent.indexOf(searchToken, startIndex);
	if (nextIndex < 0) return false;
	nextIndex += searchToken.length;
	var endIndex = xmlContent.indexOf("<", nextIndex);
	var currentValue = xmlContent.slice(nextIndex, endIndex);

	// check tag value
	if (isNaN(currentValue) || currentValue < minValue) {
		mustChange = true;
	}

	// output proper xml
	newXMLContent += xmlContent.slice(startIndex, nextIndex);
	newXMLContent += (mustChange) ? minValue : currentValue;
	startIndex = endIndex;

	return mustChange;
}

// changes publish profile settings, item 2a listed in comment at top of file
function fixPublishProfile() {
	// export publish profile
	var inputFileURI = getTempFileURI();
	doc.exportPublishProfile(inputFileURI);

	// read data back in
	xmlContent = FLfile.read(inputFileURI);

	// delete temp file
	FLfile.remove(inputFileURI);

	// convert string to XML object.  Need to chop off the beginning of the xml file
	// to get e4x not to choke on the bom + <?xml...> stuff.
	var profileXML = new XML(xmlContent.substr(xmlContent.indexOf('>') + 1));

	// make sure we have a PublishFlashProperties tag which is enabled
	var flashPropsXML = profileXML.PublishFlashProperties;
	if (flashPropsXML.length() == 0 || flashPropsXML.@enabled == "false") {
		alert("You must have Flash checked in the Formats tab of the Publish Settings dialog to run this command.");
		return false;
	}

	// prepare string used to write xml content
	newXMLContent = "";
	startIndex = 0;

	// check player version for changes
	playerVersionChanged = fixNextValue("Version", minPlayerVersion);
	if (playerVersionChanged) {
		// wipe out ExternalPlayer if we changed player version
		outputNextValue("ExternalPlayer", "");
	}

	// check AS version for changes
	asVersionChanged = fixNextValue("ActionScriptVersion", minAsVersion);

	// check permit debugging for changes
	permitDebuggingChanged = fixNextValue("DebuggingPermitted", 1);

	// check export swc for changes
	exportSwcChanged = fixNextValue("ExportSwc", 1);

	// output rest of the file
	newXMLContent += xmlContent.substr(startIndex);

	// write out new file and read it in
	var outputFileURI = getTempFileURI();
	FLfile.write(outputFileURI, newXMLContent);
	doc.importPublishProfile(outputFileURI);

	// delete temp file
	FLfile.remove(outputFileURI);

	return true;
}

// changes frame rate, item 2b listed in comment at top of file
function fixFrameRate() {
	if (doc.frameRate != 24) {
		if (confirm("The recommended frame rate for Flex components is 24fps. The current document frame rate is " + doc.frameRate + "fps.\n\nWould you like to change the document frame rate to 24fps?"))
		{
			frameRateChanged = true;
			doc.frameRate = 24;
		}
	}
	return true;
}

// Returns the "short" name for the symbol. 
function getShortName(name) {
	var slashIndex = name.lastIndexOf("/");
	if (slashIndex > 0) {
		return name.substr(slashIndex + 1);
	}
	return name;
}

// imports UIMovieClip SWC to library, item 2c listed in comment at top of file
// only adds UIMovieClip to library if there is no symbol with that name in
// the library already
function importSwcToLibrary() {
	// search library for any item named "FlexComponentBase"
	var items = doc.library.items;
	for (var i = 0; i < items.length; i++) {
		var shortName = getShortName(items[i].name);
		if (shortName == "FlexComponentBase") {
			return true;
		}
	}

	// add component to stage
	swcCopiedtoLibrary = true;

	fl.componentsPanel.addItemToDocument({x:0, y:0}, "Flex", "FlexComponentBase");
	
	// delete it from the stage
	doc.deleteSelection();

	return true;
}

// main function for changing document
function prepareDocument() {
	// get document dom, bail if cannot

	doc = fl.getDocumentDOM();

	if (doc == null) {
		alert("You must have a FLA open as your active document to run this command.");
		return false;
	}

	if (doc.asVersion < minAsVersion || parseInt(doc.getPlayerVersion()) < minPlayerVersion) {
		if (!confirm("Flex Components must target Flash Player " + minPlayerVersion + " and ActionScript " + minAsVersion + ".\n\nWould you like to change the document settings to target Flash Player " + minPlayerVersion + " and ActionScript " + minAsVersion + "?"))
			return false;
	}

	if (!fixPublishProfile()) {
		return false;
	}

	if (!fixFrameRate()) {
		return false;
	}

	if (!importSwcToLibrary()) {
		return false;
	}

	return true;
}

// report changes made to document
function reportChanges() {
	if (!playerVersionChanged && !asVersionChanged && !permitDebuggingChanged && !exportSwcChanged && !frameRateChanged && !swcCopiedtoLibrary) {
		fl.trace("Command made no changes to the FLA.");
		return;
	}

	fl.trace("Command made the following changes to the FLA:");
	if (playerVersionChanged) {
		fl.trace("  Changed player version to " + minPlayerVersion);
	}
	if (asVersionChanged) {
		fl.trace("  Changed ActionScript version to " + minAsVersion);
	}
	if (permitDebuggingChanged) {
		fl.trace("  Turned on Permit Debugging");
	}
	if (exportSwcChanged) {
		fl.trace("  Turned on Export SWC");
	}
	if (frameRateChanged) {
		fl.trace("  Set frame rate to 24");
	}
	if (swcCopiedtoLibrary) {
		fl.trace("  Imported FlexComponentBase component to library");
	}
}

// Check the document to make sure it is set up to create Flex content.
function checkDocument()
{
	// search library for any item named "UIMovieClip"
	var items = doc.library.items;
	for (var i = 0; i < items.length; i++) {
		var shortName = getShortName(items[i].name);
		if (shortName == "FlexComponentBase") {
			return true;
		}
	}
	
	return false;
}

// All non-alphanumeric characters are removed.
// If the first character is a number, preceed it with an underscore.
function makeValidClassName(name)
{
	name = name.replace(/[^a-zA-Z0-9_]/g, "");
	name = name.replace(/(^[0-9])/, "_$1");
	return name;
}

// Set the linkage properties for the library item, item 3 listed in the comment
// at the top of the file
function applyLinkagePropertiesToSymbol(libItem, baseClass)
{
	// Apply linkage values to the library item
	// 
	if (libItem != undefined)
	{
		if (libItem.symbolType != "movie clip")
		{
			fl.trace("Skipping Library item \"" + getShortName(libItem.name) + "\". It is not a MovieClip.")
		}
		else
		{
			if (! libItem.linkageExportForAS)
				libItem.linkageExportForAS = true;
			if (! libItem.linkageExportInFirstFrame)
				libItem.linkageExportInFirstFrame = true;
			libItem.linkageBaseClass = baseClass;
		
			// class name is same as symbol name, converted into
			// a valid identifier name.
			libItem.linkageClassName = makeValidClassName(getShortName(libItem.name));
			
			fl.trace("Symbol \"" + getShortName(libItem.name) + "\" can be used as a Flex component.")
		}
	}
}

function makeFlexComponent(baseClass, additionalMessage)
{
	doc = fl.getDocumentDOM();
	var selectedItems = doc.library.getSelectedItems();
	if (selectedItems.length <= 0)
	{
		alert("Please select one or more Library items before running this command.")
		return false;
	}
	else
	{
		// Do document settings first
		if (!checkDocument())
		{
			if (!prepareDocument())
				return false;
			reportChanges();
		}

		// Convert selected symbols 
		for (var i = 0; i < selectedItems.length; i++)
			applyLinkagePropertiesToSymbol(selectedItems[i], baseClass);
		
		if (additionalMessage)
			fl.trace(additionalMessage);
			
		fl.trace("Select File > Publish to create the SWC file for use in Flex.")
	}

	return true;
}

