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

package flex2.compiler;

import flash.swf.tags.DefineTag;
import flex2.compiler.io.VirtualFile;
import java.util.Map;

/**
 * Value object used to contain information related to an asset.
 *
 * @see flex2.compiler.Assets
 */
public final class AssetInfo
{
    private DefineTag defineTag;
    private VirtualFile path;
    private long creationTime;
    private Map<String, Object> args;
    
    public AssetInfo(DefineTag defineTag, VirtualFile path, long creationTime, Map<String, Object> args)
    {
        this.defineTag = defineTag;
        this.path = path;
        this.creationTime = creationTime;
        this.args = args;
    }

    AssetInfo(DefineTag defineTag)
    {
        this.defineTag = defineTag;
    }

    public Map<String, Object> getArgs()
    {
        return args;
    }

    public long getCreationTime()
    {
        return creationTime;
    }

    public DefineTag getDefineTag()
    {
        return defineTag;
    }

    /**
     * This is used by the webtier compiler.
     */
    public VirtualFile getPath()
    {
        return path;
    }

    void setDefineTag(DefineTag defineTag)
    {
        this.defineTag = defineTag;
    }
}
