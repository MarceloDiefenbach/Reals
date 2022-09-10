import UIKit
import AVFoundation


class CaptureVideo: UIViewController, AVCaptureFileOutputRecordingDelegate {
    

    @IBOutlet weak var camPreview: UIView!
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()

    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!

    @IBAction func startButton(_ sender: Any) {
        startCapture()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.stopRecording()
         }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.performSegue(withIdentifier: "showVideo", sender: nil)
         }
    }
    
    @IBAction func sendToServer(_ sender: Any) {
        performSegue(withIdentifier: "showVideo", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720

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
//        captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720

        // Setup Camera
        let camera = AVCaptureDevice.default(for: .video)

        do {
            let input = try AVCaptureDeviceInput(device: camera!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }

        // Setup Microphone
        let microphone = AVCaptureDevice.default(for: .audio)

        do {
            let micInput = try AVCaptureDeviceInput(device: microphone!)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }


        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }

        return true
    }

    func setupCaptureMode(_ mode: Int) {
        // Video Mode

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

    //EDIT 1: I FORGOT THIS AT FIRST

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
            
//            guard let data = try? Data(contentsOf: outputFileURL) else {
//                 return
//             }
//             print("File size before compression: \(Double(data.count / 1048576)) mb")
//
//             let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
//             compressVideo(inputURL: outputFileURL as URL,
//                           outputURL: compressedURL) { exportSession in
//                 guard let session = exportSession else {
//                     return
//                 }
//                 switch session.status {
//                 case .unknown:
//                     break
//                 case .waiting:
//                     break
//                 case .exporting:
//                     break
//                 case .completed:
//                     guard let compressedData = try? Data(contentsOf: compressedURL) else {
//                         return
//                     }
//                     self.outputURL = compressedURL
//                     print("File size after compression: \(Double(compressedData.count / 1048576)) mb")
//                 case .failed:
//                     break
//                 case .cancelled:
//                     break
//                 }
//             }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if (segue.identifier == "showVideo"){
            let displayVC = segue.destination as! VideoPlayback

              displayVC.videoURL = outputURL! as URL
          }
      }
}

extension CaptureVideo {

     func compressVideo(inputURL: URL,
                        outputURL: URL,
                        handler:@escaping (_ exportSession: AVAssetExportSession?) -> Void) {
         let urlAsset = AVURLAsset(url: inputURL, options: nil)
         guard let exportSession = AVAssetExportSession(asset: urlAsset,
                                                        presetName: AVAssetExportPreset1280x720) else {
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
