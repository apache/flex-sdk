/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
package utils;

import java.util.ArrayList;

/**
 * Parses a string of arguments into an ArrayList of name=value pairs.
 */
public class ArgumentParser {

	public ArgumentParser( String value )
	{
		_arguments = value;
	}
	
	// ---------------------------------------------------------------------------
	// arguments (to be parsed)
	// ---------------------------------------------------------------------------
	
	private String _arguments;

	/**
	 * The argument string to be parsed. Valid arguments are those that may be passed
	 * to compc or mxmlc.
	 */
	public String get_arguments() {
		return _arguments;
	}

	public void set_arguments(String _arguments) {
		this._arguments = _arguments;
	}
	
	// ---------------------------------------------------------------------------
	// result
	// ---------------------------------------------------------------------------
	
	/**
	 * The resultant ArrayList of arg=value pairs as String entries.
	 */
	public ArrayList result;
	
	// ---------------------------------------------------------------------------
	// toArray
	// ---------------------------------------------------------------------------
	
	/**
	 * Converts the given ArrayList into an array of Strings.
	 */
	static public String[] toArray(ArrayList value)
	{
		String[] strArray = new String[value.size()];
		for(int i=0; i < value.size(); i++ ) {
			strArray[i] = (String)value.get(i);
		}
		return strArray;
	}
	
	// ---------------------------------------------------------------------------
	// toString
	// ---------------------------------------------------------------------------
	
	/**
	 * Converts an ArrayList into a String separated by spaces. The parser should
	 * be able to re-create the ArrayList from this String.
	 */
	static public String toString(ArrayList value)
	{
		String str = "";
		for(int i=0; i < value.size(); i++ ) {
			if( i > 0 ) str += " ";
			str += (String)value.get(i);
		}
		return str;
	}
	
	// ---------------------------------------------------------------------------
	// parseArguments
	// ---------------------------------------------------------------------------
	
	/**
	 * Arguments are identified with - or -- preceding them and separated from the previous argument
	 * by one or more spaces. The value of the argument, if present, is separated from the argument name
	 * using an equal-sign.
	 * @return
	 */
	public ArrayList parseArguments()
	{
		// prefix the working copy with a space so that every argument is separated by one or more spaces.
		String working = " "+_arguments+" ";
		int index = 0;
		
		result = new ArrayList();
		
		while( index < working.length() )
		{
			int next = findNextArg(index, working);
			if( next < 0 ) break;
			
			int pos = extractArgName( next, working );
			ArgRange range = extractArgValue( pos+1, working );
			
			if( range != null ) {
				String argName = working.substring(next, pos);
				String argValue = working.substring(range.startIndex,range.endIndex);

// Places quotes around the file name just makes a file name with quotes in it and adversely
// affects how the file name is interpreted. Better to leave off the quotes				
//				result.add( argName+"="+(range.hasSpaces?"\"":"")+argValue+(range.hasSpaces?"\"":""));
//debug			System.out.println("arg name=value: "+argName+"="+(range.hasSpaces?"'":"")+argValue+(range.hasSpaces?"'":""));

				result.add( argName+"="+argValue );
				
				index = range.endIndex+1;
			} else {
				String argName = working.substring(next, pos);
				result.add(argName);
				
				index = pos+1;
			}
			
		}
		
		return result;
	}
	
	/**
	 * @private
	 * Returns the index of the next argument in the sequence.
	 */
	private int findNextArg( int index, String working )
	{
		for(int i=index; i < working.length(); i++ )
		{
			char c = working.charAt(i);
			if( c == ' ' ) continue;
			if( c == '-' || c == '+' ) {
				return i;
			}
		}
		
		return -1;
	}
	
	/**
	 * Find the index of the start of the argument name. The name must end with
	 * either a - or a space.
	 */
	private int extractArgName( int index, String working )
	{
		for(int i=index; i < working.length(); i++ )
		{
			char c = working.charAt(i);
			if( c == ' ' ) return i;
			if( c == '=' ) return i;
		}
		
		return -1;
	}
	
	/**
	 * Returns an ArgRange denoting the position of the argument value. The end of an
	 * argument's value is either the end of the string or a hyphen that is proceeded
	 * by at least one space. Should the argument value contain any spaces the ArgRange
	 * hasSpaces property is set to true.
	 */
	private ArgRange extractArgValue( int index, String working )
	{
		int firstPos = index;
		int lastPos = index;
		boolean hasSpaces = false;
		
		for(int i=index; i < working.length(); i++ )
		{
			char c = working.charAt(i);
			if( c == ' ' ) continue; // skip leading blanks.
			firstPos = i;
			break;
		}
		
		if( working.charAt(firstPos) == '-' ) return null; // there is no argValue
		
		for(int i=index; i < working.length(); i++ )
		{
			char c = working.charAt(i);
			
			// the only thing that stops us at this point is - or the end of the string
			if( c == '-' ) {
				// look at the previous character: if it is a space, then the argument's end
				// has been found. If not, consider the hyphen part of the argument value.
				char prev = working.charAt(i-1);
				if( prev == ' ' ) break;
			}
			else if( c == '+' ) {
				break;
			}
			else {
				if( c != ' ' ) lastPos = i; // the last non-blank character
			}
		}
		
		// scan for any spaces between the first and last positions
		for(int i=firstPos; !hasSpaces && i <= lastPos; i++) {
			char c = working.charAt(i);
			if( c == ' ' ) hasSpaces = true;
		}
		
		return new ArgRange(firstPos,lastPos+1,hasSpaces);
	}
}
