//
//  PhotosViewController.swift
//  TestTask
//
//  Created by Vadim Rupets on 3/26/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import UIKit
import CoreLocation

class PhotosViewController: UIViewController {

    public static let StoryboardIdentifier = "PhotosViewController"

    @IBOutlet weak var collectionView: UICollectionView!

    private let recordsManager = RecordsManager()
    private var records: [Record] = []

    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: PhotoCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)

        fetchRecords()
    }

    // MARK: - Fetch and save records

    private func fetchRecords() {
        records = recordsManager.fetchRecords()
        collectionView.reloadData()
    }

    private func saveRecords() {
        do {
            try recordsManager.saveRecords(records)
        } catch {
            let errorAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            errorAlert.addAction(okAction)

            present(errorAlert, animated: true, completion: nil)
        }

        collectionView.reloadData()
    }

    // MARK: - IBActions

    @IBAction func cameraButtonPressed() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.cameraDevice = .rear
        imagePickerController.cameraCaptureMode = .photo
        imagePickerController.delegate = self

        present(imagePickerController, animated: true, completion: nil)
    }

}

// MARK: - UIImagePickerControllerDelegate

extension PhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            dismiss(animated: true, completion: nil)
        }

        guard
            let image = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let location = locationManager.location else { return }

        let record = Record(image: image, location: location)
        records.append(record)
        saveRecords()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}

// MARK: - UICollectionViewDataSource

extension PhotosViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let record = records[indexPath.row]

        guard let recordCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }

        recordCell.imageView.image = record.image

        return recordCell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return records.count
    }

}

// MARK: - UICollectionViewDelegate

extension PhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let actionSheet = UIAlertController(title: "Actions", message: nil, preferredStyle: .actionSheet)

        let detailsAction = UIAlertAction(title: "Details", style: .default) { [weak self] _ in
            // TODO: Add details screen
        }

        let mapAction = UIAlertAction(title: "Map", style: .default) { [weak self] _ in
            // TODO: Add map screen
        }

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            _ = self?.records.remove(at: indexPath.row)
            self?.saveRecords()
        }

        actionSheet.addAction(detailsAction)
        actionSheet.addAction(mapAction)
        actionSheet.addAction(deleteAction)

        present(actionSheet, animated: true, completion: nil)
    }
}
