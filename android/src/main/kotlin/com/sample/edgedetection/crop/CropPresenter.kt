package com.sample.edgedetection.crop

import android.Manifest
import android.content.ContentValues
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Matrix
import android.os.Environment
import android.os.SystemClock
import android.provider.MediaStore
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.core.app.ActivityCompat
import com.sample.edgedetection.SourceManager
import com.sample.edgedetection.processor.Corners
import com.sample.edgedetection.processor.TAG
import com.sample.edgedetection.processor.cropPicture
import com.sample.edgedetection.processor.enhancePicture
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import org.opencv.android.Utils
import org.opencv.core.Mat
import java.io.File
import java.io.FileOutputStream


const val IMAGES_DIR = "smart_scanner"

class CropPresenter(val context: Context, private val iCropView: ICropView.Proxy) {
    private val picture: Mat? = SourceManager.pic

    private val corners: Corners? = SourceManager.corners
    private var croppedPicture: Mat? = null
    private var enhancedPicture: Bitmap? = null
    private var croppedBitmap: Bitmap? = null
    private var rotateBitmap: Bitmap? = null
    private var rotateBitmapDegree: Int = -90
    private var rotateBitmapCurrentDegree: Int = 0

    init {
        iCropView.getPaperRect().onCorners2Crop(corners, picture?.size())
        val bitmap = Bitmap.createBitmap(picture?.width() ?: 1080, picture?.height()
                ?: 1920, Bitmap.Config.ARGB_8888)
        Utils.matToBitmap(picture, bitmap, true)
        iCropView.getPaper().setImageBitmap(bitmap)
    }

    fun addImageToGallery(filePath: String, context: Context) {

        val values = ContentValues()

        values.put(MediaStore.Images.Media.DATE_TAKEN, System.currentTimeMillis())
        values.put(MediaStore.Images.Media.MIME_TYPE, "image/png")
        values.put(MediaStore.MediaColumns.DATA, filePath)

        context.contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
    }

    fun crop() {
        if (picture == null) {
            Log.i(TAG, "picture null?")
            return
        }

        if (croppedBitmap != null) {
            Log.i(TAG, "already cropped")
            return
        }

        Observable.create<Mat> {
            it.onNext(cropPicture(picture, iCropView.getPaperRect().getCorners2Crop()))
        }
                .subscribeOn(Schedulers.computation())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe { pc ->
                    Log.i(TAG, "cropped picture: " + pc.toString())
                    croppedPicture = pc
                    croppedBitmap = Bitmap.createBitmap(pc.width(), pc.height(), Bitmap.Config.ARGB_8888)
                    Utils.matToBitmap(pc, croppedBitmap)
                    iCropView.getCroppedPaper().setImageBitmap(croppedBitmap)
                    iCropView.getPaper().visibility = View.GONE
                    iCropView.getPaperRect().visibility = View.GONE
                }
    }

    fun enhance() {
        if (croppedBitmap == null) {
            Log.i(TAG, "picture null?")
            return
        }

        var imgToEnhace:Bitmap?
        if (enhancedPicture != null){
            imgToEnhace = enhancedPicture
        }else if(rotateBitmap != null){
            imgToEnhace = rotateBitmap
        }else{
            imgToEnhace = croppedBitmap
        }

        Observable.create<Bitmap> {
            it.onNext(enhancePicture(imgToEnhace))
        }
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe { pc ->

                    enhancedPicture = pc
                    rotateBitmap = enhancedPicture

                    iCropView.getCroppedPaper().setImageBitmap(pc)
                }
    }

    fun reset(){
        if (croppedBitmap == null) {
            Log.i(TAG, "picture null?")
            return
        }

        //croppedBitmap = croppedBitmap?.rotateInt(rotateBitmapDegree)

        rotateBitmap = croppedBitmap
        enhancedPicture = croppedBitmap

        iCropView.getCroppedPaper().setImageBitmap(croppedBitmap);
    }

    fun rotate() {
        if (croppedBitmap == null && enhancedPicture == null) {
            Log.i(TAG, "picture null?")
            return
        }

        if(enhancedPicture != null && rotateBitmap == null){
            Log.i(TAG, "enhancedPicture ***** TRUE")
            rotateBitmap = enhancedPicture;
        }

        if(rotateBitmap == null){
            Log.i(TAG, "rotateBitmap ***** TRUE")
            rotateBitmap = croppedBitmap;
        }


        Log.i(TAG, "ROTATEBITMAPDEGREE --> $rotateBitmapDegree")

        rotateBitmap = rotateBitmap?.rotateInt(rotateBitmapDegree)

        //rotateBitmap = rotateBitmap?.rotateFloat(rotateBitmapDegree.toFloat())

        iCropView.getCroppedPaper().setImageBitmap(rotateBitmap)

        enhancedPicture = rotateBitmap
        croppedBitmap = croppedBitmap?.rotateInt(rotateBitmapDegree)
    }

    fun save(): String? {
        if (ActivityCompat.checkSelfPermission(context, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
            Toast.makeText(context, "please grant write file permission and try again", Toast.LENGTH_SHORT).show()
        } else {
            val dir = File(Environment.getExternalStorageDirectory(), IMAGES_DIR)
            if (!dir.exists()) {
                dir.mkdirs()
            }

//            if(rotateBitmap != null) {
//                if (enhancedPicture != null) {
//                    enhancedPicture = rotateBitmap
//                    Log.i(TAG, "enhancedPicture Changed")
//                } else if(croppedBitmap != null){
//                    croppedBitmap = rotateBitmap
//                    Log.i(TAG, "rotateBitmap Changed")
//                }
//            }

            val rotatePic = rotateBitmap
            if (null != rotatePic) {
                val file = File(dir, "rotate_${SystemClock.currentThreadTimeMillis()}.png")
                val outStream = FileOutputStream(file)
                rotatePic.compress(Bitmap.CompressFormat.PNG, 100, outStream)
                outStream.flush()
                outStream.close()
                rotatePic.recycle()

                Log.i(TAG, "RotateBitmap Saved")

                return file.absolutePath

                //addImageToGallery(file.absolutePath, this.context) Commented as we don't want the images in the gallery.
                //Toast.makeText(context, "picture saved, path: ${file.absolutePath}", Toast.LENGTH_SHORT).show()
            }else {

                //first save enhanced picture, if picture is not enhanced, save cropped picture, otherwise nothing to do
                val pic = enhancedPicture
                if (null != pic) {
                    val file = File(dir, "enhance_${SystemClock.currentThreadTimeMillis()}.png")
                    val outStream = FileOutputStream(file)
                    pic.compress(Bitmap.CompressFormat.PNG, 100, outStream)
                    outStream.flush()
                    outStream.close()
                    pic.recycle()

                    Log.i(TAG, "EnhancedPicture Saved")

                    return file.absolutePath

                    //addImageToGallery(file.absolutePath, this.context) Commented as we don't want the images in the gallery.
                    //Toast.makeText(context, "picture saved, path: ${file.absolutePath}", Toast.LENGTH_SHORT).show()
                } else {
                    val cropPic = croppedBitmap
                    if (null != cropPic) {
                        val file = File(dir, "crop_${SystemClock.currentThreadTimeMillis()}.png")
                        val outStream = FileOutputStream(file)
                        cropPic.compress(Bitmap.CompressFormat.PNG, 100, outStream)
                        outStream.flush()
                        outStream.close()
                        cropPic.recycle()

                        Log.i(TAG, "CroppedBitmap Saved")

                        return file.absolutePath

                        //addImageToGallery(file.absolutePath, this.context) Commented as we don't want the images in the gallery.
                        //Toast.makeText(context, "picture saved, path: ${file.absolutePath}", Toast.LENGTH_SHORT).show()
                    }
                }
            }
        }
        return null
    }

    fun Bitmap.rotateFloat(degrees: Float): Bitmap {
        val matrix = Matrix().apply { postRotate(degrees) }
        return Bitmap.createBitmap(this, 0, 0, width, height, matrix, true)
    }

    // Extension function to rotate a bitmap
    fun Bitmap.rotateInt(degree:Int):Bitmap{
        // Initialize a new matrix
        val matrix = Matrix()

        // Rotate the bitmap
        matrix.postRotate(degree.toFloat())

        // Resize the bitmap
        val scaledBitmap = Bitmap.createScaledBitmap(
                this,
                width,
                height,
                true
        )

        // Create and return the rotated bitmap
        return Bitmap.createBitmap(
                scaledBitmap,
                0,
                0,
                scaledBitmap.width,
                scaledBitmap.height,
                matrix,
                true
        )
    }
}