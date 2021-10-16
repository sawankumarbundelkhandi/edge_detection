package com.sample.edgedetection


import com.sample.edgedetection.processor.Corners
import org.opencv.core.Mat

class SourceManager {
    companion object {
        var pic: Mat? = null
        var corners: Corners? = null
    }
}