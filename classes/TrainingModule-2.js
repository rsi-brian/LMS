/**
 * NOTES
 *
 * If cmi(.core)?.exit === "suspend", the user has not passed or completed the course
 * If cmi(.core)?.exit === "logout/normal", the user has passed and completed the course
 * if cmi.core.lesson_status === "passed", the course is complete. DOES NOT mention whether or not quizes have been passed successfully.
 *
 */

'use strict';

export default class TrainingModule {

    constructor(classOptions) {
        this.OPTIONS = {
            "debug": false,
        }
        this.COURSE = {};
        this.USER_DATA = {};
        this.DEBUG_MODE = (classOptions?.debug === true || classOptions?.debug?.toLowerCase() === 'true') ? true : this.OPTIONS.debug;
        this.RSI_TRAINING_PATH = '/training';
        this.RSI_COURSES_PATH = `${this.RSI_TRAINING_PATH}/courses`;
        this.RSI_FUNCTIONS = `${this.RSI_TRAINING_PATH}/scripts/functions.asp`;
        this.PIPWERKS_SCORM = pipwerks.SCORM;

        if (typeof pipwerks !== "undefined") this.PIPWERKS_SCORM.debug.isActive = this.DEBUG_MODE;
    }


    // PRIVATE METHODS //

    async #getManifest(path) {
        try {
            const response = await fetch(`${this.RSI_COURSES_PATH}/${path}/imsmanifest.xml`);

            if (!response.ok) {
                throw new Error(`Error ${response.status} when fetching ${response.url}.`);
            }

            return response;
        }
        catch (error) {
            this.showDebug(error, 'error');
            this.showModal("<p style='text-align:left'><strong>Error</strong>: The course could not be found.<br>Please try refreshing the page or contact support if the problem persists.</p>", 600000);
            return false;
        }
    }

    async #getUserData() {
        return fetch(this.RSI_FUNCTIONS, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'action=getUserData'
        })
        .then(response => response.json())
        .then(data => {
            return data;
        })
        .catch(error => {
            this.showDebug(`Error getting user data: ${error}`, "error");
            return false;
        });
    }

    async #processManifest(response) {
        try {
            const xmlText = await response.text();
            const parser = new DOMParser();
            const xmlDoc = parser.parseFromString(xmlText, 'text/xml');
            const resourceElement = xmlDoc.querySelector('resources > resource');
            const schemaElement = xmlDoc.querySelector('metadata > schema');
            const schemaversionElement = xmlDoc.querySelector('metadata > schemaversion');
            const titleElement = xmlDoc.querySelector('organizations > organization > title');
            const manifestElement = xmlDoc.querySelector('manifest');

            if (schemaElement) {
                this.COURSE.schema = schemaElement.textContent;
            } else {
                throw new Error('Schema element not found.');
            }

            if (schemaversionElement) {
                this.COURSE.schemaversion = schemaversionElement.textContent;
            } else {
                throw new Error('Schema version not found.');
            }

            if (resourceElement) {
                this.COURSE.href = resourceElement.getAttribute('href');
            } else {
                throw new Error('Resource element not found.');
            }

            if (titleElement) {
                this.COURSE.title = titleElement.textContent;
            } else {
                this.COURSE.title = null;
                this.showDebug('Title element not found.', 'warn');
            }

            if (manifestElement.hasAttribute('identifier')) {
                this.COURSE.identifier = manifestElement.getAttribute('identifier');
            } else {
                this.COURSE.identifier = null;                                                                          // TODO: Need to set this to something, although there should always be an identifier
                this.showDebug('Manifest identifier not found.', 'warn');
            }

            return true;
        } catch (error) {
            this.showDebug(`Error reading manifest: ${error}`, 'error');
            this.showModal('<p style="text-align:left"><strong>Error</strong>: An error occurred while attempting to read the course data.<br>Please try refreshing the page or contact support if the problem persists.</p>', 600000);
            return false;
        }
    }

    #injectCSS() {
        document.getElementById("Course_Content").onload = function() {
            const iframe = document.getElementById("Course_Content").contentWindow.document;
            const style = iframe.createElement("style");
            // const styleText = 'body {background-color: #dcdee0} ' +
            //                   '.free-logo {cursor: default !important} ' +
            //                   '.free-logo__logo {visibility: hidden !important;} ' +
            //                   '.quiz-top-panel, .top-panel {display: none !important} ' +
            //                   '.quiz-control-panel__quiz-score-info {display: none !important}';
            const styleText = 'body {background-color: #dcdee0}' +
                              '.quiz-top-panel, .top-panel {display: none !important} ' +
                              '.quiz-control-panel__quiz-score-info {display: none !important}';
            style.innerHTML = styleText;
            iframe.head.appendChild(style);
        };
    }

    #setSCORMUser(userData) {
        const SCORM = this.PIPWERKS_SCORM;
        const fullName = `${userData.lastname},${userData.firstname}`;

        switch (SCORM.version) {
            case "1.1":
            case "1.2":
            case "2001":
                return SCORM.set("cmi.core.student_id", userData.email) &&
                       SCORM.set("cmi.core.student_name", fullName);
            case "1.3":
            case "2004":
                return SCORM.set("cmi.learner_id", userData.email) &&
                       SCORM.set("cmi.learner_name", fullName);
            default:
                return false;
        }
    }

    #showContent(target = 'Course_Content') {
        const courseTarget = document.getElementById(target);

        try {
            courseTarget.src = `${this.RSI_COURSES_PATH}/${this.COURSE.path}/${this.COURSE.href}`;
            if (this.COURSE.title !== null) document.getElementById('course_title').innerHTML = this.COURSE.title;
            this.#injectCSS();
        } catch (error) {
            this.showDebug(`Error loading course content: ${error}`, 'error');
            this.showModal("<p style='text-align:left'><strong>Error</strong>: Unable to load the course content.<br>Please try refreshing the page or contact support if the problem persists.</p>", 600000);
        }
    }

    async #saveToDB(cmi) {
        try {
            const cmiJSONString = JSON.stringify(cmi);
console.info(cmiJSONString);
            const response = await fetch(this.RSI_FUNCTIONS, {
                method: 'POST',
                headers: {
                    // 'Content-Type': 'application/x-www-form-urlencoded',
                    'Content-Type': 'application/json',
                },
				body:  new URLSearchParams({
					action:		"saveCourseData",
					cmiData:    cmiJSONString,
                    courseID:   this.COURSE.courseID,
                    identifier: this.COURSE.identifier,
				})
            });

            return await response.json();
        } catch (error) {
            this.showDebug(`Error saving the data: ${error}`, "error");
            return false;
        }
    }


    // PUBLIC METHODS //

    async create(courseID, coursePath) {
        const userData = await this.#getUserData();

        // if (!userData?.attuid && !userData?.guid) {                                                                  // Disabling - Moving all authentication to the back end
        //     this.showDebug(`Cannot fetch user data (guid: ${userData.guid})`, "error");
        //     this.showModal("<p style='text-align:left'><strong>Error</strong>: Unable to load user data.<br>Please try refreshing the page or contact support if the problem persists.</p>", 600000);
        //     return false;
        // }

        this.USER_DATA = userData;
        const response = await this.#getManifest(coursePath);
        const manifest = await this.#processManifest(response);
        const SCORM = this.PIPWERKS_SCORM;
        const COURSE = this.COURSE;
        const validVersions = ["1.2", "2004", "1.3", "2001"];                                                           // 1.2 & 2001, and 1.3 & 2004 are the same

        if (!response.ok) {
            return false;
        }
        else if (!manifest) {
            return false;
        }

        COURSE.path = coursePath;
        COURSE.courseID = courseID;
        COURSE.validVersion = validVersions.filter(keyword => COURSE.schemaversion.includes(keyword));

        if (COURSE.schema !== "ADL SCORM") {
            this.showDebug(`The course is not a valid SCORM Package (${COURSE.schema}). Aborting.`);
            this.showModal('<p style="text-align:left"><strong>Error</strong>: The course is not a valid SCORM package. Please contact support.', 600000);
            return false;
        }
        else if (!COURSE.validVersion.length) {
            this.showDebug(`The SCORM Package is not a valid version (${COURSE.schemaversion}). Aborting.`);
            this.showModal('<p style="text-align:left"><strong>Error</strong>: The course is not a valid SCORM version. Please contact support.', 600000);
            return false;
        }

        SCORM.version = COURSE.validVersion[0];                                                                         // Theoretically there should only ever be 1 value, so we'll just grab the first one

        if (!SCORM.init()) {                                                                                            // Initialize the SCORM wrapper
            this.showDebug("SCORM Wrapper initialization failed.", "error");
            this.showModal("<p style='text-align:left'><strong>Error</strong>: Unable to initialize training module.<br>Please try refreshing the page or contact support if the problem persists.</p>", 600000);
            SCORM.quit();
            return false;
        }

        localStorage.setItem('userData', JSON.stringify(userData));
        const success =  this.#setSCORMUser(userData);

        if (!success) {
            this.showDebug("Failed to set SCORM data", "error");
            this.showModal("<p style='text-align:left'><strong>Error</strong>: Unable to set the training data.<br>Please try refreshing the page or contact support if the problem persists.</p>", 600000);
            SCORM.quit();
            return false;
        }

        if (!SCORM.save()) {
            this.showDebug("Failed to save SCORM data", "error");
            this.showModal("<p style='text-align:left'><strong>Error</strong>: Unable to save training progress.<br>Please try refreshing the page or contact support if the problem persists.</p>", 600000);
            SCORM.quit();
            return false;
        }

        this.#showContent();
    }

    saveCourse(cmi, writeToDB = true) {
        if (writeToDB === true) { this.#saveToDB(cmi); }
        this.saveLocal(cmi);
        this.showDebug(cmi);
    }

    saveLocal(cmi) {
// console.warn('TrainingModule.saveLocal()');
        localStorage.setItem('cmiData', JSON.stringify(cmi));

    }

    close(cmi) {
        // localStorage.removeItem('cmiData');
        this.saveCourse(cmi);
        this.PIPWERKS_SCORM.connection.isActive = false;
    }

    showModal(message = null, delay = 3000) {
        if (!message) return;

        if (document.querySelector('.modal')) {
            document.querySelector('.modal').remove();
            document.querySelector('.modal-overlay')?.remove();
        }

        const modal = document.createElement('div');
        modal.classList.add('modal');

        const messageElement = document.createElement('p');
        messageElement.innerHTML = message;
        modal.appendChild(messageElement);

        const overlay = document.createElement('div');
        overlay.classList.add('modal-overlay');

        document.body.appendChild(overlay);
        document.body.appendChild(modal);

        setTimeout(() => {
            overlay.remove();
            modal.remove();
        }, delay);
    }

    showDebug(message = null, type = "log") {
        if (!message || !this.DEBUG_MODE) return;

        switch (type) {
            case "info":
                console.info(message);
                break;
            case "warn":
                console.warn(message);
                break;
            case "error":
                console.error(message);
                break;
            default:
                console.log(message);
                break;
        }
    }

}
