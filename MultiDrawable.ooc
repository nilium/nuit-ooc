import Types
import Renderer
import Drawable

NMultiDrawable: class extends NDrawable {
    drawables: Iterable<NDrawable>
    
    init: func (=drawables) {}
    
    drawInRect: func (renderer: NRenderer, rect: NRect, frame: Int) {
        for(drawable in drawables) {
            renderer saveState()
            drawable drawInRect(renderer, rect, frame)
            renderer restoreState()
        }
    }
}
