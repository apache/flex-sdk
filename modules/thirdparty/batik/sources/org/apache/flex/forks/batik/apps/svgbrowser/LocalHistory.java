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
package org.apache.flex.forks.batik.apps.svgbrowser;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;
import java.util.List;

import javax.swing.ButtonGroup;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JRadioButtonMenuItem;

/**
 * This class represents an history of the files visited by a single
 * browser frame.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: LocalHistory.java 489226 2006-12-21 00:05:36Z cam $
 */
public class LocalHistory {
    /**
     * The frame to manage.
     */
    protected JSVGViewerFrame svgFrame;

    /**
     * The menu which contains the history.
     */
    protected JMenu menu;

    /**
     * The index of the first history item in this menu.
     */
    protected int index;

    /**
     * The visited URIs.
     */
    protected List visitedURIs = new ArrayList();

    /**
     * The index of the current URI.
     */
    protected int currentURI = -1;

    /**
     * The button group for the menu items.
     */
    protected ButtonGroup group = new ButtonGroup();

    /**
     * The action listener.
     */
    protected ActionListener actionListener = new RadioListener();

    /**
     * The current state.
     */
    protected int state;

    // States
    protected static final int STABLE_STATE = 0;
    protected static final int BACK_PENDING_STATE = 1;
    protected static final int FORWARD_PENDING_STATE = 2;
    protected static final int RELOAD_PENDING_STATE = 3;

    /**
     * Creates a new local history.
     * @param mb The menubar used to display the history. It must
     *        contain one '@@@' item used as marker to place the
     *        history items.
     * @param svgFrame The frame to manage.
     */
    public LocalHistory(JMenuBar mb, JSVGViewerFrame svgFrame) {
        this.svgFrame = svgFrame;

        // Find the marker.
        int mc = mb.getMenuCount();
        for (int i = 0; i < mc; i++) {
            JMenu m = mb.getMenu(i);
            int ic = m.getItemCount();
            for (int j = 0; j < ic; j++) {
                JMenuItem mi = m.getItem(j);
                if (mi != null) {
                    String s = mi.getText();
                    if ("@@@".equals(s)) {
                        menu = m;
                        index = j;
                        m.remove(j);
                        return;
                    }
                }
            }
        }
        throw new IllegalArgumentException("No '@@@' marker found");
    }

    /**
     * Goes back of one position in the history.
     * Assumes that <tt>canGoBack()</tt> is true.
     */
    public void back() {
        update();
        state = BACK_PENDING_STATE;
        currentURI -= 2;
        svgFrame.showSVGDocument((String)visitedURIs.get(currentURI + 1));
    }

    /**
     * Whether it is possible to go back.
     */
    public boolean canGoBack() {
        return currentURI > 0;
    }

    /**
     * Goes forward of one position in the history.
     * Assumes that <tt>canGoForward()</tt> is true.
     */
    public void forward() {
        update();
        state = FORWARD_PENDING_STATE;
        svgFrame.showSVGDocument((String)visitedURIs.get(currentURI + 1));
    }

    /**
     * Whether it is possible to go forward.
     */
    public boolean canGoForward() {
        return currentURI < visitedURIs.size() - 1;
    }

    /**
     * Reloads the current document.
     */
    public void reload() {
        update();
        state = RELOAD_PENDING_STATE;
        currentURI--;
        svgFrame.showSVGDocument((String)visitedURIs.get(currentURI + 1));
    }

    /**
     * Updates the history.
     * @param uri The URI of the document just loaded.
     */
    public void update(String uri) {
        if (currentURI < -1) {
            throw new IllegalStateException("Unexpected currentURI:" + currentURI );
        }
        state = STABLE_STATE;
        if (++currentURI < visitedURIs.size()) {
            if (!visitedURIs.get(currentURI).equals(uri)) {
                int len = menu.getItemCount();
                for (int i = len - 1; i >= index + currentURI + 1; i--) {
                    JMenuItem mi = menu.getItem(i);
                    group.remove(mi);
                    menu.remove(i);
                }
                visitedURIs = visitedURIs.subList(0, currentURI + 1);
            }
            JMenuItem mi = menu.getItem(index + currentURI);
            group.remove(mi);
            menu.remove(index + currentURI);
            visitedURIs.set(currentURI, uri);
        } else {
            if (visitedURIs.size() >= 15) {
                visitedURIs.remove(0);
                JMenuItem mi = menu.getItem(index);
                group.remove(mi);
                menu.remove(index);
                currentURI--;
            }
            visitedURIs.add(uri);
        }

        // Computes the button text.
        String text = uri;
        int i = uri.lastIndexOf('/');
        if (i == -1) {
            i = uri.lastIndexOf('\\' );
        }

        if (i != -1) {
            text = uri.substring(i + 1);
        }

        JMenuItem mi = new JRadioButtonMenuItem(text);
        mi.setToolTipText(uri);
        mi.setActionCommand(uri);
        mi.addActionListener(actionListener);
        group.add(mi);
        mi.setSelected(true);
        menu.insert(mi, index + currentURI);
    }

    /**
     * Updates the state of this history.
     */
    protected void update() {
        switch (state) {
        case BACK_PENDING_STATE:
            currentURI += 2;
            break;
        case RELOAD_PENDING_STATE:
            currentURI++;
            break;
        case FORWARD_PENDING_STATE:
            // fall-through intended
        case STABLE_STATE:
        }
    }

    /**
     * To listen to the radio buttons.
     */
    protected class RadioListener
            implements ActionListener {

        protected RadioListener() {
        }

        public void actionPerformed( ActionEvent e ) {
            String uri = e.getActionCommand();
            currentURI = getItemIndex( (JMenuItem)e.getSource() ) - 1;
            svgFrame.showSVGDocument( uri );
        }

        public int getItemIndex( JMenuItem item ) {
            int ic = menu.getItemCount();
            for ( int i = index; i < ic; i++ ) {
                if ( menu.getItem( i ) == item ) {
                    return i - index;
                }
            }
            throw new IllegalArgumentException("MenuItem is not from my menu!" );
        }
    }
}
