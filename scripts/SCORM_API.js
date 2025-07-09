'use strict';

import { trainingModule } from './course.js';

if (typeof trainingModule === 'undefined') {
    console.error('TrainingModule is inaccessible from within SCORM_API.js.');
    throw new Error("Error during API intialization.");

}

// const showConsole = (msg) => { return trainingModule.showDebug(msg, 'info') }                                            // Just here for convenience. For now.
const showConsole = (msg) => {  }

/* ------------------------------------ */
/* SCORM 1.2 RS&I API Implementation */
/* ------------------------------------ */
(function () {
    window.API = {

        data: {
            // "cmi.core.student_id": "",
            // "cmi.core.student_name": "",
            // "cmi.core.student_email": "TESTY_MCTESTERSON@rsiinc.com",
            // "cmi.core.lesson_location": "",
            // "cmi.core.lesson_status": "not attempted",
            // "cmi.core.credit": "",
            // "cmi.core.entry": "",
            // "cmi.core.score.raw": "",
            // "cmi.core.score.max": "",
            // "cmi.core.score.min": "",
            // "cmi.core.lesson_mode": "",
            // "cmi.core.exit": "",
            // "cmi.core.session_time": "",
            // "cmi.core.total_time": "",
            // "cmi.suspend_data": "",
            // "cmi.launch_data": "",
            // "cmi.comments": "",
        },
        errorCode: '0',
        diagnostic: '',

        LMSInitialize: function (param) {
showConsole('LMSInitialize');
showConsole(this.data);
showConsole('================================================================');
            this.errorCode = param == '' ? '0' : '201';

            if (param == '') {
                trainingModule.saveCourse(this.data);
            }

            return String(param == '');
        },

        LMSFinish: function (param) {
showConsole('LMSFinish');
// showConsole(this.data);
for (var key in this.data) {
    showConsole(`${key}: ${this.data[key]}`);
}
showConsole('================================================================');
            this.errorCode = param == '' ? '0' : '201';

            if (param == '') {
                trainingModule.saveCourse(this.data);
            }

            return String(param == '');
        },

        LMSGetValue: function (element) {
showConsole(`LMSGetValue ${element}: ${this.data[element]}`);
showConsole('================================================================');
            this.errorCode = '0';
            if (this.data[element] !== undefined) {
                return String(this.data[element]);
            }
            // If value doesn't exist, maybe set an errorCode or return an empty string
            return '';
        },

        LMSSetValue: function (element, value) {
showConsole(`LMSSetValue ${element}: ${value}`);
showConsole('================================================================');
            this.errorCode = '0';
            this.data[element] = value;
            return 'true';
        },

        LMSCommit: function () {
showConsole('LMSCommit');
showConsole(this.data);
showConsole('================================================================');
            this.errorCode = '0';
            trainingModule.saveCourse(this.data);
            return 'true';
        },

        LMSGetDiagnostic: function (param) {
showConsole('LMSGetDiagnostic');
showConsole(this.data);
showConsole('================================================================');
            this.errorCode = '0';
            return 'true';
        },

        LMSGetLastError: function () {
showConsole(`LMSGetLastError ${this.errorCode}`);
showConsole('================================================================');
            return this.errorCode;
        },

        LMSGetErrorString: function (errorCode) {
showConsole('LMSGetErrorString');
showConsole(errorCode);
showConsole('================================================================');
            // Just return a generic string
            return 'No error';
        },
    };
})();


/* -------------------------------------- */
/* SCORM 2004 RS&I API Implementation  */
/* -------------------------------------- */
(function () {
    window.API_1484_11 = {

        data: {
            // "cmi.completion_status": "unknown",
            // "cmi.success_status": "unknown",
            // "cmi.learner_id": "",
            // "cmi.learner_name": "",
            // "cmi.learner_email": "TESTY_MCTESTERSON@rsiinc.com",
            // "cmi.location": "",
            // "cmi.completion_threshold": "",
            // "cmi.scaled_passing_score": "",
            // "cmi.progressive_measure": "",
            // "cmi.score.raw": "",
            // "cmi.score.max": "",
            // "cmi.score.min": "",
            // "cmi.score.scaled": "",
            // "cmi.total_time": "",
            // "cmi.time_limit_action": "",
            // "cmi.max_time_allowed": "",
            // "cmi.session_time": "",
            // "cmi.lesson_mode": "",
            // "cmi.entry": "",
            // "cmi.exit": "",
            // "cmi.credit": "",
            // "cmi.mode": "",
            // "cmi.suspend_data": "",
            // "cmi.launch_data": "",
            // "cmi.comments": "",
        },
        errorCode: '0',
        diagnostic: '',

        Initialize: function (param) {
showConsole('Initialize');
showConsole(this.data);
showConsole('================================================================');
            this.errorCode = param == '' ? '0' : '201';

            if (param == '') {
                trainingModule.saveCourse(this.data);
            }

            return String(param == '');
        },

        Terminate: function (param) {
showConsole('Terminate');
// showConsole(this.data);
for (var key in this.data) {
    showConsole(`${key}: ${this.data[key]}`);
}
showConsole('================================================================');
            this.errorCode = param == '' ? '0' : '201';

            if (param == '') {
                trainingModule.saveCourse(this.data);
            }

            return String(param == '');
        },

        SetValue: function (element, value) {
            this.errorCode = '0';

            if (element.startsWith("cmi.interactions.")) {
                const match = element.match(/^cmi\.interactions\.(\d+)\.(\w+)$/);
                if (match) {
                    const index = parseInt(match[1], 10);
                    const field = match[2];

                    if (!this.data["cmi.interactions"]) {
                        this.data["cmi.interactions"] = {};
                    }
                    if (!this.data["cmi.interactions"][index]) {
                        this.data["cmi.interactions"][index] = {};
                    }

                    this.data["cmi.interactions"][index][field] = value;

                    const currentCount = parseInt(this.data["cmi.interactions._count"] || "0", 10);
                    if (index >= currentCount) {
                        this.data["cmi.interactions._count"] = (index + 1).toString();
                    }

                    return "true";
                }
            }

            this.data[element] = value;
            return "true";
        },

        GetValue: function (element) {
            this.errorCode = '0';

            if (element === "cmi.interactions._count") {
                return this.data["cmi.interactions._count"] || "0";
            }

            const match = element.match(/^cmi\.interactions\.(\d+)\.(\w+)$/);
            if (match) {
                const index = parseInt(match[1], 10);
                const field = match[2];

                if (this.data["cmi.interactions"] &&
                    this.data["cmi.interactions"][index] &&
                    this.data["cmi.interactions"][index][field] !== undefined) {
                        return this.data["cmi.interactions"][index][field];
                } else {
                    this.errorCode = '401';                                                                             // Not initialized
                    return "";
                }
            }

            return this.data[element] !== undefined ? this.data[element] : "";
        },


//         GetValue: function (element) {
// showConsole(`GetValue ${element}: ${this.data[element]}`);
// showConsole('================================================================');
//             this.errorCode = '0';
//             if (this.data[element] !== undefined) {
//                 return String(this.data[element]);
//             }
//             return '';
//         },

//         SetValue: function (element, value) {
// console.info(`${element} -> ${value}`);
// showConsole(`SetValue ${element}: ${value}`);
// showConsole('================================================================');
//             this.errorCode = '0';
//             this.data[element] = value;
//             return 'true';
//         },

        Commit: function () {
showConsole('Commit');
showConsole(this.data);
showConsole('================================================================');
            this.errorCode = '0';
            trainingModule.saveCourse(this.data);
            return 'true';
        },

        GetLastError: function () {
showConsole(`GetLastError ${this.errorCode}`);
showConsole('================================================================');
            return this.errorCode;
        },

        GetErrorString: function (errorCode) {
showConsole('GetErrorString');
            let errorString = '';

            if (errorCode != '') {
                switch(errorCode) {
                    case '0':
                        errorString = 'No error';
                    break;
                    case '101':
                        errorString = 'General exception';
                    break;
                    case '102':
                        errorString = 'General Inizialization Failure';
                    break;
                    case '103':
                        errorString = 'Already Initialized';
                    break;
                    case '104':
                        errorString = 'Content Instance Terminated';
                    break;
                    case '111':
                        errorString = 'General Termination Failure';
                    break;
                    case '112':
                        errorString = 'Termination Before Inizialization';
                    break;
                    case '113':
                        errorString = 'Termination After Termination';
                    break;
                    case '122':
                        errorString = 'Retrieve Data Before Initialization';
                    break;
                    case '123':
                        errorString = 'Retrieve Data After Termination';
                    break;
                    case '132':
                        errorString = 'Store Data Before Inizialization';
                    break;
                    case '133':
                        errorString = 'Store Data After Termination';
                    break;
                    case '142':
                        errorString = 'Commit Before Inizialization';
                    break;
                    case '143':
                        errorString = 'Commit After Termination';
                    break;
                    case '201':
                        errorString = 'General Argument Error';
                    break;
                    case '301':
                        errorString = 'General Get Failure';
                    break;
                    case '351':
                        errorString = 'General Set Failure';
                    break;
                    case '391':
                        errorString = 'General Commit Failure';
                    break;
                    case '401':
                        errorString = 'Undefinited Data Model';
                    break;
                    case '402':
                        errorString = 'Unimplemented Data Model Element';
                    break;
                    case '403':
                        errorString = 'Data Model Element Value Not Initialized';
                    break;
                    case '404':
                        errorString = 'Data Model Element Is Read Only';
                    break;
                    case '405':
                        errorString = 'Data Model Element Is Write Only';
                    break;
                    case '406':
                        errorString = 'Data Model Element Type Mismatch';
                    break;
                    case '407':
                        errorString = 'Data Model Element Value Out Of Range';
                    break;
                    case '408':
                        errorString = 'Data Model Dependency Not Established';
                    break;
                }
            }
showConsole(`${errorCode}: ${errorString}`);
showConsole('================================================================');
            return errorString;
        },
    };
})();
