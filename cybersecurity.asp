<!--#include virtual = "/includes/serverinit.asp"-->
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RS&I Training</title>
    <link rel="stylesheet" href="css/training.min.css">
</head>
<body id="training_course">

    <header class="flex flex-between">
        <a href="/training/index.asp">
            <img id="RSI_logo" src="/home/images/RSI/logos/RSI_white_md.png" alt="RS&I, Inc.">
        </a>
        <div id="course_title">RS&amp;I Training System</div>
        <div id="user_menu">Welcome, <%=UserName%><br></div>
    </header>
    <iframe id="Intro_to_Cybersecurity" width="100%" allowfullscreen></iframe>

    <script type="module">
        import { showContent } from './js/course.js';
        showContent('RS&I Cybersecurity Overview', 'Intro_to_Cybersecurity');
    </script>
    <script src="js/SCORM_API.js" type="module"></script>
</body>
</html>