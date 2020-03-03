//
//  MemeTableViewController.swift
//  ImagePicker
//
//  Created by Andrey Valverde Solera on 3/2/20.
//  Copyright © 2020 Andrey Valverde Solera. All rights reserved.
//

import UIKit


class MemeTableViewController: UITableViewController {
    
    private let reuseIdentifier = "MemeTableViewCell"
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // We only have one section
    }
    
    @IBAction func addMeme(_ sender: Any) {
        let memeViewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! MemeEditorViewController
        
        memeViewController.callback = {
                   self.tableView.reloadData()
               }
        
        present(memeViewController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        let meme = appDelegate.memes[indexPath.row]
        
        cell.imageView?.image = meme.memeImage
        cell.textLabel?.text = setMemeText(meme)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let meme = appDelegate.memes[indexPath.row]
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! MemeEditorViewController
        
        viewController.bottomText = meme.bottomText
        viewController.topText = meme.topText
        viewController.memeImage = meme.memeImage
        viewController.canEdit = false
        
        present(viewController, animated: true, completion: nil)
    }
    
    private func setMemeText(_ meme: Meme) -> String {
        return meme.topText + "..." + meme.bottomText
    }
}
