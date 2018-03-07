package com.yanrishatum.bfont;
import haxe.io.Eof;
import haxe.io.Input;
import haxe.xml.Fast;

/**
 * ...
 * @author Yanrishatum
 */
class BitmapFont
{
  
  public var info:BitmapFontInfo;
  public var common:BitmapFontCommon;
  public var pages:Map<Int, String>;
  public var chars:Map<Int, BitmapFontChar>;
  
  public function new() 
  {
    info = new BitmapFontInfo();
    common = new BitmapFontCommon();
    pages = new Map();
    chars = new Map();
  }
  
  public function loadFast(f:Fast):Void
  {
    f = f.node.font;
    if (f.hasNode.info) info.loadFast(f.node.info);
    if (f.hasNode.common) common.loadFast(f.node.common);
    for (pageNode in f.node.pages.elements)
    {
      pages.set(Std.parseInt(pageNode.att.id), pageNode.att.file);
    }
    for (charNode in f.node.chars.elements)
    {
      var char:BitmapFontChar = new BitmapFontChar();
      char.loadFast(charNode);
      chars.set(char.id, char);
    }
    if (f.hasNode.kernings)
    {
      for (kerning in f.node.kernings.elements)
      {
        var char:BitmapFontChar = chars.get(Std.parseInt(kerning.att.first));
        if (char != null)
        {
          char.kerning.set(Std.parseInt(kerning.att.second), Std.parseInt(kerning.att.amount));
        }
      }
    }
  }
  
  public function loadBinaryInput(input:Input):Void
  {
    if (input.readString(3) != "BMF") throw "Invalid bitmap font header!";
    var version:Int = input.readByte();
    if (version != 3) throw "Only version 3 supported. Blame documentation, they do not provide old versions specifications.";
    var blockC:Int = 0;
    var blockID:Int;
    do
    {
      try
      {
        blockID = input.readByte();
      }
      catch (e:Eof)
      {
        // End of file
        break;
      }
      if (blockID == 0) break;
      var blockSize:Int = input.readInt32();
      switch (blockID)
      {
        case 1:
          // info
          info.loadBinaryInput(input, version, blockSize);
          blockC |= 1;
        case 2:
          // common
          common.loadBinaryInput(input, version, blockSize);
          blockC |= 2;
        case 3:
          // pages
          var name:String = input.readUntil(0);
          var nameSize:Int = name.length;
          blockSize -= nameSize + 1;
          var nameC:Int = Std.int(blockSize / (nameSize + 1));
          var idx:Int = 1;
          pages.set(0, name);
          while (nameC-- > 0)
          {
            name = input.readUntil(0);
            pages.set(idx++, name);
            blockSize -= name.length + 1;
            if (name.length != nameSize)
            {
              var skip:Int = nameSize - name.length;
              while (skip-- > 0) input.readByte();
            }
          }
          blockC |= 4;
        case 4:
          // chars
          var charCount:Int = Std.int(blockSize / 20);
          while (charCount-- > 0)
          {
            var char:BitmapFontChar = new BitmapFontChar();
            char.loadBinaryInput(input);
            chars.set(char.id, char);
          }
          blockC |= 8;
        case 5:
          // kernings
          var kerningCount:Int = Std.int(blockSize / 10);
          while (kerningCount-- > 0)
          {
            var char:BitmapFontChar = chars.get(input.readInt32());
            if (char != null)
            {
              char.kerning.set(input.readInt32(), input.readInt16());
            }
            else
            {
              input.readInt32();
              input.readInt16();
            }
          }
          blockC |= 16;
        default:
          // Sigh
          while (blockSize-- > 0)
          {
            input.readByte();
          }
      }
    }
    while (blockC != 31);
  }
  
}