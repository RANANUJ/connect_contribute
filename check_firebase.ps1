# Firebase OTP Quick Check Script (PowerShell)
# Run this after completing Firebase Console setup

Write-Host "🔥 Firebase OTP Configuration Checker" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "📋 Your App Details:" -ForegroundColor Yellow
Write-Host "Project ID: ngo-app-4e7a9"
Write-Host "Package: com.example.connect_contribute"  
Write-Host "SHA-1: E1:C4:DC:6C:C3:D1:C9:16:42:D5:0C:65:C3:4A:52:F4:DF:9E:00:8E"

Write-Host ""
Write-Host "✅ Manual Checklist - Verify in Firebase Console:" -ForegroundColor Green
Write-Host "1. [ ] SHA-1 fingerprint added to Firebase project"
Write-Host "2. [ ] Phone authentication enabled"
Write-Host "3. [ ] Blaze plan active"
Write-Host "4. [ ] Updated google-services.json downloaded"
Write-Host "5. [ ] Rate limit cooldown period completed (1-2 hours)"

Write-Host ""
Write-Host "🧪 Testing Commands:" -ForegroundColor Magenta
Write-Host "flutter clean"
Write-Host "flutter pub get"
Write-Host "flutter run"

Write-Host ""
Write-Host "🔍 Watch for these in debug console:" -ForegroundColor Blue
Write-Host "SUCCESS: 'OptimizedAuthService: Code sent, verification ID'" -ForegroundColor Green
Write-Host "FIXED: No more 'INVALID_CERT_HASH' errors" -ForegroundColor Green
Write-Host "FIXED: No more 'reCAPTCHA token' errors" -ForegroundColor Green

Write-Host ""
Write-Host "📱 Test with Firebase test numbers first!" -ForegroundColor Yellow
Write-Host "Add +916230278253 -> 123456 in Firebase Console for safe testing"

Write-Host ""
Write-Host "🌐 Firebase Console Link:" -ForegroundColor Cyan
Write-Host "https://console.firebase.google.com/project/ngo-app-4e7a9"
