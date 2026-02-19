//
//  BarcodeScannerView.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/18/26.
//

import SwiftUI
import AVFoundation

struct BarcodeScannerView: UIViewControllerRepresentable {
    let onBarcodeScanned: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.onBarcodeScanned = { barcode in
            onBarcodeScanned(barcode)
        }
        vc.onDismiss = {
            dismiss()
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
}

final class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onBarcodeScanned: ((String) -> Void)?
    var onDismiss: (() -> Void)?

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var hasScanned = false
    private let viewfinderView = UIView()
    private let instructionLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
        setupOverlay()
        setupCloseButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              captureSession.canAddInput(input) else {
            showPermissionDeniedAlert()
            return
        }

        captureSession.addInput(input)

        let metadataOutput = AVCaptureMetadataOutput()
        guard captureSession.canAddOutput(metadataOutput) else { return }
        captureSession.addOutput(metadataOutput)

        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        metadataOutput.metadataObjectTypes = [.ean13, .ean8, .upce]

        let preview = AVCaptureVideoPreviewLayer(session: captureSession)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        view.layer.addSublayer(preview)
        previewLayer = preview
    }

    private func setupOverlay() {
        // Dimming overlay
        let dimView = UIView()
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Viewfinder cutout
        viewfinderView.translatesAutoresizingMaskIntoConstraints = false
        viewfinderView.backgroundColor = .clear
        viewfinderView.layer.borderColor = UIColor.white.cgColor
        viewfinderView.layer.borderWidth = 2
        viewfinderView.layer.cornerRadius = 12
        view.addSubview(viewfinderView)
        NSLayoutConstraint.activate([
            viewfinderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewfinderView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            viewfinderView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.55),
            viewfinderView.heightAnchor.constraint(equalTo: viewfinderView.widthAnchor, multiplier: 1.4)
        ])

        // Cut out the viewfinder area from the dim overlay
        view.layoutIfNeeded()
        dimView.layoutIfNeeded()
        viewfinderView.layoutIfNeeded()

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let path = UIBezierPath(rect: self.view.bounds)
            let cutout = UIBezierPath(roundedRect: self.viewfinderView.frame, cornerRadius: 12)
            path.append(cutout)
            path.usesEvenOddFillRule = true

            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            maskLayer.fillRule = .evenOdd
            dimView.layer.mask = maskLayer
        }

        // Corner accents
        let accentColor = UIColor(red: 0.6, green: 1.0, blue: 0.2, alpha: 1.0) // match app accent
        addCornerAccents(color: accentColor)

        // Instruction label
        instructionLabel.text = "Position barcode inside the frame"
        instructionLabel.textColor = .white
        instructionLabel.font = .systemFont(ofSize: 15, weight: .medium)
        instructionLabel.textAlignment = .center
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: viewfinderView.bottomAnchor, constant: 24),
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func addCornerAccents(color: UIColor) {
        let length: CGFloat = 24
        let thickness: CGFloat = 3

        // We add corner lines after layout
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let frame = self.viewfinderView.frame
            let corners: [(CGPoint, Bool, Bool)] = [
                (CGPoint(x: frame.minX, y: frame.minY), true, true),    // top-left
                (CGPoint(x: frame.maxX, y: frame.minY), false, true),   // top-right
                (CGPoint(x: frame.minX, y: frame.maxY), true, false),   // bottom-left
                (CGPoint(x: frame.maxX, y: frame.maxY), false, false),  // bottom-right
            ]

            for (point, isLeft, isTop) in corners {
                // Horizontal line
                let hLine = UIView()
                hLine.backgroundColor = color
                hLine.layer.cornerRadius = thickness / 2
                hLine.frame = CGRect(
                    x: isLeft ? point.x : point.x - length,
                    y: isTop ? point.y - thickness / 2 : point.y - thickness / 2,
                    width: length,
                    height: thickness
                )
                self.view.addSubview(hLine)

                // Vertical line
                let vLine = UIView()
                vLine.backgroundColor = color
                vLine.layer.cornerRadius = thickness / 2
                vLine.frame = CGRect(
                    x: isLeft ? point.x - thickness / 2 : point.x - thickness / 2,
                    y: isTop ? point.y : point.y - length,
                    width: thickness,
                    height: length
                )
                self.view.addSubview(vLine)
            }
        }
    }

    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        let config = UIImage.SymbolConfiguration(pointSize: 28)
        closeButton.setPreferredSymbolConfiguration(config, forImageIn: .normal)

        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    @objc private func closeTapped() {
        onDismiss?()
    }

    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Camera Access Required",
            message: "Please enable camera access in Settings to scan barcodes.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.onDismiss?()
        })
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        present(alert, animated: true)
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !hasScanned,
              let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let barcode = object.stringValue else { return }

        hasScanned = true
        captureSession.stopRunning()
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        onBarcodeScanned?(barcode)
    }
}
