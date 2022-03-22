//
//  VideoViewController.swift
//  rtc_demo
//
//  Created by apple on 2021/11/30.
//

import UIKit
import WebRTC


class VideoViewController: UIViewController {
    
    private let webRTCClient: [WebRTCClient]

    @IBOutlet weak var localVideoView: UIView!
    @IBOutlet weak var localVideoTwoV: UIView!
    init(webRTCClient: [WebRTCClient]) {
        self.webRTCClient = webRTCClient
        super.init(nibName: String(describing: VideoViewController.self), bundle: Bundle.main)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard self.webRTCClient.count > 0 else {
            return
        }
        
        let localRenderer = RTCMTLVideoView(frame: self.localVideoView?.frame ?? CGRect.zero)
        let remoteRendererTwo = RTCMTLVideoView(frame: self.localVideoTwoV?.frame ?? CGRect.zero)
        let remoteRenderer = RTCMTLVideoView(frame: self.view.frame)
        localRenderer.videoContentMode = .scaleAspectFill
        remoteRenderer.videoContentMode = .scaleAspectFill
        
        let localClient:WebRTCClient = self.webRTCClient.first!
        ///本地流
        localClient.startCaptureLocalVideo(renderer: localRenderer)
        self.embedView(localRenderer, into: self.localVideoView)
        
        let renderClient:WebRTCClient = self.webRTCClient.last!
        renderClient.renderRemoteVideo(to: remoteRenderer)
        renderClient.unmuteAudio()
        renderClient.speakerOn()
        self.embedView(remoteRenderer, into: self.view)
        
        //远程流
        if self.webRTCClient.count == 2 {
            let renderClient:WebRTCClient = self.webRTCClient[0]
            renderClient.renderRemoteVideo(to: remoteRenderer)
            renderClient.unmuteAudio()
            renderClient.speakerOn()
            self.embedView(remoteRenderer, into: self.view)
            
            let renderClientTwo:WebRTCClient = self.webRTCClient[1]
            renderClientTwo.renderRemoteVideo(to: remoteRendererTwo)
            renderClientTwo.unmuteAudio()
            renderClientTwo.speakerOn()
            self.embedView(remoteRendererTwo, into: localVideoTwoV)
        }
        
//        for client in self.webRTCClient {
//            ///远程流
//            client.renderRemoteVideo(to: remoteRendererTwo)
//            client.renderRemoteVideo(to: remoteRenderer)
//            ///rtc操作
//            client.unmuteAudio()
//            client.speakerOn()
//        }
//
//        self.embedView(localRenderer, into: self.localVideoView)
//        self.embedView(remoteRendererTwo, into: localVideoTwoV)
       
        self.view.sendSubviewToBack(remoteRenderer)
    }
    
    private func embedView(_ view: UIView, into containerView: UIView) {
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view":view]))

        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view":view]))
        containerView.layoutIfNeeded()
    }

    
    @IBAction func backTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
