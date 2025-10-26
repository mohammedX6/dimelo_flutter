package com.flyingapps.dimelo_flutter

import android.app.Activity
import android.graphics.Color
import android.os.Bundle
import android.view.MenuItem
import androidx.appcompat.app.AppCompatActivity
import com.dimelo.dimelosdk.main.ChatActivity

/**
 * Custom ChatActivity that extends Dimelo's ChatActivity
 * to provide proper back button handling and app bar customization
 */
class CustomChatActivity : ChatActivity() {

    private var appBarTitle: String = "Dimelo Chat"
    private var appBarColor: Int = Color.BLUE
    private var appBarTitleColor: Int = Color.BLACK
    private var appBarVisible: Boolean = true
    private var showBackButton: Boolean = true
    private var backArrowColor: Int = Color.BLACK  // Added back arrow color property

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Get app bar configuration from intent extras
        intent?.let { intent ->
            appBarTitle = intent.getStringExtra("appBarTitle") ?: "Dimelo 11Chat"
            appBarColor = intent.getIntExtra("appBarColor", Color.BLUE)
            appBarTitleColor = intent.getIntExtra("appBarTitleColor", Color.BLACK)
            appBarVisible = intent.getBooleanExtra("appBarVisible", true)
            showBackButton = intent.getBooleanExtra("showBackButton", true)
            backArrowColor = intent.getIntExtra("backArrowColor", Color.BLACK)  // Get back arrow color
            
            // Debug logging
            android.util.Log.d("CustomChatActivity", "Received title color: ${String.format("#%06X", 0xFFFFFF and appBarTitleColor)}")
            android.util.Log.d("CustomChatActivity", "Received back arrow color: ${String.format("#%06X", 0xFFFFFF and backArrowColor)}")
            android.util.Log.d("CustomChatActivity", "Received app bar title: $appBarTitle")
        }

        // Apply app bar customization
        setupAppBar()
        updateTitleColor(appBarTitleColor)
        postDelayedTitleColorAttempts()
    }

    override fun onPostCreate(savedInstanceState: Bundle?) {
        super.onPostCreate(savedInstanceState)
        postDelayedTitleColorAttempts()
    }

    override fun onResume() {
        super.onResume()
        postDelayedTitleColorAttempts()
    }

    

    /**
     * Create a custom back arrow drawable with configurable color
     */
    private fun createCustomBackArrow(): android.graphics.drawable.Drawable {
        val size = (24 * resources.displayMetrics.density).toInt() // 24dp
        val bitmap = android.graphics.Bitmap.createBitmap(size, size, android.graphics.Bitmap.Config.ARGB_8888)
        val canvas = android.graphics.Canvas(bitmap)
        
        val paint = android.graphics.Paint().apply {
            color = backArrowColor
            strokeWidth = 3f
            style = android.graphics.Paint.Style.STROKE
            strokeCap = android.graphics.Paint.Cap.ROUND
            strokeJoin = android.graphics.Paint.Join.ROUND
            isAntiAlias = true
        }
        
        // Draw the arrow: <-- (pointing left)
        val centerY = size / 2f
        val startX = size * 0.2f
        val endX = size * 0.8f
        val arrowHeadLength = size * 0.15f
        
        // Main horizontal line
        canvas.drawLine(startX, centerY, endX, centerY, paint)
        
        // Top arrow head (pointing left)
        canvas.drawLine(startX, centerY, startX + arrowHeadLength, centerY - arrowHeadLength, paint)
        
        // Bottom arrow head (pointing left)
        canvas.drawLine(startX, centerY, startX + arrowHeadLength, centerY + arrowHeadLength, paint)
        
        android.util.Log.d("CustomChatActivity", "Created custom back arrow with color: ${String.format("#%06X", 0xFFFFFF and backArrowColor)}")
        
        return android.graphics.drawable.BitmapDrawable(resources, bitmap)
    }

    /**
     * Setup the app bar with custom configuration
     */
    private fun setupAppBar() {
        supportActionBar?.let { actionBar ->
            // Set title
            actionBar.title = appBarTitle

            // Set background color
            actionBar.setBackgroundDrawable(android.graphics.drawable.ColorDrawable(appBarColor))

            // Configure back button
            actionBar.setDisplayHomeAsUpEnabled(showBackButton)
            actionBar.setDisplayShowHomeEnabled(showBackButton)

            // Set back button icon
            if (showBackButton) {
                // Create a custom black arrow drawable
                val customBackArrow = createCustomBackArrow()
                actionBar.setHomeAsUpIndicator(customBackArrow)
            }

            // Set visibility
            if (appBarVisible) {
                actionBar.show()
            } else {
                actionBar.hide()
            }
        }
        
        // Also try to set the theme programmatically
        try {
            setTheme(android.R.style.Theme_DeviceDefault_Light_DarkActionBar)
        } catch (e: Exception) {
            android.util.Log.e("CustomChatActivity", "Failed to create theme", e)

            // Ignore if theme setting fails
        }
        
        // Try to create a custom title view
        try {
            val customTitleView = android.widget.TextView(this)
            customTitleView.text = appBarTitle
            customTitleView.textSize = 18f
            customTitleView.gravity = android.view.Gravity.CENTER
            actionBar?.customView = customTitleView
            actionBar?.setDisplayShowCustomEnabled(true)
            actionBar?.setDisplayShowTitleEnabled(false)
        } catch (e: Exception) {
            android.util.Log.e("CustomChatActivity", "Failed to create custom title view", e)
        }
    }

    fun updateTitleColor(newColor: Int) {
        appBarTitleColor = newColor
        supportActionBar?.customView?.let { customView ->
            if (customView is android.widget.TextView) {
                customView.setTextColor(appBarTitleColor)
            }
        }
        val titleTextView = findViewById<android.widget.TextView>(android.R.id.title)
        titleTextView?.setTextColor(appBarTitleColor)
        val toolbar = findViewById<androidx.appcompat.widget.Toolbar>(androidx.appcompat.R.id.action_bar)
        toolbar?.let { t ->
            val toolBarTitleView = t.findViewById<android.widget.TextView>(androidx.appcompat.R.id.action_bar_title)
            toolBarTitleView?.setTextColor(appBarTitleColor)
        }
        applySpannableTitleColor()
    }

    private fun applySpannableTitleColor() {
        try {
            val titleSpan = android.text.SpannableString(appBarTitle)
            titleSpan.setSpan(android.text.style.ForegroundColorSpan(appBarTitleColor), 0, titleSpan.length, 0)
            supportActionBar?.title = titleSpan
        } catch (_: Exception) {}
    }

    private fun postDelayedTitleColorAttempts() {
        val delays = listOf(50L, 100L, 200L, 350L, 500L, 800L)
        delays.forEach { d ->
            window.decorView.postDelayed({
                updateTitleColor(appBarTitleColor)
            }, d)
        }
    }

    /**
     * Handle back button press
     * This method is called when the user presses the back button in the action bar
     */
    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            android.R.id.home -> {
                // Handle back button press
                if (showBackButton) {
                    finish()
                    true
                } else {
                    super.onOptionsItemSelected(item)
                }
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    /**
     * Handle hardware back button press
     * This ensures the hardware back button also works properly
     */
    override fun onBackPressed() {
        if (showBackButton) {
            finish()
        } else {
            super.onBackPressed()
        }
    }
}
