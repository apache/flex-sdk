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

package flex2.compiler.mxml;

import java.util.List;

/**
 * Parse tree visitors must implement this interface.
 *
 * @author Clement Wong
 */
public interface MxmlVisitor
{
	void parseApplication(Token app, List<Token> components);

	void parseDeclarations(Token t, List properties);

	void parseComponent(Token comp, List<Token> components);

	void parseStyle(Token style, Token text);

	void parseScript(Token script, Token text);

	void parseMetaData(Token metadata, Token text);

	void parseModel(Token t, List<Token> objects);

	void parseXML(Token t, List<Token> objects);
    
    void parseXMLList(Token t, List<Token> objects);

	void parseArray(Token t, List<Token> elements);

	void parseVector(Token t, List<Token> elements);

	void parseBinding(Token t);

	void parseAnonymousObject(Token t, List<Token> objects);

	void parseWebService(Token t, List<Token> children);

	void parseHTTPService(Token t, List<Token> children);

	void parseRemoteObject(Token t, List<Token> children);

	void parseOperation(Token t, List<Token> children);

	void parseRequest(Token t, List<Token> children);

	void parseMethod(Token t, List<Token> children);

	void parseArguments(Token t, List<Token> children);

	void parseString(Token s, Token data);

	void parseNumber(Token n, Token data);

    void parseInt(Token n, Token data);

    void parseUInt(Token n, Token data);

    void parseBoolean(Token b, Token data);

	void parseClass(Token b, Token data);

	void parseFunction(Token b, Token data);

	void parseInlineComponent(Token t, Token child);
	
	// States Specific Additions
	void parseReparent(Token t);
	
	void parseState(Token t, List<Token> children);

	/*
	 * FXG Specific Additions 
	 */
    void parseLibrary(Token t, List children);

    void parseDefinition(Token t, Token child);
 
    void parseDesignLayer(Token t, List<Token> children);
}
