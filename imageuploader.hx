// extern class newsimage extends MovieClip {}
import Math;
import StringTools;
import flash.Error;
import flash.display.MovieClip;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.HTTPStatusEvent;
import flash.events.ProgressEvent;
import flash.text.TextField;
import flash.net.FileReference;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.FileFilter;
import flash.display.Loader;
import lib.encode.JPGEncoder;
import flash.geom.Matrix;
import flash.utils.ByteArray;
import flash.utils.Endian;

class UploadPostHelper
{

		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------

		/**
		 * Boundary used to break up different parts of the http POST body
		 */
		private static var _boundary:String = "";

		/**
		 * Get the boundary for the post.
		 * Must be passed as part of the contentType of the UrlRequest
		 */
		public static function getBoundary():String {

			if(_boundary.length == 0) {
				for ( i in 0...0x20 ) {
					_boundary += String.fromCharCode( Math.round( 97 + Math.random() * 25 ) );
				}
			}

			return _boundary;
		}

		/**
		 * Create post data to send in a UrlRequest
		 */
		public static function getPostData(fileName:String, byteArray:ByteArray, parameters:Hash<String> = null):ByteArray {

			var i:Int;
			var bytes:String;

			var postData:ByteArray = new ByteArray();
			postData.endian = Endian.BIG_ENDIAN;

			//add Filename to parameters
			if(parameters == null) {
				parameters = new Hash<String>();
			}
			parameters.set("Filename",  fileName );                        
			//add parameters to postData
			for( key in parameters.keys() ) {
				postData = BOUNDARY(postData);
				postData = LINEBREAK(postData);
				bytes = 'Content-Disposition: form-data; name="' + key + '"';                                
				for ( i in 0...(bytes.length) ) {
					postData.writeByte( bytes.charCodeAt(i) );
				}
				postData = LINEBREAK(postData);
				postData = LINEBREAK(postData);
				postData.writeUTFBytes( parameters.get( key ) );
				postData = LINEBREAK(postData);
			}

			//add Filedata to postData
			postData = BOUNDARY(postData);
			postData = LINEBREAK(postData);
			bytes = 'Content-Disposition: form-data; name="Filedata"; filename="';
			for ( i in 0...(bytes.length) ) {
				postData.writeByte( bytes.charCodeAt(i) );
			}
			postData.writeUTFBytes(fileName);
			postData = QUOTATIONMARK(postData);
			postData = LINEBREAK(postData);
			bytes = 'Content-Type: application/octet-stream';
			for ( i in 0...(bytes.length) ) {
				postData.writeByte( bytes.charCodeAt(i) );
			}
			postData = LINEBREAK(postData);
			postData = LINEBREAK(postData);
			postData.writeBytes(byteArray, 0, byteArray.length);
			postData = LINEBREAK(postData);

			//add upload filed to postData
			postData = LINEBREAK(postData);
			postData = BOUNDARY(postData);
			postData = LINEBREAK(postData);
			bytes = 'Content-Disposition: form-data; name="Upload"';
			for ( i in 0...(bytes.length) ) {
				postData.writeByte( bytes.charCodeAt(i) );
			}
			postData = LINEBREAK(postData);
			postData = LINEBREAK(postData);
			bytes = 'Submit Query';
			for ( i in 0...(bytes.length) ) {
				postData.writeByte( bytes.charCodeAt(i) );
			}
			postData = LINEBREAK(postData);

			//closing boundary
			postData = BOUNDARY(postData);
			postData = DOUBLEDASH(postData);

			return postData;
		}

		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------

		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------

		/**
		 * Add a boundary to the PostData with leading doubledash
		 */
		private static function BOUNDARY(p:ByteArray):ByteArray {
			var l:Int = UploadPostHelper.getBoundary().length;

			p = DOUBLEDASH(p);
			for ( i in 0...l ) {
				p.writeByte( _boundary.charCodeAt( i ) );
			}
			return p;
		}

		/**
		 * Add one linebreak
		 */
		private static function LINEBREAK(p:ByteArray):ByteArray {
			p.writeShort(0x0d0a);
			return p;
		}

		/**
		 * Add quotation mark
		 */
		private static function QUOTATIONMARK(p:ByteArray):ByteArray {
			p.writeByte(0x22);
			return p;
		}

		/**
		 * Add Double Dash
		 */
		private static function DOUBLEDASH(p:ByteArray):ByteArray {
			p.writeShort(0x2d2d);
			return p;
		}
}




class ImageUploader {

       static var localImageFile : flash.net.FileReference;
       static var localImageFileLoader : Loader;
       static var container : MovieClip;
       static var hiddenLoader : Loader;
       static var hiddenContainer : MovieClip;
       static var urlLoader : URLLoader;
       static var urlRequest : URLRequest;
       static var bmd : BitmapData;
       static var byteArray : ByteArray;
       static var progress : MovieClip;
       static var finalWidth : Int;
       static var finalHeight : Int;
       static var action : String;
       static var debug : Bool;
       static var upload : MovieClip;
       static var browse : MovieClip;
       static var userDefinedBackgroundImage:Loader;
       static var backgroundImage : MovieClip;

    static function main() {
      flash.Lib.current.loaderInfo.addEventListener(Event.COMPLETE, flashLoaderComplete);
      debug = false;
      if( debug ) trace(" " );
      if( debug ) trace(" " );
      if( debug ) trace(flash.Lib.current.loaderInfo.parameters);

         if( debug ) trace( "Flash-object size: w="+flash.Lib.current.stage.stageWidth+",h="+flash.Lib.current.stage.stageHeight);

         hiddenContainer = new MovieClip();
         hiddenContainer.graphics.beginFill(0xcccccc);
         hiddenContainer.graphics.drawRect(0, 0, 10, 10);
         hiddenContainer.graphics.endFill();
         hiddenContainer.x = 0;
         hiddenContainer.y = 0;
         hiddenContainer.width = flash.Lib.current.stage.stageWidth;
         hiddenContainer.height = flash.Lib.current.stage.stageHeight;
         flash.Lib.current.addChild(hiddenContainer);
         hiddenLoader = new Loader();
         hiddenLoader.x = 0;
         hiddenLoader.y = 0;
         hiddenLoader.width = 150;
         hiddenLoader.height = 150;
         hiddenContainer.addChild( hiddenLoader );

         backgroundImage = flash.Lib.attach("missingphoto");
         backgroundImage.x = 0;
         backgroundImage.y = 0;
         backgroundImage.width = flash.Lib.current.stage.stageWidth;
         backgroundImage.height = flash.Lib.current.stage.stageHeight;
         flash.Lib.current.addChild(backgroundImage);

         userDefinedBackgroundImage = new Loader();
         userDefinedBackgroundImage.x = 0;
         userDefinedBackgroundImage.y = 0;
         flash.Lib.current.addChild(userDefinedBackgroundImage);

         container = new MovieClip();
         container.x = 0;
         container.y = 0;
         container.width = flash.Lib.current.stage.stageWidth;
         container.height = flash.Lib.current.stage.stageHeight;
         flash.Lib.current.addChild(container);

         localImageFile = new flash.net.FileReference();
         localImageFile.addEventListener( flash.events.Event.SELECT, filedialoglistener);
         localImageFile.addEventListener( flash.events.Event.COMPLETE , fileLoadedCompletelyIntoFlash);

         browse = flash.Lib.attach("browse");
         browse.x = 0;
         browse.y = 0;
         flash.Lib.current.addChild(browse);
         browse.addEventListener(flash.events.MouseEvent.CLICK, clickBrowseForFiles);

         upload = flash.Lib.attach("upload");
         upload.x = 80;
         upload.y = 0;
         flash.Lib.current.addChild(upload);
         upload.addEventListener(flash.events.MouseEvent.CLICK, clickSendImage);
         upload.visible = false;

         progress = flash.Lib.attach("progress");
         progress.x = flash.Lib.current.stage.stageWidth / 2 - 50;
         progress.y = flash.Lib.current.stage.stageHeight / 2 - 50;
         flash.Lib.current.addChild(progress);
         progress.visible = false;

         localImageFileLoader = new Loader();
         localImageFileLoader.x = 0;
         localImageFileLoader.y = 0;
         localImageFileLoader.width = 150;
         localImageFileLoader.height = 150;
         container.addChild( localImageFileLoader );
    }

     static function flashLoaderComplete(myEvent:Event)
     {
            var params:Dynamic<String> = flash.Lib.current.loaderInfo.parameters;
            finalWidth = Std.parseInt( params.finalwidth );
            finalHeight = Std.parseInt( params.finalheight );
            var debugValue = Std.parseInt( params.debug );
            if( debugValue > 0 ) { 
              debug = true;
              trace( "" );
              trace( "debug = yes" );
            }
            if( debug ) trace(" finalwidth = "+finalWidth );
            if( debug ) trace(" finalheight = "+finalHeight );

            action = StringTools.replace( params.action, "_:_", "&" );
            if( action.length() <=0 ) {
              trace( "" );
              trace( "no action defined ! e.g. action=image.php" );
            }
            if( debug ) trace(" action = "+action );

            var url:String = params.initialimage;
            if( debug ) trace(" missingimage = "+url );
            var urlReq:URLRequest = new URLRequest(url);
            userDefinedBackgroundImage.load(urlReq);
     }



    static function clickSendImage(event:flash.events.MouseEvent)
    {
        if( debug ) trace( "clickSendImage()" );
        progress.play();
        progress.visible = true;
        upload.visible = false;
        browse.visible = false;
        ImageUploader.encodeAndSendImage();

    }

    static function clickBrowseForFiles(event:flash.events.MouseEvent)
    {
        if( debug ) trace( "clickBrowseForFiles()" );
        var fileFilter = [ new FileFilter("Images (*.jpg, *.jpeg)","*.jpg; *.jpeg") ];
        localImageFile.browse(fileFilter);

    }

    static function filedialoglistener(event:flash.events.Event) {

          if( debug ) trace( "About to load " + localImageFile.name + " into flash-object" );
          progress.play();
          progress.visible = true;
          localImageFile.load();
  }

    static function fileLoadedCompletelyIntoFlash(event:flash.events.Event) {
           if( debug ) trace( "File loaded completely into flash!" );
           readSize( localImageFile.data );
           localImageFileLoader.loadBytes(localImageFile.data);
           localImageFileLoader.addEventListener(Event.ADDED_TO_STAGE,loadedIntoFlash);
           localImageFileLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaderComplete);
           hiddenLoader.loadBytes(localImageFile.data);
           hiddenLoader.addEventListener(Event.ADDED_TO_STAGE,loadedIntoFlash);
           hiddenLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaderComplete);

           progress.stop();
           progress.visible = false;
           upload.visible = true;
           browse.visible = true;
    }

    static var sofo : Array<UInt> = [  0xFF, 0xC0  ]; // [  0xFF, 0xC0 , 0x00 , 0x11 , 0x08 ];
    static var imageHeight : Int;
    static var imageWidth : Int;
    static function readSize( data : flash.utils.ByteArray ) {
           var index : Int;
            var s : String;
            s="\n";
           for( i in 0...sofo.length ){
            s = s + ";" + sofo[ i ] ;
           }
           // if( debug ) trace( "sofo="+s  );

            s ="\n";
           var b : UInt;
           var i : UInt = 0;
           index = 0;
           var size : UInt;
           var length : UInt;
           size = data.bytesAvailable;
           if( debug ) trace("size = " + size );
           b = data.readUnsignedByte();
           b = data.readUnsignedByte();
           while( data.bytesAvailable > sofo.length + 4 ) {
                  b = data.readUnsignedByte();
                  // if( debug ) trace("b="+b);
                  i = data.position;
                  if( i % 10 == 0 ) {
                      s = s + "\n" ;
                  }

                  s = s + " " + b;

                  if( b == sofo[ index ] ) {
                    // if( debug ) trace( "found " + index );
                    index++;
                  }else {
                    index=0;
                    b = data.readUnsignedByte();
                    // if( debug ) trace("lb1="+b);
                    length = b << 8;
                    b = data.readUnsignedByte();
                    // if( debug ) trace("lb2="+b);
                    length = length | b;
                    length = length - 2;
                    //if( debug ) trace("length="+length);
                    i = 0;
                    while( i < length ) {// && data.bytesAvailable > sofo.length + 4 ) {
                           b = data.readUnsignedByte();
                           i++;
                    }
                  }
                  if( index >= 2 ) {
                        b = data.readUnsignedByte();
                        b = data.readUnsignedByte();
                        b = data.readUnsignedByte();
                        imageHeight = data.readUnsignedShort();
                        imageWidth = data.readUnsignedShort();
                        if( debug ) trace( "Real image size determined; " + imageWidth + " x " + imageHeight );
                        break;
                  }

           }
           //trace ( "end" );
           //trace ( "s="+s );
    }

    static function loaderComplete(event:flash.events.Event) {
           try {
                 // if( debug ) trace( " Loader complete! "+Type.getClassName(Type.getClass(event.target)));
                 var aLoader : flash.display.Loader = cast( event.target, flash.display.LoaderInfo ).loader;
                 var aContainer : MovieClip;
                 var imageWidthHeightRatio : Float = (imageWidth / imageHeight);
                 var stageWidthHeightRatio : Float = (flash.Lib.current.stage.stageWidth / flash.Lib.current.stage.stageHeight);
                 var finalWidthHeightRatio : Float = (finalWidth / finalHeight);
                 var resizeBasedOnWidth : Bool = true;
                 if( aLoader == localImageFileLoader ) {
                       if( debug ) trace("Loader");
                       if( stageWidthHeightRatio <= imageWidthHeightRatio ) {
                           aLoader.width = flash.Lib.current.stage.stageWidth;
                           resizeBasedOnWidth = true;
                       } else {
                           aLoader.height = flash.Lib.current.stage.stageHeight;
                           resizeBasedOnWidth = false;
                       }
                       aContainer = container;
                 } else {
                       if( debug ) trace("HiddenLoader");
                       if( finalWidthHeightRatio <= imageWidthHeightRatio ) {
                           aLoader.width = finalWidth;
                           resizeBasedOnWidth = true;
                       } else {
                           aLoader.height = finalHeight;
                           resizeBasedOnWidth = false;
                       }
                       aContainer = hiddenContainer;
                 }
                 if( resizeBasedOnWidth ) {
                     if( debug ) trace( "1 w>h! ");
                     aLoader.height = aLoader.width * (imageHeight/imageWidth);
                     aContainer.width = aLoader.width;
                     aContainer.height = aContainer.width * (imageHeight/imageWidth);
                 } else {
                     if( debug ) trace( "2 h>w! ");
                     aLoader.width = aLoader.height * (imageWidth / imageHeight);
                     aContainer.height = aLoader.height;
                     aContainer.width = aContainer.height * (imageWidth / imageHeight);
                 }
                 if( debug ) trace( "new size;" +aLoader.width+ " x "+aLoader.height );
                 if( debug ) trace( "Image loaded completely" );
                 if( debug ) trace( "w="+aContainer.width+",h="+aContainer.height);
           }catch( msg : String ) {
              if( debug ) trace("Error occurred: " + msg);
           }
    }

    static function loadedIntoFlash(ev:Event) {
            if( debug ) trace( "loadedIntoFlash complete" );
     }

     static function encodeAndSendImage() {
       if( debug ) trace( "encodeImage()" );
                 var aLoader : flash.display.Loader;
                 aLoader = localImageFileLoader;
                 if( debug ) trace( "1w="+aLoader.width+",h="+aLoader.height);
                 aLoader = hiddenLoader;
                 if( debug ) trace( "2w="+aLoader.width+",h="+aLoader.height);

            var width : Int = Math.round( hiddenLoader.width );
            var height : Int = Math.round( hiddenLoader.height );
            bmd = new BitmapData( width , height, true, 0xFFFFFFFF );
            bmd.draw( hiddenContainer, new Matrix(), null, null, null, true );
//       if( debug ) trace( "bitmap drawn" );
            byteArray = new JPGEncoder( 90 ).encode( bmd );
       if( debug ) trace( "jpgencoder run size="+byteArray.length );
          // set up the request & headers for the image upload;
          var params:Dynamic<String> = flash.Lib.current.loaderInfo.parameters;
          urlRequest = new URLRequest();
          //urlRequest.url = 'image.php?path=images';
          urlRequest.url = action;
          urlRequest.contentType = 'multipart/form-data; boundary=' + UploadPostHelper.getBoundary();
          urlRequest.method = URLRequestMethod.POST;
          urlRequest.data = UploadPostHelper.getPostData( localImageFile.name, byteArray );
          urlRequest.requestHeaders.push( new URLRequestHeader( 'Cache-Control', 'no-cache' ) );
          // create the image loader & send the image to the server;
       if( debug ) trace( "url: "+ urlRequest.url );
          urlLoader = new URLLoader();
          urlLoader.addEventListener(Event.COMPLETE, urlLoaderComplete );
          urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
          urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
          urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
          urlLoader.addEventListener(ProgressEvent.PROGRESS, onProgressEvent);
       if( debug ) trace("urlLoader eventlisterners created!");
          urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
          try {
                urlLoader.load( urlRequest );
            }
            catch (error:Error) {
                if( debug ) trace( " Unable to load URL: " + error);
            }

       if( debug ) trace( "urlLoader run." );
     }

     static function urlLoaderComplete(ev:Event) {
            progress.stop();
            progress.visible = false;
            if( debug ) trace("urlLoadComplete()");
            if( debug ) trace("event: "+ev.toString() );
            if( debug ) trace("bytesloaded="+urlLoader.bytesLoaded+", bytesTotal="+urlLoader.bytesTotal+"\n");
            // if( debug ) trace("data="+urlLoader.data);
            browse.visible = true;
     }

     static function onIOError(evt:IOErrorEvent)
        {
            trace( " IOError: " + evt.text );
            browse.visible = true;
        }

     static function onSecurityError(evt:SecurityErrorEvent)
        {
            trace( " SecurityErrorEvent.: " + evt.text );
            browse.visible = true;
        }

     static function onHttpStatus(evt:HTTPStatusEvent)
        {
            if( debug ) trace( " HTTPStatusEvent.: status " + evt.status );
            browse.visible = true;
        }

     static function onProgressEvent(evt:ProgressEvent)
        {
            if( debug ) trace( " ProgressEvent.: " + evt.bytesLoaded );
        }
}



