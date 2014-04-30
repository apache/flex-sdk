/*
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
 */
package flash.tools.debugger.concrete;

import flash.tools.debugger.Isolate;

/**
 * Concrete implementation of an Isolate.
 * @author anirudhs
 */
public class DIsolate implements Isolate {

	/** Isolate object behind the primordial or main thread (always exists) */
	public static final DIsolate DEFAULT_ISOLATE = new DIsolate(Isolate.DEFAULT_ID);
	
	private int id;
	
	public DIsolate(int id) {
		this.id = id;
	}
	
	/* (non-Javadoc)
	 * @see flash.tools.debugger.Isolate#getId()
	 */
	@Override
	public int getId() {
		return id;
	}

	@Override
	public String toString() {		
		return "Worker " + getId(); //$NON-NLS-1$
	}	

}
