import GUI
import Drawable
import Types
import Window
import Renderer

NFramedWindow: class extends NWindow {
    _dragging := 0
    _drag_point: NPoint
    
    init: func (gui: NGUI, frame: NRect) {
        super(gui, frame)
        setMinimumSize(NSize new(40.0, 40.0))
    }
    
    draw: func (renderer: NRenderer) {
        drw := drawable()
        if (drw != null) {
            frame: Int = (isMainWindow?() ? 0 : 1)
            drw drawInRect(renderer, NRect new(NPoint zero(), size()), frame)
        }
    }
    
    mousePressed: func (button: Int, position: NPoint) {
        if (button == 1) {
            region: NRect
            
            region size = size()
            region set(region width() - 20.0, region height() - 20.0, 20.0, 20.0)
            if (region contains(position)) {
                _dragging = 2
                _drag_point = size() toPoint()
                _drag_point subtract(position)
                return
            }
            
            region = frame()
            region origin = NPoint zero()
            region size height = 24.0
            if (region contains(position)) {
                _dragging = 1
                return
            }
        }
        
        super(button, position)
    }
    
    mouseMoved: func (to: NPoint, delta: NPoint) {
        if (_dragging != 0) {
            frame := frame()
            if (_dragging == 1) {
                frame origin add(delta)
            } else {
                to add(_drag_point)
                frame size = to toSize()
            }
            setFrame(frame)
        }
    }
    
    mouseReleased: func (button: Int, position: NPoint) {
        if (button == 1) {
            _dragging = 0
        }
    }
    
    bounds: func -> NRect {
        bounds: NRect
        bounds origin set(1.0, 24.0)
        bounds size = size()
        bounds size subtract(bounds origin toSize())
        bounds size width -= 1
        bounds size height -= 1
        return bounds
        
    }
}
