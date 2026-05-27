from django.contrib import admin
from django.urls import path, include

from apps.users.views.auth_views import RequestOTPView, VerifyOTPLoginView, SendEmailVerificationView, VerifyEmailView

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # API endpoints
    path('api/users/', include('apps.users.urls')),
    path('api/household/', include('apps.household.urls')),
    path('api/subspace/', include('apps.subspace.urls')),
    
    # Unified Auth API
    path('dj-rest-auth/', include('dj_rest_auth.urls')),
    path('dj-rest-auth/registration/', include('dj_rest_auth.registration.urls')),
    
    # Google Social Login API (REQUIRED for dj-rest-auth to talk to Google)
    path('dj-rest-auth/google/', include('dj_rest_auth.registration.urls')), 
    
    # Custom OTP and Email Verification endpoints
    path('otp/request/', RequestOTPView.as_view(), name='request-otp'),
    path('otp/verify/', VerifyOTPLoginView.as_view(), name='verify-otp'),
    path('email/verify/send/', SendEmailVerificationView.as_view(), name='send-email-verify'),
    path('email/verify/', VerifyEmailView.as_view(), name='verify-email'),
    ]