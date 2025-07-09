'use strict';

const DEBUG_MODE = false;
if (typeof pipwerks !== "undefined") pipwerks.debug.isActive = DEBUG_MODE;

const RSI_TRAINING_PATH = '/training';
const RSI_COURSES_PATH = `${RSI_TRAINING_PATH}/courses`;
const RSI_FUNCTIONS = `${RSI_TRAINING_PATH}/scripts/functions.asp`;

async function initSCORM(path) {
    const courseData = await getCourseData(path);
    const validVersions = ["1.2", "2004"];

    if (!courseData) {
        showDebug(`Course does not exist or could not find imsmanifest.xml at ${RSI_COURSES_PATH}/${path}. Aborting.`, 'error');
        showModal("Error: The course could not be found. Please try refreshing the page or contact support if the problem persists.", 600000);
        return false;
    }

    if (courseData.schema !== "ADL SCORM") {
        showDebug(`The course is not a valid SCORM Package (${courseData.schema}). Aborting.`);
        return false;
    }

    courseData.validVersion = validVersions.filter(keyword => courseData.schemaversion.includes(keyword));

    if (!courseData.validVersion) {
        showDebug(`The SCORM Package is not a valid version (${courseData.schemaversion}). Aborting.`);
        return false;
    }

    const scorm = pipwerks.SCORM;
    scorm.version = courseData.validVersion[0];                                                                         // Theoretically there should only ever be 1 value, so we'll just grab the first one
    const isInitialized = scorm.init();

    if (!isInitialized) {
        showDebug("SCORM initialization failed!", "error");
        showModal("Error: Unable to initialize training module. Please try refreshing the page or contact support if the problem persists.", 600000);
        return false;
    }
    // else {
    //     showDebug("SCORM initialization SUCCESS");
    // }

    // showDebug("Fetching User Data");
    try {
        const userData = await getUserData();

        // Validate userData
        if (!userData || !userData.guid || !userData.fullname) {
            showDebug("User data is incomplete or invalid", "error");
            showModal("Error: Unable to load user data. Please try refreshing the page or contact support if the problem persists.", 600000);
            scorm.quit();
            return false;
        }

        // Store in localStorage as backup
        localStorage.setItem('userData', JSON.stringify(userData));
        // showDebug("==========================================");
        // showDebug("SHOWING userData & scorm from getUserData() response:");
        // showDebug(userData, "info");
        // showDebug(scorm, "info");
        // showDebug("==========================================");

        // Store in SCORM
        const success = scorm.set("cmi.core.student_id", userData.guid) &&
                        scorm.set("cmi.core.student_name", userData.fullname) &&
                        // scorm.set("cmi.core.lesson_status", "incomplete") &&
                        scorm.set("cmi.core.lesson_location", "");

        if (!success) {
            showDebug("Failed to set SCORM data", "error");
            showModal("Error: Unable to set the training data. Please try refreshing the page or contact support if the problem persists.", 600000);
            scorm.quit();
            return false;
        }

        // Save changes
        if (!scorm.save()) {
            showDebug("Failed to save SCORM data", "error");
            showModal("Error: Unable to save training progress. Please try refreshing the page or contact support if the problem persists.", 600000);
            scorm.quit();
            return false;
        }

        // showDebug("SCORM Data saved successfully", "info");
        return courseData;
    } catch (error) {
        showDebug("Failed to get user data: " + error, "error");
        showModal("Error: Unable to retrieve user information. Please try refreshing the page or contact support if the problem persists.", 600000);
        scorm.quit();
        return false;
    }
}

function getUserData() {
    return fetch(RSI_FUNCTIONS, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'action=getUserData'
    })
    .then(response => response.json())
    .then(data => {
        // showDebug("======================================================");
        // showDebug("SHOWING DATA FROM getUserData():");
        // showDebug(data);
        // showDebug("======================================================");
        return data;
    })
    .catch(error => {
        showDebug(`Error getting user data: ${error}`, "error");
        return false;
    });
}

async function getCourseData(path) {
    try {
        let courseData = {};

        // try {
            const response = await fetch(`${RSI_COURSES_PATH}/${path}/imsmanifest.xml`);
            
            if (!response.ok) {
                throw new Error(response.status);
            }
        // }
        // catch (error) {
        //     showDebug("Course does not exist. " + error, "error");
        //     showModal("Error: That course does not exist. Please try refreshing the page or contact support if the problem persists.", 600000);
        //     return false;
        // }
        
        const xmlText = await response.text();
        
        // Parse the XML string
        const parser = new DOMParser();
        const xmlDoc = parser.parseFromString(xmlText, 'text/xml');

        // Get the course's properties
        const resourceElement = xmlDoc.querySelector('resources > resource');
        const schemaElement = xmlDoc.querySelector('metadata > schema');
        const schemaversionElement = xmlDoc.querySelector('metadata > schemaversion');
        const titleElement = xmlDoc.querySelector('organizations > organization > title');

        courseData.path = path;

        if (schemaElement) {
            courseData.schema = schemaElement.textContent;
        } else {
            showDebug('Schema element not found in manifest', 'error');
            return false;
        }

        if (schemaversionElement) {
            courseData.schemaversion = schemaversionElement.textContent;
        } else {
            showDebug('Schema version not found in manifest', 'error');
            return false;
        }

        if (resourceElement) {
            courseData.href = resourceElement.getAttribute('href');
        } else {
            showDebug('Resource element not found in manifest', 'error');
            return false;
        }

        if (titleElement) {
            courseData.title = titleElement.textContent;
        } else {
            courseData.title = null;
            showDebug('Title element not found in manifest', 'error');
        }

        return courseData;
    } catch (error) {
        showDebug(`Error reading manifest: ${error}`, 'error');
        return false;
    }
}

function showContent(SCORMData, target) {
    const courseTarget = document.getElementById(target);

    if (SCORMData) {
        try {
            courseTarget.src = `${RSI_COURSES_PATH}/${SCORMData.path}/${SCORMData.href}`;
            document.getElementById('course_title').innerHTML = SCORMData.title;
        } catch (error) {
            showDebug(`Error loading course content: ${error}`, 'error');
            showModal("Error: Unable to load the course content. Please try refreshing the page or contact support if the problem persists.", 600000);
        }
    } else {
        showDebug('Course content not found', 'error');
        showModal("Error: Course content not found. Please try refreshing the page or contact support if the problem persists.", 600000);
    }
}

function showModal(message = null, delay = 3000) {
    if (!message) return;

    // Remove existing modal and overlay if they exist
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

function showDebug(message = null, type = "log") {
    if (!message || !DEBUG_MODE) return;

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




// EVENT LISTENERS

// Add click handlers for course containers on LMS home page
// if (document.querySelector('.lms-home')) {
//     document.querySelectorAll('.course-container').forEach(container => {
//         container.addEventListener('click', () => {
//             const courseId = container.dataset.targetCourse;
//             window.location.href = `course.asp?courseid=${courseId}`;
//         });
//     });
// }

// if (document.querySelector('body#training_course')) {

    document.addEventListener('DOMContentLoaded', async function() {
        try {
            const urlParams = new URLSearchParams(window.location.search);
            const courseName = urlParams.get('courseid');
            const SCORMData = await initSCORM(courseName);

            if (SCORMData) {
                showContent(SCORMData, 'Course_Content');
console.info(SCORMData);
            }
            else {
                throw new Error("Error during initialization.");
            }
        } catch (error) {
            showDebug(error, "error");
        }
    });

    // Prevent back/forward navigation on the training course pages
    window.history.pushState({page: 1}, "", window.location.href);

    // Push the state back to prevent navigation so it stays on the same page
    window.addEventListener('popstate', function(event) {
        window.history.pushState({page: 1}, "", window.location.href);
        showModal('<strong>Please note:</strong><br>The back and forward navigation buttons have been disabled for the purpose of this course.', 5000);
    });

    // Handle clicks on the browser's back button
    window.addEventListener('load', function() {
        history.pushState(null, null, location.href);
    }, false);

    // When user leaves/closes the page
    window.addEventListener('beforeunload', function() {
        const scorm = pipwerks.SCORM;
        if (scorm.connection.isActive) {
            scorm.save();
            scorm.quit();
        }
    });
// }