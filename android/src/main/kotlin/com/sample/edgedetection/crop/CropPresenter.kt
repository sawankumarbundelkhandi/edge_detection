package com.sample.edgedetection.crop

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.os.Environment
import android.os.SystemClock
import android.widget.Toast
import androidx.core.app.ActivityCompat
import com.sample.edgedetection.SourceManager
import com.sample.edgedetection.processor.Corners
import com.sample.edgedetection.processor.cropPicture
import org.opencv.android.Utils
import org.opencv.core.Mat
import java.io.File
import java.io.FileOutputStream

const val IMAGES_DIR = "smart_scanner"

class CropPresenter(val context: Context, private val iCropView: ICropView.Proxy) {
    private val picture: Mat? = SourceManager.pic

    private val corners: Corners? = SourceManager.corners
    private var croppedPicture: Mat? = null
    private var croppedBitmap: Bitmap? = null

    init {
        val bitmap = Bitmap.createBitmap(picture?.width() ?: 1080, picture?.height()
                ?: 1920, Bitmap.Config.ARGB_8888)
        Utils.matToBitmap(picture, bitmap, true)
        iCropView.getPaper().setImageBitmap(bitmap)
        iCropView.getPaperRect().onCorners2Crop(corners, picture?.size())
    }

    fun proceed(): String? {
        if (ActivityCompat.checkSelfPermission(context, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
            Toast.makeText(context, "please grant write file permission and trya gain", Toast.LENGTH_SHORT).show()
            return null
        }

        croppedPicture = cropPicture(picture!!, iCropView.getPaperRect().getCorners2Crop())
        croppedBitmap = Bitmap.createBitmap(croppedPicture!!.width(), croppedPicture!!.height(), Bitmap.Config.ARGB_8888)
        Utils.matToBitmap(croppedPicture, croppedBitmap)

        val dir = File(context.cacheDir, IMAGES_DIR)
        if (!dir.exists()) {
            dir.mkdirs()
        }

        val cropPic = croppedBitmap
        if (null != cropPic) {
            val file = File.createTempFile("crop_${SystemClock.currentThreadTimeMillis()}", ".jpeg", dir)
            file.deleteOnExit()
            val outStream = FileOutputStream(file)
            cropPic.compress(Bitmap.CompressFormat.JPEG, 100, outStream)
            outStream.flush()
            outStream.close()
            cropPic.recycle()

            return file.absolutePath
        }

        return null
    }
}