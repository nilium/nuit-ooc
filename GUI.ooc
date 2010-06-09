import structs/LinkedList
import Types
import View
import Renderer
import Window
import Popup
import Font
import Drawable

NGUI: class {
    /** The renderer to be used by the GUI to handle drawing **/
    _renderer: NRenderer = null
    
    /** The current mouse position as of the last mouse movement update **/
    _mouse_cur: NPoint
    /** The previous mouse position as of the last mouse movement update **/
    _mouse_prev: NPoint
    
    /** The view the mouse is currently over */
    _overView: NView = null
    /**
        The view to receive mouse movement/mouse release events after having
        been clicked on.
    */
    _mouseView: NView = null
    /** The view with focus (receives keyboard input) */
    _focalView: NView = null
    /** The primary window, receives mouse movement events */
    _mainWindow: NWindow = null
    /** The active popup view */
    _popup: NPopup = null
    
    /** A list of root windows managed by this GUI instance */
    _windows := LinkedList<NWindow> new()
    
    /** The default font used by views */
    _viewFont: NFont = null
    
    __updateMousePosition: func (pos: NPoint) {
        if (pos != _mouse_cur)
            pushMouseMoveEvent(_mouse_cur)
    }
    
    pushMousePressedEvent: func (button: Int, position: NPoint) {
        __updateMousePosition(position)
        
        view: NView = null
        
        if (_popup) {
            if (!_popup hidden?(false)) {
                view = _popup viewForPoint(_popup convertPointFromScreen(position))
                if (view == null) {
                    _popup hide()
                    _popup = null
                }
            } else {
                _popup = null
            }
        }
        
        if (view == null) {
            iter := _windows backward()
            while (view == null && iter hasNext()) {
                window := iter next()
            
                if (window hidden?(false))
                    continue
            
                view = window viewForPoint(window convertPointFromScreen(position))
            }
        }
        
        _mouseView = view
        
        if (_overView != view) {
            if (_overView) _overView mouseLeft()
            _overView = view
            if (_overView) _overView mouseEntered()
        }
        
        if (_focalView != view) {
            if (_focalView) _focalView focusLost()
            _focalView = view
            if (_focalView) _focalView focusGained()
        }
        
        if (view && !view disabled?(false)) {
            root := view root()
            if (root instanceOf(NWindow))
                setMainWindow(root as NWindow)
            
            view mousePressed(button, view convertPointFromScreen(position))
        }
    }
    
    pushMouseMoveEvent: func (position: NPoint) {
        _mouse_prev = _mouse_cur
        _mouse_cur = position
        
        position subtract(_mouse_prev)
        
        if (_mouseView && !(_mouseView hidden?(true) || _mouseView disabled?(true))) {
            _mouseView mouseMoved(_mouseView convertPointFromScreen(_mouse_cur), position)
        } else {
            set := false
            view: NView = null
            point: NPoint
            
            if (_popup) {
                if (!_popup hidden?(false))
                    view = _popup viewForPoint(_popup convertPointFromScreen(_mouse_cur))
                else
                    _popup = null
            }
            
            if (view == null && _mainWindow && !(_mainWindow hidden?(true) || _mainWindow disabled?(false)))
                view = _mainWindow viewForPoint(_mainWindow convertPointFromScreen(_mouse_cur))
            
            if (_overView != view) {
                if (_overView) _overView mouseLeft()
                _overView = view
                if (_overView) _overView mouseEntered()
            }
            
            if (view && !view disabled?(true))
                view mouseMoved(view convertPointFromScreen(_mouse_cur), position)
        }
    }
    
    pushMouseReleasedEvent: func (button: Int, position: NPoint) {
        __updateMousePosition(position)
        
        if (_mouseView && !(_mouseView hidden?(true) || _mouseView disabled?(true))) {
            pos := _mouseView convertPointFromScreen(position)
            _mouseView mouseReleased(button, pos)
            
            if (_overView && !NRect new(NPoint zero(), _mouseView size()) \
                                contains(_overView convertPointFromScreen(position))) {
                _overView mouseLeft()
                _overView = null
            }
            _mouseView = null
        }
    }
    
    renderer: func -> NRenderer { _renderer }
    
    /**
        Sets the renderer used by the GUI.
    */
    setRenderer: func (=_renderer) {}
    
    draw: func {
        if (_renderer == null)
            return
        
        _renderer acquire()
        
        _renderer setFillColor(NColor white())
        _renderer setClippingRegion(NRect new(NPoint zero(), _renderer screenSize()))
        _renderer disableClipping()
        
        iter := _windows iterator()
        while (iter hasNext()) {
            window := iter next()
            
            if (window hidden?(false))
                continue
            
            _renderer setDrawingOrigin(window origin())
            
            _renderer saveState()
            window draw(_renderer)
            _renderer restoreState()
            
            _renderer saveState()
            window drawSubviews(_renderer)
            _renderer restoreState()
            
            _renderer saveState()
            window drawSubwindows(_renderer)
            _renderer restoreState()
        }
        
        if (_popup) {
            if (_popup hidden?(false)) {
                _popup = null
            } else {
                _renderer setDrawingOrigin(_popup convertPointFromScreen(NPoint zero()))
                
                _renderer saveState()
                _popup draw(_renderer)
                _renderer restoreState()

                _renderer saveState()
                _popup drawSubviews(_renderer)
                _renderer restoreState()

                _renderer saveState()
                _popup drawSubwindows(_renderer)
                _renderer restoreState()
            }
        }
        
        _renderer release()
    }
    
    setMainWindow: func (window: NWindow) {
        if (window == _mainWindow)
            return
        
        if (window && window canBecomeMainWindow?() && !window hidden?(true)) {
            if (_mainWindow)
                _mainWindow lostMainWindow()
            
            if (window superview() == null && _windows remove(window))
                _windows add(window)
            else if (window superview() && window superview() subviews remove(window))
                window superview() subviews add(window)
            
            _mainWindow = window
            // false movement to set off any other changes due to the change
            // of main window (change of over view, focal view, etc.)
            pushMouseMoveEvent(_mouse_cur)
        } else if (window == null) {
            if (_mainWindow)
                _mainWindow lostMainWindow()
            
            _mainWindow = null

            pushMouseMoveEvent(_mouse_cur)
        }
        _focalView = null
    }
    
    mainWindow: func -> NWindow { _mainWindow }
    
    viewFont: func -> NFont { _viewFont }
    
    setViewFont: func (=_viewFont) {}
    
}