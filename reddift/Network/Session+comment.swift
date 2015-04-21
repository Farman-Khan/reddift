//
//  Session+comment.swift
//  reddift
//
//  Created by sonson on 2015/04/17.
//  Copyright (c) 2015年 sonson. All rights reserved.
//

import UIKit

extension Session {
    func comment(link:Link, completion:(comments:[Comment], error:NSError?)->Void) -> NSURLSessionDataTask {
        var parameter:[String:String] = ["sort":"top", "depth":"2"]
    
        var URLRequest = NSMutableURLRequest.mutableOAuthRequestWithBaseURL(baseURL, path:"comments/" + link.id, parameter:parameter, method:"GET", token:token)
        
        let task = URLSession.dataTaskWithRequest(URLRequest, completionHandler: { (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
            self.updateRateLimitWithURLResponse(response)
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    completion(subreddits:[], paginator: nil, error: error)
                })
            }
            else {
                var jsonError:NSError? = nil
                if let json = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.allZeros, error:&jsonError) as? [AnyObject] {
                }
                else {
                }
            }
        })
        task.resume()
        return task
    }
}
