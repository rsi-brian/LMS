"use strict";

// Import UI Notifications class/module
import { UINotifications } from "/includes/classes/UINotifications.js";
// Import the Training Module class (minified version)
import TrainingModule from "../classes/TrainingModule_250710.min.js";

// Set course name for the training module
const courseName = "RSI_Cybersecurity_Training";

// Export and initialize the training module with debug mode enabled
export const trainingModule = new TrainingModule({
    debug: true
});

// If the page was loaded from bfcache ("Back/Forward Cache"), force reload to reset state
window.addEventListener("pageshow", function(event) {
    if (event.persisted) {
        window.location.reload(true);
    }
});

// On DOM ready, create/init the training module for this course
document.addEventListener("DOMContentLoaded", function() {
    trainingModule.create(courseName);
});

// Push an initial state to the browser history to help control navigation
window.history.pushState({ page: 1 }, document.title, window.location.href);

// Prevent back/forward navigation and show a notification if attempted
window.addEventListener("popstate", function(event) {
    window.history.pushState({ page: 1 }, "", window.location.href);
    UINotifications.showToast(
        "<strong>Please note:</strong><br>The back and forward navigation buttons have been disabled for the purpose of this course."
    );
});

// On window load, push another state to the history to further block navigation
window.addEventListener("load", function() {
    history.pushState(null, null, location.href);
}, false);

// Before unloading (leaving/refreshing page), save and quit the SCORM session if active
window.addEventListener("beforeunload", function() {
    const scorm = pipwerks.SCORM;
    if (scorm.connection.isActive) {
        scorm.save();
        scorm.quit();
    }
});