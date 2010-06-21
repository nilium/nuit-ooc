import Image
import Types
import Renderer
import Drawable

NNinePatchDrawable: class extends NDrawable {
    image: NImage
    borderTopLeft := NSize new(8.0, 8.0)
    borderBottomRight := NSize new(8.0, 8.0)
    scaleTopLeft := NSize new(1.0, 1.0)
    scaleBottomRight := NSize new(1.0, 1.0)
    
    init: func ~bordered (=image, =borderTopLeft, =borderBottomRight, scale: NFloat) {
        scaleTopLeft set(scale, scale)
        scaleBottomRight set(scale, scale)
    }
    
    drawInRect: func (renderer: NRenderer, rect: NRect, frame: Int) {
        NINEPATCH_MINIMUM: static const NFloat = 0.25
        
        // whether or not the borders are used
        lb := borderTopLeft width >= NINEPATCH_MINIMUM
        rb := borderBottomRight width >= NINEPATCH_MINIMUM
        tb := borderTopLeft height >= NINEPATCH_MINIMUM
        bb := borderBottomRight height >= NINEPATCH_MINIMUM
        
        // the size of each border (for subimage rendering)
        lw := (lb as NFloat) * borderTopLeft width
        rw := (rb as NFloat) * borderBottomRight width
        th := (tb as NFloat) * borderTopLeft height
        bh := (bb as NFloat) * borderBottomRight height
        // scaled borders
        lws := lw * scaleTopLeft width()
        rws := rw * scaleBottomRight width()
        ths := th * scaleTopLeft height()
        bhs := bh * scaleBottomRight height()
        
        imageSize := image frameSize()
        
        dw := (rect width() - (lw * scaleTopLeft width) - (rw * scaleBottomRight width)) max(0.0)
        dh := (rect height() - (th * scaleTopLeft height) - (bh * scaleBottomRight height)) max(0.0)
        sw := imageSize width - lw - rw
        sh := imageSize height - th - bh
        
        if (tb) {
            if (lb)
                renderer drawSubimage(image, frame, NRect new(0.0, 0.0, lw, th), NRect new(rect x(), rect y(), lws, ths))
            renderer drawSubimage(image, frame, NRect new(lw, 0.0, sw, th), NRect new(rect x() + lws, rect y(), dw, ths))
            if (rb)
                renderer drawSubimage(image, frame, NRect new(lw+sw, 0.0, rw, th), NRect new(rect x() + dw + lws, rect y(), rws, ths))
            
            rect origin y += th
        }
        
        if (lb)
            renderer drawSubimage(image, frame, NRect new(0.0, th, lw, sh), NRect new(rect x(), rect y(), lws, dh))
        renderer drawSubimage(image, frame, NRect new(lw, th, sw, sh), NRect new(rect x() + lws, rect y(), dw, dh))
        if (rb)
            renderer drawSubimage(image, frame, NRect new(lw+sw, th, rw, sh), NRect new(rect x() + dw + lws, rect y(), rws, dh))
        rect origin y += dh
        
        if (bb) {
            if (lb)
                renderer drawSubimage(image, frame, NRect new(0.0, sh+th, lw, bh), NRect new(rect x(), rect y(), lws, bhs))
            renderer drawSubimage(image, frame, NRect new(lw, sh+th, sw, bh), NRect new(rect x() + lws, rect y(), dw, bhs))
            if (rb)
                renderer drawSubimage(image, frame, NRect new(lw+sw, sh+th, rw, bh), NRect new(rect x() + dw + lws, rect y(), rws, bhs))
        }
        
    }
}
