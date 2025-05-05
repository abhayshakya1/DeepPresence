import SwiftUI
import UIKit
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    var selectionLimit: Int

    func makeCoordinator() -> Coordinator {
        return Coordinator(images: $images, image: $image, isPresented: $isPresented, selectionLimit: selectionLimit)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = selectionLimit
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        @Binding var images: [UIImage]
        @Binding var image: UIImage?
        @Binding var isPresented: Bool
        var selectionLimit: Int

        init(images: Binding<[UIImage]>, image: Binding<UIImage?>, isPresented: Binding<Bool>, selectionLimit: Int) {
            _images = images
            _image = image
            _isPresented = isPresented
            self.selectionLimit = selectionLimit
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if selectionLimit == 1 {
                if let result = results.first {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                        if let error = error {
                            print("Error loading image: \(error.localizedDescription)")
                            return
                        }
                        if let selectedImage = object as? UIImage {
                            DispatchQueue.main.async {
                                self?.image = selectedImage
                                self?.images = [selectedImage] // Also update the images array
                                self?.isPresented = false
                            }
                        }
                    }
                }
            } else {
                var newImages: [UIImage] = []
                let group = DispatchGroup()
                
                for result in results {
                    group.enter()
                    result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                        if let error = error {
                            print("Error loading image: \(error.localizedDescription)")
                            group.leave()
                            return
                        }
                        if let selectedImage = object as? UIImage {
                            newImages.append(selectedImage)
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) { [weak self] in
                    self?.images = newImages
                    self?.isPresented = false
                }
            }
        }

        func pickerDidCancel(_ picker: PHPickerViewController) {
            isPresented = false
        }
    }
}
