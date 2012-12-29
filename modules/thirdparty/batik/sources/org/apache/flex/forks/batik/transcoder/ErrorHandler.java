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
package org.apache.flex.forks.batik.transcoder;

/**
 * This interface provides a way to catch errors and warnings from a
 * Transcoder.
 *
 * If an application needs to implement customized error handling, it
 * must implement this interface and then register an instance with
 * the Transcoder using the transcoder's setErrorHandler method. The
 * transcoder will then report all errors and warnings through this
 * interface.
 *
 * A transcoder shall use this interface instead of throwing an
 * exception: it is up to the application whether to throw an
 * exception for different types of errors and warnings. Note,
 * however, that there is no requirement that the transcoder continue
 * to provide useful information after a call to fatalError (in other
 * words, a transcoder class could catch an exception and report a
 * fatalError).
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: ErrorHandler.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface ErrorHandler {

    /**
     * Invoked when an error occured while transcoding.
     * @param ex the error informations encapsulated in a TranscoderException
     * @exception TranscoderException if the method want to forward
     * the exception
     */
    void error(TranscoderException ex) throws TranscoderException;

    /**
     * Invoked when an fatal error occured while transcoding.
     * @param ex the fatal error informations encapsulated in a
     * TranscoderException
     * @exception TranscoderException if the method want to forward
     * the exception
     */
    void fatalError(TranscoderException ex) throws TranscoderException;

    /**
     * Invoked when a warning occured while transcoding.
     * @param ex the warning informations encapsulated in a TranscoderException
     * @exception TranscoderException if the method want to forward
     * the exception
     */
    void warning(TranscoderException ex) throws TranscoderException;

}
