package;

import com.bit101.components.CheckBox;
import com.bit101.components.ColorChooser;
import com.bit101.components.HBox;
import com.bit101.components.InputText;
import com.bit101.components.Label;
import com.bit101.components.List;
import com.bit101.components.NumericStepper;
import com.bit101.components.PushButton;
import com.bit101.components.Style;
import com.bit101.components.TextArea;
import com.bit101.components.VBox;
import com.yanrishatum.bfont.BFont;
import com.yanrishatum.bfont.BFontGlyph;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Graphics;
import haxe.Utf8;
import haxe.io.Path;
import openfl.display.Sprite;
import openfl.Lib;
import openfl.events.Event;
import openfl.events.TextEvent;
import openfl.geom.Matrix;
import sys.FileSystem;
import sys.io.File;
import unifill.Unicode;
using unifill.Unifill;

using Std;

/**
 * ...
 * @author Yanrishatum
 */
class Main extends Sprite 
{

  private var status:Label;
  private var saveButton:PushButton;
  private var bgColorPick:ColorChooser;
  
  private var mainControls:VBox;
  
  private var fontContainer:Sprite;
  private var fontImage:Bitmap;
  private var fontOverlay:Sprite;
  
  private var previewContents:TextArea;
  private var preview:Sprite;
  
  private var spaceSize:NumericStepper;
  private var lineHeight:NumericStepper;
  private var leading:NumericStepper;
  
  private var letters:List;
  private var newLetter:PushButton;
  private var saveLetter:PushButton;
  private var letterId:InputText;
  private var letterX:NumericStepper;
  private var letterY:NumericStepper;
  private var letterWidth:NumericStepper;
  private var letterHeight:NumericStepper;
  private var letterSpacing:NumericStepper;
  private var letterOriginX:NumericStepper;
  private var letterOriginY:NumericStepper;
  private var letterAuto:CheckBox;
  
  private var font:BFont;
  private var fontPath:String;
  private var letter:BFontGlyph;
  private var source:BitmapData;
  
  private var left:VBox;
  private var right:VBox;
  
	public function new() 
	{
		super();
    Lib.application.window.onDropFile.add(handleDrop);
    Style.fontName = "Arial";
    Style.fontSize = 12;
    Style.setStyle(Style.DARK);
    Style.LABEL_TEXT = 0xBBBBBB;
    
    var vbox:VBox = new VBox(this);
    var hbox:HBox = new HBox(vbox);
    status = new Label(hbox);
    status.text = "Drop file to start working";
    saveButton = new PushButton(hbox, "Save", onSave);
    bgColorPick = new ColorChooser(hbox, 0, 0, Style.BACKGROUND, updateBgColor);
    
    vbox = mainControls = new VBox(vbox);
    mainControls.enabled = false;
    
    hbox = new HBox(vbox);
    
    left = vbox = new VBox(hbox);
    fontContainer = new Sprite();
    vbox.addChild(fontContainer);
    fontImage = new Bitmap();
    fontImage.scaleX = 2;
    fontImage.scaleY = 2;
    fontOverlay = new Sprite();
    fontContainer.addChild(fontImage);
    fontContainer.addChild(fontOverlay);
    
    previewContents = new TextArea(vbox, "Quick brown fox jumps over the lazy dog");
    previewContents.textField.addEventListener(Event.CHANGE, render);
    previewContents.textField.multiline = true;
    preview = new Sprite();
    preview.scaleX = preview.scaleY = 2;
    vbox.addChild(preview);
    
    right = vbox = new VBox(hbox);
    var hbox2:HBox = new HBox(vbox);
    var l:Label = new Label(hbox2, "Space width: ");
    l.autoSize = false;
    l.setSize(100, l.height);
    spaceSize = new NumericStepper(hbox2, handleSpaceSize);
    spaceSize.minimum = 0;
    spaceSize.maximum = 1000;
    
    hbox2 = new HBox(vbox);
    l = new Label(hbox2, "Min line height: ");
    l.autoSize = false;
    l.setSize(100, l.height);
    trace(l.width);
    lineHeight = new NumericStepper(hbox2, handleLineHeight);
    lineHeight.minimum = 0;
    lineHeight.maximum = 1000;
    
    hbox2 = new HBox(vbox);
    l = new Label(hbox2, "Leading: ");
    l.autoSize = false;
    l.setSize(100, l.height);
    leading = new NumericStepper(hbox2, handleLeading);
    leading.minimum = 0;
    leading.maximum = 1000;
    
    letters = new List(vbox, 0, 0, []);
    letters.addEventListener(Event.SELECT, selectLetter);
    
    letterId = new InputText(vbox, updateLetter);
    
    hbox2 = new HBox(vbox);
    new Label(hbox2, "Pos:").width = 40;
    letterX = new NumericStepper(hbox2, updateLetter);
    letterY = new NumericStepper(hbox2, updateLetter);
    
    hbox2 = new HBox(vbox);
    new Label(hbox2, "Size:").width = 40;
    letterWidth = new NumericStepper(hbox2, updateLetter);
    letterHeight = new NumericStepper(hbox2, updateLetter);
    
    hbox2 = new HBox(vbox);
    new Label(hbox2, "Origin:").width = 40;
    letterOriginX = new NumericStepper(hbox2, updateLetter);
    letterOriginY = new NumericStepper(hbox2, updateLetter);
    
    hbox2 = new HBox(vbox);
    new Label(hbox2, "Spacing:");
    letterSpacing = new NumericStepper(hbox2, updateLetter);
    letterAuto = new CheckBox(hbox2, "Autoupdate");
    letterAuto.selected = true;
    
    hbox2 = new HBox(vbox);
    newLetter = new PushButton(hbox2, "New glyph", onNewLetter);
    saveLetter = new PushButton(hbox2, "Save glyph", onSaveLetter);
    
    hbox2 = new HBox(vbox);
    new PushButton(hbox2, "Delete glyph", deleteLetter);
    
    Lib.current.stage.addEventListener(Event.RESIZE, onResize);
    onResize(null);
    
    var args:Array<String> = Sys.args();
    if (args.length > 0)
    {
      handleDrop(args[0]);
    }
    //#if debug
    //handleDrop("img/information.png");
    //#end
    //trace( "À".toLowerCase());
    //trace("À");
    //trace("A: " + Utf8.charCodeAt("À", 0));
    //trace("A.lower: " + Utf8.charCodeAt("À".toLowerCase(), 0));
    //trace("a: " + Utf8.charCodeAt("à", 0));
    //trace("a.upper: " + Utf8.charCodeAt("à".toUpperCase(), 0));
		// Assets:
		// openfl.Assets.getBitmapData("img/assetname.jpg");
	}
  
  private function updateBgColor(e:Dynamic):Void
  {
    fontContainer.graphics.clear();
    fontContainer.graphics.beginFill(bgColorPick.value, 1);
    fontContainer.graphics.drawRect(0, 0, fontImage.width, fontImage.height);
    fontContainer.graphics.endFill();
    if (font != null) render();
  }
  
  private function onSave(e:Dynamic):Void
  {
    if (font != null)
    {
      File.saveContent(fontPath, font.save());
    }
  }
  
  private function updateLetter(e:Dynamic):Void
  {
    if (letter == null) onNewLetter(null);
    letter.x = letterX.value.int();
    letter.y = letterY.value.int();
    letter.width = letterWidth.value.int();
    letter.height = letterHeight.value.int();
    letter.originX = letterOriginX.value.int();
    letter.originY = letterOriginY.value.int();
    letter.spacing = letterSpacing.value.int();
    if (letterId.text.length != 0)
    {
      if (letterId.text.length > 1)
      {
        var len:Int = Utf8.length(letterId.text);
        letterId.text = Utf8.sub(letterId.text, len - 1, 1);
        letterId.textField.setSelection(1, 1);
      }
      var code:Int = Utf8.charCodeAt(letterId.text, 0);
      if (code != letter.id && letterAuto.selected)  onSaveLetter(null);
      letter.id = code;
    }
    
    drawOutline();
  }
  
  private function deleteLetter(e:Dynamic):Void
  {
    if (letter != null && font.glyphs.exists(letter.id))
    {
      font.glyphs.remove(letter.id);
      updateLetterList();
      onNewLetter(null);
    }
  }
  
  private function drawOutline():Void
  {
    var g:Graphics = fontOverlay.graphics;
    var scale:Float = fontImage.scaleX;
    g.clear();
    g.beginFill(0xff0000, 0.3);
    g.drawRect(letter.x * scale, letter.y * scale, letter.width * scale, letter.height * scale);
    g.endFill();
    if (letterAuto.selected) onSaveLetter(null);
  }
  
  private function selectLetter(e:Dynamic):Void
  {
    var code:String = letters.selectedItem;
    if (code == null || code == "")
    {
      onNewLetter(null);
      return;
    }
    var c:Int = Utf8.charCodeAt(code, 0);
    var original:BFontGlyph = font.glyphs.get(c);
    if (original == null)
    {
      onNewLetter(null);
      return;
    }
    
    letter = cloneLetter(original);
    syncLetter();
    drawOutline();
  }
  
  private function cloneLetter(original:BFontGlyph):BFontGlyph
  {
    var l:BFontGlyph = new BFontGlyph();
    l.x = original.x;
    l.y = original.y;
    l.width = original.width;
    l.height = original.height;
    l.originX = original.originX;
    l.originY = original.originY;
    l.spacing = original.spacing;
    l.id = original.id;
    return l;
  }
  
  private function onNewLetter(e:Dynamic):Void
  {
    letter = new BFontGlyph();
    letter.x = 0;
    letter.y = 0;
    letter.width = 1;
    letter.height = 1;
    letter.originX = 0;
    letter.originY = 0;
    letter.spacing = 0;
    letter.id = 0;
    syncLetter();
    drawOutline();
  }
  
  private function onSaveLetter(e:Dynamic):Void
  {
    if (letter != null && letter.id != 0)
    {
      var update:Bool = !font.glyphs.exists(letter.id);
      font.glyphs.set(letter.id, cloneLetter(letter));
      if (update) updateLetterList();
      render();
    }
  }
  
  private function updateLetterList():Void
  {
    while (letters.items.length > 0) letters.removeItemAt(0);
    for (l in font.glyphs)
    {
      var utf:Utf8 = new Utf8();
      utf.addChar(l.id);
      letters.addItem(utf.toString() + ' (${l.id}; ${l.x}-${l.y}-${l.width}-${l.height})');
    }
  }
  
  private function syncLetter():Void
  {
    letterX.value = letter.x;
    letterY.value = letter.y;
    letterWidth.value = letter.width;
    letterHeight.value = letter.height;
    letterOriginX.value = letter.originX;
    letterOriginY.value = letter.originY;
    letterSpacing.value = letter.spacing;
    if (letter.id != 0)
    {
      var utf:Utf8 = new Utf8();
      utf.addChar(letter.id);
      letterId.text = utf.toString();
    }
    else letterId.text = "";
  }
  
  private function onResize(e:Dynamic):Void
  {
    var w:Float = Lib.current.stage.stageWidth;
    var h:Float = Lib.current.stage.stageHeight;
    mainControls.setSize(w, h);
    left.setSize(w * 0.7, h);
    right.setSize(w * 0.3, h);
    previewContents.setSize(w * 0.7, 50);
    letters.setSize(w * 0.3 - 5, h * .5);
    updateBgColor(null);
    if (fontImage.bitmapData != null) sizeImage();
  }
  
  private function sizeImage():Void
  {
    var zoom:Float = Math.ffloor(Math.min(left.width / fontImage.bitmapData.width, left.height * .5 / fontImage.bitmapData.height));
    //trace(zoom);
    fontImage.scaleX = fontImage.scaleY = zoom;
  }
  
  private function handleSpaceSize(e:Dynamic):Void
  {
    font.spaceSize = spaceSize.value.int();
    render();
  }
  
  private function handleLineHeight(e:Dynamic):Void
  {
    font.lineHeight = lineHeight.value.int();
    render();
  }
  
  private function handleLeading(e:Dynamic):Void
  {
    font.leading = leading.value.int();
    render();
  }
  
  private function handleDrop(path:String):Void
  {
    if (FileSystem.isDirectory(path)) return;
    var ext:String = Path.extension(path);
    
    var bfont:String;
    var png:String;
    if (ext == "png")
    {
      bfont = Path.withoutExtension(path) + ".bfont";
      png = path;
    }
    else if (ext == "bfont")
    {
      bfont = path;
      png = Path.withoutExtension(path) + ".png";
    }
    else return;
    fontPath = bfont;
    
    if (FileSystem.exists(bfont)) loadBfont(bfont, png);
    else createBfont(png);
  }
  
  private function createBfont(png:String):Void
  {
    font = new BFont();
    font.leading = 0;
    font.lineHeight = 0;
    font.spaceSize = 0;
    source = BitmapData.fromFile(png);
    status.text = "Creating new font";
    boot();
  }
  
  private function loadBfont(bfontPath:String, pngPath:String):Void
  {
    font = new BFont();
    font.load(File.getContent(bfontPath));
    source = BitmapData.fromFile(pngPath);
    status.text = "Editing existing font";
    boot();
  }
  
  @:access(com.bit101.components.Component)
  private function boot():Void
  {
    fontImage.bitmapData = source;
    sizeImage();
    lineHeight.value = font.lineHeight;
    leading.value = font.leading;
    spaceSize.value = font.spaceSize;
    updateLetterList();
    mainControls.enabled = true;
    mainControls.invalidate();
    left.invalidate();
    updateBgColor(null);
    //render();
  }
  
  private var m:Matrix = new Matrix();
  private function render(?e:Dynamic):Void
  {
    var g:Graphics = preview.graphics;
    g.clear();
    var text:String = previewContents.text;
    var len:Int = Utf8.length(text);
    
    g.beginFill(bgColorPick.value);
    g.drawRect(0, 0, Lib.current.stage.stageWidth * .7, Lib.current.stage.stageHeight);
    g.endFill();
    var x:Int = 0;
    var h:Int = font.lineHeight;
    var y:Int = 0;
    
    for (i in 0...len)
    {
      var char:Int = Utf8.charCodeAt(text, i);
      if (font.glyphs.exists(char))
      {
        var letter:BFontGlyph = font.glyphs.get(char);
        x -= letter.originX;
        y -= letter.originY;
        m.identity();
        m.translate(x - letter.x, y - letter.y);
        g.beginBitmapFill(source, m);
        g.drawRect(x, y, letter.width, letter.height);
        g.endFill();
        y += letter.originY;
        x += letter.width + letter.spacing;
        if (letter.height - letter.originY > h) h = letter.height - letter.originY;
      }
      else if (char == " ".code)
      {
        x += font.spaceSize;
        continue;
      }
      else if (char == "\n".code)
      {
        y += h + font.leading;
        h = font.lineHeight;
        x = 0;
        continue;
      }
      else if (char != "\r".code)
      {
        g.beginFill(0xff0000);
        g.drawRect(x, y, 10, 10);
        g.endFill();
        x += 11;
        if (11 > h) h = 11;
        continue;
      }
    }
  }
}
