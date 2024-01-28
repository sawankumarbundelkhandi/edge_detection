package com.sample.edgedetectoin.zoomhelper;

import android.content.Context;
import android.graphics.PointF;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.Nullable;

public class ZoomableLayout extends ViewGroup
{
    /**
     * Limit the maximum/minimum scrolling to prevent scrolling the container,
     * so that no more children are visible.
     * The value is relative to the size of the container (so 0.1 means 10% of the size of this container)
     */
    protected float mTranslationBounds = 0.1f;
    /**
     * The translation to be applied to the container
     */
    protected PointF mTranslation;
    /**
     * The the current zoom factor.
     * It is initialized with a value smaller than 1, to append some empty space around the view.
     */
    protected float mScaleFactor = 0.95f;
    /**
     * The minimum scale factor to prevent endless zooming
     */
    protected float mScaleFactorMin = 0.8f;
    /**
     * The maximum scale factor to prevent endless zooming.
     */
    protected float mScaleFactorMax = 5.0f;
    /**
     * Used to indicate, whether or not this is the first touch event, which has no differences yet.
     */
    protected boolean mIsTouchStarted = false;
    /**
     * Distance of the fingers from the last touch event
     */
    protected float mStartDistance = 0;
    /**
     * Center of the two fingers from the last touch event.
     */
    protected PointF mStartTouchPoint = new PointF(0, 0);

    public ZoomContainer(Context context)
    {
        super(context);
    }

    public ZoomContainer(Context context, @Nullable AttributeSet attrs)
    {
        super(context, attrs);
    }

    public ZoomContainer(Context context, @Nullable AttributeSet attrs, int defStyleAttr)
    {
        super(context, attrs, defStyleAttr);
    }

    /**
     * Cancel all child touch events, if there is more than one finger down.
     */
    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev)
    {
        boolean intercept = ev.getPointerCount() > 1;
        if (intercept)
        {
            Log.d("TableView", "Intercepted");
            mIsTouchStarted = false;
        }
        return intercept;
    }

    protected void initializeTranslation()
    {
        if (mTranslation == null)
        {
            mTranslation = new PointF(getWidth() * (1 - mScaleFactor) / 2f,
                    getHeight() * (1 - mScaleFactor) / 2f);
            Log.d("TableView", "Translation: " + mTranslation);
        }
    }

    /**
     * Calculate the new zoom and scroll respecting the difference to the last touch event.
     */
    @Override
    public boolean onTouchEvent(MotionEvent event)
    {
        switch (event.getAction())
        {
            case MotionEvent.ACTION_CANCEL:
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_POINTER_UP:
                mIsTouchStarted = false;
                return true;
        }
        if (event.getPointerCount() <= 1)
        {
            mIsTouchStarted = false;
            return true;
        }
        float[] currentPointArray = new float[]{event.getX(0),
                event.getY(0),
                event.getX(1),
                event.getY(1)};
        float currentFingerDistance = getDistance(currentPointArray[0],
                currentPointArray[1],
                currentPointArray[2],
                currentPointArray[3]);
        // Read the current center of the fingers to determine the the new translation
        PointF currentPoint = getPoint(currentPointArray[0],
                currentPointArray[1],
                currentPointArray[2],
                currentPointArray[3]);
        if (mIsTouchStarted)
        {
            // 1 / oldScaleFactor - 1 / newScaleFactor is required to respect the relative translation,
            // when zooming (translation is always from the upper left corner,
            // but zooming should be performed centered to the fingers)
            float scaleFactorDifference = 1f / mScaleFactor;
            mScaleFactor = getBoundScaleFactor(mScaleFactor + (currentFingerDistance / mStartDistance - 1));
            scaleFactorDifference -= 1f / mScaleFactor;
            // Add the finger scroll since the last event to the current translation.
            PointF newTranslation = new PointF(mTranslation.x + (currentPoint.x - mStartTouchPoint.x) / mScaleFactor,
                    mTranslation.y + (currentPoint.y - mStartTouchPoint.y) / mScaleFactor);
            // Add the current point multiplied with the scale difference to make sure,
            // zooming is always done from the center of the fingers. Otherwise zooming would always be
            // applied from the upper left edge of the screen.
            newTranslation.x -= currentPoint.x * scaleFactorDifference;
            newTranslation.y -= currentPoint.y * scaleFactorDifference;
            mTranslation = getBoundTranslation(newTranslation);
        }
        mStartTouchPoint = currentPoint;
        mStartDistance = currentFingerDistance;
        mIsTouchStarted = true;
        requestLayout();
        return true;
    }

    protected float getBoundValue(float value, float min, float max)
    {
        return Math.min(Math.max(value, min), max);
    }

    protected PointF getBoundTranslation(PointF translation)
    {
        translation.x = getBoundValue(translation.x,
                -(getWidth() * (mScaleFactor - 1) + getWidth() * mTranslationBounds),
                getWidth() * mTranslationBounds);
        translation.y = getBoundValue(translation.y,
                -(getHeight() * (mScaleFactor - 1) + getHeight() * mTranslationBounds),
                getHeight() * mTranslationBounds);
        return translation;
    }

    protected float getBoundScaleFactor(float scaleFactor)
    {
        return getBoundValue(scaleFactor, mScaleFactorMin, mScaleFactorMax);
    }

    protected PointF getPoint(float x1, float y1, float x2, float y2)
    {
        return new PointF(getCenter(x1, x2), getCenter(y1, y2));
    }

    protected float getCenter(float position1, float position2)
    {
        return (position1 + position2) / 2f;
    }

    protected float getDistance(float x1, float y1, float x2, float y2)
    {
        float distanceX = Math.abs(x1 - x2);
        float distanceY = Math.abs(y1 - y2);
        return (float) Math.sqrt(Math.pow(distanceX, 2) + Math.pow(distanceY, 2));
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b)
    {
        float width = (r - l);
        float height = (b - t);
        if (width <= 0 || height <= 0)
        {
            return;
        }
        initializeTranslation();
        final int childCount = getChildCount();
        l = (int) (mTranslation.x * mScaleFactor);
        r = (int) ((width + mTranslation.x) * mScaleFactor);
        t = (int) (mTranslation.y * mScaleFactor);
        b = (int) ((height + mTranslation.y) * mScaleFactor);

        for (int i = 0; i < childCount; i++)
        {
            View child = getChildAt(i);
            child.layout(l, t, r, b);
        }
    }
}
