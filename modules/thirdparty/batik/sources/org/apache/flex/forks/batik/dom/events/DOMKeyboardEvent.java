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
package org.apache.flex.forks.batik.dom.events;

import java.util.HashSet;

import org.w3c.dom.events.KeyboardEvent;
import org.w3c.dom.views.AbstractView;

/**
 * DOM 3 Keyboard event class.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: DOMKeyboardEvent.java 598494 2007-11-27 02:46:33Z cam $
 */
public class DOMKeyboardEvent extends DOMUIEvent implements KeyboardEvent {

    // Key identifiers
    public static final String KEY_UNIDENTIFIED = "Unidentified";
    public static final String KEY_ACCEPT = "Accept";
    public static final String KEY_AGAIN = "Again";
    public static final String KEY_ALL_CANDIDATES = "AllCandidates";
    public static final String KEY_ALPHANUMERIC = "Alphanumeric";
    public static final String KEY_ALT = "Alt";
    public static final String KEY_ALT_GRAPH = "AltGraph";
    public static final String KEY_APPS = "Apps";
    public static final String KEY_ATTN = "Attn";
    public static final String KEY_BROWSER_BACK = "BrowserBack";
    public static final String KEY_BROWSER_FAVORITES = "BrowserFavorites";
    public static final String KEY_BROWSER_FORWARD = "BrowserForward";
    public static final String KEY_BROWSER_HOME = "BrowserHome";
    public static final String KEY_BROWSER_REFRESH = "BrowserRefresh";
    public static final String KEY_BROWSER_SEARCH = "BrowserSearch";
    public static final String KEY_BROWSER_STOP = "BrowserStop";
    public static final String KEY_CAPS_LOCK = "CapsLock";
    public static final String KEY_CLEAR = "Clear";
    public static final String KEY_CODE_INPUT = "CodeInput";
    public static final String KEY_COMPOSE = "Compose";
    public static final String KEY_CONTROL = "Control";
    public static final String KEY_CRSEL = "Crsel";
    public static final String KEY_CONVERT = "Convert";
    public static final String KEY_COPY = "Copy";
    public static final String KEY_CUT = "Cut";
    public static final String KEY_DOWN = "Down";
    public static final String KEY_END = "End";
    public static final String KEY_ENTER = "Enter";
    public static final String KEY_ERASE_EOF = "EraseEof";
    public static final String KEY_EXECUTE = "Execute";
    public static final String KEY_EXSEL = "Exsel";
    public static final String KEY_F1 = "F1";
    public static final String KEY_F2 = "F2";
    public static final String KEY_F3 = "F3";
    public static final String KEY_F4 = "F4";
    public static final String KEY_F5 = "F5";
    public static final String KEY_F6 = "F6";
    public static final String KEY_F7 = "F7";
    public static final String KEY_F8 = "F8";
    public static final String KEY_F9 = "F9";
    public static final String KEY_F10 = "F10";
    public static final String KEY_F11 = "F11";
    public static final String KEY_F12 = "F12";
    public static final String KEY_F13 = "F13";
    public static final String KEY_F14 = "F14";
    public static final String KEY_F15 = "F15";
    public static final String KEY_F16 = "F16";
    public static final String KEY_F17 = "F17";
    public static final String KEY_F18 = "F18";
    public static final String KEY_F19 = "F19";
    public static final String KEY_F20 = "F20";
    public static final String KEY_F21 = "F21";
    public static final String KEY_BACKSPACE = "U+0008";
    public static final String KEY_TAB = "U+0009";
    public static final String KEY_CANCEL = "U+0018";
    public static final String KEY_ESCAPE = "U+001B";
    public static final String KEY_SPACE = "U+0020";
    public static final String KEY_EXCLAMATION = "U+0021";
    public static final String KEY_QUOTE = "U+0022";
    public static final String KEY_HASH = "U+0023";
    public static final String KEY_DOLLAR = "U+0024";
    public static final String KEY_AMPERSAND = "U+0026";
    public static final String KEY_APOSTROPHE = "U+0027";
    public static final String KEY_LEFT_PARENTHESIS = "U+0028";
    public static final String KEY_RIGHT_PARENTHESIS = "U+0029";
    public static final String KEY_ASTERISK = "U+002A";
    public static final String KEY_PLUS = "U+002B";
    public static final String KEY_COMMA = "U+002C";
    public static final String KEY_MINUS = "U+002D";
    public static final String KEY_FULL_STOP = "U+002E";
    public static final String KEY_SLASH = "U+002F";
    public static final String KEY_0 = "U+0030";
    public static final String KEY_1 = "U+0031";
    public static final String KEY_2 = "U+0032";
    public static final String KEY_3 = "U+0033";
    public static final String KEY_4 = "U+0034";
    public static final String KEY_5 = "U+0035";
    public static final String KEY_6 = "U+0036";
    public static final String KEY_7 = "U+0037";
    public static final String KEY_8 = "U+0038";
    public static final String KEY_9 = "U+0039";
    public static final String KEY_COLON = "U+003A";
    public static final String KEY_SEMICOLON = "U+003B";
    public static final String KEY_LESS_THAN = "U+003C";
    public static final String KEY_EQUALS = "U+003D";
    public static final String KEY_GREATER_THAN = "U+003E";
    public static final String KEY_QUESTION = "U+003F";
    public static final String KEY_AT = "U+0040";
    public static final String KEY_A = "U+0041";
    public static final String KEY_B = "U+0042";
    public static final String KEY_C = "U+0043";
    public static final String KEY_D = "U+0044";
    public static final String KEY_E = "U+0045";
    public static final String KEY_F = "U+0046";
    public static final String KEY_G = "U+0047";
    public static final String KEY_H = "U+0048";
    public static final String KEY_I = "U+0049";
    public static final String KEY_J = "U+004A";
    public static final String KEY_K = "U+004B";
    public static final String KEY_L = "U+004C";
    public static final String KEY_M = "U+004D";
    public static final String KEY_N = "U+004E";
    public static final String KEY_O = "U+004F";
    public static final String KEY_P = "U+0050";
    public static final String KEY_Q = "U+0051";
    public static final String KEY_R = "U+0052";
    public static final String KEY_S = "U+0053";
    public static final String KEY_T = "U+0054";
    public static final String KEY_U = "U+0055";
    public static final String KEY_V = "U+0056";
    public static final String KEY_W = "U+0057";
    public static final String KEY_X = "U+0058";
    public static final String KEY_Y = "U+0059";
    public static final String KEY_Z = "U+005A";
    public static final String KEY_LEFT_SQUARE_BRACKET = "U+005B";
    public static final String KEY_BACKSLASH = "U+005C";
    public static final String KEY_RIGHT_SQUARE_BRACKET = "U+005D";
    public static final String KEY_CIRCUMFLEX = "U+005E";
    public static final String KEY_UNDERSCORE = "U+005F";
    public static final String KEY_GRAVE = "U+0060";
    public static final String KEY_LEFT_BRACE = "U+007B";
    public static final String KEY_VERTICAL_BAR = "U+007C";
    public static final String KEY_RIGHT_BRACE = "U+007D";
    public static final String KEY_DELETE = "U+007F";
    public static final String KEY_INVERTED_EXCLAMATION = "U+00A1";
    public static final String KEY_COMBINING_GRAVE = "U+0300";
    public static final String KEY_COMBINING_ACUTE = "U+0301";
    public static final String KEY_COMBINING_CIRCUMFLEX = "U+0302";
    public static final String KEY_COMBINING_TILDE = "U+0303";
    public static final String KEY_COMBINING_MACRON = "U+0304";
    public static final String KEY_COMBINING_BREVE = "U+0306";
    public static final String KEY_COMBINING_DOT_ABOVE = "U+0307";
    public static final String KEY_COMBINING_DIERESIS = "U+0308";
    public static final String KEY_COMBINING_RING_ABOVE = "U+030A";
    public static final String KEY_COMBINING_DOUBLE_ACUTE = "U+030B";
    public static final String KEY_COMBINING_CARON = "U+030C";
    public static final String KEY_COMBINING_CEDILLA = "U+0327";
    public static final String KEY_COMBINING_OGONEK = "U+0328";
    public static final String KEY_COMBINING_IOTA = "U+0345";
    public static final String KEY_EURO = "U+20AC";
    public static final String KEY_VOICED_SOUND = "U+3099";
    public static final String KEY_SEMIVOICED_SOUND = "U+309A";

    public static final String KEY_F22 = "F22";
    public static final String KEY_F23 = "F23";
    public static final String KEY_F24 = "F24";
    public static final String KEY_FINAL_MODE = "FinalMode";
    public static final String KEY_FIND = "Find";
    public static final String KEY_FULL_WIDTH = "FullWidth";
    public static final String KEY_HALF_WIDTH = "HalfWidth";
    public static final String KEY_HANGUL_MODE = "HangulMode";
    public static final String KEY_HANJA_MODE = "HanjaMode";
    public static final String KEY_HELP = "Help";
    public static final String KEY_HIRAGANA = "Hiragana";
    public static final String KEY_HOME = "Home";
    public static final String KEY_INSERT = "Insert";
    public static final String KEY_JAPANESE_HIRAGANA = "JapaneseHiragana";
    public static final String KEY_JAPANESE_KATAKANA = "JapaneseKatakana";
    public static final String KEY_JAPANESE_ROMAJI = "JapaneseRomaji";
    public static final String KEY_JUNJA_MODE = "JunjaMode";
    public static final String KEY_KANA_MODE = "KanaMode";
    public static final String KEY_KANJI_MODE = "KanjiMode";
    public static final String KEY_KATAKANA = "Katakana";
    public static final String KEY_LAUNCH_APPLICATION1 = "LaunchApplication1";
    public static final String KEY_LAUNCH_APPLICATION2 = "LaunchApplication2";
    public static final String KEY_LAUNCH_MAIL = "LaunchMail";
    public static final String KEY_LEFT = "Left";
    public static final String KEY_META = "Meta";
    public static final String KEY_MEDIA_NEXT_TRACK = "MediaNextTrack";
    public static final String KEY_MEDIA_PLAY_PAUSE = "MediaPlayPause";
    public static final String KEY_MEDIA_PREVIOUS_TRACK = "MediaPreviousTrack";
    public static final String KEY_MEDIA_STOP = "MediaStop";
    public static final String KEY_MODE_CHANGE = "ModeChange";
    public static final String KEY_NONCONVERT = "Nonconvert";
    public static final String KEY_NUM_LOCK = "NumLock";
    public static final String KEY_PAGE_DOWN = "PageDown";
    public static final String KEY_PAGE_UP = "PageUp";
    public static final String KEY_PASTE = "Paste";
    public static final String KEY_PAUSE = "Pause";
    public static final String KEY_PLAY = "Play";
    public static final String KEY_PREVIOUS_CANDIDATE = "PreviousCandidate";
    public static final String KEY_PRINT_SCREEN = "PrintScreen";
    public static final String KEY_PROCESS = "Process";
    public static final String KEY_PROPS = "Props";
    public static final String KEY_RIGHT = "Right";
    public static final String KEY_ROMAN_CHARACTERS = "RomanCharacters";
    public static final String KEY_SCROLL = "Scroll";
    public static final String KEY_SELECT = "Select";
    public static final String KEY_SELECT_MEDIA = "SelectMedia";
    public static final String KEY_SHIFT = "Shift";
    public static final String KEY_STOP = "Stop";
    public static final String KEY_UP = "Up";
    public static final String KEY_UNDO = "Undo";
    public static final String KEY_VOLUME_DOWN = "VolumeDown";
    public static final String KEY_VOLUME_MUTE = "VolumeMute";
    public static final String KEY_VOLUME_UP = "VolumeUp";
    public static final String KEY_WIN = "Win";
    public static final String KEY_ZOOM = "Zoom";

    /**
     * The modifier keys in effect at the time of the event.
     */
    protected HashSet modifierKeys = new HashSet();

    /**
     * The identifier string for the key.
     */
    protected String keyIdentifier;

    /**
     * The location of the key.
     */
    protected int keyLocation;

    /**
     * <b>DOM</b>: Get whether the Control key was pressed at the time of the event.
     */
    public boolean getCtrlKey() {
        return modifierKeys.contains(KEY_CONTROL);
    }

    /**
     * <b>DOM</b>: Get whether the Shift key was pressed at the time of the event.
     */
    public boolean getShiftKey() {
        return modifierKeys.contains(KEY_SHIFT);
    }

    /**
     * <b>DOM</b>: Get whether the Alt key was pressed at the time of the event.
     */
    public boolean getAltKey() {
        return modifierKeys.contains(KEY_ALT);
    }

    /**
     * <b>DOM</b>: Get whether the Meta key was pressed at the time of the
     * event.
     */
    public boolean getMetaKey() {
        return modifierKeys.contains(KEY_META);
    }

    /**
     * <b>DOM</b>: Get the key identifier.
     */
    public String getKeyIdentifier() {
        return keyIdentifier;
    }

    /**
     * <b>DOM</b>: Get the key location.
     */
    public int getKeyLocation() {
        return keyLocation;
    }

    /**
     * <b>DOM</b>: Returns whether the given modifier key was pressed at the
     * time of the event.
     */
    public boolean getModifierState(String keyIdentifierArg) {
        return modifierKeys.contains(keyIdentifierArg);
    }

    /**
     * <b>DOM</b>: Initializes this KeyboardEvent object.
     * @param typeArg Specifies the event type.
     * @param canBubbleArg Specifies whether or not the event can bubble.
     * @param cancelableArg Specifies whether or not the event's default action 
     *   can be prevented.
     * @param viewArg Specifies the <code>Event</code>'s 
     *   <code>AbstractView</code>.
     * @param keyIdentifierArg Specifies the <code>Event</code>'s
     *   <code>keyIdentifier</code>.
     * @param keyLocationArg Specifies the <code>Event</code>'s
     *   <code>keyLocation</code>.
     * @param modifiersList Specifies which modifiers were in effect for this
     *   <code>Event</code>.
     */
    public void initKeyboardEvent(String typeArg, 
                                  boolean canBubbleArg, 
                                  boolean cancelableArg, 
                                  AbstractView viewArg,
                                  String keyIdentifierArg,
                                  int keyLocationArg,
                                  String modifiersList) {
        initUIEvent(typeArg, canBubbleArg, cancelableArg, viewArg, 0);
        keyIdentifier = keyIdentifierArg;
        keyLocation = keyLocationArg;
        modifierKeys.clear();
        String[] modifiers = split(modifiersList);
        for (int i = 0; i < modifiers.length; i++) {
            modifierKeys.add(modifiers[i]);
        }
    }

    /**
     * <b>DOM</b: Initializes this KeyboardEvent object.
     * @param namespaceURIArg Specifies the event namespace URI.
     * @param typeArg Specifies the event type.
     * @param canBubbleArg Specifies whether or not the event can bubble.
     * @param cancelableArg Specifies whether or not the event's default action 
     *   can be prevented.
     * @param viewArg Specifies the <code>Event</code>'s 
     *   <code>AbstractView</code>.
     * @param keyIdentifierArg Specifies the <code>Event</code>'s
     *   <code>keyIdentifier</code>.
     * @param keyLocationArg Specifies the <code>Event</code>'s
     *   <code>keyLocation</code>.
     * @param modifiersList Specifies which modifiers were in effect for this
     *   <code>Event</code>.
     */
    public void initKeyboardEventNS(String namespaceURIArg,
                                    String typeArg,
                                    boolean canBubbleArg, 
                                    boolean cancelableArg, 
                                    AbstractView viewArg,
                                    String keyIdentifierArg,
                                    int keyLocationArg,
                                    String modifiersList) {
        initUIEventNS(namespaceURIArg,
                               typeArg,
                               canBubbleArg,
                               cancelableArg,
                               viewArg,
                               0);
        keyIdentifier = keyIdentifierArg;
        keyLocation = keyLocationArg;
        modifierKeys.clear();
        String[] modifiers = split(modifiersList);
        for (int i = 0; i < modifiers.length; i++) {
            modifierKeys.add(modifiers[i]);
        }
    }
}
