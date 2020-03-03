//
//  SentMemesCollectionViewController.swift
//  ImagePicker
//
//  Created by Andrey Valverde Solera on 3/2/20.
//  Copyright © 2020 Andrey Valverde Solera. All rights reserved.
//

import UIKit

class SentMemesCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    private let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    private let reusableCellIdentifier = "MemeCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Collection view sizing
        let itemSize = UIScreen.main.bounds.width/3 - 3
        
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        flowLayout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        flowLayout.minimumInteritemSpacing = 3
        flowLayout.minimumLineSpacing = 3
    }
    
    @IBAction func addMeme(_ sender: Any) {
        let memeViewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! MemeEditorViewController
        
        memeViewController.callback = {
            self.collectionView.reloadData()
        }
        
        present(memeViewController, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusableCellIdentifier, for: indexPath) as! MemeCollectionViewCell
        
        // Set the image into the meme cell
        cell.memeImage.image = appDelegate.memes[indexPath.row].memeImage
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let meme = appDelegate.memes[indexPath.row]
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! MemeEditorViewController
        
        viewController.bottomText = meme.bottomText
        viewController.topText = meme.topText
        viewController.memeImage = meme.memeImage
        viewController.canEdit = false
        
        present(viewController, animated: true, completion: nil)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 // Only one section
    }
}
