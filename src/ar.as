package
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Camera;
	import flash.media.CameraUI;
	import flash.media.Video;
	import flash.utils.ByteArray;
	
	import org.libspark.flartoolkit.core.FLARCode;
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.core.raster.rgb.FLARRgbRaster_BitmapData;
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	import org.libspark.flartoolkit.detector.FLARSingleMarkerDetector;
	import org.libspark.flartoolkit.support.pv3d.FLARBaseNode;
	import org.libspark.flartoolkit.support.pv3d.FLARCamera3D;
	import org.papervision3d.core.math.Sphere3D;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
	import org.papervision3d.materials.shaders.FlatShader;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Cylinder;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;

	[SWF(width="640",height="480",frameRate="30")]
	public class ar extends Sprite
	{
		[Embed(source="p3.pat", mimeType ="application/octet-stream")]
		private var pattern:Class;
		[Embed(source="camera_para.dat", mimeType ="application/octet-stream")]
		private var params:Class;
		
		private var fparams:FLARParam;
		private var mpattern:FLARCode; 
		private var vid:Video;
		private var came:Camera;
		private var bmd:BitmapData;
		private var raster:FLARRgbRaster_BitmapData;
		private var detector:FLARSingleMarkerDetector;
		private var sce:Scene3D;
		private var camera:FLARCamera3D;
		private var container:FLARBaseNode;
		private var vp:Viewport3D;
		private var bre:BasicRenderEngine;
		private var trans:FLARTransMatResult;
		public var c3m:String = "earth.dae";
		public var colla:DAE;
		
		
		public function ar()
		{
			
			setupcam();
			setupflar();
			setupbmd();
			setuppaper();
			addEventListener(Event.ENTER_FRAME,loop);
			
		}
		private function setupflar():void
		{
			
			fparams = new FLARParam();
			fparams.loadARParam(new params() as ByteArray);
			mpattern = new FLARCode(16,16);
			mpattern.loadARPatt(new pattern());
			
		}
		private function setupcam():void
		{
			vp = new Viewport3D();
			vid = new Video(640,480);
			came = Camera.getCamera();
			came.setMode(640,480,30);
			vid.attachCamera(came);
			addChild(vid);
			
			
		}
		private function setupbmd():void
		{
			bmd = new BitmapData(640,480);
			bmd.draw(vid);
			raster = new FLARRgbRaster_BitmapData(bmd);
			detector = new FLARSingleMarkerDetector(fparams,mpattern,40);
			
			
		}
		public function setuppaper():void
		{
			sce = new Scene3D();
			camera = new FLARCamera3D(fparams);
			container = new FLARBaseNode();
			
			bre = new BasicRenderEngine();
			trans = new FLARTransMatResult();
			
			colla = new DAE();
			colla.load(c3m);
			colla.scaleX = colla.scaleY = colla.scaleZ = 6;
			
			colla.rotationX = 90;  
			colla.rotationY = 0;   
			colla.rotationZ = 45;
			
			colla.z = 5;
			
			colla.pitch(-0.3);
			
			sce.addChild(container);
			container.addChild(colla);
			
			addChild(vp);
			
		}
		private function loop(e:Event):void
		{
			bmd.draw(vid);
			
			colla.yaw(1);
				
			try
			{
			if(detector.detectMarkerLite(raster,80) && detector.getConfidence() > 0.5)
			{
				detector.getTransformMatrix(trans);
				container.setTransformMatrix(trans);
				bre.renderScene(sce,camera,vp);
				
			}
			}
			catch(e:Error){}
		}
				
	}
}