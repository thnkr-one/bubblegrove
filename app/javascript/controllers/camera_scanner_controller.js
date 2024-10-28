// app/javascript/controllers/camera_scanner_controller.js
import { Controller } from "@hotwired/stimulus"
import jsQR from "jsqr"

export default class extends Controller {
  static targets = ["video", "scanResult", "progressBar", "scannerOverlay", "qrButton"]

  connect() {
    this.cameras = []
    this.currentCameraIndex = 0
    this.scanning = false
    this.darkMode = false

    // Create canvas for QR scanning
    this.canvas = document.createElement('canvas')
    this.canvasContext = this.canvas.getContext('2d')

    this.startCamera()
  }

  async startCamera() {
    try {
      const devices = await navigator.mediaDevices.enumerateDevices()
      this.cameras = devices.filter(device => device.kind === 'videoinput')

      if (this.cameras.length === 0) {
        throw new Error('No cameras found')
      }

      // Try to get back camera first
      const backCamera = this.cameras.find(camera =>
          camera.label.toLowerCase().includes('back') ||
          camera.label.toLowerCase().includes('rear')
      )

      if (backCamera) {
        this.currentCameraIndex = this.cameras.indexOf(backCamera)
      }

      const stream = await navigator.mediaDevices.getUserMedia({
        video: {
          deviceId: this.cameras[this.currentCameraIndex].deviceId,
          width: { ideal: 1920 },
          height: { ideal: 1080 }
        }
      })

      this.videoTarget.srcObject = stream
      await this.videoTarget.play()

    } catch (error) {
      console.error("Camera error:", error)
      this.showMessage("Camera error - please check permissions")
    }
  }

  toggleQRMode() {
    if (this.scanning) {
      this.disableScanning()
    } else {
      this.enableScanning()
    }
  }

  enableScanning() {
    this.scanning = true
    this.scannerOverlayTarget.classList.remove('hidden')
    this.qrButtonTarget.classList.add('bg-blue-500')
    this.showMessage("QR scanning active")
    this.scanQRCode()
  }

  disableScanning() {
    this.scanning = false
    this.scannerOverlayTarget.classList.add('hidden')
    this.qrButtonTarget.classList.remove('bg-blue-500')
    this.showMessage("QR scanning disabled")
  }

  async scanQRCode() {
    if (!this.scanning) return

    if (this.videoTarget.readyState === this.videoTarget.HAVE_ENOUGH_DATA) {
      this.canvas.height = this.videoTarget.videoHeight
      this.canvas.width = this.videoTarget.videoWidth

      this.canvasContext.drawImage(
          this.videoTarget,
          0,
          0,
          this.canvas.width,
          this.canvas.height
      )

      const imageData = this.canvasContext.getImageData(
          0,
          0,
          this.canvas.width,
          this.canvas.height
      )

      try {
        const qrCode = jsQR(
            imageData.data,
            imageData.width,
            imageData.height,
            {
              inversionAttempts: "dontInvert",
            }
        )

        if (qrCode) {
          // For testing - log the found QR code
          console.log("Found QR code:", qrCode.data)

          // Validate UUID format
          const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
          if (uuidRegex.test(qrCode.data)) {
            await this.handleQRCode(qrCode.data)
            return
          } else {
            this.showMessage("Invalid QR code format", "error")
          }
        }
      } catch (error) {
        console.error("QR scan error:", error)
      }
    }

    if (this.scanning) {
      requestAnimationFrame(() => this.scanQRCode())
    }
  }

  async handleQRCode(uuid) {
    this.showMessage("Product found...")
    this.progressBarTarget.style.width = "33%"

    // Pause scanning while loading product
    this.disableScanning()

    try {
      const response = await fetch(`/scanner/lookup/${uuid}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      })

      if (!response.ok) {
        const errorData = await response.json()
        this.showMessage(errorData.error || 'Error fetching product', 'error')
        return
      }

      const data = await response.json()
      this.progressBarTarget.style.width = "66%"

      // Display product details (you can customize this as needed)
      this.displayProductDetails(data.data)

      this.progressBarTarget.style.width = "100%"
      this.showMessage("Product loaded successfully")
    } catch (error) {
      console.error("Handle QR code error:", error)
      this.showMessage("Error loading product details", "error")
    } finally {
      // Resume scanning after a delay
      setTimeout(() => {
        if (this.qrButtonTarget.classList.contains('bg-blue-500')) {
          this.enableScanning()
        }
      }, 2000)
    }
  }

  displayProductDetails(product) {
    // You can use Turbo Streams or manipulate the DOM directly
    // For simplicity, let's assume you have a div with id 'product_details'
    const productDetails = document.getElementById('product_details')
    if (productDetails) {
      productDetails.innerHTML = `
        <h2>${product.title}</h2>
        <img src="${product.image_src}" alt="${product.title}" width="200" />
        <p>${product.body}</p>
        <p>Vendor: ${product.vendor}</p>
        <p>Category: ${product.product_category}</p>
        <p>Price: $${product.variant_price}</p>
      `
    }
  }

  switchCamera() {
    if (this.videoTarget.srcObject) {
      this.videoTarget.srcObject.getTracks().forEach(track => track.stop())
    }

    this.currentCameraIndex = (this.currentCameraIndex + 1) % this.cameras.length
    this.startCamera()
  }

  toggleDarkMode() {
    this.darkMode = !this.darkMode
    document.body.classList.toggle('dark')
  }

  showSettings() {
    this.showMessage("Settings")
    // Add settings logic
  }

  showAnalysis() {
    this.showMessage("Analysis")
    // Add analysis logic
  }

  showMessage(message, type = 'info') {
    this.scanResultTarget.textContent = message
    this.scanResultTarget.classList.remove('hidden')
    this.scanResultTarget.classList.remove('text-red-500', 'text-green-500', 'text-blue-500')

    if (type === 'error') {
      this.scanResultTarget.classList.add('text-red-500')
    } else if (type === 'success') {
      this.scanResultTarget.classList.add('text-green-500')
    } else {
      this.scanResultTarget.classList.add('text-blue-500')
    }

    if (!message.toLowerCase().includes('error')) {
      setTimeout(() => {
        this.scanResultTarget.classList.add('hidden')
      }, 3000)
    }
  }

  disconnect() {
    this.scanning = false
    if (this.videoTarget.srcObject) {
      this.videoTarget.srcObject.getTracks().forEach(track => track.stop())
    }
  }
}
