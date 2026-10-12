@echo off
cd /d "%~dp0"
echo Starting the local app and Ollama bridge at http://127.0.0.1:4173
echo Keep this window open while using the app. Press Ctrl+C to stop the server.
node server.js
if errorlevel 1 (
  echo.
  echo The local app server stopped with an error. Check that Node.js is installed
  echo and that port 4173 is available.
  pause
)
