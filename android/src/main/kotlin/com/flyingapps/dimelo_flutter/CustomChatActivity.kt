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
    private var appBarVisible: Boolean = true
    private var showBackButton: Boolean = true
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Get app bar configuration from intent extras
        intent?.let { intent ->
            appBarTitle = intent.getStringExtra("appBarTitle") ?: "Dimelo Chat"
            appBarColor = intent.getIntExtra("appBarColor", Color.BLUE)
            appBarVisible = intent.getBooleanExtra("appBarVisible", true)
            showBackButton = intent.getBooleanExtra("showBackButton", true)
        }
        
        // Apply app bar customization
        setupAppBar()
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
                actionBar.setHomeAsUpIndicator(android.R.drawable.ic_menu_revert)
            }
            
            // Set visibility
            if (appBarVisible) {
                actionBar.show()
            } else {
                actionBar.hide()
            }
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
