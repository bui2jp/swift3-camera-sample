//
//  CameraViewController.swift
//  camera_sample
//
//  Created by Takuya on 2017/06/09.
//  Copyright © 2017年 Takuya. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia
import CoreImage
import AssetsLibrary
import CoreLocation
import ImageIO
import Photos


class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    let classname = "CameraViewController:"

    @IBOutlet weak var imgThumb: UIImageView!

    
    var myApp: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var input:AVCaptureDeviceInput!
    var output:AVCapturePhotoOutput!
    var session:AVCaptureSession!
    
    //var preView:UIView!
    //@IBOutlet weak var preView: UIView!
    //@IBOutlet weak var preView: UIView!
    @IBOutlet weak var cameraView: UIView!
    
    var camera:AVCaptureDevice!
    
    @IBOutlet weak var resolutionText: UITextField!
    @IBOutlet weak var locInfo: UISwitch!
    @IBAction func resoChanged(_ sender: Any) {
        myApp.cam_resolution = resolutionText.text!
        
        //TODO: viewをクリアする
        //cameraView
        
        
        setupCamera()
    }
    
    @IBAction func locInfoChanged(_ sender: Any) {
        myApp.cam_geoInfo = locInfo.isOn
    }
    
    //@IBOutlet weak var cameraView: UIImageView!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var albumBtn: UIButton!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(classname, #function)

        // Do any additional setup after loading the view.
        
        let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera
        // カメラが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            
            //cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
            
        }
        else{
            //label.text = "error"
            print("error")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(classname, #function)
        // スクリーン設定
        setupDisplay()
        // カメラの設定
        setupCamera()
    }
    
    
    func setupDisplay(){
        print(classname, #function)
        //スクリーンの幅
        let screenWidth = UIScreen.main.bounds.size.width;
        //let screenWidth = cameraView.bounds.size.height
        //let screenWidth = preView.bounds.size.height
        //スクリーンの高さ
        let screenHeight = UIScreen.main.bounds.size.height;
        //let screenHeight = cameraView.bounds.size.height
        //let screenHeight = preView.bounds.size.height
        
        // プレビュー用のビューを生成
        //preView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight))
        
    }
    
    // camera initialize
    func setupCamera(){
        print(classname, #function)
        // セッション
        session = AVCaptureSession()

        //MARK: 写真の解像度の変更
        // sessionPreset: キャプチャ・クオリティの設定
        switch myApp.cam_resolution {
        case "1":
            session.sessionPreset = AVCaptureSessionPresetPhoto
            break
        case "2":
            session.sessionPreset = AVCaptureSessionPresetHigh
            break
        case "3":
            session.sessionPreset = AVCaptureSessionPresetMedium
            break
        case "4":
            session.sessionPreset = AVCaptureSessionPresetLow
            break
        default:
            session.sessionPreset = AVCaptureSessionPresetHigh
        }
        

        // 背面・前面カメラの選択
        camera = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera,
                                               mediaType: AVMediaTypeVideo,
                                               position: .back) // position: .front
        
        // カメラからの入力データ
        do {
            input = try AVCaptureDeviceInput(device: camera)
            
        } catch let error as NSError {
            print(error)
        }
        
        // 入力をセッションに追加
        if(session.canAddInput(input)) {
            session.addInput(input)
        }
        
        // 静止画出力のインスタンス生成
        output = AVCapturePhotoOutput()
        
        // 出力をセッションに追加
        if(session.canAddOutput(output)) {
            session.addOutput(output)
        }
        
        // セッションからプレビューを表示を
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        //previewLayer?.frame = preView.frame
        previewLayer?.frame = cameraView.frame
        
        //AVLayerVideoGravityResize アスペクト比を変えてレイヤーに納める
        //AVLayerVideoGravityResizeAspect アスペクト比は変えない。レイヤーに納める
        //AVLayerVideoGravityResizeAspectFill アスペクト比は変えない。レイヤーからはみ出した部分は隠す。
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        
        // レイヤーをViewに設定
        // TODO:これを外すとプレビューが無くなる、けれど撮影はできる
        self.view.layer.addSublayer(previewLayer!)
        
        //セッションの開始
        session.startRunning()
    }
    
    @IBAction func btnSave(_ sender: Any) {
        print(classname, #function)
        takeStillPicture()
    }
    
    func takeStillPicture(){
        print(classname, #function)
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .auto
        photoSettings.isAutoStillImageStabilizationEnabled = true
        
        output?.capturePhoto(with: photoSettings, delegate: self)
    }
    
    // AVCapturePhotoCaptureDelegate
    func capture(_ captureOutput: AVCapturePhotoOutput,
                 didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?,
                 previewPhotoSampleBuffer: CMSampleBuffer?,
                 resolvedSettings: AVCaptureResolvedPhotoSettings,
                 bracketSettings: AVCaptureBracketedStillImageSettings?,
                 error: Error?) {
        print(classname, #function)
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        //フォトライブラリに追加する
        savePhoto(imageDataBuffer: photoSampleBuffer!)
    }

    func savePhoto(imageDataBuffer: CMSampleBuffer) {
        print(classname, #function)
        
        //位置情報等の作成
        //let metaData = createExifInfo()
        
        if let imageData =
            AVCapturePhotoOutput.jpegPhotoDataRepresentation(
                forJPEGSampleBuffer: imageDataBuffer,
                previewPhotoSampleBuffer: nil),
            let photo = UIImage(data: imageData) {
            
            // MARK:Photoアルバムに追加.　追加が完了するとimageToPhoto()がコールされる
            //UIImageWriteToSavedPhotosAlbum(photo, self, nil, nil)
            //UIImageWriteToSavedPhotosAlbum(photo, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
            UIImageWriteToSavedPhotosAlbum(photo, self, #selector(CameraViewController.imageToPhoto(_:didFinishSavingWithError:contextInfo:)), nil)

        }
    }
    
    func imageToPhoto(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        print(classname, #function)
        
        //MARK:Photoアルバムに追加後の処理
        //MARK:カメラロールに追加されたイメージファイルの管理
        
        if error != nil {
            /* 失敗 */
            print(error)
        }
        
        //MARK:位置情報(Exif)を追加
        if !myApp.cam_geoInfo {
            return
        }
        
        //Exif情報を書き換える
        // fetch the most recent image asset: 最新のイメージのassetを取得する
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        let lastImageAsset = fetchResult.lastObject!
        
        //MARK:  位置情報の編集
        // create CLLocation from lat/long coords:
        // (could fetch from LocationManager if needed)
        //Latitude 緯度　Longitude 経度
        //let coordinate = CLLocationCoordinate2DMake(myLatitude, myLongitude)
        let coordinate = CLLocationCoordinate2DMake(28.642140, 77.223267)
        //let coordinate = CLLocationCoordinate2DMake(0.000001, 0.000001)
        //New Deli (28.642140, 77.223267)
        let nowDate = Date()
        // I add some defaults for time/altitude/accuracies:
        let myLocation = CLLocation(coordinate: coordinate, altitude: 0.0, horizontalAccuracy: 1.0, verticalAccuracy: 1.0, timestamp: nowDate)

        // make change request:
        PHPhotoLibrary.shared().performChanges({
            
            // modify existing asset:
            //let assetChangeRequest = PHAssetChangeRequest(forAsset: lastImageAsset)
            let assetChangeRequest = PHAssetChangeRequest.init(for: lastImageAsset)
            assetChangeRequest.location = myLocation
            //assetChangeRequest.
        }, completionHandler: ({
            (success:Bool, error:Error?) -> Void in
            
            if (success) {
                print("Succesfully saved metadata to asset")
                print("location metadata = \(myLocation)")
            } else {
                print("Failed to save metadata to asset with error: \(error!)")
            }
        }))
        
        
        //MARK: フォトライブラリーから特定のイメージを取り出す
        PHImageManager().requestImage(for: lastImageAsset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFill, options: nil, resultHandler: {(image, info)in
            print("...got image...")
            print(info)
            
            //self.imgThumbnail = UIImageView(image: result)
            self.imgThumb.image = image
                
            print("...got image...end")
        })
    }

    /*
    func image(image: UIImage, didFinishSavingWithError: NSErrorPointer, contextInfo:UnsafePointer<Void>)       {
        
        if (didFinishSavingWithError != nil) {
            print("Error saving photo: \(didFinishSavingWithError)")
        } else {
            print("Successfully saved photo, will make request to update asset metadata")
            
            /*
            // fetch the most recent image asset:
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.image, options: fetchOptions)
            
            // get the asset we want to modify from results:
            let lastImageAsset = fetchResult.lastObject as! PHAsset
            
            // create CLLocation from lat/long coords:
            // (could fetch from LocationManager if needed)
            let coordinate = CLLocationCoordinate2DMake(myLatitude, myLongitude)
            let nowDate = NSDate()
            // I add some defaults for time/altitude/accuracies:
            let myLocation = CLLocation(coordinate: coordinate, altitude: 0.0, horizontalAccuracy: 1.0, verticalAccuracy: 1.0, timestamp: nowDate)
            
            // make change request:
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                
                // modify existing asset:
                let assetChangeRequest = PHAssetChangeRequest(forAsset: lastImageAsset)
                assetChangeRequest.location = myLocation
                
            }, completionHandler: {
                (success:Bool, error:NSError?) -> Void in
                
                if (success) {
                    print("Succesfully saved metadata to asset")
                    print("location metadata = \(myLocation)")
                } else {
                    print("Failed to save metadata to asset with error: \(error!)")
                }
                
            })
             */
        }
    }
    */
    
    /*
    func createExifInfo() -> NSMutableDictionary
    {
        //EXIF情報を作成する
        let exif = NSMutableDictionary()
        
        //Exifに写真のコメントをセットする
        exif.setObject("I love Waikiki Beach",forKey:kCGImagePropertyExifUserComment as! NSCopying)
        
        //メタデータを作成する
        let metaData = NSMutableDictionary()
        metaData.setObject(exif,forKey:kCGImagePropertyExifDictionary as! NSCopying)
        
        //ワイキキビーチの位置情報を作成する
        let gps = NSMutableDictionary()
        gps.setObject("N",forKey:kCGImagePropertyGPSLatitudeRef as! NSCopying)
        gps.setObject(21.275468,forKey:kCGImagePropertyGPSLatitude as! NSCopying)
        gps.setObject("W",forKey:kCGImagePropertyGPSLongitudeRef as! NSCopying)
        gps.setObject(157.825294,forKey:kCGImagePropertyGPSLongitude as! NSCopying)
        gps.setObject(0,forKey:kCGImagePropertyGPSAltitudeRef as! NSCopying)
        gps.setObject(0,forKey:kCGImagePropertyGPSAltitude as! NSCopying)
    
        //ExifにGPS情報をセットする
        exif.setObject(gps,forKey:kCGImagePropertyGPSDictionary as! NSCopying);
        
        return metaData
    }
    */
    
    @IBAction func btnAction(_ sender: Any) {
        print(classname, #function)
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print(classname, #function)
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
