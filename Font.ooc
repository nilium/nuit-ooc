import Types

NFontData: abstract class {
    /**
        Returns the weight of the font (from 0.0 to 1.0).  Depending on the
        implementation, this may never be used, and should return 0.5 in such
        cases.
    */
    weight: abstract func -> NFloat
    
    /**
        Returns whether or not the font is bold.
    */
    isBold: abstract func -> Bool
    
    /**
        Returns whether or not the font is italicized.
    */
    isItalic: abstract func -> Bool
    
    /**
        Returns whether or not the font can render the given character.
    */
    supportsGlyph: abstract func (chr: ULong) -> Bool
    
    /**
        Returns the pixel size of the glyph for the character.
        
        In the event that the glyph is unsupported, a default size should be
        provided for that glyph.
    */
    glyphSize: abstract func (chr: ULong) -> NSize
    
    /**
        Returns the relative horizontal position of the next character to
        follow the glyph without kerning.
    */
    glyphAdvance: abstract func (chr: ULong) -> NPoint
    
    /**
        Returns the kerning for the given glyph pairing.
    */
    glyphKerning: abstract func (left, right: ULong) -> NPoint
    
    /**
        Returns the relative offset of the glyph from the baseline.
    */
    glyphBearing: abstract func (chr: ULong) -> NPoint
    
    /**
        Returns what should be the minimum height of a line for the font.
    */
    lineHeight: abstract func -> NFloat
    
    /**
        Returns the font's ascender.
    */
    ascender: abstract func -> NFloat
    
    /**
        Returns the font's ascender.
    */
    descender: abstract func -> NFloat
}

NFont: class {
    /** The URL the font was/is to be loaded from */
    url: String = ""
    
    /** The size of the font */
    size: Int = 12
    
    /** Whether or not the font is bold */
    bold := false
    
    /** Whether or not the font is italicized */
    italic := false
    
    /**
        The font data provided by the last renderer to use the font.
    */
    data: NFontData
    
    init: func (url: String, =size, =bold, =italic) {
        this url = url ? url clone() : null
    }
    
    /** Returns the size of the font in pixels. */
    size: func -> NFloat {size}
    
    /**
        Returns the weight of the font (from 0.0 to 1.0).  Depending on the
        implementation, this may never be used, and should return 0.5 in such
        cases.
    */
    weight: func -> NFloat {
        if (data == null)
            Exception new(This, "Font has not been loaded") throw()
        return data weight()
    }
    
    /**
        Returns whether or not the font is bold.
    */
    isBold: func -> Bool {bold}
    
    /**
        Returns whether or not the font is italicized.
    */
    isItalic: func -> Bool {italic}
    
    /**
        Returns whether or not the font can render the given character.
    */
    supportsGlyph: func (chr: ULong) -> Bool {
        if (data == null)
            Exception new(This, "Font has not been loaded") throw()
        return data supportsGlyph(chr)
    }
    
    /**
        Returns the pixel size of the glyph for the character.
        
        In the event that the glyph is unsupported, a default size should be
        provided for that glyph.
    */
    glyphSize: func (chr: ULong) -> NSize {
        if (data == null)
            Exception new(This, "Font has not been loaded") throw()
        return data glyphSize(chr)
    }
    
    /**
        Returns the relative horizontal position of the next character to
        follow the glyph without kerning.
    */
    glyphAdvance: func (chr: ULong) -> NPoint {
        if (data == null)
            Exception new(This, "Font has not been loaded") throw()
        return data glyphAdvance(chr)
    }
    
    /**
        Returns the kerning for the given glyph pairing.
    */
    glyphKerning: func (left, right: ULong) -> NPoint {
        if (data == null)
            Exception new(This, "Font has not been loaded") throw()
        return data glyphKerning(left, right)
    }
    
    /**
        Returns the relative offset of the glyph from the baseline.
    */
    glyphBearing: func (chr: ULong) -> NPoint {
        if (data == null)
            Exception new(This, "Font has not been loaded") throw()
        return data glyphBearing(chr)
    }
    
    /**
        Returns what should be the minimum height of a line for the font.
    */
    lineHeight: func -> NFloat {
        if (data == null)
            Exception new(This, "Font has not been loaded") throw()
        return data lineHeight()
    }
    
    /**
        Returns the font's ascender.
    */
    ascender: func -> NFloat {
        if (data == null)
            Exception new(This, "Font has not been loaded") throw()
        return data ascender()
    }
    
    /**
        Returns the font's ascender.
    */
    descender: func -> NFloat {
        if (data == null)
            Exception new(This, "Font has not been loaded") throw()
        return data descender()
    }
    
    /**
        Returns the size of the text for the given string.
    */
    sizeOfText: func (str: String) -> NSize {
        iter := str iterator()
        lastChr, chr: ULong
        lastChr = 0
        
        init: Bool = false
        rect: NRect = NRect new(0.0, 0.0, 0.0, 0.0)
        charRect: NRect
        point: NPoint
        while (iter hasNext()) {
            chr := iter next()
            
            charRect origin = point
            charRect size = glyphSize(chr)
            charRect origin add(glyphKerning(lastChr, chr)) .add(glyphBearing(chr))
            
            if (init) {
                if (charRect left() < rect left()) rect setLeft(charRect left())
                if (charRect right() > rect right()) rect setRight(charRect right())
                if (charRect top() < rect top()) rect setTop(charRect top())
                if (charRect bottom() > rect bottom()) rect setBottom(charRect bottom())
            } else {
                init = true
                rect = charRect
            }
            
            point x += glyphAdvance(chr) x
            
            lastChr = chr
        }
        
        return rect size
    }
}