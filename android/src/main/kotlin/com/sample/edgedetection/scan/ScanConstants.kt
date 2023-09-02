package com.sample.edgedetection.scan

import org.opencv.core.Size

object ScanConstants {
    private const val MAX_IMAGE_HEIGHT = 4096.0 // Maximum allowable image height
    private const val MAX_IMAGE_WIDTH = 2048.0 // Maximum allowable image width (originally 2304)
    val MAX_SIZE : Size = Size(MAX_IMAGE_WIDTH, MAX_IMAGE_HEIGHT)
}