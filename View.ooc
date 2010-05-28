import structs/LinkedList
import structs/HashMap
import Types
import Renderer
import EventHandler
import Popup
import Window

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
    _name: String = ""
    _tag: Object = null
    _id: Int = 0
    _superview: NView = null
    _subviews: LinkedList<NView>
    _frame: NRect
    _min_size: NSize
    _disabled := false
    _hidden := false
    _eventhandlers: HashMap<String, LinkedList<NEventHandler>>

//////// Initializers

    /** Initializes the view with a frame */
    init: func ~noNameAndID (frame: NRect) {
        init(frame, "", 0)
    }
    
    /** Initializes the view with a frame and name */
    init: func ~noID (frame: NRect, name: String) {
        init(frame, name, 0)
    }
    
    /** Initializes the view with a frame, name, and ID */
    init: func (frame: NRect, name: String, id: Int) {
        _eventhandlers = HashMap<String, LinkedList<NEventHandler>> new(16)
        _subviews = LinkedList<NView> new()
        _min_size set(0.0, 0.0)
        _frame set(0.0, 0.0, 0.0, 0.0)
        setFrame(frame)
        setName(name)
        setID(id)
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
        return frame() size
    }
    
    /** Get the view's frame */
    frame: func -> NRect {
        _frame
    }
    
    /** Set the view's frame */
    setFrame: func (frame: NRect) {
        frame size = NSize max(frame size, _min_size)
        _frame = frame
    }
    
    /**
        Get the view's bounds
    */
    bounds: func -> NRect {
        result := frame()
        result origin set(0.0, 0.0)
        return result
    }
    
    /**
        Get whether or not the view is hidden.
    */
    hidden: func -> Bool { _hidden }
    
    /**
        Set whether or not the view is hidden.
        
        Hidden views do not receive events and, of course, are not drawn.
    */
    setHidden: func (=_hidden) {}
    
    /**
        Get whether or not the view is disabled.
    */
    disabled: func -> Bool { _disabled }
    
    /**
        Set whether or not the view is disabled.
        
        Disabled views do not receive events, but are drawn.
    */
    setDisabled: func (=_disabled) {}
    
//////// Layout

    /**
        Performs layout on subviews where necessary.
        
        The default implementation does nothing.
    */
    performLayout: func {}
    
    
    /** Returns the minimum size of the view */
    minimumSize: func -> NSize { _min_size }
    
    /** Sets the minimum size of the view */
    setMinimumSize: func (min_size: NSize) {
        _min_size = NSize max(NSize zero(), min_size)
    }
    
    
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
        iterator := _subviews front()
        
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
        iterator := _subviews front()
        
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
        
        _subviews add(view)
        view _superview = this
    }
    
    /** Removes this view from its superview's hierarchy */
    removeFromSuperview: final func {
        if (_superview == null)
            Exception new(This, "View does not have a superview") throw()
        
        sv := _superview
        _superview = null
        sv _subviewWasRemoved(this)
    }
    
    _subviewWasRemoved: final func (subview: NView) {
        _subviews remove(subview)
        subviewWasRemoved(subview)
    }
    
    /** Notifies the view that one of its subviews has been removed */
    subviewWasRemoved: func (subview: NView) {}
    
    /** Returns a LinkedList with all of the subviews of this view. */
    subviews: final func -> LinkedList<NView> { _subviews clone() }
    
    /** Returns the view's superview */
    superview: final func -> NView { _superview }
    
    /** Returns the root view of this view's hierarchy */
    root: func -> NView {
        rv := this
        sv := rv superview()
        while (sv != null) {
            rv = sv
            sv = sv superview()
        }
        return rv
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
        last := _subviews back()
        
        boundsOrigin := bounds() origin
        
        while (last hasPrev()) {
            subview := last prev()
            
            if (subview hidden())
                continue
            
            trpoint := point
            trpoint subtract(frame() origin)
            trpoint subtract(boundsOrigin)
            
            subview = subview viewForPoint(trpoint)
            if (subview)
                return subview
        }
        
        frame := frame()
        frame origin set(0.0, 0.0)
        if (frame contains(point))
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
    _drawSubwindows: func (renderer: NRenderer) {
        renderer saveState()
        
        renderer setClippingRegion(NRect new(NPoint zero(), renderer screenSize()))
        
        iter := _subviews back() reversed()
        while (iter hasNext()) {
            subview := iter next()
            
            // this is bad practice, but it works
            if (subview hidden() || subview instanceOf(NPopup))
                continue
            
            if (subview instanceOf(NWindow)) {
            
                renderer saveState()
                
                
                
                _clipSubview(subview, renderer)
                subview draw(renderer)
                
                clip := subview bounds()
                clip origin = subview convertPointToScreen(clip origin)
                
                renderer setClippingRegion(clip)
                subview _drawSubviews(renderer)
            
                renderer restoreState()
            }
            
            subview _drawSubwindows(renderer)
        }
        
        renderer restoreState()
    }
    
    /**
        Draws all of a view's subviews.
        
        Internal use only.
    */
    _drawSubviews: func (renderer: NRenderer) {
        renderer saveState()
        
        /*
            if the view is a root view and clips its subviews, then set up the
            initial clipping region
            
            TODO: Move this into the GUI's renderer for root views, having it
            here is kind of stupid.
        */
        if (clipsSubviews() && (superview() == null || this instanceOf(NPopup))) {
            clip := bounds()
            clip origin = convertPointToScreen(clip origin)
            renderer setClippingRegion(clip)
        }
        
        iter := _subviews back() reversed()
        while (iter hasNext()) {
            subview := iter next()
            
            // this is bad practice, but it works
            if (subview hidden() || subview instanceOf(NWindow) || subview instanceOf(NPopup))
                continue
            
            renderer saveState()
            
            _clipSubview(subview, renderer)
            subview draw(renderer)
            subview _drawSubviews(renderer)
            
            renderer restoreState()
        }
        
        renderer restoreState()
    }
    
    /**
        Clips rendering to a subview's frame
    */
    _clipSubview: func (subview: NView, renderer: NRenderer) {
        /*
        cur_clip := renderer getScreenClip()
        
        bounds := this bounds()
        frame := subview frame()
        
        //renderer translate(bounds origin)
        //renderer translate(frame origin)
        */
    }
}