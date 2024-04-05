<?php
function remove_dashboard_widgets() {
    global $wp_meta_boxes;

    // Widgets to keep
    $keep_widgets = [
        'dashboard_site_health' // Keep the Site Health widget
    ];

    // Go through the dashboard widgets and remove them if they are not in the keep list
    foreach ($wp_meta_boxes['dashboard']['normal']['core'] as $widget_id => $widget) {
        if (!in_array($widget_id, $keep_widgets)) {
            remove_meta_box($widget_id, 'dashboard', 'normal');
        }
    }
    foreach ($wp_meta_boxes['dashboard']['side']['core'] as $widget_id => $widget) {
        if (!in_array($widget_id, $keep_widgets)) {
            remove_meta_box($widget_id, 'dashboard', 'side');
        }
    }
}

add_action('wp_dashboard_setup', 'remove_dashboard_widgets');
