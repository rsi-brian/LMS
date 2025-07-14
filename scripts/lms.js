'use strict';

// The user will be logged in at this point, so show their available courses

class LMS {
    constructor() {
        this.courses = [];
    }
    
    
}

document.querySelectorAll('.course-container').forEach(container => {
    container.addEventListener('click', () => {
        const courseId = container.dataset.courseId;
        const target = container.dataset.targetCourse;
        window.location.href = `course.asp?courseid=${courseId}&name=${target}`;
    });
});
