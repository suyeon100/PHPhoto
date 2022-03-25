//
//  ViewController.swift
//  PhotoGallery
//
//  Created by 박수연 on 2022/03/25.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {
    
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "PhotoGalleryApp"
        makeNavigationItem()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 200, height: 200)
        photoCollectionView.collectionViewLayout = layout
        photoCollectionView.dataSource = self
       
    }
    
    
    func makeNavigationItem() {
        
        let photoItem = UIBarButtonItem(image: UIImage(systemName: "photo.on.rectangle" ), style: .done, target: self, action: #selector(checkPermission))
        photoItem.tintColor = .black.withAlphaComponent(0.7)
        self.navigationItem.rightBarButtonItem = photoItem
        
        // 리프레쉬 버튼
        let refreshItem = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .done, target: self, action: #selector(refresh))
        
        refreshItem.tintColor = .black.withAlphaComponent(0.7)
        self.navigationItem.leftBarButtonItem = refreshItem
        
    }
    
    // 권한부여 갤러리 눌렀을때
    @objc func checkPermission() {
        // 승인
       if PHPhotoLibrary.authorizationStatus() == .authorized || PHPhotoLibrary.authorizationStatus() == .limited{
           DispatchQueue.main.async {
               self.showGallery()
           }
           //거부
        }else if PHPhotoLibrary.authorizationStatus() == .denied{
            DispatchQueue.main.async {
                self.showAuthorizarionDenidAlert()
            }
        }else if PHPhotoLibrary.authorizationStatus() == .notDetermined{
            PHPhotoLibrary.requestAuthorization { status in
                self.checkPermission()
                
            }
        }
    
    }
    func showAuthorizarionDenidAlert() {
        
        let alert = UIAlertController(title: "포토라이브러라 접근 권환을 활성화해주세요.", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "설정으로가기", style: .default, handler:{ action in
            
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    

    
    @objc func showGallery() {
        let library =  PHPhotoLibrary.shared()
        
        var configuration = PHPickerConfiguration(photoLibrary: library)
        configuration.selectionLimit = 10
        
       let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func refresh() {
        
    }


}

// 몇개 보여줄건지
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    // cell 연결
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        return cell
    }
    
    
}
// 창 닫기
extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        let identifier =  results.map{
            $0.assetIdentifier ?? ""
        }
        let fetchAssets = PHAsset.fetchAssets(withLocalIdentifiers: identifier, options: nil)
        
        fetchAssets.enumerateObjects { asset, index, stop in
            
            let imageManager = PHImageManager()
            let imageSize = CGSize(with: 150 * scale, height: 150 * scale )
            
            imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: nil) { image, info in
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
