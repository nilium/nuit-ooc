import Types
import View
import Renderer

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
    _mouseOverView: NView = null
    
    instance: static func -> NGUI {
        if (__instance == null)
            return NGUI new()
        return __instance
    }
    
    init: func {
        __instance = this
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