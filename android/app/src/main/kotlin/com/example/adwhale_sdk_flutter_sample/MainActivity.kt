package com.example.adwhale_sdk_flutter_sample

import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import net.adwhale.sdk.adwhale_sdk_flutter.AdWhaleCustomNativeBinderFactory
import net.adwhale.sdk.adwhale_sdk_flutter.AdWhaleSdkFlutterPlugin

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Register BinderFactory for custom binding test (factoryId: app_custom)
        AdWhaleSdkFlutterPlugin.registerBinderFactory(
            "app_custom",
            AdWhaleCustomNativeBinderFactory(
                R.layout.custom_native_ad_main_layout,
                R.id.main_view_icon,
                R.id.main_view_title,
                R.id.main_view_body,
                R.id.main_button_cta,
                R.id.main_view_media
            )
        )
    }
}
