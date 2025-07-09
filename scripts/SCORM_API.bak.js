// import { showDebug } from './training.js';

/* ------------------------------------ */
/* SCORM 1.2 Minimal API Implementation */
/* ------------------------------------ */
(function () {
    // Create the API object on the window
    window.API = {
        // We'll keep an in-memory data structure for SCORM data
        data: {
            "cmi.core.lesson_status": "not attempted",
            "cmi.core.score.raw": "",
            "cmi.core.lesson_location": "",
            "cmi.core.student_id": "",
            "cmi.core.student_name": "",
            // add more as needed
        },
        errorCode: "0", // Simplified error handling

        LMSInitialize: function (param) {
            this.errorCode = "0";
																														showDebug("SCORM 1.2 -> LMSInitialize called");
                                                                                                                        if (param) { showDebug(`With Parameter: ${param}`); }
																														showDebug("===========================================================");
																														showDebug("SHOWING this & this.data FROM WITHIN LMSInitialize:");
																														showDebug(this);
																														showDebug(this.data);
																														showDebug("===========================================================");
            return "true"; // SCORM expects a string "true" or "false"
        },

        LMSFinish: function (param) {
            this.errorCode = "0";
																														showDebug("SCORM 1.2 -> LMSFinish called");
                                                                                                                        if (param) { showDebug(`With Parameter: ${param}`); }
            // If you want to finalize or store data in a DB, do it here
																														showDebug(this.data);
            // Show finished? Menu? Goodbye page?
            return "true";
        },

        LMSGetValue: function (element) {
            this.errorCode = "0";
																														showDebug("SCORM 1.2 -> LMSGetValue called for: " + element);
            if (this.data[element] !== undefined) {
                return String(this.data[element]);
            }
            // If value doesn't exist, maybe set an errorCode or return an empty string
            return "";
        },

        LMSSetValue: function (element, value) {
																														showDebug(`SCORM 1.2 -> LMSSetValue called. ${element} = ${value}`);
            this.errorCode = "0";
            this.data[element] = value;
                                                                                                                        showDebug(this.data);
            return "true";
        },

        LMSCommit: function (param) {
																														showDebug("SCORM 1.2 -> LMSCommit called");
                                                                                                                        if (param) { showDebug(`With Parameter: ${param}`); }
            this.errorCode = "0";
            // Here is where you might store `this.data` in a database
																														showDebug(this.data);
            return "true";
        },

        LMSGetDiagnostic: function (param) {
																														showDebug("SCORM 1.2 -> LMSGetDiagnostic called");
                                                                                                                        if (param) { showDebug(`With Parameter: ${param}`); }
            this.errorCode = "0";
            return "true";
        },

        LMSGetLastError: function () {
            return this.errorCode;
        },

        LMSGetErrorString: function (errorCode) {
            // Just return a generic string
            return "No error";
        },
    };
})();


/* -------------------------------------- */
/* SCORM 2004 Minimal API Implementation  */
/* -------------------------------------- */
(function () {
    // Create the API_1484_11 object on the window
    window.API_1484_11 = {
        // We'll keep an in-memory data structure
        data: {
            "cmi.completion_status": "unknown",
            "cmi.success_status": "unknown",
            "cmi.score.raw": "",
            "cmi.location": "",
            // "cmi.core.student_id": "",
            // "cmi.core.student_name": "",
            // add more as needed
        },
        errorCode: "0",

        Initialize: function () {
            this.errorCode = "0";
																														showDebug("SCORM 2004 -> Initialize called");
																														showDebug(this.data);
																														showDebug("===========================================================");
																														showDebug("SHOWING this & this.data FROM WITHIN Initialize:");
																														showDebug(this);
																														showDebug(this.data);
																														showDebug("===========================================================");
            return "true";
        },

        Terminate: function () {
																														showDebug("SCORM 2004 -> Terminate called");
																														showDebug(this.data);
            this.errorCode = "0";
            // Load the goodbye.html page?
            // Commit data if needed
            return "true";
        },

        GetValue: function (element) {
																														showDebug("SCORM 2004 -> GetValue called for: " + element);
            this.errorCode = "0";
            if (this.data[element] !== undefined) {
                return String(this.data[element]);
            }
            return "";
        },

        SetValue: function (element, value) {
                                                                                                                        showDebug(`SCORM 2004 -> SetValue called. ${element} = ${value}`);
																														// showDebug(`SCORM 2004 -> SetValue called. ${element}`);
																														// showDebug(this.data);
            this.errorCode = "0";
            this.data[element] = value;
            return "true";
        },

        Commit: function () {
																														showDebug("SCORM 2004 -> Commit called");
																														showDebug(this.data);
            this.errorCode = "0";
            // Here is where you might store `this.data` in your DB
            return "true";
        },

        GetLastError: function () {
            return this.errorCode;
        },

        GetErrorString: function (errorCode) {
            // Just return a generic string
            return "No error";
        },
    };
})();