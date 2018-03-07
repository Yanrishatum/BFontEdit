package com.yanrishatum.bfont;
import com.yanrishatum.bfont.render.BFontDimensions;
import com.yanrishatum.bfont.render.BFontTextAlign;
import com.yanrishatum.bfont.render.BFontTextLine;
import com.yanrishatum.bfont.render.BFontTextPiece;
import com.yanrishatum.bfont.render.BFontVerticalAlign;
import haxe.Utf8;

/**
 * Primitive BitmapFont system for ease of text rendering
 * @author Yanrishatum
 */
class BitmapFontText
{

  public static dynamic function resolveFont(name:String):BitmapFont
  {
    throw "Please override BitmapFontText.resolveFont";
  }
  
  public var font:String;
  public var align:BFontTextAlign;
  public var verticalAlign:BFontVerticalAlign;
  
  public var wordWrap:Bool = false;
  
  private var _textRaw:String = "";
  public var text(get, set):String;
  private function get_text():String { return _textRaw; }
  private function set_text(v:String):String
  {
    if (v == null || v.length == 0)
    {
      clear();
      return _textRaw = "";
    }
    else
    {
      clear();
      addPiece(v, resolveFont(font), tint, align);
      return _textRaw = v;
    }
  }
  
  public var tint:Int = 0xffffffff;
  
  private var lines:Array<BFontTextLine>;
  private var lineCount:Int;
  
  public var width:Int;
  public var height:Int;
  
  public var textWidth:Int;
  public var textHeight:Int;
  
  public function new() 
  {
    lines = new Array();
    lineCount = 0;
    align = Left;
    verticalAlign = Top;
    width = 0;
    height = 0;
    textWidth = textHeight = 0;
  }
  
  public function clear():Void
  {
    for (line in lines)
    {
      line.dispose();
    }
    textWidth = textHeight = 0;
    _textRaw = "";
    lineCount = 0;
  }
  
  private function renderChar(x:Int, y:Int, char:BitmapFontChar, red:Float, green:Float, blue:Float, alpha:Float):Void
  {
    throw "Please override BitmapFontText.renderChar";
  }
  
  public function render():Void
  {
    var x:Int = 0;
    var y:Int = 0;
    
    for (i in 0...lineCount)
    {
      var line:BFontTextLine = lines[i];
      switch (line.align)
      {
        // Most likely wrong
        // TODO: Floats
        case Left: x = line.x;
        case Right:
          if (width == 0)
          {
            x = (textWidth - line.width) - line.x;
          }
          else
          {
            x = (width - line.width) - line.x;
          }
        case Center:
          if (width == 0)
          {
            x = Std.int((textWidth - line.width) / 2) - line.x;
          }
          else
          {
            x = Std.int((width - line.width) / 2) - line.x;
          }
      }
      
      for (piece in line.pieces)
      {
        for (char in piece.chars)
        {
          renderChar(char.x + x, char.y + y, char.char, piece.red, piece.green, piece.blue, piece.alpha);
        }
      }
      
      y += line.lineHeight - line.y;
    }
    
  }
  
  private function addPiece(text:String, font:BitmapFont, tint:Int, align:BFontTextAlign):Void
  {
    var line:BFontTextLine = lines[lineCount];
    if (line == null)
    {
      line = new BFontTextLine(align);
      lines.push(line);
      lineCount++;
    }
    var tlines:Array<String> = wordWrap ? BFontDimensions.wordWrap(text, font, width) : text.split("\n");
    
    for (tline in tlines)
    {
      var piece:BFontTextPiece = new BFontTextPiece(font, text);
      piece.setColor(tint);
      line.addPiece(piece);
      //for (c in piece.chars) trace(c.x, c.y, String.fromCharCode(c.char.id));
      
      if (line.width + line.x > textWidth) textWidth = line.width + line.x;
      
      line = lines[lineCount];
      if (line == null && tline != tlines[tlines.length - 1])
      {
        line = new BFontTextLine(align);
        lines.push(line);
        lineCount++;
      }
    }
    // TODO: More precise calc
    textHeight = 0;
    var i:Int = 0;
    var l:Int = lineCount;
    while (i < l)
    {
      textHeight += lines[i++].lineHeight;
    }
  }
  
}
