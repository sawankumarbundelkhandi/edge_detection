package com.sample.edgedetection.scan

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.media.ExifInterface
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import android.view.Display
import android.view.MenuItem
import android.view.SurfaceView
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.sample.edgedetection.R
import com.sample.edgedetection.REQUEST_CODE
import com.sample.edgedetection.SCANNED_RESULT
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

    private val REQUEST_CAMERA_PERMISSION = 0

    private lateinit var mPresenter: ScanPresenter


    override fun provideContentViewId(): Int = R.layout.activity_scan

    companion object{
        public const val FROM_GALLERY = "from_gallery"
    }

    override fun initPresenter() {
        mPresenter = ScanPresenter(this, this)
    }

    override fun prepare() {
        if (!OpenCVLoader.initDebug()) {
            Log.i(TAG, "loading opencv error, exit")
            finish()
        }
        if (ContextCompat.checkSelfPermission(
                        this,
                        android.Manifest.permission.CAMERA
                ) != PackageManager.PERMISSION_GRANTED &&
                ContextCompat.checkSelfPermission(
                        this,
                        android.Manifest.permission.WRITE_EXTERNAL_STORAGE
                ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                    this,
                    arrayOf(
                            android.Manifest.permission.CAMERA,
                            android.Manifest.permission.WRITE_EXTERNAL_STORAGE
                    ),
                    REQUEST_CAMERA_PERMISSION
            )
        } else if (ContextCompat.checkSelfPermission(
                        this,
                        android.Manifest.permission.CAMERA
                ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                    this,
                    arrayOf(android.Manifest.permission.CAMERA),
                    REQUEST_CAMERA_PERMISSION
            )
        } else if (ContextCompat.checkSelfPermission(
                        this,
                        android.Manifest.permission.WRITE_EXTERNAL_STORAGE
                ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                    this,
                    arrayOf(android.Manifest.permission.WRITE_EXTERNAL_STORAGE),
                    REQUEST_CAMERA_PERMISSION
            )
        }

        shut.setOnClickListener {
            if (mPresenter.canShut) {
                mPresenter.shut()
            }
        }

        gallery.setOnClickListener {
            pickupFromGallery()
        };

        if(intent.hasExtra(FROM_GALLERY) && intent.getBooleanExtra(FROM_GALLERY, false)){
            pickupFromGallery()
        }
    }

    fun pickupFromGallery(){
        mPresenter.stop()
        val gallery = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.INTERNAL_CONTENT_URI)
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

    override fun onRequestPermissionsResult(
            requestCode: Int,
            permissions: Array<out String>,
            grantResults: IntArray
    ) {

        var allGranted = false
        var indexPermission = -1

        if (requestCode == REQUEST_CAMERA_PERMISSION) {
            if (grantResults.count() == 1) {
                if (permissions.indexOf(android.Manifest.permission.CAMERA) >= 0) {
                    indexPermission = permissions.indexOf(android.Manifest.permission.CAMERA)
                }
                if (permissions.indexOf(android.Manifest.permission.WRITE_EXTERNAL_STORAGE) >= 0) {
                    indexPermission =
                            permissions.indexOf(android.Manifest.permission.WRITE_EXTERNAL_STORAGE)
                }
                if (indexPermission >= 0 && grantResults[indexPermission] == PackageManager.PERMISSION_GRANTED) {
                    allGranted = true
                }
            }

            if (grantResults.count() == 2 && (
                            grantResults[permissions.indexOf(android.Manifest.permission.CAMERA)] == PackageManager.PERMISSION_GRANTED
                                    && grantResults[permissions.indexOf(android.Manifest.permission.WRITE_EXTERNAL_STORAGE)] == PackageManager.PERMISSION_GRANTED)
            ) {
                allGranted = true
            }
        }

        if (allGranted) {
            showMessage(R.string.camera_grant)
            mPresenter.initCamera()
            mPresenter.updateCamera()
        }

        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

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
                if (null != data && null != data.extras) {
                    val path = data.extras!!.getString(SCANNED_RESULT)
                    setResult(Activity.RESULT_OK, Intent().putExtra(SCANNED_RESULT, path))
                    finish()
                }
            }else{
                if(intent.hasExtra(FROM_GALLERY) && intent.getBooleanExtra(FROM_GALLERY, false))
                    finish()
            }
        }

        if (requestCode == 1) {
            if (resultCode == Activity.RESULT_OK) {
                val uri: Uri = data!!.data!!
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    onImageSelected(uri)
                }
            }else{
                if(intent.hasExtra(FROM_GALLERY) && intent.getBooleanExtra(FROM_GALLERY, false))
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
                ExifInterface.ORIENTATION_UNDEFINED)
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
