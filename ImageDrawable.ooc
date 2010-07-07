import Types
import Drawable
import Image
import Renderer

NImageScaling: enum {
    /** Causes the image to be drawn without scaling and will be clipped to the drawing rectangle */
    none = 0
    /** Causes the image to be drawn such that it will be stretched to fill the entire width of the drawing rectangle */
    fillWidth = 1
    /** Causes the image to be drawn such that it will be stretched to fill the entire height of the drawing rectangle */
    fillHeight = 2
    /** Causes the image to be drawn such that it will be stretched to fill the drawing rectangle */
    fill = 3
    /** Causes the image to be scaled such that it will be stretched to fill the drawing rectangle while maintaining its aspect ratio. */
    fillAspect = 4
}

NImageAlignment: enum {
    /** Image is aligned to the top-left corner of the drawing rect */
    topLeft = 0
    /** Image is aligned to the top-center edge of the drawing rect */
    top = 1
    /** Image is aligned to the top-right corner of the drawing rect */
    topRight = 2
    /** Image is aligned to the mid-left of the drawing rect */
    left = 3
    /** Image is aligned to the middle of the drawing rect */
    center = 4
    /** Image is aligned to the mid-right of the drawing rect */
    right = 5
    /** Image is aligned to the bottom-left corner of the drawing rect */
    bottomLeft = 6
    /** Image is aligned to the bottom-center edge of the drawing rect */
    bottom = 7
    /** Image is aligned to the bottom-right corner of the drawing rect */
    bottomRight = 8
}

NImageDrawable: class extends NDrawable {
    image: NImage
    
    scaling := NImageScaling fillAspect
    align := NImageAlignment topLeft
    
    init: func ~defaultScalingAlign (=image) {
        init(image, NImageScaling fillAspect, NImageAlignment topLeft)
    }
    init: func (=image, =scaling, =align) {}
    
    _imageRectForRect: func(rect: NRect) -> NRect {
        imageSize := image frameSize()
        outRect := rect
        match scaling {
            case NImageScaling none =>
                outRect size = outRect size min(imageSize)
            
            case NImageScaling fillWidth =>
                outRect size height = outRect size height min(imageSize height)
            
            case NImageScaling fillHeight =>
                outRect size width = outRect size width min(imageSize width)
            
            case NImageScaling fillAspect =>
                size := NSize new(outRect size height * (imageSize width / imageSize height), outRect size height)
            
                if (outRect width() < size width)
                    size set(outRect size width, outRect size width * (imageSize height / imageSize width))
            
                outRect size = size
        }
        
        edge := (align as Int)%3
        if (align <= NImageAlignment topRight) {
            
        } else if (align <= NImageAlignment right) {
            outRect origin y = ((rect top() + rect bottom()) - outRect height()) * 0.5
        } else {
            outRect alignBottom(rect bottom())
        }
        
        match (edge) {
            case 1 =>
                outRect origin x = ((rect left() + rect right()) - outRect width()) * 0.5
            case 2 =>
                outRect alignRight(rect right())
        }
        
        return outRect
    }
    
    drawInRect: func (renderer: NRenderer, rect: NRect, frame: Int) {
        imageSize := image frameSize()
        imgRect := _imageRectForRect(rect)
        
        if (scaling == NImageScaling fill || scaling == NImageScaling fillAspect)
            renderer drawImage(image, frame, imgRect)
        else
            renderer drawSubimage(image, frame, imgRect size toRect(), imgRect)
    }
    
    scaling: func -> NImageScaling {scaling}
    setScaling: func (=scaling) {}
}
