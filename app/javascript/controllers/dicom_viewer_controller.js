// app/javascript/controllers/dicom_viewer_controller.js
//
// Wraps the Cornerstone.js v2 UMD globals (loaded via CDN <script> tags
// in the show view) into a Stimulus controller.
//
// Supported tools (left-mouse-button by default):
//   Wwwc  – Window / Level (brightness & contrast)
//   Zoom  – scroll-wheel + right-drag zoom
//   Pan   – middle-drag pan
//   Length – caliper measurement
//
// Active Storage serves DICOM files via signed redirect URLs.
// cornerstoneWADOImageLoader fetches them with the wadouri: scheme.

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "viewport",
    "currentSlice",
    "totalSlices",
    "wlWindow",
    "wlCenter",
    "zoomLevel"
  ]

  static values = {
    images:       Array,
    currentIndex: { type: Number, default: 0 }
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────

  connect() {
    if (this.imagesValue.length === 0) return
    this.viewportInitialized = false
    this.pollForCornerstone()
  }

  disconnect() {
    if (this.viewportInitialized && window.cornerstone) {
      try { window.cornerstone.disable(this.viewportTarget) } catch (_e) {}
    }
  }

  // ── Initialisation ───────────────────────────────────────────────────────

  // CDN <script> tags load asynchronously; poll until globals are present.
  pollForCornerstone() {
    if (
      window.cornerstone &&
      window.cornerstoneTools &&
      window.cornerstoneWADOImageLoader &&
      window.dicomParser
    ) {
      this.initViewer()
    } else {
      setTimeout(() => this.pollForCornerstone(), 100)
    }
  }

  initViewer() {
    const cs     = window.cornerstone
    const csTools = window.cornerstoneTools
    const loader  = window.cornerstoneWADOImageLoader

    // Wire up external dependencies required by the loaders
    loader.external.cornerstone  = cs
    loader.external.dicomParser  = window.dicomParser
    loader.configure({ useWebWorkers: false })

    // Wire up cornerstoneTools external dependencies
    csTools.external.cornerstone      = cs
    csTools.external.cornerstoneMath  = window.cornerstoneMath
    csTools.external.Hammer           = window.Hammer
    csTools.init()

    // Enable the DOM element for rendering
    const el = this.viewportTarget
    cs.enable(el)
    this.viewportInitialized = true

    // Register interactive tools
    csTools.addTool(csTools.WwwcTool)
    csTools.addTool(csTools.ZoomTool)
    csTools.addTool(csTools.PanTool)
    csTools.addTool(csTools.LengthTool)

    // Default bindings: W/L on left, zoom on right, pan on middle
    csTools.setToolActive("Wwwc",  { mouseButtonMask: 1 })
    csTools.setToolActive("Zoom",  { mouseButtonMask: 2 })
    csTools.setToolActive("Pan",   { mouseButtonMask: 4 })

    // Reflect W/L, zoom, and slice position on every render
    el.addEventListener("cornerstoneimagerendered", (e) => this.onRender(e))

    this.loadImage(this.currentIndexValue)
  }

  // ── Image Loading ────────────────────────────────────────────────────────

  loadImage(index) {
    const url = this.imagesValue[index]
    if (!url) return

    // wadouri: tells the WADO image loader to fetch and parse the DICOM file
    window.cornerstone
      .loadAndCacheImage(`wadouri:${url}`)
      .then((image) => {
        window.cornerstone.displayImage(this.viewportTarget, image)
        if (this.hasCurrentSliceTarget) {
          this.currentSliceTarget.textContent = index + 1
        }
      })
      .catch((err) => {
        console.error("[DicomViewer] Failed to load image:", err)
      })
  }

  // ── Tool Activation ──────────────────────────────────────────────────────

  activateTool(event) {
    const toolName = event.currentTarget.dataset.tool
    window.cornerstoneTools.setToolActive(toolName, { mouseButtonMask: 1 })

    // Visual feedback: highlight the active button
    this.element.querySelectorAll(".dicom-tool-btn").forEach((btn) => {
      btn.classList.toggle("bg-indigo-600", btn.dataset.tool === toolName)
      btn.classList.toggle("bg-gray-700",  btn.dataset.tool !== toolName)
    })
  }

  // ── Navigation ───────────────────────────────────────────────────────────

  nextSlice() {
    if (this.currentIndexValue < this.imagesValue.length - 1) {
      this.currentIndexValue++
      this.loadImage(this.currentIndexValue)
    }
  }

  previousSlice() {
    if (this.currentIndexValue > 0) {
      this.currentIndexValue--
      this.loadImage(this.currentIndexValue)
    }
  }

  // ── Viewport Adjustments ─────────────────────────────────────────────────

  resetView() {
    window.cornerstone.fitToWindow(this.viewportTarget)
  }

  invertColors() {
    const el       = this.viewportTarget
    const viewport = window.cornerstone.getViewport(el)
    viewport.invert = !viewport.invert
    window.cornerstone.setViewport(el, viewport)
  }

  // ── Overlay Updates ──────────────────────────────────────────────────────

  onRender(event) {
    const vp = event.detail.viewport
    if (this.hasWlWindowTarget)  this.wlWindowTarget.textContent  = Math.round(vp.voi.windowWidth)
    if (this.hasWlCenterTarget)  this.wlCenterTarget.textContent  = Math.round(vp.voi.windowCenter)
    if (this.hasZoomLevelTarget) this.zoomLevelTarget.textContent = `${(vp.scale * 100).toFixed(0)}%`
  }
}
