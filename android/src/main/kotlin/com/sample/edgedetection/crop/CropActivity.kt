package com.sample.edgedetection.crop

import android.app.Activity
import android.content.Intent
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.widget.ImageView
import com.sample.edgedetection.R
import com.sample.edgedetection.SCANNED_RESULT
import com.sample.edgedetection.base.BaseActivity
import com.sample.edgedetection.view.PaperRectangle
import kotlinx.android.synthetic.main.activity_crop.*


class CropActivity : BaseActivity(), ICropView.Proxy {

    private var showMenuItems = false

    private lateinit var mPresenter: CropPresenter

    override fun prepare() {
    }

    override fun provideContentViewId(): Int = R.layout.activity_crop


    override fun initPresenter() {
        mPresenter = CropPresenter(this, this)
    }

    override fun getPaper(): ImageView = paper

    override fun getPaperRect(): PaperRectangle = paper_rect

    override fun getCroppedPaper(): ImageView = picture_cropped

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.crop_activity_menu, menu)

        menu.setGroupVisible(R.id.enhance_group, showMenuItems)

        menu.findItem(R.id.rotation_image).isVisible = showMenuItems

        if (showMenuItems) {
            menu.findItem(R.id.action_label)
                .setTitle(applicationContext.getString(R.string.done)).icon = applicationContext.getDrawable(R.drawable.ic_done)
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
            if (item.title == applicationContext.getString(R.string.crop)) {
                Log.e(TAG, "Crop touched!")
                mPresenter.crop()
                changeMenuVisibility(true)
                return true
            }

            if (item.title == applicationContext.getString(R.string.done)) {
                Log.e(TAG, "Saved touched!")
                var path = mPresenter.save()
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