from django.contrib import admin
from django.urls import path, include


urlpatterns = [
    path('admin/', admin.site.urls),
    
    # API endpoints
    path('api/users/', include('apps.users.urls')),
    path('api/household/', include('apps.household.urls')),
    path('api/subspace/', include('apps.subspace.urls')),
    
    ]