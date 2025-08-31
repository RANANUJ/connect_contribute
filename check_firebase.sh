#!/bin/bash

# Firebase OTP Quick Check Script
# Run this after completing Firebase Console setup

echo "🔥 Firebase OTP Configuration Checker"
echo "======================================"

echo ""
echo "📋 Your App Details:"
echo "Project ID: ngo-app-4e7a9"
echo "Package: com.example.connect_contribute"  
echo "SHA-1: E1:C4:DC:6C:C3:D1:C9:16:42:D5:0C:65:C3:4A:52:F4:DF:9E:00:8E"

echo ""
echo "✅ Manual Checklist - Verify in Firebase Console:"
echo "1. [ ] SHA-1 fingerprint added to Firebase project"
echo "2. [ ] Phone authentication enabled"
echo "3. [ ] Blaze plan active"
echo "4. [ ] Updated google-services.json downloaded"
echo "5. [ ] Rate limit cooldown period completed (1-2 hours)"

echo ""
echo "🧪 Testing Commands:"
echo "flutter clean"
echo "flutter pub get"
echo "flutter run"

echo ""
echo "🔍 Watch for these in debug console:"
echo "SUCCESS: 'OptimizedAuthService: Code sent, verification ID'"
echo "FIXED: No more 'INVALID_CERT_HASH' errors"
echo "FIXED: No more 'reCAPTCHA token' errors"

echo ""
echo "📱 Test with Firebase test numbers first!"
echo "Add +916230278253 -> 123456 in Firebase Console for safe testing"
