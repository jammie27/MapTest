package ;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;

import map.Canvas;
import map.LngLat;
import map.MapService;
import com.Button;
import com.ToolBar;

/**
 * ...
 * @author eg
 */

class Main extends Sprite 
{
	var inited:Bool;
	var canvas:Canvas;
    var toolbar:ToolBar;
    var layer_osm:map.TileLayer;


	/* ENTRY POINT */
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;

		// (your code here)
		toolbar = new ToolBar();
        canvas = new Canvas();

        toolbar.move(0, 0);
        canvas.move(0, 0);
//        canvas.setCenter(new LngLat(15.5, 49.5));
		canvas.setCenter(new LngLat(7.4635729, 51.5120542 ));
        layer_osm = new map.TileLayer(new OpenStreetMapService(12), 8);
        canvas.addLayer(layer_osm);
        canvas.addLayer(new VectorLayer(new OpenStreetMapService(12)));
        canvas.setZoom(2);
        stageResized(null);

        initToolbar();

        addChild(canvas);
        addChild(toolbar);

        canvas.initialize();
		// Stage:
		// stage.stageWidth x stage.stageHeight @ stage.dpiScale
		
		// Assets:
		// nme.Assets.getBitmapData("img/assetname.jpg");
	}

	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	    public function stageResized(e:Event)
    {
        toolbar.setSize(flash.Lib.current.stage.stageWidth, 30);
        canvas.setSize(flash.Lib.current.stage.stageWidth, flash.Lib.current.stage.stageHeight);
    }

    function initToolbar()
    {
        var me = this;
        toolbar.addButton(new ZoomOutButton(), "Zoom Out", function(b:CustomButton) { me.canvas.zoomOut(); });
        toolbar.addButton(new ZoomInButton(), "Zoom In",  function(b:CustomButton) { me.canvas.zoomIn(); });
        toolbar.addSeparator(30);

        //pan buttons
        toolbar.addButton(new UpButton(), "Move up",  function(b:CustomButton) { me.pan(1); });
        toolbar.addButton(new DownButton(), "Move down",  function(b:CustomButton) { me.pan(2); });
        toolbar.addButton(new LeftButton(), "Move left",  function(b:CustomButton) { me.pan(4); });
        toolbar.addButton(new RightButton(), "Move right",  function(b:CustomButton) { me.pan(8); });

        //layer buttons
        toolbar.addSeparator(50);
        var me = this;
        var tbosm = new TextButton("OSM Layer");
        tbosm.checked = true;
        toolbar.addButton(tbosm, "Open Street Map Layer",  
                          function(b:CustomButton) 
                          { 
                            tbosm.checked = !tbosm.checked;
                            if (tbosm.checked)
                               me.canvas.enableLayer(me.layer_osm); 
                            else 
                               me.canvas.disableLayer(me.layer_osm); 
                          });

    }

    function pan(direction:Int)
    {
       var lt:LngLat = canvas.getLeftTopCorner();
       var br:LngLat = canvas.getRightBottomCorner();
       var p:LngLat  = canvas.getCenter();

       if (direction & 0x3 == 1) p.lat = lt.lat; //up
       if (direction & 0x3 == 2) p.lat = br.lat; //down
       if (direction & 0xC == 4) p.lng = lt.lng; //left
       if (direction & 0xC == 8) p.lng = br.lng; //right

       canvas.panTo(p);
    }

	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}


