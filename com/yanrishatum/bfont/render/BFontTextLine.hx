package com.yanrishatum.bfont.render;

/**
 * ...
 * @author Yanrishatum
 */
class BFontTextLine
{
  
  public var align:BFontTextAlign;
  public var pieces:Array<BFontTextPiece>;
  public var width:Int = 0;
  public var height:Int = 0;
  public var y:Int = 0;
  public var x:Int = 0;
  public var lineHeight:Int = 0;
  public var caret:Int = 0;

  public function new(align:BFontTextAlign) 
  {
    this.align = align;
    this.pieces = new Array();
  }
  
  public function addPiece(piece:BFontTextPiece):Void
  {
    caret = piece.align(this, pieces.length != 0 ? pieces[pieces.length - 1] : null);
    if (pieces.length == 0) x = piece.left;
    width += piece.right;
    
    if (piece.font.common.lineHeight > lineHeight)
    {
      lineHeight = piece.font.common.lineHeight;
    }
    var h:Int = piece.bottom - piece.top;
    if (h > height) height = h;
    
    if (piece.top < y) y = piece.top;
    this.pieces.push(piece);
  }
  
  public function dispose():Void
  {
    for (p in pieces) p.dispose();
    this.pieces = new Array();
  }
  
}