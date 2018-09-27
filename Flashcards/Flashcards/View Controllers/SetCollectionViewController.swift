//
//  SetCollectionViewController.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/25/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit
import CoreData

class SetCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate, OrganizerViewController {
    
    // MARK: - ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cardController.fetchCards(in: parentOrganizer)
    }
    
    // MARK: - Properties
    
    var parentOrganizer: Organizer?
    let cardController = CardController()
    lazy var fetchedResultsController: NSFetchedResultsController<Card> = {
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        // Is there a better way to handle the optional organizerID?
        fetchRequest.predicate = NSPredicate(format: "parentSetID == %@", parentOrganizer!.identifier!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
        return frc
    }()
    
    
    // MARK: - Actions
    
    @IBAction func createCard(_ sender: Any) {
        let alert = UIAlertController(title: "Create a new card?", message: nil, preferredStyle: .alert)
        let createAction = UIAlertAction(title: "Create", style: .default) { (_) in
            guard let identifier = self.parentOrganizer?.identifier else { return }
            self.cardController.create(parentSetID: identifier, context: CoreDataStack.moc)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(createAction)
        alert.addAction(cancelAction)
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
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
        
        let card = fetchedResultsController.object(at: indexPath)
        cell.card = card
        
        return cell
    }
    
    
    // MARK: - Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? CardDetailViewController,
            let indexPath = collectionView.indexPathsForSelectedItems?.first else { return }
        
        destinationVC.card = fetchedResultsController.object(at: indexPath)
    }
}
