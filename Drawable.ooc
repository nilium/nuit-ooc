import Types
import Renderer

NDrawable: abstract class {
    drawInRect: abstract func (renderer: NRenderer, rect: NRect, frame: Int)
}
