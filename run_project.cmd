@echo off
REM ------------------------------------------------------------
REM Script Name  : run_project.cmd
REM Description  : Opens two command prompt windows
REM               - "Backend" for Django server
REM               - "Frontend" for React/Vue/Angular (npm run dev)
REM ------------------------------------------------------------

:: Start Backend (Django) server in a new command prompt window
start "Backend" cmd /K "python manage.py runserver"

:: Start Frontend (npm) server in another new command prompt window
start "Frontend" cmd /K "cd /d admin-panel && npm run dev"

exit
