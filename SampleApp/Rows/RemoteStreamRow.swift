//
//  RemoteStreamRow.swift
//  SampleApp
//
//  Created by Aleksandr Khorobrykh on 30/01/2019.
//  Copyright © 2019 Apizee. All rights reserved.
//

import Eureka
import ApiRTCSDK

public final class RemoteStreamRow: Row<RemoteStreamCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<RemoteStreamCell>()
    }
}

public class RemoteStreamCell: Cell<Bool>, CellType {
    
    private var videoView: VideoView?
    private var videoTrack: VideoTrack?
    
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
        
        stream.onEvent(self) { [weak self] event in
            guard let `self` = self else { return }
            switch event {
            case .mediaStream(let mediaStream):
                DispatchQueue.main.async {
                    guard let videoTrack = mediaStream.videoTracks.first else {
                        print("Video track is nil")
                        return
                    }
                    
                    let videoView = VideoView(frame: self.contentView.bounds, renderer: .metal)
                    videoView.contentMode = .scaleAspectFit
                    self.contentView.addSubview(videoView)
                    videoView.snp.makeConstraints { (make) in
                        make.top.left.right.bottom.equalTo(0)
                    }
            
                    self.videoTrack = videoTrack
                    videoTrack.addRenderer(videoView.renderer)
            
                    self.videoView = videoView
                }
            default:
                break
            }
        }
    }
    
    open func removeStream() {
        self.videoTrack?.removeRenderer()
        videoView?.removeFromSuperview()
        videoView = nil
    }
}
