import structs/LinkedList
import structs/HashMap
import Types
import Renderer
import EventHandler
import Popup
import Window
import Drawable
import Font

/**
    Base class for all views in NUIT.
    
    Views
    =====
    brief overview of what exactly a view is
    
    View Hierarchy
    ==============
    brief overview of how the view hierarchy works
    
    Event Handling
    ==============
    explain how events are propagated/handled
    
    Drawing
    =======
    explain how to draw views
*/
NView: class {
    /** The GUI instance the view uses */
    _gui: NGUI
    
    /** The name of the view */
    _name: String = ""
    
    /** A tag object associated with the view */
    _tag: Object = null
    
    /** An ID number associated with the view */
    _id: Int = 0
    
    /** The view's superview/parent view */
    _superview: NView = null
    
    /** A list of subviews contained by the view */
    subviews := LinkedList<NView> new()
    
    /** The view's frame */
    _frame: NRect
    
    /** The minimum size of the view */
    _min_size: NSize
    
    /** Flag to switch on/off use of the minimum size */
    _has_min_size := false
    
    /** The maximum size of the view */
    _max_size: NSize
    
    /** Flag to switch on/off use of the maximum size */
    _has_max_size := false
    
    /** Flag to disable/enable the view (prevents input receipt) */
    _disabled := false
    
    /** Flag to hide/show the view (prevents drawing and input receipt) */
    _hidden := false
    
    /** A map of event handlers attached to the view */
    _eventhandlers := HashMap<String, LinkedList<NEventHandler>> new(16)
    
    /** The font used by the view - do not access this directly when drawing */
    _font: NFont = null
    
    /**
        The drawable used by the view - do not access this directly when
        drawing.
    */
    _drawable: NDrawable = null
    
    /** The top-left corner of the view's bounds */
    _bounds_topLeft: NSize
    
    /** The bottom-right corner of the view's bounds */
    _bounds_bottomRight: NSize

//////// Initializers
    
    /** Initializes the view its GUI instance and a frame */
    init: func (=_gui, frame: NRect) {
        if (_gui == null)
            Exception new(This, "Cannot initialize a view without an NGUI instance") throw()
        
        setFrame(frame)
    }
    
//////// Basic properties

    /** Get the name of the view */
    name: func -> String { _name clone() }
    
    /** Set the name of the view */
    setName: func (name: String) {
        _name = name clone()
    }
    
    /** Get the view's ID number */
    id: func -> Int { _id }
    
    /** Set the view's ID number */
    setID: func (=_id) {}
    
    /** Get the size of the view's frame */
    size: final func -> NSize {
        frame() size
    }
    
    /** Get the origin of the view's frame */
    origin: final func -> NPoint {
        frame() origin
    }
    
    /** Get the view's frame */
    frame: func -> NRect {
        _frame
    }
    
    /** Set the view's frame */
    setFrame: func (frame: NRect) {
        if (_has_min_size)
            frame size = NSize max(frame size, _min_size)
        if (_has_max_size)
            frame size = NSize min(frame size, _max_size)
        _frame = frame
    }
    
    /**
        Get the view's bounds
    */
    bounds: func -> NRect {
        bnds := size() toRect()
        bnds origin = _bounds_topLeft toPoint()
        bnds size subtract(_bounds_topLeft)
        bnds size subtract(_bounds_bottomRight)
        return bnds
    }
    
    setBounds: func (=_bounds_topLeft, =_bounds_bottomRight) {}
    
    setBounds: final func ~withRect (rect: NRect) {
        size := size()
        topLeft := NSize new(rect left(), rect top())
        bottomRight := NSize new(size width - rect left(), size height - rect bottom())
        setBounds(topLeft, bottomRight)
    }
    
    }
    
    /**
        Get whether or not the view is hidden.
    */
    hidden?: func -> Bool { hidden?(true) }
    
    /**
        Get whether or not the view is hidden.
        
        If :param:`recurse` is true, it will check superviews to see if any of
        them are hidden as well, returning true if any superview isn't visible.
    */
    hidden?: func ~recursive (recurse: Bool) -> Bool {
        hidden := _hidden
        if (!hidden && recurse) {
            sv := superview()
            while (!hidden && sv) {
                hidden = sv hidden?(false)
                sv = sv superview()
            }
        }
        return hidden
    }
    
    /**
        Set whether or not the view is hidden.
        
        Hidden views do not receive events and, of course, are not drawn.
    */
    setHidden: func (=_hidden) {}
    
    /**
        Makes the view hidden.  This is the same as calling `setHidden(true)`,
        and is provided mainly for convenience.
    */
    hide: final func { setHidden(true) }
    
    /**
        Makes the view visible.  This is the same as calling `setHidden(false)`,
        and is provided mainly for convenience.
    */
    show: final func { setHidden(false) }
    
    /**
        Get whether or not the view is disabled.
    */
    disabled?: func -> Bool { disabled?(false) }
    
    /**
        Get whether or not the view is disabled.
        
        If :param:`recurse` is true, it will check superviews to see if any of
        them are disabled as well, returning true if any superview is disabled.
    */
    disabled?: func ~recursive (recurse: Bool) -> Bool {
        disabled := _disabled
        if (!disabled && recurse) {
            sv := superview()
            while (!disabled && sv) {
                disabled = sv disabled?(false)
                sv = sv superview()
            }
        }
        return disabled
    }
    
    /**
        Set whether or not the view is disabled.
        
        Disabled views do not receive events, but are drawn.
    */
    setDisabled: func (=_disabled) {}
    
    /**
        Makes the view disabled.  This is the same as calling
        `setDisabled(true)`, and is provided mainly for convenience.
    */
    disable: final func { setDisabled(true) }
    
    /**
        Makes the view enabled.  This is the same as calling
        `setDisabled(false)`, and is provided mainly for convenience.
    */
    enable: final func { setDisabled(false) }
    
//////// Layout

    /**
        Performs layout on subviews where necessary.
        
        The default implementation does nothing.
    */
    performLayout: func {}
    
    /** Returns the min size of the view */
    minSize: func -> NSize { _min_size }
    
    /** Sets the min size of the view */
    setMinSize: func (min_size: NSize) {
        _min_size = NSize max(NSize zero(), min_size)
    }
    
    /** Returns the max size of the view */
    maxSize: func -> NSize { _max_size }
    
    /** Sets the max size of the view */
    setMaxSize: func (max_size: NSize) {
        _max_size = NSize max(NSize zero(), max_size)
    }
    
    /** Returns whether or not a min size is used */
    minSizeEnabled: func -> Bool { _has_min_size }
    
    /** Sets whether or not a min size is used */
    setMinSizeEnabled: func (=_has_min_size) {}
    
    /** Returns whether or not a min size is used */
    maxSizeEnabled: func -> Bool { _has_max_size }
    
    /** Sets whether or not a min size is used */
    setMaxSizeEnabled: func (=_has_max_size) {}
    
    /**
        Returns whether or not this view clips its subviews inside its bounds.
        
        NOTE: The exact reasons for how this is determined are somewhat iffy,
        but essentially, a view that clips subviews will 1) be clipped itself
        to its frame and 2) its subviews will be clipped to its bounds.
        
        This may change later on down the road, and it is recommended that you
        simply do not attempt to change this from its default value.
    */
    clipsSubviews: func -> Bool { true }


//////// View hierarchy

    /**
        Find a subview with the given name.  Passing `true` to :param:`recurse`
        results in :func:`findSubviewWithName` being called for subviews as
        well.
        
        :return: Returns the first view with the given :param:`name`, or null
        if none is found.
    */
    findSubviewWithName: func (name: String, recurse: Bool) -> NView {
        iterator := subviews iterator()
        
        if (recurse) {
            subview: NView = null
            
            while (subview == null && iterator hasNext()) {
                subview = iterator next()
            
                if (subview name() == name) {
                    return subview
                }
            
                subview = subview findSubviewWithName(name, true)
            }
            
            return subview
        } else {
            while (iterator hasNext()) {
                view := iterator next()
                if (view name() == name) {
                    return view
                }
            }
        }
        
        return null
    }
    
    /** Find a subview with the given ID */
    findSubviewWithName: func ~noRecurse (name: String) -> NView {
        findSubviewWithName(name, false)
    }
    
    /**
        Find a subview with the given ID.  Passing `true` to :param:`recurse`
        results in :func:`findSubviewWithID` being called for subviews as well.
        
        :return: Returns the first view with the given :param:`id`, or null if
        none is found.
    */
    findSubviewWithID: func (id: Int, recurse: Bool) -> NView {
        iterator := subviews iterator()
        
        if (recurse) {
            subview: NView = null
            
            while (subview == null && iterator hasNext()) {
                subview = iterator next()
            
                if (subview id() == id) {
                    return subview
                }
            
                subview = subview findSubviewWithID(id, true)
            }
            
            return subview
        } else {
            while (iterator hasNext()) {
                view := iterator next()
                if (view id() == id) {
                    return view
                }
            }
        }
        
        return null
    }
    
    /** Find a subview with the given :param:`id` */
    findSubviewWithID: func ~noRecurse (id: Int) -> NView {
        findSubviewWithID(id, false)
    }
    
    
    isSubviewOf: func (view: NView) -> Bool {
        sv := superview()
        while (sv != null) {
            if (sv == view)
                return true
            sv = sv superview()
        }
        return false
    }
    
    
    /** Adds a view as a subview to this view's hierarchy */
    addSubview: func (view: NView) {
        if (view superview() != null)
            Exception new(This, "Cannot add a subview that already has a superview") throw()
        
        subviews add(view)
        view _superview = this
    }
    
    /** Removes this view from its superview's hierarchy */
    removeFromSuperview: final func {
        if (_superview == null)
            Exception new(This, "View does not have a superview") throw()
        
        sv := _superview
        _superview = null
        sv subviews remove(this)
        sv subviewWasRemoved(this)
    }
    
    /** Notifies the view that one of its subviews has been removed */
    subviewWasRemoved: func (subview: NView) {}
    
    /** Returns a LinkedList with all of the subviews of this view. */
    subviews: final func -> LinkedList<NView> { subviews clone() }
    
    /** Returns the view's superview */
    superview: final func -> NView { _superview }
    
    /** Returns the root view of this view's hierarchy */
    root: func -> NView {
        rv := this
        while (rv superview() != null)
            rv = rv superview()
        return rv
    }
    
    /**
        Returns the view's window.
        
        If the view in question is a root window, this will return null.  If
        the view is a subwindow, the superwindow is returned.
    */
    window: func -> NWindow {
        sv := superview()
        while (sv) {
            if (sv instanceOf(NWindow))
                return sv as NWindow
            sv = sv superview()
        }
        return null
    }

//////// Working with view coordinates
    
    /**
        Converts a :param:`point` from a given :param:`view`'s coordinate
        system to this view's and returns the result.
        
        :param: view The view to convert the point from.
    */
    convertPointFromView: func (point: NPoint, view: NView) -> NPoint {
        convertPointFromScreen(view convertPointToScreen(point))
    }
    
    /**
        Converts a :param:`point` from this view's coordinate system to another
        :param:`view`'s and returns the result.
        
        :param: view The view to convert the point to.
    */
    convertPointToView: func (point: NPoint, view: NView) -> NPoint {
        convertPointToScreen(view convertPointFromScreen(point))
    }
    
    /**
        Converts a :param:`point` from the view's frame to screen (or whatever
        the coordinates are in prior to being in a frame) coordinates and
        returns the resulting point.
    */
    convertPointToScreen: func (point: NPoint) -> NPoint {
        point add(frame() origin)
        sv := superview()
        while (sv != null) {
            point add(sv bounds() origin)
            point add(sv frame() origin)
            sv = sv superview()
        }
        return point
    }
    
    /**
        Converts a :param:`point` from screen coordinates so that they are
        relative to the view's frame.
    */
    convertPointFromScreen: func (point: NPoint) -> NPoint {
        point subtract(frame() origin)
        sv := superview()
        while (sv != null) {
            point subtract(sv frame() origin)
            point subtract(sv bounds() origin)
            sv = sv superview()
        }
        return point
    }
    
    /**
        Returns a view at the :param:`point` specified, including this view,
        or null if there are no views in the view hierarchy that contain the
        point.
        
        The point is assumed to be in the view's coordinate system already.
    */
    viewForPoint: func (point: NPoint) -> NView {
        last := subviews backIterator()
        
        sansBounds := point
        sansBounds subtract(bounds() origin)
        
        while (last hasPrev()) {
            subview := last prev()
            
            if (subview hidden?(false))
                continue
            
            trpoint := sansBounds
            trpoint subtract(subview frame() origin)
            
            subview = subview viewForPoint(trpoint)
            if (subview) {
                if (subview instanceOf(NWindow) || subview instanceOf(NPopup))
                    return subview
                
                inter := subview frame()
                inter origin add(bounds() origin)
                inter = bounds() intersection(inter)
                if (inter contains(point))
                    return subview
            }
        }
        
        if (size() contains(point))
            return this
        
        return null
    }

//////// Drawing routines

    /**
        Draws the view using the renderer provided.
        
        By default, does nothing.
    */
    draw: func (renderer: NRenderer) {}
    
    /**
        Draws all of a view's subviews.
        
        Internal use only.
    */
    drawSubwindows: func (renderer: NRenderer) {
        renderer setClippingRegion(NRect new(NPoint zero(), renderer screenSize()))
        renderer disableClipping()
        renderer translateDrawingOrigin(bounds() origin)
        
        iter := subviews backward()
        while (iter hasNext()) {
            subview := iter next()
            
            // this is bad practice, but it works
            if (subview hidden?(false) || subview instanceOf(NPopup))
                continue
            
            if (subview instanceOf(NWindow)) {
                
                renderer saveState()
                renderer translateDrawingOrigin(subview origin())
                
                renderer saveState()
                subview draw(renderer)
                renderer restoreState()
                
                if (subview clipsSubviews()) {
                    clip := subview bounds()
                    clip origin = subview convertPointToScreen(clip origin)
                    renderer clipRegion(clip)
                    renderer enableClipping()
                }
                
                subview drawSubviews(renderer)
            
                renderer restoreState()
            }
            
            renderer saveState()
            subview drawSubwindows(renderer)
            renderer restoreState()
        }
    }
    
    /**
        Draws all of a view's subviews.
        
        Internal use only.
    */
    drawSubviews: func (renderer: NRenderer) {
        renderer translateDrawingOrigin(bounds() origin)
        
        if (clipsSubviews()) {
            clip := bounds()
            clip origin = renderer drawingOrigin()
            
            renderer enableClipping()
            renderer clipRegion(clip)
        }
        
        iter := subviews backward()
        while (iter hasNext()) {
            subview := iter next()
            drawSubview(renderer, subview)
        }
    }
    
    /**
        Draws a specific subview
    */
    drawSubview: func (renderer: NRenderer, subview: NView) {
        // this is bad practice, but it works
        if (subview hidden?(false) || subview instanceOf(NWindow) || subview instanceOf(NPopup))
            return
        
        renderer saveState()
        
        _clipSubview(subview, renderer)
        renderer saveState()
        subview draw(renderer)
        renderer restoreState()
        
        if (subview clipsSubviews()) {
            clip := subview bounds()
            clip origin = subview convertPointToScreen(clip origin)
            renderer enableClipping()
            renderer clipRegion(clip)
        }
        
        subview drawSubviews(renderer)
        
        renderer restoreState()
    }
    
    /**
        Clips rendering to a subview's frame
    */
    _clipSubview: func (subview: NView, renderer: NRenderer) {
        origin := subview convertPointToScreen(NPoint zero())
        renderer translateDrawingOrigin(subview origin())
        
        if (subview clipsSubviews()) {
            renderer enableClipping()
            renderer clipRegion(NRect new(renderer drawingOrigin(), size()))
        }
    }

//////// Events & event handling
    
    __pointToSuperview: final func (point: NPoint) -> NPoint {
        if (_superview) point add(frame() origin) .add(_superview bounds() origin)
        return point
    }
    
    /** Forwards a mouse movement event to the view's superview */
    forwardMouseMovedEvent: final func (mousePosition, mouseDelta: NPoint) {
        if (_superview)
            _superview mouseMoved(__pointToSuperview(mousePosition), mouseDelta)
    }
    
    /** Forwards a mouse pressed event to the view's superview */
    forwardMousePressedEvent: final func (button: Int, mousePosition: NPoint) {
        if (_superview)
            _superview mousePressed(button, __pointToSuperview(mousePosition))
    }
    
    /** Forwards a mouse released event to the view's superview */
    forwardMouseReleasedEvent: final func (button: Int, mousePosition: NPoint) {
        if (_superview)
            _superview mouseReleased(button, __pointToSuperview(mousePosition))
    }
    
    /**
        Called when the mouse has moved and this view is to receive the
        movement event.
        
        :param: position The current position of the mouse *in the view's
        coordinate space.*
        
        :param: delta The amount that the mouse has moved from its last
        position.
        
        The default implementation passes the event on to its superview.  If
        your implementation is not able to handle the event, you should call
        the superclass's implementation or :meth:`forwardMouseMovedEvent` with
        the event data.
    */
    mouseMoved: func (mousePosition, mouseDelta: NPoint) {
        forwardMouseMovedEvent(mousePosition, mouseDelta)
    }
    
    /**
       Called when a mouse :param:`button` has been pressed and this view is to
       receive the event.
       
       :param: button The button that was pressed.  The value for each button
       is 1 for left, 2 for right, and 3 for middle mouse.  Other mouse buttons
       are not defined but may still be received.
        
       :param: position The current position of the mouse *in the view's
       coordinate space.*

       The default implementation passes the event on to its superview.  If
       your implementation is not able to handle the event, you should call
       the superclass's implementation or :meth:`forwardMousePressedEvent`
       with the event data.
    */
    mousePressed: func (button: Int, mousePosition: NPoint) {
        forwardMousePressedEvent(button, mousePosition)
    }
    
    /**
       Called when a mouse :param:`button` has been released and this view is
       to receive the event.
       
       :param: button The button that was released.  The value for each button
       is 1 for left, 2 for right, and 3 for middle mouse.  Other mouse buttons
       are not defined but may still be received.
        
       :param: position The current position of the mouse *in the view's
       coordinate space.*

       The default implementation passes the event on to its superview.  If
       your implementation is not able to handle the event, you should call
       the superclass's implementation or :meth:`forwardMouseReleasedEvent`
       with the event data.
    */
    mouseReleased: func (button: Int, mousePosition: NPoint) {
        forwardMouseReleasedEvent(button, mousePosition)
    }
    
    /**
        Called when the mouse has entered the view.  This does not imply that
        the view has gained focus or will receive any other events.
    */
    mouseEntered: func {}
    
    /**
        Called when the mouse has left the view.  This does not imply that
        the view has lost focus or that it will receive any other events.
    */
    mouseLeft: func {}
    
    /**
        Called when the view has gained focus (is now the receiver of keyboard
        input).
    */
    focusGained: func {}
    
    /**
        Called when the view has lost focus (will not receive keyboard input).
    */
    focusLost: func {}
    
    /**
        Called by an NView or subclass thereof when a custom event should be
        fired for the view.  This sends the :param:`event` and the
        corresponding event :param:`data` to all event handlers registered for
        that event.
        
        :param: event The event name.
        
        :param: data A HashMap<String,Object> containing any data relevant to
        the event.
    */
    _fireEvent: func (event: String, data: HashMap<String, Object>) {
        handlers := _eventhandlers get(event) as LinkedList<NEventHandler>
        if (handlers != null) {
            iter := handlers iterator()
            while (iter hasNext())
                iter next() fire(this, event, data)
        }
    }
    
    addEventHandler: func (event: String, handler: NEventHandler) {
        handlers := _eventhandlers get(event) as LinkedList<NEventHandler>
        if (handlers == null) {
            handlers = LinkedList<NEventHandler> new()
            _eventhandlers put(event, handlers)
        }
        handlers add(handler)
    }
    
    /** Returns the event handler created for the function/closure */
    addEventHandler: func ~closure (event: String, handlerFn: Func (NView, String, HashMap<String, Object>)) -> NEventHandler {
        handler := NClosureEventHandler new(handlerFn)
        addEventHandler(event, handler)
        return handler
    }
    
    removeEventHandler: func (event: String, handler: NEventHandler) {
        handlers := _eventhandlers get(event) as LinkedList<NEventHandler>
        if (handlers != null)
            handlers remove(handler)
    }
    
    removeEventHandlers: func (event: String) {
        handlers := _eventhandlers get(event) as LinkedList<NEventHandler>
        if (handlers != null)
            handlers clear()
    }
    
//////// Drawables/fonts
    
    /**
        Returns the font to be used by the view.
        
        :return: If the view has a font it's supposed to use, that font is
        returned, otherwise it returns the result of :meth:`NGUI.viewFont`.
        The result may be null, so checking for whether or not the font can be
        used is important.
    */
    font: func -> NFont { _font ? _font : _gui viewFont() }
    
    /** 
        Sets the font to be used by the view.
        
        As a rule of thumb, view subclasses should probably not have fonts
        associated with them because there's no way to ensure distribution of a
        given font, nor is there a way to guarantee a given renderer can load
        the provided font.
    */
    setFont: func (=_font) {}
    
    drawable: func -> NDrawable { _drawable }
    
    setDrawable: func (=_drawable) {}
    
}