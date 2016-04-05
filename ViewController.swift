//
//  ViewController.swift
//  SessionDemo
//
//  Created by Serx on 16/3/29.
//  Copyright © 2016年 serxlee. All rights reserved.
//

import UIKit


class ViewController: UIViewController, NSURLSessionDelegate, NSURLSessionDataDelegate,  NSURLSessionTaskDelegate{

    var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 40, y: 40, width: 300, height: 300))
        imageView.backgroundColor = UIColor.lightGrayColor()
        imageView.contentMode = .ScaleToFill
        return imageView
    }()
    
    var session = NSURLSession()
    var dataTast: NSURLSessionDataTask = NSURLSessionDataTask()
    var progressview = UIProgressView()
    
    var expectedLengh = Int64()
    var buffer: NSMutableData = NSMutableData.init()
    
    let imageUrl:NSURL = NSURL(string: "http://pics.sc.chinaz.com/files/pic/pic9/201509/apic15014.jpg")!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataTast.resume()
        self.session.finishTasksAndInvalidate()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        downloadEpisodeWithFeedItem()
        dataTestEpisodeWithFeedItem(imageUrl)
        
        self.view.addSubview(imageView)
    }
    
    func dataTestEpisodeWithFeedItem(episodeURL: NSURL){
        
        
        
//        let request: NSURLRequest = NSURLRequest(URL: episodeURL)
        dataTast = session.dataTaskWithURL(episodeURL)
        
    }
    
    func downloadEpisodeWithFeedItem() {
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        let lenght = response.expectedContentLength
        if lenght == -1{
            
            self.expectedLengh = response.expectedContentLength
            completionHandler(NSURLSessionResponseDisposition.Allow)
        }else{
            
            completionHandler(NSURLSessionResponseDisposition.Cancel)
            let alert = UIAlertController(title: "error", message: "Do not contain property of expectedlength", preferredStyle: UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        self.buffer.appendData(data)
        self.progressview.progress = Float(self.buffer.length)/Float(self.expectedLengh)
    }
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        
        if (error == nil){
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                let image: UIImage = UIImage(data: self.buffer)!
                self.imageView.image = image
                self.progressview.hidden = true
            }
        }else{
            
            let userinfo: NSDictionary = (error?.userInfo)!
            let failurl: String = userinfo.objectForKey(NSURLErrorFailingURLStringErrorKey) as! String
            let localDescription: String = userinfo.objectForKey(NSURLLocalizedTypeDescriptionKey) as! String
            
            if failurl == imageUrl && localDescription == "cancelled"{
                
                let alert = UIAlertController(title: "Message", message: "The task is canceled", preferredStyle: UIAlertControllerStyle.Alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alert.addAction(okAction)
                presentViewController(alert, animated: true, completion: nil)
            }else{
                
                let alert = UIAlertController(title: "Message", message: "Unknown type error", preferredStyle: UIAlertControllerStyle.Alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alert.addAction(okAction)
                presentViewController(alert, animated: true, completion: nil)
            }
            self.progressview.hidden = true
        }
    }
    
    
    

    
    @IBAction func resumeTest(sender: UIButton) {
        
        if self.dataTast.state == NSURLSessionTaskState.Suspended{
            
            self.dataTast.resume()
        }
    }
    
    @IBAction func pauseTest(sender: UIButton) {
        
        if self.dataTast.state == NSURLSessionTaskState.Running{
            
            self.dataTast.suspend()
        }
    }
    
    @IBAction func cancelTest(sender: UIButton) {
        
        switch self.dataTast.state{
            
        case .Running:
            self.dataTast.cancel()

        case .Suspended:
            self.dataTast.cancel()
        default:
            break
        }
    }
}

