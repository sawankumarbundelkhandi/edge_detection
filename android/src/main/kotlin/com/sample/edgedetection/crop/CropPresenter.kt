package com.sample.edgedetection.crop

import android.Manifest
import android.net.Uri
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
import android.os.Build
import android.media.MediaScannerConnection
import android.media.MediaScannerConnection.OnScanCompletedListener


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
    fun addImageToGalleryOldApi(filePath: String,context: Context) {
        if (Build.VERSION.SDK_INT > 28) {
            return
        }
        Log.i("ADD IMAGE TO GELLARY ${Build.VERSION.SDK_INT}", "${filePath}")
        val values = ContentValues()
        values.put(MediaStore.Images.Media.DATE_TAKEN, System.currentTimeMillis())
        values.put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
        values.put(MediaStore.MediaColumns.DATA,filePath)
        context.contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
    }
    fun addImageToGallery(fileName: String, bitmap: Bitmap, context: Context) {
        //val collection = MediaStore.Images.Media.getContentUri(MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
        if (Build.VERSION.SDK_INT < 29) {
            return
        }
        val collection = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        Log.i(TAG, "${fileName}")
        val values = ContentValues()
        values.put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
        values.put(MediaStore.MediaColumns.DATE_ADDED, System.currentTimeMillis())
        values.put(MediaStore.MediaColumns.DATE_MODIFIED, System.currentTimeMillis())
        values.put(MediaStore.MediaColumns.MIME_TYPE, "image/jpeg")
        values.put(MediaStore.MediaColumns.SIZE, bitmap.byteCount)
        values.put(MediaStore.MediaColumns.WIDTH, bitmap.width)
        values.put(MediaStore.MediaColumns.HEIGHT, bitmap.height)
        values.put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_PICTURES + "${File.separator}" + "${IMAGES_DIR}")
        values.put(MediaStore.Images.Media.IS_PENDING, 1)
        val uri = context.contentResolver.insert(collection, values)
        context.contentResolver.openOutputStream(uri!!, "w").use {
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, it)
        }
        Log.i(TAG, "${uri}")
        values.clear()
        values.put(MediaStore.Images.Media.IS_PENDING, 0)
        // val urii = Uri.fromFile(File(fileUrl!!)!!)
        context.contentResolver.update(uri!!, values, null, null)
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

        var imgToEnhace: Bitmap?
        if (enhancedPicture != null) {
            imgToEnhace = enhancedPicture
        } else if (rotateBitmap != null) {
            imgToEnhace = rotateBitmap
        } else {
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

    fun reset() {
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

        if (enhancedPicture != null && rotateBitmap == null) {
            Log.i(TAG, "enhancedPicture ***** TRUE")
            rotateBitmap = enhancedPicture;
        }

        if (rotateBitmap == null) {
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
            val dir: File
            if (Build.VERSION.SDK_INT < 29) {
              dir =  Environment.getExternalStoragePublicDirectory(
                        Environment.DIRECTORY_PICTURES);
            } else {
               val path = context.getExternalFilesDir(Environment.DIRECTORY_PICTURES)
               dir = File(path, IMAGES_DIR)
            }
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
                addImageToGallery("rotate_${SystemClock.currentThreadTimeMillis()}.jpeg", croppedBitmap!!, this.context)
                val file = File(dir, "rotate_${SystemClock.currentThreadTimeMillis()}.jpeg")
                val outStream = FileOutputStream(file)
                rotatePic.compress(Bitmap.CompressFormat.JPEG, 100, outStream)
                outStream.flush()
                outStream.close()
                rotatePic.recycle()
                addImageToGalleryOldApi(file.absolutePath,context)
                Log.i(TAG, "RotateBitmap Saved")
                return file.absolutePath
                //Commented as we don't want the images in the gallery.
                //Toast.makeText(context, "picture saved, path: ${file.absolutePath}", Toast.LENGTH_SHORT).show()
            } else {
                //first save enhanced picture, if picture is not enhanced, save cropped picture, otherwise nothing to do
                val pic = enhancedPicture

                if (null != pic) {
                    addImageToGallery("enhance_${SystemClock.currentThreadTimeMillis()}.jpeg", croppedBitmap!!, this.context)
                    val file = File(dir, "enhance_${SystemClock.currentThreadTimeMillis()}.jpeg")
                    val outStream = FileOutputStream(file)
                    pic.compress(Bitmap.CompressFormat.JPEG, 100, outStream)
                    outStream.flush()
                    outStream.close()
                    pic.recycle()
                    addImageToGalleryOldApi(file.absolutePath,context)
                    Log.i(TAG, "EnhancedPicture Saved")
                    return file.absolutePath
                    //addImageToGallery(file.absolutePath, this.context) Commented as we don't want the images in the gallery.
                    //Toast.makeText(context, "picture saved, path: ${file.absolutePath}", Toast.LENGTH_SHORT).show()
                 } else {
                    val cropPic = croppedBitmap
                    if (null != cropPic) {
                        addImageToGallery("crop_${SystemClock.currentThreadTimeMillis()}.jpeg", croppedBitmap!!, this.context)
                        val file = File(dir, "crop_${SystemClock.currentThreadTimeMillis()}.jpeg")
                        val outStream = FileOutputStream(file)
                        cropPic.compress(Bitmap.CompressFormat.JPEG, 100, outStream)
                        outStream.flush()
                        outStream.close()
                        cropPic.recycle()
                        addImageToGalleryOldApi(file.absolutePath,context)
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
    fun Bitmap.rotateInt(degree: Int): Bitmap {
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
