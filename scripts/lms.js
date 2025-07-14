'use strict';

document.querySelectorAll('.course-container').forEach(container => {
    container.addEventListener('click', () => {
        const courseId = container.dataset.targetCourse;
        window.location.href = `course.asp?courseid=${courseId}`;
    });
});
