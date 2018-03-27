//
//  PhotosViewController.swift
//  TestTask
//
//  Created by Vadim Rupets on 3/26/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class PhotosViewController: UIViewController {

    public static let StoryboardIdentifier = "PhotosViewController"
    private let detailsViewControllerSegueIdentifier = "ShowDetailsViewController"

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    private let recordsManager = RecordsManager()
    private var records: [Record] = []

    private let locationManager = CLLocationManager()
    private let cameraDistance = 10000.0

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: PhotoCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)

        fetchRecords()
    }

    // MARK: - Fetch and save records

    private func fetchRecords() {
        activityIndicatorView.startAnimating()

        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.records = strongSelf.recordsManager.fetchRecords()

            DispatchQueue.main.async {
                strongSelf.activityIndicatorView.stopAnimating()
                strongSelf.collectionView.reloadData()
            }
        }
    }

    private func saveRecords() {
        activityIndicatorView.startAnimating()

        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else { return }

            do {
                try strongSelf.recordsManager.saveRecords(strongSelf.records)
            } catch {
                let errorAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                errorAlert.addAction(okAction)

                strongSelf.present(errorAlert, animated: true, completion: nil)
            }

            DispatchQueue.main.async {
                strongSelf.activityIndicatorView.stopAnimating()
                strongSelf.collectionView.reloadData()
            }
        }
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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == detailsViewControllerSegueIdentifier,
            let detailsViewController = segue.destination as? DetailsViewController,
            let image = sender as? UIImage else { return }

        detailsViewController.image = image
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
            guard let strongSelf = self else { return }

            let record = strongSelf.records[indexPath.row]
            strongSelf.performSegue(withIdentifier: strongSelf.detailsViewControllerSegueIdentifier, sender: record.image)
        }

        let mapAction = UIAlertAction(title: "Map", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }

            let record = strongSelf.records[indexPath.row]

            let placemark = MKPlacemark(coordinate: record.location.coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "You took this photo here"
            mapItem.openInMaps(launchOptions: nil)
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

// MARK: - UICollectionViewDelegateFlowLayout

extension PhotosViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.size.width

        return CGSize(width: collectionViewWidth / 4, height: collectionViewWidth / 4)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}
