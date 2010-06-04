import Image
import Types
import Renderer
import Drawable

NTilingMode: enum {
    both = 0
    horizontal = 1
    vertical = 2
}

NTiledImageDrawable: class extends NDrawable {
    image: NImage
    tilingMode := NTilingMode both
    offset: NPoint = NPoint new(0.5, 0.5)
    
    init: func (=image) {}
    
    drawInRect: func (renderer: NRenderer, rect: NRect, frame: Int) {
        imageSize := image frameSize()
        xoff := offset x * imageSize width
        yoff := offset y * imageSize height
        xoffWidth := NFloat min(xoff, rect width())
        yoffHeight := NFloat min(yoff, rect height())
        
        xsteps := (rect width() / imageSize width - offset x) as Int
        ysteps := (rect height() / imageSize height - offset y) as Int
        
        xfits := (0.2 < xoffWidth)
        yfits := (0.2 < yoffHeight)
        
        drect: NRect
        srect: NRect
        
        xiter, yiter: Int
        
        match (tilingMode) {
            case NTilingMode both =>
                
                if (yfits) {
                    drect = NRect new(rect x() + xoff, rect y(), imageSize width, yoffHeight)
                    srect = NRect new(0.0, imageSize height - yoff, imageSize width, yoffHeight)
                    for(xiter in 0..xsteps) {
                        renderer drawSubimage(image, frame, srect, drect)
                        drect origin x += imageSize width
                    }
                }
                
                if (xfits) {
                    drect = NRect new(rect x(), rect y() + yoff, xoffWidth, imageSize height)
                    srect = NRect new(imageSize width - xoff, 0.0, xoffWidth, imageSize height)
                    for(yiter in 0..ysteps) {
                        renderer drawSubimage(image, frame, srect, drect)
                        drect origin y += imageSize height
                    }
                }
                
                if (xfits && yfits) {
                    drect = NRect new(rect x(), rect y(), xoffWidth, yoffHeight)
                    srect = NRect new(imageSize width - xoff, imageSize height - yoff, xoffWidth, yoffHeight)
                    renderer drawSubimage(image, frame, srect, drect)
                }
                
                rect origin x += xoff
                rect origin y += yoff
                rect size width -= xoff
                rect size height -= yoff
                
                xseg := rect width() - xsteps * imageSize width
                yseg := rect height() - ysteps * imageSize height
                
                drect = NRect new(rect origin, imageSize)
                for(xiter in 0..xsteps) {
                    drect origin y = rect y()
                    for(yiter in 0..ysteps) {
                        renderer drawImage(image, frame, drect)
                        drect origin y += imageSize height
                    }
                    drect origin x += imageSize width
                }
                
                xfits = (0.2 < xseg)
                yfits = (0.2 < yseg)
                
                if (yfits) {
                    drect = NRect new(rect x(), rect y() + ysteps * imageSize height, imageSize width, yseg)
                    srect = NRect new(0.0, 0.0, imageSize width, yseg)
                    for (xiter in 0..xsteps) {
                        renderer drawSubimage(image, frame, srect, drect)
                        drect origin x += imageSize width
                    }
                    if (0.2 < yoffHeight) {
                        drect origin x = rect x() - xoff
                        drect size width = xoffWidth
                        srect origin x = imageSize width - xoff
                        srect size width = xoffWidth
                        renderer drawSubimage(image, frame, srect, drect)
                    }
                }
                
                if (xfits) {
                    drect = NRect new(rect x() + xsteps * imageSize width, rect y(), xseg, imageSize height)
                    srect = NRect new(0.0, 0.0, xseg, imageSize height)
                    for (yiter in 0..ysteps) {
                        renderer drawSubimage(image, frame, srect, drect)
                        drect origin y += imageSize height
                    }
                    if (0.2 < xoffWidth) {
                        drect origin y = rect y() - yoff
                        drect size height = yoffHeight
                        srect origin y = imageSize height - yoff
                        srect size height = yoffHeight
                        renderer drawSubimage(image, frame, srect, drect)
                    }
                }
                
                if (xfits && yfits) {
                    drect = NRect new(rect x() + xsteps * imageSize width, rect y() + ysteps * imageSize height, xseg, yseg)
                    srect = NRect new(0.0, 0.0, xseg, yseg)
                    renderer drawSubimage(image, frame, srect, drect)
                }
                
            case NTilingMode horizontal =>
                
                if (xfits) {
                    drect = rect
                    drect size width = xoffWidth
                    srect = NRect new(imageSize width - xoff, 0.0, xoffWidth, imageSize height)
                    renderer drawSubimage(image, frame, srect, drect)
                }
                
                rect origin x += xoff
                rect size width -= xoff
                
                drect = NRect new(rect origin, imageSize)
                drect size height = rect height()
                for(xiter in 0..xsteps) {
                    renderer drawImage(image, frame, drect)
                    drect origin x += imageSize width
                }
                
                drect size width = rect width() - xsteps * imageSize width
                if (0.2 < drect width()) {
                    srect = NRect new(NPoint zero(), NSize new(drect width(), imageSize height))
                    renderer drawSubimage(image, frame, srect, drect)
                }
                
            case NTilingMode vertical =>
                
                if (yfits) {
                    drect = rect
                    drect size height = yoffHeight
                    srect = NRect new(0.0, imageSize height - yoff, imageSize width, yoffHeight)
                    renderer drawSubimage(image, frame, srect, drect)
                }
                
                rect origin y += yoff
                rect size height -= yoff
                
                drect = NRect new(rect origin, imageSize)
                drect size width = rect width()
                for(yiter in 0..ysteps) {
                    renderer drawImage(image, frame, drect)
                    drect origin y += imageSize height
                }
                
                drect size height = rect height() - ysteps * imageSize height
                if (0.2 < drect height()) {
                    srect = NRect new(NPoint zero(), NSize new(imageSize width, drect height()))
                    renderer drawSubimage(image, frame, srect, drect)
                }
                
        }
    }
    
    setOffset: func (off: NPoint) {
        off x -= off x floor()
        off y -= off y floor()
        offset = off
    }
}
