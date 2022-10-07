//
//  CaptureReactions.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 01/10/22.
//

import UIKit
import AVFoundation

class CaptureReactions: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    @IBOutlet weak var camPreview: UIView!
    @IBOutlet weak var startRecordButton: UIImageView!
    @IBOutlet weak var cancelButton: UIImageView!
    @IBOutlet weak var loadingBackground: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewMask: UIView!
    
    
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()

    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    var videoData: Data!
    var videoSize: Double!
    var cameraType: Bool = false
    var post: Post?
    var service = ServiceFirebase()
    var pushNotificationService = PushNotificationSender()
    
    let captureReactionNotificationService = CaptureReactionNotificationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureSession.sessionPreset = AVCaptureSession.Preset.medium
        setStartRecordButton()
        setCancelRecordButton()
        setupPreview2()
        setupLoadingView()
        viewMask.layer.cornerRadius = viewMask.bounds.height/2.1
        viewMask.layer.borderWidth = 5
        viewMask.layer.borderColor = UIColor(named: "primary")?.cgColor
    }
    
    func setupLoadingView() {
        loadingBackground.isHidden = true
        loadingBackground.layer.opacity = 0.8
        activityIndicator.startAnimating()
    }
    
    func setupPreview2() {
        // Do any additional setup after loading the view, typically from a nib.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.setupSession() {
                self.setupPreview()
                self.startSession()
            }
         }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = camPreview.bounds
        previewLayer.videoGravity = .resizeAspectFill
        camPreview.layer.addSublayer(previewLayer)
    }

    //MARK:- Setup Camera

    func setupSession() -> Bool {
        captureSession.sessionPreset = AVCaptureSession.Preset.medium

        let frontalCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)!
        
        do {
            let input = try AVCaptureDeviceInput(device: frontalCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }

        //MARK: - Setup Microphone
//        let microphone = AVCaptureDevice.default(for: .audio)
//
//        do {
//            let micInput = try AVCaptureDeviceInput(device: microphone!)
//            if captureSession.canAddInput(micInput) {
//                captureSession.addInput(micInput)
//            }
//        } catch {
//            print("Error setting device audio input: \(error)")
//            return false
//        }


        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }

        return true
    }

    //MARK:- Camera Session
    func startSession() {
        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }

    func stopSession() {
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }

    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }

    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation

        orientation = AVCaptureVideoOrientation.portrait

        return orientation
    }

    func startCapture() {

        startRecording()

    }

    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString

        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }

        return nil
    }

    func startRecording() {

        if movieOutput.isRecording == false {

            let connection = movieOutput.connection(with: .video)
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }

            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }

            let device = activeInput.device
            if (device.isSmoothAutoFocusSupported) {
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }

            }

            //EDIT2: And I forgot this
            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)

        }
        else {
            stopRecording()
        }

    }

    func stopRecording() {

        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
        }
    }

    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("start record")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        print("stop record")
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            
            //MARK: - call compress video
            
            guard let data = try? Data(contentsOf: outputFileURL) else {
                 return
             }
             print("File size before compression: \(Double(data.count / 1048576)) mb")
            self.videoSize = Double(data.count / 1048576)
             let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
             compressVideo(inputURL: outputFileURL as URL,
                           outputURL: compressedURL) { exportSession in
                 guard let session = exportSession else {
                     return
                 }
                 switch session.status {
                 case .unknown:
                     break
                 case .waiting:
                     break
                 case .exporting:
                     break
                 case .completed:
                     guard let compressedData = try? Data(contentsOf: compressedURL) else {
                         return
                     }
                     self.outputURL = compressedURL
                     self.videoData = compressedData
                     
                     print("File size after compression: \(Double(compressedData.count / 1048576)) mb")
                 case .failed:
                     break
                 case .cancelled:
                     break
                 }
             }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if (segue.identifier == "showVideo"){
            let displayVC = segue.destination as! VideoPlayback

              displayVC.videoURL = outputURL! as URL
              displayVC.videoSize = self.videoSize
              displayVC.videoData = self.videoData
          }
      }
}

//MARK: - compress video

extension CaptureReactions {

     func compressVideo(inputURL: URL,
                        outputURL: URL,
                        handler:@escaping (_ exportSession: AVAssetExportSession?) -> Void) {
         let urlAsset = AVURLAsset(url: inputURL, options: nil)
         guard let exportSession = AVAssetExportSession(asset: urlAsset,
                                                        presetName: AVAssetExportPreset960x540) else {
             handler(nil)
             return
         }
         exportSession.outputURL = outputURL
         exportSession.outputFileType = .mp4
         exportSession.exportAsynchronously {
             handler(exportSession)
         }
     }
 }

extension CaptureReactions {
    
    func setStartRecordButton() {
        
        let tapStartButton = UITapGestureRecognizer(target: self, action: #selector(self.startButtonTapped))
            startRecordButton.addGestureRecognizer(tapStartButton)
            startRecordButton.isUserInteractionEnabled = true
        
        }

    @objc func startButtonTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            startCapture()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.stopRecording()
                self.loadingBackground.isHidden = false
             }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                self.service.uploadReactions(post: self.post!, urlVideo: self.outputURL! as URL, completionHandler: { (response) in
                    if response {
                        self.captureReactionNotificationService.postNotification(.didFinishUploadingReaction)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [self] in
                            self.pushNotificationService.sendReactionNotification(username: post?.ownerUsername ?? "")
                            AppCoordinator.shared.changeToCurrentRoot()
                        }
                    }
                })
             }
        }
    }
    
    func setCancelRecordButton() {
        
        let tapCancelButton = UITapGestureRecognizer(target: self, action: #selector(self.cancelButtonTapped))
            cancelButton.addGestureRecognizer(tapCancelButton)
            cancelButton.isUserInteractionEnabled = true
        
        }

        @objc func cancelButtonTapped(sender: UITapGestureRecognizer) {
            if sender.state == .ended {
                AppCoordinator.shared.changeToRootViewController(atStoryboard: "Feed")
            }
        }
    
}
