package com.sample.edgedetection.crop

import android.app.Activity
import android.content.Intent
import android.widget.ImageView
import com.sample.edgedetection.R
import com.sample.edgedetection.base.BaseActivity
import com.sample.edgedetection.view.PaperRectangle
import kotlinx.android.synthetic.main.activity_crop.*
import android.view.MenuItem
import android.view.Menu
import com.sample.edgedetection.SCANNED_RESULT


class CropActivity : BaseActivity(), ICropView.Proxy {

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
        return super.onCreateOptionsMenu(menu)
    }

    // handle button activities
    override fun onOptionsItemSelected(item: MenuItem): Boolean {

        if(item.itemId == android.R.id.home){
            onBackPressed()
            return true
        }

        if (item.itemId == R.id.action_label) {
            if(item.title == applicationContext.getString(R.string.next)){
                item.title = "Done"
                mPresenter.crop()
                return true
            }
            if(item.title == applicationContext.getString(R.string.done)){
                var path = mPresenter.save()
                setResult(Activity.RESULT_OK, Intent().putExtra(SCANNED_RESULT, path))
                System.gc()
                finish()
            return true
        }
        }

        return super.onOptionsItemSelected(item)
    }
}