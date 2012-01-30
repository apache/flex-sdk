////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.accessibility
{

/**
 *  The AccConst class defines constants defined in
 *  Microsoft's Active Accessibility (MSAA) specification.
 *  They are used to implement subclasses of AccessibilityImplementation.
 *
 *  <p>Since Flash Player uses MSAA to provide accessibility,
 *  the names of the constants in this file have been taken
 *  verbatim from Microsoft's MSAA SDK.
 *  Their descriptions have been taken with minor modifications.
 *  Keep in mind when reading them that Flash Player is considered
 *  an "MSAA server application" because DisplayObjects in a SWF
 *  provide MSAA information to MSAA clients such as screen readers,
 *  via a COM interface called IAccessible.</p>
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public final class AccConst
{
    include "../core/Version.as";

    //--------------------------------------
    //  MSAA roles
    //--------------------------------------

    /**
     *  An MSAA role indicating that
     *  the object represents a title or caption bar for a window.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_TITLEBAR:uint = 0x1;

    /**
     *  An MSAA role indicating that
     *  the object represents the menu bar,
     *  usually following (beneath) the title bar of a window,
     *  from which menus can be selected by the user.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_MENUBAR:uint = 0x2;

    /**
     *  An MSAA role indicating that
     *  the object represents a vertical or horizontal scroll bar,
     *  which can be either part of the client area or used in a control.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_SCROLLBAR:uint = 0x3;

    /**
     *  An MSAA role indicating that
     *  the object represents a special mouse pointer,
     *  which allows a user to manipulate
     *  user interface elements such as a window.
     *
     *  <p>For example, a user can click and drag a sizing grip
     *  in the lower-right corner of a window to resize it.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_GRIP:uint = 0x4;

    /**
     *  An MSAA role indicating that
     *  the object represents a system sound,
     *  which is associated with various system events.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_SOUND:uint = 0x5;

    /**
     *  An MSAA role indicating that
     *  the object represents the system mouse pointer.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_CURSOR:uint = 0x6;

    /**
     *  An MSAA role indicating that
     *  the object represents the system caret.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_CARET:uint = 0x7;

    /**
     *  An MSAA role indicating that
     *  the object represents an alert or a condition
     *  that a user should be notified about.
     *
     *  <p>This role should be used only for objects that embody an alert
     *  but are not associated with another user interface element
     *  such as a message box, graphic, text, or sound.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_ALERT:uint = 0x8;

    /**
     *  An MSAA role indicating that
     *  the object represents the window frame,
     *  which usually contains child objects such as a title bar,
     *  client, and other objects typically contained in a window.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_WINDOW:uint = 0x9;

    /**
     *  An MSAA role indicating that
     *  the object represents a window's client area.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_CLIENT:uint = 0xA;

    /**
     *  An MSAA role indicating that
     *  the object represents a menu,
     *  which presents a list of options from which the user
     *  can make a selection to perform an action.
     *
     *  <p>All menu types must have this role,
     *  including drop-down menus that are displayed by selection
     *  from a menu bar, and shortcut menus that are displayed
     *  when the right mouse button is clicked.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_MENUPOPUP:uint = 0xB;

    /**
     *  An MSAA role indicating that
     *  the object represents a menu item,
     *  which is an entry in a menu that a user can choose
     *  to carry out a command, select an option, or display another menu.
     *
     *  <p>Functionally, a menu item can be equivalent to a push button,
     *  radio button, check box, or menu.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_MENUITEM:uint = 0xC;

    /**
     *  An MSAA role indicating that
     *  the object represents a ToolTip that provides helpful hints.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_TOOLTIP:uint = 0xD;

    /**
     *  An MSAA role indicating that
     *  the object represents a main window for an application.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_APPLICATION:uint = 0xE;

    /**
     *  An MSAA role indicating that
     *  the object represents a document window.
     *
     *  <p>A document window is always contained within an application window.
     *  This role applies only to multiple-document interface (MDI) windows
     *  and refers to the object that contains the MDI title bar.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_DOCUMENT:uint = 0xF;

    /**
     *  An MSAA role indicating that
     *  the object represents a pane within a frame or document window.
     *
     *  <p>Users can navigate between panes
     *  and within the contents of the current pane,
     *  but cannot navigate between items in different panes.
     *  Thus, panes represent a level of grouping
     *  lower than frame windows or documents,
     *  but above individual controls.
     *  Typically the user navigates between panes
     *  by pressing TAB, F6, or CTRL+TAB, depending on the context.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_PANE:uint = 0x10;

    /**
     *  An MSAA role indicating that
     *  he object represents a graphical image used to represent data.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_CHART:uint = 0x11;

    /**
     *  An MSAA role indicating that
     *  the object represents a dialog box or message box.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_DIALOG:uint = 0x12;

    /**
     *  An MSAA role indicating that
     *  the object represents a window border.
     *
     *  <p>The entire border is represented by a single object,
     *  rather than by separate objects for each side.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_BORDER:uint = 0x13;

    /**
     *  An MSAA role indicating that
     *  the object logically groups other objects.
     *
     *  <p>There may or may not be a parent-child relationship
     *  between the grouping object and the objects it contains.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_GROUPING:uint = 0x14;

    /**
     *  An MSAA role indicating that
     *  the object is used to visually divide a space into two regions,
     *  such as a separator menu item
     *  or a bar dividing split panes within a window.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_SEPARATOR:uint = 0x15;

    /**
     *  An MSAA role indicating that
     *  the object represents a toolbar,
     *  which is a grouping of controls
     *  that provide easy access to frequently used features.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_TOOLBAR:uint = 0x16;

    /**
     *  An MSAA role indicating that
     *  the object represents a status bar,
     *  which is an area typically at the bottom of a window
     *  that displays information about the current operation,
     *  state of the application, or selected object.
     *
     *  <p>The status bar can have multiple fields,
     *  which display different kinds of information.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_STATUSBAR:uint = 0x17;

    /**
     *  An MSAA role indicating that
     *  the object represents a table
     *  containing rows and columns of cells,
     *  and optionally, row headers and column headers.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_TABLE:uint = 0x18;

    /**
     *  An MSAA role indicating that
     *  the object represents a column header,
     *  providing a visual label for a column in a table.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_COLUMNHEADER:uint = 0x19;

    /**
     *  An MSAA role indicating that
     *  the object represents a row header,
     *  providing a visual label for a table row.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_ROWHEADER:uint = 0x1A;

    /**
     *  An MSAA role indicating that
     *  the object represents a column of cells within a table.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_COLUMN:uint = 0x1B;

    /**
     *  An MSAA role indicating that
     *  the object represents a row of cells within a table.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_ROW:uint = 0x1C;

    /**
     *  An MSAA role indicating that
     *  the object represents a cell within a table.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_CELL:uint = 0x1D;

    /**
     *  An MSAA role indicating that
     *  the object represents a link to something else.
     *
     *  <p>This object might look like text or a graphic,
     *  but it acts like a button.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_LINK:uint = 0x1E;

    /**
     *  An MSAA role indicating that
     *  the object displays help in the form of a ToolTip or help balloon.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_HELPBALLOON:uint = 0x1F;

    /**
     *  An MSAA role indicating that
     *  the object represents a cartoon-like graphic object,
     *  such as Microsoft Office Assistant, which is typically displayed
     *  to provide help to users of an application.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_CHARACTER:uint = 0x20;

    /**
     *  An MSAA role indicating that
     *  the object represents a list box, 
     *  allowing the user to select one or more items.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_LIST:uint = 0x21;

    /**
     *  An MSAA role indicating that
     *  the object represents an item in a list box
     *  or the list portion of a combo box,
     *  drop-down list box, or drop-down combo box.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_LISTITEM:uint = 0x22;

    /**
     *  An MSAA role indicating that
     *  the object represents an outline or tree structure,
     *  such as a tree view control, which displays a hierarchical list
     *  and usually allows the user to expand and collapse branches.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_OUTLINE:uint = 0x23;

    /**
     *  An MSAA role indicating that
     *  the object represents an item in an outline or tree structure.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_OUTLINEITEM:uint = 0x24;

    /**
     *  An MSAA role indicating that
     *  the object represents a page tab.
     *  Normally the only child of a page tab control
     *  is a ROLE_SYSTEM_GROUPING object
     *  that contains the contents of the associated page.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_PAGETAB:uint = 0x25;

    /**
     *  An MSAA role indicating that
     *  the object represents a property sheet.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_PROPERTYPAGE:uint = 0x26;

    /**
     *  An MSAA role indicating that
     *  the object represents an indicator
     *  such as a pointer graphic that points to the current item.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_INDICATOR:uint = 0x27;

    /**
     *  An MSAA role indicating that
     *  the object represents a picture.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_GRAPHIC:uint = 0x28;

    /**
     *  An MSAA role indicating that
     *  the object represents read-only text
     *  such as labels for other controls or instructions in a dialog box.
     *
     *  <p>Static text cannot be modified or selected.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_STATICTEXT:uint = 0x29;

    /**
     *  An MSAA role indicating that
     *  the object represents selectable text
     *  that can be editable or read-only.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_TEXT:uint = 0x2A;

    /**
     *  An MSAA role indicating that
     *  the object represents a push button control.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_PUSHBUTTON:uint = 0x2B;

    /**
     *  An MSAA role indicating that
     *  the object represents a check box control,
     *  an option that can be turned on or off independently of other options.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_CHECKBUTTON:uint = 0x2C;

    /**
     *  An MSAA role indicating that
     *  the object represents an option button
     *  (also called a radio button).
     *
     *  <p>It is one of a group of mutually exclusive options.
     *  All objects sharing a single parent that have this attribute
     *  are assumed to be part of single mutually exclusive group.
     *  You can use ROLE_SYSTEM_GROUPING objects to divide them
     *  into separate groups when necessary.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_RADIOBUTTON:uint = 0x2D;

    /**
     *  An MSAA role indicating that
     *  the object represents a combo box;
     *  that is, an edit control with an associated list box
     *  that provides a set of predefined choices.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_COMBOBOX:uint = 0x2E;

    /**
     *  An MSAA role indicating that
     *  the object represents a drop-down list box.
     *
     *  <p>It shows one item and allows the user to display and select
     *  another from a list of alternative values.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_DROPLIST:uint = 0x2F;

    /**
     *  An MSAA role indicating that
     *  the object represents a progress bar,
     *  dynamically showing the user the percent complete
     *  of an operation in progress.
     *
     *  <p>This control usually takes no user input.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_PROGRESSBAR:uint = 0x30;

    /**
     *  An MSAA role indicating that
     *  the object represents a dial or knob.
     *
     *  <p>This can also be a read-only object with like a speedometer.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_DIAL:uint = 0x31;

    /**
     *  An MSAA role indicating that
     *  the object represents a hot-key field that allows the user
     *  to enter a combination or sequence of keystrokes.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_HOTKEYFIELD:uint = 0x32;

    /**
     *  An MSAA role indicating that
     *  the object represents a slider,
     *  which allows the user to adjust a setting
     *  in given increments between minimum and maximum values.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_SLIDER:uint = 0x33;

    /**
     *  An MSAA role indicating that
     *  the object represents a spin box,
     *  which is a control that allows the user 
     *  to increment or decrement the value displayed
     *  in a separate "buddy" control associated with the spin box.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_SPINBUTTON:uint = 0x34;

    /**
     *  An MSAA role indicating that
     *  the object represents a graphical image used to diagram data.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_DIAGRAM:uint = 0x35;

    /**
     *  An MSAA role indicating that
     *  the object represents an animation control,
     *  which contains content that is changing over time,
     *  such as a control that displays a series of bitmap frames,
     *  like a film strip.
     *
     *  <p>Animation controls are usually displayed when files
     *  are being copied, or when some other time-consuming task
     *  is being performed.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_ANIMATION:uint = 0x36;

    /**
     *  An MSAA role indicating that
     *  the object represents a mathematical equation.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_EQUATION:uint = 0x37;

    /**
     *  An MSAA role indicating that
     *  the object represents a button that drops down a list of items.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_BUTTONDROPDOWN:uint = 0x38;

    /**
     *  An MSAA role indicating that
     *  the object represents a button that drops down a menu.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_BUTTONMENU:uint = 0x39;

    /**
     *  An MSAA role indicating that
     *  the object represents a button that drops down a grid.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_BUTTONDROPDOWNGRID:uint = 0x3A;

    /**
     *  An MSAA role indicating that
     *  the object represents blank space between other objects.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_WHITESPACE:uint = 0x3B;

    /**
     *  An MSAA role indicating that
     *  the object represents a container of page tab controls.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_PAGETABLIST:uint = 0x3C;

    /**
     *  An MSAA role indicating that
     *  the object represents a control that displays time.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_CLOCK:uint = 0x3D;

    /**
     *  An MSAA role indicating that
     *  the object represents a button on a toolbar that has a drop-down
     *  list icon directly adjacent to the button.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_SPLITBUTTON:uint = 0x3E;

    /**
     *  An MSAA role indicating that
     *  the object represents an edit control designed for an Internet
     *  Protocol (IP) address. The edit control is divided into sections
     *  for the different parts of the IP address.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_IPADDRESS:uint = 0x3F;

    /**
     *  An MSAA role indicating that
     *  the object represents items that navigate like an outline item.
     *  You can use the up and down arrows to move through the outline.
     *  However, instead of expanding and collapsing the menus by using
     *  left and right arrow keys, these menus expand or collapse when
     *  the space bar or enter key is pressed and the item has focus.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ROLE_SYSTEM_OUTLINEBUTTON:uint = 0x40;

    //--------------------------------------
    //  MSAA states
    //--------------------------------------

    /**
     *  A constant representing the absence of any MSAA state flags.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_NORMAL:uint = 0;

    /**
     *  An MSAA state flag indicating that the object is unavailable. 
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_UNAVAILABLE:uint = 0x1;

    /**
     *  An MSAA state flag indicating that the object is selected.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_SELECTED:uint = 0x2;

    /**
     *  An MSAA state flag indicating that the object
     *  currently has the keyboard focus.
     *
     *  <p>Do not confuse object focus with object selection.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_FOCUSED:uint = 0x4;

    /**
     *  An MSAA state flag indicating that the object is pressed.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_PRESSED:uint = 0x8;

    /**
     *  An MSAA state flag indicating that the object's check box is selected.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_CHECKED:uint = 0x10;

    /**
     *  An MSAA state flag indicating that the state of a three-state
     *  check box or toolbar button is not determined.
     *
     *  <p>The check box is neither checked nor unchecked
     *  and is therefore in the third or mixed state.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_MIXED:uint = 0x20;

    /**
     *  An MSAA state flag indicating that the object is read-only.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_READONLY:uint = 0x40;

    /**
     *  An MSAA state flag indicating that the object
     *  is currently hot-tracked by the mouse,
     *  meaning that its appearance has changed
     *  to indicate that the mouse pointer is located over it.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_HOTTRACKED:uint = 0x80;

    /**
     *  An MSAA state flag indicating the default button or menu item.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_DEFAULT:uint = 0x100;

    /**
     *  An MSAA state flag indicating that children of this object
     *  that have the ROLE_SYSTEM_OUTLINEITEM role are displayed.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_EXPANDED:uint = 0x200;

    /**
     *  An MSAA state flag indicating that children of this object
     *  that have the ROLE_SYSTEM_OUTLINEITEM role are hidden.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_COLLAPSED:uint = 0x400;

    /**
     *  An MSAA state flag indicating that the object
     *  cannot accept input at this time.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_BUSY:uint = 0x800;

    /**
     *  An MSAA state flag indicating that the object
     *  is not clipped to the boundary of its parent object
     *  and does not move automatically when the parent moves.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_FLOATING:uint = 0x1000;

    /**
     *  An MSAA state flag indicating that the object displays
     *  scrolling or moving text or graphics.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_MARQUEED:uint = 0x2000;

    /**
     *  An MSAA state flag indicating that the object's appearance
     *  is changing rapidly or constantly.
     *
     *  <p>Graphics that are occasionally animated, but not always,
     *  should be described as ROLE_SYSTEM_GRAPHIC
     *  with the State property set to STATE_SYSTEM_ANIMATED.
     *  This state should not be used to indicate
     *  that the object's location is changing.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_ANIMATED:uint = 0x4000;

    /**
     *  An MSAA state flag indicating that the object is hidden or not visible.
     *
     *  <p>A list of files names in a list box might contain
     *  several hundred names, but only a few are visible to the user.
     *  The rest are clipped by the parent
     *  and should have STATE_SYSTEM_INVISIBLE set.</p>
     *  <p>Objects that are never visible should be set as STATE_SYSTEM_OFFSCREEN.
     *  Note that an object can be considered visible
     *  (that is, the STATE_SYSTEM_INVISIBLE flag is not set)
     *  and yet be obscured by another application,
     *  so will not be visible to the user.
     *  For example, an object is considered visible
     *  if it appears in the main window of an application
     *  even though it is obscured by a dialog.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_INVISIBLE:uint = 0x8000;

    /**
     *  An MSAA state flag indicating that the object
     *  has no on-screen representation.
     *
     *  <p>A sound or alert object would have this state,
     *  or a hidden window that will never be made visible.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_OFFSCREEN:uint = 0x10000;

    /**
     *  An MSAA state flag indicating that the object can be resized.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_SIZEABLE:uint = 0x20000;

    /**
     *  An MSAA state flag indicating that the object can be moved.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_MOVEABLE:uint = 0x40000;

    /**
     *  An MSAA state flag indicating that the object
     *  can use text-to-speech (TTS) to describe itself.
     *
     *  <p>A speech-based accessibility aid should not announce information
     *  when an object with this state has the focus because the object
     *  will automatically announce information about itself.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_SELFVOICING:uint = 0x80000;

    /**
     *  An MSAA state flag indicating that the object is on the active window
     *  and can receive keyboard focus.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_FOCUSABLE:uint = 0x100000;

    /**
     *  An MSAA state flag indicating that the object can accept selection.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_SELECTABLE:uint = 0x200000;

    /**
     *  An MSAA state flag indicating that the object is linked.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_LINKED:uint = 0x400000;

    /**
     *  An MSAA state flag indicating that the object has been traversed.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_TRAVERSED:uint = 0x800000;

    /**
     *  An MSAA state flag indicating that the object
     *  can accept multiple selected items
     *  (that is, SELFLAG_ADDSELECTION for the IAccessible::accSelect
     *  method is valid).
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_MULTISELECTABLE:uint = 0x1000000;

    /**
     *  An MSAA state flag indicating that the object can extend its selection
     *  using SELFLAG_EXTENDSELECTION in the IAccessible::accSelect method.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_EXTSELECTABLE:uint = 0x2000000;

    /**
     *  An MSAA state flag indicating that the object displays
     *  low-priority information that may not be important to the user.
     *
     *  <p>This state could be used, for example, when Word changes
     *  the appearance of the TipWizard button on its toolbar
     *  to indicate that it has a hint for the user.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_ALERT_LOW:uint = 0x4000000;

    /**
     *  An MSAA state flag flaindicating that the object displays
     *  important information that does not need to be conveyed
     *  to the user immediately.
     *
     *  <p>For example, when a battery level indicator is starting
     *  to reach a low level, it could generate a medium-level alert.
     *  Blind access utilities could then generate a sound
     *  to let the user know that important information is available,
     *  without actually interrupting the user's work.
     *  The user could then query the alert information
     *  at his or her leisure.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_ALERT_MEDIUM:uint = 0x8000000;

    /**
     *  An MSAA state flag indicating that the object displays
     *  important information that should be conveyed to the user immediately.
     *
     *  <p>For example, a battery level indicator reaching a critical low level
     *  could transition to this state, in which case a blind access utility
     *  could announce this information immediately to the user,
     *  and a screen magnification program could scroll the screen
     *  so that the battery indicator is in view.
     *  This state is also appropriate for any prompt or operation
     *  that must be completed before the user can continue.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_ALERT_HIGH:uint = 0x10000000;

    /**
     *  An MSAA state flag indicating that the object
     *  is a password-protected edit control.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_PROTECTED:uint = 0x20000000;

    /**
     *  An MSAA state flag indicating that the object
     *  has a pop-up menu. (MSAA 2.0)
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_HASPOPUP:uint = 0x40000000;

    /**
     *  A bitmask representing all valid MSAA state flags.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const STATE_SYSTEM_VALID:uint = 0x7FFFFFFF;

    //--------------------------------------
    //  MSAA selection flags
    //--------------------------------------

    /**
     *  A constant representing the absence of any MSAA selection flags.
     */
    public static const SELFLAG_NONE:uint = 0;

    /**
     *  An MSAA selection flag that sets the focus to the object
     *  and makes it the selection anchor.
     *
     *  <p>Used by itself, this flag does not alter the selection,
     *  and its behavior is similar to moving the focus manually
     *  by pressing the arrow keys while holding down the CTRL key
     *  in Windows Explorer or in any multiple-selection list box.</p>
     *
     *  <p>With objects that have the state STATE_SYSTEM_MULTISELECTABLE,
     *  SELFLAG_TAKEFOCUS can be combined with the following values:
     *  <ul>
     *    <li>SELFLAG_TAKESELECTION</li>
     *    <li>SELFLAG_EXTENDSELECTION</li>
     *    <li>SELFLAG_ADDSELECTION</li>
     *    <li>SELFLAG_REMOVESELECTION</li>
     *    <li>SELFLAG_ADDSELECTION | SELFLAG_EXTENDSELECTION</li>
     *    <li>SELFLAG_REMOVESELECTION | SELFLAG_EXTENDSELECTION</li>
     *  </ul></p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const SELFLAG_TAKEFOCUS:uint = 0x1;

    /**
     *  An MSAA selection flag that selects the object
     *  and removes the selection from all other objects in the container.
     *
     *  <p>This flag does not change the focus or the selection anchor
     *  unless it is combined with SELFLAG_TAKEFOCUS.
     *  The behavior of SELFLAG_TAKESELECTION | SELFLAG_TAKEFOCUS
     *  is equivalent to single-clicking an item in Windows Explorer.</p>
     *
     *  <p>This flag must not be combined with the following flags:
     *  <ul>
     *    <li>SELFLAG_ADDSELECTION</li>
     *    <li>SELFLAG_REMOVESELECTION</li>
     *    <li>SELFLAG_EXTENDSELECTION</li>
     *  </ul></p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const SELFLAG_TAKESELECTION:uint = 0x2;

    /**
     *  An MSAA selection flag that alters the selection
     *  so that all objects between the selection anchor
     *  and this object take on the anchor object's selection state.
     *
     *  <p>That is, if the anchor object is not selected,
     *  the objects are removed from the selection;
     *  if the anchor object is selected,
     *  the selection is extended to include this object
     *  and all the objects in between.
     *  You can set the selection state by combining this flag with
     *  SELFLAG_ADDSELECTION or SELFLAG_REMOVESELECTION.</p>
     *
     *  <p>This flag does not change the focus or the selection anchor
     *  unless it is combined with SELFLAG_TAKEFOCUS.
     *  The behavior of SELFLAG_EXTENDSELECTION | SELFLAG_TAKEFOCUS
     *  is equivalent to addding an item to a selection manually
     *  by holding down the SHIFT key and clicking an unselected object
     *  in Windows Explorer.</p>
     *
     *  <p>This flag may not be combined with SELFLAG_TAKESELECTION.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const SELFLAG_EXTENDSELECTION:uint = 0x4;

    /**
     *  An MSAA selection flag that adds the object to the current selection,
     *  possibly resulting in a noncontiguous selection.
     *
     *  <p>This flag does not change the focus or the selection anchor
     *  unless it is combined with SELFLAG_TAKEFOCUS.
     *  The behavior of SELFLAG_ADDSELECTION | SELFLAG_TAKEFOCUS
     *  is equivalent to adding an item to a selection manually
     *  by holding down the CTRL key and clicking an unselected object
     *  in Windows Explorer.</p>
     *
     *  <p>This flag may not be combined with SELFLAG_REMOVESELECTION
     *  or with SELFLAG_TAKESELECTION.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const SELFLAG_ADDSELECTION:uint = 0x8;

    /**
     *  An MSAA selection flag that removes the object from the current
     *  selection, possibly resulting in a noncontiguous selection.
     *
     *  <p>This flag does not change the focus or the selection anchor
     *  unless it is combined with SELFLAG_TAKEFOCUS.
     *  The behavior of SELFLAG_REMOVESELECTION | SELFLAG_TAKEFOCUS
     *  is equivalent to removing an item from a selection manually
     *  by holding down the CTRL key while clicking a selected object
     *  in Windows Explorer.</p>
     *
     *  <p>This flag may not be combined with SELFLAG_ADDSELECTION
     *  or with SELFLAG_TAKESELECTION.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const SELFLAG_REMOVESELECTION:uint = 0x10;

    /**
     *  A bitmask representing all valid MSAA selection flags.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const SELFLAG_VALID:uint = 0x1F;

    //--------------------------------------
    //  MSAA system events
    //--------------------------------------

    /**
     *  An MSAA event indicating that a sound was played.
     *
     *  <p>The system sends this event when a system sound
     *  (such as for menus) is played even if no sound is audible
     *  (for example, lack of a sound file or sound card).
     *  MSAA server applications send this event
     *  if a custom user interface element generates a sound.</p> 
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_SOUND:uint = 0x0001;

    /**
     *  An MSAA event indicating that an alert was generated.
     *
     *  <p>MSAA server applications send this event
     *  whenever an important user interface change has occurred
     *  that a user might need to know about.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_ALERT:uint = 0x0002;

    /**
     *  An MSAA event indicating that the foreground window changed.
     *
     *  <p>The system sends this event even if the foreground window
     *  is changed to another window in the same thread.
     *  MSAA server applications never send this event.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_FOREGROUND:uint = 0x0003;

    /**
     *  An MSAA event indicating that a menu item on the menu bar was selected.
     *
     *  <p>The system sends this event for standard menus.
     *  MSAA server applications send this event for custom menus
     *  (user interface elements that function as menus
     *  but are not created in the standard way).
     *  The system may trigger more than one EVENT_SYSTEM_MENUSTART event
     *  that may or may not have a corresponding EVENT_SYSTEM_MENUEND event.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_MENUSTART:uint = 0x0004;

    /**
     *  An MSAA event indicating that a menu from the menu bar was closed.
     *
     *  <p>The system sends this event for standard menus.
     *  MSAA server applications send this event for custom menus.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_MENUEND:uint = 0x0005;

    /**
     *  An MSAA event indicating that a pop-up menu was displayed.
     *
     *  <p>The system sends this event for standard menus.
     *  MSAA servers applications send this event for custom menus
     *  (user interface elements that function as menus
     *  but are not created in the standard way).</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_MENUPOPUPSTART:uint = 0x0006;

    /**
     *  An MSAA event indicating that a pop-up menu was closed.
     *
     *  <p>The system sends this event for standard menus.
     *  MSAA server appolications send this event for custom menus.
     *  When a pop-up menu is closed, the client receives this message
     *  followed almost immediately by the EVENT_SYSTEM_MENUEND event.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_MENUPOPUPEND:uint = 0x0007;

    /**
     *  An MSAA event indicating that a window has received mouse capture.
     *
     *  <p>This event is sent by the system;
     *  MSAA server applications never send this event.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_CAPTURESTART:uint = 0x0008;

    /**
     *  An MSAA event indicating that a window has lost mouse capture.
     *
     *  <p>This event is sent by the system;
     *  MSAA server applications never send this event.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_CAPTUREEND:uint = 0x0009;

    /**
     *  An MSAA event indicating that a window is being moved or resized.
     *
     *  <p>This event is sent by the system;
     *  MSAA server applications never send this event.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_MOVESIZESTART:uint = 0x000A;

    /**
     *  An MSAA event indicating that the movement or resizing
     *  of a window is finished.
     *
     *  <p>This event is sent by the system;
     *  MSAA server applications never send this event.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_MOVESIZEEND:uint = 0x000B;

    /**
     *  An MSAA event indicating that a window
     *  entered context-sensitive Help mode.
     */
    public static const EVENT_SYSTEM_CONTEXTHELPSTART:uint = 0x000C;

    /**
     *  An MSAA event indicating that a window
     *  exited context-sensitive Help mode.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_CONTEXTHELPEND:uint = 0x000D;

    /**
     *  An MSAA event indicating that an application
     *  is about to enter drag-and-drop mode.
     *
     *  <p>Applications that support drag-and-drop operations
     *  must send this event; the system does not.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_DRAGDROPSTART:uint = 0x000E;

    /**
     *  An MSAA event indicating that an application
     *  is about to exit drag-and-drop mode.
     *
     *  <p>Applications that support drag-and-drop operations
     *  must send this event; the system does not.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_DRAGDROPEND:uint = 0x000F;

    /**
     *  An MSAA event indicating that a dialog box was displayed.
     *
     *  <p>This event is sent by the system for standard dialog boxes.
     *  MSAA server applications send this event for custom dialog boxes
     *  (windows that function as dialog boxes
     *  but are not created in the standard way).</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_DIALOGSTART:uint = 0x0010;

    /**
     *  An MSAA event indicating that a dialog box was closed.
     *
     *  <p>This event is sent by the system for standard dialog boxes.
     *  MSAA server applications send this event for custom dialog boxes.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_DIALOGEND:uint = 0x0011;

    /**
     *  An MSAA event indicating that scrolling has started on a scroll bar.
     *
     *  <p>This event is sent by the system for scroll bars
     *  attached to a window and for standard scroll bar controls.
     *  MSAA server applications send this event for custom scroll bars
     *  (user interface elements that function as scroll bars
     *  but are not created in the standard way).</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_SCROLLINGSTART:uint = 0x0012;

    /**
     *  An MSAA event indicating that scrolling has ended on a scroll bar.
     *
     *  <p>This event is sent by the system for scroll bars attached
     *  to a window and for standard scroll bar controls.
     *  MSAA server applications send this event for custom scroll bars.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_SCROLLINGEND:uint = 0x0013;

    /**
     *  An MSAA event indicating that the user pressed ALT+TAB,
     *  which activates the switch window.
     *
     *  <p>This event is sent by the system;
     *  MSAA server applications never send this event.
     *  If only one application is running when the user presses ALT+TAB,
     *  the system sends an EVENT_SYSTEM_SWITCHEND event
     *  without a corresponding EVENT_SYSTEM_SWITCHSTART event.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_SWITCHSTART:uint = 0x0014;

    /**
     *  An MSAA event indicating that the user released ALT+TAB.
     *
     *  <p>This event is sent by the system;
     *  MSAA server applications never send this event.
     *  If only one application is running when the user presses ALT+TAB,
     *  the system sends this event without a corresponding
     *  EVENT_SYSTEM_SWITCHSTART event.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_SWITCHEND:uint = 0x0015;

    /**
     *  An MSAA event indicating that a window object
     *  is about to be minimized or maximized.
     *
     *  <p>This event is sent by the system;
     *  MSAA server applications never send this event.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_MINIMIZESTART:uint = 0x0016

    /**
     *  An MSAA event indicating that a window object
     *  was minimized or maximized.
     *
     *  <p>This event is sent by the system;
     *  MSAA server applications never send this event.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_SYSTEM_MINIMIZEEND:uint = 0x0017;

    //--------------------------------------
    //  MSAA object events
    //--------------------------------------

    /**
     *  An MSAA event indicating that an object was created.
     *
     *  <p>The system sends this event for the following user interface
     *  elements: caret, header control, list view control, tab control,
     *  toolbar control, tree view control, and window object.
     *  MSAA server applications send this event for their accessible objects.  
     *  Servers must send this event for all of an object's child objects
     *  before sending the event for the parent object.
     *  Servers must ensure that all child objects are fully created
     *  and ready to accept IAccessible calls from clients
     *  when the parent object sends this event.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_CREATE:uint = 0x8000;

    /**
     *  An MSAA event indicating that an object was destroyed.
     *
     *  <p>The system sends this event for the following user interface
     *  elements: caret, header control, list view control, tab control,
     *  toolbar control, tree view control, and window object.
     *  MSAA server applications send this event for their accessible objects. 
     *  This event may or may not be sent for child objects.
     *  However, clients can assume that all the children of an object
     *  have been destroyed when the parent object sends this event.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_DESTROY:uint = 0x8001;

    /**
     *  An MSAA event indicating that a hidden object is being shown.
     *
     *  <p>The system sends this event for the following user interface
     *  elements: caret, cursor, and window object.
     *  MSAA server applications send this event for their accessible objects.
     *  Clients can assume that when this event is sent by a parent object,
     *  all child objects have already been displayed.
     *  Therefore, server applications do not need to send this event
     *  for the child objects.   
     *  Hidden objects include the STATE_SYSTEM_INVISIBLE flag
     *  and shown objects do not.
     *  The EVENT_OBJECT_SHOW event also indicates
     *  that the STATE_SYSTEM_INVISIBLE flag has been cleared.
     *  Therefore, servers do not need to send the EVENT_STATE_CHANGE event
     *  in this case.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_SHOW:uint = 0x8002;

    /**
     *  An MSAA event indicating that an object is being hidden.
     *
     *  <p>The system sends this event for the following user interface
     *  elements: caret and cursor.
     *  MSAA server applications send this event for their accessible objects.
     *  When this event is generated for a parent object,
     *  all child objects have already been hidden.
     *  Therefore, server applications do not need to send this event
     *  for the child objects.   
     *  Hidden objects include the STATE_SYSTEM_INVISIBLE flag
     *  and shown objects do not.
     *  The EVENT_OBJECT_HIDE event also indicates
     *  that the STATE_SYSTEM_INVISIBLE flag has been set.
     *  Therefore, servers do not need to send the EVENT_STATE_CHANGE event
     *  in this case.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_HIDE:uint = 0x8003;

    /**
     *  An MSAA event indicating that a container object
     *  has added, removed, or reordered its children.
     *
     *  <p>The system sends this event for the following user interface
     *  elements: header control, list view control, toolbar control,
     *  and window object.
     *  MSAA server applications send this event
     *  as appropriate for their accessible objects.
     *  For example, this event is generated by a list view object
     *  when the number of child elements or the order of the elements changes.
     *  This event is also sent by a parent window when the z order
     *  for the child windows has changed.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_REORDER:uint = 0x8004;

    /**
     *  An MSAA event indicating that an object has received the keyboard focus.
     *
     *  <p>The system sends this event for the following user interface
     *  elements: list view control, menu bar, pop-up menu, switch window,
     *  tab control, tree view control, and window object.
     *  MSAA server applications send this event
     *  for their accessible objects.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_FOCUS:uint = 0x8005;

    /**
     *  An MSAA event indicating that the selection
     *  within a container object changed.
     *
     *  <p>The system sends this event for the following user interface
     *  elements: list view control, tab control, tree view control,
     *  and window object.
     *  MSAA server applications send this event for their accessible objects.
     *  This event signals a single selection -- either a child has been
     *  selected in a container that previously did not contain any selected
     *  children or the selection has changed from one child to another.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_SELECTION:uint = 0x8006;

    /**
     *  An MSAA event indicating that an item within a container object
     *  was added to the selection.
     *
     *  <p>The system sends this event for the following user interface
     *  elements: list box, list view control, and tree view control.
     *  MSAA server applications send this event for their accessible objects.
     *  This event signals that a child has been added
     *  to an existing selection.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_SELECTIONADD:uint = 0x8007;

    /**
     *  An MSAA event indicating that an item within a container object
     *  was removed from the selection.
     *
     *  <p>The system sends this event for the following user interface
     *  elements: list box, list view control, and tree view control.
     *  MSAA server applications send this event for their accessible objects.
     *  This event signals that a child has been removed
     *  from an existing selection.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_SELECTIONREMOVE:uint = 0x8008;

    /**
     *  An MSAA event indicating that numerous selection changes
     *  occurred within a container object.
     *
     *  <p>The system sends this event for list boxes.
     *  MSAA server applications send this event for their accessible objects.
     *  This event may be sent when the selected items within a control
     *  have changed substantially.
     *  This event informs the client that many selection changes have occurred
     *  (instead of sending several EVENT_OBJECT_SELECTIONADD
     *  or EVENT_OBJECT_SELECTIONREMOVE events).
     *  The client can query for the selected items by calling the container
     *  object's IAccessible::get_accSelection method and enumerating the
     *  selected items.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_SELECTIONWITHIN:uint = 0x8009;

    /**
     *  An MSAA event indicating that an object's state has changed.
     *
     *  <p>The system sends this event for the following user interface
     *  elements: check box, combo box, header control, push button,
     *  radio button, scroll bar, toolbar control, tree view control,
     *  up-down control, and window object.
     *  MSAA server applications send this event for their accessible objects.
     *  For example, a state change can occur when a button object
     *  has been pressed or released, or when an object is being
     *  enabled or disabled.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_STATECHANGE:uint = 0x800A;

    /**
     *  An MSAA event indicating that an object has changed
     *  location, shape, or size.
     *
     *  <p>The system sends this event for the following user interface
     *  elements: caret and window object.
     *  MSAA server applications send this event for their accessible objects.
     *  This event is generated in response to the top-level object
     *  within the object hierarchy that has changed,
     *  not for any children it might contain.
     *  For example, if the user resizes a window,
     *  the system sends this notification for the window,
     *  but not for the menu bar, title bar, scroll bars,
     *  or other objects that have also changed. 
     *  The system does not send this event for every non-floating
     *  child window when the parent moves.
     *  However, if an application explicitly resizes child windows
     *  as a result of being resized itself,
     *  the system will send multiple events for the resized children. 
     *  If an object's State property is set to STATE_SYSTEM_FLOATING,
     *  servers should send EVENT_OBJECT_LOCATIONCHANGE
     *  whenever the object changes location.
     *  If an object does not have this state,
     *  servers should only trigger this event
     *  when the object moves relative to its parent.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_LOCATIONCHANGE:uint = 0x800B;

    /**
     *  An MSAA event indicating that an object's MSAA Name property changed.
     *
     *  <p>The system sends this event for the following user interface
     *  elements: check box, cursor, list view control, push button,
     *  radio button, status bar control, tree view control, and window object.
     *  MSAA server applications send this event
     *  for their accessible objects.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_NAMECHANGE:uint = 0x800C;

    /**
     *  An MSAA event indicating that an object's
     *  MSAA Description property changed.
     *
     *  <p>MSAA server applications send this event
     *  for their accessible objects.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_DESCRIPTIONCHANGE:uint = 0x800D;

    /**
     *  An MSAA event indicating that an object's MSAA Value property changed.
     *
     *  <p>The system sends this event for the following user interface
     *  elements: edit control, header control, hot key control,
     *  progress bar control, scroll bar, slider control, and up-down control.
     *  MSAA server applications send this event
     *  for their accessible objects.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_VALUECHANGE:uint = 0x800E;

    /**
     *  An MSAA event indicating that an object has a new parent object.
     *
     *  <p>MSAA server applications send this event
     *  for their accessible objects.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_PARENTCHANGE:uint = 0x800F;

    /**
     *  An MSAA event indicating that an object's MSAA Help property changed.
     *
     *  <p>MSAA server applications send this event
     *  for their accessible objects.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_HELPCHANGE:uint = 0x8010;

    /**
     *  An MSAA event indicating that an object's
     *  MSAA DefaultAction property changed.
     *
     *  <p>The system sends this event for dialog boxes.
     *  MSAA server applications send this event
     *  for their accessible objects.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_DEFACTIONCHANGE:uint = 0x8011;

    /**
     *  An MSAA event indicating that an object's
     *  MSAA KeyboardShortcut property changed.
     *
     *  <p>MSAA server applications send this event
     *  for their accessible objects.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_ACCELERATORCHANGE:uint = 0x8012;

    /**
     *  An MSAA event indicating that an object has been invoked;
     *  for example, the user has clicked a button. (MSAA 2.0)
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_INVOKED:uint = 0x8013;

    /**
     *  An MSAA event indicating that an object's text selection has changed.
     *  (MSAA 2.0)
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_TEXTSELECTIONCHANGED:uint = 0x8014;

    /**
     *  An MSAA event indicating that the scrolling of a window object
     *  has ended. (MSAA 2.0)
     *
     *  <p>Unlike the similar event (EVENT_SYSTEM_SCROLLEND),
     *  this event will be associated with the scrolling window itself.
     *  There is no difference between horizontal or vertical scrolling.</p>
     *
     *  <p>This event should be posted whenever scroll action is completed,
     *  including when it is scrolled by scroll bars, mouse wheel,
     *  or keyboard navigations.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const EVENT_OBJECT_CONTENTSCROLLED:uint = 0x8015;

}

}

