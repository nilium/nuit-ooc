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
    supportsGlyph: abstract func (chr: Char) -> Bool
    
    /**
        Returns the pixel size of the glyph for the character.
        
        In the event that the glyph is unsupported, a default size should be
        provided for that glyph.
    */
    glyphSize: abstract func (chr: Char) -> NSize
    
    /**
        Returns the relative horizontal position of the next character to
        follow the glyph without kerning.
    */
    glyphAdvance: abstract func (chr: Char) -> NSize
    
    /**
        Returns the kerning for the given glyph pairing.
    */
    glyphKerning: abstract func (left, right: Char) -> NFloat
    
    /**
        Returns the relative offset of the glyph from the baseline.
    */
    glyphPosition: abstract func (chr: Char) -> NPoint
    
    /**
        Returns what should be the minimum height of a line for the font.
    */
    lineHeight: abstract func -> NFloat
    
    /**
        Returns the font's baseline.
    */
    baseLine: abstract func -> NFloat
}

NFont: abstract class {
    /** The URL the font was/is to be loaded from */
    url: String = ""
    
    /** The size of the font */
    size: NFloat = 12.0
    
    /** Whether or not the font is bold */
    bold := false
    
    /** Whether or not the font is italicized */
    italic := false
    
    /**
        The font data provided by the last renderer to use the font.
    */
    fontData: NFontData
    
    
    init: func ~notBoldNotItalic (url: String, size: NFloat) {
        init(url, size, false, false)
    }
    
    init: func (url: String, =size, =bold, =italic) {
        this url = url clone()
    }
    
    /** Returns the size of the font in pixels. */
    size: func -> NFloat {size}
    
    /**
        Returns the weight of the font (from 0.0 to 1.0).  Depending on the
        implementation, this may never be used, and should return 0.5 in such
        cases.
    */
    weight: func -> NFloat {
        if (fontData == null)
            Exception new(This, "Font has not been loaded") throw()
        return fontData baseLine()
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
    supportsGlyph: func (chr: Char) -> Bool {
        if (fontData == null)
            Exception new(This, "Font has not been loaded") throw()
        return fontData supportsGlyph(chr)
    }
    
    /**
        Returns the pixel size of the glyph for the character.
        
        In the event that the glyph is unsupported, a default size should be
        provided for that glyph.
    */
    glyphSize: func (chr: Char) -> NSize {
        if (fontData == null)
            Exception new(This, "Font has not been loaded") throw()
        return fontData glyphSize(chr)
    }
    
    /**
        Returns the relative horizontal position of the next character to
        follow the glyph without kerning.
    */
    glyphAdvance: func (chr: Char) -> NSize {
        if (fontData == null)
            Exception new(This, "Font has not been loaded") throw()
        return fontData glyphAdvance(chr)
    }
    
    /**
        Returns the kerning for the given glyph pairing.
    */
    glyphKerning: func (left, right: Char) -> NFloat {
        if (fontData == null)
            Exception new(This, "Font has not been loaded") throw()
        return fontData glyphKerning(left, right)
    }
    
    /**
        Returns the relative offset of the glyph from the baseline.
    */
    glyphPosition: func (chr: Char) -> NPoint {
        if (fontData == null)
            Exception new(This, "Font has not been loaded") throw()
        return fontData glyphPosition(chr)
    }
    
    /**
        Returns what should be the minimum height of a line for the font.
    */
    lineHeight: func -> NFloat {
        if (fontData == null)
            Exception new(This, "Font has not been loaded") throw()
        return fontData lineHeight()
    }
    
    /**
        Returns the font's baseline.
    */
    baseLine: func -> NFloat {
        if (fontData == null)
            Exception new(This, "Font has not been loaded") throw()
        return fontData baseLine()
    }
    
    /**
        Returns the size of the text for the given string.
    */
    sizeOfText: func (str: String) -> NSize {
        iter := str iterator()
        lastChar := 0
        
        size: NSize
        
        while (iter hasNext()) {
            chr := iter next()
            
            // TODO: code for determining the size of a given string
            
            lastChar = chr
        }
        
        return size
    }
}