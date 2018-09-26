//
//  GroupCollectionViewController.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/25/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Collection cell enum

enum CollectionCellID: String {
    case group = "GroupCell"
    case set = "SetCell"
}


// MARK: - OrganizerViewController protocol

protocol OrganizerViewController {
    var organizerID: String? { get set }
}


// MARK: - Your Library collection view controller

class GroupCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate, OrganizerViewController {
    
    // MARK: - Properties
    
    var organizerID: String?
    let organizerController = OrganizerController()
    lazy var fetchedResultsController: NSFetchedResultsController<Organizer> = {
        let fetchRequest: NSFetchRequest<Organizer> = Organizer.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "parentGroupID == %@", organizerID ?? "noParentGroup")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "type", ascending: true), NSSortDescriptor(key: "dateCreated", ascending: false)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.moc, sectionNameKeyPath: "type", cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
        return frc
    }()

    
    // MARK: - Actions
    
    @IBAction func create(_ sender: Any) {
        // Come back later and create my own controller that conforms to UIAlertController or add an extension?
        let alert = UIAlertController(title: "Create", message: nil, preferredStyle: .alert)
        let segmentedControl = UISegmentedControl(items: ["Group", "Set"])
        segmentedControl.selectedSegmentIndex = 0
        alert.view.addSubview(segmentedControl)
        var titleTextField: UITextField!
        alert.addTextField { (textField) in
            textField.placeholder = "Title"
            titleTextField = textField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let createAction = UIAlertAction(title: "Create", style: .default) { (_) in
            // Come back and do error handling
            guard let title = titleTextField.text else { return }
            
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                self.organizerController.create(type: .group, title: title, parentGroupID: self.organizerID ?? "noParentGroup", context: CoreDataStack.moc)
            case 1:
                self.organizerController.create(type: .set, title: title, parentGroupID: "noParentGroup", context: CoreDataStack.moc)
            default:
                return
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(createAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Collection view fetched results controller delegate
    
    private var blockOperations: [BlockOperation] = []
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        let op: BlockOperation
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            op = BlockOperation { self.collectionView?.insertItems(at: [newIndexPath]) }
        case .delete:
            guard let indexPath = indexPath else { return }
            op = BlockOperation { self.collectionView?.deleteItems(at: [indexPath]) }
        case .update:
            guard let indexPath = indexPath else { return }
            op = BlockOperation { self.collectionView?.reloadItems(at: [indexPath]) }
        case .move:
            guard let indexPath = indexPath,  let newIndexPath = newIndexPath else { return }
            op = BlockOperation { self.collectionView?.moveItem(at: indexPath, to: newIndexPath) }
        }
        
        blockOperations.append(op)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        var op: BlockOperation?
        switch type {
        case .insert:
            op = BlockOperation { self.collectionView?.insertSections(IndexSet(integer: sectionIndex)) }
        case .delete:
            op = BlockOperation { self.collectionView?.deleteSections(IndexSet(integer: sectionIndex)) }
        default:
            break
        }
        
        guard let newOp = op else { return }
        blockOperations.append(newOp)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            self.blockOperations.forEach { $0.start() }
        }, completion: { finished in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }
    
    
    // MARK: - Collection view delegate and data source
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // Come back and fix
        return fetchedResultsController.sections?.count ?? 1
    }
    
    // Have to figure out section titles later
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier: String
        if indexPath.section == 0 {
            identifier = CollectionCellID.group.rawValue
        } else {
            identifier = CollectionCellID.set.rawValue
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        return cell
    }
    
    
    // MARK: - Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard var organizerDestVC = segue.destination as? OrganizerViewController,
            let collectionDestVC = segue.destination as? UICollectionViewController,
            let indextPath = collectionView.indexPathsForSelectedItems?.first else { return }
        
        let organizer = fetchedResultsController.object(at: indextPath)
        organizerDestVC.organizerID = organizer.identifier
        collectionDestVC.title = organizer.title
    }
}
