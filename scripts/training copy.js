// Initialize training progress
async function initializeTraining() {
    const userId = getCurrentUserId(); // Get from your auth system
    const courseId = 'course-123'; // Your course identifier
    
    try {
        const response = await fetch('progress_initialize.asp', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: `userId=${userId}&courseId=${courseId}`
        });
        console.log('Training initialized');
    } catch (error) {
        console.error('Failed to initialize training:', error);
    }
}

// Save progress
async function saveProgress(page, score) {
    const userId = getCurrentUserId();
    const courseId = 'course-123';
    
    try {
        await fetch('progress_save.asp', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: `userId=${userId}&courseId=${courseId}&lastPage=${page}&score=${score}`
        });
    } catch (error) {
        console.error('Failed to save progress:', error);
    }
}

// Complete the course
async function completeCourse() {
    const userId = getCurrentUserId();
    const courseId = 'course-123';
    
    try {
        await fetch('progress_complete.asp', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: `userId=${userId}&courseId=${courseId}`
        });
    } catch (error) {
        console.error('Failed to complete course:', error);
    }
}

// Get current progress
async function getProgress() {
    const userId = getCurrentUserId();
    const courseId = 'course-123';
    
    try {
        const response = await fetch(`progress_get.asp?userId=${userId}&courseId=${courseId}`);
        return await response.json();
    } catch (error) {
        console.error('Failed to get progress:', error);
        return null;
    }
}

// Initialize when page loads
// window.onload = initializeTraining;
