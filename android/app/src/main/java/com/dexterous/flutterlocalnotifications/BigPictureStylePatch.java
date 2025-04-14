package com.dexterous.flutterlocalnotifications;

import android.graphics.Bitmap;
import android.graphics.drawable.Icon;
import android.app.Notification.BigPictureStyle;

/**
 * This class is a patch for the ambiguity issue in the BigPictureStyle class.
 * It provides a method to explicitly set the bigLargeIcon with a Bitmap.
 */
public class BigPictureStylePatch {
    
    /**
     * Sets the bigLargeIcon with a Bitmap, resolving the ambiguity between
     * bigLargeIcon(Bitmap) and bigLargeIcon(Icon) methods.
     * 
     * @param style The BigPictureStyle to modify
     * @param bitmap The Bitmap to set as the bigLargeIcon
     * @return The modified BigPictureStyle
     */
    public static BigPictureStyle setBigLargeIconBitmap(BigPictureStyle style, Bitmap bitmap) {
        return style.bigLargeIcon(bitmap);
    }
} 