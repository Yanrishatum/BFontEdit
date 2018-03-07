package com.yanrishatum.bfont.render;
import com.yanrishatum.bfont.BitmapFontChar;
import com.yanrishatum.bfont.render.BFontTextPiece.BFontTextChar;
import haxe.Utf8;

/**
 * ...
 * @author Yanrishatum
 */
class BFontTextPiece
{
  public var font:BitmapFont;
  public var text:String;
  
  public var alpha:Float = 1;
  public var red:Float = 1;
  public var green:Float = 1;
  public var blue:Float = 1;
  
  public var chars:Array<BFontTextChar>;
  public var top:Int;
  public var bottom:Int;
  public var left:Int;
  public var right:Int;
  
  public function new(font:BitmapFont, text:String)
  {
    this.font = font;
    this.text = text;
  }
  
  public function align(line:BFontTextLine, previous:BFontTextPiece):Int
  {
    var x:Int = line.caret;
    chars = new Array();
    var y:Int = -font.common.base;
    top = y;
    bottom = 0;
    left = 0;
    right = 0;
    
    var last:BitmapFontChar = previous != null && previous.font == this.font ? previous.chars[previous.chars.length - 1].char : null;
    var rchar:BFontTextChar = null;
    
    var len:Int = Utf8.length(text);
    var i:Int = 0;
    
    // Calc left
    if (last != null)
    {
      var code:Int = Utf8.charCodeAt(text, 0);
      var char:BitmapFontChar = font.chars.get(code);
      if (char != null)
      {
        var kerning:Null<Int> = last.kerning.get(code);
        if (kerning != null) left += kerning;
        left += char.xOffset;
      }
    }
    
    while (i < len)
    {
      var code:Int = Utf8.charCodeAt(text, i++);
      var char:BitmapFontChar = font.chars.get(code);
      if (char == null)
      {
        continue;
      }
      if (last != null)
      {
        var kerning:Null<Int> = last.kerning.get(code);
        if (kerning != null)
        {
          x += kerning;
          right += kerning;
        }
      }
      rchar = BFontTextChar.get();
      rchar.char = char;
      rchar.x = x + char.xOffset;
      rchar.y = y + char.yOffset;
      
      // Calc top/bottom
      if (rchar.y < top) top = rchar.y;
      if (rchar.y + char.height > bottom) bottom = rchar.y + char.height;
      
      chars.push(rchar);
      last = char;
      x += char.xAdvance;
    }
    // Calc right
    if (rchar != null)
    {
      right = rchar.x + rchar.char.width - line.width;
    }
    return x;
  }
  
  public function setColor(color:Int):Void
  {
    this.alpha = ((color >> 24) & 0xff) / 0xff;
    this.red = ((color >> 16) & 0xff) / 0xff;
    this.green = ((color >> 8) & 0xff) / 0xff;
    this.blue = (color & 0xff) / 0xff;
  }
  
  public function dispose():Void
  {
    if (chars != null)
    {
      for (char in chars) char.free();
    }
    chars = null;
    font = null;
  }
  
}

class BFontTextChar
{
  private static var tail:BFontTextChar;
  public static function get():BFontTextChar
  {
    if (tail == null)
    {
      return new BFontTextChar();
    }
    else
    {
      var c:BFontTextChar = tail;
      tail = c.next;
      c.next = null;
      return c;
    }
  }
  
  private var next:BFontTextChar;
  
  public var char:BitmapFontChar;
  public var x:Int;
  public var y:Int;
  
  private function new()
  {
    
  }
  
  public function free():Void
  {
    this.char = null;
    next = tail;
    tail = this;
  }
  
}