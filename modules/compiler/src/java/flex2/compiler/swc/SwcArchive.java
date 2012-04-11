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

package flex2.compiler.swc;

import flex2.compiler.io.VirtualFile;

import java.util.Map;

/**
 * Defines the API for loading, saving, closing a SWC and adding and
 * fetching files from a SWC.
 *
 * @author Roger Gonzalez
 */
public interface SwcArchive
{
    public String getLocation();
    public void load();
    public void save() throws Exception;
	public void close();

    public Map<String, VirtualFile> getFiles();
    public VirtualFile getFile( String path );
    public void putFile( VirtualFile file );
    public void putFile( String path, byte[] data, long lastModified );

    public long getLastModified();
}
