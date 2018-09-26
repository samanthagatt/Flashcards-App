//
//  GroupCollectionViewController.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/25/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit
import CoreData

class GroupCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    var parentGroupID: String!
    let groupController = GroupController()
    let setController = SetController()
    lazy var groupFRC: NSFetchedResultsController<Group> = {
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "parentGroupID == %@", parentGroupID)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
        return frc
    }()
    lazy var setFRC: NSFetchedResultsController<Set> = {
        let fetchRequest: NSFetchRequest<Set> = Set.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "parentGroupID == %@", parentGroupID)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.moc, sectionNameKeyPath: nil, cacheName: nil)
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
                self.groupController.create(title: title, parentGroupID: self.parentGroupID, context: CoreDataStack.moc)
            case 1:
                self.setController.create()
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
        return 2
    }
    
    // Have to figure out section titles later
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Come back and fix
        switch section {
        case 0:
            return groupFRC.fetchedObjects?.count ?? 0
        default:
            return setFRC.fetchedObjects?.count ?? 0
        }
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
        guard let indextPath = collectionView.indexPathsForSelectedItems?.first else { return }
        // Should probably make a protocol for view controllers that have a parentGroup property so I don't have to do the switch case block
        switch segue.identifier {
        case "ShowGroupDetail":
            guard let destinationVC = segue.destination as? GroupCollectionViewController else { return }
            // Not sure if this will work since I'm using two frc's (one for each section)
            destinationVC.parentGroupID = groupFRC.object(at: indextPath).identifier
        case "ShowSetDetail":
            guard let destinationVC = segue.destination as? SetCollectionViewController else { return }
            // Not sure if this will work since I'm using two frc's (one for each section)
            destinationVC.parentGroupID = groupFRC.object(at: indextPath).identifier
        default:
            return
        }
    }
}
