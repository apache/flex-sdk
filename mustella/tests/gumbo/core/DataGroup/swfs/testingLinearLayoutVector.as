////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
import spark.layouts.supportClasses.LinearLayoutVector;

///////////////////

private var linearLayoutVectorTestingResults:String = "";

//
// This method serves as the entry point for Mustella test to call the set of tests in this file
//
public function runLinearLayoutVectorTests():Boolean {
	// run these tests
	test();
	
	// return true if no failures
	return 	linearLayoutVectorTestingResults != "fail";
}

///////////////////////

//
// The following code was written to perform some simple tests of the LinearLayoutVector class.
// Hans Muller wrote this chunk of code and will contribute additions/modifications to QA to update 
// when needed.
//
// Note: Be sure to leave the line in fail() that sets the result string if you make changes below.
//

private function fail(s:String):void
{
	// track that something failed
	linearLayoutVectorTestingResults = "fail";
	
	throw new Error("LinearLayoutVector test failed: " + s);
}

private function checkBounds(v:LinearLayoutVector, i:uint, r1:Rectangle):void
{
	var r0:Rectangle = v.getBounds(i);
	if (!r1.equals(r0))
		fail(v + ".getBounds(" + i + ") " + r0 + " != "  + r1);
}

private function testEmptyLLV():void
{
	var llv:LinearLayoutVector =  new LinearLayoutVector();
	llv.length = 129;
	llv.defaultMajorSize = 10;
	llv.minorSize = 100;
	llv.gap = 1;
	
	if (llv.start(0) != 0)   
		fail("llv.start(0) != 0");
		
	llv.majorAxis = LinearLayoutVector.VERTICAL;
	checkBounds(llv, 0, new Rectangle(0, 0, 100, 10));
	  
	llv.majorAxis = LinearLayoutVector.HORIZONTAL;
	checkBounds(llv, 0, new Rectangle(0, 0, 10, 100));

	if (llv.start(1) != 11)  
		fail("llv.start(1) != 11");
	if (llv.indexOf(11) != 1)
		fail("llv.index(11) != 1");
		
	llv.majorAxis = LinearLayoutVector.VERTICAL;
	checkBounds(llv, 1, new Rectangle(0, 11, 100, 10));
					
	llv.majorAxis = LinearLayoutVector.HORIZONTAL;
	checkBounds(llv, 1, new Rectangle(11, 0, 10, 100));

	if (llv.start(127) != (1270 + 127))
		fail("llv.start(127) != " + (1270 + 127));
	if (llv.indexOf(1270 + 127) != 127)
		fail("llv.indexOf(1270 + 127) != 127");                
		
	if (llv.start(128) != (1280 + 128))
		fail("llv.start(128) != " + (1280 + 128));
	if (llv.indexOf(1280 + 128) != 128)
		fail("llv.indexOf(1280 + 128) != 128");
		
	llv.majorAxis = LinearLayoutVector.VERTICAL;
	checkBounds(llv, 128, new Rectangle(0, (1280 + 128), 100, 10));
	
	llv.majorAxis = LinearLayoutVector.HORIZONTAL;
	checkBounds(llv, 128, new Rectangle((1280 + 128), 0, 10, 100));
}

private function testLLV(llv:LinearLayoutVector):void
{
	var distance:Number = 0;
	var defaultMajorSize:Number = llv.defaultMajorSize;
	var minorSize:Number = llv.minorSize;
	var gap:Number = llv.gap;
	var lastIndex:int = llv.length - 1;
	for(var i:int = 0; i < llv.length; i++)
	{
		if (llv.getMajorSize(i) != defaultMajorSize)
			fail("getMajorSize(" + i + ") default, " + defaultMajorSize + " != " + llv.getMajorSize(i));
			
		// check simple read/write
		llv.setMajorSize(i, i);
		if (llv.getMajorSize(i) != i)
			fail("getMajorSize(" + i + ") => " + llv.getMajorSize(i));
			
		// check the start() method
		if (llv.start(i) != distance)
			fail("start(" + i + ") => " + llv.start(i) + " != " + distance);
			
		// Check the getBounds() method
		
		llv.majorAxis = LinearLayoutVector.VERTICAL;
		checkBounds(llv, i, new Rectangle(0, distance, minorSize, i));
		
		llv.majorAxis = LinearLayoutVector.HORIZONTAL;
		checkBounds(llv, i, new Rectangle(distance, 0, i, minorSize));

		// check the indexof() method
		// Note that if gap==0, indices 0 and 1 are indistinguishable, since
		// distance is the *start* of the item
		if ((i > 1) && (llv.indexOf(distance) != i))
			fail("indexOf(" + distance + ") => " + llv.indexOf(distance) + " != " + i);
		
		var distancePlus:Number = distance + 0.1;
		if ((i > 0) && (llv.indexOf(distancePlus) != i))
			fail("indexOf(" + distancePlus + ") => " + llv.indexOf(distancePlus) + " != " + i);

		distance += i;
							
		// check the end() method, distance is now the cumulative distance
		// to the end of item i
		if (llv.end(i) != distance)
			fail("current end(" + i + ") => " + llv.end(i) + " != " + distance);
			
		if (i < lastIndex)
			distance += gap;

		// check end(lastIndex) which requires summing the defaultSize 
		// elements that follow index i
		var nDefaultItems:int = lastIndex - i;
		var defaultItemsGap:Number = Math.max(0, (nDefaultItems - 1) * gap);
		var totalDistance:Number = distance + (defaultMajorSize * nDefaultItems) + defaultItemsGap;
		if (llv.end(lastIndex) != totalDistance)
			fail("extreme end(" + lastIndex + ") => " + llv.end(lastIndex) + " != " + totalDistance);
			
	}
}

/**
 *  Test for a problem with the final statement in indexOf():
 *   return index + Math.floor(Number(distance - curDistance) / Number(_defaultMajorSize + _gap));
 *  At this point in the logic, the value of index == the first index in the block
 *  that is known to contain the index.  The original code incorrectly used Math.ceil().
 * 
 *  Fixed in SVN 4984.
 */
private function testIndexOf():void
{
	var llv:LinearLayoutVector = createLLV(257, 15, 10);
	llv.setMajorSize(0, 15);  // force block 0 to be allocated
	trace("    " + llv);

	var y:Number = (128 * 25) + 10;
	var index:int = llv.indexOf(y); // middle of elt 0, block #1 
	if (index != 128)
		fail("indexOf(" + y + ") failed, index " + index + " expected 128");

	y = (128 * 25);
	index = llv.indexOf(y); // beginning of elt 0, block #1 
	if (index != 128)
		fail("indexOf(" + y + ") failed, index " + index + " expected 128");

	y = (255 * 25) + 10; 
	index = llv.indexOf(y); // middle of elt 255, block #1 
	if (index != 255)
		fail("indexOf(" + y + ") failed, " + index + " + expected 255");

	y = (256 * 25) + 10; 
	index = llv.indexOf(y); // middle of elt 256, block #2 
	if (index != 256)
		fail("indexOf(" + y + ") failed, " + index + " + expected 256");

}

private function createLLV(l:uint, s:Number, g:Number):LinearLayoutVector
{
	var llv:LinearLayoutVector =  new LinearLayoutVector();
	llv.length = l;
	llv.defaultMajorSize = s;
	llv.minorSize = 25;
	llv.gap = g;
	return llv;
}

private function test():void
{
	trace("Check empty LinearLayoutVector, sizes are default.");
	testEmptyLLV();

	trace("Check LinearLayoutVector get/set/start with allocations ...");
	var llv:LinearLayoutVector;                

	llv =  createLLV(1000, 10, 1);
	trace ("    " + llv);
	testLLV(llv);
	  
	llv =  createLLV(100, 0, 0);
	trace ("    " + llv);
	testLLV(llv);

	llv =  createLLV(128, 10, 1);
	trace ("    " + llv);
	testLLV(llv);


	llv =  createLLV(129, 10, 1);
	trace ("    " + llv);
	testLLV(llv);

	llv =  createLLV(512, 10, 1);
	trace ("    " + llv);
	testLLV(llv);

	llv =  createLLV(515, 10, 1);
	trace ("    " + llv);
	testLLV(llv);
	
	trace("Check indexOf()");
    testIndexOf();


	trace("Done.");

}            