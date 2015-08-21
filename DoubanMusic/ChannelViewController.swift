
import UIKit
import QuartzCore

protocol ChannelProtocol{
    func onChangeChannel(url:String)
}


class ChannelViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate{

    
    @IBAction func onTapped(sender: AnyObject) {
        
        var array = NSMutableArray()
        
        for index in 0...7{
            var string = NSString(string:"icon\(index)")
            
            
        }
    }

    @IBOutlet weak var channelTableView: UITableView!
    
    var channelData:NSArray = NSArray()
    
    var delegate:ChannelProtocol?
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
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
        return channelData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = self.channelTableView.dequeueReusableCellWithIdentifier("channel") as! UITableViewCell
        
        var channelName = cell.viewWithTag(105) as! UILabel
        var rowData = self.channelData[indexPath.row] as! NSDictionary
        channelName.text = rowData["name"] as? String
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        var rowData = self.channelData[indexPath.row] as! NSDictionary
        let channel_id:AnyObject = (rowData["channel_id"] as AnyObject?)!
        let channel = "http://douban.fm/j/mine/playlist?channel_\(channel_id)"
        println("====channel===\(channel)")
        self.delegate?.onChangeChannel(channel)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

