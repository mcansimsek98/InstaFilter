//
//  ViewController.swift
//  Project13
//
//  Created by Mehmet Can Şimşek on 17.07.2022.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    @IBOutlet var changeFilterName: UIButton!
    @IBOutlet var radius: UISlider!
    @IBOutlet var radiusLbl: UILabel!
    @IBOutlet var intenstyLbl: UILabel!
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")

    }
    
    
    @objc func importPicture() {
        let picer = UIImagePickerController()
        picer.allowsEditing = true
        picer.delegate = self
        present(picer, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        //showImage()
        changeFilterName.setTitle("CISepiaTone", for: .normal)
       appleyProcessing()
        
    }
    
    func appleyProcessing() {
        
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
            intensity.isEnabled = true
            intenstyLbl.isEnabled = true
        }else {
          //  intensity.isEnabled = false
          //  intenstyLbl.isEnabled = false
          //  intensity.value = 0
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(radius.value * 200 , forKey: kCIInputRadiusKey)
            radius.isEnabled = true
            radiusLbl.isEnabled = true
        }else {
            radius.isEnabled = false
            radiusLbl.isEnabled = false
            radius.value = 0
        }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)}
        if inputKeys.contains(kCIInputCenterKey) {currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)}
        
        
        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            self.imageView.image = processedImage
        }

    }

    @IBAction func changeFilter(_ sender: Any) {
        let ac = UIAlertController(title: "Choose Filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        //ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
        
    }
    
    func setFilter(action: UIAlertAction) {
        guard currentImage != nil else { return }
        
        guard let actionTitle = action.title else { return }
        
        currentFilter = CIFilter(name: actionTitle)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        changeFilterName.setTitle(action.title, for: .normal)
        appleyProcessing()
    }
    
    @IBAction func save(_ sender: Any) {
        if imageView.image == nil {
            let ac = UIAlertController(title: "Save Error", message: "There aren't photos selected.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }else {
            guard let image = imageView.image else { return }
            
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contectInfo:)), nil)
        }
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error? , contectInfo: UnsafeRawPointer) {

            if let error = error {
            let ac = UIAlertController(title: "Save Error", message: error.localizedDescription, preferredStyle: .alert )
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    
    @IBAction func intensityChange(_ sender: Any) {
        appleyProcessing()
    }
    
    
    func showImage() {
            print(#function)
            UIView.animate(withDuration: 0, delay: 0, options: [], animations: {
                self.imageView.alpha = 0
            }) { (_) in
                self.help()
            }
            
        }
        
        func help() {
            UIView.animate(withDuration: 1, animations: {
                self.imageView.alpha = 1
            }, completion: nil)
        }
}
