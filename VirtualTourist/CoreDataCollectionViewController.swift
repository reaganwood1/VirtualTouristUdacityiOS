//
//  CoreDataTableViewController.swift
//  Tricorder
//
//  Created by Fernando Rodríguez Romero on 22/02/16.
//  Copyright © 2016 udacity.com. All rights reserved.
//

import UIKit
import CoreData

class CoreDataCollectionViewController: UICollectionViewController {
    
    // MARK:  - Properties
    var fetchedResultsController : NSFetchedResultsController?{
        didSet{
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
//            tableView.reloadData()
            collectionView?.reloadData()
        }
    }
    
    // should this have been deleted?
//    init(fetchedResultsController fc : NSFetchedResultsController){
//        fetchedResultsController = fc
//        super.init(fetchedResultsController: fc)
//        //style : UITableViewStyle =  .Plain
//    }
    
    // Do not worry about this initializer. I has to be implemented
    // because of the way Swift interfaces with an Objective C
    // protocol called NSArchiving. It's not relevant.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}



// MARK:  - Subclass responsability
extension CoreDataCollectionViewController{
    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//        fatalError("This method MUST be implemented by a subclass of CoreDataTableViewController")
//    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        fatalError("This method MUST be implemented by a sublass of CoreDataCollectionViewController")
    }
}

// MARK:  - Table Data Source
extension CoreDataCollectionViewController{
    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        if let fc = fetchedResultsController{
//            return (fc.sections?.count)!;
//        }else{
//            return 0
//        }
//    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let fc = fetchedResultsController{
            return (fc.sections?.count)!;
        }else{
            return 0
        }
    }
    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let fc = fetchedResultsController{
//            return fc.sections![section].numberOfObjects;
//        }else{
//            return 0
//        }
//    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController{
            return fc.sections![section].numberOfObjects;
        }else{
            return 0
        }
    }

    // No replacement
//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if let fc = fetchedResultsController{
//            return fc.sections![section].name;
//        }else{
//            return nil
//        }
//    }
    
    // No replacement
//    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
//        if let fc = fetchedResultsController{
//            return fc.sectionForSectionIndexTitle(title, atIndex: index)
//        }else{
//            return 0
//        }
//    }
    
    // No replacement
//    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
//        if let fc = fetchedResultsController{
//            return  fc.sectionIndexTitles
//        }else{
//            return nil
//        }
//    }
    
}

// MARK:  - Fetches
extension CoreDataCollectionViewController{
    
    func executeSearch(){
        if let fc = fetchedResultsController{
            do{
                try fc.performFetch()
            }catch let e as NSError{
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
}


// MARK:  - Delegate
extension CoreDataCollectionViewController: NSFetchedResultsControllerDelegate{
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        //tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                                     atIndex sectionIndex: Int,
                                             forChangeType type: NSFetchedResultsChangeType) {
        
        let set = NSIndexSet(index: sectionIndex)
        
        switch (type){
            
        case .Insert:
            collectionView?.insertSections(set)
            //tableView.insertSections(set, withRowAnimation: .Fade)
            
        case .Delete:
            //tableView.deleteSections(set, withRowAnimation: .Fade)
            collectionView?.deleteSections(set)
            
        default:
            // irrelevant in our case
            break
            
        }
    }
    
    
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                                    atIndexPath indexPath: NSIndexPath?,
                                                forChangeType type: NSFetchedResultsChangeType,
                                                              newIndexPath: NSIndexPath?) {
        
        guard let newIndexPath = newIndexPath else{
            fatalError("No indexPath received")
        }
        switch(type){
            
        case .Insert:
            //tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            collectionView?.insertItemsAtIndexPaths([newIndexPath])
            
        case .Delete:
            //tableView.deleteRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            collectionView?.deleteItemsAtIndexPaths([newIndexPath])
        case .Update:
            //tableView.reloadRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            collectionView?.reloadItemsAtIndexPaths([newIndexPath])
        case .Move:
            collectionView?.deleteItemsAtIndexPaths([newIndexPath])
            collectionView?.insertItemsAtIndexPaths([newIndexPath])
            //tableView.deleteRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            //tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        }
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        //tableView.endUpdates()
    }
}
















