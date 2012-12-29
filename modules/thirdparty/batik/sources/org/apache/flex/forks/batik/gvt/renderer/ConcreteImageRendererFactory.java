/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.gvt.renderer;


/**
 * This class provides a factory for renderers.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ConcreteImageRendererFactory.java 475477 2006-11-15 22:44:28Z cam $
 */
public class ConcreteImageRendererFactory implements ImageRendererFactory {

    /**
     * Creates a new renderer.
     */
    public Renderer createRenderer() {
        return createStaticImageRenderer();
    }

    /**
     * Creates a new static image renderer
     */
    public ImageRenderer createStaticImageRenderer(){
        if (onMacOSX)
            return new MacRenderer();
        return new StaticRenderer();
    }

    /**
     * Creates a new dynamic image renderer
     */
    public ImageRenderer createDynamicImageRenderer(){
        if (onMacOSX)
            return new MacRenderer();
        return new DynamicRenderer();
    }


    static final boolean onMacOSX;
    static {
        // This should be OK for applets.
        onMacOSX = ("Mac OS X".equals(System.getProperty("os.name")));
    }
}
