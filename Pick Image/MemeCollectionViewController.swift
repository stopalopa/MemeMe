//
//  CollectionViewController.swift
//  Pick Image
//
//  Created by Natasha Stopa on 4/14/20.
//  Copyright © 2020 Stopa Inc. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
        
    var memes: [Meme]! {
          let object = UIApplication.shared.delegate
          let appDelegate = object as! AppDelegate
          return appDelegate.memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space: CGFloat = 1.0
        print(view.frame.size.width)
        print(view.frame.size.height)
        let dimension = (view.frame.size.width - (2 * space)) / 2.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        print(flowLayout.itemSize)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView!.reloadData()
        print("reloaded")
        self.tabBarController?.navigationItem.title = "Sent Memes"
    }
     
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionViewCell", for: indexPath) as! MemeCollectionViewCell
        
        let meme = self.memes[(indexPath as NSIndexPath).row]
        cell.memeImage.image = meme.memedImage
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        
        let detailController = self.storyboard?.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = memes[(indexPath as NSIndexPath).row]
        //detailController.meme = memeArray[indexPath.row]
        navigationController?.pushViewController(detailController, animated: true)
    }
}
