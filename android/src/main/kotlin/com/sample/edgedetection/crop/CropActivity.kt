package com.sample.edgedetection.crop

import android.app.Activity
import android.content.Intent
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
        proceed.setOnClickListener {
            var path = mPresenter.proceed()
            setResult(Activity.RESULT_OK, Intent().putExtra(SCANNED_RESULT, path))
            System.gc()
            finish()
        }
    }

    override fun provideContentViewId(): Int = R.layout.activity_crop


    override fun initPresenter() {
        mPresenter = CropPresenter(this, this)
    }

    override fun getPaper(): ImageView = paper

    override fun getPaperRect(): PaperRectangle = paper_rect

    override fun getCroppedPaper(): ImageView = picture_cropped
}