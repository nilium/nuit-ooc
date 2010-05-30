import structs/LinkedList
import Types
import View
import Renderer
import Window
import Popup

NGUI: class {
    /** The active NGUI instance **/
    __instance: static NGUI = null
    /** The renderer to be used by the GUI to handle drawing **/
    _renderer: NRenderer
    
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
    
    _windows: LinkedList<NWindow>
    
    activeInstance: static func -> NGUI {
        if (__instance == null)
            return NGUI new()
        return __instance
    }
    
    init: func {
        __instance = this
        _windows = LinkedList<NWindow> new()
    }
    
    makeActive: func {
        __instance = this
    }
    
    makeInactive: func {
        if (__instance == this) {
            __instance = null
        }
    }
    
    __updateMousePosition: func (pos: NPoint) {
        if (pos != _mouse_cur)
            pushMouseMoveEvent(_mouse_cur)
    }
    
    pushMousePressedEvent: func (button: Int, position: NPoint) {
        __updateMousePosition(position)
        
        view: NView = null
        
        if (_popup) {
            if (!_popup hidden?()) {
                view = _popup viewForPoint(_popup convertPointFromScreen(_mouse_cur))
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
            
                if (window hidden?())
                    continue
            
                view = window viewForPoint(window convertPointFromScreen(_mouse_cur))
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
        
        if (view && !view disabled?()) {
            root := view root()
            if (root instanceOf(NWindow))
                setMainWindow(root as NWindow)
            
            view mousePressed(button, view convertPointFromScreen(_mouse_cur))
        }
    }
    
    pushMouseMoveEvent: func (position: NPoint) {
        _mouse_prev = _mouse_cur
        _mouse_cur = position
        
        position subtract(_mouse_prev)
        
        if (_mouseView && !(_mouseView hidden?() || _mouseView disabled?(true))) {
            _mouseView mouseMoved(_mouseView convertPointFromScreen(_mouse_cur), position)
        } else {
            set := false
            view: NView = null
            point: NPoint
            
            if (_popup) {
                if (!_popup hidden?())
                    view = _popup viewForPoint(_popup convertPointFromScreen(_mouse_cur))
                else
                    _popup = null
            }
            
            if (view == null && _mainWindow && !(_mainWindow hidden?() || _mainWindow disabled?()))
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
    }
    
    /**
        Sets the renderer used by the GUI.
    */
    setRenderer: func (=_renderer) {}
    
    draw: func {
        if (_renderer == null)
            return
        
        _renderer acquire()
        _renderer saveState()
        
        _renderer restoreState()
        _renderer release()
    }
    
    setMainWindow: func (window: NWindow) {
        if (window == _mainWindow)
            return
        
        if (window && window canBecomeMainWindow?()) {
            if (_mainWindow)
                _mainWindow lostMainWindow()
            
            if (window superview() == null && _windows contains(window))
                _windows remove(window) .add(window)
            
            // false movement to set off any other changes due to the change
            // of main window
            pushMouseMoveEvent(_mouse_cur)
        } else if (window == null) {
            if (_mainWindow)
                _mainWindow lostMainWindow()
            
            _mainWindow = null

            pushMouseMoveEvent(_mouse_cur)
        }
    }
    
}