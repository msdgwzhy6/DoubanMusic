//
//  ViewController.swift
//  DoubanMusic
//
//  Created by zhouyihua on 15/8/19.
//  Copyright (c) 2015年 xiebangyuan. All rights reserved.
//

import UIKit
import MediaPlayer
import QuartzCore

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate ,HttpProtocol,ChannelProtocol{
    @IBOutlet weak var progress: UIProgressView!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var btnPlay: UIImageView!
    
    @IBOutlet var tap: UITapGestureRecognizer!
    
    @IBAction func onTap(sender: UITapGestureRecognizer) {
        if sender.view == btnPlay {
            btnPlay.hidden = true
            audioPlayer.play()
            btnPlay.removeGestureRecognizer(tap)
            titleImage.addGestureRecognizer(tap)
        }else if sender.view == titleImage{
            btnPlay.hidden = false
            audioPlayer.pause()
            titleImage.removeGestureRecognizer(tap)
            btnPlay.addGestureRecognizer(tap)
        }
        
    }
    var mhttp:HttpController = HttpController()
    var songsData:NSArray = NSArray()
    var channelsData:NSArray = NSArray()
    var imageCache = Dictionary<String,UIImage>()
    var audioPlayer:MPMoviePlayerController = MPMoviePlayerController()
    var timer:NSTimer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.titleImage.addGestureRecognizer(tap)
        mhttp.delegate = self
        mhttp.onSearch("http://www.douban.com/j/app/radio/channels")
        mhttp.onSearch("http://douban.fm/j/mine/playlist?channel=0")
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //添加cell动画 相当于android的属性动画
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return songsData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = self.tableView.dequeueReusableCellWithIdentifier("song") as! UITableViewCell
        let rowData:NSDictionary = self.songsData[indexPath.row] as! NSDictionary
        var title = cell.viewWithTag(102) as! UILabel
        var artist = cell.viewWithTag(103) as! UILabel
        var songImage = cell.viewWithTag(104) as! UIImageView
        title.text = rowData["title"] as? String
        artist.text = rowData["artist"] as? String
        let url = rowData["picture"] as! String
        let image = self.imageCache[url]
        if image == nil{
            var imageUrl:NSURL = NSURL(string:url)!
            var request:NSURLRequest = NSURLRequest(URL:imageUrl)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:{(response:NSURLResponse!,data:NSData!,error:NSError!)->Void in
                    let img = UIImage(data: data)
                    songImage.image = img
                    self.imageCache[url] = img
          })
        }else{
            songImage.image = self.imageCache[url]
        }
        
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        var rowData:NSDictionary = songsData[indexPath.row] as! NSDictionary
        var songUrl = rowData["url"] as! String
        var imageUrl = rowData["picture"] as! String
        setAudio(songUrl)
        setImage(imageUrl)
    }
    
    func didRecieveResults(results:NSDictionary){
        println("--1111-\(results)")
        if results["song"] != nil{
             songsData = results["song"] as! NSArray
            tableView.reloadData()
//            var rowData:NSDictionary = songsData[0] as! NSDictionary
//            var songUrl = rowData["url"] as! String
//            var imageUrl = rowData["picture"] as! String
//            setAudio(songUrl)
//            setImage(imageUrl)
            
        }else if results["channels"] != nil{
            channelsData = results["channels"] as! NSArray
            tableView.reloadData()
        }
        
    }
    
    func setAudio(url:String){
        timer?.invalidate()
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string:url)
        self.audioPlayer.play()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "onUpdate", userInfo: nil, repeats: true)
        btnPlay.removeGestureRecognizer(tap)
        titleImage.addGestureRecognizer(tap)
        btnPlay.hidden  = true
    }
    
    func onUpdate(){
        let c = audioPlayer.currentPlaybackTime
        if c>0.0{
            let t = audioPlayer.duration
            let p:CFloat = CFloat(c/t)
            progress.setProgress(p, animated: true)
            let all:Int = Int(c)
            let s:Int = all % 60
            let m:Int = all / 60
            var timeStr:String = ""
            if(m<10){
                timeStr = "0\(m):"
            }else{
                timeStr = "\(m):"
            }
            
            if(s<10){
                timeStr += "0\(s)"
            }else{
                timeStr += "\(s)"
            }
            time.text = timeStr
        }
    }
    func setImage(url:String){
        
        let image = self.imageCache[url]
        if image == nil{
            var imageUrl:NSURL = NSURL(string:url)!
            var request:NSURLRequest = NSURLRequest(URL:imageUrl)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:{(response:NSURLResponse!,data:NSData!,error:NSError!)->Void in
                let img = UIImage(data: data)
                self.titleImage.image = img
                self.imageCache[url] = img
            })
        }else{
            self.titleImage.image = self.imageCache[url]
        }
    }
    
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var channelVC = segue.destinationViewController as! ChannelViewController
        channelVC.channelData = self.channelsData
        channelVC.delegate = self
    }
    
    func onChangeChannel(url:String){
        mhttp.onSearch(url)
    }
}

