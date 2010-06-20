import Types
import Drawable
import Image
import Renderer

NImageScaling: enum {
    none = 0             /** Causes the image to be drawn without scaling and will be clipped to the drawing rectangle */
    fillWidth = 1        /** Causes the image to be drawn such that it will be stretched to fill the entire width of the drawing rectangle */
    fillHeight = 2       /** Causes the image to be drawn such that it will be stretched to fill the entire height of the drawing rectangle */
    fill = 3             /** Causes the image to be drawn such that it will be stretched to fill the drawing rectangle */
    fillAspect = 4       /** Causes the image to be scaled such that it will be stretched to fill the drawing rectangle while maintaining its aspect ratio. */
}

NImageDrawable: class extends NDrawable {
    image: NImage
    
    scaling := NImageScaling fillAspect
    
    init: func ~defaultScaling (=image) {
        init(image, NImageScaling fillAspect)
    }
    init: func (=image, =scaling) {}
    
    drawInRect: func (renderer: NRenderer, rect: NRect, frame: Int) {
        imageSize := image frameSize()
        match scaling {
            case NImageScaling none =>
                rect size width = NFloat min(imageSize width, rect size width)
                rect size height = NFloat min(imageSize height, rect size height)
            
            case NImageScaling fillWidth =>
                rect size height = NFloat min(imageSize height, rect size height)
            
            case NImageScaling fillHeight =>
                rect size width = NFloat min(imageSize width, rect size width)
            
            case NImageScaling fill =>
                renderer drawImage(image, frame, rect)
                return
            
            case NImageScaling fillAspect =>
                size := NSize new(rect size height * (imageSize width / imageSize height), rect size height)
            
                if (rect width() < size width)
                    size set(rect size width, rect size width * (imageSize height / imageSize width))
            
                rect size = size
                renderer drawImage(image, frame, rect)
            
                return
        }
        
        renderer drawSubimage(image, frame, NRect new(NPoint zero(), rect size), rect)
    }
    
    scaling: func -> NImageScaling {scaling}
    setScaling: func (=scaling) {}
}
