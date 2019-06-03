//
//  ViewController.swift
//  Notes
//
//  Created by Manjit Singh on 2018-04-04.
//  Copyright © 2018 Manjit Singh. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate,  UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate,CLLocationManagerDelegate {
   // let locationManager:CLLocationManage!
    @IBOutlet weak var noteInfoView: UIView!
  
    @IBOutlet weak var noteNameLabel: UITextField!
    @IBOutlet weak var noteSubjectLabel: UITextField!
    @IBOutlet weak var noteDescriptionLabel: UITextView!
    
    @IBOutlet weak var noteImageview: UIImageView!
    var today : String!
    
   
    var lati = 0.0
    var longi = 0.0
     var locationManager = CLLocationManager()
    var managedObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
    }
    
    var notesFetchedResultsController: NSFetchedResultsController<Note>!
    var notes = [Note]()
    var note: Note?
    var isExsisting = false
    var indexPath: Int?
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       self.hideKeyboard()
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        today = getTodayString()
        
        print("this is time check it "+today)
        
        
        if let note = note {
            noteNameLabel.text = note.notename
            noteSubjectLabel.text = note.notesubject
            noteDescriptionLabel.text = note.notedescription
            noteImageview.image = UIImage(data: note.noteimage! as Data)
            
        }
        
        if noteNameLabel.text != "" {
            isExsisting = true
        }
        
        // Delegates
        noteNameLabel.delegate = self
        noteSubjectLabel.delegate = self
        noteDescriptionLabel.delegate = self
        
        
        // Styles
        noteInfoView.layer.shadowColor =  UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0).cgColor
        noteInfoView.layer.shadowOffset = CGSize(width: 0.75, height: 0.75)
        noteInfoView.layer.shadowRadius = 1.5
        noteInfoView.layer.shadowOpacity = 0.2
        noteInfoView.layer.cornerRadius = 2
        
       

       // noteImageview.setBottomBorder()

    }
    func getTodayString() -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        
        let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
        
        return today_string
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let locValue:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)// manager.location!.coordinate
        lati = locValue.latitude
        longi = locValue.longitude
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        // Hide the keyboard.
//      //  noteNameLabel.resignFirstResponder()
//     //   noteSubjectLabel.resignFirstResponder()
//        noteDescriptionLabel.resignFirstResponder()
//        return true
//    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        noteDescriptionLabel.text = textField.text
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    func saveToCoreData(completion: @escaping ()->Void){
        managedObjectContext!.perform {
            do {
                try self.managedObjectContext?.save()
                completion()
                print("Note saved to CoreData.")
                
            }
                
            catch let error {
                print("Could not save note to CoreData: \(error.localizedDescription)")
                
            }
            
        }
        
    }
    
  
   
    @IBAction func imageButtonWasPressed(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
         let alertController = UIAlertController(title: "Add an Image", message: "Choose From", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)

        }
        
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        let savedPhotosAction = UIAlertAction(title: "Saved Photos Album", style: .default) { (action) in           pickerController.sourceType = .savedPhotosAlbum
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotosAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        noteImageview.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonWasPressed(_ sender: UIBarButtonItem) {
        if noteNameLabel.text == "" || noteNameLabel.text == "NOTE NAME" || noteDescriptionLabel.text == "" || noteDescriptionLabel.text == "Note Description..." {
            
            let alertController = UIAlertController(title: "Missing Information", message:"You left one or more fields empty. Please make sure that all fields are filled before attempting to save.", preferredStyle: UIAlertControllerStyle.alert)
            let OKAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil)
            
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }
            
        else {
            if (isExsisting == false) {
                let noteName = noteNameLabel.text
                 let noteSubject = noteSubjectLabel.text
                let noteDescription = noteDescriptionLabel.text
                
                if let moc = managedObjectContext {
                    let note = Note(context: moc)
                    
                    if let data = UIImageJPEGRepresentation(self.noteImageview.image!, 1.0) {
                        note.noteimage = data as NSData as Data
                    }
                    
                    note.notename = noteName
                    note.notesubject = noteSubject
                    note.notedescription = noteDescription
                    note.notelatitude = lati
                    note.notelongititude = longi
                    note.notetime = today
                    saveToCoreData() {
                        
                        let isPresentingInAddFluidPatientMode = self.presentingViewController is UINavigationController
                        
                        if isPresentingInAddFluidPatientMode {
                            self.dismiss(animated: true, completion: nil)
                            
                        }
                            
                        else {
                            self.navigationController!.popViewController(animated: true)
                            
                        }
                        
                    }
                    
                }
                
            }
                
            else if (isExsisting == true) {
                
                let note = self.note
                
                let managedObject = note
                managedObject!.setValue(noteNameLabel.text, forKey: "notename")
                managedObject!.setValue(noteDescriptionLabel.text, forKey: "notedescription")
                managedObject!.setValue(noteSubjectLabel.text, forKey: "notesubject")
                if let data = UIImageJPEGRepresentation(self.noteImageview.image!, 1.0) {
                    managedObject!.setValue(data, forKey: "noteimage")
                }
                
                do {
                    try managedObjectContext?.save()
                    
                    let isPresentingInAddFluidPatientMode = self.presentingViewController is UINavigationController
                    
                    if isPresentingInAddFluidPatientMode {
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                        
                    else {
                        self.navigationController!.popViewController(animated: true)
                        
                    }
                    
                }
                    
                catch {
                    print("Failed to update existing note.")
                }
            }
            
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddFluidPatientMode = presentingViewController is UINavigationController
        
        if isPresentingInAddFluidPatientMode {
            dismiss(animated: true, completion: nil)
            
        }
            
        else {
            navigationController!.popViewController(animated: true)
            
        }
        
    }
    
    // Text field
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return false
//        
//    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
            
        }
        
        return true
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == "Note Description...") {
            textView.text = ""
            
        }
        
    }
    
}
