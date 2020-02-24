//
//  DetailsViewController.swift
//  AnıDefterim
//
//  Created by USER on 23.02.2020.
//  Copyright © 2020 Furkan Basoglu. All rights reserved.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            
            saveButton.isHidden = true
            
            // Core Data işlemi
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = chosenPaintingID?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                        
                    }
                    
                }
            }catch{
                print("error")
            }
            
            
        }else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            
            nameText.text = ""
            yearText.text = ""
            
        }
        
        
        
        //Recognizers
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer) //Ekranda bir yere tıkladığımızda klavyeyi kapat
        
        imageView.isUserInteractionEnabled = true //Kullanıcının ekrana tıklaması
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
    @objc func selectImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(){  //Ekranda çıkan klavyeyi kapatmak için
        view.endEditing(true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
            
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
            
        //Attributes
            
        newPainting.setValue(nameText.text!, forKey: "name")
            
            
        if let year = Int(yearText.text!) {
            newPainting.setValue(year, forKey: "year")
        }
            
        newPainting.setValue(UUID(), forKey: "id")
            
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
            
        newPainting.setValue(data, forKey: "image")
            
        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
            
          
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
            
        }
    
    
}
