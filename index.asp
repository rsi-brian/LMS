<!--#include VIRTUAL = "/training/scripts/functions.asp"-->
<html lang="en">
<head>
	<title>RS&I Training</title>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<link rel="stylesheet" href="https://use.typekit.net/mbs4iof.css">
	<link rel="stylesheet" href="css/training_250321.min.css">
</head>
<body class="lms-home">

	<header class="flex flex-between">
		<img id="RSI_logo" src="/home/images/RSI/logos/RSI_white_md.png" alt="RS&I, Inc.">
		<div id="course_title">RS&amp;I Training System</div>
		<div id="user_menu" style="text-align:center;">
			<!-- Logged in as<br><br> -->
		</div>
	</header>

	<div class="lms-content">
		<!-- <div class="greeting">
			Welcome, !
		</div> -->

		<h3>Your Available Courses:</h3>
		<div class="available-courses flex">
			<% showCourses %>
		</div>
	</div>


	<footer>
		<div class="top flex flex-between">
			<div>
				<p><a class="bold" href="/home/about-rsi.asp#rsi_map"><strong>Branch Locations</strong></a></p>
				<p><a class="bold" href="/home/about-rsi.asp#contact-us"><strong>Contact Us</strong></a></p>
				RS&amp;I Corporate Phone Number: <strong><a href="tel:+12085235721">1.208.523.5721</a></strong><br>
				Corporate Headquarters: <strong><a href="https://goo.gl/maps/2k68yAvL3rEJN3uG7" target="_blank">2436 N Woodruff Ave, Idaho Falls, ID 83401</a></strong>
			</div>
			<div>
				<p>
					<a href="//blog.rsiinc.com">Blog</a><br>
					<a href="/home/careers.asp">Careers</a><br>
					<a href="/home/submit-a-testimony.asp">Share Your Success Story</a><br>
					<a href="/home/linktree.asp">Social Media Linktree</a><br>
				</p>
			</div>
			<div class="social-icons">
				<a href="https://www.facebook.com/rsidistributor" target="_blank" rel="nofollow">
					<img src="/home/images/icons/Facebook.png" alt="Facebook icon"></a>
				<a href="https://www.instagram.com/rsidistributor" target="_blank" rel="nofollow">
					<img src="/home/images/icons/Instagram.png" alt="Instagram icon"></a>
				<a href="https://www.linkedin.com/company/rs%26i" target="_blank" rel="nofollow">
					<img src="/home/images/icons/LinkedIn.png" alt="LinkedIn icon"></a>
				<a href="https://x.com/rsidistributor" target="_blank" rel="nofollow">
					<img src="/home/images/icons/Twitter-X_white.png" alt="Twitter icon"></a>
			</div>
		</div>
		<div class="bottom flex flex-between">
			<div class="copyright">Copyright <span class="rsi-copyright-date">2000-2025</span> RS&amp;I. All rights reserved.</div>
			<div class="img-container">
				<a href="/home/index.asp">
					<img class="logo" src="/home/images/RSI/logos/RSI_white_md.png" alt="RS&amp;I logo">
				</a>
			</div>
			<div class="legaleze">
				<a href="/home/terms-of-use.asp">Terms of Use</a> |
				<a href="/home/privacy-policy.asp">Privacy Policy</a> |
				<a href="/home/sitemap.asp">Site Map</a>
			</div>
		</div>
	</footer>

	<script src="scripts/lms.js" type="module"></script>
</body>
</html>