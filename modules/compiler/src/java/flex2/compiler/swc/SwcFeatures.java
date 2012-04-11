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

/**
 * The features enabled for a SWC.
 *
 * @author Brian Deitte
 */
public class SwcFeatures
{
    private boolean debug;
    private boolean externalDeps = false;
    private boolean scriptDeps = true;

    public boolean isComponents()
    {
        return components;
    }

    public void setComponents( boolean components )
    {
        this.components = components;
    }

    public boolean isFiles()
    {
        return files;
    }

    public void setFiles( boolean files )
    {
        this.files = files;
    }

    private boolean files = false;
    private boolean components = false;
    //private boolean methodDeps;

    public boolean isDebug()
    {
        return debug;
    }

    public void setDebug(boolean debug)
    {
        this.debug = debug;
    }

    public boolean hasExternalDeps()
    {
        return externalDeps;
    }

    public void setExternalDeps(boolean externalDeps)
    {
        this.externalDeps = externalDeps;
    }

    public boolean isScriptDeps()
    {
        return scriptDeps;
    }

    public void setScriptDeps(boolean scriptDeps)
    {
        this.scriptDeps = scriptDeps;
    }


    /*public boolean isMethodDeps()
    {
        return methodDeps;
    }

    public void setMethodDeps(boolean methodDeps)
    {
        this.methodDeps = methodDeps;
    }
    */
}
