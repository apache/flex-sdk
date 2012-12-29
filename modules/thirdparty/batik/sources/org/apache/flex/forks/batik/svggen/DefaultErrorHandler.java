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
package org.apache.flex.forks.batik.svggen;

/**
 * The <code>ErrorHandler</code> interface allows you to specialize
 * how the error will be set on an SVG <code>Element</code>.
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @version $Id: DefaultErrorHandler.java 475477 2006-11-15 22:44:28Z cam $
 */
public class DefaultErrorHandler implements ErrorHandler {
    /**
     * This method handles the <code>SVGGraphics2DIOException</code>. The default
     * implementation re-throws the exception.
     */
    public void handleError(SVGGraphics2DIOException ex)
        throws SVGGraphics2DIOException {
        throw ex;
    }

    /**
     * This method handles the <code>SVGGraphics2DRuntimeException</code>.
     * The default implementation print the exception message.
     */
    public void handleError(SVGGraphics2DRuntimeException ex)
        throws SVGGraphics2DRuntimeException {
        System.err.println(ex.getMessage());
    }
}
