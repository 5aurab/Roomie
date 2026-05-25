from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # API endpoints
    path('api/users/', include('apps.users.urls')),
    path('api/household/', include('apps.household.urls')),
    
    # Unified Auth API
    path('dj-rest-auth/', include('dj_rest_auth.urls')),
    path('dj-rest-auth/registration/', include('dj_rest_auth.registration.urls')),
    
    # Google Social Login API (REQUIRED for dj-rest-auth to talk to Google)
    path('dj-rest-auth/google/', include('dj_rest_auth.registration.urls')), 
]