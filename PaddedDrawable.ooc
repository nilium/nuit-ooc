import Types
import Renderer
import Drawable

NPaddedDrawable: class extends NDrawable {
    drawable: NDrawable
    
    paddingTopLeft: NSize
    paddingBottomRight: NSize
    
    init: func (=drawable, =paddingTopLeft, =paddingBottomRight) {}
    
    drawInRect: func (renderer: NRenderer, rect: NRect, frame: Int) {
        if (drawable == null)
            return
        
        rect size subtract(paddingBottomRight) .subtract(paddingTopLeft)
        if (rect width() < 0.0 || rect height() < 0.0)
            return
        
        rect origin add(paddingTopLeft toPoint())
        drawable drawInRect(renderer, rect, frame)
    }
}
