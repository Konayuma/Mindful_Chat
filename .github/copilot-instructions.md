<!-- Use this fi- [x] Customize the Project
	<!--
	V- [x] Create and Run Task
	<!--
	Verify that all previous steps have been completed.
	Check https://code.visualstudio.com/docs/debugtest/tasks to determine if the project needs a task. If so, use t- [x] Launch the Project
	<!--
	Verify the create_and_run_task to create and launch a task based on package.json, README.md, and project structure.
	Skip this step otherwise.
	 -->

- [x] Launch the Projectat all previous steps have been completed.
	Prompt user for debug mode, launch only if confirmed.
	 -->

- [x] Ensure Documentation is Complete previous steps have been completed successfully and you have marked the step as completed.
	Develop a plan to modify codebase according to user requirements.
	Apply modifications using appropriate tools and user-pr- [x] Install Required Extensions
	<!-- ONLY install extensions provided references.
	Skip this step for "Hello World" projects.
	-->

- [x] Install Required Extensionsvided mentione- [x] Compile the Project
	<!--
	Verify that all previous steps have been completed.
	Install any missing dependencies.
	Run diagnostics and in the get_project_setup_info. Skip this step otherwise and mark as completed. -->

- [x] Compile the Project resolve any issues.
	Check for markdown files in project folder for relevant instructions on how to do this.
	-->

- [x] Create and Run Taskace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->
- [x] Verify that the copilot-instructions.md file in the .github directory is created.

- [x] Clarify Project Requirements
	<!-- Flutter mobile app for mental health - completed -->

- [x] Scaffold the Project
	<!--
	Ensure that the previous step has been marked as completed.
	Call project setup tool with projectType parameter.
	Run scaffolding command to create project files and folders.
	Use '.' as the working directory.
	If no appropriate projectType is available, search documentation using available tools.
	Otherwise, create the project structure manually using available file creation tools.
	-->

- [x] Customize the Project
	<!-- Completed: Authentication flow screens created from Figma designs, Firebase backend implemented -->

- [x] Install Required Extensions
	<!-- No extensions required for Flutter project -->

- [x] Compile the Project
	<!-- All authentication screens compile successfully with Supabase integration. Removed all Firebase files including google-services.json, firebase.json, firestore files. -->

- [x] Create and Run Task
	<!-- Task "Flutter: Run App" is available. App is currently building after cleaning corrupted cache. -->

- [ ] Launch the Project
	<!-- 
	⚠️ IMPORTANT REMINDERS:
	1. App is building - first build takes 3-5 minutes
	2. Before testing auth, user MUST run supabase_schema.sql in Supabase Dashboard:
	   - Go to https://wlpuqichfpxrwchzrdzz.supabase.co
	   - Click "SQL Editor" → "New query"
	   - Copy all from supabase_schema.sql
	   - Paste and run
	   - Wait for "Success. No rows returned"
	3. Then test: Sign up → Check Supabase Dashboard → Sign in
	 -->

- [ ] Ensure Documentation is Complete
	<!--
	Verify that all previous steps have been completed.
	Verify that README.md and the copilot-instructions.md file in the .github directory exists and contains current project information.
	Clean up the copilot-instructions.md file in the .github directory by removing all HTML comments.
	 -->