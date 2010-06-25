import GUI
import Image
import Drawable
import NinePatchDrawable
import Types
import View
import Window
import Renderer

/**
    A common NWindow subclass, has a visible frame, can be resized and moved.
    
    :section: Skin Attributes
    
    :attrib:`FramedWindow`
    :type: NDrawable
    Two-frame drawable for the window background.  Frame 0 is the active window
    frame, frame 1 is the inactive window frame.  Disabled windows use the
    inactive window frame as well.
    
    :attrib:`Shadow`
    :type: NDrawable
    Drawable for all shadows in NUIT (or at least all that use this drawable).
    
    :attrib:`FramedWindowResizer`
    :type: NSize
    :default: {16.0, 16.0}
    Width of the resizer block on the window.
*/
NFramedWindow: class extends NWindow {
    _shadow: NDrawable
    _dragging := 0
    _drag_point: NPoint
    _caption := ""
    _resizerSize: NSize
    
    init: func (gui: NGUI, frame: NRect) {
        super(gui, frame)
        
        minSize = NSize new(64.0, 64.0)
        minSizeEnabled = true
        setBounds(NSize new(2.0, 22.0), NSize new(2.0))
    }
    
    _loadDefaultDrawables: func {
        skin := _gui skin()
        setDrawable(skin drawableForName("FramedWindow"))
        _shadow = skin drawableForName("Shadow")
        _resizerSize = skin sizeForName("FramedWindowResizer", NSize new(16.0))
    }
    
    draw: func (renderer: NRenderer) {
        drw := drawable()
        if (drw != null) {
            // Only draw the title and shadow if we have a frame to begin with
            
            frame: Int = (isMainWindow?() ? 0 : 1)
            if (_shadow) {
                renderer saveState()
                renderer applyFillColor(NColor black(0.5))
                shadowRect := NRect new(NPoint new(-4.0, 0.0), size())
                shadowRect size height += 6.0
                shadowRect size width += 8.0
                _shadow drawInRect(renderer, shadowRect, 0)
                renderer restoreState()
            }
            drw drawInRect(renderer, NRect new(NPoint zero(), size()), frame)
            
            font := font()
            if (font && _caption) {
                renderer saveState()
                origin := renderer drawingOrigin()
                origin x += 2
                origin y += 2
                renderer enableClipping()
                renderer clipRegion(NRect new(origin, NSize new(size() width-4, 22.0)))
                sz := font sizeOfText(_caption)
                asc := font ascender()
                pos := NPoint new(_bounds_topLeft width + (((size() width - (_bounds_topLeft width + _bounds_bottomRight width)) - sz width)*0.5) floor(), (_bounds_topLeft height - sz height)*0.5 + font ascender() + font descender())
                renderer drawText(_caption, font, pos)
                renderer restoreState()
            }
        }
    }
    
    mousePressed: func (button: Int, position: NPoint) -> NView {
        if (button == 1) {
            region: NRect
            
            region origin = (size() - _resizerSize) as NPoint
            region size = _resizerSize
            if (region contains(position)) {
                _dragging = 2
                _drag_point = size() as NPoint - position
                return this
            }
            
            region = frame()
            region origin = NPoint zero()
            region size height = 24.0
            if (region contains(position)) {
                _dragging = 1
                return this
            }
        }
        
        super(button, position)
    }
    
    mouseMoved: func (to: NPoint, delta: NPoint) {
        if (_dragging != 0) {
            frame := frame()
            if (_dragging == 1) {
                frame origin += delta
            } else {
                frame size = (to + _drag_point) as NSize
            }
            setFrame(frame)
        }
    }
    
    mouseReleased: func (button: Int, position: NPoint) {
        if (button == 1) {
            _dragging = 0
        }
    }
    
    setCaption: func (._caption) {
        if (_caption != null)
            this _caption = _caption clone()
        else
            this _caption = _caption
    }
    
    caption: func -> String {
        _caption
    }
}
