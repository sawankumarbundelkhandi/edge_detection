package com.sample.edgedetection.crop

import android.widget.ImageView
import com.sample.edgedetection.view.PaperRectangle
import com.sample.edgedetection.view.ZoomableImageView



/**
 * Created by pengke on 15/09/2017.
 */
class ICropView {
    interface Proxy {
        fun getPaper(): ZoomableImageView
        fun getPaperRect(): PaperRectangle
        fun getCroppedPaper(): ImageView
    }
}