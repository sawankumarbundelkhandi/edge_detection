package com.sample.edgedetection.scan

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.media.ExifInterface
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import android.util.Log
import android.view.*
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import com.sample.edgedetection.EdgeDetectionHandler
import com.sample.edgedetection.R
import com.sample.edgedetection.REQUEST_CODE
import com.sample.edgedetection.base.BaseActivity
import com.sample.edgedetection.view.PaperRectangle
import kotlinx.android.synthetic.main.activity_scan.*
import org.opencv.android.OpenCVLoader
import org.opencv.core.Core
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.core.Size
import org.opencv.imgcodecs.Imgcodecs
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.io.InputStream

class ScanActivity : BaseActivity(), IScanView.Proxy {

    private lateinit var mPresenter: ScanPresenter;

    override fun provideContentViewId(): Int = R.layout.activity_scan

    override fun initPresenter() {
        val initialBundle = intent.getBundleExtra(EdgeDetectionHandler.INITIAL_BUNDLE) as Bundle;
        mPresenter = ScanPresenter(this, this, initialBundle)
    }

    override fun prepare() {
        if (!OpenCVLoader.initDebug()) {
            Log.i(TAG, "loading opencv error, exit")
            finish()
        }

        shut.setOnClickListener {
            if (mPresenter.canShut) {
                mPresenter.shut()
            }
        }

        flash.visibility =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                // to hidde the flashLight button from  SDK versions which we do not handle the permission for!
                Build.VERSION.SDK_INT <= Build.VERSION_CODES.Q &&
                //
                baseContext.packageManager.hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH)
            ) View.VISIBLE else View.GONE;
        flash.setOnClickListener {
            mPresenter.toggleFlash();
        }

        val initialBundle = intent.getBundleExtra(EdgeDetectionHandler.INITIAL_BUNDLE) as Bundle;

        this.title = initialBundle.getString(EdgeDetectionHandler.SCAN_TITLE) as String

        gallery.visibility =
            if (initialBundle.getBoolean(EdgeDetectionHandler.CAN_USE_GALLERY, true))
                View.VISIBLE
            else View.GONE;

        gallery.setOnClickListener {
            pickupFromGallery()
        };

        if (initialBundle.containsKey(EdgeDetectionHandler.FROM_GALLERY) && initialBundle.getBoolean(
                EdgeDetectionHandler.FROM_GALLERY,
                false
            )
        ) {
            pickupFromGallery()
        }
    }

    fun pickupFromGallery() {
        mPresenter.stop()
        val gallery = Intent(
            Intent.ACTION_PICK,
            android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI).apply{
            type="image/*"
        }
        ActivityCompat.startActivityForResult(this, gallery, 1, null);
    }


    override fun onStart() {
        super.onStart()
        mPresenter.start()
    }

    override fun onStop() {
        super.onStop()
        mPresenter.stop()
    }

    override fun exit() {
        finish()
    }

    override fun getCurrentDisplay(): Display? {
        return if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
            this.display
        } else {
            this.windowManager.defaultDisplay
        }
    }

    override fun getSurfaceView(): SurfaceView = surface

    override fun getPaperRect(): PaperRectangle = paper_rect

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                setResult(Activity.RESULT_OK)
                finish()
            } else {
                if (intent.hasExtra(EdgeDetectionHandler.FROM_GALLERY) && intent.getBooleanExtra(
                        EdgeDetectionHandler.FROM_GALLERY, false
                    )
                )
                    finish()
            }
        }

        if (requestCode == 1) {
            if (resultCode == Activity.RESULT_OK) {
                val uri: Uri = data!!.data!!
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    onImageSelected(uri)
                }
            } else {
                if (intent.hasExtra(EdgeDetectionHandler.FROM_GALLERY) && intent.getBooleanExtra(
                        EdgeDetectionHandler.FROM_GALLERY,
                        false
                    )
                )
                    finish()
            }
        }
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {

        if (item.itemId == android.R.id.home) {
            onBackPressed()
            return true
        }

        return super.onOptionsItemSelected(item)
    }

    @RequiresApi(Build.VERSION_CODES.N)
    fun onImageSelected(imageUri: Uri) {
        val iStream: InputStream = contentResolver.openInputStream(imageUri)!!

        val exif = ExifInterface(iStream);
        var rotation = -1
        val orientation: Int = exif.getAttributeInt(
            ExifInterface.TAG_ORIENTATION,
            ExifInterface.ORIENTATION_UNDEFINED
        )
        when (orientation) {
            ExifInterface.ORIENTATION_ROTATE_90 -> rotation = Core.ROTATE_90_CLOCKWISE
            ExifInterface.ORIENTATION_ROTATE_180 -> rotation = Core.ROTATE_180
            ExifInterface.ORIENTATION_ROTATE_270 -> rotation = Core.ROTATE_90_COUNTERCLOCKWISE
        }
        Log.i(TAG, "rotation:" + rotation)

        var imageWidth = exif.getAttributeInt(ExifInterface.TAG_IMAGE_WIDTH, 0).toDouble()
        var imageHeight = exif.getAttributeInt(ExifInterface.TAG_IMAGE_LENGTH, 0).toDouble()
        if (rotation == Core.ROTATE_90_CLOCKWISE || rotation == Core.ROTATE_90_COUNTERCLOCKWISE) {
            imageWidth = exif.getAttributeInt(ExifInterface.TAG_IMAGE_LENGTH, 0).toDouble()
            imageHeight = exif.getAttributeInt(ExifInterface.TAG_IMAGE_WIDTH, 0).toDouble()
        }
        Log.i(TAG, "width:" + imageWidth)
        Log.i(TAG, "height:" + imageHeight)

        val inputData: ByteArray? = getBytes(contentResolver.openInputStream(imageUri)!!)
        val mat = Mat(Size(imageWidth, imageHeight), CvType.CV_8U)
        mat.put(0, 0, inputData)
        val pic = Imgcodecs.imdecode(mat, Imgcodecs.CV_LOAD_IMAGE_UNCHANGED)
        if (rotation > -1) Core.rotate(pic, pic, rotation)
        mat.release()

        mPresenter.detectEdge(pic);
    }

    @Throws(IOException::class)
    fun getBytes(inputStream: InputStream): ByteArray? {
        val byteBuffer = ByteArrayOutputStream()
        val bufferSize = 1024
        val buffer = ByteArray(bufferSize)
        var len = 0
        while (inputStream.read(buffer).also { len = it } != -1) {
            byteBuffer.write(buffer, 0, len)
        }
        return byteBuffer.toByteArray()
    }
}
