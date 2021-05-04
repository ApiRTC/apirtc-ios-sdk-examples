//
//  LocalStreamRow.swift
//  SampleApp
//
//  Created by Aleksandr Khorobrykh on 30/01/2019.
//  Copyright © 2019 Apizee. All rights reserved.
//

import UIKit
import Eureka
import ApiRTCSDK
import AVFoundation

public final class LocalStreamRow: Row<LocalStreamCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<LocalStreamCell>()
    }
}

public class LocalStreamCell: Cell<Bool>, CellType {
    
    private var cameraView: CameraView?
    private var captureSession: AVCaptureSession?
    
    private var externalCameraView: UIImageView?
    
    public override func setup() {
        super.setup()
        
        height = {
            return 200
        }
    }
    
    public override func update() {
        super.update()
    }
    
    open func addStream(_ stream: ApiRTCStream) {
        switch stream.type {
        case .video, .videoOnly:
            guard let captureSession = stream.captureSession else {
                print("WARNING: Capture session is nil")
                return
            }
            cameraView = CameraView(frame: contentView.bounds)
            cameraView?.backgroundColor = .clear
            contentView.addSubview(cameraView!)
            cameraView?.snp.makeConstraints({ (make) in
                make.edges.equalTo(0)
            })
            cameraView?.captureSession = captureSession
        case .externalCamera:
            externalCameraView = UIImageView(frame: contentView.bounds)
            externalCameraView?.backgroundColor = .clear
            contentView.addSubview(externalCameraView!)
            externalCameraView?.snp.makeConstraints({ (make) in
                make.edges.equalTo(0)
            })
            stream.onEvent(self) { [weak self] (event) in
                guard let `self` = self else {
                    return
                }
                switch event {
                case .externalCameraFrame(let image):
                    DispatchQueue.main.async {
                        self.externalCameraView?.image = image
                    }
                default:
                    break
                }
            }
        default:
            break
            
        }
    }
    
    open func removeStream() {
        cameraView?.captureSession = nil
        externalCameraView?.image = nil
    }
}
