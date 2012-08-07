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
import mx.controls.Alert;
import mx.controls.Button;
import mx.containers.Panel;

import mx.graphics.SolidColor;
import spark.primitives.*;
import spark.effects.Animate;
import spark.effects.animation.SimpleMotionPath;
import spark.effects.animation.MotionPath;
import mx.controls.Alert;
import mx.geom.TransformOffsets;

import spark.components.Button;
import spark.components.Group;
import spark.components.DataGroup;
import mx.flash.UIMovieClip;

import comps.*;

/*
 * Returns true if two numbers are basically equal within the threshold
 */
public function roughlyEqual(number1:Number, number2:Number, threshold:Number = 0.001):Boolean {
	// TODO: This method hasn't been tested at all yet.
	if (Math.abs(number1 - number2) < threshold)
		return true;
		
	return false;
}

/*
 * This method is an alternative to using AssertError in Mustella.
 * 
 * You should use the Mustella's AssertError when it works for you,
 * but if it fails to catch RTEs then use this method as a fallback
 * as it seems to catch more errors.
 * 
 * There are some RTEs that either method won't catch depending
 * on when they are thrown in the component life cycle.
 * 
 * Usage: 
 * 
 * You can define an inline function like this: 
 *   <AssertMethodValue method="value=application.assertError(function():void { *CODE_THAT_THROWS_ERROR* })" value="Error: Some Error" />
 * or, pass in the name of a function you have already written:
 *   <AssertMethodValue method="value=application.assertError(myErrorThrowingFunctionName)" value="Error: Some Error" />
 */
public function assertError(func:Function):String {
			   
	try {
		func.call();
	} catch (e:Error) {
		return e.toString();
	}
	
	return "no error";
   
}


/*
 * Returns a Halo Button
 */
public function createHaloButton(str:String = 'halo button', width:int = 80, height:int = 20):mx.controls.Button {
	var myButton:mx.controls.Button = new mx.controls.Button();
	myButton.label = str;
	myButton.width = width;
	myButton.height = height;
	return myButton;
}

/*
 * Returns a Spark Button
 */
public function createSparkButton(str:String, width:int = 80, height:int = 20):spark.components.Button {
	var myButton:spark.components.Button = new spark.components.Button();
	myButton.label = str;
	myButton.width = width;
	myButton.height = height;
	return myButton;
}

/*
 * Returns a Group with a "stretch" Rect in it
 */
public function createGroup(width:int = 50, height:int = 50, color:int = 0x000055):Group {
	var myGroup:Group = new Group();
	myGroup.width = width;
	myGroup.height = height;
	
	var myRect:Rect = new Rect();
	myRect.top = 0;
	myRect.left = 0;
	myRect.right = 0;
	myRect.bottom = 0;
	
	var myFill:SolidColor = new SolidColor();
	myFill.color = color;
	myRect.fill = myFill;
	
	myGroup.addElement(myRect);	
	
	return myGroup;
}

/*
 * Returns a halo Panel
 */
public function createPanel(title:String = "halo panel", width:int = 50, height:int = 50):mx.containers.Panel {
	var myPanel:mx.containers.Panel = new mx.containers.Panel();
	myPanel.title = title;
	myPanel.width = width;
	myPanel.height = height;	
	return myPanel;
}

/*
 * Animate target.property from start to end values
 */
public function animateProperty(target:Object, property:String, start:*, end:*, duration:Number = 1000):void {
	
	var anim:Animate = new Animate();
	
	anim.motionPaths = new Vector.<MotionPath>();
	anim.duration = duration;
	anim.motionPaths.push(new SimpleMotionPath(property, start, end));
	
	anim.play([target]);
}

/*
 * Transform a UIMovieClip
 */
public function transformClip(myClip:UIMovieClip):void {
	var newMatrix:Matrix = myClip.transform.matrix;
	newMatrix.rotate(45 * (Math.PI / 180));
	myClip.transform.matrix = newMatrix;
}