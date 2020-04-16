//
//  TableViewController.swift
//  Pick Image
//
//  Created by Natasha Stopa on 4/14/20.
//  Copyright © 2020 Stopa Inc. All rights reserved.
//

import UIKit

class MemeTableViewController: UITableViewController {

    // Retrieve meme list from global scope
    var memeArray: [Meme]! {
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //memes = appDelegate.memes
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView!.reloadData()
       }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return memeArray.count
      }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeCell")!
        let meme = self.memeArray[(indexPath as NSIndexPath).row]
        
        // Set the name and image
        //var imageView = UIImageView(frame: CGRectMake(100, 150, 150, 150))
        cell.imageView?.image = meme.memedImage
        cell.textLabel?.text = meme.topText + "..." + meme.bottomText
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = self.storyboard?.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = memeArray[indexPath.row]
        navigationController?.pushViewController(detailController, animated: true)
    }
}
