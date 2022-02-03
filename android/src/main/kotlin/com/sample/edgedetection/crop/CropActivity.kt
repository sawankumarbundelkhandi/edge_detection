package com.sample.edgedetection.crop

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.ImageView
import androidx.appcompat.content.res.AppCompatResources
import com.sample.edgedetection.R
import com.sample.edgedetection.SCANNED_RESULT
import com.sample.edgedetection.base.BaseActivity
import com.sample.edgedetection.view.PaperRectangle
import kotlinx.android.synthetic.main.activity_crop.*


class CropActivity : BaseActivity(), ICropView.Proxy {

    private var showMenuItems = false

    private lateinit var mPresenter: CropPresenter

    override fun prepare() {
        /*proceed.setOnClickListener {
            var path = mPresenter.proceed()
            setResult(Activity.RESULT_OK, Intent().putExtra(SCANNED_RESULT, path))
            System.gc()
            finish()
        }*/
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        paper.post {
            //we have to initialize everything in post when the view has been drawn and we have the actual height and width of the whole view
            mPresenter.onViewsReady(paper.width, paper.height)
        }
    }

    override fun provideContentViewId(): Int = R.layout.activity_crop


    override fun initPresenter() {
        mPresenter = CropPresenter(this, this)
        findViewById<ImageView>(R.id.crop).setOnClickListener {
            Log.e(TAG, "Crop touched!")
            mPresenter.crop()
            changeMenuVisibility(true)
        }
    }

    override fun getPaper(): ImageView = paper

    override fun getPaperRect(): PaperRectangle = paper_rect

    override fun getCroppedPaper(): ImageView = picture_cropped

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.crop_activity_menu, menu)

        menu.setGroupVisible(R.id.enhance_group, showMenuItems)

        menu.findItem(R.id.rotation_image).isVisible = showMenuItems

        if (showMenuItems) {
            menu.findItem(R.id.action_label).isVisible = true
            findViewById<ImageView>(R.id.crop).visibility = View.GONE
        } else {
            menu.findItem(R.id.action_label).isVisible = false
            findViewById<ImageView>(R.id.crop).visibility = View.VISIBLE
        }

        return super.onCreateOptionsMenu(menu)
    }


    private fun changeMenuVisibility(showMenuItems: Boolean) {
        this.showMenuItems = showMenuItems
        invalidateOptionsMenu()
    }

    // handle button activities
    override fun onOptionsItemSelected(item: MenuItem): Boolean {

        if (item.itemId == android.R.id.home) {
            onBackPressed()
            return true
        }

        if (item.itemId == R.id.action_label) {
            Log.e(TAG, item.title.toString())

            if (item.title == applicationContext.getString(R.string.done)) {
                Log.e(TAG, "Saved touched!")
                val path = mPresenter.save()
                Log.e(TAG, "Saved touched! $path")
                setResult(Activity.RESULT_OK, Intent().putExtra(SCANNED_RESULT, path))
                System.gc()
                finish()
                return true
            }
        }

        if (item.title == applicationContext.getString(R.string.rotate)) {
            Log.e(TAG, "Rotate touched!")
            mPresenter.rotate()
            return true
        }


        if (item.title == applicationContext.getString(R.string.black)) {
            Log.e(TAG, "Black White touched!")
            mPresenter.enhance()
            return true
        }

        if (item.title == applicationContext.getString(R.string.reset)) {
            Log.e(TAG, "Reset touched!")
            mPresenter.reset()
            return true
        }

        return super.onOptionsItemSelected(item)
    }
}