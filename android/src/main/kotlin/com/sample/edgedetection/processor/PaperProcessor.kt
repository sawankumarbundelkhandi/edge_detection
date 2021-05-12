package com.sample.edgedetection.processor

import android.graphics.Bitmap
import android.util.Log
import org.opencv.android.Utils
import org.opencv.core.*
import org.opencv.imgproc.Imgproc

const val TAG: String = "PaperProcessor"

fun processPicture(previewFrame: Mat): Corners? {
    val contours = findContours(previewFrame)
    return getCorners(contours, previewFrame.size())
}

fun cropPicture(picture: Mat, pts: List<Point>): Mat {

    pts.forEach { Log.i(TAG, "point: " + it.toString()) }
    val tl = pts[0]
    val tr = pts[1]
    val br = pts[2]
    val bl = pts[3]

    val widthA = Math.sqrt(Math.pow(br.x - bl.x, 2.0) + Math.pow(br.y - bl.y, 2.0))
    val widthB = Math.sqrt(Math.pow(tr.x - tl.x, 2.0) + Math.pow(tr.y - tl.y, 2.0))

    val dw = Math.max(widthA, widthB)
    val maxWidth = java.lang.Double.valueOf(dw)!!.toInt()


    val heightA = Math.sqrt(Math.pow(tr.x - br.x, 2.0) + Math.pow(tr.y - br.y, 2.0))
    val heightB = Math.sqrt(Math.pow(tl.x - bl.x, 2.0) + Math.pow(tl.y - bl.y, 2.0))

    val dh = Math.max(heightA, heightB)
    val maxHeight = java.lang.Double.valueOf(dh)!!.toInt()

    val croppedPic = Mat(maxHeight, maxWidth, CvType.CV_8UC4)

    val src_mat = Mat(4, 1, CvType.CV_32FC2)
    val dst_mat = Mat(4, 1, CvType.CV_32FC2)

    src_mat.put(0, 0, tl.x, tl.y, tr.x, tr.y, br.x, br.y, bl.x, bl.y)
    dst_mat.put(0, 0, 0.0, 0.0, dw, 0.0, dw, dh, 0.0, dh)

    val m = Imgproc.getPerspectiveTransform(src_mat, dst_mat)

    Imgproc.warpPerspective(picture, croppedPic, m, croppedPic.size())
    m.release()
    src_mat.release()
    dst_mat.release()
    Log.i(TAG, "crop finish")
    return croppedPic
}

fun enhancePicture(src: Bitmap?): Bitmap {
    val src_mat = Mat()
    Utils.bitmapToMat(src, src_mat)
    Imgproc.cvtColor(src_mat, src_mat, Imgproc.COLOR_RGBA2GRAY)
    Imgproc.adaptiveThreshold(src_mat, src_mat, 255.0, Imgproc.ADAPTIVE_THRESH_MEAN_C, Imgproc.THRESH_BINARY, 15, 15.0)
    val result = Bitmap.createBitmap(src?.width ?: 1080, src?.height ?: 1920, Bitmap.Config.RGB_565)
    Utils.matToBitmap(src_mat, result, true)
    src_mat.release()
    return result
}

private fun findContours(src: Mat): ArrayList<MatOfPoint> {

    val grayImage: Mat
    val cannedImage: Mat
    val kernel: Mat = Imgproc.getStructuringElement(Imgproc.MORPH_RECT, Size(9.0, 9.0))
    val dilate: Mat
    val size = Size(src.size().width, src.size().height)
    grayImage = Mat(size, CvType.CV_8UC4)
    cannedImage = Mat(size, CvType.CV_8UC1)
    dilate = Mat(size, CvType.CV_8UC1)

    Imgproc.cvtColor(src, grayImage, Imgproc.COLOR_BGR2GRAY)
    Imgproc.GaussianBlur(grayImage, grayImage, Size(5.0, 5.0), 0.0)
    Imgproc.threshold(grayImage, grayImage, 20.0, 255.0, Imgproc.THRESH_TRIANGLE)
    Imgproc.Canny(grayImage, cannedImage, 75.0, 200.0)
    Imgproc.dilate(cannedImage, dilate, kernel)
    val contours = ArrayList<MatOfPoint>()
    val hierarchy = Mat()
    Imgproc.findContours(dilate, contours, hierarchy, Imgproc.RETR_TREE, Imgproc.CHAIN_APPROX_SIMPLE)
    contours.sortByDescending { p: MatOfPoint -> Imgproc.contourArea(p) }
    hierarchy.release()
    grayImage.release()
    cannedImage.release()
    kernel.release()
    dilate.release()

    return contours
}

private fun getCorners(contours: ArrayList<MatOfPoint>, size: Size): Corners? {
    val indexTo: Int
    when (contours.size) {
        in 0..5 -> indexTo = contours.size - 1
        else -> indexTo = 4
    }
    for (index in 0..contours.size) {
        if (index in 0..indexTo) {
            val c2f = MatOfPoint2f(*contours[index].toArray())
            val peri = Imgproc.arcLength(c2f, true)
            val approx = MatOfPoint2f()
            Imgproc.approxPolyDP(c2f, approx, 0.03 * peri, true)
            //val area = Imgproc.contourArea(approx)
            val points = approx.toArray().asList()
            var convex = MatOfPoint()
            approx.convertTo(convex, CvType.CV_32S);
            // select biggest 4 angles polygon
            if (points.size == 4 && Imgproc.isContourConvex(convex)){
                val foundPoints = sortPoints(points)
                return Corners(foundPoints, size)
            }
        } else {
            return null
        }
    }

    return null
}

private fun sortPoints(points: List<Point>): List<Point> {
    val p0 = points.minBy { point -> point.x + point.y } ?: Point()
    val p1 = points.minBy { point -> point.y - point.x } ?: Point()
    val p2 = points.maxBy { point -> point.x + point.y } ?: Point()
    val p3 = points.maxBy { point -> point.y - point.x } ?: Point()
    return listOf(p0, p1, p2, p3)
}