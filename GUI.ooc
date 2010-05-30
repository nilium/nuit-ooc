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
    
    
}