@echo off
setlocal EnableExtensions EnableDelayedExpansion
REM Local Agentia quality gates (Windows). Agentia runs this from the repo root during
REM `agentia cicd work test` and before `agentia cicd work submit`. Exit non-zero to stop.

REM >>> agent-passport (managed by `agentia passport setup`; edit with setup, not by hand) >>>
REM Agent Passport: the agent must hold a current, granted stamp before this story moves on.
echo ## Agent Passport: verifying the agent
call agentia passport verify --env Passport-Dev --agent CustomerServiceAgent --travel-to Passport-QA
if errorlevel 1 exit /b %errorlevel%
REM <<< agent-passport <<<
