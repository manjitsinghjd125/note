//
//  noteTableViewController.swift
//  Notes
//
//  Created by Manjit Singh on 2018-04-04.
//  Copyright © 2018 Manjit Singh. All rights reserved.
//

import UIKit
import CoreData

class noteTableViewController: UITableViewController,UISearchBarDelegate  {
 
    
    //var noteItemArray = [noteitem]()
    var notes = [Note]()
   
    
    var managedObjectContext: NSManagedObjectContext?
    {
    return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
   
    
    func fetchObj(selectedScopeIdx:Int?=nil,targetText:String?=nil){// -> [note]{
       // var aray = [noteitem]()
        
        let fetchRequest:NSFetchRequest<Note> = Note.fetchRequest()
        
        if selectedScopeIdx != nil && targetText != nil{
            
            var filterKeyword = ""
            switch selectedScopeIdx! {
            case 0:
                filterKeyword = "notename"
            case 1:
                filterKeyword = "notesubject"
            default:
                filterKeyword = "notedescription"
            }
            
            var predicate = NSPredicate(format: "\(filterKeyword) contains[c] %@", targetText!)
           
            
            fetchRequest.predicate = predicate
        }
        
       
            do {
                notes = try self.managedObjectContext!.fetch(fetchRequest)
              
            }
            catch{
                print("Could not fetch notes from core data: \(error.localizedDescription)")
            }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
       // updateData()
        self.hideKeyboard()
       setUpSearchBar()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
   
    @IBAction func sortdata(_ sender: Any) {
        tableView.reloadData()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        let alertController = UIAlertController(title: "Sort By", message: "Choose Option", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Name", style: .default) { (action) in
            let sort = NSSortDescriptor(key: "notename", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare))
            fetchRequest.sortDescriptors = [sort]
            do {
                self.notes = try context.fetch(fetchRequest)
            } catch {
                print("Cannot fetch Expenses")
            }
            
        }
        
        let photosLibraryAction = UIAlertAction(title: "Subject", style: .default) { (action) in
            let sort = NSSortDescriptor(key: "notesubject", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare))
            fetchRequest.sortDescriptors = [sort]
            do {
                self.notes = try context.fetch(fetchRequest)
            } catch {
                print("Cannot fetch Expenses")
            }
            
        }
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        //alertController.addAction(savedPhotosAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
        // display it by Sort.
        
        
       
    }
    fileprivate func setUpSearchBar() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 65))
        
        searchBar.showsScopeBar = true
        searchBar.scopeButtonTitles = ["notename","notesubject","notedescription"]
        searchBar.selectedScopeButtonIndex = 0
        
        searchBar.delegate = self
        
        self.tableView.tableHeaderView = searchBar
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard !searchText.isEmpty else {
            fetchObj()
            tableView.reloadData()
            return
        }
        
        fetchObj(selectedScopeIdx: searchBar.selectedScopeButtonIndex, targetText:searchText)
        
        tableView.reloadData()
        print(searchText)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        retrieveNote()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteTableViewCell", for: indexPath) as! noteTableViewCell

        let note: Note = notes[indexPath.row]
        
        cell.celldata(note: note)

        return cell
    }
    

   
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
   

  
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let noteEntity = "Note" //Entity Name
        
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let note = notes[indexPath.row]
        
        if editingStyle == .delete {
            managedContext.delete(note)
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Error While Deleting Note: \(error.userInfo)")
            }
            
        }
        
        //Code to Fetch New Data From The DB and Reload Table.
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: noteEntity)
        
        do {
            notes = try managedContext.fetch(fetchRequest) as! [Note]
        } catch let error as NSError {
            print("Error While Fetching Data From DB: \(error.userInfo)")
        }
        tableView.reloadData()

    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showNote"){
            let v = segue.destination as! ViewController
            let indexpath = self.tableView.indexPathForSelectedRow
            let row = indexpath?.row
            v.note = notes[row!]
            
        }
    }
    func retrieveNote(){
        managedObjectContext?.perform {
            self.fetchNotesFromCoreData{ (notes) in
                if let notes = notes {
                    self.notes = notes
                    self.tableView.reloadData()
                }
            }
        }
    }

    func fetchNotesFromCoreData(completion: @escaping ([Note]?) -> Void) {
        managedObjectContext?.perform {
            var notes = [Note]()
            let request: NSFetchRequest<Note> = Note.fetchRequest()
            do {
                notes = try self.managedObjectContext!.fetch(request)
                completion(notes)
            }
            catch{
                print("Could not fetch notes from core data: \(error.localizedDescription)")
            }
        }
    }
    
    
}

extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false;
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
