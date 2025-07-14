'use strict';

import { UINotifications } from "/includes/classes/UINotifications.js";
import TrainingModule from "../classes/TrainingModule_250320.min.js";
import { LMSAuth } from "/includes/Authentication/Authenticate.min.js";

const urlParams = new URLSearchParams(window.location.search);


// EVENT LISTENERS //

// Force reload if coming from bfcache
window.addEventListener("pageshow", function (event) {
    if (event.persisted) {
        window.location.reload(true);
    }
});

document.addEventListener('DOMContentLoaded', async function() {
    if (await LMSAuth.verifyLogin()) {
        const courseID = urlParams.get('courseid');
        const courseName = urlParams.get('name');
        trainingModule.create(courseID, courseName);
    }
});

// Prevent back/forward navigation on the training course pages
window.history.pushState({page: 1}, document.title, window.location.href);

// Push the state back to prevent navigation so it stays on the same page
window.addEventListener('popstate', function(event) {
    window.history.pushState({page: 1}, "", window.location.href);
    UINotifications.showToast('<strong>Please note:</strong><br>The back and forward navigation buttons have been disabled for the purpose of this course.');
});

// Handle clicks on the browser's back button
window.addEventListener('load', function() {
    history.pushState(null, null, location.href);
}, false);

// Cleanup when closing
// Use pageshow/pagehide
// https://web.dev/articles/bfcache
window.addEventListener('beforeunload', function() {
    const scorm = pipwerks.SCORM;
    if (scorm.connection.isActive) {
        scorm.save();
        scorm.quit();
    }
});



export const trainingModule = new TrainingModule({ "debug": true });