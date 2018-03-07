package com.yanrishatum.bfont.render;
import com.yanrishatum.bfont.BitmapFont;
import com.yanrishatum.bfont.BitmapFontChar;
import haxe.Utf8;

/**
 * ...
 * @author Yanrishatum
 */
class BFontDimensions
{
  public var x:Int;
  public var y:Int;
  public var width:Int;
  public var height:Int;
  public var caret:Int;
  public var last:BitmapFontChar;
  
  public static function wordWrap(text:String, font:BitmapFont, width:Int):Array<String>
  {
    var output:Array<String> = new Array();
    var lines:Array<String> = text.split("\n");
    var x:Int, wordSize:Int, kerning:Null<Int>;
    var space:BitmapFontChar = font.chars.get(" ".code);
    if (space == null)
    {
      space = new BitmapFontChar();
      space.xAdvance = 0;
    }
    var dims:BFontDimensions = new BFontDimensions();
    
    for (line in lines)
    {
      var words:Array<String> = line.split(" ");
      var wrapLine:Array<String> = new Array();
      x = -space.xAdvance;
      for (word in words)
      {
        calculateLine(word, font, dims, x > 0 ? space : null);
        wordSize = dims.x + dims.width + space.xAdvance;
        
        if (x + wordSize > width)
        {
          output.push(wrapLine.join(" "));
          wrapLine = new Array();
          x = -space.xAdvance;
        }
        x += wordSize;
        wrapLine.push(word);
      }
      output.push(wrapLine.join(" "));
    }
    return output;
  }
  
  public static function calculateLine(text:String, font:BitmapFont, ?dims:BFontDimensions, ?last:BitmapFontChar):BFontDimensions
  {
    if (dims == null) dims = new BFontDimensions();
    else dims.reset();
    
    // TODO: y/height
    
    var len:Int = Utf8.length(text);
    var i:Int = 0;
    var code:Int, char:BitmapFontChar, kerning:Null<Int>;
    var x:Int = 0;
    if (last != null)
    {
      code = Utf8.charCodeAt(text, 0);
      char = font.chars.get(code);
      kerning = last.kerning.get(code);
      if (kerning != null) dims.x += kerning;
      if (char != null) dims.x += char.xOffset;
    }
    while (i < len)
    {
      code = Utf8.charCodeAt(text, i++);
      char = font.chars.get(code);
      if (char == null) continue;
      if (last != null)
      {
        kerning = last.kerning.get(code);
        if (kerning != null) x += kerning;
      }
      x += char.xAdvance;
      
      last = char;
    }
    dims.caret = x;
    dims.width = x - last.xAdvance + last.width + last.xOffset - dims.x;
    dims.last = last;
    return dims;
  }
  
  public function new() 
  {
    x = y = width = height = caret = 0;
  }
  
  public function reset():Void
  {
    x = y = width = height = caret = 0;
    last = null;
  }
  
}