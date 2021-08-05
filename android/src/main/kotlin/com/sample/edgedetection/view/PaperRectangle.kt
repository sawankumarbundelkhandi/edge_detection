package com.sample.edgedetection.view

import android.app.Activity
import android.content.Context
import android.graphics.*
import android.util.AttributeSet
import android.util.DisplayMetrics
import android.util.Log
import android.view.MotionEvent
import android.view.View
import com.sample.edgedetection.SourceManager
import com.sample.edgedetection.processor.Corners
import com.sample.edgedetection.processor.TAG
import org.opencv.core.Point
import org.opencv.core.Size
import kotlin.math.pow
import kotlin.math.sqrt


class PaperRectangle : View {
    constructor(context: Context) : super(context)
    constructor(context: Context, attributes: AttributeSet) : super(context, attributes)
    constructor(context: Context, attributes: AttributeSet, defTheme: Int) : super(
        context,
        attributes,
        defTheme
    )

    private val rectPaint = Paint()
    private val circlePaint = Paint()
    private var ratioX: Double = 1.0
    private var ratioY: Double = 1.0
    private var tl: Point = org.opencv.core.Point(100.toDouble(), 20.toDouble())
    private var tr: Point = org.opencv.core.Point(800.toDouble(), 20.toDouble())
    private var br: Point = org.opencv.core.Point(800.toDouble(), 500.toDouble())
    private var bl: Point = org.opencv.core.Point(100.toDouble(), 500.toDouble())
    private val path: Path = Path()
    private var point2Move = Point()
    private var cropMode = false
    private var latestDownX = 0.0F
    private var latestDownY = 0.0F

    init {
        rectPaint.color = Color.RED
        rectPaint.isAntiAlias = true
        rectPaint.isDither = true
        rectPaint.strokeWidth = 6F
        rectPaint.style = Paint.Style.STROKE
        rectPaint.strokeJoin = Paint.Join.ROUND    // set the join to round you want
        rectPaint.strokeCap = Paint.Cap.ROUND      // set the paint cap to round too
        rectPaint.pathEffect = CornerPathEffect(10f)

        circlePaint.color = Color.LTGRAY
        circlePaint.isDither = true
        circlePaint.isAntiAlias = true
        circlePaint.strokeWidth = 4F
        circlePaint.style = Paint.Style.STROKE
    }

    fun onCornersDetected(corners: Corners) {
        ratioX = corners.size.width.div(measuredWidth)
        ratioY = corners.size.height.div(measuredHeight)
        tl = corners.corners[0] ?: Point()
        tr = corners.corners[1] ?: Point()
        br = corners.corners[2] ?: Point()
        bl = corners.corners[3] ?: Point()

        Log.i(TAG, "POINTS ------>  $tl corners")

        resize()
        path.reset()
        path.moveTo(tl.x.toFloat(), tl.y.toFloat())
        path.lineTo(tr.x.toFloat(), tr.y.toFloat())
        path.lineTo(br.x.toFloat(), br.y.toFloat())
        path.lineTo(bl.x.toFloat(), bl.y.toFloat())
        path.close()
        invalidate()
    }

    fun onCornersNotDetected() {
        path.reset()
        invalidate()
    }

    fun onCorners2Crop(corners: Corners?, size: Size?) {

        val margin = 100.0
        cropMode = true
        val width: Double = size?.width ?: 0.0
        val height: Double = size?.height ?: 0.0
        val altura: Double = distance(corners)
        Log.i(TAG, "DIAGONAL ------>  $altura diagonal")
        if (altura < 700 ) {
            tl = org.opencv.core.Point(margin.toDouble(), margin.toDouble())
            tr = org.opencv.core.Point((width - margin).toDouble(), margin.toDouble())
            br = org.opencv.core.Point((width - margin).toDouble(), (height - margin).toDouble())
            bl = org.opencv.core.Point(margin.toDouble(), (height - margin).toDouble())
        } else {
            tl = corners?.corners?.get(0) ?: org.opencv.core.Point(margin.toDouble(), margin.toDouble())
            tr = corners?.corners?.get(1) ?: org.opencv.core.Point((width - margin).toDouble(), margin.toDouble())
            br = corners?.corners?.get(2) ?: org.opencv.core.Point((width - margin).toDouble(), (height - margin).toDouble())
            bl = corners?.corners?.get(3) ?: org.opencv.core.Point(margin.toDouble(), (height - margin).toDouble())
        }
        val displayMetrics = DisplayMetrics()
        (context as Activity).windowManager.defaultDisplay.getMetrics(displayMetrics)
        //exclude status bar height
        val statusBarHeight = getStatusBarHeight(context)
        val navigationBarHeight = getNavigationBarHeight(context)
        ratioX = size?.width?.div(displayMetrics.widthPixels) ?: 1.0
        ratioY = size?.height?.div(displayMetrics.heightPixels - statusBarHeight - navigationBarHeight) ?: 1.0
        resize()
        movePoints()
    }

    fun getCorners2Crop(): List<Point> {
        reverseSize()
        return listOf(tl, tr, br, bl)
    }

    override fun onDraw(canvas: Canvas?) {
        super.onDraw(canvas)
        if(!cropMode) {
            val margin = 40
            path.moveTo(margin.toFloat(), margin.toFloat())
            path.lineTo(((canvas?.width ?: 0) - margin).toFloat(), margin.toFloat())
            path.lineTo(((canvas?.width ?: 0) - margin).toFloat(), ((canvas?.height ?: 0) - 100).toFloat())
            path.lineTo(margin.toFloat(), ((canvas?.height ?: 0) - 100).toFloat())
            path.close()
        }
        canvas?.drawPath(path, rectPaint)
        if (cropMode) {
            canvas?.drawCircle(tl.x.toFloat(), tl.y.toFloat(), 20F, circlePaint)
            canvas?.drawCircle(tr.x.toFloat(), tr.y.toFloat(), 20F, circlePaint)
            canvas?.drawCircle(bl.x.toFloat(), bl.y.toFloat(), 20F, circlePaint)
            canvas?.drawCircle(br.x.toFloat(), br.y.toFloat(), 20F, circlePaint)
        }
    }

    override fun onTouchEvent(event: MotionEvent?): Boolean {

        if (!cropMode) {
            return false
        }
        when (event?.action) {
            MotionEvent.ACTION_DOWN -> {
                latestDownX = event.x
                latestDownY = event.y
                calculatePoint2Move(event.x, event.y)
            }
            MotionEvent.ACTION_MOVE -> {
                point2Move.x = (event.x - latestDownX) + point2Move.x
                point2Move.y = (event.y - latestDownY) + point2Move.y
                movePoints()
                latestDownY = event.y
                latestDownX = event.x
            }
        }
        return true
    }

    private fun calculatePoint2Move(downX: Float, downY: Float) {
        val points = listOf(tl, tr, br, bl)
        point2Move = points.minBy { Math.abs((it.x - downX).times(it.y - downY)) } ?: tl
    }

    private fun movePoints() {
        path.reset()
        path.moveTo(tl.x.toFloat(), tl.y.toFloat())
        path.lineTo(tr.x.toFloat(), tr.y.toFloat())
        path.lineTo(br.x.toFloat(), br.y.toFloat())
        path.lineTo(bl.x.toFloat(), bl.y.toFloat())
        path.close()
        invalidate()
    }


    private fun resize() {
        tl.x = tl.x.div(ratioX)
        tl.y = tl.y.div(ratioY)
        tr.x = tr.x.div(ratioX)
        tr.y = tr.y.div(ratioY)
        br.x = br.x.div(ratioX)
        br.y = br.y.div(ratioY)
        bl.x = bl.x.div(ratioX)
        bl.y = bl.y.div(ratioY)
    }

    private fun reverseSize() {
        tl.x = tl.x.times(ratioX)
        tl.y = tl.y.times(ratioY)
        tr.x = tr.x.times(ratioX)
        tr.y = tr.y.times(ratioY)
        br.x = br.x.times(ratioX)
        br.y = br.y.times(ratioY)
        bl.x = bl.x.times(ratioX)
        bl.y = bl.y.times(ratioY)
    }

    private fun getNavigationBarHeight(pContext: Context): Int {
        val resources = pContext.resources
        val resourceId = resources.getIdentifier("navigation_bar_height", "dimen", "android")
        return if (resourceId > 0) {
            resources.getDimensionPixelSize(resourceId)
        } else 0
    }

    private fun getStatusBarHeight(pContext: Context): Int {
        val resources = pContext.resources
        val resourceId = resources.getIdentifier("status_bar_height", "dimen", "android")
        return if (resourceId > 0) {
            resources.getDimensionPixelSize(resourceId)
        } else 0
    }

    private fun distance(corners: Corners?): Double {
        val corntl = corners?: null
        if (corntl != null) {
        val tl = corntl.corners[0] ?: org.opencv.core.Point()
        val br = corntl.corners[3] ?: org.opencv.core.Point()

        val d : Double = sqrt((
            (tl.x.toFloat()-br.x.toFloat()).pow(2) + 
            (tl.y.toFloat()-br.y.toFloat()).pow(2)
            ).toDouble())   
        return d
        }
        return 0.0
    }
}