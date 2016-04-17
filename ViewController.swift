//
//  ViewController.swift
//  SessionDemo
//
//  Created by Serx on 16/3/29.
//  Copyright © 2016年 serxlee. All rights reserved.
//

import UIKit


class ViewController: UIViewController, NSURLSessionDelegate, NSURLSessionDataDelegate,  NSURLSessionTaskDelegate{
    
    
    //MARK: - ------All Properties------
    //MARK: -
    
    var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 40, y: 40, width: 300, height: 300))
        imageView.backgroundColor = UIColor.lightGrayColor()
        imageView.contentMode = .ScaleToFill
        return imageView
    }()
    
     //定义一个默认的session
    var defaultSession = NSURLSession()
    
    //获取data的task
    var dataTast: NSURLSessionDataTask = NSURLSessionDataTask()
    
    //进度条
    var progressview = UIProgressView()
    
    var expectedLengh = Int64()
    var buffer: NSMutableData = NSMutableData.init()
    
    let imageUrl:NSURL = NSURL(string: "http://pics.sc.chinaz.com/files/pic/pic9/201509/apic15014.jpg")!
    
    
    //下载 session ， downloadsession
    lazy var downLoadSession: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        //delegateQueue设置为nil session会自己创建一个串行的队列
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        return session
    }()
    

    //MARK: - ----Apple Inc.Func----
    //MARK: -
    
        override func viewDidLoad() {
        super.viewDidLoad()

//        doTest2()
            
        /*
        downloadEpisodeWithFeedItem()
        dataTestEpisodeWithFeedItem(imageUrl)
        
        self.view.addSubview(imageView)

            
        self.dataTast.resume()
        self.defaultSession.finishTasksAndInvalidate()
        */
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        

        
    }
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
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
     */
    
    
    //获取已接受数据， 计算百分 进度条
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        self.buffer.appendData(data)
        self.progressview.progress = Float(self.buffer.length)/Float(self.expectedLengh)
    }
    
    //获取结束， check error
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
    
    //MARK: - ----Individual Func----
    //MARK: -
    
    //download executive
    func downlaod(){
        var downloadTask = NSURLSessionDataTask()
        downloadTask = downLoadSession.dataTaskWithURL(imageUrl)
        
        downloadTask.resume()
    }
    
    //defind the session by myself
    func doTest2(){
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 10.0
        configuration.requestCachePolicy = .UseProtocolCachePolicy
        configuration.HTTPAdditionalHeaders = ["Content-Type":"image/jpeg"]
        
        let defaultSession2 = NSURLSession(configuration: configuration)
        
        var dataTask2: NSURLSessionDataTask?
        
        let request = NSMutableURLRequest(URL: imageUrl)
        
        request.HTTPMethod = "GET"
        
        dataTask2 = defaultSession2.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            
            print(data)
            print(response)
        })
        
        dataTask2?.resume()
    }
    
    
    func dataTestEpisodeWithFeedItem(episodeURL: NSURL){
//        let request: NSURLRequest = NSURLRequest(URL: episodeURL)
        self.dataTast = self.defaultSession.dataTaskWithURL(episodeURL)
    }
    
    func downloadEpisodeWithFeedItem() {
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        defaultSession = NSURLSession(configuration: config, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        
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

