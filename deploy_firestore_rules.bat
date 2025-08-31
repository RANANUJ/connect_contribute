@echo off
echo Deploying updated Firestore security rules...
echo.

REM Copy the rules to the proper location
copy firestore_rules.txt firestore.rules

REM Deploy using Firebase CLI
firebase deploy --only firestore:rules

echo.
echo Firestore rules deployment completed!
echo.
echo The updated rules now include:
echo - users collection (user can read/write their own document)
echo - userStats collection (user can read/write their own stats)
echo - ngos collection (NGO can read/write their own document + public read)
echo - donation_requests collection (authenticated users can read/write)
echo - volunteer_opportunities collection (authenticated users can read/write)
echo.
pause
