/*************************************************************************
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 * Copyright 2010 Adobe Systems Incorporated
 * All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe Systems Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Adobe Systems Incorporated and its
 * suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe Systems Incorporated.
 **************************************************************************/

package utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.security.GeneralSecurityException;
import java.security.Key;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.UnrecoverableKeyException;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;
import java.util.Enumeration;

/**
 * Class responsible for all interactions with the KeyStore class.
 * 
 * Assumes the PFX file contains exactly one private key and certificate.
 */
public class P12Reader {
	
	private static final String KEYSTORE_TYPE = "PKCS12"; //$NON-NLS-1$
	
    private KeyStore keyStore;
    private String password;
    private String alias;

    /**
     * Creates a new instance of PFXReader.
     *
     * @throws CertificateException If any of the certificates in the certificate file
     *         could not be loaded.
     * @throws FileNotFoundException If the certifcate file is not found.
     * @throws IOException If there is an I/O or format problem with the certificate file or
     *         if the password is incorrect.
     * @throws NoSuchAlgorithmException If the algorithm used to check the integrity of
     *         the certificate file cannot be found.
     * @throws KeyStoreException 
     */
    public P12Reader( File file, String password ) throws GeneralSecurityException, IOException {
        this( new FileInputStream( file ), password );
    }

    /**
     * Creates a new instance of PFXReader.
     *
     * @throws CertificateException If any of the certificates in the certificate file
     *         could not be loaded.
     * @throws IOException If there is an I/O or format problem with the certificate file or
     *         if the password is incorrect.
     * @throws NoSuchAlgorithmException If the algorithm used to check the integrity of
     *         the certificate file cannot be found.
     * @throws KeyStoreException 
     */
    public P12Reader( InputStream inputStream, String password ) throws GeneralSecurityException, IOException {
        this.password = password;

       // try {
            keyStore = KeyStore.getInstance(KEYSTORE_TYPE);
            keyStore.load( inputStream, password.toCharArray() );
            Enumeration aliases = keyStore.aliases();
            if( aliases.hasMoreElements() ) alias = (String) aliases.nextElement();
        //} catch( KeyStoreException e ) {
        //    assert false; // should never get here
        //}
    }

    /**
     * Returns the private key or <code>null</code> if it does not exist.
     * 
     * @throws NoSuchAlgorithmException If the algorithm for recovering the key cannot be found.
     * @throws UnrecoverableKeyException If the key cannot be recovered (e.g., the given password is wrong).
     */
    public PrivateKey getPrivateKey() throws GeneralSecurityException {
        Key key = null;

        //try {
            if( alias != null ) key = keyStore.getKey( alias, password.toCharArray() );
        //} catch( KeyStoreException e ) {
        //    assert false; // should never get here
        //}

        return ( PrivateKey ) key;
    }

    /*
     * Returns the certificate or <code>null</code> if it does not exist.
     *
     */
    public Certificate getCertificate() throws KeyStoreException {
        Certificate certificate = null;

        //try {
            if( alias != null ) certificate = keyStore.getCertificate( alias );
        //} catch( KeyStoreException e ) {
        //    assert false; // should never get here
        //}

        return certificate;
    }

    /**
     * Returns the certificate chain or <code>null</code> if it does not exist.
     * @throws KeyStoreException 
     */
    public Certificate[] getCertificateChain() throws KeyStoreException {
        Certificate[] certificates = null;

        //try {
            if( alias != null ) certificates = keyStore.getCertificateChain( alias );
            // convert all zero-length arrays as null
            if( ( certificates != null ) && ( certificates.length == 0 ) ) certificates = null;
        //} catch( KeyStoreException e ) {
        //    assert false; // should never get here
        //}

        return certificates;
    }
}

